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


<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.inbox.MailReceiver"%>
<%@ page import="com.intland.codebeamer.persistence.dto.InboxDto" %>

<%-- Show an inbox details in read only mode
	 Parameters:
	 requestScope.inbox		The inboxDto to show
--%>
<c:set var="inbox" value="${requestScope.inbox}" />

<c:if test="${! empty param.title}">
	${param.title}
</c:if>


<c:if test="${! empty inbox}">
	<TABLE BORDER="0" CELLPADDING="2" style="border-collapse: separate;border-spacing: 1px;">
	<TR>
		<TD CLASS="optional"><spring:message code="inbox.name.label" text="Name"/>:</TD>
		<TD CLASS="tableItem expand" valign="top">
			${inbox.name}
		</TD>
	</TR>

	<TR>
		<TD CLASS="optional" VALIGN="top"><spring:message code="inbox.description.label" text="Description"/>:</TD>
		<TD CLASS="tableItem expand" valign="top">
			<tag:transformText value="${inbox.description}" format="${inbox.descriptionFormat}" />
		</TD>
	</TR>

	<TR>
		<TD CLASS="optional"><spring:message code="inbox.email.label" text="Email Address"/>:</TD>
		<TD CLASS="tableItem expand">
			<a href="mailto:<c:out value='${inbox.email}'/>"><c:out value='${inbox.email}'/></a>
		</TD>
	</TR>

	<TR VALIGN="top">
		<TD CLASS="optional"><spring:message code="inbox.allowedEmails.label" text="Allowed Email Addresses"/>:</TD>
		<TD class="tableItem expand">
			<c:set var="ALLOWED_EMAILS_ALL" value="<%=InboxDto.ALLOWED_EMAILS_ALL%>" />
			<c:set var="ALLOWED_EMAILS_ALL_CB" value="<%=InboxDto.ALLOWED_EMAILS_ALL_CB%>" />
			<c:set var="ALLOWED_EMAILS_PROJECT_MEMBERS" value="<%=InboxDto.ALLOWED_EMAILS_PROJECT_MEMBERS%>" />

			<c:if test="${inbox.allowedEmails eq ALLOWED_EMAILS_ALL}">
				<spring:message code="inbox.allowedEmails.all" text="All"/>
			</c:if>
			<c:if test="${inbox.allowedEmails eq ALLOWED_EMAILS_ALL_CB}">
				<spring:message code="inbox.allowedEmails.users" text="Only registered Users"/>
			</c:if>
			<c:if test="${inbox.allowedEmails eq ALLOWED_EMAILS_PROJECT_MEMBERS}">
				<spring:message code="inbox.allowedEmails.members" text="Only Project Members"/>
			</c:if>
		</TD>
	</TR>

	<TR>
		<TD CLASS="optional"><spring:message code="inbox.extraAllowedEmails.label" text="Additional Email Addresses"/>:</TD>
		<TD CLASS="tableItem expand">
			${inbox.extraAllowedEmails}
		</TD>
	</TR>

	<TR>
		<TD CLASS="optional"><spring:message code="inbox.enabled.label" text="Enabled"/>:</TD>
		<TD class="tableItem expand">
			<c:choose>
				<c:when test="${inbox.enabled}">
					<spring:message code="button.yes" text="Yes"/>
				</c:when>
				<c:otherwise>
					<spring:message code="button.no" text="No"/>
				</c:otherwise>
			</c:choose>
		</TD>
	</TR>

	</TABLE>
</c:if>
