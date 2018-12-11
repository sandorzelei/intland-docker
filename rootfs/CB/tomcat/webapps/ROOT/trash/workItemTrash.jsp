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

.cannot-delete-warn {
	display: inline-block;
}
</style>


<c:url var="restoreWorkItemsURL" value="/trash/restoreWorkItems.spr">
	<c:param name="projectId" value="${projectId}"/>
</c:url>
<c:url var="deleteWorkItemsURL" value="/trash/deleteWorkItems.spr">
	<c:param name="projectId" value="${projectId}"/>
</c:url>


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
	        if ($(this).is(':checked')) {
	      	  	$("input[name='trackerItemTrashId']").each(function () {
	                $(this).prop("checked", true);
	            });
	        } else {
	      	  	$("input[name='trackerItemTrashId']").each(function () {
	                $(this).prop("checked", false);
	            });
	        }
	    });

		$("#restore-${tab}").click(function () {
			var link = $(this);
			var style = link.css(['color', 'cursor']);

			if (style.cursor != 'progress') {
				var trackerItemIds = [];
				$('input:checkbox[name="trackerItemTrashId"]:checked').each(function() {
					trackerItemIds.push(parseInt($(this).val()));
				});

				if (trackerItemIds.length > 0) {
					var busy = ajaxBusyIndicator.showBusyPage();

					link.css({
						color  : 'lightGray',
						cursor : 'progress'
					});

					$.ajax("${restoreWorkItemsURL}", {
						type        : 'POST',
						data		: JSON.stringify(trackerItemIds),
						contentType : 'application/json',
						dataType    : 'json'
					}).done(function(result) {
						doSearch();
			    	}).fail(function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
			    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			    		}
			    	}).always(function() {
						ajaxBusyIndicator.close(busy);

						link.css(style);
			    	});
				}
			}

			return false;
		});

		$("#delete-${tab}").click(function () {

			var msg = '<spring:message javaScriptEscape="true" code="documents.deleteTrash.trackeritems.warning" />';
			return showFancyConfirmDialogWithCallbacks(msg, function(){
				var link = $(this);
				var style = link.css(['color', 'cursor']);

				if (style.cursor != 'progress') {
					var trackerItemIds = [];
					$('input:checkbox[name="trackerItemTrashId"]:checked').each(function() {
						trackerItemIds.push(parseInt($(this).val()));
					});

					if (trackerItemIds.length > 0) {
						var busy = ajaxBusyIndicator.showBusyPage();

						link.css({
							color  : 'lightGray',
							cursor : 'progress'
						});

						$.ajax("${deleteWorkItemsURL}", {
							type        : 'POST',
							data		: JSON.stringify(trackerItemIds),
							contentType : 'application/json',
							dataType    : 'json'
						}).done(function(result) {
							doSearch();
						}).fail(function(jqXHR, textStatus, errorThrown) {
							try {
								var exception = $.parseJSON(jqXHR.responseText);
								alert(exception.message);
							} catch(err) {
								console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
							}
						}).always(function() {
							ajaxBusyIndicator.close(busy);

							link.css(style);
						});
					}
				}
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
	<c:set var="searchToken" value="${searchText}" />
</c:if>

<spring:message var="restoreHint" code="documents.restoreTrash.trackeritems.tooltip" text="Restore selected work items from trash"/>
<spring:message var="deleteHint" code="documents.deleteTrash.trackeritems.tooltip" text="Irreversibly delete selected work items from trash"/>
<spring:message var="searchHint" code="search.hint" text="Search..."/>
<spring:message var="searchTitle" code="trash.trackeritems.search.tooltip" text="Use wildcards to search work items by name..."/>
<spring:message var="filterLabel" code="search.submit.label" text="GO" />

<ui:actionBar>
	<c:if test="${not isEmptyList}">
		<a href="#" title="${restoreHint}" id="restore-${tab}" class="actionLink"><spring:message code="documents.restoreTrash.title" text="Restore"/></a>
		<c:choose>
			<c:when test="${possibleToDeleteItems}">
				<a href="#" title="${deleteHint}" id="delete-${tab}" class="actionLink"><spring:message code="documents.deleteTrash.title" text="Delete"/></a>
			</c:when>
			<c:otherwise>
				<div class="textHint cannot-delete-warn "><spring:message code="trash.trackeritems.cannot.delete" text="Work Items cannot be deleted from trash!" /></div>
			</c:otherwise>
		</c:choose>
	</c:if>
	<div class="${filterClass}">
		<input type="text" id="documentSearchPattern-${tab}" size="20" title="${searchTitle}" class="searchFilterBox" value="${searchToken}">
		<input id="filterBtn-${tab}" type="button" class="button goButton" value="${filterLabel}" title=""/>
	</div>
</ui:actionBar>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All" />
<c:set var="checkAll">
	<input type="CHECKBOX" title="${toggleButton}" id="checkAll-${tab}" name="SELECT_ALL" value="on">
</c:set>

<ui:displaytagPaging requestURI="/trash.spr?orgDitchnetTabPaneId=${tab}&projectId=${projectId}" defaultPageSize="${pagesize}" items="${content}" excludedParams="projectId page title tab orgDitchnetTabPaneId"/>

<display:table requestURI="${actionURL}" id="trashTable" name="${content}" cellpadding="0" class="trashTable" excludedParams="projectId title tab openTabId orgDitchnetTabPaneId" export="false"
	decorator="com.intland.codebeamer.ui.view.table.TrashLayoutDecorator" sort="external">

	<display:setProperty name="basic.empty.showtable" value="false" />
	<display:setProperty name="basic.msg.empty_list" value="${emptyMessage}"/>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${isEmptyList ? 'none' : 'bottom'}"/>

	<display:column title="${checkAll}" media="html" property="checkbox" sortable="false" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth"/>

	<display:column titleKey="issue.id.label" property="id" sortable="true" sortProperty="id" headerClass="textData" class="textData columnSeparator" />

	<display:column titleKey="issue.priority.short" property="priority" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<display:column titleKey="issue.summary.label" property="name" sortable="true" headerClass="textData" class="textDataWrap columnSeparator" />

	<display:column titleKey="issue.tracker.label" property="tracker.name" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<display:column titleKey="issue.status.label" property="status" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<display:column titleKey="issue.modifiedAt.label" property="modifiedAt" sortable="true" headerClass="dateData" class="dateData columnSeparator" />

	<display:column titleKey="issue.modifiedBy.label" property="modifier" sortable="true" headerClass="dateData" class="dateData columnSeparator" />

	<display:column titleKey="issue.submittedAt.label" property="submittedAt" sortable="true" headerClass="dateData columnSeparator" class="dateData columnSeparator" />

	<display:column titleKey="issue.submitter.label" property="submitter" sortable="true" headerClass="textData" class="textData columnSeparator" />

</display:table>
