from pathlib import Path
r=Path('yolk-survivors')
def edit(p,a,b):
 p=r/p;s=p.read_text(encoding='utf-8-sig');assert a in s,p;p.write_text(s.replace(a,b),encoding='utf-8')
edit(Path('resources/items/passives/catalogue_passive.gd'),'func get_description() -> String:','func get_shop_price(completed_wave: int) -> int:\n\treturn 1 if effect_key == "chocolate_coin" else super.get_shop_price(completed_wave)\n\nfunc get_description() -> String:')
edit(Path('scenes/units/players/passive_items.gd'),'\t\t"energy_shake":','\t\t"chocolate_coin": Global.coins = Global.coins * 2 if randf() < 0.5 else 0\n\t\t"energy_shake":')
edit(Path('scenes/units/players/passive_items.gd'),'\tif not enemy.last_hit_grants_rewards: return','\tif not enemy.last_hit_grants_rewards or enemy.get_meta("stage_hazard", false) or count("printer") == 0: return')
edit(Path('scenes/ui/shop/shop_panel.gd'),'var context_card: ItemCard','var gamble_button: Button\n\nvar context_card: ItemCard')
edit(Path('scenes/ui/shop/shop_panel.gd'),'\t_build_next_stage_preview()','\t_build_next_stage_preview()\n\tgamble_button = Button.new()\n\tgamble_button.text = "Gamble · 1 yolk"\n\tgamble_button.position = Vector2(35, 180)\n\tgamble_button.pressed.connect(func():\n\t\tif Global.coins < 1: return\n\t\tGlobal.coins -= 1\n\t\tGlobal.coins = Global.coins * 2 if randf() < 0.5 else 0\n\t\tgamble_button.hide()\n\t\t_update_reroll_button()\n\t)\n\tadd_child(gamble_button)\n\tgamble_button.hide()')
edit(Path('scenes/ui/shop/shop_panel.gd'),'\tshop_wave = maxi(1, current_wave)','\tshop_wave = maxi(1, current_wave)\n\tgamble_button.visible = is_instance_valid(Global.player) and Global.player.stats.unlock_id == "gambler"')
edit(Path('scenes/components/health_component.gd'),'\tif owner is Player and is_instance_valid(owner.passive_items) and value >= current_health','\tif owner is Player and is_instance_valid(owner.passive_items) and owner.passive_items.shell_invulnerability > 0.0: return\n\tif owner is Player and is_instance_valid(owner.passive_items) and value >= current_health')
edit(Path('scenes/units/players/passive_items.gd'),'var extra_shell_used := false','var shell_invulnerability := 0.0\nvar extra_shell_used := false')
edit(Path('scenes/units/players/passive_items.gd'),'\textra_shell_used = false\n\t_clear_slip()','\textra_shell_used = false\n\tshell_invulnerability = 0.0\n\t_clear_slip()')
edit(Path('scenes/units/players/passive_items.gd'),'func _process(delta: float) -> void:','func _process(delta: float) -> void:\n\tshell_invulnerability = maxf(0.0, shell_invulnerability - delta)')
edit(Path('scenes/units/players/passive_items.gd'),'\textra_shell_used = true','\textra_shell_used = true\n\tshell_invulnerability = 1.0')
p=r/'resources/items/passives/catalogue/item_034.tres';s=p.read_text(encoding='utf-8').replace('effect_key = ""','effect_key = "chocolate_coin"').replace('ready_for_shop = false','ready_for_shop = true');p.write_text(s,encoding='utf-8')
edit(Path('tests/verify_catalogue_passives.gd'),'catalogue.size() == 25','catalogue.size() == 26')
# Low-HP survival test checks immunity then clears on next wave.
edit(Path('tests/verify_catalogue_passives.gd'),'\tassert(player.passive_items.extra_shell_used)','\tassert(player.passive_items.extra_shell_used)\n\tplayer.health_component.take_damage(9999)\n\tassert(player.health_component.current_health > 0)')

