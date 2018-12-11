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
 *
 * $Revision: 23955:cdecf078ce1f $ $Date: 2009-11-27 19:54 +0100 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- JSP fragment for showing the table of Document or Wiki baselines
	 Parameters:
	 param.requestURI		The uri called by displaytag to reorder table
--%>

<%
	pageContext.setAttribute("SIGNATURE_INDEX", Integer.valueOf(25));
%>

<display:table name="${itemBaselines}" id="baseline" requestURI="${requestURI}" defaultsort="4" defaultorder="descending" export="false"
	class="expandTable" cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"
	excludedParams="orgDitchnetTabPaneId, requestURI">

	<spring:message var="baselineLabel" code="baseline.label" text="Baseline"/>
	<display:column title="${baselineLabel}" sortable="true" sortProperty="sortName" headerClass="textData columnSeparator" class="textData columnSeparator">
		<ct:call object="${baseline}" method="getUrlLinkBaselined" param1="${baseline.version}" return="itemUrl"/>
		<a href="<c:url value="${itemUrl}"/>" class="itemUrl">
			<c:if test="${empty baseline.dto.name}"><spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]"/></c:if><c:out value='${baseline.dto.name}'/>
		</a>
	</display:column>

	<spring:message var="versionlabel" code="document.version.label" text="Version"/>
	<display:column title="${versionlabel}" property="version" sortable="true" sortProperty="sortVersion" headerClass="numberData columnSeparator" class="numberData smallerText columnSeparator" />

	<spring:message var="baselineDescription" code="baseline.description.label" text="Description"/>
	<display:column title="${baselineDescription}" property="description" sortable="true" sortProperty="sortDescription" headerClass="textData expand columnSeparator" class="textDataWrap smallerText columnSeparator" />

	<spring:message var="baselineCreatedAt" code="baseline.createdAt.label" text="Created at"/>
	<display:column title="${baselineCreatedAt}" property="submittedAt" sortable="true" sortProperty="sortSubmittedAt" headerClass="dateData columnSeparator" class="dateData columnSeparator" />

	<spring:message var="baselineCreatedBy" code="baseline.createdBy.label" text="Created by"/>
	<display:column title="${baselineCreatedBy}" property="submitter" sortable="true" sortProperty="sortSubmitter" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="baselineSignature" code="baseline.signed.label" text="Signed"/>
	<display:column title="${baselineSignature}" sortable="false" headerClass="textData" class="textData" >
		<c:choose>
			<c:when test="${fn:contains(baseline.dto.customFields[SIGNATURE_INDEX], 'baseline.signed.label')}">
				<img src="<c:url value='/images/choice-yes.gif'/>"/>
			</c:when>
			<c:otherwise>
				--
			</c:otherwise>
		</c:choose>
	</display:column>

</display:table>
