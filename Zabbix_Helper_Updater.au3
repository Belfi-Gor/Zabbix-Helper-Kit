; #INDEX# =======================================================================================================================
; Title .........: Zabbix Helper Updater
; Version .......: 0.4
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


Global Const $g_esZHK_esUnitName = "Zabbix Helper Updater"
Global Const $g_efZHK_efVersion =  0.3
Global $g_sOSArch = @OSArch
Global $g_bIsAdmin = IsAdmin()
Global $g_sScriptFullPath = @ScriptFullPath
Global Const $g_esLocalRepositoryRoot = "C:\zabbix"
Global Const $g_esDefaultZabbixAgentFileName = "zabbix_agentd.exe"
Global Const $g_esDefaultZabbixAgentMainConfFileName = "zabbix_agentd.win.conf"
Global Const $g_efDefaultZHKLocalRepositoryVersion = 0
Global Const $g_esDefaultRemoteRepositoryPath = "/ftp/zabbix"
Global Const $g_esDefaultFTPServer = "192.168.1.5"
Global Const $g_esDefaultFTPUsername = "zabbix_helper"
Global Const $g_esDefaultFTPPassword = "gVVqW4"
Global Const $g_esDefaultDeployZabbixHelper = 0
Global Const $g_eiDefaultZHKUpdaterIsInstalledTrigger = 0
Global Const $g_eiDefaultZabbixAgentIsInstalledTrigger = 0
Global Const $g_eiDefaultZHKHelperIsInstalledTrigger = 0
Global Const $g_esDefaultUsername = "rogaikopita\admin"
Global Const $g_esDefaultPassword = "123JaAdmincheg!"
Global Const $g_esDefaultRemoteZHKVersionFile = "zhk_version"
Global Const $g_esDefaultX64FolderName = "amd64"
Global Const $g_esDefaultX86FolderName = "i386"
Global Const $g_esDefaultWorkgroupName = "WORKGROUP"
Global $g_sLogFileName = StringLower(StringReplace($g_esZHK_esUnitName, " ", "_")) & ".log"
Global Const $g_esZHKUpdaterConfFileName = "ZHK_Updater.cfg"
Global $g_sLocalZHKUpdaterConfFilePath = $g_esLocalRepositoryRoot & "\" & $g_esZHKUpdaterConfFileName
Global Const $g_esZHKUpdaterInstallationFileName = "ZHK_Installation_Status.cfg"
Global $g_sLocalZHKUpdaterInstallationFilePath = $g_esLocalRepositoryRoot & "\" & $g_esZHKUpdaterInstallationFileName
Global Const $bTimeStamp = True
Global $g_ZHKdebug_sLogFilePath = $g_esLocalRepositoryRoot & "\" & $g_sLogFileName
Global Enum $placeholder, $eLogWindow, $eConsoleWrite, $eMsgBox, $eFileWrite, $NotepadWindow
Global Const $g_esDebug = True
_DebugSetup($g_esZHK_esUnitName, $g_esDebug, $eFileWrite, $g_ZHKdebug_sLogFilePath, $bTimeStamp)
Global Const $g_esSectionNameConfiguration = "Configuration"
Global Const $g_esKeyNameZabbixAgentFileName = "ZabbixAgentFileName"
Global Const $g_esKeyNameZabbixAgentMainConfFileName = "ZabbixAgentMainConfFileName"
Global Const $g_esKeyNameLocalRepositoryVersion = "LocalRepositoryVersion"
Global Const $g_esKeyNameRemoteRepositoryPath = "RemoteRepositoryPath"
Global Const $g_esKeyNameFTPServer = "FTPServer"
Global Const $g_esKeyNameFTPUsername = "FTPUsername"
Global Const $g_esKeyNameFTPPassword = "FTPPassword"
Global Const $g_esKeyNameDeployZabbixHelper = "DeployZabbixHelper"
Global Const $g_esKeyNameRemoteZHKVersionFile = "RemoteZHKVersionFile"
Global Const $g_esKeyNameX64FolderName = "X64FolderName"
Global Const $g_esKeyNameX86FolderName = "X86FolderName"
Global Const $g_esSectionNameWindowsUser = "WindowsUser"
Global Const $g_esKeyNameUsername = "Username"
Global Const $g_esKeyNamePassword = "Password"
Global Const $g_esKeyNameWorkgroup = "Workgroup"
Global Const $g_esSectionNameLocalRepository = "LocalRepository"
Global Const $g_esKeyNameLocalRepositoryName = "LocalRepositoryName"
Global Const $g_esSectionNameInstallationStatus = "Installation Status"
Global Const $g_esKeyNameZHKUpdaterIsInstalled = "ZHKUpdaterIsInstalled"
Global Const $g_esKeyNameZabbixAgentIsInstalled = "ZabbixAgentIsInstalled"
Global Const $g_esKeyNameZHKHelperIsInstalled = "ZHKHelperInstalled"
Global $g_fZHKLocalRepositoryVersion = Number(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameLocalRepositoryVersion, $g_efDefaultZHKLocalRepositoryVersion))
Global $g_sRemoteRepositoryPath = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameRemoteRepositoryPath, $g_esDefaultRemoteRepositoryPath))
Global $g_sFTPServer = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPServer, $g_esDefaultFTPServer))
Global $g_sFTPUsername = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPUsername, $g_esDefaultFTPUsername))
Global $g_sFTPPassword = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameFTPPassword, $g_esDefaultFTPPassword))
Global $g_iDeployZabbixHelper = Number(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameDeployZabbixHelper, $g_esDefaultDeployZabbixHelper))
Global $g_sWindowsUsername = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameWindowsUser, $g_esKeyNameUsername, $g_esDefaultUsername))
Global $g_sWindowsPassword = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameWindowsUser, $g_esKeyNamePassword, $g_esDefaultPassword))
Global $g_sWorkgroupName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameWorkgroup, $g_esDefaultWorkgroupName))
Global $g_sZabbixAgentFileName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameZabbixAgentFileName, $g_esDefaultZabbixAgentFileName))
Global $g_sZabbixAgentMainConfFileName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameZabbixAgentMainConfFileName, $g_esDefaultZabbixAgentMainConfFileName))
Global $g_sRemoteZHKVersionFileName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameRemoteZHKVersionFile, $g_esDefaultRemoteZHKVersionFile))
Global $g_sX64FolderName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameX64FolderName, $g_esDefaultX64FolderName))
Global $g_sX86FolderName = String(IniRead($g_sLocalZHKUpdaterConfFilePath, $g_esSectionNameConfiguration, $g_esKeyNameX86FolderName, $g_esDefaultX86FolderName))
Global $g_iZHKUpdaterIsInstalledTrigger = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZHKUpdaterIsInstalled, $g_eiDefaultZHKUpdaterIsInstalledTrigger))
Global $g_iZabbixAgentInstalled = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZabbixAgentIsInstalled, $g_eiDefaultZabbixAgentIsInstalledTrigger))
Global $g_iZHKHelperInstalled = Number(IniRead($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZHKHelperIsInstalled, $g_eiDefaultZHKHelperIsInstalledTrigger))
Global $g_sRemoteZHKVersionFilePath = $g_sRemoteRepositoryPath & "/" & $g_sRemoteZHKVersionFileName
Global $g_sX64RemoteRepositoryPath =  $g_sRemoteRepositoryPath & "/" & $g_sX64FolderName
Global $g_sX86RemoteRepositoryPath =  $g_sRemoteRepositoryPath & "/" & $g_sX86FolderName
Global Const $g_ZHK_esZabbixHelperUnitName = "Zabbix Helper"

_myDebug("Запуск модуля Zabbix Helper: " & $g_esZHK_esUnitName & "v" & $g_efZHK_efVersion)
_myDebug("Параметры инициализации :", 1)
_myDebug("Путь к логфайлу: " & $g_ZHKdebug_sLogFilePath)
_myDebug("Путь к локальному файлу конфигурации: " & $g_sLocalZHKUpdaterConfFilePath)
_myDebug("Путь к файлу версий ZHK в репозитории: " & $g_sRemoteZHKVersionFilePath)
_myDebug("Архитектура текущей ОС: " & $g_sOSArch)
_myDebug("Версия локального репозитория: " & $g_fZHKLocalRepositoryVersion)
_myDebug("Маркер установки Zabbix Agent: " & $g_iZabbixAgentInstalled)
_myDebug("Маркер установки Zabbix Helper: " & $g_iZHKHelperInstalled)
_myDebug("Маркер установки Zabbix Helper Updater: " & $g_iZHKUpdaterIsInstalledTrigger)
_myDebug("Права администратора: " & $g_bIsAdmin)
_myDebug("Текущая папка:" & $g_sScriptFullPath)

If _getWorkGroup() = $g_sWorkgroupName Then
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

;~ Exit 

Global $hFTPConn = _FTP_Connect($hFTPOpen, $g_sFTPServer, $g_sFTPUsername, $g_sFTPPassword)
If @error Then
   _myDebug("Не могу подколючиться к FTP")
	Exit
Else
   _myDebug("Подключение к FTP установлено")
EndIf

If Not FileExists("C:/zabbix") Then DirCreate("C:/zabbix")

If $g_iZHKUpdaterIsInstalledTrigger = 0 Then _installZHKUpdater()

If $g_fZHKLocalRepositoryVersion < _getZHKUpdaterRemoteVersion($g_sRemoteZHKVersionFilePath) Then
	_myDebug("Необходимо обновление локального репозитория")

	_getZabbixAgentLastVersion()
	_getZabbixAgentApplyUpdate()
	If $g_iZabbixAgentInstalled = 0 Then _installZabbixAgent()

	_getZHKUpdaterConfLastVersion()
	_getZHKUpdaterConfApplyUpdate()
	If $g_iZHKUpdaterIsInstalledTrigger = 0 Then _installZHKUpdater()


	If $g_iDeployZabbixHelper = 1 Then
		_getZHKHelperLastVersion()
		_getZHKHelperApplyUpdate()
		If $g_iZHKHelperInstalled = 0 Then _installZHKHelper()
	EndIf
	FileCopy($g_sScriptFullPath, "C:/zabbix/Zabbix_Helper_Updater.exe", 1)
Else
	_myDebug("Обновление локального репозитория не требуется")
EndIf

_myDebug("Завершение работы модуля Zabbix Helper: " & $g_esZHK_esUnitName)

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
	Local $sZabbixHelperLocalFilePath = $g_esLocalRepositoryRoot & "\upd_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe"
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
	FileMove($g_esLocalRepositoryRoot & "\" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", $g_esLocalRepositoryRoot & "\bkp_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", 1)
	FileMove($g_esLocalRepositoryRoot & "\upd_" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", $g_esLocalRepositoryRoot & "\" & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & ".exe", 1)
	_myDebug("", -1)
EndFunc

Func _installZHKHelper()
	_myDebug("Устанавливаю Zabbix Helper", 1)
	Local $sUser = $g_sWindowsUsername
	Local $sPassword = $g_sWindowsPassword
	If $g_bInDomain Then
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper" /tr "' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:00 /RL HIGHEST /RU '&$sUser&' /RP '&$sPassword, "", @SW_HIDE)
	Else
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper" /tr "' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:00 /RL HIGHEST /RU SYSTEM', "", @SW_HIDE)
	EndIf
	Sleep(20000)
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Helper Kit - Zabbix Helper" dir=in action=allow program="' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_ZHK_esZabbixHelperUnitName, " ", "_") & '.exe" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZHKHelperIsInstalled, 1)
	_myDebug("", -1)
EndFunc

Func _getZHKUpdaterConfLastVersion()
	_myDebug("Загружаю последнюю конфигурацию Zabbix Helper Updater", 1)
	Local $sZabbixHelperConfRemoteFilePath = $g_sRemoteRepositoryPath & "/" & $g_esZHKUpdaterConfFileName
	_myDebug("Путь к файлу конфигурации Zabbix Helper Updater в удалённом репозитории: " & $sZabbixHelperConfRemoteFilePath)
	Local $sZabbixHelperConfLocalFilePath = $g_esLocalRepositoryRoot & "/upd_" & $g_esZHKUpdaterConfFileName
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
	FileMove($g_esLocalRepositoryRoot & "\" & $g_esZHKUpdaterConfFileName, $g_esLocalRepositoryRoot & "\bkp_" & $g_esZHKUpdaterConfFileName, 1)
	FileMove($g_esLocalRepositoryRoot & "\upd_" & $g_esZHKUpdaterConfFileName, $g_esLocalRepositoryRoot & "\" & $g_esZHKUpdaterConfFileName, 1)
	_myDebug("", -1)
EndFunc

Func _getZabbixAgentLastVersion()
	_myDebug("Загружаю последнюю версию Zabbix Agent", 1)
	Local $sZabbixAgentRemoteFilePath = $g_sCurOSArchRemoteRepositoryPath & "/" & $g_sZabbixAgentFileName
	_myDebug("Путь к файлу Zabbix Agent в удалённом репозитории: " & $sZabbixAgentRemoteFilePath)
	Local $sZabbixAgentLocalFilePath = $g_esLocalRepositoryRoot & "/upd_" & $g_sZabbixAgentFileName
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
	Local $sZabbixAgentMainConfLocalFilePath = $g_esLocalRepositoryRoot & "/upd_" & $g_sZabbixAgentMainConfFileName
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
	FileMove($g_esLocalRepositoryRoot & "\" & $g_sZabbixAgentFileName, $g_esLocalRepositoryRoot & "\bkp_" & $g_sZabbixAgentFileName, 1)
	FileMove($g_esLocalRepositoryRoot & "\upd_" & $g_sZabbixAgentFileName, $g_esLocalRepositoryRoot & "\" & $g_sZabbixAgentFileName, 1)
	FileMove($g_esLocalRepositoryRoot & "\" & $g_sZabbixAgentMainConfFileName, $g_esLocalRepositoryRoot & "\bkp_" & $g_sZabbixAgentMainConfFileName, 1)
	FileMove($g_esLocalRepositoryRoot & "\upd_" & $g_sZabbixAgentMainConfFileName, $g_esLocalRepositoryRoot & "\" & $g_sZabbixAgentMainConfFileName, 1)
	_ServiceNet("Zabbix Agent", "start")
	_myDebug("", -1)
EndFunc

Func _installZabbixAgent()
	_myDebug("Устанавливаю Zabbix Agent", 1)
	_ServiceNet("Zabbix Agent", "stop")
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Helper Kit - Zabbix Agent" dir=in action=allow program="' &$g_esLocalRepositoryRoot& '\' & $g_sZabbixAgentFileName & '" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	Local $var = ShellExecute("c:\zabbix\zabbix_agentd.exe", " -c c:\zabbix\zabbix_agentd.win.conf -i", "")
	Sleep(20000)
	_ServiceNet("Zabbix Agent", "start")
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZabbixAgentIsInstalled, 1)
	_myDebug("", -1)
EndFunc

Func _installZHKUpdater()
	Local $sUser = $g_sWindowsUsername
	Local $sPassword = $g_sWindowsPassword
	_myDebug("Устанавливаю Zabbix helper Updater", 1)
	If $g_bInDomain Then
		_myDebug("Произвожу установку в домене")
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper Updater" /tr "' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_esZHK_esUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:30 /RL HIGHEST /RU '&$sUser&' /RP '&$sPassword, "", @SW_HIDE)
	Else
		_myDebug("Произвожу установку в рабочей группе")
		Local $var = Run(@ComSpec & " /c " & 'schtasks /create /tn "Zabbix Helper Kit - Zabbix Helper Updater" /tr "' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_esZHK_esUnitName, " ", "_") & '.exe" /sc HOURLY /mo 1 /st 00:30 /RL HIGHEST /RU SYSTEM', "", @SW_HIDE)
	EndIf
	Sleep(20000)
	Local $var = Run(@ComSpec & " /c " & 'netsh advfirewall firewall add rule name="Zabbix Helper Kit - Zabbix Helper Updater" dir=in action=allow program="' &$g_esLocalRepositoryRoot& '\' & StringReplace($g_esZHK_esUnitName, " ", "_") & '.exe" enable=yes', "", @SW_HIDE)
	Sleep(20000)
	IniWrite($g_sLocalZHKUpdaterInstallationFilePath, $g_esSectionNameInstallationStatus, $g_esKeyNameZHKUpdaterIsInstalled, 1)
	$g_iZHKUpdaterIsInstalledTrigger = 1
	_myDebug("", -1)
EndFunc

Func _Exit()
	If IsDeclared("hFTPConn") Then _FTP_Close($hFTPConn)
	If IsDeclared("hFTPOpen") Then _FTP_Close($hFTPOpen)
EndFunc