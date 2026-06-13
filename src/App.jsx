import { useEffect } from 'react'
import './App.css'

export default function App() {
  useEffect(() => {
    if (document.getElementById('chatbot')) return
    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = 'https://res.public.onecdn.static.microsoft/customerconnect/v1/7dttl/init.js'
    script.id = 'chatbot'
    script.setAttribute('environmentId', 'cc734fba-a619-eb45-a69a-079ec1c89709')
    script.region = 'unitedstates'
    script.crossOrigin = 'anonymous'
    document.body.appendChild(script)
  }, [])

  return (
    <div className="page">
      <video
        className="bg-video"
        src="/waterfall.mp4"
        autoPlay
        loop
        muted
        playsInline
        preload="auto"
        aria-hidden="true"
      />
      <div className="bg-veil" aria-hidden="true" />

      <header className="hero">
        <h1>DHARMA JAY</h1>
        <p className="tagline">
          Be now. Remember the past, choose your future, be in the present.
          Now is the only time you have, and it is timeless.
        </p>
      </header>

      <main>
        <section className="about">
          <h2>ABOUT THE AUTHOR</h2>
          <p className="lead">An observer, facilitator and participant.</p>

          <p className="imagine-intro">Imagine&hellip;</p>
          <ul className="imagine">
            <li>&hellip; if there are more dimensions to existence beyond what we can paint with our minds.</li>
            <li>&hellip; if you could paint with more colors than what the 5-color sensory palette can offer.</li>
            <li>&hellip; if you are in control of your choices, and what life unfolds before you is based on those choices.</li>
            <li>&hellip; if we live in a reality where nothing is real, and everything is real.</li>
            <li>&hellip; if the universe is infinite, there are no limits except for those that we choose to believe in.</li>
            <li>&hellip; if we limit ourselves based on what questions we ask, what we look for, and by what answers we seek.</li>
            <li>&hellip; if you can live a lifetime in every moment.</li>
            <li>&hellip; if we are in heaven, nirvana, paradise.</li>
          </ul>

          <p className="imagine-intro">Imagine&hellip;</p>
          <p className="imagine-close">&hellip; if this is all true.</p>
        </section>

        <section className="connect">
          <h2>CONNECT</h2>
          <p>Click on the chat bubble to start a chat with me.</p>
        </section>
      </main>

      <footer className="footer">
        <p className="copyright">©2018 by Dharma Jay.</p>
      </footer>
    </div>
  )
}
