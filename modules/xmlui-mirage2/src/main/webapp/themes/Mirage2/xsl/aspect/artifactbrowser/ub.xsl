
<!--
     Misc templates added by UB

     Author: Karl Magnus Nilsen

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!-- New doctoral theses box on front page -->
    <xsl:template match="/dri:document/dri:body/dri:div[@n='new-doctoral-theses']">
      <div class="new-doctoral-theses col-md-6">
	<xsl:apply-templates />

      </div>

      <div style="clear: both"></div>

    </xsl:template>

    <!-- Community list on front page -->
    <xsl:template match="/dri:document/dri:body/dri:div[@n='comunity-browser']">
      
      <xsl:variable name="uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']" />
        <xsl:choose>
	  <xsl:when test="$uri = ''">
	    <div class="community-list col-md-6">
	      <xsl:apply-templates />
	    </div>
	  </xsl:when>
	  
	  <xsl:otherwise>
	    <xsl:apply-templates />
	  </xsl:otherwise>

	</xsl:choose>

    </xsl:template>

</xsl:stylesheet>
