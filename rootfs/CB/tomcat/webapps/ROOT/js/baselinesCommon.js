/**
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */

/**
 * Common functions for baselines.
 * This file is included in every page, so keep it as short and simple as possible.
 */
codebeamer.Baselines = codebeamer["Baselines"] || (function($) {

	var changeDefaultBaseline = function(projectId, baselineParamName) {
		var url = contextPath + "/branching/trackerBaselinesAndBranches.spr?project_id=" + (projectId || "");
		if (baselineParamName) {
			url += "&baseline_param_name=" + baselineParamName;
		}
		showPopupInline(url, {
			geometry: "large"
		});
	};

	var selectBaseline = function(projectId, side) {
		showPopupInline(contextPath + "/proj/ajax/baselines.spr?proj_id=" + (projectId || "") + "&selection_side=" + side, {
			geometry: "half_half"
		});
	};

	var createNewBaseline = function(projectId) {
		window.location.href = contextPath + "/proj/baselines.spr?proj_id=" + projectId + "&create_new_baseline=true";
	};

	var compareWithBaseline = function(projectId, baselineId) {
		window.location.href = contextPath + "/proj/baselines.spr?proj_id=" + projectId + "&compare_with=" + baselineId;
	};

	var switchToHead = function(baselineParamName) {
		var url = UrlUtils.addOrReplaceParameter(parent.window.location.href, baselineParamName.split(","), "");
		if (baselineParamName == "branchId") {
			url = UrlUtils.addOrReplaceParameter(url, "skipBranchSwitchWarning", "true");
		}
		window.location.href = url;
	};

	var compareBaselinesButtonHandler = function(parentEl, compareURL, compareParamName, avoidCache) {
		compareParamName = compareParamName || "baseline";
		var $selectedCheckboxes = $(parentEl).find("input:checked");
		if ($selectedCheckboxes.length != 2) {
			alert(i18n.message("project.baselines.compare.select.two"));
			return false;
		}
		var requestURL = compareURL +
			"&" + compareParamName + "1=" + ($selectedCheckboxes.get(1).value || "0") +
			"&" + compareParamName + "2=" + ($selectedCheckboxes.get(0).value || "0");
		if (avoidCache) {
			var timestamp = new Date();
			requestURL += "&avoidCache=" + timestamp.getTime();
		}
		launch_url(requestURL, "large");
		return false;
	};

	return {
		changeDefaultBaseline: changeDefaultBaseline,
		createNewBaseline: createNewBaseline,
		compareWithBaseline: compareWithBaseline,
		switchToHead: switchToHead,
		selectBaseline: selectBaseline,
		compareBaselinesButtonHandler: compareBaselinesButtonHandler
	};
})(jQuery);
