@ECHO off
:Builder
SET WITPATH=wit-v3.00a-r7387-cygwin\bin\wit
SET SZSPATH=szs-v1.54a-r7393-cygwin\bin\wstrt
cls
echo Ver. 1.0
echo /============================================\
echo I  Pasos                                     I
echo I  1. Aplicar parche al iso                  I
echo I  2. Cambiar el ID del juego                I
echo I  3. Cambiar ID de TMD de .iso              I
echo I  4. Cambiar el nombre interno de del juego I
echo I  5. Salir a jugar (Y)                      I
echo I                                            I
echo I  (3. Hara que la Wii cree una              I
echo I      nueva partida para el mod.)           I
echo I                                            I
echo I  Contacto:viktormax3@gmail.com             I
echo I  Agradecimientos a el team de Wiimms       I 
echo I  Por los binarios wit y szs utilizados     I 
echo \============================================/

SET /P Input=Elige una opcion 1, 2, 3, 4 o 5: 
IF %Input% EQU 1 GOTO :Build_Iso
IF %Input% EQU 2 GOTO :Change_GameID
IF %Input% EQU 3 GOTO :Change_TMD
IF %Input% EQU 4 GOTO :Change_Name
IF %Input% EQU 5 exit

GOTO :Builder
exit


:Build_Iso

echo /=============================================\
echo I Comencemos eligiendo la imagen del disco... I
echo \=============================================/
SET /P  isoFile=Por favor ingrese el nombre de su imagen de disco. (p.ej. SMG2.iso, SMG2.wbfs): 
if not defined isoFile GOTO :Build_Iso
if not exist ".\%isoFile%" (
	echo /==========================================================\
	echo I  Imagen de disco no encontrada.                          I
	echo I  Verifique que la imagen se encuentre en esta carpeta    I
	echo I  Verifique que el nombre este correcto                   I
	echo I  Presione cualquier tecla para ingresar un nuevo nombre. I
	echo \==========================================================/
	pause >nul
	GOTO :Build_iso )

:Modded_File

echo /=========================================================\
echo I  Como quiere que se llame la imagen de disco modificada?I
echo \=========================================================/
SET /P moddedFile=Por favor ingrese un nombre. (p.ej. Neo Mario Galaxy.iso, Neo Mario Galaxy.wbfs): 
if not defined moddedFile GOTO :Modded_File
if exist ".\%moddedFile%" (
	echo /====================================\
	echo I       El archivo ya existe!        I
	echo I   Presione cualquier tecla para    I
	echo I      ingresar un nuevo nombre.     I
	echo \====================================/
	pause >nul
	GOTO :Modded_File )


echo /=====================================\
echo I      Imagen de disco encontrada,    I
echo I       Aplicando el mod!             I
echo I      Extrayendo archivos ...        I
echo I      Esto llevara un tiempo.        I
echo \=====================================/
for /f %%i in ('%WITPATH% ID6 "%isoFile%"') do set GAMEID=%%i
SET WORKDIR=.\%GAMEID%-UNPACK
if exist "%WORKDIR%\" (
	rmdir /s /q "%WORKDIR%\" >nul )
%WITPATH% extract -1p "%isoFile%" --DEST "%WORKDIR%" --psel data -ovv
if exist "./gct/%GAMEID%.gct" (
    %SZSPATH% patch "%WORKDIR%/sys/main.dol" --add-sect "gct/%GAMEID%.gct" -ovv
) else (
    echo /===================================\
echo I             ERROR                 I
echo I    %GAMEID%.GCT No encontrado!    I
echo I  Asegurese de que su archivo .gct I
echo I    este en la carpeta 'gct' y     I
echo I   tenga el nombre %GAMEID%.GCT    I
echo \===================================/
pause >nul
GOTO :Builder
)

color 07
echo /======================================\
echo I          Aplicando el mod!           I
echo I   Copiando archivos modificados ...  I
echo I       Esto llevara un tiempo.        I
echo \======================================/

if exist ".\nmg\nmg\ASM" (
	rmdir /s /q ".\nmg\nmg\ASM" >nul )
if exist ".\nmg\nmg\version.info" (
	del ".\nmg\nmg\version.info" >nul )
	xcopy ".\nmg\nmg\*" "%WORKDIR%/files" /E /Y > nul
	xcopy ".\banner\*" "%WORKDIR%/files" /E /Y > nul

echo /=======================================\
echo I          Aplicando el mod!            I
echo I Creando imagen de disco modificada... I
echo I        Esto llevara un tiempo.        I
echo \=======================================/


%WITPATH% copy "%WORKDIR%" --DEST ".\%moddedFile%" -ovv
rd /S /Q "%WORKDIR%"
echo /===========================\
echo I           Listo!          I
echo I     Presione cualquier    I
echo I  tecla para continuar...  I
echo \===========================/
pause >nul
GOTO :Builder


:Change_GameID

if not defined moddedFile (
echo /=============================================\
echo I Comencemos eligiendo la imagen del disco... I
echo \=============================================/
SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
)

if not exist "./%moddedFile%" (
	echo /====================================\
	echo I        El archivo no existe!       I
	echo I   Presione cualquier tecla para    I
	echo I      ingresar un nuevo nombre.     I
	echo \====================================/
	SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
	GOTO :Change_GameID 
) else ( GOTO :New_GameID
)
	

:New_GameID

echo /====================================\
echo I Ahora elige la nueva ID del juego. I
echo \====================================/
SET /P  newGameID=Introduzca la nueva ID del juego (Sugerido (pal) NMGP01 (ntsc) NMGE01 (japan) NMGJ01): 
if not defined newGameID GOTO :New_GameID
for /f %%i in ('%WITPATH% ID6 "%moddedFile%"') do set GAMEID=%%i
wit EDIT --id  %newGameID%  ".\%moddedFile%" >nul
copy ".\txtcodes\%GAMEID%.txt" "%newGameID%.txt"

echo /===========================\
echo I           Listo!          I
echo I     Presione cualquier    I
echo I  tecla para continuar...  I
echo \===========================/
pause >nul
GOTO :Builder



:Change_TMD

if not defined moddedFile (
echo /=============================================\
echo I Comencemos eligiendo la imagen del disco... I
echo \=============================================/
SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
)

if not exist "./%moddedFile%" (
	echo /====================================\
	echo I        El archivo no existe!       I
	echo I   Presione cualquier tecla para    I
	echo I      ingresar un nuevo nombre.     I
	echo \====================================/
	SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
	GOTO :Change_TMD 
) else ( GOTO :New_TMD
)

:New_TMD

echo /=====================================\
echo I Ahora elige la nueva TMD del juego. I
echo \=====================================/
SET /P  newTMD=Escribe un nuevo TMD (Max. 4 caracteres) (Sugerido (pal) NMGP (ntsc) NMGE (japan) NMGJ )
if not defined newTMD GOTO :New_TMD
%WITPATH% EDIT --tt-id  %newTMD%  ".\%moddedFile%" >nul

echo /===========================\
echo I           Listo!          I
echo I     Presione cualquier    I
echo I  tecla para continuar...  I
echo \===========================/
pause >nul
GOTO :Builder


:Change_Name

if not defined moddedFile (
echo /=============================================\
echo I Comencemos eligiendo la imagen del disco... I
echo \=============================================/
SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
)

if not exist "./%moddedFile%" (
	echo /====================================\
	echo I        El archivo no existe!       I
	echo I   Presione cualquier tecla para    I
	echo I      ingresar un nuevo nombre.     I
	echo \====================================/
	SET /P  moddedFile=Por favor ingrese el nombre de su imagen de disco. [p.ej. SMG2.iso, SMG2.wbfs] 
	GOTO :Change_Name 
) else ( GOTO :New_Name
)

:New_Name

echo /==============================\
echo I     Ahora elige el nuevo     I
echo I    nombre interno del juego  I
echo \==============================/
SET /P  newName=Ingrese el nuevo nombre (Max. 63 caracteres): (Sugererido "Neo Mario Galaxy" sin comillas)
if not defined newName GOTO :New_Name
%WITPATH% EDIT --name  "%newName%"  ".\%moddedFile%"

echo /===========================\
echo I           Listo!          I
echo I     Presione cualquier    I
echo I  tecla para continuar...  I
echo \===========================/
pause >nul
GOTO :Builder