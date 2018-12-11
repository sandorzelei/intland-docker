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
codebeamer.Traceability = codebeamer.Traceability || (function($) {

	var config = {};

	var draggableSettings = {
		helper: "clone",
		zIndex: 100,
		delay: 300,
		start: function(e, ui) {
			removeResultFromLevel($(this).closest(".levelContainer").find(".addButton"));
			var $droppableLevels = getDroppableLevels($(this));
			$droppableLevels.addClass("highlighted");
			$(this).hide();
		},
		stop: function(e, ui) {
			$(".levelContainer").removeClass("highlighted");
			$(this).show();
			//cleanupLevels();
		}
	};

	var droppableSettings = {
		accept: ".entityContainer",
		hoverClass: "dropHover",
		drop: function(e, ui) {
			var $level = $(this);
			var $droppableLevels = getDroppableLevels(ui.draggable);
			if ($droppableLevels.filter(function() { return this == $level.get(0); }).length > 0) {
				var $addButton = $level.find(".addButton");
				ui.draggable.detach().insertBefore($addButton);
				extendLevels($addButton);
				$(".controlContainer .addButton").show();
				if ($addButton.prev(".entityContainer").data("id") == "all") {
					$addButton.closest(".levelContainer").find(".entityContainer:not(.all)").remove();
					$addButton.hide();
				}
				removeResultFromLevel($addButton);
			}
		}
	};

	var loadTrackerItemTraceability = function($cont, itemId, baselineId, callback, isTestRun) {
		var $showAssociationCheckbox = $("#itemTraceabilityShowAssociations");
		var $showDescriptionCheckbox = $("#itemTraceabilityShowDescription");
		var $showSCMCheckbox = $("#itemTraceabilityShowSCM");
		var $ignoreRedundantsCheckbox = $("#itemTraceabilityIgnoreRedundants");
		var $depthSelector = $("#itemTraceabilityDepthSelector");

		var load = function(showAssociation, showDescription, showSCM, ignoreRedundants, depth) {
			var busySign = ajaxBusyIndicator.showBusysign($cont);
			$showAssociationCheckbox.prop("disabled", true);
			if (!isTestRun) {
				$showDescriptionCheckbox.prop("disabled", true);
				$showSCMCheckbox.prop("disabled", true);
			}
			$ignoreRedundantsCheckbox.prop("disabled", true);
			$depthSelector.prop("disabled", true);
			var url = contextPath + "/proj/tracker/loadItemTraceability.spr?itemId=" + itemId + (baselineId ? ("&baselineId=" + baselineId) : "");
			if (typeof showAssociation !== 'undefined') {
				url += "&showAssociations=" + (showAssociation ? "true" : "false");
			}
			if (!isTestRun) {
				if (typeof showDescription !== 'undefined') {
					url += "&showDescription=" + (showDescription ? "true" : "false");
				}
				if (typeof showSCM !== 'undefined') {
					url += "&showSCM=" + (showSCM ? "true" : "false");
				}
			}
			if (typeof ignoreRedundants !== 'undefined') {
				url += "&ignoreRedundants=" + (ignoreRedundants ? "true" : "false");
			}
			if (typeof depth !== 'undefined') {
				url += "&depth=" + depth;
			}
			$.ajax(url, {
				type: "GET"
			}).success(function(result) {
				$cont.html(result);
				$showAssociationCheckbox.prop("disabled", false);
				if (!isTestRun) {
					$showDescriptionCheckbox.prop("disabled", false);
					$showSCMCheckbox.prop("disabled", false);
				}
				$ignoreRedundantsCheckbox.prop("disabled", false);
				$depthSelector.prop("disabled", false);
				ajaxBusyIndicator.close(busySign);
				if (callback) {
					callback();
				}
			}).fail(function() {
				ajaxBusyIndicator.close(busySign);
				showFancyAlertDialog(i18n.message("tracker.item.traceability.fail.warning"));
			});
		};

		// Load Traceability tables via AJAX if not yet loaded.
		if ($cont.children().length == 0) {
			load();
		}

		$showAssociationCheckbox.off("change");
		$showAssociationCheckbox.change(function() {
			load($(this).is(":checked"), $showDescriptionCheckbox.is(":checked"), $showSCMCheckbox.is(":checked"), $ignoreRedundantsCheckbox.is(":checked"), $depthSelector.val());
		});

		if (!isTestRun) {
			$showDescriptionCheckbox.off("change");
			$showDescriptionCheckbox.change(function() {
				load($showAssociationCheckbox.is(":checked"), $(this).is(":checked"), $showSCMCheckbox.is(":checked"), $ignoreRedundantsCheckbox.is(":checked"), $depthSelector.val());
			});

			$showSCMCheckbox.off("change");
			$showSCMCheckbox.change(function() {
				load($showAssociationCheckbox.is(":checked"), $showDescriptionCheckbox.is(":checked"), $(this).is(":checked"), $ignoreRedundantsCheckbox.is(":checked"), $depthSelector.val());
			});
		}

		$ignoreRedundantsCheckbox.off("change");
		$ignoreRedundantsCheckbox.change(function() {
			load($showAssociationCheckbox.is(":checked"), $showDescriptionCheckbox.is(":checked"), $showSCMCheckbox.is(":checked"), $(this).is(":checked"), $depthSelector.val());
		});

		$depthSelector.off("change");
		$depthSelector.change(function() {
			load($showAssociationCheckbox.is(":checked"), $showDescriptionCheckbox.is(":checked"), $showSCMCheckbox.is(":checked"), $ignoreRedundantsCheckbox.is(":checked"), $(this).val());
		});

	};

	var setStickyHeader = function() {
		$(window).scroll(function(){
			var $tableHeader = $(".traceabilityBrowserPluginTable.tb").find('thead tr.traceabilityHeaderRow');
			if ($tableHeader.length > 0) {
				var thWidths = [];
				$tableHeader.find("th").each(function() {
					thWidths.push($(this).width());
				});
				var $tableHeaderOffset = $tableHeader.offset().top;
				var scrollTop = $(window).scrollTop();
				if (scrollTop >= $tableHeaderOffset) {
					var scrollLeft = $(window).scrollLeft();
					var $existingStickyTableHeader = $(".traceabilityBrowserCont.stickyTableHeader");
					if ($existingStickyTableHeader.length == 0) {
						var $stickyTableHeader = $tableHeader.clone();
						$stickyTableHeader.find(".levelReferenceSetting").css("visibility", "hidden");
						var $stickyTable = $("<table>", { "class" : "traceabilityBrowserPluginTable tb"});
						$stickyTable.append($("<thead>").append($stickyTableHeader));
						$stickyTable.find("th").each(function(index) {
							$(this).css("width", thWidths[index]);
						});
						var $stickyTableCont = $("<div>", { "class" : "stickyTableHeader traceabilityBrowserCont"});
						$stickyTableCont.append($stickyTable);
						$stickyTableCont.css("left", scrollLeft * -1);
						$("body").append($stickyTableCont);
					} else {
						$existingStickyTableHeader.css("left", scrollLeft * -1);
					}
				} else {
					$(".traceabilityBrowserCont.stickyTableHeader").remove();
				}
			}
		});
	};

	var highlightCells = function($table) {

		var countColumns = function($tr) {
			var count = 0;
			$($tr.children(':not(.referencingTrackers)')).each(function () {
				if ($(this).attr('colspan')) {
					count += +$(this).attr('colspan');
				} else {
					count++;
				}
			});
			return count;
		};

		var hoverTds = function($tr, n) {
			var maxColumn = countColumns($tr.closest('table:not(.referencingTrackers)').find('tr:first'));
			$tr.find('td[rowspan]:not(.referencingTrackers)').slice(0,n).addClass("hover");
			if (countColumns($tr) < maxColumn) {
				hoverTds($tr.prevAll('tr:has(td[rowspan]:not(.referencingTrackers)):first'), maxColumn - countColumns($tr));
			}
		};

		var getHoverTds = function($td) {
			return $td.siblings(':not(.referencingTrackers)').andSelf();
		};

		var getHoverNextTds = function($td) {
			var tr = $td.parent();
			var tdRowspan = $td.attr('rowspan');
			var nextTds = $();
			if (typeof tdRowspan !== "undefined") {
				var nextTrs = tr.nextAll('tr').slice(0, tdRowspan - 1);
				nextTds = nextTrs.find('td:not(.referencingTrackers)');
			}
			return nextTds;
		};

		$table.on('mouseenter', 'td:not(.referencingTrackers)', function() {
			getHoverTds($(this)).addClass('hover');
			getHoverNextTds($(this)).addClass('hover');
			var td = $(this);
			var maxColumn = countColumns(td.closest('table:not(.referencingTrackers)').find('tr:first'));
			if (countColumns(td.parent()) < maxColumn ) {
				hoverTds(td.parent().prevAll('tr:has(td[rowspan]:not(.referencingTrackers)):first'), maxColumn - countColumns(td.parent()));
			}
		});

		$table.on('mouseleave', 'td:not(.referencingTrackers)', function() {
			getHoverTds($(this)).removeClass('hover');
			getHoverNextTds($(this)).removeClass('hover');
			$(this).parent().prevAll('tr:has(td[rowspan]:not(.referencingTrackers))').find('td[rowspan]:not(.referencingTrackers)').removeClass("hover");
		});

	};

	var extendLevels = function($addButton) {
		var $tr = $addButton.closest("tr");
		var $table = $(".controlContainer table.levelsTable");
		var $lastTr = $table.find("tr.levelTr").last();
		if ($lastTr.get(0) == $tr.get(0)) {
			var $newTr = $lastTr.clone();
			$newTr.find(".addButton").removeClass("context-menu-active");
			$newTr.find(".entityContainer").remove();
			$newTr.find(".levelContainer").droppable(droppableSettings);
			var index = parseInt($newTr.find(".number").text(), 10);
			$newTr.find(".number").text(index + 1);
			$table.append($newTr);
		}
	};

	var cleanupLevels = function() {
		var $levels = $(".levelContainer.droppable");
		var $lastLevel = $levels.last();
		$levels.each(function() {
			if ($(this).get(0) != $lastLevel.get(0) && $(this).find(".entityContainer:not(.ui-draggable-dragging)").length == 0) {
				$(this).closest("tr").remove();
			}
		});
		var index = 1;
		$(".levelContainer.droppable").each(function() {
			$(this).closest("tr").find(".number").text(index);
			index++;
		});
	};

	var getDroppableLevels = function($entity) {
		var $droppableLevels = $();
		$(".levelContainer.droppable").each(function() {
			var $entities = $(this).find(".entityContainer");
			var ids = [];
			$entities.each(function() {
				ids.push($(this).data("id"));
			});
			if ($.inArray("all", ids) === -1 && $.inArray($entity.data("id"), ids) === -1) {
				$droppableLevels = $droppableLevels.add($(this));
			}
		});
		return $droppableLevels;
	};

	var removeResultFromLevel = function($addButton) {
		$addButton.closest("tr").removeClass("ignoredLevel");
		$addButton.closest(".levelContainer").find(".numberOfItems").hide();
	};

	var toggleNoFollowWarning = function($addButton) {
		if (config.hasOwnProperty("excludePreviousLevelTypeIds")) {
			var selectedTypes = [];
			$addButton.closest(".levelsTable").find(".levelTr:not(.initialTrackers)").each(function() {
				$(this).find(".entityContainer").each(function() {
					var trackerTypeId = $(this).data("trackerTypeId");
					if ($(this).data("id") !== 0 && trackerTypeId) {
						selectedTypes.push(parseInt(trackerTypeId, 10));
					}
				});
			});
			var showNoFollowWarning = false;
			if (selectedTypes.length > 0) {
				for (var i = 0; i < selectedTypes.length; i++) {
					var typeId = selectedTypes[i];
					if ($.inArray(typeId, config.excludePreviousLevelTypeIds) > -1) {
						showNoFollowWarning = true;
						break;
					}
				}
			}
			if (showNoFollowWarning) {
				$("#noFollowWarning").fadeIn();
			} else {
				$("#noFollowWarning").fadeOut();
			}
		}
	};

	var addEntityToLevel = function($addButton, name, id, trackerTypeId, iconUrl, isInitial, selectedViewId, selectedBranchId, revision, isInitialization) {

		var addEntity = function() {
			id = parseInt(id, 10);
			var isTracker = id > 1000;

			var $entityContainer = $("<span>", { "class" : "entityContainer" + (isInitial ? "" : " draggable") + (isTracker ? " trackerEntity" : "") });
			$entityContainer.append($("<span>", { "class" : "issueHandle"}));
			var $iconSpan = $("<span>", { "class" : "icon"});
			$iconSpan.append($("<img>", { "src" : iconUrl, "style" : "background-color: #5f5f5f" }));
			$entityContainer.append($iconSpan);
			$entityContainer.append($("<span>", { "class" : "name"}).html(name));

			if (isInitial) {
				var $viewSelect = $("<select>", { "class" : "viewSelector"});
				$viewSelect.append($("<option>", { value: -2 }).text("Select View!"));

				var $defaultViews = $("<optgroup>", { label: i18n.message("report.selector.public.reports.label")});
				for (var i = 0; i < config.defaultViews.length; i++) {
					var view = config.defaultViews[i];
					$defaultViews.append($("<option>", { "class" : "defaultView", value: view.id }).text(view.name));
				}
				$viewSelect.append($defaultViews);
				$viewSelect.val(selectedViewId ? selectedViewId : -2);

				$.getJSON(contextPath + "/reportselector/loadReports.spr", { trackerId: id }).done(function(result) {
					if (result.hasOwnProperty("public") && result["public"].length > 0) {
						for (var i = 0; i < result["public"].length; i++) {
							var publicCustomView = result["public"][i];
							$defaultViews.append($("<option>", { value: publicCustomView.id }).text(publicCustomView.name));
						}
					}
					if (result.hasOwnProperty("own") && result["own"].length > 0) {
                        var $ownViews = $("<optgroup>", { label: i18n.message("report.selector.private.reports.label") });
						for (var i = 0; i <  result["own"].length; i++) {
							var customView =  result["own"][i];
                            $ownViews.append($("<option>", { value: customView.id }).text(customView.name));
						}
						$viewSelect.append($ownViews);
					}
					var $selectedOption = $viewSelect.find('option[value="' + selectedViewId + '"]');
					$viewSelect.val($selectedOption.length > 0 ? selectedViewId : -2);
				});

				$entityContainer.append($viewSelect);

				var $branchSelect = $("<select>", { "class" : "branchSelector"});
				$.getJSON(contextPath + "/ajax/traceabilitybrowser/getBranches.spr", { trackerId: id }).done(function(result) {
					$branchSelect.append($("<option>", { value: 0}).text(i18n.message("tracker.branching.master.name")));
					for (var i = 0; i < result.length; i++) {
						var branch = result[i];
						var $option = $("<option>", { value: branch.id, "class": "branchTracker level-" + branch.level}).text(branch.name);
						$branchSelect.append($option);
					}
					if (result.length == 0) {
						$branchSelect.css("display", "none");
					}
					if (selectedBranchId) {
						$branchSelect.val(selectedBranchId);
					} else {
						$branchSelect.val("0");
					}
					$branchSelect.change();
					$branchSelect.multiselect("refresh");
				});

				$entityContainer.append($branchSelect);
				$branchSelect.multiselect({
					"classes" : "branchSelector",
					multiple: false,
					"selectedText": function(numChecked, numTotal, checked) {
						var value = [];
						$(checked).each(function(){
							value.push($(this).next().html());
						});
						return value[0];
					}
				}).multiselectfilter({
					label: "",
					placeholder: i18n.message("Filter")
				});

				if (revision != null) {
					$viewSelect.hide();
					$branchSelect.hide();
				}

			}

			$entityContainer.append($("<span>", { "class" : "deleteButton"}));
			$entityContainer.data("id", id);
			$entityContainer.data("trackerTypeId", trackerTypeId);
			$addButton.before($entityContainer);
			if (!isInitial) {
				$entityContainer.draggable(draggableSettings);
			}

			// If only one Initial Tracker exists and this is changed, reload the page to provide project and tracker context
			if (!isInitialization && config.trackerId != id && isInitial && $addButton.closest(".levelContainer").find(".entityContainer").length == 1) {
				window.location.href = contextPath + "/proj/tracker/traceabilitybrowser.spr?tracker_id=" + id + "&view_id=-2";
			}

			removeResultFromLevel($addButton);
			extendLevels($addButton);
			toggleNoFollowWarning($addButton);
		};

		// If only one Initial Tracker exists and this is changed, show a warning message about page reload
		if (!isInitialization && config.trackerId != id && isInitial && $addButton.closest(".levelContainer").find(".entityContainer").length == 0) {
			showFancyConfirmDialogWithCallbacks(i18n.message("tracker.traceability.browser.reload.warning"), function() {
				addEntity();
			});
		} else {
			addEntity();
		}
	};

	var addAllEntityToLevel = function($addButton) {
		var $entityContainer = $("<span>", { "class" : "entityContainer draggable all" });
		$entityContainer.append($("<span>", { "class" : "issueHandle"}));
		var $iconSpan = $("<span>", { "class" : "icon"});
		$entityContainer.append($iconSpan);
		$entityContainer.append($("<span>", { "class" : "name"}).text("All"));
		$entityContainer.append($("<span>", { "class" : "deleteButton"}));
		$entityContainer.data("id", 0);
		$addButton.closest(".levelContainer").find(".entityContainer").remove();
		$addButton.before($entityContainer);
		extendLevels($addButton);
		$addButton.hide();
		$entityContainer.draggable(draggableSettings);
		toggleNoFollowWarning($addButton);
	};

	var initAddCustomTrackerDialog = function() {
		var $dialog = $("#traceabilityAddCustomTrackerDialog");
		var $projectSelector = $dialog.find(".project");
		var $trackerSelectorHelper = $dialog.find(".trackerSelectorHelper");
		var $trackerSelector = $dialog.find(".tracker");
		$projectSelector.change(function() {
			var projectId = $(this).val();
			$trackerSelector.empty();
			$trackerSelector.append($trackerSelectorHelper.find('option[data-project-id="' + projectId + '"]').clone());
		});
		$dialog.dialog({
			autoOpen: false,
			dialogClass: 'popup',
			modal: true,
			width: "auto",
			buttons: [{
				text: i18n.message("button.ok"),
				"class": "button",
				click: function() {
					var $projectSelector = $(this).find(".project");
					var projectName = $projectSelector.find('option[value="' + $projectSelector.val() + '"]').text();
					var $trackerSelector = $(this).find(".tracker");
					var trackerId = $trackerSelector.val();
					var $tracker = $trackerSelector.find('option[value="' + trackerId + '"]');
					var trackerName = $.trim($tracker.text());
					var iconUrl = contextPath + $tracker.attr("data-icon-url");
					var trackerTypeId = $tracker.attr("data-tracker-type-id");
					addEntityToLevel($dialog.data("addButton"), projectName + " → " + trackerName, trackerId, trackerTypeId, iconUrl, $dialog.data("isInitial"));
					$(this).dialog("close");
				}
			}, {
				text: i18n.message("button.cancel"),
				"class": "button cancelButton",
				click: function() {
					$(this).dialog("close");
				}
			}]
		});
	};

	var addCustomTracker = function($addButton) {

		var $dialog = $("#traceabilityAddCustomTrackerDialog");
		$dialog.data("addButton", $addButton);
		$dialog.data("isInitial", $addButton.hasClass("addInitialButton"));
		var $projectSelector = $dialog.find(".project");
		var $trackerSelector = $dialog.find(".tracker");
		var $trackerSelectorHelper = $dialog.find(".trackerSelectorHelper");

		$projectSelector.empty();
		$trackerSelector.empty();
		$trackerSelectorHelper.empty();

		var busy = ajaxBusyIndicator.showBusyPage();
		$.getJSON(config.addCustomTrackerUrl, { trackerId: config.trackerId, initial : $dialog.data("isInitial") }).done(function(result) {

			var $recentProjectGroup = $("<optgroup>", { label: i18n.message("recent.projects.label") });
			for (var i = 0; i < result.recentProjects.length; i++) {
				var project = result.recentProjects[i];
				$recentProjectGroup.append($("<option>", { value: project.id }).text(project.name));
			}
			$projectSelector.append($recentProjectGroup);

			var $otherProjectGroup = $("<optgroup>", { label: i18n.message("Projects") });
			for (var i = 0; i < result.projects.length; i++) {
				var project = result.projects[i];
				$otherProjectGroup.append($("<option>", { value: project.id }).text(project.name));
			}
			$projectSelector.append($otherProjectGroup);

			for (var i = 0; i < result.trackers.length; i++) {
				var tracker = result.trackers[i];
				var name = "";
				if (tracker.isBranch) {
					for (var n = 0; n < (tracker.branchLevel * 5); n++) {
						name += "&nbsp;";
					}
				}
				name += tracker.name;
				$trackerSelectorHelper.append($("<option>", {
					value: tracker.id,
					"class" : tracker.isBranch ? "branchTracker" : "",
					"data-project-id": tracker.projectId,
					"data-tracker-type-id": tracker.trackerTypeId,
					"data-icon-url" : tracker.iconUrl
				}).html(name));
			}

			ajaxBusyIndicator.close(busy);

			$dialog.dialog("open");
			$projectSelector.change();

		});
	};

	var initContextMenus = function(initialMenuItems, trackerTypeItems, trackerItems) {
		var initialMenu = new ContextMenuManager({
			selector: ".controlContainer .addInitialButton",
			trigger: "left",
			className: "traceabilityContextMenu",
			build: function($triggerElement, e) {
				var existingEntities = [];
				$triggerElement.closest(".levelContainer").find(".entityContainer").each(function() {
					existingEntities.push($(this).find(".name").text());
				});
				for (var key in initialMenuItems) {
					initialMenuItems[key].disabled = $.inArray(key, existingEntities) > -1;
				}
				return {
					items: initialMenuItems
				}
			}
		});
		initialMenu.render();
		var menu = new ContextMenuManager( {
			selector: ".controlContainer .addButton",
			trigger: "left",
			className: "traceabilityContextMenu",
			build: function($triggerElement, e) {
				var items = {
					"trackers" : {
						name: i18n.message("tracker.traceability.browser.trackers.of.current"),
						items: trackerItems
					},
					"trackerTypes" : {
						name: i18n.message("tracker.traceability.browser.trackers.types.of.all"),
						items: trackerTypeItems
					},
					"separator1" : "------",
					"addCustomTracker": {
						name: i18n.message("tracker.traceability.browser.custom.tracker"),
						callback: function(key, opt) {
							addCustomTracker($(this));
						}
					},
					"separator2" : "------",
					"all": {
						name: i18n.message("tracker.traceability.browser.all"),
						callback: function(key, opt) {
							addAllEntityToLevel($(this));
						}
					}
				};
				var existingEntities = [];
				$triggerElement.closest(".levelContainer").find(".entityContainer").each(function() {
					existingEntities.push($(this).find(".name").text() + '-' + $(this).data('id'));
				});

				for (var key in items["trackers"].items) {
					items["trackers"].items[key].disabled = $.inArray(key, existingEntities) > -1;
				}
				for (var key in items["trackerTypes"].items) {
					items["trackerTypes"].items[key].disabled = $.inArray(key, existingEntities) > -1;
				}
				return {
					items: items
				};
			}
		});
		menu.render();
	};

	var initControls = function(initialTrackerList, trackerList, revision) {

		var initCurrentControls = function(initialTrackerList, trackerList) {
			if (initialTrackerList.length > 0) {
				var $initialAddButton = $(".controlContainer .initialTrackers .addInitialButton");
				for (var i=0; i < initialTrackerList.length; i++) {
					var parameter = initialTrackerList[i];
					addEntityToLevel($initialAddButton, parameter.name, parameter.id, parameter.trackerTypeId, parameter.iconUrl, true, parameter.viewId, parameter.branchId, revision, true);
				}
			}
			if (trackerList.length > 0) {
				for (var i=0; i < trackerList.length; i++) {
					var level = trackerList[i];
					var $addButton = $(".controlContainer .addButton").last();
					for (var j=0; j < level.length; j++) {
						var parameter = level[j];
						if (parameter.isAll) {
							addAllEntityToLevel($addButton);
						} else {
							addEntityToLevel($addButton, parameter.name, parameter.id, parameter.trackerTypeId, parameter.iconUrl, false);
						}
					}
				}
			}
		};

		var initRemoveButtons = function() {
			$(".controlContainer").on("click", ".deleteButton", function(e) {
				// Remove entity
				var $button = $(e.target);
				var $tr = $button.closest("tr");
				var $addButton = $tr.find(".addButton");
				$addButton.show();
				$button.closest(".entityContainer").remove();
				removeResultFromLevel($addButton);
				toggleNoFollowWarning($addButton);
				//cleanupLevels();
			});
		};

		var initDroppable = function() {
			$(".levelContainer.droppable").droppable(droppableSettings);
		};

		var initFilterSwitcher = function() {
			$(".switchToFilter").click(function() {
				$(".initialFilter").show();
				$(".initialTrackers").hide();
			});
			$(".switchToTrackers").click(function() {
				$(".initialFilter").hide();
				$(".initialTrackers").show();
			});
		};

		initCurrentControls(initialTrackerList, trackerList);
		initRemoveButtons();
		initDroppable();
		initFilterSwitcher();

	};

	var initSuggestedArea = function() {
		$("#referencingTypes a").click(function() {
			addEntityFromSuggestedArea($(this));
		});
	};

	var addEntityFromSuggestedArea = function($element) {
		var $addButton = $(".controlContainer .addButton").last();
		var $tr = $element.closest("tr");
		var label = $element.text();
		var iconUrl = $tr.find(".refCode img").first().attr("src");
		var id = $element.attr("data-id");
		var trackerTypeId = $element.attr("data-tracker-type-id");
		addEntityToLevel($addButton, label, id, trackerTypeId, iconUrl, false);
		$("#selectButton").click();
	};

	var getTrackerList = function() {
		var trackerList = "";
		$(".controlContainer .levelContainer.droppable").each(function() {
			var level = "";
			$(this).find(".entityContainer").each(function() {
				level += $(this).data("id") + " ";
			});
			level = level.replace(/\ +$/, '');
			trackerList += level + ",";
		});
		trackerList = trackerList.replace(/\,+$/, '');
		return trackerList;
	};

	var getInitialTrackerList = function() {
		var trackerList = "";
		$(".controlContainer .initialTrackers .levelContainer").each(function() {
			$(this).find(".entityContainer").each(function() {
				trackerList += $(this).data("id") + " ";
				trackerList += "" + (config.revisionId ? "-2" : $(this).find(".viewSelector").val());
				if ($(this).find(".branchSelector").is(":visible")) {
					var branchValue = $(this).find(".branchSelector").val();
					if (branchValue != "0") {
						trackerList += " " + branchValue;
					}
				}
				trackerList += ",";
			});
		});
		trackerList = trackerList.replace(/\,+$/, '');
		return trackerList;
	};

	var getLevelReferenceTypes = function() {
		var result = [];
		$("#traceabilityPlugin_UI").find(".levelReferenceSetting").each(function() {
			if ($(this).attr("data-default") === "false") {
				result.push($(this).attr("data-index") + "-" +
					($(this).attr("data-assocIn") == "true" ? 1 : 0) +
					($(this).attr("data-assocOut") == "true" ? 1 : 0) +
					($(this).attr("data-refIn") == "true" ? 1 : 0) +
					($(this).attr("data-refOut") == "true" ? 1 : 0) +
					($(this).attr("data-folder") == "true" ? 0 : 1) +
					($(this).attr("data-child") == "true" ? 1 : 0));
			}
		});
		return result.join(",");
	};

	function initReferenceTypeSelectors($container) {

		$container.on("click", ".levelReferenceSetting", function() {
			$(".levelSettingContainer").remove(); // remove others from the screen
			var $levelSettingSign = $(this);

			var $settingCont = $("<div>", { "class" : "levelSettingContainer"});

			var $assoc = $("<div>", { "class": "levelSettingTitle"}).text(i18n.message("tracker.traceability.browser.show.associations"));
			$assoc.append($("<input>", { type: "checkbox", id: "levelSetting_assoc_incoming", checked: $levelSettingSign.attr("data-assocIn") == "true"}));
			$assoc.append($("<label>", { "for": "levelSetting_assoc_incoming"}).text(i18n.message("tracker.traceability.browser.incoming")));
			$assoc.append($("<input>", { type: "checkbox", id: "levelSetting_assoc_outgoing", checked: $levelSettingSign.attr("data-assocOut") == "true"}));
			$assoc.append($("<label>", { "for": "levelSetting_assoc_outgoing"}).text(i18n.message("tracker.traceability.browser.outgoing")));
			$settingCont.append($assoc);

			var $ref = $("<div>", { "class": "levelSettingTitle"}).text(i18n.message("tracker.traceability.browser.show.relations"));
			$ref.append($("<input>", { type: "checkbox", id: "levelSetting_ref_incoming", checked: $levelSettingSign.attr("data-refIn") == "true"}));
			$ref.append($("<label>", { "for": "levelSetting_ref_incoming"}).text(i18n.message("tracker.traceability.browser.incoming")));
			$ref.append($("<input>", { type: "checkbox", id: "levelSetting_ref_outgoing", checked: $levelSettingSign.attr("data-refOut") == "true"}));
			$ref.append($("<label>", { "for": "levelSetting_ref_outgoing"}).text(i18n.message("tracker.traceability.browser.outgoing")));
			$settingCont.append($ref);

			var $other = $("<div>", { "class": "levelSettingTitle"});
			$other.append($("<input>", { type: "checkbox", id: "levelSetting_folder", checked: $levelSettingSign.attr("data-folder") == "true"}));
			$other.append($("<label>", { "for": "levelSetting_folder"}).text(i18n.message("tracker.traceability.browser.show.folders")));
			$other.append($("<br>"));
			$other.append($("<input>", { type: "checkbox", id: "levelSetting_child", checked: $levelSettingSign.attr("data-child") == "true"}));
			$other.append($("<label>", { "for": "levelSetting_child"}).text(i18n.message("tracker.traceability.browser.show.children")));
			$settingCont.append($other);

			var $okButton = $("<button>",{ "class": "button"}).text(i18n.message("button.ok"));
			$okButton.click(function() {
				var $cont = $(this).closest(".levelSettingContainer");
				var assocIn = $cont.find("#levelSetting_assoc_incoming").prop("checked") == true;
				var assocOut = $cont.find("#levelSetting_assoc_outgoing").prop("checked") == true;
				var refIn = $cont.find("#levelSetting_ref_incoming").prop("checked") == true;
				var refOut = $cont.find("#levelSetting_ref_outgoing").prop("checked") == true;
				var folder = $cont.find("#levelSetting_folder").prop("checked") == true;
				var child = $cont.find("#levelSetting_child").prop("checked") == true;
				var originalAssocIn = $levelSettingSign.attr("data-assocIn") == "true";
				var originalAssocOut = $levelSettingSign.attr("data-assocOut") == "true";
				var originalRefIn = $levelSettingSign.attr("data-refIn") == "true";
				var originalRefOut = $levelSettingSign.attr("data-refOut") == "true";
				var originalFolder = $levelSettingSign.attr("data-folder") == "true";
				var originalChild = $levelSettingSign.attr("data-child") == "true";
				if (assocIn != originalAssocIn || assocOut != originalAssocOut ||
					refIn != originalRefIn || refOut != originalRefOut ||
					folder != originalFolder || child != originalChild) {
					$levelSettingSign.attr("data-default", "false");
					$levelSettingSign.attr("data-assocIn", assocIn ? "true" : "false");
					$levelSettingSign.attr("data-assocOut", assocOut ? "true" : "false");
					$levelSettingSign.attr("data-refIn", refIn ? "true" : "false");
					$levelSettingSign.attr("data-refOut", refOut ? "true" : "false");
					$levelSettingSign.attr("data-folder", folder ? "true" : "false");
					$levelSettingSign.attr("data-child", child ? "true" : "false");
					showBrowser();
				}
				$(this).closest(".levelSettingContainer").remove();
			});
			$settingCont.append($okButton);

			var $cancelButton = $("<button>", { "class": "button cancelButton"}).text(i18n.message("button.cancel"));
			$cancelButton.click(function() {
				$(this).closest(".levelSettingContainer").remove();
			});
			$settingCont.append($cancelButton);

			$("body").append($settingCont);
			$settingCont.position({
				of: $levelSettingSign,
				my: "left top",
				at: "left bottom",
				collision: "flipfit"
			});

			return false;
		});
	}

	var setTabArrowHeight = function() {
		var $box = $("#relations-box");
		var $cont = $box.find(".traceabilityBrowserCont").first();
		$box.find(".traceabilityTabTopArrowPlaceholder").css("height", $cont.height() - 18);
	};

	var initTraceabilityTab = function() {
		$("#relations-box").find(".wikiContent").addClass("traceabilityTabWikiContent");
		setTabArrowHeight();
		$(window).resize(setTabArrowHeight);
	};

	var showBrowser = function(permanent, skipAjaxBusySign) {
        var cbQL = null;
		if (permanent) {
			var currentViewId = config.currentViewId;
			var showAssociations = config.currentShowAssociation;
			var showRelations = config.currentShowRelation;
			var showOutgoingAssociations = config.currentShowOutgoingAssociation;
			var showOutgoingRelations = config.currentShowOutgoingRelation;
			var excludeFolders = config.currentExcludeFolders;
			var showChildren = config.currentShowChildren;
			var showDescription = config.currentShowDescription;
			var ignoreRedundants = config.currentIgnoreRedundants;
			var trackerList = config.currentTrackerList;
			var initialTrackerList = config.currentInitialTrackerList;
			var levelReferenceTypes = config.currentLevelReferenceTypes;
			if (config.currentInitialCbQL !== 'null') {
				cbQL = config.currentInitialCbQL;
			}
		} else {
			var currentViewId = -2;
			var showAssociations = $('#showAssociations').is(':checked') ? 'true' : 'false';
			var showRelations = $('#showRelations').is(':checked') ? 'true' : 'false';
			var showOutgoingAssociations = $('#showOutgoingAssociations').is(':checked') ? 'true' : 'false';
			var showOutgoingRelations = $('#showOutgoingRelations').is(':checked') ? 'true' : 'false';
			var excludeFolders = $('#excludeFolders').is(':checked') ? 'false' : 'true';
			var showChildren = $('#showChildren').is(':checked') ? 'true' : 'false';
			var showDescription = $('#showDescription').is(':checked') ? 'true' : 'false';
			var ignoreRedundants = $('#ignoreRedundants').is(':checked') ? 'true' : 'false';
			var trackerList = getTrackerList();
			var initialTrackerList = getInitialTrackerList();
			var levelReferenceTypes = getLevelReferenceTypes();
		}

		if (!permanent && $(".initialFilter").is(":visible")) {
			var $reportSelector = $(".reportSelectorTag").first();
			var containerId = $reportSelector.attr("id");
			if (codebeamer.ReportSupport.isLogicInvalid(containerId, codebeamer.ReportSupport.logicEnabled(containerId))) {
				return;
			}
			cbQL = codebeamer.ReportSupport.getCbQl(containerId);
		}

		if (cbQL !== null) {
			cbQL = encodeURIComponent(cbQL);
		}

		if (trackerList.length !== 0 && initialTrackerList.length !== 0) {
			var $cont = $(".traceabilityBrowserDataCont");
			$cont.empty();
			if (!skipAjaxBusySign) {
				var busySign = ajaxBusyIndicator.showBusysign($cont);
			}
			var revision = "";
			if (config.revisionId) {
				revision = "&revision=" + config.revisionId;
			}
			$.ajax(encodeURI(contextPath + "/proj/tracker/loadTraceability.spr?tracker_id=" + config.trackerId +"&view_id=" + currentViewId +
				'&trackerList=' + trackerList +
				'&initialTrackerList=' + initialTrackerList +
				(cbQL != null ? '&initialCbQL=' + cbQL : '') +
				'&showIncomingAssociations=' + showAssociations +
				'&showIncomingRelations=' + showRelations +
				'&showOutgoingAssociations=' + showOutgoingAssociations +
				'&showOutgoingRelations=' + showOutgoingRelations +
				'&excludeFoldersAndInformation=' + excludeFolders +
				'&showChildren=' + showChildren +
				'&showDescription=' + showDescription +
				'&ignoreRedundants=' + ignoreRedundants +
				'&levelReferenceTypes=' + levelReferenceTypes + revision), {
				type: 'GET'
			}).success(function (result) {
				$cont.html(result);
				// Remove sticky header if present
				$(".traceabilityBrowserCont.stickyTableHeader").remove();

				if (!skipAjaxBusySign) {
					ajaxBusyIndicator.close(busySign);
				}
				$("#export").data("hasResult", true);
				$("#export").data("depth", $cont.find("th.referenceType").length);
			}).fail(function (o) {
				if (!skipAjaxBusySign) {
					ajaxBusyIndicator.close(busySign);
				}
				showFancyAlertDialog(i18n.message("tracker.item.traceability.fail.warning"));
			});
		} else {
			showFancyAlertDialog(i18n.message("tracker.traceability.browser.empty.warning"));
		}
	};

	var initSaveSetting = function() {

		var saveSettingDialog = $('#saveSettingDialog').dialog({
			autoOpen: false,
			modal: true,
			dialogClass: 'popup',
			width: 400,
			buttons: [
				{
					text: i18n.message("button.save"),
					click: function() {
						var currentViewId = -2;
						var nameInput = $('#saveSettingDialog .name');
						var name = nameInput.val();
						var data = {
							"tracker_id" : config.trackerId,
							"view_id" : currentViewId,
							"name" : name,
							"initial_tracker_list" : getInitialTrackerList(),
							"tracker_list" : getTrackerList(),
							"show_associations" : $('#showAssociations').is(':checked') ? 'true' : 'false',
							"show_relations" : $('#showRelations').is(':checked') ? 'true' : 'false',
							"show_outgoing_associations" : $('#showOutgoingAssociations').is(':checked') ? 'true' : 'false',
							"show_outgoing_relations" : $('#showOutgoingRelations').is(':checked') ? 'true' : 'false',
							"exclude_folders" : $('#excludeFolders').is(':checked') ? 'false' : 'true',
							"show_children" : $('#showChildren').is(':checked') ? 'true' : 'false',
							"show_description" : $('#showDescription').is(':checked') ? 'true' : 'false',
							"ignore_redundants" : $('#ignoreRedundants').is(':checked') ? 'true' : 'false',
							"level_reference_types" : getLevelReferenceTypes()
						};
						var cbQL = getCbQL();
						if (cbQL != null) {
							data["initial_cbQL"] = cbQL;
						}
						if (name.length > 0) {
							$.ajax(config.saveSettingUrl, {
								type: 'POST',
								data : data
							}).success(function (data) {
								var dataJson = $.parseJSON(data);
								if (dataJson.hasOwnProperty("success") && dataJson.success) {
									showOverlayMessage(i18n.message("tracker.traceability.browser.successfully.saved.preset"));
									nameInput.val("");
									saveSettingDialog.dialog("close");
								} else if (dataJson.hasOwnProperty("message")) {
									showFancyAlertDialog(dataJson.message);
								} else {
									showOverlayMessage(i18n.message("tracker.traceability.browser.cannot.saved.preset"), null, true);
									nameInput.val("");
									saveSettingDialog.dialog("close");
								}
							}).fail(function (o) {
								showOverlayMessage(i18n.message("tracker.traceability.browser.cannot.saved.preset"), null, true);
								saveSettingDialog.dialog("close");
							});
						}
					}
				},
				{
					text: i18n.message("button.cancel"),
					"class": "cancelButton",
					click: function() {
						saveSettingDialog.dialog("close");
					}
				}
			]
		});

		$('#saveSetting').click(function() {
			cleanupLevels();
			var trackerList = getTrackerList();
			if (trackerList.length > 0) {
				var url = getPermanentLinkUrl();
				if (exceedMaximumUrlLength(url)) {
					showExceedMaximumUrlLengthWarning();
					return false;
				} else {
					saveSettingDialog.dialog("open");
				}
			} else {
				showFancyAlertDialog(i18n.message("tracker.traceability.browser.select.tracker.alert"));
			}
		});
	};

	var getCbQL = function() {
		var cbQL = null;
		if ($(".initialFilter").is(":visible")) {
			var $reportSelector = $(".reportSelectorTag").first();
			cbQL = codebeamer.ReportSupport.getCbQl($reportSelector.attr("id"));
			cbQL = encodeURIComponent(cbQL);
		}
		return cbQL;
	};

	var showExceedMaximumUrlLengthWarning = function() {
		showFancyAlertDialog(i18n.message("tracker.traceability.browser.url.warning"));
	};

	var getPermanentLinkUrl = function() {
		var currentViewId = -2;
		var revision = '';
		if (config.revisionId) {
			revision = "&revision=" + config.revisionId;
		}
		var cbQL = getCbQL();
		return config.browserUrl + config.trackerId + '&view_id=' + currentViewId +
			'&trackerList=' + getTrackerList() +
			'&initialTrackerList=' + getInitialTrackerList() +
			(cbQL != null ? '&initialCbQL=' + cbQL : "") +
			'&showIncomingAssociations=' + ($('#showAssociations').is(':checked') ? 'true' : 'false') +
			'&showIncomingRelations=' + ($('#showRelations').is(':checked') ? 'true' : 'false') +
			'&showOutgoingAssociations=' + ($('#showOutgoingAssociations').is(':checked') ? 'true' : 'false') +
			'&showOutgoingRelations=' + ($('#showOutgoingRelations').is(':checked') ? 'true' : 'false') +
			'&excludeFoldersAndInformation=' + ($('#excludeFolders').is(':checked') ? 'false' : 'true') +
			'&showChildren=' + ($('#showChildren').is(':checked') ? 'true' : 'false') +
			'&showDescription=' + ($('#showDescription').is(':checked') ? 'true' : 'false') +
			'&ignoreRedundants=' + ($('#ignoreRedundants').is(':checked') ? 'true' : 'false') +
			'&levelReferenceTypes=' + getLevelReferenceTypes() + revision;
	};

	var initPermanentLink = function() {
		$('#permanentLink').click(function() {
			cleanupLevels();
			var url = getPermanentLinkUrl();
			if (exceedMaximumUrlLength(url)) {
				showExceedMaximumUrlLengthWarning();
				return false;
			} else {
				window.location.href = encodeURI(url);
			}
		});
	};

	var initExport = function() {
		$("#export").click(function() {
			codebeamer.Traceability.cleanupLevels();
			if ($(this).data("hasResult")) {
				var currentViewId = -2;
				var revision = '';
				if (config.revisionId) {
					revision = "&revisionId=" + config.revisionId;
				}
				var depth = $(this).data("depth");
				var showExportPopup = function() {
					var cbQL = getCbQL();
					var exportUrl = encodeURI(config.exportUrl + '&view_id=' + currentViewId +
						'&trackerList=' + getTrackerList() +
						'&initialTrackerList=' + getInitialTrackerList() +
						(cbQL != null ? '&initialCbQL=' + cbQL : "") +
						'&showAssociations=' + ($('#showAssociations').is(':checked') ? 'true' : 'false') +
						'&showRelations=' + ($('#showRelations').is(':checked') ? 'true' : 'false') +
						'&showOutgoingAssociations=' + ($('#showOutgoingAssociations').is(':checked') ? 'true' : 'false') +
						'&showOutgoingRelations=' + ($('#showOutgoingRelations').is(':checked') ? 'true' : 'false') +
						'&excludeFoldersAndInformation=' + ($('#excludeFolders').is(':checked') ? 'false' : 'true') +
						'&showChildren=' + ($('#showChildren').is(':checked') ? 'true' : 'false') +
						'&showDescription=' + ($('#showDescription').is(':checked') ? 'true' : 'false') +
						'&ignoreRedundants=' + ($('#ignoreRedundants').is(':checked') ? 'true' : 'false') +
						'&levelReferenceTypes=' + getLevelReferenceTypes() +
						'&depth=' + (depth + 1) + revision);
					if (exceedMaximumUrlLength(exportUrl)) {
						showExceedMaximumUrlLengthWarning();
						return false;
					} else {
						inlinePopup.show(exportUrl, { height: 350 });
					}
				};
				showExportPopup();
			} else {
				showFancyAlertDialog(i18n.message("tracker.traceability.browser.nothing.to.export"));
			}
		});
	};

	var initConfigLink = function() {
		$('.configImg, .configParameters').click(function(e) {
			e.stopPropagation();
			showPopupInline(config.configUrl);
		});
	};

	var initShowBrowser = function() {
		$('#selectButton').click(function() {
			cleanupLevels();
			showBrowser(false);
		});
	};

	var initHelpLink = function() {
		$('.traceabilityBrowserDataCont .helpLink').mouseleave(function(e) {e.stopImmediatePropagation(); }).tooltip({
			position: {my: "left top+5", collision: "flipfit"},
			tooltipClass : "tooltip",
			content : function() {
				var text = '<h3>' + i18n.message("tracker.traceability.browser.info.whatIs.title") + '</h3>';
				text += '<p>' + i18n.message("tracker.traceability.browser.info.whatIs") + '</p>';
				text += '<h3>' + i18n.message("tracker.traceability.browser.info.usage.title") + '</h3>';
				text += '<p>' + i18n.message("tracker.traceability.browser.info.usage") + '</p>';
				return text;
			},
			open : function(e, ui) {
				ui.tooltip.mouseleave(function(e) {
					$('.traceabilityBrowserDataCont .helpLink').tooltip("close");
				});
			}
		});
	};

	var	initSuggestionsTable = function($container) {
		var $table = $("#traceabilitySuggestedTable");
		$table.find("a").click(function() {
			addEntityFromSuggestedArea($(this));
		});
	};

	var refreshCounts = function($table) {
		$table.find(".infiniteScrollTop").last().find("td").each(function() {
			var index = $(this).attr("data-index");
			if (typeof index !== 'undefined') {
				var count = parseInt($(this).attr("data-count"), 10);
				var $countNumber = $table.find(".countContainer[data-index='" + index +"']").find(".countNumber");
				var previousCount = parseInt($countNumber.text(), 10);
				var newCount = count + previousCount;
				$countNumber.text(newCount);
			}
		});
	};

	var initInfiniteScroll = function($table) {
		$.waypoints("destroy");
		var $top = $table.find("#infiniteScrollTop");
		if ($top.length > 0) {
			// TODO set top
		}
		var $bottom = $table.find("#infiniteScrollBottom");
		if ($bottom.length > 0) {
			var $cont = $table.closest(".traceabilityBrowserCont");
			var page = $bottom.attr("data-page");
			var permanentLink = $bottom.attr("data-permanent-link");
			$bottom.waypoint({
				triggerOnce: true,
				offset: "bottom-in-view",
				handler: function() {
					if ($bottom.data("triggered")) {
						return;
					}
					$bottom.data("triggered", true);
					var busySign = ajaxBusyIndicator.showBusysign($cont);
					$.ajax(encodeURI(contextPath + permanentLink + "&page=" + page), {
						type: 'GET'
					}).success(function (result) {
						ajaxBusyIndicator.close(busySign);
						var resultObject = $($.parseHTML(result));
						if (resultObject.find("td.name").length > 0) {
							$table.find("tr:last").after(result);
							$bottom.remove();
							codebeamer.ReferenceSettingBadges.init($table);
							initInfiniteScroll($table);
							refreshCounts($table);
						}
					}).fail(function (o) {
						ajaxBusyIndicator.close(busySign);
						showFancyAlertDialog(i18n.message("tracker.item.traceability.fail.warning"));
					});
				}
			});
		}
	};

	var initManagePresetLink = function() {
		$('#managePresets').click(function() {
			showPopupInline(config.manageSettingUrl, { width: 900 });
		});
	};

	var initShowHiddenTrackers = function() {
		$('#showHiddenTrackers').change(function() {
			var checked = $(this).is(':checked');
			$(".selectTrackerTable tr[data-visible]").each(function() {
				if (!$(this).data('visible')) {
					checked ? $(this).show() : $(this).hide();
				}
			});
		});
		$('#showHiddenTrackers').change();
	};

	var initActions = function() {
		initShowBrowser();
		initManagePresetLink();
		initHelpLink();
		initSaveSetting();
		initPermanentLink();
		initExport();
		initConfigLink();
	};

	var initInitialFilterGoButton = function() {
		$(".initialFilterGoButton").click(function() {
			var containerId = $(".reportSelectorTag").attr("id");
			if (codebeamer.ReportSupport.isLogicInvalid(containerId, codebeamer.ReportSupport.logicEnabled(containerId))) {
				return;
			}
			var cbQL = codebeamer.ReportSupport.getCbQl(containerId);
			if (typeof cbQL === "undefined") {
				showFancyAlertDialog(i18n.message("queries.empty.query.alert"));
				return false;
			}
			cbQL = encodeURIComponent(cbQL);
			var url = contextPath + "/proj/tracker/traceabilitybrowser.spr?tracker_id=" + $(this).attr("data-trackerId") + "&initialCbQL=" + cbQL;
			if (exceedMaximumUrlLength(url)) {
				showExceedMaximumUrlLengthWarning();
				return false;
			} else {
				window.location.href = url;
			}
		});
	};

	var initProjectLevelActions = function() {
		initShowHiddenTrackers();
		initManagePresetLink();
		initInitialFilterGoButton();
	};

	var initProjectLevel = function(settings) {
		config = $.extend({}, config, settings);
		initProjectLevelActions();
	};

	var init = function(settings) {
		config = $.extend({}, config, settings);
		if (config.currentInitialCbQL) {
			var busyPage = ajaxBusyIndicator.showBusyPage();
			$(document).ajaxStop(function() {
				ajaxBusyIndicator.close(busyPage);
			})
		}
		initContextMenus(config.initialMenuItems, config.trackerTypeMenuItems, config.trackerMenuItems);
		initControls(config.initialTrackerList, config.trackerList, config.revisionId);
		initSuggestedArea();
		initAddCustomTrackerDialog();
		initActions();

		if (config.currentTrackerList !== "false" || config.currentInitialCbQL !== 'null') {
			try {
				showBrowser(true, true);
			} catch (e) {
				window.location.href = config.browserUrl + config.trackerId;
			}
		}
	};

	return {
		"init": init,
		"initProjectLevel": initProjectLevel,
		"addCustomTracker": addCustomTracker,
		"addEntityToLevel": addEntityToLevel,
		"addEntityFromSuggestedArea" : addEntityFromSuggestedArea,
		"cleanupLevels" : cleanupLevels,
		"highlightCells" : highlightCells,
		"loadTrackerItemTraceability" : loadTrackerItemTraceability,
		"setStickyHeader" : setStickyHeader,
		"initInfiniteScroll" : initInfiniteScroll,
		"initReferenceTypeSelectors" : initReferenceTypeSelectors,
		"initSuggestionsTable" : initSuggestionsTable,
		"initTraceabilityTab" : initTraceabilityTab,
		"setTabArrowHeight" : setTabArrowHeight
	};

})(jQuery);