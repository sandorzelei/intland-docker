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

var codebeamer = codebeamer || {};
codebeamer.DisplaytagTrackerItemsResizeableColumns = codebeamer.DisplaytagTrackerItemsResizeableColumns || (function($) {

	var config = {};

	var initColResizer = function($container) {
		var isDocumentExtendedView = config.hasOwnProperty("isDocumentExtendedView") ? config.isDocumentExtendedView : false;
		$container.colResizable({
			liveDrag: !isDocumentExtendedView,
			headerOnly: true,
			minWidth: 100,
			onResize: function() {
				if (isDocumentExtendedView) {
					var widths = [];
					$container.find("th:not(.control-bar)").each(function() {
						widths.push($(this).css("width"));
					});
					$container.find("tbody tr.requirementTr").each(function() {
						var index = 0;
						$(this).find("td:not(.control-bar)").each(function() {
							$(this).css("width", widths[index]);
							index++;
						});
					});
					$(window).trigger("resize.JColResizer");
				}
			}
		});
		var skipColumnIndexes = [];
		var index = 0;
		$container.find("th").each(function() {
			if ($(this).hasClass("skipColumn") || $(this).hasClass("extraInfoColumn") || $(this).hasClass("control-bar")) {
				skipColumnIndexes.push(index);
			}
			index++;
		});

		var index = 0;
		$container.prev(".JCLRgrips").find(".JCLRgrip").each(function() {
			if ($.inArray(index, skipColumnIndexes) > -1) {
				$(this).hide();
			}
			index++;
		});

		$container.find(".control-bar").css("width", "30px");
		$(window).trigger("resize.JColResizer");
	};

	var reInit = function($container) {
		$container.colResizable({ disable : true});
		initColResizer($container);
	};

	var init = function($container, settings) {
		config = settings || {};

		var isDocumentExtendedView = config.hasOwnProperty("isDocumentExtendedView") ? config.isDocumentExtendedView : false;

		$("#resizeableColumns").prop("checked", true);

		if (isDocumentExtendedView) {
			$container.find("td.control-bar").css("width", "30px");
		} else {
			var checkBoxColumnWidth = $container.find("tbody tr:not(.skipIdent)").first().find(".checkbox-column-minwidth").innerWidth();
			$container.find("th.checkbox-column-minwidth").css("width", checkBoxColumnWidth);
			$container.find("th.extraInfoColumn").css("width", checkBoxColumnWidth);
			$container.find("td.column-minwidth").css("width", checkBoxColumnWidth);
			// increase summary field size because of the bigger padding
			$container.find("th[data-fieldlayoutid=3]").css("width", $container.find("th[data-fieldlayoutid=3]").width() + 10);
		}

		$container.find("th[data-fieldlayoutid]").each(function() {
			if ($(this).next().is(".skipColumn")) {
				$(this).next().remove();
			}
		});

		$container.find("td").each(function() {
			var $next = $(this).next();
			if ($next.hasClass("menuTrigger")) {
				var $img = $next.find("img").clone();
				var $menuCont = $next.find("span.menu-container").clone();
				$img.css("float", "right");
				$menuCont.css("float", "right");
				$(this).prepend($menuCont);
				$(this).prepend($img);
				$next.remove();
			}
		});

		$container.find(".control-bar").css("width", "30px");

		initColResizer($container);

		$(function() {
			$(window).trigger("resize.JColResizer");
		});
	};

	return {
		"init": init,
		"reInit" : reInit
	};

})(jQuery);

