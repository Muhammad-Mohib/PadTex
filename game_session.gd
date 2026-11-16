extends CanvasLayer

@export var round_seconds := 60.0

@onready var ball: Node = get_node("../Ball")
@onready var bat: Node = get_node("../Player")

var scores := {}          # player name -> best rally
var _current_name := ""
var _time_left := 0.0
var _playing := false
var _guest_count := 0

var _board_panel: PanelContainer
var _board_label: Label
var _hud_label: Label
var _overlay: ColorRect
var _entry_box: VBoxContainer
var _final_box: VBoxContainer
var _title: Label
var _message: Label
var _name_edit: LineEdit
var _end_btn: Button
var _final_board: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_show_entry_screen("Welcome to Heaven Jam!", "Enter your name to start a %d-second turn." % int(round_seconds))


func _process(delta: float) -> void:
	if not _playing:
		return
	if not get_tree().paused:
		_time_left -= delta
		if _time_left <= 0.0:
			_end_turn()
			return
	_update_hud()
	_update_board()


# ---------------------------------------------------------------- flow

func _start_turn(player_name: String) -> void:
	_current_name = player_name
	_time_left = round_seconds
	_playing = true
	_overlay.visible = false
	_hud_label.visible = true
	bat.input_locked = false
	get_tree().paused = false
	ball.reset_for_new_player()
	_update_hud()
	_update_board()


func _end_turn() -> void:
	_playing = false
	var best: int = ball.get_best()
	scores[_current_name] = maxi(int(scores.get(_current_name, 0)), best)
	_lock_game()
	_update_board()
	_show_entry_screen("Time's up!",
		"%s scored a best rally of %d.\nNext player, enter your name." % [_current_name, best])


func _end_game() -> void:
	_lock_game()
	_board_panel.visible = false
	_entry_box.visible = false
	_final_box.visible = true
	_overlay.visible = true
	_final_board.text = _board_text(scores, "")


func _new_game() -> void:
	scores.clear()
	_guest_count = 0
	_show_entry_screen("New game", "Enter your name to start a %d-second turn." % int(round_seconds))


func _lock_game() -> void:
	get_tree().paused = true
	bat.input_locked = true
	_hud_label.visible = false


# ---------------------------------------------------------------- buttons

func _on_start_pressed(_text := "") -> void:
	var player_name := _name_edit.text.strip_edges()
	if player_name.is_empty():
		_message.text = "Please type a name, or choose \"Play without name\"."
		_name_edit.grab_focus()
		return
	_start_turn(player_name)


func _on_guest_pressed() -> void:
	_guest_count += 1
	var player_name := "Guest %d" % _guest_count
	while scores.has(player_name):
		_guest_count += 1
		player_name = "Guest %d" % _guest_count
	_start_turn(player_name)


# ---------------------------------------------------------------- screens

func _show_entry_screen(title: String, message: String) -> void:
	_lock_game()
	_title.text = title
	_message.text = message
	_name_edit.text = ""
	_end_btn.visible = not scores.is_empty()
	_final_box.visible = false
	_entry_box.visible = true
	_overlay.visible = true
	_board_panel.visible = true
	_update_board()
	_name_edit.grab_focus.call_deferred()


func _update_hud() -> void:
	var secs := int(ceil(maxf(_time_left, 0.0)))
	_hud_label.text = "%s   |   Time %d:%02d   |   Rally %d   |   Best %d" % [
		_current_name, secs / 60, secs % 60, ball.get_rally(), ball.get_best()]


func _update_board() -> void:
	var live := scores.duplicate()
	if _playing:
		live[_current_name] = maxi(int(live.get(_current_name, 0)), ball.get_best())
	_board_label.text = _board_text(live, _current_name if _playing else "")
	_board_panel.visible = not live.is_empty() and not _final_box.visible


func _board_text(table: Dictionary, highlight: String) -> String:
	if table.is_empty():
		return "No scores yet."
	var names := table.keys()
	names.sort_custom(func(a, b): return table[a] > table[b] or (table[a] == table[b] and str(a) < str(b)))
	var lines := PackedStringArray(["LEADERBOARD"])
	for i in names.size():
		var marker := "  <" if names[i] == highlight else ""
		lines.append("%d. %s  -  %d%s" % [i + 1, names[i], table[names[i]], marker])
	return "\n".join(lines)


# ---------------------------------------------------------------- UI build

func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.65)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(Color(0.08, 0.1, 0.16, 0.95)))
	center.add_child(card)

	var stack := VBoxContainer.new()
	card.add_child(stack)

	_entry_box = VBoxContainer.new()
	_entry_box.custom_minimum_size = Vector2(460, 0)
	_entry_box.add_theme_constant_override("separation", 14)
	stack.add_child(_entry_box)

	_title = _label("", 34, HORIZONTAL_ALIGNMENT_CENTER)
	_entry_box.add_child(_title)
	_message = _label("", 18, HORIZONTAL_ALIGNMENT_CENTER)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_entry_box.add_child(_message)

	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Player name"
	_name_edit.max_length = 16
	_name_edit.add_theme_font_size_override("font_size", 22)
	_name_edit.text_submitted.connect(_on_start_pressed)
	_entry_box.add_child(_name_edit)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_entry_box.add_child(row)
	var start_btn := _button("Start", _on_start_pressed)
	start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(start_btn)
	var guest_btn := _button("Play without name", _on_guest_pressed)
	guest_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(guest_btn)

	_end_btn = _button("End game & show leaderboard", _end_game)
	_entry_box.add_child(_end_btn)

	# --- final leaderboard screen
	_final_box = VBoxContainer.new()
	_final_box.custom_minimum_size = Vector2(460, 0)
	_final_box.add_theme_constant_override("separation", 14)
	_final_box.visible = false
	stack.add_child(_final_box)
	_final_box.add_child(_label("Final Leaderboard", 34, HORIZONTAL_ALIGNMENT_CENTER))
	_final_board = _label("", 22, HORIZONTAL_ALIGNMENT_CENTER)
	_final_box.add_child(_final_board)
	_final_box.add_child(_button("New game", _new_game))
	_final_box.add_child(_button("Quit", func(): get_tree().quit()))

	_board_panel = PanelContainer.new()
	_board_panel.position = Vector2(16, 12)
	_board_panel.add_theme_stylebox_override("panel", _card_style(Color(0, 0, 0, 0.5)))
	add_child(_board_panel)
	_board_label = _label("", 20, HORIZONTAL_ALIGNMENT_LEFT)
	_board_panel.add_child(_board_label)

	_hud_label = _label("", 24, HORIZONTAL_ALIGNMENT_CENTER)
	_hud_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hud_label.offset_top = 12
	_hud_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hud_label.add_theme_constant_override("outline_size", 6)
	_hud_label.visible = false
	add_child(_hud_label)


func _label(text: String, size: int, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", size)
	return l


func _button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 44)
	b.add_theme_font_size_override("font_size", 20)
	b.pressed.connect(callback)
	return b


func _card_style(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(18)
	return sb
