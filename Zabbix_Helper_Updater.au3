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
_myDebug("Конец параметров инициализации", -1)
_ServiceNet("Zabbix Agent", "start")
_ServiceNet("Zabbix Agent", "stop")
_myDebug("Завершение работы модуля Zabbix Helper: " & $g_ZHK_esUnitName)

Func _ServiceNet($sServiceName, $sCommand)
	_myDebug("Останавливаю сервис " & $sServiceName, 1)
	Local $sCMDCommand = @ComSpec & " /c " & 'net '&$sCommand&' "'&$sServiceName&'"'
	Local $var = RunWait($sCMDCommand, "", @SW_HIDE)
	If @error Then
		_myDebug("Ошибка выполнения команды")
	Else
		_myDebug("Команда выполнена")
	EndIf
	_myDebug("Отправленная команда: " & $sCMDCommand)
	_myDebug("", -1)
EndFunc