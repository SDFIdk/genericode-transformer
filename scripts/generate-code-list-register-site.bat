@echo off
rem Start with clearing the ERRORLEVEL back to 0, in case an error occurred during a previous execution of this batch file
rem See also https://ss64.com/nt/errorlevel.html
(call )

rem The only logical logical operator directly supported by IF is NOT, 
rem so do not combine all conditions in one expression by writing OR, see also https://ss64.com/nt/if.html
rem Do NOT use parentheses around the goto command, see also https://ss64.com/nt/goto.html
if "%~1" == "" goto displayUsageMessage
if "%~2" == "" goto displayUsageMessage
if "%~3" == "" goto displayUsageMessage
)


rem Check availability of external commands, see also https://www.robvanderwoude.com/autodownload.php
rem Use newer syntax for checking errorlevel, see also https://ss64.com/nt/if.html
call asciidoctorj -h >NUL 2>&1
if %ERRORLEVEL% NEQ 0 goto displayMessageAsciidoctorJ

(call Morgana 2>&1) | FIND /I "MorganaXProc-III" >NUL
if %ERRORLEVEL% EQU 1 goto displayMessageMorgana

setlocal
echo:
echo Arguments set:
echo   ^<directory^>                               %~1
echo   ^<code-list-register-uri^>                  %~2
echo   ^<report^>                                  %~3
if "%~4" == "" (
	set overwrite_existing_alternative_formats=false
) else (
	set overwrite_existing_alternative_formats=%~4
)
echo   ^<overwrite-existing-alternative-formats^>  %overwrite_existing_alternative_formats%

if "%~5" == "" (
	set debug_pipeline=false
) else (
	set debug_pipeline=%~5
)
echo   ^<debug^>                                   %debug_pipeline%
echo:

rem Check arguments
if not exist "%~1" echo "%~1" does not exist & goto displayUsageMessage
rem Check whether directory (drive (d) + path (p)) for report exists, see also https://ss64.com/nt/for.html
for %%G in ("%~3") do if not exist %%~dpG echo %%~dpG does not exist & goto displayUsageMessage

echo Convert top level README file from AsciiDoc to HTML
if exist "%~1\README.adoc" (
	echo Converting "%~1\README.adoc"
	call asciidoctorj -b xhtml5 -a stylesheet! -a docinfo=private -a docinfodir="%cd%\src\main\xml\xhtml" -o "%~1\index.html" "%~1\README.adoc"
	if %ERRORLEVEL% NEQ 0 (
		exit /B %ERRORLEVEL%
	)
	
	echo Convert 2nd level README files from AsciiDoc to HTML
	for /d %%i in ("%~1\*") do (
		if exist "%%i\README.adoc" (
			echo Converting "%%i\README.adoc"
			call asciidoctorj -b xhtml5 -a stylesheet! -a docinfo=shared -a docinfodir="%cd%\src\main\xml\xhtml" -o "%%i\index.html" "%%i\README.adoc"
			if %ERRORLEVEL% NEQ 0 (
				exit /B %ERRORLEVEL%
			)
		)
	)
	
	echo Update HTML files
	rem Use caret sign to put the different options and configuration on their own line
	call Morgana -config=local-scripts\morgana-config.xml ^
	src\main\xml\xproc\generate-code-list-register-site.xpl ^
	-option:input-directory="%~1" ^
	-option:code-list-register-uri="%~2" ^
	-output:report="%~3" ^
	-option:overwrite-existing-alternative-formats=%overwrite_existing_alternative_formats% ^
	-static:debug=%debug_pipeline%
	
	echo Exit code: %ERRORLEVEL%
	
	exit /B %ERRORLEVEL%
) else (
	echo "%~1\README.adoc" does not exist, did you specify the correct directory?
	exit /B 1
)
goto:eof

:displayUsageMessage
	echo:
	echo Usage: scripts\%~nx0 ^<directory^> ^<code-list-register-uri^> ^<report^> [^<overwrite-existing-alternative-formats^>] [^<debug^>]
	echo:
	echo     directory                               path to existing local directory containing the code list register site
	echo                                             E.g. "C:\path\to\local\copy\of\codelistregister"
	echo     code-list-register-uri                  URI of the code list register, e.g. "https://example.org/codelistregister/"
	echo                                             E.g. "https://example.org/codelistregister/"
	echo     report                                  path to local file in existing directory to which to write the report (XML file)
	echo                                             E.g "C:\path\to\report.xml"
	echo     overwrite-existing-alternative-formats  false ^(default^) or true
	echo     debug                                   false ^(default^) or true
	echo:
goto:eof

:displayMessageAsciidoctorJ
	echo asciidoctorj was not found, please install it and try again.
	echo Use scripts\print-configuration.bat to check your configuration.
goto:eof

:displayMessageMorgana
	echo Morgana was not found, please install it and try again.
	echo Use scripts\print-configuration.bat to check your configuration.
goto:eof
