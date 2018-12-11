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
<meta name="decorator" content="main" />
<meta name="module" content="sysadmin" />
<meta name="moduleCSSClass" content="sysadminModule newskin" />

<%@page import="com.intland.codebeamer.controller.admin.email.SendEmailCommand"%>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<wysiwyg:froalaConfig />

<spring:message var="saveButton" code="button.send" text="Send" />
<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="user.email.send" text="Send Email"/></ui:pageTitle>
</ui:actionMenuBar>

<spring:message code="email.to.loggedInUsers" text="Logged in Accounts" var="loggedInOption"/>
<spring:message code="email.to.allActiveUsers" text="All Accounts" var="allOption"/>
		
<form:form autocomplete="off" commandName="emailCommand">

	<ui:actionBar>
		<input type="submit" class="button" value="${saveButton}" name="_save" />
		<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<div class="contentWithMargins">
	
		<table border="0" cellpadding="1" class="formTableWithSpacing">
			<tr>
				<td class="optional"><spring:message code="email.to.label" text="To"/>:</td>
				<td nowrap>
					<form:select path="type">
						<form:option value="<%=SendEmailCommand.LOGGEDIN%>" label="${loggedInOption}" />
						<form:option value="<%=SendEmailCommand.ALL%>" label="${allOption}" />
					</form:select>
				</td>
			</tr>		
			<tr>
				<td class="mandatory"><spring:message code="email.subject.label" text="Subject"/>:</td>
				<td class="expandText">
					<form:input cssClass="expandText" size="80" path="subject"/>
				</td>
			</tr>
	
			<tr valign="top">
				<td class="mandatory">
					<span class="labelText"><spring:message code="email.body.label" text="Message"/>:</span>
				</td>
				<td>
					<wysiwyg:editor editorId="message" useAutoResize="false" height="280" formatSelectorSpringPath="textFormat" overlayHeaderKey="wysiwyg.email.message.editor.overlay.header">
					    <form:textarea path="message" cssClass="editor" rows="16" cols="80" />
					</wysiwyg:editor>
				</td>
			</tr>
	
		</table>
		
	</div>

</form:form>
