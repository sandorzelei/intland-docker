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

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<div class="actionBar">
	<c:url var="actionUrl" value="/servicedesk/serviceDesk.spr"/>
	<spring:message code="tracker.showAll.label" text="All" var="allLabel"/>

	<spring:message code="tracker.serviceDesk.field.requestType.label" text="Request type" var="requestTypeTitle"/>
	<form:form action="${actionUrl}" method="GET">
		<label for="trackerId">${requestTypeTitle}:</label>
		<form:select path="trackerId" id="trackerId" multiple="false">
			<form:option value="-1" label="${allLabel}"/>
			<c:forEach items="${trackerTitles}" var="entry">
				<form:option value="${entry.key.id}" label="${entry.value}"/>
			</c:forEach>
		</form:select>

		<label for="statusFilter"><spring:message code="tracker.field.Status.label" text="Status"/>:</label>
		<spring:message code="issue.flag.Open.label" text="Open" var="openLabel"/>
		<spring:message code="issue.flag.Closed.label" text="Closed" var="closedLabel"/>
		<form:select path="statusFilter" id="statusFilter" multiple="false">
			<form:option value="All" label="${allLabel }"/>
			<form:option value="Open" label="${openLabel }"/>
			<form:option value="Closed" label="${closedLabel }"/>
		</form:select>

		<form:button class="button"><spring:message code="Filter" text="Filter"/></form:button>
	</form:form>
</div>

<display:table name="${items}" id="trackeItem" cellpadding="0"
	pagesize="20" class="trackerItems" requestURI="${requestURI}"
	decorator="com.intland.codebeamer.controller.servicedesk.ServiceDeskTableDecorator">

	<display:setProperty name="basic.empty.showtable" value="false" />
	<%--<display:setProperty name="basic.show.header" value="false" /> --%>
	<display:setProperty name="paging.banner.placement" value="bottom" />
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />

	<spring:message code="tracker.field.Summary.label" text="Summary" var="summaryTitle"/>
	<spring:message code="tracker.field.Status.label" text="Status" var="statusTitle"/>
	<spring:message code="tracker.field.Modified at.label" text="Modified at" var="modifiedAtTitle"/>

	<display:column title="" class="columnSeparator iconColumn" property="icon"/>
	<display:column title="${summaryTitle}" class="columnSeparator" property="name"/>
	<display:column title="${requestTypeTitle}" class="columnSeparator" property="tracker"/>
	<display:column title="${statusTitle}" class="columnSeparator" property="status"/>
	<display:column title="${modifiedAtTitle}" class="columnSeparator" property="modifiedAt"/>
</display:table>
