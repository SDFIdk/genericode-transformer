@echo off
rem Start with clearing the ERRORLEVEL back to 0, in case an error occurred during a previous execution of this batch file
rem See also https://ss64.com/nt/errorlevel.html
(call )

if "%~1" == "" (
	rem Exit this batch script with non-zero (that is, unsuccessful) error code.
	echo Usage: %~nx0 ^<directory^> [^<overwrite-existing-alternative-formats^>] [^<debug^>]
	echo:
	echo     directory                                  path to local directory containing the code list register site
	echo     overwrite-existing-alternative-formats     false ^(default^) or true
	echo     debug                                      false ^(default^) or true
	echo:
	exit /B 1
)

setlocal
echo Arguments provided:
echo ^<directory^>
echo %~1
if "%~2" == "" (
	set overwrite_existing_alternative_formats=false
) else (
	set overwrite_existing_alternative_formats=%~2
)
echo ^<overwrite-existing-alternative-formats^>
echo %overwrite_existing_alternative_formats%

if "%~3" == "" (
	set debug_pipeline=false
) else (
	set debug_pipeline=%~3
)
echo ^<debug^>
echo %debug_pipeline%

echo Convert top level README file from AsciiDoc to HTML
if exist "%~1\README.adoc" (
	echo Converting "%~1\README.adoc"
	call asciidoctorj -b xhtml5 -a stylesheet! -o "%~1\index.html" "%~1\README.adoc"
	if %ERRORLEVEL% NEQ 0 (
		exit /B %ERRORLEVEL%
	)
	
	echo Convert 2nd level README files from AsciiDoc to HTML
	for /d %%i in ("%~1\*") do (
		if exist "%%i\README.adoc" (
			echo Converting "%%i\README.adoc"
			call asciidoctorj -b xhtml5 -a stylesheet! -o "%%i\index.html" "%%i\README.adoc"
			if %ERRORLEVEL% NEQ 0 (
				exit /B %ERRORLEVEL%
			)
		)
	)
	
	echo Update HTML files
	rem Use caret sign to put the different options and configuration on their own line
	call Morgana src\main\xml\xproc\generate-code-list-register-site.xpl ^
	-xslt-connector=saxon12-3 ^
	-option:input-directory=%~1 ^
	-option:overwrite-existing-alternative-formats=%overwrite_existing_alternative_formats% ^
	-static:debug=%debug_pipeline%
	
	echo Exit code: %ERRORLEVEL%
	
	exit /B %ERRORLEVEL%
) else (
	echo "%~1\README.adoc" does not exist, did you specify the correct directory?
)