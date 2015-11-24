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
				<xsl:text disable-output-escaping="yes">&lt;fig id=&quot;</xsl:text>
				<xsl:choose>
					<xsl:when test="string(following-sibling::*[1]/@id)"><xsl:value-of select="following-sibling::*[1]/@id"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="concat('fig_',generate-id())"/></xsl:otherwise>
				</xsl:choose>
				<xsl:text disable-output-escaping="yes">&quot; frame="all" class="- topic/fig "&gt;</xsl:text>
					<title class="- topic/title ">
						<xsl:value-of select="text()"/>
					</title>
					<image id="{concat('figIMG_',generate-id())}" align="center" placement="break"
						class="- topic/image ">
						<xsl:attribute name="href">
							<xsl:value-of select="following-sibling::p[1]/image[@href]"/>
						</xsl:attribute>
					</image>
				<xsl:text disable-output-escaping="yes">&lt;/fig&gt;</xsl:text>
				<xsl:call-template name="killELEMENT"/>
			</xsl:when>
			<xsl:when test="following-sibling::*[1]/name()='table'">
				<table id="{concat('table_',generate-id())}" class="- topic/table "
					outputclass="Dx:FootnotesInTable">
					<title class="- topic/title ">
						<xsl:value-of select="text()"/>
					</title>
					<xsl:copy-of select="following-sibling::*[1]/tgroup"/>
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

	<xsl:template match="xref/text()">
		<xsl:choose>
			<xsl:when test="xref/@scope='external'"><xsl:copy-of select="."/></xsl:when>
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
