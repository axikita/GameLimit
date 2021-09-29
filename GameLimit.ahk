#Persistent
SetWorkingDir E:\ahkReference

; SCRIPT CONFIGURATION VARIABLES: EDIT THESE TO CUSTOMIZE THIS SCRIPT.########################################
timePerDay := 120 ;minutes
TargetProcess = destiny2.exe


; initialization ----------------------------

timeBudget := timePerDay * 7 ;this is the budget per week, which will actually be controlled.
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


Overtime := 0








; Main Loop- this executes continuously while the program runs.####################################################################################
Loop{
	; MsgBox, % ArrayToString(Sessions)
	Process, Exist, % TargetProcess
	If (ErrorLevel = 0) ;process does not exist, game is not running.----------------------#
		{
		Gui, MyGUI: Destroy
		
		; If an active session has just ended, write it to the file--------------------------------------
		If (SessionActive = 1){
			SessionActive := 0
			; WriteSession(ByRef Year, ByRef Day, ByRef Start, ByRef Overtime, ByRef Sessions){
			; MsgBox, Sessions, Prewrite: 
			; MsgBox, % ArrayToString(Sessions)
			Sessions := WriteSession(SessionYear, SessionDay, SessionStart, Overtime, Sessions)
			; MsgBox, Sessions, postWrite: 
			; MsgBox, % ArrayToString(Sessions)
			
		}
		
		
		Sleep, 10000 ; This is how often we should check if the process is launched.
		}
		
		
		
		
	Else { ; Process Exists, aka, game is running.-------------------------------------------#
		
		; If an active session does not exist, create a new one---------------------------------------------
		If( SessionActive = 0){
		
			; check to make sure a new session is legal, if all the time is spent, don't allow.---------
			Sessions := CheckLoadedArray(Sessions)
			spent := TimeSpent(Sessions)
			
			if(spent > timeBudget){
				; kill new process, display error
				Process, Close, % TargetProcess
				sessionLog := ArrayToString(Sessions)
				message := "No play time remaining.`nLogged Sessions: `n`n" . sessionLog . "`n`nToday is " . A_YYYY . "," . A_YDay
				MsgBox, % message
				
			} else {
				SessionActive := 1
				SessionYear := A_YYYY
				SessionDay := A_YDay
				SessionStart := A_Hour * 60 + A_Min
				Overtime := 0
				
				; GUI_INIT: If you want to adjust the HUD, here's the place to do it.
				minuteTime := A_Hour * 60 + A_Min
				stringArr= [%A_YYYY%, %A_YDay%, %minuteTime%]
				guiTime := % TimeLeft(timeBudget, SessionStart, Sessions)
				stringDisplay := Format("Playtime: {1}", guiTime)
		
				Gui, MyGUI: Destroy
				Gui, MyGUI: +LastFound +AlwaysOnTop -Caption +ToolWindow  
				MyGuiID := WinExist()
				Gui, MyGUI: Color, 555555
				Gui, MyGUI: Font, cFFFFFF
				Gui, MyGUI: Font, s10
				Gui, MyGUI: Add, Text, vName, %stringDisplay%
				WinSet, TransColor, 555555 150 ;makes the specified color into transparent
				Gui, MyGUI: Show, x5 y30, NoActivate
				; END_GUI_INIT
			}
		} Else{ ;Still in current session
		
			if(overtime = 0){
		
				;check current length
				timeCheck := % TimeLeft(timeBudget, SessionStart, Sessions)
				; MsgBox, % timeCheck
				if( timeCheck < 0){
					;Prompt for overtime or close
					ovrResult := 0
					
					MsgBox, 4, , Would you like to go into OVERTIME?, 20
					IfMsgBox, No 
						ovrResult := 0
					Else
						ovrResult :=1
						
					if(ovrResult = 1){
						;write current session to file. Start a new overtime session.
						
						; MsgBox, Sessions, Prewrite: 
						; MsgBox, % ArrayToString(Sessions)
						Sessions := WriteSession(SessionYear, SessionDay, SessionStart, Overtime, Sessions)
						; MsgBox, Sessions, postWrite: 
						; MsgBox, % ArrayToString(Sessions)
						
						SessionActive := 1
						SessionYear := A_YYYY
						SessionDay := A_YDay
						SessionStart := A_Hour * 60 + A_Min
						overtime := 1
						; Gui, MyGUI: Destroy
						
						stringDisplay := "--OVERTIME--"
						Gui, OVR: +LastFound +AlwaysOnTop -Caption +ToolWindow  
						MyGuiID := WinExist()
						Gui, OVR: Color, 550000
						Gui, OVR: Font, cFF0000
						Gui, OVR: Font, s30
						Gui, OVR: Add, Text, vName, %stringDisplay%
						WinSet, TransColor, 550000 150 ;makes the specified color into transparent
						Gui, OVR: Show, xcenter y100, NoActivate
					} else {
					
						; MsgBox, Sessions, Prewrite: 
						; MsgBox, % ArrayToString(Sessions)
						Sessions := WriteSession(SessionYear, SessionDay, SessionStart, Overtime, Sessions)
						; MsgBox, Sessions, postWrite: 
						; MsgBox, % ArrayToString(Sessions)
						
						SessionActive := 0
						overtime := 0
						Process, Close, % TargetProcess
					}
				}
	
	
				; GUI Display---------------------------------------------------------------------------------------
				if WinExist(MyGuiID){
					GuiControl,, MyGUI, Edited, not replaced
					Sleep, 5000
				} else {
					
					minuteTime := A_Hour * 60 + A_Min
					stringArr= [%A_YYYY%, %A_YDay%, %minuteTime%]
					guiTime := % TimeLeft(timeBudget, SessionStart, Sessions)
					stringDisplay := Format("Playtime: {1}", guiTime)

					GuiControl, MyGUI:, Name, %StringDisplay%
			
					Sleep, 1000 ; This is how often we should check while the process is running, and refresh the GUI
				}
			} else { ;overtime = 1
				Gui, MyGUI: Destroy
				Sleep, 1000
			
			}
		}
	}
}


; Hotkey for Info#############################################################################
^!#F12:: 
DisplayInfo(){
	text := "GameLimit.ahk Info`nSessions:`n`n"
	global Sessions
	sessionText := ArrayToString(Sessions)
	global timeBudget
	startTime :=  A_Hour * 60 + A_Min
	timeText :=  TimeLeft(840, startTime, Sessions)
	text := text . sessionText
	MsgBox, % text
}



; Utilitiy Functions #############################################################################################################################

WriteSession(ByRef Year, ByRef Day, ByRef Start, ByRef penalty, ByRef Sess){
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
	
	newSession := Format("{1:i},{2:i},{3:i}", Year, Day, SessionTime)
	MsgBox, "adding the following new session:"
	MsgBox, % newSession
	Sess.Push(newSession)
	ArrayToFile(Sess) ;saves it to long term memory
	return Sess
}




; removes session entries that have expired.
CheckLoadedArray(ByRef arr){ 
	; MsgBox, evaluating: 
	; MsgBox, % ArrayToString(arr)

	savedValues := []


	Loop, % arr.MaxIndex() {
		thisSession := % arr[A_Index]
		
		elements := StrSplit(thisSession, ",")
		
		if(elements.MaxIndex() = 3){ ; only save properly formatted values
		
			if(elements[1] < %A_YYYY%){
			
				if(elements[2] >= (A_YDay + 365 - 6)){
					savedValues.Push(arr[A_Index])

				}
			} else {
		
				if(elements[2] >= (A_YDay - 6)){
					savedValues.Push(arr[A_Index])
					; MsgBox, pushing element
				}
			}
		}
	}
	; MsgBox, SavedValues: 
	; MsgBox, % ArrayToString(savedValues)
	return savedValues
}


; Calculates time spent in previous logged sessions
TimeSpent(ByRef arr){ 
	time := 0

	Loop, % arr.MaxIndex() {
		thisSession := % arr[A_Index]
		elements := StrSplit(thisSession, ",")
		thisTime := % elements[3]
		time := thisTime + time
	}
	
	return time
}

CurrentLength(ByRef Start){
	time := A_Hour * 60 + A_Min
	; MsgBox, % time
	if(time<Start){
		time := 1440 + A_Min ;add a day
	}
	elapsed := time - Start
	return elapsed
}

TimeLeft(ByRef Budget, byRef Start, ByRef sessArray){
	prevSpent := TimeSpent(sessArray)
	spentNow := CurrentLength(Start)
	
	Remaining := Budget-prevSpent-spentNow
	
	return Remaining

}



; Reverses an array. Not used/ depricated.
ReverseArray(ByRef arr){

	newArr := arr.Clone()
	
	Loop, % arr.MaxIndex() {
		newArr[arr.MaxIndex()-A_Index+1] := arr[A_Index]
	}
	
	return newArr

}



; creation of Array from file

FileToArray(){
	FileRead, LoadedText, GameLimitData.txt
	oText := StrSplit(LoadedText, "#")
	;MsgBox, Split array
	;MsgBox, % oText.MaxIndex()
	return oText
}

ArrayToFile(ByRef sess){
	fileString := ""
	delimiter := "#"
	Loop, % sess.MaxIndex(){
		fileString := fileString . sess[A_Index]
		fileString := filestring . delimiter
		}
				
	MsgBox, % fileString
	FileDelete, GameLimitData.txt
	FileAppend, % fileString, GameLimitData.txt
}

ArrayToString(ByRef sess){
	fileString := ""
	Loop, % sess.MaxIndex()
		fileString := fileString . sess[A_Index] . "`r"
	
	return fileString
}






 