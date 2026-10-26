extends Resource
## Isolated from shop and level-up rarity policies. All luck milestones are editable.
@export_group("Base chances")
@export_range(0,1,0.01) var common := 0.65
@export_range(0,1,0.01) var rare := 0.25
@export_range(0,1,0.01) var epic := 0.09
@export_range(0,1,0.01) var legendary := 0.01
@export_group("Luck milestones")
@export var equal_tiers_luck := 500.0
@export var no_common_luck := 1500.0
@export var no_rare_luck := 3000.0
@export var all_legendary_luck := 5000.0

func probabilities(luck: float) -> Array[float]:
	var base: Array[float] = [maxf(0,common),maxf(0,rare),maxf(0,epic),maxf(0,legendary)]
	var total := base[0]+base[1]+base[2]+base[3]
	if total<=0.0: base.assign([1.0,0.0,0.0,0.0])
	else:
		for index in 4: base[index]/=total
	var milestones := [0.0,maxf(1,equal_tiers_luck)]
	milestones.append(maxf(milestones.back()+1,no_common_luck))
	milestones.append(maxf(milestones.back()+1,no_rare_luck))
	milestones.append(maxf(milestones.back()+1,all_legendary_luck))
	var chances := [base,[0.25,0.25,0.25,0.25],[0.0,1.0/3,1.0/3,1.0/3],[0.0,0.0,0.5,0.5],[0.0,0.0,0.0,1.0]]
	luck = maxf(0,luck)
	for stage in range(1,milestones.size()):
		if luck<=milestones[stage]:
			var blend: float = (luck-milestones[stage-1])/(milestones[stage]-milestones[stage-1])
			var result: Array[float] = []
			for tier in 4: result.append(lerpf(chances[stage-1][tier],chances[stage][tier],blend))
			return result
	return [0.0,0.0,0.0,1.0]

func roll_tier(luck: float, random: RandomNumberGenerator = null) -> int:
	var roll := random.randf() if random else randf()
	var chances := probabilities(luck)
	for tier in 4:
		roll-=chances[tier]
		if roll<0.0: return tier
	return 3

func select_item(player: Player, reserved: Array = [], random: RandomNumberGenerator = null) -> ItemPassive:
	var available := []
	for item in load("res://resources/items/passives/catalogue.gd").items():
		if not item.available_for(player): continue
		if item.max_copies>0:
			var waiting := 0
			for entry in reserved:
				if entry.item.get_offer_key()==item.get_offer_key(): waiting+=1
			if player.passive_items.count(item.effect_key)+waiting>=item.max_copies: continue
		available.append(item)
	if available.is_empty(): return null
	var tier := roll_tier(player.stats.luck,random)
	var candidates := available.filter(func(item): return item.item_tier==tier)
	# A capped/exhausted rarity falls back downward without forfeiting the reward.
	while candidates.is_empty() and tier>0:
		tier-=1
		candidates=available.filter(func(item): return item.item_tier==tier)
	if candidates.is_empty(): candidates=available
	return candidates[random.randi_range(0,candidates.size()-1) if random else randi_range(0,candidates.size()-1)]
