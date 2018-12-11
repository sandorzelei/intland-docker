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
 * Common functions for branches.
 */

var codebeamer = codebeamer || {};
codebeamer.branches = codebeamer.branches || (function($) {

	var mergeBranches = function () {
		var $selectedCheckboxes = $("input[name=selectedBranches]:checked");
		if ($selectedCheckboxes.length != 2) {
			showFancyAlertDialog(i18n.message("tracker.branching.compare.select.two"));
			return false;
		}

		var branchId = $selectedCheckboxes.get(0).value;
		var targetBranchId = $selectedCheckboxes.get(1).value;

		if (!branchId) { // if the first selected branch is the master then use the second as branch id
			branchId = targetBranchId;
			targetBranchId = '';
		}

		var url = '{0}/branching/diff.spr?branchId={1}&targetBranchId={2}'.format(contextPath, branchId, targetBranchId);
		parent.location.href = url;
	};

	return {
		"mergeBranches": mergeBranches
	};
})(jQuery);