AppsKey::RWin
Pause::CapsLock
#If WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe Code.exe") || WinActive("ahk_exe XYplorer.exe") || WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe Listary.exe")
`::Esc
Esc::`
#If
#IfWinNotActive ahk_exe spice64.exe
CapsLock::RCtrl
#IfWinNotActive

#IfWinActive ahk_exe Ryujinx.exe
VKDC::Delete
#IfWinActive

; Dragon's dogma 2
#IfWinActive ahk_exe DD2.exe

`::0

*1::
    Send, {RCtrl Down}{1 Down}
return
*1 Up::
    Send, {1 Up}{RCtrl Up}
return

*2::
    Send, {RCtrl Down}{2 Down}
return
*2 Up::
    Send, {2 Up}{RCtrl Up}
return

*3::
    Send, {RCtrl Down}{3 Down}
return
*3 Up::
    Send, {3 Up}{RCtrl Up}
return

*4::
    Send, {RCtrl Down}{4 Down}
return
*4 Up::
    Send, {4 Up}{RCtrl Up}
return

*r::
    Send, {RCtrl Down}{r Down}
return
*r Up::
    Send, {r Up}{RCtrl Up}
return

*t::
    Send, {RCtrl Down}{t Down}
return
*t Up::
    Send, {t Up}{RCtrl Up}
return

*b::
    Send, {RCtrl Down}{b Down}
return
*b Up::
    Send, {b Up}{RCtrl Up}
return

*g::
    Send, {RCtrl Down}{g Down}
return
*g Up::
    Send, {g Up}{RCtrl Up}
return
#IfWinActive