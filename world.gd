extends Node2D

@export var food_scene: PackedScene
@export var food_container: Node2D
@export var navigation_region: NavigationRegion2D


func _on_food_timer_timeout() -> void:
	spawn_food()


func spawn_food():
	var food_instance = food_scene.instantiate()
	food_instance.position = NavigationServer2D.map_get_random_point(navigation_region.get_navigation_map(), 1, true)
	print(food_instance.position)
	food_container.add_child(food_instance)
