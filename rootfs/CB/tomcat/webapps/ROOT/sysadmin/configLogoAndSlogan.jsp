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
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<wysiwyg:froalaConfig />

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="cb.logoSlogan.title" text="Logo and Slogan customization"/></ui:pageTitle>
</ui:actionMenuBar>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">

function submitForm(button) {
	return isFileUploadsFinished(false);
}
</SCRIPT>

<style type="text/css">
	.IE #uploadCell .qq-upload-button input[name=file] {
		font-size: 400px !important;
	}

	.logo-align-container {
		display: flex;
		flex-direction: row;
	}

	.logo-image-container {
		display: flex;
		align-items: center;
		margin-right: 20px;
	}

	.logo-image-container .logo-image-option {
		max-height: 45px;
		max-width: 250px
	}
	.editor-wrapper:not(.fr-fake-popup-editor) {
		margin-bottom: 20px;
	}
	.editor-wrapper img.outlink {
		display: none;
	}

    .qq-upload-button {
        border: none !important;
    }
</style>

<html:form action="/sysadmin/updateLogoAndSlogan" enctype="multipart/form-data">

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<html:submit styleClass="button" value="${saveButton}" property="Save" onclick="submitForm(this);" />
	&nbsp;&nbsp;<html:cancel styleClass="cancelButton button" value="${cancelButton}" onclick="history.back();return false" />
</ui:actionBar>

<ui:showErrors />

<DIV CLASS="warning"><spring:message code="cb.logoSlogan.warning" text="After you save the GUI changes, please click your browser's <strong>Refresh</strong> button to display the new GUI."/></DIV>

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

<TR VALIGN="TOP">
	<TD class="optional"><spring:message code="cb.slogan.label" text="Slogan"/>:</TD>

	<TD CLASS="expandTextArea">
		<html:textarea styleClass="expandTextArea" property="slogan" rows="12" cols="80" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="cb.logo.selector" text="Select Logo Image"/>:</TD>

	<TD>
		<div class="logo-align-container">
			<label class="logo-image-container">
				<html:radio property="selectedLogo" value="default"/>
				<img class="logo-image-option" src="<ui:urlversioned value="${logoAndSloganForm.defaultLogoUrl}"/>" />
			</label>
			<c:if test="${logoAndSloganForm.isCustomLogoAvailable && !logoAndSloganForm.evalLicense}">
				<label class="logo-image-container">
					<html:radio property="selectedLogo" value="custom"/>
					<img class="logo-image-option" src="<ui:urlversioned value="${logoAndSloganForm.customLogoUrl}"/>" />
				</label>
			</c:if>
		</div>
	</TD>
</TR>

<c:if test="${!logoAndSloganForm.evalLicense}">
	<TR class="uploadRow">
		<TD NOWRAP CLASS="labelCell optional"><spring:message code="cb.logo.label" text="Upload Logo Image"/>:</TD>
		<TD COLSPAN="5" id="uploadCell" class="uploadFormField">
			<ui:fileUpload single="true" uploadConversationId="configLogoAndSlogan"/>
		</TD>
	</TR>
</c:if>

<TR>
	<TD class="optional" title="${logoLinkTargetUrlTitle}"><spring:message code="cb.logoLinkTargetUrl.label" text="Logo URL"/>:</TD>
	<TD>
		<html:text property="logoLinkTargetUrl" size="1024" title="${logoLinkTargetUrlTitle}" style="width: calc(100% - 10px);" />
	</TD>
</TR>

<TR>
	<spring:message var="recentHistoryItemsTitle" code="cb.recentHistoryItems.tooltip"/>
	<TD class="optional" title="${recentHistoryItemsTitle}">
		<spring:message code="cb.recentHistoryItems.label" text="Recent History Items"/>:
	</TD>

	<TD NOWRAP>
		<html:text property="recentHistoryItems" size="2" title="${recentHistoryItemsTitle}"/>
	</TD>
</TR>

<TR>
	<spring:message var="itemsPerPageTitle" code="cb.itemsPerPage.tooltip"/>
	<TD class="optional" title="${itemsPerPageTitle}">
		<spring:message code="cb.itemsPerPage.label" text="Items per page"/>:
	</TD>
	<TD NOWRAP>
		<html:text property="itemsPerPage" size="3" title="${itemsPerPageTitle}"/>
	</TD>
</TR>
<TR>
	<TD class="optional"><spring:message code="cookie.policy.label" text="Cookie Policy"/>:</TD>
	<TD>
		<html:checkbox property="cookiePolicyEnabled" styleId="cookiePolicyEnabled" />
		<label for="cookiePolicyEnabled"><spring:message code="cookie.policy.enabled.label" text="Enabled"/></label>
	</TD>
</TR>

<TR VALIGN="top">
	<TD class="optional">
		<spring:message code="cookie.policy.text.label" text="Cookie Policy Text"/>:
	</TD>
	<TD>
		<wysiwyg:editor editorId="editor" height="220" useAutoResize="false" formatSelectorStrutsProperty="cookiePolicyFormat" overlayDefaultHeaderKey="wysiwyg.default.properties.overlay.header">
			<html:textarea property="cookiePolicy" styleId="editor" rows="11" cols="95" />
		</wysiwyg:editor>
	</TD>
</TR>

</TABLE>

</html:form>
