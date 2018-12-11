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
</style>

<ui:actionMenuBar>
	<spring:message code="cmdb.version.stats.configuration.page.title" text="Tracker Item References configuration" />
</ui:actionMenuBar>

<form:form action="${submitUrl}" method="POST" target="_self">
	<div class="actionBar">
		<spring:message var="saveTitle" code="button.save" text="Save"/>
		<input type="submit" value="${saveTitle}" class="button">
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}"/>
	</div>
	<input type="hidden" id="excludedTrackerTypes" name="excludedTrackerTypes" value="">
	<div class="contentWithMargins">
		<h3><spring:message code="cmdb.version.stats.configuration.page.direction.label=" text="Reference Direction"/></h3>
		<div>
			<input id="incomingDirectionInput" name="directionInput" type="radio" value="INCOMING" <c:if test="${icomingRelationsEnabled}"> checked="checked"</c:if>>
			<label for="incomingDirectionInput"><spring:message code="cmdb.version.stats.configuration.page.direction.incoming" text="Incoming only"/></label>
			<input id="outgoingDirectionInput" name="directionInput" type="radio" value="OUTGOING"<c:if test="${outgoingRelationsEnabled}"> checked="checked"</c:if>>
			<label for="outgoingDirectionInput""><spring:message code="cmdb.version.stats.configuration.page.direction.outgoing" text="Outgoing only"/></label>
			<input id="bothDirectionInput" name="directionInput" type="radio" value="BOTH_WAY"<c:if test="${bothRelationDirectionsEnabled}"> checked="checked"</c:if>>
			<label for="bothDirectionInput"><spring:message code="cmdb.version.stats.configuration.page.direction.both" text="Incoming and Outgoing"/></label>
		</div>
		<h3><spring:message code="cmdb.version.stats.configuration.page.tracker.type" text="Tracker types"/></h3>
		<p><spring:message code="cmdb.version.stats.configuration.page.tracker.message"/></p>
		<table id="trackerTypes">
			<c:forEach var="trackerType" items="${availableTrackerTypes}">
				<tr>
					<td>
						<input data-tracker-type-id="${trackerType.id}" id="trackerType_${trackerType.id}" type="checkbox"<c:if test="${!excludedTrackerTypes.contains(trackerType.id.toString())}"> checked="checked"</c:if>>
					</td>
					<td>
						<label for="trackerType_${trackerType.id}">
							<spring:message code="tracker.type.${trackerType.name}.plural" text="${trackerType.name}"/>
						</label>
					</td>
				</tr>
			</c:forEach>
		</table>
	</div>
</form:form>

<script type="text/javascript">
	$(function() {

		var setExcludedTrackerTypes = function() {
			var excludedTrackerTypes = "";
			$("#trackerTypes input").each(function() {
				if (!$(this).is(':checked')) {
					excludedTrackerTypes += $(this).data("tracker-type-id") + ',';
				}
			});
			if (excludedTrackerTypes.length > 0) {
				excludedTrackerTypes = excludedTrackerTypes.slice(0, -1);
			}
			$('#excludedTrackerTypes').val(excludedTrackerTypes);
		};

		setExcludedTrackerTypes();

		$("form").submit(function() {
			setExcludedTrackerTypes();
		});

	});
</script>



