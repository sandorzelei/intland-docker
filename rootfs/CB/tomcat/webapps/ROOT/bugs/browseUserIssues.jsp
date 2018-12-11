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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<meta name="decorator" content="main"/>
<meta name="module" content="mystart"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false">
	<c:out value="${title}" escapeXml="false" />
</ui:pageTitle>

<style type="text/css">
<!--
	#directly {
		margin-left: 1.5em;
		background-color: transparent;
		border: none;
		font-weight: bold;
	}
	#filtersBox {
		margin: 5px 0px;
		color: white;
	}
	.filterForm label {
		color: white !important;
	}
-->
</style>

<form:form action="${actionURL}" method="POST">
	<ui:actionMenuBar>
			<spring:message code="user.issues.label" text="Issues of"/> <tag:userLink user_id="${member.id}"/>
			<br/>
			<span id="filtersBox" class="filterForm">
				<label><spring:message code="user.issues.fields.label" text="Issues are"/></label>
				<spring:message var="fieldsTitle" code="user.issues.fields.tooltip" text="Filter by the user's relation to the issue"/>
				<form:select cssStyle="margin-left:0.5em;" path="fields" onchange="this.form.submit();" title="${fieldsTitle}">
					<c:forEach items="${fieldList}" var="fieldRel">
						<form:option value="${fieldRel.value}">
							<spring:message code="user.issues.${fieldRel.label}" text="${fieldRel.label}" htmlEscape="true"/>
						</form:option>
					</c:forEach>
				</form:select>
				<label><spring:message code="user.issues.flags.label" text="user, status is"/></label>
				<spring:message var="flagsTitle" code="user.issues.flags.tooltip" text="Filter by issue Status"/>
				<form:select path="show" onchange="this.form.submit();" title="${flagsTitle}">
					<c:forEach items="${showList}" var="flagSet">
						<form:option value="${flagSet.name}">
							<spring:message code="issue.flags.${flagSet.name}.label" text="${flagSet.name}" htmlEscape="true"/>
						</form:option>
					</c:forEach>
				</form:select>
				<label><spring:message code="user.issues.filter.label" text=", and"/></label>
				<spring:message var="filterTitle" code="user.issues.filter.tooltip" text="Filter by Due Date"/>
				<form:select path="filter" onchange="this.form.submit();" title="${filterTitle}">
					<c:forEach items="${filterList}" var="filterOption">
						<form:option value="${filterOption.id}">
							<spring:message code="issue.filter.${filterOption.name}.label" text="${filterOption.name}" htmlEscape="true"/>
						</form:option>
					</c:forEach>
				</form:select>
<%--
						&nbsp;view
						<form:select path="viewId">
							<form:options items="${viewList}" itemLabel="name" itemValue="id"/>
						</form:select>

						<c:if test="${viewId gt 0}">
							<c:url var="editViewURL" value="/proj/tracker/editTrackerView.do">
								<c:param name="view_id"  value="${viewId}"/>
								<c:param name="referrer" value="${referrerURI}"/>
							</c:url>
							<a href="${editViewURL}">Edit</a>|
						</c:if>

						<c:url var="newViewURL" value="/proj/tracker/editTrackerView.do">
							<c:param name="entityId" 	 value="${user.id}"/>
							<c:param name="entityTypeId" value="1"/>
							<c:param name="viewTypeId"   value="2"/>
							<c:param name="referrer" 	 value="${referrerURI}"/>
						</c:url>

						<a href="${newViewURL}">New</a>
--%>
				<spring:message var="directlyTitle" code="user.issues.directly.tooltip" text="Excludes the issues bound to the user's roles only"/>
				<label for="directly" style="font-weight: bold;" title="${directlyTitle}">
					<form:checkbox id="directly" path="directly" onclick="this.form.submit();"/>
					<spring:message code="user.issues.directly.label" text="Exclude roles"/>
				</label>
			</span>
	</ui:actionMenuBar>
</form:form>

<bugs:displaytagTrackerItems htmlId="userIssues" layoutList="${userIssueColumns}" items="${items}" selection="false"
	browseTrackerMode="true" defaultsort="1" export="false" pagesize="${pagesize}"	excludedParams="page"
/>

