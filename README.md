# genericode-transformer

## About the underlying standards and tools

### Genericode

[Genericode](https://docs.oasis-open.org/codelist/genericode/v1.0/genericode-v1.0.html), also known as Code List Representation, is “a single semantic model for code lists and accompanying XML serialization that is designed to IT-enable and standardize the publication of machine-readable code list information and its interchange between systems”[^1]. Genericode is developed by the [Organization for the Advancement of Structured Information Standards (OASIS)](https://www.oasis-open.org/). See the [website of the OASIS Code List Representation TC](https://www.oasis-open.org/committees/codelist/) for more information.

[^1]: Source: [Genericode Approved as an OASIS Standard](https://www.oasis-open.org/2023/02/01/genericode-approved-as-an-oasis-standard/)

### XProc

[Xproc](https://xproc.org/) is an XML based programming language for processing documents in pipelines. XProc 3 is developed by the [XProc Next Community Group](https://www.w3.org/community/xproc-next/), a community group of the [World Wide Web Consortium (W3C)](https://www.w3.org/).

## Installation

The installation instructions assume that the installation is done on a Windows computer.

- genericode-transformer: clone this repository on your local machine (no releases are available at the moment);
- Java:
  - Ensure you have a Java 11 (or later) installation;
  - Ensure that environment variable `JAVA_HOME` is set and points to that Java installation;
- Saxon:
  - Download and unzip the XSLT 3 processor [Saxon](https://github.com/Saxonica/Saxon-HE/releases/latest) into a suitable directory;
  - Set environment variable `SAXON_CP` to the location of the principal Saxon jar file, saxon-he-x.y.jar;
- Morgana:
  - Download and unzip the XProc 3 processor [Morgana](https://www.xml-project.com/morganaxproc-iiise.html) into a suitable directory;
  - Add the path to that directory to your user's _Path_ environment variable;
  - Place a _copy_ of jar file saxon-he-x.y.jar in the MorganaXProc-IIIse\MorganaXProc-IIIse_lib folder.
- AsciidoctorJ:
  - Download and unzip [AsciidoctorJ](https://github.com/asciidoctor/asciidoctorj) into a suitable directory;
  - Add the path to that directory to your user's _Path_ environment variable.

## Usage

The usage instructions assume that the application is used on a Windows computer.

### Adding/updating a single codelist's publication details

To update the publication details of a genericode code list, run batch file `update-publication-details.bat` in folder `scripts` from the _root directory_ of the working tree of your local repository:

```bat
scripts\update-publication-details.bat "C:\path\to\codelist.gc" https://example.org/codelistregister/subregister/
```

> [!CAUTION]
> The application invoked by the batch file modifies the file given as the first argunment. Make sure to keep a backup or to work in a directory that is under version control, so you can undo the changes if needed.

### Generating a code list register site

To generate a whole code list register site, run batch file `generate-code-list-register-site.bat` in folder `scripts`from the _root directory_ of the working tree of your local repository:

```bat
scripts\generate-code-list-register-site.bat "C:\path\to\directory\containing\working\copy\of\codelistregistersite"
```

> [!CAUTION]
> The applications invoked by the batch file add files to the given directory and/or modify existing files. Make sure to keep a backup or to work in a directory that is under version control, so you can undo the changes if needed.

If you want to overwrite existing CSV and HTML encodings of the code list versions, invoke the batch file as follows:

```bat
scripts\generate-code-list-register-site.bat "C:\path\to\directory\containing\working\copy\of\codelistregistersite" true
```

Run the batch file without arguments to see all the options:

```bat
scripts\generate-code-list-register-site.bat
```

## Development

### Running the tests

The XSLT stylesheets are tested using [XSpec](https://github.com/xspec/xspec/), a unit test and behaviour-driven development (BDD) framework for XSLT, XQuery, and Schematron.

On Windows, the XSpec XSLT tests can be run using the batch files in the [scripts folder](/scripts). Run the batch files from the _root directory_ of the working tree of your local repository, for instance:

```bat
scripts\run-xslt-tests.bat
```



