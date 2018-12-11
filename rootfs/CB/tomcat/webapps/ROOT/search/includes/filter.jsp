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

<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="java.util.Map"%>
<%@ page import="com.intland.codebeamer.controller.form.SearchForm"%>

<%-- JSP fragment contains the advanced filter fields only --%>

<script type="text/javascript" src="<ui:urlversioned value='/js/toolbar-search-box.js' />"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/filter.js' />"></script>

<%
	boolean associationMode = "true".equals(request.getParameter("associationMode"));
	Map searchCheckboxes = (Map)request.getAttribute("searchCheckboxes");
	if (associationMode) {
		// association currently can not be created for these, so removing checkboxes
		//searchCheckboxes.remove("Accounts");
		//searchCheckboxes.remove("Projects");
		searchCheckboxes.remove("Source commits");
		searchCheckboxes.remove("Tags");
	}
%>

<c:set var="showSearchCheckboxes" value="true" />
<c:set var="workingSetsCount" value="${fn:length(availableWorkingSets)}" />

<c:if test="${not empty param.showSearchCheckboxes}">
	<c:set var="showSearchCheckboxes" value="${param.showSearchCheckboxes}"/>
</c:if>

<form:hidden path="advanced" />

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/toolbar-search-box.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/filter.less' />" type="text/css" media="all" />

<script type="text/javascript">

	function selectAll(element) {
		setAllStatesFrom(element, 'searchOnArtifact');
		triggerTrackerSearchboxChange();
	}
	function triggerTrackerSearchboxChange() {
		var $trackerCheckbox = $(".searchOnArtifactCheckbox input[value=4]");
		$trackerCheckbox.trigger("change");
	}
</script>

<table border="0" class="formTableWithSpacing" id="advancedFilter">

<tr>
	<td width="200" class="optional"><spring:message code="search.for" text="Search for"/>:</td>

	<td>
		<spring:message var="searchTitle" code="search.title" text="Enter Full Text Search Pattern"/>
		<spring:message var="searchSubmit" code="search.submit.label" text="GO"/>
		<spring:message var="searchSubmitTitle" code="search.submit.tooltip" text="Start Search"/>

		<form:input path="filter" title="${searchTitle}" maxlength="80"
			id="searchFilterPattern" onkeypress="return submitOnEnter(this,event)" autocomplete="true" />

		<input type="submit" class="button" name="${param.associationMode ? 'FROM_SEARCH' : '' }" title="${searchSubmitTitle}" value="${searchSubmit}">
		<br><form:errors path="filter" cssClass="invalidfield"/>
	</td>
</tr>

<tr>
	<td width="200" class="optional"><spring:message code="search.syntax.label" text="Syntax"/>:</td>

	<spring:message var="searchSyntaxTitle" code="search.syntax.tooltip" text="Turn on to use Lucene's query syntax as described in help"/>

	<td title="${searchSyntaxTitle}">
		<form:checkbox id="luceneQuery" path="luceneQuery" title="${searchSyntaxTitle}" />
		<label for="luceneQuery"><spring:message code="search.syntax.allowed" text="Allow query syntax"/></label>
		<spring:message var="syntaxHelpTitle" code="search.syntax.help" text="Syntax help"/>
		<ui:helpLink cssStyle="margin-left:10px;" helpURL="/help/search.do" title="${syntaxHelpTitle}" />
	</td>
</tr>

<tr>
	<td width="200" class="optional"><spring:message code="search.fuzzy.label" text="Approximate matches"/>:</td>

	<spring:message var="searchFuzzyTitle" code="search.fuzzy.tooltip" text="Finds approximate matches as described in help"/>

	<td title="${searchFuzzyTitle}" >
		<form:checkbox id="fuzzySearch" path="fuzzySearch" title="${searchFuzzyTitle}" />
		<label for="fuzzySearch"><spring:message code="search.fuzzy.allowed" text="Find approximate matches"/></label>
	</td>
</tr>

<tr>
	<td width="200" class="optional"><spring:message code="search.extended.label" text="Extended search"/>:</td>

	<spring:message var="extendedSearchTitle" code="search.extended.tooltip" text="Search by every word individually"/>

	<td title="${extendedSearchTitle}" >
		<form:checkbox id="extendedSearch" path="extendedSearch" title="${extendedSearchTitle}" />
		<label for="extendedSearch">${extendedSearchTitle}</label>
	</td>
</tr>

<tr>
	<td width="200" class="optional" style="height: 21px"><spring:message code="Projects" text="Projects"/>:</td>

	<td>
		<form:select path="projIdList" multiple="true" id="searchPageProjectSelector" size="1">
		</form:select>
		<input id="selectedProjectIds" type="hidden" name="projId">
	</td>
</tr>

<c:if test="${showSearchCheckboxes}">
	<tr valign="top">
		<td class="optional" style="vertical-align: top;"><spring:message code="search.what.label" text="In Contents"/>:</td>

		<td class="artifactSearchFilters">
			<div style="border-bottom: solid 1px #f5f5f5; padding-bottom: 10px; margin-bottom: 10px;">
				<spring:message var="searchScopeToggle" code="search.what.toggle" text="Select/Clear All"/>
				<form:checkbox path="selectAll" id="selectAll" title="${searchScopeToggle}" onclick="setAllStatesFrom(this, 'searchOnArtifact'); triggerTrackerSearchboxChange();" />
				<label for="selectAll"><c:out value="${searchScopeToggle}"/></label>
			</div>

			<c:forEach var="checkbox" varStatus="forStatus" items="${searchCheckboxes}">
				<spring:message var="searchArtifactLabel" code="${checkbox.key}" text="${checkbox.key}"/>
				<spring:message var="searchArtifactTitle" code="${checkbox.key}.tooltip" text="${searchArtifactLabel}"/>

				<c:set var="extraClass" value="${extraClasses[checkbox.value]}" />
				<div class="searchOnArtifactCheckbox <c:if test="${not empty extraClass}">${extraClass}</c:if>" title="${searchArtifactTitle}">
					<form:checkbox path="searchOnArtifact" id="searchOnArtifact${forStatus.index}" value="${checkbox.value}" />
					<label for="searchOnArtifact${forStatus.index}">
						<c:set var="imgurl" value="${searchIcons[checkbox.key]}" />
						<c:if test="${! empty imgurl}">
							<img src="<c:url value='${imgurl}'/>"></img>
						</c:if>
						${searchArtifactLabel}
					</label>
				</div>
				<c:if test="${(forStatus.count) % 3 == 0}">
					<div style="clear:both;"></div>
				</c:if>
			</c:forEach>
			<div style="clear:both;"></div>
		</td>
	</tr>
</c:if>

<tr>
	<td class="optional"><spring:message code="search.owner.label" text="Owner/Submitter"/>:</td>

	<td>
		<spring:message var="objectOwnerTitle" code="search.owner.tooltip" text="User pattern such as: name, company, email, address, phone ..."/>
		<form:input path="ownerPattern" title="${objectOwnerTitle}"	maxlength="80" id="ownerPattern" />
		<br/><form:errors path="ownerPattern" cssClass="invalidfield"/>
	</td>
</tr>

<tr>
	<spring:message var="searchCreatedAtTitle" code="search.createdAt.tooltip" text="Only find objects created in this period"/>
	<td class="optional" title="${searchCreatedAtTitle}"><spring:message code="search.createdAt.label" text="Created/Submitted"/>:</td>

	<td class="durationFilters">
		<ui:duration property="createdAtDuration" value="${searchForm.createdAtDuration}" allowFutureDuration="false">
			<spring:message code="duration.after.label" text="After"/>:
			<form:input path="createdAtFrom" size="12" maxlength="30" id="createdAtFrom" />
			<ui:calendarPopup textFieldId="createdAtFrom" otherFieldId="createdAtTo"/>

			<spring:message code="duration.before.label" text="Before"/>:
			<form:input path="createdAtTo" size="12" maxlength="30" id="createdAtTo" />
			<ui:calendarPopup textFieldId="createdAtTo" otherFieldId="createdAtFrom"/>
		</ui:duration>
		<form:errors path="createdAtDuration" cssClass="invalidfield"/>
	</td>
</tr>

<tr>
	<spring:message var="searchModifiedAtTitle" code="search.modifiedAt.tooltip" text="Only find objects created or last modified in this period"/>
	<td class="optional" title="${searchModifiedAtTitle}"><spring:message code="search.modifiedAt.label" text="Modified"/>:</td>

	<td class="durationFilters">
		<ui:duration property="lastModifiedAtDuration" value="${searchForm.lastModifiedAtDuration}" allowFutureDuration="false">
			<spring:message code="duration.after.label" text="After"/>:
			<form:input path="lastModifiedAtFrom" size="12" maxlength="30" id="lastModifiedAtFrom" />
			<ui:calendarPopup textFieldId="lastModifiedAtFrom" otherFieldId="lastModifiedAtTo"/>

			<spring:message code="duration.before.label" text="Before"/>:
			<form:input path="lastModifiedAtTo" size="12" maxlength="30" id="lastModifiedAtTo" />
			<ui:calendarPopup textFieldId="lastModifiedAtTo" otherFieldId="lastModifiedAtFrom"/>
		</ui:duration>
		<form:errors path="lastModifiedAtDuration" cssClass="invalidfield"/>
	</td>
</tr>

<c:if test="${workingSetsCount != 0}">
<tr valign="top">
	<td class="optional" style="vertical-align: top;"><spring:message code="search.scope.label" text="Search In"/>:</td>
	<td>
		<spring:message var="workingSetsLabel" code="Working Sets" text="Working Sets"/>
		<ui:collapsingBorder label="${workingSetsLabel} (${workingSetsCount})" cssClass="separatorLikeCollapsingBorder workingSetBox" open="false">
			<div class="projectOrWorkingsetList">
				<label for="searchInWorkingSet">
					<form:radiobutton path="searchIn" value="<%=SearchForm.SEARCH_IN_WORKING_SETS%>" id="searchInWorkingSet" style="display: none"/>
				</label>
				<form:select path="wsId" id="wsId" multiple="true" cssClass="fixMiddleSelectWidth" onchange="workingSetChangeHandler(this); return true;">
					<option value="-1"><spring:message code="workingset.none.label" text="None"/></option>
					<form:options items="${availableWorkingSets}" itemValue="id" itemLabel="name"/>
				</form:select>
			</div>
		</ui:collapsingBorder>
	</td>
</tr>
</c:if>

<form:hidden path="fromSearchPlugin" id="fromSearchPlugin" value="false"></form:hidden>

</table>

<script type="text/javascript">
	jQuery(function() {
		codebeamer.toolbar.initCombinedListElement('.artifactSearchFilters');

		// disable the commit and attachment search when searching on tracker items is not selected
		var $trackerCheckbox = $(".searchOnArtifactCheckbox input[value=4]");
		$trackerCheckbox.change(function () {
			var checked = $(this).is(':checked');

			$(".searchOnArtifactCheckbox input[value=32]").prop("disabled", !checked);
			$(".searchOnArtifactCheckbox input[value=1024]").prop("disabled", !checked);
		});

		triggerTrackerSearchboxChange();
	});

	function workingSetChangeHandler(select) {
        document.getElementById('searchInWorkingSet').checked='true';

        var $select = $(select);
        var value = $select.val();

        // when the None option is selected deselect all the other options
        if (value.indexOf("-1") >= 0) {
            // deselect the other options
            for(var i = 0; i < select.options.length; i++) {
                var element = select.options[i];

                if (element.value != "-1") {
                    element.selected = false;
                }
            }
		}
	}
</script>
