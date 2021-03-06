<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

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
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">

        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">

        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>

            <div class="row">
                <div class="col-sm-4">
			<!-- KM: Add and reorganize metadata fields -->
			<xsl:call-template name="itemSummaryView-DIM-URI"/>
			<xsl:call-template name="itemSummaryView-DIM-doi"/>
            <div class="row">
				<div class="col-xs-6 col-sm-12">
			        <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                </div>
			
                <div class="col-xs-6 col-sm-12">
				    <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                </div>
            </div>

			<xsl:call-template name="itemSummaryView-DIM-embargo"/>
 
            <xsl:call-template name="itemSummaryView-DIM-date"/>
		    <xsl:call-template name="itemSummaryView-DIM-type"/>

        <!-- optional: Altmeric.com badge and PlumX widget -->
		<xsl:if test='confman:getProperty("altmetrics", "altmetric.enabled") and ($identifier_doi or $identifier_handle)'>
            <xsl:call-template name='impact-altmetric'/>
		</xsl:if>
        <xsl:if test='confman:getProperty("altmetrics", "plumx.enabled") and $identifier_doi'>
            <xsl:call-template name='impact-plumx'/>
        </xsl:if>

		<!-- KM: Add ShareThis buttons -->
		<xsl:call-template name="share-buttons"/>


				</div>
                <div class="col-sm-8">
		  <xsl:call-template name="itemSummaryView-DIM-authors"/>
		  <xsl:call-template name="itemSummaryView-DIM-editor"/>
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
		    <xsl:call-template name="itemSummaryView-DIM-description"/>
			<xsl:call-template name="itemSummaryView-DIM-hasversion"/>
			<xsl:call-template name="itemSummaryView-DIM-isversionof"/>
			<xsl:call-template name="itemSummaryView-DIM-haspart"/>
			<xsl:call-template name="itemSummaryView-DIM-ispartof"/>
			<xsl:call-template name="itemSummaryView-DIM-isbasedon"/>
		    <xsl:call-template name="itemSummaryView-DIM-publisher"/>
		    <xsl:call-template name="itemSummaryView-DIM-series"/>
		    <xsl:call-template name="itemSummaryView-DIM-citation"/>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-4">
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
		</div>
		<div class="col-sm-8">
                    <xsl:call-template name="itemSummaryView-collections"/>
					<xsl:call-template name="itemSummaryView-DIM-rightsholder"/>
		</div>
	    </div>

        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>	

					<!-- KM: Add link to bitstream on thumbnail -->
                    <xsl:variable name="href">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
					</xsl:variable>

					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$href"/>
						</xsl:attribute>

                    <img alt="Thumbnail">
                        <xsl:attribute name="src">

							<!-- Checking if Thumbnail is restricted and if so, show a restricted image -->
							<xsl:choose>
								<xsl:when test="contains($src,'isAllowed=n')">
                                        <xsl:value-of select="$theme-path"/>
                                        <xsl:text>images/restricted_</xsl:text>
                                        <xsl:value-of select="$current_locale"/>
                                        <xsl:text>.png</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$src"/>
								</xsl:otherwise>
							</xsl:choose>

                        </xsl:attribute>
                    </img>

					</a>

                </xsl:when>
                <xsl:otherwise>
                    <img alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
	      <!-- KM: Show header -->
                <!--<h5 class="visible-xs"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>-->
		<h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
			        <!-- KM: Allow html-tags -->
                                <!--<xsl:copy-of select="node()"/>-->
				<xsl:value-of select="node()" disable-output-escaping="yes"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
      <!-- KM: Add dc.contributor.authorexternal, remove dc.creator and dc.contributor -->
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='contributor'][@qualifier='authorexternal' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
			    <!-- KM: Use semicolon to separate authors -->
			    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
		    <!-- KM: Added dc.contributor.authorexternal -->
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='authorexternal']">
		      <!-- Add divider before first element, since the last dc.contributor.author element will not have one -->
		      <xsl:text>; </xsl:text>
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='authorexternal']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
			    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='authorexternal']) != 0">
			      <xsl:text>; </xsl:text>
			    </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
		    <!-- KM: Do not show dc.creator or dc.contributor -->
		    <!--
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
		    -->
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <!-- KM: Use semicolon to separate authors, so remove div here -->
        <!--<div>-->
			<a>
				<xsl:attribute name="href">
					<xsl:text>/munin/browse?type=author&amp;value=</xsl:text>
					<xsl:copy-of select="node()"/>
				</xsl:attribute>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
			<xsl:copy-of select="node()"/>
			</a>
        <!--</div>-->
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.description -->
    <xsl:template name="itemSummaryView-DIM-description">
        <xsl:if test="dim:field[@element='description' and not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
		        <xsl:value-of select="node()" disable-output-escaping="yes"/>
			<xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
		</div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.type -->
    <xsl:template name="itemSummaryView-DIM-type">
        <xsl:if test="dim:field[@element='type'][not(@qualifier) and descendant::text()]">
            <div class="simple-item-view-type item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-type</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='type'][not(@qualifier)]">
		      
		      <xsl:copy-of select="./node()"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='type' and not(@qualifier)]) != 0">
			<br/>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.isversionof -->
    <xsl:template name="itemSummaryView-DIM-isversionof">
        <xsl:if test="dim:field[@element='relation' and @qualifier='isversionof' and descendant::text()]">
            <div class="simple-item-view-ispartof item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-isversionof</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='isversionof']">
		      
						<xsl:value-of select="node()" disable-output-escaping="yes"/>

						<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='isversionof']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.hasversion -->
    <xsl:template name="itemSummaryView-DIM-hasversion">
        <xsl:if test="dim:field[@element='relation' and @qualifier='hasversion' and descendant::text()]">
            <div class="simple-item-view-haspart item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-hasversion</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='hasversion']">
		      
						<xsl:value-of select="node()" disable-output-escaping="yes"/>

						<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='hasversion']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.ispartof -->
    <xsl:template name="itemSummaryView-DIM-ispartof">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartof' and descendant::text()]">
            <div class="simple-item-view-ispartof item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-ispartof</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartof']">
		      
						<xsl:value-of select="node()" disable-output-escaping="yes"/>

						<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartof']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.haspart -->
    <xsl:template name="itemSummaryView-DIM-haspart">
        <xsl:if test="dim:field[@element='relation' and @qualifier='haspart' and descendant::text()]">
            <div class="simple-item-view-haspart item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-haspart</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='haspart']">
		      
						<xsl:value-of select="node()" disable-output-escaping="yes"/>

						<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='haspart']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.doi -->
    <xsl:template name="itemSummaryView-DIM-doi">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='doi' and descendant::text()]">
            <div class="simple-item-view-doi item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-doi</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
						<xsl:choose>
							<xsl:when test="starts-with(., '10.')">
								<a>
									<xsl:attribute name="href">
										<xsl:text>https://doi.org/</xsl:text>
										<xsl:value-of select="node()"/>
									</xsl:attribute>
									<xsl:text>https://doi.org/</xsl:text>
									<xsl:value-of select="node()"/>
								</a>
							</xsl:when>
							<xsl:when test="starts-with(., 'http')">
								<a>
									<xsl:attribute name="href">
										<xsl:value-of select="node()"/>
									</xsl:attribute>
									<xsl:value-of select="node()"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="node()" />
							</xsl:otherwise>
						</xsl:choose>

						<xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.isbasedon -->
    <xsl:template name="itemSummaryView-DIM-isbasedon">
        <xsl:if test="dim:field[@element='relation' and @qualifier='isbasedon' and descendant::text()]">
            <div class="simple-item-view-isbasedon item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-isbasedon</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='isbasedon']">
		      
						<xsl:value-of select="node()" disable-output-escaping="yes"/>

						<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='isbasedon']) != 0">
							<div class="spacer">&#160;</div>
		     		    </xsl:if>

                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.publisher -->
    <xsl:template name="itemSummaryView-DIM-publisher">
        <xsl:if test="dim:field[@element='publisher'][not(@qualifier) and descendant::text()]">
            <div class="simple-item-view-publisher item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='publisher'][not(@qualifier)]">
		      
		      <xsl:copy-of select="./node()"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='publisher' and not(@qualifier)]) != 0">
			<br/>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.relation.ispartofseries -->
    <xsl:template name="itemSummaryView-DIM-series">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries' and descendant::text()]">
            <div class="simple-item-view-series item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-series</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
		      
		      <xsl:copy-of select="./node()"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartofseries']) != 0">
			<br/>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.identifier.citation -->
    <xsl:template name="itemSummaryView-DIM-citation">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='citation' and descendant::text()]">
            <div class="simple-item-view-citation item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-citation</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='citation']">
		      
		        <xsl:value-of select="node()" disable-output-escaping="yes"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='citation']) != 0">
			<br/>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.contributor.editor -->
    <xsl:template name="itemSummaryView-DIM-editor">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='editor' and descendant::text()]">
            <div class="simple-item-view-editor item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-editor</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='contributor' and @qualifier='editor']">
		      
		      <xsl:copy-of select="./node()"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='editor']) != 0">
			<xsl:text>; </xsl:text>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

	<!-- KM: Added field - dc.date.embargoEndDate -->
    <xsl:template name="itemSummaryView-DIM-embargo">
        <xsl:if test="dim:field[@element='date' and @qualifier='embargoEndDate' and descendant::text()]">
            <!--<div class="simple-item-view-embargo item-page-field-wrapper table">-->
            <div class="simple-item-view-embargo alert alert-warning">
				<i class="glyphicon glyphicon-lock" aria-hidden="true"></i>
				<xsl:text>&#160;</xsl:text>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.item-embargo</i18n:text>
				<xsl:text>&#160;</xsl:text>
                <span class="bold">
					<xsl:for-each select="dim:field[@element='date' and @qualifier='embargoEndDate']">

						<xsl:copy-of select="./node()"/>

						<xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='embargoEndDate']) != 0">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</span>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.type.version -->
    <xsl:template name="itemSummaryView-DIM-typeversion">
        <xsl:if test="//mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='version' and descendant::text()]">
		    <xsl:variable name="typeversion" select="//mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='version']/node()"/>
                <span>
					<i18n:text>
						<xsl:value-of select="concat('xmlui.dri2xhtml.METS-1.0.typeversion.', $typeversion)"/>
					</i18n:text>
					<xsl:text>&#160;</xsl:text>
                </span>
        </xsl:if>
    </xsl:template>

    <!-- KM: Added field - dc.rights.holder -->
    <xsl:template name="itemSummaryView-DIM-rightsholder">
        <xsl:if test="dim:field[@element='rights' and @qualifier='holder'and descendant::text()]">
            <div class="simple-item-view-publisher item-page-field-wrapper table">
                <span>
                    <xsl:for-each select="dim:field[@element='rights' and @qualifier='holder']">
		      
		      <xsl:copy-of select="./node()"/>
		      
		      <xsl:if test="count(following-sibling::dim:field[@element='rights' and @qualifier='holder']) != 0">
			<br/>
		      </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

		    <!-- KM: Remove LICENSE from the file view -->		    
		    <!--<xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">-->
		    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file">
		    <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </div>

	<!-- KM: Add file description and mimetype after file name (next line) -->
	<!-- KM: Display dc.type.version in display mode before file description (normally they will not both appear) -->
	<div style="margin-left: 18px; margin-bottom: 5px;">
      <xsl:call-template name="itemSummaryView-DIM-typeversion"/>
	  <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
		  <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" disable-output-escaping="yes"/>
		  <xsl:text>&#160;</xsl:text>
	  </xsl:if>
	  <xsl:text>(</xsl:text>
	  <xsl:call-template name="getFileTypeDesc">
	    <xsl:with-param name="mimetype">
	      <xsl:value-of select="substring-before($mimetype,'/')"/>
	      <xsl:text>/</xsl:text>
	      <xsl:choose>
		<xsl:when test="contains($mimetype,';')">
		  <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="substring-after($mimetype,'/')"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	  </xsl:call-template>
	  <xsl:text>)</xsl:text>
	</div>
	

    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
	  
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">


                            <!-- KM: Checking if Thumbnail is restricted and if so, show a restricted image -->
							<xsl:variable name="src">
								<xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
							</xsl:variable>
                            <xsl:choose>
                                <xsl:when test="contains($src,'isAllowed=n')">
                                        <xsl:value-of select="$theme-path"/>
                                        <xsl:text>images/restricted_</xsl:text>
                                        <xsl:value-of select="$current_locale"/>
                                        <xsl:text>.png</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
										<xsl:value-of select="$src" />
<!--
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
-->								</xsl:otherwise>
							</xsl:choose>
							

                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>



                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>
	    

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
		
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-0 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>

        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <!-- KM: ShareThis buttons -->
    <xsl:template name="share-buttons">

        <div class="sharethis-inline-share-buttons"></div>
      
    </xsl:template>

    <xsl:template name='impact-altmetric'>
        <div id='impact-altmetric'>
            <!-- Altmetric.com -->
            <script type="text/javascript" src="{concat($scheme, 'd1bxh8uas1mnw7.cloudfront.net/assets/embed.js')}">&#xFEFF;
            </script>
            <div id='altmetric'
                 class='altmetric-embed'>
                <xsl:variable name='badge_type' select='confman:getProperty("altmetrics", "altmetric.badgeType")'/>
                <xsl:if test='boolean($badge_type)'>
                    <xsl:attribute name='data-badge-type'><xsl:value-of select='$badge_type'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='badge_popover' select='confman:getProperty("altmetrics", "altmetric.popover")'/>
                <xsl:if test='$badge_popover'>
                    <xsl:attribute name='data-badge-popover'><xsl:value-of select='$badge_popover'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='badge_details' select='confman:getProperty("altmetrics", "altmetric.details")'/>
                <xsl:if test='$badge_details'>
                    <xsl:attribute name='data-badge-details'><xsl:value-of select='$badge_details'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='no_score' select='confman:getProperty("altmetrics", "altmetric.noScore")'/>
                <xsl:if test='$no_score'>
                    <xsl:attribute name='data-no-score'><xsl:value-of select='$no_score'/></xsl:attribute>
                </xsl:if>

                <xsl:if test='confman:getProperty("altmetrics", "altmetric.hideNoMentions")'>
                    <xsl:attribute name='data-hide-no-mentions'>true</xsl:attribute>
                </xsl:if>

                <xsl:variable name='link_target' select='confman:getProperty("altmetrics", "altmetric.linkTarget")'/>
                <xsl:if test='$link_target'>
                    <xsl:attribute name='data-link-target'><xsl:value-of select='$link_target'/></xsl:attribute>
                </xsl:if>

				<xsl:if test='$identifier_doi'>
                    <xsl:attribute name='data-doi'><xsl:value-of select='$identifier_doi'/></xsl:attribute>
                </xsl:if>
                <xsl:if test='$identifier_handle'>
                    <xsl:attribute name='data-handle'><xsl:value-of select='$identifier_handle'/></xsl:attribute>
				</xsl:if>
                &#xFEFF;
            </div>
        </div>
    </xsl:template>

    <xsl:template name="impact-plumx">
        <div id="impact-plumx" style="clear:right">
            <!-- PlumX <http://plu.mx> -->
            <xsl:variable name="plumx_type" select="confman:getProperty('altmetrics', 'plumx.widget-type')"/>
            <xsl:variable name="plumx-script-url">
                <xsl:choose>
                    <xsl:when test="boolean($plumx_type)">
                        <xsl:value-of select="concat($scheme, 'd39af2mgp1pqhg.cloudfront.net/widget-', $plumx_type, '.js')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($scheme, 'd39af2mgp1pqhg.cloudfront.net/widget-popup.js')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <script type="text/javascript" src="{$plumx-script-url}">&#xFEFF;
            </script>

            <xsl:variable name="plumx-class">
                <xsl:choose>
                    <xsl:when test="boolean($plumx_type) and ($plumx_type != 'popup')">
                        <xsl:value-of select="concat('plumx-', $plumx_type)"/>
                    </xsl:when>
                    <xsl:otherwise>plumx-plum-print-popup</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <a>
                <xsl:attribute name="id">plumx</xsl:attribute>
                <xsl:attribute name="class"><xsl:value-of select="$plumx-class"/></xsl:attribute>
                <xsl:attribute name="href">https://plu.mx/pitt/a/?doi=<xsl:value-of select="$identifier_doi"/></xsl:attribute>

                <xsl:variable name="plumx_data-popup" select="confman:getProperty('altmetrics', 'plumx.data-popup')"/>
                <xsl:if test="$plumx_data-popup">
                    <xsl:attribute name="data-popup"><xsl:value-of select="$plumx_data-popup"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('altmetrics', 'plumx.data-hide-when-empty')">
                    <xsl:attribute name="data-hide-when-empty">true</xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('altmetrics', 'plumx.data-hide-print')">
                    <xsl:attribute name="data-hide-print">true</xsl:attribute>
                </xsl:if>

                <xsl:variable name="plumx_data-orientation" select="confman:getProperty('altmetrics', 'plumx.data-orientation')"/>
                <xsl:if test="$plumx_data-orientation">
                    <xsl:attribute name="data-orientation"><xsl:value-of select="$plumx_data-orientation"/></xsl:attribute>
                </xsl:if>

                <xsl:variable name="plumx_data-width" select="confman:getProperty('altmetrics', 'plumx.data-width')"/>
                <xsl:if test="$plumx_data-width">
                    <xsl:attribute name="data-width"><xsl:value-of select="$plumx_data-width"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('altmetrics', 'plumx.data-border')">
                    <xsl:attribute name="data-border">true</xsl:attribute>
                </xsl:if>
                &#xFEFF;
            </a>

        </div>
    </xsl:template>

</xsl:stylesheet>
