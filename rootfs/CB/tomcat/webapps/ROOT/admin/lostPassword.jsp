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
<meta name="moduleCSSClass" content="newskin workspaceModule loginModule"/>

<ui:actionMenuBar>
	<span class="titleNormal"><spring:message code="lostPassword.title" text="Lost Password"/></span>
</ui:actionMenuBar>

<html:form action="/lostPassword">

<spring:message var="applyButton"  code="button.send" text="Send"/>
<spring:message var="cancelButton" code="Cancel" text="Cancel"/>

<ui:actionBar>
	<html:submit styleClass="button" property="send"  value="${applyButton}" />
	<html:cancel styleClass="button cancelButton" value="${cancelButton}"/>
</ui:actionBar>

<ui:showErrors />

<div class="information"><spring:message code="password.reset.send.info" text="Please enter your account name or email to send a password reset request!"/></div>

<div class="contentWithMargins">
<spring:message code="lostPassword.username" text="Please enter your account name"/>: <html:text property="user" size="15" />
&nbsp;
<spring:message code="lostPassword.orEmail" text="or email"/>: <html:text property="email" size="30" />
</div>

</html:form>
