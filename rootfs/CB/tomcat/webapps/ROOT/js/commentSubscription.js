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

var codebeamer = codebeamer || {};
codebeamer.CommentSubscription = codebeamer.CommentSubscription || (function($) {

	var initAccordion = function($container) {
		var $accordion = $container.find(".accordion");
		$accordion.cbMultiAccordion();
		$accordion.cbMultiAccordion("open", 0);
		$accordion.cbMultiAccordion("open", 1);
	};

	var initCancelButton = function($container) {
		$container.find(".cancelButton").click(function() {
			closePopupInline();
			return false;
		});
	};

	var initSaveButton = function($container) {
		$container.find(".saveButton").click(function() {

			// TODO

			return false;
		});
	};

	var init = function($container) {
		initAccordion($container);
		initSaveButton($container);
		initCancelButton($container);
	};

	return {
		"init": init
	};

})(jQuery);
