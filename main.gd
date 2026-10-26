extends Node2D
# Humano Mutado - prototipo. WASD mover, ESPACIO atacar, R reiniciar.
# Cada 5 muertes mutas: mas velocidad, daño y alcance.

var p := Vector2(480, 270)
var face := Vector2.RIGHT
var hp := 100.0
var kills := 0
var mut := 0
var atk_t := 0.0
var flash := 0.0
var spawn_t := 1.0
var enemies: Array = []
var tj_id := -1
var atk_id := -1
var tj_start := Vector2.ZERO
var tj_vec := Vector2.ZERO

func _input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		if e.pressed:
			if e.position.x < 480.0 and tj_id == -1:
				tj_id = e.index
				tj_start = e.position
			elif e.position.x >= 480.0 and atk_id == -1:
				atk_id = e.index
		else:
			if e.index == tj_id:
				tj_id = -1
				tj_vec = Vector2.ZERO
			if e.index == atk_id:
				atk_id = -1
	elif e is InputEventScreenDrag and e.index == tj_id:
		tj_vec = ((e.position - tj_start) / 50.0).limit_length(1.0)

func _process(d: float) -> void:
	if hp <= 0.0:
		if Input.is_physical_key_pressed(KEY_R) or atk_id != -1:
			hp = 100.0; kills = 0; mut = 0; enemies.clear(); p = Vector2(480, 270)
		queue_redraw()
		return
	var v := Vector2(
		int(Input.is_physical_key_pressed(KEY_D)) - int(Input.is_physical_key_pressed(KEY_A)),
		int(Input.is_physical_key_pressed(KEY_S)) - int(Input.is_physical_key_pressed(KEY_W)))
	if v != Vector2.ZERO:
		v = v.normalized()
	elif tj_vec != Vector2.ZERO:
		v = tj_vec
	if v != Vector2.ZERO:
		face = v.normalized()
	p += v * (140.0 + mut * 12.0) * d
	p = p.clamp(Vector2(16, 16), Vector2(944, 524))
	atk_t -= d
	flash -= d
	if (Input.is_physical_key_pressed(KEY_SPACE) or atk_id != -1) and atk_t <= 0.0:
		atk_t = 0.4
		flash = 0.12
		for e in enemies:
			if e.pos.distance_to(p + face * 30.0) < 45.0 + mut * 4.0:
				e.hp -= 20.0 + mut * 6.0
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = max(0.5, 2.0 - kills * 0.03)
		var pos: Vector2 = (p + Vector2.from_angle(randf() * TAU) * 450.0).clamp(Vector2(10, 10), Vector2(950, 530))
		enemies.append({"pos": pos, "hp": 40.0})
	for e in enemies:
		e.pos += (p - e.pos).normalized() * 60.0 * d
		if e.pos.distance_to(p) < 20.0:
			hp -= 15.0 * d
	var alive: Array = []
	for e in enemies:
		if e.hp > 0.0:
			alive.append(e)
		else:
			kills += 1
	enemies = alive
	mut = kills / 5
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.22, 0.4, 0.18))
	draw_rect(Rect2(400, 0, 160, 540), Color(0.45, 0.42, 0.38))
	for e in enemies:
		draw_circle(e.pos, 12, Color(0.6, 0.15, 0.6))
	var body := Color(0.15, 0.15, 0.2).lerp(Color(0.3, 0.9, 0.3), min(mut / 10.0, 1.0))
	draw_circle(p, 14, body)
	draw_circle(p + face * 8.0, 4, Color.WHITE)
	if flash > 0.0:
		draw_circle(p + face * 30.0, 45.0 + mut * 4.0, Color(1, 1, 1, 0.35))
	draw_circle(Vector2(110, 430) + tj_vec * 40.0, 40, Color(1, 1, 1, 0.2))
	draw_circle(Vector2(850, 430), 50, Color(1, 0.3, 0.3, 0.3))
	var f := ThemeDB.fallback_font
	draw_string(f, Vector2(10, 22), "Vida: %d   Mutacion: %d   Muertes: %d" % [hp, mut, kills], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	if hp <= 0.0:
		draw_string(f, Vector2(340, 270), "HAS MUERTO - R para reiniciar", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.RED)
