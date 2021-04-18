extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var arrow_res = preload("res://Scenes/Arrow.tscn")

var ArrowConnections := {}

var making_arrow:=false
var new_arrow:Node2D
var new_arrow_origin:String

var mode = "build_normal"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("shift") and mode=="build_normal":
		mode = "build_arrow"
	elif Input.is_action_just_released("shift")and mode=="build_arrow":
		mode = "build_normal"
		destroy_new_arrow()
	
	if mode=="build_normal" and Input.is_action_just_pressed("delete"):
		for node in $Nodes.get_children():
			if node.hover==true:
				delete_graph_node(node)
	
	if mode=="build_arrow":
		if Input.is_action_just_pressed("click"):
			#print("click")
			for node in $Nodes.get_children():
				#print("node")
				if node.hover==true and node.type=="process":
					#print("hover")
					start_new_arrow(node)
					break
		
		if Input.is_action_just_released("click"):
			for node in $Nodes.get_children():
				if node.hover==true and node.type=="resource":
					end_new_arrow(node)
					break
			destroy_new_arrow()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for arrowName in ArrowConnections:
		get_node("Arrows/"+arrowName).p1 = get_node("Nodes/"+ArrowConnections[arrowName][0]).global_position
		get_node("Arrows/"+arrowName).p2 = get_node("Nodes/"+ArrowConnections[arrowName][1]).global_position
		get_node("Arrows/"+arrowName).offset = ArrowConnections[arrowName][2]
		get_node("Arrows/"+arrowName).mode = ArrowConnections[arrowName][3]
	if mode == "build_normal" and new_arrow != null:
		destroy_new_arrow()

func delete_graph_node(node):
	var arrows_to_delete = []
	for arrowName in ArrowConnections:
		if ArrowConnections[arrowName][0]==node.name or \
		   ArrowConnections[arrowName][1]==node.name:
			get_node("Arrows/"+arrowName).queue_free()
			arrows_to_delete.append(arrowName)
	for arrowName in arrows_to_delete:
		ArrowConnections.erase(arrowName)
	node.queue_free()

func start_new_arrow(node):
	if making_arrow==false:
		making_arrow=true
		#print("newarrow")
		new_arrow = arrow_res.instance()
		new_arrow.p1 = node.global_position
		new_arrow.mode = "new"
		new_arrow_origin = node.name
		$Arrows.add_child(new_arrow)

func end_new_arrow(node):
	if making_arrow==true:
		# check if its a duplicate
		var dup=false
		for arrowName in ArrowConnections:
			if ArrowConnections[arrowName][0] == new_arrow_origin and \
			   ArrowConnections[arrowName][1] == node.name:
				destroy_new_arrow()
				dup=true
				break
		if not dup: 
			ArrowConnections[new_arrow.name] = [new_arrow_origin, node.name, 0, "allowed"]
		making_arrow=false

func destroy_new_arrow():
	if making_arrow==true:
		new_arrow.queue_free()
	making_arrow=false
	new_arrow_origin = "NONE"















