<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:param name="removeElementsNamed" select="'|alt|'"/>
	<xsl:param name="removeAttributesNamed" select="'|colwidth|xtrc|xtrf|height|keyref|linking|print|scope|search|'"/>
	
	<xsl:variable name="metaORG" select="'REF and BOARD DESIGN'"/>
	<xsl:variable name="metaRPN" select="'V-ODE-BLUEMIX1'"/>

	<xsl:variable name="ALPHA_UC" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="ALPHA_LC" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="NEWLINE" select="'&#x0A;'"/>
	<xsl:variable name="rootNAME" select="name(node()[1])"/>
	<xsl:variable name="initcap_root" select="concat(translate(substring($rootNAME,1,1),$ALPHA_LC,$ALPHA_UC),translate(substring($rootNAME,2  ),$ALPHA_UC,$ALPHA_LC))"/>
	<xsl:variable name="doctype" select="concat('!DOCTYPE ',$rootNAME,' PUBLIC &quot;-//OASIS//DTD DITA ',$initcap_root,'//EN&quot; &quot;',$rootNAME,'.dtd&quot;') "/>

	<xsl:template match="@*|node()">			
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/">			
		<xsl:value-of select="$NEWLINE"/>
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text>
		<xsl:value-of select="$doctype"/>
		<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		<xsl:value-of select="$NEWLINE"/>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="shortdesc">
			<xsl:if test="not(name(preceding-sibling::element[1])= 'title')">
			<title class="- topic/title "/>
				<xsl:copy>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:if>
	</xsl:template>
	
	<xsl:template match="ph">
		<xsl:copy-of select="./text()"/>
   </xsl:template>

	<xsl:template match="title">

		<xsl:choose>
			<xsl:when test="name(following-sibling::element()[1]) = 'table' and not(./table/title)">
			<table>
				<xsl:copy>
					<xsl:apply-templates/>
					<xsl:apply-templates select="./following-sibling::table[1]/tgroup[1]"/>
			</xsl:copy>
			</table>
		</xsl:when>
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
					<xsl:attribute name="width">
						<xsl:value-of select="following-sibling::p[1]/image/@width"/>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="following-sibling::p[1]/image/@href"/>
					</xsl:attribute>
				</image>
				<xsl:text disable-output-escaping="yes">&lt;/fig&gt;</xsl:text>
			</xsl:when>
			
			<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>
	
	<xsl:template match="table" name="KILLtable">
		<xsl:if test="not(./title)"/>
	</xsl:template>
	
	<xsl:template match="image" name="KILLimage">
		<xsl:if test="not(name(./ancestor::*[1])='fig')"/>
	</xsl:template>
	
	<xsl:template match="p" name="KILLpara">
			<xsl:if test="not(./text()='')">
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//*[contains(name(),'body')]">
		<prolog class="- topic/prolog ">
			<metadata class="- topic/metadata ">
				<data name="Application" class="- topic/data " />
				<data name="IP" class="- topic/data " />
				<data name="Organization" value="{$metaORG}" class="- topic/data " />
				<data name="Package" class="- topic/data " />
				<data name="Packing" class="- topic/data " />
				<data name="Product" value="{$metaRPN}" class="- topic/data " />
				<data name="Confidentiality" value="" class="- topic/data " />
				<data name="Technology" class="- topic/data " />
				<data name="Package option" class="- topic/data " />
			</metadata>
		</prolog>
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()[contains($removeElementsNamed,concat('|', name(), '|'))]"/>
	<xsl:template match="attribute()[contains($removeAttributesNamed,concat('|', name(), '|'))]"/>	
	
	<!--	<xsl:template match="/">

		<xsl:variable name="initcap_root">
			<xsl:value-of select="concat(translate(substring($rootNAME,1,1),$ALPHA_LC,$ALPHA_UC),translate(substring($rootNAME,2  ),$ALPHA_UC,$ALPHA_LC))"/>
		</xsl:variable>
		<xsl:variable name="doctype" select="concat('!DOCTYPE ',$rootNAME,' PUBLIC &quot;-//OASIS//DTD DITA ',$initcap_root,'//EN&quot; &quot;',$rootNAME,'.dtd&quot;') "/>
		<xsl:value-of select="$NEWLINE"/>
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text>
		<xsl:value-of select="$doctype"/>
		<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
		<xsl:value-of select="$NEWLINE"/>
	</xsl:template>

-->	<!--<xsl:template match="shortdesc">
		<xsl:if test="not(preceding-sibling::title)" ><title class="- topic/title "/></xsl:if>
		<xsl:copy-of select="."/>
	</xsl:template>
-->
	<!--<xsl:template match="title">
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
						<xsl:attribute name="width">
							<xsl:value-of select="following-sibling::p[1]/image/@width"/>
						</xsl:attribute>
						<xsl:attribute name="href">
							<xsl:value-of select="following-sibling::p[1]/image/@href"/>
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
	</xsl:template>-->
	
	<!--<xsl:template match="p">
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

	<xsl:template name="killELEMENT"/>-->
	
</xsl:stylesheet>
