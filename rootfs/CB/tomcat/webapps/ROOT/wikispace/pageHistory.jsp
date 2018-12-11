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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="export" value="false" />
<c:set var="doc_id" value="${wikiPage.id}" />
<c:url var="compareRevisionsUrl" value="/proj/wiki/compareWikiPageRevisions">
	<c:param name="doc_id" value="${wikiPage.id}" />
</c:url>


<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers

	<%@include file="./includes/compareRevisions.js" %>

	function confirmRestore(ver) {
		var msg = '<spring:message javaScriptEscape="true" code="wiki.history.restore" />';
		msg = msg.replace(/\{0\}/, ver);
		return confirm(msg);
	}
// -->
</SCRIPT>

<form action="/proj/wiki/compareWikiPageRevisions">

	<div class="actionBar" style="margin-bottom:0;">
		<c:if test="${!isDashboard}">
			<spring:message var="compareSelectedVersions" code="wiki.history.compare.selected.versions" text="Compare Selected Versions" />
			<input type="button" class="button" onclick="compareRevisions(this.form, '${compareRevisionsUrl}'); return false;" value="${compareSelectedVersions}" />
			<div style="float: right;">
				<spring:message code="document.version.restore.hint" text="To restore a version, use the tooltip menu beside the version number that you wish to restore"/>
			</div>
		</c:if>
	</div>

	<ui:displaytagPaging defaultPageSize="${pagesize}" items="${pageHistory}" excludedParams="page"/>

	<display:table name="${pageHistory}" id="revision" requestURI="" sort="external" defaultsort="2" defaultorder="descending" export="${export}"
			cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty pageHistory.list ? 'none' : 'bottom'}"/>

		<ui:actionGenerator builder="wikiPageHistoryActionMenuBuilder" actionListName="actions" subject="${revision}">

		<c:if test="${!isDashboard}">
			<display:column media="html">
				<input type="checkbox" name="selectedRevisions" value="${revision.version}" />
			</display:column>
		</c:if>

		<spring:message var="versionLabel" code="document.version.label" text="Version"/>
		<display:column title="${versionLabel}" sortProperty="sortVersion" sortable="true" headerClass="numberData" class="numberData" media="html">
			<c:if test="${!empty wikiPage.additionalInfo.publishedRevision}">
				<c:choose>
					<c:when test="${revision.version eq wikiPage.additionalInfo.publishedRevision}">
						<span class="subtext">(Published)</span>
					</c:when>
				 	<c:when test="${revision.version eq wikiPage.version}">
						<span class="subtext approvableArtifact">(Pending)</span>
					</c:when>
				</c:choose>
			</c:if>

			<c:choose>
				<c:when test="${isDashboard}">
					<span>${revision.version}</span>
				</c:when>
				<c:otherwise>
					<c:set var="clickAction" value="${actions['displayRevision']}" />
					<c:if test="${! empty clickAction}">
						<a href="${clickAction.url}" title='${clickAction.toolTip}'><c:out value="${revision.version}" /></a>
					</c:if>
				</c:otherwise>
			</c:choose>

		</display:column>

		<display:column title="${versionLabel}" property="version" headerClass="numberData" class="numberData"	media="excel xml csv pdf rtf" />

		<c:if test="${!isDashboard}">
			<display:column media="html" class="action-column-minwidth columnSeparator">
				<ui:actionMenu actions="${actions}" />
			</display:column>
		</c:if>

		<spring:message var="versionDateLabel" code="document.createdAt.label" text="Date"/>
		<display:column title="${versionDateLabel}" property="lastModifiedAt" sortable="true" sortProperty="sortLastModifiedAt" headerClass="dateData" class="dateData columnSeparator" />

		<spring:message var="versionCreatorLabel" code="document.createdBy.label" text="Created by"/>
		<display:column title="${versionCreatorLabel}" property="lastModifiedBy" sortable="true" sortProperty="sortLastModifiedBy" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="versionCommentLabel" code="document.comment.label" text="Comment"/>
		<display:column title="${versionCommentLabel}" property="comment" sortable="true" headerClass="textData expand" class="textDataWrap columnSeparator" />

		<spring:message var="versionSizeLabel" code="document.fileSize.label" text="Size"/>
		<display:column title="${versionSizeLabel}" property="fileSize" sortable="true" sortProperty="sortFileSize" headerClass="numberData" class="numberData" />
	  </ui:actionGenerator>
	</display:table>
</form>
