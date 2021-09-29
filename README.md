# GameLimit

GameLimit.ahk is an autohotkey script that limits video game playtime.

This script was inspired by [This Stackexchange Comment.](https://gaming.stackexchange.com/a/75079)

## Functionality Overview

The script looks for a designated process (like destiny2.exe or steam.exe).

If the process is present, GameLimit displays a "remaining time" overlay and records the session time.

If the time expires, the player is prompted to quit, or go into "overtime" mode. Overtime sessions are counted as triple-time, so, eg, a 4 minute session will log as 12 minutes. This allows for the game to be wrapped up, if other players are relying on you, but the penalty disincentivises playing during overtime.

If the game is launched while no time remains in the budget, the game process will be closed- you cannot launch into overtime.

Sessions are individually logged as Year, Day of Year, Session Length in Minutes.

You can press Ctrl+Win+Alt+F12 to view a popup of the current logged sessions and remaining time.

After a week, a session will be struck from the record- so if you use up all your time on Sunday, you can play again next Sunday. 

If the time is spread out over multiple days/ multiple sessions, time will become availiable as the sessions become a week old. So if you played 130 minutes on Monday, you will get 130 minutes back next Monday.

The "rolling basis" nature here, rather than having a budget within a given fixed time frame, is intended to disincentivise making sure to spend your hours before you lose them. Playing always comes at the same cost.

This means that the script can be configured to allow, say, about 2 hours a day, but those hours can be saved up for longer play sessions.

## Setup

Install [AutoHotkey](https://www.autohotkey.com/) if you don't already have it. (Windows only)

Copy this repository's contents- GameLimit.ahk and GameLimitData.txt- to whatever folder you desire. Make sure GameLimitData.txt

Create a shortcut to GameLimit.ahk, and place the shortcut in your Startup folder. This will make GameLimit.ahk run automatically at Startup.

Open GameLimit.ahk in a text editor. Near the top of the file, there are two basic configuration values:

```
timePerDay := 120 ;minutes
TargetProcess = destiny2.exe
```

Change `120` to whatever you want the daily time budget to be, in minutes. Note that this will be converted to a weekly budget, so 120 minutes is 840 minutes per week.

Change `destiny2.exe` to whatever process name you want to limit. If you want to limit all video games, `steam.exe` might be a good alternative choice.



## Intended Use

This script is designed as a personal productivity tool. I want to limit my own video game usage. As such, I haven't focused on security or obfuscation- this is not written to hide the functionality from a hostile actor, eg, a computer-savvy child who might want to kill the script. It could probably be modified to do so.




