extends RefCounted

const INFLATION_PERCENT_PER_WAVE := 10
const SELL_RATIO := 0.25
const FIRST_SHOP_AFFORDABLE_PRICE := 12

static func shop_price(base_price: int, completed_wave: int) -> int:
	var wave := maxi(1, completed_wave)
	# Integer arithmetic keeps flooring exact at tier/price boundaries.
	@warning_ignore("integer_division")
	var inflation := base_price * INFLATION_PERCENT_PER_WAVE * wave / 100
	return maxi(1, base_price + wave + inflation)

static func sell_price(base_price: int, completed_wave: int) -> int:
	return floori(shop_price(base_price, completed_wave) * SELL_RATIO)

static func reroll_price(completed_wave: int, rerolls: int) -> int:
	var wave := maxi(1, completed_wave)
	var increase := maxi(1, floori(wave * 0.4))
	return floori(wave * 0.75) + increase * (maxi(0, rerolls) + 1)
