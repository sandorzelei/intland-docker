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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content=""/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:title style="top-sub-headline-decoration" >
	<ui:pageTitle>Who is - Host: <c:out value='${hostname}'/> User: <c:out value='${user.name}'/> (<c:out value='${user.lastName}, ${user.firstName}'/>)</ui:pageTitle>
</ui:title>

<c:if test="${!empty geoLocation.mapUrl}">
	<table class="fullExpandTable displaytag" border="0" cellspacing="0" cellpadding="0">
		<tr class="odd">
			<td class="textData">Country:</td>

			<tag:tableColumnSeparator />

			<td class="textData"><c:out value="${geoLocation.country}" /></td>
		</tr>

		<tr class="even">
			<td class="textData">Region:</td>

			<tag:tableColumnSeparator />

			<td class="textData"><c:out value="${geoLocation.region}" /></td>
		</tr>

		<tr class="odd">
			<td class="textData">Zip Code:</td>

			<tag:tableColumnSeparator />

			<td class="textData"><c:out value="${geoLocation.zip}" /></td>
		</tr>

		<tr class="even">
			<td class="textData">City:</td>

			<tag:tableColumnSeparator />

			<td class="textData"><c:out value="${geoLocation.city}" /></td>
		</tr>

		<tr class="odd">
			<td class="textData">Map:</td>

			<tag:tableColumnSeparator />

			<td class="textData"><a href="${geoLocation.mapUrl}" target="_blank"><img border="0" src="${pageContext.request.contextPath}/images/newskin/action/map.png" title="Google Map" /></a></td>
		</tr>

		<tr>
			<td height="10"></td>
		</tr>
	</table>
</c:if>

<display:table class="fullExpandTable" cellpadding="0" requestURI="" name="${whois}" id="who">
	<display:column title="Property" property="property" headerClass="textData" class="textData columnSeparator" sortable="true" />

	<display:column title="Value" property="value"
		headerClass="textData" class="textData" sortable="true" />
</display:table>
