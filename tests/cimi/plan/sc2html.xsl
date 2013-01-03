<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="h w"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:w="http://www.wstf.org">

  <xsl:strip-space elements="*" />
  <xsl:variable name="prereqName">Dependencies</xsl:variable>

  <!--

  Elements:

  scenario        - outer most element
  metadata        - contains info about the scenario
   number         - sc00x
   title          -
   date           -
   status         -

  abstract        - summary of scenario
  section         - sections are listed in the TOC
  subsection      - indented sub-section - it is numbered 1.2
  subheading      - non-indented sub-section - it is not numbered

  scope           -
   technology     -

  timeline        -
   item           -

  namespaces      -
   namespace      -

  terms           -
   term           -

  operation       -
   action         -
   headers        -
   body           -

  exemplar        -
  xml             -
  populate        -

  note            -
  item            -
  num             -
  toggle          - adds a toggle section

  part            -
   group          -
    tests         -
     test         -
      desc        -
      description -
      succ        -
      success     -

  changes         -
   change         -

  -->

  <xsl:output method="html" encoding="utf-8" indent="yes"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    media-type="text/html" omit-xml-declaration="no" />

  <xsl:template match="w:scenario">
   <html>
    <head>
      <title>
       <xsl:value-of select="w:metadata/w:number"/> -
       <xsl:value-of select="w:metadata/w:title"/>
      </title>
       <xsl:if test="not(//w:metadata/w:nowstf)">
        <link rel="SHORTCUT ICON"
              href="http://www.wstf.org/images/wstf-ico.gif"
             type="image/x-icon" />
       </xsl:if>
      <link href="http://www.wstf.org/docs/web/scen-v1.css" type="text/css"
            rel="stylesheet"/>
      <script type="text/javascript"
              src="http://www.wstf.org/docs/web/scen-v1.js"/>
    </head>
    <body>
     <!-- ========== Title Bar Info ========== -->
     <xsl:if test="not(//w:metadata/w:nowstf)">
      <img style="position:absolute;top:9px;left:9px;background-color:#d3d3d3"
           onclick="window.location='http://www.wstf.org'"
           src="http://www.wstf.org/images/wstf-small.gif"/>
     </xsl:if>
     <h1 style="padding-left:43px;padding-right:43px"> <!-- padding to avoid icon -->
       <xsl:value-of select="w:metadata/w:number"/> -
       <xsl:value-of select="w:metadata/w:title"/>
     </h1>
     <p class="date">Produced
      <xsl:if test="not(//w:metadata/w:nowstf)">
       by WSTF
      </xsl:if>
      : <xsl:value-of select="w:metadata/w:date"/>
     </p>
     <p class="status">Status:
      <xsl:value-of select="w:metadata/w:status"/>
     </p>

     <xsl:apply-templates select="w:abstract"/>
     <xsl:apply-templates select="w:timeline"/>

     <!-- ========== TOC ========== -->
     <xsl:if test="not(contains(//w:metadata/w:status,'Preview'))">
      <h2>Table of Contents</h2>
      <p>
       <ol>
        <xsl:for-each select="w:section">
         <li><a href="#sec{position()}"><xsl:value-of select="@title"/></a></li>
        </xsl:for-each>
       </ol>
      </p>
     </xsl:if>

     <!-- ========== Now process each section ========== -->
     <xsl:apply-templates select="w:section"/>

     <!-- ========== Add in some javascript ========== -->
     <xsl:for-each select="//w:populate">
       <script> populateFromURL( "<xsl:value-of select="generate-id(.)"/>", "<xsl:value-of select="@url"/>" ); </script>
     </xsl:for-each>

    </body>
   </html>
  </xsl:template>

  <xsl:template match="w:abstract">
   <h2>Abstract</h2>
   <p>
    <xsl:apply-templates/>
   </p>
  </xsl:template>

  <xsl:template match="w:timeline">
   <p>
    <b>
     <xsl:choose>
      <xsl:when test="@title"><xsl:value-of select="@title"/></xsl:when>
      <xsl:otherwise>Timeline</xsl:otherwise>
     </xsl:choose>
    </b>
    <br/>
    <table class="mono" cellpadding="2" cellspacing="0">
     <thead>
      <tr>
       <td>Start</td>
       <td>End</td>
       <td>Activity</td>
      </tr>
     </thead>
     <tbody>
      <xsl:for-each select="w:item">
       <tr>
        <td><xsl:value-of select="@start"/></td>
        <td><xsl:value-of select="@end"/></td>
        <td><xsl:value-of select="@action"/></td>
       </tr>
      </xsl:for-each>
     </tbody>
    </table>
   </p>
  </xsl:template>

  <xsl:template match="w:terms">
   <h4>Definitions</h4>
   The following terms will be used throughout this scenario to refer
   to the various factors that make up the individual tests.
   <table class="" cellpadding="2" cellspacing="0">
    <thead>
     <tr>
      <td>Term</td>
      <td>Definition</td>
     </tr>
    </thead>
    <tbody>
     <xsl:for-each select="w:term">
      <tr>
       <td><xsl:value-of select="@term"/></td>
       <td><xsl:apply-templates/></td>
      </tr>
     </xsl:for-each>
    </tbody>
   </table>
  </xsl:template>

  <xsl:template match="w:scope">
   <h4>Scope</h4>
   Specifications, standards and technologies being tested:
   <ul>
    <xsl:for-each select="w:technology">
     <li><a href="{@url}"><xsl:value-of select="@name"/></a></li>
    </xsl:for-each>
   </ul>
  </xsl:template>

  <xsl:template match="w:namespaces">
   <h4>Namespaces</h4>
   The following table defines the namespaces used in this document:
   <table class="mono" cellpadding="2" cellspacing="0">
    <thead>
     <tr>
      <td>Prefix</td>
      <td>Namespace</td>
      <td>Specification/Document</td>
     </tr>
    </thead>
    <tbody>
     <xsl:for-each select="w:namespace">
      <tr>
       <td><xsl:value-of select="@prefix"/></td>
       <td><xsl:value-of select="@ns"/></td>
       <td><a href="{@ns}"><xsl:value-of select="@name"/></a></td>
      </tr>
     </xsl:for-each>
    </tbody>
   </table>
  </xsl:template>

  <!-- ========== New Section ========== -->
  <xsl:template match="w:section">
   <h2>
    <a name="sec{position()}">
     <xsl:if test="not(contains(//w:metadata/w:status,'Preview'))">
       <xsl:number format="1. "/>
     </xsl:if>
     <xsl:value-of select="@title"/>
    </a>
   </h2>
   <p>
    <xsl:apply-templates/>
   </p>
  </xsl:template>

  <xsl:template match="w:subheading">
   <h4><xsl:value-of select="@title"/></h4>
   <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="w:subsection">
   <div style="margin-left:10px;margin-bottom:5px">
    <h3>
     <xsl:number format="1.1. " level="multiple" count="w:section|w:subsection"/><xsl:value-of select="@title"/>
    </h3>
    <xsl:apply-templates/>
   </div>
  </xsl:template>

  <xsl:template match="w:operation">
   <h4 style="margin-top:5px"><u><xsl:value-of select="@name"/></u></h4>
   <div style="margin:0;margin-left:0px">
    <xsl:apply-templates/>
   </div>
  </xsl:template>

  <!-- ===== Bullet item w/o indent ===== -->
  <xsl:template match="w:note">
   <ul style="margin-top:0;margin-bottom:0;padding-left:0em;margin-left:1em">
    <li><xsl:apply-templates/></li>
   </ul>
  </xsl:template>

  <!-- ===== Bullet item w/indent ===== -->
  <xsl:template match="w:item">
   <ul style="margin-top:0;margin-bottom:0">
    <li><xsl:apply-templates/></li>
   </ul>
  </xsl:template>

  <xsl:template match="w:num">
   <xsl:variable name="nn" select="@group"/>
   <xsl:if test="@group">
    <xsl:variable name="num" select="1+count(preceding-sibling::w:num[@group=$nn])"/>
    <ol start='{$num}' style="margin-top:0px;margin-bottom:0px">
     <li><xsl:apply-templates/></li>
    </ol>
   </xsl:if>
   <xsl:if test="not(@group)">
    <xsl:variable name="num" select="1+count(preceding-sibling::w:num[not(@group)])"/>
    <ol start='{$num}' style="margin-top:0px;margin-bottom:0px">
     <li><xsl:apply-templates/></li>
    </ol>
   </xsl:if>
  </xsl:template>

  <!-- ===== Toggle/Popup ===== -->
  <xsl:template match="w:toggle">
   <xsl:variable name="num" select="1+count(preceding::w:toggle)"/>
   <xsl:variable name="style" select="@style"/>
   <a href="javascript:toggle('togDiv{$num}')"><xsl:value-of select="@title"/></a>
   <div id="togDiv{$num}" onclick="javascript:toggle('togDiv{$num}')" style="display:block;visibility:hidden;height:0;{$style}">
     <xsl:apply-templates/>
   </div>
  </xsl:template>

  <xsl:template match="w:popup">
   <xsl:variable name="num" select="1+count(preceding::w:popup)"/>
   <xsl:variable name="style" select="@style"/>
   <a href="javascript:toggle('togDiv{$num}')"><xsl:value-of select="@title"/></a>
   <div id="togDiv{$num}" style="border:2px ridge black;padding:2px;background-color:white;position:absolute;right:10px;display:block;visibility:hidden;height:0;{$style}">
     <span style="background-color:white;border-top:2px ridge black;border-left:2px ridge black;border-right:2px ridge black;position:absolute;right:-2px;padding-left:1px;padding-right:1px;cursor:pointer;top:-18px" onclick="javascript:toggle('togDiv{$num}')"><b>CLOSE</b></span>
     <xsl:apply-templates/>
   </div>
  </xsl:template>


  <!-- ===== Snippet of XML ===== -->
  <xsl:template match="w:xml">
   <xsl:if test="@title">
    <p style="margin:0"><tt><b><xsl:value-of select="@title"/>:</b></tt></p>
   </xsl:if>
   <pre class="ex" style="margin-bottom:0"><xsl:apply-templates/></pre>
  </xsl:template>

  <!-- ===== Pseudo code - soap message ===== -->
  <xsl:template match="w:exemplar">
   <xsl:if test="@type!=''">
    <br/><tt><b><xsl:value-of select="@type"/>:</b></tt>
   </xsl:if>
   <pre class="ex" style="margin-bottom:0">
    <p style="margin:0"><b>[Action]</b></p>
    <xsl:if test="w:action">
      <xsl:value-of select="w:action"/>
    </xsl:if>

    <p style="margin:0;padding-top:10px"><b>[Headers]</b></p>
    <xsl:if test="w:headers">
      <xsl:value-of select="w:headers"/>
    </xsl:if>

    <p style="margin:0;padding-top:10px"><b>[Body]</b></p>
    <xsl:value-of select="w:body"/>
   </pre>
  </xsl:template>

  <!-- Tests are grouped into 'parts'. Each part is a new # -->
  <xsl:template match="w:part">
   <p><b>Part <xsl:number level="single" count="w:part"/> -
         <xsl:value-of select="@title"/></b><p/>
    <xsl:apply-templates/>
   </p>
  </xsl:template>

  <!-- Within a part we can group tests -->
  <xsl:template match="w:group">
   <p><b><xsl:value-of select="@title"/></b><br/>
    <xsl:apply-templates/>
   </p>
  </xsl:template>

  <!-- ===== Tests are shown in table format ===== -->
  <xsl:template match="w:tests">
   <table class="mono" cellpadding="2" cellspacing="0">
    <thead>
     <tr>
      <td width="4%">Number</td>
      <td width="48%">Description</td>
      <td width="48%">Success Criteria</td>
     </tr>
    </thead>
    <tbody>
     <xsl:apply-templates/>
    </tbody>
   </table>
  </xsl:template>

  <xsl:template match="w:tests/w:test">
   <tr>
    <td>
     <xsl:choose>
      <xsl:when test="@num"><xsl:value-of select="@num"/></xsl:when>
      <xsl:otherwise>
       <xsl:choose>
        <xsl:when test="ancestor::w:part">
         <xsl:number level="single" count="w:part"/>
         <xsl:text>.</xsl:text>
         <xsl:number level="any" from="w:part" count="w:test"/>
        </xsl:when>
        <xsl:when test="not(ancestor::w:part)">
         <xsl:number level="single" count="w:test"/>
        </xsl:when>
       </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
    </td>
    <td>
     <xsl:if test="@name">
      <b><xsl:value-of select="@name"/></b><br/>
     </xsl:if>
     <xsl:apply-templates select="w:description|w:desc"/>
    </td>
    <td>
     <xsl:apply-templates select="w:success|w:succ"/>
    </td>
   </tr>
  </xsl:template>

  <xsl:template match="w:part/w:test">
   <div style="margin-left:10px">
   <b>
    <xsl:choose>
     <xsl:when test="@num"><xsl:value-of select="@num"/></xsl:when>
     <xsl:otherwise>
      <xsl:choose>
       <xsl:when test="ancestor::w:part">
        <xsl:number level="single" count="w:part"/>
        <xsl:text>.</xsl:text>
        <xsl:number level="any" from="w:part" count="w:test"/>
       </xsl:when>
       <xsl:when test="not(ancestor::w:part)">
        <xsl:number level="single" count="w:test"/>
       </xsl:when>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   - <xsl:value-of select="@name"/></b><br/>
   <pre style="margin-top:0px;margin-bottom:0px"><xsl:apply-templates/></pre>
   </div>
  </xsl:template>

  <!-- ========== Dynamically load XML files ========== -->
  <xsl:template match="w:populate">
   <div id="{generate-id(.)}"/>
  </xsl:template>

  <!-- ========== Change History Section ========== -->
  <xsl:template match="w:changes">
   <table class="mono" cellpadding="2" cellspacing="0">
    <thead>
     <tr>
      <td>Date</td>
      <td>Who</td>
      <td>Change</td>
     </tr>
    </thead>
    <tbody>
     <xsl:for-each select="w:change">
      <tr>
       <td nowrap="1"><xsl:value-of select="@date"/></td>
       <td nowrap="1"><xsl:value-of select="@who"/></td>
       <td><xsl:apply-templates/></td>
      </tr>
     </xsl:for-each>
    </tbody>
   </table>
  </xsl:template>

  <!-- ========== Some Util Templates ========== -->

  <!-- === Just blindly copy all unknown elements/attributes === -->
  <xsl:template match="w:*" name="copy">
    <xsl:element name="{local-name(.)}">
     <xsl:for-each select="@*">
       <xsl:copy/>
     </xsl:for-each>
     <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!--
  <xsl:template match="@*|node()" name="copy">
   <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
  </xsl:template>
  -->

  <xsl:template name="echoXML">
   <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name(.)"/>
   <xsl:text>&gt;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
