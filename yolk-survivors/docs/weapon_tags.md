# Weapon tags

Edit tags in each ItemWeapon resource: Melee, Ranged, Explosive, Pyro, Electric, Chili, Control, Pet. Tags combine and appear in selection and shop. All tiers have explicit tags.

Control is reserved for weapons applying Slow, Rooted or Airbourne. Ordinary knockback alone does not grant the tag, although the Crowd control stat still increases its force. Electricity deals damage and propagates without slowing players or enemies. Independent control effects remain unchanged.

Damage scaling is separate: damage_scaling_stat and scales_with_effects preserve the existing balance. Adding a tag does not change damage scaling. Morrón has Ranged/Chili but retains Effects scaling without flat ranged damage; Ají Amarillo retains ranged scaling. The hidden legacy type field is serialized compatibility data only.

Examples: Spark Lighter = Melee/Pyro/Electric; Pressure Cooker = Ranged/Explosive/Control; Electric Knife = Melee/Electric; Carolina Reaper = Pyro/Chili; pets = Pet.
