# Heaven Jam

A small solo padel game made in Godot. Hit the ball over the net, let it bounce off the far wall, and see how long you can keep the rally going.

## Controls

| Input | Action |
| --- | --- |
| Move mouse | Move the bat |
| Left / right click | Rotate the bat |
| Esc | Pause / resume |

## How to play

- The ball is served from the far side and bounces once on your side.
- Hit it with the bat to send it back over the net.
- Swing sideways while hitting to aim left or right.
- If the ball gets past you, the rally ends and a new serve comes.
- Your current rally and best rally are shown in the top-left corner.

## Running the project

1. Install [Godot 4.7](https://godotengine.org/download).
2. Open Godot, click **Import**, and select `project.godot` in this folder.
3. Press **F5** to play.

## Project files

- `main.tscn`: the main scene (court, camera, bat, ball)
- `player.gd`: bat movement and pause menu
- `ball.gd`: serves, bounces, hits and the rally counter

## Tweaking

Select the **Ball** node and change the values in the Inspector, for example `serve_speed` and `hit_speed` to make the game faster or slower.
