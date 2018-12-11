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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ attribute name="jsVariable" required="true" description="The name of the js variable that will contain the controller object" %>
<%@ attribute name="treeUrl" required="true" description="The url that can be used for populating the tree" %>
<%@ attribute name="treePopulatorFn" required="true" description="The name of the javascript function that will be used to produce the request parameters sent to treeUrl" %>
<%@ attribute name="exclude" required="false" rtexprvalue="true" description="the ids of the issues that must not be listed on the history tab" %>
<%@ attribute name="disableTree" required="false" %>
<%@ attribute name="disableSearch" required="false"%>
<%@ attribute name="disableHistory" required="false"%>
<%@ attribute name="enableExternalUrls" required="false" %>
<%@ attribute name="externalUrlItems" required="false" type="java.util.Collection" description="A collection of URLs to set as URL input field values" %>
<%@ attribute name="selectedHistoryValues" required="false" rtexprvalue="true" type="java.util.Collection" description="A collection of typeId-entityTypeId strings that tells which history items must be selected" %>
<%@ attribute name="disableTreeMultipleSelection" required="false"%>
<%@ attribute name="onlyTopLevel" required="false" description="if true, then only the top level nodes are shown in the tree" %>
<%@ attribute name="treeVariableName" required="false" rtexprvalue="true" description="The nem of the js variable of the tree. If you have multiple trees on the same page you must specify this parameter" %>
<%@ attribute name="treePaneTitle" required="false" rtexprvalue="true" %>
<%@ attribute name="hideHeader" required="false" %>
<%@ attribute name="treeHeight" required="false" %>
<%@ attribute name="showTreeSearchBox" required="false" description="If true, the search box above the tree will be shown" %>
<%@ attribute name="initTreeOnPageLoad" required="false" %>
<%@ attribute name="selectorClickHandler" required="false" %>

<%@ tag import="java.util.Collection" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/search.css' />" type="text/css"/>
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/historyList.css' />" type="text/css"/>
<script src="<ui:urlversioned value="/js/historyList.js" />"></script>
<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.history.initializeHistoryList('#history_item');
	});
</script>

<c:if test="${empty treeHeight}">
	<c:set var="treeHeight" value="300px"/>
</c:if>

<c:if test="${empty initTreeOnPageLoad}">
	<c:set var="initTreeOnPageLoad" value="true"/>
</c:if>

<c:if test="${!hideHeader}">
	<span class="titlenormal"><spring:message code="association.to.choice.label" text="&nbsp;Select Artifacts&nbsp;"/></span>
</c:if>

<c:set var="historyTab" value="historyTab"></c:set>
<c:set var="searchTab" value="searchTab"></c:set>
<c:set var="treeTab" value="treeTab"></c:set>

<tab:tabContainer id="association" skin="cb-box">

	<c:if test="${empty disableHistory || !disableHistory}">
		<spring:message var="targetHistory" code="association.to.choice.history" text="From History"/>
		<tab:tabPane id="${historyTab}" tabTitle="${targetHistory}">

			<div style="text-align: right;margin-top:5px;">
				<input type="text" autocomplete="off" name="filterInput" id="filterInput" value="" maxlength="30" size="30" />
			</div>

			<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
			<c:set var="checkAll">
				<input type="checkbox" title="${toggleButton}" name="select_all" value="on"	onclick="setAllStatesFrom(this, 'historyItem')">
			</c:set>

			<tag:history var="history" command="list" excludeId="${exclude}" />

			<display:table name="${history}" id="history_item" requestURI="${requestURI}" cellpadding="0" defaultsort="4" defaultorder="descending" >
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />

				<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="checkboxId" value="historyItem_${history_item_rowNum}" />
					<c:set var="checkboxValue" value="${history_item.typeId}-${history_item.entityId}" />
					<%
						Collection<String> selectedValues = (Collection<String>) request.getAttribute("selectedHistoryValues");
						String value = (String) jspContext.getAttribute("checkboxValue");
						jspContext.setAttribute("isChecked", selectedValues != null && selectedValues.contains(value));
					%>
					<input type="checkbox" name="historyItem" class="historyItemSelector" id="${checkboxId}" value="${checkboxValue}" ${isChecked ? 'checked="checked"' : ''} />
				</display:column>

				<display:column class="textDataWrap iconWithLink">
					<label for="${checkboxId}">
						<ui:wikiLink item="${history_item.dto}" hideBadges="${true}" showItemName="${false}"/>
					</label>
				</display:column>

				<spring:message var="objectShortDescription" code="user.history.shortDescription.label" text="Artifact"/>
				<display:column title="${objectShortDescription}" sortProperty="shortDescription" sortable="true" headerClass="textData" class="textDataWrap columnSeparator">
					<label for="${checkboxId}">
						<c:choose>
							<c:when test="${not empty history_item.shortDescription}">
								<c:out value="${history_item.shortDescription}" />
							</c:when>
							<c:otherwise>
								<spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]"/>
							</c:otherwise>
						</c:choose>
					</label>
				</display:column>

				<spring:message var="objectAccessDate" code="user.history.date.label" text="Date"/>
				<display:column title="${objectAccessDate}" sortProperty="date" sortable="true"
					headerClass="textData" class="textData columnSeparator">
					<tag:formatDate value="${history_item.date}" />
				</display:column>

			</display:table>

		</tab:tabPane>
	</c:if>

	<c:if test="${empty disableSearch || !disableSearch}">
		<spring:message var="targetSearch" code="association.to.choice.search" text="From Search"/>
		<tab:tabPane id="${searchTab}" tabTitle="${targetSearch}">
			<c:set var="matches" value="${searchResults.hitCount}" />

			<%-- TODO: compute the correct requestURI --%>
			<c:set var="requestURI" value="/proj/addAssociationDialog.do?method=search" />

			<%-- search filters --%>
			<%-- The search controller's form bean is bound to "searchForm" command bean,
				so to make the spring form tags work we need to wrap them with a nestedPath, tells the tags what is the form name. --%>
			<spring:nestedPath path="searchForm">
				<jsp:include page="/search/includes/filter.jsp" flush="false">
					<jsp:param name="associationMode" value="true" />
				</jsp:include>
			</spring:nestedPath>

			<%--
				displaying results
				div added to show scrollbar when necessary
			--%>
			<div id="searchResultsContainer">
				<c:choose>
					<c:when test="${matches gt 0}">
						<span class="titlenormal"><spring:message code="association.to.choice.search.title" text="&nbsp;Add Associations&nbsp;"/></span>
						<jsp:include page="/search/results.jsp?showAssoc=true&advanced=true&requestURI=${requestURI}" flush="true" />
					</c:when>
					<c:otherwise>
						<spring:message code="association.to.choice.search.empty" text="No matching found"/>
					</c:otherwise>
				</c:choose>
			</div>
		</tab:tabPane>
	</c:if>

	<c:if test="${enableExternalUrls}">
		<spring:message var="targetUrl" code="association.to.choice.url" text="URL"/>
		<tab:tabPane id="association-url" tabTitle="${targetUrl}">
			<table border="0" class="formTableWithSpacing" cellpadding="2">
				<c:forEach items="${externalUrlItems}" var="urlItem" varStatus="status">
				<tr>
					<td nowrap>&nbsp;<spring:message code="association.to.choice.url.label" text="URL-{0}" arguments="${status.count}"/>:&nbsp;</td>
					<td><input type="text" autocomplete="off" name="urlItems[${status.index}]" id="filterInput" value="<c:out value='${urlItem}'/>" size="80" maxlength="4000"/></td>
				</tr>
				</c:forEach>
			</table>
		</tab:tabPane>
	</c:if>

	<c:if test="${empty disableTree || !disableTree}">
		<c:if test="${empty treePaneTitle}">
			<spring:message var="treePaneTitle" code="association.to.choice.browse" text="Browse trackers"/>
		</c:if>
		<tab:tabPane id="${treeTab}${treeVariableName}" tabTitle="${treePaneTitle}">
			<input type="hidden" name="treeItems" id ="treeItems"/>
			<script type="text/javascript">
				var nodeSelected = function (node, data) {
					var selected = $.jstree.reference("#artifactSelectorTreePane_${treeVariableName}").get_selected();
					var a = [];
					for (var i = 0; i < selected.length; i++) {
						a.push($(selected[i]).attr("typeid") + "-" + selected[i]["id"]);
					}
					$("input[name=treeItems]").attr("value", a.join());
					<c:if test="${not empty selectorClickHandler}">
						${selectorClickHandler}(node, data);
					</c:if>
				};
			</script>
			<ui:treeControl editable="false" url="${treeUrl}" containerId="artifactSelectorTreePane_${treeVariableName}" populateFnName="${treePopulatorFn}"
				nodeClickedHandler="nodeSelected" disableMultipleSelection="${disableTreeMultipleSelection}"
				onlyTopLevel="${onlyTopLevel}" treeVariableName="${treeVariableName}" disableTreeCookies="true" initTreeOnPageLoad="${initTreeOnPageLoad}"/>
			<c:if test="${showTreeSearchBox}">
				<div id="treeSearchDiv">
					<ui:treeFilterBox treeId="artifactSelectorTreePane_${treeVariableName}" minFilterLength="3"/>
				</div>
			</c:if>
			<div id="artifactSelectorTreePane_${treeVariableName}" style="height:${treeHeight};overflow:auto;"></div>
			<c:if test="${initTreeOnPageLoad}">
				<script type="text/javascript">
					<c:choose>
						<c:when test="${not empty treeVariableName}">
							${treeVariableName}.init();
						</c:when>
						<c:otherwise>
							tree.init();
						</c:otherwise>
					</c:choose>
				</script>
			</c:if>
			<br/>
		</tab:tabPane>
	</c:if>
</tab:tabContainer>

<script type="text/javascript">
	var ${jsVariable} = ${jsVariable} || {};
	${jsVariable}.getSelectedIds = function() {
		var $focused = $(".ditch-focused");
		var id = $focused.attr("id");
		if (id === "${historyTab}-tab") {
			return $("input[name=historyItem]:checked").map(function (i, o) {
				return o["value"];
			});
		} else if (id === "${searchTab}-tab") {
			return $("input[name=searchItem]:checked").map(function (i, o) {
				return o["value"];
			});
		} else {
			var $t = $.jstree.reference("#artifactSelectorTreePane_${treeVariableName}");
			if ($t) {
				return $t.get_selected().map(function (i,o) {
					return $(o).attr("typeid") + "-" + o["id"];
				});
			}
		}

		return [];
	};

	<c:if test="${showTreeSearchBox}">
		$("#${treeTab}${treeVariableName}").height($("#artifactSelectorTreePane_${treeVariableName}").height() + 20);
	</c:if>
	<c:if test="${!showTreeSearchBox}">
		$("#${treeTab}${treeVariableName}").height($("#artifactSelectorTreePane_${treeVariableName}").height());
	</c:if>

	jQuery(function($) {
		$(".itemUrl").click(function(e) {
			e.preventDefault();
			e.stopPropagation();
			// Enable / disable linked checkbox
			$(e.currentTarget).parents('label').click();
		});
	});
</script>
