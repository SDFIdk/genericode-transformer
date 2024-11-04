set TEST_DIR=target
rem See https://github.com/xspec/xspec/wiki/Environment-Variables
set SAXON_CUSTOM_OPTIONS=--recognize-uri-query-parameters:true

for %%f in (src\test\xml\xspec\*.xspec) do (
    call "%XSPEC_HOME%\bin\xspec.bat" "%%f"
)