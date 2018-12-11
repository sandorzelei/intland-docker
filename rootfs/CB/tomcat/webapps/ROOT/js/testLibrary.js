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
 */

jQuery(function() {
	var accordion = $("#testAccordion");

	(function init() {
		accordion.accordion({
			"header": '.accordionHeader',
			"heightStyle": "fill",
			"active": 0,
			"activate": function (e, ui) {
				if (ui.newPanel.attr("id") === "testPlanLibraryPane") {
					testLibraryTree.init();
				} else if (ui.newPanel.attr("id") === "testSetLibraryPane") {
					testSetLibraryTree.init();
				}
			}
		});
	})();

	(function reactToWindowResize() {
		var resizeAccordion = function() {
			accordion.accordion("refresh");
		};
		$(window).resize(function() {
			throttle(resizeAccordion, window, null, 400);
		});
		setTimeout(resizeAccordion, 150);
	})();

	(function testLibraryConfiguration() {
		var createCallback = function(type, treeId) {
			return function() {
				var trackerId = $("#" + treeId).data("trackerId");
				showPopupInline(contextPath + "/trackers/library/configure.spr?tracker_type=" + type + "&tree_id=" + treeId + "&tracker_id=" + trackerId);
				return false;
			}
		};
		$("#configureTestCases").click(createCallback("testcase", "testLibraryTreePane"));
		$("#configureTestSets").click(createCallback("testset", "testSetLibraryTreePane"));
	})();
});
