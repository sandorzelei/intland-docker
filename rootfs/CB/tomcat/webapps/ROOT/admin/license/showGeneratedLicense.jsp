<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="license"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<head>
	<style>
	<!--
		#licenseXML, #licenseBinary {
			border: solid 1px silver;
		}

	-->
	</style>
</head>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.license.label" text="License"/></ui:pageTitle>
</ui:actionMenuBar>

<div class="contentWithMargins">
	<h4>The generated license is:</h4>
	<div id="licenseInformationContainer">
		<jsp:include page="showLicenseInformation.jsp"/>
	</div>

	<h4>The generated license in XML format:</h4>
	<pre id="licenseXML"><c:out value="${licenseXML}" escapeXml="true"/></pre>

	<c:if test="${!empty licenseBinary}">
		<h4>The generated license in binary format is:</h4>
		<pre id="licenseBinary">${licenseBinary}</pre>
	</c:if>
</div>
