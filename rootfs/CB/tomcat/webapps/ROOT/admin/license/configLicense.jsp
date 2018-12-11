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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<%@page import="com.intland.codebeamer.controller.admin.ConfigLicenseCommand"%>

<style>
<!--
#newLicense {
	font-family: monospace;
	font-size: 9pt;
}
-->
</style>

<c:set var="showingCurrentLicense" value="<%=ConfigLicenseCommand.Stages.showingCurrentLicense%>"/>
<c:set var="editingLicense" value="<%=ConfigLicenseCommand.Stages.editingLicense%>"/>
<c:set var="confirmLicense" value="<%=ConfigLicenseCommand.Stages.confirmLicense%>"/>

<c:set var="pageTitle">
<c:choose>
	<c:when test="${command.stage eq showingCurrentLicense}"><spring:message code="sysadmin.license.label" text="License"/></c:when>
	<c:when test="${command.stage eq editingLicense}"><spring:message code="sysadmin.license.edit.label" text="Edit license"/></c:when>
	<c:when test="${command.stage eq confirmLicense}"><spring:message code="sysadmin.license.verify.label" text="Verify new license details"/></c:when>
</c:choose>
</c:set>

<ui:actionMenuBar>
	<ui:pageTitle>${pageTitle}</ui:pageTitle>
</ui:actionMenuBar>

<form:form>
<form:hidden path="stage"/>
<ui:actionBar>
<acl:isUserInRole value="system_admin">
	&nbsp;&nbsp;

	<c:choose>
		<c:when test="${command.stage eq showingCurrentLicense}">
			<spring:message var="editLicenseButton" code="sysadmin.license.edit.button" text="Edit license"/>
			<spring:message var="editLicenseTitle" code="sysadmin.licence.edit.tooltip" text="Replace your current license with a new one."/>
			<input type="submit" class="button" value="${editLicenseButton}" title="${editLicenseTitle}" name="editLicense" />
			<c:if test="${! empty command.previousLicense}">
				<spring:message var="revertLicenseButton" code="sysadmin.license.revert.button" text="Revert to previous license"/>
				<spring:message var="revertLicenseTitle" code="sysadmin.license.revert.tooltip" text="In case your license goes wrong, simply revert to previous license."/>
				&nbsp;&nbsp;
				<input type="submit" class="button" value="${revertLicenseButton}" name="revertToPrevious" title="${revertLicenseTitle}" />
			</c:if>
			<c:url var="cancelUrl" value="/sysadmin.do"/>
			<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
			<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
		</c:when>

		<c:when test="${command.stage eq editingLicense}">
			<spring:message var="verifyLicenseButton" code="sysadmin.license.verify.button" text="Next"/>
			<spring:message var="verifyLicenseTitle" code="sysadmin.licence.verify.tooltip" text="Verify and save license."/>
			<input type="submit" class="button" value="${verifyLicenseButton}" title="${verifyLicenseTitle}"/>
		</c:when>

		<c:when test="${command.stage eq confirmLicense}">
			<spring:message var="saveLicenseButton" code="sysadmin.license.save.button" text="Save license"/>
			<spring:message var="saveLicenseTitle" code="sysadmin.licence.save.tooltip" text="Click that you have verified and confirmed the license."/>
			<input type="submit" class="button" value="${saveLicenseButton}" name="confirmLicense" title="${saveLicenseTitle}"/>
		</c:when>
	</c:choose>

	<c:if test="${!(command.stage eq showingCurrentLicense)}">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;
		<input type="submit" class="button cancelButton" value="${cancelButton}" name="_cancel"/>
	</c:if>
</acl:isUserInRole>
</ui:actionBar>

<div class="contentWithMargins">
<c:choose>
	<c:when test="${command.stage eq showingCurrentLicense}">
		<p><spring:message code="sysadmin.licence.request.link" text="Contact Intland for a License Key" arguments="${license.physicalHostId}"/></p>
		<p><b><spring:message code="sysadmin.licence.current.title" text="Current license"/>:</b></p>
		<jsp:include page="./showLicenseInformation.jsp" />
	</c:when>

	<c:when test="${command.stage eq editingLicense}">
		<spring:message code="sysadmin.licence.edit.title" text="Paste new license here"/>:
		<form:errors path="newLicense" cssClass="invalidfield"/><br/>
		<textarea cols="80" rows="15" name="newLicense" id="newLicense"><c:out value="${command.newLicense}"/></textarea>	<%-- whatever reason the form:textarea does not keep content? --%>
	</c:when>

	<c:when test="${command.stage eq confirmLicense}">
		<form:hidden path="newLicense"/>
		<b><spring:message code="sysadmin.licence.verify.title" text="Please verify the new license details below, and click Confirm to save the new license."/></b>
		<br/><br/>

		<c:set var="license" value="${newLicense}" scope="request"/>
		<jsp:include page="./showLicenseInformation.jsp" />
	</c:when>
</c:choose>
</div>

</form:form>