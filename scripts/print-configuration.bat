@echo off
chcp 65001 >NUL
echo:
echo Check Java
echo ----------
call %JAVA_HOME%\bin\java.exe --version
echo:
echo Check AsciidoctorJ
echo ------------------
call asciidoctorj --version
echo:
echo Check Morgana
echo -------------
call Morgana -config=local-scripts\morgana-config.xml src\main\xml\xproc\retrieve-processor-properties.xpl -silent
echo:
echo Check Saxon
echo -----------
call %JAVA_HOME%\bin\java.exe -cp %SAXON_CP% net.sf.saxon.Transform -t -?
echo:
echo Check XSpec
echo -----------
call "%XSPEC_HOME%\bin\xspec.bat" -h
echo:
rem Temporarily switch to a code page other than 65001 to avoid a change of font when calling powershell, 
rem see also https://stackoverflow.com/questions/70729614/graphic-cli-changed-after-run-the-powershell-command-in-batch-file
chcp 850 >NUL
rem Find the version of XSpec in the POM
powershell -Command "$xml = [xml](Get-Content '%XSPEC_HOME%\pom.xml'); $nsManager = New-Object System.Xml.XmlNamespaceManager $xml.NameTable; $nsManager.AddNamespace('pom', 'http://maven.apache.org/POM/4.0.0'); Write-Host 'XSpec version:' $xml.SelectSingleNode('/pom:project/pom:version', $nsManager).InnerText"
chcp 65001 >NUL
echo:
echo Directories where your operating system searches for executable files: %PATH%