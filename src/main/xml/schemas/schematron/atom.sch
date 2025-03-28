<?xml version="1.0" encoding="UTF-8"?>
<schema
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xslt2">

    <title>Additional rules for genericode files</title>
    <p>Additional rules for genericode files are specified by KDS.</p>

    <ns
        prefix="atom"
        uri="http://www.w3.org/2005/Atom" />

    <pattern id="p_feed_athor">
        <title>Check authors</title>

        <rule context="atom:feed">
            <assert
                id="feed_author"
                test="atom:author or not(atom:entry[not(atom:author)])"
                diagnostics="atom_id">
                An atom:feed must have an atom:author unless all of its atom:entry children have an atom:author.
            </assert>
        </rule>

    </pattern>

    <pattern id="p_entry_alternate_link">
        <title>Check entry's alternate link</title>

        <rule context="atom:entry">
            <assert
                id="entry_alternate_link"
                test="atom:link[@rel='alternate'] or atom:link[not(@rel)] or atom:content"
                diagnostics="atom_id">
                An atom:entry must have at least one atom:link element with a rel attribute of 'alternate' or an atom:content.
            </assert>
        </rule>

    </pattern>

    <pattern id="p_entry_author">
        <title>Check entry's author</title>

        <rule context="atom:entry">
            <assert
                id="feed_author"
                test="atom:author or ../atom:author or atom:source/atom:author"
                diagnostics="atom_id">
                An atom:entry must have an atom:author if its feed does not.
            </assert>
        </rule>

    </pattern>

    <diagnostics>
        <diagnostic id="atom_id">
            Atom id: <value-of select="atom:id" />
        </diagnostic>
    </diagnostics>

</schema>