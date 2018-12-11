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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui"%>

<meta name="decorator" content="main" />
<meta name="module" content="mystart" />
<meta name="moduleCSSClass" content="workspaceModule newskin" />

<style type="text/css">

	span.subtext {
		margin-top: 10px;
		display: block;
	}

</style>

<ui:actionMenuBar cssClass="accountHeadLine">
	<ui:pageTitle>
		<spring:message code="user.upload.photo.page.title" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="updateUserPhoto" action="updateUserPhoto.spr" enctype="multipart/form-data">

<input type="hidden" name="userId" value="${user.id}">

<ui:actionBar>
	<c:if test="${canModifyPhoto}">
		<input type="submit" class="button" name="upload" value="<spring:message code="user.upload.photo" text="Upload photo"/>"/>
	</c:if>
	<c:if test="${hasPhotoUploaded && canModifyPhoto}">
		<input type="submit" class="button" name="delete" value="<spring:message code="user.upload.photo.delete" text="Delete current photo"/>"/>
	</c:if>
	<input type="submit" class="button cancelButton" name="cancel" value="<spring:message code="button.cancel" text="Cancel"/>"/>
</ui:actionBar>

<div class="contentWithMargins">

	<c:if test="${!canModifyPhoto}">
		<div class="warning">
			<spring:message code="user.upload.photo.not.authorized" text="You are not authorized modify user photos."/>
		</div>
	</c:if>

	<div>
		<ui:userPhoto userId="${user.id}" large="true"/>
	</div>

	<c:if test="${canModifyPhoto}">
		<input type="file" name="file" size="50">
		<span class="subtext">
			<spring:message code="user.upload.photo.explanation"/>
		</span>
	</c:if>

</div>

</form:form>
