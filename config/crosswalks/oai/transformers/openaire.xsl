<?xml version="1.0" encoding="UTF-8"?>
<!-- 

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

	Developed by DSpace @ Lyncode <dspace@lyncode.com> 
	Following OpenAIRE Guidelines 1.1:
		- http://www.openaire.eu/component/content/article/207

 -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://www.lyncode.com/xoai">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
 
 	<!-- Formatting dc.date.issued -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field/text()">
		<xsl:call-template name="formatdate">
			<xsl:with-param name="datestr" select="." />
		</xsl:call-template>
	</xsl:template>
	
 	<!-- KM: Prefixing dc.date.embargoEndDate -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='embargoEndDate']/doc:element/doc:field/text()">
		<xsl:value-of select="concat('info:eu-repo/date/embargoEnd/', .)" />
	</xsl:template>
	
	<!-- Removing other dc.date.* -->
	<!--<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued']" />-->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued' and @name!='embargoEndDate']" />

	<!-- Prefixing dc.type -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field/text()">
		<xsl:call-template name="addPrefix">
			<xsl:with-param name="value" select="." />
			<xsl:with-param name="prefix" select="'info:eu-repo/semantics/'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Prefixing and Modifying dc.rights -->
	<!-- Removing unwanted -->
	<!--<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element" />-->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='accessRights']/doc:element/doc:element" />
	<!-- Replacing -->
	<!--<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field/text()">-->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='accessRights']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="contains(., 'open access')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'openAccess')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'restrictedAccess')">
				<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'embargoedAccess')">
				<xsl:text>info:eu-repo/semantics/embargoedAccess</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- KM: Should probably be closedAccess here? -->
				<!--<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>-->
				<xsl:text>info:eu-repo/semantics/closedAccess</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- AUXILIARY TEMPLATES -->
	
	<!-- dc.type prefixing -->
	<xsl:template name="addPrefix">
		<xsl:param name="value" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="starts-with($value, $prefix)">
				<xsl:value-of select="$value" />
			</xsl:when>
			<!-- KM: Replace Munin types with openaire-standard types -->
			<xsl:when test="contains($value, 'Master thesis')">
				<xsl:value-of select="concat($prefix, 'masterThesis')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Journal article')">
				<xsl:value-of select="concat($prefix, 'article')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Doctoral thesis')">
				<xsl:value-of select="concat($prefix, 'doctoralThesis')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Research report')">
				<xsl:value-of select="concat($prefix, 'report')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Conference object')">
				<xsl:value-of select="concat($prefix, 'conferenceObject')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Book')">
				<xsl:value-of select="concat($prefix, 'book')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Chapter')">
				<xsl:value-of select="concat($prefix, 'bookPart')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Chronicle')">
				<xsl:value-of select="concat($prefix, 'other')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Working paper')">
				<xsl:value-of select="concat($prefix, 'workingPaper')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Lecture')">
				<xsl:value-of select="concat($prefix, 'lecture')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Preprint')">
				<xsl:value-of select="concat($prefix, 'preprint')" />
			</xsl:when>
			<xsl:when test="contains($value, 'Others')">
				<xsl:value-of select="concat($prefix, 'other')" />
			</xsl:when>
			<!-- KM: Just write the value here, since this will match the other Munin types that are not mapped. -->
			<xsl:otherwise>
				<!--<xsl:value-of select="concat($prefix, $value)" />-->
				<xsl:value-of select="$value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Date format -->
	<xsl:template name="formatdate">
		<xsl:param name="datestr" />
		<xsl:variable name="sub">
			<xsl:value-of select="substring($datestr,1,10)" />
		</xsl:variable>
		<xsl:value-of select="$sub" />
	</xsl:template>
</xsl:stylesheet>
