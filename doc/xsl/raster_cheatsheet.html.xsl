<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- ********************************************************************
     ********************************************************************
	 Copyright 2011, Regina Obe
     License: BSD
	 Purpose: This is an xsl transform that generates PostgreSQL COMMENT ON FUNCTION ddl
	 statements from postgis xml doc reference
     ******************************************************************** -->

	<xsl:include href="common_utils.xsl" />
	<xsl:include href="common_cheatsheet.xsl" />

	<xsl:output method="text" />

<xsl:template match="/">
	<xsl:text><![CDATA[<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>PostGIS Raster Cheat Sheet</title>
	<style type="text/css">
<!--
table { page-break-inside:avoid; page-break-after:auto }
tr    { page-break-inside:avoid; page-break-after:avoid }
thead { display:table-header-group }
tfoot { display:table-footer-group }
body {
	font-family: Arial, sans-serif;
	font-size: 8.5pt;
}
@media print { a , a:hover, a:focus, a:active{text-decoration: none;color:black} }
@media screen { a , a:hover, a:focus, a:active{text-decoration: underline} }
.comment {font-size:x-small;color:green;font-family:"courier new"}
.notes {font-size:x-small;color:#dd1111;font-weight:500;font-family:verdana}
#example_heading {
	border-bottom: 1px solid #000;
	margin: 10px 15px 10px 85px;
	color: #4a124a;font-size: 7.5pt;
}

#content_functions {
	width:100%;
	float: left
}

#content_examples {
	float: left;
	width: 100%;
	page-break-before: auto
}

.section {
	border: 1px solid #000;
	margin: 4px;
	]]></xsl:text>
	<xsl:choose><xsl:when test="$output_purpose = 'false'"><![CDATA[width: 45%;]]></xsl:when><xsl:otherwise><![CDATA[width: 100%;]]></xsl:otherwise></xsl:choose>
<xsl:text><![CDATA[		float: left;
}

.example {
	border: 1px solid #000;
	margin: 4px;
	width: 50%;
	float:left;
}

.example b {font-size: 7.5pt}
.example th {
	border: 1px solid #000;
	color: #000;
	background-color: #ddd;
	font-size: 8.0pt;
}

.section th {
	border: 1px solid #000;
	color: #fff;
	background-color: #4a124a;
	font-size: 9.5pt;

}
.section td {
	font-family: Arial, sans-serif;
	font-size: 8.5pt;
	vertical-align: top;
	border: 0;
}

.func {font-weight: 600}
.func_args {font-size: 8pt;font-family:courier}

.evenrow {
	background-color: #eee;
}

.oddrow {
	background-color: #fff;
}

h1 {
	margin: 0px;
	padding: 0px;
	font-size: 14pt;
}
code {font-size: 8pt}
-->
</style>
	</head><body><h1 style='text-align:center'>PostGIS ]]></xsl:text> <xsl:value-of select="$postgis_version" /><xsl:text><![CDATA[ Raster Cheatsheet</h1>]]></xsl:text>
		<xsl:text><![CDATA[<span class='notes'>New in this release <sup>1</sup> Enhanced in this release <sup>2</sup> Requires GEOS 3.9 or higher<sup>g3.9</sup> &nbsp;aggregate <sup>agg</sup> &nbsp;&nbsp;  &nbsp;2.5/3D support<sup>3d</sup>&nbsp;SQL-MM<sup>mm</sup> &nbsp;Supports geography <sup>G</sup></span> <div id="content_functions">]]></xsl:text>
			<xsl:apply-templates select="/book/chapter[@id='RT_reference']" name="function_list" />
			<xsl:text><![CDATA[</div>]]></xsl:text>
			<xsl:text><![CDATA[<div id="content_examples">]]></xsl:text>
			<!-- examples go here -->
			<xsl:if test="$include_examples='true'">
				<xsl:apply-templates select="/book/chapter[@id='RT_reference']/sect1[count(//refentry//refsection//programlisting) &gt; 0]"  />
			</xsl:if>
			<xsl:text><![CDATA[</div>]]></xsl:text>
			<xsl:text><![CDATA[</body></html>]]></xsl:text>
</xsl:template>


  <xsl:template match="chapter" name="function_list">
		<xsl:for-each select="sect1[//funcprototype]">
			<!--Beginning of section -->
			<xsl:text><![CDATA[<table class="section"><tr><th colspan="2">]]></xsl:text>
				<xsl:value-of select="title" />
				<!-- end of section header beginning of function list -->
				<xsl:text><![CDATA[</th></tr>]]></xsl:text>
			<xsl:for-each select="current()//refentry">
				<!-- add row for each function and alternate colors of rows -->
				<!-- , hyperlink to online manual -->
		 		<![CDATA[<tr]]> class="<xsl:choose><xsl:when test="position() mod 2 = 0">evenrow</xsl:when><xsl:otherwise>oddrow</xsl:otherwise></xsl:choose>" <![CDATA[><td colspan='2'><span class='func'>]]><xsl:text><![CDATA[<a href="]]></xsl:text><xsl:value-of select="$linkstub" /><xsl:value-of select="@id" />.html<xsl:text><![CDATA[" target="_blank">]]></xsl:text><xsl:value-of select="refnamediv/refname" /><xsl:text><![CDATA[</a>]]></xsl:text><![CDATA[</span>]]><xsl:if test="contains(.,$new_tag)"><![CDATA[<sup>1</sup> ]]></xsl:if>
		 		<!-- enhanced tag -->
		 		<xsl:if test="contains(.,$enhanced_tag)"><![CDATA[<sup>2</sup> ]]></xsl:if>
		 		<xsl:if test="contains(.,'implements the SQL/MM')"><![CDATA[<sup>mm</sup> ]]></xsl:if>
		 		<xsl:if test="contains(refsynopsisdiv/funcsynopsis,'geography') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geography')"><![CDATA[<sup>G</sup>  ]]></xsl:if>
		 		<xsl:if test="contains(.,'GEOS &gt;= 3.9')"><![CDATA[<sup>g3.9</sup> ]]></xsl:if>
		 		<xsl:if test="contains(.,'This function supports 3d')"><![CDATA[<sup>3D</sup> ]]></xsl:if>
		 		<!-- if only one proto just dispaly it on first line -->
		 		<xsl:if test="count(refsynopsisdiv/funcsynopsis/funcprototype) = 1">
		 			(<xsl:call-template name="list_in_params"><xsl:with-param name="func" select="refsynopsisdiv/funcsynopsis/funcprototype" /></xsl:call-template><xsl:if test=".//paramdef[contains(type,'setof')] or .//paramdef[contains(type,'geography set')] or
						.//paramdef[contains(type,'raster set')]"><![CDATA[<sup> agg</sup> ]]></xsl:if><xsl:if test=".//paramdef[contains(type,'winset')]"><![CDATA[ <sup>W</sup> ]]></xsl:if>)
		 		</xsl:if>

		 		<![CDATA[&nbsp;&nbsp;]]>
		 		<xsl:if test="$output_purpose = 'true'"><xsl:value-of select="refnamediv/refpurpose" /></xsl:if>
		 		<!-- output different proto arg combos -->
		 		<xsl:if test="count(refsynopsisdiv/funcsynopsis/funcprototype) &gt; 1"><![CDATA[<span class='func_args'><ol>]]><xsl:for-each select="refsynopsisdiv/funcsynopsis/funcprototype"><![CDATA[<li>]]><xsl:call-template name="list_in_params"><xsl:with-param name="func" select="." /></xsl:call-template><xsl:if test=".//paramdef[contains(type,' set')] or .//paramdef[contains(type,'setof')] or .//paramdef[contains(type,'geography set')] or
						.//paramdef[contains(type,'raster set') ]"><![CDATA[<sup> agg</sup> ]]></xsl:if><xsl:if test=".//paramdef[contains(type,'winset')]"><![CDATA[ <sup>W</sup> ]]></xsl:if><![CDATA[</li>]]></xsl:for-each>
		 		<![CDATA[</ol></span>]]></xsl:if>
		 		<![CDATA[</td></tr>]]>
		 	</xsl:for-each>
		 	<!--close section -->
		 	<![CDATA[</table>]]>
		</xsl:for-each>
	</xsl:template>

	 <xsl:template match="sect1[//refentry//refsection/programlisting]">
	 		<!-- less than needed for converting html tags in listings so they are printable -->
	 		<xsl:variable name="lt"><xsl:text><![CDATA[<]]></xsl:text></xsl:variable>
	 		<!-- only print section header if it has examples - not sure why this is necessary -->
	 		<xsl:if test="refentry/refsection/programlisting">
			<!--Beginning of section -->
				<xsl:text><![CDATA[<table class='example'><tr><th colspan="2" class="example_heading">]]></xsl:text>
				<xsl:value-of select="title" /> Examples
				<!-- end of section header beginning of function list -->
				<xsl:text><![CDATA[</th></tr>]]></xsl:text>
				<!--only pull the first example section of each function -->
			<xsl:for-each select="refentry//refsection[contains(title,'Example')][1]/programlisting[1]">

				 <xsl:variable name='plainlisting'>
					<xsl:call-template name="globalReplace">
						<xsl:with-param name="outputString" select="."/>
						<xsl:with-param name="target" select="$lt"/>
						<xsl:with-param name="replacement" select="'&amp;lt;'"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name='listing'>
					<xsl:call-template name="break">
						<xsl:with-param name="text" select="$plainlisting" />
					</xsl:call-template>
				</xsl:variable>



				<!-- add row for each function and alternate colors of rows -->
		 		<![CDATA[<tr]]> class="<xsl:choose><xsl:when test="position() mod 2 = 0">evenrow</xsl:when><xsl:otherwise>oddrow</xsl:otherwise></xsl:choose>"<![CDATA[>]]>
		 		<![CDATA[<td><b>]]><xsl:value-of select="ancestor::refentry/refnamediv/refname" /><![CDATA[</b><br /><code>]]><xsl:value-of select="$listing"  disable-output-escaping="no"/><![CDATA[</code></td></tr>]]>
		 	</xsl:for-each>
		 	<![CDATA[</table>]]>
		 	</xsl:if>
		 	<!--close section -->


	</xsl:template>

</xsl:stylesheet>
