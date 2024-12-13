# genericode-transformer

## About the underlying standards and tools

### Genericode

[Genericode](https://docs.oasis-open.org/codelist/genericode/v1.0/genericode-v1.0.html), also known as Code List Representation, is “a single semantic model for code lists and accompanying XML serialization that is designed to IT-enable and standardize the publication of machine-readable code list information and its interchange between systems”[^1]. Genericode is developed by the [Organization for the Advancement of Structured Information Standards (OASIS)](https://www.oasis-open.org/). See the [website of the OASIS Code List Representation TC](https://www.oasis-open.org/committees/codelist/) for more information.

[^1]: Source: [Genericode Approved as an OASIS Standard](https://www.oasis-open.org/2023/02/01/genericode-approved-as-an-oasis-standard/)

## Installation

This tool relies on the presence of Java, an XProc 3 processor and the XSLT processor Saxon. The instructions here are given for XProc 3 processor Morgana.

- Clone the repository on your local machine, no releases are available at the moment.
- Ensure you have a Java 8 or Java 11 installation.
- Download and install [Morgana](https://www.xml-project.com/morganaxproc-iiise.html), add the path to the folder where you installed Morgana to your user's _Path_ environment variable.
- Download the latest version of the [XSLT processor Saxon](https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/) and place the jar file Saxon-HE-x.y.jar in the MorganaXProc-IIIse\MorganaXProc-IIIse_lib folder.

## Usage

On Windows and using Saxon, an XSLT transformation can be executed with the following command, where `SAXON_CP` is set to the location of the Saxon jar file (the one downloaded earlier or the one of your local Saxon command line installation):

```bat
%JAVA_HOME%\bin\java.exe -cp %SAXON_CP% net.sf.saxon.Transform -s:path\to\input.gc -xsl:path\to\gc2<format>.xsl -o:path\to\output.<format>
```

On Windows and using Morgana, a pipeline written in [XProc](https://xproc.org/) can be executed.

Create a file morgana-config.xml file in folder `local-scripts`. Adjust the value of element `xslt-connector` to match the value specified for your version of Saxon as specified in https://www.xml-project.com/manual/ch02.html#configuration_s1_1_s2_2, and make sure to add a media type mapping for genericode files (*.gc), see https://www.xml-project.com/manual/ch02.html#configuration_s1_5.

```xml
<morgana-config xmlns="http://www.xml-project.com/morganaxproc">	
	<!-- See "Selecting the XSLTConnector" on https://www.xml-project.com/manual/ch02.html#configuration_s1_1_s2_2 -->
	<XSLTValidationMode>LAX</XSLTValidationMode>
	<xslt-connector>saxon12-3</xslt-connector>
    
	<mediatype-mapping>
		<map file-extension="gc" media-type="application/xml" />
	</mediatype-mapping>	
    
</morgana-config>
```

Create a batch file, e.g. `create-code-list-version-overviews.bat` in folder `local-scripts` as follows, adjust the paths to the input and output:

```bat
Morgana -config=local-scripts\morgana-config.xml src\main\xml\xproc\create-code-list-version-overviews.xpl -option:input-directory=C:\path\to\directory -static:debug=false"
```

Run `create-code-list-version-overviews.bat` from the root directory of the repository:

```bat
local-scripts\create-code-list-version-overviews.bat
```

> [!CAUTION]
> Certain pipelines add files to the given directory or modify existing files. Make sure to keep a backup or to work in a directory that is under version control, so you can revert changes if needed.

To generate the whole code list register site, create a batch file, e.g. `generate-code-list-register-site.bat` in folder `local-scripts` as follows

```bat
@echo off
rem Convert all README.adoc files in this directory and its subdirectories to README.html files
rem xhtml5 is the backend and no stylesheet is included, the output files will be further processed, including adding a stylesheet, using XSLT
if "%~1" == "" (
	@rem Exit this batch script with non-zero (that is, unsuccessful) error code.
	echo Usage: %~nx0 "C:\path\to\directory\containing\files\to\convert"
	@exit /B 1
)

echo Convert top level README file from AsciiDoc to HTML
if exist "%~1\README.adoc" (
	echo Converting "%~1\README.adoc"
	call asciidoctorj -b xhtml5 -a stylesheet! -o "%~1\index.html" "%~1\README.adoc"
)

echo Convert 2nd level README files from AsciiDoc to HTML
for /d %%i in ("%~1\*") do (
	if exist "%%i\README.adoc" (
		echo Converting "%%i\README.adoc"
		call asciidoctorj -b xhtml5 -a stylesheet! -o "%%i\index.html" "%%i\README.adoc"
	)
)

call Morgana -config=local-scripts\morgana-config.xml ^
src\main\xml\xproc\generate-code-list-register-site.xpl ^
-option:input-directory=%~1 ^
-static:debug=false
```

Run `generate-code-list-register-site.bat` from the root directory of the repository:

```bat
local-scripts\generate-code-list-register-site.bat "C:\path\to\directory\containing\working\copy\of\codelistregistersite"
```

## Development

### Running the tests

The XSLT stylesheets are tested using [XSpec](https://github.com/xspec/xspec/), a unit test and behaviour-driven development (BDD) framework for XSLT, XQuery, and Schematron.

On Windows, the XSpec XSLT tests can be run using the batch files in the [scripts folder](/scripts). Run the batch files from the root directory of the repository, for instance:

```bat
scripts\run-xslt-tests.bat
```



