<?xml version="1.0"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xp="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xs math" 
	version="3.0">
	
	<xsl:param name="source" select="'file:quayapi.json'"/>
	<xsl:param name="output-prologue" select="'yes'"/>
		
	<xsl:output indent="no" omit-xml-declaration="yes" />
	
	
	
	<xsl:template match="/">
		<xsl:variable name="jsonstr" select="unparsed-text($source)"/>
		
		<xsl:variable name="jsondoc" select="json-to-xml($jsonstr)"/>
		
		<xsl:apply-templates select="$jsondoc/xp:map"/>
			
	</xsl:template>

	<xsl:template match="/xp:map">

	<xsl:choose>
	<xsl:when test="$output-prologue='yes'">
		<xsl:call-template name="output-prologue"/>
	</xsl:when>
	<xsl:otherwise>
		<!--<xsl:text>&#xA;= Red Hat Quay API&#xA;&#xA;</xsl:text>
		<xsl:text>The API provides programatic access to the features supported by Red Hat Quay.&#xA;&#xA;</xsl:text>-->
		
	    <xsl:text>&#xA;= </xsl:text><xsl:value-of select="xp:map[@key='info']/xp:string[@key='title']"/><xsl:text>&#xA;&#xA;</xsl:text>
	    <xsl:value-of disable-output-escaping="yes" select="xp:map[@key='info']/xp:string[@key='description']" /><xsl:text>&#xA;&#xA;</xsl:text>

	</xsl:otherwise>
	</xsl:choose>



	    <xsl:apply-templates select="xp:map[@key='securityDefinitions']"/>	    
	    <xsl:apply-templates select="xp:map[@key='paths']"/>
	    
		<xsl:call-template name="output-response-defns"/>	    
	    
	</xsl:template>
	



    <xsl:template match="/xp:map/xp:map[@key='securityDefinitions']">	


<xsl:result-document href="modules/api-authorization.adoc"  indent="no" omit-xml-declaration="yes">
		<xsl:text>&#xA;= Authorization&#xA;</xsl:text>

		<xsl:for-each select="xp:map">

    		<xsl:text>&#xA;</xsl:text><xsl:value-of select="@key"/><xsl:text>&#xA;&#xA;</xsl:text>
    
    		<xsl:text>&#xA;[discrete]&#xA;</xsl:text>
		    <xsl:text>== Scopes&#xA;&#xA;</xsl:text>	
    
			<xsl:text>The following scopes are used to control access to the API endpoints:&#xA;&#xA;</xsl:text>    
    
			<xsl:text>[options="header", width=100%, cols=".^2a,.^9a"]&#xA;</xsl:text>
			<xsl:text>|===&#xA;</xsl:text>
			<xsl:text>|Scope|Description&#xA;</xsl:text>

			<xsl:for-each select="xp:map[@key='scopes']/xp:string">
				<xsl:text>|**</xsl:text><xsl:value-of select="@key"/><xsl:text>**|</xsl:text><xsl:value-of select="."/><xsl:text>&#xA;</xsl:text>
			</xsl:for-each>
 
			<xsl:text>|===&#xA;</xsl:text>  
 
		</xsl:for-each>

  </xsl:result-document>
  <xsl:text>&#xA;include::</xsl:text><xsl:value-of select="'modules/api-authorization.adoc'"/><xsl:text>[leveloffset=+2]&#xA;</xsl:text>

    </xsl:template>
    
    
   
    <xsl:template match="/xp:map/xp:map[@key='paths']">
    	    	
    		<xsl:for-each-group select="./xp:map[starts-with(@key, '/api/v1')]" group-by="string(xp:string[@key='x-tag'])">


				<xsl:variable name="tag" select="xp:string[@key='x-tag']"/>

				<xsl:variable name="tag-filename" select="concat('modules/api-', $tag, '.adoc')"/>

<xsl:result-document href="{$tag-filename}"  indent="no" omit-xml-declaration="yes">
				<xsl:text>&#xA;= </xsl:text><xsl:value-of select="$tag"/><xsl:text>&#xA;</xsl:text>

				<xsl:value-of select="/xp:map/xp:array[@key='tags']/xp:map[xp:string[@key='name' and string(.)=$tag]]/xp:string[@key='description']"/><xsl:text>&#xA;&#xA;</xsl:text>
</xsl:result-document>

<xsl:text>&#xA;&#xA;include::</xsl:text><xsl:value-of select="$tag-filename"/><xsl:text>[leveloffset=+2]</xsl:text>
    	
				<xsl:for-each select="current-group()">   
	    	
    				<xsl:for-each select="./xp:map">

						<xsl:variable name="operationId" select="xp:string[@key='operationId']"/>

						<xsl:variable name="filename" select="concat('modules/api-', $tag, '-', $operationId, '.adoc')"/>

<xsl:result-document href="{$filename}"  indent="no" omit-xml-declaration="yes">					
						<xsl:text>&#xA;= </xsl:text><xsl:value-of select="$operationId"/><xsl:text>&#xA;</xsl:text>


						<xsl:value-of select="./xp:string[@key='description']"/>


						<xsl:text>&#xA;&#xA;[discrete]&#xA;</xsl:text>    		
						<xsl:text>== </xsl:text><xsl:value-of select="upper-case(@key)"/> <xsl:text> </xsl:text><xsl:value-of select="../xp:string[@key='x-path']"/><xsl:text>&#xA;&#xA;</xsl:text>    
            

						<xsl:call-template name="output-authorizations"/>

						<xsl:call-template name="output-path-parameters"/>
						
						<xsl:call-template name="output-query-parameters"/>
						
						<xsl:call-template name="output-body-schema"/>
						
						<xsl:call-template name="output-responses"/>
</xsl:result-document>

<xsl:text>&#xA;include::</xsl:text><xsl:value-of select="$filename"/><xsl:text>[leveloffset=+3]</xsl:text>

    				</xsl:for-each>
    				</xsl:for-each>
    			</xsl:for-each-group>

    </xsl:template>


<xsl:template name="output-authorizations">

	<!--<xsl:text>&#xA;&#xA;[discrete]&#xA;</xsl:text>  
	<xsl:text>==== Authorizations &#xA;</xsl:text>-->
	
	<xsl:text>&#xA;&#xA;**Authorizations: **</xsl:text>
	
	<xsl:for-each select="./xp:array[@key='security']/xp:map">
		<xsl:value-of select="xp:array/@key"/><xsl:text> (**</xsl:text><xsl:value-of select="xp:array/xp:string"/><xsl:text>**)&#xA;&#xA;</xsl:text>
	</xsl:for-each>
	
</xsl:template>



<xsl:template name="output-path-parameters">

	<xsl:if test="xp:array[@key='parameters']/xp:map/xp:string[@key='in'] = 'path'">
		
		<xsl:text>&#xA;[discrete]&#xA;</xsl:text>  
		<xsl:text>== Path parameters&#xA;&#xA;</xsl:text>	
		<xsl:text>[options="header", width=100%, cols=".^2a,.^3a,.^9a,.^4a"]&#xA;</xsl:text>
		<xsl:text>|===&#xA;</xsl:text>
		<xsl:text>|Type|Name|Description|Schema&#xA;</xsl:text>    

		<xsl:for-each select="xp:array[@key='parameters']/xp:map[xp:string[@key='in'][.='path']]">


			<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='in']"/>
			<xsl:text>|**</xsl:text><xsl:value-of select="./xp:string[@key='name']"/><xsl:text>**</xsl:text>
			
			<xsl:choose>
				<xsl:when test="./xp:boolean[@key='required'] = 'true'"><xsl:text> + &#xA;_required_</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text> + &#xA;_optional_</xsl:text></xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='description']"/>
			<xsl:text>|</xsl:text>
			
			<xsl:choose>
				<xsl:when test="./xp:map[@key='schema']/xp:string"><xsl:value-of select="./xp:map[@key='schema']/xp:string"/></xsl:when>
				<xsl:when test="./xp:string[@key='type']"><xsl:value-of select="./xp:string[@key='type']"/></xsl:when>
			</xsl:choose>
			
			<xsl:text>&#xA;</xsl:text>
			
		</xsl:for-each>

		<xsl:text>|===&#xA;</xsl:text> 

	</xsl:if>


</xsl:template>

<xsl:template name="output-query-parameters">

	<xsl:if test="xp:array[@key='parameters']/xp:map/xp:string[@key='in'] = 'query'">
		
		<xsl:text>&#xA;&#xA;[discrete]&#xA;</xsl:text>  	
		<xsl:text>== Query parameters&#xA;&#xA;</xsl:text>	
		
		<xsl:text>[options="header", width=100%, cols=".^2a,.^3a,.^9a,.^4a"]&#xA;</xsl:text>
		<xsl:text>|===&#xA;</xsl:text>
		<xsl:text>|Type|Name|Description|Schema&#xA;</xsl:text>    
		
		<xsl:for-each select="xp:array[@key='parameters']/xp:map[xp:string[@key='in'][.='query']]">
			
			<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='in']"/>
			<xsl:text>|**</xsl:text><xsl:value-of select="./xp:string[@key='name']"/><xsl:text>**</xsl:text>
			
			<xsl:choose>
				<xsl:when test="./xp:boolean[@key='required'] = 'true'"><xsl:text> + &#xA;_required_</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text> + &#xA;_optional_</xsl:text></xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='description']"/>
			<xsl:text>|</xsl:text>
			<xsl:choose>
				<xsl:when test="./xp:map[@key='schema']/xp:string"><xsl:value-of select="./xp:map[@key='schema']/xp:string"/></xsl:when>
				<xsl:when test="./xp:string[@key='type']"><xsl:value-of select="./xp:string[@key='type']"/></xsl:when>
			</xsl:choose>
			
			<xsl:text>&#xA;</xsl:text>
		</xsl:for-each>
		
		<xsl:text>|===&#xA;</xsl:text> 
	
	</xsl:if>

</xsl:template>



<xsl:template name="output-body-schema">

	
	<xsl:if test="xp:array[@key='parameters']/xp:map/xp:string[@key='in'] = 'body'">
	
		<xsl:variable name="defn" select="xp:array[@key='parameters']/xp:map[xp:string[@key='in'] = 'body']/xp:map[@key='schema']/xp:string[@key='$ref']"/>
		
		<xsl:variable name="defn-name" select="substring-after($defn, '/definitions/')"/>                  
		                  
		<xsl:for-each select="/xp:map/xp:map[@key='definitions']/xp:map[@key=$defn-name]">                  
		
			<xsl:text>&#xA;&#xA;[discrete]&#xA;</xsl:text>  	
			<xsl:text>== Request body schema (application/json)&#xA;&#xA;</xsl:text>
			<xsl:value-of select="xp:string[@key='description']"/><xsl:text>&#xA;&#xA;</xsl:text>	
			
			<xsl:text>[options="header", width=100%, cols=".^3a,.^9a,.^4a"]&#xA;</xsl:text>
			<xsl:text>|===&#xA;</xsl:text>
			<xsl:text>|Name|Description|Schema&#xA;</xsl:text>   
			
		
			<xsl:for-each select="xp:map[@key='properties']/xp:map">
			
				<xsl:text>|**</xsl:text><xsl:value-of select="@key"/><xsl:text>**</xsl:text>
				
				<xsl:choose>
					<xsl:when test="./xp:boolean[@key='required'] = 'true'"><xsl:text> + &#xA;_required_</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text> + &#xA;_optional_</xsl:text></xsl:otherwise>
				</xsl:choose>
				
				<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='description']"/>
				<xsl:text>|</xsl:text>
				
				<xsl:choose>
					<xsl:when test="./xp:string[@key='type']"><xsl:value-of select="./xp:string[@key='type']"/>
						<xsl:if test="./xp:string[@key='type']='array'"><xsl:text> of </xsl:text><xsl:value-of select="xp:map[@key='items']/xp:string[@key='type']"/>
							<xsl:text> + &#xA;</xsl:text>
							<xsl:if test="xp:number[@key='minItems'] &gt; 0"><xsl:text>`non-empty` </xsl:text></xsl:if>
							<xsl:if test="xp:boolean[@key='uniqueItems'] = 'true'"><xsl:text>`unique` </xsl:text></xsl:if>
						</xsl:if>					
					</xsl:when>
				</xsl:choose>
				
				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>
		
			<xsl:text>|===&#xA;</xsl:text> 		
		</xsl:for-each>
	
	</xsl:if>


</xsl:template>


<xsl:template name="output-responses">
	
	<xsl:text>&#xA;&#xA;[discrete]&#xA;</xsl:text>   
	<xsl:text>== Responses&#xA;&#xA;</xsl:text>	
	
	<xsl:text>[options="header", width=100%, cols=".^2a,.^14a,.^4a"]&#xA;</xsl:text>
	<xsl:text>|===&#xA;</xsl:text>
	<xsl:text>|HTTP Code|Description|Schema&#xA;</xsl:text>
	
	
	<xsl:for-each select="xp:map[@key='responses']/xp:map">
		<xsl:sort select="@key" order="ascending"/>
		
		<xsl:text>|</xsl:text><xsl:value-of select="./@key"/>
		<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='description']"/>
		<xsl:text>|</xsl:text>
		
		<xsl:variable name="defn" select="substring-after(./xp:map[@key='schema']/xp:string, '#/definitions/')"/>
		<xsl:if test="$defn != ''">
			<xsl:value-of select="concat('&lt;&lt;_', lower-case($defn), ',', $defn, '&gt;&gt;')"/>
		</xsl:if>
	
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>

	<xsl:text>|===&#xA;</xsl:text> 
	
</xsl:template>


<xsl:template name="output-response-defns">


<xsl:result-document href="modules/api-definitions.adoc"  indent="no" omit-xml-declaration="yes">
	<xsl:text>&#xA;&#xA;= Definitions&#xA;</xsl:text>
	
	<xsl:variable name="list-of-defns" select="for $i in distinct-values(//xp:map[@key='responses']//xp:map[@key='schema']/xp:string[@key='$ref']) return substring-after($i, '#/definitions/')"/>
	
	
	<xsl:for-each select="//xp:map[@key='definitions']/xp:map[@key = $list-of-defns]">
		<xsl:call-template name="output-defn"/>
	</xsl:for-each>	
</xsl:result-document>

<xsl:text>&#xA;&#xA;include::</xsl:text><xsl:value-of select="'modules/api-definitions.adoc'"/><xsl:text>[leveloffset=+2]&#xA;</xsl:text>

</xsl:template>



<xsl:template name="output-defn">
	
	<xsl:value-of select="concat('&#xA;[[_', lower-case(@key), ']]&#xA;')"/>
	<xsl:value-of select="concat('== ', @key, '&#xA;&#xA;')"/>	
	
	<xsl:text>[options="header", width=100%, cols=".^3a,.^9a,.^4a"]&#xA;</xsl:text>
	<xsl:text>|===&#xA;</xsl:text>
	<xsl:text>|Name|Description|Schema&#xA;</xsl:text>   
	
	
	<xsl:for-each select="xp:map[@key='properties']/xp:map">
	
		<xsl:text>|**</xsl:text><xsl:value-of select="@key"/><xsl:text>**</xsl:text>
		
		<xsl:choose>
			<xsl:when test="./xp:boolean[@key='required'] = 'true'"><xsl:text> + &#xA;_required_</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text> + &#xA;_optional_</xsl:text></xsl:otherwise>
		</xsl:choose>
		
		<xsl:text>|</xsl:text><xsl:value-of select="./xp:string[@key='description']"/>
		<xsl:text>|</xsl:text>
		<xsl:choose>
			<xsl:when test="./xp:string[@key='type']"><xsl:value-of select="./xp:string[@key='type']"/>
				<xsl:if test="./xp:string[@key='type']='array'"><xsl:text> of </xsl:text><xsl:value-of select="xp:map[@key='items']/xp:string[@key='type']"/>
					<xsl:text> + &#xA;</xsl:text>
					<xsl:if test="xp:number[@key='minItems'] &gt; 0"><xsl:text>`non-empty` </xsl:text></xsl:if>
					<xsl:if test="xp:boolean[@key='uniqueItems'] = 'true'"><xsl:text>`unique` </xsl:text></xsl:if>
				</xsl:if>
			
			</xsl:when>
		</xsl:choose>
		
		<xsl:text>&#xA;</xsl:text>
	</xsl:for-each>
	
	<xsl:text>|===&#xA;</xsl:text> 
</xsl:template>


<xsl:template name="output-prologue">

<xsl:text>include::modules/attributes.adoc[]</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;[id='api']</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;= {productname} API Guide</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;The {productname} application programming interface (API) is an OAuth 2 RESTful API that</xsl:text>
<xsl:text>&#xA;consists of a set of endpoints</xsl:text>
<xsl:text>&#xA;for adding, displaying, changing and deleting features for {productname}.</xsl:text>
<xsl:text>&#xA;This guide describes those endpoints and shows command and browser-based examples</xsl:text>
<xsl:text>&#xA;for accessing them.</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;include::modules/proc_use-api.adoc[leveloffset=+1]</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;== Appendix A: {productname} Application Programming Interface (API)</xsl:text>
<xsl:text>&#xA;[id="ref-api-quay"]</xsl:text>
<xsl:text>&#xA;</xsl:text>
<xsl:text>&#xA;This API allows you to perform many of the operations required to work with {productname} repositories, users, and organizations.</xsl:text>
<xsl:text>&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>
