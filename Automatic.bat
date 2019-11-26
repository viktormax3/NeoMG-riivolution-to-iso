@ECHO off
SET WITPATH=wit-v3.00a-r7387-cygwin\bin\wit
SET SZSPATH=szs-v1.54a-r7393-cygwin\bin\wstrt
cls
echo Ver. 1.0
echo /==============================================\
echo I  Pasos                                       I
echo I  1. Apply patch to ISO                       I
echo I  2. Chnage the ID of the game                I
echo I  3. Change the TMD of the .iso image         I
echo I  4. Change the internal game name of the ISO I
echo I  5. End of patcher                           I
echo I                                              I
echo I  (3. Will make new savegame for the game     I
echo I                                              I
echo I  Contacto:viktormax3@gmail.com               I
echo I  Thanks to Wiimm for his SZS and ISO Tools   I 
echo \==============================================/
GOTO :Build_Iso

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

if exist ".\nmg\SystemData\" ( 
	SET ModDir=.\nmg
)
if exist ".\nmg\nmg\SystemData\" ( 
	SET ModDir=.\nmg\nmg
)
if exist ".\nmg\nmg\nmg\SystemData\" ( 
	SET ModDir=.\nmg\nmg\nmg
)
if not defined ModDir (
	echo /==============================================\
	echo I        Carpeta del mod no encontrada:        I
	echo I *Verifique que se encuentre en esta carpeta  I
	echo I *Verifique que el nombre sea nmg             I
	echo I *Verifique que este descomprimida            I
	echo I    Presione cualquier tecla para salir.      I
	echo \==============================================/
	pause >nul
	exit
)

	echo /==============================================\
	echo I        Carpeta del mod  encontrada           I
	echo \==============================================/	
	
SET moddedFile=Neo Mario Galaxy.iso
if exist ".\%moddedFile%" (
	echo /====================================\
	echo I       El archivo ya existe!        I
	echo I   Presione cualquier tecla para    I
	echo I              salir                 I
	echo \====================================/
	pause >nul
	exit )


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
exit
)

echo /======================================\
echo I          Aplicando el mod!           I
echo I   Copiando archivos modificados ...  I
echo I       Esto llevara un tiempo.        I
echo \======================================/

rmdir /s /q "%ModDir%\ASM"
del /s /q "%ModDir%\version.info"
xcopy "%ModDir%\*" "%WORKDIR%/files" /E /Y > nul
xcopy ".\banner\*" "%WORKDIR%/files" /E /Y > nul

echo /=======================================\
echo I          Aplicando el mod!            I
echo I Creando imagen de disco modificada... I
echo I        Esto llevara un tiempo.        I
echo \=======================================/

%WITPATH% copy "%WORKDIR%" --DEST ".\%moddedFile%" -ovv
rd /S /Q "%WORKDIR%"

if %GAMEID% EQU SB4E01 set REG=USA
if %GAMEID% EQU SB4E01 set TMD=NMGE
if %GAMEID% EQU SB4E01 set ID=NMGE01
if %GAMEID% EQU SB4J01 set REG=JAP
if %GAMEID% EQU SB4J01 set TMD=NMGJ
if %GAMEID% EQU SB4J01 set ID=NMGJ01
if %GAMEID% EQU SB4P01 set REG=PAL
if %GAMEID% EQU SB4P01 set TMD=NMGP
if %GAMEID% EQU SB4P01 set ID=NMGP01

echo /==========================================\
echo I        Imagen de disco Region %REG%        I
echo I  Se cambiara el ID  de %GAMEID% a %ID%   I
echo \==========================================/
%WITPATH% EDIT --id  %ID%  ".\%moddedFile%" >nul
copy ".\txtcodes\%GAMEID%.txt" ".\%ID%.txt"

echo /=======================================\
echo I      Imagen de disco Region  %REG%      I
echo I    Se cambiara el ID el TMD a %TMD%    I
echo \=======================================/
%WITPATH% EDIT --tt-id  %TMD%  ".\%moddedFile%" >nul

echo /=====================================\
echo I       Imagen de disco Region %REG%    I
echo I    Se cambiara el nombre interno a  I
echo I           Neo Mario Galaxy          I
echo \=====================================/

%WITPATH% EDIT --name  "Neo Mario Galaxy"  ".\%moddedFile%"
echo /==========================\
echo I          Listo!          I
echo I    Presione cualquier    I
echo I     tecla para salir...  I
echo \==========================/
pause >nul
exit 
