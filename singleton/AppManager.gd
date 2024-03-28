extends Node
## Application manager class that provides app features:
## - change resolution and toggle fullscreen
## - auto fullscreen on standalone game start
## - toggle debug overlay (needs to be defined separately)
## - take screenshot
##
## Usage:
## - create scene AppManager.tscn and register it as autoload singleton scene
##   (the easiest is to copy AppManagerTemplate.tscn)
## - define input for the following actions:
##     app_prev_resolution
##     app_next_resolution
##     app_toggle_fullscreen - recommended: F11 (application style),
##                                          Alt+Enter (Linux/Windows style),
##                                          Ctrl+Meta+F (macOS style)
##     app_toggle_debug_overlay
##     app_take_screenshot_native
##     app_take_screenshot_scaled
##     app_exit - recommended: Ctrl+Q (Linux/Windows style),
##                             Meta+Q (macOS style)


## Emitted when fullscreen is toggled via AppManager shortcuts
signal fullscreen_toggled(new_window_mode: DisplayServer.WindowMode)


@export_group("Components")

## (Optional) Canvas Layer showing debug info
@export var debug_overlay: CanvasLayer


@export_group("Parameters")

## Scale the window on start by this factor
## This replaces display/window/stretch/scale for projects when it causes issues
## (e.g. gives unwanted HUD anchors in editor or offsets HUD elements at runtime,
## as in https://github.com/godotengine/godot-proposals/issues/9307)
## Note: if auto_fullscreen_in_pc_template is true, it takes precedence on PC template
@export var auto_scale: float = 1.0

## If true, auto-switch to fullscreen on PC template (standalone) game start
## Note: it takes precedence over auto_scale on PC template
@export var auto_fullscreen_in_pc_template: bool = false

## Array of resolution presets
@export var preset_resolutions: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160),
	]

## (Debug only) If true, show the debug overlay on start, else hide it
@export var debug_show_debug_overlay_on_start: bool = false


## Current index of resolution among array of presets
var current_preset_resolution_index = -1

## Current frame counter
var current_frame: int


func _ready():
	# Autoload singletons are placed at the top of the scene tree
	# and are therefore processed first, but to be safe we set
	# low priority values for the AppManager
	process_priority = -100
	process_physics_priority = -100

	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] and \
			auto_fullscreen_in_pc_template and OS.has_feature("pc") and OS.has_feature("template"):
		print("[AppManager] Playing standalone game with auto-fullscreen ON, enabling fullscreen")
		toggle_fullscreen.call_deferred()
	elif auto_scale != 1.0:
		set_window_scale(auto_scale)

	if debug_overlay != null:
		# Show debug overlay by default only in editor/debug exports, if corresponding flag is true
		# Else, hide debug overlay until user toggles visibility with debug input
		debug_overlay.visible = OS.has_feature("debug") and debug_show_debug_overlay_on_start

	current_frame = 0


func _unhandled_input(event: InputEvent):
	# let user toggle hi-dpi resolution freely
	# (hi-dpi is hard to detect and resize is hard to force on start)
	if _is_action_pressed_in_event_safe(event, &"app_prev_resolution"):
		change_resolution(-1)
	elif _is_action_pressed_in_event_safe(event, &"app_next_resolution"):
		change_resolution(1)

	if _is_action_pressed_in_event_safe(event, &"app_toggle_fullscreen"):
		toggle_fullscreen()
	if _is_action_pressed_in_event_safe(event, &"app_toggle_debug_overlay") and debug_overlay:
		toggle_debug_overlay()

	if _is_action_pressed_in_event_safe(event, &"app_take_screenshot_native"):
		take_screenshot(false)
	elif _is_action_pressed_in_event_safe(event, &"app_take_screenshot_scaled"):
		take_screenshot(true)

	if _is_action_pressed_in_event_safe(event, &"app_exit"):
		get_tree().quit()


func _physics_process(_delta):
	current_frame += 1


func get_native_window_size() -> Vector2i:
	return Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)


func set_window_scale(scale: float):
	var native_window_size := get_native_window_size()
	# Note that Vector2i(Vector2) truncates fractional part
	var scaled_window_size := Vector2i(scale * native_window_size)
	DisplayServer.window_set_size(scaled_window_size)

	# Since window_set_size keeps top-left and we want to preserve recenter, adjust position by subtracting
	# half of the window size delta (if scaling down, window_size_delta has negative components, but this also works)
	var window_size_delta := scaled_window_size - native_window_size
	DisplayServer.window_set_position.call_deferred(DisplayServer.window_get_position() - Vector2i(window_size_delta / 2.0))


func change_resolution(delta: int):
	# Redo this every time in case user changed monitor during game (rare)
	var screen_size = DisplayServer.screen_get_size()

	# Filter out preset resolutions bigger than screen size
	var valid_preset_resolutions: Array[Vector2i] = []
	for preset_resolution in preset_resolutions:
		if preset_resolution.x <= screen_size.x and \
				preset_resolution.y <= screen_size.y:
			valid_preset_resolutions.append(preset_resolution)

	if valid_preset_resolutions.is_empty():
		push_error("[AppManager] change_resolution: all preset resolutions are ",
			"bigger than screen size, STOP")
		return

	var new_preset_resolution_index: int
	if current_preset_resolution_index == -1:
		if delta > 0:
			new_preset_resolution_index = 0
		else:
			new_preset_resolution_index = valid_preset_resolutions.size() - 1
	else:
		new_preset_resolution_index = (current_preset_resolution_index + delta) % \
			valid_preset_resolutions.size()

	if current_preset_resolution_index == new_preset_resolution_index:
		return

	current_preset_resolution_index = new_preset_resolution_index

	var new_preset_resolution := valid_preset_resolutions[new_preset_resolution_index]
	DisplayServer.window_set_size(new_preset_resolution)

	print("[AppManager] Changed to preset resolution: %s" % new_preset_resolution)


func toggle_fullscreen():
	var new_window_mode: DisplayServer.WindowMode

	# For debug, borderless window is enough
	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		new_window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_EXCLUSIVE_FULLSCREEN")
	else:
		new_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_WINDOWED")

	DisplayServer.window_set_mode(new_window_mode)

	fullscreen_toggled.emit(new_window_mode)


func toggle_debug_overlay():
	var new_value = not debug_overlay.visible
	debug_overlay.visible = new_value

	print("[AppManager] Toggle debug canvas layer: %s" % new_value)


## Take a screenshot and save it in user path
## If scaled is true, use the current window scale
## Else, use the native resolution
func take_screenshot(scaled: bool):
	var datetime = Time.get_datetime_dict_from_system()

	# Make sure all numbers less than 10 are padded with a leading 0 so
	# alphabetical sorting matches sorting by date. Modify in-place.
	for key in ["month", "day", "hour", "minute", "second"]:
		datetime[key] = "%02d" % datetime[key]
	var screenshot_filename = "{year}-{month}-{day}_{hour}-{minute}-{second}.png".format(datetime)
	var screenshot_filepath = "user://Screenshots".path_join(screenshot_filename)

	# user:// should map to:
	# Windows: %APPDATA%\Godot\app_userdata\[project_name] or
	#          %APPDATA%\[project_name/custom_user_dir_name]
	# macOS: ~/Library/Application Support/Godot/app_userdata/[project_name] or
	#        ~/Library/Application Support/[project_name/custom_user_dir_name]
	# Linux: ~/.local/share/godot/app_userdata/[project_name] or
	#        ~/.local/share/[project_name/custom_user_dir_name]
	# See https://docs.godotengine.org/en/4.0/tutorials/io/data_paths.html#accessing-persistent-user-data-user
	if not DirAccess.dir_exists_absolute("user://Screenshots"):
		# no Screenshots directory in user dir, make it
		var err = DirAccess.make_dir_recursive_absolute("user://Screenshots")
		if err:
			push_error("[AppManager] Failed to make directory user://Screenshots with error code: ", err)
			return

	save_screenshot_in(screenshot_filepath, scaled)


func save_screenshot_in(screenshot_filepath: String, scaled: bool):
	# Get image data from viewport texture (in Godot 4, this is already ready to use,
	# no need to flip_y)
	var image = get_viewport().get_texture().get_image()

	if ProjectSettings.get_setting("display/window/stretch/mode") != "disabled":
		if scaled:
			# We want screenshot at window size
			if ProjectSettings.get_setting("display/window/stretch/mode") == "viewport":
				# In viewport stretch mode, texture is always at native dimensions, so resize to window size
				var scaled_window_size := DisplayServer.window_get_size()
				image.resize(scaled_window_size.x, scaled_window_size.y, Image.INTERPOLATE_NEAREST)
			# In canvas_items stretch mode, texture is already at window size
		else:
			# We want screenshot at native size
			if ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items":
				# In canvas_items stretch mode, texture is always at scaled dimensions, so resize to native size
				var native_window_size := get_native_window_size()
				image.resize(native_window_size.x, native_window_size.y, Image.INTERPOLATE_NEAREST)
			# In viewport stretch mode, texture is already at native size

	# Else, when "display/window/stretch/mode" is "disabled", no stretching occurs
	# so the screenshot is at native resolution but scaled window size
	# and there is nothing meaningful to honor the scaled flag

	var err = image.save_png(screenshot_filepath)
	if err:
		push_error("[AppManager] Failed to save screenshot in: ", screenshot_filepath,
			" with error code: ", err)
	else:
		print("[AppManager] Saved screenshot in %s" % screenshot_filepath)


func _is_action_pressed_in_event_safe(event: InputEvent, action: StringName):
	return InputMap.has_action(action) and event.is_action_pressed(action)
