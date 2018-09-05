;Geometry Dash Downloader 1.1.1
;By Dan3436

#NoEnv
#SingleInstance Force
#NoTrayIcon

Path := "C:\Users\" . A_UserName . "\AppData\Local\GeometryDash"
Title := "GD Downloader"

Gui -MaximizeBox
Gui Color, White
Gui Add, Text, x19 y14 w215 h15, Select a language/Selecciona un lenguaje:
Gui Add, Text, x0 y84 w255 h42 -Background
Gui Add, Button, gMain x78 y92 w75 h23 Default, OK
Gui Add, Button, gCancel x167 y92 w75 h23, Cancel
Gui Add, DropDownList, vL x67 y46 w120 AltSubmit, English||Español
Gui Show, w255 h125, % Title
Return

Main:
Gui Submit
Gui Destroy
Gui -MaximizeBox
Gui Color, White
Gui Add, Edit, vID x39 y82 w62 h21 Number
Gui Add, Text, x63 y64 w12 h14, ID
Gui Add, Text, x42 y10 w196 h16, % L=1?"Enter the data to download the audio":"Ingresa los datos para descargar el audio"
Gui Add, Text, x140 y64 w100 h15 Center, % L=1?"Audio name":"Nombre del audio"
Gui Add, Edit, vName x140 y82 w102 h21
Gui Add, GroupBox, x21 y43 w238 h74, % L=1?"Data":"Datos"
Gui Add, Text, x0 y180 w280 h41 -Background
Gui Add, Button, gDownload x97 y189 w80 h23 Default, % L=1?"Download":"Descargar"
Gui Add, Button, gHelp x189 y189 w80 h23, % L=1?"Help":"Ayuda"
Gui Add, DropDownList, vSP x80 y145 w120 AltSubmit, % L=1?"Normal path||Alternate path|Other...":"Ruta normal||Ruta alterna|Otro..."
Gui Add, Text, x82 y128 w86 h14, % L=1?"Save path":"Ruta de guardado"
Gui Show, w280 h220, % Title
Return

Help:
Gui +OwnDialogs
MsgBox 64, % L=1?"Help":"Ayuda", % L=1
?"You can select one of the three audio save paths:`n`nNormal path: " . Path . "`nAlternate path: Geometry Dash folder\Resources`nOther: To specify."
:"Puedes elegir una de las tres rutas de guardado:`n`nRuta normal: " . Path . "`nRuta alterna: Carpeta de Geometry Dash\Resources`nOtro: A especificar."
Return

Download:
Gui Submit, NoHide
Gui +OwnDialogs

if !ID or !Name ;Ensure that both ID and Name isn't blank.
	Return

if (ID < 469775){ ;First ID with the known name pattern.
	MsgBox 48, % Title, % L=1?"No support for ID's minor than 469775`nThe known name pattern can't be used.":"Sin soporte a ID's menores a 469775.`nNo se puede usar el patrón de nombre conocido."
	Return
}

if (SP <> 1){ ;Alternate save path or other.
	FileSelectFolder Path,,, % SP=2?(L=1?"Select the Geometry Dash folder":"Selecciona la carpeta de Geometry Dash"):(L=1?"Select the save folder":"Selecciona la carpeta de guardado")
	if !Path {
		MsgBox 48, % Title, % L=1?"You didn't selected a folder or it isn't a valid folder":"No seleccionaste una carpeta o no es una carpeta válida.", 1.5
		Return
	}
	if (SP = 2){
		if !FileExist(Path . "\Resources"){ ;Check if Resources folder doesn't exist.
			MsgBox 48, % Title, % L=1?"""Resources"" folder, the alternate save folder, wasn't found.":"No se encontró la carpeta ""Resources"", la carpeta alterna de guardado."
			Return
		}
		Path .= "\Resources"
	}
}
Path .= "\" . ID . ".mp3" ;Finally, add the ID and audio extension in any save path case.

if FileExist(Path){ ;If the audio file exists, ask if overwrite.
	MsgBox 308, % Title, % L=1?"There's already an audio named """ . ID . ".mp3"". Overwrite?":"Ya existe un audio denominado """ . ID . ".mp3"". ¿Sobreescribir?"
	IfMsgBox No
	{
		Path := "C:\Users\" . A_UserName . "\AppData\Local\GeometryDash" ;Reset the save path
		Return
	}
}

For Key, Value in {" ": "-", "&": "amp", "<": "lt", ">": "gt", """": "quot"}
Name := StrReplace(Name, Key, Value) ;Apply the for-loop only here, otherwise the RegExReplace will delete the characters to filter before getting replaced.
Name := SubStr(RegExReplace(Name, "[^\w-_]"), 1, 26)

/*
	Filter:
	
	(Space) = -
		 & = amp
		 < = lt
		 > = gt
		 " = quot
	(Other) = (Delete)
	
	Keep "-" and "_"
	
	Characters limit = 26
	
	----------------------------------
	
	Operations to replace the last 3 numbers of the ID with 0:
	
	SubStr(ID, 1, -3) * 1000 - Delete the last 3 numbers and multiply by 1000.
	ID - Mod(ID, 1000)       - Substract the ID with the modulo of ID/1000.
	ID - SubStr(ID, -2)      - Substract the ID with it's last 3 numbers. The most exact of the three operations.
*/

Gui Destroy
try DownloadFile("http://audio.ngfiles.com/" . ID - SubStr(ID, -2) . "/" . ID . "_" . Name . ".mp3")
catch e
{
	MsgBox 16, Error, % (e=404
	?(L=1?"The audio wasn't found.`nBe sure to write the name and ID correctly.":"No se encontró el audio.`nAsegúrate de escribir correctamente el nombre y la ID.")
	:((InStr(e.Message, "0x80072EE7")?(L=1?"The server name could not be resolved. Check your Internet connection.":"No se pudo resolver el nombre del servidor.`nComprueba tu conexión a Internet."):e.Message)))
	FileDelete % Path
	ExitApp
}
MsgBox 64, % Title, % L=1?"Audio downloaded successfully.":"Audio descargado exitosamente."
ExitApp

DownloadFile(Url){ ;Based on Bruttosozialprodukt's function - https://autohotkey.com/boards/viewtopic.php?f=6&t=1674
	global Path, ID
	Req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Req.Open("HEAD", Url)
	Req.Send()
	if Req.Status = 404 ;The download might appear to succeed but it's just an error page. If Status is 404 (Not found), throw the error.
		Throw 404
	FinalSize := Req.GetResponseHeader("Content-Length")
	Progress AMH80,, % L=1?"Wait...":"Espera...", % Url
	File := FileOpen(Path, "rw")
	SetTimer ProgressBar, 100
	UrlDownloadToFile % Url, % Path
	Progress Off
	SetTimer ProgressBar, Off
	File.Close()
	Return
	
	ProgressBar:
	CurrentSize := File.Length
	CurrentSizeTick := A_TickCount
	Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000), 1)
/*
	;Get remaining time:
	TimeRemain := Round((FinalSize-CurrentSize)/(Speed*1024))
	Time := 19990101
	Time += %TimeRemain%, Seconds
	FormatTime mmss, %Time%, mm:ss
	TimeRemain := LTrim(TimeRemain//3600 ":" mmss, "0:")
*/
	LastSizeTick := CurrentSizeTick
	LastSize := CurrentSize
	PercentDone := Round(CurrentSize/FinalSize*100)
	Progress % PercentDone, % PercentDone . "%", % (L=1?"Downloading (":"Descargando (") . Speed . " KB/s)", % (L=1?"Downloading ":"Descargando ") . ID . ".mp3 (" . Round(CurrentSize/1048576, 2) . " MB / " . Round(FinalSize/1048576, 2) . " MB)"
	Return
}

Cancel:
GuiEscape:
GuiClose:
ExitApp
