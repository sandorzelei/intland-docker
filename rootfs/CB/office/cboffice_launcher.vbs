' Copyright by Intland Software, http://www.intland.com
' All rights reserved.
'
' Last modification: 08 October 2015
' 
' You can find the Generated debug log file here: 
' %TEMP%\cboffice_launcher.log
' Example: c:\Users\....\AppData\Local\Temp\cboffice_launcher.log
'
' Do not modify this file!

Dim WshShell
Set WshShell = CreateObject("WScript.Shell")
Const cbVer = "1.03"
Const cbDebugFilePrefix = "cboffice_launcher"

execStdOut(Wscript.Arguments)

Function execStdOut(args)
	sProtocolPrefix = "cboffice://"
    logFileName = GenerateTimeFile(cbDebugFilePrefix)

	For Each url In args
        Debug logFileName, "----------------------------------"
        Debug logFileName, "Starting cbOffice Launcher - " & cbVer
        Debug logFileName, "Original url: " & url
        url = Replace(url, sProtocolPrefix, "")
		url = deleteLastSlash(url)
        Debug logFileName, "Service Url: " & url
		ftype = getFileType(url)
        Debug logFileName, "File type: " & ftype
		ftype = Replace(ftype,"*","")

		if ftype = "" Then
			WScript.Echo "Can not specify the file type for: "+url
			WScript.Quit
		End If
		strDefaultDOCProgram = GetProgramPath(logFileName,ftype)
        Debug logFileName, "Associated Program: " & strDefaultDOCProgram

		If Len(strDefaultDOCProgram) > 0 Then 
            command = "%comspec% /c """+strDefaultDOCProgram+""""+" "+url
            Debug logFileName, "Start associated command: " & command
			WSHShell.Run command, 0, true
		Else 
			WScript.Echo "Can not specify Command for: "+url
			WScript.Quit
		End If
		EXIT For
	Next
End Function

Function deleteLastSlash(str)
	if Right(str,1) = "/" Then
		newlen = Len(str)-1
		str = Left(str,newlen)
	End If
	deleteLastSlash=str
End Function

Function getFileType(str)
	lastDot = InStrRev(str,".")
	if lastDot > 0 And lastDot<Len(str) Then
		getFileType = mid(str, lastDot, Len(str))
	Else
		getFileType = ""
	End If
End Function

Function GetProgramPath(logFileName,ext)
	Dim strProg, strProgPath

	' Get Program Association Handle
	sCommand = "assoc " + ext

	oExec =  TrimCRLF(ExecuteWithTerminalOutput(logFileName, sCommand))
	strProg = ""
	if Len(oExec) > 0 Then 
		strProg = Split(oExec, "=")(1)
	End If

	' Get Path To Program
	oExec =  TrimCRLF(ExecuteWithTerminalOutput(logFileName, "ftype " + strProg))
	strProgPath = ""
	If Len(oExec) > 0 Then 
		strProgPath = Split(oExec, """")(1)
	End IF

	' Return the program path
	GetProgramPath = strProgPath
End Function

Function ExecuteWithTerminalOutput(logFileName,cmd)
	Set fso = CreateObject("Scripting.FileSystemObject")
	tempfile = fso.GetTempName
	'path = fso.GetParentFolderName(wscript.ScriptFullName)
	Const TemporaryFolder = 2
	path = fso.GetSpecialFolder(TemporaryFolder)

	tempfile = path + "\" + tempfile
	command = "%comspec% /c " + cmd + " > " + """"+tempfile+""""
    Debug logFileName, "Command: " & command
	WSHShell.Run command, 0, true
	
	Set myFile = fso.OpenTextFile(tempfile)
	If myFile.AtEndOfStream Then
		ExecuteWithTerminalOutput = ""
	Else
		ExecuteWithTerminalOutput = myFile.ReadAll
	End If	
	myFile.Close
End Function

Function TrimCRLF(str)
	str = Replace(str, vbCr, "")
	str = Replace(str, vbLf, "")
	TrimCRLF = str
End Function

Function GenerateTimeFile(cbDebugFilePrefix)
	strLogFileName = cbDebugFilePrefix & ".log"

	'Delete Temp file if exists
	Set debugFso = CreateObject("Scripting.FileSystemObject")
	debugFile = debugFso.GetSpecialFolder(2) + "\" + strLogFileName
    Set objFile = debugFso.CreateTextFile(debugFile)
    objFile.Close
    Set objFile = nothing
    
    GenerateTimeFile = debugFile
End Function 

Function Debug(filename, str)
	Set debugFso = CreateObject("Scripting.FileSystemObject")
   
    ' OpenTextFile Method needs a Const value
    ' ForAppending = 8 ForReading = 1, ForWriting = 2
    Const ForAppending = 8
    Set objTextFile = debugFso.OpenTextFile _
    (filename, ForAppending, True, True)
    
    objTextFile.WriteLine(Now & " - " & str)
    objTextFile.Close
End Function
