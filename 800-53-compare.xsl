<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs oscal fn"
    version="3.0" xmlns:fn="local function" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0">
    <xsl:param name="show-all-withdrawn" as="xs:boolean" required="false" select="true()"/>
    <!-- r5 -->
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
    <!-- r4 -->
    <xsl:variable name="SP800-53r4" as="document-node()" xpath-default-namespace=""
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/master/nist.gov/SP800-53/rev4/xml/NIST_SP-800-53_rev4_catalog.xml')"/>
    <xsl:variable name="SP800-53r4-low" as="document-node()" xpath-default-namespace=""
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/master/nist.gov/SP800-53/rev4/xml/NIST_SP-800-53_rev4_LOW-baseline_profile.xml')"/>
    <xsl:variable name="SP800-53r4-moderate" as="document-node()" xpath-default-namespace=""
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/master/nist.gov/SP800-53/rev4/xml/NIST_SP-800-53_rev4_MODERATE-baseline_profile.xml')"/>
    <xsl:variable name="SP800-53r4-high" as="document-node()" xpath-default-namespace=""
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/master/nist.gov/SP800-53/rev4/xml/NIST_SP-800-53_rev4_HIGH-baseline_profile.xml')"/>
    <xsl:output method="html" indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="r4-bullet" as="xs:string">④ </xsl:variable>
    <xsl:variable name="r5-bullet" as="xs:string">⑤ </xsl:variable>
    <xsl:function name="fn:withdrawn" as="xs:boolean">
        <xsl:param name="control" as="element()" required="true"/>
        <xsl:sequence select="$control/prop[@name = 'status'] = ('Withdrawn', 'withdrawn')"/>
    </xsl:function>
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
                <h2>Inputs</h2>
                <p>
                    <span>This report uses documents from <a target="_blank"
                            href="https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53"
                            >https://github.com/usnistgov/oscal-content/tree/master/nist.gov/SP800-53</a>.</span>
                </p>
                <p>
                    <strong>NB: That repository <em>may</em> lag the most recently published <a target="_blank"
                            href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final">SP 800-53r5</a></strong>
                    <span> (and it does lag as of the creation of this document: the errata are not yet incorporated).</span>
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
                <h3>Changes</h3>
                <p>
                    <xsl:text expand-text="true">Based on that content, SP 800-53r5 has {format-integer(count($SP800-53r5//control[not(@id = $SP800-53r4//control/@id)]),'w')} novel (i.e.,  not in SP 800-53r4) controls and control enhancements.</xsl:text>
                </p>
                <p>
                    <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//control) - count($SP800-53r5//control[fn:withdrawn(.)]),'w')} active (i.e., not withdrawn) controls and control enhancements (there were {format-integer(count($SP800-53r5//control[fn:withdrawn(.)]) - count($SP800-53r4//control[fn:withdrawn(.)]),'w')} newly withdrawn, and {format-integer(count($SP800-53r4//control[fn:withdrawn(.)]),'w')} previously withdrawn).</xsl:text>
                </p>
                <p>
                    <xsl:text expand-text="true">There are {format-integer(count($SP800-53r5//param),'w')} organization-defined parameters (ODPs).</xsl:text>
                </p>
                <h2>SP 800-53r5 controls</h2>
                <p>The following shows SP 800-53r5 controls<xsl:if test="not($show-all-withdrawn)"> (except those withdrawn in both versions)</xsl:if>
                    and indicates (with Ⓛ, Ⓜ, Ⓗ, and Ⓟ) whether they appear in SP 800-53B (or SP 800-53r4) Low, Moderate, High, or Privacy control
                    baselines.</p>
                <p>The SP 800-53r4 controls, when present, appear just below each SP 800-53r5 control.</p>
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
                            <xsl:if test="$show-all-withdrawn or not(fn:withdrawn(.) and fn:withdrawn($r4))">
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
                                        <xsl:if test="fn:withdrawn(.) and fn:withdrawn($r4)">
                                            <xsl:attribute name="class">withdrawn2</xsl:attribute>
                                        </xsl:if>
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
    <xsl:template mode="statement" match="strong | ol | li">
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
        <span title="{@param-id}">
            <xsl:apply-templates mode="statement" select="ancestor::control/param[@id = current()/@param-id]"/>
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
                        <xsl:variable name="substrings" as="xs:string*">
                            <xsl:apply-templates mode="statement" select="node()"/>
                        </xsl:variable>
                        <xsl:value-of select="$substrings"/>
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
                    <xsl:text expand-text="true">{string-join($choices,', ')}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Selection: </xsl:text>
                    <xsl:text expand-text="true">{string-join($choices,' or ')}</xsl:text>
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
