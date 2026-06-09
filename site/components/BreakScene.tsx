// The app's calm "break" landscape, recreated live in SVG + CSS — a sprout that
// grows in on load, then sways in the wind, with a glowing sun and swaying grass.
// Pure CSS animation (no JS), reduced-motion aware. An illustration, not a fake
// app window. Colours reference the --color-scene-* tokens (gate 48).

const C = (t: string) => `var(--color-scene-${t})`;

const blades = [
  { x: 150, h: 24, dur: 4.6, delay: 0.0 },
  { x: 167, h: 32, dur: 5.4, delay: 0.5 },
  { x: 234, h: 28, dur: 5.0, delay: 0.3 },
  { x: 251, h: 19, dur: 4.4, delay: 0.9 },
  { x: 221, h: 15, dur: 5.8, delay: 1.2 },
];

export default function BreakScene() {
  return (
    <figure
      aria-label="An illustration of a sprout growing in a calm golden-hour landscape — what a break feels like"
      className="relative w-full max-w-[540px] overflow-hidden rounded-[22px] md:ml-auto"
      style={{
        aspectRatio: "16 / 10",
        background: "linear-gradient(to bottom, var(--color-scene-sky-top), var(--color-scene-sky-bot))",
        boxShadow: "0 40px 80px -30px oklch(44.9% 0.087 354.4 / 0.45)",
        outline: "1px solid oklch(100% 0 0 / 0.5)",
      }}
    >
      {/* glowing sun */}
      <div className="scene-sun absolute rounded-full" style={{ width: "26%", aspectRatio: "1 / 1", top: "11%", left: "10%" }} />

      <svg className="absolute inset-0 h-full w-full" viewBox="0 0 400 250" preserveAspectRatio="xMidYMax slice" aria-hidden>
        <defs>
          <linearGradient id="leafGrad" x1="0" y1="1" x2="0" y2="0">
            <stop offset="0" style={{ stopColor: C("stem") }} />
            <stop offset="1" style={{ stopColor: C("leaf-light") }} />
          </linearGradient>
        </defs>

        {/* hills → shore → foreground ground */}
        <path d="M0 158 Q 110 118 215 152 T 400 148 L400 250 L0 250Z" style={{ fill: C("hill") }} opacity="0.6" />
        <path d="M0 178 Q 200 166 400 182 L400 250 L0 250Z" style={{ fill: C("shore") }} />
        <path d="M0 212 Q 200 205 400 214 L400 250 L0 250Z" style={{ fill: C("shore-deep") }} />

        {/* a couple of drifting gulls */}
        <g fill="none" style={{ stroke: C("bird") }} strokeWidth="1.4" strokeLinecap="round" opacity="0.5">
          <path d="M262 60 q6 -6 12 0 q6 -6 12 0" />
          <path d="M312 50 q5 -5 10 0 q5 -5 10 0" />
        </g>

        {/* swaying grass */}
        <g>
          {blades.map((b, i) => (
            <g key={i} className="blade" style={{ animationDuration: `${b.dur}s`, animationDelay: `${b.delay}s` }}>
              <path
                d={`M${b.x - 2.4} 213 Q ${b.x} ${213 - b.h} ${b.x + 3} ${211 - b.h} Q ${b.x + 4.4} ${213 - b.h + 7} ${b.x + 2} 213 Z`}
                style={{ fill: C("leaf") }}
                opacity="0.92"
              />
            </g>
          ))}
        </g>

        {/* the sprout: grows once, then sways */}
        <g className="plant-grow">
          <g className="plant-sway">
            <path d="M200 211 C 192 173 208 133 200 88" fill="none" style={{ stroke: C("stem") }} strokeWidth="7" strokeLinecap="round" />
            <g className="leaf-flutter">
              <ellipse cx="184" cy="171" rx="9" ry="22" fill="url(#leafGrad)" transform="rotate(-40 184 171)" />
              <ellipse cx="216" cy="161" rx="9" ry="22" fill="url(#leafGrad)" transform="rotate(40 216 161)" />
              <ellipse cx="189" cy="127" rx="8" ry="19" fill="url(#leafGrad)" transform="rotate(-32 189 127)" />
              <ellipse cx="211" cy="121" rx="8" ry="19" fill="url(#leafGrad)" transform="rotate(32 211 121)" />
              {/* bloom */}
              <g transform="translate(200 86)">
                {[0, 60, 120, 180, 240, 300].map((a) => (
                  <ellipse key={a} cx="0" cy="-8" rx="3.2" ry="7" style={{ fill: C("petal") }} transform={`rotate(${a})`} />
                ))}
                <circle r="4.6" style={{ fill: C("petal-core") }} />
              </g>
            </g>
          </g>
        </g>
      </svg>

      <div className="grain absolute inset-0 opacity-[0.05]" />
    </figure>
  );
}
