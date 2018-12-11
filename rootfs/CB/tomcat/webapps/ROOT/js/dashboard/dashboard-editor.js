/*
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
 */

/*  dashboard related functionality */

var codebeamer = codebeamer || {};
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.editor = codebeamer.dashboard.editor || (function($) {

	function init() {
		$("#headerHidden").change(function() {
			if ($(this).is(":checked")) {
				$("#colorField").hide();
			} else {
				$("#colorField").show();
			}
		});
	}

	return {
		"init": init
	};
}(jQuery));