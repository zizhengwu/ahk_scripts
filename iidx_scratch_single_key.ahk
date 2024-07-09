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

last := 0 ;; q->0, w->1
q_down := 0
w_down := 0

$LShift::
    if (q_down)
        return
    Send, {b up}{b down}
    last := 0
    q_down := 1
return

$LShift up::
    if (last = 0) {
        Send, {b up}
    }
    q_down := 0
return

$;::
    if (w_down)
        return
    Send, {b up}{b down}
    last := 1
    w_down := 1
return

$; up::
    if (last = 1) {
        Send, {b up}
    }
    w_down := 0
return
