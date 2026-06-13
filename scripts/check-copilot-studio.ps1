<#
.SYNOPSIS
  Find the Microsoft 365 / Power Platform environment + Copilot Studio agent
  that backs the chat bubble embedded on this site, and confirm whether the
  environmentId hardcoded in src/App.jsx is still live.

.DESCRIPTION
  The chat bubble in src/App.jsx loads:
      https://res.public.onecdn.static.microsoft/customerconnect/v1/7dttl/init.js
  with environmentId: cc734fba-a619-eb45-a69a-079ec1c89709 (region: unitedstates)

  This script:
    1. Installs required PowerShell modules (CurrentUser scope, no admin needed).
    2. Signs you in to Power Platform interactively.
    3. Lists all Power Platform environments in your tenant and flags the one
       matching the embedded environmentId, if any.
    4. Attempts to list Copilot Studio agents in the matched environment.
    5. Prints next steps for grabbing the live embed snippet.

  PowerShell CAN'T generate the embed snippet (init.js src + environmentId).
  For that you still need:
      https://copilotstudio.microsoft.com -> your agent -> Channels
      -> Custom website -> Copy code

.NOTES
  Requires PowerShell 7+ (pwsh). On macOS install via:  brew install --cask powershell
  Then run:                                              pwsh scripts/check-copilot-studio.ps1

  Some Power Platform admin cmdlets historically targeted Windows PowerShell.
  Recent versions (>= 2.0.180) work on PowerShell 7 cross-platform. If a cmdlet
  fails on macOS, run the script from a Windows machine signed in to the same
  tenant.
#>

[CmdletBinding()]
param(
  [string]$EmbeddedEnvironmentId = 'cc734fba-a619-eb45-a69a-079ec1c89709'
)

$ErrorActionPreference = 'Stop'

function Ensure-Module {
  param([Parameter(Mandatory)][string]$Name)
  if (-not (Get-Module -ListAvailable -Name $Name)) {
    Write-Host "Installing module: $Name" -ForegroundColor Cyan
    Install-Module -Name $Name -Scope CurrentUser -Force -AllowClobber
  } else {
    Write-Host "Module present:    $Name" -ForegroundColor DarkGray
  }
  Import-Module $Name -ErrorAction Stop
}

Write-Host "=== Step 1: install required modules ===" -ForegroundColor Yellow
Ensure-Module 'Microsoft.PowerApps.Administration.PowerShell'
Ensure-Module 'Microsoft.PowerApps.PowerShell'

Write-Host "`n=== Step 2: sign in to Power Platform (interactive) ===" -ForegroundColor Yellow
Add-PowerAppsAccount | Out-Null

Write-Host "`n=== Step 3: list environments ===" -ForegroundColor Yellow
$envs = Get-AdminPowerAppEnvironment

if (-not $envs) {
  Write-Warning "No environments returned. Sign in with the account that owns the bot tenant."
  return
}

$envs |
  Select-Object @{n='Name';         e={ $_.DisplayName }},
                @{n='EnvironmentId';e={ $_.EnvironmentName }},
                @{n='Location';     e={ $_.Location }},
                @{n='Type';         e={ $_.EnvironmentType }},
                @{n='Match';        e={ if ($_.EnvironmentName -eq $EmbeddedEnvironmentId) { 'YES <-- embedded id' } else { '' } }} |
  Format-Table -AutoSize

$match = $envs | Where-Object { $_.EnvironmentName -eq $EmbeddedEnvironmentId }

if (-not $match) {
  Write-Host "`nNo environment in this tenant matches $EmbeddedEnvironmentId." -ForegroundColor Red
  Write-Host "Likely causes:" -ForegroundColor Yellow
  Write-Host "  - The agent was moved to a new environment (snippet needs updating)."
  Write-Host "  - The agent or environment was deleted."
  Write-Host "  - You signed in to a different tenant than the one hosting the bot."
  Write-Host "`nNext step: in Copilot Studio find your agent, go to"
  Write-Host "  Channels -> Custom website -> Copy code, and replace the src +"
  Write-Host "  environmentId values in src/App.jsx (lines 9-11)."
  return
}

Write-Host "`nMatched environment: $($match.DisplayName)" -ForegroundColor Green
Write-Host "  EnvironmentId : $($match.EnvironmentName)"
Write-Host "  Location      : $($match.Location)"
Write-Host "  Type          : $($match.EnvironmentType)"

Write-Host "`n=== Step 4: list Copilot Studio agents in this environment ===" -ForegroundColor Yellow
try {
  $tokenObj = Get-PowerAppsAccessToken -Audience 'https://api.powerplatform.com/'
  $token    = $tokenObj.AccessToken
} catch {
  $token = $null
  Write-Warning "Could not obtain Power Platform API token: $($_.Exception.Message)"
}

if ($token) {
  $url = "https://api.powerplatform.com/copilot/environments/$($match.EnvironmentName)/bots?api-version=2022-03-01-preview"
  try {
    $bots = Invoke-RestMethod -Uri $url -Headers @{ Authorization = "Bearer $token" }
    if ($bots.value) {
      $bots.value |
        Select-Object name, id, botSchemaName, createdOn |
        Format-Table -AutoSize
    } else {
      Write-Host "No agents returned for this environment via the API." -ForegroundColor Yellow
    }
  } catch {
    Write-Warning "Bot list API call failed: $($_.Exception.Message)"
    Write-Host "Open https://copilotstudio.microsoft.com to list agents in this environment manually."
  }
} else {
  Write-Host "Open https://copilotstudio.microsoft.com to list agents."
}

Write-Host "`n=== Step 5: confirm / update the embed snippet ===" -ForegroundColor Yellow
Write-Host "  1. Go to https://copilotstudio.microsoft.com"
Write-Host "  2. Switch to environment: $($match.DisplayName)"
Write-Host "  3. Open your agent."
Write-Host "  4. Click Channels -> Custom website -> Copy code."
Write-Host "  5. Compare the snippet against src/App.jsx lines 9-11:"
Write-Host "       script.src           = '<init.js URL>'"
Write-Host "       environmentId        = '<GUID>'"
Write-Host "       region               = '<region>'"
Write-Host "  6. If anything differs, update src/App.jsx, commit, and push."
Write-Host "`nDone."
