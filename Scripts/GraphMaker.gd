extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var arrow_res = preload("res://Scenes/Arrow.tscn")
var Warning_res = preload("res://Scenes/Warning.tscn")

var ArrowConnections := {}
# arrow1 : ["node1", "node2", "0", "allowed"]

var making_arrow:=false
var new_arrow:Node2D
var new_arrow_origin:String

var mode = "build_normal"

var cur_deadlock_start = "NONE"

onready var deadlockLabel = $"UI/DeadlockPanel/Deadlock"
onready var modeLabal = $"UI/Mode"

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
	
	if mode=="simulate":
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
					make_request(node)
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

func switch_to_sim():
	mode = "simulate"

func switch_to_build():
	mode = "build_normal"
	for arrowData in ArrowConnections.values():
		arrowData[3] = "allowed"
	for arrow in $Arrows.get_children():
		arrow.is_red = false

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
	
	update_loop()
	

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
			#print("|+|+|+|+|FINDLOOP|+|+|+|+|")
			update_loop()
		making_arrow=false

func make_request(node):
	if making_arrow==true:
		# check if its allowed
		var dup=false
		for arrowData in ArrowConnections.values():
			if arrowData[0] == new_arrow_origin \
			and arrowData[1] == node.name:
				dup=true
				if arrowData[3]=="allocated" \
				or arrowData[3]=="request":
					if arrowData[3]=="allocated":
						for arrowData2 in ArrowConnections.values():
							if arrowData2[3] == "request" \
							and arrowData2[1] == node.name:
								arrowData2[3] = "allocated"
								break
					arrowData[3]="allowed"
					update_deadloop(new_arrow_origin)
					return
				# check if resource is available
				var available=true
				for arrowData2 in ArrowConnections.values():
					if arrowData2[3] == "allocated" \
					and arrowData2[1] == node.name:
						available = false
				if available:
					arrowData[3] = "allocated"
				else:
					arrowData[3] = "request"
				break
		if not dup:
			#print("Not allowed!")
			$UI.add_child(Warning_res.instance())
		
		update_deadloop(new_arrow_origin)
		
		destroy_new_arrow()
		making_arrow=false

func destroy_new_arrow():
	if making_arrow==true:
		new_arrow.queue_free()
	making_arrow=false
	new_arrow_origin = "NONE"

func update_loop():
	var loop = false
	for node in $Nodes.get_children():
		if find_loop(node.name):
			loop = true
	if loop:
		deadlockLabel.text = "Deadlock  Possible"
		deadlockLabel.add_color_override("font_color", Color(1,1,0))
	else:
		deadlockLabel.text = "Deadlock  Impossible"
		deadlockLabel.add_color_override("font_color", Color(0,1,0))

# returns true or false representing if a loop of arrows exists (ignores type)
func find_loop(start_node:String, visited:=[]):
	for arrowData in ArrowConnections.values():
#		print("Start: "+start_node)
#		print("Type: "+get_node("Nodes/"+start_node).type)
#		print(visited)
#		print(arrowData)
		var from
		var to
		# get the direction to check for a loop
		if get_node("Nodes/"+start_node).type=="process":
			from = 0
			to = 1
		else:
			from = 1
			to = 0
		if arrowData[from] == start_node \
		and arrowData[to] in visited \
		and arrowData[to] != visited[-1]:
			# found a loop
			print("LOOP'D")
			return true
		if arrowData[from] == start_node \
		and not arrowData[to] in visited:
			# recursive call
			if find_loop(arrowData[to], visited + [start_node]):
				return true
	# no loop in all subtrees
	return false

func update_deadloop(start_node):
	var deadlock_arrows = []
	for node in $Nodes.get_children():
		var deadloop = find_deadlock(node.name)
		for arrow in deadloop:
			if not arrow in deadlock_arrows:
				deadlock_arrows.append(arrow)
	for arrow in $Arrows.get_children():
		if arrow.name in deadlock_arrows:
			arrow.is_red = true
		else:
			arrow.is_red = false
	# update label
	if len(deadlock_arrows) > 0:
		deadlockLabel.text = "Deadlocked!"
		deadlockLabel.add_color_override("font_color", Color(1,0,0))
	else:
		update_loop()

# returns a list of arrows representing the deadlock loop,
# or an empty list if there is no deadlock
func find_deadlock(start_node:String, visited:=[], arrows:=[]):
	for arrowName in ArrowConnections:
#		print("Start: "+start_node)
#		print("Type: "+get_node("Nodes/"+start_node).type)
#		print(visited)
#		print(arrowData)
		if not (ArrowConnections[arrowName][3] == "allocated" \
		or ArrowConnections[arrowName][3] == "request"):
			continue
		var from
		var to
		# get the direction to check for a loop
		if get_node("Nodes/"+start_node).type=="process":
			from = 0
			to = 1
			if ArrowConnections[arrowName][3] == "allocated":
				continue
		else:
			from = 1
			to = 0
			if ArrowConnections[arrowName][3] == "request":
				continue
		if ArrowConnections[arrowName][from] == start_node \
		and ArrowConnections[arrowName][to] in visited \
		and ArrowConnections[arrowName][to] != visited[-1]:
			# found a loop
			print("LOOP'D")
			return arrows.slice(arrows.find(ArrowConnections[arrowName][to]), -1) + [arrowName]
		if ArrowConnections[arrowName][from] == start_node \
		and not ArrowConnections[arrowName][to] in visited:
			# recursive call
			var recurse = find_deadlock(ArrowConnections[arrowName][to], visited + [start_node], arrows+[arrowName])
			if len(recurse) > 0:
				return recurse
	# no loop in all subtrees
	return []














