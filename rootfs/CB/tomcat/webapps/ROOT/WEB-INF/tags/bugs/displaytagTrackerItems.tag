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
<%--
	Tag to render a displaytag table, which contains tracker-items. Used on bugs page for example.
--%>

<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ tag import="java.util.Set"%>
<%@ tag import="java.util.HashSet"%>
<%@ tag import="java.util.Arrays"%>

<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>
<%@ tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ tag import="com.intland.codebeamer.ui.view.table.TrackerTreeTableLayoutDecorator"%>
<%@ tag import="com.intland.codebeamer.ui.view.table.QueriesColumnDecorator"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"%>
<%@ tag import="org.displaytag.pagination.PaginatedList"%>
<%@ tag import="com.intland.codebeamer.manager.trackeritems.DisplaytagTrackerItemsSupport"%>
<%@ tag import="java.util.List" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="items" required="true" description="The list of TrackerItems to show" type="java.lang.Object" rtexprvalue="true" %>
<%@ attribute name="reportId" required="false" description="Report ID if present." type="java.lang.Integer" rtexprvalue="true" %>
<%@ attribute name="layoutList"	required="true" description="A list of TrackerLayoutLabelDto define the columns to show" type="java.util.List" rtexprvalue="true" %>
<%@ attribute name="decorator" required="false" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" %>
<%@ attribute name="includeBaselineInTtId" required="false" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="showContextMenu" required="false" %>
<%@ attribute name="forceOpenInNewWindow" required="false" %>

<%-- selection specific attributes --%>
<%@ attribute name="selection" required="false" description="If selecting tracker-items is supported (by checkbox or radio buttons)" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="selectionFieldName" required="false" description="The name for selection field/property" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="multiSelect" required="false" description="true for multi-select (checkbox), false for singleselect (radio button)" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="allowSelectionPredicate" required="false" type="org.apache.commons.collections.Predicate"
	description="Commons' predicate will be called with TrackerItem as parameter, and decides if the selection is allowed on the given TrackerItem" rtexprvalue="true" %>
<%@ attribute name="selectedItems" required="false" type="java.lang.String[]" description="String array of ids of selected items" rtexprvalue="true"  %>

<%-- displaytag attributes --%>
<%@ attribute name="defaultsort" required="false" description="same as display:table's defaultsort" type="java.lang.Integer" rtexprvalue="true" %>
<%@ attribute name="defaultorder" required="false" description="same as display:table's defaultorder" type="java.lang.Object" rtexprvalue="true" %>
<%@ attribute name="requestURI" required="false" description="same as display:table" type="java.lang.Object" rtexprvalue="true" %>
<%@ attribute name="pagesize" required="false" description="The page size for displaytag" type="java.lang.Object" rtexprvalue="true" %>
<%@ attribute name="excludedParams" required="false" description="same as displaytag:table" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="export" required="false" description="same as displaytag:table" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="clearNavigationList" required="false" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="paginationParamPrefix" required="false" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="htmlId" required="false" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="exportTypes" required="false" rtexprvalue="true" %>
<%@ attribute name="exportMode" required="false" description="It reflects the usage scenario. Export done through the Codebeamer should not contain certain UI elements." type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="extraColumn" required="false" type="java.util.Map" description="A map containing a html string for each tracker item in the table. This html will be rendered in a separate column" rtexprvalue="true"%>
<%@ attribute name="extraColumnLabel" required="false" description="The label for the extra column" rtexprvalue="true"%>
<%@ attribute name="extraColumnClass" required="false" description="The css class for the extra column" rtexprvalue="true"%>
<%@ attribute name="hideIconColumn" required="false" description="If the icon column should hide or not." rtexprvalue="true"%>
<%@ attribute name="globalSortable" required="false" description="If set to false then the columns are not sortable. Default is true" rtexprvalue="true"%>
<%@ attribute name="isReview" required="false" description="If set to true then used for displaying review items. Default is false" rtexprvalue="true"%>
<%@ attribute name="hideItemChildrenHandler" type="java.lang.Boolean" required="false" description="If the handler for children should hide or not." rtexprvalue="true"%>
<%@ attribute name="plannerMode" type="java.lang.Boolean" required="false" description="If displaytag is used in planner or not (add extra columns)." rtexprvalue="true"%>

<%--If you set inlineEdit to true, please make sure to include <wysiwyg:froalaConfig /> taglib in your JSP file in which you use the taglib!--%>
<%@ attribute name="inlineEdit" type="java.lang.Boolean" required="false" description="If inline editing should be supported or not." %>
<%@ attribute name="inlineEditBuildTransitionMenu" type="java.lang.Boolean" required="false" description="Build transtion menu if click on the status icon of an item." %>

<%@ attribute name="showHeaderIfEmpty" type="java.lang.Boolean" required="false" description="Show header if there is no result." %>

<%@ attribute name="resizableColumns" type="java.lang.Boolean" required="false" description="If the column headers shoud resizeable or not." %>
<%@ attribute name="disableResizableColumns" type="java.lang.Boolean" required="false" description="If disable the resize handlers or not." %>

<%--
	Following parameters are specific to when this tag is called from browseTracker.jsp.

	I've tried to use fragments, to add the display:column fields dynamically to the displaytag-table, but it does not work :-(
	(Would have used <% attribute ... fragment="true" > to pass fragment and <jsp:invoke fragement="xxx"... to call it...)
	Ssee: http://www.mail-archive.com/displaytag-user@lists.sourceforge.net/msg04790.html
--%>
<%@ attribute name="browseTrackerMode" required="false" description="Boolean if the table is called from browseTracker.jsp" type="java.lang.Boolean" rtexprvalue="true" %>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<%-- set defaults for attributes --%>
<c:if test="${empty defaultorder}">
	<c:set var="defaultorder" value="ascending" />
</c:if>
<c:if test="${empty export}">
	<c:set var="export" value="true"/>
</c:if>
<c:if test="${empty selection}" >
	<c:set var="selection" value="false" />
</c:if>
<c:if test="${empty multiSelect}">
	<c:set var="multiSelect" value="true"/>
</c:if>
<c:if test="${empty globalSortable}">
    <c:set var="globalSortable" value="true"/>
</c:if>
<c:if test="${empty isReview}">
    <c:set var="isReview" value="false"/>
</c:if>

<c:set var="PROJECT_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.PROJECT_NAME_LABEL_ID)%>" />
<c:set var="TRACKER_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.TYPE_LABEL_ID)%>" />
<c:set var="PRIORITY_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.PRIORITY_LABEL_ID)%>" />
<c:set var="NAME_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.NAME_LABEL_ID)%>" />
<c:set var="STATUS_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.STATUS_LABEL_ID)%>" />
<c:set var="DESCRIPTION_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_LABEL_ID)%>" />
<c:set var="ID_LABEL_ID" value="<%=Integer.valueOf(TrackerLayoutLabelDto.ID_LABEL_ID)%>" />

<c:if test="${inlineEdit}">
	<script type="text/javascript" src="<ui:urlversioned value='/js/displaytagTrackerItemsInlineEdit.js'/>"></script>
</c:if>

<c:if test="${resizableColumns}">
	<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/colresizable/colResizable-1.6.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/js/displaytagTrackerItemsResizeableColumns.js'/>"></script>
</c:if>

<c:if test="${!exportMode}" >
	<ui:displaytagPaging defaultPageSize="${pagesize}" items="${items}" requestURI="${requestURI}" excludedParams="${excludedParams} ${empty paginationParamPrefix ? '' : paginationParamPrefix}page pagesize"/>
</c:if>

<%
	// for better performance the selected items are copied to this set
	Set selectedItemsSet = new HashSet();
	if (selectedItems != null) {
		selectedItemsSet = new HashSet(Arrays.asList(selectedItems));
	}

%>

<!-- tracker table starts here -->

<c:if test="${selection}" >
	<c:choose>
		<c:when test="${multiSelect}" >
			<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
			<c:set var="checkAll">
				<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, '${selectionFieldName}')">
			</c:set>
			<c:set var="selectControlType">checkbox</c:set>
		</c:when>
		<c:otherwise>
			<c:set var="checkAll" value=""/>
			<c:set var="selectControlType">radio</c:set>
		</c:otherwise>
	</c:choose>
</c:if>

<div class="scrollable">

<%
	if (decorator == null) {
		if (includeBaselineInTtId != null && includeBaselineInTtId.booleanValue()) {
			decorator = new TrackerTreeTableLayoutDecorator();
		} else {
			decorator = new TrackerSimpleLayoutDecorator();
		}
	}
	decorator.setClearNavigationList(clearNavigationList);
	request.setAttribute("decorator", decorator);

	request.setAttribute("treeTableIndicatorColumnIndex", DisplaytagTrackerItemsSupport.getTreeTableIndicatorColumnIndex((List<TrackerLayoutLabelDto>) jspContext.getAttribute("layoutList")));
	if (resizableColumns != null && Boolean.TRUE.equals(resizableColumns)) {
		UserDto user = (UserDto) request.getUserPrincipal();
		request.setAttribute("percentages", DisplaytagTrackerItemsSupport.getPercentagesOfColumns(user, reportId, (List<TrackerLayoutLabelDto>) jspContext.getAttribute("layoutList"), false));
	}
%>

<style type="text/css">
<!--
	.bug-icon {
		padding: 0 2px;
	}
-->
table.treetable span.indenter {
	float  : left;
	display: table-column;
	height : 1.5em;
}

table.treetable th.indenter {
	padding-left: 24px;
}

.transition-action-menu .ui-menu-item a {
	padding-left: 26px;
}
</style>

<%-- correct the column index in the default sort --%>
<c:if test="${selection && !empty defaultsort}">
	<c:set var="defaultsort" value="${defaultsort + 1}" />
</c:if>
<c:if test="${browseTrackerMode && !empty defaultsort}">
	<c:set var="defaultsort" value="${defaultsort + 1}" />
</c:if>

<display:table htmlId="${htmlId}" sort="external" excludedParams="${excludedParams}" requestURI="${requestURI}" export="${export}" name="${items}" id="item" cellpadding="0"
	pagesize="${pagesize}" defaultsort="${defaultsort}" defaultorder="${defaultorder}"
	class="trackerItems relationsExpander${isReview ? ' reviews' : ''}${inlineEdit ? ' inlineEditEnabled' : ''}${resizableColumns ? ' resizeableColumns' : ''}${decorator.sprintHistory ? ' sprintHistoryVisible' : ''}"
	decorator="decorator">

	<c:choose>
		<c:when test="${showHeaderIfEmpty}">
			<display:setProperty name="basic.empty.showtable" value="true" />
		</c:when>
		<c:otherwise>
			<display:setProperty name="basic.empty.showtable" value="false" />
		</c:otherwise>
	</c:choose>


	<display:setProperty name="export.csv.decorator" value="trackerSimpleLayoutDecorator" />
	<display:setProperty name="export.excel.decorator" value="trackerSimpleLayoutDecorator" />
	<display:setProperty name="export.xml.decorator" value="trackerSimpleLayoutDecorator" />
	<display:setProperty name="export.pdf.decorator" value="trackerSimpleLayoutDecorator" />
	<display:setProperty name="export.rtf.decorator" value="trackerSimpleLayoutDecorator" />

	<c:if test="${!exportMode}" >
		<display:setProperty name="paging.banner.placement" value="bottom" />
		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
	</c:if>

	<c:if test="${exportMode}" >
		<display:setProperty name="paging.banner.first" value="" />
		<display:setProperty name="paging.banner.some_items_found" value="" />
		<display:setProperty name="paging.banner.all_items_found" value="" />
		<display:setProperty name="paging.banner.no_items_found" value="" />
		<display:setProperty name="paging.banner.one_item_found" value="" />
	</c:if>

	<c:if test="${! empty exportTypes}">
		<display:setProperty name="export.types" value="${exportTypes}" />
	</c:if>

	<c:if test="${!empty paginationParamPrefix}">
		<display:setProperty name="pagination.pagenumber.param"    value="${paginationParamPrefix}page" />
		<display:setProperty name="pagination.sort.param"          value="${paginationParamPrefix}sort" />
		<display:setProperty name="pagination.sortdirection.param" value="${paginationParamPrefix}dir" />
	</c:if>

	<c:if test="${selection}">
		<display:column title="${checkAll}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html">
			<%
				boolean allowSelection = true;
				if (allowSelectionPredicate != null) {
					allowSelection = allowSelectionPredicate.evaluate(item);
				}

				// determine if the current item is checked
				String idStr =  "" + ((IdentifiableDto) item).getId();
				String checked = selectedItemsSet.contains(idStr) ? "checked='checked'" : "";
			%>
			<c:if test="<%=allowSelection%>">
				<input type="${selectControlType}" value="${item.id}" name="${selectionFieldName}" <%=checked%>	/>
			</c:if>
		</display:column>
	</c:if>

	<c:if test="${browseTrackerMode}">
		<display:column title="" property="extraInfo" media="html" class="column-minwidth" />
	</c:if>

	<%-- the menu should appear behind the "status" field, but if that is missing then it will be behind the name field--%>
	<c:set var="menuFollowsField" value="${NAME_LABEL_ID}" />
	<c:forEach items="${layoutList}" var="fieldLayout">
		<c:if test="${fieldLayout.id eq STATUS_LABEL_ID}" ><c:set var="menuFollowsField" value="${STATUS_LABEL_ID}"/></c:if>
	</c:forEach>

	<c:if test="${plannerMode}">
		<c:if test="${groupSize > 0}">
			<c:forEach begin="1" end="${groupSize}">
				<display:column class="groupIssueHandlePlaceholder"/>
				<display:column class="groupPlaceholder"><span class="groupPlaceholderHelper"></span></display:column>
			</c:forEach>
		</c:if>
		<spring:message code="planner.tableHead.rank" var="rankTitle"/>
		<display:column class="issueHandle" headerClass="skipColumn issueHandleHeader"/>
		<display:column class="rankTd" headerClass="rankTh" title="${rankTitle}">
			<span class="rank"></span>
		</display:column>
		<display:column class="ratingTd" headerClass="ratingTh extraInfoColumn"/>
	</c:if>

	<c:set var="columnDecoratorName" value="${not empty columnDecorator ? 'columnDecorator' : ''}" />

	<c:forEach items="${layoutList}" var="fieldLayout" varStatus="loopStatus">
		<spring:message var="label" code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
		<spring:message var="title" code="tracker.field.${fieldLayout.title}.label" text="${fieldLayout.title}"/>
		<c:set var="property" value="${fieldLayout.property}" />
		<c:set var="sortProperty" value="${fieldLayout.sortProperty}" />
		<c:set var="columnSortOrder" value="${fieldLayout.id eq PRIORITY_LABEL_ID ? 'descending' : 'ascending'}" />
		<c:set var="headerStyleClass" value="${fieldLayout.headerStyleClass}" />
		<c:set var="styleClass" value="${fieldLayout.styleClass}" />
		<c:set var="sortable" value="${empty param.revision and globalSortable}" />

		<c:set var="extraHeader" value="${fieldLayout.id eq NAME_LABEL_ID ? '' : 'column-minwidth' }"/>
		<c:choose>
			<c:when test="${!resizableColumns}">
				<c:set var="extraClass" value="${fieldLayout.id eq ID_LABEL_ID ? 'idColumn' : ''}${fieldLayout.table ? ' tableField' : ''} ${fieldLayout.id eq NAME_LABEL_ID or fieldLayout.wikiTextField or fieldLayout.subjectField or fieldLayout.isUserDefinedChoiceField() or fieldLayout.table ? '' : 'column-minwidth' } fieldColumn fieldId_${fieldLayout.id}"/>
			</c:when>
			<c:otherwise>
				<c:set var="extraClass" value="${fieldLayout.id eq ID_LABEL_ID ? 'idColumn' : ''}${fieldLayout.table ? ' tableField' : ''} fieldColumn fieldId_${fieldLayout.id}"/>
			</c:otherwise>
		</c:choose>
		<c:if test="${!empty fieldLayout.description}">
			<c:set var="title">
				<label title="<c:out value='${fieldLayout.description}'/>">${empty title ? label : title}</label>
			</c:set>
		</c:if>

		<%-- Html view --%>
		<c:set var="isName" value="${fieldLayout.id eq NAME_LABEL_ID}"/>
		<c:if test="${isName}">
			<c:if test="${!browseTrackerMode && !hideIconColumn}">
				<display:column class="column-minwidth bug-icon" media="html" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator"
					sortable="${sortable}" sortProperty="${sortProperty}" defaultorder="${columnSortOrder}"
				>
					<ui:coloredEntityIcon subject="${item}" iconUrlVar="iconUrl" iconBgColorVar="iconBgColor"/>
					<img style="background-color:${iconBgColor}; margin-left:4px;" src="<c:url value="${iconUrl}"/>">
				</display:column>
			</c:if>

			<c:if test="${showIndent or !empty htmlId}">
				<c:set var="extraHeader" value="indenter"/>
				<%-- An extra column for the tree view expander
				<display:column title="" property="indent" media="html" class="column-minwidth" />
				--%>
			</c:if>
		</c:if>

		<c:if test="${loopStatus.last}">
			<c:set var="styleClass" value="${styleClass} " />
		</c:if>
		<c:if test="${property == 'name'}">
			<c:set var="styleClass" value="${styleClass} " />
		</c:if>
		<c:if test="${property == 'submitter' || property == 'assignedTo' || property == 'modifier'}">
			<c:set var="styleClass" value="${styleClass} cutLongData" />
		</c:if>
		<c:if test="${property == 'assignedTo'}">
			<c:set var="styleClass" value="${styleClass} allowMultiLine" />
		</c:if>
		<c:if test="${fieldLayout.table}">
			<c:set var="sortable" value="false" />
		</c:if>

		<c:set var="percentageStyle">
			<c:if test="${resizableColumns}">width: ${percentages.get(loopStatus.index)}%</c:if>
		</c:set>

		<display:column title="${empty title ? label : title}" property="${property}" style="${percentageStyle}"
			headerClass="${headerStyleClass} ${extraHeader}" class="${styleClass} ${extraClass} columnSeparator" comparator="com.intland.codebeamer.persistence.util.DtoComparator"
			sortable="${sortable}" sortProperty="${sortProperty}" defaultorder="${columnSortOrder}" media="html" decorator="${columnDecoratorName}" />

		<c:if test="${browseTrackerMode && (fieldLayout.id eq menuFollowsField)}">
			<display:column sortable="false" class="column-minwidth menuTrigger" media="html">
				<%-- This menu does not make sense in baseline mode, which is read only. If we are not in baseline mode, then revision parameter is missing.--%>
				<c:if test="${empty param.revision}">
					<img class="menuArrowDown${alwaysDisplayContextMenuIcons eq 'true' ? ' always-display-context-menu' : ''}" src="<c:url value='/images/space.gif'/>"/>
					<span class="menu-container"></span>
				</c:if>
			</display:column>
		</c:if>

		<c:if test="${export}">
			<display:column title="${fieldLayout.labelWithoutBR}" property="${property}"
				headerClass="${headerStyleClass}" class="${styleClass} ${extraClass}"
				media="excel xml csv pdf rtf" />
		</c:if>

	</c:forEach>

	<c:if test="${extraColumn != null }">
		<spring:message var="label" code="${extraColumnLabel }"/>
		<display:column title="${label }" class="textSummaryData columnSeparator ${extraColumnClass}" headerClass="textSummaryData columnSeparator">
			${extraColumn[item] }
		</display:column>
	</c:if>

	<display:column title="Description" class="textData" media="excel xml csv pdf rtf" property="description" />
	<display:column title="Description Format" class="textData" media="excel xml csv pdf rtf" property="descriptionFormat" />

</display:table>
</div>

<c:if test="${selection and multiSelect}">
	<%-- hidden field to clear selection checkboxes, when none selected --%>
	<input type="hidden" name="${selectionFieldName}" value="-1" />
</c:if>

<c:if test="${!empty htmlId}">
	<spring:message var="showChildren" code="issue.children.show.tooltip" text="Show children" javaScriptEscape="true"/>
	<spring:message var="hideChildren" code="issue.children.hide.tooltip" text="Hide children" javaScriptEscape="true"/>

	<c:set var="sortChildren" value='<%=(items instanceof PaginatedList ? ((PaginatedList)items).getSortCriterion() : "")%>'/>
	<c:set var="dirChildren"  value='<%=(items instanceof PaginatedList ? ((PaginatedList)items).getSortDirection() : "desc")%>'/>

	<style type="text/css">
		div.summaryGroup {
			margin-left: 20px;
		}
		table.treetable span.indenter {
			height: 16px;
		}
	</style>
	<script type="text/javascript">
		(function($) {

		    var showItemChildren = ${hideItemChildrenHandler ? 'false' : 'true'};

			var alignSummaries = function () {
				$(".summaryGroup").each(function () {
					var $t = $(this);
					var $indenter = $t.prev(".indenter");
					var padding = parseInt($indenter.css("padding-left") ? $indenter.css("padding-left").replace("px", "") : "");
					if (padding > 0) {
						var left =  + 20;
						$t.css("margin-left", left + "px");
					}
				});
			};

			$(function() {

				var tc${htmlId} = ${selection ? 2 : 1} + ${treeTableIndicatorColumnIndex};

				if (showItemChildren) {
                    $("#${htmlId}").trackerItemTreeTable({
                        columnIndex : tc${htmlId},
                        expandString : "${showChildren}",
                        collapseString : "${hideChildren}",
                        loadByAjax : true,
                        ajaxUrl : "<c:url value='/trackers/ajax/getChildren.spr'/>",
                        ajaxAsync : false,
                        ajaxCache : false,
                        ajaxItemParamName : "parent",
                        ajaxData : {
                            columns     : "<c:forEach items='${layoutList}' var='field' varStatus='loop'>${field.id}<c:if test='${!loop.last}'>,</c:if></c:forEach>",
                            sort        : "<c:out value='${sortChildren}' />",
                            dir         : "${dirChildren}",
                            browse      : ${browseTrackerMode},
                            selection   : ${selection},
                            multiSelect : ${multiSelect},
                            selectName  : "${selectionFieldName}",
                            revision	: "${param.revision}"
                        },
                        onExpand : function() {
                            alignSummaries();
                        },
                        onCollapse : function() {
                            alignSummaries();
                        }
                    });
                }

				$("#${htmlId} td").on("click", ".menuArrowDown", function (event) {
					var $trigger = $(event.target).next(".menu-container");
					var forceOpenInNewWindow = '${forceOpenInNewWindow}' == 'true';
					var rowId = $trigger.closest("tr").attr("id");
					var id = rowId;
					var revision;

					if (!$.isNumeric(rowId)) {
						var parts = rowId.split("/");
						id = parts[0];
						revision = parts[1];
					}
					buildAjaxTransitionMenu($trigger, {
						'task_id': id,
						'cssClass': 'inlineActionMenu transition-action-menu',
						'builder': 'trackerTableTransitionMenuBuilder',
						'revision': revision,
						'forceOpenInNewWindow': forceOpenInNewWindow
					});
				});

				alignSummaries();

				var resizeableColumns = ${resizableColumns ? 'true' : 'false'};
				var disableResizeableColumns = ${disableResizableColumns ? 'true' : 'false'};
				setTimeout(function() {
					if (resizeableColumns && !disableResizeableColumns) {
						codebeamer.DisplaytagTrackerItemsResizeableColumns.init($("#${htmlId}"));
					}
				}, 1);

			});

			var inlineEdit = ${inlineEdit ? 'true' : 'false'};
			if (inlineEdit) {
			    codebeamer.DisplaytagTrackerItemsInlineEdit.init($("#${htmlId}"), {
					plannerMode : ${plannerMode ? 'true' : 'false'},
					buildTransitionMenu : ${inlineEditBuildTransitionMenu ? 'true' : 'false'},
					buildRelations: ${buildRelations ? 'true' : 'false'}
				});
            }

		})(jQuery);
	</script>

	<c:if test="${inlineEdit}">
		<wysiwyg:editorInline />
	</c:if>

</c:if>

