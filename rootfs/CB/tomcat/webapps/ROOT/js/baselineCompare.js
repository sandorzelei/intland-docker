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

codebeamer.BaselineCompare = codebeamer["BaselineCompare"] || (function($) {

	var adjustBaselineHeadersNow = function() {
		var containers = $(".compareContainer").find(".baselineHeaderContainer");
		containers.css("height", "auto").setAllToMaxHeight();
	};

	var adjustBaselineHeaders = throttleWrapper(adjustBaselineHeadersNow, 100);

	var adjustBackLinkNow = function() {
		var container = $(".compareContainer");
		var lastVisibleTab = container.find(".ditch-tab:visible").last();
		if (lastVisibleTab.length > 0) {
			var linkLeft = lastVisibleTab.offset().left + lastVisibleTab.outerWidth();
			container.find(".backContainer").css("left", linkLeft);
		}
	};

	var adjustBackLink = throttleWrapper(adjustBackLinkNow, 100);

	/**
	 * Fixes paging links to pass their currently selected tab's ID forward.
	 */
	var fixPagingLinks = function() {
		$(".compareContainer").find(".ditch-tab-pane").each(function() {
			var pane = $(this);
			var tabId = pane.attr("id");
			pane.find(".pagelinks a").each(function() {
				var link = $(this);
				var oldUrl = link.attr("href");
				var newUrl = UrlUtils.addOrReplaceParameter(oldUrl, "orgDitchnetTabPaneId", tabId);
				link.attr("href", newUrl);
			});
		});
	};

	var addStatsHeaderShortcutLinks = function() {
		$(".compareContainer .statsPerCategory .categoryHeader a").each(function(index, link) {
			var tab = $("#baseline-compare-tabs").find(".ditch-tab:not(:first-child)").get(index);
			$(link).click(function() {
				return tab.click();
			});
		});
	};

	var init = function() {
		adjustBaselineHeaders();
		adjustBackLink();
		$(window).resize(function() {
			adjustBaselineHeaders();
			adjustBackLink();
		});
		$("#baselineAccordion").on("open", function() {
			adjustBaselineHeadersNow();
			adjustBackLinkNow();
		});
	};

	var initAfterReload = function() {
		initJQueryMenus(".compareContainer");
		$(".compareContainer .ditch-tab").on("click", function() {
			adjustBaselineHeadersNow();
			return true;
		});
		$("#backToListLink").click(function() {
			$("#baselineAccordion").cbMultiAccordion("open", 0);
			return false;
		});
		adjustBaselineHeadersNow();
		adjustBackLinkNow();
		fixPagingLinks();
		addStatsHeaderShortcutLinks();
	};

	return {
		init: init,
		initAfterReload: initAfterReload
	};
})(jQuery);
