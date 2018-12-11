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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<c:set var="tab"><c:out value="${param.tab}"/></c:set>
<c:set var="title"><c:out value="${param.title}"/></c:set>
<c:url var="actionURL" value="/trash.spr?orgDitchnetTabPaneId=${tab}&projectId=${projectId}" />

<style type="text/css">
.trashTable {
	width: inherit !important;
}

.descriptionColumn {
	max-width: 600px !important;
	word-wrap: break-word !important;
	white-space: normal;
}

.filterDiv {
	margin-left: auto;
	margin-top: -2px;
	margin-right: -10px;
}

.filterdivNotEmpty {
	float: right;
	display: inline;
}

.goButton {
	margin-right: 0px !important;
	margin-left: 0px !important;
}
</style>

<script type="text/javascript">
	// HTML does not allow nested <form> elements, so we will assemble it dynamically
	jQuery(function($) {
		function doSearch() {
			var filterPattern = $("#documentSearchPattern-${tab}").val();
			document.location = "${actionURL}&searchText=" + encodeURIComponent(filterPattern);
		}

   		applyHintInputBox("#documentSearchPattern-${tab}", "${searchHint}");

		var pattern = $("#documentSearchPattern-${tab}");

		pattern.keypress(function(e) {
			if (e.which == 13) {
				doSearch();
			    return false;
		     }
		     return true;
	    });

		$("#filterBtn-${tab}").click(function(){
			doSearch();
		});

		$("#checkAll-${tab}").click(function () {
	        if ($("#checkAll-${tab}").is(':checked')) {
	      	  	$("input[name='selectedArtifactIds-${tab}']").each(function () {
	                $(this).prop("checked", true);
	            });

	        } else {
	      	  	$("input[name='selectedArtifactIds-${tab}']").each(function () {
	                $(this).prop("checked", false);
	            });
	        }
	    });

		$("#restore-${tab}").click(function () {
			return submitArtifacts($(this), {
				tab     : "${tab}",
				action  : restoreArtifacts,
				success : doSearch
			});
		});

		$("#delete-${tab}").click(function () {
			return submitArtifacts($(this), {
				tab     : "${tab}",
				action  : deleteArtifacts,
				success : doSearch
			});
		});
   });

</script>

<c:set var="isEmptyList" value="${empty content.list}" />
<c:set var="filterClass" value="filterDiv filterdivNotEmpty" />

<c:set var="emptyMessage">
	<spring:message code="documents.emptyTrashCategory.message" arguments="${title}"/>
</c:set>

<c:if test="${isEmptyList}">
	<c:set var="filterClass" value="filterDiv" />
</c:if>

<c:if test="${not empty searchText}">
	<c:set var="searchText"><c:out value="${searchText}" /></c:set>
	<c:set var="emptyMessage">
		<spring:message code="documents.emptyTrashQuery.message" arguments="${title},${searchText}" />
	</c:set>
</c:if>

<c:set var="searchToken" value="" />
<c:if test="${tab == openTabId}">
	<c:set var="searchToken">${searchText}</c:set>
</c:if>

<spring:message var="restoreHint" code="documents.restoreTrash.tooltip" text="Restore selected documents from trash"/>
<spring:message var="deleteHint" code="documents.deleteTrash.tooltip" text="Irreversibly delete selected documents from trash"/>
<spring:message var="searchHint" code="search.hint" text="Search..."/>
<spring:message var="searchTitle" code="documents.search.tooltip" text="Use wildcards to search files or directories by name..."/>
<spring:message var="filterLabel" code="search.submit.label" text="GO" />

<ui:actionBar>
	<c:if test="${not isEmptyList}">
		<a href="#" title="${restoreHint}" id="restore-${tab}" class="actionLink"><spring:message code="documents.restoreTrash.title" text="Restore"/></a>
		<a href="#" title="${deleteHint}" id="delete-${tab}" class="actionLink"><spring:message code="documents.deleteTrash.title" text="Delete"/></a>
	</c:if>
	<div class="${filterClass}">
		<input type="text" id="documentSearchPattern-${tab}" size="20" title="${searchTitle}" class="searchFilterBox" value="${searchToken}" >
		<input id="filterBtn-${tab}" type="button" class="button goButton" value="${filterLabel}" title=""/>
	</div>
</ui:actionBar>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All" />
<c:set var="checkAll">
	<input type="CHECKBOX" title="${toggleButton}" id="checkAll-${tab}" name="SELECT_ALL" value="on">
</c:set>

<ui:displaytagPaging defaultPageSize="${pagesize}" items="${content}" excludedParams="page"/>

<display:table requestURI="${actionURL}" id="trashTable" name="${content}" cellpadding="0" class="trashTable" excludedParams="openTabId orgDitchnetTabPaneId" export="false"
	decorator="com.intland.codebeamer.ui.view.table.TrashListDecorator" sort="external">

	<display:setProperty name="basic.empty.showtable" value="false" />
	<display:setProperty name="basic.msg.empty_list" value="${emptyMessage}"/>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${isEmptyList ? 'none' : 'bottom'}"/>

	<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
			headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
		<input type="checkbox" name="selectedArtifactIds-${tab}" value="${idGenerator[trashTable]}" />
	</display:column>

	<display:column class="rawData" title="" property="actionInfo" media="html" />

	<spring:message var="docPath" code="project.name.label" text="Name"/>
	<c:if test="${tab == 'filesTrash' or param.tab == 'wikiTrash'}">
		<spring:message var="docPath" code="document.path.label" text="Path"/>
	</c:if>
	<display:column title="${docPath}" property="name" sortable="true" sortProperty="path" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="docVersion" code="document.version.label" text="Version"/>
	<display:column title="${docVersion}" property="version" headerClass="numberData" class="numberData columnSeparator" />

	<spring:message var="docDescription" code="document.description.label" text="Description"/>
	<display:column title="${docDescription}" property="description" sortable="false" headerClass="textData" class="textDataWrap columnSeparator descriptionColumn" />

	<spring:message var="docModifiedAt" code="document.lastModifiedAt.label" text="Modified at"/>
	<display:column title="${docModifiedAt}" property="lastModifiedAt" sortable="true" sortProperty="sortLastModifiedAt"	headerClass="dateData" class="dateData columnSeparator" />

	<spring:message var="docModifiedBy" code="document.lastModifiedBy.label" text="Modified by"/>
	<display:column title="${docModifiedBy}" property="lastModifiedBy" sortable="true" sortProperty="sortLastModifiedBy" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="docStatus" code="document.status.label" text="Status"/>
	<display:column title="${docStatus}" property="status" sortable="true" sortProperty="sortStatus" headerClass="textData StatusHeaderClass" class="textData columnSeparator StatusClass" />

	<spring:message var="docSize" code="document.fileSize.label" text="Size"/>
	<display:column title="${docSize}" property="fileSize" sortable="true" sortProperty="sortFileSize" headerClass="numberData" class="numberData" />

</display:table>
