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
<%@ page import="com.intland.codebeamer.Config"%>
<%@ page import="com.intland.codebeamer.servlet.FilteredQueryStringBuilder"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
	.newskin #west {
		overflow: auto !important;
	}

	#closer-west, #opener-west {
		display: none;
	}

	#rightPane .actionBar {
		margin: 0px 0px;
	}

	#scmFile, .pagebanner {
		margin-left: 15px !important;
		margin-right: 15px !important;
	}

	#scmFile {
		width: 97%;
		margin-top: 10px;
	}

	#rightPane .actionBar .breadcrumbs {
		position: relative;
		top: 4px;
	}

	#treePane {
		margin-top: 5px;
	}

	.mimeTypeIcon {
		margin-right: 5px;
		top: 3px;
		position: relative;
	}

	.newskin .displaytag td {
		padding-top: 10px;
	}

	.newskin .displaytag td, .newskin .displaytag th {
		padding-left: 15px;
		padding-right: 15px;
	}

	.filterForm {
		padding: 6px 4px 4px 0;
	}

	.filterForm select {
		position: relative;
		top: -2px;
		width: 60%;
	}
</style>

<c:set var="repositoryId" value="${repository.id}" />

<%-- TODO: this would be depend on the repo type and set by ScmRepositoryManagerController#viewFiles() --%>
<c:set var="showChangeDetailsWithAjax" value="true" />

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<c:set var="filesPanel">
			<c:set var="branchOrTag"><c:out value="${command.branchOrTag}"/></c:set>
			<c:url var="breadCrumbUrl" value="/scm/dir/${repository.id}/${branchOrTag}"/>
			<div class="actionBar">
				<spring:message var="rootName" code="scm.repository.node.label" text="SCM Repository"/>
				<ui:pathBreadcrumb path="${command.path}" requestParameterName="path" rootName="${rootName}" baseURL="${breadCrumbUrl}" />
			</div>

			<ui:displaytagPaging defaultPageSize="${pagesize}" items="${files}" excludedParams="page"/>
			<c:url var="filesUrl" value="/proj/scm/repository.spr"/>
			<display:table requestURI="${filesUrl}" name="${files}" id="scmFile" cellpadding="0" cellspacing="0"
							sort="external" decorator="com.intland.codebeamer.ui.view.table.ScmBrowseDecorator">
				<c:if test="${allItems > pageSize}">
					<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
					<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				</c:if>

				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty files.list ? 'none' : 'bottom'}"/>

				<spring:message var="nameTitle" code="scm.browse.name.label" text="Name"/>
				<display:column title="${nameTitle}" property="name" sortable="true" headerClass="textData" class="textData nameColumn" />

				<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
					<ui:actionMenu builder="scmFileListContextActionMenuBuilder" subject="${scmFile}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
				</display:column>

				<spring:message var="revTitle" code="scm.browse.revision.label" text="Rev."/>
				<display:column title="${revTitle}" property="${showChangeDetailsWithAjax ? 'space' : 'revision'}" sortable="${! showChangeDetailsWithAjax}"
					headerClass="textData" class="textData columnSeparator compact revisionColumn"/>

				<spring:message var="dateTitle" code="scm.browse.date.label" text="Date"/>
				<display:column title="${dateTitle}" property="${showChangeDetailsWithAjax ? 'space' : 'date'}" sortable="${! showChangeDetailsWithAjax}"
					headerClass="dateData" class="dateData columnSeparator dateColumn"/>

				<spring:message var="authorTitle" code="scm.commit.author.label" text="Author"/>
				<display:column title="${authorTitle}" property="${showChangeDetailsWithAjax ? 'space' : 'author'}" sortable="${! showChangeDetailsWithAjax}"
					headerClass="textData" class="textData columnSeparator authorColumn" />

				<spring:message var="messageTitle" code="scm.commit.comment.label" text="Message"/>
				<display:column title="${messageTitle}" property="${showChangeDetailsWithAjax ? 'space' : 'commitMessage'}" sortable="${! showChangeDetailsWithAjax}"
					headerClass="textData expand" class="textDataWrap columnSeparator compact commitMessageColumn" escapeXml="true" />

				<spring:message var="tasksTitle" code="scm.commit.tasks.label" text="Tasks"/>
				<display:column title="${tasksTitle}" property="${showChangeDetailsWithAjax ? 'space' : 'tasks'}" headerClass="textData" class="textData tasksColumn"/>
			</display:table>
</c:set>

<c:set var="showTree" value="true"/>
<c:choose>
	<c:when test="${showTree}">
		<ui:splitTwoColumnLayoutJQuery>
			<jsp:attribute name="leftContent">
				<jsp:include page="scmtree.jsp" />
			</jsp:attribute>
			<jsp:attribute name="leftPaneActionBar">
				<c:if test="${supportsBranchesTagsOnFileListing}">
					<div>
						<spring:message code="scm.branches.label" var="branchesLabel"/>
						<spring:message code="scm.tags.label" var="tagsLabel"/>
						<c:url var="filesUrl" value="${repository.filesUrlLink}"/>
						<form:form action="${filesUrl}" cssClass="filterForm" method="GET">
							<input type="hidden" name="path" id="path" value="<c:out value='${command.path}'/>"/>
							<label><spring:message code="scm.branchesortags.label" text="Branches, tags"/>
								<form:select id="branchOrTag" path="branchOrTag"
										onchange="onBranchChanged(this);">
									<form:option disabled="true" value="${branchesLabel}"/>
									<c:forEach items="${command.branches}" var="branch">
										<form:option value="${branch}" label="${branch}" />
									</c:forEach>
									<form:option value="${tagsLabel}" disabled="true"/>
									<c:forEach items="${command.tags}" var="tag">
										<form:option value="${tag}" label="${tag}"/>
									</c:forEach>
								</form:select>
							</label>
						</form:form>
					</div>
				</c:if>
			</jsp:attribute>
			<jsp:body>
				${filesPanel}
			</jsp:body>
		</ui:splitTwoColumnLayoutJQuery>
	</c:when>
	<c:otherwise>
		${filesPanel}
	</c:otherwise>
</c:choose>

<c:if test="${showChangeDetailsWithAjax}">
<%
	String queryParams = (new FilteredQueryStringBuilder(request)).setEncode(true).getFilteredQueryString();
	pageContext.setAttribute("queryParams", queryParams);
%>

<ui:delayedScript>
<%-- this ajax call will fetch the file details --%>
<c:url var="ajaxViewFilesURL" value="/proj/scm/ajax/viewFiles.spr?${queryParams}" />
<script type="text/javascript">
// show the busy indicator above the 1st revision-cell
var cell = $("#scmFile tr .revisionColumn").first();
var busySign = null;
if (cell.length>0) {
	busySign = ajaxBusyIndicator.showBusysign(cell[0], i18n.message("ajax.loading"), false, {
		width: "12em",
		context: [ cell[0], "tl", "tl", null, [10, 10] ]
	});
}
$.ajax({
	url: "${ajaxViewFilesURL}",
	type: "GET",
	cache: false,
	success: function(data, textStatus, jqXHR) {
		// find all rows in the file table and add the content has arrived in the json response
		$("#scmFile tr .nameColumn a").each(function(index, value) {
			var fileName = $(value).html();

			var dataForFile = data[fileName];

			if (dataForFile != null) {
				var tableRow = $(value).parents("tr").first();	// note: closest() would be nicer, but it does not work just in jquery 1.6 with IE6

				// fill the cell in the current row with the property value
				var fillCell = function(property) {
					var content = dataForFile[property];
					// the revision property's cell has "revisionColumn" css class to make it easier to find
					$(tableRow).find("td." + property +"Column").html(content);
				};
				fillCell("revision");
				fillCell("date");
				fillCell("author");
				fillCell("commitMessage");
				fillCell("tasks");
			}
		});
		if (busySign) {
			ajaxBusyIndicator.close(busySign);
		}
	},
	error: function(jqXHR, textStatus, errorThrown) {
		if (busySign) {
			ajaxBusyIndicator.close(busySign);
		}
	}
});

$("#treePane").bind("loaded.jstree", function(){ initializeTreeIconColors($("#treePane"));});

function onBranchChanged(element) {
	// delet path when branch is changed
	$("#path").val("");
	element.form.submit();
}

</script>
</ui:delayedScript>
</c:if>
