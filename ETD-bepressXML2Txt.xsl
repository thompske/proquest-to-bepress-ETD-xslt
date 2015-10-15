<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- Copyright 2015 Kelly Thompson
		Main XSLT from this document was written by Shawn Averkamp and Joanna Lee in 2009.
		Modified for use by Kelly Thompson in 2015.
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
			
	<xsl:output method="text" version="1.0" encoding="UTF-8"/>
	<!-- Transform of bepress XML to a tab-delimited file for Electronic Theses and Dissertations (ETDs) -->
	
	<xsl:template match="/">
		<!-- Header row -->
		<xsl:text>URL&#9;Title&#9;First Name&#9;Middle Name&#9;Last Name&#9;Name Suffix&#9;Rights holder&#9;Document Type&#9;Degree Name&#9;Department&#9;Advisor1&#9;Advisor2&#9;Advisor3&#9;Institution&#9;Publication Date&#9;Copyright Date&#9;Embargo Date&#9;Disciplines&#9;Keywords&#9;Abstract&#9;&#xa;</xsl:text>
		
		<xsl:for-each select="documents/document">
			
			<xsl:value-of select="fulltext-url"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="normalize-space(title)"/>
			<xsl:text>&#9;</xsl:text>
			
			<!-- author name -->
			<xsl:value-of select="authors/author/fname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/mname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/lname"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/suffix"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='rights_holder']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="document-type"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="degree_name"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="department"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='advisor1']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='advisor2']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='advisor3']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="authors/author/institution"/>
			<xsl:text>&#9;</xsl:text>
						
			<xsl:value-of select="publication-date"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='copyright_date']/value"/>
			<xsl:text>&#9;</xsl:text>
			
			<xsl:value-of select="fields/field[@name='embargo_date']/value"/>
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
			
			<!-- Combine abstract into one field separated by <p> tags -->
			<xsl:for-each select="abstract/p">
				<xsl:text>&lt;p&gt;</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text>&lt;/p&gt;</xsl:text>
			</xsl:for-each>
			<xsl:text>&#9;</xsl:text>		
			
			<xsl:text>&#xa;</xsl:text>
		
		</xsl:for-each>
		
	</xsl:template>
</xsl:stylesheet>
