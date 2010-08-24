<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/">
    <div id="test">
    <h2><xsl:value-of select="/testsuite/@name"/></h2>
      <ul>
        <xsl:apply-templates/> 
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="testcase">
    <li>
      <xsl:if test="failure">
        <xsl:attribute name="class">failure</xsl:attribute>
      </xsl:if>
      <span class="timing"><xsl:value-of select="@time"/></span>
      <span class="name"><xsl:value-of select="@name"/></span>
    </li>
    <xsl:apply-templates/> 
  </xsl:template>

  <xsl:template match="failure">
    <li class="failure_details">
      <a class="type">
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="../@name"/>
        </xsl:attribute>
        <xsl:value-of select="@type"/>
      </a>
      <pre class="code">
        <xsl:attribute name="class">
          <xsl:text>code</xsl:text>
          <xsl:value-of select="../@name"/>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </pre>
    </li>
  </xsl:template>

</xsl:stylesheet>
