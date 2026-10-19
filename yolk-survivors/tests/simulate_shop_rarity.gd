extends SceneTree
## Headless CLI: --script res://tests/simulate_shop_rarity.gd -- --samples=100000 --seed=12345
func _initialize(): call_deferred("simulate")

func simulate():
	var policy = load("res://resources/shop_rarity.gd")
	var samples := 100000
	var full_offers := false
	var random := RandomNumberGenerator.new()
	random.seed = 12345
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--samples="): samples = maxi(1000, argument.get_slice("=", 1).to_int())
		if argument.begins_with("--seed="): random.seed = argument.get_slice("=", 1).to_int()
		if argument == "--offers": full_offers = true
	seed(random.seed)
	var global = root.get_node("Global")
	var pool := []
	if full_offers:
		# Complete tier availability isolates the rarity policy from catalogue shortages.
		for tier in 4:
			for index in 8:
				var item = load("res://resources/items/item_base.gd").new()
				item.item_name = "Simulation_%d_%d" % [tier, index]
				item.item_tier = tier
				pool.append(item)
	var workspace := ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var destination := workspace.path_join("output/shop-full-offers-simulation.csv" if full_offers else "output/shop-rarity-simulation.csv")
	DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
	var report := FileAccess.open(destination, FileAccess.WRITE)
	assert(report != null)
	report.store_csv_line(PackedStringArray(["wave", "samples", "common_expected", "rare_expected", "epic_expected", "legendary_expected", "common_observed", "rare_observed", "epic_observed", "legendary_observed"]))
	for wave in range(1, 21):
		var expected: Array[float] = policy.probabilities(wave)
		var counts := [0, 0, 0, 0]
		for sample in samples:
			if full_offers:
				var offers = global.select_items_for_offer(pool, wave, global.SHOP_PROBABILITY_CONFIG)
				assert(offers.size() == 4)
				for item in offers: counts[item.item_tier] += 1
			else: counts[policy.roll_tier(wave, random)] += 1
		var total := samples * (4 if full_offers else 1)
		var row := PackedStringArray([str(wave), str(total)])
		for chance in expected: row.append("%.9f" % chance)
		for tier in 4:
			var observed := float(counts[tier]) / total
			row.append("%.9f" % observed)
			var tolerance := 6.0 * sqrt(expected[tier] * (1.0 - expected[tier]) / total) + 0.0005
			assert(absf(observed - expected[tier]) <= tolerance, "Wave %d tier %d: %.6f vs %.6f" % [wave, tier, observed, expected[tier]])
			if expected[tier] == 0.0: assert(counts[tier] == 0, "Locked rarity appeared")
		report.store_csv_line(row)
	report.close()
	print("PASS: %d %s across waves 1-20; every tier within 6-sigma tolerance, no early unlocks. CSV: %s" % [samples * 20 * (4 if full_offers else 1), "generated offers" if full_offers else "sequential rarity draws", destination])
	quit()
