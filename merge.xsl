<?xml version="1.0" encoding="UTF-8"?>
<!-- 
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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="xml"/>
    <xsl:template match="/">
        
        <xsl:copy>
            <xsl:apply-templates mode="rootcopy"/>
        </xsl:copy>
            
    </xsl:template>
    
    <xsl:template match="node()" mode="rootcopy">
        <xsl:copy>
            <xsl:variable name="folderURI" select="resolve-uri('.',base-uri())"/>
            <xsl:for-each select="collection(concat($folderURI, '?select=*.xml;recurse=yes'))/*/node()">
                <xsl:if test="documents">
                    <xsl:attribute name="xsi:noNamespaceSchemaLocation" namespace="http://www.bepress.com/document-import.xsd" />
                </xsl:if>
                <xsl:apply-templates mode="copy" select="."/>
            </xsl:for-each>
        </xsl:copy>
            
    </xsl:template>
    
    <!-- Deep copy template -->
    <xsl:template match="node()|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates mode="copy" select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template name="sorting">
        <xsl:for-each select="documents/document">
            <xsl:sort select="lname"/>
            <xsl:sort select="fname"/>
        </xsl:for-each>
    </xsl:template>

    
    <!-- Handle default matching -->
    <xsl:template match="*"/>
</xsl:stylesheet>