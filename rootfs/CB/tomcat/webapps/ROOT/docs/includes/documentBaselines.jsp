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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- JSP fragment for showing the table of Document or Wiki baselines
	 Parameters:
	 param.requestURI		The uri called by displaytag to reorder table
	 param.projectScope		Do we show project scope baselines (true) or artifact scope baselines (false)
	 request.baselines		The list of baselines to show
--%>

<style type="text/css">
	.SignedHeaderClass, .SignedClass {
		text-align: center;
	}

	.SignedHeaderClass {
		padding-right: 10px !important;
	}
</style>

<%-- include the JS and hidden field for deleting one/multiple documents --%>
<jsp:include page="./deleteArtifacts.jsp" >
	<jsp:param name="confirmMessageKey" value="docs.delete.baseline.confirm" />
	<jsp:param name="confirmOneMessageKey" value="docs.delete.oneBaseline.confirm" />
	<jsp:param name="confirmOneDirMessageKey" value="docs.delete.oneBaseline.confirm" />
</jsp:include>

<c:set var="requestURI" value="${param.requestURI}" />

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<display:table name="${baselines}" id="baseline" requestURI="" defaultsort="9" defaultorder="descending" export="false"
	class="expandTable" cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator"
	excludedParams="orgDitchnetTabPaneId, requestURI">

	<display:column media="html">
		<input type="checkbox" name="selectedBaselines" value="${empty baseline.baseline ? baseline.id : baseline.baseline.root.id}" />
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="rawData actionIcon" property="actionInfo" />

	<spring:message var="baselineLabel" code="baseline.label" text="Baseline"/>
	<display:column title="${baselineLabel}" property="name" sortable="true" sortProperty="sortName" headerClass="textData" class="textData" />

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${baseline}" actionListName="actions">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</ui:actionGenerator>
	</display:column>

	<c:choose>
		<c:when test="${param.projectScope}">
			<c:url var="wikiHomepageURL" value="/proj/wiki/displayWikiPageRevision.spr">
				<c:param name="doc_id"   value="${PROJECT_DTO.wikiHomepageId}"/>
				<c:param name="revision" value="${baseline.id}"/>
			</c:url>

			<spring:message var="wikiLabel" code="project.wikiHomepageId.label" text="Wiki"/>
			<display:column title="${wikiLabel}" sortable="false" headerClass="textData" class="textData columnSeparator">
				<spring:message var="wikiTitle" code="project.baseline.wiki.tooltip" text="Project Wiki Home Page in this baseline"/>
				<a href="${wikiHomepageURL}" title="${wikiTitle}">
					<spring:message code="project.baseline.wiki.label" text="Homepage"/>
				</a>
			</display:column>
		</c:when>
		<c:otherwise>
			<spring:message var="versionlabel" code="document.version.label" text="Version"/>
			<display:column title="${versionlabel}" property="version" sortable="true" sortProperty="sortVersion" headerClass="numberData" class="numberData smallerText columnSeparator" />
		</c:otherwise>
	</c:choose>

	<spring:message var="baselineDescription" code="baseline.description.label" text="Description"/>
	<display:column title="${baselineDescription}" property="description" sortable="true" sortProperty="sortDescription" headerClass="textData expand" class="textDataWrap smallerText columnSeparator" />

	<spring:message var="baselineCreatedAt" code="baseline.createdAt.label" text="Created at"/>
	<display:column title="${baselineCreatedAt}" property="createdAt" sortable="true" sortProperty="sortCreatedAt" headerClass="dateData" class="dateData columnSeparator" />

	<spring:message var="baselineCreatedBy" code="baseline.createdBy.label" text="Created by"/>
	<display:column title="${baselineCreatedBy}" property="owner" sortable="true" sortProperty="sortOwner" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="baselineSignature" code="baseline.signed.label" text="Signed"/>
	<display:column title="${baselineSignature}" sortable="false" headerClass="textData SignedHeaderClass" class="textData SignedClass" >
		<c:choose>
			<c:when test="${fn:contains(baseline.dto.comment, 'baseline.signed.label')}">
				<img src="<c:url value='/images/newskin/item/signed.png'/>"/>
			</c:when>
			<c:otherwise>
				--
			</c:otherwise>
		</c:choose>
	</display:column>

</display:table>
