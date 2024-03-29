@tool

# Constants and data classes

const SHAPE_SPHERE = 0
const SHAPE_BOX = 1
const SHAPE_TORUS = 2
const SHAPE_CYLINDER = 3
const SHAPE_GENERIC = 4

const OP_UNION = 0
const OP_SUBTRACT = 1
const OP_COLOR = 2
const OP_CUTAWAY = 3

const PARAM_TRANSFORM = 0
const PARAM_COLOR = 1
const PARAM_SMOOTHNESS = 2
const PARAM_RADIUS = 3
const PARAM_SIZE = 4
const PARAM_THICKNESS = 5
const PARAM_HEIGHT = 6
const PARAM_ROUNDING = 7
const PARAM_LAYER = 8
const PARAM_SIZE_PRIMARY = 9
const PARAM_SIZE_SECONDARY = 10
const PARAM_GENERIC_SHAPE = 11
const PARAM_OFFSET = 12
const PARAM_ONION_ALPHA = 13
const PARAM_ONION_THICKNESS = 14

const G_SPHERE = 0
const G_BOX = 1
const G_TORUS = 2
const G_CYLINDER = 3
const G_ROUNDCONE = 4
const G_PLANE = 5



const _param_names = [
	"transform",
	"color",
	"smoothness",
	"radius",
	"size",
	"thickness",
	"height",
	"rounding",
	"layer",
	"size_primary",
	"size_secondary",
	"generic_shape",
	"offset",
	"onion_alpha",
	"onion_thickness"
]

const _param_types = [
	TYPE_TRANSFORM3D,
	TYPE_COLOR,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_VECTOR3,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_FLOAT,
	TYPE_INT,
	TYPE_VECTOR3,
	TYPE_FLOAT,
	TYPE_FLOAT
]

class Param:
	var value = null
	var uniform := ""

	func _init(p_v):
		value = p_v


class SceneObject:
	var operation := OP_UNION
	var shape := SHAPE_SPHERE
	var params := {}
	#var active := true
	
	var g_shape := G_SPHERE

	func _init(p_shape: int):
		shape = p_shape

		params[PARAM_TRANSFORM] = Param.new(Transform3D())
		params[PARAM_COLOR] = Param.new(Color(1,1,1))
		params[PARAM_SMOOTHNESS] = Param.new(0.2)
		params[PARAM_LAYER] = Param.new(1.0)

		match shape:
			
			SHAPE_GENERIC:
				params[PARAM_SIZE_PRIMARY] = Param.new(3.0)
				params[PARAM_SIZE_SECONDARY] = Param.new(3.0)
				params[PARAM_GENERIC_SHAPE] = Param.new(0) 
				params[PARAM_ROUNDING] = Param.new(0.2)
				params[PARAM_OFFSET] = Param.new(Vector3(0,0,0))
				params[PARAM_ONION_ALPHA] = Param.new(0.0)
				params[PARAM_ONION_THICKNESS] = Param.new(1.0)
				
			SHAPE_SPHERE:
				params[PARAM_RADIUS] = Param.new(1.0)

			SHAPE_BOX:
				params[PARAM_SIZE] = Param.new(Vector3(1,1,1))
				params[PARAM_ROUNDING] = Param.new(0.0)

			SHAPE_TORUS:
				params[PARAM_RADIUS] = Param.new(1.0)
				params[PARAM_THICKNESS] = Param.new(0.25)

			SHAPE_CYLINDER:
				params[PARAM_RADIUS] = Param.new(0.5)
				params[PARAM_HEIGHT] = Param.new(1.0)
				params[PARAM_ROUNDING] = Param.new(0.0)
				



static func get_param_type(param_index: int) -> int:
	return _param_types[param_index]


static func get_param_name(param_index: int) -> String:
	return _param_names[param_index]

