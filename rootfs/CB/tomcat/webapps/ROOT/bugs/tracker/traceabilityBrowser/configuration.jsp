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
--%>
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
	#trackerTypes td {
		padding: 0.2em;
	}
	span.actionBarSection {
		margin-right: 1.5em;
	}
</style>

<ui:actionMenuBar>
	<spring:message code="tracker.traceability.browser.configuration.label" text="Traceability Browser configuration" />
</ui:actionMenuBar>

<form:form action="${submitUrl}" method="POST" target="_top">
	<div class="actionBar">
		<spring:message var="saveTitle" code="button.save" text="Save"/>
		<input type="submit" value="${saveTitle}" class="button">
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}"/>
	</div>
	<input type="hidden" name="referer" value="${referer}">
	<input type="hidden" id="excludedTrackerTypeIds" name="excludedTrackerTypeIds" value="">
	<input type="hidden" id="showHiddenTrackers" name="showHiddenTrackers" value="false">
	<input type="hidden" id="showSuggestions" name="showSuggestions" value="true">
	<div class="contentWithMargins">
		<h3><spring:message code="tracker.traceability.browser.tracker.types" text="Tracker types"/></h3>
		<p><spring:message code="tracker.traceability.browser.tracker.type.select"/></p>
		<table id="trackerTypes">
			<c:forEach var="trackerType" items="${availableTrackerTypes}">
				<tr>
					<td>
						<input data-tracker-type-id="${trackerType.id}" id="trackerType_${trackerType.id}" type="checkbox"<c:if test="${!excludedTrackerTypeIds.contains(trackerType.id.toString())}"> checked="checked"</c:if>>
					</td>
					<td>
						<label for="trackerType_${trackerType.id}">
							<c:choose>
								<c:when test="${trackerType.id == commitTypeId}">
									<spring:message code="SCM commits" text="SCM Commits"/>
								</c:when>
								<c:otherwise>
									<spring:message code="tracker.type.${trackerType.name}.plural" text="${trackerType.name}"/>
								</c:otherwise>
							</c:choose>
						</label>
					</td>
				</tr>
			</c:forEach>
		</table>
		<h3><spring:message code="tracker.traceability.browser.other.settings.title" text="Other settings"/></h3>
		<div>
			<input id="showHiddenTrackersInput" type="checkbox"<c:if test="${showHiddenTrackers}"> checked="checked"</c:if>><label class="showHiddenTrackers" for="showHiddenTrackersInput"><spring:message code="tracker.traceability.browser.show.hidden.trackers.info"/></label>
			<input id="showSuggestionsInput" type="checkbox"<c:if test="${showSuggestions}"> checked="checked"</c:if>><label class="showHiddenTrackers" for="showSuggestionsInput"><spring:message code="tracker.traceability.browser.show.suggestions"/></label>
		</div>
	</div>
</form:form>

<script type="text/javascript">
	$(function() {

		var hiddenTrackersCheckbox = $('#showHiddenTrackersInput');
		var showSuggestionsCheckbox = $('#showSuggestionsInput');

		var setDependencyType = function() {
			$("#showHiddenTrackers").val(hiddenTrackersCheckbox.is(':checked'));
			$("#showSuggestions").val(showSuggestionsCheckbox.is(':checked'));
		};

		var setExcludedTrackerTypeIds = function() {
			var excludedTrackerTypes = "";
			$("#trackerTypes input").each(function() {
				if (!$(this).is(':checked')) {
					excludedTrackerTypes += $(this).data("tracker-type-id") + ',';
				}
			});
			if (excludedTrackerTypes.length > 0) {
				excludedTrackerTypes = excludedTrackerTypes.slice(0, -1);
			}
			$('#excludedTrackerTypeIds').val(excludedTrackerTypes);
		};

		setExcludedTrackerTypeIds();

		$("form").submit(function() {
			setDependencyType();
			setExcludedTrackerTypeIds();
		});

	});
</script>

