; #INDEX# =======================================================================================================================
; Title .........: Zabbix Helper Updater
; AutoIt Version : 3.3.14.5
; Description ...: Программа для обновления Zabbix Helper Kit и Zabbix Agent + файл конфигурации заббикс агента
; Author(s) .....: Belfigor
; www ...........: adminguide.ru
; Dependencies ..: _myDebug.au3
; ===============================================================================================================================

#include <myDebug.au3>
#include <FTPEx.au3>
Opt("MustDeclareVars", 1)
OnAutoItExitRegister ("_Exit")
Global Const $g_ZHK_esUnitName = "Zabbix Helper Updater"
Global Const $g_ZHK_esZabbixHelperUnitName = "Zabbix Helper"
Global Const $g_ZHK_efVersion =  0.1
Global Const $g_esDebug = True
Global Enum $placeholder, $eLogWindow, $eConsoleWrite, $eMsgBox, $eFileWrite, $NotepadWindow
Global Const $bTimeStamp = True
Global Const $g_esDefaultFTPServer = "192.168.1.5"
Global Const $g_esDefaultFTPUsername = "zabbix_helper"
Global Const $g_esDefaultFTPPassword = "gVVqW4"
Global Const $g_esDefaultRemoteRepositoryPath = "/ftp/zabbix"
Global Const $g_esDefaultDeployZabbixHelper = "0"
Global Const $g_esUser = "/RU rogaikopita\admin"
Global Const $g_esPassword = "/RP 123JaAdmincheg!"

Global Const $g_esSectionNameConfiguration = "Configuration"
Global Const $g_esKeyNameLocalRepositoryVersion = "LocalRepositoryVersion"
Global Const $g_esKeyNameRemoteRepositoryPath = "RemoteRepositoryPath"
Global Const $g_esKeyNameFTPServer = "FTPServer"
Global Const $g_esKeyNameFTPUsername = "FTPUsername"
Global Const $g_esKeyNameFTPPassword = "FTPPassword"
Global Const $g_esKeyNameDeployZabbixHelper = "DeployZabbixHelper"
Global $sLocalRepositoryPath = "C:\zabbix"
Global $sLogFileName = StringLower(StringReplace($g_ZHK_esUnitName, " ", "_")) & ".log"
Global $g_ZHKdebug_sLogFilePath = $sLocalRepositoryPath & "\" & $sLogFileName
Global $g_sOSArch = @OSArch

Global $g_sZHKUpdaterConfFileName = "ZHK_Updater.cfg"
Global $g_sLocalZHKUpdaterConfFilePath = $sLocalRepositoryPath & "\" & $g_sZHKUpdaterConfFileName
Global $g_sZHKUpdaterInstallationFileName = "ZHK_Installation_Status.cfg"
Global $g_sLocalZHKUpdaterInstallationFilePath = $sLocalRepositoryPath & "\" & $g_sZHKUpdaterInstallationFileName

Global $g_fZHKLocalRepositoryVersion = Number(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameLocalRepositoryVersion, 0))
Global $g_sRemoteRepositoryPath = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameRemoteRepositoryPath, $g_esDefaultRemoteRepositoryPath))
Global Const $g_sRemoteZHKVersionFile = "zhk_version"
Global $g_sRemoteZHKVersionFilePath = $g_sRemoteRepositoryPath & "/" & $g_sRemoteZHKVersionFile
Global Const $g_sX64FolderName =  "amd64"
Global $g_sX64RemoteRepositoryPath =  $g_sRemoteRepositoryPath & "/" & $g_sX64FolderName
Global Const $g_sX86FolderName =  "i386"
Global $g_sX86RemoteRepositoryPath =  $g_sRemoteRepositoryPath & "/" & $g_sX86FolderName
Global Const $g_sZabbixAgentFileName = "zabbix_agentd.exe"
Global Const $g_sZabbixAgentMainConfFileName = "zabbix_agentd.win.conf"
Global $g_sFTPServer = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPServer, $g_esDefaultFTPServer))
Global $g_sFTPUsername = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPUsername, $g_esDefaultFTPUsername))
Global $g_sFTPPassword = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPPassword, $g_esDefaultFTPPassword))

Global $g_iDeployZabbixHelper = Number(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameDeployZabbixHelper, $g_esDefaultDeployZabbixHelper))

Global $g_iZHKUpdaterInstalled = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZHKUpdaterIsInstalled", 0))
Global $g_iZabbixAgentInstalled = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZabbixAgentInstalled", 0))
Global $g_iZHKHelperInstalled = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZHKHelperInstalled", 0))

_DebugSetup($g_ZHK_esUnitName, $g_esDebug, $eFileWrite, $g_ZHKdebug_sLogFilePath, $bTimeStamp)

_myDebug("Запуск модуля Zabbix Helper: " & $g_ZHK_esUnitName)
_myDebug("Параметры инициализации :", 1)
_myDebug("Текущая версия ZHK:  " & $g_ZHK_efVersion)
_myDebug("Путь к логфайлу: " & $g_ZHKdebug_sLogFilePath)
_myDebug("Путь к локальному файлу конфигурации: " & $g_sLocalZHKUpdaterConfFilePath)
_myDebug("Путь к файлу версий ZHK в репозитории: " & $g_sRemoteZHKVersionFilePath)
_myDebug("Архитектура текущей ОС: " & $g_sOSArch)
_myDebug("Версия локального репозитория: " & $g_fZHKLocalRepositoryVersion)
_myDebug("Маркер установки Zabbix Agent: " & $g_iZabbixAgentInstalled)
_myDebug("Маркер установки Zabbix Helper: " & $g_iZHKHelperInstalled)
_myDebug("Маркер установки Zabbix Helper Updater: " & $g_iZHKUpdaterInstalled)

If _getWorkGroup() = "WORKGROUP" Then
	Global $g_bInDomain = False
Else
	Global $g_bInDomain = True
EndIf

_myDebug("Нахождение в домене: " & $g_bInDomain)

If $g_sOSArch =  "X64" Then
	Global $g_sCurOSArchRemoteRepositoryPath = $g_sX64RemoteRepositoryPath
ElseIf $g_sOSArch =  "X86" Then
	Global $g_sCurOSArchRemoteRepositoryPath = $g_sX86RemoteRepositoryPath
Else
	_myDebug("Не описан репозиторий для архитектуры: " & $g_sOSArch)
	_Exit()
EndIf
_myDebug("Репозиторий для текущей архитектуры агента: " & $g_sCurOSArchRemoteRepositoryPath)

_myDebug("Имя раздела с настройками:" & $g_esSectionNameConfiguration)
_myDebug($g_esKeyNameLocalRepositoryVersion & ":" & $g_fZHKLocalRepositoryVersion)
_myDebug($g_esKeyNameRemoteRepositoryPath & ":" & $g_sRemoteRepositoryPath)
_myDebug($g_esKeyNameFTPServer & ":" & $g_sFTPServer)
_myDebug($g_esKeyNameFTPUsername & ":" & $g_sFTPUsername)
_myDebug($g_esKeyNameFTPPassword & ":" & $g_sFTPPassword)
_myDebug($g_esKeyNameDeployZabbixHelper & ":" & $g_iDeployZabbixHelper)

_myDebug("Конец параметров инициализации", -1)

Global $hFTPOpen = _FTP_Open('Zabbix Helper Kit FTP session')
If @error Then
	_myDebug("Не удалось инициализировать FTP сессию. Ошибка: " & @error)
	Exit
Else
   _myDebug("FTP сессия инициализирована")
EndIf


Global $hFTPConn = _FTP_Connect($hFTPOpen, $g_sFTPServer, $g_sFTPUsername, $g_sFTPPassword)
If @error Then
   _myDebug("Не могу подколючиться к FTP")
	Exit
Else
   _myDebug("Подключение к FTP установлено")
EndIf

If $g_fZHKLocalRepositoryVersion < _getZHKUpdaterRemoteVersion($g_sRemoteZHKVersionFilePath) Then
	_myDebug("Необходимо обновление локального репозитория")

	_getZabbixAgentLastVersion()
	_getZabbixAgentApplyUpdate()
	If $g_iZabbixAgentInstalled = 0 Then _installZabbixAgent()

	_getZHKUpdaterConfLastVersion()
	_getZHKUpdaterConfApplyUpdate()
	If $g_iZHKUpdaterInstalled = 0 Then _installZHKUpdater()


	If $g_iDeployZabbixHelper = 1 Then
		_getZHKHelperLastVersion()
		_getZHKHelperApplyUpdate()
		If $g_iZHKHelperInstalled = 0 Then _installZHKHelper()
	EndIf
Else
	_myDebug("Обновление локального репозитория не требуется")
EndIf

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
	_myDebug("Использованная команда: " & $sCMDCommand)
	_myDebug("", -1)
	Sleep(5000)
EndFunc

Func _getWorkGroup()
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = ""
	Local $strComputer = "localhost"

	Local $Output=""
	$Output &= "Computer: " & $strComputer  & @CRLF
	$Output &= "==========================================" & @CRLF
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\")
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL", _
											  $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) then
	   For $objItem In $colItems
		   Return $objItem.Workgroup
	   Next
	EndIf
EndFunc

Func _getZHKUpdaterRemoteVersion($sPath)
	_myDebug("Проверяю версию ZHK Updater в удалённом репозитории", 1)
	_myDebug("Путь к файлу версии: " & $sPath)
	Local $hFTPFile = _FTP_FileOpen ($hFTPConn, $sPath)
	If @error Then
		_myDebug("Ошибка при открытии файла на фтп: " & @error)
		Return SetError(1, 1, False)
	EndIf
	Local $fRemoteVersion = BinaryToString(_FTP_FileRead($hFTPFile, 10))
	If @error Then
		_myDebug("Ошибка при чтении файла с фтп: " & @error)
		Return SetError(2, 2, False)
	EndIf
	_myDebug("Версия ZHK Updater в репозитории:"&$fRemoteVersion)
	If @error Then Return SetError(3,3,False)
	_FTP_FileClose ($hFTPFile)
	_myDebug("", -1)
	Return Number(BinaryToString($fRemoteVersion))
EndFunc

Func _getZHKHelperLastVersion()
	_myDebug("Загружаю последнюю версию Zabbix Helper", 1)
	Local $sZabbixHelperRemoteFilePath = $g_sRemoteRepositoryPath & "/" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe"
	_myDebug("Путь к файлу Zabbix Helper в удалённом репозитории: " & $sZabbixHelperRemoteFilePath)
	Local $sZabbixHelperLocalFilePath = $sLocalRepositoryPath & "\upd_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe"
	_myDebug("Путь к новому файлу Zabbix Helper в локальном репозитории: " & $sZabbixHelperLocalFilePath)
	Local $iFileGet = _FTP_FileGet($hFTPConn, $sZabbixHelperRemoteFilePath, $sZabbixHelperLocalFilePath)
	If Not $iFileGet Then
		_myDebug("Ошибка при загрузке обновления" & @error)
	Else
		_myDebug("Обновление загружено")
	EndIf
	_myDebug("", -1)
EndFunc

Func _getZHKHelperApplyUpdate()
	_myDebug("Применяю обновление Zabbix Helper", 1)
	FileMove($sLocalRepositoryPath & "\" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", $sLocalRepositoryPath & "\bkp_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", 1)
	FileMove($sLocalRepositoryPath & "\upd_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", $sLocalRepositoryPath & "\" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", 1)
	_myDebug("", -1)
EndFunc

Func _installZHKHelper()
	_myDebug("Устанавливаю Zabbix Helper", 1)
	Local $sUser = $g_esUser
	Local $sPassword = $g_esPassword
	If $g_bInDomain Then
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper" /tr "' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:00 /RL HIGHEST '&$sUser&' '&$sPassword, "", @SW_HIDE)
	Else
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper" /tr "' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:00 /RL HIGHEST /RU SYSTEM', "", @SW_HIDE)
	EndIf
	Sleep(20000)
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Helper Kit - Zabbix Helper" dir=in action=allow program="' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZHKHelperInstalled", 1)
	_myDebug("", -1)
EndFunc

Func _getZHKUpdaterConfLastVersion()
	_myDebug("Загружаю последнюю конфигурацию Zabbix Helper Updater", 1)
	Local $sZabbixHelperConfRemoteFilePath = $g_sRemoteRepositoryPath & "/" & $g_sZHKUpdaterConfFileName
	_myDebug("Путь к файлу конфигурации Zabbix Helper Updater в удалённом репозитории: " & $sZabbixHelperConfRemoteFilePath)
	Local $sZabbixHelperConfLocalFilePath = $sLocalRepositoryPath & "\upd_" & $g_sZHKUpdaterConfFileName
	_myDebug("Путь к новому файлу конфигурации Zabbix Helper Updater в локальном репозитории: " & $sZabbixHelperConfLocalFilePath)
	Local $iFileGet = _FTP_FileGet($hFTPConn, $sZabbixHelperConfRemoteFilePath, $sZabbixHelperConfLocalFilePath)
	If Not $iFileGet Then
		_myDebug("Ошибка при загрузке обновления" & @error)
	Else
		_myDebug("Обновление загружено")
	EndIf
	_myDebug("", -1)
EndFunc

Func _getZHKUpdaterConfApplyUpdate()
	_myDebug("Применяю обновление файла конфигурации Zabbix Helper Updater", 1)
	FileMove($sLocalRepositoryPath & "\" & $g_sZHKUpdaterConfFileName, $sLocalRepositoryPath & "\bkp_" & $g_sZHKUpdaterConfFileName, 1)
	FileMove($sLocalRepositoryPath & "\upd_" & $g_sZHKUpdaterConfFileName, $sLocalRepositoryPath & "\" & $g_sZHKUpdaterConfFileName, 1)
	_myDebug("", -1)
EndFunc

Func _getZabbixAgentLastVersion()
	_myDebug("Загружаю последнюю версию Zabbix Agent", 1)
	Local $sZabbixAgentRemoteFilePath = $g_sCurOSArchRemoteRepositoryPath & "/" & $g_sZabbixAgentFileName
	_myDebug("Путь к файлу Zabbix Agent в удалённом репозитории: " & $sZabbixAgentRemoteFilePath)
	Local $sZabbixAgentLocalFilePath = $sLocalRepositoryPath & "\upd_" & $g_sZabbixAgentFileName
	_myDebug("Путь к новому файлу Zabbix Agent в локальном репозитории: " & $sZabbixAgentLocalFilePath)
	Local $iFileGet = _FTP_FileGet($hFTPConn, $sZabbixAgentRemoteFilePath, $sZabbixAgentLocalFilePath)
	If Not $iFileGet Then
		_myDebug("Ошибка при загрузке обновления" & @error)
	Else
		_myDebug("Обновление загружено")
	EndIf
	_myDebug("", -1)

	_myDebug("Загружаю последнюю версию основной конфигурации Zabbix Agent", 1)
	Local $sZabbixAgentMainConfRemoteFilePath = $g_sRemoteRepositoryPath & "/" & $g_sZabbixAgentMainConfFileName
	_myDebug("Путь к файлу конфигурации Zabbix Agent в удалённом репозитории: " & $sZabbixAgentMainConfRemoteFilePath)
	Local $sZabbixAgentMainConfLocalFilePath = $sLocalRepositoryPath & "\upd_" & $g_sZabbixAgentMainConfFileName
	_myDebug("Путь к новому файлу конфигурации Zabbix Agent в локальном репозитории: " & $sZabbixAgentMainConfLocalFilePath)
	Local $iFileGet = _FTP_FileGet($hFTPConn, $sZabbixAgentMainConfRemoteFilePath, $sZabbixAgentMainConfLocalFilePath)
	If Not $iFileGet Then
		_myDebug("Ошибка при загрузке обновления" & @error)
	Else
		_myDebug("Обновление загружено")
	EndIf
	_myDebug("", -1)
EndFunc

Func _getZabbixAgentApplyUpdate()
	_myDebug("Применяю обновление Zabbix Agent и его конфигурации", 1)
	_ServiceNet("Zabbix Agent", "stop")
	FileMove($sLocalRepositoryPath & "\" & $g_sZabbixAgentFileName, $sLocalRepositoryPath & "\bkp_" & $g_sZabbixAgentFileName, 1)
	FileMove($sLocalRepositoryPath & "\upd_" & $g_sZabbixAgentFileName, $sLocalRepositoryPath & "\" & $g_sZabbixAgentFileName, 1)
	FileMove($sLocalRepositoryPath & "\" & $g_sZabbixAgentMainConfFileName, $sLocalRepositoryPath & "\bkp_" & $g_sZabbixAgentMainConfFileName, 1)
	FileMove($sLocalRepositoryPath & "\upd_" & $g_sZabbixAgentMainConfFileName, $sLocalRepositoryPath & "\" & $g_sZabbixAgentMainConfFileName, 1)
	_ServiceNet("Zabbix Agent", "start")
	_myDebug("", -1)
EndFunc

Func _installZabbixAgent()
	_myDebug("Устанавливаю Zabbix Agent", 1)
	_ServiceNet("Zabbix Agent", "stop")
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Agent" dir=in action=allow program="' &$sLocalRepositoryPath& '\' & $g_sZabbixAgentFileName & '" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	Local $var = ShellExecute("c:\zabbix\zabbix_agentd.exe", " -c c:\zabbix\zabbix_agentd.win.conf -i", "")
	Sleep(20000)
	_ServiceNet("Zabbix Agent", "start")
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZabbixAgentInstalled", 1)
	_myDebug("", -1)
EndFunc

Func _installZHKUpdater()
	Local $sUser = $g_esUser
	Local $sPassword = $g_esPassword
	_myDebug("Устанавливаю Zabbix helper Updater", 1)
	If $g_bInDomain Then
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper Updater" /tr "' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:30 /RL HIGHEST '&$sUser&' '&$sPassword, "", @SW_HIDE)
	Else
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper Updater" /tr "' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:30 /RL HIGHEST /RU SYSTEM', "", @SW_HIDE)
	EndIf
	Sleep(20000)
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Helper Kit - Zabbix Helper Updater" dir=in action=allow program="' &$sLocalRepositoryPath& '\' & StringReplace($g_ZHK_esUnitName, " ", "_") & '.exe" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, "Installation", "ZHKUpdaterIsInstalled", 1)
	_myDebug("", -1)
EndFunc

Func _Exit()
	If IsDeclared("hFTPConn") Then _FTP_Close($hFTPConn)
	If IsDeclared("hFTPOpen") Then _FTP_Close($hFTPOpen)
EndFunc