<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- Copyright 2009 Shawn Averkamp and Joanna Lee
		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		
		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
	-->
	
	<xsl:output method="text" version="1.0" encoding="iso-8859-1"/>
	<!-- Transform of bepress XML to a tab-delimited file for Electronic Theses and Dissertations (ETDs) -->
	
	<xsl:template match="/">
		<!-- Header row -->
		<xsl:text>title&#9;publication-date&#9;publication_date_date_format&#9;email&#9;institution&#9;lname&#9;fname&#9;mname&#9;suffix&#9;disciplines&#9;keywords&#9;abstract&#9;fulltext-url&#9;document-type&#9;degree_name&#9;department&#9;abstract_format&#9;language&#9;provenance&#9;copyright_date&#9;embargo_date&#9;file_size&#9;fileformat&#9;rights-holder&#9;advisor1&#9;advisor2&#9;advisor3&#9;major&#9;&#xa;</xsl:text>
		
		<xsl:for-each select="documents/document">
			
			<xsl:value-of select="normalize-space(title)"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="publication-date"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="publication_date_date_format"/>
			<xsl:text>&#9;</xsl:text>
			
			<!-- author name -->
			
			<xsl:value-of select="authors/author/email"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/institution"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/lname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/fname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/mname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/suffix"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:for-each select="disciplines/discipline">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text>; </xsl:text>
			</xsl:for-each>
			<xsl:text>&#9;</xsl:text>
			
			<!-- Combine keywords into one field separated by commas -->
			<xsl:for-each select="keywords/keyword">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text>, </xsl:text>
			</xsl:for-each>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:for-each select="abstract/p">
				<xsl:text>&lt;p&gt;</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text>&lt;/p&gt;</xsl:text>
			</xsl:for-each>
			<xsl:text>&#9;</xsl:text>	
			
			<xsl:value-of select="fulltext-url"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="document-type"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="degree_name"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="department"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="abstract_format"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='language']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='provenance']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='copyright_date']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='embargo_date']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='file_size']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='fileformat']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='rights_holder']/value"/>
			<xsl:text>&#9;</xsl:text>		
			
			<xsl:value-of select="fields/field[@name='advisor1']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='advisor2']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='advisor3']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='major']/value"/>
			<xsl:text>&#9;</xsl:text>

			<xsl:text>&#xa;</xsl:text>
		
		</xsl:for-each>
		
	</xsl:template>
</xsl:stylesheet>
