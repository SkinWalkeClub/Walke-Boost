# Walke Boost

A client-side FPS optimizer that's **reversible**. Turn it on to strip everything expensive off your render; turn it off and the game looks *exactly* like it did before — because it snapshots every value it touches and puts them back.

Most "fps boost" scripts nuke your game one-way and you have to rejoin to undo them. This one has a real off switch.

## Why it's different

- **Reversible** — every changed property is saved and restored on `Boost.restore()`. No rejoin to undo.
- **Live** — parts that stream in *after* you turn it on get optimized too (hooks `DescendantAdded`).
- **Granular + presets** — flip individual systems, or use `potato` / `low` / `balanced`.
- **Only touches rendering** — never game logic, so it won't break the game you're in.

## Load it

```lua
local Boost = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkinWalkeClub/Walke-Boost/main/boost.lua"))()
```

## Use it

```lua
Boost.apply("low")     -- potato | low | balanced
-- ...
Boost.restore()        -- puts everything back exactly as it was
Boost.toggle("low")    -- on/off in one call
```

Custom mix instead of a preset:

```lua
Boost.apply({
	particles = true,   -- disable ParticleEmitter/Trail/Beam/Smoke/Fire/Sparkles
	materials = true,   -- all parts -> SmoothPlastic
	reflect   = true,   -- Reflectance -> 0
	shadows   = true,   -- CastShadow off + Lighting.GlobalShadows off
	textures  = true,   -- decals/textures hidden
	meshDetail= true,   -- MeshPart RenderFidelity -> Performance
	postfx    = true,   -- Bloom/Blur/DoF/SunRays/ColorCorrection off
	terrain   = true,   -- grass decoration + water waves off
	atmosphere= true,   -- fog pulled in, Atmosphere density 0
	quality   = true,   -- settings().Rendering.QualityLevel -> Level01
	fps       = 0,      -- setfpscap value (0 = uncap), if your executor has it
	destroy   = false,  -- true = DELETE particles/decals instead of hiding (NOT reversible)
})
```

## Live FPS readout

```lua
Boost.monitor(function(fps) print("fps:", fps) end)
```

## Presets

| preset | what |
|---|---|
| `potato` | everything on **+ destroy** (max fps, irreversible parts) |
| `low` | everything on, reversible |
| `balanced` | particles, shadows, post-fx, terrain, atmosphere — keeps textures/materials |

## Notes

- `destroy = true` deletes decals/particles/SurfaceAppearance instead of hiding them — that part can't be restored, so it's off by default.
- `quality` and `fps` need `settings()` access and `setfpscap` respectively; if your executor doesn't expose them, those steps are skipped silently and the rest still runs.
- Everything is `pcall`-guarded — a property that doesn't exist on some class won't stop the pass.

## License

MIT — Weegee_MLG / The Skin Walke Team.
