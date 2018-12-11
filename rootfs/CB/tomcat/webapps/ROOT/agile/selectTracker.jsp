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
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<ui:actionMenuBar>
	<spring:message code="planner.add.issue.select.tracker.title" />
</ui:actionMenuBar>

<style>

.warning-sign {
	height: 16px;
	display: inline-block;
	vertical-align: middle;
	position: relative;
	top: -2px;
	visibility: hidden;
	cursor: pointer;
	padding-left: 5px;
}

.newskin.popupBody .actionBar {
	padding-left: 0px
}

</style>


<script type="text/javascript">
	var prefilledFields = ${not empty prefilledFields ? prefilledFields : "null"};
	var prefilledValues = ${not empty prefilledValues ? prefilledValues : "null"};

	var otherUrlParameters = "";

	var buildReferenceDataUrlParameterName = function(trackerId, fieldId) {
		return "fieldReferenceData[" +trackerId + "_" + fieldId + "]";
	};

	var buildReferenceDataUrlParameter = function(trackerId, fieldId, fieldValue) {
		return encodeURIComponent(buildReferenceDataUrlParameterName(trackerId, fieldId)) + "=" + encodeURIComponent(fieldValue);
	};

	var changeUrl = function(trackerId, release, otherUrlParameters) {
		var iframe, dialogId;

		iframe = $("#inlinedPopupIframe", window.parent.document);
		dialogId = iframe.parent().attr("id");

		location.href = contextPath + "/cardboard/createIssue.spr?tracker_id=" + trackerId + (release ? "&release=" + release : "") + (otherUrlParameters ? otherUrlParameters : "");
		iframe.ready(function() {
			var dimensions = calculateWindowGeometry("large", window.parent);
			var dialog = window.parent.$('#' + dialogId);
			dialog.dialog("option", "width", dimensions.width);
			dialog.dialog("option", "height", dimensions.height);
		});
	}

	var showDialog = function () {
		var trackerId, release, params, cbQLGroup;

		trackerId = $(".trackerSelector").val();
		release = $("#release").data("id");

		changeUrl(trackerId, release, otherUrlParameters);

	};

	$(document).ready(function () {

		if (prefilledValues) {
			$(document).on("change", ".trackerSelector", function() {
				var trackerId, release, params, cbQLGroup;

				$(".warning-sign").css("visibility", "hidden");
				$(".warning-sign, .nextButton").attr("title", "");

				$(".nextButton").prop( "disabled", true);

				trackerId = $(".trackerSelector").val();
				release = $("#release").data("id");
				otherUrlParameters = "";

				params = {
						trackerId: trackerId
					};

				for (cbQLGroup in prefilledFields) {
					if (prefilledFields.hasOwnProperty(cbQLGroup)) {
						params["cbQLGrouping[" + cbQLGroup + "]"] = prefilledFields[cbQLGroup];
					}
				}

				$.get(contextPath + "/ajax/convert/cbQLGroupingToTrackerFields.spr", params)
					.success(function(data) {
						var fieldId, promises, promise, ajaxParams, ajaxUrl, errors;

						promises = [];
						errors = [];

						if (data) {
							for (fieldId in data) {
								if (data.hasOwnProperty(fieldId)) {
									ajaxParams = {
										tracker_id: trackerId,
										labelId: fieldId,
										autoCompleteFilter: prefilledValues[data[fieldId].value]
									};

									if (data[fieldId].value.indexOf("1") === 0) {
										ajaxUrl = "/ajax/getUserFieldSuggestions.spr";
										ajaxParams["opener_fieldName"] = buildReferenceDataUrlParameterName(trackerId, fieldId);
										ajaxParams.specialValueResolver="com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorSpecialValues";
										ajaxParams.onlyUsersAndRolesWithPermissionsOnTracker=true;
										ajaxParams.searchOnAllUsers=false;
										ajaxParams.acceptEmail=false;
									} else {
										ajaxUrl = "/ajax/getReferenceFieldSuggestions.spr";
										ajaxParams.fieldName = buildReferenceDataUrlParameterName(trackerId, fieldId);
									}

									promise = $.get(contextPath + ajaxUrl, {
											tracker_id: trackerId,
											labelId: fieldId,
											fieldName: buildReferenceDataUrlParameterName(trackerId, fieldId),
											autoCompleteFilter: prefilledValues[data[fieldId].value]
										}).success((function(fieldId, name) {
											return function(results) {
														if (results && results.hasOwnProperty("resultset") && $.isArray(results.resultset) && results.resultset.length > 0) {
															otherUrlParameters += "&" + buildReferenceDataUrlParameter(trackerId, fieldId, data[fieldId].value);
														} else {
															errors.push(name);
														}
													};
										})(fieldId, ajaxParams.autoCompleteFilter));

									promises.push(promise);
								}
							}

							$.when.apply($, promises).done(function() {
								if (errors.length > 0) {
									$(".warning-sign").css("visibility", "visible");
									$(".warning-sign, .nextButton").attr("title", i18n.message("planner.add.issue.select.tracker.reference.compatibility.warning") + errors.join(";"));
								}
								$(".nextButton").prop( "disabled", false);
							});
						}
					});


			});
		}

		<c:if test="${useCookies}">
			if (selectTracker) {
				selectTracker.storeSelections = function() {
					var uniqueId, parent;

					uniqueId = $("#release").data("id");
					parent = window.parent;

					if ((uniqueId === undefined || uniqueId === null) && (parent.hasOwnProperty("codebeamer") && parent.codebeamer.hasOwnProperty("ReportSupport")) ) {
						uniqueId = parent.codebeamer.ReportSupport.getReleaseId(parent.$(".reportSelectorTag").attr("id"));
						if (uniqueId === undefined || uniqueId === null) {
							uniqueId = parent.codebeamer.ReportSupport.getReleaseTrackerId(parent.$(".reportSelectorTag").attr("id"));
						}
					}
					$.cookie("codebeamer.planner.selectedProject." + uniqueId, $("#project").val(), { path: contextPath + '/planner', expires: 90, secure: (location.protocol === 'https:')});
					$.cookie("codebeamer.planner.selectedTracker." + uniqueId, $(".trackerSelector").val(), { path: contextPath + '/planner', expires: 90, secure: (location.protocol === 'https:')});
				}
			}
		</c:if>

		var selectedTracker = null;
		var selectedProject = null;

		<c:choose>
			<c:when test="${useCookies}">
				var uniqueId, parent;

				uniqueId = $("#release").data("id");
				parent = window.parent;

				if ((uniqueId === undefined || uniqueId === null) && (parent.hasOwnProperty("codebeamer") && parent.codebeamer.hasOwnProperty("ReportSupport")) ) {
					uniqueId = parent.codebeamer.ReportSupport.getReleaseId(parent.$(".reportSelectorTag").attr("id"));
					if (uniqueId === undefined || uniqueId === null) {
						uniqueId = parent.codebeamer.ReportSupport.getReleaseTrackerId(parent.$(".reportSelectorTag").attr("id"));
					}
				}
				selectedTracker = $.cookie("codebeamer.planner.selectedTracker." + uniqueId);
				selectedProject = $.cookie("codebeamer.planner.selectedProject." + uniqueId);
				<c:if test="${not empty currentProjectId}">
					if (! selectedProject) {
						selectedProject = ${currentProjectId};
					}
				</c:if>
			</c:when>
			<c:otherwise>
				<c:if test="${not empty currentProjectId}">
					selectedProject = ${currentProjectId};
				</c:if>
			</c:otherwise>
		</c:choose>

		if (typeof selectTracker !== "undefined") {
			// Render this change later to make sure that the browser properly displays the selected option
			setTimeout(function() {
				selectTracker.init(selectedProject, selectedTracker);
				if (prefilledValues) {
					$(".trackerSelector").trigger("change");
				}
			}, 200);
		} else {
			if (prefilledValues &&  $(".trackerSelector").val()) {
				$(".trackerSelector").trigger("change");
			}
		}

		<c:if test="${not empty jsCallbackFunction}">
			$('form').submit(function(event) {
				parent.${jsCallbackFunction}(event, $(this), ${enableTrDnD});
			});
		</c:if>

	});
</script>

<c:if test="${not empty version}">
	<div id="release" data-id="${version.id}"></div>
</c:if>
<form:form action="${submitUrl}" method="GET" target="${not empty version ? '_self' :'_top'}">
	<div class="actionBar">
		<c:choose>
			<c:when test="${not empty version or param.isPopup}">
				<img class="warning-sign" src="../images/newskin/message/warning-l.png"></img>
				<spring:message var="buttonTitle" code="button.next" text="Next"/>
				<input type="button" value="${buttonTitle}" class="nextButton button" onclick="showDialog();"<c:if test="${newGroupItem and (empty projects or empty trackersByProject)}"> disabled="disabled"</c:if>>
			</c:when>
			<c:otherwise>
				<c:if test="${not empty projects and not empty trackersByProject}">
					<spring:message var="okTitle" code="button.ok" text="OK"/>
					<input type="submit" value="${okTitle}" class="button">
				</c:if>
			</c:otherwise>
		</c:choose>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}"/>
	</div>
	<div class="contentWithMargins">
		<c:choose>
			<c:when test="${empty projects or empty trackersByProject}">
				<div class="warning">
					<c:choose>
						<c:when test="${not empty version}">
							<spring:message code="planner.add.issue.select.tracker.no.references" text="No work trackers are referencing this tracker."/>
						</c:when>
						<c:when test="${newGroupItem}">
							<spring:message code="planner.new.group.item.empty.warning"/>
						</c:when>
						<c:otherwise>
							<spring:message code="tracker.traceability.browser.tracker.selector.no.available" text="All available trackers are already added."/>
						</c:otherwise>
					</c:choose>
				</div>
			</c:when>
			<c:otherwise>
				<jsp:include page="./selectTrackerWidget.jsp"></jsp:include>
			</c:otherwise>
		</c:choose>
	</div>
</form:form>

