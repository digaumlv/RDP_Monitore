#include <Array.au3>

; Fun��o para fechar janelas de erro de conex�o
Func CloseErrorWindows()
    Local $windows = ["Remote Desktop Connection", "Conex�o de �rea de Trabalho Remota"]

    For $i = 0 To UBound($windows) - 1
        Local $window = $windows[$i]
        If WinExists($window, "&Help") Then
            ControlClick($window, "&Help", "Button1")
            WinClose($window, "&Help")
        ElseIf WinExists($window, "OK") Then
            ControlClick($window, "OK", "Button1")
            WinClose($window, "OK")
        EndIf
    Next
EndFunc

; Chamando a fun��o para fechar janelas de erro de conex�o
CloseErrorWindows()

; Criar objeto Shell.Application
$oShell = ObjCreate("Shell.Application")

; Caminho onde ser� criado o arquivo ini
$IniFile = @ScriptDir & "\configRDP.ini"

; Se o arquivo ini n�o existe, crie-o com valores padr�o
If Not FileExists($IniFile) Then
    IniWrite($IniFile, "RDPs", "aRDPsNames", "Dev")
    IniWrite($IniFile, "RDPs", "FolderRDPs", @DesktopDir & "\RDP\")
EndIf

; Lendo valores do arquivo ini para arrays
$RDPsNames = StringSplit(IniRead($IniFile, "RDPs", "aRDPsNames", "default"), ",")
$FolderRDPs = IniRead($IniFile, "RDPs", "FolderRDPs", "default")

Dim $aRDPsNames[0]
Dim $aRDPsPaths[0]

; Carregando valores da INI para arrays
For $i = 1 To UBound($RDPsNames) - 1
    _ArrayAdd($aRDPsNames, $RDPsNames[$i])
    _ArrayAdd($aRDPsPaths, $FolderRDPs & $RDPsNames[$i] & ".rdp")
Next

; Loop para monitorar as janelas
While True
    For $i = 0 To UBound($aRDPsNames) - 1
        Local $winTitle = $aRDPsNames[$i]
        Local $rdpFile = $aRDPsPaths[$i]

        ; Se a janela n�o existe, execute o arquivo RDP
        If Not WinExists($winTitle, "") Then
            ShellExecute($rdpFile)

            ; Aguarde at� que a janela esteja ativa
            If Not WinWaitActive($winTitle, "", 30) = 0 Then
                Sleep(2000)
                $oShell.TileVertically()
            Else
                ; Feche janelas de erro de conex�o
                CloseErrorWindows()
            EndIf
        Else
            ; Feche janelas de erro de conex�o
            CloseErrorWindows()
        EndIf
    Next

    ; Aguarde 5 segundos antes da pr�xima itera��o
    Sleep(5000)
WEnd
