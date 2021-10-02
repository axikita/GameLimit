#Persistent
SetWorkingDir %A_ScriptDir%

; BASIC SCRIPT CONFIGURATION VARIABLES: EDIT THESE TO CUSTOMIZE THIS SCRIPT.########################################

timePerDay := 120 ; minutes per day. This will be converted to a weekly budget if DailyReset is 0.
TargetProcesses := ["destiny2.exe"] ; list of processes. Format: ["destiny2.exe"] or ["destiny2.exe", "gw2.exe"]
ResetPolicy := 3 ; determines when reset takes effect. 0-> Rolling Basis 1->Sun 2->Mon 3->Tue 4->Wed 5->Thu 6->Fri 7->Sat
DailyReset := 0 ; 0-> Time Per Day is caluclated into time per week. 1-> Every day is independent, and you have %timePerDay% minutes to play.
dislpayGUI := 1 ; 1 -> gui will display remaining time as overlay, 0 -> no GUI will display, only the popup on process close.
overtimeAllowed := 1 ; 0 -> overtime dissalowed. 1-> overime allowed.

; END OF BASIC SCRIPT CONFIGURATION VARIABLES.######################################################################
; ADVANCED CONFIG VARIABLES ########################################################################################

 ; These are GUI coordinates for the overlays, measured from the upper left corner of the screen to the upper left corner of the text, in pixels.
GuiX := 5
GuiY := 30
 ; overtime GUi is centered, so only downward displacement is measured.
OvertimeGuiY := 100

; END OF ADVANCED SCRIPT CONFIGURATION VARIABLES.######################################################################

; initialization ----------------------------


if(DailyReset = 0){
	timeBudget := timePerDay * 7 ;this is the budget per week, which will actually be controlled.
} else {
	timeBudget := timePerDay ;this is the budget per day, which will actually be controlled.
}
timeRemaining := timePerDay

MyGuiID := ""

Sessions := FileToArray()
Sessions := CheckLoadedArray(Sessions)

; MsgBox, Sessions: 
; MsgBox, % ArrayToString(Sessions)


SessionActive := 0 ;0 is false, 1 is true
SessionYear := A_YYYY
SessionDay := A_YDay
SessionStart := A_Hour * 60 + A_Min
SessionDayDigit := A_WDay ;1-7, used for day of week identification
SessionDayStr := A_DDD ;String identifier, eg, "wed"- used for log displays


Overtime := 0









; Main Loop- this executes continuously while the program runs.####################################################################################
Loop{

	ProcessRunning := 0 ; set for loop. Will become 1 if any process is discovered.
	
	Loop, % TargetProcesses.MaxIndex() {
		Process, Exist, % TargetProcesses[A_Index]
		If (ErrorLevel = 0) { ; process does not exist, game is not running.----------------------#
			; do nothing
		} else {
			ProcessRunning := 1
		}			
	}
	
	If (ProcessRunning = 0) { ; process does not exist, game is not running.----------------------#
	
		Gui, MyGUI: Destroy
		
		; If an active session has just ended, write it to the file--------------------------------------
		If (SessionActive = 1){
			SessionActive := 0
			
			; WriteSession(ByRef Year, ByRef Day, ByRef DayDigit, ByRef DayStr, ByRef Start, ByRef penalty, ByRef Sess)
			Sessions := WriteSession(SessionYear, SessionDay, SessionDayDigit, SessionDayStr, SessionStart, Overtime, Sessions)

			
		}
		
		
	}
		
		
		
		
		
	Else { ; Process Exists, aka, game is running.-------------------------------------------#
		
		; If an active session does not exist, create a new one---------------------------------------------
		If( SessionActive = 0){
		
			; check to make sure a new session is legal, if all the time is spent, don't allow.---------
			Sessions := CheckLoadedArray(Sessions)
			spent := TimeSpent(Sessions)
			
			if(spent > timeBudget){
				; kill new process, display error
				Loop, % TargetProcesses.MaxIndex() {
					Process, Close, % TargetProcesses[A_Index]
				}
				
				sessionLog := ArrayToString(Sessions)
				message := "No play time remaining.`nLogged Sessions: `n`n" . sessionLog . "`n`nToday is " . A_YYYY . "," . A_YDay
				MsgBox, % message
				
			} else {
				SessionActive := 1
				SessionYear := A_YYYY
				SessionDay := A_YDay
				SessionStart := A_Hour * 60 + A_Min
				SessionDayDigit := A_WDay 
				SessionDayStr := A_DDD 
				Overtime := 0
				
				Gui, MyGUI: Destroy
				
				if(dislpayGUI = 1){
					; GUI_INIT: If you want to adjust the HUD, here's the place to do it.
					minuteTime := A_Hour * 60 + A_Min
					stringArr= [%A_YYYY%, %A_YDay%, %minuteTime%]
					guiTime := % TimeLeft(timeBudget, SessionStart, Sessions)
					
					clockDisplay := MinuteToClock(guiTime)	
				
					StringDisplay := "Playtime: " . clockDisplay

					Gui, MyGUI: +LastFound +AlwaysOnTop -Caption +ToolWindow  
					MyGuiID := WinExist()
					Gui, MyGUI: Color, 555555
					Gui, MyGUI: Font, cFFFFFF
					Gui, MyGUI: Font, s10
					Gui, MyGUI: Add, Text, vName, %stringDisplay%
					WinSet, TransColor, 555555 150 ;makes the specified color into transparent
					Gui, MyGUI: Show, x%GuiX% y%GuiY%, NoActivate
					; END_GUI_INIT
				}
			}
		} Else{ ;Still in current session, aka, a session is running and has not ended
		
			if(overtime = 0){
		
				; check current session duration
				timeCheck := % TimeLeft(timeBudget, SessionStart, Sessions)
				if( timeCheck < 0){
				
					if(overtimeAllowed = 1){
						; Prompt for overtime or close
						ovrResult := 0
					
						MsgBox, 4, , Would you like to go into OVERTIME?, 20
						IfMsgBox, No 
							ovrResult := 0
						Else
							ovrResult :=1
						
						if(ovrResult = 1){
							; Overtime selected. write current session to file. Start a new overtime session. Display overtime GUI.
						
							Sessions := WriteSession(SessionYear, SessionDay, SessionDayDigit, SessionDayStr, SessionStart, Overtime, Sessions)

							SessionActive := 1
							SessionYear := A_YYYY
							SessionDay := A_YDay
							SessionStart := A_Hour * 60 + A_Min
							SessionDayDigit := A_WDay 
							SessionDayStr := A_DDD 
							overtime := 1
						
							if(dislpayGUI = 1){
								stringDisplay := "--OVERTIME--"
								Gui, OVR: +LastFound +AlwaysOnTop -Caption +ToolWindow  
								MyGuiID := WinExist()
								Gui, OVR: Color, 550000
								Gui, OVR: Font, cFF0000
								Gui, OVR: Font, s30
								Gui, OVR: Add, Text, vName, %stringDisplay%
								WinSet, TransColor, 550000 150 ; makes the specified color into transparent
								Gui, OVR: Show, xcenter y%OvertimeGuiY%, NoActivate
							}
							
						
						} else {
							; No overtime. Write session to log, flag session as over, and kill target process
					
							Sessions := WriteSession(SessionYear, SessionDay, SessionDayDigit, SessionDayStr, SessionStart, Overtime, Sessions)

							SessionActive := 0
							overtime := 0
							Loop, % TargetProcesses.MaxIndex() {
								Process, Close, % TargetProcesses[A_Index]
							}
						}
					} else { 
						; overtime not allowed.
						
						MsgBox, Out of time, process will be terminated.
					
						Sessions := WriteSession(SessionYear, SessionDay, SessionDayDigit, SessionDayStr, SessionStart, Overtime, Sessions)

						SessionActive := 0
						overtime := 0
						Loop, % TargetProcesses.MaxIndex() {
							Process, Close, % TargetProcesses[A_Index]
						}
					
					}
				}
	
				
				; GUI Display---------------------------------------------------------------------------------------
				if(dislpayGUI = 1){
			
					minuteTime := A_Hour * 60 + A_Min
					stringArr= [%A_YYYY%, %A_YDay%, %minuteTime%]
					guiTime := % TimeLeft(timeBudget, SessionStart, Sessions)
					clockDisplay := MinuteToClock(guiTime)
					
					StringDisplay := "Playtime: " . clockDisplay

					GuiControl, MyGUI:, Name, %StringDisplay%
				}
				
			} else { ;overtime = 1
				Gui, MyGUI: Destroy
				
				; the session can go as long as the player wants, with penalty. The timer no longer logs, so, there's no GUI update to perform.
			
			}
		}
	}
	
	Sleep, 1000 ; run the main loop once every second. Every 1 second = 2.4MB ram, every 10 seconds = 2.1 MB ram.
}





; Hotkey for Info#############################################################################
^!#F12:: 
DisplayInfo(){
	processText = Processes monitored:`n

	global TargetProcesses
	Loop, % TargetProcesses.MaxIndex() {
		processText := processText . TargetProcesses[A_Index] . "`n"
	}
	
	
	text := processText . "`n`nLogged Sessions:`n`n"
	global Sessions
	sessionText := ArrayToString(Sessions)
	global timeBudget
	startTime :=  A_Hour * 60 + A_Min
	timeText :=  TimeLeft(840, startTime, Sessions)
	text := text . sessionText
	MsgBox, % text
}







; Utilitiy Functions #############################################################################################################################




; removes session entries that have expired.
CheckLoadedArray(ByRef arr){ 

	savedValues := []

	global ResetPolicy ;0 for rolling, 1=Sun
	
	global DailyReset ; 0 for weekly, 1 for hard daily limit
	
	if(DailyReset = 0){
	if( ResetPolicy = 0){ ;This is, check on a rolling basis.------------------------------------------


		Loop, % arr.MaxIndex() {
			thisSession := % arr[A_Index]
			
			elements := StrSplit(thisSession, ",")
			
			if(elements.MaxIndex() = 5){ ; only save properly formatted values. Year,DayOfYear,#weekday,strWeekday,SessionTime, eg, 2021,271,4,Wed,17 
			
				if(elements[1] < %A_YYYY%){
				
					if(elements[2] >= (A_YDay + 365 - 6)){
				
						if(elements[5] > 0){
							savedValues.Push(arr[A_Index])
						}

					}
				} else {
		
					if(elements[2] >= (A_YDay - 6)){
				
						if(elements[5] > 0){
							savedValues.Push(arr[A_Index])
						}
					
					}
				}
			}
		}
	
	} else { ; end ResetPolicy = 0, so, reset is based on the specific day, not on rolling.-------------------------
	
	
		Loop, % arr.MaxIndex() {
			thisSession := % arr[A_Index]
			
			elements := StrSplit(thisSession, ",")
			
			if(elements.MaxIndex() = 5){ ; only save properly formatted values. Year,DayOfYear,#weekday,strWeekday,SessionTime, eg, 2021,271,4,Wed,17 
				
				
				if(elements[1] < %A_YYYY%){
					; don't do anything if the session occured last year. The math is more complicated here and I don't feel like figuring out the year offset, so you get your time back on a new year. Happy new years.
				} else {
					; figure out RolloverDay for the entry. if RolloverDay <= today's day of year, then the session is no longer valid.
					if(elements[3]<ResetPolicy){
						RolloverDay := elements[2]-elements[3]+ResetPolicy
					} else {
						RolloverDay := elements[2]-elements[3]+ResetPolicy+7
					}
					
					if( A_YDay < RolloverDay){ ;rolloverday not yet reached, so, keep.
						if(elements[5] > 0){ ;only keep nonzero-minute sessions.
							savedValues.Push(arr[A_Index])
						}
					}
				}
			}
		}
	
	
	}
	} else { ; daily reset, drop any elements from previous days.
		Loop, % arr.MaxIndex() {
			thisSession := % arr[A_Index]
			
			elements := StrSplit(thisSession, ",")
			
			if(elements.MaxIndex() = 5){ ; only save properly formatted values. Year,DayOfYear,#weekday,strWeekday,SessionTime
				
				if(elements[2] = %A_YDay%){
					if(elements[5] > 0){
						savedValues.Push(arr[A_Index])
					}
				}
			}
	
		}
	}
	
	
	
	return savedValues
}






; Time calculation functions --------------------------------------------------------------

; Calculates time spent in previous logged sessions
TimeSpent(ByRef arr){ 
	time := 0

	Loop, % arr.MaxIndex() {
		thisSession := % arr[A_Index]
		elements := StrSplit(thisSession, ",")
		thisTime := % elements[5]
		time := thisTime + time
	}
	
	return time
}


; current session length. used as subprocess of TimeLeft()
CurrentLength(ByRef Start){
	time := A_Hour * 60 + A_Min
	if(time<Start){
		time := 1440 + A_Min ;add a day
	}
	elapsed := time - Start
	return elapsed
}


; Remaining time in budget, considering all factors.
TimeLeft(ByRef Budget, byRef Start, ByRef sessArray){
	prevSpent := TimeSpent(sessArray)
	spentNow := CurrentLength(Start)
	
	Remaining := Budget-prevSpent-spentNow
	
	return Remaining

}

MinuteToClock(minuteTime){
	timestring := ""
	clockHour := Floor(minuteTime / 60)
	clockMinute := minuteTime - (clockHour*60)
	if(clockMinute<10){
		timestring := clockHour . ":0" . clockMinute
	} else{
		timestring := clockHour . ":" . clockMinute
	}
	
	return timestring
}


; File Read/Write operations--------------------------------------------------------

WriteSession(ByRef Year, ByRef Day, ByRef DayDigit, ByRef DayStr, ByRef Start, ByRef penalty, ByRef Sess){
	Sess := CheckLoadedArray(Sess)

	SessionEnd := A_Hour * 60 + A_Min ; local, declared here
	If(SessionEnd<Start){
		SessionEnd := SessionEnd + 1440 ; add a day of time, session went past midnight.
	}
	if(penalty = 0){
		SessionTime := SessionEnd - Start
	} else {
		Gui, OVR: Destroy
		Gui, MyGUI: Destroy
		SessionTime := (SessionEnd - Start) * 3
	}
	
	newSession := Format("{1:i},{2:i},{3:i},{4},{5:i}", Year, Day, DayDigit, DayStr, SessionTime)
	
	msgText := "Play session recorded:`n`n" . Year . ", " . DayStr . ", " . SessionTime . " minutes`n`n`n`n Press CTRL+ALT+WIN+F12 for session logs."
	MsgBox, % msgText
	;MsgBox, % newSession
	Sess.Push(newSession)
	ArrayToFile(Sess) ;saves it to long term memory
	return Sess
}


; creation of Array from file
FileToArray(){
	FileRead, LoadedText, GameLimitData.txt
	oText := StrSplit(LoadedText, "#")
	;MsgBox, Split array
	;MsgBox, % oText.MaxIndex()
	return oText
}


; performs write operation. Overwrites existing file. Creates a new file even if one didn't exist.
ArrayToFile(ByRef sess){
	fileString := ""
	delimiter := "#"
	Loop, % sess.MaxIndex(){
		fileString := fileString . sess[A_Index]
		fileString := filestring . delimiter
		}
				
	FileDelete, GameLimitData.txt
	FileAppend, % fileString, GameLimitData.txt
}


; For logging. don't use this for file writing.
ArrayToString(ByRef sess){
	runningTime := 0
	fileString := ""
	Loop, % sess.MaxIndex(){
		thisSession := % sess[A_Index]
		elements := StrSplit(thisSession, ",")
		
		fileString := fileString . elements[1] . "," elements[4] . "," . elements[5] . " minutes`r"
		runningTime := runningTime + elements[5]
	}
	
	global TimeBudget
	
	timeLeft := TimeBudget-runningTime
	
	filestring := filestring . "`r`r` Time remaining: " . MinuteToClock(timeLeft) . " out of " . MinuteToClock(timeBudget)
	
	global ResetPolicy
	
	global DailyReset
	
	if(DailyReset = 0){
	if(ResetPolicy = 0){
		filestring := filestring . "`r`r` Reset occurs on a rolling basis."
	}
	if(ResetPolicy = 1){
		filestring := filestring . "`r`r` Reset occurs on Sunday."
	}
	if(ResetPolicy = 2){
		filestring := filestring . "`r`r` Reset occurs on Monday."
	}
	if(ResetPolicy = 3){
		filestring := filestring . "`r`r` Reset occurs on Tuesday."
	}
	if(ResetPolicy = 4){
		filestring := filestring . "`r`r` Reset occurs on Wednesday."
	}
	if(ResetPolicy = 5){
		filestring := filestring . "`r`r` Reset occurs on Thursday."
	}
	if(ResetPolicy = 6){
		filestring := filestring . "`r`r` Reset occurs on Friday."
	}
	if(ResetPolicy = 7){
		filestring := filestring . "`r`r` Reset occurs on Saturday."
	}
	} else {
		filestring := filestring . "`r`r` Reset occurs Tomorrow."
	}
	
	return fileString
}






 