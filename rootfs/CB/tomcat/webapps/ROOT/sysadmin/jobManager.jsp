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
<%@ page import="com.intland.codebeamer.manager.CbQLManager" %>
<%@ page import="com.intland.codebeamer.persistence.dto.ObjectQuartzScheduleDto" %>

<meta name="decorator" content="main" />
<meta name="module" content="sysadmin" />
<meta name="moduleCSSClass" content="sysadminModule newskin" />

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib prefix="tag" uri="taglib" %>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.job.manager.label" text="Job Manager" />
	</ui:pageTitle>
</ui:actionMenuBar>
<ui:actionBar>
	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
</ui:actionBar>

<c:url var="requestURI" value="/sysadmin/jobManager.spr" />

<ui:displaytagPaging items="${items}" excludedParams="${page}"/>

<div class="contentWithMargins">
	<display:table requestURI="${requestURI}" class="expandTable displaytag" name="${items}" id="jobItem" excludedParams="${page}">

		<display:setProperty name="paging.banner.placement" value="${empty items.list ? 'none' : 'bottom'}"/>

		<spring:message code="sysadmin.job.manager.id.label" var="idLabel"/>
		<display:column title="${idLabel}" property="id" headerClass="textData" class="numberData"/>

		<spring:message code="sysadmin.job.manager.type.label" var="typeLabel"/>
		<display:column title="${typeLabel}" headerClass="textData" class="textData">
			<c:choose>
				<c:when test="${jobItem.typeId == reportTypeId}"><spring:message code="queries.report.label"/></c:when>
				<%--Set here other Job Types if they will be supported--%>
				<c:otherwise><spring:message code="sysadmin.job.manager.other.type.label"/></c:otherwise>
			</c:choose>
		</display:column>

		<spring:message code="sysadmin.job.manager.name.label" var="nameLabel"/>
		<display:column title="${nameLabel}" property="name" headerClass="textData" class="textDataWrap columnSeparator"/>

		<spring:message code="sysadmin.job.manager.status.label" var="statusLabel"/>
		<display:column title="${statusLabel}" headerClass="textData" class="textDataWrap column-minwidth columnSeparator">
			<c:choose>
				<c:when test="${jobItem.status == 'WAITING'}"><span class="issueStatus issueStatusResolved"><spring:message code="sysadmin.job.manager.status.waiting.label"/></span></c:when>
				<c:when test="${jobItem.status == 'IN_PROGRESS'}"><span class="issueStatus issueStatusVerified"><spring:message code="sysadmin.job.manager.status.in.progress.label"/></span></c:when>
				<c:when test="${jobItem.status == 'FAILED_TO_START'}"><span class="issueStatus issueStatusNew"><spring:message code="sysadmin.job.manager.status.failed.to.start.label"/></span></c:when>
				<c:when test="${jobItem.status == 'STOPPED'}"><span class="issueStatus issueStatusNew"><spring:message code="sysadmin.job.manager.status.stopped.label"/></span></c:when>
			</c:choose>
		</display:column>

		<spring:message code="sysadmin.job.manager.owner.label" var="ownerLabel"/>
		<display:column title="${ownerLabel}" headerClass="textData" class="textData columnSeparator">
			<tag:userLink user_id="${jobItem.userId}"/>
		</display:column>

		<spring:message code="sysadmin.job.manager.object.label" var="objectLabel"/>
		<display:column title="${objectLabel}" headerClass="textData" class="textDataWrap columnSeparator">
			<c:choose>
				<c:when test="${jobItem.typeId == reportTypeId}">
					<%
						pageContext.setAttribute("cbQLDto", CbQLManager.getInstance().findById(((ObjectQuartzScheduleDto) jobItem).getObjectId()));
					%>
					<a href="<c:url value="${cbQLDto.urlLink}"/>" target="_blank"><c:out value="${cbQLDto.name}"/></a>
				</c:when>
				<%--Set here other Job Types if they will be supported--%>
				<c:otherwise>
					${jobItem.objectId}
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message code="sysadmin.job.manager.cron.label" var="cronLabel"/>
		<display:column title="${cronLabel}" property="cron" headerClass="textData" class="textDataWrap columnSeparator"/>

		<spring:message code="sysadmin.job.manager.last.run.label" var="lastRunLabel"/>
		<display:column title="${lastRunLabel}" headerClass="textData" class="dateData columnSeparator">
			<tag:formatDate value="${jobItem.lastRun}"/>
		</display:column>

		<spring:message code="sysadmin.job.manager.created.at.label" var="createdAtLabel"/>
		<display:column title="${createdAtLabel}" headerClass="textData" class="dateData columnSeparator">
			<tag:formatDate value="${jobItem.createdAt}"/>
		</display:column>

		<display:column class="textData columnSeparator">
			<c:if test="${jobItem.typeId == reportTypeId}"><a class="editJob" href="#" onclick="showPopupInline(contextPath + '/proj/query/editSubscription.spr?queryId=${jobItem.objectId}&subscriptionId=${jobItem.id}&fromSysadmin=true' , {width: 1000, height: 600});return false;"><spring:message code="button.edit"/></a></c:if>
		</display:column>

		<display:column class="textData columnSeparator">
			<a class="disableEnableJob" href="<c:url value="/sysadmin/stopEnable.spr?jobId=${jobItem.id}"/>">
				<c:choose>
					<c:when test="${jobItem.status == 'STOPPED' || jobItem.status == 'FAILED_TO_START'}"><spring:message code="sysadmin.job.manager.enable.label"/></c:when>
					<c:otherwise><spring:message code="sysadmin.job.manager.disable.label"/></c:otherwise>
				</c:choose>
			</a>
		</display:column>

		<display:column class="textData columnSeparator">
			<a class="removeJob" href="<c:url value="/sysadmin/deleteJob.spr?jobId=${jobItem.id}"/>"><spring:message code="sysadmin.job.manager.remove.label"/></a>
		</display:column>

	</display:table>
</div>