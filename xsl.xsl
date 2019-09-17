<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns="http://www.w3.org/2005/Atom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="html">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:variable name="base-uri">https://pavilion.bushimo.jp/webview/news_list.do</xsl:variable>
  <xsl:template match="/html:html">
    <feed>
      <title><xsl:value-of select="html:head/html:title" /></title>
      <link rel="alternate" href="{$base-uri}" />
      <id><xsl:value-of select="$base-uri" /></id>
      <xsl:apply-templates select="html:body//html:li/html:a" />
    </feed>
  </xsl:template>

  <xsl:template match="html:ul[@class='infolist']/html:li/html:a">
    <!-- `resolve-uri()` is not available in XSLT 1.0, hence this :( -->
    <xsl:variable name="uri" select="concat('https://pavilion.bushimo.jp', @href)" />
    <xsl:variable name="date" select="*[contains(@class, 'date')]/text()" />
    <!-- Convert from "YYYY/MM/DD" (non-zero-padded) to RFC 3339 date-time -->
    <xsl:variable
        name="iso-date"
        select=
          "concat(
            format-number(substring-before($date, '/'), '0000'),
            '-',
            format-number(substring-before(substring-after($date, '/'), '/'), '00'),
            '-',
            format-number(substring-after(substring-after($date, '/'), '/'), '00'),
            'T00:00:00+09:00'
          )" />
    <entry>
      <title>
        <xsl:call-template name="trim">
          <xsl:with-param name="str" select="text()[1]" />
        </xsl:call-template>
      </title>
      <link rel="alternate" href="{$uri}" />
      <id><xsl:value-of select="$uri" /></id>
      <updated><xsl:value-of select="$iso-date" /></updated>
      <xsl:for-each select="*[contains(@class, 'type')]">
        <category term="{text()}" />
      </xsl:for-each>
      <summary><xsl:value-of select="$uri" /></summary>
      <content type="application/xhtml+xml" src="{$uri}" />
    </entry>
  </xsl:template>

  <xsl:variable name="whitespace" select="'&#09;&#10;&#13; '" />
  <xsl:template name="trim">
    <xsl:param name="str" />
    <xsl:choose>
      <xsl:when test="string-length($str) &gt; 0 and contains($whitespace, substring($str, 1, 1))">
        <xsl:call-template name="trim">
          <xsl:with-param name="str" select="substring($str, 2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string-length($str) &gt; 0 and contains($whitespace, substring($str, string-length($str)))">
        <xsl:call-template name="trim">
          <xsl:with-param name="str" select="substring($str, 1, string-length($str)-1)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$str"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
