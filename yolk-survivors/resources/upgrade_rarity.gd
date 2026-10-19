extends RefCounted
## Cumulative probabilities: P(Rare+), P(Epic+), P(Legendary).
## Level-up offers only: actual character level, including refreshes.
## Base curve without Luck; 1-2 Common, Rare 3+, Epic 10+, Legendary 15+.
const LAST_BASE_LEVEL := 20
const STARTS := [3, 10, 15]
const CAPS := [0.60, 0.20, 0.05]

static func cumulative(character_level: int) -> Array[float]:
	var level := clampi(character_level, 1, LAST_BASE_LEVEL)
	var values: Array[float] = []
	for index in 3:
		values.append(0.0 if level < STARTS[index] else minf(CAPS[index], CAPS[index] * float(level - STARTS[index] + 1) / float(LAST_BASE_LEVEL - STARTS[index] + 1)))
	return values

static func probabilities(character_level: int) -> Array[float]:
	var c := cumulative(character_level)
	return [1.0 - c[0], c[0] - c[1], c[1] - c[2], c[2]]

## Convert cumulative caps into conditional chances, then roll high to low.
## At caps: Legendary 5%; Epic 15/95%; Rare 40/80%; residual Common 40%.
static func roll_tier(character_level: int, random: RandomNumberGenerator = null) -> int:
	var c := cumulative(character_level)
	var legendary_roll := random.randf() if random else randf()
	if legendary_roll < c[2]: return 3
	var epic_roll := random.randf() if random else randf()
	if epic_roll < (c[1] - c[2]) / (1.0 - c[2]): return 2
	var rare_roll := random.randf() if random else randf()
	if rare_roll < (c[0] - c[1]) / (1.0 - c[1]): return 1
	return 0
