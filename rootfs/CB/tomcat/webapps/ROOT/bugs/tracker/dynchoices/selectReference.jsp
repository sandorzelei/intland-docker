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
 * $Revision$ $Date$
--%>
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="trackersModule"/>

<%--
	Popup page to select referenced object matching with the AssociationType
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@page import="com.intland.codebeamer.servlet.bugs.dynchoices.SelectReferenceController"%>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/search.css' />" type="text/css"/>

<style type="text/css">

.contentWithMargins {
	margin-top: 0 !important;
}

#referenceSelector {
	margin-bottom: 6px;
}

#referenceSelector th {
	padding-top: 1;
	padding-bottom: 1;
}

#referenceSelector td {
	padding-top: 1;
	padding-bottom: 0;
}

#referenceSelector tr {
	border-top: 0;
	padding-top: 1;
	padding-bottom: 0;
}

#filterPart {
	display: block;
	float: right;
}

#filterPart .helpLink {
	display: inline-block;
	width: 16px;
	height: 16px;
	background: url("../../images/newskin/action/help.png") center no-repeat;
	cursor: pointer;
	position: relative;
	top: 2px;
}

.unsetBox {
	padding: 10px 15px;
}

.inactive {
	color: #D1D1D1;
}

.referenceSettingAccordion {
	display: none;
}

.treeSearchBoxContainer {
	width: 200px;
}

.treeFilterBox {
	width: 166px !important;
}

.treeSearchToggleButton {
	border: 0;
}

.reportSummary {
	cursor: pointer;
}

.itemUrlLink {
	float: right;
	color: #d1d1d1 !important;
	font-weight: bold;
}

.itemUrlLink:hover {
	text-decoration: none !important;
	color: #0093b8 !important;
}


</style>

<c:set var="workItemMode" value="${command.workItemMode}" />

<spring:message var="refFldName" scope="request" code="tracker.field.${trackerLabel.label}.label" text="${trackerLabel.label}" htmlEscape="true"/>
<c:if test="${empty refFldName}">
	<spring:message var="itemLabel" code="tracker.type.Item" text="Item"/>
	<c:set var="refFldName" value="${itemLabel}"/>
</c:if>

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.references.choose.title" text="Choose {0}" arguments="${refFldName}"/></ui:pageTitle>
</ui:actionMenuBar>

<c:set var="DEBUG" value="false" />
<c:set var="showID" scope="request" value="true" />

<c:if test="${DEBUG}">
<c:set var="showID" scope="request" value="true" />

<pre class="debug">
	command: ${command}
</pre>
</c:if>

<form:form>
	<input type="hidden" id="filterMode" name="filterMode" value="true">
	<script>
		function removeFilterParamFromUrl() {
			var refFilterForm = $('#filterMode').parent();
			refFilterForm.attr("action", refFilterForm.attr("action").replace(/&?filter=([^&]$|[^&]*)/i, ""));
			refFilterForm.attr("action", refFilterForm.attr("action").replace(/&?page=([^&]$|[^&]*)/i, "&page=1"));
			refFilterForm.attr("action", refFilterForm.attr("action").replace(/&?filterMode=([^&]$|[^&]*)/i, ""));
		}
	</script>
	<spring:message var="clearButton" code="issue.references.clear.tooltip" text="Clear selection"/>

	<c:set var="actionBarContent">
		<spring:message var="setButton" code="button.set" text="Set"/>
		&nbsp;&nbsp;<input type="submit" class="button" name="setButton" value="${setButton}" onclick="removeFilterParamFromUrl();" />

		<%-- button allow resetting to default-value --%>
		<c:if test="${!empty command.setToDefaultLabel}">
			&nbsp;&nbsp;<input type="submit" class="button" name="<%=SelectReferenceController.BUTTON_RESET_TO_DEFAULT%>" value="<c:out value='${command.setToDefaultLabel}'/>" />
		</c:if>

		<c:if test="${! multiSelect}">
			<script type="text/javascript">
				function unselect() {
					$("#selectColumnTitle").click();
				}
			</script>
			&nbsp;&nbsp;<input type="button" class="button" name="_cancel" value="${clearButton}" onclick="unselect(); return false;" />
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close()" />

		<span id="filterPart" style="display:none;">
			<div class="treeSearchBoxContainer">
				<spring:message var="filterLabel" code="Filter" text="Filter"/>
				<div class="treeSearchContainer">
					<div class="treeSearchField">
						<input class="treeFilterBox withButton" type="text" id="filterInput" name="filter" autocomplete="off" value="${filter}" placeholder="${filterLabel}" style="${cssStyle}" title="${filterLabel}" />
						<button id="filterSearch" class="treeSearchToggleButton" type="submit" onclick="removeFilterParamFromUrl();"/>
					</div>
				</div>
			</div>
		</span>

		<c:if test="${DEBUG}">
			<span class="debug">
				&nbsp;&nbsp;<input type="submit" class="button" name="test" value="Test" title="Just a test submit button" />
			</span>
		</c:if>
	</c:set>
	<ui:actionBar>${actionBarContent}</ui:actionBar>

	<c:if test="${filterType == 9 && !workItemMode}">
		<div class="accordion">
			<h3 class="accordion-header"><spring:message code="reference.setting.title" text="Reference Settings"/></h3>
			<div class="referenceSettingAccordion accordion-content">
			<span class="baselineContainer">
				<spring:message code="reference.setting.baselines" text="Baselines"/>
				<select class="baselineSelector">
					<option value="NONE"<c:if test="${defaultReferenceVersionType eq 'NONE'}"> selected="selected"</c:if>><spring:message code="reference.setting.head" text="--"/></option>
					<option value="HEAD"<c:if test="${defaultReferenceVersionType eq 'HEAD'}"> selected="selected"</c:if>><spring:message code="reference.setting.current.head" text="Current HEAD"/></option>
					<c:forEach items="${baselines}" var="baseline">
						<c:if test="${baseline.id != null}">
							<option value="${baseline.id}">${baseline.name}</option>
						</c:if>
					</c:forEach>
				</select>
			</span>
			<span>
				<input id="propagateSuspectsCheckbox" type="checkbox"<c:if test="${defaultPropagateSuspects}"> checked="checked"</c:if>>
				<label for="propagateSuspectsCheckbox"><spring:message code="association.propagatingSuspects.label" text="Propagate suspects"/></label>
			</span>
			<span>
				<input id="reverseSuspectCheckbox" type="checkbox"<c:if test="${defaultReverseSuspect}"> checked="checked"</c:if>>
				<label for="reverseSuspectCheckbox"><spring:message code="reference.setting.reverse.suspect" text="Reverse direction"/></label>
			</span>
			<span>
				<input id="bidirectionalSuspectCheckbox" type="checkbox"<c:if test="${defaultBidirectionalSuspect}"> checked="checked"</c:if>>
				<label for="bidirectionalSuspectCheckbox"><spring:message code="reference.setting.bidirectional.suspect" text="Bidirectional suspect"/></label>
			</span>
			<span>
				<input id="propagateDependenciesCheckbox" type="checkbox"<c:if test="${defaultPropagateDependencies}"> checked="checked"</c:if>>
				<label for="propagateDependenciesCheckbox"><spring:message code="reference.setting.propagatingDependencies.label" text="Propagate unresolved dependencies"/></label>
			</span>
			</div>
		</div>
	</c:if>

	<c:if test="${not empty filter}">
		<div class="warning"><spring:message code="reference.setting.reference.selector.filter.string" arguments="${filter}"/></div>
	</c:if>

	<c:if test="${command.showUnset and filterType gt 0}">
		<div class="descriptionBox unsetBox">
			<input id="unsetOption" type="checkbox" name="searchItem" value="${command.unsetValue}" <c:if test="${command.unsetSelected}">checked="checked"</c:if>/>
			&nbsp;
			<label for="unsetOption"><c:out value="${unsetLabel}" /> / <spring:message code="tracker.view.op.unset" text="unset"/></label>
		</div>
	</c:if>

	<%-- include the search result will show all matches. the currently selected items are passed in "selectedItems" request var. --%>
	<c:set var="selectedItems" value="${command.selectedItemMap}" scope="request" />

	<%-- single or multi selection?, defined by the parameter: multipleSelection,
	put the checkbox or radio to check-all/clear-all into header --%>
	<c:choose>
		<c:when test="${multiSelect}">
			<c:set var="selectInputType" scope="request" value="checkbox" />
			<spring:message var="toggleButton" code="search.what.toggle"/>
			<c:set var="selectColumnTitle" scope="request">
				<input TYPE="CHECKBOX" TITLE="${toggleButton}" id="selectColumnTitle" NAME="SELECT_ALL" VALUE="on"
						ONCLICK="setAllStatesFrom(this, 'searchItem', new InSameTableClosure(this))"/>
			</c:set>
		</c:when>
		<c:otherwise>
			<c:set var="selectInputType" scope="request" value="radio" />
			<c:set var="selectColumnTitle" scope="request">
				<input type="radio" name='searchItem' title="${clearButton}" value="" id="selectColumnTitle" style="visibility: hidden;" />
			</c:set>
		</c:otherwise>
	</c:choose>

	<ui:displaytagPaging defaultPageSize="${pagesize}" items="${filterResult}" excludedParams="page"/>

	<div class="contentWithMargins">
	<c:choose>
		<c:when test="${filterType == 0}">
			<c:choose>
				<c:when test="${trackerLabel.languageField or trackerLabel.countryField}">
					<%-- Languages or Countries --%>
					<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="language" cellpadding="0" >
						<display:setProperty name="paging.banner.placement" value="none"/>

						<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
							<c:set var="selectionValue" value="${language.value}" />
							<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
								<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
							/>
							<input type="hidden" name="visibleItem" value="${selectionValue}" />
						</display:column>

						<c:if test="${showID}">
							<spring:message var="idTitle" code="tracker.choice.id.label" text="ID"/>
							<display:column title="${idTitle}" property="value" headerClass="keyIdTextData" class="keyIdTextData columnSeparator referenceSelectLessImportant" sortable="false" style="width:5%"/>
						</c:if>

						<spring:message var="nameTitle" code="${trackerLabel.languageField ? 'tracker.field.valueType.language.label' : 'tracker.field.valueType.country.label'}" text="Language"/>
						<display:column title="${nameTitle}" property="key" headerClass="textData" class="textSummaryData referenceSelectName" sortable="false"/>
					</display:table>
				</c:when>

				<c:otherwise>
					<%-- Choice options --%>
					<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="option" cellpadding="0">
						<display:setProperty name="paging.banner.placement" value="none"/>

						<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
							<c:set var="selectionValue" value="${option.key}" />
							<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
								<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
							/>
							<input type="hidden" name="visibleItem" value="${selectionValue}" />
						</display:column>

						<c:if test="${showID}">
							<spring:message var="idTitle" code="tracker.choice.id.label" text="ID"/>
							<display:column title="${idTitle}" headerClass="keyIdTextData" class="keyIdTextData columnSeparator referenceSelectLessImportant" sortable="false" style="width:5%">
								<c:out value="${option.value.id}" default="--" />
							</display:column>
						</c:if>

						<display:column title="${refFldName}" headerClass="textData" class="textSummaryData referenceSelectName" sortable="false">
							<label title="<c:out value='${option.value.description}'/>">
							<c:choose>
								<c:when test="${empty option.value.id}">
									<spring:message code="${option.value.name}" text="${option.value.name}"/>
								</c:when>
								<c:otherwise>
									<spring:message code="tracker.choice.${option.value.name}.label" text="${option.value.name}"/>
								</c:otherwise>
							</c:choose>
							</label>
						</display:column>
					</display:table>
				</c:otherwise>
			</c:choose>
		</c:when>

		<c:when test="${filterType == 1}"> <%-- Users --%>
			<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="user" cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.UserDecorator">
				<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.reference.choose.users" text="Users"/></display:setProperty>
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="selectionValue" value="1-${user.id}" />
					<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
						<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<spring:message var="accountTitle" code="user.account.label" text="Account"/>
				<display:column title="${accountTitle}" property="name" headerClass="textData" class="textData columnSeparator" sortable="true" />

				<spring:message var="realNameTitle" code="user.realName.label" text="Real Name"/>
				<display:column title="${realNameTitle}" property="realName" headerClass="textData" class="textData columnSeparator" sortable="true" />
			</display:table>
		</c:when>

		<c:when test="${filterType == 2}"> <%-- Projects --%>
			<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="project" cellpadding="0" decorator="com.intland.codebeamer.ui.view.table.ProjectDecorator">
				<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.reference.choose.projects" text="Projects"/></display:setProperty>
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="selectionValue" value="2-${project.id}" />
					<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
						<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<c:if test="${showID}">
					<spring:message var="projectId" code="project.id.label" text="Id"/>
					<display:column title="${projectId}" property="id" sortable="true" headerClass="textData" class="textData columnSeparator referenceSelectLessImportant" />
				</c:if>

				<spring:message var="projectName" code="project.name.label" text="Name"/>
				<display:column title="${projectName}" property="name" sortable="true" headerClass="textData" class="textData columnSeparator referenceSelectName" />

				<spring:message var="projectDescription" code="project.description.label" text="Description"/>
				<display:column title="${projectDescription}" property="description" headerClass="textDataWrap expandTable" class="textDataWrap columnSeparator" />

				<spring:message var="projectCategory" code="project.category.label" text="Category"/>
				<display:column title="${projectCategory}" property="category" sortable="true" headerClass="textData" class="textData" />
			</display:table>
		</c:when>

		<c:when test="${filterType == 3}"> <%-- Trackers --%>
			<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="tracker" cellpadding="0">
				<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.reference.choose.trackers" text="Projects"/></display:setProperty>
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="selectionValue" value="3-${tracker.id}" />
					<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
						<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<c:if test="${showID}">
					<spring:message var="trackerId" code="tracker.id.label" text="Id"/>
					<display:column title="${trackerId}" property="id" sortable="true" headerClass="textData" class="textData columnSeparator" />
				</c:if>

				<spring:message var="trackerName" code="tracker.name.label" text="Name"/>
				<display:column title="${trackerName}" property="name" sortable="true" headerClass="textData" class="textData columnSeparator"/>

				<spring:message var="trackerDescription" code="tracker.description.label" text="Description"/>
				<display:column title="${trackerDescription}" property="description" headerClass="textDataWrap expandTable" class="textDataWrap columnSeparator"/>

				<spring:message var="projectName" code="project.label" text="Project"/>
				<display:column title="${projectName}" property="project.name" sortable="true" headerClass="textData" class="textData"/>
			</display:table>
		</c:when>

		<c:when test="${filterType == 9}"> <%-- Tracker Items --%>
			<spring:message var="showChildren" code="issue.children.show.tooltip" text="Show children" javaScriptEscape="true"/>
			<spring:message var="hideChildren" code="issue.children.hide.tooltip" text="Hide children" javaScriptEscape="true"/>
			<c:set var="decorator" scope="request" value="<%=new com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator(request)%>"/>

			<jsp:include page="itemSelector.jsp"/>

			<c:if test="${showChildrenSelector}">
				<script type="text/javascript">
					(function($) {
						$(function() {

							var openSelectedIds = [];
							<c:forEach items="${expandPaths}" var="id">
							openSelectedIds.push(${id});
							</c:forEach>

							$("#itemSelector").trackerItemTreeTable({
								columnIndex :  ${showID ? 2 : 1},
								expandString : "${showChildren}",
								collapseString : "${hideChildren}",
								loadByAjax : true,
								ajaxUrl : "<c:url value='/trackers/ajax/childrenSelector.spr'/>",
								ajaxAsync : false,
								ajaxCache : false,
								ajaxItemParamName : "item_id",
								ajaxData : {
									tracker_id   : ${empty command.tracker_id ? '""' : command.tracker_id},
									field_id     : ${empty command.labelId ? '""' : command.labelId},
									showID       : ${showID},
									selectType   : "${selectInputType}",
									selectedItems: "<spring:escapeBody htmlEscape="true" javaScriptEscape="true">${command.selectedItems}</spring:escapeBody>"
								},
								autoExpandTrackerItemIds: openSelectedIds
							});

						});
					})(jQuery);
				</script>
			</c:if>

		</c:when>

		<c:when test="${filterType == 18}"> <%-- Repositories --%>
			<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="repository" cellpadding="0">
				<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.reference.choose.repositories" text="Projects"/></display:setProperty>
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="selectionValue" value="18-${repository.id}" />
					<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
						<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<c:if test="${showID}">
					<spring:message var="repositoryId" code="scm.repository.id.label" text="Id"/>
					<display:column title="${repositoryId}" property="id" sortable="true" headerClass="textData" class="textData columnSeparator" />
				</c:if>

				<spring:message var="repositoryName" code="project.administration.scm.managed.repository.name.label" text="Repository"/>
				<display:column title="${repositoryName}" property="name" sortable="true" headerClass="textData" class="textData columnSeparator"/>

				<spring:message var="projectName" code="project.label" text="Project"/>
				<display:column title="${projectName}" property="project.name" sortable="true" headerClass="textData" class="textData columnSeparator"/>

				<spring:message var="repositoryType" code="scm.repository.type.label" text="Type"/>
				<display:column title="${repositoryType}" headerClass="textData" class="textData">
					<spring:message code="scmtype.${repository.type}.displayname" text="${repository.type}"/>
				</display:column>
			</display:table>
		</c:when>

		<c:when test="${filterType == 5 && isReport}">
			<display:table htmlId="referenceSelector" requestURI="/proj/tracker/selectReference.spr" sort="external" name="${filterResult}" id="report" cellpadding="0">
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>
				<c:set var="selectionValue" value="${filterType}-${report.id}" />

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<input id="searchItem_${selectionValue}" type="${selectInputType}" name="searchItem" value="${selectionValue}"
						   <c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<spring:message code="report.label" var="reportLabel"/>
				<spring:message var="openLabel" code="tracker.openItems.label" text="Open"/>
				<display:column title="${reportLabel}" headerClass="textData" class="textSummaryData" sortable="true" sortProperty="REV.name">
					<a class="itemUrlLink" href="<c:url value="${report.urlLink}"></c:url>" target="_blank" title="${openLabel}">↗</a>
					<label class="reportSummary" for="searchItem_${selectionValue}">${report.shortDescription}</label>
				</display:column>

				<spring:message code="queries.type.label" var="typeLabel"/>
				<display:column title="${typeLabel}" headerClass="textData" class="textData" sortable="false">
					<c:choose>
						<c:when test="${report.owner == user}"><spring:message code="queries.private.label" text="own"/></c:when>
						<c:otherwise><spring:message code="queries.shared.label" text="shared"/></c:otherwise>
					</c:choose>
				</display:column>

				<spring:message code="tracker.field.Modified at.label" var="modifiedAtLabel"/>
				<display:column title="${modifiedAtLabel}" headerClass="textData" class="dateData columnSeparator" sortable="true" sortProperty="REV.created_at">
					<tag:formatDate value="${report.lastModifiedAt}"/>
				</display:column>
				<spring:message code="tracker.field.Modified by.label" var="modifiedByLabel"/>
				<display:column title="${modifiedByLabel}" headerClass="textData" class="textData columnSeparator" sortable="true" sortProperty="REV.created_by">
					<tag:userLink user_id="${report.lastModifiedBy.id}"/>
				</display:column>

			</display:table>
			<script type="text/javascript">
				$(function() {
					$("#referenceSelector th a").click(function() {
						var url = $(this).attr("href");
						var linkSortParam = getUrlParameter("sort", url);
						var currentSort = '${sort}';
						var currentDir = '${dir}';
						var updatedUrl = addParameterToUrl(url, "dir", currentSort === linkSortParam && currentDir === 'asc' ? 'desc' : 'asc');
						$(this).attr("href", updatedUrl);
						return true;
					});
				});
			</script>
		</c:when>

		<c:otherwise>
			<display:table htmlId="referenceSelector" requestURI="" sort="external" name="${filterResult}" id="value" cellpadding="0">
				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'top'}"/>

				<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:set var="selectionValue" value="${filterType}-${value.id}" />
					<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
						<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
					/>
					<input type="hidden" name="visibleItem" value="${selectionValue}" />
				</display:column>

				<c:if test="${showID}">
					<spring:message var="idTitle" code="issue.id.label" text="ID"/>
					<display:column title="${idTitle}" property="id" headerClass="keyIdTextData" class="keyIdTextData columnSeparator" sortable="true" style="width:5%"/>
				</c:if>

				<display:column title="${refFldName}" property="shortDescription" headerClass="textData" class="textSummaryData" sortable="true" />

			</display:table>
		</c:otherwise>
	</c:choose>
	</div>

</form:form>

<script type="text/javascript">
$(function() {
	// all displaytag tables are filterable
	var $displayTagTable = $('.displaytag');

	if ($displayTagTable.size() == 0) {
		$("#filterPart").hide();
	} else {
		$("#filterPart").show();
		setTimeout( function() { $("#filterInput").focus(); }, 100);
		$("#filterInput").keypress(function(e) {
			if (e.keyCode === 13) {
				e.preventDefault();
				e.stopPropagation();
				$("#filterSearch").click();
			}
		});
	}

	var $accordion = $('.accordion');
	$accordion.cbMultiAccordion({ active: -1 });

	$("#propagateSuspectsCheckbox").change(function() {
		var $this = $(this); 
		['reverseSuspectCheckbox', 'bidirectionalSuspectCheckbox'].forEach(function(id) {
			var $checkbox = $('#' + id),
				$label = $('label[for="' + id + '"]');
			
			if ($this.prop('checked')) {
				$label.removeClass('inactive');
				$checkbox.prop('disabled', false);
			} else {
				$label.addClass('inactive');
				$checkbox.prop('checked', false);
				$checkbox.prop('disabled', true);
			}
		});
		
		if ($this.prop('checked') && $('#propagateDependenciesCheckbox').prop('checked')) {
			$('#reverseSuspectCheckbox')
				.prop('disabled', true)
				.next()
				.addClass('inactive');
		}
	});

	$("#propagateSuspectsCheckbox").change();
	
	['reverseSuspectCheckbox', 'bidirectionalSuspectCheckbox'].forEach(function(id, index) {
		var $checkbox = $('#' + id),
			$otherCheckbox = $('#' + (index == 0 ? 'bidirectionalSuspectCheckbox' : 'reverseSuspectCheckbox'));
		
		$checkbox.on('change', function() {
			if ($checkbox.prop('checked')) {
				$otherCheckbox.prop('checked', false);
			}
		});
	});
	
	$('#propagateDependenciesCheckbox').on('change', function() {
		var $baselineContainer = $('.baselineContainer'),
			$reverseSuspectCheckbox = $('#reverseSuspectCheckbox'),
			$reverseSuspectLabel = $('label[for="reverseSuspectCheckbox"]'),
			isCheckboxOn = $(this).prop('checked') == true;
		
		$baselineContainer
			.toggleClass('inactive', isCheckboxOn)
			.find('select').prop('disabled', isCheckboxOn);
		
		$reverseSuspectLabel.toggleClass('inactive', isCheckboxOn)
		$reverseSuspectCheckbox.prop('disabled', isCheckboxOn);
		
		if (!isCheckboxOn) {
			$('#propagateSuspectsCheckbox').change();
		} else {
			$reverseSuspectCheckbox.prop('checked', false);
		}
	});

	$('input[name="resetToDefaultButton"]').click(function(e) {
		e.preventDefault();
		$("#filterMode").val("false");
		$("form").append("<input type='hidden' name='resetToDefaultButton' value='true' />")
		$("form").submit();
	});

	$('input[name="setButton"]').click(function(e) {
		e.preventDefault();
		$("#filterMode").val("false");

		<c:choose>
			<c:when test="${filterType == 9 && !workItemMode}">
				var $baselineSelector = $('.baselineSelector');
				var baselineId = $baselineSelector.prop('disabled') ? 'NONE' : $baselineSelector.val();
				var propagateSuspects = $("#propagateSuspectsCheckbox").prop("checked") ? "true" : "false";
				var reverseSuspect = $("#reverseSuspectCheckbox").prop("checked") ? "true" : "false";
				var bidirectionalSuspect = $('#bidirectionalSuspectCheckbox').prop('checked') ? 'true' : 'false';
				var propagateDependencies = $("#propagateDependenciesCheckbox").prop("checked") ? "true" : "false";
				// Rewrite IDs for according to the Reference Settings
				var selectedTrackerItemIds = [];
				$('input[name="searchItem"]').each(function() {
					if ($(this).prop("checked")) {
						selectedTrackerItemIds.push(parseInt($(this).attr("data-tracker-item-id"), 10));
					}
				});

				if (baselineId == "HEAD") {
					baselineId = 0;
				}

				ajaxBusyIndicator.showBusyPage();
				$.getJSON(contextPath + "/ajax/referenceSetting/getTrackerItemVersionByBaseline.spr", {
					baselineId: baselineId == "NONE" ? null : parseInt(baselineId, 10),
					trackerItemIdList: selectedTrackerItemIds.join(",")
				}).done(function(result) {
					var versionByItemId = result["versionByItemId"];
					for (var trackerItemId in versionByItemId) {
						var version = versionByItemId[trackerItemId];
						$('input[name="visibleItem"][data-tracker-item-id="' + trackerItemId + '"]').each(function() {
							$(this).val($(this).val() + "/" + version + "#0#" + propagateSuspects + "#false#" + reverseSuspect + '#' + bidirectionalSuspect + '#' + propagateDependencies + '#false');
						});
					}
					$('input[name="searchItem"]').each(function () {
						var $visibleItem = $('input[name="visibleItem"][data-tracker-item-id="' + $(this).attr("data-tracker-item-id") + '"]');
						if (!$(this).is("#unsetOption")) {
							$(this).val($visibleItem.val());
						}
					});
					$("form").submit();
				});
			</c:when>
			<c:otherwise>
				$("form").submit();
			</c:otherwise>
		</c:choose>

	});
	
	try {
		if (window.parent != window) {
			var inputId = UrlUtils.getParameter(window.location.href, 'selectedItemsWithJS');
			if (inputId) {
				var selectedItems = window.parent.$('#' + inputId).val();
				
				if (selectedItems) {
					var $selectedItemsInput = $('<input>', { name: 'selectedItems', type: 'hidden', value: selectedItems });
					$('form#command').append($selectedItemsInput);
				}
			}
		}
	} catch(e) {
		console.warn('Failed to set selected items!', e)		
	}
});
</script>
