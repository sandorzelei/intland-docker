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
 * $Revision: 20363:7da50ff3cb82 $ $Date: 2009-02-12 05:41 +0000 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@page import="com.intland.codebeamer.persistence.dao.InboxDao"%>
<%@page import="com.intland.codebeamer.persistence.dao.impl.InboxDaoImpl"%>

<%
	InboxDao inboxDao = InboxDaoImpl.getInstance();
	pageContext.setAttribute("defaultInbox", inboxDao.findDefault());
%>

<%-- JSP fragment to show default/main inbox information --%>
<c:set var="title" >
	<spring:message code="sysadmin.inboxes.main.tooltip" text="The Main Inbox is where the replies to the CodeBeamer e-mails are received."/>

	<ui:title style="top-sub-headline-decoration" bottomMargin="10" separatorGapHeight="2" titleStyle="" topMargin="0" />

	<c:if test="${empty defaultInbox}">
		<spring:message code="sysadmin.inboxes.main.missing" text="<strong>No Main Inbox is defined yet.</strong> Create it by clicking on link above..."/>
	</c:if>
</c:set>

<c:set var="inbox" value="${defaultInbox}" scope="request" />

<div class="actionBar">
	<ui:actionLink builder="inboxActionMenuBuilder" keys="createMainInbox, editInbox" subject="${inbox}"/>
</div>

<jsp:include page="./showInbox.jsp">
	<jsp:param name="title" value="${title}" />
</jsp:include>
