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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />

<style type="text/css">
	.newskin .ui-multiselect-menu {
		display: none;
    }
</style>

<script src="<ui:urlversioned value='/js/multiselect-filter.js'/>"></script>

<div class="contentWithMargins">
	<spring:message code="tracker.filter.Any.label" text="Any" var="anyLabel"/>
	<form:form id="advancedFilterForm">
		<div>
		<div class="form-box">
			<table border="0" class="propertyTable" cellpadding="2">
				<tr>
					<td class="optional"><spring:message var="title" code="tracker.coverage.browser.filter.by.coverage.title" />
						<label for="filterRequirementByCoverage" title="${title}" ><spring:message code="tracker.coverage.browser.filter.by.coverage" text="Coverage"/>:</label>
					</td>
					<td class="tableItem">
						<form:select path="filterRequirementsByCoverage" id="filterRequirementByCoverage" cssClass="coverage">
							<form:option value="">${anyLabel }</form:option>
							<c:if test="${coverageType != 'testrun'}">
								<form:option value="Covered"><spring:message code="tracker.coverage.browser.filter.by.coverage.opt.covered" text="Covered"/></form:option>
								<form:option value="NotCovered"><spring:message code="tracker.coverage.browser.filter.by.coverage.opt.notcovered" text="Not Covered"/></form:option>
							</c:if>
							<optgroup label="Coverage Status">
								<c:forEach items="${coverageStatuses }" var="coverageStatus">
									 <form:option value="${coverageStatus.value }"><spring:message code="tracker.coverage.status.${coverageStatus.key}.label" text="${coverageStatus }"/></form:option>
								</c:forEach>
							</optgroup>
						</form:select>
					</td>
				</tr>

				<tr>
					<td class="optional">
						<spring:message var="title" code="tracker.coverage.browser.filter.status.title" />
						<label for="filterByStatus" title="Fitler by Status"><spring:message code="tracker.coverage.browser.filter.status"/>:</label>
					</td>
					<td class="tableItem">
                       <select name="_requirementStatuses" id="filterByStatus" multiple="multiple">

							<optgroup label="Meaning">
								<c:forEach items="${supportedStatusMeanings }" var="meaning">
									<c:set var="selected" value=""/>
									<ct:call object="${command.requirementStatuses }" method="contains" return="contains" param1="${meaning}"/>
									<c:if test="${contains}">
										<c:set var="selected" value="selected='selected'"/>
									</c:if>
									<spring:message code="issue.flag.${meaning }.label" var="meaningTitle"/>
									<option value="${meaning }" title="${meaningTitle }" ${selected }>${meaningTitle }</option>
								</c:forEach>
							</optgroup>
							<c:forEach var="projectGroup" items="${statuses}">
									<c:forEach items="${projectGroup.value}" var="entry">
										<optgroup label="<c:out value='${projectGroup.key.name } - ${entry.key.name }'/>">
											<c:forEach items="${entry.value}" var="status">
												<c:set var="selected" value=""/>
												<ct:call object="${command.requirementStatuses }" method="contains" return="contains" param1="${entry.key.id}-${status.id}"/>
												<c:if test="${contains}">
													<c:set var="selected" value="selected='selected'"/>
												</c:if>
												<option value="${entry.key.id}-${status.id}"  title="<c:out value='${status.name }'/>" class="status" ${contains ? "selected='selected'" : "" }>
													<c:out value='${status.name }'/>
												</option>
											</c:forEach>
										</optgroup>
									</c:forEach>
							</c:forEach>
						</select>
					</td>
				</tr>

				<c:if test="${fn:length(trackersByProject) > 0}">
					<tr>
						<td class="optional">
							<label for="filterTrackerIds"><spring:message code="tracker.label"/>:</label>
						</td>
						<td class="tableItem">
							<select name="_filterTrackerIds" id="filterTrackerIds" multiple="multiple">
								<option value="" title="${anyLabel }">${anyLabel }</option>
								<c:forEach var="entry" items="${trackersByProject}">
									<optgroup label="<c:out value='${entry.key.name }'/>">
										<c:forEach items="${entry.value}" var="tracker">
											<c:set var="selected" value=""/>
											<ct:call object="${command.filterTrackerIds }" method="contains" return="contains" param1="${tracker.id}"/>
											<c:if test="${contains}">
												<c:set var="selected" value="selected='selected'"/>
											</c:if>
											<option value="${tracker.id}"  title="<c:out value='${tracker.name }'/>" class="status" ${contains ? "selected='selected'" : "" }>
												<c:out value='${tracker.name }'/>
											</option>
										</c:forEach>
									</optgroup>
								</c:forEach>
							</select>
						</td>
					</tr>
				</c:if>

				<c:if test="${fn:length(requirementReleaseTrackers) > 0 && coverageType != 'release' && coverageType != 'testrun'}">
					<tr>
						<td class="optional">
							<label for="requirementReleaseSelector"><spring:message code="tracker.coverage.browser.requirement.release.label" text="Work Item Release"/>:</label>
						</td>
						<td class="tableItem">
							<select name="_requirementReleases" id="requirementReleaseSelector" class="release" multiple="multiple">
								<spring:message code="tracker.filter.Any.label" text="Any" var="anyLabel"/>
								<option value="-1" title="${anyLabel}">${anyLabel}</option>
								<c:forEach items="${requirementReleaseTrackers}" var="releaseTracker">
									<optgroup label="${releaseTracker.key.project.name} - ${releaseTracker.key.name}">
										<c:forEach items="${releaseTracker.value}" var="pair">
										 	<c:set var="selected" value=""/>
											<ct:call object="${command.requirementReleases }" method="contains" return="contains" param1="${pair.right.id}"/>
											<c:if test="${contains}">
												<c:set var="selected" value="selected='selected'"/>
											</c:if>
											<option value="${pair.right.id}" title="<c:out value='${pair.right.name}'/>" ${selected} class="release">
												<c:forEach begin="1" end="${(pair.left)*2}">&nbsp;</c:forEach><c:out value='${pair.right.name}'/>
											</option>
										</c:forEach>
									</optgroup>
								</c:forEach>
							</select>
						</td>
					</tr>
				</c:if>

				<!-- test case type options -->
				<tr>
					<td class="optional">
						<spring:message var="title" code="tracker.coverage.browser.filter.testCaseType.title" />
						<label for="filterByTestCaseType" title="Fitler by Test Case Type"><spring:message code="tracker.coverage.browser.filter.testCaseType" text="Test Case Type"/>:</label>
					</td>
					<td class="tableItem">
						<select name="_testCaseType" id="filterByTestCaseType" multiple="multiple">
							<c:forEach var="projectGroup" items="${testCaseTypes}">
									<c:forEach items="${projectGroup.value}" var="entry">
										<optgroup label="<c:out value='${projectGroup.key.name } - ${entry.key.name }'/>">
											<ct:call object="${command.testCaseTypes }" method="contains" return="emptySelected" param1="${entry.key.id}-empty"/>
											<option value="${entry.key.id}-empty" title="--" class="type" ${emptySelected ? "selected='selected'" : "" }>--</option>
											<c:forEach items="${entry.value}" var="type">
												<ct:call object="${command.testCaseTypes }" method="contains" return="contains" param1="${entry.key.id}-${type.id}"/>
												<option value="${entry.key.id}-${type.id}"  title="<c:out value='${type.name }'/>" class="type" ${contains ? "selected='selected'" : "" }>
													<c:out value='${type.name }'/>
												</option>
											</c:forEach>
										</optgroup>
									</c:forEach>
							</c:forEach>
						</select>
					</td>
				</tr>

				<tr>
					<td class="optional">
						<spring:message var="title" code="tracker.coverage.browser.filter.test.stability.title" />
						<label for="testStability" title="${title}" ><spring:message code="tracker.coverage.browser.filter.test.stability.label" text="TestStability"/>:</label>
					</td>
					<td class="tableItem">
						<form:select path="testStability" id="testStability" cssClass="stability">
							<form:option value="All"><spring:message code="tracker.coverage.browser.filter.by.coverage.opt.all" /></form:option>
							<spring:message code="tracker.coverage.browser.filter.test.stability.opt.stable" text="Stable" var="stableName"/>
							<spring:message code="tracker.coverage.browser.filter.test.stability.opt.unstable" text="Unstable" var="unstableCoveredName"/>
							<form:option value="Stable" title="${stableName }" class="coverage">${stableName }</form:option>
							<form:option value="Unstable" title="${unstableName}" class="coverage">${unstableName}</form:option>
						</form:select>
					</td>


				</tr>

				<tr>
					<td>

					</td>
					<td class="tableItem">
						<spring:message code="search.submit.label" text="GO" var="goLabel"/>
						<input type="button" class="button" onclick="loadCoverageBrowser();" value="${goLabel }"></input>
					</td>
				</tr>
			</table>
		</div>

		<div class="form-box">
			<table border="0" class="propertyTable" cellpadding="2">
				<%-- test run related filters --%>
				<c:if test="${fn:length(configurations) > 0}">
					<tr>
						<td class="optional">
							<label for="configurationSelector"><spring:message code="testrunner.configuration.label" text="Configuration"/>:</label>
						</td>
						<td class="tableItem">
							<select name="_configurationIds"  id="configurationSelector" class="configuration" multiple="multiple">
								<c:forEach items="${configurations}" var="entry">
									<c:choose>
										<c:when test="${entry.key.id == -1 || entry.key.id == 21}">
											<c:forEach items="${entry.value}" var="configuration">
												<c:set var="selected" value=""/>
												<ct:call object="${command.configurationIds }" method="contains" return="contains" param1="${configuration.id}"/>
												<c:if test="${contains}">
													<c:set var="selected" value="selected='selected'"/>
												</c:if>
												<option value="${configuration.id }" ${selected } title="<c:out value='${configuration.name }'/>" class="configuration"><c:out value='${configuration.name }'/></option>
											</c:forEach>
										</c:when>
										<c:otherwise>
											<optgroup label="${entry.key.project.name} - ${entry.key.name}">
												<c:forEach items="${entry.value}" var="configuration">
													<c:set var="selected" value=""/>
													<ct:call object="${command.configurationIds }" method="contains" return="contains" param1="${configuration.id}"/>
													<c:if test="${contains}">
														<c:set var="selected" value="selected='selected'"/>
													</c:if>
													<option value="${configuration.id }" ${selected } title="<c:out value='${configuration.name }'/>" class="configuration"><c:out value='${configuration.name }'/></option>
												</c:forEach>
											</optgroup>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</td>
					</tr>
				</c:if>

				<c:if test="${fn:length(testRunReleaseTrackers) > 0}">
					<tr>
						<td class="mandatory">
							<label for="testRunReleaseSelector"><spring:message code="tracker.coverage.browser.test.run.release.label" text="Test Run Release"/>:</label>
						</td>
						<td class="tableItem">
							<select name="testRunReleases" id="testRunReleaseSelector" class="release" multiple="multiple">
								<c:forEach items="${testRunReleaseTrackers}" var="releaseTracker">
									<optgroup label="<c:out value='${releaseTracker.key.project.name} - ${releaseTracker.key.name}'/>">
										<c:forEach items="${releaseTracker.value}" var="pair">

											<c:set var="selected" value=""/>

											<ct:call object="${command.testRunReleases }" method="contains" return="contains" param1="${pair.right.id}"/>
											<c:if test="${contains}">
												<c:set var="selected" value="selected='selected'"/>
											</c:if>

											<option value="${pair.right.id}" title="<c:out value='${pair.right.name}'/>" ${selected} class="release">
												<c:forEach begin="1" end="${(pair.left)*2}">&nbsp;</c:forEach><c:out value='${pair.right.name}'/>
											</option>
										</c:forEach>
									</optgroup>
								</c:forEach>
							</select>
						</td>
					</tr>
				</c:if>
				<tr>
					<spring:message var="runningIntervalLabel" code="tracker.coverage.browser.test.run.interval.label" text="Running interval"/>
					<td class="optional">${runningIntervalLabel}:</td>

					<td class="tableItem">
						<spring:message code="duration.after.label" text="After"/>:
						<form:input path="lastRunFrom" size="12" maxlength="30" id="lastRunFrom" />
						<ui:calendarPopup textFieldId="lastRunFrom" otherFieldId="lastRunTo"/>

						<spring:message code="duration.before.label" text="Before"/>:
						<form:input path="lastRunTo" size="12" maxlength="30" id="lastRunTo" />
						<ui:calendarPopup textFieldId="lastRunTo" otherFieldId="lastRunTo"/>
					</td>
				</tr>

				<tr>
					<spring:message var="buildLabel" code="tracker.coverage.browser.filter.tested.build.label" text="Tested Build"/>
					<td class="optional">${buildLabel}:</td>

					<td class="tableItem">
						<form:input path="build"></form:input>
					</td>
				</tr>

				<tr>
					<spring:message var="assigneesLabel" code="testcase.run.by" text="Last Run by"/>
					<td class="optional">${assigneesLabel}:</td>

					<td class="tableItem">
						<bugs:userSelector htmlId="assigneeIds" showUnset="false"
		                   showCurrentUser="false" singleSelect="false" allowRoleSelection="false" ids="${ids}"/>
					</td>
				</tr>
				<tr>
					<spring:message var="recentRunsLabel" code="tracker.coverage.browser.number.of.recent.runs.label"
						text="Number of recent Test Runs shown"/>
					<td class="optional">${recentRunsLabel}:</td>

					<td class="tableItem">
						<form:input type="number" path="recentRuns" min="0" max="10"/>
					</td>
				</tr>
			</table>
		</div>
		</div>
	</form:form>

</div>

<script type="text/javascript">
	var defaultMultiselectOptions = {
		"header": "Apply",
		"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
        "menuHeight": 255,
        "header": true,
		"selectedText": function(numChecked, numTotal, checked) {
			return $.map(checked, function(a) {
				return $(a).attr("title");
			}).join(", ");
		},
		"create": function (e) {
		 	var $widget = $("[name=multiselect_" + $(this).attr("id") + "]").closest(".ui-multiselect-menu");
			$widget.hide();

			var $addOptionsHere = $widget.find(".ui-multiselect-header .ui-helper-reset");

			// add the filter box for options
			var li = $("<div>").addClass("filter").addClass("option-filter").append($("<input>").attr({"type": "text", "placeholder": "filter..."}));
			li.append($("<div>").addClass("ui-icon ui-icon-circle-close"));
            $addOptionsHere.before(li);

			li.find("input").keyup(function () {
				var searchText = $(this).val().toLowerCase();
				filterList($widget.find('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)'), searchText);
			});

			li.find(".ui-icon").click(function () {
				var $allListElements = $widget.find('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)');
				$allListElements.show();
				$(this).prev("input").val("");
			});

			$widget.find("input[type=checkbox]").click(function () {
				var $box = $(this);
				if ($box.is(":checked")) {
					if ($box.val() == -1) {
						// if the any option is clicked select all the other options too
						$widget.find(":checkbox:checked").each(function() {
							var $this = $(this);
							if ($this.val() != -1 && $this.is(":checked")) {
								$this.attr("checked", false);
							}
						});
					} else {
						// if something is checked uncheck the any option
						$widget.find("[value=-1]").attr("checked", false);

						$box.parents("ul").find(".optgroup-clearer").show();
					}
				}
			});

			var $clearAllButton = $("<ul>", {"class": "clear-all",
			                                 "title": i18n.message("tracker.coverage.browser.clear.selection.title")});
			$clearAllButton.append($("<li>").html(i18n.message("tracker.coverage.browser.clear.selection.label")));

			var multiselect = $(this);
			$clearAllButton.click(function () {
				multiselect.multiselect("uncheckAll");
			})

            $addOptionsHere.before($clearAllButton);

            try {
				updatePermanentLink();
			} catch(e) {
				console.log(e);
			}
		}
	};

	$(document).ready(function () {
        // multiselect lists
        $("#configurationSelector,#filterByStatus,#requirementReleaseSelector,#filterTrackerIds,#filterByTestCaseType,#testRunReleaseSelector").multiselect(defaultMultiselectOptions);

	});
</script>
