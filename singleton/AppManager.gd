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
##     app_take_screenshot_scaled - recommended: F12 (Steam style)
##     app_take_screenshot_native - recommended: Ctrl/Shift+F12
##     app_exit - recommended: Command/Control (Auto) + Q, will automatically map to:
##                             - Ctrl+Q (on Linux/Windows)
##                             - Meta+Q (on macOS)


## Emitted when fullscreen is toggled via AppManager shortcuts
signal fullscreen_toggled(new_window_mode: DisplayServer.WindowMode)


@export_group("Components")

## (Optional) Canvas Layer showing debug info
@export var debug_overlay: CanvasLayer


@export_group("Parameters")

## If true, window scale will be initialized following the preset index
## initial_window_scale_preset_index
## Even when false, the list of window_scale_presets will be used when
## changing resolution
@export var set_window_scale_on_start: bool = false

## Array of scale presets
@export var window_scale_presets: Array[float] = [
		1.0,
		2.0,
		3.0,
		4.0,
	]

## Index of window scale preset to use on game start, among window_scale_presets
## This replaces display/window/stretch/scale for projects when it causes issues
## (e.g. gives unwanted HUD anchors in editor or offsets HUD elements at runtime,
## as in https://github.com/godotengine/godot-proposals/issues/9307)
## Note: if auto_fullscreen_in_pc_template is true,
## auto_fullscreen_in_pc_template takes precedence on PC template
@export var initial_window_scale_preset_index: int = 0

## If true, auto-switch to fullscreen on PC template (standalone) game start
## Note: it takes precedence over auto_scale on PC template
@export var auto_fullscreen_in_pc_template: bool = false

## If true, hide cursor when fullscreen is enabled
@export var hide_cursor_during_fullscreen: bool = false

## (Debug only) If true, show the debug overlay on start, else hide it
@export var debug_show_debug_overlay_on_start: bool = false


## Computed constant additional size provided by window decorations, used to compute
## hypothetical window size with decorations for different window sizes
var computed_window_decorations_additional_size: Vector2i

## Dynamically cached screen usable rect size, used to detect when changing monitor screen size,
## desktop taskbar or top menu bar
var cached_screen_usable_rect_size: Vector2i

## Dynamically cached array of valid window scale presets, i.e. scale presets for which
## the resulting window size with decorations is not bigger than the screen
## usable rect size (see method is_window_size_valid)
## This means that a scale that corresponds to fullscreen size will not be valid
## due to window title bar (and possibly OS taskbar and top menu bar reducing
## usable rect).
var cached_valid_window_scale_presets: Array[float]

## Current index of window scale among array of presets
var current_window_scale_preset_index: int

## Current frame counter
var current_frame: int


func _ready():
	# Autoload singletons are placed at the top of the scene tree
	# and are therefore processed first, but to be safe we set
	# low priority values for the AppManager
	process_priority = -100
	process_physics_priority = -100

	# Initialize computed constants and dynamically cached variables
	computed_window_decorations_additional_size = DisplayServer.window_get_size_with_decorations() \
		- DisplayServer.window_get_size()
	cached_screen_usable_rect_size = DisplayServer.screen_get_usable_rect().size
	update_cached_valid_window_scale_presets()

	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] and \
			auto_fullscreen_in_pc_template and OS.has_feature("pc") and OS.has_feature("template"):
		print("[AppManager] Playing standalone game with auto-fullscreen ON, enabling fullscreen")
		# Defer display change on game start to ensure it works
		toggle_fullscreen.call_deferred()
	else:
		if set_window_scale_on_start:
			# Defer display change on game start to ensure it works
			# Force update: true for initial window scale
			set_window_scale_preset_index.call_deferred(initial_window_scale_preset_index, true)

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
		get_viewport().set_input_as_handled()
	elif _is_action_pressed_in_event_safe(event, &"app_next_resolution"):
		change_resolution(1)
		get_viewport().set_input_as_handled()

	if _is_action_pressed_in_event_safe(event, &"app_toggle_fullscreen"):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()

	if _is_action_pressed_in_event_safe(event, &"app_toggle_debug_overlay") and debug_overlay:
		toggle_debug_overlay()
		get_viewport().set_input_as_handled()

	if _is_action_pressed_in_event_safe(event, &"app_take_screenshot_native"):
		take_screenshot(false)
		get_viewport().set_input_as_handled()
	elif _is_action_pressed_in_event_safe(event, &"app_take_screenshot_scaled"):
		take_screenshot(true)
		get_viewport().set_input_as_handled()

	if _is_action_pressed_in_event_safe(event, &"app_exit"):
		get_tree().quit()
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float):
	current_frame += 1


func _process(_delta: float):
	# There is no signal for Screen usable rect change, so we must check it manually
	# (this can happen when hiding taskbar or changing monitor display)
	var screen_usable_rect_size := DisplayServer.screen_get_usable_rect().size
	if cached_screen_usable_rect_size != screen_usable_rect_size:
		cached_screen_usable_rect_size = screen_usable_rect_size
		update_cached_valid_window_scale_presets()


func update_cached_valid_window_scale_presets():
	cached_valid_window_scale_presets.clear()

	# Get native window size (should be stable)
	var native_window_size := get_native_window_size()

	# Filter out preset window scales that lead to a window size with decorations
	# bigger than screen size in any dimension
	for preset_window_scale in window_scale_presets:
		# Note that Vector2i(Vector2) truncates fractional part
		var scaled_window_size := Vector2i(preset_window_scale * native_window_size)
		if is_window_size_valid(scaled_window_size):
			cached_valid_window_scale_presets.append(preset_window_scale)

	if cached_valid_window_scale_presets.is_empty():
		push_warning("[AppManager] update_cached_valid_window_scale_presets: all preset window scales ",
			"lead to window with decorations bigger than screen usable rect size, ",
			"so cached_valid_window_scale_presets is empty")


## Return true if window with passed size could fit in screen usable rect
## This does not apply to fullscreen, which doesn't care about usable rect
func is_window_size_valid(window_size: Vector2i):
	var window_size_with_decorations := window_size + computed_window_decorations_additional_size
	return window_size_with_decorations.x <= cached_screen_usable_rect_size.x and \
		window_size_with_decorations.y <= cached_screen_usable_rect_size.y


func get_native_window_size() -> Vector2i:
	return Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)


func set_window_scale(scale: float):
	# Set new window size using scale
	# Note that Vector2i(Vector2) truncates fractional part
	var new_window_size := Vector2i(scale * get_native_window_size())

	if not is_window_size_valid(new_window_size):
		push_error("[AppManager] set_window_scale: new_window_size %s + decorations goes over cached_screen_usable_rect_size %s" %
			[new_window_size, cached_screen_usable_rect_size])
		return

	var window := get_window()

	# Store window top-left position (without decorations) and size (without decorations) before change
	var previous_window_position := window.position
	var previous_window_size := window.size

	# We must make sure to set position *before* size to avoid bug where window.position is reverted
	# to its old value 1 frame later (https://github.com/godotengine/godot/issues/90638)
	# Therefore we compute new_window_position in advance
	# It also has the benefit to ignore any window clamping done by setting window.size
	# while window is getting bigger too close to the screen bottom-right edges,
	# since the position is computed before resizing, and there is no clamping afterward
	# since the window will be already placed at the proper top-left.

	# Since setting window.size keeps top-left and we want to preserve window center,
	# predict wanted top-left position with new scale by adding previous window extent (half size)
	# to get window center, then subtract new window extent to get new window top-left
	var new_window_position := previous_window_position + previous_window_size / 2 - new_window_size / 2

	# Adjust position to preserve previous center
	window.position = new_window_position

	# Resize to wanted scale
	# Note that window.size is recommended over DisplayServer.window_set_size
	# In https://github.com/godotengine/godot/issues/89543, we found out that it guarantees
	# immediate content update on Linux X11, without a need for the hack to move window by 1px
	# and back
	window.size = new_window_size


func change_resolution(delta: int):
	if DisplayServer.window_get_mode() in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		push_warning("[AppManager] change_resolution: Window is currently fullscreen, ",
			"don't do anything to avoid glitchy attempt to resize window while stuck in fullscreen")
		return

	var new_preset_window_scale_index := (current_window_scale_preset_index + delta) % \
			cached_valid_window_scale_presets.size()

	set_window_scale_preset_index(new_preset_window_scale_index, false)


## Set window scale preset index and update window scale according to preset array
## If force_update is true, do this even if the index didn't change
## This is useful on initialization and when leaving fullscreen
func set_window_scale_preset_index(new_preset_window_scale_index: int, force_update: bool):
	if not force_update and current_window_scale_preset_index == new_preset_window_scale_index:
		return

	current_window_scale_preset_index = new_preset_window_scale_index

	if new_preset_window_scale_index < cached_valid_window_scale_presets.size():
		var new_preset_window_scale := cached_valid_window_scale_presets[new_preset_window_scale_index]
		set_window_scale(new_preset_window_scale)
		print("[AppManager] Set window scale to: %0.2f" % new_preset_window_scale)
	else:
		push_error("[AppManager] set_window_scale_preset_index: invalid preset index %d, " % new_preset_window_scale_index,
			"expected 0 <= index < %d" % cached_valid_window_scale_presets.size())


func toggle_fullscreen():
	var new_window_mode: DisplayServer.WindowMode

	# For debug, borderless window is enough
	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		new_window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		if hide_cursor_during_fullscreen:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_EXCLUSIVE_FULLSCREEN")
	else:
		new_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		if hide_cursor_during_fullscreen:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_WINDOWED")

	DisplayServer.window_set_mode(new_window_mode)

	# When leaving fullscreen, force reset scale to last window scale to fix
	# Window manager slightly modifying window size after each double toggle fullscreen
	# Do not do this when *entering* fullscreen, this would add an extra lag
	if new_window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		set_window_scale_preset_index(current_window_scale_preset_index, true)

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
		var target_screenshot_size := DisplayServer.window_get_size() if scaled else get_native_window_size()

		# If needed, resize screenshot to target size
		# In practice, this happens when:
		# - stretch mode is "viewport" and we want scaled screenshot (scale up)
		# - stretch mode is "canvas_items" and we want native screenshot (scale down)
		# While scale down sounds scarier, it turns out that it pixel-perfectly placed sprites
		# are perfectly scaled back to their native resolution, and sprites with fractional
		# pixel offsets are simply snapped to the closest pixel as if playing in "viewport" stretch mode
		if target_screenshot_size != image.get_size():
			image.resize(target_screenshot_size.x, target_screenshot_size.y, Image.INTERPOLATE_NEAREST)

	# Else, when "display/window/stretch/mode" is "disabled", no stretching occurs
	# so the screenshot is at native resolution but scaled window size
	# and there is nothing meaningful to honor the scaled flag

	var err = image.save_png(screenshot_filepath)
	if err:
		push_error("[AppManager] Failed to save screenshot in: ", screenshot_filepath,
			" with error code: ", err)
	else:
		print("[AppManager] Saved %s screenshot in %s" % ["scaled" if scaled else "native", screenshot_filepath])


func _is_action_pressed_in_event_safe(event: InputEvent, action: StringName):
	return InputMap.has_action(action) and event.is_action_pressed(action)
