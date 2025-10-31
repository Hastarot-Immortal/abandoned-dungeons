extends Node2D

func _ready() -> void:
	var size = 60
	var map = MapGenerator.gen_map(Vector2i(size, size), 43, 0b010)
	build_world(map)

func build_world(map: Map) -> void:
	for x in range(map.height()):
		for y in range(map.width()):
			$TileMapLayer.set_cell(
				Vector2i(x, y),
				encode(map.get_at(x, y)),
				Vector2i(0, 0)
			)

func encode(cell: int) -> int:
	if Map.is_error(cell):
		return 1
	
	match MapEncoder.encode(cell):
		MapEncoder.BUILDING.FLOOR:
			return 0
		MapEncoder.BUILDING.WALL:
			return 1
		_:
			return 0


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ecs"):
		get_tree().quit()
