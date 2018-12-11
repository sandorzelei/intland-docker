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
 *
 * $Revision$ $Date$
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="charttaglib" prefix="chart" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%
	pageContext.setAttribute("lineBreak", "<TR><TD>&nbsp;</TD></TR>", PageContext.REQUEST_SCOPE);
%>

<c:set var="user" value="${pageContext.request.userPrincipal}" />

<c:set var="user_id" value="${user.id}" />

<c:forEach items="${paramValues.proj_id}" var="pr_id" varStatus="status">
	<c:set var="proj_ids" value="${proj_ids}${pr_id}" />
	<c:if test="${!status.last}">
		<c:set var="proj_ids" value="${proj_ids}," />
	</c:if>
</c:forEach>

<c:if test="${empty proj_ids}">
	<c:set var="proj_ids" value="${PROJECT_DTO.id}" />
</c:if>

<c:set var="proj_id" value="${proj_ids}" scope="request" />

<c:set var="geometry" value="${param.geometry}" />
<c:choose>
	<c:when test="${geometry == 'tight'}">
		<c:set var="whtd" value="450" scope="request" />
		<c:set var="hght" value="250" scope="request" />
	</c:when>

	<c:when test="${geometry == 'wide'}">
		<c:set var="whtd" value="750" scope="request" />
		<c:set var="hght" value="400" scope="request" />
	</c:when>

	<c:otherwise>
		<c:set var="whtd" value="600" scope="request" />
		<c:set var="hght" value="300" scope="request" />
	</c:otherwise>
</c:choose>

<span class="filterForm">
<ui:showErrors />

<c:if test="${!empty param.action}">
	<c:set var="action" value="${param.action}" />
</c:if>

<html:form action="${action}">
	<jsp:useBean id="projectChartDateSelectorForm" class="com.intland.codebeamer.struts.ProjectChartDateSelectorForm" scope="session" />

	<c:set var="parseDatePattern" value="${userData.dateFormatPattern}" />
	<c:set var="formatDatePattern" value="yyyy-MM-dd" scope="request" />

	<c:catch>
		<fmt:parseDate var="startDate" value="${projectChartDateSelectorForm.map.startDate}" scope="request" pattern="${parseDatePattern}" parseLocale="en" />
	</c:catch>

	<c:if test="${empty startDate}">
		<c:catch>
			<fmt:parseDate var="startDate" value="${projectChartDateSelectorForm.map.startDate}" scope="request" pattern="yyyy-MM-dd" parseLocale="en" />
		</c:catch>
	</c:if>

	<c:catch>
		<fmt:parseDate var="closeDate" value="${projectChartDateSelectorForm.map.closeDate}" scope="request" pattern="${parseDatePattern}" parseLocale="en" />
	</c:catch>

	<c:if test="${empty closeDate}">
		<c:catch>
			<fmt:parseDate var="closeDate" value="${projectChartDateSelectorForm.map.closeDate}" scope="request" pattern="yyyy-MM-dd" parseLocale="en" />
		</c:catch>
	</c:if>

	<html:hidden property="action" value="${action}" />
	<c:forTokens items="${proj_id}" delims="," var="pid" varStatus="status">
		<html:hidden property="proj_id" value="${pid}" />
	</c:forTokens>

	<label>
		<spring:message code="period.label" text="Period"/>
		<%-- get the duration from the dyna-action-form --%>
		<c:set var="duration" value='<%= projectChartDateSelectorForm.get("duration")%>' />
		<ui:duration property="duration" value="${duration}">
			<label>
				<spring:message code="period.begin.label" text="Start"/>
				<html:text property="startDate" size="12" styleId="startDate" />
				<ui:calendarPopup textFieldId="startDate" otherFieldId="closeDate"/>
			</label>

			<label>
				<spring:message code="period.end.label" text="End"/>
				<html:text property="closeDate" size="12" styleId="closeDate" />
				<ui:calendarPopup textFieldId="closeDate" otherFieldId="startDate"/>
			</label>
		</ui:duration>
	</label>

	<label>
		<spring:message code="chart.geometry.label" text="Geometry"/>
		<html:select property="geometry">
			<html:option value="tight"><spring:message code="chart.geometry.tigh" text="Tight"/></html:option>
			<html:option value="normal"><spring:message code="chart.geometry.normal" text="Normal"/></html:option>
			<html:option value="wide"><spring:message code="chart.geometry.wide" text="Wide"/></html:option>
		</html:select>
	</label>

	<html:submit styleClass="button" property="GO">
		<spring:message code="search.submit.label" text="GO"/>
	</html:submit>
</html:form>
</span>