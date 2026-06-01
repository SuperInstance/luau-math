# luau-math

Core math library for Roblox games. Brings symmetry groups, sequences, and rhythm math to Luau.

## Features

### Symmetry (`src/Symmetry.luau`)
- **CyclicGroup** — rotations of a regular n-gon (ℤ/nℤ)
- **DihedralGroup** — rotations + reflections of a regular n-gon (D_n)
- **Burnside** — Burnside's lemma for counting distinct colorings under symmetry

### Rhythm (`src/Rhythm.luau`)
- **Tempo** — BPM ↔ milliseconds conversion
- **Polyrhythm** — LCM cycle lengths and binary patterns for polyrhythms
- **Syncopation** — Longuet-Higgins syncopation scoring
- **Groove** — Swing factor calculations
- **RhythmicEntropy** — Shannon entropy of interval distributions

### Sequence (`src/Sequence.luau`)
- **Fibonacci** — nth Fibonacci number and full sequences
- **Golden** — Golden ratio and Fibonacci spiral point generation
- **Pascal** — Pascal's triangle rows and full triangles

## Installation

### Wally
Add to your `wally.toml`:
```toml
[dependencies]
LuauMath = "superinstance/luau-math@0.1.0"
```

### Manual
Copy `src/` files into your project under `ReplicatedStorage/luau-math`.

## Usage

```lua
local Symmetry = require(path.to.luau-math.Symmetry)
local Rhythm = require(path.to.luau-math.Rhythm)
local Sequence = require(path.to.luau-math.Sequence)

-- Cyclic group Z/4Z
local c4 = Symmetry.CyclicGroup.new(4)
print(c4:compose(1, 3)) --> 0
print(c4:order())        --> 4

-- Tempo conversion
print(Rhythm.Tempo.bpmToMs(120)) --> 500

-- Fibonacci
print(Sequence.Fibonacci.nth(10)) --> 55
print(Sequence.Golden.ratio())    --> 1.6180339887499

-- Polyrhythm
local len = Rhythm.Polyrhythm.cycleLength(3, 4) --> 12

-- Burnside's lemma: 2-color necklaces with 3 beads
local orbits = Symmetry.Burnside.lemma({8, 2, 2}, 3) --> 4
```

## Testing

```bash
luau tests/run-tests.luau
```

25+ tests covering all modules.

## API Reference

### Symmetry.CyclicGroup
| Method | Description |
|--------|-------------|
| `.new(n)` | Create cyclic group of order n |
| `:elements()` | List all elements `{0, 1, ..., n-1}` |
| `:compose(a, b)` | Group operation `(a + b) mod n` |
| `:inverse(a)` | Inverse element `(n - a) mod n` |
| `:identity()` | Identity element `0` |
| `:order()` | Group order `n` |

### Symmetry.DihedralGroup
| Method | Description |
|--------|-------------|
| `.new(n)` | Create dihedral group D_n |
| `:elements()` | All 2n elements `{rotation, reflection}` |
| `:compose(a, b)` | Group multiplication |
| `:inverse(a)` | Inverse element |
| `:identity()` | Identity `{0, false}` |
| `:order()` | Group order `2n` |

### Symmetry.Burnside
| Method | Description |
|--------|-------------|
| `.lemma(fixedCounts, groupOrder)` | Count distinct orbits under group action |

### Rhythm.Tempo
| Method | Description |
|--------|-------------|
| `.bpmToMs(bpm)` | Convert BPM to milliseconds per beat |
| `.msToBpm(ms)` | Convert milliseconds to BPM |

### Rhythm.Polyrhythm
| Method | Description |
|--------|-------------|
| `.cycleLength(a, b)` | LCM of a and b |
| `.pattern(a, b)` | Binary patterns for two voices |

### Rhythm.Syncopation
| Method | Description |
|--------|-------------|
| `.score(pattern)` | Longuet-Higgins syncopation score |

### Rhythm.Groove
| Method | Description |
|--------|-------------|
| `.swingFactor(bpm, swingPercent)` | `{downbeat, upbeat}` durations in ms |

### Rhythm.RhythmicEntropy
| Method | Description |
|--------|-------------|
| `.calculate(pattern)` | Shannon entropy of inter-onset intervals |

### Sequence.Fibonacci
| Method | Description |
|--------|-------------|
| `.nth(n)` | nth Fibonacci number |
| `.sequence(count)` | First `count` Fibonacci numbers |

### Sequence.Golden
| Method | Description |
|--------|-------------|
| `.ratio()` | Golden ratio φ ≈ 1.618 |
| `.fibonacciSpiral(points)` | `{x, y, r}` spiral points |

### Sequence.Pascal
| Method | Description |
|--------|-------------|
| `.row(n)` | nth row of Pascal's triangle |
| `.triangle(rows)` | First `rows` rows |

## License

MIT
