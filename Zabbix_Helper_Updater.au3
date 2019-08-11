#include <myDebug.au3>
#include <FTPEx.au3>
Opt("MustDeclareVars", 1)
Global Const $g_ZHK_esUnitName = "Zabbix Helper Updater"
Global Const $g_ZHK_efVersion =  0.1
Global Const $g_esDebug = True
Global Enum $placeholder, $eLogWindow, $eConsoleWrite, $eMsgBox, $eFileWrite, $NotepadWindow
Global Const $bTimeStamp = True 
Global $sLocalPath = "C:\zabbix"
Global $sLogFileName = StringLower(StringReplace($g_ZHK_esUnitName, " ", "_")) & ".log"
Global $g_ZHKdebug_sLogFilePath = $sLocalPath & "\" & $sLogFileName

Global $g_sRemoteRepositoryPath = String(IniRead("ZHK_Uploader", "Configuration", "RemoteRepositoryPath", "/ftp/zabbix"))
Global $g_sRemoteZHKVersionFile = "zhk_version"
Global $g_sRemoteZHKVersionFilePath = $g_sRemoteRepositoryPath & "/" & $g_sRemoteZHKVersionFile
Global $g_sFTPServer = String(IniRead("ZHK_Uploader", "Configuration", "FTPServer", ""))
Global $g_sFTPUsername = String(IniRead("ZHK_Uploader", "Configuration", "FTPUsername", ""))
Global $g_sFTPPassword = String(IniRead("ZHK_Uploader", "Configuration", "FTPPassword", ""))

_DebugSetup($g_ZHK_esUnitName, $g_esDebug, $eConsoleWrite, $g_ZHKdebug_sLogFilePath, $bTimeStamp)

_myDebug("Запуск модуля Zabbix Helper: " & $g_ZHK_esUnitName)
_myDebug("Параметры инициализации :", 1)
_myDebug("Текущая версия ZHK:  " & $g_ZHK_efVersion)
_myDebug("Путь к логфайлу: " & $g_ZHKdebug_sLogFilePath)
_myDebug("Путь к файлу версий ZHK в репозитории: " & $g_sRemoteZHKVersionFilePath)

Func _ServiceStop($sServiceName)
   _myDebug("Останавливаю сервис " & $sServiceName)
   Local $var = RunWait(@ComSpec & " /c " & 'net stop "'&$sServiceName&'"', "", @SW_HIDE)
   If @error Then
	  _myDebug("Ошибка остановки сервиса")
   Else
	  _myDebug("Сервис остановлен")
   EndIf
EndFunc

Func _ServiceStart($sServiceName)
   _myDebug("Запускаю сервис " & $sServiceName)
   Local $var = RunWait(@ComSpec & " /c " & 'net start "'&$sServiceName&'"', "", @SW_HIDE)
   If @error Then
	  _myDebug("Ошибка запуска сервиса")
   Else
	  _myDebug("Сервис запущен")
   EndIf
EndFunc