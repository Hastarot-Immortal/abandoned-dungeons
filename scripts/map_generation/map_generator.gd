class_name MapGenerator extends Node

static var main_style: int

static func gen_map(size: Vector2i, rand_seed: int, style: int) -> Map:
	seed(rand_seed)
	main_style = style
	
	match main_style:
		0b001:
			return gen_map001(size)
		0b010:
			return gen_map010(size)
		0b100:
			return gen_map100(size)
		_:
			return random(size)
			
##Prim's algorithm + modifications
static func gen_map001(size: Vector2i) -> Map:
	
	var map = Map.new(
		Vector2i(size.x | 1, size.y | 1), 
		MapEncoder.BUILDING.WALL
	)
	var walls: Array[Array] = []
	var floors: Array[Vector2i] = []
	var used_walls: Array[Vector2i] = []
	
	var start = Vector2i(
		randi_range(1, map.width() - 2) | 1,
		randi_range(1, map.height() - 2) | 1
	)
	map.set_at_vector(
		start, 
		MapEncoder.get_building(MapEncoder.BUILDING.FLOOR, main_style)
	)
	
	walls.append_array(
		walls_around(start, map)
		.map(func(item): return [item, start])
	)
	
	floors.append(start)
	
	while !walls.is_empty():
		fast_shuffle(walls)
		
		var wall = walls.pop_back()
		var wall_cell = wall[0]
		var start_cell = wall[1]
		
		var next_cell = wall_cell + (wall_cell - start_cell)
		
		if MapEncoder.is_building(
			map.get_at_vector(next_cell),
			MapEncoder.BUILDING.WALL
		):
			map.set_at_vector(
				next_cell, 
				MapEncoder.get_building(MapEncoder.BUILDING.FLOOR, main_style)
			)
			map.set_at_vector(
				wall_cell, 
				MapEncoder.get_building(MapEncoder.BUILDING.FLOOR, main_style)
			)
			floors.append_array([next_cell, wall_cell])
			walls.append_array(
				walls_around(next_cell, map)
				.map(func(item): return [item, next_cell])
			)
		else:
			used_walls.append(wall_cell)
	
	used_walls = used_walls.filter(func(cell): return is_removed_wall(cell, map))
	used_walls.shuffle()
	
	@warning_ignore("integer_division")
	for _i in range(used_walls.size() / 10):
		var wall = used_walls.pop_back()
		map.set_at_vector(
			wall,
			MapEncoder.get_building(MapEncoder.BUILDING.FLOOR, main_style)
		)
		floors.append(wall)
		
	used_walls.clear()
	for y in range(2, map.height() - 2, 2):
		for x in range(2, map.width() - 2, 2):
			if MapEncoder.is_building(
				map.get_at(x, y),
				MapEncoder.BUILDING.WALL
			):
				used_walls.append(Vector2i(x, y))
	
	used_walls = used_walls.filter(func(cell): return is_removed_wall(cell, map))
	used_walls.shuffle()
	
	@warning_ignore("integer_division")
	for _i in range(used_walls.size() / 4):
		var wall = used_walls.pop_back()
		map.set_at_vector(
			wall,
			MapEncoder.get_building(MapEncoder.BUILDING.FLOOR, main_style)
		)
		floors.append(wall)
	
	var dead_ends = floors.filter(func(cell): return is_dead_end(cell, map))
	dead_ends.shuffle()
	
	@warning_ignore("integer_division")
	for _i in range(dead_ends.size() / 2):
		var dead_end = dead_ends.pop_back()
		map.set_at_vector(
			dead_end,
			MapEncoder.get_building(MapEncoder.BUILDING.WALL, main_style)
		)
		
	return map

static func gen_map010(size: Vector2i) -> Map:
	var map = Map.new(size)

	random_fill(map, func(): return MapEncoder.get_building(
		MapEncoder.BUILDING.FLOOR, main_style) \
		if randi_range(1, 100) < 45 else \
		MapEncoder.get_building(MapEncoder.BUILDING.WALL, main_style))

	for i in range(3):
		cellular_automaton(map, rule4_5)
		
	var cells = cellular_automaton_with_memory(map, rule4_5)

	swap_buildings(map, MapEncoder.BUILDING.FLOOR, MapEncoder.BUILDING.WALL)
	fill_board(map, MapEncoder.BUILDING.WALL)
	
	for y in range(map.height()):
		cells.erase(Vector2i(0, y))
		cells.erase(Vector2i(map.width() - 1, y))

		
	for x in range(map.width()):
		cells.erase(Vector2i(x, 0))
		cells.erase(Vector2i(x, map.height() - 1))

	
	return map

static func gen_map100(size: Vector2i) -> Map:
	var map = Map.new(size)

	return map

static func random(size) -> Map:
	var rand_map_gen = [
		gen_map001, 
		gen_map010, 
		gen_map100
	].pick_random()
	
	return rand_map_gen.call(size)

static func fast_shuffle(walls: Array) -> void:
	var to
	match walls.size():
		1:
			to = 0
		2:
			to = 0
		3: 
			to = 1
		4:
			to = 2
		5: 
			to = 3
		_:
			to = walls.size() - 4
			
	var index = randi_range(0, to)
	var temp = walls[index]
	walls[index] = walls[walls.size() - 1]
	walls[walls.size() - 1] = temp

const neumann_directions: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)]

static func is_valid_wall(cell: Vector2i, map: Map) -> bool:
	return cell.x > 1 and cell.x < (map.width() - 1) \
	and cell.y > 1 and cell.y < (map.height() - 1)

static func walls_around(cell: Vector2i, map: Map) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	
	for direction in neumann_directions:
		var wall = cell + direction
		if is_valid_wall(wall, map) and \
		MapEncoder.is_building(
			map.get_at_vector(wall), 
			MapEncoder.BUILDING.WALL
		):
			arr.push_back(wall)
	
	return arr

static func is_dead_end(cell: Vector2i, map: Map) -> bool:
	var res: Array[bool] = []
	for direction in neumann_directions:
		var wall = cell + direction
		if MapEncoder.is_building(
			map.get_at_vector(wall),
			MapEncoder.BUILDING.WALL
		):
			res.append(true)
		else:
			res.append(false)
	return res.count(true) == 3

static func is_removed_wall(cell: Vector2i, map: Map) -> bool:
	var res: Array[bool] = []
	
	for direction in neumann_directions:
		if MapEncoder.is_building(
			map.get_at_vector(cell + direction),
			MapEncoder.BUILDING.FLOOR
		):
			res.append(true)
		else:
			res.append(false)
			
	if res.count(true) == 4:
		return true
	if res.count(true) == 3:
		return true
	if res == [true, false, true, false]:
		return true
	if res == [false, true, false, true]:
		return true
	
	return false

static func random_fill(map: Map, rule: Callable) -> void:
	for y in range(map.height()):
		for x in range(map.width()):
			map.set_at(x, y, rule.call())

static func cellular_automaton(map: Map, rule: Callable) -> void:
	for y in range(map.height()):
		for x in range(map.width()):
			map.set_at(x, y, rule.call(Vector2i(x, y), map))

static func rule4_5(cell: Vector2i, map: Map) -> int:
	if MapEncoder.is_building(
		map.get_at_vector(cell), 
		MapEncoder.BUILDING.FLOOR
	):
		if count_walls_with_dir(cell, map, moore_directions) >= 5:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.WALL,
				main_style
			)
		else:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)
	elif MapEncoder.is_building(
		map.get_at_vector(cell), 
		MapEncoder.BUILDING.WALL
	):
		if count_walls_with_dir(cell, map, moore_directions) >= 4:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.WALL,
				main_style
			)
		else:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)
	else:
		return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)

const moore_directions: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(1, -1),
	Vector2i(1, 0),
	Vector2i(1, 1)]

const directions_step_2: Array[Vector2i] = [
	Vector2i(-2, -2),
	Vector2i(-2, -1),
	Vector2i(-2, 0),
	Vector2i(-2, 1),
	Vector2i(-2, 2),
	Vector2i(-1, -2),
	Vector2i(-1, 2),
	Vector2i(0, -2),
	Vector2i(0, 2),
	Vector2i(1, -2),
	Vector2i(1, 2),
	Vector2i(2, -2),
	Vector2i(2, -1),
	Vector2i(2, 0),
	Vector2i(2, 1),
	Vector2i(2, 2)]

static func count_walls_with_dir(cell: Vector2i, map: Map, directions: Array[Vector2i]) -> int:
	var res: int = 0
	
	for direction in directions:
		var neighbor = cell + direction
		if map.is_valid_vector(neighbor):
			if MapEncoder.is_building(
				map.get_at_vector(neighbor),
				MapEncoder.BUILDING.WALL
			):
				res += 1
	return res

static func swap_buildings(map: Map, first: MapEncoder.BUILDING, second: MapEncoder.BUILDING):
	for y in range(map.height()):
		for x in range(map.width()):
			if MapEncoder.is_building(map.get_at(x, y), first):
				map.set_at(x, y, MapEncoder.get_building(second, main_style))
			elif MapEncoder.is_building(map.get_at(x, y), second):
				map.set_at(x, y, MapEncoder.get_building(first, main_style))

static func fill_board(map: Map, building: MapEncoder.BUILDING):
	for y in range(map.height()):
		map.set_at(0, y, MapEncoder.get_building(building, main_style))
		map.set_at(map.width() - 1, y, MapEncoder.get_building(building, main_style))
		
	for x in range(map.width()):
		map.set_at(x, 0, MapEncoder.get_building(building, main_style))
		map.set_at(x, map.height() - 1, MapEncoder.get_building(building, main_style))

## return array with dictionaries (first - floor, second - wall) 
static func cellular_automaton_with_memory(map: Map, rule: Callable) -> Dictionary[Vector2i, bool]:
	var res: Dictionary[Vector2i, bool] = {}
	
	for y in range(map.height()):
		for x in range(map.width()):
			map.set_at(x, y, rule.call(Vector2i(x, y), map))
			if MapEncoder.is_building(
				map.get_at(x, y), 
				MapEncoder.BUILDING.WALL) \
				and count_walls(Vector2i(x, y), map) >= 1:
				res[Vector2i(x, y)] = true
	return res

##return array of dictionaries (with only border cells)
static func split_in_rooms(floors: Dictionary, map: Map):
	var rooms = [{}]
	var cur_index = 0
	
				
	return rooms

static func count_walls(cell: Vector2i, map: Map) -> int:
	var res: int = 0
	
	for direction in neumann_directions:
		var neighbor = cell + direction
		if map.is_valid_vector(neighbor):
			if MapEncoder.is_building(
				map.get_at_vector(neighbor),
				MapEncoder.BUILDING.WALL
			):
				res += 1
	return res

static func rule4_5_mod(cell: Vector2i, map: Map) -> int:
	if MapEncoder.is_building(
		map.get_at_vector(cell), 
		MapEncoder.BUILDING.FLOOR
	):
		if count_walls_with_dir(cell, map, neumann_directions) >= 5 \
		or count_walls_with_dir(cell, map, directions_step_2) <= 1:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.WALL,
				main_style
			)
		else:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)
	elif MapEncoder.is_building(
		map.get_at_vector(cell), 
		MapEncoder.BUILDING.WALL
	):
		if count_walls_with_dir(cell, map, neumann_directions) >= 4 \
		or count_walls_with_dir(cell, map, directions_step_2) <= 1:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.WALL,
				main_style
			)
		else:
			return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)
	else:
		return MapEncoder.get_building(
				MapEncoder.BUILDING.FLOOR,
				main_style
			)
