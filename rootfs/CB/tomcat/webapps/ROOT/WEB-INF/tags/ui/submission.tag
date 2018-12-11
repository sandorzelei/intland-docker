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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>


<%@ attribute name="userId" required="true" description="ID of the user or -1 if it is unknown." %>
<%@ attribute name="userName" required="false" description="Name to display as title of the photo." %>
<%@ attribute name="cssClass" required="false" description="CSS class to add to the component wrapper." %>
<%@ attribute name="cssStyle" required="false" description="CSS styling to add to the component wrapper." %>
<%@ attribute name="date" type="java.util.Date" required="true" description="Date of submission." %>
<%@ attribute name="lastModifiedBy" type="java.lang.Integer" required="false" description="Id of user, that made the last modification." %>
<%@ attribute name="lastModifiedAt" type="java.util.Date"    required="false" description="Date of last modification." %>

<table cellpadding="0" cellspacing="0" class="${not empty cssClass ? cssClass : ''}" style="${not empty cssStyle ? cssStyle : ''}">
	<tr>
		<td style="padding-right:0">
			<ui:userPhoto userId="${userId}" userName="${userName}"/>
		</td>
		<td>
			<c:choose>
				<c:when test="${userId != null and userId != -1}">
					<tag:userLink user_id="${userId}"/>
				</c:when>
				<c:otherwise>
					<c:out value="${userName}"/>
				</c:otherwise>
			</c:choose>
			<br>
			<span class="subtext"><tag:formatDate value="${date}"/></span>
		</td>
	</tr>

	<c:if test="${lastModifiedAt != null}">
	<tr>
		<td colspan="2" style="padding-left: 20px;">
			<span class="subtext">
				<spring:message code="document.lastModifiedAt.label" text="Modified last"/>:

				<c:if test="${lastModifiedBy != null and lastModifiedBy != -1}">
					<br>
					<tag:userLink user_id="${lastModifiedBy}" />
				</c:if>

				<br>
				<tag:formatDate value="${lastModifiedAt}"/>
			</span>
		</td>
	</tr>
	</c:if>

</table>

