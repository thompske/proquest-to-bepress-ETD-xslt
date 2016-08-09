<?xml version='1.0' encoding="UTF-8" ?>

<!-- Copyright 2015 Kelly Thompson
	Originally created by Shawn Averkamp and Joanna Lee
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. -->
	
<!--
	1/15/10 - removed title case option from names (author and advisor) to retain capilization as input since most were not in all caps; 
	added bibliographic page number section; added note for optimized pdf; standardized degree names, added document-type and disciplines, replaced encoding in abstract,
	changed title to only change case if no lower case vowels
	4/29/10 - changed encoding to UTF-8; added language
	7/7/10 moved local fields to degree name, department, language; added abstract_format
-->

<!-- 
	2013 - XSL was acquired and heavily modified by Logan Jewett for usage by Iowa State University. Many areas were
	added, removed, or modified.
 -->

<!-- 
	2015-04-28 - XSL was modified by Kelly Thompson.  
	-file_size (or pages), changed " .p" to " pages" to reflect RDA content standard.
	-Updated embargo date processing for files from ProQuest produced 11/20/2014 until 02/25/2015. 
	YOU NEED TO FILL IN YOUR OWN FILE SERVER URL ON LINE 1486.
	
	2015-09-30 - XSLT was modified by Kelly Thompson for a batch of embargoed dissertations received 2015-09-25.
	The embargo dates in this XML were not formatted consistently - some conform to the old embargo date format from the 
	previous xsd, some were in the buggy form (produced in batches from about November 20, 2014 until February 25, 2015),
	and some conform to the "new" DTD that ProQuest is supposed to be using for ETDs.  This XSLT should
	adequately deal with embargo dates in any of the three formats.
	
	HOWEVER, I highly recommend that you look at the XML you received to ensure that the embargo data is in the 
	indicated fields, and that you perform quality control checks on the resulting crosswalked XML before uploading 
	to your repository.  We have found that the data we receive is not of a very high quality, and needs a human eye
	to reach the quality we are aiming for with our metadata. 
	
	I also added in functionality to replace several functions of the "ETD-CON" tool developed by Logan Jewett.
	These functions of the ETD-CON tool ceased working with the Java 8 update due to some deprecated code, 
	so we needed to incorporate:
	* converting degree names to conform to a controlled vocabulary
	* converting ProQuest disciplines to bepress disciplines
	* converting department names from PQ to conform to the repository version of those dept. names.
	
	This transformation will need to be customized for any institution adopting this code.
	
 -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://www.metaphoricalweb.org/xmlns/string-utilities"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:util="http://blank">

	<xsl:output method="xml" indent="yes"/>

	<!-- Transform of ProQuest XML to Digital Commons XML Schema for Electronic Theses and Dissertations (ETDs) -->

	<!-- function to transform title from all caps to title case (stopwords included) -->
	<xsl:function name="str:title-case" as="xs:string">
		<xsl:param name="expr"/>
		<xsl:variable name="tokens" select="tokenize($expr, '(~)|( )')"/>
		<xsl:variable name="titledTokens"
			select="for $token in $tokens return 
			concat(upper-case(substring($token,1,1)),
			lower-case(substring($token,2)))"/>
		<xsl:value-of select="$titledTokens"/>
	</xsl:function>

	<xsl:function name="util:strip-tags">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, '&lt;')">
				<xsl:value-of
					select="concat(substring-before($text, '&lt;'),
       					 util:strip-tags(substring-after($text, '&gt;')))"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="/">
		<documents xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:noNamespaceSchemaLocation="http://www.bepress.com/document-import.xsd">

			<xsl:for-each select="DISS_submission">
				<document>

					<title>
						<xsl:variable name="title" select="DISS_description/DISS_title"/>

						<xsl:choose>
							<xsl:when test="contains($title,'a')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'e')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'i')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'o')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'u')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="DISS_description/DISS_title"/>
								<xsl:variable name="hyphentitle" select="replace($title, '-', '-~')"/>
								<xsl:value-of
									select="normalize-space(replace(str:title-case((util:strip-tags($hyphentitle))), '- ', '-'))"
								/>
							</xsl:otherwise>
						</xsl:choose>
					</title>

					<!-- We've used DISS_comp_date as our publication date, which is generally represented as yyyy, but if DISS_accept_date is preferred, this will transform date to ISO 8601 format (yyyy-mm-dd).  -->
					<publication-date>
						<xsl:variable name="datestr">
							<xsl:value-of select="DISS_description/DISS_dates/DISS_accept_date"/>
						</xsl:variable>
						<xsl:variable name="month" select="substring-before($datestr,'/')" />
						<xsl:variable name="day" select="substring-before(substring-after($datestr,'/'),'/')" />
						<xsl:variable name="year" select="substring-after(substring-after($datestr,'/'),'/')" />
						<xsl:value-of select="$year"/>
						<xsl:value-of select="'-'" />
						<xsl:if test="string-length($month) = 1">
							<xsl:value-of select="'0'" />
						</xsl:if>
						<xsl:value-of select="$month" />
						<xsl:value-of select="'-'" />
						<xsl:if test="string-length($day) = 1">
							<xsl:value-of select="'0'" />
						</xsl:if>
						<xsl:value-of select="$day" />
					</publication-date>
					<publication_date_date_format>YYYY-MM-DD</publication_date_date_format>

					<!-- Author -->
					<authors>
						<xsl:for-each select="DISS_authorship/DISS_author">
							<author xsi:type="individual">
								<email>
									<xsl:value-of select="DISS_contact[@type='current']/DISS_email"
									/>
								</email>
								<institution>Iowa State University</institution>
								<lname>
									<xsl:variable name="lastname" select="DISS_name/DISS_surname"/>
									<xsl:variable name="hyphenlastname"
										select="replace($lastname, '-', '-~')"/>
									<xsl:value-of
										select="replace(str:title-case(normalize-space($hyphenlastname)), '- ', '-')"
									/>
								</lname>
								<fname>
									<xsl:variable name="firstname" select="DISS_name/DISS_fname"/>
									<xsl:variable name="hyphenfirstname"
										select="replace($firstname, '-', '-~')"/>
									<xsl:value-of
										select="replace(str:title-case(normalize-space($hyphenfirstname)), '- ', '-')"
									/>
								</fname>
								<mname>
									<xsl:variable name="middlename" select="DISS_name/DISS_middle"/>
									<xsl:variable name="hyphenmiddlename"
										select="replace($middlename, '-', '-~')"/>
									<xsl:value-of
										select="replace(str:title-case(normalize-space($hyphenmiddlename)), '- ', '-')"
									/>
								</mname>
								<suffix>
									<xsl:variable name="suf">
										<xsl:value-of select="DISS_name/DISS_suffix"/>
									</xsl:variable>
									<xsl:value-of select="str:title-case($suf)"/>
								</suffix>

							</author>
						</xsl:for-each>
					</authors>

					<!-- changed the organization involving changing the discipline -->

					<disciplines>
						<xsl:for-each
							select="DISS_description/DISS_categorization/DISS_category/DISS_cat_desc">
								<xsl:choose>
									<xsl:when test=".='Acoustics'">
										<discipline>Acoustics, Dynamics, and Controls</discipline>
									</xsl:when>
									<xsl:when test=".='Adult education'">
										<discipline>Adult and Continuing Education Administration</discipline>
										<discipline>Adult and Continuing Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Aeronomy'">
										<discipline>Atmospheric Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Aerospace engineering'">
										<discipline>Aerospace Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Aesthetics'">
										<discipline>Esthetics</discipline>
									</xsl:when>
									<xsl:when test=".='African American studies'">
										<discipline>African American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='African history'">
										<discipline>African History</discipline>
									</xsl:when>
									<xsl:when test=".='African literature'">
										<discipline>African Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='African studies'">
										<discipline>African Languages and Societies</discipline>
										<discipline>African Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Aging'">
										<discipline>Gerontology</discipline>
										<discipline>Family, Life Course, and Society</discipline>
									</xsl:when>
									<xsl:when test=".='Agriculture'">
										<discipline>Agriculture</discipline>
									</xsl:when>
									<xsl:when test=".='Agriculture economics'">
										<discipline>Agricultural Economics</discipline>
										<discipline>Agricultural and Resource Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Agriculture education'">
										<discipline>Agricultural Education</discipline>
									</xsl:when>
									<xsl:when test=".='Agriculture engineering'">
										<discipline>Agriculture</discipline>
										<discipline>Bioresource and Agricultural Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Agronomy'">
										<discipline>Agriculture</discipline>
										<discipline>Agricultural Science</discipline>
										<discipline>Agronomy and Crop Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Alternative dispute resolution'">
										<discipline>Dispute Resolution and Administration</discipline>
									</xsl:when>
									<xsl:when test=".='Alternative energy'">
										<discipline>Oil, Gas, and Energy</discipline>
									</xsl:when>
									<xsl:when test=".='Alternative medicine'">
										<discipline>Alternative and Complementary	Medicine</discipline>
									</xsl:when>
									<xsl:when test=".='American history'">
										<discipline>United States History</discipline>
									</xsl:when>
									<xsl:when test=".='American literature'">
										<discipline>American Literature</discipline>
										<discipline>Literature in English, North America</discipline>
									</xsl:when>
									<xsl:when test=".='American studies'">
										<discipline>American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Analytical chemistry'">
										<discipline>Analytical Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Ancient history'">
										<discipline>Ancient History, Greek and Roman through Late	Antiquity</discipline>
									</xsl:when>
									<xsl:when test=".='Ancient languages'">
										<discipline>Indo-European Linguistics and	Philology</discipline>
									</xsl:when>
									<xsl:when test=".='Animal behavior'">
										<discipline>Behavior and Ethology</discipline>
									</xsl:when>
									<xsl:when test=".='Animal diseases'">
										<discipline>Animal Diseases</discipline>
									</xsl:when>
									<xsl:when test=".='Animal sciences'">
										<discipline>Agriculture</discipline>
										<discipline>Animal Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Applied mathematics'">
										<discipline>Applied Mathematics</discipline>
									</xsl:when>
									<xsl:when test=".='Archaeology'">
										<discipline>History of Art, Architecture, and	Archaeology</discipline>
									</xsl:when>
									<xsl:when test=".='Architectural engineering'">
										<discipline>Architectural Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Architecture'">
										<discipline>Architecture</discipline>
									</xsl:when>
									<xsl:when test=".='Area planning and development'">
										<discipline>Urban, Community and Regional	Planning</discipline>
									</xsl:when>
									<xsl:when test=".='Art criticism'">
										<discipline>Theory and Criticism</discipline>
									</xsl:when>
									<xsl:when test=".='Art education'">
										<discipline>Art Education</discipline>
									</xsl:when>
									<xsl:when test=".='Art history'">
										<discipline>History of Art, Architecture, and	Archaeology</discipline>
									</xsl:when>
									<xsl:when test=".='Artificial intelligence'">
										<discipline>Artificial Intelligence and Robotics</discipline>
									</xsl:when>
									<xsl:when test=".='Arts management'">
										<discipline>Arts Management</discipline>
									</xsl:when>
									<xsl:when test=".='Asian American studies'">
										<discipline>Asian American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Asian history'">
										<discipline>Asian History</discipline>
										<discipline>Asian Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Asian literature'">
										<discipline>Asian Studies</discipline>
										<discipline>East Asian Languages and Societies</discipline>
										<discipline>South and Southeast Asian Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Asian studies'">
										<discipline>Asian Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Astronomy'">
										<discipline>Astrophysics and Astronomy</discipline>
									</xsl:when>
									<xsl:when test=".='Astrophysics'">
										<discipline>Astrophysics and Astronomy</discipline>
									</xsl:when>
									<xsl:when test=".='Atmospheric chemistry'">
										<discipline>Atmospheric Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Atmospheric sciences'">
										<discipline>Atmospheric Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Atomic physics'">
										<discipline>Atomic, Molecular and Optical	Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Audiology'">
										<discipline>Speech Pathology and Audiology</discipline>
									</xsl:when>
									<xsl:when test=".='Automotive engineering'">
										<discipline>Automotive Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Baltic studies'">
										<discipline>European Languages and Societies</discipline>
										<discipline>Eastern European Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Banking'">
										<discipline>Finance and Financial	Management</discipline>
									</xsl:when>
									<xsl:when test=".='Behavioral sciences'">
										<discipline>Social and Behavioral Sciences</discipline>
										<discipline>Behavioral Neurobiology</discipline>
									</xsl:when>
									<xsl:when test=".='Biblical studies'">
										<discipline>Biblical Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Bilingual education'">
										<discipline>Bilingual, Multilingual, and Multicultural Education</discipline>
									</xsl:when>
									<xsl:when test=".='Biochemistry'">
										<discipline>Biochemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Biogeochemistry'">
										<discipline>Biogeochemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Biographies'">
										<discipline>Biography</discipline>
									</xsl:when>
									<xsl:when test=".='Biological oceanography'">
										<discipline>Oceanography</discipline>
									</xsl:when>
									<xsl:when test=".='Biomedical engineering'">
										<discipline>Biomedical</discipline>
									</xsl:when>
									<xsl:when test=".='Biosystems'">
										<discipline>Systems Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Black history'">
										<discipline>African American Studies</discipline>
										<discipline>United States History</discipline>
									</xsl:when>
									<xsl:when test=".='Black studies'">
										<discipline>African American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='British and Irish literature'">
										<discipline>Literature in English, British Isles</discipline>
									</xsl:when>
									<xsl:when test=".='Business education'">
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Canadian history'">
										<discipline>Other History</discipline>
									</xsl:when>
									<xsl:when test=".='Canadian literature'">
										<discipline>Literature in English, North America</discipline>
									</xsl:when>
									<xsl:when test=".='Canadian studies'">
										<discipline>Other International and Area Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Canon law'">
										<discipline>Religion Law</discipline>
									</xsl:when>
									<xsl:when test=".='Caribbean literature'">
										<discipline>Latin American Literature</discipline>
										<discipline>Other Race, Ethnicity and Post-Colonial Studies</discipline>
										<discipline>Other French and Francophone Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Caribbean studies'">
										<discipline>Other Race, Ethnicity and Post-Colonial Studies</discipline>
										<discipline>Latin American Languages and Societies</discipline>
										<discipline>Latin American Studies</discipline>
										<discipline>Other French and Francophone Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Cellular biology'">
										<discipline>Cell Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Chemical engineering'">
										<discipline>Chemical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Chemical oceanography'">
										<discipline>Oceanography</discipline>
									</xsl:when>
									<xsl:when test=".='Chemistry'">
										<discipline>Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Cinematography'">
										<discipline>Film and Media Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Civil engineering'">
										<discipline>Civil Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Classical literature'">
										<discipline>Classical Literature and Philology</discipline>
									</xsl:when>
									<xsl:when test=".='Classical studies'">
										<discipline>Classics</discipline>
									</xsl:when>
									<xsl:when test=".='Clerical studies'">
										<discipline>Other Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Climate change'">
										<discipline>Climate</discipline>
										<discipline>Environmental Indicators and Impact Assessment</discipline>
									</xsl:when>
									<xsl:when test=".='Clinical psychology'">
										<discipline>Clinical Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Cognitive psychology'">
										<discipline>Cognitive Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Communication'">
										<discipline>Communication</discipline>
									</xsl:when>
									<xsl:when test=".='Community college education'">
										<discipline>Community College Leadership</discipline>
										<discipline>Community College Education Administration</discipline>
									</xsl:when>
									<xsl:when test=".='Comparative literature'">
										<discipline>Comparative Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Comparative religion'">
										<discipline>Comparative Methodologies and	Theories</discipline>
									</xsl:when>
									<xsl:when test=".='Computer engineering'">
										<discipline>Computer Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Computer science'">
										<discipline>Computer Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Condensed matter physics'">
										<discipline>Condensed Matter Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Conservation biology'">
										<discipline>Biodiversity</discipline>
										<discipline>Natural Resources and Conservation</discipline>
										<discipline>Natural Resources Management and Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Continental dynamics'">
										<discipline>Tectonics and Structure</discipline>
									</xsl:when>
									<xsl:when test=".='Continuing education'">
										<discipline>Adult and Continuing Education Administration</discipline>
										<discipline>Adult and Continuing Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Counseling psychology'">
										<discipline>Counseling Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Criminology'">
										<discipline>Criminology and Criminal Justice</discipline>
										<discipline>Criminology</discipline>
									</xsl:when>
									<xsl:when test=".='Cultural anthropology'">
										<discipline>Social and Cultural Anthropology</discipline>
									</xsl:when>
									<xsl:when test=".='Cultural resource management'">
										<discipline>Cultural Resource Management and Policy Analysis</discipline>
									</xsl:when>
									<xsl:when test=".='Cultural resources management'">
										<discipline>Cultural Resource Management and Policy Analysis</discipline>
									</xsl:when>
									<xsl:when test=".='Curriculum development'">
										<discipline>Curriculum and Instruction</discipline>
									</xsl:when>
									<xsl:when test=".='Demography'">
										<discipline>Demography, Population, and Ecology</discipline>
									</xsl:when>
									<xsl:when test=".='Design'">
										<discipline>Art and Design</discipline>
									</xsl:when>
									<xsl:when test=".='Developmental biology'">
										<discipline>Developmental Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Developmental psychology'">
										<discipline>Developmental Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Divinity'">
										<discipline>Other Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Early childhood education'">
										<discipline>Pre-Elementary, Early Childhood, Kindergarten Teacher Education</discipline>
									</xsl:when>
									<xsl:when test=".='East European studies'">
										<discipline>European Languages and Societies</discipline>
										<discipline>Eastern European Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Ecology'">
										<discipline>Ecology and Evolutionary Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Economic history'">
										<discipline>Economic History</discipline>
									</xsl:when>
									<xsl:when test=".='Economic theory'">
										<discipline>Economic Theory</discipline>
									</xsl:when>
									<xsl:when test=".='Economics'">
										<discipline>Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Economics, Commerce-Business'">
										<discipline>Economics</discipline>
										<discipline>Other Business</discipline>
									</xsl:when>
									<xsl:when test=".='Economics, Labor'">
										<discipline>Labor Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Education finance'">
										<discipline>Education Economics</discipline>
										<discipline>Educational Administration and Supervision</discipline>
									</xsl:when>
									<xsl:when test=".='Education policy'">
										<discipline>Education Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Educational administration'">
										<discipline>Educational Administration and Supervision</discipline>
									</xsl:when>
									<xsl:when test=".='Educational evaluation'">
										<discipline>Educational Assessment, Evaluation, and Research</discipline>
									</xsl:when>
									<xsl:when test=".='Educational leadership'">
										<discipline>Educational Administration and Supervision</discipline>
									</xsl:when>
									<xsl:when test=".='Educational psychology'">
										<discipline>Educational Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Educational technology'">
										<discipline>Instructional Media Design</discipline>
									</xsl:when>
									<xsl:when test=".='Educational tests &amp; measurements'">
										<discipline>Educational Assessment, Evaluation, and Research</discipline>
									</xsl:when>
									<xsl:when test=".='Electrical engineering'">
										<discipline>Electrical and Electronics</discipline>
									</xsl:when>
									<xsl:when test=".='Electromagnetics'">
										<discipline>Electromagnetics and Photonics</discipline>
									</xsl:when>
									<xsl:when test=".='Elementary education'">
										<discipline>Elementary and Middle and Secondary Education Administration</discipline>
										<discipline>Elementary Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Endocrinology'">
										<discipline>Endocrinology</discipline>
										<discipline>Endocrinology, Diabetes, and Metabolism</discipline>
									</xsl:when>
									<xsl:when test=".='Energy'">
										<discipline>Oil, Gas, and Energy</discipline>
									</xsl:when>
									<xsl:when test=".='English as a second language'">
										<discipline>Bilingual, Multilingual, and Multicultural Education</discipline>
										<discipline>English Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Entomology'">
										<discipline>Entomology</discipline>
									</xsl:when>	
									<xsl:when test=".='Entrepreneurship'">
										<discipline>Entrepreneurial and Small Business Operations</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental economics'">
										<discipline>Natural Resource Economics</discipline>
										<discipline>Economics</discipline>
										<discipline>Agricultural and Resource Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental education'">
										<discipline>Education</discipline>
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental engineering'">
										<discipline>Environmental Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental geology'">
										<discipline>Geology</discipline>
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental health'">
										<discipline>Environmental Health and Protection</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental justice'">
										<discipline>Environmental Policy</discipline>
										<discipline>Environmental Sciences</discipline>
										<discipline>Environmental Law</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental management'">
										<discipline>Natural Resources Management and Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental philosophy'">
										<discipline>Environmental Sciences</discipline>
										<discipline>Philosophy</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental science'">
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Environmental studies'">
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Ethics'">
										<discipline>Ethics and Political Philosophy</discipline>
									</xsl:when>
									<xsl:when test=".='Ethnic studies'">
										<discipline>Ethnic Studies</discipline>
									</xsl:when>
									<xsl:when test=".='European history'">
										<discipline>European History</discipline>
									</xsl:when>
									<xsl:when test=".='European studies'">
										<discipline>European Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Evolution &amp; development'">
										<discipline>Evolution</discipline>
										<discipline>Developmental Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Experimental psychology'">
										<discipline>Psychology</discipline>
										<discipline>Other Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Film studies'">
										<discipline>Film and Media Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Finance'">
										<discipline>Finance and Financial Management</discipline>
									</xsl:when>
									<xsl:when test=".='Fine arts'">
										<discipline>Fine Arts</discipline>
									</xsl:when>
									<xsl:when test=".='Fisheries and aquatic sciences'">
										<discipline>Agriculture</discipline>
										<discipline>Aquaculture and Fisheries</discipline>
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Food science'">
										<discipline>Food Science</discipline>
									</xsl:when>
									<xsl:when test=".='Foreign language instruction'">
										<discipline>Bilingual, Multilingual, and Multicultural Education</discipline>
									</xsl:when>
									<xsl:when test=".='Forensic anthropology'">
										<discipline>Biological and Physical Anthropology</discipline>
									</xsl:when>
									<xsl:when test=".='Forestry'">
										<discipline>Forest Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='French Canadian culture'">
										<discipline>Other Languages, Societies, and Cultures</discipline>
										<discipline>Other French and Francophone Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='French Canadian literature'">
										<discipline>French and Francophone Literature</discipline>
										<discipline>Other French and Francophone Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Gender studies'">
										<discipline>Feminist, Gender, and Sexuality Studies</discipline>
										<discipline>Gender and Sexuality</discipline>
									</xsl:when>
									<xsl:when test=".='Geobiology'">
										<discipline>Biogeochemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Geochemistry'">
										<discipline>Geochemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Geographic information science and geodesy'">
										<discipline>Geographic Information Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Geological engineering'">
										<discipline>Geotechnical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Geophysical engineering'">
										<discipline>Geotechnical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Geophysics'">
										<discipline>Geophysics and Seismology</discipline>
									</xsl:when>
									<xsl:when test=".='Geotechnology'">
										<discipline>Geotechnical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Germanic literature'">
										<discipline>German Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Gerontology'">
										<discipline>Gerontology</discipline>
										<discipline>Family, Life Course, and Society</discipline>
									</xsl:when>
									<xsl:when test=".='Gifted education'">
										<discipline>Gifted Education</discipline>
									</xsl:when>
									<xsl:when test=".='GLBT studies'">
										<discipline>Lesbian, Gay, Bisexual, and Transgender Studies</discipline>
										<discipline>Gender and Sexuality</discipline>
									</xsl:when>
									<xsl:when test=".='Health care management'">
										<discipline>Health and Medical Administration</discipline>
									</xsl:when>
									<xsl:when test=".='Health education'">
										<discipline>Health and Physical Education</discipline>
										<discipline>Public Health Education and Promotion</discipline>
										<discipline>Medical Education</discipline>
									</xsl:when>
									<xsl:when test=".='Health sciences'">
										<discipline>Medicine and Health Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='High temperature physics'">
										<discipline>Physics</discipline>
										<discipline>Other Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Higher education'">
										<discipline>Higher Education Administration</discipline>
										<discipline>Higher Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Higher education administration'">
										<discipline>Higher Education Administration</discipline>
									</xsl:when>
									<xsl:when test=".='Hispanic American studies'">
										<discipline>Latina/o Studies</discipline>
										<discipline>Chicana/o Studies</discipline>
										<discipline>Other Race, Ethnicity and post-Colonial Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Histology'">
										<discipline>Cell Anatomy</discipline>
									</xsl:when>
									<xsl:when test=".='History of education'">
										<discipline>Other History</discipline>
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='History of Oceania'">
										<discipline>History of the Pacific Islands</discipline>
										<discipline>Pacific Islands Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='History of science'">
										<discipline>History of Science, Technology, and Medicine</discipline>
									</xsl:when>
									<xsl:when test=".='Holocaust studies'">
										<discipline>Jewish Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Home economics'">
										<discipline>Home Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Home economics education'">
										<discipline>Home Economics</discipline>
									</xsl:when>
									<xsl:when test=".='Horticulture'">
										<discipline>Agriculture</discipline>
										<discipline>Horticulture</discipline>
									</xsl:when>
									<xsl:when test=".='Hydrologic sciences'">
										<discipline>Hydrology</discipline>
									</xsl:when>
									<xsl:when test=".='Icelandic &amp; Scandinavian literature'">
										<discipline>Scandinavian Studies</discipline>
										<discipline>Other Languages, Societies, and Cultures</discipline>
									</xsl:when>
									<xsl:when test=".='Immunology'">
										<discipline>Immunology and Infectious Disease</discipline>
										<discipline>Allergy and Immunology</discipline>
										<discipline>Medical Immunology</discipline>
									</xsl:when>
									<xsl:when test=".='Individual &amp; family studies'">
										<discipline>Family, Life Course, and Society</discipline>
									</xsl:when>
									<xsl:when test=".='Industrial arts education'">
										<discipline>Other education</discipline>
									</xsl:when>
									<xsl:when test=".='Industrial engineering'">
										<discipline>Industrial Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Information science'">
										<discipline>Library and Information Science</discipline>
									</xsl:when>
									<xsl:when test=".='Information technology'">
										<discipline>Databases and Information Systems</discipline>
									</xsl:when>
									<xsl:when test=".='Inorganic chemistry'">
										<discipline>Inorganic Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Instructional design'">
										<discipline>Curriculum and Instruction</discipline>
										<discipline>Instructional Media Design</discipline>
									</xsl:when>
									<xsl:when test=".='Intellectual property'">
										<discipline>Intellectual Property</discipline>
									</xsl:when>
									<xsl:when test=".='International law'">
										<discipline>International Law</discipline>
									</xsl:when>
									<xsl:when test=".='International relations'">
										<discipline>International Relations</discipline>
									</xsl:when>
									<xsl:when test=".='Islamic culture'">
										<discipline>Near Eastern Languages and Societies</discipline>
										<discipline>Islamic World and Near East History</discipline>
										<discipline>Near and Middle Eastern Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Journalism'">
										<discipline>Journalism Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Judaic studies'">
										<discipline>Jewish Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Labor relations'">
										<discipline>Labor Relations</discipline>
										<discipline>Labor History</discipline>
									</xsl:when>
									<xsl:when test=".='Land use planning'">
										<discipline>Urban, Community and Regional Planning</discipline>
									</xsl:when>
									<xsl:when test=".='Landscape architecture'">
										<discipline>Landscape Architecture</discipline>
									</xsl:when>
									<xsl:when test=".='Language'">
										<discipline>Other Languages, Societies, and Cultures</discipline>
									</xsl:when>
									<xsl:when test=".='Language arts'">
										<discipline>English Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Latin American history'">
										<discipline>Latin American History</discipline>
									</xsl:when>
									<xsl:when test=".='Latin American literature'">
										<discipline>Latin American Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Latin American studies'">
										<discipline>Latin American Languages and Societies</discipline>
										<discipline>Latin American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Library science'">
										<discipline>Library and Information Science</discipline>
									</xsl:when>
									<xsl:when test=".='Limnology'">
										<discipline>Fresh Water Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Literature'">
										<discipline>English Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Literature of Oceania'">
										<discipline>Pacific Islands Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Logic'">
										<discipline>Logic and foundations of mathematics</discipline>
									</xsl:when>
									<xsl:when test=".='Low temperature physics'">
										<discipline>Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Macroecology'">
										<discipline>Ecology and Evolutionary Biology</discipline>
										<discipline>Environmental Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Management'">
										<discipline>Business Administration, Management, and Operations</discipline>
										<discipline>Management Sciences and Quantitative Methods</discipline>
									</xsl:when>
									<xsl:when test=".='Marine geology'">
										<discipline>Geology</discipline>
										<discipline>Oceanography</discipline>
									</xsl:when>
									<xsl:when test=".='Marketing'">
										<discipline>Advertising and Promotion Management</discipline>
										<discipline>Marketing</discipline>
									</xsl:when>
									<xsl:when test=".='Mass communication'">
										<discipline>Mass Communication</discipline>
									</xsl:when>
									<xsl:when test=".='Materials Science'">
										<discipline>Materials Science and Engineering</discipline>
										<discipline>Mechanics of Materials</discipline>
									</xsl:when>
									<xsl:when test=".='Mathematics education'">
										<discipline>Science and Mathematics Education</discipline>
									</xsl:when>
									<xsl:when test=".='Mechanical engineering'">
										<discipline>Mechanical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Mechanics'">
										<discipline>Engineering Mechanics</discipline>
									</xsl:when>
									<xsl:when test=".='Medical ethics'">
										<discipline>Bioethics and Medical Ethics</discipline>
									</xsl:when>
									<xsl:when test=".='Medical imaging and radiology'">
										<discipline>Bioimaging and Biomedical Optics</discipline>
										<discipline>Radiology</discipline>
										<discipline>Analytical, Diagnostic and Therapeutic Techniques and Equipment</discipline>
									</xsl:when>
									<xsl:when test=".='Medicine'">
										<discipline>Medicine and Health Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Medieval history'">
										<discipline>Medieval History</discipline>
									</xsl:when>
									<xsl:when test=".='Medieval literature'">
										<discipline>Medieval Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Mental health'">
										<discipline>Mental and Social Health</discipline>
										<discipline>Psychiatric and Mental Health</discipline>
									</xsl:when>
									<xsl:when test=".='Middle Eastern history'">
										<discipline>Islamic World and Near East History</discipline>
									</xsl:when>
									<xsl:when test=".='Middle Eastern literature'">
										<discipline>Near Eastern Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Middle Eastern studies'">
										<discipline>Near and Middle Eastern Studies</discipline>
										<discipline>Near Eastern Languages and Societies</discipline>
										<discipline>Islamic World and Near East History</discipline>
									</xsl:when>
									<xsl:when test=".='Middle school education'">
										<discipline>Elementary and Middle and Secondary Education Administration</discipline>
										<discipline>Junior High, Intermediate, Middle School Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Military history'">
										<discipline>Military History</discipline>
									</xsl:when>
									<xsl:when test=".='Military studies'">
										<discipline>Military Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Mineralogy'">
										<discipline>Geology</discipline>
									</xsl:when>
									<xsl:when test=".='Mining engineering'">
										<discipline>Mining Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Modern history'">
										<discipline>History</discipline>
									</xsl:when>
									<xsl:when test=".='Modern language'">
										<discipline>Modern Languages</discipline>
									</xsl:when>
									<xsl:when test=".='Modern literature'">
										<discipline>Modern Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Molecular biology'">
										<discipline>Molecular Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Molecular chemistry'">
										<discipline>Chemistry</discipline>
										<discipline>Chemical Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Molecular physics'">
										<discipline>Atomic, Molecular and Optical Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Multicultural education'">
										<discipline>Bilingual, Multilingual, and Multicultural Education</discipline>
									</xsl:when>
									<xsl:when test=".='Multimedia'">
										<discipline>Interactive Arts</discipline>
									</xsl:when>
									<xsl:when test=".='Museum studies'">
										<discipline>Other History of Art, Architecture, and Archaeology</discipline>
									</xsl:when>
									<xsl:when test=".='Music education'">
										<discipline>Music Education</discipline>
									</xsl:when>
									<xsl:when test=".='Nanoscience'">
										<discipline>Nanoscience and Nanotechnology</discipline>
									</xsl:when>
									<xsl:when test=".='Nanotechnology'">
										<discipline>Nanoscience and Nanotechnology</discipline>
									</xsl:when>
									<xsl:when test=".='Native American studies'">
										<discipline>Native American Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Natural resource management'">
										<discipline>Natural Resources Management and Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Naval engineering'">
										<discipline>Other Engineering</discipline>
										<discipline>Other Civil and Environmental Engineering</discipline>
										<discipline>Ocean Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Near Eastern studies'">
										<discipline>Near and Middle Eastern Studies</discipline>
										<discipline>Near Eastern Languages and Societies</discipline>
										<discipline>Islamic World and Near East History</discipline>
									</xsl:when>
									<xsl:when test=".='Neurosciences'">
										<discipline>Neuroscience and Neurobiology</discipline>
									</xsl:when>
									<xsl:when test=".='North African studies'">
										<discipline>Near and Middle Eastern Studies</discipline>
										<discipline>Near Eastern Languages and Societies</discipline>
										<discipline>African Languages and Societies</discipline>
										<discipline>African Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Nuclear chemistry'">
										<discipline>Radiochemistry</discipline>
										<discipline>Other Chemistry</discipline>
										<discipline>Nuclear Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Nuclear engineering'">
										<discipline>Nuclear Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Nuclear physics'">
										<discipline>Nuclear</discipline>
									</xsl:when>
									<xsl:when test=".='Nursing'">
										<discipline>Nursing</discipline>
									</xsl:when>
									<xsl:when test=".='Nutrition'">
										<discipline>Nutrition</discipline>
										<discipline>Human and Clinical Nutrition</discipline>
									</xsl:when>
									<xsl:when test=".='Obstetrics and gynecology'">
										<discipline>Obstetrics and Gynecology</discipline>
									</xsl:when>
									<xsl:when test=".='Occupational health'">
										<discipline>Occupational Health and Industrial Hygiene</discipline>
									</xsl:when>
									<xsl:when test=".='Occupational psychology'">
										<discipline>Vocational Rehabilitation Counseling</discipline>
									</xsl:when>
									<xsl:when test=".='Occupational therapy'">
										<discipline>Occupational Therapy</discipline>
									</xsl:when>
									<xsl:when test=".='Ocean engineering'">
										<discipline>Ocean Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Operations research'">
										<discipline>Operational Research</discipline>
									</xsl:when>
									<xsl:when test=".='Organic chemistry'">
										<discipline>Organic Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Organization theory'">
										<discipline>Organizational Behavior and Theory</discipline>
									</xsl:when>
									<xsl:when test=".='Organizational behavior'">
										<discipline>Organizational Behavior and Theory</discipline>
									</xsl:when>
									<xsl:when test=".='Osteopathic medicine'">
										<discipline>Osteopathic Medicine and Osteopathy</discipline>
									</xsl:when>
									<xsl:when test=".='Pacific Rim studies'">
										<discipline>Other International and Area Studies</discipline>
										<discipline>Pacific Islands Languages and Societies</discipline>
										<discipline>South and Southeast Asian Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Packaging'">
										<discipline>Product Design</discipline>
									</xsl:when>
									<xsl:when test=".='Paleoclimate science'">
										<discipline>Climate</discipline>
										<discipline>Paleontology</discipline>
									</xsl:when>
									<xsl:when test=".='Paleoecology'">
										<discipline>Ecology and Evolutionary Biology</discipline>
										<discipline>Paleontology</discipline>
									</xsl:when>
									<xsl:when test=".='Particle physics'">
										<discipline>Elementary Particles and Fields and String Theory</discipline>
									</xsl:when>
									<xsl:when test=".='Pastoral counseling'">
										<discipline>Other Religion</discipline>
										<discipline>Counseling</discipline>
										<discipline>Marriage and Family Therapy and Counseling</discipline>
									</xsl:when>
									<xsl:when test=".='Patent law'">
										<discipline>Intellectual Property Law</discipline>
									</xsl:when>
									<xsl:when test=".='Peace studies'">
										<discipline>Peace and Conflict Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Pedagogy'">
										<discipline>Educational Methods</discipline>
										<discipline>Curriculum and Instruction</discipline>
									</xsl:when>
									<xsl:when test=".='Performing arts'">
										<discipline>Theatre and Performance Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Performing arts education'">
										<discipline>Theatre and Performance Studies</discipline>
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Personality psychology'">
										<discipline>Personality and Social Contexts</discipline>
									</xsl:when>
									<xsl:when test=".='Petroleum engineering'">
										<discipline>Petroleum Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Petroleum geology'">
										<discipline>Oil, Gas, and Energy</discipline>
										<discipline>Geology</discipline>
									</xsl:when>
									<xsl:when test=".='Petrology'">
										<discipline>Oil, Gas, and Energy</discipline>
										<discipline>Geology</discipline>
									</xsl:when>
									<xsl:when test=".='Pharmaceutical sciences'">
										<discipline>Pharmacy and Pharmaceutical Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Philosophy of education'">
										<discipline>Social and Philosophical Foundations of Education</discipline>
									</xsl:when>
									<xsl:when test=".='Philosophy of Religion'">
										<discipline>Religious Thought, Theology and Philosophy of Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Philosophy of science'">
										<discipline>Philosophy of Science</discipline>
									</xsl:when>
									<xsl:when test=".='Physical anthropology'">
										<discipline>Biological and Physical Anthropology</discipline>
									</xsl:when>
									<xsl:when test=".='Physical chemistry'">
										<discipline>Physical Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Physical education'">
										<discipline>Health and Physical Education</discipline>
									</xsl:when>
									<xsl:when test=".='Physical geography'">
										<discipline>Physical and Environmental Geography</discipline>
									</xsl:when>
									<xsl:when test=".='Physical oceanography'">
										<discipline>Oceanography</discipline>
									</xsl:when>
									<xsl:when test=".='Physical therapy'">
										<discipline>Physical Therapy</discipline>
									</xsl:when>
									<xsl:when test=".='Physiological psychology'">
										<discipline>Behavioral Neurobiology</discipline>
										<discipline>Biological Psychology</discipline>
										<discipline>Behavior and Behavior Mechanisms</discipline>
									</xsl:when>
									<xsl:when test=".='Planetology'">
										<discipline>Other Astrophysics and Astronomy</discipline>
										<discipline>The Sun and the Solar System</discipline>
									</xsl:when>
									<xsl:when test=".='Plant biology'">
										<discipline>Agriculture</discipline>
										<discipline>Plant Biology</discipline>
									</xsl:when>
									<xsl:when test=".='Plant pathology'">
										<discipline>Agriculture</discipline>
										<discipline>Plant Pathology</discipline>
									</xsl:when>
									<xsl:when test=".='Plant sciences'">
										<discipline>Agriculture</discipline>
										<discipline>Plant Sciences</discipline>
									</xsl:when>
									<xsl:when test=".='Plasma physics'">
										<discipline>Plasma and Beam Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Plastics'">
										<discipline>Polymer and Organic Materials</discipline>
									</xsl:when>
									<xsl:when test=".='Plate tectonics'">
										<discipline>Tectonics and Structure</discipline>
									</xsl:when>
									<xsl:when test=".='Political science'">
										<discipline>Political Science</discipline>
									</xsl:when>
									<xsl:when test=".='Political studies'">
										<discipline>Political Science</discipline>
										<discipline>Politics and Social Change</discipline>
										<discipline>Political History</discipline>
									</xsl:when>
									<xsl:when test=".='Polymer chemistry'">
										<discipline>Polymer Chemistry</discipline>
									</xsl:when>
									<xsl:when test=".='Psychobiology'">
										<discipline>Behavioral Neurobiology</discipline>
										<discipline>Biological Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Public administration'">
										<discipline>Public Administration</discipline>
									</xsl:when>
									<xsl:when test=".='Public health'">
										<discipline>Public Health Education and Promotion</discipline>
									</xsl:when>
									<xsl:when test=".='Public health occupations education'">
										<discipline>Medical Education</discipline>
										<discipline>Public Health Education and Promotion</discipline>
									</xsl:when>
									<xsl:when test=".='Public policy'">
										<discipline>Public Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Quantitative psychology and psychometrics'">
										<discipline>Quantitative Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Quantum physics'">
										<discipline>Quantum Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Range management'">
										<discipline>Natural Resources Management and Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Reading instruction'">
										<discipline>Reading and Language</discipline>
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Recreation and tourism'">
										<discipline>Recreation, Parks and Tourism Administration</discipline>
										<discipline>Tourism</discipline>
										<discipline>Recreation Business</discipline>
									</xsl:when>
									<xsl:when test=".='Regional studies'">
										<discipline>Other International and Area Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Religious education'">
										<discipline>Religion</discipline>
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Religious history'">
										<discipline>History of Religion</discipline>
										<discipline>Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Remote sensing'">
										<discipline>Remote Sensing</discipline>
									</xsl:when>
									<xsl:when test=".='Romance literature'">
										<discipline>Spanish and Portuguese Language and Literature</discipline>
										<discipline>French and Francophone Language and Literature</discipline>
										<discipline>Italian Language and Literature</discipline>
									</xsl:when>
									<xsl:when test=".='Russian history'">
										<discipline>Soviet and Post-Soviet Studies</discipline>
										<discipline>Slavic Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Scandinavian studies'">
										<discipline>Scandinavian Studies</discipline>
										<discipline>European Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='School counseling'">
										<discipline>Student Counseling and Personnel Services</discipline>
										<discipline>School Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Science education'">
										<discipline>Science and Mathematics Education</discipline>
									</xsl:when>
									<xsl:when test=".='Secondary education'">
										<discipline>Elementary and Middle and Secondary Education Administration</discipline>
										<discipline>Secondary Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Sedimentary geology'">
										<discipline>Sedimentology</discipline>
									</xsl:when>
									<xsl:when test=".='Slavic literature'">
										<discipline>Slavic Languages and Societies</discipline>
									</xsl:when>
									<xsl:when test=".='Slavic studies'">
										<discipline>European Languages and Societies</discipline>
										<discipline>Slavic Languages and Societies</discipline>
										<discipline>Eastern European Studies</discipline>
										<discipline>Soviet and Post-Soviet Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Social psychology'">
										<discipline>Social Psychology</discipline>
									</xsl:when>
									<xsl:when test=".='Social research'">
										<discipline>Quantitative, Qualitative, Comparative, and Historical Methodologies</discipline>
									</xsl:when>
									<xsl:when test=".='Social sciences education'">
										<discipline>Liberal Studies</discipline>
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Social structure'">
										<discipline>Sociology of Culture</discipline>
										<discipline>Inequality and Stratification</discipline>
										<discipline>Other Sociology</discipline>
									</xsl:when>
									<xsl:when test=".='Social work'">
										<discipline>Social Work</discipline>
									</xsl:when>
									<xsl:when test=".='Sociolinguistics'">
										<discipline>Anthropological Linguistics and Sociolinguistics</discipline>
									</xsl:when>
									<xsl:when test=".='Sociology of education'">
										<discipline>Social and Philosophical Foundations of Education</discipline>
										<discipline>Educational Sociology</discipline>
									</xsl:when>
									<xsl:when test=".='Soil sciences'">
										<discipline>Soil Science</discipline>
									</xsl:when>
									<xsl:when test=".='South African studies'">
										<discipline>African Languages and Societies</discipline>
										<discipline>African Studies</discipline>
										<discipline>Race, Ethnicity and Post-Colonial Studies</discipline>
									</xsl:when>
									<xsl:when test=".='South Asian studies'">
										<discipline>South and Southeast Asian Languages and Societies</discipline>
										<discipline>Asian Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Special education'">
										<discipline>Special Education Administration</discipline>
										<discipline>Special Education and Teaching</discipline>
									</xsl:when>
									<xsl:when test=".='Speech therapy'">
										<discipline>Speech and Hearing Science</discipline>
										<discipline>Speech Pathology and Audiology</discipline>
									</xsl:when>
									<xsl:when test=".='Spirituality'">
										<discipline>Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Sports management'">
										<discipline>Sports Management</discipline>
									</xsl:when>
									<xsl:when test=".='Statistics'">
										<discipline>Statistics and Probability</discipline>
									</xsl:when>
									<xsl:when test=".='Sub Saharan Africa studies'">
										<discipline>African Languages and Societies</discipline>
										<discipline>African Studies</discipline>
									</xsl:when>
									<xsl:when test=".='System science'">
										<discipline>Systems Engineering</discipline>
									</xsl:when>
									<xsl:when test=".='Systematic biology'">
										<discipline>Biodiversity</discipline>
										<discipline>Evolution</discipline>
									</xsl:when>
									<xsl:when test=".='Teacher education'">
										<discipline>Teacher Education and Professional Development</discipline>
									</xsl:when>
									<xsl:when test=".='Technical communication'">
										<discipline>Other Communication</discipline>
									</xsl:when>
									<xsl:when test=".='Textile research'">
										<discipline>Art and Materials Conservation</discipline>
									</xsl:when>
									<xsl:when test=".='Theater'">
										<discipline>Theatre and Performance Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Theater history'">
										<discipline>Theatre History</discipline>
									</xsl:when>
									<xsl:when test=".='Theology'">
										<discipline>Religious Thought, Theology and Philosophy of Religion</discipline>
									</xsl:when>
									<xsl:when test=".='Theoretical mathematics'">
										<discipline>Mathematics</discipline>
									</xsl:when>
									<xsl:when test=".='Theoretical physics'">
										<discipline>Physics</discipline>
									</xsl:when>
									<xsl:when test=".='Transportation planning'">
										<discipline>Transportation Engineering</discipline>
										<discipline>Transportation</discipline>
										<discipline>Urban Studies and Planning</discipline>
									</xsl:when>
									<xsl:when test=".='Urban forestry'">
										<discipline>Other Forestry and Forest Sciences</discipline>
										<discipline>Landscape Architecture</discipline>
									</xsl:when>
									<xsl:when test=".='Urban planning'">
										<discipline>Urban Studies and Planning</discipline>
										<discipline>Urban, Community and Regional Planning</discipline>
									</xsl:when>
									<xsl:when test=".='Veterinary medicine'">
										<discipline>Veterinary Medicine</discipline>
									</xsl:when>
									<xsl:when test=".='Vocational education'">
										<discipline>Other Education</discipline>
									</xsl:when>
									<xsl:when test=".='Water resources management'">
										<discipline>Water Resource Management</discipline>
									</xsl:when>
									<xsl:when test=".='Web studies'">
										<discipline>Communication Technology and New Media</discipline>
										<discipline>Digital Communications and Networking</discipline>
										<discipline>Social Media</discipline>
									</xsl:when>
									<xsl:when test=".='Wildlife conservation'">
										<discipline>Natural Resources and Conservation</discipline>
									</xsl:when>
									<xsl:when test=".='Wildlife management'">
										<discipline>Natural Resources Management and Policy</discipline>
									</xsl:when>
									<xsl:when test=".='Women&amp;apos;s studies'">
										<discipline>Women's Studies</discipline>
									</xsl:when>
									<xsl:when test=".='Wood sciences'">
										<discipline>Wood Science and Pulp, Paper Technology</discipline>
									</xsl:when>
									<xsl:when test=".='World history'">
										<discipline>History</discipline>
									</xsl:when>
									<xsl:otherwise>
										<discipline><xsl:value-of select="."/></discipline>
									</xsl:otherwise>
								</xsl:choose>
						</xsl:for-each>
					</disciplines>

					<!-- Outputs each keyword into its own keyword element , splitting on both semicolon and comma-->
					<keywords>
						<xsl:for-each select="DISS_description/DISS_categorization/DISS_keyword">
							<xsl:variable name="keywordstring">
								<xsl:value-of select="translate(., ';', ',')"/>
							</xsl:variable>
							<xsl:variable name="tokenkeyword"
								select="tokenize($keywordstring, ',\s+')"/>
							<xsl:for-each select="$tokenkeyword">
								<keyword>
									<xsl:value-of select="."/>
								</keyword>
							</xsl:for-each>
						</xsl:for-each>
					</keywords>

					<!-- Abstract  - replaces ProQuest formatting characters to bepress formatting -->
					<abstract>
						<xsl:for-each select="DISS_content/DISS_abstract">
							<xsl:for-each select="DISS_para">
								<xsl:variable name="abstract">
									<xsl:value-of select="."/>
								</xsl:variable>
								<xsl:if test="$abstract!='Abstract'">
									<p>
										<xsl:value-of
											select="concat(normalize-space(replace(
											replace(
											replace(
											replace(
											replace(
											replace(
											replace(
											replace(.,'&lt;bold&gt;','&lt;strong&gt;'),
											'&lt;/bold&gt;','&lt;/strong&gt;'),
											'&lt;italic&gt;','&lt;em&gt;'),
											'&lt;/italic&gt;','&lt;/em&gt;'),
											'&lt;super&gt;','&lt;sup&gt;'),
											'&lt;/super&gt;','&lt;/sup&gt;'),
											'&lt;underline&gt;',' '),
											'&lt;/underline&gt;',' ')),' ')"
										/>
									</p>
								</xsl:if>
							</xsl:for-each>
						</xsl:for-each>
					</abstract>

					<fulltext-url>
							
							<xsl:variable name="pdfpath">
								<xsl:value-of select="DISS_content/DISS_binary"/>
							</xsl:variable>
							<xsl:value-of
								select="concat('http://YOURURLHERE.edu/folder/', $pdfpath)"/>
						

					</fulltext-url>

					<!-- Adds document type -->
					<document-type>
						<xsl:variable name="document">
							<xsl:value-of select="DISS_description/@type"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="starts-with(upper-case($document), 'D')">
								<xsl:text>dissertation</xsl:text>
							</xsl:when>
							<xsl:when test="starts-with(upper-case($document), 'M')">
								<xsl:text>thesis</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$document"/>
							</xsl:otherwise>
						</xsl:choose>
					</document-type>

					<!-- Normalizes degree names -->
					<degree_name>
						<xsl:for-each select="DISS_description/DISS_degree">
								<xsl:variable name="degreestr1">
									<xsl:value-of select="."/>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="contains($degreestr1, 'M.A. and M.C.R.P.')">
										<xsl:value-of>Master of Arts/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.A.') and contains($degreestr1, 'M.S.')">
										<xsl:value-of>Master of Arts/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.Arch.') and contains($degreestr1, 'M.B.A.')">
										<xsl:value-of>Master of Architecture/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.Arch.') and contains($degreestr1, 'M.C.R.P.')">
										<xsl:value-of>Master of Architecture/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.B.A.') and contains($degreestr1, 'M.Arch.')">
										<xsl:value-of>Master of Architecture/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.B.A.') and contains($degreestr1, 'M.C.R.P.')">
										<xsl:value-of>Master of Community and Regional Planning/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.B.A.') and contains($degreestr1, 'M.S.')">
										<xsl:value-of>Master of Science/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.Arch.')">
										<xsl:value-of>Master of Architecture/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.B.A.')">
										<xsl:value-of>Master of Community and Regional Planning/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.L.A.')">
										<xsl:value-of>Master of Landscape Architecture/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.P.A.')">
										<xsl:value-of>Master of Public Administration/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.A.')">
										<xsl:value-of>Master of Arts/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.C.R.P.') and contains($degreestr1, 'M.S.')">
										<xsl:value-of>Master of Community and Regional Planning/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.S.') and contains($degreestr1, 'M.A.')">
										<xsl:value-of>Master of Arts/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.S.') and contains($degreestr1, 'M.B.A.')">
										<xsl:value-of>Master of Science/Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.S.') and contains($degreestr1, 'M.C.R.P.')">
										<xsl:value-of>Master of Community and Regional Planning/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.S.') and contains($degreestr1, 'M.P.A.')">
										<xsl:value-of>Master of Public Administration/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.P.A.') and contains($degreestr1, 'M.C.R.P.')">
										<xsl:value-of>Master of Public Administration/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when
										test="contains($degreestr1, 'M.P.A.') and contains($degreestr1, 'M.S.')">
										<xsl:value-of>Master of Public Administration/Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.A.')">
										<xsl:value-of>Master of Arts</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.A.T.')">
										<xsl:value-of>Master of Arts in Teaching</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Acc.')">
										<xsl:value-of>Master of Accounting</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Ag.')">
										<xsl:value-of>Master of Agriculture</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Arch.')">
										<xsl:value-of>Master of Architecture</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.B.A.')">
										<xsl:value-of>Master of Business Administration</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.C.R.P.')">
										<xsl:value-of>Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Ed.')">
										<xsl:value-of>Master of Education</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Educ.')">
										<xsl:value-of>Master of Education</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.Engr.')">
										<xsl:value-of>Master of Engineering</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.F.A.')">
										<xsl:value-of>Master of Fine Arts</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.F.C.S.')">
										<xsl:value-of>Master of Family and Consumer Sciences</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.I.D.')">
										<xsl:value-of>Master of Industrial Design</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.L.A.')">
										<xsl:value-of>Master of Landscape Architecture</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.L.A. and M.C.R.P.')">
										<xsl:value-of>Master of Landscape Architecture/Master of Community and Regional Planning</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.P.A.')">
										<xsl:value-of>Master of Public Administration</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.S.')">
										<xsl:value-of>Master of Science</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'M.S.M.')">
										<xsl:value-of>Master of School Mathematics</xsl:value-of>
									</xsl:when>
									<xsl:when test="contains($degreestr1, 'Ph.D.')">
										<xsl:value-of>Doctor of Philosophy</xsl:value-of>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$degreestr1"/>
									</xsl:otherwise>
								</xsl:choose>
							
						</xsl:for-each>
					</degree_name>

					
					<!-- Normalizes department names -->
					<department>
						<xsl:for-each select="DISS_description/DISS_institution/DISS_inst_contact">
							<xsl:variable name="deptstring">
								<xsl:value-of select="."/>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($deptstring, '&amp;')">
									<xsl:value-of select="replace($deptstring, '&amp;', 'and')"/>
								</xsl:when>
								<xsl:when test=".='Accounting'">
									<xsl:value-of>Theses &amp; dissertations (College of Business)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Aerospace Engineering'">
									<xsl:value-of>Aerospace Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Agricultural and Biosystems Engineering'">
									<xsl:value-of>Agricultural and Biosystems Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Agricultural Education and Studies'">
									<xsl:value-of>Agricultural Education and Studies</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Agronomy'">
									<xsl:value-of>Agronomy</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Animal Science'">
									<xsl:value-of>Animal Science</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Anthropology'">
									<xsl:value-of>Anthropology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Apparel, Educational Studies and Hospitality Management'">
									<xsl:value-of>Apparel, Events and Hospitality Management</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Apparel, Events and Hospitality Management'">
									<xsl:value-of>Apparel, Events and Hospitality Management</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Architecture'">
									<xsl:value-of>Architecture</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Art and Design'">
									<xsl:value-of>Art and Design</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Biochemistry, Biophysics, and Molecular Biology'">
									<xsl:value-of>Biochemistry, Biophysics and Molecular Biology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Biomedical Sciences'">
									<xsl:value-of>Biomedical Sciences</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Business Administration'">
									<xsl:value-of>Theses &amp; dissertations (College of Business)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Chemical and Biological Engineering'">
									<xsl:value-of>Chemical and Biological Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Chemistry'">
									<xsl:value-of>Chemistry</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Civil, Construction, and Environmental Engineering'">
									<xsl:value-of>Civil, Construction, and Environmental Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Community and Regional Planning'">
									<xsl:value-of>Community and Regional Planning</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Computer Science'">
									<xsl:value-of>Computer Science</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Curriculum and Instruction'">
									<xsl:value-of>Curriculum and Instruction</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Ecology, Evolution, and Organismal Biology'">
									<xsl:value-of>Ecology, Evolution, and Organismal Biology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Economics'">
									<xsl:value-of>Economics</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Educational Leadership and Policy Studies'">
									<xsl:value-of>Educational Leadership and Policy Studies</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Electrical and Computer Engineering'">
									<xsl:value-of>Electrical and Computer Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Engineering Mechanics'">
									<xsl:value-of>Aerospace Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='English'">
									<xsl:value-of>English</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Entomology'">
									<xsl:value-of>Entomology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Family and Consumer Sciences'">
									<xsl:value-of>Apparel, Events and Hospitality Management</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Family and Consumer Sciences Education and Studies'">
									<xsl:value-of>Apparel, Events and Hospitality Management</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Food Science and Human Nutrition'">
									<xsl:value-of>Food Science and Human Nutrition</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Genetics, Development and Cell Biology'">
									<xsl:value-of>Genetics, Development and Cell Biology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Geological and Atmospheric Sciences'">
									<xsl:value-of>Geological and Atmospheric Sciences</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Graphic Design'">
									<xsl:value-of>Graphic Design</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='History'">
									<xsl:value-of>History</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Horticulture'">
									<xsl:value-of>Horticulture</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Human Development and Family Studies'">
									<xsl:value-of>Human Development and Family Studies</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Industrial and Manufacturing Systems Engineering'">
									<xsl:value-of>Industrial and Manufacturing Systems Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Industrial Design'">
									<xsl:value-of>Industrial Design</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Industrial Relations'">
									<xsl:value-of>Theses &amp; dissertations (Interdisciplinary)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Integrated Studio Arts'">
									<xsl:value-of>Integrated Studio Arts</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Interdisciplinary Graduate Studies'">
									<xsl:value-of>Theses &amp; dissertations (Interdisciplinary)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Interior Design'">
									<xsl:value-of>Interior Design</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Journalism and Mass Communication'">
									<xsl:value-of>Greenlee School of Journalism and Communication</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Kinesiology'">
									<xsl:value-of>Kinesiology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Landscape Architecture'">
									<xsl:value-of>Landscape Architecture</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Logistics, Operations, and Management Information Systems'">
									<xsl:value-of>Theses &amp; dissertations (College of Business)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Materials Science and Engineering'">
									<xsl:value-of>Materials Science and Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Mathematics'">
									<xsl:value-of>Mathematics</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Mechanical Engineering'">
									<xsl:value-of>Mechanical Engineering</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Natural Resource Ecology and Management'">
									<xsl:value-of>Natural Resource Ecology and Management</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Neuroscience'">
									<xsl:value-of>Theses &amp; dissertations (Interdisciplinary)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Physics and Astronomy'">
									<xsl:value-of>Physics and Astronomy</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Plant Pathology'">
									<xsl:value-of>Plant Pathology and Microbiology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Plant Pathology and Microbiology'">
									<xsl:value-of>Plant Pathology and Microbiology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Political Science'">
									<xsl:value-of>Political Science</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Psychology'">
									<xsl:value-of>Psychology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Sociology'">
									<xsl:value-of>Sociology</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Statistics'">
									<xsl:value-of>Statistics</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Supply Chain and Information Systems'">
									<xsl:value-of>Theses &amp; dissertations (College of Business)</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Textiles and Clothing'">
									<xsl:value-of>Textiles and Clothing</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Veterinary Clinical Sciences'">
									<xsl:value-of>Veterinary Clinical Sciences</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Veterinary Diagnostic and Production Animal Medicine'">
									<xsl:value-of>Veterinary Diagnostic and Production Animal Medicine</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Veterinary Microbiology and Preventative Medicine'">
									<xsl:value-of>Veterinary Microbiology and Preventive Medicine</xsl:value-of>
								</xsl:when>
								<xsl:when test=".='Veterinary Pathology'">
									<xsl:value-of>Veterinary Pathology</xsl:value-of>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$deptstring"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</department>

					<!-- add abstract format - testing  -->
					<abstract_format>html</abstract_format>

					<fields>

						<!-- add language - add additional spelled out forms of ISO 639-1 codes as needed -->
						<field name="language" type="string">
							<value>
								<xsl:value-of
									select="DISS_description/DISS_categorization/DISS_language"/>
							</value>
						</field>

						<field name="provenance" type="string">
							<value>Received from ProQuest</value>
						</field>

						<!-- Rights info -->
						<field name="copyright_date" type="string">
							<value>
								<xsl:value-of select="DISS_description/DISS_dates/DISS_comp_date"/>
							</value>
						</field>

						<!-- Embargo date -->

						<field name="embargo_date" type="date">
							<value>
								<xsl:variable name="accept_code">
									<xsl:value-of select="//DISS_repository/DISS_acceptance"/>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$accept_code = '0'">
										<xsl:choose>
											<xsl:when test="//DISS_restriction/DISS_sales_restriction[@code] != '0'">
												<xsl:variable name="removeDate" select="//DISS_restriction/DISS_sales_restriction/@remove"/> 
												<xsl:variable name="month" select="substring-before($removeDate,'/')" />
												<xsl:variable name="day" select="substring-before(substring-after($removeDate,'/'),'/')" />
												<xsl:variable name="year" select="substring-after(substring-after($removeDate,'/'),'/')" />
												<xsl:value-of select="$year"/>
												<xsl:value-of select="'-'" />
												<xsl:if test="string-length($month) = 1">
													<xsl:value-of select="'0'" />
												</xsl:if>
												<xsl:value-of select="$month" />
												<xsl:value-of select="'-'" />
												<xsl:if test="string-length($day) = 1">
													<xsl:value-of select="'0'" />
												</xsl:if>
												<xsl:value-of select="$day" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="xs:date('2001-01-01')"/>
											</xsl:otherwise>
										</xsl:choose>	
									</xsl:when>
									<xsl:when test="$accept_code = '1'">
										<xsl:variable name="embargo_text">
											<xsl:value-of select="DISS_repository/DISS_access_option"/>
										</xsl:variable>
										<xsl:variable name="agreement_exists">
											<xsl:value-of select="DISS_repository/DISS_access_option"/>
										</xsl:variable>
										<xsl:variable name="dateString">
											<xsl:value-of select="DISS_repository/DISS_agreement_decision_date"/>
										</xsl:variable>
										<xsl:variable name="dateString">
											<xsl:value-of select="DISS_repository/DISS_agreement_decision_date"/>
										</xsl:variable>
										<xsl:variable name="fdate" select="concat(substring($dateString, 1, 10), 'T', substring($dateString, 12, 19))"/>
											<xsl:choose>
												<xsl:when test="//DISS_repository/DISS_access_option != ''">
													<xsl:choose>									
														<xsl:when
															test="($embargo_text = 'No, 6 month delayed release') and not(string-length($dateString) = 0)">
															<xsl:value-of
																select="xs:date(xs:dateTime($fdate) + 180*xs:dayTimeDuration('P1D'))"
															/>
														</xsl:when>
														<xsl:when
															test="($embargo_text = 'No, 1 year delayed release') and not(string-length($dateString) = 0)">
															<xsl:value-of
																select="xs:date(xs:dateTime($fdate) + 365*xs:dayTimeDuration('P1D'))"
															/>
														</xsl:when>
														<xsl:when
															test="($embargo_text = 'No, 2 year delayed release') and not(string-length($dateString) = 0)">
															<xsl:value-of
																select="xs:date(xs:dateTime($fdate) + 730*xs:dayTimeDuration('P1D'))"
															/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="xs:date('2001-01-01')"/>
														</xsl:otherwise>
													</xsl:choose>	
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="//DISS_repository/DISS_delayed_release != ''">
															<xsl:variable name="releaseDate" select="//DISS_repository/DISS_delayed_release"/> 
															<xsl:value-of select="xs:date(substring($releaseDate, 1, 10))"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="xs:date('2001-01-01')"/>
														</xsl:otherwise>
													</xsl:choose>	
												</xsl:otherwise>
											</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
											<xsl:value-of select="xs:date('2001-01-01')"/>
									</xsl:otherwise>
								</xsl:choose>
							</value>
						</field>

						<!-- Pages numbers (from actual length of PDF, not based on page numbering) -->
						<field name="file_size" type="string">
							<value>
								<xsl:value-of
									select="concat(DISS_description/@page_count, ' pages')"/>
							</value>
						</field>

						<!-- Automatically sets fileformat to pdf -->
						<field name="fileformat" type="string">
							<value>application/pdf</value>
						</field>

						<field name="rights_holder" type="string">
							<value>
								<xsl:value-of
									select="DISS_authorship/DISS_author/DISS_name/DISS_fname"/>
								<xsl:text> </xsl:text>
								<xsl:value-of
									select="DISS_authorship/DISS_author/DISS_name/DISS_middle"/>
								<xsl:text> </xsl:text>
								<xsl:value-of
									select="DISS_authorship/DISS_author/DISS_name/DISS_surname"/>
								<xsl:text> </xsl:text>
								<xsl:value-of
									select="DISS_authorship/DISS_author/DISS_name/DISS_suffix"/>
							</value>
						</field>

						<!-- Advisors (up to 3 captured) -->
						<xsl:call-template name="advisor"/>
					</fields>
				</document>
			</xsl:for-each>
		</documents>
	</xsl:template>
	<xsl:template match="DISS_description" name="advisor">
		<xsl:if test="DISS_description/DISS_advisor[1]">
			<field name="advisor1" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[1]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[1]/DISS_name/DISS_surname"/>
					</xsl:variable>

					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[1]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>

		</xsl:if>
		<xsl:if test="DISS_description/DISS_advisor[2]">
			<field name="advisor2" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[2]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[2]/DISS_name/DISS_surname"/>
					</xsl:variable>

					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[2]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>
		</xsl:if>
		<xsl:if test="DISS_description/DISS-advisor[3]">
			<field name="advisor3" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[3]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[3]/DISS_name/DISS_surname"/>
					</xsl:variable>
					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[3]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
