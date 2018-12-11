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
<meta name="module" content="start"/>
<meta name="moduleCSSClass" content="membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springmodules.org/tags/valang" prefix="vl" %>

<%@page import="com.intland.codebeamer.cti.controllers.CTIController"%>

<c:set var="requestURI" value="/incomingCall.spr" />
<c:url var="action" value="/incomingCall.spr" />

<form:form commandName="ctiForm" action="${action}">

	<ui:actionMenuBar>
			<ui:pageTitle><spring:message code="cti.incomingCall.title" text="Incoming telephone call from {0}" arguments="${ctiForm.phone}"/></ui:pageTitle>
	</ui:actionMenuBar>

	<ui:actionBar>
		<div style="float:left;">
			<%-- Note: /createUser.spr has no security --%>
			<c:url var="newAccountURL" value="incomingCall.spr" >
				<c:param name="<%=CTIController.REQ_PARAM_CREATE_NEW_USER%>" value="true" />
				<c:param name="<%=CTIController.REQ_PARAM_FROM_PHONE_NUMBER%>" value="${ctiForm.phone}"/>
			</c:url>
			<a href='${newAccountURL}'><spring:message code="cti.incomingCall.createAccount.label" text="Create new Account"/></a>
		</div>

		<div style="float:right;">
<%--
			<b>Phone number</b>
			<form:input path="phone" size="30" title="Search users by a phone number" />
			&nbsp;
			<input type="submit" name="doSearchByPhone" class="button" title="Search by phone" value="GO" />
			&nbsp;
--%>
			<b><spring:message code="cti.incomingCall.search.label" text="Search"/></b>&nbsp;
			<spring:message var="searchTitle" code="cti.incomingCall.search.tooltip" text="Search users by free text"/>
			<spring:message var="searchButton" code="search.submit.label" text="GO"/>

			<form:input path="filter" size="30" title="${searchTitle}" />
			&nbsp;
			<input type="submit" name="doSearch" class="button" title="${searchTitle}" value="${searchButton}" />
		</div>
		<div style="clear:both;" ></div>
	</ui:actionBar>

<ui:title style="top-sub-headline-decoration" separatorGapHeight="2" titleStyle="" topMargin="0" >
		<c:set var="nr_of_users" value="${fn:length(ctiForm.users)}" />
		<c:choose>
			<c:when test="${ctiForm.searchByFilter}">
				<c:set var="filter"><c:out value="${ctiForm.filter}"/></c:set>
				<spring:message code="cti.incomingCall.search.filter.result" text="{0} accounts found by filter {1}" arguments="${nr_of_users},${filter}"/>
			</c:when>
			<c:otherwise>
				<c:set var="phone"><c:out value="${ctiForm.phone}"/></c:set>
				<spring:message code="cti.incomingCall.search.phone.result" text="{0} accounts found by phone number {1}" arguments="${nr_of_users},${phone}"/>
			</c:otherwise>
		</c:choose>
	</ui:title>

<acl:isUserInRole var="canViewCompany" value="account_company_view" />

<display:table class="expandTable" requestURI="${requestURI}" name="${ctiForm.users}" id="user" cellpadding="0"
	defaultsort="4" excludedParams="" export="false" decorator="com.intland.codebeamer.ui.view.table.UserDecorator" >

	<display:setProperty name="basic.msg.empty_list_row">
		<tr class="empty">
			<td colspan="{0}">
				<div class="explanation">
					<spring:message code="account.filter.no.matching.account" />
				</div>
			</td>
		</tr>
	</display:setProperty>

	<spring:message var="accountTitle" code="user.account.label" text="Account"/>
	<display:column title="${accountTitle}" headerClass="textData" class="textData columnSeparator" sortProperty="name" sortable="true"
			media="html" style="width:1%;">
		<c:choose>
			<c:when test="${!empty user.id}">
				<tag:userLink user_id="${user.id}" />
			</c:when>
			<c:otherwise>
				<c:url var="newAccountURL" value="/incomingCall.spr" >
					<c:param name="<%=CTIController.REQ_PARAM_CREATE_NEW_USER%>" value="true" />
					<c:param name="<%=CTIController.REQ_PARAM_FROM_TEMPLATE_INDEX%>" value="${user_rowNum - 1}"/>
				</c:url>

				<a href="${newAccountURL}"><spring:message code="cti.incomingCall.createAccount.label" text="Create new Account"/></a>
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="userTitle" code="user.title.label" text="Title"/>
	<display:column title="${userTitle}" headerClass="textData" class="textData columnSeparator" property="title" sortable="false" style="width:2%;"/>

	<spring:message var="userFirstName" code="user.firstName.label" text="First Name"/>
	<display:column title="${userFirstName}" headerClass="textData" class="textData columnSeparator" property="firstName" sortable="true" style="width:7%;"/>

	<spring:message var="userLastName" code="user.lastName.label" text="Last Name"/>
	<display:column title="${userLastName}" headerClass="textData" class="textData columnSeparator" property="lastName" sortable="true"/>

	<c:if test="${canViewCompany}">
		<spring:message var="userCompany" code="user.company.label" text="Company"/>
		<display:column title="${userCompany}" headerClass="textData" class="textData columnSeparator" property="company" sortable="true" media="html" style="width:5%;"/>
	</c:if>

	<spring:message var="userAddress" code="user.address.label" text="Address"/>
	<display:column title="${userAddress}" headerClass="textData" class="textData columnSeparator" property="address" sortable="true" style="width:15%;"/>

	<spring:message var="userZip" code="user.zip.label" text="Zip"/>
	<display:column title="${userZip}" headerClass="textData" class="textData columnSeparator" property="zip" sortable="true" style="width:2%;"/>

	<spring:message var="userCity" code="user.city.label" text="City"/>
	<display:column title="${userCity}" headerClass="textData" class="textData columnSeparator" property="city" sortable="true" style="width:8%;"/>
<%--
	<spring:message var="userState" code="user.state.label" text="State"/>
	<display:column title="${userState}" headerClass="textData" class="textData columnSeparator" property="state" sortable="true" style="width:3%;"/>
--%>
	<spring:message var="userCountry" code="user.country.label" text="Country"/>
	<display:column title="${userCountry}" headerClass="textData" class="textData columnSeparator" property="country" sortable="true" style="width:5%;"/>

	<spring:message var="userPhone" code="user.phone.label" text="Phone"/>
	<display:column title="${userPhone}" headerClass="textData" class="textData columnSeparator" property="phone" sortable="true" style="width:7%;"/>

	<spring:message var="userMobile" code="user.mobile.label" text="Mobile"/>
	<display:column title="${userMobile}" headerClass="textData" class="textData columnSeparator" property="mobile" sortable="true" style="width:7%;"/>

	<spring:message var="userEMail" code="user.email.label" text="EMail"/>
	<display:column title="${userEMail}" headerClass="textData" class="textData columnSeparator" property="email"
		comparator="com.intland.codebeamer.ui.view.table.EmailComparator" sortable="true" escapeXml="true" style="width:10%;"/>

</display:table>

</form:form>

