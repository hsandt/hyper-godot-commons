# Hyper Godot Commons
A collection of utility scripts for Godot 4

It is the equivalent of my other utility repository, [Hyper Unity Commons](https://github.com/hsandt/hyper-unity-commons), for Godot.

## What it is for

I keep this repository to use as Git submodule in my personal and team projects. The features should be stable and simple math functions are tested, but the code goes under regular changes to fit my needs, so I don't guarantee a stable API across versions. In fact, there is no proper version release, development is continuously done on the main branch.

For this reason, this is not meant to be used as a strong dependency for projects where I am not part of the team. If you need a more stable, documented utility repository, you can have a look at other projects like [Fractural Commons](https://github.com/Fractural/FracturalCommons), [Godot Helper Pack (For Godot 4.x) by Jason Lothamer](https://github.com/jhlothamer/godot_helper_pack) and [Godot Utils by addmix](https://github.com/addmix/godot_utils).

However, if you found some scripts that would benefit your project in this repository, you're welcome to use them under the current license (see [LICENSE](LICENSE)), following the instructions below.

## Setup

Because scripts are under active development, I recommend people who want to use them but who are not working with me to either:

a. clone this repository as submodule, but stick to a certain commit for a given project (or at least pull new commits carefully, paying attention to those flagged "! API BREAKING !")

b. download and copy individual scripts to your project (copy the LICENSE along and indicate any changes you did)

Note that you can clone/copy the repository content to any project subfolder, including the `addons` folder. This repository is not an addon (it has no `plugin.cfg` file) so it won't need to be Enabled even if it is placed under the `addons` folder.

## Test

[GUT](https://godotengine.org/asset-library/asset/1709) is an optional dependency to run the unit tests. It is optional because, while parsing will fail on the test scripts in `test/unit` without it, it won't cause an issue at runtime, so if you never open the test scripts, you won't see any issue even if GUT is not installed.

However, if you have installed it, you can add the path to `test/unit` (e.g. res://addons/hyper-godot-commons/test/unit) to one of the Test Directories to run Hyper Godot Commons's own unit tests.

Currently, unit tests only cover MathUtils functions, except those depending on randomness.

## Contributing

Improvement suggestions and bug reports are welcome in the [Issues](https://github.com/hsandt/hyper-godot-commons/issues). I generally don't take pull requests at the moment, but if you open an issue, we can discuss it further and see what can be done.

## Features

### Audio

- [OneShotAudioStreamPlayer](audio/OneShotAudioStreamPlayer.gd) + template scene: Subclass of AudioStreamPlayer that frees itself when audio stream has finished playing
    - `play_audio_stream`

- [SFXManager](audio/SFXManager.gd) + template scene: A manager class to easily spawn one-shot SFX
    - `spawn_sfx`

### Singleton

- [AppManager](singleton/AppManager.gd) + template scene: Application manager class that provides app features
  - `auto_fullscreen_in_standalone` flag: auto-switch to fullscreen on standalone game start
  - `change_resolution`: change resolution among customizable presets in `preset_resolutions`
  - `toggle_fullscreen`: toggle fullscreen
  - `toggle_debug_overlay`: toggle debug overlay references in `debug_overlay` (overlay canvas and script must be defined separately)
  - `take_screenshot`: take screenshot


### Utils

- [CanvasItemUtils](utils/CanvasItemUtils.gd)
    - `get_absolute_z_index`: Return the absolute Z index of a CanvasItem

- [DebugUtils](utils/DebugUtils.gd)
    - `assert_member_is_set`: Assert that member is set on context

- [MathEnums](utils/MathEnums.gd)
- [MathUtils](utils/MathUtils.gd)
    - `exclusive_randf`: Return a random float in [0; 1)
    - `is_cardinal_direction_horizontal`: Return true if passed cardinal direction is horizontal, false if vertical
    - `horizontal_axis_value_to_cardinal_direction`: Return the cardinal direction corresponding to a non-zero horizontal axis value
    - `vertical_axis_value_to_cardinal_direction`: Return the cardinal direction corresponding to a non-zero vertical axis value
    - `cardinal_direction_to_vector2i`: Return Vector2i corresponding to cardinal direction

- [NodeUtils](utils/NodeUtils.gd)
    - `queue_free_children`: Call queue free on all children of node
    - `instantiate_under`: Instantiate a packed scene under a parent
    - `instantiate_under_at`: Instantiate a packed scene under a parent at a global position


