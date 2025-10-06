<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:err="http://www.w3.org/ns/xproc-error"
                xmlns:gt="urn:uuid:dcebd429-ed94-465a-a0a0-66e47def2454"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                name="transform-and-store-codelists"
                type="gt:transform-and-store-codelists"
                version="3.1">
    <p:documentation>This step takes a directory containing versions of code lists in genericode (GC),
        in the directory itself and in its
        subdirectories,
        and creates the CSV and HTML encodings of each code list version, in the directory structure that is provided as input.
        So
        v1.2.3.codelist.csv, v1.2.3.codelist.html and v1.2.3.codelist.atom will be saved in the same directory as v1.2.3.codelist.gc is present in.
        It is assumed that the
        file names follow the pattern v1.2.3.codelist.html, v1.2.3.codelist.gc, etc.

        This step has neither input nor output ports. It reads from and
        writes to a file system.
    </p:documentation>
    <p:import href="directory-list-absolute-uris.xpl"/>
    <p:option name="input-directory"
              required="true"/>
    <!-- E.g. https://example.org/codelistregister/ -->
    <p:option name="code-list-register-uri"
              required="true"/>
    <p:option name="overwrite-existing-alternative-formats"
              as="xsd:boolean"
              select="false()"/>
    <p:option name="debug"
              as="xsd:boolean"
              select="false()"
              static="true"/>
    <p:variable name="input-directory-urified"
                select="p:urify($input-directory)"/>
    <gt:directory-list-absolute-uris name="create-directory-list"
                                     p:message="Produce list of contents of {$input-directory} (code list versions in all formats)">
        <p:with-option name="path"
                       select="$input-directory-urified"/>
        <!-- v1.2.3.codelist.gc must match,
        v1.2.3.codelist.csv must match,
        v1.2.3.codelist.html must match,
        v1.2.3.codelist.atom must match
        v1.2.3.codelist.rdf must match
        Later on it is checked whether the CSV/HTML/Atom/RDF encodings already exist.
         -->
        <p:with-option name="include-filter"
                       select="'v[0-9]+\.[0-9]+\.[0-9]+\.[^/]+\.[gc|csv|html|atom|rdf]'"/>
        <p:with-option name="max-depth"
                       select="'unbounded'"/>
    </gt:directory-list-absolute-uris>
    <p:store name="store-directory-list"
             message="Store processed directory list for debugging"
             href="{'../../../../target/store-directory-list-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
             serialization="map { 'indent': true() }"
             use-when="$debug">
    </p:store>
    <gt:directory-list-absolute-uris name="create-dirlist-gcversion"
                                     p:message="Produce list of contents of {$input-directory} (code list versions in GC format and code list value index files)">
        <p:with-option name="path"
                       select="$input-directory-urified"/>
        <p:with-option name="include-filter"
                       select="'(v[0-9]+\.[0-9]+\.[0-9]+\.[^/]+\.gc|([^/]+/){3}index\.html)'"/>
        <p:with-option name="max-depth"
                       select="'unbounded'"/>
    </gt:directory-list-absolute-uris>
    <p:xslt name="sort-code-list-files-on-version-desc"
            version="3.0">
        <p:with-input port="stylesheet"
                      href="../xslt/sort-codelist-files-on-version-desc.xsl"/>
    </p:xslt>
    <p:store name="directory-list-new-absolute-uris-for-gcversions"
             message="Store processed directory list for debugging"
             href="{'../../../../target/store-new-directory-list-absolute-uris-for-gcversions-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
             serialization="map { 'indent': true() }"
             use-when="$debug">
    </p:store>
    <p:for-each name="iterate-over-codelist-directories">
        <p:with-input select="/c:directory/c:directory/c:directory"/>
        <p:identity message="Start processing code list directory {base-uri(/c:directory)}"/>
        <p:variable name="code-list-register-uri-latest-html"
                    select="/c:directory/c:file[ends-with(@name, '.gc')][1]
                            => base-uri()
                            => p:urify()
                            => replace($input-directory-urified || '/', $code-list-register-uri)
                            => replace('\.gc$', '.html')
                            "/>
        <p:variable name="codevalue-index-files-exist"
                    as="xsd:boolean"
                    select="exists(/c:directory/c:directory/c:file[@name eq 'index.html'])"/>
        <!-- Load only the index.html in the first directory, and check only what URL that file redirects to,
        to avoid loading all index.html files, as I/O operations are expensive. So assume that the
        redirects have been created correctly earlier, and they are all the same. -->
        <p:if name="if-codevalue-index-files-exist"
              test="$codevalue-index-files-exist">
            <p:variable name="base-uri-index-file-first-codevalue-directory"
                        select="base-uri(/c:directory/c:directory[1]/c:file[@name eq 'index.html'])"/>
            <p:load name="load-index-file-first-codevalue-directory"
                    message="Load {$base-uri-index-file-first-codevalue-directory}"
                    href="{$base-uri-index-file-first-codevalue-directory}"
                    content-type="application/xhtml+xml"/>
            <!-- See also https://html.spec.whatwg.org/multipage/semantics.html#pragma-directives -->
            <p:variable name="redirection-target-url"
                        select="replace(/xhtml:html/xhtml:head/xhtml:meta[@http-equiv eq 'refresh']/@content, '^\d+;\s+URL=(.*)$', '$1', 'i')"/>
            <!-- Add attribute to XML document flowing through the pipeline,
            to avoid having to invent a new structure for the output of this subpipeline,
             and consequently also having to add another subpipeline to handle the case
            in which the code value index files do not exist (p:choose, instead of p:if now).
            Add attribute in a namespace, to comply with https://spec.xproc.org/3.1/file/#c.directory-list. -->
            <p:add-attribute name="add-redirection-target"
                             match="/c:directory/c:directory[1]/c:file[@name eq 'index.html']"
                             attribute-name="gt:redirection-target"
                             attribute-value="{$redirection-target-url}">
                <p:with-input port="source">
                    <p:pipe step="iterate-over-codelist-directories"
                            port="current"/>
                </p:with-input>
            </p:add-attribute>
            <p:store name="store-add-redirection-target"
                     message="Store directory list with redirection target for debugging"
                     href="{'../../../../target/store-add-redirection-target-' || format-time(current-time(),'[H01][m01][s01][f001]') || '.xml'}"
                     serialization="map { 'indent': true() }"
                     use-when="$debug">
            </p:store>
        </p:if>
        <p:variable name="codevalue-index-files-for-latest-version-exist"
                    as="xsd:boolean"
                    select="if (exists(/c:directory/c:directory[1]/c:file[@name eq 'index.html']/@gt:redirection-target)) then /c:directory/c:directory[1]/c:file[@name eq 'index.html']/@gt:redirection-target eq $code-list-register-uri-latest-html else false()">
        </p:variable>
        <p:if test="$codevalue-index-files-exist and not($codevalue-index-files-for-latest-version-exist)">
            <p:identity message="Delete deprecated index files and directories"/>
            <p:for-each name="remove-codevalue-directory">
                <p:with-input select="c:directory/c:directory"/>
                <p:identity message="Delete deprecated version directory and file {base-uri(/c:directory)}"
                            use-when="$debug"/>
                <p:file-delete href="{base-uri(/c:directory)}"
                               recursive="true"/>
            </p:for-each>
        </p:if>
        <p:for-each name="iterate-over-gc-files-in-codelist-directory">
            <p:with-input select="//c:file[ends-with(@name, '.gc')]">
                <p:pipe step="iterate-over-codelist-directories"
                        port="current"/>
            </p:with-input>
            <p:identity message="In iterate-over-gc-files for {base-uri(/c:file)}"
                        use-when="$debug"/>
            <p:variable name="gc-name"
                        select="/c:file/@name"/>
            <p:variable name="base-uri-gc"
                        select="base-uri(/c:file)"/>
            <p:variable name="gc-parent-directory"
                        select="substring-before($base-uri-gc,$gc-name)"/>
            <p:variable name="base-uri-csv"
                        select="replace($base-uri-gc, '\.gc$', '.csv')"/>
            <p:variable name="csv-exists"
                        select="exists(//c:file[base-uri() eq $base-uri-csv])">
                <p:pipe step="create-directory-list"
                        port="result"/>
            </p:variable>
            <p:variable name="base-uri-html"
                        select="replace($base-uri-gc, '\.gc$', '.html')"/>
            <p:variable name="html-exists"
                        select="exists(//c:file[base-uri() eq $base-uri-html])">
                <p:pipe step="create-directory-list"
                        port="result"/>
            </p:variable>
            <p:variable name="base-uri-atom"
                        select="replace($base-uri-gc, '\.gc$', '.atom')"/>
            <p:variable name="atom-exists"
                        select="exists(//c:file[base-uri() eq $base-uri-atom])">
                <p:pipe step="create-directory-list"
                        port="result"/>
            </p:variable>
            <p:variable name="base-uri-rdf"
                        select="replace($base-uri-gc, '\.gc$', '.rdf')"/>
            <p:variable name="rdf-exists"
                        select="exists(//c:file[base-uri() eq $base-uri-rdf])">
                <p:pipe step="create-directory-list"
                        port="result"/>
            </p:variable>
            <p:choose>
                <!-- Only load the genericode file when it is actually needed to transform it into other formats,
                as loading files from disk can be expensive. -->
                <p:when test="$overwrite-existing-alternative-formats or not($csv-exists) or not($html-exists) or not($atom-exists) or not($rdf-exists) or not($codevalue-index-files-for-latest-version-exist)">
                    <p:load name="load-gc"
                            message="Load {$gc-name} from {$base-uri-gc}"
                            href="{$base-uri-gc}"
                            content-type="application/xml"/>
                    
                    <p:variable name="csv-is-alternate-format"
                                select="exists(/gc:CodeList/Identification/AlternateFormatLocationUri[@MimeType eq 'text/csv'])"/>
                        <!-- No $html-is-alternate-format: HTML generation does not depend on the presence of an entry for HTML in AlternateFormatLocationUri,
                        the HTML is always needed to have a proper website -->
                        <!-- No $atom-is-alternate-format: we need the Atom to have a proper feed, 
                        and the Atom entries are not even linked to via a button on the HTML page. -->
                    <p:variable name="rdf-is-alternate-format"
                                select="exists(/gc:CodeList/Identification/AlternateFormatLocationUri[@MimeType eq 'application/rdf+xml'])"/>
                    <p:choose>
                        <p:when test="$csv-is-alternate-format and ($overwrite-existing-alternative-formats or not($csv-exists))">
                            <p:xslt name="gc2csv"
                                    message="Transform {$base-uri-gc} to CSV">
                                <p:with-input port="source">
                                    <p:pipe step="load-gc"
                                            port="result"/>
                                </p:with-input>
                                <p:with-input port="stylesheet"
                                              href="../xslt/gc2csv.xsl"/>
                            </p:xslt>
                            <p:store name="store-csv"
                                     message="Store CSV code list in {$base-uri-csv}"
                                     href="{$base-uri-csv}"/>
                        </p:when>
                        <p:otherwise>
                            <p:identity message="Do not transform {$gc-name} to CSV as {$base-uri-csv} already exists or CSV is not an alternate format for {$gc-name}"/>
                        </p:otherwise>
                    </p:choose>
                    <p:choose>
                        <p:when test="$overwrite-existing-alternative-formats or not($html-exists)">
                            <p:xslt name="gc2html"
                                    message="Transform {$base-uri-gc} to HTML">
                                <p:with-input port="source">
                                    <p:pipe step="load-gc"
                                            port="result"/>
                                </p:with-input>
                                <p:with-input port="stylesheet"
                                              href="../xslt/gc2html.xsl"/>
                            </p:xslt>
                            <p:store name="store-html"
                                     message="Store HTML code list in {$base-uri-html}"
                                     href="{$base-uri-html}"/>
                        </p:when>
                        <p:otherwise>
                            <p:identity message="Do not transform {$gc-name} to HTML as {$base-uri-html} already exists"/>
                        </p:otherwise>
                    </p:choose>
                    <p:choose>
                        <p:when test="$overwrite-existing-alternative-formats or not($atom-exists)">
                            <p:xslt name="gc2atom"
                                    message="Transform {$base-uri-gc} to ATOM">
                                <p:with-input port="source">
                                    <p:pipe step="load-gc"
                                            port="result"/>
                                </p:with-input>
                                <p:with-input port="stylesheet"
                                              href="../xslt/gc2atom.xsl"/>
                            </p:xslt>
                            <p:store name="store-atom"
                                     message="Store ATOM code list in {$base-uri-atom}"
                                     href="{$base-uri-atom}"/>
                        </p:when>
                        <p:otherwise>
                            <p:identity message="Do not transform {$gc-name} to ATOM as {$base-uri-atom} already exists"/>
                        </p:otherwise>
                    </p:choose>
                    <p:choose>
                        <p:when test="$rdf-is-alternate-format and ($overwrite-existing-alternative-formats or not($rdf-exists))">
                            <p:xslt name="gc2rdf"
                                    message="Transform {$base-uri-gc} to RDF">
                                <p:with-input port="source">
                                    <p:pipe step="load-gc"
                                            port="result"/>
                                </p:with-input>
                                <p:with-input port="stylesheet"
                                              href="../xslt/gc2rdf.xsl"/>
                            </p:xslt>
                            <p:store name="store-rdf"
                                     message="Store RDF code list in {$base-uri-rdf}"
                                     href="{$base-uri-rdf}"/>
                        </p:when>
                        <p:otherwise>
                            <p:identity message="Do not transform {$gc-name} to RDF as {$base-uri-rdf} already exists or RDF is not an alternate format for {$gc-name}"/>
                        </p:otherwise>
                    </p:choose>
                    <p:choose>
                        <p:when test="$rdf-is-alternate-format and (p:iteration-position() = 1) and ($overwrite-existing-alternative-formats or not($codevalue-index-files-for-latest-version-exist))">
                            <p:identity message="Create directory and index file for each code value in {$gc-name}"/>
                            <p:for-each name="for-each-gc-codevalue">
                                <p:with-input select="/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='kode']/SimpleValue">
                                    <p:pipe step="load-gc" port="result" />
                                </p:with-input>
                                <!-- 
                                (1) Encode characters that are reserved according to RFC 3986 (encode-for-uri)
                                (2) Replace characters that are reserved in relation to Windows file names, see e.g. https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file,
                                with a string based on the official Unicode names of these characters, see https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-4/#G2082.  -->
                                <p:variable name="codevalue-directory-name"
                                            select=".
                                                => replace(':','colon')
                                                => replace('\*','asterisk')
                                                => replace('&quot;','quotation_mark')
                                                => replace('/','solidus')
                                                => replace('&lt;','less_than_sign')
                                                => replace('&gt;','greater_than_sign')
                                                => replace('\?','question_mark')
                                                => replace('\\','reverse_solidus')
                                                => replace('\|','vertical_line')
                                                => encode-for-uri()
                                            "/>
                                <p:variable name="codevalue-directory-uri"
                                            select="p:urify(concat($gc-parent-directory, $codevalue-directory-name, '/'))"/>
                                <p:variable name="codevalue-index-file-uri"
                                            select="concat($codevalue-directory-uri, 'index.html')"/>
                                <p:file-mkdir href="{$codevalue-directory-uri}"/>
                                <p:identity message="Create index file in {$codevalue-directory-name} that redirects to {$code-list-register-uri-latest-html}"
                                            use-when="$debug"/>
                                <p:xslt name="codevalue-index-redirect">
                                    <p:with-input port="source">
                                        <p:empty/>
                                    </p:with-input>
                                    <p:with-input port="stylesheet"
                                                  href="../xslt/codevalue-index-redirect.xsl"/>
                                    <p:with-option name="template-name"
                                                   select="'main'"/>
                                    <p:with-option name="parameters"
                                                   select="map {'code-list-register-uri-latest-html' : $code-list-register-uri-latest-html }"/>
                                </p:xslt>
                                <p:identity message="Store index file in {$codevalue-index-file-uri}"
                                            use-when="$debug"/>
                                <p:store name="save-index"
                                         href="{$codevalue-index-file-uri}">
                                </p:store>
                            </p:for-each>
                        </p:when>
                        <p:otherwise>
                            <p:identity message="Do not create directories nor index files for {$gc-name}"/>
                        </p:otherwise>
                    </p:choose>
                </p:when>
                <p:otherwise>
                    <p:identity message="Do not transform {$gc-name} as its alternative formats already exist"/>
                </p:otherwise>
            </p:choose>
        </p:for-each>
    </p:for-each>
</p:declare-step>