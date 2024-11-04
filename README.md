# genericode-validator

## About the underlying standards and tools

### Genericode

[Genericode](https://docs.oasis-open.org/codelist/genericode/v1.0/genericode-v1.0.html), also known as Code List Representation, is “a single semantic model for code lists and accompanying XML serialization that is designed to IT-enable and standardize the publication of machine-readable code list information and its interchange between systems”[^1]. Genericode is developed by the [Organization for the Advancement of Structured Information Standards (OASIS)](https://www.oasis-open.org/). See the [website of the OASIS Code List Representation TC](https://www.oasis-open.org/committees/codelist/) for more information.

[^1]: Source: [Genericode Approved as an OASIS Standard](https://www.oasis-open.org/2023/02/01/genericode-approved-as-an-oasis-standard/)

## Installation

TODO

## Usage

On Windows and using Saxon, an XSLT transformation can be executed with the following command:

```bat
%JAVA_HOME%bin\java.exe -cp %SAXON_CP% net.sf.saxon.Transform -s:path\to\input.gc -xsl:path\to\gc2<format>.xsl -o:path\to\output.<format>
```

## Development

### Running the tests

The XSLT stylesheets are tested using [XSpec](https://github.com/xspec/xspec/), a unit test and behaviour-driven development (BDD) framework for XSLT, XQuery, and Schematron.

On Windows, the XSpec XSLT tests can be run using the batch files in the [scripts folder](/scripts). Run the batch files from the root directory of the repository, for instance:

```bat
scripts\run-xslt-tests.bat
```



