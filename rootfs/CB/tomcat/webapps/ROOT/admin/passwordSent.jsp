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

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="login"/>

<ui:actionMenuBar>
	<spring:message code="lostPassword.title" text="Lost Password"/>
</ui:actionMenuBar>

<div class="information">
	<spring:message code="password.reset.sent" text="The password reset URL was sent you by email, Please check your mailbox."/>
</div>

