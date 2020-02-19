; #INDEX# =======================================================================================================================
; Title .........: Zabbix Helper Kit - Zabbix Helper
; Version .......: 0.1
; AutoIt Version : 3.3.14.5
; Description ...: Программа для обновления Zabbix Helper Kit и Zabbix Agent + файл конфигурации заббикс агента
; Author(s) .....: Belfigor
; www ...........: adminguide.ru
; Dependencies ..: _myDebug.au3
; ===============================================================================================================================

#include <myDebug.au3>
#include <FTPEx.au3>
#include <Array.au3>
;~ Opt("MustDeclareVars", 1)
OnAutoItExitRegister ("_Exit")

Global Const $g_esLocalRepositoryRoot = "C:\zabbix"
Global Const $g_esZHKModuleConfFileName = "ZHK_Module.cfg"
Global Const $g_esZHKModuleInstallationFileName = "ZHK_Installation_Status.cfg"
Global $g_sLocalZHKModuleConfFilePath = $g_esLocalRepositoryRoot & "\" & $g_esZHKModuleConfFileName
Global $g_sLocalZHKModuleInstallationFilePath = $g_esLocalRepositoryRoot & "\" & $g_esZHKModuleInstallationFileName
Global Const $g_esZHK_esUnitName = "Zabbix Helper Module"
Global $g_sLogFileName = StringLower(StringReplace($g_esZHK_esUnitName, " ", "_")) & ".log"
Global Const $g_efZHK_efVersion =  0.3
Global $g_sOSArch = @OSArch
Global $g_bIsAdmin = IsAdmin()
Global $g_sScriptFullPath = @ScriptFullPath
Global Const $bTimeStamp = True
Global $g_ZHKdebug_sLogFilePath = $g_esLocalRepositoryRoot & "\" & $g_sLogFileName
Global Enum $placeholder, $eLogWindow, $eConsoleWrite, $eMsgBox, $eFileWrite, $NotepadWindow
Global Const $g_esDebug = True
_DebugSetup($g_esZHK_esUnitName, $g_esDebug, $eConsoleWrite, $g_ZHKdebug_sLogFilePath, $bTimeStamp)

Global $g_sRemoteZHKVersionFileName = "zhk_zh_version"
Global $g_sRemoteRepositoryPath = "/zabbix";https://www.youtube.com/watch?v=34CZjsEI1yU
Global $g_sRemoteZHKVersionFilePath = $g_sRemoteRepositoryPath & "/" & $g_sRemoteZHKVersionFileName
Global $g_sFTPServer = "127.0.0.1"
Global $g_sFTPUsername = "zabbix_helper"
Global $g_sFTPPassword = "gVVqW4"
Global $g_fZHKLocalRepositoryVersion = 0.5


;====== Ниже вот этой вот хуйни, не должно быть ниодного захардкоженного значения


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

;~ _getZHKModuleUpdate($g_sRemoteRepositoryPath, $g_esLocalRepositoryRoot)
;~ _ArrayDisplay(_getUpdateHelpers())
;~ _applyZHKModuleUpdate()

;~  Exit 

If _getZHKModuleLocalVersion() < _getZHKModuleRemoteVersion($g_sRemoteZHKVersionFilePath) Then 
	_myDebug("Локальная версия устарела, необходимо обновление")
	_getZHKModuleUpdate($g_sRemoteRepositoryPath, $g_esLocalRepositoryRoot)
	If @error Then 
		_myDebug("temp-ошибка при загрузке обновления")
		Exit
	EndIf
	
	_applyZHKModuleUpdate()
Else 
	_myDebug("Обновление внешних расширений не требуется")
EndIf

Func _applyZHKModuleUpdate()
	_ServiceNet("Zabbix Agent",  "stop")
	Local $asHelpers = _getUpdateHelpersNames()
	If Not @error Then _killHelpers($asHelpers)
	_bkpZHKModuleFiles($g_esLocalRepositoryRoot)
	Local $sLocalSourcePath = $g_esLocalRepositoryRoot & "\update"
	Local $sLocalDestPath = $g_esLocalRepositoryRoot & "\zabbix_helper"
	Local $var = DirRemove($sLocalDestPath, 1)
	If Not $var Then _myDebug("Не удалось удалить папку с хэлперами")
	$var = DirMove($sLocalSourcePath, $sLocalDestPath, 1)
	If Not $var Then 
		_myDebug("Не удалось применить обновление")
		Return SetError(1, 1, False)
	EndIf
	_myDebug("Обновление установлено")
	_ServiceNet("Zabbix Agent",  "start")
	Return True
EndFunc

Func _killHelpers($asLocalHelpers)
	For $i = 0 to UBound($asLocalHelpers)-1 Step 1
		_myDebug("Проверяю процесс " & $asLocalHelpers[$i])
		If ProcessExists($asLocalHelpers[$i]) Then 
			_myDebug("Процесс " & $asLocalHelpers[$i] & " запущен")
			ProcessClose($asLocalHelpers[$i])
			If @error Then 
				_myDebug("Ошибка при закрытии процесса" & $asLocalHelpers[$i] & ": " & @error)
			Else 
				_myDebug("Процесс " & $asLocalHelpers[$i] & " убит")
			EndIf
		EndIf
	Next
EndFunc

Func _getUpdateHelpersNames()
	Local $asExceptions[2] = ["Zabbix_Helper.exe", "Zabbix_Helper_Updater.exe"]
	Local $hSearch = FileFindFirstFile($g_esLocalRepositoryRoot& "\update\*.exe")
	If $hSearch = -1 Then
		_myDebug("В папке update не обнаружены exe файлы")
		Return SetError(1, 1, False)
	EndIf
	Local $asHelpers[0]
;~ 	MsgBox(0, 0, UBound($asHelpers))
;~ 	Exit 
	While 1
		$sFileName = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		_ArraySearch($asExceptions, $sFileName)
		If Not @error Then 
			_myDebug("Пропускаю файл " & $sFileName)
		Else 
			_ArrayAdd($asHelpers, $sFileName)
		EndIf		
	Wend
	If UBound($asHelpers) = 0 Then 
		_myDebug("В обновлении не обнаружены хэлперы")
		Return SetError(2, 2, False)
	EndIf
	_myDebug("В обновлении обнаружены хелперы")
	Return $asHelpers
EndFunc 

Func _bkpZHKModuleFiles($sLocalPath)
	Local $sLocalSourcePath = $sLocalPath & "\zabbix_helper"
	Local $sLocalDestPath = $sLocalPath & "\zabbix_helper_bkp"
	DirRemove($sLocalDestPath)
	Local $var = DirMove($sLocalSourcePath, $sLocalDestPath, 1)
	If Not $var Then 
		_myDebug("Не удалось создать резервную копию файлов")
		Return SetError(1, 1, False)
	EndIf
	_myDebug("Резервная копия создана")
	Return True
EndFunc 

Func _getZHKModuleUpdate($sRemotePath, $sLocalPath, $sFile = Null)
	$sRemotePath =  $sRemotePath & "/update/"
	$sLocalPath =  $sRemotePath & "\"
	_myDebug("Скачиваю обновление", 1)
	Local $var = DirCreate($sLocalPath)
	If $var Then
		_myDebug("Ошибка при создании директории update")
	Else
		_myDebug("Директория update создана")
	EndIf
	
	If $sFile Then 
		Local $GetFile=_FTP_FileGet($hFTPConn, $sRemotePath&$sFile, $sLocalPath&"\"&$sFile)
		If @error Then 
			_myDebug("Не удалось загрузить файл из " &$sRemotePath&$sFile&" в " & $sLocalPath&"\"&$sFile)
			Return(SetError(1, 1, False))
		EndIf
		Return True
	EndIf
	Local $h_Handle
	Local $aFile = _FTP_FindFileFirst($hFTPConn, $sRemotePath, $h_Handle)
	If @error Then
		_myDebug("В папке "&$sRemotePath&" не найдены файлы")
		Return(SetError(2, 2, False))
	EndIf
	
	Local $GetFile=_FTP_FileGet($hFTPConn, $sRemotePath&$aFile[10], $sLocalPath&$aFile[10])
   _myDebug("Качаю файл "&$aFile[10])
   
	While 1
		Local $hNextFile = _FTP_FindFileNext($h_Handle)
		If Not @error Then
			$GetFile=_FTP_FileGet($hFTPConn, $sRemotePath&$hNextFile[10], $sLocalPath&$hNextFile[10])
			_myDebug("Качаю файл "&$hNextFile[10])
		Else
			ExitLoop
		EndIf
	Wend
	_myDebug("Загрузка обновлений завершена")
   Local $iFindClose = _FTP_FindFileClose($h_Handle)
   Return True 
EndFunc

Func _getZHKModuleLocalVersion()
	Return $g_fZHKLocalRepositoryVersion
EndFunc

Func _getZHKModuleRemoteVersion($sPath)
	_myDebug("Проверяю версию ZHK Module в удалённом репозитории", 1)
	_myDebug("Путь к файлу версии: " & $sPath)
	Local $hFTPFile = _FTP_FileOpen ($hFTPConn, $sPath)
	If @error Then
		_myDebug("Ошибка при открытии файла на фтп: " & @error)
		Return SetError(1, 1, False)
	EndIf
	_myDebug("Файл обнаружен")
	
	Local $bData = _FTP_FileRead($hFTPFile, 10)
	If @error Then 
		_myDebug("Не могу прочитать файл: " & @error)
	EndIf
	
	Local $fRemoteVersion = BinaryToString($bData)
	If @error Then
		_myDebug("Ошибка при чтении файла с фтп: " & @error)
		Return SetError(2, 2, False)
	EndIf
	
	_myDebug("Версия ZHK Module в репозитории:"&$fRemoteVersion)
	If @error Then Return SetError(3,3,False)
	_FTP_FileClose ($hFTPFile)
	_myDebug("", -1)
	Return Number(BinaryToString($fRemoteVersion))
EndFunc

Func _Exit()
	If IsDeclared("hFTPConn") Then _FTP_Close($hFTPConn)
	If IsDeclared("hFTPOpen") Then _FTP_Close($hFTPOpen)
	Exit
EndFunc

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