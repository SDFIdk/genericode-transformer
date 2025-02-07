@echo off
rem Start with clearing the ERRORLEVEL back to 0, in case an error occurred during a previous execution of this batch file
rem See also https://ss64.com/nt/errorlevel.html
(call )

if "%~1" == "" (
	rem Exit this batch script with non-zero (that is, unsuccessful) error code.
	echo Usage: %~nx0 ^<file^> ^<codeListSubregisterUri^>
	echo:
	echo     file                                  genericode file path
	echo     codeListSubregisterUri                first part of the retrieval location URIs, e.g. https://example.org/codelistregister/subregister/
	echo:
	exit /B 1
)

if "%~2" == "" (
	echo Missing second argument codeListSubregisterUri
	exit /B 1
)

setlocal
echo Arguments provided:
echo ^<file^>
echo %~1
echo ^<codeListSubregisterUri^>
echo %~2

echo Add publication details via XSLT transformation
call %JAVA_HOME%\bin\java.exe -cp %SAXON_CP% net.sf.saxon.Transform -s:"%~1" -xsl:src\main\xml\xslt\gc2gc.xsl -o:"%~1" codeListSubregisterUri="%~2"

echo Exit code: %ERRORLEVEL%
	
exit /B %ERRORLEVEL%
