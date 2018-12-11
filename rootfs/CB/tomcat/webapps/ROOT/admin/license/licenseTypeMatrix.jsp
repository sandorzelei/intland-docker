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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
	JSP fragment shows the license-type matrix.

	Parameters:
	${licenseTypes}	- List<Map.Entry<LicenseType,Collection<LicenseType>>>
 --%>
<c:if test="${!empty licenseTypes}">
	<style type="text/css">
		.licenseTypeMatrix td {
			white-space: nowrap;
			text-align: center;
		}
		.licenseTypeMatrix .checked {
			background-color: green;
			color: white;
		}
	</style>
	<table border="2" cellpadding="2" cellspacing="0" class="licenseTypeMatrix">
		<tr>
		  	<th><spring:message code="sysadmin.license.product" text="Product"/></th>
			<c:forEach items="${licenseTypes[0].key.metaInfo.propertyLabels}" var="propname" varStatus="loop">
				<c:set var="propInfo" value="${ licenseTypes[0].key.metaInfo.properties[loop.index]}"/>
				<c:choose>
					<c:when test="${propInfo == 'documentApproval' or propInfo == 'documentReview'}">
						<th style="background-color: red">
					</c:when>
					<c:when test="${!showTraceabilityMatrix and propInfo == 'traceabilityMatrix'}">
					</c:when>
					<c:otherwise>
						<th>
					</c:otherwise>
				</c:choose>
		  			<spring:message var="name" code="sysadmin.license.product.${propname}" text="${propname}" htmlEscape="true"/>
					<c:if test="${showTraceabilityMatrix or propInfo != 'traceabilityMatrix'}">
					    <c:out value="${name}"/>
					</c:if>
					<c:if test="${licenseTypes[0].key.metaInfo.properties[loop.index] == 'documentApproval'}">
						(deprecated)
					</c:if>

		  			<spring:message var="tooltip" code="sysadmin.license.product.${licenseTypes[0].key.metaInfo.properties[loop.index]}.tooltipextra" text="" htmlEscape="true"/>
					<c:if test="${!showTraceabilityMatrix and propInfo == 'traceabilityMatrix'}">
					    <c:set var="tooltip" value="" />
					</c:if>
		  			<c:if test="${not empty tooltip}">
		  				<span class="helpLinkButton withContextHelp" title="sysadmin.license.product.${licenseTypes[0].key.metaInfo.properties[loop.index]}.tooltipextra"/>
		  			</c:if>
		  		<c:if test="${showTraceabilityMatrix or propInfo != 'traceabilityMatrix'}">
		  		</th>
		  		</c:if>
		  	</c:forEach>
		</tr>
		<c:forEach items="${licenseTypes}" var="licenseType">
			<tr class="odd">
				<spring:message var="tooltip" code="sysadmin.license.product.${licenseType.key.type}.tooltip" text="" htmlEscape="true"/>
		   		<td title="${tooltip}" style="text-align:left;"><b><spring:message code="sysadmin.license.product.${licenseType.key.type}" text="${licenseType.key.type}"/></b></td>
		   		<c:set var="properties" value="${licenseType.key.properties}" />
				<c:forEach items="${licenseType.key.metaInfo.booleanProperties}" var="propname">
				<c:if test="${showTraceabilityMatrix or propname != 'traceabilityMatrix'}">
				    <td title="${licenseType.key.type} - ${propname}" class="${properties[propname] ? 'checked': ''}" ><c:out value="${properties[propname] ? 'x' : '-'}"/></td>
				</c:if>
			  	</c:forEach>
				<c:forEach items="${licenseType.key.metaInfo.numericProperties}" var="propname">
                    <td title="${licenseType.key.type} - ${propname}" ><c:out value="${properties[propname]}"/></td>
			  	</c:forEach>
		   	</tr>
			<c:forEach items="${licenseType.value}" var="option">
				<tr class="even">
					<spring:message var="tooltip" code="sysadmin.license.option.${option.type}.tooltip" text="" htmlEscape="true"/>
			   		<td title="${tooltip}" style="text-align:left;">&nbsp;&nbsp;+&nbsp;<spring:message code="sysadmin.license.option.${option.type}" text="${option.type}"/></td>
			   		<c:set value="${option.properties}" var="properties"/>
					<c:forEach items="${licenseType.key.metaInfo.booleanProperties}" var="propname">
					<c:if test="${showTraceabilityMatrix or propname != 'traceabilityMatrix'}">
					    <td title="${licenseType.key.type} - ${propname}" class="${properties[propname] ? 'checked': ''}" ><c:out value="${properties[propname] ? 'x' : '-'}"/></td>
					</c:if>
				  	</c:forEach>
					<c:forEach items="${licenseType.key.metaInfo.numericProperties}" var="propname">
				  		<td title="${licenseType.key.type} - ${propname}" ><c:out value="${properties[propname]}"/></td>
				  	</c:forEach>
			   	</tr>
			</c:forEach>
		</c:forEach>
	</table>
</c:if>