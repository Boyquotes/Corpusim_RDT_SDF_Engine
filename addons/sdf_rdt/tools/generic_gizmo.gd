@tool
extends EditorNode3DGizmoPlugin

const SDFGeneric = preload("../sdf_generic.gd")

const INDEX_SIZE_PRIMARY = 0
const INDEX_SIZE_SECONDARY = 1

const POINT_COUNT = 32

var _undo_redo : EditorUndoRedoManager


func _init():
	create_handle_material("handles_billboard", false)
	# TODO This is supposed to create an "on-top" material, but it still renders behind...
	# See https://github.com/godotengine/godot/issues/44077
	create_material("lines", Color(1, 1, 1), false, true, false)


func set_undo_redo(ur: EditorUndoRedoManager):
	_undo_redo = ur


func get_name() -> String:
	return "SDFGenericGizmo"


func _has_gizmo(spatial: Node3D) -> bool:
	return spatial is SDFGeneric


func _get_handle_value(gizmo: EditorNode3DGizmo, index: int, secondary:= false):
	var node : SDFGeneric = gizmo.get_node_3d()
	match index:
		INDEX_SIZE_PRIMARY:
			return node.size_primary
		INDEX_SIZE_SECONDARY:
			return node.size_secondary


func _set_handle(gizmo: EditorNode3DGizmo, index: int, secondary: bool, camera: Camera3D, screen_point: Vector2):
	var node : SDFGeneric = gizmo.get_node_3d()

	var ray_pos := camera.project_ray_origin(screen_point)
	var ray_dir := camera.project_ray_normal(screen_point)

	var gtrans := node.global_transform
	
	match index:
		INDEX_SIZE_PRIMARY:
			node.size_primary = _get_axis_distance(gtrans, ray_pos, ray_dir, Vector3.AXIS_X)
		
		INDEX_SIZE_SECONDARY:
			node.size_secondary = _get_axis_distance(gtrans, ray_pos, ray_dir, Vector3.AXIS_Y)


static func _get_axis_distance(
	gtrans: Transform3D, ray_origin: Vector3, ray_dir: Vector3, axis: int) -> float:
	
	var seg0 := gtrans.origin - 4096.0 * gtrans.basis[axis]
	var seg1 := gtrans.origin + 4096.0 * gtrans.basis[axis]

	var hits := Geometry3D.get_closest_points_between_segments(
		seg0, seg1, ray_origin, ray_origin + ray_dir * 4096.0)

	var hit = gtrans.affine_inverse() * hits[0]
	return hit[axis]


func _commit_handle(gizmo: EditorNode3DGizmo, index: int, secondary, restore, cancel := false):
	var node : SDFGeneric = gizmo.get_node_3d()
	var ur := _undo_redo
	
	match index:
		INDEX_SIZE_PRIMARY:
			ur.create_action("Set SDFGeneric size_primary")
			ur.add_do_property(node, "size_primary", node.size_primary)
			ur.add_undo_property(node, "size_primary", restore)
			ur.commit_action()

		INDEX_SIZE_SECONDARY:
			ur.create_action("Set SDFGeneric size_secondary")
			ur.add_do_property(node, "size_secondary", node.size_secondary)
			ur.add_undo_property(node, "size_secondary", restore)
			ur.commit_action()


func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	
	var node : SDFGeneric = gizmo.get_node_3d()
	var size_secondary := node.size_secondary
	var size_primary := node.size_primary
	
	var points := []
	var angle_step := TAU / float(POINT_COUNT)
	var size_secondarys = [-size_secondary, size_secondary]
	var size_primary_xz = Vector3(size_primary, 1, size_primary)
	
	# Top and bottom caps
	for i in POINT_COUNT:
		var angle := float(i) * angle_step
		for h in size_secondarys:
			points.append(size_primary_xz * Vector3(cos(angle), h, sin(angle)))
			points.append(size_primary_xz * Vector3(cos(angle + angle_step), h, sin(angle + angle_step)))
	
	# Lines to connect caps
	var lines_angle_step := TAU / 4.0
	var lines_angle_start := PI / 4.0
	for i in 4:
		var theta := lines_angle_start + float(i) * lines_angle_step
		var p := Vector2(size_primary * cos(theta), size_primary * sin(theta))
		points.append(Vector3(p.x, -size_secondary, p.y))
		points.append(Vector3(p.x, size_secondary, p.y))

	var handles := [
		Vector3(size_primary, 0, 0),
		Vector3(0, size_secondary, 0)
	]
	
	gizmo.add_lines(PackedVector3Array(points), get_material("lines", gizmo), false)
	var ids:=PackedInt32Array()
	gizmo.add_handles(PackedVector3Array(handles), get_material("handles_billboard", gizmo), ids, false, false)


