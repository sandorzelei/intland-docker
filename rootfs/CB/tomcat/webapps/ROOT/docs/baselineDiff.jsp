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
<meta name="decorator" content="${!empty param.proj_id ? 'main' : 'popup'}"/>
<meta name="module" content="baselines"/>
<meta name="moduleCSSClass" content="newskin documentsModule baselinesModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:url var="firstBaselineUrl"  value="${first.propertiesLink}"/>
<c:set var="firstBaselineName" value="${empty first.baseline ? first.dto.name : first.baseline.root.name}"/>

<c:url var="secondBaselineUrl"  value="${second.propertiesLink}"/>
<c:set var="secondBaselineName" value="${empty second.baseline ? second.dto.name : second.baseline.root.name}"/>

<style type="text/css">
.dateData td {
	text-align: left;
}
table.displaytag {
	width: 97% !important;
}
.textData {
	white-space: normal;
	vertical-align: middle;
}
.centered {
	text-align: center;
}
.bdvHeader {
 	text-align: center;
	padding-left: 5px !important;
	padding-right: 5px !important;
}
.tableIcon {
	margin-right: 5px !important;
	margin-left: 16px !important;
}
.diffNameTable td {
	padding-top: 0px !important;
	padding-left: 0px !important;
}
.lastmodifiedheader {
	text-align: left;
	padding-left: 14px !important;
}
.diffNameTable .subtext {
	font-size: 13px !important;
	color: #2b2b2b !important;
}
.diffNameTable td {
	padding-bottom: 0px !important;
}
</style>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
		<ui:pageTitle><spring:message code="baseline.diff.title" text="Compare baseline"/>
			<a href="${firstBaselineUrl}"><c:out value="${firstBaselineName}"/></a> --&gt;
			<a href="${secondBaselineUrl}"><c:out value="${secondBaselineName}"/></a>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>


<spring:message var="actionTitle" code="issue.history.action.label" text="Action"/>
<spring:message var="versionTitle" code="document.version.label" text="Version"/>

<ui:displaytagPaging defaultPageSize="50" items="${diffs}" excludedParams="page"/>

<div class="contentWithMargins">
	<display:table requestURI="" id="diff" name="${diffs}" cellpadding="0" export="true" sort="external" decorator="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" >

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><div class="pagebanner">{0} {1} different.</div></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty listDocumentForm.content.list ? 'none' : 'bottom'}"/>

		<display:setProperty name="export.csv.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
		<display:setProperty name="export.excel.decorator" value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
		<display:setProperty name="export.xml.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
		<display:setProperty name="export.pdf.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
		<display:setProperty name="export.rtf.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />

		<display:column title="${actionTitle}" property="action" headerClass="textData" class="textData columnSeparator"  style="width:5%"/>

		<display:column title="${firstBaselineName}" property="oldRevisionWithoutVersion" headerClass="textData" class="textData" style="width:15%"/>

		<display:column title="${versionTitle}" property="oldRevisionVersionLink" headerClass="textData bdvHeader" class="textData columnSeparator centered" style="width:5%" />

		<display:column title="${secondBaselineName}" property="newRevisionWithoutVersion" headerClass="textData" class="textData"  style="width:15%"/>

		<display:column title="${versionTitle}" property="newRevisionVersionLink" headerClass="textData bdvHeader" class="textData centered" style="width:5%" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${diff}" actionListName="actions" deniedKeys="Open Directory,Display Wiki Note">
				<ui:actionMenu actions="${actions}" />
			</ui:actionGenerator>
		</display:column>

		<spring:message var="changeComment" code="document.comment.label" text="Comment"/>
		<display:column title="${changeComment}" property="comment" headerClass="textData  expand" class="textData columnSeparator" />

		<spring:message var="lastModifiedAt" code="document.lastModifiedAt.label" text="Last modified at"/>
		<display:column title="${lastModifiedAt}" media="html" headerClass="dateData lastmodifiedheader" class="dateData columnSeparator" style="width:5%">
			<c:if test="${diff.dto != null && diff.dto.lastModifiedBy != null && diff.dto.lastModifiedAt != null}">
				<ui:submission userId="${diff.dto.lastModifiedBy.id}" userName="${diff.dto.lastModifiedBy.name}" date="${diff.dto.lastModifiedAt}"/>
			</c:if>
		</display:column>

	</display:table>
</div>
