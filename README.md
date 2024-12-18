# genericode-transformer

## About the underlying standards and tools

### Genericode

[Genericode](https://docs.oasis-open.org/codelist/genericode/v1.0/genericode-v1.0.html), also known as Code List Representation, is “a single semantic model for code lists and accompanying XML serialization that is designed to IT-enable and standardize the publication of machine-readable code list information and its interchange between systems”[^1]. Genericode is developed by the [Organization for the Advancement of Structured Information Standards (OASIS)](https://www.oasis-open.org/). See the [website of the OASIS Code List Representation TC](https://www.oasis-open.org/committees/codelist/) for more information.

[^1]: Source: [Genericode Approved as an OASIS Standard](https://www.oasis-open.org/2023/02/01/genericode-approved-as-an-oasis-standard/)

### XProc

[Xproc](https://xproc.org/) is an XML based programming language for processing documents in pipelines. XProc 3 is developed by the [XProc Next Community Group](https://www.w3.org/community/xproc-next/), a community group of the [World Wide Web Consortium (W3C)](https://www.w3.org/).

## Installation

This tool relies on the presence of Java, an XProc 3 processor, the XSLT processor Saxon and AsciidoctorJ. The instructions here are given for XProc 3 processor Morgana.

- Clone the repository on your local machine, no releases are available at the moment.
- Ensure you have a Java 11 installation.
- Download and install [Morgana](https://www.xml-project.com/morganaxproc-iiise.html), add the path to the folder where you installed Morgana to your user's _Path_ environment variable.
- Download the latest version of the [XSLT processor Saxon](https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/) and place the jar file Saxon-HE-x.y.jar in the MorganaXProc-IIIse\MorganaXProc-IIIse_lib folder.
- Download and install [AsciidoctorJ](https://github.com/asciidoctor/asciidoctorj), add the path to the folder where you installed AsciidoctorJ to your user's _Path_ environment variable.

## Usage

> [!CAUTION]
> Certain pipelines add files to the given directory or modify existing files. Make sure to keep a backup or to work in a directory that is under version control, so you can revert changes if needed.

On Windows and using Morgana, a pipeline written in [XProc](https://xproc.org/) can be executed.

To generate the whole code list register site, run batch file `generate-code-list-register-site.bat` in folder `scripts`from the root directory of the repository:

```bat
scripts\generate-code-list-register-site.bat "C:\path\to\directory\containing\working\copy\of\codelistregistersite"
```

or, if you want to overwrite existing CSV and HTML encodings of the code list versions:

```bat
scripts\generate-code-list-register-site.bat "C:\path\to\directory\containing\working\copy\of\codelistregistersite" true
```

Run the batch file without arguments to see all the options:

```bat
scripts\generate-code-list-register-site.bat
```

On Windows and using Saxon, a single XSLT transformation can be executed with the following command, where `SAXON_CP` is set to the location of the Saxon jar file (the one downloaded earlier or the one of your local Saxon command line installation):

```bat
%JAVA_HOME%\bin\java.exe -cp %SAXON_CP% net.sf.saxon.Transform -s:path\to\input.gc -xsl:path\to\gc2<format>.xsl -o:path\to\output.<format>
```

## Development

### Running the tests

The XSLT stylesheets are tested using [XSpec](https://github.com/xspec/xspec/), a unit test and behaviour-driven development (BDD) framework for XSLT, XQuery, and Schematron.

On Windows, the XSpec XSLT tests can be run using the batch files in the [scripts folder](/scripts). Run the batch files from the root directory of the repository, for instance:

```bat
scripts\run-xslt-tests.bat
```



