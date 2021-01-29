<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs oscal fn"
    version="3.0" xmlns:fn="local function" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0">
    <xsl:param name="show-all-withdrawn" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="compare-ODP" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="false()"/>
    <!-- r5 inputs -->
    <xsl:variable name="SP800-53r5" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev5/@base, /revs/rev5/doc[@name = 'SP800-53r5']/@url))"/>
    <xsl:variable name="SP800-53r5-low" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev5/@base, /revs/rev5/doc[@name = 'SP800-53r5-low']/@url))"/>
    <xsl:variable name="SP800-53r5-moderate" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev5/@base, /revs/rev5/doc[@name = 'SP800-53r5-moderate']/@url))"/>
    <xsl:variable name="SP800-53r5-high" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev5/@base, /revs/rev5/doc[@name = 'SP800-53r5-high']/@url))"/>
    <xsl:variable name="SP800-53r5-privacy" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev5/@base, /revs/rev5/doc[@name = 'SP800-53r5-privacy']/@url))"/>
    <!-- r4 inputs -->
    <xsl:variable name="SP800-53r4" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev4/@base, /revs/rev4/doc[@name = 'SP800-53r4']/@url))"/>
    <xsl:variable name="SP800-53r4-low" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev4/@base, /revs/rev4/doc[@name = 'SP800-53r4-low']/@url))"/>
    <xsl:variable name="SP800-53r4-moderate" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev4/@base, /revs/rev4/doc[@name = 'SP800-53r4-moderate']/@url))"/>
    <xsl:variable name="SP800-53r4-high" as="document-node()" xpath-default-namespace=""
        select="doc(concat(/revs/rev4/@base, /revs/rev4/doc[@name = 'SP800-53r4-high']/@url))"/>
    <xsl:output method="html" indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="r4-bullet" as="xs:string">④</xsl:variable>
    <xsl:variable name="r5-bullet" as="xs:string">⑤</xsl:variable>
    <xsl:function name="fn:withdrawn" as="xs:boolean">
        <xsl:param name="control" as="element()" required="true"/>
        <xsl:sequence select="$control/prop[@name = 'status'] = ('Withdrawn', 'withdrawn')"/>
    </xsl:function>
    <xsl:function name="fn:param-text" as="xs:string">
        <xsl:param name="param" as="element()" required="true"/>
        <xsl:value-of select="$param"/>
    </xsl:function>
    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'"/>
    <xsl:variable name="ODP-low" as="document-node()" select="doc('file:/home/gapinski/Projects/CSET/NASA_SP-800-53_rev4_Low-baseline_profile.xml')"/>
    <xsl:variable name="ODP-moderate" as="document-node()"
        select="doc('file:/home/gapinski/Projects/CSET/NASA_SP-800-53_rev4_Moderate-baseline_profile.xml')"/>
    <xsl:variable name="ODP-high" as="document-node()" select="doc('file:/home/gapinski/Projects/CSET/NASA_SP-800-53_rev4_High-baseline_profile.xml')"/>
    <xsl:variable name="CC" as="document-node()" select="doc('cc.xml')"/>
    <xsl:variable name="MAP54" as="document-node()" select="doc('54.xml')"/>
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <title>NIST SP 800-53r5 versus SP 800-53r4</title>
                <xsl:variable name="css" select="unparsed-text(replace(static-base-uri(), '\.xsl$', '.css'))"/>
                <style><xsl:value-of disable-output-escaping="true" select="replace($css, '\s+', ' ')"/></style>
            </head>
            <body>
                <h1>NIST SP 800-53r5 versus SP 800-53r4</h1>
                <p>
                    <xsl:text expand-text="true">Last updated { format-dateTime(current-dateTime(), '[MNn] [D] [Y] [H01]:[m01] [ZN,*-3]') }.</xsl:text>
                </p>
                <!-- Introduction -->
                <h2 id="introduction">Introduction</h2>
                <p>This document is an analysis of NIST <cite><a target="_blank"
                            href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final">SP 800-53 revision 5</a></cite> and additionally
                    compares it with the prior version <cite><a target="_blank" href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final"
                            >SP 800-53 revision 4</a></cite>.</p>
                <p>The term "control" as used in this document refers to both (in SP 800-53 parlance) controls and control enhancements.</p>
                <p>NIST introduced a separate document <cite><a target="_blank" href="https://csrc.nist.gov/publications/detail/sp/800-53b/final">SP
                            800-53B</a></cite> which specifies control baselines to be used in conjunction with SP 800-53r5 controls. Control
                    baselines had previously appeared in SP 800-53r4 appendix D.</p>
                <p> The deadline for complete SP 800-53r5 adoption is 2021-09-23 — <xsl:value-of
                        select="xs:integer(floor(days-from-duration(xs:date('2021-09-23Z') - current-date()) div 7))"/> weeks — from when this
                    docuument was created. <cite><a target="_blank" href="https://www.cio.gov/policies-and-priorities/circular-a-130/">OMB Circular
                            A-130 Managing Information as a Strategic Resource</a></cite> Appendix I §5 part a ¶3 (page I-16) specifies
                        <blockquote>For legacy information systems, agencies are expected to meet the requirements of, and be in compliance with,
                        NIST standards and guidelines within one year of their respective publication dates unless otherwise directed by OMB. The
                        one-year compliance date for revisions to NIST publications applies only to new or updated material in the publications. For
                        information systems under development or for legacy systems undergoing significant changes, agencies are expected to meet the
                        requirements of, and be in compliance with, NIST standards and guidelines immediately upon deployment of the
                        systems.</blockquote> In other words, adoption should be immediate or no later than one year after publication.</p>
                <p><a href="#inputs">Inputs</a> — <a href="#changes">Changes</a> — <a href="#details">Details</a> — <a href="#extras">Extras</a></p>
                <h2 id="inputs">OSCAL Inputs</h2>
                <p>
                    <span>This report uses documents from <a target="_blank"
                            href="https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53"
                            >https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53</a>.</span>
                </p>
                <p> NB: That repository <em>might</em> lag the most recently published SP 800-53r5. It appeared to match as of <a
                        href="https://github.com/usnistgov/oscal-content/commit/9fd42a99a440f0ac7e0db2087cde4995bf33bf7c#diff-1ada417fef1c4041fc8ae4531ca0de363af15561d915790c9fdd58a4ce489fc8"
                        >this commit</a>.<span/>
                </p>
                <ul>
                    <xsl:for-each
                        select="($SP800-53r5, $SP800-53r5-low, $SP800-53r5-moderate, $SP800-53r5-high, $SP800-53r5-privacy, $SP800-53r4, $SP800-53r4-low, $SP800-53r4-moderate, $SP800-53r4-high)">
                        <li>
                            <div>
                                <code>
                                    <xsl:value-of select="document-uri(.)"/>
                                </code>
                            </div>
                            <div>
                                <cite>
                                    <xsl:value-of select=".//metadata/title"/>
                                </cite>
                            </div>
                            <div>
                                <xsl:text expand-text="true">Last modified: {.//metadata/last-modified} </xsl:text>
                            </div>
                        </li>
                    </xsl:for-each>
                </ul>
                <h2 id="changes">Changes from SP 800-53r4 to SP 800-53r5</h2>
                <h3>Controls which are selected in baselines</h3>
                <p>Controls which are selected in baselines are destined to be employed and thus the related ODPs are destined to be tailored.</p>
                <xsl:variable name="controls" as="element()*" select="$SP800-53r5//control"/>
                <xsl:variable name="baselined-controls" as="element()*"
                    select="$controls[@id = ($SP800-53r5-low//import/include/call/@control-id, $SP800-53r5-moderate//import/include/call/@control-id, $SP800-53r5-high//import/include/call/@control-id, $SP800-53r5-privacy//import/include/call/@control-id)]"/>
                <xsl:variable name="novel-controls" as="element()*" select="$controls[not(@id = $SP800-53r4//control/@id)]"/>
                <xsl:variable name="novel-and-baselined-controls" as="element()*"
                    select="$novel-controls[@id = ($SP800-53r5-low//import/include/call/@control-id, $SP800-53r5-moderate//import/include/call/@control-id, $SP800-53r5-high//import/include/call/@control-id, $SP800-53r5-privacy//import/include/call/@control-id)]"/>
                <p>
                    <xsl:text>SP 800-53r5 has  </xsl:text>
                    <xsl:value-of select="count($baselined-controls)"/>
                    <xsl:text> controls selected in one or more baselines and these collectively incorporate </xsl:text>
                    <xsl:value-of select="count($baselined-controls/param)"/>
                    <xsl:text> organization-defined parameters.</xsl:text>
                </p>
                <p>
                    <xsl:text expand-text="true">SP 800-53r5 has {count($novel-controls)} novel (i.e.,  not in SP 800-53r4) controls.</xsl:text>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="count($novel-and-baselined-controls)"/>
                    <xsl:text> of those are selected in one or more SP 800-53B baselines, and collectively incorporate </xsl:text>
                    <xsl:value-of select="count($novel-and-baselined-controls/param)"/>
                    <xsl:text> (novel) organization-defined parameters.</xsl:text>
                </p>
                <p>The following shows the novel SP 800-53r5 controls which appear in SP 800-53B Low, Moderate, High, or Privacy control
                    baselines.</p>
                <table>
                    <caption>Novel SP 800-53r5 controls which are selected in SP 800-53B baselines</caption>
                    <thead>
                        <tr>
                            <th><xsl:attribute name="class">center</xsl:attribute>Family</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>Control</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>Title</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>Baselines</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>ODPs</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="$novel-and-baselined-controls">
                            <tr>
                                <td>
                                    <xsl:value-of select="ancestor::group/title"/>
                                </td>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']"/>
                                    </a>
                                </td>
                                <td>
                                    <xsl:if test="parent::control">
                                        <xsl:value-of select="parent::control/title"/>
                                        <xsl:text> | </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="title"/>
                                </td>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <xsl:if test="
                                            current()/@id = $SP800-53r5-low//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-moderate//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-high//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-privacy//import/include/call/@control-id
                                            ">
                                        <div>
                                            <span class="FIPS199categorization">
                                                <xsl:if test="current()/@id = $SP800-53r5-low//import/include/call/@control-id">
                                                    <xsl:text>Ⓛ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓜ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-high//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓗ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓟ</xsl:text>
                                                </xsl:if>
                                            </span>
                                        </div>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <xsl:if test="param">
                                        <xsl:value-of select="count(param)"/>
                                    </xsl:if>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <ul>
                    <li>
                        <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-low//import/include/call/@control-id]),'#,##0')} novel controls selected in the SP 800-53B Low security control baseline.</xsl:text>
                        <div>
                            <xsl:for-each select="$novel-controls[@id = $SP800-53r5-low//import/include/call/@control-id]">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a href="#{@id}">
                                    <xsl:value-of select="prop[@name = 'label']"/>
                                </a>
                            </xsl:for-each>
                        </div>
                    </li>
                    <li>
                        <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-moderate//import/include/call/@control-id]),'#,##0')} novel controls selected in the SP 800-53B Moderate security control baseline.</xsl:text>
                        <div>
                            <xsl:for-each select="$novel-controls[@id = $SP800-53r5-moderate//import/include/call/@control-id]">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a href="#{@id}">
                                    <xsl:value-of select="prop[@name = 'label']"/>
                                </a>
                            </xsl:for-each>
                        </div>
                    </li>
                    <li>
                        <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-high//import/include/call/@control-id]),'#,##0')} novel controls selected in the SP 800-53B High security control baseline.</xsl:text>
                        <div>
                            <xsl:for-each select="$novel-controls[@id = $SP800-53r5-high//import/include/call/@control-id]">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a href="#{@id}">
                                    <xsl:value-of select="prop[@name = 'label']"/>
                                </a>
                            </xsl:for-each>
                        </div>
                    </li>
                    <li>
                        <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-privacy//import/include/call/@control-id]),'#,##0')} novel controls selected in the SP 800-53B Privacy control baseline.</xsl:text>
                        <div>
                            <xsl:for-each select="$novel-controls[@id = $SP800-53r5-privacy//import/include/call/@control-id]">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a href="#{@id}">
                                    <xsl:value-of select="prop[@name = 'label']"/>
                                </a>
                            </xsl:for-each>
                        </div>
                    </li>
                    <li>
                        <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[not(@id = ($SP800-53r5-low//import/include/call/@control-id,$SP800-53r5-moderate//import/include/call/@control-id,$SP800-53r5-high//import/include/call/@control-id,$SP800-53r5-privacy//import/include/call/@control-id))]),'#,##0')} novel controls not selected in any SP 800-53B baseline.</xsl:text>
                        <div>
                            <xsl:for-each
                                select="$novel-controls[not(@id = ($SP800-53r5-low//import/include/call/@control-id, $SP800-53r5-moderate//import/include/call/@control-id, $SP800-53r5-high//import/include/call/@control-id, $SP800-53r5-privacy//import/include/call/@control-id))]">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a href="#{@id}">
                                    <xsl:value-of select="prop[@name = 'label']"/>
                                </a>
                            </xsl:for-each>
                        </div>
                    </li>
                </ul>
                <p>
                    <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control) - count($SP800-53r5//control[fn:withdrawn(.)]),'#,##0')} active (i.e., not withdrawn) controls (there were {format-integer(count($SP800-53r5//control[fn:withdrawn(.)]) - count($SP800-53r4//control[fn:withdrawn(.)]),'#,##0')} newly withdrawn, and {format-integer(count($SP800-53r4//control[fn:withdrawn(.)]),'#,##0')} previously withdrawn).</xsl:text>
                </p>
                <p>
                    <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//param),'#,##0')} organization-defined parameters (ODPs).</xsl:text>
                </p>
                <ul>
                    <li>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-low//import/include/call/@control-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Low security control baseline.</xsl:text>
                    </li>
                    <li>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-moderate//import/include/call/@control-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Moderate security control baseline.</xsl:text>
                    </li>
                    <li>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-high//import/include/call/@control-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B High security control baseline.</xsl:text>
                    </li>
                    <li>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-privacy//import/include/call/@control-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Privacy control baseline.</xsl:text>
                    </li>
                    <li>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[not(@id = ($SP800-53r5-low//import/include/call/@control-id,$SP800-53r5-moderate//import/include/call/@control-id,$SP800-53r5-high//import/include/call/@control-id,$SP800-53r5-privacy//import/include/call/@control-id))]/param),'#,##0')} ODPs which occur in controls not selected in any SP 800-53B baseline.</xsl:text>
                    </li>
                </ul>
                <p>Organization-defined parameter selections and assignments may (but need not necessarily) vary by impact when 800-53B baselines are
                    selected (<a href="#pl-10">PL-10</a>) and tailored (<a href="#pl-11">PL-11</a>).</p>
                <h2 id="details">SP 800-53r5 control details and comparison</h2>
                <p>The following shows SP 800-53r5 controls<xsl:if test="not($show-all-withdrawn)"> (except those withdrawn in both versions)</xsl:if>
                    and indicates (with Ⓛ, Ⓜ, Ⓗ, and Ⓟ) whether they appear in SP 800-53B Low, Moderate, High, or Privacy control baselines (or SP
                    800-53r4 Low, Moderate, or High control baselines).</p>
                <p>The corresponding SP 800-53r4 control, when present, appears just below each SP 800-53r5 control.</p>
                <p>Control statements with ODPs have them rendered as <span>[<span class="select">Selection: selection text</span>]</span> and
                            <span>[<span class="label">Assignment: assignment text</span>]</span>. Hovering over an ODP will display the ODP
                    identifier.</p>
                <p>SP 800-53r5 to SP 800-53r4 ODP mappings appear right-justified below the control statements. ODPs may be novel, a reasonably
                    assured match, or a qualified match.</p>
                <xsl:if test="$show-tailored-ODPs">
                    <p>When ODPs have been tailored in a baseline, they appear within a statement thus: <details class="ODPs"><summary>[<span
                                    class="label">ODP selection or assignment</span>]</summary>
                            <span>Ⓛ <i>tailored value</i></span><br/>
                            <span>Ⓜ <i>tailored value</i></span><br/>
                            <span>Ⓗ <i>tailored value</i></span><br/>
                            <span>Ⓟ <i>tailored value</i></span></details> — click to expose the values.</p>
                </xsl:if>
                <table>
                    <colgroup>
                        <col style="width: 1%;"/>
                        <col style="width: 3%;"/>
                        <col style="width: 4%;"/>
                        <col style="width: 50%;"/>
                        <col style="width: 35%;"/>
                    </colgroup>
                    <thead>
                        <tr>
                            <th>Rev</th>
                            <th>Control</th>
                            <th>Control<br/>Baselines</th>
                            <th>Statement</th>
                            <th>Guidance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="
                                $SP800-53r5//control">
                            <xsl:sort order="ascending" select="current()/prop[@name = sort-id]"/>
                            <xsl:variable name="r4" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                            <xsl:if test="
                                    ($show-all-withdrawn or not(fn:withdrawn(.) and fn:withdrawn($r4)))
                                    ">
                                <tr>
                                    <xsl:attribute name="id" select="@id"/>
                                    <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                        <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                    </xsl:if>
                                    <td rowspan="{if ($r4) then '2' else '1'}">
                                        <xsl:if test="$r4">
                                            <xsl:attribute name="class">multirow</xsl:attribute>
                                            <xsl:attribute name="rowspan">2</xsl:attribute>
                                        </xsl:if>
                                        <span class="revision">
                                            <xsl:text>⑤</xsl:text>
                                        </span>
                                        <xsl:if test="$r4">
                                            <span class="revision">
                                                <xsl:text>④</xsl:text>
                                            </span>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="$r4">
                                                <xsl:attribute name="class">multirow</xsl:attribute>
                                                <xsl:attribute name="rowspan">2</xsl:attribute>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:value-of select="prop[@name = 'label']"/>
                                    </td>
                                    <td>
                                        <xsl:if test="
                                                current()/@id = $SP800-53r5-low//import/include/call/@control-id
                                                or
                                                current()/@id = $SP800-53r5-moderate//import/include/call/@control-id
                                                or
                                                current()/@id = $SP800-53r5-high//import/include/call/@control-id
                                                or
                                                current()/@id = $SP800-53r5-privacy//import/include/call/@control-id
                                                ">
                                            <div>
                                                <xsl:if test="fn:withdrawn(.)">
                                                    <xsl:attribute name="class">anomaly</xsl:attribute>
                                                </xsl:if>
                                                <xsl:copy-of select="$r5-bullet"/>
                                                <span class="FIPS199categorization">
                                                    <xsl:if test="current()/@id = $SP800-53r5-low//import/include/call/@control-id">
                                                        <xsl:text>Ⓛ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include/call/@control-id">
                                                        <xsl:text> </xsl:text>
                                                        <xsl:text>Ⓜ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-high//import/include/call/@control-id">
                                                        <xsl:text> </xsl:text>
                                                        <xsl:text>Ⓗ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include/call/@control-id">
                                                        <xsl:text> </xsl:text>
                                                        <xsl:text>Ⓟ</xsl:text>
                                                    </xsl:if>
                                                </span>
                                            </div>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <div>
                                            <xsl:copy-of select="$r5-bullet"/>
                                            <span>
                                                <xsl:if test="fn:withdrawn(.)">
                                                    <xsl:attribute name="class">withdrawn</xsl:attribute>
                                                </xsl:if>
                                                <xsl:if test="parent::control">
                                                    <xsl:value-of select="parent::control/title"/>
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="title"/>
                                            </span>
                                            <xsl:choose>
                                                <xsl:when test="fn:withdrawn(.)">
                                                    <xsl:call-template name="withdrawn">
                                                        <xsl:with-param name="control" select="current()"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates mode="statement" select="part[@name = 'statement']"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </div>
                                        <xsl:if test="$compare-ODP and param">
                                            <div class="comparison">
                                                <xsl:variable name="r5-control" as="element()" select="current()"/>
                                                <xsl:variable name="r4-control" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                                                <xsl:if test="$r4-control/param and count(param) != count($r4-control/param)">
                                                    <xsl:text expand-text="true">There are {count(param)} {$r5-bullet} ODPs and {count($r4-control/param)} {$r4-bullet} ODPs</xsl:text>
                                                </xsl:if>
                                                <xsl:for-each select="param">
                                                    <xsl:variable name="text" as="xs:string" select="fn:param-text(.)"/>
                                                    <!--<xsl:message select="xs:string(@id), $text"/>-->
                                                    <div>
                                                        <xsl:choose>
                                                            <xsl:when test="not($r4)">
                                                                <span>
                                                                    <xsl:attribute name="class">novel</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text expand-text="true"> is a novel ODP (new in {$r5-bullet})</xsl:text>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when test="not($r4-control/param)">
                                                                <span>
                                                                    <xsl:attribute name="class">novel</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text expand-text="true"> is a novel ODP (no {$r4-bullet} ODPs)</xsl:text>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when test="$MAP54//*:param[@rev5-id = current()/@id]/@novel">
                                                                <span>
                                                                    <xsl:attribute name="class">novel</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text expand-text="true"> is a novel ODP (new in {$r5-bullet})</xsl:text>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when test="$MAP54//*:param[@rev5-id = current()/@id]/@partial">
                                                                <span>
                                                                    <xsl:attribute name="class">partialmatch</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text> partially matches </xsl:text>
                                                                    <xsl:value-of select="$r4-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="$MAP54//*:param[@rev5-id = current()/@id]/@rev4-id"/>
                                                                    </span>
                                                                    <xsl:text expand-text="true"> — {$MAP54//*:param[@rev5-id = current()/@id]/@partial}</xsl:text>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when test="$MAP54//*:param[@rev5-id = current()/@id]">
                                                                <span>
                                                                    <xsl:attribute name="class">match</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text> presumptively matches </xsl:text>
                                                                    <xsl:value-of select="$r4-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="$MAP54//*:param[@rev5-id = current()/@id]/@rev4-id"/>
                                                                    </span>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when test="not($r4-control/param[@id = current()/@id])">
                                                                <span>
                                                                    <xsl:attribute name="class">nomatch</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text> has no identical r4 counterpart</xsl:text>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="$r4-control/param[@id = current()/@id] and $r4-control/param[@id = current()/@id] = current()">
                                                                <span>
                                                                    <xsl:attribute name="class">match</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text> id+text matches </xsl:text>
                                                                    <xsl:value-of select="$r4-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="$r4-control/param[@id = current()/@id]/@id"/>
                                                                    </span>
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <span>
                                                                    <xsl:attribute name="class">nomatch</xsl:attribute>
                                                                    <xsl:value-of select="$r5-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="@id"/>
                                                                    </span>
                                                                    <xsl:text> text does not match </xsl:text>
                                                                    <xsl:value-of select="$r4-bullet"/>
                                                                    <span class="param_id">
                                                                        <xsl:value-of select="$r4-control/param[@id = current()/@id]/@id"/>
                                                                    </span>
                                                                    <!--<xsl:text> (</xsl:text>
                                                                    <xsl:text>«</xsl:text>
                                                                    <xsl:value-of select="."/>
                                                                    <xsl:text>»</xsl:text>
                                                                    <xsl:text> != </xsl:text><xsl:text>«</xsl:text>
                                                                    <xsl:value-of select="$r4-control/param[@id = current()/@id]"/><xsl:text>»</xsl:text>
                                                                    <xsl:text>)</xsl:text>-->
                                                                </span>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="fn:withdrawn(.)">
                                                <xsl:call-template name="withdrawn">
                                                    <xsl:with-param name="bullet" select="$r5-bullet"/>
                                                    <xsl:with-param name="control" select="current()"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:copy-of select="$r5-bullet"/>
                                                <xsl:value-of select="part[@name = 'guidance']"/>
                                                <xsl:if test="link[@rel = 'related']">
                                                    <div>
                                                        <xsl:text>Related controls: </xsl:text>
                                                        <xsl:for-each select="link[@rel = 'related']">
                                                            <xsl:if test="position() != 1">
                                                                <xsl:text>, </xsl:text>
                                                            </xsl:if>
                                                            <a href="{@href}">
                                                                <xsl:value-of select="upper-case(substring-after(@href, '#'))"/>
                                                            </a>
                                                        </xsl:for-each>
                                                    </div>
                                                </xsl:if>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <xsl:if test="$r4">
                                    <tr>
                                        <xsl:variable name="id" as="xs:string" select="current()/@id"/>
                                        <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                            <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                        </xsl:if>
                                        <!--<xsl:if test="$CC//control[@id = $id][@type = 'none']" xpath-default-namespace="">
                                            <xsl:attribute name="class">novel</xsl:attribute>
                                        </xsl:if>-->
                                        <td>
                                            <xsl:if test="
                                                    current()/@id = $SP800-53r4-low//import/include/call/@control-id
                                                    or
                                                    current()/@id = $SP800-53r4-moderate//import/include/call/@control-id
                                                    or
                                                    current()/@id = $SP800-53r4-high//import/include/call/@control-id
                                                    ">
                                                <div>
                                                    <xsl:if test="$r4 and fn:withdrawn($r4)">
                                                        <xsl:attribute name="class">anomaly</xsl:attribute>
                                                    </xsl:if>
                                                    <xsl:copy-of select="$r4-bullet"/>
                                                    <span class="FIPS199categorization">
                                                        <xsl:if test="current()/@id = $SP800-53r4-low//import/include/call/@control-id">
                                                            <xsl:text>Ⓛ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="current()/@id = $SP800-53r4-moderate//import/include/call/@control-id">
                                                            <xsl:text> </xsl:text>
                                                            <xsl:text>Ⓜ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="current()/@id = $SP800-53r4-high//import/include/call/@control-id">
                                                            <xsl:text> </xsl:text>
                                                            <xsl:text>Ⓗ</xsl:text>
                                                        </xsl:if>
                                                    </span>
                                                </div>
                                            </xsl:if>
                                        </td>
                                        <td>
                                            <div>
                                                <xsl:copy-of select="$r4-bullet"/>
                                                <xsl:if test="$r4/parent::control">
                                                    <xsl:value-of select="$r4/parent::control/title"/>
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="$r4/title"/>
                                                <xsl:choose>
                                                    <xsl:when test="fn:withdrawn($r4)">
                                                        <xsl:call-template name="withdrawn">
                                                            <xsl:with-param name="control" select="$r4"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:apply-templates mode="statement" select="$r4/part[@name = 'statement']"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                        </td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="fn:withdrawn($r4)">
                                                    <xsl:call-template name="withdrawn">
                                                        <xsl:with-param name="bullet" select="$r4-bullet"/>
                                                        <xsl:with-param name="control" select="$r4"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="$r4/part[@name = 'guidance']/p">
                                                    <xsl:copy-of select="$r4-bullet"/>
                                                    <xsl:value-of select="$r4/part[@name = 'guidance']/p"/>
                                                    <xsl:if test="link[@rel = 'related']">
                                                        <div>
                                                            <xsl:text>Related controls: </xsl:text>
                                                            <xsl:for-each select="link[@rel = 'related']">
                                                                <xsl:if test="position() != 1">
                                                                    <xsl:text>, </xsl:text>
                                                                </xsl:if>
                                                                <span>
                                                                    <xsl:value-of select="upper-case(substring-after(@href, '#'))"/>
                                                                </span>
                                                            </xsl:for-each>
                                                        </div>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="$r4-bullet"/>
                                                    <xsl:text>(No guidance)</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                    </tbody>
                </table>
                <h2 id="extras">Extras</h2>
                <p>The following table shows all SP 800-53r5 controls which are selected by one or more SP 800-53B baselines.</p>
                <table>
                    <caption>SP 800-53r5 controls which are selected in SP 800-53B baselines</caption>
                    <thead>
                        <tr>
                            <th><xsl:attribute name="class">center</xsl:attribute>Control</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>Title</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>Baselines</th>
                            <th><xsl:attribute name="class">center</xsl:attribute>ODPs</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="$baselined-controls">
                            <tr>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']"/>
                                    </a>
                                </td>
                                <td>
                                    <xsl:value-of select="ancestor::group/title"/>
                                    <xsl:text> | </xsl:text>
                                    <xsl:if test="parent::control">
                                        <xsl:value-of select="parent::control/title"/>
                                        <xsl:text> | </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="title"/>
                                </td>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <xsl:if test="
                                            current()/@id = $SP800-53r5-low//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-moderate//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-high//import/include/call/@control-id
                                            or
                                            current()/@id = $SP800-53r5-privacy//import/include/call/@control-id
                                            ">
                                        <div>
                                            <span class="FIPS199categorization">
                                                <xsl:if test="current()/@id = $SP800-53r5-low//import/include/call/@control-id">
                                                    <xsl:text>Ⓛ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓜ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-high//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓗ</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include/call/@control-id">
                                                    <xsl:text> </xsl:text>
                                                    <xsl:text>Ⓟ</xsl:text>
                                                </xsl:if>
                                            </span>
                                        </div>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:attribute name="class">center</xsl:attribute>
                                    <xsl:if test="param">
                                        <xsl:value-of select="count(param)"/>
                                    </xsl:if>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="withdrawn">
        <xsl:param name="control"/>
        <xsl:param name="bullet" as="xs:string*" required="false"/>
        <div class="statement">
            <xsl:copy-of select="$bullet"/>
            <xsl:for-each select="link">
                <xsl:if test="position() = 1">
                    <xsl:text expand-text="true">Withdrawn — {translate(@rel, '-', ' ')} </xsl:text>
                </xsl:if>
                <xsl:if test="position() != 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:if test="position() = last() and last() != 1">
                    <xsl:text> and </xsl:text>
                </xsl:if>
                <a href="{@href}">
                    <xsl:value-of select="upper-case(substring-after(@href, '#'))"/>
                </a>
            </xsl:for-each>
            <xsl:text>.</xsl:text>
        </div>
    </xsl:template>
    <xsl:template mode="statement" match="part[@name = 'statement']">
        <xsl:param name="rev" as="xs:string*" required="false"/>
        <xsl:variable name="content" as="node()*">
            <div class="statement">
                <xsl:attribute name="id" select="@id"/>
                <xsl:value-of select="$rev"/>
                <xsl:apply-templates mode="statement" select="node()"/>
            </div>
        </xsl:variable>
        <xsl:copy-of select="$content"/>
    </xsl:template>
    <xsl:template mode="statement" match="part[@name = 'item']">
        <div class="item">
            <xsl:attribute name="id" select="@id"/>
            <xsl:variable name="content" as="node()*">
                <xsl:apply-templates mode="statement" select="node()"/>
            </xsl:variable>
            <xsl:copy-of select="$content"/>
        </div>
    </xsl:template>
    <xsl:template mode="statement" match="p">
        <xsl:apply-templates mode="statement" select="node()"/>
    </xsl:template>
    <xsl:template mode="statement" match="em">
        <!-- em is misused, so ignore it (most cases should be a cite, not em) -->
        <xsl:apply-templates mode="statement" select="node()"/>
    </xsl:template>
    <xsl:template mode="statement" match="strong | ol | li | b">
        <xsl:element name="{local-name()}">
            <xsl:attribute name="class">semantic-error</xsl:attribute>
            <xsl:apply-templates mode="statement" select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template mode="statement" match="a">
        <a href="{@href}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    <xsl:template mode="statement" match="prop">
        <xsl:text expand-text="true">{.} </xsl:text>
    </xsl:template>
    <xsl:template mode="statement" match="insert">
        <span>
            <xsl:attribute name="title" select="@param-id"/>
            <xsl:attribute name="class">insert</xsl:attribute>
            <!--<span class="super-prm-id">
                <xsl:value-of select="@param-id"/>
            </span>-->
            <xsl:variable name="insert" as="node()*">
                <xsl:apply-templates mode="statement" select="ancestor::control/param[@id = current()/@param-id]"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 4')">
                    <!-- show r4 ODPs -->
                    <xsl:message select="$insert"/>
                    <xsl:choose>
                        <xsl:when test="$show-tailored-ODPs">
                            <details class="ODPs">
                                <summary>
                                    <xsl:copy-of select="$insert"/>
                                </summary>
                                <xsl:variable name="ODPs" as="xs:string*">
                                    <xsl:choose>
                                        <xsl:when test="$ODP-low//set-parameter[@param-id = current()/@param-id]">
                                            <xsl:text expand-text="true">Ⓛ: {$ODP-low//set-parameter[@param-id = current()/@param-id]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text expand-text="true">Ⓛ: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$ODP-moderate//set-parameter[@param-id = current()/@param-id]">
                                            <xsl:text expand-text="true">Ⓜ: {$ODP-moderate//set-parameter[@param-id = current()/@param-id]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text expand-text="true">Ⓜ: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$ODP-high//set-parameter[@param-id = current()/@param-id]">
                                            <xsl:text expand-text="true">Ⓗ: {$ODP-high//set-parameter[@param-id = current()/@param-id]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text expand-text="true">Ⓗ: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:for-each select="$ODPs">
                                    <xsl:if test="position() != 1">
                                        <br/>
                                    </xsl:if>
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                            </details>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$insert"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$insert"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    <xsl:template mode="statement" match="param">
        <xsl:apply-templates mode="statement"/>
    </xsl:template>
    <xsl:template mode="statement" match="label">
        <xsl:text>[</xsl:text>
        <span class="label">
            <xsl:text>Assignment: </xsl:text>
            <xsl:value-of select="."/>
        </span>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template mode="statement" match="select">
        <xsl:variable name="choices" as="node()*">
            <xsl:for-each select="choice">
                <xsl:choose>
                    <xsl:when test="*">
                        <xsl:variable name="substrings" as="node()*">
                            <xsl:apply-templates mode="statement" select="node()"/>
                        </xsl:variable>
                        <xsl:copy-of select="$substrings"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>[</xsl:text>
        <span class="select">
            <xsl:choose>
                <xsl:when test="@how-many = 'one or more'">
                    <xsl:text>Selection (one or more): </xsl:text>
                    <xsl:for-each select="$choices">
                        <xsl:if test="position() != 1">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Selection: </xsl:text>
                    <xsl:for-each select="$choices">
                        <xsl:if test="position() != 1">
                            <span class="boolean"> or </span>
                        </xsl:if>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template mode="statement" match="text()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template mode="statement" match="node()" priority="-9">
        <xsl:message terminate="yes" expand-text="true">control: {ancestor::control/@id} id: {@id} name: {name()}</xsl:message>
    </xsl:template>
    <xsl:template match="node()" priority="-1">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
