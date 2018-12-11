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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%@page import="com.intland.codebeamer.ui.view.actionmenubuilder.ArtifactListContextActionMenuBuilder"%>

<%-- set the default icons on the ajaxDocumentLockController from the java class --%>
<script type="text/javascript">
	AjaxDocumentLockController.prototype.ICON_URL_LOCKED = '<%=ArtifactListContextActionMenuBuilder.ICON_URL_LOCKED%>';
	AjaxDocumentLockController.prototype.ICON_URL_NOT_LOCKED = '<%=ArtifactListContextActionMenuBuilder.ICON_URL_NOT_LOCKED%>';
</script>

<jsp:include page="/docs/includes/createArtifacts.jsp" />

<ui:showErrors />

<c:set var="searchMode" value="${!empty listDocumentForm.searchPattern || !empty listDocumentForm.mimeTypeFilter}" />

<html:form action="/proj/doc/documentProperties" method="GET" styleId="documentPropertiesForm">

<html:hidden property="action" />
<html:hidden property="revision" />

<c:choose>
	<c:when test="${!empty listDocumentForm.doc_id}">
		<html:hidden property="doc_id" />
	</c:when>

	<c:when test="${!empty listDocumentForm.proj_id}">
		<html:hidden property="proj_id" />
	</c:when>
</c:choose>

<c:set var="currentDirectory" value="${listDocumentForm.currentDirectory}" />
<%-- wiki description of the current dir --%>

<style type="text/css">
	#fileAttributes {
		width: 98%;
	}

	#opener-west {
		margin-top: -20px !important;
		margin-left: -5px;
	}

	#rightPane > div.pagebanner {
		padding-top: 5px;
	}
</style>

<c:if test="${listDocumentForm.directoryRootType eq 'Baseline'}">
	<style type="text/css">
		.odd {
			background: #FFF0AA !important;
		}
		.even {
			background: #FFFFDD !important;
		}
	</style>
</c:if>

<c:set var="rightActionBar">
<ui:actionGenerator builder="artifactActionMenuBuilder" subject="${listDocumentForm}" actionListName="actionList">
<c:set var="actionList" value="${actionList}" scope="request" />

<c:set var="showFileUploadWidget" value="${!empty actionList['newFile']}" />

<c:set var="isBaselined" value="${listDocumentForm.directoryRootType eq 'Baseline'}" />

<c:set var="middlePaneActionBar">
	<jsp:include page="includes/listDocumentsActionBar.jsp">
		<jsp:param name="unwrapContents" value="true" />
		<jsp:param name="isBaselined" value="${isBaselined}" />
		<jsp:param name="displayNew" value="${showFileUploadWidget}" />
	</jsp:include>
</c:set>

</ui:actionGenerator>

</c:set>

<%-- include the JS and hidden field for deleting one/multiple documents --%>
<jsp:include page="/docs/includes/deleteArtifacts.jsp" >
	<jsp:param name="confirmMessageKey" value="docs.delete.confirm" />
	<jsp:param name="confirmOneMessageKey" value="docs.deleteOneDoc.confirm" />
	<jsp:param name="confirmOneDirMessageKey" value="docs.deleteOneDir.confirm" />
</jsp:include>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>

<c:set var="checkAll">
	<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, 'selectedArtifactIds')">
</c:set>

<c:set var="export" value="false" />

<ui:displaytagPaging defaultPageSize="${pagesize}" items="${listDocumentForm.content}" excludedParams="page"/>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<c:set var="docTable">
	${rightActionBar}

	<c:if test="${!empty currentDirectory.description}">
		<div class="descriptionBox">
			<tag:transformText value="${currentDirectory.description}" format="${currentDirectory.descriptionFormat}" />
		</div>
	</c:if>

	<display:table requestURI="/proj/doc.do" id="fileAttributes" name="${listDocumentForm.content}" cellpadding="0"
		export="${export}" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator" sort="external" defaultsort="4"
		excludedParams="emptyTrash trashMode" class="${listDocumentForm.directoryRootType eq 'Baseline'? 'baseline' : '' }">

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty listDocumentForm.content.list ? 'none' : 'bottom'}"/>

		<c:if test="${export}">
			<display:setProperty name="export.csv.decorator" value="com.intland.codebeamer.ui.view.table.DocumentListDecorator" />
			<display:setProperty name="export.excel.decorator" value="com.intland.codebeamer.ui.view.table.DocumentListDecorator" />
			<display:setProperty name="export.xml.decorator" value="com.intland.codebeamer.ui.view.table.DocumentListDecorator" />
			<display:setProperty name="export.pdf.decorator" value="com.intland.codebeamer.ui.view.table.DocumentListDecorator" />
			<display:setProperty name="export.rtf.decorator" value="com.intland.codebeamer.ui.view.table.DocumentListDecorator" />
		</c:if>

		<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
			headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">

			<ct:call return="cutToClipboard" object="${listDocumentForm}" method="isCutToClipboard" param1="${sessionScope.clipboard}" param2="${fileAttributes}" />

			<c:if test="${!cutToClipboard}">
				<ct:call return="itemId"     object="${listDocumentForm}" method="getItemId"  param1="${fileAttributes}" />
				<ct:call return="isSelected" object="${listDocumentForm}" method="isSelected" param1="${fileAttributes}" />
				<input type="checkbox" name="selectedArtifactIds" value="${itemId}"
					<c:if test="${isSelected}" >checked="checked"</c:if> >
				</input>
			</c:if>
		</display:column>

		<display:column class="rawData actionIcon" title="" property="actionInfo" media="html" />

		<%-- Show the path for searchMode --%>
		<spring:message var="docName" code="document.name.label" text="Name"/>
		<c:choose>
			<c:when test="${searchMode}">
				<display:column title="${ui:removeXSSCodeAndHtmlEncode(docName)}" property="path" sortable="true" headerClass="textData expand" class="textData nameLink summaryLink" />
			</c:when>
			<c:otherwise>
				<display:column title="${ui:removeXSSCodeAndHtmlEncode(docName)}" property="name" sortable="true" sortProperty="sortName" headerClass="textData" class="textData nameLink summaryLink" />
			</c:otherwise>
		</c:choose>

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionGenerator builder="newSkinArtifactListContextActionMenuBuilder"  subject="${fileAttributes}" actionListName="actions"
				deniedKeys="Open Directory,Display Wiki Note">
				<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
			</ui:actionGenerator>
		</display:column>

		<spring:message var="docVersion" code="document.version.label" text="Version"/>
		<display:column title="${docVersion}" property="version" headerClass="numberData" class="numberData smallerText columnSeparator" />

		<c:if test="${!searchMode}">
			<spring:message var="docDescription" code="document.description.label" text="Description"/>
			<display:column title="${docDescription}" property="description" sortable="false" headerClass="textData expand" class="textDataWrap smallerText columnSeparator" />
		</c:if>

		<spring:message var="docModifiedAt" code="document.lastModifiedAt.label" text="Modified at"/>
		<display:column title="${docModifiedAt}" property="lastModifiedAt" sortable="true" sortProperty="sortLastModifiedAt" headerClass="dateData" class="dateData columnSeparator" />

		<spring:message var="docModifiedBy" code="document.lastModifiedBy.short" text="Modified by"/>
		<display:column title="${docModifiedBy}" property="lastModifiedBy" sortable="true" sortProperty="sortLastModifiedBy" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="docStatus" code="document.status.label" text="Status"/>
		<display:column title="${docStatus}" property="status" sortable="true" sortProperty="sortStatus" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="docSize" code="document.fileSize.label" text="Size"/>
		<display:column title="${docSize}" property="fileSize" sortable="true" sortProperty="sortFileSize" headerClass="numberData" class="numberData" />
	</display:table>
</c:set>

<jsp:include page="./includes/docTreeLayout.jsp">
	<jsp:param name="panesExtraClasses" value="autoAdjustPanesHeight" />
	<jsp:param name="showFileUploadWidget" value="${showFileUploadWidget}" />
	<jsp:param name="middlePanel" value="${docTable}" />
	<jsp:param name="middlePaneActionBar" value="${middlePaneActionBar}" />
	<jsp:param name="docId" value="${listDocumentForm.doc_id}" />
	<jsp:param name="revision" value="${listDocumentForm.revision}" />
	<jsp:param name="isBaselined" value="${isBaselined}" />
</jsp:include>

</html:form>
