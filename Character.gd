extends CharacterBody2D
class_name Character

@export var SPEED := 100.0
@export var AIMLESS_RADIUS := 350
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hunger_bar: ProgressBar = $"Hunger Bar"
@onready var state_timer: Timer = $StateTimer
@onready var sprite: Sprite2D = $Sprite

enum State { Idle, Aimless, Hungry }

@export var hunger: float = 1
@export var state: State = State.Idle

var target_food: Node2D = null

func _ready():
	await get_tree().physics_frame
	get_random_skin_color()
	state_timer.wait_time = randf_range(1, 3)


func _input(event):
	return
	if event is InputEventMouseButton and event.is_pressed():
		navigation_agent.target_position = get_global_mouse_position()


func _physics_process(delta):
	if navigation_agent.is_navigation_finished(): 
		return
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * SPEED
	
	move_and_slide()
	pass


func _on_state_timer_timeout():
	var random = randi() % 2
	state = State.values()[random]
	
	if hunger <= .3:
		state = State.Hungry
	apply_state()


func apply_state():
	if state == State.Aimless:
		apply_aimless_state()
	elif state == State.Idle:
		apply_idle_state()
	elif state == State.Hungry:
		apply_hungry_state()
	
	hunger_bar.value = hunger
	
	if hunger <= 0:
		queue_free()


func apply_aimless_state():
	say("STATE: Aimless")
	var x_position = randi_range(-AIMLESS_RADIUS, AIMLESS_RADIUS)
	var y_position = randi_range(-AIMLESS_RADIUS, AIMLESS_RADIUS)
	
	var next_target = Vector2(x_position, y_position)
	navigation_agent.target_position = next_target
	hunger -= .2


func apply_idle_state():
	say("STATE: Idle")
	navigation_agent.target_position = global_position


func apply_hungry_state():
	say("STATE: Hungry")
	say("HMMMM G FAIM LA NON ???")
	hunger -= .05
	
	if target_food and is_instance_valid(target_food):
		return
	
	var closest_food = get_closest_food()
	if closest_food == null:
		return
	
	target_food = closest_food
	navigation_agent.target_position = closest_food.position


func get_closest_food() -> Node2D:
	var food_nodes = get_tree().get_nodes_in_group("food")
	if food_nodes.size() <= 0:
		return null
	var closest_food = food_nodes[0]
	var closest_food_distance := position.distance_to(closest_food.position)
	for food_node in food_nodes:
		var distance := position.distance_to(food_node.position)
		if distance < closest_food_distance:
			closest_food = food_node
			closest_food_distance = distance
	return closest_food


func say(message: String):
	if not Constants.CHARACTER_SAY_ENABLED: 
		return
	print("%s - %s" % [name, message])


func eat_food():
	target_food = null
	hunger = 1
	hunger_bar.value = hunger


func get_random_skin_color():
	sprite.modulate = Color(randf(), randf(), randf())
	say(str(modulate))
