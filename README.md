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
- Each player gets a 1-minute turn. Their best rally in that minute is their score.

## Playing with friends

1. When the game starts, type your name and press **Start** (or Enter), or choose **Play without name** to play as a guest.
2. Your name, time left, current rally and best rally appear at the top of the screen.
3. The leaderboard in the top-left lists every player's best score.
4. When the minute is up, the next player enters their name. Entering a name that already exists counts as another try for that player, and only their highest score is kept.
5. When everyone is done, choose **End game & show leaderboard** to see the final standings, then **New game** or **Quit**.

Pressing Esc during a turn pauses the game and the clock.

## Running the project

1. Install [Godot 4.7](https://godotengine.org/download).
2. Open Godot, click **Import**, and select `project.godot` in this folder.
3. Press **F5** to play.

## Project files

- `main.tscn`: the main scene (court, camera, bat, ball)
- `player.gd`: bat movement and pause menu
- `ball.gd`: serves, bounces, hits and the rally counter
- `game_session.gd`: name entry, 1-minute turns and the leaderboard

## Tweaking

Select the **Ball** node and change the values in the Inspector, for example `serve_speed` and `hit_speed` to make the game faster or slower. To change the turn length, select the **GameSession** node and edit `round_seconds`.
