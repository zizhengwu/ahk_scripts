#NoEnv
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

SetCapsLockState, AlwaysOff
CapsLock::return

; --- Global Variables ---
global queue := []         ; Command queue for b events
global lastSentTime := 0   ; Timestamp when last command was sent
global minDelay := 16      ; Minimum delay between commands in ms (changed to 16ms)
last := 0                  ; Which key last initiated a press: 0 = LShift, 1 = ;
q_down := 0                ; State flag for LShift
w_down := 0                ; State flag for semicolon

; Initialize with current time minus delay to allow immediate first command
lastSentTime := A_TickCount - minDelay

; Start a timer that polls very frequently
SetTimer, ProcessQueue, 2

; --- Function to try sending command immediately or queue it ---
QueueCommand(cmd) {
    global queue, lastSentTime, minDelay
    currentTime := A_TickCount
    
    ; Try to send immediately if enough time has passed
    if (currentTime - lastSentTime >= minDelay) {
        Send, %cmd%
        lastSentTime := currentTime
        return
    }
    
    ; Otherwise, queue it with timestamp
    queue.Push({command: cmd, timestamp: currentTime})
}

; --- Timer Routine: Process queued commands as soon as timing allows ---
ProcessQueue:
    global queue, lastSentTime, minDelay
    if (queue.Length() > 0) {
        currentTime := A_TickCount
        
        ; If enough time has passed since last command, send next command
        if (currentTime - lastSentTime >= minDelay) {
            cmdObj := queue.RemoveAt(1)
            Send, % cmdObj.command
            lastSentTime := currentTime
        }
    }
return

; --- Hotkeys ---

; LShift (simulate scratch input)
$LShift::
    if (q_down)
        return
    QueueCommand("{b up}")
    QueueCommand("{b down}")
    last := 0
    q_down := 1
return

$LShift up::
    if (last = 0)
        QueueCommand("{b up}")
    q_down := 0
return

; Semicolon (simulate alternate scratch input)
$;::
    if (w_down)
        return
    QueueCommand("{b up}")
    QueueCommand("{b down}")
    last := 1
    w_down := 1
return

$; up::
    if (last = 1)
        QueueCommand("{b up}")
    w_down := 0
return