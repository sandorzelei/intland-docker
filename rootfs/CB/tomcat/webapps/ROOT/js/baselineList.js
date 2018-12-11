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

codebeamer.BaselineList = codebeamer["BaselineList"] || (function($) {

	var dropArea;
	var dropHint;
	var leftBaseline;
	var rightBaseline;
	var leftSelectButton;
	var rightSelectButton;
	var baselines;
	var baselineTable;
	var compareButtonCont;
	var compareButton;
	var placeHolderCompareButton;
	var filter;
	var ajaxLoader;

	var initVariables = function(root) {
		root = root || top;
		dropArea = root.$(".baselineDropArea");
		dropHint = root.$(".dropHint");
		leftBaseline = dropArea.find(".leftBaseline");
		rightBaseline = dropArea.find(".rightBaseline");
		leftSelectButton = root.$("#leftBaselineSelector");
		rightSelectButton = root.$("#rightBaselineSelector");
		baselines = leftBaseline.add(rightBaseline);
		filter = root.$(".filter");
		baselineTable = root.$("#baseline");
		compareButton = root.$("#compareSelectedBaselines");
		placeHolderCompareButton = root.$("#placeHolderCompareSelectedBaselines");
		compareButtonCont = compareButton.closest(".compareBaselinesCont");
		ajaxLoader = root.$("#baselineCompareInProgress");
	};

	var isBaselineSourceDifferent = function() {
		var leftBaselineParentTypeId, rightBaselineParentTypeId, different;

		leftBaselineParentTypeId = leftBaseline.find('.parentTypeId').text();
		rightBaselineParentTypeId = rightBaseline.find('.parentTypeId').text();

		different = false;
		if (leftBaselineParentTypeId !== rightBaselineParentTypeId) {
			different = true;
		}

		return different;
	}

	var init = function(isComparisonPage) {

		isComparisonPage = !!isComparisonPage;

		initVariables();

		var accordion = $("#baselineAccordion");
		var accordionOffsetTop = accordion.offset().top;
		var footerHeight = $("#footer").outerHeight();

		compareButton.click(function() {
			var question = i18n.message('baseline.compare.question');
			if (isBaselineSourceDifferent()) {
				showFancyConfirmDialogWithCallbacks(question,
					function() {
						compareSelectedBaselines("stats-tab", 1); // when the user clicks the button, always start with the stats tab
					},
					function() {
					});
			} else {
				compareSelectedBaselines("stats-tab", 1); // when the user clicks the button, always start with the stats tab
			}

			return false;
		}).prop("disabled", true);

		if (isComparisonPage) {
			$(".compareContainer").hide();
		}

		accordion.cbMultiAccordion({
			active: isComparisonPage ? 1 : 0,
			allowOneOpen: true,
			fixedHeight: function() {
				return $(window).height() - accordionOffsetTop - footerHeight;
			}
		}).on("open", function() {
			fixHeights();
		});

		/*baselineTable.find("tbody tr").draggable({
			"revert": "invalid",
			"handle": ".issueHandle",
			"helper": "clone",
			"cursor": "move",
			"start": function(e, ui) {
				$(ui.helper).addClass("ui-draggable-helper");
				dropArea.addClass("highlightAsTarget");
			},
			"stop": function() {
				dropArea.removeClass("highlightAsTarget");
			}
		});

		dropArea.droppable({
			drop: function(event, ui) {
				dropBaseline(ui.draggable);
			},
			"hoverClass": "highlighted"
		});*/

		$(".changeComparison").click(function() {
			// we need to dynamically check this because drop areas might get swapped often
			var links = $(".changeComparison");
			var left = $(this).index(links) == 0;
			if (left) {
				leftSelectButton.click();
			} else {
				rightSelectButton.click();
			}
			return false;
		});

		setupRows();

		$("a.starIt,a.unstarIt,a.lock,a.unlock").addClass("reloadPage");
	};

	var setupRows = function() {
		baselineTable.find("tbody tr").addClass("disableTextSelection")
			.attr("title", i18n.message("project.baseline.doubleClickSelect.hint"))
			.dblclick(function(e) {
				dropBaseline(this);
				e.stopPropagation();
				e.preventDefault();
				return false;
			});

		baselineTable.find("tbody tr a").click(function(e) {
			var $element, timerId;

			e.preventDefault();

			$element = $(this);
			timerId = $element.data("timer");

			if (timerId) {
				// Double click detected
				window.clearTimeout(timerId);
				$element.data("timer", "");
			} else {
				$element.data("timer", window.setTimeout(function() {
					// Single click, go to link location
					window.location = $element.attr("href");
				}, 500));
			}

		});
	};

	var hasPushStateFeature = typeof window.history.pushState !== "undefined";

	var compareSelectedBaselines = function(tabId, page) {
		var selectedBaselines = $(".leftBaseline.notEmpty, .rightBaseline.notEmpty");
		if (selectedBaselines.length != 2) {
			alert(i18n.message("project.baselines.compare.select.two"));
			return false;
		}

		var leftBaselineId = getId(leftBaseline);
		var rightBaselineId = getId(rightBaseline);
		tabId = tabId || getUrlParameter("orgDitchnetTabPaneId");
		page = page || getUrlParameter("page");
		var baselineParams = "&baseline1=" + leftBaselineId + "&baseline2=" + rightBaselineId +
			"&orgDitchnetTabPaneId=" + tabId + "&page=" + page;
		var compareUrl = compareButton.data("compare-url");
		var baseUrl = compareButton.data("base-url");
		var requestURL = compareUrl + baselineParams;
		var tstmp = new Date();
		requestURL += "&avoidCache=" + tstmp.getTime();
		ajaxLoader.show();
		compareButton.hide();

		var compareContainer = $(".compareContainer");
		compareContainer.html('<div class="globalAjaxLoader"></div>').show();

		$.ajax({
			url: requestURL,
			method: "get"
		}).done(function(response) {
			compareContainer.replaceWith(response).show();
			codebeamer.BaselineCompare.initAfterReload();
			$("#baselineAccordion")
				.cbMultiAccordion("close", 0)
				.cbMultiAccordion("open", 1);
			if (hasPushStateFeature) {
				window.history.pushState({}, "", baseUrl + baselineParams);
			}
		}).fail(function() {
			alert("An error occurred while loading the results.");
		}).always(function() {
			ajaxLoader.hide();
			compareButton.show();
		});
		return false;
	};

	var dropBaseline = function(baselineRow, target) {

		var extractMetaInfo = function(row) {
			row = $(row);
			var metaData = row.find(".metaData");
			if (metaData.length > 0) {
				return {
					id: metaData.data("baseline-id"),
					timestamp: metaData.data("baseline-created-timestamp"),
					date: metaData.data("baseline-created-date"),
					name: metaData.data("baseline-name"),
					url: metaData.data("baseline-url"),
					description: metaData.data("baseline-description"),
					parentTypeId: metaData.data("baseline-parent"),
					source: metaData.data("baseline-source")
				};
			} else {
				return {
					id: row.find(".id").text(),
					timestamp: row.find(".timestamp").text(),
					date: row.find(".date").html(),
					name: row.find(".name").html(),
					url: row.find(".name").prop("href"),
					description: row.find(".description").html(),
					parentTypeId: row.find(".parentTypeId").html(),
					source: row.find(".source").html()
				}
			}
		};

		var adjustButtons = function(baseline, nowHasTwoSelections) {
			if (baseline.hasClass("leftBaseline")) {
				leftSelectButton.hide();
				placeHolderCompareButton.hide();
				compareButton.show();
			}
			if (baseline.hasClass("rightBaseline")) {
				rightSelectButton.hide();
				placeHolderCompareButton.hide();
				compareButton.show();
			}
			if (nowHasTwoSelections) {
				compareButton.show();
				compareButton.prop("disabled", false).prop("title", compareButton.data("title-for-enabled-state"));
				dropHint.hide();
			}
		};

		var touch = function(baseline) {
			baselines.removeClass("latest");
			baseline.addClass("notEmpty latest");
		};

		var update = function(baseline, data) {
			for (var key in data) {
				var value = data[key];
				if (!value) {
					value = (key === "id" || key === "timestamp") ? "" : "&nbsp;";
				}
				var elem = baseline.find("." + key);
				elem.html(value);
				if (key === "name") {
					elem.prop("href", data["url"]);
				} else if (key === "description" || key === "source") {
					elem.toggle($.trim(elem.text()) != ""); // .text() works well even with html nbsp entities
				}
			}
			touch(baseline);
		};

		var swap = function(a, b) {
			var aInfo = extractMetaInfo(a);
			var bInfo = extractMetaInfo(b);
			update(a, bInfo);
			update(b, aInfo);
		};

		var info = extractMetaInfo(baselineRow);

		var notEmptyBaselines = baselines.filter(".notEmpty");
		var noSelectionYet = notEmptyBaselines.length == 0;
		var oneSelectionYet = notEmptyBaselines.length == 1;

		var targetBaseline;

		if (target == "left") {
			console.debug("Select left baseline by button");
			targetBaseline = leftBaseline;
		} else if (target == "right") {
			console.debug("Select right baseline by button");
			targetBaseline = rightBaseline;
		} else {
			if (noSelectionYet) {
				console.debug("Was not selection yet, updating left baseline");
				targetBaseline = leftBaseline;
			} else if (oneSelectionYet) {
				console.debug("Already was one selection, updating non-empty baseline");
				targetBaseline = baselines.not(notEmptyBaselines);
			} else {
				console.debug("Were two selections, updating latest one");
				targetBaseline = baselines.not(".latest");
			}
		}

		$(targetBaseline).closest(".baselineListWrapper").removeClass("noSelectionYet").addClass("atLeastOneSelection");

		var otherBaseline = baselines.not(targetBaseline);

		var duplicate = false;
		notEmptyBaselines.each(function() {
			var bl = $(this);
			if (getId(bl) == info.id) {
				duplicate = true;
			}
		});
		if (duplicate) {
			alert(i18n.message("project.baseline.duplicatedSelection"));
			return false;
		}

		update(targetBaseline, info);

		var nowHasTwoSelections = baselines.filter(".notEmpty").length == 2;
		var baselineLastUpdated = targetBaseline;

		if (nowHasTwoSelections && getTimestamp(leftBaseline) > getTimestamp(rightBaseline)) {
			console.debug(getTimestamp(leftBaseline) + " > " + getTimestamp(rightBaseline) + ", swapping them");
			swap(leftBaseline, rightBaseline);
			baselineLastUpdated = otherBaseline;
			touch(otherBaseline);
		}

		baselineLastUpdated.one("webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend", function(e) {
			baselineLastUpdated.css("background-color", "");
		});
		setTimeout(function() {
			baselineLastUpdated.css("background-color", "yellow");
		}, 100);

		adjustButtons(targetBaseline, nowHasTwoSelections);
		fixHeights();

		return true;
	};

	var fixHeights = function() {
		var leftTable = leftBaseline.filter(".notEmpty").find(".selectedBaselineInfo");
		var rightTable = rightBaseline.filter(".notEmpty").find(".selectedBaselineInfo");
		var leftHeight = leftTable.height();
		var rightHeight = rightTable.height();
		var maxHeight = leftHeight && rightHeight ? Math.max(leftHeight, rightHeight) : "auto";

		// if there isn't any baseline selected for comparison then return
		if (!leftHeight && !rightHeight) {
			return;
		}

		leftTable.add(rightTable).css("height", maxHeight);

		// fix droparea layout, too
		var dropAreaPaddingTop =  parseInt(dropArea.css('padding-top'));
		var dropAreaExtraClearance = Math.min(leftHeight, rightHeight) === 0 ? 60 : 0;
		var dropAreaHeight = compareButton.position().top + compareButton.outerHeight() + dropAreaPaddingTop - dropAreaExtraClearance;

		// If at least one panel has a baseline selected, then add extra padding otherwise the baseline list would scoll just below the action buttons
		if (Math.min(leftHeight, rightHeight) === 0 ) {
			// Substract the padding added earlier
			dropAreaHeight = dropAreaHeight + 60;
			dropArea.css("padding-bottom", 60);
		} else {
			dropArea.css("padding-bottom", 0);
		}

		dropArea.css("margin-top", -dropAreaHeight);
		filter.css("margin-top", dropAreaHeight);
	};

	var getId = function(baseline) {
		return baseline.find(".id").text() || 0;
	};

	var getTimestamp = function(baseline) {
		return baseline.find(".timestamp").text() || 0;
	};

	/**
	 * Selects a specified baseline for comparison.
	 * @param baselineId Baseline ID or 0 to indicate HEAD revision
	 */
	var addToComparison = function(baselineId) {
		var metaDatas = baselineTable.find(".metaData");
		for (var i = 0; i < metaDatas.length; i++) {
			var metaData = $(metaDatas[i]);
			var rowId = metaData.data("baseline-id") || 0;
			if (rowId == baselineId) {
				var row = metaData.closest("tr");
				dropBaseline(row);
				return ;
			}
		}
	};

	/**
	 * Select two baselines by their ID and automatically initiate a comparison action.
	 * @param baseline1 ID of baseline 1
	 * @param baseline2 ID of baseline 2
	 */
	var selectAndCompareBaselines = function(baseline1, baseline2) {
		addToComparison(baseline1);
		addToComparison(baseline2);
		compareSelectedBaselines();
	};

	var addBaselineFromPopup = function(root, baseline, selectionSide) {
		initVariables(root);
		return dropBaseline(baseline, selectionSide);
	};

	var initBaselineDescriptions = function() {
		$(document).tooltip({
			items: '.description-placeholder',
			tooltipClass: 'baseline-ui-tooltip',
			content: function() {
				var element = $(this).siblings('div.baseline-description');
				return element.html();
			}
		});
	}

	var showBaselineInProgressMessage = function (failed) {
		if (failed) {
			showFancyAlertDialog(i18n.message("baseline.creation.failed.message"));
		} else {
			showFancyAlertDialog(i18n.message("baseline.creation.inprogress.message"));
		}
	};

	return {
		init: init,
		addToComparison: addToComparison,
		addBaselineFromPopup : addBaselineFromPopup,
		selectAndCompareBaselines: selectAndCompareBaselines,
		initBaselineDescriptions: initBaselineDescriptions,
		showBaselineInProgressMessage: showBaselineInProgressMessage
	};
})(jQuery);
