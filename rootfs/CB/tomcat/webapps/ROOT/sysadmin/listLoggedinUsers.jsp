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
<meta name="moduleCSSClass" content="sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="export" value="false" />
<c:set var="requestURI" value="/sysadmin/loggedinUsers.spr" />

<ui:actionMenuBar>
		<ui:pageTitle><spring:message code="loggedInUsers.title" text="User Accounts Logged in"/></ui:pageTitle> (<fmt:formatNumber value="${fn:length(userSessions)}" />)
</ui:actionMenuBar>

<%-- List logged-in accounts --%>
<display:table requestURI="${requestURI}" name="${userSessions}" id="userSession" cellpadding="0" defaultsort="1">
	<spring:message var="loggedInAccount" code="user.name.label" text="Account"/>
	<display:column title="${loggedInAccount}" headerClass="textData" class="textData columnSeparator" sortProperty="user.name" sortable="true">
		<tag:userLink user_id="${userSession.user.id}" />
	</display:column>

	<spring:message var="loggedInName" code="user.realName.label" text="Name"/>
	<display:column title="${loggedInName}" headerClass="textData" class="textData columnSeparator" sortProperty="user.lastName" sortable="true">
		<c:out value="${userSession.user.lastName},${userSession.user.firstName}" />
	</display:column>

	<spring:message var="loggedInCompany" code="user.company.label" text="Company"/>
	<display:column title="${loggedInCompany}" headerClass="textData" class="textDataWrap columnSeparator" property="user.company"
		sortable="true" escapeXml="true" />

<%--
	<c:set var="hostName" value="${userSession.remoteHost}" />
--%>
	<c:set var="hostName" value="${userSession.remoteHost}" />
	<c:url var="whois" value="/whois.do">
		<c:param name="user_id" value="${userSession.user.id}" />
		<c:param name="host" value="${userSession.remoteHost}" />
	</c:url>

	<spring:message var="loggedInHost" code="user.hostName.label" text="Host"/>
	<display:column title="${loggedInHost}" headerClass="textData" class="textDataWrap columnSeparator" sortProperty="remoteHost" sortable="true">
		<c:choose>
			<c:when test="${empty hostName or hostName == 'localhost' or hostName == '127.0.0.1'}">
				<c:out value="${hostName}" />
			</c:when>

			<c:otherwise>
				<a href="${whois}" title="Whois: ${hostName}" onclick="launch_url('${whois}',null);return false;"><c:out value="${hostName}" /></a>
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="loggedInLastAccess" code="loggedInUsers.lastAccessDate.label" text="Last Accessed Date"/>
	<display:column title="${loggedInLastAccess}" headerClass="dateData" class="dateData columnSeparator" sortProperty="loginAt" sortable="true">
		<c:catch>
			<tag:formatDate var="lastAccessedDate" value="${userSession.loginAt}" />
		</c:catch>
		<c:out value="${lastAccessedDate}" default="--" escapeXml="false" />
	</display:column>

	<c:if test="${showLicenses}">
		<spring:message var="userLicenseType" code="user.licenseType.label" text="License Type"/>
		<display:column title="${userLicenseType}" headerClass="textData" class="textDataWrap columnSeparator" sortable="false">
			<ul style="padding-left: 1em; margin: 0;">
				<c:forEach items="${userSession.licenses}" var="license">
					<li>
						<c:out value="${license.key}" /> - <spring:message code="user.licenseType.${license.value.id}" text="license.value"/>
					</li>
				</c:forEach>
			</ul>
		</display:column>
	</c:if>

</display:table>

<c:if test="${showLicenses and licensesInuse > 0}">
	<spring:message var="licenseUsageLabel" code="sysadmin.license.usage.label" text="Licenses in use" />
	<ui:collapsingBorder label="${licensesInuse} ${licenseUsageLabel}" open="false" cssStyle="margin: 2em 0em 1em 0em; border: 0;">
		<c:forEach items="${usedLicenses}" var="license">
			<c:set var="inUseRatio">
				<spring:message code="sysadmin.license.inUse.ratio" text="{0} of {1}" arguments="${license.inUse},${license.licenses}"/>
				<c:out value="${license.product}" /> - <spring:message code="user.licenseType.${license.type.id}" text="license.type"/>
			</c:set>

			<ui:collapsingBorder label="${inUseRatio}" open="false" cssStyle="margin: 0.5em 0em 0.5em 2em; border: 0;">
				<ul style="margin: 0.5em;">
					<c:forEach items="${license.sessions}" var="userSession">
						<li>
							<c:set var="hostName" value="${userSession.remoteHost}" />

							<tag:userLink user_id="${userSession.user.id}" /> @
							<c:choose>
								<c:when test="${empty hostName or hostName == 'localhost' or hostName == '127.0.0.1'}">
									<c:out value="${hostName}" />
								</c:when>

								<c:otherwise>
									<c:url var="whois" value="/whois.do">
										<c:param name="user_id" value="${userSession.user.id}" />
										<c:param name="host" value="${userSession.remoteHost}" />
									</c:url>
									<a href="${whois}" title="Whois: ${hostName}" onclick="launch_url('${whois}',null);return false;">
										<c:out value="${hostName}" />
									</a>
								</c:otherwise>
							</c:choose>
						</li>
					</c:forEach>
				</ul>
			</ui:collapsingBorder>
		</c:forEach>
	</ui:collapsingBorder>
</c:if>

<ui:title style="top-sub-headline-decoration" >
	<spring:message code="loggedInUsers.dailyStatistics.label" text="Daily Statistics of the last {0} days" arguments="${nrOfLastDays}"/>
</ui:title>

<c:choose>
	<c:when test="${isFloating}">
		<c:set var="defaultsort" value="3" />
	</c:when>
	<c:otherwise>
		<c:set var="defaultsort" value="2" />
	</c:otherwise>
</c:choose>

<display:table requestURI="${requestURI}" name="${dailyLoggins}" id="action" cellpadding="0"
	defaultsort="${defaultsort}" defaultorder="descending" export="${export}">

	<spring:message var="loggedInTotalUserCount" code="loggedInUsers.totalUserCount.label" text="Users logged in"/>
	<display:column title="${loggedInTotalUserCount}" headerClass="numberData" class="numberData columnSeparator"
		sortProperty="count" sortable="true">
		<fmt:formatNumber value="${action.count}" maxFractionDigits="0" minFractionDigits="0"/>
	</display:column>

	<c:if test="${isFloating}">
		<spring:message var="loggedInMaxConcurrentCount" code="loggedInUsers.maxConcurrentUserCount.label" text="Maximum Concurrent Users"/>
		<display:column title="${loggedInMaxConcurrentCount}" headerClass="numberData" class="numberData columnSeparator"
			property="maxConcurent" sortable="true" />
	</c:if>

	<spring:message var="loggedInDate" code="loggedInUsers.date.label" text="Date"/>
	<display:column title="${loggedInDate}" headerClass="dateData" class="dateData columnSeparator"
		sortProperty="date" sortable="true" media="html xml csv pdf">
		<tag:formatDate value="${action.date}" type="date" />
	</display:column>

	<display:column title="${loggedInDate}" headerClass="dateData" class="dateData columnSeparator"
		property="date" sortable="true" media="excel" />
</display:table>

<%-- Set "dailyUsage" to "true" to get also the daily usage statistic. --%>
<c:set var="dailyUsage" value="false" />
<c:if test="${dailyUsage}">
	<c:choose>
		<c:when test="${onlineTimeGroupByUser == 'user'}">
			<c:set var="defaultsort" value="4" />
		</c:when>

		<c:otherwise>
			<c:set var="defaultsort" value="3" />
		</c:otherwise>
	</c:choose>

	<form:form action="${pageContext.request.contextPath}/sysadmin/loggedinUsers.spr">

	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">

	<TR>
		<c:choose>
			<c:when test="${onlineTimeGroupByUser == 'user'}">
				<c:set var="userOptionSelected" value='selected="selected"' />
				<c:set var="companyOptionSelected" value='' />
			</c:when>

			<c:otherwise>
				<c:set var="userOptionSelected" value='' />
				<c:set var="companyOptionSelected" value='selected="selected"' />
			</c:otherwise>
		</c:choose>

		<TD NOWRAP>
			<ui:title style="top-sub-headline-decoration" separatorGapHeight="2" titleStyle="">
				<spring:message code="loggedInUsers.dailyUsageStatistics.label" text="<STRONG>Daily Usage Statistics of the last {0} days &nbsp;&nbsp;&nbsp;&nbsp;Group by</STRONG>" arguments="${nrOfLastDays}"/>:
				<select id="onlineTimeGroupByUser" name="onlineTimeGroupByUser" onchange="this.form.submit();">
					<option value="user" ${userOptionSelected}><spring:message code="user.name.label" text="Account"/></option>
					<option value="company" ${companyOptionSelected}><spring:message code="user.company.label" text="Company"/></option>
				</select>
			</ui:title>
		</TD>
	</TR>

	</TABLE>

	<display:table requestURI="${requestURI}" name="${onlineTime}" id="item" cellpadding="0"
		defaultsort="${defaultsort}" defaultorder="descending" export="${export}">

		<c:if test="${onlineTimeGroupByUser == 'user'}">
			<display:column title="Account" headerClass="textData" class="textData columnSeparator"
				sortProperty="user.name" sortable="true" media="html">
				<tag:userLink user_id="${item.user.id}" />
			</display:column>

			<display:column title="Account" headerClass="textData" class="textData columnSeparator"
				sortable="true" media="excel xml csv pdf" property="user.name" />
		</c:if>

		<spring:message var="loggedInCompany" code="user.company.label" text="Company"/>
		<display:column title="${loggedInCompany}" headerClass="textData" class="textDataWrap columnSeparator" sortProperty="user.company" sortable="true">
			<c:out value="${item.user.company}" />
		</display:column>

		<spring:message var="loggedInTime" code="loggedInUsers.time.label" text="Online Time"/>
		<display:column title="${loggedInTime}" headerClass="numberData" class="numberData columnSeparator"
			sortable="true" sortProperty="time">
			<fmt:formatNumber value="${item.time / 3600.0}"
				maxFractionDigits="2" minFractionDigits="2" /> H
		</display:column>

		<spring:message var="loggedInDate" code="loggedInUsers.date.label" text="Date"/>
		<display:column title="${loggedInDate}" headerClass="dateData" class="dateData columnSeparator"
			sortProperty="date" sortable="true" media="html xml csv pdf">
			<tag:formatDate value="${item.date}" type="date" />
		</display:column>

		<display:column title="${loggedInDate}" headerClass="dateData" class="dateData columnSeparator"
			property="date" sortable="true" media="excel" />

		<c:if test="${onlineTimeGroupByUser == 'user'}">
			<c:set var="remoteHost" value="${item.hostName}" />
			<c:url var="whois" value="/whois.do">
				<c:param name="user_id" value="${item.user.id}" />
				<c:param name="host" value="${remoteHost}" />
			</c:url>

			<spring:message var="loggedInHost" code="user.hostName.label" text="Host"/>
			<display:column title="${loggedInHost}" headerClass="textData" class="textDataWrap columnSeparator" sortProperty="hostName" sortable="true">
				<c:choose>
					<c:when test="${empty remoteHost or remoteHost == 'localhost' or remoteHost == '127.0.0.1'}">
						<c:out value="${remoteHost}" />
					</c:when>

					<c:otherwise>
						<a href="${whois}" title="Whois: ${remoteHost}" onclick="launch_url('${whois}',null);return false;"><c:out value="${remoteHost}" /></a>
					</c:otherwise>
				</c:choose>
			</display:column>
		</c:if>
	</display:table>

	</form:form>
</c:if>
