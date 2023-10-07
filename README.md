# Hyper Godot Commons
A collection of utility scripts for Godot 4

It is the equivalent of my other utility repository, [Hyper Unity Commons](https://github.com/hsandt/hyper-unity-commons), for Godot.

I keep this repository to use as Git submodule in my personal and team projects. The features should be stable and simple math functions are tested, but the code goes under regular changes to fit my needs, so I don't guarantee a stable API across versions. In fact, there is no proper version release, development is continuously done on the main branch.

For this reason, this is not meant to be used as a strong dependency for projects where I am not part of the team. If you need a more stable, documented utility repository, you can have a look at other projects like [Fractural Commons](https://github.com/Fractural/FracturalCommons), [Godot Helper Pack (For Godot 4.x) by Jason Lothamer](https://github.com/jhlothamer/godot_helper_pack) and [Godot Utils by addmix](https://github.com/addmix/godot_utils).

However, if you found some scripts that would benefit your project in this repository, you're welcome to use them under the current license (see [LICENSE](LICENSE)). Because scripts are under active development, I recommend people who want to use them but who are not working with me to either:

a. clone this repository as submodule, but stick to a certain commit for a given project (or at least pull new commits carefully, paying attention to those flagged "! API BREAKING !")

b. download and copy individual scripts to your project (copy the LICENSE along and indicate any changes you did)

Note that you can clone/copy the repository content to any project subfolder, including the `addons` folder. This repository is not an addon (it has no `plugin.cfg` file) so it won't need to be Enabled even if it is placed under the `addons` folder.

Improvement suggestions are welcome. I don't take pull requests at the moment, but you can reach me at [hs@gamedesignshortcut.com](mailto:hs@gamedesignshortcut.com).
