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
(function($) {
	$(document).ready(function() {
		var $pasteWidgetMenu = $(".paste-widget-menu");

		if ($pasteWidgetMenu.hasClass("hidden-menu")) {
			$pasteWidgetMenu.parent().hide();
			$pasteWidgetMenu.removeClass("hidden-menu");
		}

		$("body").off("dashboard:copy:done");
		$("body").on("dashboard:copy:done", function() {
			$pasteWidgetMenu.parent().show();
		});

		$("body").off("dashboard:paste:done");
		$("body").on("dashboard:paste:done", function() {
			$pasteWidgetMenu.parent().hide();
		});
	});
}(jQuery));