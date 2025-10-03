@echo off
rem Start with clearing the ERRORLEVEL back to 0, in case an error occurred during a previous execution of this batch file
rem See also https://ss64.com/nt/errorlevel.html
(call )

rem The only logical logical operator directly supported by IF is NOT, 
rem so do not combine all conditions in one expression by writing OR, see also https://ss64.com/nt/if.html
rem Do NOT use parentheses around the goto command, see also https://ss64.com/nt/goto.html
if "%~1" == "" goto displayUsageMessage
if "%~2" == "" goto displayUsageMessage

(call Morgana 2>&1) | FIND /I "MorganaXProc-III" >NUL
if %ERRORLEVEL% EQU 1 goto displayMessageMorgana

setlocal
echo Arguments set:
echo ^<file^>                              %~1
echo ^<codeListSubregisterUri^>            %~2
if "%~3" == "" (
	set add_rdf_as_alternate_format=true
) else (
	set add_rdf_as_alternate_format=%~3
)
echo ^<add_rdf_as_alternate_format^>       %add_rdf_as_alternate_format%

rem Check arguments
if not exist "%~1" echo "%~1" does not exist & goto displayUsageMessage

call Morgana -config=local-scripts\morgana-config.xml ^
src\main\xml\xproc\add-publication-details-to-gc.xpl ^
-option:gc-file-path="%~1" ^
-option:code-list-subregister-uri="%~2" ^
-option:add-csv-as-alternate-format=true ^
-option:add-rdf-as-alternate-format=%add_rdf_as_alternate_format%

echo Exit code: %ERRORLEVEL%
exit /B %ERRORLEVEL%
goto:eof

:displayUsageMessage
	echo:
	echo Usage: %~nx0 ^<file^> ^<codeListSubregisterUri^> ^<addRdfAsAlternateFormat^>
	echo:
	echo     file                                  genericode file path (note: this file will be UPDATED by running this script)
	echo     codeListSubregisterUri                first part of the retrieval location URIs, e.g. https://example.org/codelistregister/subregister/
	echo     addRdfAsAlternateFormat               true ^(default^) or false
	echo:
goto:eof

:displayMessageMorgana
	echo Morgana was not found, please install it and try again.
	echo Use scripts\print-configuration.bat to check your configuration.
goto:eof