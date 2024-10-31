rem See https://github.com/xspec/xspec/wiki/Environment-Variables
set TEST_DIR=target

for %%f in (src\test\xml\xspec\*.xspec) do (
    call "%XSPEC_HOME%\bin\xspec.bat" "%%f"
)