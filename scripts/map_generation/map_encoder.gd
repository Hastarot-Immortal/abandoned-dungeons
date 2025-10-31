class_name MapEncoder extends Node

enum BUILDING{
	FLOOR = 0b0_0000_000,
	WALL = 0b0_0001_000,
}

const BUILDING_MASK = 0b0_1111_000

static func encode(cell: int) -> BUILDING:
	return (cell & BUILDING_MASK) as BUILDING
	
static func get_building(building: BUILDING, style: int) -> int:
	return building | (style & 0b111)

static func is_building(cell: int, building: BUILDING) -> bool:
	return encode(cell) == building
