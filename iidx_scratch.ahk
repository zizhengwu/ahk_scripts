#NoEnv
ListLines, Off
SetKeyDelay, -1
SetBatchLines, -1

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

toggle := 1
last := 0 ;; q->0, w->1
q_down := 0
w_down := 0

$LShift::
    if (q_down)
        return
    Send, {m up}{n up}
    Send, % toggle ? "{m down}" : "{n down}"
    q_down := 1
    last := 0
    toggle := !toggle
return

$LShift up::
    if (last = 0) {
        Send, {m up}{n up}
    }
    q_down := 0
return

$;::
    if (w_down)
        return
    Send, {m up}{n up}
    Send, % toggle ? "{m down}" : "{n down}"
    w_down := 1
    last := 1
    toggle := !toggle
return

$; up::
    if (last = 1) {
        Send, {m up}{n up}
    }
    w_down := 0
return
