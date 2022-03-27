
#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.10.2
	Author:         Mike Kovacic

	Script Function:
	Prevents unauthorized use of any application this UDF is used in, and notifies whoever you specify of any failures.
	This is meant for an Active Directory enviornment, and should be added to your Includes folder. simply #include it when you need it. Make sure you customize the email, SMTP server and anything AD group name oyu want to use for your secure group.

#ce ----------------------------------------------------------------------------

If 1 = 2 Then FileWrite($h_Open, Binary($v_executable)) ; <~~ Confuse decompiler - helps prevent decompiling of script
#include <Date.au3>
#include <Inet.au3>
#include <AD.au3>
Global $Verbose_Output = 1
Global $Email_that_gets_Notified = "Me@gmail.com" ;<-- change this to your email obviously

;_ad_open($sad_useridparam, $sad_passwordparam, $sad_dnsdomainparam, $sad_hostserverparam, $sad_configurationparam)
_ad_open()


If _AD_IsMemberOf("MyCompany_Users") Then ; <-- Make this an AD group that everyone is a member of in your AD enviornment.

	If $Verbose_Output = 1 Then MsgBox(64, "SECURE", "ACCESS GRANTED.")

	; this means all is well and this UDF will quit silently.


Else

	; this means they are not a member of the group and its time to rat them out!


	Local $s_SmtpServer = "smtprelay.MyCompany.com"
	$sResult = "mkovacic@MyCompany.com"
	$sResult2 = "Mike"
	$s_FromName = _AD_GetObjectAttribute(@UserName, "displayName")
	$s_FromAddress = _AD_GetObjectAttribute(@UserName, "mail")
	$s_Subject = "## UNAUTHORIZED APPLICATION USAGE ATTEMPT ALERT ## - Generated from " & @ScriptName
	Local $as_Body[10]
	$as_Body[0] = "## UNAUTHORIZED APPLICATION USAGE ATTEMPT ALERT ##" & @CRLF & @CRLF
	$as_Body[1] = "This report has been generated because someone has tried to start a secure application without being a member of the required group." & @CRLF
	$as_Body[2] = "Name: " & _AD_GetObjectAttribute(@UserName, "displayName") & @CRLF
	$as_Body[3] = "IP: " & @IPAddress1 & @CRLF
	$as_Body[4] = "Computer: " & @ComputerName & @CRLF
	$as_Body[5] = "Time/Date of attempt: " & _DateTimeFormat(_NowCalc(), 1) & " " & _DateTimeFormat(_NowCalc(), 3) & @CRLF
	$as_Body[6] = "Local path to application for user: " & @AutoItExe & @CRLF
	If StringLeft(@AutoItExe, 2) = "C:" Then
		$side = StringSplit(@AutoItExe, ":")
		$UNC = '"\\' & @ComputerName & '\C$' & $side[2] & '"'
		$otherside = StringSplit(@ScriptDir, ":")
		$UNCL = '"\\' & @ComputerName & '\C$' & $otherside[2] & '"'
	Else
		$UNC = @AutoItExe
		$UNCL = @ScriptDir
	EndIf
	$as_Body[7] = "UNC Path of EXE: " & $UNC & @CRLF
	$as_Body[8] = "UNC Path Directory: " & $UNCL & @CRLF & @CRLF
	$as_Body[9] = "The user who attempted to run the application was refused access." & @CRLF & "This auto-generated message was sent because the user mentioned above is not a member of the secure group. "

	;Msgbox(0,"",$as_Body[8])
	

	If $Verbose_Output = 1 Then MsgBox(16, "SECURE", "ACCESS DENIED.")


	_INetSmtpMail($s_SmtpServer, $s_FromName, $s_FromAddress, $Email_that_gets_Notified, $s_Subject, $as_Body, @ComputerName, -1)

	_ad_Close()
	Sleep(2000)
	MsgBox(16, "Access Denied", "You must be a member of the secure group to use this tool.")
	Exit
EndIf
