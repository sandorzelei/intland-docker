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
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="requestURI" value="/sysadmin/configPeriodicalInbox.spr" />

<ui:actionMenuBar showGlobalMessages="true">
	<ui:pageTitle><spring:message code="sysadmin.inboxes.title" text="Email Inboxes and Polling"/></ui:pageTitle>
</ui:actionMenuBar>

<div class="contentWithMargins">
<ui:showErrors />

<tab:tabContainer id="inbox-customize" skin="cb-box">
<c:url var="pollNowURL" value="/sysadmin/pollInboxNow.spr" />	
<spring:message var="pollNowMessage" code="sysadmin.inboxes.polling.now" text="Poll inboxes now!"/>
<c:set var="inboxPolling">
	<spring:message code="sysadmin.inboxes.polling.title" text="Polling"/>
	&nbsp;<a id="pollNowLink" title="${pollNowMessage}" ><img style="position: fixed;" src="<c:url value='/images/exec.gif'/>"/></a>
	&nbsp;&nbsp;
</c:set>

<script type="text/javascript">
	$("#pollNowLink").click(function(event) {
		window.location.href="${pollNowURL}";
		event.stopPropagation();
	});
</script>

<tab:tabPane id="inbox-customize-polling" tabTitle="${inboxPolling}">
	<c:url var="action" value="${requestURI}" />
	<form:form action="${action}" >
		<script type="text/javascript">
			$("#period").focus();
		</script>

		<div class="actionBar">
				<a href="${pollNowURL}">${pollNowMessage}</a>

				<spring:message var="saveButton" code="button.save" text="Save"/>
				<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

				&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
				&nbsp;&nbsp;<input type="submit" class="cancelButton button" name="_cancel" value="${cancelButton}" />
		</div>

		<TABLE BORDER="0" CELLPADDING="2" style="border-collapse: separate;border-spacing: 1px;">
		<TR>
			<TD COLSPAN="2">
				<spring:message code="sysadmin.inboxes.polling.period.tooltip" />
			</TD>
		</TR>

		<TR>
			<TD CLASS="mandatory"><spring:message code="sysadmin.inboxes.polling.period.label" text="Polling Period (minutes)"/>:</TD>
			<TD>
				<input type="text" size="5" name="period" value="<c:out value='${period}'/>" />
				<c:if test="${invalidPeriod}">
					<br/>
					<span class="invalidfield"><spring:message code="sysadmin.inboxes.invalid.period" /></span>
				</c:if>
			</TD>
		</TR>

		</TABLE>

	</form:form>
</tab:tabPane>

<spring:message var="inboxMainTitle" code="sysadmin.inboxes.main.title" text="Main Inbox"/>
<tab:tabPane id="inbox-customize-default-inbox" tabTitle="${inboxMainTitle}">
	<jsp:include page="./showDefaultInbox.jsp"/>
</tab:tabPane>

<spring:message var="inboxCustomTitle" code="sysadmin.inboxes.custom.title" text="Email Inboxes"/>
<tab:tabPane id="inbox-customize-inboxes" tabTitle="${inboxCustomTitle}">
	<div class="actionBar">
		<ui:actionLink builder="inboxActionMenuBuilder" keys="createInbox"/>
	</div>

	<b><spring:message code="sysadmin.inboxes.custom.label" text="Email Inboxes"/>:</b><br/>

	<display:table requestURI="${requestURI}" name="${inboxes}" id="item" cellpadding="0" defaultsort="1">
		<spring:message var="inboxProject" code="inbox.project.label" text="Project"/>
		<display:column title="${inboxProject}" sortProperty="project.name" sortable="true" headerClass="textData" class="textData columnSeparator">
			<c:choose>
				<c:when test="${! empty item.project.id}">
					<c:url var="link" value="/project/${item.project.id}"/>
					<a href="${link}"><c:out value="${item.project.name}" default="--" /></a>
				</c:when>
				<c:otherwise>
					--
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="inboxActions" code="inbox.label" text="Inbox"/>
		<display:column title="${inboxActions}" sortable="true"	headerClass="textData" class="textData columnSeparator" escapeXml="false" >
			<ui:actionGenerator builder="inboxActionMenuBuilder" actionListName="actions" subject="${item}">
				<a href="${actions.editInbox.url}" title="${actions.editInbox.toolTip}">
					<c:out value='${item.name}' />
				</a>
			</ui:actionGenerator>
		</display:column>

		<spring:message var="inboxDescription" code="inbox.description.label" text="Description"/>
		<display:column title="${inboxDescription}" property="description" sortable="true"	headerClass="textData" class="textDataWrap columnSeparator" />

		<spring:message var="inboxEmail" code="inbox.email.label" text="Email"/>
		<display:column title="${inboxEmail}" sortable="true" sortProperty="email" headerClass="textData" class="textDataWrap columnSeparator" >
			<c:choose>
				<c:when test="${! empty item.email}"><a href="mailto:<c:out value='${item.email}'/>"><c:out value='${item.email}'/></a></c:when>
				<c:otherwise>--</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="inboxTarget" code="inbox.target.label" text="Target"/>
		<display:column title="${inboxTarget}" sortProperty="reference.shortDescription" sortable="true" headerClass="textData" class="textDataWrap columnSeparator">
			<c:choose>
				<c:when test="${item.parent != null}">
					<c:url var="targetLink" value="${item.parent.urlLink}"/>
					<a href="${targetLink}"><spring:message code="tracker.${item.parent.name}.label" text="${item.parent.name}" /></a>
				</c:when>
				<c:otherwise>
					--
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="inboxEnabled" code="inbox.enabled.label" text="Polling"/>
		<display:column title="${inboxEnabled}" property="enabled" sortable="true" headerClass="textData" class="textData columnSeparator" escapeXml="true" />

		<spring:message var="inboxServer" code="inbox.server.label" text="Server"/>
		<display:column title="${inboxServer}" property="server" sortable="true" headerClass="textData" class="textData columnSeparator" escapeXml="true" />

		<spring:message var="inboxProtocol" code="inbox.protocol.label" text="Protocol"/>
		<display:column title="${inboxProtocol}" property="protocol" sortable="true" headerClass="textData" class="textData columnSeparator" escapeXml="true" />

		<spring:message var="inboxSecure" code="inbox.useSsl.label" text="Secure (SSL)"/>
		<display:column title="${inboxSecure}" property="useSsl" sortable="true" headerClass="textData" class="textData columnSeparator" escapeXml="true" />

		<spring:message var="inboxLastPoll" code="inbox.lastAccessAt.label" text="Last Poll"/>
		<display:column title="${inboxLastPoll}" sortable="false" headerClass="dateData" class="dateData columnSeparator">
			<tag:formatDate value="${lastAccessAt[item.id]}" />
		</display:column>

		<spring:message var="inboxLastModification" code="inbox.lastModifiedAt.label" text="Modification"/>
		<display:column title="${inboxLastModification} " sortProperty="lastModifiedAt" sortable="true"	headerClass="dateData" class="dateData columnSeparator">
			<tag:formatDate value="${item.lastModifiedAt}" />
		</display:column>

	</display:table>

</tab:tabPane>

</tab:tabContainer>
</div>