#NoEnv
ListLines, Off
SetKeyDelay, -1
SetBatchLines, -1

toggle := 1
last := 0 ;; q->0, w->1
q_down := 0
w_down := 0

$LShift::
    if (q_down)
        return
    q_down := 1
    last := 0
    Send, {m up}{n up}
    Send, % toggle ? "{m down}" : "{n down}"
    toggle := !toggle
return

$LShift up::
    q_down := 0
    if (last = 0) {
        Send, {m up}{n up}
    }
return

$;::
    if (w_down)
        return
    w_down := 1
    last := 1
    Send, {m up}{n up}
    Send, % toggle ? "{m down}" : "{n down}"
    toggle := !toggle
return

$; up::
    w_down := 0
    if (last = 1) {
        Send, {m up}{n up}
    }
return
