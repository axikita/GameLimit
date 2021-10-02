# GameLimit

GameLimit.ahk is an autohotkey script that limits video game playtime.

This script was inspired by [This Stackexchange Comment.](https://gaming.stackexchange.com/a/75079)

## Functionality Overview

The script looks for a designated process (like destiny2.exe or steam.exe).

If the process is present, GameLimit displays a "remaining time" overlay and records the session time.

If the time expires, the player is prompted to quit, or go into "overtime" mode. Overtime sessions are counted as triple-time, so, eg, a 4 minute session will log as 12 minutes. This allows for the game to be wrapped up, if other players are relying on you, but the penalty disincentives playing during overtime.

If the game is launched while no time remains in the budget, the game process will be closed- you cannot launch into overtime.

Sessions are individually logged as Year, Day of Year, Session Length in Minutes.

You can press Ctrl+Win+Alt+F12 to view a popup of the current logged sessions and remaining time.

After a week, a session will be struck from the record- so if you use up all your time on Sunday, you can play again next Sunday. 

If the time is spread out over multiple days/ multiple sessions, time will become available as the sessions become a week old. So if you played 130 minutes on Monday, you will get 130 minutes back next Monday.

The "rolling basis" nature here, rather than having a budget within a given fixed time frame, is intended to disincentives making sure to spend your hours before you lose them. Playing always comes at the same cost.

This means that the script can be configured to allow, say, about 2 hours a day, but those hours can be saved up for longer play sessions.

## Setup

Install [AutoHotkey](https://www.autohotkey.com/) if you don't already have it. (Windows only)

Copy this repository's contents- GameLimit.ahk- to whatever folder you desire.

Create a shortcut to GameLimit.ahk, and place the shortcut in your Startup folder. This will make GameLimit.ahk run automatically at Startup.

Be sure to create a shortcut, rather than putting GameLimit.ahk directly in the startup folder- GameLimit.ahk will create a log file called GameLimitData.txt in it's own file folder, and if that is the startup folder, the text file will launch at startup.



Open GameLimit.ahk in a text editor. Near the top of the file, there are some basic configuration values:

```
timePerDay := 120 
TargetProcesses := ["destiny2.exe"] 
ResetPolicy := 3 
DailyReset := 0 
dislpayGUI = 1 
```

**timePerDay:** Change `120` to whatever you want the daily time budget to be, in minutes. Note that this will be converted to a weekly budget, so 120 minutes is 840 minutes per week.

**TargetProcesses:** Change `destiny2.exe` to whatever process name you want to limit. If you want to limit all video games, `steam.exe` might be a good alternative choice. If you want to limit multiple individual games, list them in the array as `["game1.exe", "game2.exe", "game3.exe"]`

**ResetPolicy:** if set to `0`, the time budget will reset on a rolling basis, as described above. 30 minutes played on Monday will mean 30 minutes become available next Monday; 45 minutes on Wednesday will mean 45 minutes become available next Wednesday, and so on.

If set to 1-7, all of the time will reset on the designated day of the week. `1` is Sunday, `2` is Monday, `3` is Tuesday, and so on. The full weekly budget of hours will become available on the designated day.

**DailyReset:** if set to `0`, the script will work as described in ResetPolicy. If set to `1`, Then instead, `timePerDay` will be a strrict daily limit, and will not be extrapolated to a weekly limit. If you set `timePerDay := 120` you will have exactly 2 hours of game time available every day.

**DisplayGUI:** if set to `0`, then the remaining time will not be displayed as a game overlay. If set to `1`, then the timer will appear in the upper left corner. 

**OvertimeAllowed:** if set to `1`, overtime will be allowed- a player can continue to play, at a 3 times time penalty. This works best with `ResetPolicy := 0`, otherwise the penalty isn't particularly meaningful. So, rely on an honor system, or, disable this to cause a hard cut-off, by setting `OvertimeAllowed := 0`





## Intended Use

This script is designed as a personal productivity tool. I want to limit my own video game usage. As such, I haven't focused on security or obfuscation- this is not written to hide the functionality from a hostile actor, eg, a computer-savvy child who might want to kill the script. It could probably be modified to do so.





