extends Node2D


@export var snake_scene : PackedScene
@export var head_scene : PackedScene

# Game variable
var score : int
var game_started : bool = false

# Board variables
var row_count := 20
var col_count := 20
var cell_size := 16

# Apple variables
@onready var apple = $Apple
var apple_pos : Vector2
var regen_food := true

# Snake variables
var old_data : Array	# Store previous positions of each snake part
var snake_data : Array 	# Store cell positions of each snake part
var snake : Array		# Store snake-part scenes

# Handling movement
var start_pos := Vector2(9, 9)
var move_direction : Vector2
var can_move : bool

func move_snake():
	var head = snake[0]
	if !can_move:
		return
	elif Input.is_action_just_pressed("up") and move_direction != Vector2.DOWN:
		move_direction = Vector2.UP
		can_move = false
	elif Input.is_action_just_pressed("down") and move_direction != Vector2.UP:
		move_direction = Vector2.DOWN
		can_move = false
	elif Input.is_action_just_pressed("left") and move_direction != Vector2.RIGHT:
		move_direction = Vector2.LEFT
		can_move = false
	elif Input.is_action_just_pressed("right") and move_direction != Vector2.LEFT:
		move_direction = Vector2.RIGHT
		can_move = false
	elif Input.is_action_just_pressed("start_game") and !game_started:
		game_started = true
	head.get_node("Head").rotation = move_direction.angle()


func _ready():
	new_game()


func _process(_delta):
	move_snake()


func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOver.hide()
	$MoveTimer.start()
	set_score(0)
	move_direction  = Vector2.UP
	can_move = true
	generate_snake()
	spawn_apple()

func set_score(new_score : int):
	score = new_score
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	add_head(start_pos + Vector2(0, 0))
	add_segment(start_pos + Vector2(0, 1))
	add_segment(start_pos + Vector2(0, 2))

func add_head(pos: Vector2):
	snake_data.append(pos)
	var SnakeHead = head_scene.instantiate()
	SnakeHead.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeHead)
	snake.append(SnakeHead)

func add_segment(pos: Vector2):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)


func _on_move_timer_timeout():
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(snake_data.size()):
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bound()
	check_self_eaten()


func check_out_of_bound():
	if snake_data[0].x < 0 or snake_data[0].x > col_count - 1:
		end_game()
	if snake_data[0].y < 0 or snake_data[0].y > row_count - 1:
		end_game()


func check_self_eaten():
	pass
	for i in range(1, snake_data.size()):
		if snake_data[0] == snake_data[i]:
			end_game()


func spawn_apple():
	while regen_food:
		regen_food = false
		apple_pos = Vector2(
			randi_range(0, col_count - 1),
			randi_range(0, row_count - 1)
		)
		for part_pos in snake_data:
			if apple_pos == part_pos:
				regen_food = true
				break
				
	regen_food = true
	apple.position = (apple_pos * cell_size) + Vector2(0, cell_size)


func _on_apple_eaten():
	set_score(score + 1)
	add_segment(old_data[-1])
	spawn_apple()

func end_game():
	$GameOver.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true


func _on_game_over_restart():
	new_game()
