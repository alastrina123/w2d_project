<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="shortdesc">
		<title class="- topic/title "/>
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="title">
		<xsl:choose>
			<xsl:when test="following-sibling::*[1]/*[1]/name()='image'">
				<fig id="{concat('fig_',generate-id())}" frame="all">
					<title class="fig/title">
						<xsl:value-of select="text()"/>
					</title>
					<image id="{concat('figIMG_',generate-id())}" align="center" placement="break"
						class="- topic/image ">
						<xsl:attribute name="href">
							<xsl:value-of select="following-sibling::p[1]/image[@href]"/>
						</xsl:attribute>
					</image>
				</fig>
				<xsl:call-template name="killELEMENT"/>
			</xsl:when>
			<xsl:when test="following-sibling::*[1]/name()='table'">
				<table id="{concat('table_',generate-id())}" class="- topic/table "
					outputclass="DX:FootnotesInTable">
					<title class="- table/title ">
						<xsl:value-of select="text()"/>
					</title>
					<xsl:copy-of select="following-sibling::table/tgroup"/>
				</table>
				<xsl:call-template name="killELEMENT"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="p">
		<xsl:choose>
			<xsl:when test="descendant::*[1]/name()='image'">
				<xsl:call-template name="killELEMENT"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template match="table">
		<xsl:choose>
			<xsl:when test="not(descendant::*[1]/name()='title')">
				<xsl:call-template name="killELEMENT"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template name="killELEMENT"/>
	
</xsl:stylesheet>
