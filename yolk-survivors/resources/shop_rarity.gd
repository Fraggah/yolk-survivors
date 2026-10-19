extends RefCounted
## Cumulative probabilities: P(Rare+), P(Epic+), P(Legendary).
## Base progression only. Luck calibration has deliberately not been enabled.
const LAST_BASE_WAVE := 20
const STARTS := [2, 9, 15]
const CAPS := [0.60, 0.20, 0.05]

static func cumulative(completed_wave: int) -> Array[float]:
	var wave := clampi(completed_wave, 1, LAST_BASE_WAVE)
	var values: Array[float] = []
	for index in 3:
		values.append(0.0 if wave < STARTS[index] else minf(CAPS[index], CAPS[index] * float(wave - STARTS[index] + 1) / float(LAST_BASE_WAVE - STARTS[index] + 1)))
	return values

static func probabilities(completed_wave: int) -> Array[float]:
	var c := cumulative(completed_wave)
	return [1.0 - c[0], c[0] - c[1], c[1] - c[2], c[2]]

## Convert cumulative caps into conditional chances, then roll high to low.
## At caps: Legendary 5%; Epic 15/95%; Rare 40/80%; residual Common 40%.
static func roll_tier(completed_wave: int, random: RandomNumberGenerator = null) -> int:
	var c := cumulative(completed_wave)
	var legendary_roll := random.randf() if random else randf()
	if legendary_roll < c[2]: return 3
	var epic_roll := random.randf() if random else randf()
	if epic_roll < (c[1] - c[2]) / (1.0 - c[2]): return 2
	var rare_roll := random.randf() if random else randf()
	if rare_roll < (c[0] - c[1]) / (1.0 - c[1]): return 1
	return 0
