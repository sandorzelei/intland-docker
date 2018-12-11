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
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<wysiwyg:froalaConfig />

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="cb.loginWelcomeText.title" text="Login and Welcome Text"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form>

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	<input type="submit"  class="button" value="${saveButton}" />
	&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins">
<ui:showErrors />

<style type="text/css">
	#loginText-preview {
		overflow-y: auto;
	}

	#welcomeText-preview {
		overflow-y: auto;
	}

	.style-checkbox {
		height: 50px;
	}

	.style-checkbox td {
		vertical-align: top !important;
	}

	.editor-wrapper:not(.fr-fake-popup-editor) {
        margin-bottom: 20px;
	}
</style>

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing">

<TR VALIGN="top">
	<TD class="optional">
		<spring:message code="cb.loginText.label" text="Login Text" htmlEscape="false"/>
	</TD>
	<TD CLASS="expandTextArea">
		<spring:message var="loginTitle" code="cb.loginText.tooltip" text="This message will appear on the bottom of the login screen"/>
		<wysiwyg:editor editorId="loginText" focus="true" formatSelectorSpringPath="loginTextFormat" useAutoResize="false" height="320" overlayHeaderKey="wysiwyg.login.text.overlay.header">
		    <form:textarea path="loginText" id="loginText" rows="20" cols="70" title="${loginTitle}" />
		</wysiwyg:editor>
	</TD>
</TR>

<TR VALIGN="top" class="style-checkbox">
	<TD class="optional">
		<spring:message code="cb.loginText.style.label" text="Login Text Style:" htmlEscape="false"/>:
	</TD>
	<TD align="left">
		<spring:message var="keepLoginTextStypeLabel" code="cb.loginText.style" text="Use codeBeamer style"/>
		<form:checkbox path="keepLoginTextStype" label="${keepLoginTextStypeLabel}"/>
	</TD>
</TR>

<TR VALIGN="top">
	<TD class="optional">
		<spring:message code="cb.welcomeText.label" text="Welcome Text"/>:
	</TD>
	<TD CLASS="expandTextArea">
		<spring:message var="welcomeTitle" code="cb.welcomeText.tooltip" text="This message will appear at the top of each user's homepage"/>
		<wysiwyg:editor editorId="welcomeText" formatSelectorSpringPath="welcomeTextFormat" useAutoResize="false" height="240" overlayHeaderKey="wysiwyg.welcome.text.overlay.header">
		    <form:textarea path="welcomeText" id="welcomeText" rows="15" cols="70" title="${welcomeTitle}" />
		</wysiwyg:editor>
	</TD>
</TR>

</TABLE>
</div>

</form:form>

