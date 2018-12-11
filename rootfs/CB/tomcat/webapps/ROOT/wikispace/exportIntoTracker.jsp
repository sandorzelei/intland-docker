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
<meta name="module" content="wikispace"/>
<meta name="moduleCSSClass" content="wikiModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<spring:message var="exportToTracker" code="wiki.export.tracker.label" />

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false" >${exportToTracker}</ui:pageTitle>
</ui:actionMenuBar>

<form:form command="command">
	<spring:message var="saveButton" code="button.save"/>
	<spring:message var="cancelButton" code="button.cancel"/>
<div class='actionBar'>
	<c:if test="${!empty trackers}">
		&nbsp;&nbsp;<input type="submit" class="button" name="_save" value="${exportToTracker}"  />
	</c:if>
	&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close()" />
</div>
<div class="contentWithMargins">
	<form:hidden path="docId"/>
	<c:choose>
		<c:when test="${empty trackers }">
			<div class="warning">
				<spring:message text="No trackers found where the new item could be created" code="wiki.export.tracker.no.trackers"></spring:message>
			</div>
		</c:when>
		<c:otherwise>
			<p>
				<spring:message code="wiki.export.tracker.should.be.imported" arguments="${issuesShouldBeImported}" />
			</p>

			<form:radiobuttons path="trackerId" items="${trackers}" itemLabel="name" itemValue="id" delimiter="<br />"/>
		</c:otherwise>
	</c:choose>

</div>

</form:form>