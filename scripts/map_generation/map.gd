## Map
class_name Map extends Node

var grid_size: Vector2i
var grid: Array[PackedByteArray]

const MAP_ERROR: int = 0b1000_0000
const OUT_OF_BOUNDS: int = MAP_ERROR | 0b0000_0001

func _init(size: Vector2i, fill_value: int = 0):
	grid_size = size
	grid = []
	
	grid.resize(grid_size.y)
	for y in range(grid_size.y):
		grid[y].resize(grid_size.x)
		grid[y].fill(fill_value)

func width() -> int:
	return grid_size.x

func height() -> int:
	return grid_size.y

func is_valid(x: int, y: int) -> bool:
	return x >= 0 and x < width() and y >= 0 and y < height()
	
func is_valid_vector(vector: Vector2i) -> bool:
	return is_valid(vector.x, vector.y)

func get_at(x: int, y: int) -> int:
	if is_valid(x, y):
		return grid[y].decode_u8(x)
	else:
		return OUT_OF_BOUNDS

func get_at_vector(vector: Vector2i) -> int:
	if is_valid(vector.x, vector.y):
		return grid[vector.y].decode_u8(vector.x)
	else:
		return OUT_OF_BOUNDS

func set_at(x: int, y: int, value: int) -> void:
	if is_valid(x, y):
		grid[y].encode_u8(x, value)
		
func set_at_vector(vector: Vector2i, value: int) -> void:
	if is_valid(vector.x, vector.y):
		grid[vector.y].encode_u8(vector.x, value)

static func is_error(input: int) -> bool:
	return bool(input & MAP_ERROR)
