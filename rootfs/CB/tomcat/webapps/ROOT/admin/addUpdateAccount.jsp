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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springmodules.org/tags/valang" prefix="vl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<meta name="decorator" content="main"/>
<meta name="module" content="mystart"/>
<meta name="moduleCSSClass" content="workspaceModule newskin"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/workspace/userdata.css' />" type="text/css" media="all" />
</head>

<style type="text/css">
	#rolesList label {
		white-space: nowrap;
		display: block;
		float: left;
		padding: 0 10px 15px 0;
	}
	#userDataTable .formTableWithSpacing td {
		vertical-align: top;
	}
	td.data {
		width: 80%;
	}
	#userDataTable .formTableWithSpacing tr.blockStart > td {
		padding-top: 50px !important;
	}
	#userDataTable select {
		max-width: 25em;
	}
	#licenseTypesTable {
		margin: 5px 5px 0 5px;
	}
	#licenseTypesTable th {
		padding:0px 0px 10px 0px;
	}
	#licenseTypesTable tr {
		border-bottom: none;
	}
	#licenseTypesTable label {
		margin-right: 30px;
	}
	#userDataTable textarea {
		padding: 10px;
	}
	#userDataTable input[type="checkbox"] {
		border: none;
		padding: 0;
		margin: 0;
	}
	.recaptchatable #recaptcha_response_field {
		margin-left: 8px;
	}
	.block {
		margin-bottom: 0px;
	}
	.user-ldap-alert {
		background-image: url("images/newskin/action/permission-alert.png");
		background-position: center;
		background-repeat: no-repeat;
	    width: 12px;
	    height: 12px;
	    cursor: pointer;
	    display: inline-block;
	}
</style>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers

var RecaptchaOptions = {
   theme : 'clean'
};

// -->
</SCRIPT>

<ui:actionMenuBar cssClass="accountHeadLine">
	<ui:pageTitle><spring:message code="${dialogTitleKey}" /></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="userForm" autocomplete="off">

<form:hidden path="user.id"/>
<form:hidden path="referrerURL"/>

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	<input type="submit" class="button" data-purpose="submit" value="${saveButton}" />
	<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
	<c:if test="${isAccountEditing && isAccountDeactivated && isAccountAdministrator}">
		<spring:message var="encryptButton" code="user.encrypt.button" text="Encrypt Sensitive User Data"/>
		<a class="actionLink encryptButton" href="#" data-encryption-base="${randomValue}">
			<spring:message code="user.encrypt.button" text="Encrypt Sensitive User Data"/>
		</a>
	</c:if>

</ui:actionBar>

<jsp:include page="userFormTable.jsp"></jsp:include>

</form:form>


