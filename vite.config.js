import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { execFile } from 'node:child_process'

function gitPullApi() {
  return {
    name: 'git-pull-api',
    configureServer(server) {
      server.middlewares.use('/api/git-pull', (req, res) => {
        if (req.method !== 'POST') {
          res.statusCode = 405
          res.setHeader('Allow', 'POST')
          res.end('Method Not Allowed')
          return
        }
        execFile('git', ['pull', '--ff-only'], { cwd: process.cwd() }, (err, stdout, stderr) => {
          res.setHeader('Content-Type', 'application/json')
          res.statusCode = err ? 500 : 200
          res.end(JSON.stringify({
            ok: !err,
            code: err ? err.code ?? 1 : 0,
            stdout,
            stderr,
          }))
        })
      })
    },
  }
}

export default defineConfig({
  plugins: [react(), gitPullApi()],
  base: '/',
})
