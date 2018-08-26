;Geometry Dash Downloader 1.1
;By Dan3436

#NoEnv
#SingleInstance Force
#NoTrayIcon

Gui -MaximizeBox
Gui Color, White
Gui Add, Text, x19 y14 w215 h15, Select a language/Selecciona un lenguaje:
Gui Add, Text, x0 y84 w255 h42 -Background
Gui Add, Button, gLang x78 y92 w75 h23 Default, OK
Gui Add, Button, gCancel x167 y92 w75 h23, Cancel
Gui Add, DropDownList, vLang x67 y46 w120 AltSubmit, English||Español
Gui Show, w255 h125, GD Downloader
Return

Lang:
Gui Submit
Gui Destroy
;Lang 1: English, Lang 2: Español 
T1:="Enter the data to download the audio",T2="Audio name",T3="Data",T4="Download",T5="Help",T6="Normal path||Alternate path|Other...",T7="Save path",T8="Audio save paths in Geometry Dash`n`nNormal path: C:\Users\" . A_UserName . "\AppData\Local\GeometryDash\`nAlternate path: Geometry Dash folder\Resources\`nOther: To specify.",T9="Complete the data",T10="No support for ID's minor than 469775`nThe known name pattern can't be used.",T11="Select the Geometry Dash folder",T12="You didn't selected a folder or it isn't a valid folder",T13="""Resources"" folder, the alternate save folder, wasn't found.",T15="The audio wasn't found.`nBe sure to write the name and ID correctly.",T16="The server name could not be resolved. Check your Internet connection.",T17="Audio downloaded successfully.",T18="Wait...",T19="Dowloading... (",T20="Downloading ",T21=" MB of "
if Lang = 2
T1:="Ingresa los datos para descargar el audio",T2="Nombre del audio",T3="Datos",T4="Descargar",T5="Ayuda",T6="Ruta normal||Ruta alterna|Otro...",T7="Ruta de guardado",T8="Rutas de guardado del audio en Geometry Dash`n`nRuta normal: C:\Users\" . A_UserName . "\AppData\Local\GeometryDash\`nRuta alterna: Carpeta de Geometry Dash\Resources\`nOtro: A elegir.",T9="Completa los datos.",T10="Sin soporte a ID's menores a 469775.`nNo se puede usar el patrón de nombre conocido.", T11="Selecciona la carpeta de Geometry Dash",T12="No seleccionaste una carpeta o no es una carpeta válida.",T13="No se encontró la carpeta ""Resources"", la carpeta alterna de guardado.",T15="No se encontró el audio.`nAsegúrate de escribir correctamente el nombre y la ID.",T16="No se pudo resolver el nombre del servidor.`nComprueba tu conexión a Internet.",T17="Audio descargado exitosamente.",T18="Espera...",T19="Descargando... (",T20="Descargando ",T21=" MB de "

Gui -MaximizeBox
Gui Color, White
Gui Add, Edit, vID x39 y82 w62 h21 Number
Gui Add, Text, x63 y64 w12 h14, ID
Gui Add, Text, x42 y10 w196 h16, % T1
Gui Add, Text, x147 y64 w86 h15, % T2
Gui Add, Edit, vName x140 y82 w102 h21
Gui Add, GroupBox, x21 y43 w238 h74, % T3
Gui Add, Text, x0 y180 w280 h41 -Background
Gui Add, Button, gDownload x97 y189 w80 h23 Default, % T4
Gui Add, Button, gHelp x189 y189 w80 h23, % T5
Gui Add, DropDownList, vSP x80 y145 w120 AltSubmit, % T6
Gui Add, Text, x82 y128 w86 h14, % T7
Gui Show, w280 h220, GD Downloader
Return

Help:
Gui +OwnDialogs
MsgBox 64, % T5, % T8
Return

Download:
Gui, Submit, NoHide
Gui +OwnDialogs

if (!ID or !Name){ ;Ensure that both ID and Name isn't blank.
	MsgBox 48, Error, % T9
	Return
}

if (ID < 469775){ ;First ID with the known name pattern.
	MsgBox 48, Error, % T10
	Return
}

Path := "C:\Users\" . A_UserName . "\AppData\Local\GeometryDash" ;Normal save path.
if (SP > 1){ ;Alternate save path or other.
	if (SP = 3){
		if Lang = 1                                ;If user selected other path, replace T11 var
			T11 := "Select the save path"         ;so the prompt in FileSelectFolder will be not ambiguous.
		T11 := "Selecciona la carpeta de guardado"
	}
	FileSelectFolder Path,,, % T11
	if !(Path){
		MsgBox 48, Error, % T12, 1.5
		Return
	}
	if (SP = 2){
		if !FileExist(Path . "\Resources"){ ;Check if Resources folder doesn't exist.
			MsgBox 48, Error, % T13
			Return
		}
		Path .= "\Resources"
	}
}
Path .= "\" . ID . ".mp3" ;Finally, add the ID and audio extension in any save path case.

if FileExist(Path){ ;If the audio file exists, ask if overwrite.
	if Lang = 1 ;It's necessary put this variable here because of the ID var beign recently stored.
		T14 := "There's already an audio named """ . ID . ".mp3"". Overwrite?"
	T14 := "Ya existe un audio denominado """ . ID . ".mp3"". ¿Sobreescribir?"
	MsgBox 308, GD Downloader, % T14
	IfMsgBox No, Return
}

For Key, Value in {" ": "-", "&": "amp", "<": "lt", ">": "gt", """": "quot"}
Name := StrReplace(Name, Key, Value)                 ;Apply only the for-loop here, otherwise the RegExReplace
Name := SubStr(RegExReplace(Name, "[^\w-_]"), 1, 26) ;will delete the characters to filter before getting replaced.

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
	
	Operations to change the last 3 numbers of the ID to 0:
	
	SubStr(ID, 1, -3) * 1000 - Delete the last 3 numbers and multiply by 1000.
	ID - Mod(ID, 1000)       - Substract the ID with the modulo of ID/1000.
	ID - SubStr(ID, -2)      - Substract the ID with it's last 3 numbers.
*/

try DownloadFile("http://audio.ngfiles.com/" . ID - Mod(ID, 1000) . "/" . ID . "_" . Name . ".mp3")
catch e { ;Error
	if InStr(e.Message, "0x80072F76")
		MsgBox 16, Error, % T15
	else if InStr(e.Message, "0x80072EE7")
		MsgBox 16, Error, % T16
	else MsgBox 16, Error, % e.Message
	FileDelete % Path
	ExitApp
}
MsgBox 64, GD Downloader, % T17
ExitApp

DownloadFile(Url){ ;Based on Bruttosozialprodukt's function - https://autohotkey.com/boards/viewtopic.php?f=6&t=1674
	global ;Necessary
	Req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Req.Open("HEAD", Url)
	Req.Send()
	FinalSize := Req.GetResponseHeader("Content-Length")
	Progress, MH80,, % T18, % Url
	SetTimer, ProgressBar, 100
	UrlDownloadToFile, % Url, % Path
	Progress, Off
	SetTimer, ProgressBar, Off
	Return
	
	ProgressBar:
	CurrentSize := FileOpen(Path, "r").Length
	CurrentSizeTick := A_TickCount
	Speed := Round(((CurrentSize-LastSize)/1024)/((CurrentSizeTick-LastSizeTick)/1000))
	LastSizeTick := CurrentSizeTick
	LastSize := FileOpen(Path, "r").Length
	PercentDone := Round(CurrentSize/FinalSize*100)
	Progress, % PercentDone, % PercentDone . "%", %  T19 Speed . " KB/s)", % T20 ID . ".mp3 (" . Round(CurrentSize/1048576, 2) T21 Round(FinalSize/1048576, 2) . " MB)"
	Return
}

Cancel:
GuiEscape:
GuiClose:
ExitApp
