#NoEnv
#Requires AutoHotkey v1
ListLines, Off
SetKeyDelay, -1
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1
Process, Priority, , High
Thread, Priority, 100  ; Set thread priority to maximum

; Elevate if not running as admin
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

; --- Global Variables ---
global queue := []         ; Command queue for events
global lastSentTime := 0   ; Timestamp when last command was sent
global minDelay := 32     ; Minimum delay between commands in ms
global LShift_Down := false
global left_down := 0
global right_down := 0

; Create log file and clear it at startup
logFile := A_ScriptDir . "\ahk_debug.log"
FileDelete, %logFile%
FileAppend, Script started at %A_Hour%:%A_Min%:%A_Sec%`n, %logFile%

; Create enhanced debug GUI with history
global debugMessages := []  ; Array to store the last 100 debug messages
global maxDebugMessages := 100  ; Maximum number of messages to keep

; Create a larger debug window with a ListView
; Gui, +AlwaysOnTop +Resize
; Gui, Add, ListView, r20 w600 vDebugList -Multi Grid, Time|Message
; Gui, Show, x50 y50 h400, Debug Window (Last 100 Messages)

; --- Debug Functions ---
LogDebummg(message) {
    global logFile, debugMessages, maxDebugMessages
    timestamp := A_TickCount
    formattedTime := FormatTime(timestamp)
    logMessage := formattedTime . ": " . message . "`n"
    
    ; Add to debug messages array
    debugMessages.Push({time: formattedTime, message: message})
    
    ; Keep only the last maxDebugMessages messages
    while (debugMessages.Length() > maxDebugMessages)
        debugMessages.RemoveAt(1)
    
    ; Update GUI ListView
    UpdateDebugListView()
    
    ; Write to log file
    FileAppend, %logMessage%, %logFile%
    
    ; Also output to debug console
    OutputDebug, %logMessage%
}

UpdateDebugListView() {
    global debugMessages
    
    ; Clear ListView
    LV_Delete()
    
    ; Populate with current messages (newest at top)
    For i, msg in debugMessages
        LV_Add("", msg.time, msg.message)
    
    ; Auto-size columns
    LV_ModifyCol(1, "AutoHdr")
    LV_ModifyCol(2, "AutoHdr")
    
    ; Scroll to the bottom to show newest messages
    LV_Modify(LV_GetCount(), "Vis")
}

FormatTime(timestamp) {
    time := A_Hour . ":" . A_Min . ":" . A_Sec . "." . SubStr("000" . Mod(timestamp, 1000), -2)
    return time
}

ShowQueueStatus() {
    global queue, lastSentTime, minDelay
    currentTime := A_TickCount
    timeSinceLastSent := currentTime - lastSentTime
    timeRemaining := Max(0, minDelay - timeSinceLastSent)
    
    status := "Queue length: " . queue.Length() 
            . " | Time since last: " . timeSinceLastSent . "ms"
            . " | Next can send in: " . timeRemaining . "ms"
    
    ; LogDebug(status)
}

; (Duplicate elevation block; remove if unneeded)
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

; Initialize with current time minus delay to allow immediate first command
lastSentTime := A_TickCount - minDelay

; Start a timer that polls very frequently
SetTimer, ProcessQueue, 1

SetCapsLockState, AlwaysOff
CapsLock::return

; --- Function to queue command (immediate send logic removed) ---
QueueCommand(cmd) {
    Critical, On
    global queue, lastSentTime
    currentTime := A_TickCount
    if (queue.Length() == 0 && currentTime - lastSentTime >= minDelay) {
        Send, % cmd
        lastSentTime := currentTime
        return
    }
    queue.Push({command: cmd})
    Critical, Off
    ; LogDebug("Queued: " . cmd)
    ; ShowQueueStatus()
}

; --- Timer Routine: Process queued commands as soon as timing allows ---
ProcessQueue:
    global queue, lastSentTime, minDelay
    ; ShowQueueStatus()
    while (queue.Length() > 0 && (queue[1].command == "{m up}" || queue[1].command == "{n up}" || queue[1].command == "{m up}{n up}")) {
        cmdObj := queue.RemoveAt(1)
        Send, % cmdObj.command
        ; LogDebug("Sent from queue: " . cmdObj.command)
    }
    if (queue.Length() > 0) {
        currentTime := A_TickCount
        if (currentTime - lastSentTime >= minDelay) {
            cmdObj := queue.RemoveAt(1)
            Send, % cmdObj.command
            ; LogDebug("Sent from queue: " . cmdObj.command)
            lastSentTime := currentTime
        }
    }
    sleep 30
    while (queue.Length() > 0 && (queue[1].command == "{m up}" || queue[1].command == "{n up}" || queue[1].command == "{m up}{n up}")) {
        cmdObj := queue.RemoveAt(1)
        Send, % cmdObj.command
        ; LogDebug("Sent from queue: " . cmdObj.command)
    }
return

; --- Hotkeys ---

^r::Reload  ; Press Ctrl+R to reload the script

$*LShift::
    Critical, On
    global left_down, lastDownTime, queue
    if (left_down) {
        return
    }
    left_down := 1
    ; LogDebug("left down")
    thisDownTime := A_TickCount
    lastDownTime := thisDownTime
    ; Queue the composite command
    QueueCommand("{m up}{n up}{m down}")
    Critical, Off
return

$*LShift up::
    Critical, On
    ; LogDebug("left up")
    left_down := 0
    if (queue[queue.Length()].command == "{m up}{n up}{n down}") {
        return
    }
    QueueCommand("{m up}{n up}")
    Critical, Off
return

$*;::
    Critical, On
    global right_down, lastDownTime, queue
    if (right_down) {
        return
    }
    right_down := 1
    ; LogDebug("right down")
    thisDownTime := A_TickCount
    lastDownTime := thisDownTime
    ; Queue the composite command
    QueueCommand("{m up}{n up}{n down}")
    Critical, Off
return

$*; up::
    Critical, On
    ; LogDebug("right up")
    right_down := 0
    if (queue[queue.Length()].command == "{m up}{n up}{m down}") {
        return
    }
    QueueCommand("{m up}{n up}")
    Critical, Off
return
