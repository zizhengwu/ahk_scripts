#NoEnv
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
ListLines, Off
SetKeyDelay, -1
SetBatchLines, -1

left_down = 0
LastRightClick := 0

~$*Q::
    if (!left_down)
    {
        Send {Lbutton Down}
        left_down = 1
    }
    While GetKeyState("LButton", "P")
    {
        CurrentTime := A_TickCount
        If (CurrentTime - LastRightClick > 200)
        {
            SendInput {RButton}
            LastRightClick := CurrentTime
        }
    }
return

~$*Q Up::
    left_down = 0
    Send {Lbutton Up}
