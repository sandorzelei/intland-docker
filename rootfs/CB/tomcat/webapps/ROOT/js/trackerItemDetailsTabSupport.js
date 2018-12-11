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
codebeamer.TrackerItemDetailsTabSupport = codebeamer.TrackerItemDetailsTabSupport || (function($) {

	function loadTab($container, url, callback) {
		if (!$container.data("loaded")) {
			var busy = ajaxBusyIndicator.showBusysign($container.parent());
			$.get(url, function(result) {
				$container.html(result);
				$container.data("loaded", true);
				ajaxBusyIndicator.close(busy);
				$container.find(".yuimenubar").each(function() {
					var actionMenuId = $(this).attr("id");
					initPopupMenu(actionMenuId, {
						context: [actionMenuId, 'tl', 'bl', ['beforeShow', 'windowResize']]
					});
				});
				if (callback) {
					callback();
				}
			}).fail(function(error) {
				ajaxBusyIndicator.close(busy);
				var messageCode = error.status == 403 ? "tracker.item.details.tab.access.denied" : "tracker.item.details.tab.warning";
				showFancyAlertDialog(i18n.message(messageCode), "error");
			});
		}
	}

	function loadProperTab(selectedTabId, issueId, baselineId) {
		if (selectedTabId == "task-details-commits-tab") {
			loadTab($("#scmHistory"), contextPath + "/itemdetails/scmHistory.spr?itemId=" + issueId + (baselineId ? "&version=" + baselineId : ""), function() {
				showDiff.loadAllDiffs();
			});
		} else if (selectedTabId == "task-details-all-tab") {
			loadTab($("#allHistory"), contextPath + "/itemdetails/allHistory.spr?itemId=" + issueId + (baselineId ? "&version=" + baselineId : ""));
		}
	}

	function initOnPageLoad($container, issueId, baselineId) {
		var $selected = $container.find(".ditch-tab.ditch-focused").first();
		loadProperTab($selected.attr("id"), issueId, baselineId);
	}

	return {
		"loadProperTab": loadProperTab,
		"initOnPageLoad" : initOnPageLoad
	};

})(jQuery);