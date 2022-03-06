<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs oscal fn"
    version="3.0" xmlns:fn="local function" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0">
    <xsl:param name="show-all-withdrawn" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="show-ODP-id" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="compare-ODP" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="show-guidance" as="xs:boolean" required="false" select="false()"/>
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
    <xsl:output method="html" version="5.0" include-content-type="false"/>
    <xsl:output indent="false"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="r4-bullet" as="xs:string">④</xsl:variable>
    <xsl:variable name="r5-bullet" as="xs:string">⑤</xsl:variable>
    <xsl:function name="fn:withdrawn" as="xs:boolean">
        <xsl:param name="control" as="element()" required="true"/>
        <xsl:sequence select="$control/prop[@name = 'status']/@value = ('Withdrawn', 'withdrawn')"/>
    </xsl:function>
    <xsl:function name="fn:parameter-text" as="xs:string">
        <xsl:param name="parameter" as="element()" required="true"/>
        <xsl:value-of select="$parameter"/>
    </xsl:function>
    <xsl:function name="fn:control-title" as="xs:string">
        <xsl:param name="control" as="element()" required="true"/>
        <xsl:variable name="control-title" as="xs:string*">
            <xsl:if test="$control/parent::control">
                <xsl:value-of select="$control/parent::control/title"/>
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:value-of select="$control/title"/>
        </xsl:variable>
        <xsl:value-of select="string-join($control-title)"/>
    </xsl:function>
    <xsl:function name="fn:compare-controls-side-by-side" as="node()*">
        <xsl:param name="control-id" as="xs:string" required="true"/>
        <xsl:variable name="cr5" as="element()" select="$SP800-53r5//control[@id = $control-id]"/>
        <xsl:variable name="cr4" as="element()" select="$SP800-53r4//control[@id = $control-id]"/>
        <table>
            <caption>
                <xsl:text>Comparison of control </xsl:text>
                <a href="#{$cr5/@id}">
                    <xsl:value-of select="$cr5/prop[@name = 'label']/@value"/>
                </a>
            </caption>
            <colgroup>
                <col style="width: 50%;"/>
                <col style="width: 50%;"/>
            </colgroup>
            <thead>
                <tr>
                    <th style="text-align:center;">SP 800-53r5</th>
                    <th style="text-align:center;">SP 800-53r4</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <div>
                            <xsl:value-of select="fn:control-title($cr5)"/>
                        </div>
                        <div>
                            <xsl:apply-templates mode="statement" select="$cr5/part[@name = 'statement']">
                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                            </xsl:apply-templates>
                        </div>
                    </td>
                    <td>
                        <div>
                            <xsl:value-of select="fn:control-title($cr4)"/>
                        </div>
                        <div>
                            <xsl:apply-templates mode="statement" select="$cr4/part[@name = 'statement']">
                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                            </xsl:apply-templates>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:function>
    <xsl:function name="fn:novel-ODP" as="xs:boolean">
        <xsl:param name="param-id" as="xs:string" required="true"/>
        <xsl:sequence select="xs:boolean($param-id = $MAP54//*:param-map[@novel]/@rev5-id)"/>
    </xsl:function>
    <xsl:variable name="UTC" as="xs:duration" select="xs:dayTimeDuration('PT0H')"/>
    <xsl:variable name="UTC-date" select="adjust-date-to-timezone(current-date(), $UTC)"/>
    <xsl:variable name="UTC-datetime" select="adjust-dateTime-to-timezone(current-dateTime(), $UTC)"/>
    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'"/>
    <xsl:variable name="ODP-low" as="document-node()" select="doc(/revs/odv/ODP-low)"/>
    <xsl:variable name="ODP-moderate" as="document-node()" select="doc(/revs/odv/ODP-moderate)"/>
    <xsl:variable name="ODP-high" as="document-node()" select="doc(/revs/odv/ODP-high)"/>
    <!--<xsl:variable name="CC" as="document-node()" select="doc('cc.xml')"/>-->
    <xsl:variable name="MAP54" as="document-node()" select="doc('odp-mapping.xml')"/>
    <xsl:variable name="document-title" as="xs:string">NIST SP 800-53r5 Analysis</xsl:variable>
    <xsl:template name="inter-section">
        <hr/>
        <nav>
            <a href="#top">Top</a> — <a href="#numbers">Controls and ODPs</a> — <a href="#details">Control Details</a> — <a href="#inputs">OSCAL
                Inputs</a> — <a href="#extras">Extras</a>
        </nav>
        <hr/>
    </xsl:template>
    <xsl:template name="odp-mapping">
        <xsl:result-document href="odp-mapping.xml" indent="1">
            <xsl:element name="params">
                <xsl:for-each select="$SP800-53r5//control">
                    <xsl:sort order="ascending" select="current()/prop[@name = sort-id]/@value"/>
                    <xsl:variable name="r4" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                    <xsl:for-each select="current()/param">
                        <xsl:choose>
                            <xsl:when test="not($r4)">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="novel" select="true()"/>
                                    <xsl:comment> no r4 </xsl:comment>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="not($r4/param)">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="novel" select="true()"/>
                                    <xsl:comment> no r4 params</xsl:comment>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@novel">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="novel" select="true()"/>
                                    <xsl:comment> previously asserted </xsl:comment>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="rev4-id" select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                    <xsl:attribute name="partial" select="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial"/>
                                    <xsl:comment> previously asserted partial </xsl:comment>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="rev4-id" select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                    <xsl:comment> previously asserted match??? </xsl:comment>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$r4/param[@id = current()/@id] and $r4/param[@id = current()/@id] = current()">
                                <xsl:element name="param-map">
                                    <xsl:attribute name="rev5-id" select="@id"/>
                                    <xsl:attribute name="rev4-id" select="$r4/param[@id = current()/@id]/@id"/>
                                    <xsl:comment> previously asserted id+text match </xsl:comment>
                                </xsl:element>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    <xsl:template match="/">
        <!--<xsl:call-template name="odp-mapping"/>-->
        <xsl:variable name="controls" as="element()*" select="$SP800-53r5//control"/>
        <xsl:variable name="baselined-controls" as="element()*"
            select="$controls[@id = ($SP800-53r5-low//import/include-controls/with-id, $SP800-53r5-moderate//import/include-controls/with-id, $SP800-53r5-high//import/include-controls/with-id, $SP800-53r5-privacy//import/include-controls/with-id)]"/>
        <xsl:variable name="novel-controls" as="element()*" select="$controls[not(@id = $SP800-53r4//control/@id)]"/>
        <xsl:variable name="novel-and-baselined-controls" as="element()*"
            select="$novel-controls[@id = ($SP800-53r5-low//import/include-controls/with-id, $SP800-53r5-moderate//import/include-controls/with-id, $SP800-53r5-high//import/include-controls/with-id, $SP800-53r5-privacy//import/include-controls/with-id)]"/>
        <xsl:variable name="novel-ODP-ids" as="xs:string*" select="$MAP54//*:param-map[@novel]/@rev5-id"/>
        <!--<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>-->
        <html lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>
                    <xsl:value-of select="$document-title"/>
                </title>
                <xsl:variable name="css" select="unparsed-text(replace(static-base-uri(), '\.xsl$', '.css'))"/>
                <style><xsl:value-of disable-output-escaping="true" select="replace($css, '\s+', ' ')"/></style>
            </head>
            <body>
                <div>
                    <h1 id="top">
                        <xsl:value-of select="$document-title"/>
                    </h1>
                    <p>
                        <xsl:text expand-text="true">Last updated { format-dateTime(current-dateTime(), '[MNn] [D] [Y] [H01]:[m01] [ZN,*-3]') }.</xsl:text>
                    </p>
                    <xsl:variable name="href" as="xs:string" expand-text="true"
                        >mailto:gary@garygapinski.com?subject={encode-for-uri($document-title)}%20({format-dateTime($UTC-datetime,'v[Y][M01][D01]T[H01][m01][s01]Z')})</xsl:variable>
                    <p>The <a target="_blank" title="Gary Gapinski" href="{$href}">author</a> welcomes comments and suggestions regarding document
                        content and format.</p>
                    <!--<p>This document was crafted using Chromium-derived browsers for presentation checks. YMMV with other browsers not derived from
                        Chromium.</p>-->
                </div>
                <xsl:call-template name="inter-section"/>
                <!-- Introduction -->
                <div>
                    <h2 id="introduction">Introduction</h2>
                    <p>This document is an analysis of National Institue of Standards and Technology (<dfn>NIST</dfn>) Special Publication 800-53
                        Revision 5 (SP 800-53r5) <cite><a target="_blank" href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final"
                                >Security and Privacy Controls for Information Systems and Organizations</a></cite> comparing it with the now
                        superseded <a target="_blank" href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final">Special Publication
                            800-53 Revision 4</a> (SP 800-53r4).</p>
                    <p>The term "control" as used in this document refers to both (in SP 800-53 parlance) controls and control enhancements.</p>
                    <p>NIST introduced a separate document Special Publication 800-53B (SP 800-53B) <cite><a target="_blank"
                                href="https://csrc.nist.gov/publications/detail/sp/800-53b/final">Control Baselines for Information Systems and
                                Organizations</a></cite> which specifies baselines to be used in conjunction with SP 800-53r5 controls. Control
                        baselines had previously appeared in SP 800-53r4 appendix D.</p>
                    <p>NIST published SP 800-53r5 in September, 2020 and updated it with a large number of errata in December, 2020.</p>
                    <p>This document would not have been possible without <a href="#inputs">structured information</a> made available by NIST in OSCAL
                        format. See <cite><a target="_blank" href="https://pages.nist.gov/OSCAL/">OSCAL: the Open Security Controls Assessment
                                Language</a></cite> for information about OSCAL.</p>
                    <div>
                        <h3>SP 800-53r5 Adoption</h3>
                        <p>The deadline for complete SP 800-53r5 adoption by US Federal Government agencies was September 23, 2021 — one year after its
                            publication.</p>
                        <p>Office of Management and Budget Circular A-130 <cite><a target="_blank"
                                    href="https://www.whitehouse.gov/sites/whitehouse.gov/files/omb/circulars/A130/a130revised.pdf">Managing
                                    Information as a Strategic Resource</a></cite>, July 2016 Appendix I §5 part a "NIST Standards and Guidelines" ¶3
                            (page I-16, PDF page 53) specifies</p>
                        <blockquote>For legacy information systems, agencies are expected to meet the requirements of, and be in compliance with, NIST
                            standards and guidelines within one year of their respective publication dates unless otherwise directed by OMB. The
                            one-year compliance date for revisions to NIST publications applies only to new or updated material in the publications.
                            For information systems under development or for legacy systems undergoing significant changes, agencies are expected to
                            meet the requirements of, and be in compliance with, NIST standards and guidelines immediately upon deployment of the
                            systems.</blockquote>
                        <p>In other words, adoption should be immediate or no later than one year after publication. OMB A-130 has, by the way, an
                            impressive number of requirements (NIST Special Publication adoption amongst them).</p>
                    </div>
                    <div>
                        <h3>SP 800-53r5 Adoption Tasks</h3>
                        <ul>
                            <li>Tailor novel and altered controls and update related baselines/templates/overlays.</li>
                            <li>Tailor novel and altered organization-defined parameters (ODPs) and update related baselines/templates/overlays.</li>
                            <li>Update individual system security plans accordingly.</li>
                            <li>Re-assess system security plans using (the as yet unpublished) SP 800-53A revision 5.</li>
                        </ul>
                    </div>
                    <div>
                        <h3>General Changes in SP 800-53r5</h3>
                        <div>
                            <p>Large numbers of <a href="#novel-controls">controls</a> and <a href="#novel-ODPs">ODPs</a> were introduced, and
                                pre-existing controls were augmented with novel ODPs.
                                <xsl:text expand-text="true">The PT ({count($SP800-53r5//group[@id='pt']//control)} controls) and SR ({count($SP800-53r5//group[@id='sr']//control)} controls) families are entirely new.</xsl:text></p>
                            <p>Virtually all pre-existing controls had syntactic changes and many had substantial semantic changes which will require
                                manual review in order to assess the consequences of the changes.</p>
                        </div>
                        <div>
                            <h4>Imperative mood</h4>
                            <p>Control statement grammar was changed from indicative to imperative mood. In many cases the occasion of this mood
                                change was accompanied by additional changes to clarify, refine, and augment control statements. For example, </p>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('ir-4')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('ca-2')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('at-3')"/>
                            </div>
                        </div>
                        <div>
                            <h4>The term "information system" is now shunned in control statements</h4>
                            <p>The term "information system" previously found in <xsl:value-of
                                    select="count($SP800-53r4//control[part[@name = 'statement']/p[matches(., 'information system', 'i')]])"/> control
                                statements was changed to just "system" or was disappeared entirely. For example,</p>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('cm-4')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('au-7')"/>
                            </div>
                        </div>
                        <div>
                            <h4>Commingled privacy considerations</h4>
                            <p>Privacy considerations were commingled in <xsl:value-of
                                    select="count($SP800-53r5//control[matches(part[@name = 'statement'], 'privacy', 'i')])"/> controls. For
                                example,</p>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('pl-2')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('ac-4.1')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('cm-3.4')"/>
                            </div>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('sa-8')"/>
                            </div>
                        </div>
                        <div>
                            <h4>Altered policy and procedure controls</h4>
                            <p>All <xsl:value-of select="count($SP800-53r5//control[matches(@id, '-1$')])"/> of the XX-1 "Policy and Procedures"
                                controls were re-worked with 4 additional ODPs each. For example,</p>
                            <div class="comparison-example">
                                <xsl:copy-of select="fn:compare-controls-side-by-side('si-1')"/>
                            </div>
                        </div>
                    </div>
                </div>
                <xsl:call-template name="inter-section"/>
                <!-- Controls and ODPs -->
                <div>
                    <h2 id="numbers">SP 800-53r5 Controls and ODPs</h2>
                    <h3>All controls</h3>
                    <p>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control) - count($SP800-53r5//control[fn:withdrawn(.)]),'#,##0')} active (i.e., not withdrawn) controls (there were {format-integer(count($SP800-53r5//control[fn:withdrawn(.)]) - count($SP800-53r4//control[fn:withdrawn(.)]),'#,##0')} newly withdrawn in SP 800-53r5, and {format-integer(count($SP800-53r4//control[fn:withdrawn(.)]),'#,##0')} previously withdrawn in earlier versions).</xsl:text>
                    </p>
                    <p>
                        <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//param),'#,##0')} organization-defined parameters (ODPs).</xsl:text>
                    </p>
                    <ul>
                        <li>
                            <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-low//import/include-controls/with-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Low security control baseline.</xsl:text>
                        </li>
                        <li>
                            <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-moderate//import/include-controls/with-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Moderate security control baseline.</xsl:text>
                        </li>
                        <li>
                            <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-high//import/include-controls/with-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B High security control baseline.</xsl:text>
                        </li>
                        <li>
                            <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[@id = $SP800-53r5-privacy//import/include-controls/with-id]/param),'#,##0')} ODPs cited in controls selected in the SP 800-53B Privacy control baseline.</xsl:text>
                        </li>
                        <li>
                            <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control[not(@id = ($SP800-53r5-low//import/include-controls/with-id,$SP800-53r5-moderate//import/include-controls/with-id,$SP800-53r5-high//import/include-controls/with-id,$SP800-53r5-privacy//import/include-controls/with-id))]/param),'#,##0')} ODPs which occur in controls not selected in any SP 800-53B baseline.</xsl:text>
                        </li>
                    </ul>
                    <div>
                        <h3>Controls which are selected in baselines</h3>
                        <p>Controls which are selected in baselines are destined to be employed and thus any related ODPs are destined to be
                            tailored.</p>
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
                        <ul>
                            <li>
                                <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-low//import/include-controls/with-id]),'#,##0')} novel controls selected in the SP 800-53B Low security control baseline.</xsl:text>
                                <!--<div>
                                <xsl:for-each select="$novel-controls[@id = $SP800-53r5-low//import/include-controls/with-id]">
                                    <xsl:if test="position() != 1">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']/@value"/>
                                    </a>
                                </xsl:for-each>
                            </div>-->
                            </li>
                            <li>
                                <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-moderate//import/include-controls/with-id]),'#,##0')} novel controls selected in the SP 800-53B Moderate security control baseline.</xsl:text>
                                <!--<div>
                                <xsl:for-each select="$novel-controls[@id = $SP800-53r5-moderate//import/include-controls/with-id]">
                                    <xsl:if test="position() != 1">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']/@value"/>
                                    </a>
                                </xsl:for-each>
                            </div>-->
                            </li>
                            <li>
                                <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-high//import/include-controls/with-id]),'#,##0')} novel controls selected in the SP 800-53B High security control baseline.</xsl:text>
                                <!--<div>
                                <xsl:for-each select="$novel-controls[@id = $SP800-53r5-high//import/include-controls/with-id]">
                                    <xsl:if test="position() != 1">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']/@value"/>
                                    </a>
                                </xsl:for-each>
                            </div>-->
                            </li>
                            <li>
                                <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[@id = $SP800-53r5-privacy//import/include-controls/with-id]),'#,##0')} novel controls selected in the SP 800-53B Privacy control baseline.</xsl:text>
                                <!--<div>
                                <xsl:for-each select="$novel-controls[@id = $SP800-53r5-privacy//import/include-controls/with-id]">
                                    <xsl:if test="position() != 1">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']/@value"/>
                                    </a>
                                </xsl:for-each>
                            </div>-->
                            </li>
                            <li>
                                <xsl:text expand-text="true">SP 800-53r5 has {format-integer(count($novel-controls[not(@id = ($SP800-53r5-low//import/include-controls/with-id,$SP800-53r5-moderate//import/include-controls/with-id,$SP800-53r5-high//import/include-controls/with-id,$SP800-53r5-privacy//import/include-controls/with-id))]),'#,##0')} novel controls not selected in any SP 800-53B baseline.</xsl:text>
                                <!--<div>
                                <xsl:for-each
                                    select="$novel-controls[not(@id = ($SP800-53r5-low//import/include-controls/with-id, $SP800-53r5-moderate//import/include-controls/with-id, $SP800-53r5-high//import/include-controls/with-id, $SP800-53r5-privacy//import/include-controls/with-id))]">
                                    <xsl:if test="position() != 1">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <a href="#{@id}">
                                        <xsl:value-of select="prop[@name = 'label']/@value"/>
                                    </a>
                                </xsl:for-each>
                            </div>-->
                            </li>
                        </ul>
                        <p>Organization-defined parameter selections and assignments may (but need not necessarily) vary by impact when 800-53B
                            baselines are selected (<a href="#pl-10">PL-10</a>) and tailored (<a href="#pl-11">PL-11</a>).</p>
                    </div>
                    <div id="novel-controls">
                        <h3>Novel (baselined) controls in SP 800-53r5</h3>
                        <p>The following shows the <xsl:value-of select="format-integer(count($novel-and-baselined-controls), '#,##0')"/> novel SP
                            800-53r5 controls which appear in SP 800-53B Low, Moderate, High, or Privacy control baselines.</p>
                        <p>These are just controls that appear in baselines; there are <xsl:value-of
                                select="format-integer(count($novel-controls except $novel-and-baselined-controls), '#,##0')"/> other novel
                            controls.</p>
                        <table>
                            <caption>Novel SP 800-53r5 controls which are selected in SP 800-53B baselines</caption>
                            <thead>
                                <tr>
                                    <th><xsl:attribute name="class">center</xsl:attribute>Control</th>
                                    <th><xsl:attribute name="class">center</xsl:attribute>Title</th>
                                    <th><xsl:attribute name="class">center</xsl:attribute>ODPs</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="$novel-and-baselined-controls">
                                    <tr>
                                        <td>
                                            <xsl:attribute name="class">center</xsl:attribute>
                                            <a href="#{@id}">
                                                <xsl:value-of select="prop[@name = 'label']/@value"/>
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
                                            <xsl:if test="
                                                    current()/@id = $SP800-53r5-low//import/include-controls/with-id
                                                    or
                                                    current()/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                    or
                                                    current()/@id = $SP800-53r5-high//import/include-controls/with-id
                                                    or
                                                    current()/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                    ">
                                                <span class="LMHP fr">
                                                    <xsl:variable name="categorization" as="xs:string*">
                                                        <xsl:if test="current()/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                            <xsl:text>Ⓛ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                            <xsl:text>Ⓜ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="current()/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                            <xsl:text>Ⓗ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include-controls/with-id">
                                                            <xsl:text>Ⓟ</xsl:text>
                                                        </xsl:if>
                                                    </xsl:variable>
                                                    <xsl:value-of select="string-join($categorization, ' ')"/>
                                                </span>
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
                    </div>
                </div>
                <div id="novel-ODPs">
                    <h3>Novel (baselined) ODPs in SP 800-53r5</h3>
                    <p>Novel ODPs occur in previously existing controls as well as controls novel to SP 800-53r5 (indicated by <xsl:value-of
                            select="$r5-bullet"/>).</p>
                    <p>There are <xsl:value-of select="count($MAP54//*:param-map[@novel])"/> novel ODPs in SP 800-53r5 (relative to SP 800-53r4).
                            <xsl:value-of select="count($baselined-controls/param[@id = $novel-ODP-ids])"/> of those novel ODPs appear in baselined
                        controls.</p>
                    <table>
                        <colgroup>
                            <col style="width: 4%;"/>
                            <col style="width: 25%;"/>
                            <col style="width: 6%;"/>
                            <col style="width: 50%;"/>
                        </colgroup>
                        <thead>
                            <tr>
                                <th><xsl:attribute name="class">center</xsl:attribute>Control</th>
                                <th>Title</th>
                                <th><xsl:attribute name="class">center</xsl:attribute>ODP</th>
                                <th>Context</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="$baselined-controls[param/@id = $novel-ODP-ids]">
                                <xsl:variable name="control" as="element()" select="current()"/>
                                <xsl:for-each select="param[@id = $novel-ODP-ids]">
                                    <tr>
                                        <xsl:choose>
                                            <xsl:when test="position() = 1">
                                                <xsl:variable name="rows" as="xs:integer"
                                                    select="1 + count(following-sibling::param[@id = $novel-ODP-ids])"/>
                                                <td rowspan="{$rows}">
                                                    <xsl:attribute name="class">center</xsl:attribute>
                                                    <xsl:if test="$control/@id = $novel-controls/@id">
                                                        <xsl:value-of select="$r5-bullet"/>
                                                        <xsl:text> </xsl:text>
                                                    </xsl:if>
                                                    <a href="#{$control/@id}">
                                                        <xsl:value-of select="$control/prop[@name = 'label']/@value"/>
                                                    </a>
                                                </td>
                                                <td rowspan="{$rows}">
                                                    <xsl:if test="$control/parent::control">
                                                        <xsl:value-of select="$control/parent::control/title"/>
                                                        <xsl:text> | </xsl:text>
                                                    </xsl:if>
                                                    <xsl:value-of select="$control/title"/>
                                                    <xsl:if test="
                                                            $control/@id = $SP800-53r5-low//import/include-controls/with-id
                                                            or
                                                            $control/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                            or
                                                            $control/@id = $SP800-53r5-high//import/include-controls/with-id
                                                            or
                                                            $control/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                            ">
                                                        <span class="LMHP fr">
                                                            <xsl:variable name="categorization" as="xs:string*">
                                                                <xsl:if test="$control/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                                    <xsl:text>Ⓛ</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="$control/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                                    <xsl:text>Ⓜ</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="$control/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                                    <xsl:text>Ⓗ</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="$control/@id = $SP800-53r5-privacy//import/include-controls/with-id">
                                                                    <xsl:text>Ⓟ</xsl:text>
                                                                </xsl:if>
                                                            </xsl:variable>
                                                            <xsl:value-of select="string-join($categorization, ' ')"/>
                                                        </span>
                                                    </xsl:if>
                                                </td>
                                                <td>
                                                    <xsl:attribute name="class">center</xsl:attribute>
                                                    <xsl:value-of select="@id"/>
                                                </td>
                                                <td>
                                                    <xsl:choose>
                                                        <xsl:when test="$control//p[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                            <xsl:apply-templates mode="statement"
                                                                select="$control//p[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:when
                                                            test="$control//select[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                            <xsl:apply-templates mode="statement"
                                                                select="$control//select[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>FIXME</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <td>
                                                    <xsl:attribute name="class">center</xsl:attribute>
                                                    <xsl:value-of select="@id"/>
                                                </td>
                                                <td>
                                                    <xsl:choose>
                                                        <xsl:when test="$control//p[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                            <xsl:apply-templates mode="statement"
                                                                select="$control//p[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:when
                                                            test="$control//select[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                            <xsl:apply-templates mode="statement"
                                                                select="$control//select[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>FIXME</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </tr>
                                </xsl:for-each>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
                <div>
                    <h3>modified ODPs in SP 800-53r5</h3>
                    <xsl:variable name="modified-ODP-ids" as="xs:string*" select="$MAP54//*:param-map[@partial]/@rev5-id"/>
                    <p>Modified ODPs occur in previously existing controls as well as controls novel to SP 800-53r5 (indicated by <xsl:value-of
                            select="$r5-bullet"/>).</p>
                    <p>There are <xsl:value-of select="count($MAP54//*:param-map[@partial])"/> modified ODPs in SP 800-53r5 (relative to SP
                        800-53r4).</p>
                    <p>Modified ODPs should have previously tailored values reviewed and updated where necessary.</p>
                    <table>
                        <colgroup>
                            <col style="width: 6%;"/>
                            <col style="width: 6%;"/>
                            <col style="width: 10%;"/>
                            <col/>
                        </colgroup>
                        <thead>
                            <tr>
                                <th><xsl:attribute name="class">center</xsl:attribute>Control</th>
                                <th><xsl:attribute name="class">center</xsl:attribute>ODP</th>
                                <th>Changes</th>
                                <th>Context</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="$controls[param/@id = $modified-ODP-ids]">
                                <xsl:variable name="control" as="element()" select="current()"/>
                                <xsl:for-each select="param[@id = $modified-ODP-ids]">
                                    <tr>
                                        <td>
                                            <xsl:attribute name="class">center</xsl:attribute>
                                            <xsl:if test="$control/@id = $novel-controls/@id">
                                                <xsl:value-of select="$r5-bullet"/>
                                                <xsl:text> </xsl:text>
                                            </xsl:if>
                                            <a href="#{$control/@id}">
                                                <xsl:value-of select="$control/prop[@name = 'label']/@value"/>
                                            </a>
                                            <xsl:if test="
                                                    $control/@id = $SP800-53r5-low//import/include-controls/with-id
                                                    or
                                                    $control/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                    or
                                                    $control/@id = $SP800-53r5-high//import/include-controls/with-id
                                                    or
                                                    $control/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                    ">
                                                <span class="LMHP fr">
                                                    <xsl:variable name="categorization" as="xs:string*">
                                                        <xsl:if test="$control/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                            <xsl:text>Ⓛ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="$control/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                            <xsl:text>Ⓜ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="$control/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                            <xsl:text>Ⓗ</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="$control/@id = $SP800-53r5-privacy//import/include-controls/with-id">
                                                            <xsl:text>Ⓟ</xsl:text>
                                                        </xsl:if>
                                                    </xsl:variable>
                                                    <xsl:value-of select="string-join($categorization, ' ')"/>
                                                </span>
                                            </xsl:if>
                                        </td>
                                        <td>
                                            <xsl:attribute name="class">center</xsl:attribute>
                                            <xsl:value-of select="@id"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial"/>
                                        </td>
                                        <td>
                                            <xsl:apply-templates mode="statement"
                                                select="$control//p[descendant::insert[@type = 'param'][@id-ref = current()/@id]]">
                                                <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                                            </xsl:apply-templates>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
                <xsl:call-template name="inter-section"/>
                <xsl:choose>
                    <xsl:when test="true()">
                        <xsl:call-template name="details2"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="details1"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="inter-section"/>
                <!-- Inputs -->
                <div>
                    <h2 id="inputs">OSCAL Inputs</h2>
                    <p>See <cite><a target="_blank" href="https://pages.nist.gov/OSCAL/">OSCAL: the Open Security Controls Assessment
                            Language</a></cite> for information about OSCAL. The <a target="_blank"
                            href="https://pages.nist.gov/OSCAL/documentation/schema/catalog-layer/">Catalog</a> and <a target="_blank"
                            href="https://pages.nist.gov/OSCAL/documentation/schema/profile-layer/">Profile</a> layers will be of particular
                        interest.</p>
                    <p>
                        <span>This report uses documents from <a target="_blank"
                                href="https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53"
                                >https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53</a>.</span>
                    </p>
                    <p> NB: That repository <em>might</em> lag the most recently published SP 800-53r5. It appeared to match as of <a target="_blank"
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
                                <div>
                                    <xsl:text expand-text="true">OSCAL version: {.//metadata/oscal-version}</xsl:text>
                                </div>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
                <xsl:call-template name="inter-section"/>
                <!-- Extras -->
                <div>
                    <h2 id="extras">Extras</h2>
                    <p>The following table shows all (not just novel) <xsl:value-of select="count($baselined-controls)"/> SP 800-53r5 controls which
                        are selected by one or more SP 800-53B baselines. Thes controls have <xsl:value-of select="count($baselined-controls//param)"
                        /> ODPs. </p>
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
                                            <xsl:value-of select="prop[@name = 'label']/@value"/>
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
                                                current()/@id = $SP800-53r5-low//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-high//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                ">
                                            <div>
                                                <span class="LMHP">
                                                    <xsl:if test="current()/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                        <xsl:text>Ⓛ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                        <xsl:text>Ⓜ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                        <xsl:text>Ⓗ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include-controls/with-id">
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
                </div>
                <xsl:call-template name="inter-section"/>
                <div class="trailer">
                    <hr/>
                    <p>Revised <xsl:value-of select="$UTC-datetime"/></p>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="details1">
        <!-- Details -->
        <div>
            <h2 id="details">SP 800-53r5 control details and comparison with SP 800-53r4</h2>
            <p>The following shows SP 800-53r5 controls<xsl:if test="not($show-all-withdrawn)"> (except those withdrawn in both versions)</xsl:if> and
                indicates (with Ⓛ, Ⓜ, Ⓗ, and Ⓟ) whether they appear in SP 800-53B Low, Moderate, High, or Privacy control baselines (or SP 800-53r4
                Low, Moderate, or High control baselines).</p>
            <p>The corresponding SP 800-53r4 control, when present, appears just below each SP 800-53r5 control.</p>
            <p>ODPs within control statements are rendered as illustrated in the following examples<xsl:if test="$show-ODP-id"> with the parameter
                    identifier as a preceding superscript</xsl:if>:</p>
            <ul>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ac-1_prm_1']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ac-2.2_prm_1']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ca-2.2_prm_3']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'at-1_prm_3']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates> (orange underline indicates this ODP is novel in SP 800-53r5) </li>
            </ul>
            <p> Hovering over an ODP will<xsl:if test="$show-ODP-id"> also</xsl:if> display the parameter identifier. Parameter identifiers are unique
                within an SP 800-53 version OSCAL instance document and are specific to an SP 800-53 version (i.e., they are <strong>not</strong>
                guaranteed to be identical from version to version).</p>
            <xsl:if test="$compare-ODP">
                <p>SP 800-53r5 to SP 800-53r4 ODP mappings appear right-justified below the control statements. ODPs may be novel, a qualified match,
                    or a reasonably assured match.</p>
                <ul>
                    <li>Novel ODPs will require novel selections or assignments to be declared for tailoring of baselines.</li>
                    <li>Qualified matches will require minor adjustments to previously declared tailoring.</li>
                    <li>Assured matches can use previously declared (SP 800-53r4) tailoring values.</li>
                </ul>
            </xsl:if>
            <xsl:if test="$show-tailored-ODPs">
                <p>When ODPs have been tailored in a baseline, they appear within a statement thus: <details class="ODPs"><summary>[<span
                                class="label">ODP selection or assignment</span>]</summary>
                        <span>Ⓛ <i>tailored value</i></span><br/>
                        <span>Ⓜ <i>tailored value</i></span><br/>
                        <span>Ⓗ <i>tailored value</i></span><br/>
                        <span>Ⓟ <i>tailored value</i></span></details> — click to expose the values.</p>
            </xsl:if>
            <table class="tr-hover">
                <colgroup>
                    <col style="width: 4%;"/>
                    <col style="width: 1%;"/>
                    <col style="width: 50%;"/>
                    <col style="width: 35%;"/>
                </colgroup>
                <thead>
                    <tr>
                        <th>Control</th>
                        <th>v</th>
                        <th>Statement</th>
                        <th>Guidance</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="
                            $SP800-53r5//control">
                        <xsl:sort order="ascending" select="current()/prop[@name = sort-id]/@value"/>
                        <xsl:variable name="r4" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                        <xsl:if test="
                                ($show-all-withdrawn or not(fn:withdrawn(.) and fn:withdrawn($r4)))
                                ">
                            <tr>
                                <xsl:attribute name="id" select="@id"/>
                                <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                    <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                </xsl:if>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="$r4">
                                            <xsl:attribute name="class">multirow</xsl:attribute>
                                            <xsl:attribute name="rowspan">2</xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:value-of select="prop[@name = 'label']/@value"/>
                                </td>
                                <td>
                                    <xsl:attribute name="class">multirow</xsl:attribute>
                                    <xsl:copy-of select="$r5-bullet"/>
                                </td>
                                <td>
                                    <div>
                                        <xsl:if test="fn:withdrawn(.)">
                                            <xsl:attribute name="class">withdrawn</xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="parent::control">
                                            <xsl:value-of select="parent::control/title"/>
                                            <xsl:text> | </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select="title"/>
                                        <xsl:if test="
                                                current()/@id = $SP800-53r5-low//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-high//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                ">
                                            <xsl:if test="fn:withdrawn(.)">
                                                <xsl:attribute name="class">anomaly</xsl:attribute>
                                            </xsl:if>
                                            <span class="LMHP fr">
                                                <xsl:variable name="categorization" as="xs:string*">
                                                    <xsl:if test="current()/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                        <xsl:text>Ⓛ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                        <xsl:text>Ⓜ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                        <xsl:text>Ⓗ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include-controls/with-id">
                                                        <xsl:text>Ⓟ</xsl:text>
                                                    </xsl:if>
                                                </xsl:variable>
                                                <xsl:value-of select="string-join($categorization, ' ')"/>
                                            </span>
                                        </xsl:if>
                                    </div>
                                    <div>
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
                                    <xsl:if test="false() and $compare-ODP and param">
                                        <div class="comparison">
                                            <xsl:variable name="r5-control" as="element()" select="current()"/>
                                            <xsl:variable name="r4-control" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                                            <!--<xsl:if test="$r4-control/param and count(param) != count($r4-control/param)">
                                                    <xsl:text expand-text="true">There are {count(param)} {$r5-bullet} ODPs and {count($r4-control/param)} {$r4-bullet} ODPs</xsl:text>
                                                </xsl:if>-->
                                            <xsl:for-each select="param">
                                                <xsl:variable name="text" as="xs:string" select="fn:parameter-text(.)"/>
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
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@novel">
                                                            <span>
                                                                <xsl:attribute name="class">novel</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> is a novel ODP (new in {$r5-bullet})</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial">
                                                            <span>
                                                                <xsl:attribute name="class">partialmatch</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> partially matches </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> — {$MAP54//*:param-map[@rev5-id = current()/@id]/@partial}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]">
                                                            <span>
                                                                <xsl:attribute name="class">match</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> presumptively matches </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
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
                                    <xsl:if test="$compare-ODP and param">
                                        <div class="comparison">
                                            <xsl:variable name="r5-control" as="element()" select="current()"/>
                                            <xsl:variable name="r4-control" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                                            <!--<xsl:if test="$r4-control/param and count(param) != count($r4-control/param)">
                                                    <xsl:text expand-text="true">There are {count(param)} {$r5-bullet} ODPs and {count($r4-control/param)} {$r4-bullet} ODPs</xsl:text>
                                                </xsl:if>-->
                                            <xsl:for-each select="param">
                                                <xsl:variable name="text" as="xs:string" select="fn:parameter-text(.)"/>
                                                <!--<xsl:message select="xs:string(@id), $text"/>-->
                                                <div>
                                                    <xsl:choose>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@novel">
                                                            <span>
                                                                <xsl:attribute name="class">novel</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> is new in {$r5-bullet}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial">
                                                            <span>
                                                                <xsl:attribute name="class">partialmatch</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> ≳ </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> — {$MAP54//*:param-map[@rev5-id = current()/@id]/@partial}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]">
                                                            <span>
                                                                <xsl:attribute name="class">match</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> ≍ </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                            </span>
                                                        </xsl:when>
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
                                    <xsl:attribute name="class">prior-revision</xsl:attribute>
                                    <xsl:variable name="id" as="xs:string" select="current()/@id"/>
                                    <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                        <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                    </xsl:if>
                                    <!--<xsl:if test="$CC//control[@id = $id][@type = 'none']" xpath-default-namespace="">
                                            <xsl:attribute name="class">novel</xsl:attribute>
                                        </xsl:if>-->
                                    <td>
                                        <xsl:attribute name="class">multirow</xsl:attribute>
                                        <xsl:copy-of select="$r4-bullet"/>
                                    </td>
                                    <td>
                                        <div>
                                            <div>
                                                <xsl:if test="$r4/parent::control">
                                                    <xsl:value-of select="$r4/parent::control/title"/>
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="$r4/title"/>
                                                <xsl:if test="
                                                        current()/@id = $SP800-53r4-low//import/include-controls/with-id
                                                        or
                                                        current()/@id = $SP800-53r4-moderate//import/include-controls/with-id
                                                        or
                                                        current()/@id = $SP800-53r4-high//import/include-controls/with-id
                                                        ">
                                                    <xsl:if test="$r4 and fn:withdrawn($r4)">
                                                        <xsl:attribute name="class">anomaly</xsl:attribute>
                                                    </xsl:if>
                                                    <span class="LMHP fr">
                                                        <xsl:variable name="categorization" as="xs:string*">
                                                            <xsl:if test="current()/@id = $SP800-53r4-low//import/include-controls/with-id">
                                                                <xsl:text>Ⓛ</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="current()/@id = $SP800-53r4-moderate//import/include-controls/with-id">
                                                                <xsl:text>Ⓜ</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="current()/@id = $SP800-53r4-high//import/include-controls/with-id">
                                                                <xsl:text>Ⓗ</xsl:text>
                                                            </xsl:if>
                                                        </xsl:variable>
                                                        <xsl:value-of select="string-join($categorization, ' ')"/>
                                                    </span>
                                                </xsl:if>
                                            </div>
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
        </div>
    </xsl:template>
    <xsl:template name="details2">
        <div>
            <h2 id="details">SP 800-53r5 control details and comparison with SP 800-53r4</h2>
            <p>The following shows SP 800-53r5 controls<xsl:if test="not($show-all-withdrawn)"> (except those withdrawn in both versions)</xsl:if> and
                indicates (with Ⓛ, Ⓜ, Ⓗ, and Ⓟ) whether they appear in SP 800-53B Low, Moderate, High, or Privacy control baselines (or SP 800-53r4
                Low, Moderate, or High control baselines).</p>
            <p>The corresponding SP 800-53r4 control, when present, appears just below each SP 800-53r5 control.</p>
            <p>ODPs within control statements are rendered as illustrated in the following examples<xsl:if test="$show-ODP-id"> with the parameter
                    identifier as a preceding superscript</xsl:if>:</p>
            <ul>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ac-1_prm_1']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ac-2.2_prm_1']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'ca-2.2_prm_3']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates>
                </li>
                <li>
                    <xsl:apply-templates mode="statement" select="$SP800-53r5//insert[@type = 'param'][@id-ref = 'at-1_prm_3']">
                        <xsl:with-param tunnel="true" name="tag-with-id" as="xs:boolean" select="false()"/>
                    </xsl:apply-templates> (orange underline indicates this ODP is novel in SP 800-53r5) </li>
            </ul>
            <p> Hovering over an ODP will<xsl:if test="$show-ODP-id"> also</xsl:if> display the parameter identifier. Parameter identifiers are unique
                within an SP 800-53 version OSCAL instance document and are specific to an SP 800-53 version (i.e., they are <strong>not</strong>
                guaranteed to be identical from version to version).</p>
            <xsl:if test="$compare-ODP">
                <p>SP 800-53r5 to SP 800-53r4 ODP mappings appear right-justified below the control statements. ODPs may be novel, a qualified match,
                    or a reasonably assured match.</p>
                <ul>
                    <li>Novel ODPs will require novel selections or assignments to be declared for tailoring of baselines.</li>
                    <li>Qualified matches will require minor adjustments to previously declared tailoring.</li>
                    <li>Assured matches can use previously declared (SP 800-53r4) tailoring values.</li>
                </ul>
            </xsl:if>
            <xsl:if test="$show-tailored-ODPs">
                <p>When ODPs have been tailored in a baseline, they appear within a statement thus: <details class="ODPs"><summary>[<span
                                class="label">ODP selection or assignment</span>]</summary>
                        <span>Ⓛ <i>tailored value</i></span><br/>
                        <span>Ⓜ <i>tailored value</i></span><br/>
                        <span>Ⓗ <i>tailored value</i></span><br/>
                        <span>Ⓟ <i>tailored value</i></span></details> — click to expose the values.</p>
            </xsl:if>
            <table class="tr-hover">
                <colgroup>
                    <col style="width: 4%;"/>
                    <col style="width: 45%;"/>
                    <col style="width: 45%;"/>
                </colgroup>
                <thead>
                    <tr>
                        <th style="text-align:center;">Control</th>
                        <th style="text-align:center;">SP 800-53r5</th>
                        <th style="text-align:center;">SP 800-53r4</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="
                            $SP800-53r5//control">
                        <xsl:sort order="ascending" select="current()/prop[@name = sort-id]/@value"/>
                        <xsl:variable name="r4" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                        <xsl:if test="
                                ($show-all-withdrawn or not(fn:withdrawn(.) and fn:withdrawn($r4)))
                                ">
                            <tr>
                                <xsl:attribute name="id" select="@id"/>
                                <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                    <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                </xsl:if>
                                <td class="center">
                                    <xsl:if test="$show-guidance">
                                        <xsl:attribute name="rowspan">2</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="prop[@name = 'label']/@value"/>
                                </td>
                                <td>
                                    <div>
                                        <xsl:if test="fn:withdrawn(.)">
                                            <xsl:attribute name="class">withdrawn</xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="parent::control">
                                            <xsl:value-of select="parent::control/title"/>
                                            <xsl:text> | </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select="title"/>
                                        <xsl:if test="
                                                current()/@id = $SP800-53r5-low//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-moderate//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-high//import/include-controls/with-id
                                                or
                                                current()/@id = $SP800-53r5-privacy//import/include-controls/with-id
                                                ">
                                            <xsl:if test="fn:withdrawn(.)">
                                                <xsl:attribute name="class">anomaly</xsl:attribute>
                                            </xsl:if>
                                            <span class="LMHP fr">
                                                <xsl:variable name="categorization" as="xs:string*">
                                                    <xsl:if test="current()/@id = $SP800-53r5-low//import/include-controls/with-id">
                                                        <xsl:text>Ⓛ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-moderate//import/include-controls/with-id">
                                                        <xsl:text>Ⓜ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-high//import/include-controls/with-id">
                                                        <xsl:text>Ⓗ</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="current()/@id = $SP800-53r5-privacy//import/include-controls/with-id">
                                                        <xsl:text>Ⓟ</xsl:text>
                                                    </xsl:if>
                                                </xsl:variable>
                                                <xsl:value-of select="string-join($categorization, ' ')"/>
                                            </span>
                                        </xsl:if>
                                    </div>
                                    <div>
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
                                    <xsl:if test="false() and $compare-ODP and param">
                                        <div class="comparison">
                                            <xsl:variable name="r5-control" as="element()" select="current()"/>
                                            <xsl:variable name="r4-control" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                                            <!--<xsl:if test="$r4-control/param and count(param) != count($r4-control/param)">
                                                    <xsl:text expand-text="true">There are {count(param)} {$r5-bullet} ODPs and {count($r4-control/param)} {$r4-bullet} ODPs</xsl:text>
                                                </xsl:if>-->
                                            <xsl:for-each select="param">
                                                <xsl:variable name="text" as="xs:string" select="fn:parameter-text(.)"/>
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
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@novel">
                                                            <span>
                                                                <xsl:attribute name="class">novel</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> is a novel ODP (new in {$r5-bullet})</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial">
                                                            <span>
                                                                <xsl:attribute name="class">partialmatch</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> partially matches </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> — {$MAP54//*:param-map[@rev5-id = current()/@id]/@partial}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]">
                                                            <span>
                                                                <xsl:attribute name="class">match</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> presumptively matches </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
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
                                    <xsl:if test="$compare-ODP and param">
                                        <div class="comparison">
                                            <xsl:variable name="r5-control" as="element()" select="current()"/>
                                            <xsl:variable name="r4-control" as="element()*" select="$SP800-53r4//control[@id = current()/@id]"/>
                                            <!--<xsl:if test="$r4-control/param and count(param) != count($r4-control/param)">
                                                    <xsl:text expand-text="true">There are {count(param)} {$r5-bullet} ODPs and {count($r4-control/param)} {$r4-bullet} ODPs</xsl:text>
                                                </xsl:if>-->
                                            <xsl:for-each select="param">
                                                <xsl:variable name="text" as="xs:string" select="fn:parameter-text(.)"/>
                                                <!--<xsl:message select="xs:string(@id), $text"/>-->
                                                <div>
                                                    <xsl:choose>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@novel">
                                                            <span>
                                                                <xsl:attribute name="class">novel</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> is new in {$r5-bullet}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]/@partial">
                                                            <span>
                                                                <xsl:attribute name="class">partialmatch</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> ≳ </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                                <xsl:text expand-text="true"> — {$MAP54//*:param-map[@rev5-id = current()/@id]/@partial}</xsl:text>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:when test="$MAP54//*:param-map[@rev5-id = current()/@id]">
                                                            <span>
                                                                <xsl:attribute name="class">match</xsl:attribute>
                                                                <xsl:value-of select="$r5-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="@id"/>
                                                                </span>
                                                                <xsl:text> ≍ </xsl:text>
                                                                <xsl:value-of select="$r4-bullet"/>
                                                                <span class="param_id">
                                                                    <xsl:value-of select="$MAP54//*:param-map[@rev5-id = current()/@id]/@rev4-id"/>
                                                                </span>
                                                            </span>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </div>
                                            </xsl:for-each>
                                        </div>
                                    </xsl:if>
                                </td>
                                <td>
                                    <!--<xsl:choose>
                                        <xsl:when test="fn:withdrawn(.)">
                                            <xsl:call-template name="withdrawn">
                                                <xsl:with-param name="bullet" select="$r5-bullet"/>
                                                <xsl:with-param name="control" select="current()"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
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
                                    </xsl:choose>-->
                                    <xsl:choose>
                                        <xsl:when test="$r4">
                                            <div>
                                                <div>
                                                    <xsl:if test="$r4/parent::control">
                                                        <xsl:value-of select="$r4/parent::control/title"/>
                                                        <xsl:text> | </xsl:text>
                                                    </xsl:if>
                                                    <xsl:value-of select="$r4/title"/>
                                                    <xsl:if test="
                                                            current()/@id = $SP800-53r4-low//import/include-controls/with-id
                                                            or
                                                            current()/@id = $SP800-53r4-moderate//import/include-controls/with-id
                                                            or
                                                            current()/@id = $SP800-53r4-high//import/include-controls/with-id
                                                            ">
                                                        <xsl:if test="$r4 and fn:withdrawn($r4)">
                                                            <xsl:attribute name="class">anomaly</xsl:attribute>
                                                        </xsl:if>
                                                        <span class="LMHP fr">
                                                            <xsl:variable name="categorization" as="xs:string*">
                                                                <xsl:if test="current()/@id = $SP800-53r4-low//import/include-controls/with-id">
                                                                    <xsl:text>Ⓛ</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="current()/@id = $SP800-53r4-moderate//import/include-controls/with-id">
                                                                    <xsl:text>Ⓜ</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="current()/@id = $SP800-53r4-high//import/include-controls/with-id">
                                                                    <xsl:text>Ⓗ</xsl:text>
                                                                </xsl:if>
                                                            </xsl:variable>
                                                            <xsl:value-of select="string-join($categorization, ' ')"/>
                                                        </span>
                                                    </xsl:if>
                                                </div>
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
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="class">centered</xsl:attribute>
                                            <xsl:text>No predecessor</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <xsl:if test="$show-guidance">
                                <tr>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="fn:withdrawn(.)">
                                                <!--<xsl:call-template name="withdrawn">
                                                <xsl:with-param name="control" select="current()"/>
                                            </xsl:call-template>-->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <details>
                                                    <summary>Guidance</summary>
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
                                                </details>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td>
                                        <xsl:if test="$r4">
                                            <xsl:choose>
                                                <xsl:when test="fn:withdrawn($r4)">
                                                    <xsl:call-template name="withdrawn">
                                                        <xsl:with-param name="control" select="$r4"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="$r4/part[@name = 'guidance']/p">
                                                    <details>
                                                        <summary>Guidance</summary>
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
                                                    </details>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>(No guidance)</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template name="extra"> </xsl:template>
    <xsl:template name="withdrawn">
        <xsl:param name="control"/>
        <xsl:param name="bullet" as="xs:string*" required="false"/>
        <div class="statement">
            <xsl:copy-of select="$bullet"/>
            <xsl:for-each select="link[@rel = ('incorporated-into')]">
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
                    <xsl:variable name="target" as="xs:string" select="substring-after(@href, '#')"/>
                    <xsl:choose>
                        <xsl:when test="matches($target, 'smt')">
                            <xsl:value-of select="$target"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//control[@id = $target]/prop[@name = 'label']/@value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </xsl:for-each>
            <xsl:text>.</xsl:text>
        </div>
    </xsl:template>
    <xsl:template mode="statement" match="part[@name = 'statement']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()"/>
        <xsl:variable name="content" as="node()*">
            <div class="statement">
                <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                    <xsl:attribute name="id" select="@id"/>
                </xsl:if>
                <xsl:apply-templates mode="statement" select="node()"/>
            </div>
        </xsl:variable>
        <xsl:copy-of select="$content"/>
    </xsl:template>
    <xsl:template mode="statement" match="part[@name = 'item']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()"/>
        <div class="item">
            <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:variable name="content" as="node()*">
                <xsl:apply-templates mode="statement" select="node()"/>
            </xsl:variable>
            <xsl:copy-of select="$content"/>
        </div>
    </xsl:template>
    <xsl:template mode="statement" match="p">
        <xsl:apply-templates mode="statement" select="node()"/>
    </xsl:template>
    <xsl:template mode="statement" match="em | strong | ol | li | b">
        <xsl:element name="span">
            <xsl:attribute name="class">semantic-error</xsl:attribute>
            <xsl:attribute name="title" expand-text="true">The input catalog contained a faux HTML &lt;{local-name()}&gt; element</xsl:attribute>
            <xsl:apply-templates mode="statement" select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template mode="statement" match="a">
        <a href="{@href}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    <xsl:template mode="statement" match="prop[@name = 'label']">
        <xsl:text expand-text="true">{@value} </xsl:text>
    </xsl:template>
    <xsl:template mode="statement" match="insert">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()"/>
        <xsl:choose>
            <xsl:when test="@type = 'param'">
                <span>
                    <xsl:attribute name="title" select="@id-ref"/>
                    <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                        <xsl:attribute name="id" select="@id-ref"/>
                        <xsl:choose>
                            <xsl:when test="fn:novel-ODP(@id-ref)">
                                <xsl:attribute name="class">novel-ODP insert</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">established-ODP insert</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="$show-ODP-id">
                        <span class="superscript-identifier">
                            <xsl:value-of select="@id-ref"/>
                        </span>
                    </xsl:if>
                    <xsl:variable name="insert" as="node()*">
                        <xsl:apply-templates mode="statement" select="ancestor::control/param[@id = current()/@id-ref]"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 4')">
                            <!-- show r4 ODPs -->
                            <!--<xsl:message select="$insert"/>-->
                            <xsl:choose>
                                <xsl:when test="$show-tailored-ODPs">
                                    <details class="ODPs">
                                        <summary>
                                            <xsl:copy-of select="$insert"/>
                                        </summary>
                                        <xsl:variable name="ODPs" as="xs:string*">
                                            <xsl:choose>
                                                <xsl:when test="$ODP-low//set-parameter[@id-ref = current()/@id-ref]">
                                                    <xsl:text expand-text="true">Ⓛ: {$ODP-low//set-parameter[@id-ref = current()/@id-ref]/value}</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text expand-text="true">Ⓛ: (Not defined)</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:choose>
                                                <xsl:when test="$ODP-moderate//set-parameter[@id-ref = current()/@id-ref]">
                                                    <xsl:text expand-text="true">Ⓜ: {$ODP-moderate//set-parameter[@id-ref = current()/@id-ref]/value}</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text expand-text="true">Ⓜ: (Not defined)</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:choose>
                                                <xsl:when test="$ODP-high//set-parameter[@id-ref = current()/@id-ref]">
                                                    <xsl:text expand-text="true">Ⓗ: {$ODP-high//set-parameter[@id-ref = current()/@id-ref]/value}</xsl:text>
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
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Life must end</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
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
    <xsl:template mode="statement" match="remarks"><!-- ignore for now --></xsl:template>
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
