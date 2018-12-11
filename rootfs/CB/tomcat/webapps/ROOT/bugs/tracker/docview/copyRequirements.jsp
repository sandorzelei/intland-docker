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
	this is a popup that is displayed after a user drops a requirement from the requirement library to the left tree.
	on this dialog the user can decide if he wants to copy also the test cases of the requirement and from which baseline
	wants to create the copies.
--%>
<meta name="decorator" content="popup"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script src="<ui:urlversioned value='/js/itemLinking.js' />"></script>

<style type="text/css">
	label {
		font-weight: bold;
		padding-right: 10px;
	}

	#testCaseTrackerSelector {
		padding-bottom: 12px;
	}
</style>

<c:set var="targetName"><c:out value="${tracker.name }" escapeXml="true"/></c:set>

<ui:actionMenuBar >
	<ui:pageTitle>
		<spring:message code="tracker.view.layout.document.copy.page.title" text="Copying items to ${targetName }" arguments="${targetName }"/>
	</ui:pageTitle>
</ui:actionMenuBar>

<spring:message code="review.baselines.head.label" var="headLabel" text="HEAD"></spring:message>

<form:form commandName="command" method="post">
	<form:hidden path="parentId"/>
	<form:hidden path="trackerId"/>

	<div class="actionBar">
		<spring:message var="saveText" code="button.save" />
		<spring:message var="cancelText" code="button.cancel" />
		<input type="submit" class="button" value="${saveText}" />
		<a href="#" onclick="parent.refreshTrees(); closePopupInline(); return false;" class="cancelButton">${cancelText}</a>
	</div>

	<div class="contentWithMargins">
		<c:set var="copyCount" value="${fn:length(copiedItems) }"/>
		<c:url value="${tracker.urlLink }" var="trackerUrl"/>
		<c:url value="${tracker.name }" var="trackerName"/>

		<div class="information">
			<spring:message code="${copyCount == 1 ? 'tracker.view.layout.document.copy.hint' : 'tracker.view.layout.document.copy.hint.plural' }"
					arguments="${copyCount },${trackerUrl }, ${trackerName } "/><br/>
			<a href="#" onclick="$(this).next().show(); $(this).hide(); return false;">
				<spring:message code="tracker.view.layout.document.linking.show.items.label" text="Show Items"/>
			</a>
			<div style="display:none;">
				<c:forEach items="${copiedItems }" var="item" varStatus="status">
					<ui:itemLink item="${item }"></ui:itemLink>
					<c:if test="${!status.last }">, </c:if>
				</c:forEach>
			</div>
		</div>
		<c:if test="${not empty sourceTrackerBaselines }">
			<div class="form-element">
				<label>
					<spring:message code="baseline.label" text="Baseline"/>:
				</label>
				<span class="hint" style="width: 51%">
					<spring:message code="ttracker.view.layout.document.copy.baseline.hint"
						text="If you select a baseline for a tracker then the items from that tracker will be copied based on the selected baseline"/>				</span>
				<c:forEach items="${sourceTrackerBaselines }" var="entry">
					<p>
						<c:out value="${entry.key.name }"></c:out>:
						<select name="baselineIds[${entry.key.id }]">
							<option value="-1">${headLabel }</option>
							<c:forEach items="${entry.value }" var="baseline">
								<option value="${baseline.id }"><c:out value="${baseline.name }"/></option>
							</c:forEach>
						</select>
					</p>
				</c:forEach>
			</div>
		</c:if>

		<c:if test="${tracker.testCase }">
			<%-- when copying test cases we show an extra action: if the user want to copy the verifies field as well --%>
			<div class="form-element">
				<input type="checkbox" name="copyVerifiesField" id="copyVerifiesField"/>
				<label for="copyVerifiesField">
					<spring:message code="tracker.view.layout.document.copy.verifies.label" text="Copy Verifies field"></spring:message>
				</label>
				<span class="hint" style="display: inline-block;">
					<spring:message code="tracker.view.layout.document.copy.verifies.hint"></spring:message>
				</span>
			</div>
		</c:if>
		<div id="requirement-field-mapping">

		</div>

		<c:if test="${not tracker.testCase and not empty testCases and empty testCaseTrackersByProject }">
			<div class="warning">
				<spring:message code="tracker.view.layout.document.copy.test.cases.no.tracker"
					text="The Test Cases cannot be copied because there is no Test Case tracker configured to reference this tracker"/>
			</div>
		</c:if>
		<c:if test="${not empty testCases and not empty testCaseTrackersByProject }">
			<div id="testCaseOptions" style="margin-left: 22px;">
				<div class="form-element" style="margin-left: -22px;">
					<form:checkbox path="copyTestCases" id="copyTestCases"/>
					<label for="copyTestCases">
						<spring:message code="tracker.view.layout.document.linking.copy.test.cases.label" text="Copy the Test Cases of the Items"/> (${fn:length(testCases) })
					</label>
				</div>

				<div class="form-element" id="testCaseTrackerSelector">
					<label for="testCaseTrackerId">
						<spring:message code="tracker.view.layout.document.linking.test.case.tracker.label" text="Test Case tracker to copy to"/>:
					</label>
					<form:select path="testCaseTrackerId" id="testCaseTracker" disabled="true">
						<c:forEach items="${testCaseTrackersByProject }" var="entry">
							<optgroup label="<c:out value="${entry.key.name }"/>">
								<c:forEach items="${entry.value }" var="tracker">
									<option value="${tracker.id }">
										<c:out value="${tracker.name }"/>
									</option>
								</c:forEach>
							</optgroup>
						</c:forEach>
					</form:select>
				</div>

				<c:if test="${not empty testCaseTrackerBaselines }">
					<div class="form-element">
						<label>
							<spring:message code="baseline.label" text="Baseline"/>:
						</label>
						<span class="hint" style="width: 51%">
							<spring:message code="ttracker.view.layout.document.copy.baseline.hint"
								text="If you select a baseline for a tracker then the items from that tracker will be copied based on the selected baseline"/>
						</span>
						<c:forEach items="${testCaseTrackerBaselines }" var="entry">
							<p>
								<c:out value="${entry.key.name }"></c:out>:
								<select name="testCaseBaselineIds[${entry.key.id }]" disabled="disabled">
									<option value="-1">${headLabel }</option>

									<c:forEach items="${entry.value }" var="baseline">
										<option value="${baseline.id }"><c:out value="${baseline.name }"/></option>
									</c:forEach>
								</select>
							</p>
						</c:forEach>
					</div>
				</c:if>
			</div>
		</c:if>
		<div id="field-mapping">

		</div>
	</div>
</form:form>

<script type="text/javascript">
	(function ($) {

		var loadTestCaseFieldMappings = function () {
			var $fieldMappingBox = $("#field-mapping");
			$fieldMappingBox.empty();

			var $select = $("#testCaseTracker");
			var destinationTrackerId = $select.val();

			var allIds = [${testCaseTrackerIds}];
			var allNames = [${testCaseTrackerNames}];

			ajaxBusyIndicator.showBusysign($fieldMappingBox, i18n.message("tracker.view.layout.document.linking.load.message"));

			for (var i = 0; i < allIds.length; i++) {
				var sourceTrackerId = allIds[i];

				var $div = $("<div>");
				$fieldMappingBox.append($div);

				var label = i18n.message("tracker.view.layout.document.link.test.case.mapping.label", allNames[i]);
				codebeamer.itemLinking.loadFieldMapping($div, sourceTrackerId, destinationTrackerId, "testCaseFieldMappings[" + sourceTrackerId + "]", true, label);
			}
			ajaxBusyIndicator.close();
		};

		var loadRequirementFieldMappings = function ()  {
			// for each possible requirement tracker load the field mapping dialog
			var $fieldMappingBox = $("#requirement-field-mapping");
			var requirementTrackerIds = [${requirementTrackerIds}];
			ajaxBusyIndicator.showBusysign($fieldMappingBox, i18n.message("tracker.view.layout.document.linking.load.message"));

			for (var i = 0; i < requirementTrackerIds.length; i++) {
				var sourceTrackerId = requirementTrackerIds[i];
				var $div = $("<div>");
				$fieldMappingBox.append($div);
				codebeamer.itemLinking.loadFieldMapping($div, sourceTrackerId, parent.trackerObject.config.id, "fieldMappings[" + sourceTrackerId + "]", true);
			}
			ajaxBusyIndicator.close();
		};

		$("#copyTestCases").click(function (ev) {
			var checked = ev.currentTarget.checked;
			$("#testCaseOptions select").prop("disabled", !checked);

			// show the test case field mapping dialog only if the copy test cases option is selected
			$("#field-mapping").toggle(checked);
			if (checked) {
				loadTestCaseFieldMappings();
			}
		});

		// load the field mapping for all source test case trackers when the user selects a new test case tracker
		$("#testCaseTracker").change(function () {
			loadTestCaseFieldMappings();
		});

		setTimeout(loadRequirementFieldMappings, 200);
	})(jQuery);
</script>
