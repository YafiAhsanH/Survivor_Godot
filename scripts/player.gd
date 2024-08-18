extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurt_box = %HurtBox
@onready var health_bar = $HealthBar
@onready var experience_bar = $ExperienceBar
@onready var blade = %Blade

var SPEED = 200.0
var health = 100.0
var maxhealth = 100.0
const DAMAGE_RATE = 5.0
var xp = 0
var xp_multiplier = 1
var level = 1
var faced_direction = Enums.DIRECTION.RIGHT
var time = 0

signal health_depleted
signal level_up

var last_movement = Vector2.UP

var experience = 0
var experience_level = 1
var collected_experience = 0

#Attacks
var ice_spear = preload("res://scenes/ice_spear.tscn") 
var tornado = preload("res://scenes/tornado.tscn")
var javelin = preload("res://scenes/javelin.tscn")
var drone = preload("res://scenes/drone.tscn")

#AttackNodes
@onready var ice_spear_timer = %IceSpearTimer
@onready var ice_spear_attack_timer = %IceSpearAttackTimer
@onready var tornado_timer = %TornadoTimer
@onready var tornado_attack_timer = %TornadoAttackTimer
@onready var javelin_base = %JavelinBase
@onready var drone_base = %DroneBase

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

#IceSpear
var ice_spear_ammo = 0
var ice_spear_baseAmmo = 0
var ice_spear_attackSpeed = 1.5
var ice_spear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseAmmo = 0
var tornado_attackSpeed = 3
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0

#Drone
var drone_ammo = 0
var drone_level = 0

#Enemy Related
var enemy_close = []

#GUI
@onready var exp_bar = %ExperienceBar
@onready var lbl_level = %lbl_level
@onready var level_panel = %LevelUp
@onready var upgradeOptions = %UpgradeOptions
@onready var item_options = preload("res://scenes/item_option.tscn")
@onready var lbl_timer = %lblTimer

func _ready():
	upgrade_character("icespear1")
	animated_sprite.sprite_frames = CharacterManager.load_character()
	animated_sprite.play("idle")
	attack()
	set_exp_bar(experience, calculate_experience_cap())
	_on_hurt_box_2_hurt(0,0,0)

func _physics_process(delta):
	# get direction (x, y)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# save last movement direction
	if direction != Vector2.ZERO:
		last_movement = direction
	
	# calculate velocity
	velocity = direction * SPEED
	
	# get direction of x axis
	var direction_x = direction[0]
	
	
	# flip sprite based on x axis direction
	if direction_x < 0:
		faced_direction = Enums.DIRECTION.LEFT
		animated_sprite.flip_h = true
	elif direction_x > 0:
		faced_direction = Enums.DIRECTION.RIGHT
		animated_sprite.flip_h = false
	
	# determine animation
	if velocity.length() > 0.0:
		animated_sprite.animation = "run"
	else:
		animated_sprite.animation = "idle"
		
	#Debug HITBOX HURTBOX=================================
	#var overlapping_mobs = hurt_box.get_overlapping_bodies()
	#if overlapping_mobs.size() > 0:
		#health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		#health_bar.value = health
		#if health <= 0.0:
			#emit_signal("health_depleted")
	
	# call action on left-click
	if Input.is_action_just_pressed("left_click"):
		action_left_click(faced_direction)
	
	move_and_slide()
	
func gain_xp(xp_gained):
	xp += xp_gained * xp_multiplier
	experience_bar.value = xp 
	
	# handle level up
	if xp >= 100:
		level += 1
		xp = 0
		xp_multiplier = xp_multiplier * 0.95
		experience_bar.value = xp
		emit_signal("level_up")
		
func action_left_click(dir_x):
	blade.attack(dir_x)
	
func _on_hurt_box_2_hurt(damage, _angle, _knockback):
	health -= clamp(damage - armor, 1.0, 999.0)
	health_bar.max_value = maxhealth
	health_bar.value = health
	if health <= 0.0:
		emit_signal("health_depleted")
		
func attack():
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attackSpeed * (1 - spell_cooldown)
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
			
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attackSpeed * (1 - spell_cooldown)
		if tornado_timer.is_stopped():
			tornado_timer.start()
			
	if javelin_level > 0:
		spawn_javelin()
	
	if drone_level > 0:
		spawn_drone()

func _on_ice_spear_timer_timeout():
	ice_spear_ammo += ice_spear_baseAmmo + additional_attacks
	ice_spear_attack_timer.start()

func _on_ice_spear_attack_timer_timeout():
	if ice_spear_ammo > 0:
		var ice_spear_attack = ice_spear.instantiate()
		ice_spear_attack.position = position
		ice_spear_attack.target = get_random_target()
		ice_spear_attack.level = ice_spear_level
		add_child(ice_spear_attack)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseAmmo + additional_attacks
	tornado_attack_timer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_attack_timer.start()
		else:
			tornado_attack_timer.stop()

func spawn_javelin():
	var get_javelin_total = javelin_base.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelin_base.add_child(javelin_spawn)
		calc_spawns -= 1
	#update javelin
	var get_javelins = javelin_base.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()
			
func spawn_drone():
	#var reset_markers = [Vector2(randf_range(-1,1) * 30, randf_range(-1,1) * 30), Vector2(randf_range(-1,1) * 30, randf_range(-1,1) * 30)]
	#var count = 0
	var get_drone_total = drone_base.get_child_count()
	var calc_spawns = (drone_ammo + additional_attacks) - get_drone_total
	while calc_spawns > 0:
		var reset_marker = Marker2D.new()
		reset_marker.position = Vector2(randf_range(-1,1) * 30, randf_range(-1,1) * 30) 
		self.add_child(reset_marker)
		var drone_spawn = drone.instantiate()
		drone_spawn.position = position + Vector2(randf_range(-1,1) * 30, randf_range(-1,1) * 30)
		#drone_spawn.reset_position = reset_markers[count]
		drone_spawn.reset_position = reset_marker
		drone_base.add_child(drone_spawn)
		calc_spawns -= 1
		#count += 1
		 
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
		
func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experience_cap()
		levelup()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
		
	set_exp_bar(experience, exp_required)

func calculate_experience_cap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 * (experience_level - 39) * 12
	return exp_cap
	
func set_exp_bar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

func levelup():
	lbl_level.text = str("Level: ", experience_level)
	var tween = level_panel.create_tween()
	tween.tween_property(level_panel, "position", Vector2(377.5, 73), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	level_panel.visible = true
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = item_options.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"drone1":
			drone_level = 1
			drone_ammo = 1
		"drone2":
			drone_level = 2
			drone_ammo = 1
		"drone3":
			drone_level = 3
			drone_ammo = 2
		"drone4":
			drone_level = 4
			drone_ammo = 3
		"icespear1":
			ice_spear_level = 1
			ice_spear_baseAmmo += 1
		"icespear2":
			ice_spear_level = 2
			ice_spear_baseAmmo += 1
		"icespear3":
			ice_spear_level = 3
		"icespear4":
			ice_spear_level = 4
			ice_spear_baseAmmo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseAmmo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseAmmo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackSpeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseAmmo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			SPEED += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			health += 20
			health = clamp(health,0,maxhealth)
	
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_panel.visible = false
	level_panel.position = Vector2(1364, 73)
	get_tree().paused = false
	calculate_experience(0)
	
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #find already collected upgrades
			pass
		elif i in upgrade_options: #if the upgrade alreadya n option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #dont pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #check for prerequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var random_item = dblist.pick_random()
		upgrade_options.append(random_item)
		return random_item
	else:
		return null
			
func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lbl_timer.text = str(get_m, ":", get_s)
