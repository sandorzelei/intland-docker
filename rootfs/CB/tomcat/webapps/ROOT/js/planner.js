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
codebeamer.planner = codebeamer.planner || (function($) {

	var SCROLL_TOLERANCE = 30;

	var interruptSuggestionsRendering = false;

	var isProjectBacklog = false;

	var contextUrl = contextPath; // global variable

	var ajaxLoaderImageUrl = contextUrl + "/images/ajax-loading_10.gif";
	var maxHistoryCountToShow = 10;

	var assigneePlaceHolder = -1;

	var showParentItemsChecked = false;

	var multipleSelectionEnabled = false;

	var cbQLForPlannerFilters = null;

	var firstLoad = true;

	var isIncrementalScroll = false;

	var isSortInProgress = false;

	var getUniqueId = (function() {
		var counter = 0;
		return function() {
			++counter;
			return "planner-unique-" + counter;
		}
	})();

	var findVersionById = function(id, includeVirtual) {
		if (!id) {
			return null;
		}

		if (typeof includeVirtual == "undefined") {
			includeVirtual = false;
		}
		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");
		return leftPane.find((includeVirtual ? "" : ".version") + "[data-version-id=" + id + "]");
	};

	var findRowById = function(id) {
		return $("tr[data-item-id=" + id + "]");
	};

	var findParentRow = function(elem) {
		return $(elem).closest("[data-item-id]");
	};

	var isCurrentVersionId = function(versionId) {
		var currentVersionId = $("#currentVersion").data("id");
		return versionId == currentVersionId;
	};

	var isTrackerScope = function() { return !!codebeamer.plannerConfig["isTrackerScope"]; };
	var isReleaseScope = function() { return !!codebeamer.plannerConfig["isReleaseScope"]; };
	var isSprintScope  = function() { return !!codebeamer.plannerConfig["isSprintScope"]; };
	var getReleaseTrackerId  = function() { return codebeamer.plannerConfig["releaseTrackerId"]; };

	var adjustLayout = function() {
		var planner = $("#planner");
		var footerHeight = $("#footer").outerHeight();
		var getMaxHeight = function(which) {
			var pane = which;
			if (typeof which == "string") {
				pane = planner.find("." + which + "-pane .overflow");
			}
			var paneWhitespace = pane.outerHeight() - pane.height();
			var headerHeight = pane.offset().top;
			return $(window).height() - headerHeight - footerHeight - paneWhitespace;
		};
		var leftOverflow = planner.find(".left-pane .overflow");
		var centerPaneOverflow = planner.find(".center-pane .overflow");
		var rightOverflow = planner.find(".right-pane .overflow");

		planner.css("height", getMaxHeight(planner));

		if (leftOverflow.length > 0) {
			leftOverflow.css({
				"height": getMaxHeight("left")
			});
		}
		if (rightOverflow.length > 0) {
			rightOverflow.css({
				"height": getMaxHeight("right")
			});
		}
		if (centerPaneOverflow.length > 0) {
			centerPaneOverflow.css({
				"height": getMaxHeight("center")
			});
		}
		$("body").css("overflow", "hidden");

		(function fixEastOpener() {
			$("#opener-east").detach().appendTo($("#middleHeaderDiv"));
		})();
	};

	var itemAccordionStatePersistence = true;

	var openTaskEditorOverlay = function(taskId, duplicate) {
		var relativeUrl = duplicate ? "/planner/duplicateItem.spr" : "/cardboard/editCard.spr";
		showPopupInline(contextUrl + relativeUrl + "?task_id=" + taskId, {
			geometry: "large"
		});
	};

	var cardEditorSaveHandler = function(taskId, editorType) {
		if (codebeamer.planner["groupItemButton"]) {
			$.post(contextPath + "/ajax/planner/getNewGroupItemData.spr", { itemId: taskId }, function(result) {
				var $newGroupItemContainer = codebeamer.planner["groupItemButton"].closest(".newGroupItemContainer");
				var isBacklog = false;
				if ($newGroupItemContainer.hasClass("backlogNewGroupItem")) {
					isBacklog = true;
					var $groupRowRankable = $("#trackerItems").find("tr.groupRow").first().clone();
					var $groupPlaceholderRow = $("#trackerItems").find("tr.groupPlaceholderRow").first().clone();
				} else {
					var $groupRow = codebeamer.planner["groupItemButton"].closest("tr.groupRow");
					var $groupPlaceholderRow = $groupRow.nextAll(".groupPlaceholderRow").first().clone();
					var $groupRowRankable = $groupRow.nextAll(".groupRow.rankable").first().clone();
				}
				$groupRowRankable.attr("data-id", taskId);
				$groupRowRankable.attr("data-typed-value",  result.type + "-" + taskId);
				$groupRowRankable.attr("data-name",  result.name);
				$groupRowRankable.find(".groupHeaderPlaceholder").css("background-color", result.color);
				$groupRowRankable.find(".groupping-level").css("background-color", result.color);
				$groupRowRankable.find(".wikiLinkContainer").empty();
				$groupRowRankable.find(".wikiLinkContainer").append($(result.wikiLink).find(".wikiLink").clone());
				$groupRowRankable.find(".itemCount").remove();
				$groupRowRankable.find(".groupRank").empty();
				var $itemPlaceholderRow = $("<tr>", { "class" : "trackerItem trackerItemPlaceholder", "data-rank" : 1 });
				$itemPlaceholderRow.append($("<td>", { colspan: parseInt($groupPlaceholderRow.find("td[colspan]").attr("colspan"), 10) + 2} ).text(i18n.message("planner.new.group.item.info")));
				if (isBacklog) {
					$("#trackerItems").find("tr.groupPlaceholderRow").first().after($groupPlaceholderRow).after($itemPlaceholderRow).after($groupRowRankable);
				} else {
					$groupRow.next(".headerRow").after($itemPlaceholderRow).after($groupPlaceholderRow).after($groupRowRankable).after($groupPlaceholderRow);
				}
				refreshGroupOrder($("#trackerItems"), $groupRowRankable, $groupRowRankable.attr("data-cbqlvariable"), true);
			});
		} else {
			forceReportSelectorSearch();
			if (editorType == "new-item" || editorType == "edit-item" ||
				editorType == "new-version" || editorType == "edit-version" ||
				editorType == "new-team" || editorType == "edit-team") {
				reloadLeftPane(taskId);
			}
		}
	};

	var refreshTeamIssueCounters = function () {
		// collect the collapsed team ids
		var collapsed = $(".team-list .expander:not(.expanded)").map(function () {
			return $(this).data("teamid");
		});

		var bs = ajaxBusyIndicator.showBusysign($(".team-list"), i18n.message("ajax.loading"));
		$.get(contextPath + "/ajax/planner/getTeamHierarchy.spr", {
			"tracker_id": codebeamer.plannerConfig.isTrackerScope ? codebeamer.plannerConfig.releaseTrackerId : undefined,
			"version_id": codebeamer.plannerConfig.isTrackerScope ? undefined : codebeamer.plannerConfig.versionId
		}, function (data) {
			$(".teams-accordion").html(data.rendered);
			setupDroppables(".left-pane .team-list li");

			// restore the collapsed state

			for (var i = 0; i < collapsed.length; i++) {
				var $expander = $(".expander[data-teamid=" + collapsed[i] + "]");

				if ($expander.is(".expanded")) {
					$expander.click();
				}
			}
			updateLeftPaneContextMenuIcons();
		}).always(function () {
			if (bs) {
				bs.remove();
			}
		});
	};

	var refreshIssueCounters = function() {
		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");
		leftPane.find(".sprints-accordion .issue-count").css("visibility", "hidden");

		var versionsViewModel = codebeamer.plannerConfig.versionsViewModel;

		for (var versionId in versionsViewModel) {
			var statsForVersion = versionsViewModel[versionId];
			var statsRendered = "";
			var versionElems = findVersionById(versionId, true);
			$(versionElems).each(function() {
				var versionElem = $(this);
				var isBacklog = versionElem.hasClass("backlog");
				if (statsForVersion) {
					var issueCount = statsForVersion["issueCount"];
					if (isBacklog) {
						issueCount -= statsForVersion["childrenIssueCount"];
					}
					statsRendered = "<div class='issueCountContainer'>" + issueCount +
						"</div><div class='storyPointsContainer'><div class='storyPointsLabel open'>" + statsForVersion["storyPoints"] +
						"<div class='storyPointsIcon'></div></div></div>";
				}
				versionElem.find(".issue-count").css("visibility", "visible").html(statsRendered);
			});
		}
	};

	var removeRow = function(row) {
		var issueList = row.parents(".issuelist");
		row.remove();
		// remove the sprint header is the last item was assigned to an other user
		if (issueList.find("tr").size() == 0) {
			issueList.prev().prev("div").hide();
			var centerPane = $("#planner").find(".center-pane");
			var visibleVersions =  centerPane.find(".overflow .version-header:visible");
			if (visibleVersions.length == 0) {
				// nothing is visible in the center pane, display message instead
				centerPane.find(".nothing-found-message").show();
			}
		}
		adjustRowStylingInAllIssueLists();
		$.waypoints('refresh');
	};

	var getAssigneeIdsOfRow = function(row) {
		return row.find("td.issueAssignedTo").attr("data-ids").split(",").sort();
	};

	var reloadVersionStatsBox = throttleWrapper(function(successCallback) {
		var planner = $("#planner");
		var container = planner.find(".left-pane .release-stats-accordion");
		var params = getBasicParameters();
		var selectedRowIds = $.map(container.find("tr.assigneeTable.selected[data-id]"), function(row) {
			return $(row).data("id");
		});
		if (selectedRowIds.length > 0) {
			params["force_contain_user_ids"] = selectedRowIds.join(",");
		}
		$.post(contextUrl + "/ajax/planner/renderVersionStatistics.spr",
			params,
			function(data) {
				var tempContainer = $("<div></div>").html(data);
				var versionStatsBox = tempContainer.html();
				container.html(versionStatsBox);
				$(selectedRowIds).each(function() {
					container.find("tr.assigneeTable[data-id=" + this + "]").addClass("selected");
				});
				VersionStatsBox.init();
				if (successCallback) {
					successCallback(data);
				}
			});
	});

	var getCenterScrollState = function() {
		var planner = $("#planner");
		var centerPaneOverflow = planner.find(".center-pane .overflow");
		return {
			"top": centerPaneOverflow.scrollTop()
		};
	};

	var selectItem = function(item) {
		if (!item.is(".selected")) {
			item.click();
		}
	};

	var scrollToItemAndSelect = function(id) {
		codebeamer.waypointHelpers.restoreCenterScrollState($("#planner .center-pane .overflow"), {}, id, selectItem);
	};

	var addParentsIfNecessary = function() {
		if ($("#showParentItems").is(":checked")) {
			addParents();
		}
	};

	var addParents = function() {
		$("#showParentItems").prop("disabled", true);
		removeParents();
		var $issueLists = $("#planner").find(".center-pane").find(".trackerItems");
		var parentIds = [];
		$issueLists.each(function() {
			var $trs = $(this).find("tr");
			$trs.each(function() {
				var parentId = $(this).attr("data-tt-parent-id");
				if (parentId && parentId != "" && parentId != 0) {
					parentIds.push(parentId);
				}
			});
		});
		var uniqueParentIds = $.unique(parentIds);
		var busy = ajaxBusyIndicator.showBusysign($("#plannerCenterPane"));
		$.getJSON(contextPath + "/ajax/planner/getParentInfo.spr", { parentIdList : uniqueParentIds.join(",")}).done(function(result) {
			$issueLists.each(function() {
				$(this).addClass("withParents");
				var $trs = $(this).find("tbody").find("tr");
				if ($(this).find("thead")) {
					$(this).find("thead").find("th").first().before($("<th>", { "class" : "parentHandlerTh"}));
				}
				var previousParentId = null;
				$trs.each(function() {
					if ($(this).hasClass("trackerItem")) {
						var $parentHandler = $("<td>", { "class" : "parentHandler", "data-parent-id" : parentId});
						$(this).find("td").first().before($parentHandler);
						var parentId = $(this).attr("data-tt-parent-id");
						if (!parentId || parentId == "") {
							parentId = 0;
						}
						var numberOfTds = $(this).find("td").length;
						if (parentId && parentId != 0 && parentId != "") {
							var parentList = result[parseInt(parentId, 10)];
							var color = parentList[0].color;
							$(this).find(".parentHandler").addClass("withParent").css("background-color", color);
							if (previousParentId != parentId) {
								var $parentTr = $("<tr>", { "class" : "parent" });
								var $parentTd = $("<td>", { "class" : "parentTd", "colspan" : numberOfTds - 1 });
								for (var i = 0; i < parentList.length; i++) {
									var parentInfo = parentList[i];
									var $parentSpan = $("<span>", { "class" : "parentSpan", "style" : "background-color: " + color});
									var $parentIcon = $("<span>", { "class" : "parentIcon"});
									$parentIcon.append($("<img>", { "src" : parentInfo.iconUrl, "style" : "background-color: " + parentInfo.iconBgColor }));
									$parentSpan.append($parentIcon);
									var $parentName = $("<span>", { "class" : "parentName"}).html("<a target='_blank' href=\"" + parentInfo.url + "\">[" + parentInfo.keyAndId + "] " + parentInfo.name + "</a>");
									$parentSpan.append($parentName);
									$parentTd.append($parentSpan);
								}
								var $parentHandlerTd = $("<td>", { "class" : "parentHandler withParent parentHeader", "style" : "background-color: " + color, "data-parent-id" : parentId});
								var $parentHandlerControlTd = $("<td>", { "class" : "parentHandlerControl withParent", "style" : "background-color: " + color, "data-parent-id" : parentId});
								$parentTr.append($parentHandlerTd);
								$parentTr.append($parentHandlerControlTd);
								$parentTr.append($parentTd);
								$(this).before($parentTr);
							}
						} else {
							var $parentTr = $("<tr>", { "class" : "parent noParent" });
							var $parentTd = $("<td>", { "class" : "parentTd", "colspan" : numberOfTds - 1 });
							var $parentHandlerTd = $("<td>", { "class" : "parentHandler parentHeader"});
							var $parentHandlerControlTd = $("<td>", { "class" : "parentHandlerControl"});
							$parentTr.append($parentHandlerTd);
							$parentTr.append($parentHandlerControlTd);
							$parentTr.append($parentTd);
							$(this).before($parentTr);
						}
						previousParentId = parentId;
					} else {
						var $grouppigLevel = $(this).find("td.groupping-level");
						if ($grouppigLevel.length > 0) {
							$grouppigLevel.attr("colspan", parseInt($grouppigLevel.attr("colspan"), 10) + 1);
						}
						if ($(this).find("th").length > 0) {
							$(this).find("th").first().before($("<th>", { "class" : "parentHandlerTh"}));
						}
					}
				});
			});
			ajaxBusyIndicator.close(busy);
			$("#plannerCenterPane .scrollable").show();
			$("#showParentItems").prop("disabled", false);
		});
	};

	var removeParents = function() {
		var $issueLists = $("#planner").find(".center-pane").find(".trackerItems");
		$issueLists.each(function() {
			$issueLists.removeClass("withParents");
			$(this).find("th.parentHandlerTh").remove();
			$(this).find("tr.parent").remove();
			$(this).find("td.parentHandler").remove();
		});
	};

	var storeGroupClosedState = function(cbQLVariable, ids, includeNoGroup, isRemove) {
		$.ajax(contextPath + (isRemove ? "/ajax/planner/removeGroupClosedState.spr" : "/ajax/planner/addGroupClosedState.spr"), {
			method: "POST",
			async: false,
			data: {
				ids: ids.join(","),
				cbQLVariable: cbQLVariable,
				includeNoGroup: includeNoGroup
			}
		}).fail(function() {
			showFancyAlertDialog(i18n.message("planner.collapse.state.save.error"));
		});
	};

	var initOpeners = function($table) {

		var addGroupClosedState = function(cbQLVariable, ids, includeNoGroup) {
			storeGroupClosedState(cbQLVariable, ids, includeNoGroup, false);
		};

		var removeGroupClosedState = function(cbQLVariable, ids, includeNoGroup) {
			storeGroupClosedState(cbQLVariable, ids, includeNoGroup, true);
		};

		$table.on("click", ".opener:not(.disabled)", function() {
			var $groupRow = $(this).closest(".groupRow.firstLevel");
			var includeNoGroup = false;
			if ($groupRow.find(".headerNoGroup").length > 0) {
				includeNoGroup = true;
			}
			var cbQlVariable = $groupRow.attr("data-cbQLVariable");
			if (includeNoGroup && !cbQlVariable) {
				var groupingField = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
				cbQlVariable = groupingField.data("fieldObject")["cbQLGroupByAttributeName"];
			}
			var ids = [];
			var id = $groupRow.attr("data-id");
			ids.push(id);
			if ($(this).hasClass("opened")) {
				removeGroupClosedState(cbQlVariable, ids, includeNoGroup);
				$(this).removeClass("opened");
			} else {
				addGroupClosedState(cbQlVariable, ids, includeNoGroup);
				$(this).addClass("opened");
			}
			forceReportSelectorSearch();
		});
	};

	var afterIssueListsLoaded = function(itemId) {
		var centerPane = $("#planner").find(".center-pane");
		var issueLists = centerPane.find(".issuelist");
		if (issueLists.children().size() == 0) {
			var $message = $("<div></div>").addClass("subtext").css({"text-align": "center"}).append(i18n.message("table.nothing.found"));
			issueLists.append($message);
		}
		refreshIssueCounters();
		addCenterPaneEventHandlers();
		emptyIssueInfoBoxes();
		updateSorting();
		adjustLayout();
		hideEmptyReleases();
		if (itemId) {
			scrollToItemAndSelect(itemId);
		}

		addParentsIfNecessary();

		$("body").trigger("issueListLoaded");
	};

	var currentlyOnProjectBacklogPage = function() {
		var leftPane = $("#planner").find(".left-pane");
		return leftPane.find("li.project-backlog.selected").length > 0;
	};

	var reloadLeftPane = function(versionIdToHighlight) {

		/**
		 * JQuery's html() implementation in IE8 might insert undesired line breaks, remove them
		 */
		var fixWhitespacesIE8 = function(markup) {
			return markup.replaceAll(/>\s*<!--\s*-->\s*</m, "><");
		};

		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");
		var scrollTop = leftPane.find(".overflow").scrollTop();
		var selectedVersionId = leftPane.find(".version.selected").data("version-id");
		var isBacklogSelected = leftPane.find(".project-backlog").hasClass("selected");
		var resizer = leftPane.find(".ui-resizable-handle").detach();

		var busy = ajaxBusyIndicator.showBusysign(leftPane.find(".overflow"));

		$(".extendedReleaseMenu.menu-downloaded", function() {
			$(".extendedReleaseMenu").removeClass("menu-downloaded").removeData("menujson");
			$.contextMenu("destroy", $(this));
		});

		$.ajax({
			url: contextUrl + "/planner/planner.spr",
			data: getBasicParameters(),
			cache: false,
			success: function(response) {
				var newContent = fixWhitespacesIE8($(response).find(".left-pane").html());
				leftPane.html(newContent).append(resizer);
				addLeftPaneEventHandlers();
				reloadVersionStatsBox(function() {
					leftPane.find(".overflow").scrollTop(scrollTop);
				});
				refreshIssueCounters();
				adjustLayout();
				if (versionIdToHighlight) {
					var version = findVersionById(versionIdToHighlight);
					flashChanged(version, function() {
						setTimeout(function() {
							version.css("background-color", "");
						}, 1000); // wait some time for row click to finish
					});
				}
				if (selectedVersionId) {
					findVersionById(selectedVersionId).addClass("selected");
				} else {
					if (isBacklogSelected) {
						leftPane.find(".project-backlog").addClass("selected");
					}
				}
				var cbQL = codebeamer.ReportSupport.getCbQl($(".reportSelectorTag").attr("id"));
				if (cbQL) {
					setTimeout(function() {
						setPlannerFilters(cbQL);
					}, 300);
				}
				initAddSprintButton();

				ajaxBusyIndicator.close(busy);
				updateLeftPaneContextMenuIcons();
			},
			fail: function() {
				ajaxBusyIndicator.close(busy);
			}
		});


	};

	var reloadIssuesList = throttleWrapper(function(extraParams, successCallback, itemId) {
		if ($.isFunction(extraParams)) {
			successCallback = extraParams;
			extraParams = {};
		}

		var planner = $("#planner");

		var showAjaxLoader = function() {
			var centerPaneOverflow = planner.find(".center-pane .overflow");
			centerPaneOverflow.text("");
			var p = centerPaneOverflow.get(0);
			return ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
				width: "12em"
			});
		};

		var params = getFilterParameters();

		var busySign = showAjaxLoader();

		// generate a request id for handling out-of-order ajax requests
		requestId = Date.now();
		params["requestId"] = requestId;

		$.post(contextUrl + "/ajax/planner.spr",
			$.extend(params, extraParams),
			function(data) {
				if (data.requestId != requestId) {
					return;
				}

				var tempContainer = $("<div></div>").html(data.rendered);
				var centerPaneContents = tempContainer.find(".center-pane").html();
				planner.find(".center-pane").html(centerPaneContents);
				ajaxBusyIndicator.close(busySign);
				$("#showParentItems").prop("checked", showParentItemsChecked);
				initShowParentItems();
				afterIssueListsLoaded(itemId);
				if (successCallback) {
					successCallback(data);
				}
			}).always(function () {
				try {
					busySign.dialog("close");
				} catch(e){}
			});
	});

	var hideEmptyReleases = function () {
		$("#planner").find("div.issuelist").each(function() {
			$(this).prev().prev(".version-header").hide();
		});
	};

	var getBasicParameters = function() {
		var $currentVersion = $("#currentVersion");
		var $currentTracker = $("#currentTracker");
		var params = {};
		if ($currentVersion.size() > 0) {
			params["task_id"] = $currentVersion.data("id");
		} else {
			params["tracker_id"] = $currentTracker.data("id");
		}
		return params;
	};

	var getFilterParameters = function() {
		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");
		var centerPane = planner.find(".center-pane");
		var params = getBasicParameters();

		// filters

		var versionFilters = leftPane.find(".version.filter, .project-backlog");

		params["filter_versions"] = $.map(versionFilters.filter(".selected, .virtually-selected"),function(elem) {
			return $(elem).attr("data-version-id");
		}).join();

		params["filter_teams"] = $.map($(".selected .color-box"), function (elem) {
			return $(elem).data("teamid");
		}).join();

		var trackerFilters = $.map($("[name=multiselect_tracker-select]:checked"), function (elem) {
			return $(elem).val();
		}).join();

		params["tracker_filters"] = trackerFilters;

		var filterTextInput = planner.find(".action-lane .filter-text");
		var filterText = filterTextInput.val();
		if (filterText == filterTextInput.prop("placeholder")) {
			filterText = "";
		}
		params["filter_issue_text"] = filterText;

		var assigneeId = $("#versionStatsBox").find("tr.selected").first().data("id");
		params["filter_assignee"] = (assigneeId != 0) ? assigneeId : "";

		params["coloring_item_id"] = leftPane.find(".color-filters .selected").first().data("id");

		if (currentlyOnProjectBacklogPage()) {
			var projectBacklogNavigation = centerPane.find(".backlog-controls .navigation");
			var selectedTabName = "filter";
			if (projectBacklogNavigation.length > 0) {
				var selectedTab = projectBacklogNavigation.find("li.selected:not(.arrow)");
				if (selectedTab.hasClass("history")) {
					selectedTabName = "history";
				}
			}

			params["pb_tab"] = selectedTabName;
			params["pb_filter_text"] = centerPane.find(".history-filter-controls input[type=text]").first().val();
		}

		return params;
	};

	var setupDroppables = function(selector) {
		if (!selector) {
			selector = ".left-pane .version-list li, .left-pane .team-list li, .left-pane .color-filters li";
		}

		var isIndirectParentOf = function(version1, version2) {
			var draggedVersionId = version1.data("version-id").toString();
			var parentIds = version2.attr("data-parent-list-version-ids");
			if (parentIds) {
				parentIds = parentIds.split(",");
				if ($.inArray(draggedVersionId, parentIds) != -1) {
					return true;
				}
			}
			return false;
		};

		var commonProperties = {
			"accept": function(draggable) {
				var droppable = $(this);
				var isRow = draggable.is("tr[data-tt-id]");
				var isGroupRow = draggable.is(".groupRow.rankable");
				var isVersion = draggable.is(".version");
				var targetIsDirectParent = draggable.data("parent-version-id") == droppable.data("version-id");
				var targetIsVirtual = droppable.hasClass("virtual");
				var targetIsRelation = droppable.hasClass("relation");

				if (draggable.attr("data-isRelease") == "true") {
					return false;
				}

				if (isGroupRow || targetIsRelation) {
					return true;
				} else {
					return (isRow || (isVersion && !targetIsDirectParent && !targetIsVirtual && !isIndirectParentOf(draggable, droppable)));
				}

			},
			"tolerance": "pointer",
			"hoverClass": "highlighted"
		};

		var dropHandler = function(event, ui) {

			var $droppable = $(this);
			var $draggable = ui.draggable;
			var isVersion = $draggable.is(".version");
			var targetIsTeam = $droppable.is(".team");
			var targetIsRelation = $droppable.is(".relation");

			codebeamer.dropped = true;
			if (isVersion) {
				$draggable.detach().hide(); // just detach because jQuery UI event handlers will refer to it later
				updateParentRelease($draggable.data("version-id"), $droppable.data("version-id"), function() {
					// wait some time before removing
					setTimeout(function() {
						$draggable.remove();
					}, 1000);
				}, function() {
					$draggable.show();
				});
			} else {
				var $row = $(ui.draggable);
				if (targetIsTeam) {
					updateTeam($row, $droppable.data("teamid"));
				} else if (targetIsRelation) {
					updateRelation($row, $droppable, $droppable.data("id"));
				} else {
					updateTargetRelease($row, $droppable, $droppable.data("version-id"));
				}
			}
		};

		var highlightPossibleDropTargets = throttleWrapper(function(event, ui) {
			var $draggable = $(ui.draggable);
			if ($draggable.hasClass("ui-layout-resizer") || $draggable.is("[data-fieldlayoutid]")) {
				return;
			}
			if ($draggable.hasClass("groupRow") && $draggable.attr("data-isRelease") == "true") {
				return;
			}
			var isVersion = $draggable.is(".version");
			var teamEditable = true; //$draggable.is(".teamFieldEditable");
			var userStoryEditable = true; //$draggable.is(".userStoryFieldEditable");
			var requirementEditable = true; //$draggable.is(".requirementFieldEditable");

			if (!$draggable.is(".targetReleaseEditable") && !teamEditable && !userStoryEditable
					&& !requirementEditable && !isVersion) {
				return;
			}
			var assignedReleaseId = isVersion
				? $draggable.data("parent-version-id")
				: $draggable.attr("data-releaseId");
			var versions;
			var opacity = null;
			if (isVersion) {
				versions = $("#planner").find(".left-pane .version-list li.version")
					.not(".virtual").not($draggable);
				if (assignedReleaseId) {
					versions = versions.not("[data-version-id=" + assignedReleaseId + "]")
				}
				versions.each(function() {
					var version = $(this);
					if (isIndirectParentOf($draggable, version)) {
						versions = versions.not(version);
					}
				});
			} else {
				if (!assignedReleaseId) {
					assignedReleaseId = -1; // project backlog
				}
				var itemId = $draggable.attr("data-tt-id");
				versions = $("#planner").find(".left-pane .version-list li" + (teamEditable ? ", .left-pane .team-list li" : "")
						+ (userStoryEditable ? ", .left-pane .color-filters li.level-2" : "") + (requirementEditable ? ", .left-pane .color-filters li.level-1" : ""))
					.not("[data-version-id=" + assignedReleaseId + "]")
					.not("[data-version-id=" + itemId + "]");
			}
			versions.addClass("acceptsDrop");
			if (opacity != null) {
				opacity.addClass("refuseDrop");
			}
		});

		var removeHighlighting = throttleWrapper(function() {
			$(".acceptsDrop").removeClass("acceptsDrop");
			$(".refuseDrop").removeClass("refuseDrop");
		});

		$("#planner").find(selector).droppable($.extend({
			"drop": dropHandler,
			"activate": highlightPossibleDropTargets,
			"deactivate": removeHighlighting
		}, commonProperties));
	};

	var setCbQLForPlannerFilters = function(cbQL) {
		cbQLForPlannerFilters = cbQL;
	};

	var setPlannerFilters = function(cbQL) {
		if (cbQLForPlannerFilters != null) {
			cbQL = cbQLForPlannerFilters;
		}
		var $leftPane = $("#planner").find(".left-pane");
		$leftPane.find(".team-list li.selected, .color-filters li.selected").removeClass("selected");
		$leftPane.find(".team-list a.state-checked").removeClass("state-checked");
		$leftPane.find(".plannerTeamCommitment tr.selected").removeClass("selected");
		if (cbQL == null || cbQL.length == 0) {
			return;
		}

		var getIdsFromCbQL = function(cbQL, cbQLAttrName) {
			var part = cbQL.substring(cbQL.indexOf(cbQLAttrName + " IN"), cbQL.length);
			part = part.substring(part.indexOf("(") + 1, part.indexOf(")"));
			if (part == null || part.length == 0 || cbQL.indexOf(cbQLAttrName + " IS NULL") > -1) {
				return [];
			}
			return part.split(",");
		};

		if (cbQL.indexOf("assignedToRole") > -1) {
			var ids = getIdsFromCbQL(cbQL, "assignedToRole");
			if (ids.length > 0) {
				$leftPane.find('.plannerTeamCommitment tr[data-id="13-' + ids[0] + '"]').addClass("selected");
			}
		} else if (cbQL.indexOf("assignedTo") > -1) {
			var ids = getIdsFromCbQL(cbQL, "assignedTo");
			if (ids.length == 0) {
				$leftPane.find('.plannerTeamCommitment tr[data-id="1--1"]').addClass("selected");
			} else {
				$leftPane.find('.plannerTeamCommitment tr[data-id="1-' + ids[0] + '"]').addClass("selected");
			}
		}
		if (cbQL.indexOf("TeamID") > -1) {
			var ids = getIdsFromCbQL(cbQL, "TeamID");
			if (ids.length == 0) {
				$leftPane.find('.team-list li[data-teamid="-1"]').addClass("selected").find("a.project-status").addClass("state-checked");
			} else {
				for (var i = 0; i < ids.length; i++) {
					$leftPane.find('.team-list li[data-teamid="' + ids[i] + '"]').addClass("selected").find("a.project-status").addClass("state-checked");
				}
			}
		}
		if (cbQL.indexOf("referenceToId") > -1) {
			var ids = getIdsFromCbQL(cbQL, "referenceToId");
			if (ids.length > 0) {
				$leftPane.find('.color-filters li[data-id="' + ids[0] + '"]').addClass("selected");
			}
		}
	};

	var setupColoredRelationsLoader = function(skipSetupDroppables, callback) {
		var leftPane = $("#planner").find(".left-pane");
		var scrollTop = leftPane.find(".overflow").scrollTop();

		var setupColorFilters = function() {
			var colorFilters = leftPane.find(".color-filters:not(.release)").find("[data-id]");
			colorFilters.each(function() {
				var elem = $(this);
				var id = elem.data("id");
				if (id > 0) {
					elem.click(function(event) {
						// don't load the filters when the context menu is active
						if (!event.target || $(event.target).is(".menuArrowDown") || $(event.target).is(".simpleDropdownMenu")) {
							return true;
						}
						scrollTop = leftPane.find(".overflow").scrollTop();
						elem.toggleClass("selected");
						if (elem.hasClass("selected")) {
							colorFilters.not(elem).removeClass("selected");
						}
						var selectedIds = [];
						var selectedItemIds = [];
						colorFilters.each(function() {
							if ($(this).is(".selected")) {
								var referenceId = $(this).data("id");
								selectedIds.push({ value: referenceId.toString() });
								selectedItemIds.push(referenceId.toString());
							}
						});

						$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
							dataType: "json",
							data: { field_id: -5 },
							async: false
						}).done(function(fieldObject) {
							var $referenceFields = $(".reportSelectorTag").find("button.referenceField");
							$referenceFields.each(function() {
								var fieldInfo = $(this).data("fieldObject");
								if (fieldInfo.id == -5) {
									$(this).next(".removeIcon").click();
								}
							});
							if (selectedIds.length > 0) {
								var values = [];
								values.push({
									left: {
										value : "referenceToId"
									},
									operator: "IN",
									right: {
										value: selectedIds
									}
								});
								var reportSelectorId = $(".reportSelectorTag").attr("id");
								codebeamer.ReportSupport.getReportSelectorResult(reportSelectorId, getCbQLOfFilter(reportSelectorId, "referenceToId", selectedItemIds));
								codebeamer.ReportSupport.renderField(reportSelectorId, fieldObject, false, values);
							} else {
								cbQLForPlannerFilters = null;
								forceReportSelectorSearch();
							}
						});
					});
				}
			});
		};

		var url = contextUrl + "/ajax/planner/coloredRelationItems.spr";
		var reportSelectorId = $(".reportSelectorTag").attr("id");
		var container = $(".relations-accordion.accordion-content");
		container.empty().append($("<div>", { "class" : "reportAjaxLoading"}).append($("<img>", { src: contextPath + "/images/ajax-loading_16.gif"})));
		var cbQL = cbQLForPlannerFilters != null ? cbQLForPlannerFilters : codebeamer.ReportSupport.getCbQl(reportSelectorId);
		var data = {
			version_id : codebeamer.ReportSupport.getReleaseId(reportSelectorId),
			tracker_id: codebeamer.ReportSupport.getReleaseTrackerId(reportSelectorId),
			filterProjectIds: codebeamer.ReportSupport.getFilterProjectIds(reportSelectorId),
			filterTrackerIds: codebeamer.ReportSupport.getFilterTrackerIds(reportSelectorId),
			cbQL: cbQL
		};
		if ($("#currentVersion").length > 0) {
			data["recursive"] = codebeamer.ReportSupport.getRecursiveRelease(reportSelectorId);
		}
		$.post(url, data)
			.success(function(response) {
				container.html($.trim(response));
				setupColorFilters();
				setPlannerFilters(cbQL);
				if (!skipSetupDroppables) {
					setupDroppables(".left-pane .color-filters li");
				}
				addClosedGroupHeaders();
				if (callback) {
					callback();
				}
				leftPane.find(".overflow").scrollTop(scrollTop);
				updateLeftPaneContextMenuIcons();
			}).fail(function() {
				container.html(i18n.message("ajax.genericError"));
			});
	};

	var addClosedGroupHeaders = function() {

		showAjaxLoading();

		var addReleaseRow = function(colspan, $release, $table, $header, append, $referenceRow) {
			var $tr = $("<tr>", { "class" : "skipIdent groupRow releaseGroupRow" });
			var $td = $("<td>", { "class" : "releaseGrouppingLevel", "height" : "auto", "colspan" : colspan});
			$td.append($release);
			var releaseId = $release.attr("data-releaseId");
			$td.append($("<span>", { "class" : "releaseMenu", "id" : "context-menu-" + releaseId, "data-id" : releaseId}));
			var $newGroupItemCont = $("<span>", { "class" : "newGroupItemContainer"});
			$newGroupItemCont.append($("<a>", { "class" : "newGroupItem", "href" : "#" }).text(i18n.message("planner.new.group.item")));
			$td.append($newGroupItemCont);
			$tr.append($td);
			$header.show();
			if (append) {
				$table.append($tr);
				$table.append($header);
			} else if ($referenceRow != null) {
				$referenceRow.after($header);
				$referenceRow.after($tr);
			} else {
				$table.prepend($header);
				$table.prepend($tr);
			}
		};

		var addGroupRow = function($li, $rowItem, colspan, $row, noGroupText, cbQLVariable, id, itemIds, closedGroupIds) {
			var bgColor = $li.css("background-color");
			var count = $li.attr("data-count");

			// Do not add group header if it is not closed and if it is not in the current page
			var page = parseInt($li.attr("data-page"), 10);
			var $pagelink = $("#plannerCenterPane .pagelinks");
			if ($pagelink.length > 0) {
				var currentPage = parseInt($pagelink.find("strong").text(), 10);
				if (currentPage !== page && closedGroupIds && closedGroupIds.indexOf(id) === -1) {
					return;
				}
			}

			if (noGroupText) {
				bgColor = "hsl(0, 0%, 90%)";
			}
			var $tr = $("<tr>", { "class" : "skipIdent groupRow rankable firstLevel"});
			var closedGroupIsInTheList = true;
			if (cbQLVariable && id) {
				$tr.attr("data-cbqlvariable", cbQLVariable);
				$tr.attr("data-id", id);
				closedGroupIsInTheList = closedGroupIds && closedGroupIds.indexOf(id) > -1;
			}
			if (itemIds) {
				$tr.attr("data-itemIds", itemIds);
			}
			$tr.append($("<td>", { "class" : "groupHeaderIssueHandle issueHandle ui-sortable-handle"}));
			$tr.append($("<td>", { "class" : "groupHeaderPlaceholder", "style" : "background-color: " + bgColor}));
			var $groupingTd = $("<td>", { "class" : "groupping-level groupping-level-top groupping-level-1 groupping-ident-1", "style" : "background-color: " + bgColor, "colspan": colspan});
			if (closedGroupIsInTheList) {
				$groupingTd.append($("<span>", { "class" : "opener opened"}));
			} else {
				$groupingTd.append($("<span>", { "class" : "opener opened disabled", "title" : i18n.message("planner.missing.items.warning")}));
			}
			if (noGroupText) {
				$groupingTd.append($("<span>", { "class" : "headerNoGroup"}).text(noGroupText));
			} else {
				$groupingTd.append($("<span>", { "class" : "groupRank" }));
				var $wikiLinkContainer = $("<span>", { "class": "wikiLinkContainer"});
				$wikiLinkContainer.append($rowItem);
				$groupingTd.append($wikiLinkContainer);
			}
			var $itemCount = $("<span>", { "class" : "itemCount"});
			$itemCount.text(" (" + count + " " + i18n.message(count > 1 ? "queries.group.header.multiple" : "queries.group.header.single") + ")");
			$groupingTd.append($itemCount);
			$tr.append($groupingTd);
			$row.after($tr.clone());
		};

		if ($(".left-pane .color-filters").hasClass("referenceRelations")) {

			var $closedGroups = $("#plannerClosedGroups").val();
			var closedGroupIds = [];
			if ($closedGroups.length > 0) {
				closedGroupIds = $closedGroups.split(",");
			}

			var $releases = $(".left-pane .color-filters li.release");
			var isBacklog = $releases.length == 0;
			var $header = $("#trackerItems thead tr");
			$header.addClass("headerRow");

			var isTableEmpty = $("#trackerItems tbody tr").first().hasClass("empty");
			if (isTableEmpty) {
				var addedGroupRow = false;
				$header.prepend($("<th>", { "class" : "skipColumn"}));
				$header.prepend($("<th>", { "class" : "skipColumn"}));
				var colspan = $header.find("th").length;
				if ($releases.length > 0) {
					$("#trackerItems .empty").remove();
					$("#trackerItems thead").hide();
					$("#trackerItems").next(".pagebanner").hide();
					$releases.each(function() {
						addReleaseRow(colspan, $(this).find(".releaseGroupName").clone(), $("#trackerItems"), $header.clone(), true);
					});
				}

				var groupRowColspan = $header.find("th").length - 2;
				$(".left-pane .color-filters li.relation:not(.release)").each(function() {
					var $releaseLi = $(this).prevAll(".release").first();
					var $referenceRow = $("#trackerItems tr").last();
					var noGroupText = $(this).hasClass("noGroup") ? $(this).text() : null;
					if ($releaseLi.length > 0) {
						var $releaseRow = $("#trackerItems").find(".releaseGroupName[data-releaseId=" + $releaseLi.attr("data-releaseId") + "]").closest(".releaseGroupRow");
						$referenceRow = $releaseRow.nextUntil(".releaseGroupRow").last();
					}
					addedGroupRow = true;
					addGroupRow($(this), $(this).find(".item-name .wikiLinkContainer").clone(), groupRowColspan, $referenceRow, noGroupText, $(this).attr("data-cbql-variable"), $(this).attr("data-id"), $(this).attr("data-itemIds"), closedGroupIds);
				});
				if (addedGroupRow) {
					$("#trackerItems").find("tr.empty").remove();
				}

			} else {
				var groupRowColspan = $header.find("th").length - 2;
				if (!isBacklog) {
					var index = 0;
					$releases.each(function() {
						var releaseId = $(this).attr("data-releaseId");
						var $releaseRow = $("#trackerItems").find('.releaseGroupName[data-releaseId="' + releaseId + '"]').closest(".releaseGroupRow");
						if ($releaseRow.length == 0) {
							var $referenceRow = null;
							if (index > 0) {
								var $lastReleaseRow = $("#trackerItems").find('.releaseGroupName[data-releaseId="' + $($releases.get(index - 1)).attr("data-releaseId") + '"]').closest(".releaseGroupRow");
								if ($lastReleaseRow.length == 0) {
									$referenceRow = null;
								} else {
									$referenceRow = $lastReleaseRow.next(".headerRow");
								}
							}
							addReleaseRow($header.find("th").length, $(this).find(".releaseGroupName").clone(), $("#trackerItems").find("tbody"), $header.clone(), false, $referenceRow);
						}
						index++;
					});
					$releases.each(function() {
						var $releaseLi = $(this);
						var $lis = $releaseLi.nextUntil(".release");
						var releaseId = $releaseLi.attr("data-releaseId");
						var $releaseRow = $("#trackerItems").find('.releaseGroupName[data-releaseId="' + releaseId + '"]').closest(".releaseGroupRow");
						var index = 0;
						$lis.each(function() {
							var $li = $(this);
							var $rows = $("#trackerItems").find('.releaseGroupName[data-releaseId="' + releaseId + '"]').closest(".releaseGroupRow").nextUntil(".releaseGroupRow").filter(".groupRow.firstLevel");
							var noGroupText = $(this).hasClass("noGroup") ? $(this).text() : null;
							if (noGroupText !== null) {
								if ($rows.find(".headerNoGroup").length == 0) {
									addGroupRow($li, null, groupRowColspan, $rows.length == 0 ? $releaseRow.next(".headerRow") : $rows.nextUntil(".releaseGroupRow").last(), noGroupText, null, null, $li.attr("data-itemIds"), closedGroupIds);
								}
							} else {
								var id = $li.attr("data-id");
								if ($rows.filter("[data-id=" + id + "]").length == 0) {
									var $referenceRow = $("#trackerItems").find('.releaseGroupName[data-releaseId="' + releaseId + '"]').closest(".releaseGroupRow").next(".headerRow").next(".groupPlaceholderRow");
									var $previousLi = $($lis.get(index - 1));
									var $referenceRowGroup = $rows.filter("[data-id=" + $previousLi.attr("data-id") + "]");
									if ($referenceRowGroup.length == 0) {
										$referenceRow = $releaseRow.next(".headerRow");
									} else {
										var $untilRelease = $referenceRowGroup.nextUntil(".releaseGroupRow");
										var $untilGroup = $referenceRowGroup.nextUntil(".groupRow.firstLevel");
										if ($untilGroup.length == 0 || $untilRelease.length == 0) {
											$referenceRow = $referenceRowGroup;
										} else if ($untilRelease.length < $untilGroup.length) {
											$referenceRow = $untilRelease.last();
										} else {
											$referenceRow = $untilGroup.last();
										}
									}
									addGroupRow($li, $li.find(".item-name .wikiLinkContainer").clone(), groupRowColspan, $referenceRow, null, $li.attr("data-cbql-variable"), $li.attr("data-id"), $li.attr("data-itemIds"), closedGroupIds);
								}
							}
							index++;
						});
					});
				} else {
					var $lis = $(".left-pane .color-filters li.relation:not(.release)");
					var index = 0;
					$lis.each(function() {
						var $li = $(this);
						var $rows = $("#trackerItems").find(".groupRow.firstLevel");
						var noGroupText = $(this).hasClass("noGroup") ? $(this).text() : null;
						if (noGroupText !== null) {
							if ($rows.find(".headerNoGroup").length == 0) {
								addGroupRow($li, null, groupRowColspan, $("#trackerItems tr").last(), noGroupText, null, null, $li.attr("data-itemIds"), closedGroupIds);
							}
						} else {
							var id = $li.attr("data-id");
							if ($rows.filter("[data-id=" + id + "]").length == 0) {
								var $referenceRow = $("#trackerItems tr").first();
								var $previousLi = $($lis.get(index - 1));
								var $referenceRowGroup = $rows.filter("[data-id=" + $previousLi.attr("data-id") + "]");
								if ($referenceRowGroup.length > 0) {
									var $untilGroup = $referenceRowGroup.nextUntil(".groupRow.firstLevel");
									if ($untilGroup.length == 0) {
										$referenceRow = $referenceRowGroup;
									} else {
										$referenceRow = $untilGroup.last();
									}
								}
								addGroupRow($li, $li.find(".item-name .wikiLinkContainer").clone(), groupRowColspan, $referenceRow, null, $li.attr("data-cbql-variable"), $li.attr("data-id"), $li.attr("data-itemIds"), closedGroupIds);
							}
						}
						index++;
					});
				}
			}

			var groupIndex = 1;
			var lastReleaseIdForRank = null;
			$("#trackerItems .groupRank").each(function() {
				var $releaseGroupRow = $(this).closest("tr").prevAll(".releaseGroupRow").first();
				if ($releaseGroupRow.length > 0) {
					var releaseIdForRank = $releaseGroupRow.find(".releaseGroupName").attr("data-releaseId");
					if (releaseIdForRank != lastReleaseIdForRank) {
						groupIndex = 1;
					}
					lastReleaseIdForRank = releaseIdForRank;
				}
				$(this).text(groupIndex);
				groupIndex++;
			});

			hideAjaxLoading();

			$(".expandAll").show();
			$(".expandAll").off("click");
			$(".expandAll").on("click", function() {
				var groupingField = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
				var cbQlVariable = groupingField.data("fieldObject")["cbQLGroupByAttributeName"];
				$.ajax(contextPath + "/ajax/planner/removeAllGroupClosedState.spr", {
					method: "POST",
					async: false,
					data: {
						cbQLVariable: cbQlVariable,
						includeNoGroup: true
					}
				}).fail(function() {
					showFancyAlertDialog(i18n.message("planner.collapse.state.save.error"));
				});
				forceReportSelectorSearch();
			});

			$(".collapseAll").show();
			$(".collapseAll").off("click");
			$(".collapseAll").on("click", function() {
				var groupingField = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
				var cbQlVariable = groupingField.data("fieldObject")["cbQLGroupByAttributeName"];
				var ids = [];
				$(".left-pane .color-filters li.relation:not(.release)").each(function() {
					var id = parseInt($(this).attr("data-id"), 10);
					if (id && ids.indexOf(id) === -1) {
						ids.push(id);
					}
				});
				storeGroupClosedState(cbQlVariable, ids, false, false);
				storeGroupClosedState(cbQlVariable, [], true, false);
				forceReportSelectorSearch();
			});

		} else {
			hideAjaxLoading();
			$(".expandAll").hide();
			$(".collapseAll").hide();
			$("#trackerItems .opener").hide();
		}
	};

	var getCbQLOfFilter = function(reportSelectorId, cbQLAttrName, selectedIds) {
		var existingCbQL = codebeamer.ReportSupport.getCbQl(reportSelectorId);
		var cbQL = "";
		if (selectedIds.length == 0) {
			cbQL = cbQLAttrName + " IS NULL";
		} else {
			cbQL = cbQLAttrName + " IN (" + selectedIds.join(",") + ")";
		}
		var groupByIndex = existingCbQL.indexOf("GROUP BY");
		if (groupByIndex > -1) {
			cbQL = existingCbQL.substr(0, groupByIndex) + " AND " + cbQL + " " + existingCbQL.substr(groupByIndex);
		} else if (existingCbQL.length > 0) {
			cbQL += " AND " + existingCbQL;
		}
		setCbQLForPlannerFilters(cbQL);
		return cbQL;
	};

	var updateUrl = function(versionId) {
		var urlUpdate = versionId == "-1" ? UrlUtils.addOrReplaceParameter(location.href, "openProductBacklog", "true") : UrlUtils.removeParameter(location.href, "openProductBacklog");
		History.pushState({ "url" : urlUpdate }, document.title, urlUpdate);
	};

	var addLeftPaneEventHandlers = function() {
		var leftPane = $("#planner").find(".left-pane");

		var $reportSelector = $("#planner").find(".reportSelectorTag");
		var reportSelectorId = $reportSelector.attr("id");

		var addTeamFilter = function(e, $team) {
			var target = $(e.target);
			if (target.is(".expander")) {
				return true;
			}
			var noTeamSelected = false;

			var wasSelected = $team.is(".selected");
			if ($team.attr("data-teamId") == "-1" && !wasSelected) {
				noTeamSelected = true;
				$(".filter.team").each(function() {
					if ($(this).attr("data-teamId") != "-1") {
						$(this).removeClass("selected");
						$(this).find(".color-box").removeClass("state-checked");
					}
				});
			} else {
				$('.filter.team[data-teamId="-1"]').removeClass("selected");
				$('.filter.team[data-teamId="-1"]').find(".color-box").removeClass("state-checked");
			}

			if ($team.attr("data-teamId") == "-1") {
				$team.find(".color-box").toggleClass("state-checked", !wasSelected);
				$team.toggleClass("selected", !wasSelected);
			} else {
				$team.find(".color-box").toggleClass("state-checked");
				$team.toggleClass("selected");
			}

			var selectedTeams = [];
			var selectedTeamIds = [];
			if (!noTeamSelected) {
				$(".filter.team").each(function() {
					if ($(this).is(".selected")) {
						var teamId = $(this).attr("data-teamId");
						if (teamId != "-1") {
							selectedTeams.push({ value: teamId });
							selectedTeamIds.push(teamId);
						}
					}
				});
			}
			var values = [];
			if (noTeamSelected) {
				values.push({
					left: {
						value : "TeamID"
					},
					operator: "IS NULL"
				});
			} else {
				values.push({
					left: {
						value : "TeamID"
					},
					operator: "IN",
					right: {
						value: selectedTeams
					}
				});
			}

			var $referenceFields = $(".reportSelectorTag").find("button.referenceField");
			$referenceFields.each(function() {
				var fieldInfo = $(this).data("fieldObject");
				if (fieldInfo.id == 21) {
					$(this).next(".removeIcon").click();
				}
			});

			if (noTeamSelected || selectedTeams.length > 0) {
				$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
					dataType: "json",
					data: { field_id: 21 },
					async: false
				}).done(function(fieldObject) {
					codebeamer.ReportSupport.getReportSelectorResult(reportSelectorId, getCbQLOfFilter(reportSelectorId, "TeamID", selectedTeamIds));
					codebeamer.ReportSupport.renderField(reportSelectorId, fieldObject, false, values);
				});
			} else {
				forceReportSelectorSearch();
			}

			return false;
		};

		leftPane.off("click", ".filter");
		leftPane.on("click", ".filter", function(e) {
			var version = $(this);

			var menuLabel = version.find(".extendedReleaseMenu, .menuArrowDown").first();
			var target = $(e.target);
			if (target[0] == menuLabel[0]) {
				return true;
			}

			var isTeam = version.is(".team");
			if (isTeam) {
				addTeamFilter(e, $(this));
				return false;
			}

			if (target.hasClass("drag-in-progress")) {
				return false;
			}

			if (target.is(".expander")) {
				return true;
			}

			if (!target.is("li.filter")) {
				target = target.closest("li.filter");
			}

			var versionId = target.attr("data-version-id");
			var isBacklog = target.hasClass("backlog");
			if (isBacklog) {
				target.parent().find(".version[data-version-id=" + versionId + "]").toggleClass("virtually-selected");
			}
			version.siblings(".filter.selected").removeClass("selected"); // remove all existing selections


			version.toggleClass("selected");

			var currentTrackerId = $("#currentTracker").attr("data-id");
			if (version.hasClass("selected")) {
				codebeamer.ReportSupport.setRelease(reportSelectorId, versionId, versionId == "-1" ? currentTrackerId : null, false);
			} else {
				var currentVersionId = $("#currentVersion").attr("data-id");
				if (currentVersionId) {
					codebeamer.ReportSupport.setRelease(reportSelectorId, currentVersionId, null, true);
				} else {
					codebeamer.ReportSupport.setReleaseTrackerId(reportSelectorId, currentTrackerId);
				}
			}

			$(".extendedReleaseMenu.menu-downloaded", function() {
				$(".extendedReleaseMenu").removeClass("menu-downloaded").removeData("menujson");
				$.contextMenu("destroy", $(this));
			});

			forceReportSelectorSearch();
			updateUrl(version.hasClass("selected") ? versionId : null);

			return false;
		});

		leftPane.off("click", ".expander");
		leftPane.on("click", ".expander", function () {
			var $expander = $(this);
			var $team = $expander.parents("li");
			var level = $team.data("level");
			var $siblings = $team.siblings();
			var hide = $expander.is(".expanded");
			$expander.toggleClass("expanded");

			var $next = $team.next();
			while ($next && $next.is("li") && $next.data("level") > level) {
				if (hide) {
					$next.hide();
					$next.find(".expander").removeClass("expanded");
				} else {
					$next.show();
					$next.find(".expander").addClass("expanded");
				}
				$next = $next.next();
			}
		});

		leftPane.off("click", ".color-filters .level-2 .simpleDropdownMenu .menuArrowDown");
		leftPane.on("click", ".color-filters .level-2 .simpleDropdownMenu .menuArrowDown", function (event) {
			var $menuContainer = $(this).parents("li.level-2");
			var $menuArrow = $(this).parent();

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				buildInlineMenuFromJson($(this).parent(), ".color-filters .level-2[data-id=" + $menuContainer.data("id") + "]  .simpleDropdownMenu", {
					'task_id': $menuContainer.data("id"),
					'cssClass': 'inlineActionMenu transition-action-menu',
					'builder': 'plannerRelationsActionMenuBuilder',
					'currentVersionId':  $('.issuelist').siblings('.id').data('versionId'),
					'releaseTrackerId': getReleaseTrackerId()
				}, $('.relations-accordion.accordion-content'));

			}

		});

		var setupDraggables = function() {
			var currentVersionId = $("#currentVersion").data("id");
			var currentVersion = findVersionById(currentVersionId, true);
			var realVersions = leftPane.find(".version:not(.virtual)").not(currentVersion);

			setTimeout(function() {
				realVersions.each(function() {
					var $this = $(this);
					$this.css("height", $this.css("height")).find(".knob").show();
				});
			}, 1000);

			leftPane.find(".filter .knob").click(function(e) {
				e.stopImmediatePropagation();
			});

			realVersions.draggable({
				"revert": true,
				"handle": ".knob",
				zIndex: 100,
				"start": function() {
					var version = $(this);
					if (version.is(".selected")) {
						version.click();
					}
					version.addClass("drag-in-progress");
				},
				"stop": function() {
					var draggable = $(this);
					setTimeout(function() {
						draggable.removeClass("drag-in-progress");
					}, 100);
				}
			});
		};

		var setupAccordion = function() {
			var leftAccordion = getLeftAccordion();
			leftAccordion.cbMultiAccordion();

			leftAccordion.on("open", function(event, headerIndex) {
                if (headerIndex == 1) { // Team tab
					refreshTeamIssueCounters();
                }
			}).on("openOrClose", function() {
				var state = leftAccordion.cbMultiAccordion("saveState");
				storeItemAccordionState(state, "PLANNER_ITEM_ACCORDION_STATE");
			});

			$.get(contextUrl + "/userSetting.spr?name=PLANNER_ITEM_ACCORDION_STATE", function(response) {
				var stateObject = $.parseJSON(response);
				leftAccordion.prop("default-accordion-state", stateObject);
				itemAccordionStatePersistence = false;
				leftAccordion.cbMultiAccordion("restoreState", stateObject);
				itemAccordionStatePersistence = true;
			});
		};
		setupDroppables();
		setupDraggables();
		setupAccordion();

		var actionLane = $("#planner").find(".action-lane");

		actionLane.find(".add-new-item-link").not(".initialized").click(function() {
			addIssue();
			return false;
		}).addClass("initialized");

		actionLane.find(".add-new-version-link").not(".initialized").click(function() {
			addVersion();
			return false;
		}).addClass("initialized");

		$(".add-team-icon").not(".initialized").click(function () {
			var url = contextPath + "/planner/createIssueWithType.spr?type_id=150&isPopup=true";
			showPopupInline(url);
			return false;
		}).addClass("initialized");

		$(".export-to-excel-icon").not(".initialized").click(function () {
			exportToExcel();
			return false;
		}).addClass("initialized");

		leftPane.find(".version.filter a").not(".expander").click(function(event) {
			event.stopPropagation();
		});

		initJQueryMenus(leftPane);

	};

	var toggleSortableElements = function() {
		$("#planner").find(".center-pane").find(".issuelist").each(function() {
			var $container = $(this);
			var sortable = isCurrentIssueListSortable($container);
			var $items = $container.find(".only-if-sortable");
			$items.each(function() {
				$(this).parent("li").toggle(sortable);
			});
			$items.first().closest("ul").first().prev("h6").toggle(sortable);
		});
	};

	/**
	 * checks if the view is filtered and if yes disables the rows (so that they cannot be moved).
	 */
	var updateSorting = function() {

		var disableRow = function($row) {
			$("td", $row).addClass("disabled");
		};

		var enableRow = function($row) {
			$("td", $row).removeClass("disabled");
		};

		var planner = $("#planner");
		if (isProjectBacklog) {
			if (isProjectBacklogEditable) {
				planner.find(".issuelist tr:not(.targetReleaseEditable)").each(function() {
					disableRow($(this));
				});
			} else {
				planner.find(".issuelist tr").each(function() {
					disableRow($(this));
				});
			}
			planner.find("table.issuelist").addClass("not-sortable");
		} else {
			planner.find(".issuelist tr:not(.targetReleaseEditable)").each(function() {
				enableRow($(this));
			});
			planner.find("table.issuelist").removeClass("not-sortable");
		}

		toggleSortableElements();
	};

	var initSelectionAwareLinks = function(links) {
		$(links).click(function() {
			var href = $(this).attr("href");
			var selection = findSelectedIssue();
			if (selection.length > 0) {
				var selectedId = selection.first().attr("id");
				href += UrlUtils.generateHashParameters({"select": selectedId});
			}
			window.location.href = href;
			return false;
		});
	};

	var addCenterPaneEventHandlers = function(filterForClassName) {
		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");
		var centerPane = planner.find(".center-pane");

		var filterForSelector = (typeof filterForClassName == "undefined") ? "*" : ("." + filterForClassName);

		centerPane.find(".left-pane-toggle").not(".initialized").click(function() {
			leftPane.toggle();
			var leftPaneVisible = leftPane.is(":visible");
			$.cookie("plannerLeftPaneVisible", leftPaneVisible);
			$(this).toggleClass("left-pane-is-hidden");
			centerPane.toggleClass("left-pane-is-hidden");
			return false;
		}).addClass("initialized");

		var filterTextInput = actionLane.find(".filter-text");

		var reload = throttleWrapper(function() {
			filterTextInput.attr("disabled", "disabled");
			reloadIssuesList(function() {
				planner.find(".action-lane .filter-text").setCursorToTextEnd(); // DOM changes, need to find element again
			});
		}, 600);

		var placeholder = i18n.message("planner.filterIssues");

		filterTextInput.keyup(function () {
			var $this = $(this);
			var $body = $("body");
			var val = $this.val();
			if (val.length > 2) {
				reload();
				$body.data("valid-filter", true);
			} else if ($body.data("valid-filter")) {
				reload();
				$body.data("valid-filter", false);
			}
		}).prop("placeholder", placeholder).Watermark(placeholder);

		var setupEditability = function() {
			centerPane.find(".issuelist tr:not(.dnd-initialized)").each(function() {
				var $row = $(this);
				var id = $row.attr("id");
				$(["targetReleaseEditable", "assigneeEditable", "itemEditable", "teamFieldEditable", "summaryEditable", "userStoryFieldEditable", "requirementFieldEditable"]).each(function(i, e) {
					if (e in codebeamer.plannerConfig) {
						if (codebeamer.plannerConfig[e].contains(id)) {
							$row.addClass(e);
						}
					}
				});
			});
		};

		var setupSortables = function() {
			if (codebeamer.plannerConfig.hasAgileLicense) {
				centerPane.find(".issuelist").each(function () {
					var $container = $(this);
					setupSortableForIssueList($container);
				});
			}
		};

		var addRowEventHandlers = function() {
			var rows = centerPane.find(".issuelist tr").not(".tableHeader").filter(filterForSelector);

			rows.each(function() {
				var row = $(this);
				var url = contextUrl + "/issue/" + row.attr("id");
				row.find(".issueKey a").attr({
					"href": url
				});

				if (row.hasClass("itemEditable")) {
					var editIcon = $("<a>", {
						"class": "editInOverlayIcon",
						"title": i18n.message("planner.editInOverlay.tooltip")
					}).click(function() {
						editItemInOverlay(findParentRow(editIcon).data("item-id"));
					});
					editIcon.insertBefore(row.find(".simpleDropdownMenu"));
				}
			});

			// wrap to prevent firing on double click
			// but known issue: in IE8, double click triggers single click event handler once
			var selectHandler = singleCallWrapper(function(e) {
				var $this = $(this);
				var target = $(e.target);
				var menuLabel = $this.find(".menuArrowDown").first();
				if (target[0] == menuLabel[0]) {
					return false;
				}

				var isSelected = $this.is(".selected");
				var isNoOtherSelected = $this.siblings().find(".selected").length == 0;

				var removeAllExistingSelection = function() {
					centerPane.find(".issuelist tr.selected").removeClass("selected");
				};

				removeAllExistingSelection();

				var rightAccordion = getRightAccordion();
				var rightOverflow = rightAccordion.prev(".overflow");
				var sections = [0, 1, 2, 3, 4];
				if (isSelected) {
					$this.removeClass("selected");
					if (isNoOtherSelected) {
						rightAccordion.cbMultiAccordion("close", sections);
					}
				} else {
					$this.addClass("selected");
					reloadSelectedIssue(function() {
						rightAccordion.cbMultiAccordion("enable", sections);
						var defaultState = rightAccordion.prop("default-accordion-state");
						itemAccordionStatePersistence = false;
						rightAccordion.cbMultiAccordion("restoreState", defaultState);
						itemAccordionStatePersistence = true;
						rightAccordion.prop("default-accordion-state", null);
						rightAccordion.cbMultiAccordion("scrollToHeader", 0, rightOverflow);
					});
				}
			}, 200);

			rows.click(selectHandler);

			rows.each(function() {
				initJQueryMenus(this);
			});
		};

		setupEditability();
		setupSortables();
		addRowEventHandlers();

		toggleSortableElements();
		InplaceEditor.init(); // TODO: filterForSelector?

		var addNextPageEventHandler = function() {
			var centerPane = $("#planner").find(".center-pane");
			var centerPaneOverflow = centerPane.find(".overflow");

			var handler = function() {
				var $this = $(this);
				var centerPane = $("#planner").find(".center-pane");
				var lastVersion = centerPane.find(".issuelist").filter(":visible").last();
				var lastVersionRow = lastVersion.find("tr").last();
				var startVersionId = $this.data("start-version-id");
				var lastItemIdRendered = $this.data("last-item-id-rendered");

				var loaderId = getUniqueId();
				var loader = $("<div class='load-more-in-progress' style='text-align: center; padding: 1em;'></div>");
				loader.attr("id", loaderId).html('<img src="' + ajaxLoaderImageUrl + '">');
				$this.replaceWith(loader);

				var versionId = $("#currentVersion").data("id");
				var trackerId = $("#currentTracker").data("id");

				var params = {
					paging_start_version_id: startVersionId,
					paging_last_item_id_rendered: lastItemIdRendered
				};

				if (versionId) {
					params.task_id = versionId;
				} else {
					params.tracker_id = trackerId;
				}

				$.post(contextUrl + "/ajax/plannerPager.spr",
					$.extend(params, getFilterParameters()),
					function(data) {
						// check if DOM hasn't changed since AJAX request start to avoid weird situations
						if ($("#" + loaderId).length == 1) {
							var response = $("<div></div>").html(data);
							var newRows = response.find(".issuelist tr").addClass("uninitialized");

							var oldStartVersionId = lastVersion.prev(".id").first().data("version-id");
							var newStartVersionId = newRows.first().closest("table").prev(".id").first().data("version-id");
							var firstNewIssueList = (newStartVersionId && newStartVersionId != "") ? response.find("[data-version-id=" + newStartVersionId + "]").next(".issuelist") : response.find(".issuelist").first();

							if (oldStartVersionId == newStartVersionId) { // must append to previously loaded list
								var rowsToInsertToLastVersion = firstNewIssueList.find("tr").not(".tableHeader");
								if (rowsToInsertToLastVersion.length > 0) {
									rowsToInsertToLastVersion.insertAfter(lastVersionRow);
									var fixClasses = function() {
										var isOdd = function(tr) {
											return tr.hasClass("odd");
										};

										var firstRow = rowsToInsertToLastVersion.first();

										lastVersionRow.removeClass("last-row-in-table");
										rowsToInsertToLastVersion.last().addClass("last-row-in-table");

										var isParityMixed = isOdd(firstRow) == isOdd(lastVersionRow);
										if (isParityMixed) {
											rowsToInsertToLastVersion.each(function() {
												$(this).toggleClass("odd even");
											});
										}
									};
									fixClasses();
								}
								loader.replaceWith(firstNewIssueList.nextAll());
							} else {
								loader.replaceWith(response.html());
							}

							hideEmptyReleases();
							addCenterPaneEventHandlers("uninitialized");
							centerPane.find(".uninitialized").removeClass("uninitialized");
							addParentsIfNecessary();
						}
					}
				);
				return false;
			};

			initSelectionAwareLinks(centerPane.find(".append-selection-id"));

			var loadMoreLink = centerPane.find(".load-more");
			loadMoreLink.click(handler);
			loadMoreLink.waypoint(handler, {
				offset: function() {
					return centerPaneOverflow.height() + 100;
				},
				context: '.overflow'
			});
		};

		setTimeout(addNextPageEventHandler, 500);

		var initHistory = function() {
			centerPane.find("tr").slice(maxHistoryCountToShow).hide();

			var refreshHistoryFiltering = throttleWrapper(function() {
				var filterText = $(this).val();
				filterText = filterText ? filterText.toLowerCase() : "";
				var rows = centerPane.find("tr").hide();
				var shown = 0;
				rows.removeClass("first-row-in-table last-row-in-table");
				rows.each(function() {
					var row = $(this);
					if ((row.find(".issueName").text().toLowerCase().indexOf(filterText) != -1) && (shown < maxHistoryCountToShow)) {
						if (shown == 0) {
							row.addClass("first-row-in-table");
						}
						row.show();
						shown++;
					} else {
						row.hide();
					}
					centerPane.find(".empty-filtered").toggle(shown == 0);
				});
				rows.filter(":visible").last().addClass("last-row-in-table");
			}, 100);

			var input = centerPane.find(".history-filter-controls").find("input[type=text]");
			input.keyup(refreshHistoryFiltering);
			refreshHistoryFiltering.call(input);
		};

		// add project backlog controls if needed
		var controls = centerPane.find(".backlog-controls:not(.initialized)");
		if (controls.length > 0) {
			controls.find(".navigation li").click(function() {
				loadProjectBacklogTab(this);
			});
			controls.addClass("initialized");
		}

		if (centerPane.find(".backlog-controls .history").is(".selected")) {
			initHistory();
		}

		setupCenterAutoScrollOnDnD(planner.find(".center-pane"), $("#planner").find(".center-pane .overflow"));
	};

	var storeItemAccordionState = throttleWrapper(function(state, propertyName) {
		if (itemAccordionStatePersistence) {
			$.post(contextPath + "/userSetting.spr", {
				"name": propertyName,
				"value": JSON.stringify(state)
			});
		}
	}, 500);

	var addRightPaneEventHandlers = function() {
		var accordion = getRightAccordion();

		accordion.cbMultiAccordion({"active": -1})
			.cbMultiAccordion("disable", [0, 1, 2, 3, 4])
			.on("openOrClose", function() {
				var state = accordion.cbMultiAccordion("saveState");
				storeItemAccordionState(state, "DOCUMENT_VIEW_ITEM_ACCORDION_STATE");
			})
			.on("refreshCommentCount", function() {
				refreshCommentCount();
			});

		$.get(contextUrl + "/userSetting.spr?name=DOCUMENT_VIEW_ITEM_ACCORDION_STATE", function(response) {
			var stateObject = $.parseJSON(response);
			accordion.prop("default-accordion-state", stateObject);
		});
	};

	var addGlobalEventHandlers = function() {
		$(window).resize(function() {
			adjustLayout();
		});

		$("#headerToggler").click(function() { // adjust layout after hiding header
			adjustLayout();
		});

		$("#planner").bind("eastResize", function() {
			codebeamer.planner.adjustLayout();
		}).bind("eastOpen", function() {
			codebeamer.planner.adjustLayout();
		}).bind("eastClose", function() {
			codebeamer.planner.adjustLayout();
		});

		// TODO
		// var storeLeftPaneSize = throttleWrapper(function(size) {
		// 	$.post(contextPath + "/userSetting.spr", {
		// 		"name": "PLANNER_LEFT_PANE_WIDTH",
		// 		"value": size + "px"
		// 	});
		// }, 500);
		//
		// $(".left-pane").resizable({
		// 	minWidth: 300,
		// 	maxWidth: 500,
		// 	handles: "e",
		// 	start: function(event, ui) {
		// 		$(ui.element).find(".ui-resizable-handle").addClass("being-dragged");
		// 	},
		// 	stop: function(event, ui) {
		// 		$(ui.element).find(".ui-resizable-handle").removeClass("being-dragged");
		// 		storeLeftPaneSize(ui.size.width);
		// 	}
		// });
	};

	var loadProjectBacklogTab = function(li, callback) {
		var centerPane = $("#planner").find(".center-pane");
		var controls = centerPane.find(".backlog-controls");
		controls.nextAll().remove(); // remove all page data below

		li = $(li);

		li.addClass("selected").siblings().removeClass("selected");
		var arrowClass = li.data("arrow-class");
		li.siblings("." + arrowClass).addClass("selected");

		var relativeUrl = li.data("url");
		if (!relativeUrl) {
			return ;
		}

		var url = contextUrl + relativeUrl;
		var loader = $("<div class='backlog-controls-loader'></div>").insertAfter(controls);

		$.post(url, getFilterParameters(), function(response) {
			loader.replaceWith(response);
			afterIssueListsLoaded();
			if ($.isFunction(callback)) {
				callback.call();
			}
		});
	};

	var initRightPaneInlineEditing = function($propertyTable, $descriptionField) {
		if ($propertyTable.length) {
			codebeamer.DisplaytagTrackerItemsInlineEdit.init($propertyTable);
		}
		if ($descriptionField.length) {
			codebeamer.DisplaytagTrackerItemsInlineEdit.initForField($descriptionField, true);
		}
	};
	
	var reloadSelectedIssue = function(callback, id) {
		var taskId = null;
		if (id) {
			taskId = id;
		} else {
			var $tr = findSelectedIssue();
			if ($tr.size() == 0) {
				return;
			}
			taskId = $tr.attr("id");
		}

		if (taskId == null) {
			return;
		}

		var container = getRightAccordion();
		var issueDetailsContainer = container.find("> .issue-details");
		var issueDescriptionContainer = container.find("> .issue-description");
		var issueCommentsContainer = container.find("> .issue-comments");
		var issueAssociationsContainer = container.find("> .issue-associations");
		var issueReferencesContainer = container.find("> .issue-references");

		var $props = $(".issue-details");
		var p = $props[0];
		var busySign = ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
			width: "12em",
			context: [ p, "tl", "tl", null, [($props.width() > 0 ? ($props.width() - 12) / 2 : 200), 10] ]
		});

		$.ajax({
			"url": contextUrl + "/trackers/ajax/readIssueProperties.spr",
			"type": "GET",
			"data": {
				"task_id": taskId,
				"showDescription": true,
				"allowAddComment": true,
				"showActionBar": false,
				"descriptionOpen": $.cookie("codebeamer.planner.descriptionOpen"),
				"commentsOpen": $.cookie("codebeamer.planner.commentsOpen")
			},
			"success": function(data) {
				data = $("<div></div>").html(data);

				var inject = function(cont, roles) {
					if (!$.isArray(roles)) {
						roles = [ roles ];
					}
					for (var i = 0; i < roles.length; i++) {
						var content = data.find("[data-planner-role=" + roles[i] + "]");
						(i == 0) ? cont.html(content) : cont.append(content);
					}
				};

				inject(issueDetailsContainer, ["title", "details", "transitions"]);
				inject(issueDescriptionContainer, "description");
				inject(issueCommentsContainer, ["add-comment", "comments"]);
				inject(issueAssociationsContainer, ["associations"]);
				inject(issueReferencesContainer, ["references"]);

				// make issue link open a new tab
				container.find("[data-planner-role=title] a").attr("target", codebeamer.userPreferences.newWindowTarget);

				// swap comment titles with contents
				var commentGroups = issueCommentsContainer.find(".commentGroup");
				commentGroups.each(function() {
					var cont = $(this).find(".commentContent");
					var meta = $(this).find(".commentMeta");
					meta.insertBefore(cont);
				});
				refreshCommentCount();
				refreshRelationItemCounter('.issue-associations-title', '.issue-associations');
				refreshRelationItemCounter('.issue-references-title', '.issue-references');

				initJQueryMenus(issueDetailsContainer);
				initJQueryMenus(issueCommentsContainer);
				codebeamer.suspectedLinkBadge.init();

				codebeamer.ReferenceSettingBadges.init(container);

				initRightPaneInlineEditing(issueDetailsContainer.find('.propertyTable.inlineEditEnabled'), issueDescriptionContainer.find('.fieldColumn.inlineEditEnabled'));
				
				var $addAssociationLink = issueAssociationsContainer.find('.addAssociationControl .actionLink');
				if ($addAssociationLink.length) {
					$addAssociationLink.removeAttr('onclick');
					$addAssociationLink.on('click', function() {
						showPopupInline(contextPath + '/proj/tracker/addAssociation.do?inline=true&from_type_id=9&from_id=' + taskId + 
							'&callback=refreshSelectedIssueProperties', { geometry: '70%_70%' });
						return false;
					});
				}
				
				if (callback && $.isFunction(callback)) {
					callback.call();
				}
			},
			"cache": false // no caching because IE cannot handle it correctly
		}).always(function() {
			if (busySign) {
				ajaxBusyIndicator.close(busySign);
			}
		});
	};

	var findSelectedIssue = function() {
		return $("#planner").find(".trackerItems tr.selected");
	};

	var findSelectedIssueId = function() {
		var selection = findSelectedIssue();
		return selection.length > 0 ? selection.first().attr("id") : null;
	};

	var emptyIssueInfoBoxes = function() {
		$("#planner").find(".right-pane").find(".issue-details, .issue-description, .issue-comments, .issue-associations").empty();
		refreshCommentCount(0);
		var rightAccordion = getRightAccordion();
		rightAccordion.cbMultiAccordion("close", [0, 1, 2, 3, 4])
			.cbMultiAccordion("disable", [0, 1, 2, 3, 4]);
	};

	var refreshCommentCount = function(value) {
		var container = getRightAccordion();
		if (typeof value == "undefined") {
			value = container.find(".commentGroup .commentContent").length;
		}
		container.find(".comment-count").text(value > 0 ? "(" + value + ")" : "");
	};

	var refreshRelationItemCounter = function(headerSelector, contentSelector) {
		var container = getRightAccordion();
		var value = $(contentSelector).find('tr.relation-item').length;
		container.find(headerSelector + " .item-count").text(value > 0 ? "(" + value + ")" : "");
	}

	var isCurrentIssueListSortable = function($container) {
		// TODO: check if field in release is editable
		if ($container.hasClass("not-sortable")) {
			return false;
		}
		var $id = $container.prev(".id");
		var $tab = findVersionById($id.data("version-id"), true);
		if (!$tab) {
			return false;
		}
		var type = $tab.data("type");
		var sortable = $tab.data("releaseSortable");
		return type !== "project-backlog" && sortable == true;
	};

	var isCurrentIssueListProjectBacklog = function() {
		return $(".backlog-controls").length > 0;
	};

	var isProjectBacklogEditable = function() {
		var backlogControls, isReadOnly;

		backlogControls = $(".backlog-controls");
		isReadOnly = backlogControls.data("read-only");

		return isReadOnly !== true;
	};

	var adjustRowStylingInAllIssueLists = function() {
		var centerPane = $("#planner").find(".center-pane");
		centerPane.find("table.issuelist").find("tr").each(function() {
			$(this).toggleClass("last-row-in-table", $(this).is(":last-child"));
		});
	};

	var sendIssueTo = function(id, position, where, releaseId) {

		var $table = $("#planner .trackerItems");
		var $row = $table.find('tr[data-tt-id="' + id + '"][data-releaseId="' + releaseId + '"]');

		var $reference = null;
		if (where == "top") {
			$reference = $table.find('tr[data-releaseId="' + releaseId + '"]').first();
		} else {
			$reference = $table.find('tr[data-releaseId="' + releaseId + '"]').last();
		}

		var releaseTrackerId = codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));

		if (id != $reference.attr("data-tt-id")) {
			$.ajax({
				"url": contextPath + "/ajax/moveIssue.spr",
				"type": "POST",
				"data": {
					"taskId": releaseId,
					"movedIssueId":  $row.attr("data-tt-id"),
					"referenceId": $reference.attr("data-tt-id"),
					"position": position,
					"projectId": -1,
					"releaseTrackerId" : releaseTrackerId
				},
				"success": function (response) {
					if (response["success"] == true) {
						if (position == "before") {
							$row.detach().insertBefore($reference);
						} else {
							$row.detach().insertAfter($reference);
						}
						var itemIds = [];
						var $itemRows = $table.find('tr.trackerItem[data-releaseId="' + releaseId + '"]');
						$itemRows.each(function() {
							itemIds.push(parseInt($(this).attr("data-tt-id"), 10));
						});
						$.ajax(contextPath + "/planner/getRanks.spr", {
							method: "POST",
							dataType: "json",
							data : {
								data : JSON.stringify(itemIds),
								releaseId : releaseId,
								releaseTrackerId: releaseTrackerId
							}
						}).done(function(result) {
							showOverlayMessage();
							$itemRows.each(function() {
								var itemId = parseInt($(this).attr("data-tt-id"), 10);
								var rank = result[itemId];
								$(this).attr("data-rank", rank);
								$(this).find(".rankTd .rank").text(rank);
							});
							addParentsIfNecessary();
						});
					} else {
						showOverlayMessage(response.hasOwnProperty("message") ? response.message : i18n.message("planner.rank.general.error"), null, true);
					}
				}
			});
		}

	};

	// TODO remove?
	var refreshRanks = function (releaseId, projectId, movedIssueId, skipAddParents) {
		// update rankings if available
		if ($(".rank").size() > 0) {
			var finalReleaseId, finalProjectId, $release;

			finalReleaseId = -1;
			if (releaseId) {
				finalReleaseId = $.isFunction(releaseId) ? releaseId(movedIssueId) : releaseId;

				if (finalReleaseId) {
					$release = $(".id[data-version-id=" + finalReleaseId + "]").next().find("tbody");
				}
			};

			finalProjectId = -1;
			if (projectId) {
				finalProjectId = projectId;
				$release = $(".id[data-version-id]").next().find("tbody");
			}

			$.get(contextPath + "/ajax/planner/getRanks.spr", {
				"taskId": finalReleaseId,
				"projectId": finalProjectId
			}, function (data) {
				var lastItemPosition, lastItemId;

				lastItemPosition = 0;

				$release.find("tr").each(function () {
					var $row = $(this);
					var rank = data[$row.data("itemId")];
					var $rank = $row.find(".rank");
					$rank.data("rank", rank).html(rank);
				});

				// Also update the last item id to point to the "real" last item
				$.map(data, function(property, key) {
					if (property > lastItemPosition) {
						lastItemPosition = property;
						lastItemId = key;
					}
				});

				if (lastItemId) {
					$release.parents(".issuelist").prev(".id").data("last-item-id", lastItemId);
				}

				if (!skipAddParents) {
					addParentsIfNecessary();
				}

			});
		}
	};

	var moveIssueUpOrDown = function(id, attributes) {
		var direction = attributes.direction;
		var percent = attributes.percent;
		var releaseId = attributes.releaseId;

		var $table = $("#planner .trackerItems");
		var $row = $table.find('tr[data-tt-id="' + id + '"][data-releaseId="' + releaseId + '"]');
		var $rows = $table.find('tr[data-releaseId="' + releaseId + '"]');

		var rowsToMove = (percent ? Math.floor(percent * $rows.length / 100) : 9);

		var index = -1;
		for (var i = 0; i < $rows.length; i++) {
			if ($($rows.get(i)).attr("id") == id) {
				index = i;
				break;
			}
		}

		var referenceIndex = direction == "middle" ? Math.floor($rows.length / 2) : (direction == "top" ? index - rowsToMove : index + rowsToMove);
		if (referenceIndex < 0) {
			referenceIndex = 0;
		}

		if (referenceIndex > $rows.length) {
			referenceIndex = $rows.length - 1;
		}

		var releaseTrackerId = codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));

		var $reference = $($rows.get(referenceIndex));
		var referenceId = $reference.attr("id");
		var position = direction == "top" ? "before" : "after";
		if (referenceId != id) {
			$.ajax({
				"url": contextPath + "/ajax/moveIssue.spr",
				"type": "POST",
				"data": {
					"taskId": releaseId,
					"movedIssueId":  $row.attr("data-tt-id"),
					"referenceId": $reference.attr("data-tt-id"),
					"position": position,
					"projectId": -1
				},
				"success": function (response) {
					if (response["success"] == true) {
						if (position == "before") {
							$row.detach().insertBefore($reference);
						} else {
							$row.detach().insertAfter($reference);
						}
						var itemIds = [];
						var $itemRows = $table.find('tr.trackerItem[data-releaseId="' + releaseId + '"]');
						$itemRows.each(function() {
							itemIds.push(parseInt($(this).attr("data-tt-id"), 10));
						});
						$.ajax(contextPath + "/planner/getRanks.spr", {
							method: "POST",
							dataType: "json",
							data : {
								data : JSON.stringify(itemIds),
								releaseId : releaseId,
								releaseTrackerId: releaseTrackerId
							}
						}).done(function(result) {
							showOverlayMessage();
							$itemRows.each(function() {
								var itemId = parseInt($(this).attr("data-tt-id"), 10);
								var rank = result[itemId];
								$(this).attr("data-rank", rank);
								$(this).find(".rankTd .rank").text(rank);
							});
							addParentsIfNecessary();
						});
					} else {
						showOverlayMessage(response.hasOwnProperty("message") ? response.message : i18n.message("planner.rank.general.error"), null, true);
					}
				}
			});
		}
	};

	var sendIssueToTop = function(id, attributes) {
		sendIssueTo(id, "before", "top", parseInt(attributes.releaseId, 10));
	};

	var sendIssueToBottom = function(id, attributes) {
		sendIssueTo(id, "after", "bottom", parseInt(attributes.releaseId, 10));
	};

	var updateRowStyleToRanked = function(row) {
		var rankCell, issueHandle;

		rankCell = $(row).find("td[data-rank]");
		rankCell.removeClass().addClass("rank subtext");
		rankCell.attr("title", "");

		issueHandle = $(row).find(".issueHandle");
		issueHandle.attr("title", i18n.message("cmdb.version.stats.drag.drop.hint"));
	};

	var updateRowStyleToNonRanked = function(row) {
		var rankCell, issueHandle;

		rankCell = $(row).find("td[data-rank]");
		rankCell.removeClass().addClass("rank subtext rankWarning");
		rankCell.attr("title", i18n.message("planner.reorder.disabled.tooltip"));
		rankCell.data("rank", "!");
		rankCell.html("!");

		issueHandle = $(row).find(".issueHandle");
		issueHandle.attr("title", "");
	};

	var sendIssueToBacklogPosition = function(context, position, pasteBefore) {
		var movedIssue, movedIssueId;

		movedIssue = $(context);
		movedIssueId = movedIssue.attr("data-tt-id");
		var releaseTrackerId = codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));

		VersionStats.moveIssueInBacklog(retrieveProjectId(), movedIssueId, position, function(data) {
			forceReportSelectorSearch();
		}, function(response) {
			$(".issuelist tbody").sortable("cancel");
			message = response["message"] ? response["message"] : i18n.message("ajax.changes.error.try.reload");
			showOverlayMessage(message, 6, true);
		}, releaseTrackerId, true);
	};

	var sendIssueToBacklogTop = function(id) {
		var context = $("#" + id);
		sendIssueToBacklogPosition(context, "top", true);
	};

	var sendIssueToBacklogMiddle = function(id) {
		var context = $("#" + id);
		sendIssueToBacklogPosition(context, "middle", true);
	};

	var sendIssueToBacklogBottom = function(id) {
		var context = $("#" + id);
		sendIssueToBacklogPosition(context, "bottom", false);
	};

	var sendIssueToBacklogFromRelease = function(id, attr, position) {
		var context = $('#' + id);

		sendIssueToVersion(context, attr.backlogId, function () {
			VersionStats.moveIssueInBacklog(attr.projectId, id, position);
		});
	};

	var sendIssueToBacklogTopFromRelease = function(id, attr) {
		sendIssueToBacklogFromRelease(id, attr, "top");
	};

	var sendIssueToBacklogMiddleFromRelease = function(id, attr) {
		sendIssueToBacklogFromRelease(id, attr, "middle");
	};

	var sendIssueToBacklogBottomFromRelease = function(id, attr) {
		sendIssueToBacklogFromRelease(id, attr, "bottom");
	};

	var sendIssueToBacklogNonRanked = function(id) {
		var movedIssue;

		movedIssue = $("#" + id);

		VersionStats.resetRankInBacklog(retrieveProjectId(), id, function(data) {
			var referencedIssue, referencedIssueId;

			if (data["reference"] && $.isNumeric(data["reference"])) {
				referencedIssueId = parseInt(data["reference"]);
				if (referencedIssueId > 0) {
					if (referencedIssueId !== parseInt(id)) {
						referencedIssue = $("[data-item-id=" + referencedIssueId + "]");
						movedIssue.detach().insertAfter(referencedIssue);
					}
					updateRowStyleToNonRanked(movedIssue);
					refreshRanks(null, retrieveProjectId(), id);
				} else {
					updateRowStyleToNonRanked(movedIssue);
				}

				$.waypoints('refresh');
			}

			forceReportSelectorSearch();

		}, function(response) {});
	};

	var sendIssueToVersion = function(context, versionId, callback) {
		var $droppable = findVersionById(versionId, true);
		if (multipleSelectionEnabled) {
			setElementDataForMultipleSelection($(context));
		}
		updateTargetRelease($(context), $droppable, versionId, callback);
	};

	var sendIssueToAnOtherVersion = function (id, attr) {
		var context = $("#" + id);
		sendIssueToVersion(context, attr.versionId);
	};

	var sendIssueToBacklogAndResetRank = function (id, attr) {
		var callback = function(data) {
			sendIssueToAnOtherVersion(id, attr);
		};

		VersionStats.resetRankInBacklog(retrieveProjectId(), id, callback, callback);
	};

	var reloadCounters = function () {
		// reload the counters
		$.get(contextUrl + "/planner/versionsViewModel.spr",
			getBasicParameters(),
			function(data) {
				codebeamer.plannerConfig.versionsViewModel = data;
				refreshIssueCounters();
				reloadVersionStatsBox();
			});
	};

	var getItemIdsOfGroup = function($row) {
		var itemIdsAttr = $row.attr("data-itemIds");
		if (itemIdsAttr && itemIdsAttr.length > 0) {
			return itemIdsAttr.split(",");
		}
		var itemIds = [];
		$row.next().next().nextAll().each(function () {
			if ($(this).hasClass("groupPlaceholderRow")) {
				return false;
			}
			if ($(this).hasClass("trackerItem")) {
				itemIds.push(parseInt($(this).attr("data-tt-id"), 10));
			}
		});
		return itemIds;
	};

	var updateTeam = function($row, teamId) {
		var itemIds = [];
		if ($row.hasClass("groupRow")) {
			itemIds = getItemIdsOfGroup($row);
		} else if (multipleSelectionEnabled) {
			itemIds = $row.data("ids");
		} else {
			itemIds.push(parseInt($row.attr("data-tt-id"), 10));
		}
		for (var i = 0; i < itemIds.length; i++) {
			codebeamer.DisplaytagTrackerItemsInlineEdit.saveField(itemIds[i], 21, "9-" + teamId.toString(), null, null, function() {
				reloadLeftPane();
			});
		}
	};

	var updateAssignee = function($row, assigneeId) {
		var itemIds = [];
		if ($row.hasClass("groupRow")) {
			itemIds = getItemIdsOfGroup($row);
		} else if (multipleSelectionEnabled) {
			itemIds = $row.data("ids");
		} else {
			itemIds.push(parseInt($row.attr("data-tt-id"), 10));
		}
		for (var i = 0; i < itemIds.length; i++) {
			codebeamer.DisplaytagTrackerItemsInlineEdit.saveField(itemIds[i], 5, assigneeId, null, null, function() {
				reloadLeftPane();
			});
		}
	};

	var updateRelation = function($row, $droppable, relId) {
		if ($droppable.hasClass("release") && !$droppable.attr("data-cbql-variable")) {
			return;
		}
		if ($droppable.attr("data-cbql-variable") == "parentId" || $droppable.attr("data-cbql-variable") == "childId") {
			showOverlayMessage(i18n.message("planner.group.by.move.error"), null, true);
			return;
		}
		var issueId = $row.attr("data-tt-id");
		var issueIds = null;
		if ($row.hasClass("groupRow")) {
			issueIds = getItemIdsOfGroup($row).join(",");
		} else if (multipleSelectionEnabled) {
			issueIds = $row.data("ids").join(',');
		}
		if ($droppable.hasClass("grouped") && $droppable.attr("data-cbql-variable")) {
			var data = {
				"cbQLVariable": $droppable.attr("data-cbql-variable"),
				"referenceId": $droppable.attr("data-id")
			};
			if (issueIds != null) {
				data["issueIds"] = issueIds;
			} else {
				data["issueId"] = issueId;
			}
			$.post(contextPath + "/ajax/planner/updateReferenceField.spr", data, function (response) {
				showOverlayMessage();
				forceReportSelectorSearch();
			}).error(function (response) {
				showOverlayMessage(response.responseText, 5, true);
			});
		} else {
			var data = {
				"relationId": relId
			};
			if (issueIds != null) {
				data["issue_ids"] = issueIds;
			} else {
				data["issue_id"] = issueId;
			}
 			$.post(contextPath + "/ajax/planner/addToRelation.spr", data, function (response) {
				showOverlayMessage();
				if ($row.hasClass("groupRow")) {
					forceReportSelectorSearch();
				} else if (multipleSelectionEnabled) {
					var ids = $row.data("ids");
					for (var i = 0; i < ids.length; i++) {
						$(".trackerItems tr#" + ids[i]).find(".issueHandle").css("background-color", response["field-color"]);
					}
				} else {
					var cell = $row.find(".issueHandle");
					cell.css("background-color", response["field-color"] != null ? response["field-color"] : "#d1d1d1");
				}
			}).error(function (response) {
				showOverlayMessage(response.responseText, 5, true);
			});
		}
	};

	var updateTargetRelease = function($row, $droppable, releaseId, callback) {
		if ($droppable.hasClass("grouped")) {
			return;
		}

		var issueId;
		var $affectedRows = $();
		if ($row.hasClass("groupRow")) {
			var itemIds = [];
			var itemIdsAttr = $row.attr("data-itemIds");
			if (itemIdsAttr && itemIdsAttr.length > 0) {
				itemIds = itemIdsAttr.split(",");
			} else {
				$row.next().next().nextAll().each(function () {
					if ($(this).hasClass("groupPlaceholderRow")) {
						return false;
					}
					if ($(this).hasClass("trackerItem")) {
						itemIds.push(parseInt($(this).attr("data-tt-id"), 10));
						$affectedRows = $affectedRows.add($(this));
					}
				});
			}
			assignedRelease = $affectedRows.first().attr("data-releaseId");
			issueId = itemIds;
		} else if (multipleSelectionEnabled) {
			issueId = $row.data("ids");
		} else {
			issueId = $row.attr("id");
		}

		var assignedRelease = $row.attr("data-releaseId");
		assignedRelease = assignedRelease || "-1"; // if missing, this is a project backlog item
		if (assignedRelease == releaseId) {
			return;
		}

		// hide the row immediately to make the interaction faster
		$row.hide();
		$affectedRows.hide();

		if (releaseId === null || releaseId === '') {
			releaseId = -1;
		}

		var failureCallback = function(result) {
			codebeamer.release.failureCallback(result);
			forceReportSelectorSearch();
			$row.show();
			$row.css("display", ""); // added "display: block" might cause the DOM to break
			$affectedRows.show();
			$affectedRows.css("display", "");
		};

		moveItemToRelease(assignedRelease, releaseId, issueId,
			function(result) {
				if (result && result.hasOwnProperty("success") && result.success) {
					showOverlayMessage();
					forceReportSelectorSearch();
					reloadLeftPane();
					if (callback) {
						callback();
					}
				} else {
					failureCallback(result ? result : null);
				}
			},
			function(response) {
				failureCallback(response.responseText);
			}
		);
	};

	var updateParentRelease = function(versionIdToUpdate, newParentVersionId, successCallback, failureCallback) {
		moveItemToRelease("-1", newParentVersionId, versionIdToUpdate,
			function(result) {
				if (result && result.hasOwnProperty("success") && result.success) {
					showOverlayMessage();
					forceReportSelectorSearch();
					reloadLeftPane();
					if ($.isFunction(successCallback)) {
						successCallback.call();
					}
				} else {
					showOverlayMessage(result && result.hasOwnProperty("message") ? result.message : null, 5, true);
					if ($.isFunction(failureCallback)) {
						failureCallback.call();
					}
				}
			},
			function(response) {
				showOverlayMessage(response.responseText, 5, true);
				if ($.isFunction(failureCallback)) {
					failureCallback.call();
				}
			}
		);
	};

	var editRelease = function(releaseId) {
		openTaskEditorOverlay(releaseId);
	};

	var deleteRelease = function(releaseId) {
		releaseId = parseInt(releaseId);
		var planner = $("#planner");
		var leftPane = planner.find(".left-pane");

		var releaseVersionIds = $.map(leftPane.find(".version.is-release"), function(v) {
			return parseInt($(v).data("version-id"));
		});

		var redirectUrl = "";
		var isTopLevel = $.inArray(releaseId, releaseVersionIds) > -1;
		var lastVersionDeleted = isTopLevel && (releaseVersionIds.length == 1);
		var currentVersionDeleted = releaseId == $("#currentVersion").data("id");
		if (isTrackerScope() && lastVersionDeleted) {
			redirectUrl = "/category/" + getReleaseTrackerId();
		} else if (!isTrackerScope() && currentVersionDeleted) {
			var versionToDelete = findVersionById(releaseId);
			var versionParentId = versionToDelete.data("parent-version-id");
			if (versionParentId) {
				redirectUrl = "/item/" + versionParentId + "/planner";
			} else {
				redirectUrl = "/category/" + getReleaseTrackerId() + "/planner";
			}
		}

		var confirmationMessage = i18n.message(!isSprintScope() && isTopLevel
			? "planner.confirm.deleteRelease"
			: "planner.confirm.deleteSprint");

		showFancyConfirmDialogWithCallbacks(confirmationMessage, function() {
			$.post(contextUrl + "/ajax/planner/deleteVersion.spr", {
				"issue_id": releaseId
			}, function() {
				if (redirectUrl == "") {
					showOverlayMessage();
					reloadLeftPane();
					forceReportSelectorSearch();
				} else {
					window.location.href = contextUrl + redirectUrl;
				}
			}).fail(function() {
					showOverlayMessage(i18n.message("planner.deleteVersion.failed.message"), 3, true);
				});
		});
	};

	var editItemInOverlay = function(id, duplicate) {
		return openTaskEditorOverlay(id, duplicate);
	};

	var reloadIssueMenu = function(issueId, releaseId) {
		$("#" + issueId + " .menu-downloaded").removeClass("menu-downloaded");
	};

	var isVisibleAfterUpdate = function($row, $target) {
		var $filter = $(".filter.selected");
		var filtered = $filter.size() > 0;
		var $currentVersion = $("#currentVersion");

		if ($target.size() == 0) {
			return false;
		}

		if ($currentVersion.size() > 0) {
			// watching the planner of a release

			// dropping on the project backlog
			if ($target.is(".project-backlog")) {
				return false;
			}
			if (filtered && $target.is(".backlog")) {
				return false;
			}

			// dropping on a tab when an another is used for filtering
			if (filtered && $filter.data("version-id") != $target.data("version-id")) {
				return false;
			}
		} else {
			// watching the planner of a project
			if (filtered && $filter.data("version-id") != $target.data("version-id")) {
				return false;
			}
		}
		return true;
	};

	var addIssue = function() {
		codebeamer.planner["groupItemButton"] = null;
		var $currentVersion = $("#currentVersion");
		var $currentTracker = $("#currentTracker");
		var url = contextUrl + "/planner/createIssue.spr";
		if ($currentVersion.size() > 0) {
			url += "?task_id=" + $currentVersion.data("id");
		} else {
			url += "?tracker_id=" + $currentTracker.data("id");
		}

		url += "&isPopup=true";

		showPopupInline(url);
	};

	var addVersion = function(parentVersion) {
		if (!parentVersion) {
			var $currentVersion = $("#currentVersion");
			if ($currentVersion.length > 0) {
				parentVersion = $currentVersion.data("id");
			}
		}
		var url = contextUrl + "/planner/createVersion.spr?tracker_id=" + getReleaseTrackerId();
		if (parentVersion) {
			url += "&parent_version_id=" + parentVersion;
		}
		showPopupInline(url, { // for successful save callback logic, see cardEditorSaveHandler
			geometry: "large"
		});
	};

	/**
	 * Move item (issue or version) to the specified version. That means if item is an issue, its 'versions' field will
	 * be updated. If it is a version, its 'parent' field will be updated.
	 *
	 * @param fromVersionId the version which is currently assigned to the issue
	 * @param versionId Target version ID
	 * @param issueId Item ID (can be an issue or a version)
	 * @param successCallback Optional
	 * @param failureCallback Optional
	 */
	var moveItemToRelease = function(fromVersionId, versionId, issueId, successCallback, failureCallback) {
		if (versionId === null || versionId === '') {
			versionId = -1;
		}

		var params = {
			"version_id": versionId,
			"from_version_id": fromVersionId
		};

		if ($.isArray(issueId)) {
			params["issueIds"] = issueId.join(",");
		} else {
			params["issue_id"] = issueId;
		}

		$.post(contextUrl + "/ajax/planner/updateTargetReleaseOrParent.spr", params, successCallback || function() {})
			.fail(failureCallback || function() {});
	};

	var InplaceEditor = (function() {

		var addInplaceCellEventHandlers = function() {
			if (codebeamer.plannerConfig.hasAgileLicense) {
				$("#planner").find(".issuelist tr:not(.read-only)").find(".show-on-hover:not(.initialized),.highlight-on-hover:not(.initialized)")
					.on("dblclick", function(e) {
						$(".center-pane tr.selected").removeClass("selected");
						$(this).parents("tr").addClass("selected");
						getRightAccordion().cbMultiAccordion("enable", [0, 1, 2, 3, 4])
							.cbMultiAccordion("open", 0);
						reloadSelectedIssue();
						$(this).addClass("initialized"); // avoid duplicate event handlers
						$(e.target).parent().click();
					});
			}
		};

		var getDefaultContent = function(cell) {
			var defaultContent = cell.attr("data-default");
			if (typeof defaultContent == "undefined") {
				defaultContent = "";
			}
			return defaultContent;
		};

		var initializeItemContextMenus = function () {
			// Planner content loads with AJAX, so remove the listener attacher earlier
			$(document).off("click", ".center-pane .menuArrowDown");

			$(document).on("click", ".center-pane .menuArrowDown", function () {
				var $menuArrow = $(this);

				// Create context menu only it it is not already initialized
				if (!$menuArrow.data("menujson")) {
					var id = $menuArrow.closest('tr').data('itemId');
					var currentVersionId = $menuArrow.closest('.issuelist').prev('.id').data('versionId');

					if (currentVersionId == "") {
						currentVersionId = -1;
					}

					// Download and create context menu
					buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
						'task_id': id,
						'cssClass': 'inlineActionMenu',
						'builder': 'plannerItemActionMenuBuilder',
						'currentVersionId': currentVersionId,
						'releaseTrackerId': getReleaseTrackerId()
					});

					// Register handler to properly destroy the context menu after AJAX load.
					// This prevents errors, when the center pane is reloaded multiple times.
					$("body").one("issueListLoaded", function() {
						$.contextMenu("destroy", "#" + $menuArrow.attr("id"));
					});
				}
			})
		};

		var init = function() {
			var planner = $("#planner");

			var getIssueRow = function(cell) {
				return $(cell).closest("tr[data-item-id]")
			};

			var getIssueId = function(cell) {
				return getIssueRow(cell).data("item-id");
			};

			var save = function(issueId, fieldName, value, successCallback, errorCallback) {
				$.post(
					contextUrl + "/ajax/planner/updateItem.spr",
					{
						"issue_id": issueId,
						"field_name": fieldName,
						"value": value
					},
					function(response) {
						if (successCallback) {
							successCallback(response);
							reloadSelectedIssue();
							reloadVersionStatsBox();
							reloadCounters();
						}
					}
				).fail(errorCallback || function() {
					});
			};

			var updateAffectedValues = function(cell, response) {

				var cellClasses = cell.get(0).className;

				var updateRow = function(rows, newIds, newValue) {
					var affectedCell = $(rows).find("." + cellClasses.replace(" ", "."));
					var classes = getCellClasses(affectedCell);
					setValue(affectedCell, newValue, classes, newIds);
					flashChanged(affectedCell);
				};

				var updateBasedOnResponse = function() {
					if ("affectedItems" in response) {
						var affected = response["affectedItems"];
						for (var id in affected) {
							var values = affected[id];
							for (var fieldName in values) {
								if (fieldName.indexOf("_") !== 0) { // "_" indicates an extra IDs field
									updateRow(findRowById(id), values["_" + fieldName], values[fieldName]);
								}
							}
						}
					}
				};

				var updateMultipleAppearancesOfSameItem = function() {
					var baseRow = getIssueRow(cell);
					var baseIds = cell.data("ids");
					var baseValue = cell.text();
					var id = getIssueId(cell);
					var otherAppearances = $("tr[data-item-id=" + id + "]").not(baseRow);
					otherAppearances.each(function() {
						updateRow(this, baseIds, baseValue);
					});
				};

				updateBasedOnResponse();
				updateMultipleAppearancesOfSameItem();
			};

			var cssClassForEditingInProgress = "editing-in-progress";

			var disableMoreEvents = function(elem) {
				$(elem).addClass(cssClassForEditingInProgress);
			};

			var enableMoreEvents = function(elem) {
				$(elem).removeClass(cssClassForEditingInProgress);
			};

			var areEventsDisabled = function(elem) {
				return $(elem).hasClass(cssClassForEditingInProgress);
			};

			var handler = function(fieldName, inputMarkup, isReferenceEditor) {
				return function(event) {
					if (isReferenceEditor) {
						interruptSuggestionsRendering = false;
					}
					var cell = $(event.target);
					if (!cell.is("td")) { // if it is an input element inside a cell, find its parent
						cell = cell.closest("td");
					}
					if (!areEventsDisabled(cell)) {
						disableMoreEvents(cell);

						var defaultContent = getDefaultContent(cell);
						var currentValueIsDefault = cell.text() == $("<div>" + defaultContent + "</div>").text();
						var originalRawValue = (defaultContent != "" && currentValueIsDefault)
							? ""
							: cell.text();
						var originalValue;

						if (isReferenceEditor && fieldName == "assignedTo") {
							var row = cell.closest("tr");
							originalValue = getAssigneeIdsOfRow(row).join(",") || assigneePlaceHolder.toString();
						} else {
							originalValue = originalRawValue;
						}

						// if content is wrapped into a span, we will have to wrap again when updating cell
						var classes = getCellClasses(cell);

						var inputElem = $(inputMarkup);

						cell.html(inputElem);
						cell.find("input").click(function(e) {
							e.stopPropagation(); // avoid propagation, would cause full row (de)select otherwise
						});

						var endEditing = function() {
							var newValue;
							if (!isReferenceEditor) {
								newValue = inputElem.val();
							} else {
								interruptSuggestionsRendering = true;
								var newValueIds = cell.find("input[type=hidden]").val()
									.split(",")
									.sort()
									.filter(Boolean); // remove empty values
								newValue = newValueIds.join(",") || assigneePlaceHolder.toString();
							}
							var valueToPutIntoCell = originalRawValue;
							if (originalValue != newValue) {
								var escWasPressed = inputElem.hasClass("esc-was-pressed");
								if (!escWasPressed) {
									var valueToBeSaved = newValue;
									var issueId = getIssueId(cell);
									save(issueId, fieldName, newValue, function(response) {
										var valueSaved = (response && "newValue" in response) ? response["newValue"] : valueToBeSaved;
										setValue(cell, valueSaved, classes, valueToBeSaved);
										updateAffectedValues(cell, response);
										enableMoreEvents(cell);
										showOverlayMessage();
									}, function(response) {
										setValue(cell, originalRawValue, classes);
										enableMoreEvents(cell);
										showOverlayMessage(response.responseText, 5, true);
										addInplaceCellEventHandlers();
									});
									valueToPutIntoCell = $('<img src="' + ajaxLoaderImageUrl + '">');
								}
							}
							setValue(cell, valueToPutIntoCell, classes);
							cell.removeClass("esc-was-pressed");
							enableMoreEvents(cell);

							if (isReferenceEditor) {
								$("html").unbind("click");
							}

							addInplaceCellEventHandlers();
							setTimeout(refreshTeamIssueCounters, 1000);
						};

						if (!isReferenceEditor) {
							inputElem.attr("value", originalRawValue);

							// set focus to field end for non-Chrome browsers
							var inputNativeElem = inputElem.get(0);
							var elemLength = originalRawValue.length;
							try { // not supported in Chrome for input type "number"
								inputNativeElem.selectionStart = elemLength;
								inputNativeElem.selectionEnd = elemLength;
							} catch(ex) { }
							inputNativeElem.focus();

							inputElem.blur(endEditing);
						} else {
							$(inputElem).click(function(e) {
								e.stopPropagation();
							});
							setTimeout(function() {
								$("html").bind("click", function() {
									endEditing();
								});
							}, 300); // wait some time for IE 8
						}

						inputElem.keyup(function(e) {
							if (e.keyCode == 27) { // ESC key
								if (!isReferenceEditor) {
									inputElem.val(originalRawValue);
								}
								inputElem.addClass("esc-was-pressed");
								endEditing();
							} else if (e.keyCode == 13) { // ENTER key
								endEditing();
							}
						});

						if (!isReferenceEditor) {
							inputElem.focus();
						} else {
							inputElem.find("input[type=text]").focus();
						}
						return false;
					}
					return true;
				};
			};

			var nameMaxLength = codebeamer.plannerConfig.itemNameMaxLength;

			planner.find(".issuelist tr.summaryEditable:not(.read-only) .issueName").dblclick(function (event) {
				var callback = handler("name", "<input type='text' maxlength='" + nameMaxLength + "' style='width:100%'>");
				callback(event);
			});
			planner.find(".issuelist tr:not(.read-only) .storyPoints:not(.not-editable)").click(handler("storyPoints",
				"<input type='number' step='1'>"));

			if (codebeamer.plannerConfig.hasAgileLicense) {
				planner.find(".issuelist tr:not(.read-only) .issueAssignedTo").click(function(event) {
					var cell = $(event.target).closest(".issueAssignedTo"); // extra protection: avoid creating nested editors
					if (!areEventsDisabled(cell)) {
						disableMoreEvents(cell);
						$.post(
							contextUrl + "/ajax/planner/renderInplaceAssigneeEditor.spr", {
								"issue_id": getIssueId(this)
							},
							function(response) {
								enableMoreEvents(cell);
								handler("assignedTo", response, true)(event);
							}
						).fail(function() {
								alert("Could not initiate assignee editor mode!");
								enableMoreEvents(cell);
							});
					}
				});

				planner.find(".issuelist tr:not(.read-only) .teams:not(.not-editable)").click(function(event) {
					var cell = $(event.target).closest(".teams"); // extra protection: avoid creating nested editors
					if (!areEventsDisabled(cell)) {
						disableMoreEvents(cell);
						var $this = $(this);
						$.post(
							contextUrl + "/ajax/planner/renderInplaceTeamsEditor.spr", {
								"issue_id": getIssueId(this),
								"teamFieldId": $this.data("teamFieldId")
							},
							function(response) {
								enableMoreEvents(cell);
								handler($this.data("teamFieldName"), response, true)(event);
							}
						).fail(function() {
								alert("Could not initiate assignee editor mode!");
								enableMoreEvents(cell);
							});
					}
				});

				addInplaceCellEventHandlers();
			}

			var $trackerSelector = $('#tracker-select');
			codebeamer.multiselect.init($trackerSelector, {
				"filter": function () {
					var trackerFilters = $.map($("[name=multiselect_tracker-select]:checked"), function (elem) {
						return $(elem).val();
					});
					$.post(contextPath + "/userSetting.spr", {
						"name": "PLANNER_TRACKER_FILTER",
						"value": trackerFilters.join()
					}, function () {
						reloadIssuesList();
					});
				}
			});


			$(document).keyup(function (event) {
				var $editedField = $(".editing-in-progress");
				if ($editedField.size() > 0) {
					var inputElem = $editedField.find("input");

					if (event.keyCode == 27 || event.keyCode == 13) {
						inputElem.trigger(event);

					}
				}
			});

			initializeItemContextMenus()
		};

		var getCellClasses = function(cell) {
			var span = cell.find("span");
			return (span.length > 0) ? span.get(0).className : "";
		};

		var setValue = function(cell, newValue, classes, postedValues) {
			if ($.type(newValue) == "string") {
				if (newValue == "") {
					cell.html(getDefaultContent(cell));
					addInplaceCellEventHandlers();
				} else if (typeof classes !== "undefined" && classes != "") {
					var elem = $('<span class="' + classes + '">' + newValue + "</span>")
						.removeClass("initialized show-on-hover");
					cell.html(elem);
					addInplaceCellEventHandlers();
				} else {
					cell.html(newValue);
				}
				if (newValue != "") {
					var prependSign = (cell.hasClass("aggregated")) ? "&sum; " : "";
					cell.prepend(prependSign);
				}
			} else {
				cell.html(newValue);
			}
			if (cell.hasClass("issueAssignedTo") && (typeof postedValues != "undefined")) {
				// needs some special treatment:
				//   - must update the assignee IDs stored in the DOM
				//   - must react correctly to actual filtering
				cell.attr("data-ids", postedValues);
				var row = cell.closest("tr");
				var selectedAssigneeId = VersionStatsBox.getSelectedAssigneeId();
				if (selectedAssigneeId) {
					var rowAssigneeIds = getAssigneeIdsOfRow(row);
					if ($.inArray(selectedAssigneeId, rowAssigneeIds) == -1) {
						removeRow(row);
					}
				}
			}
		};

		return {
			"init": init,
			"getCellClasses": getCellClasses,
			"setCellValue": setValue
		}
	})();

	var getLeftAccordion = function() {
		return $("#planner").find(".left-pane .accordion").first();
	};

	var getRightAccordion = function() {
		return $("#planner").find(".right-pane .overflow .accordion");
	};

	$(function() {
		refreshIssueCounters();
		addLeftPaneEventHandlers();
		addRightPaneEventHandlers();
		emptyIssueInfoBoxes();
		reloadVersionStatsBox();

		addGlobalEventHandlers();

		adjustLayout();
		setTimeout(function() {
			$("#opener-east").toggle($("#east").is(":visible") == false); // fix for unnecessary icon displayed by jQuery plugin
			adjustLayout();
		}, 100); // make sure other components will not break the layout while initializing

		hideEmptyReleases();

		initSelectionAwareLinks($(".actionMenuBar .append-selection-id"));
		var hashParams = UrlUtils.getHashParameters();
		if (!$.isEmptyObject(hashParams)) {
			var id = hashParams["select"];
			setTimeout(function() {
				scrollToItemAndSelect(id);
				window.location.hash = "";
			}, 500);
		}

		initAddSprintButton();

		initShowParentItems();

		if ($("#showParentItems").is(":checked")) {
			addParents();
			showParentItemsChecked = true;
		} else {
			showParentItemsChecked = false;
		}

		initMultipleSelection();

	});

	var initAddSprintButton = function() {
		$(".add-sprint-icon").click(function () {
			addVersion();
			return false;
		});
	};

	var retrieveProjectId = function() {
		return $("#plannerProjectId").val();
	};

	var setupSortableForIssueList = function($container) {
		var releaseIdFunction = function(movedIssueId) {
			var $idContainer = $("tr#" + movedIssueId).closest(".issuelist").prev(".id");
			return $idContainer.data("version-id");
		};

		if (isCurrentIssueListSortable($container) || (isCurrentIssueListProjectBacklog())) {
			isProjectBacklog = isCurrentIssueListProjectBacklog();
			VersionStats.makeTableSortable($container, function(movedIssueId) {
				var $idContainer = $("tr#" + movedIssueId).closest(".issuelist").prev(".id");
				return $idContainer.data("version-id");
			}, {
				"tolerance": "pointer",
				"out": function(event, ui) {
					$(ui.placeholder).hide();
					codebeamer.is_dragging = false;
				},
				"over": function(event, ui) {
					if (!isProjectBacklog) {
						$(ui.placeholder).show();
					}
					codebeamer.is_dragging = true;
				},
				"start": function() {
					codebeamer.is_dragging = true;
				},
				"stop": function(event, ui) {
					var $panel = $(event.target);
					var offset = $panel.offset();
					var x = event.clientX;
					var y = event.clientY;
					var inside = false;

					function errorCallback(response) {
						$(".issuelist tbody").sortable("cancel");
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.error.try.reload");
						showOverlayMessage(message, 6, true);
					};

					if (offset.left <= x && x <= offset.left + $panel.width() && offset.top <= y && y <= offset.top + $panel.height()) {
						inside = true;
					}

					var $underCursor = $(document.elementFromPoint(x, y));
					var assigneeUpdated = $underCursor.is(".assigneeTable") || $underCursor.parents(".assigneeTable").size() > 0;
					var teamUpdated = $underCursor.is(".team-list") || $underCursor.parents(".team-list").size() > 0;
					if (((!inside && !codebeamer.dropped) || assigneeUpdated || teamUpdated)) {
						$(".issuelist tbody").sortable("cancel");
					}
					codebeamer.is_dragging = false;
					codebeamer.dropped = false;

					// Try to update the order. If it fails, then put the moved item back to its original position.
					if (isProjectBacklog) {
						var projectId = retrieveProjectId();
						VersionStats.updateHandler(null, projectId, event, ui, function () {
							var $row = $(ui.item);
							refreshRanks(releaseIdFunction, retrieveProjectId(), $row.attr("id"), true);
						}, errorCallback);
					} else {
						VersionStats.updateHandler(releaseIdFunction, null, event, ui, function () {
							var $row = $(ui.item);
							refreshRanks(releaseIdFunction, retrieveProjectId(), $row.attr("id"), true);
						}, errorCallback);
					}
				},
				"scroll": true,
				"refreshPositions": true,
				"handle": "td.issueHandle:not(.disabled)",
				"cursor": "move"
			}, function (ui) {
				var $row = $(ui.item);
				refreshRanks(releaseIdFunction, retrieveProjectId(), $row.attr("id"), true);
				addParentsIfNecessary();
			});
		} else {
			var hint = i18n.message("cmdb.version.stats.drag.drop.hint");
			$container.find("tr:not(.dnd-initialized)").each(function() {
				var $tr = $(this);
				var tableHeader = $tr.is(".tableHeader");
				var isHandleAlreadyAdded = $tr.find("td.issueHandle").length > 0;
				if (!tableHeader && !isHandleAlreadyAdded) {
					var handle = $('<td class="issueHandle disabled"></td>');
					$tr.prepend(handle);
					var categoryColor = $tr.data("category-color");
					if (categoryColor) {
						handle.css("background-color", categoryColor);
					}
				}
			});
		}
	};

	var VersionStatsBox = (function() {

		var getSelectedAssigneeId = function() {
			var box = $("#versionStatsBox");
			var value = box.find("tr.selected").attr("data-id");
			return value || null;
		};

		var init = function() {
				var box = $("#versionStatsBox");
				box.css("cursor", "pointer");
				var rows = box.find("tr.assigneeTable");
				rows.each(function() {
					var tr = $(this);
					tr.click(function() {
						var wasSelected = tr.is(".selected");
						rows.removeClass("selected");
						tr.toggleClass("selected", !wasSelected);

						var dataId = tr.attr("data-id");
						var memberId = null;
						var roleId = null;
						var values = [];
						if (dataId == "1--1") {
							values.push({
								left: {
									value : "assignedTo"
								},
								operator: "is null"
							});
						} else {
							var idParts = dataId.split("-");
							var type = idParts[0];
							var id = idParts[1];
							var fieldName = "assignedTo";
							if (type == "13") {
								fieldName = "assignedToRole";
								roleId = id;
							} else {
								memberId = id;
							}
							values.push({
								left: {
									value: fieldName
								},
								operator: "IN",
								right: {
									value: [{
										value: id
									}]
								}
							});
						}

						var $assignedToSelector = $(".reportSelectorTag").find("button.assignedToSelector");
						$assignedToSelector.next(".removeIcon").click();
						if (!wasSelected) {
							$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
								dataType: "json",
								data: { field_id: 5 },
								async: false
							}).done(function(fieldObject) {
								var reportSelectorId = $(".reportSelectorTag").attr("id");
								var ids = [];
								if (memberId != null) {
									ids.push(memberId);
								} else if (roleId != null) {
									ids.push(roleId);
								}
								var cbQLAttrName = ((memberId == null && roleId == null) || memberId != null) ? "assignedTo" : "assignedToRole";
								codebeamer.ReportSupport.getReportSelectorResult(reportSelectorId, getCbQLOfFilter(reportSelectorId, cbQLAttrName, ids));
								codebeamer.ReportSupport.renderField(reportSelectorId, fieldObject, false, values);
							});
						} else {
							forceReportSelectorSearch();
						}

					});
				});

				$(".assigneeTable").droppable({
					"drop": function (event, ui) {
						var $droppable = $(this);
						var $row = $(ui.draggable);
						updateAssignee($row, $droppable.data("id"));
					},
					"activate": throttleWrapper(function(event, ui) {
						$(".assigneeTable").each(function () {
							$(this).addClass("acceptsDrop availableAssignee");
						});
					}),
					"deactivate": function() {
						$(".availableAssignee").removeClass("availableAssignee");
					},
					"accept": function(draggable) {
						if (draggable.hasClass("groupRow") && draggable.attr("data-isRelease") == "true") {
							return false;
						}
						if (draggable.is("tr.trackerItem") || draggable.is("tr.groupRow")) {
							return true;
						}
						return false;
					},
					"tolerance": "pointer",
					"hoverClass": "highlighted"
				});
			};

			var initTeamMenus = function () {
				var contextMenu = new ContextMenuManager({
					selector: ".team .simpleDropdownMenu .menuArrowDown",
					items:  {
						"edit" : {
							name: i18n.message("button.edit"),
							callback: function(key, options) {
								var teamId = $(options.$trigger).parents("li.team").data("teamid");
								openTaskEditorOverlay(teamId, false);
							}
						}
					},
					trigger: "left",
					context : $("body")
				});
				contextMenu.render();
			};

			initTeamMenus();
		// };
		return {
			"init": init,
			"getSelectedAssigneeId": getSelectedAssigneeId
		};
	})();

	var isInterruptSuggestionsRendering = function() {
		return interruptSuggestionsRendering;
	};

	// Report selector functions

	var hasGroupBy = function() {
		return $(".reportSelectorTag").find(".groupArea").find(".droppableField").length > 0;
	};

	var hasOrderBy = function() {
		return $(".reportSelectorTag").find(".orderByArea").find(".droppableField").length > 0;
	};

	var setElementDataForMultipleSelection = function($element) {
		var $rows = [];
		var checkedIds = [];
		var hasUnOrdered = false;
		$(".multipleSelectionCheckbox:checked").each(function() {
			if ($(this).attr("data-unordered") == "true") {
				hasUnOrdered = true;
			}
			checkedIds.push(parseInt($(this).attr("data-id"), 10));
			$rows.add($(this).closest("tr"));
		});
		if (checkedIds.length == 0) {
			var $checkbox = $element.find(".multipleSelectionCheckbox");
			if (!$checkbox.closest("tr").hasClass("itemType_Release")) {
				$checkbox.prop("checked", true);
			}
			checkedIds.push(parseInt($checkbox.attr("data-id"), 10));
			$rows.add($element);
		}
		$element.data("ids", checkedIds);
		$element.data("rows", $rows);
		$element.data("hasUnOrdered", hasUnOrdered);
	};

	var addRankHandlers = function($container, skipRanks) {

		var collectReleaseAndItemIds = function($table) {
			var result = {};
			var lastReleaseId = -1;
			var lastItemIdList = [];
			$table.find("tr").each(function() {
				if ($(this).find("td").hasClass("releaseGrouppingLevel")) {
					if (lastReleaseId != null) {
						result[lastReleaseId] = lastItemIdList;
					}
					if ($(this).find(".releaseGroupName").length > 0) {
						lastReleaseId = parseInt($(this).find(".releaseGroupName").attr("data-releaseId"), 10);
					} else {
						lastReleaseId = -1;
					}
					lastItemIdList = [];
				} else if ($(this).hasClass("trackerItem")) {
					lastItemIdList.push(parseInt($(this).attr("data-tt-id"), 10));
				}
			});
			result[lastReleaseId] = lastItemIdList;
			return result;
		};

		var releaseTrackerId = codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));

		var $lastTr = $("#planner").find("table.trackerItems.inited").last().find("tr").last();
		var lastTrRank = null;
		try {
			lastTrRank = parseInt($lastTr.find(".rankTd .rank").text(), 10);
		} catch (e) {
			// skip
		}

		$("#planner").find("table.trackerItems").each(function() {

			if (!$(this).hasClass("inited")) {

				var $table = $(this);
				if ($table.find("tbody tr").first().hasClass("empty")) {
					$table.next(".pagebanner").remove();
				}

				var $headerRow = $table.find("> thead > tr");
				$headerRow.css("display", "none");
				var headerRowHeight = parseInt($headerRow.height(), 10);
				$table.find(".releaseGrouppingLevel").css("height", headerRowHeight + "px");

				var $droppableField = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
				if ($droppableField.length === 0) {
					$table.find(".newGroupItemContainer").hide();
				} else if ($droppableField.length === 1) {
					var fieldObject = $droppableField.data("fieldObject");
					if (fieldObject.id == 72 || fieldObject.id == 76 || fieldObject.id == 79 ||
						fieldObject.id === -1 || fieldObject.id === 1 || fieldObject.typeName !== "references") {
						$table.find(".newGroupItemContainer").hide();
					}
				}

				var hasGroupingRow = false;
				var index = 0;
				$table.find("> tbody > tr").each(function() {
					var isGroupingRow = $(this).find("td").first().hasClass("releaseGrouppingLevel");
					var nextRowIsGroupingRow = $(this).next("tr").find("td").first().hasClass("releaseGrouppingLevel");
					if (isGroupingRow && !nextRowIsGroupingRow) {
						hasGroupingRow = true;
						var $groupingTd = $(this).find("td").first();
						$(this).after($headerRow.clone().css("display", "table-row").addClass("headerRow"));
						$table.find("> thead").hide();
						$groupingTd.css("height", "auto");
					}
					index++;
				});

				if(!hasGroupingRow) {
					$headerRow.css("display", "table-row");
				}

				codebeamer.ReportSupport.initDrag($(".reportSelectorTag").attr("id"), $("#plannerCenterPane"));

				var releaseAndItemIds = collectReleaseAndItemIds($(this));
				showAjaxLoading();

				$.ajax(contextPath + "/planner/getPlannerAdditionalInfo.spr", {
					method : "POST",
					dataType: "json",
					data : { data : JSON.stringify(releaseAndItemIds), releaseTrackerId : releaseTrackerId }
				}).done(function(result) {

					if (hasGroupBy()) {
						initNewGroupItem($table);
						initNewItemWithinGroup($table);
					}

					var lastReleaseId = -1;
					var groupedItemRank = 1;
					$table.find("> tbody > tr").each(function() {
						var isGroupingRow = $(this).find("td").first().hasClass("releaseGrouppingLevel");
						if (isGroupingRow) {
							var $groupingTd = $(this).find("td").first();
							if ($(this).find(".releaseGroupName").length > 0) {
								lastReleaseId = parseInt($groupingTd.find(".releaseGroupName").attr("data-releaseId"), 10);
							} else {
								lastReleaseId = -1;
							}
						} else if ($(this).find(">th").length == 0 && $(this).attr("data-tt-id")) {
							var itemId = parseInt($(this).attr("data-tt-id"), 10);
							var rank = "";
							if (!skipRanks && result[lastReleaseId] && result[lastReleaseId][itemId]["rank"] != null) {
								rank = (hasGroupBy() && !hasOrderBy()) ? groupedItemRank : result[lastReleaseId][itemId]["rank"];
								if (hasGroupBy() && !hasOrderBy()) {
									groupedItemRank++;
								}
							}
							if (!skipRanks && rank !== "" && rank > 0 && lastTrRank) {
								rank += lastTrRank;
							}
							if (!skipRanks && rank) {
								$(this).attr("data-rank", rank);
							}
							$(this).attr("data-releaseId", lastReleaseId);
							$(this).attr("data-storyPoints", result[lastReleaseId] ? result[lastReleaseId][itemId]["storyPoints"] : "");

							// Add rating data
							var $ratingTd = $(this).find(".ratingTd");
							var ratingClass = "";
							var rate = result[lastReleaseId] ? result[lastReleaseId][itemId]["rating"] : null;
							if (typeof rate !== "undefined" && rate !== null) {
								ratingClass = " rated-" + rate;
							}
							var $ratingCont = $("<div>", { "class" : "rating-container" + ratingClass, "data-issueid" : itemId, "id" : "rating_" + itemId, "title" : i18n.message("tracker.show.rating.title")});
							$ratingTd.append($ratingCont);

							// Add rank data
							var $rankTd = $(this).find(".rankTd");
							// Do not display ranks if implicit order by is selected
							if (hasOrderBy()) {
								rank = " ";
							}
							$rankTd.find(".rank").text(rank);
							if (codebeamer.plannerConfig.hasReleaseIssueEditPermission && !skipRanks && result[lastReleaseId] && lastReleaseId == -1 && rank.length == 0) {
								var $sendToOrdered = $("<span>", { "class" : "sendToOrderedBacklog", "title": i18n.message("planner.sendToBacklogBottom")}).data("itemId", itemId);
								$sendToOrdered.click(function() {
									sendIssueToBacklogBottom($(this).data("itemId"));
								});
								$rankTd.append($sendToOrdered);
							}

							// Add drag&drop handle
							var $handleTd = $(this).find(".issueHandle");
							var color = result[lastReleaseId] ? result[lastReleaseId][itemId]["color"] : null;
							if (color != null) {
								$handleTd.css("background-color", color);
							}

							var $contextMenuSpan = $("<span>", { "class" : "contextMenuContainer"});
							var $editInOverlayIcon = $("<span>", { "class" : "editInOverlayIcon"});
							var $menuIcon = $("<span>", { "class" : "simpleDropdownMenu itemMenuArrowDown", id: "context-menu-" + itemId + "-" + lastReleaseId});
							$contextMenuSpan.append($editInOverlayIcon);
							$contextMenuSpan.append($menuIcon);
							$(this).find("td.textSummaryData").append($contextMenuSpan);
						}
					});

					if (multipleSelectionEnabled) {
						removeMultipleSelectionHandlers();
						addMultipleSelectionHandlers();
					}

					var commonHelper = function(e, $element) {

						var height = $element.height();
						var tdWidths = [];
						$element.find("td").each(function() {
							tdWidths.push($(this).width());
						});

						var $rows = [];
						if (multipleSelectionEnabled) {
							setElementDataForMultipleSelection($element);
							$rows = $element.data("rows");
							if ($element.data("hasUnOrdered")) {
								try {
									$(this).sortable("disable");
									$(this).sortable("option", { items: "tr.trackerItemsNoSort" });
									$(this).sortable("refresh");
								} catch (e) {
									// sortable is not initialized in all cases (e.g. if you select only unordered items from Backlog
								}
							}
						} else {
							var $helperRow = $element.clone();
							$rows.add($helperRow);
						}

						var $helper = $("<table>", { "class" : "trackerItems displaytag sortableHelperTable"});
						var length = $rows.length;
						if ($rows.length == 1) {
						 	var $row = $rows[0];
							$row.css("height", height + "px");
							var index = 0;
							$row.find("td").each(function() {
								$(this).css("width", tdWidths[index] + "px");
								index++;
							});
							$row.find(".parentHandler").remove();
							$helper.append($row.clone());
						} else {
							var width = $rows[0].closest("table").width();
							var $helperRow = $rows[0].clone();
							$helperRow.find("td:not(.issueHandle)").remove();
							$helperRow.append($("<td>", { "class": "textSummaryData" }).text(length + " " + i18n.message("planner.items.selected")));
							$helperRow.find(".textSummaryData").css("width", (width - 30) + "px");
							$helper.append($helperRow);
						}

						$helper.find(".contextMenuContainer").remove();

						return $helper;

					};

					var doIncrementScroll = function($pageLink) {
						var page = parseInt($pageLink.find("strong").text(), 10);
						$pageLink.find(".incrementalScrollLoading").show();
						var nextPage = page + 1;
						var containerId = $(".reportSelectorTag").attr("id");
						var cbQL = codebeamer.ReportSupport.getCbQl(containerId);
						isIncrementalScroll = true;
						codebeamer.ReportSupport.getReportSelectorResult(containerId, cbQL, nextPage, null, false, false, null, function(nextPageResult) {
							$pageLink.remove();
							var $nextPageDiv = $("<div>");
							$nextPageDiv.html(nextPageResult);
							var $nextPageTable = $nextPageDiv.find("table.trackerItems");
							$nextPageTable.find("tr.empty").remove();
							if (hasGroupBy()) {
								var groupRowSelector = ".groupRow.firstLevel:not(.releaseGroupRow)";
								var $lastGroupRow = $("#planner").find(".trackerItems").find(".groupRow.firstLevel").last();
								var $firstGroupRow = $nextPageTable.find(groupRowSelector).first().clone();
								var lastReleaseId = parseInt($("#planner").find(".trackerItems").find(".releaseGroupRow").last().find(".releaseGroupName").attr("data-releaseid"), 10);
								var firstReleaseId = parseInt($nextPageTable.find(".releaseGroupRow").first().find(".releaseGroupName").attr("data-releaseid"), 10);
								var sameRelease = lastReleaseId ? lastReleaseId == firstReleaseId : true;
								if (sameRelease && $lastGroupRow.find(".groupping-level").text() == $firstGroupRow.find(".groupping-level").text()) {
									$nextPageTable.find(groupRowSelector).first().prev(".groupPlaceholderRow").remove();
									$nextPageTable.find(groupRowSelector).first().next(".groupPlaceholderRow").remove();
									$nextPageTable.find(groupRowSelector).first().next(".groupPlaceholderRow").remove();
									$nextPageTable.find(groupRowSelector).first().next(".groupPlaceholderRow").remove();
									$nextPageTable.find(groupRowSelector).first().next(".groupRow").remove();
									$nextPageTable.find(groupRowSelector).first().next(".groupPlaceholderRow").remove();
									$nextPageTable.find(groupRowSelector).first().remove();
								}
							}
							$("#planner").find(".trackerItems").last().after($nextPageTable).after($nextPageDiv.find(".pagelinks"));
						}, true);
					};

					var sortScroller = function(e, ui) {
						var $center = $("#plannerCenterPane");
						var leftPosition = $center.offset().left;
						var topPosition = $center.offset().top;
						var bottomPosition = topPosition + $center.height();
						if (ui.position.left > leftPosition) {
							var scrollTop = $center.scrollTop();
							if (ui.position.top < topPosition) {
								$center.scrollTop(scrollTop - SCROLL_TOLERANCE);
							}
							if (ui.position.top > (bottomPosition - 30)) {
								$center.scrollTop(scrollTop + SCROLL_TOLERANCE);
							}
						} else {
							var $right = $("#west .overflow");
							var scrollTop = $right.scrollTop();
							if (ui.position.top < topPosition + 50) {
								$right.scrollTop(scrollTop - SCROLL_TOLERANCE);
							}
							if (ui.position.top > (bottomPosition - 30)) {
								$right.scrollTop(scrollTop + SCROLL_TOLERANCE);
							}
						}
					};

					if (!hasOrderBy()) {
						$table.sortable({
							items: "tr.trackerItem[data-rank]",
							handle: "td.issueHandle",
							appendTo: $("#planner"),
							placeholder: "sortablePlaceholder",
							scroll: false,
							helper: commonHelper,
							sort: sortScroller,
							start: function(e, ui) {
								isSortInProgress = true;
								if (hasGroupBy()) {
									$(this).data("valueToUpdateId", "9-" + ui.item.prevAll(".groupRow").first().attr("data-id"));
								}
							},
							stop: function() {
								$(this).sortable("enable");
								$(this).sortable("option", { items: "tr.trackerItem[data-rank]" });
								$(this).sortable("refresh");
								isSortInProgress = false;
							},
							update: function(e, ui) {
								var $that = $(this);
								var $row = ui.item;
								var $reference = null;
								var position = "after";
								if ($row.prev(".trackerItem").size() > 0) {
									$reference = $row.prev();
								} else {
									$reference = $row.next(".trackerItem");
									position = "before";
								}
								var releaseId = $reference.attr("data-releaseId");
								var projectId = null;
								if (!releaseId || releaseId == "-1") {
									projectId = retrieveProjectId();
								}
								var data = {
									"taskId": releaseId,
									"referenceId": $reference.attr("data-tt-id"),
									"position": position,
									"projectId": projectId,
									"releaseTrackerId" : releaseTrackerId
								};
								if (multipleSelectionEnabled) {
									data["movedIssueIds"] = $row.data("ids").join(",");
								} else {
									data["movedIssueId"] = $row.attr("data-tt-id");
								}
								if (hasGroupBy()) {
									var valueToUpdateId = $that.data("valueToUpdateId");
								}
								$.ajax({
									"url": contextPath + "/ajax/moveIssue.spr",
									"type": "POST",
									"data": data,
									"success": function (response) {
										var referenceShouldBeUpdated = false;
										if (hasGroupBy()) {
											var $groupRow = $row.prevAll(".groupRow").first();
											var valueId = $groupRow.attr("data-id");
											var value = valueId ? ("9-" + valueId) : "";
											if (valueToUpdateId != value) {
												referenceShouldBeUpdated = true;
											}
										}
										if (referenceShouldBeUpdated) {
											var cbQLVariable = $groupRow.attr("data-cbqlvariable");
											if (!cbQLVariable) {
												cbQLVariable = $groupRow.prevAll(".groupRow").first().attr("data-cbqlvariable");
											}
											$.ajax(contextPath + "/ajax/planner/getFieldIdFromCbQLVariable.spr", {
												method: "POST",
												dataType: "json",
												data: {
													cbQLVariable: cbQLVariable
												}
											}).done(function (fieldId) {
												if (valueId !== "null" && fieldId != null) {
													var ids = [];
													if (multipleSelectionEnabled) {
														ids = $row.data("ids");
													} else {
														ids.push(parseInt($row.attr("data-tt-id"), 10));
													}
													for (var i = 0; i < ids.length; i++) {
														codebeamer.DisplaytagTrackerItemsInlineEdit.saveReferenceField(ids[i], fieldId, value, valueToUpdateId, function () {
															forceReportSelectorSearch();
														}, function () {
															$table.sortable("cancel");
														});
													}
												} else {
													showOverlayMessage(i18n.message("planner.group.by.move.error"), null, true);
													$table.sortable("cancel");
												}
											}).fail(function () {
												$table.sortable("cancel");
											});
										}
										if (!hasGroupBy() && multipleSelectionEnabled) {
											forceReportSelectorSearch();
											return;
										}
										if (response["success"] == true) {
											if (!hasGroupBy()) {
												var itemIds = [];
												var $itemRows = $table.find('tr.trackerItem[data-releaseId="' + releaseId + '"]');
												$itemRows.each(function() {
													itemIds.push(parseInt($(this).attr("data-tt-id"), 10));
												});
												$.ajax(contextPath + "/planner/getRanks.spr", {
													method: "POST",
													dataType: "json",
													data: {
														data: JSON.stringify(itemIds),
														releaseId: releaseId,
														releaseTrackerId: codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"))
													}
												}).done(function (result) {
													showOverlayMessage();
													$itemRows.each(function () {
														var itemId = parseInt($(this).attr("data-tt-id"), 10);
														var rank = result[itemId];
														$(this).attr("data-rank", rank);
														$(this).find(".rankTd .rank").text(rank);
													});
													addParentsIfNecessary();
												});
											} else if (hasGroupBy() && !referenceShouldBeUpdated) {
												var index = 1;
												$table.find("tr.trackerItem[data-rank]").each(function() {
													$(this).attr("data-rank", index);
													$(this).find(".rankTd .rank").text(index);
													index++;
												})
											}
										} else {
											showOverlayMessage(response.hasOwnProperty("message") ? response.message : i18n.message("planner.rank.general.error"), null, true);
											$table.sortable("cancel");
										}
										// Do the incremental scroll if scroll position is bottom after D&D
										var $overflow = $(".overflow");
										if ($overflow.scrollTop() + $overflow.height() > $overflow[0].scrollHeight - 100) {
											var $pageLink = $("#planner").find(".pagelinks");
											if ($pageLink.length > 0) {
												doIncrementScroll($pageLink);
											}
										}
									}
								});
								isSortInProgress = false;
							}
						});
						$table.find("tr.trackerItem:not([data-rank])").draggable({
							handle: "td.issueHandle",
							appendTo: $("#planner"),
							helper: function(e) {
								return commonHelper(e, $(e.currentTarget));
							}
						});
						if (hasGroupBy()) {
							$table.find("tbody").sortable({
								items: "tr.groupRow[data-id]",
								handle: "td.issueHandle",
								appendTo: $("#planner"),
								placeholder: "sortablePlaceholder",
								helper: commonHelper,
								sort: sortScroller,
								scroll: false,
								start: function() {
									isSortInProgress = true;
								},
								stop: function() {
									isSortInProgress = false;
								},
								update: function(e, ui) {
									var $row = $(ui.item);
									var cbQLVariable = $row.attr("data-cbqlvariable");
									refreshGroupOrder($table, $row, cbQLVariable);
									isSortInProgress = false;
								}
							});
						}
					} else {
						$table.find("tr.trackerItem").draggable({
							handle: "td.issueHandle",
							appendTo: $("#planner"),
							helper: function(e) {
								return commonHelper(e, $(e.currentTarget));
							}
						});
						if (hasGroupBy()) {
							$table.find("tr.groupRow").draggable({
								handle: "td.issueHandle",
								appendTo: $("#planner"),
								helper: function(e) {
									return commonHelper(e, $(e.currentTarget));
								}
							});
						}
					}

					initInlineRating($("#planner"));
					initOpeners($table);

					addParentsIfNecessary();

					var $pageLink = $("#planner").find(".pagelinks");
					$("#planner").find(".pagebanner").remove();
					if ($pageLink.length > 0) {
						$pageLink.prepend($("<div>", { "class" : "incrementalScrollLoading"}));
						$pageLink.children().hide();

						var incrementScrollHandler = function(direction) {
							if (direction == "down" && !isSortInProgress) {
								doIncrementScroll($pageLink);
							}
						};

						$pageLink.waypoint(incrementScrollHandler, {
							offset: function() {
								return $("#planner").find(".overflow").height() + 100;
							},
							context: '.overflow'
						});
					}

					$table.addClass("inited");

					// Merge tables
					var $tables = $("#planner").find(".trackerItems");
					if ($tables.length > 1) {
						var $firstTable = $tables.first();
						var $lastTable = $tables.last();
						if ($firstTable != $lastTable) {
							if ($lastTable.find("thead").length > 0) {
								$lastTable.find("thead").remove();
							}
							$firstTable.append($lastTable.find("tr"));
							$lastTable.remove();
						}
						var lastGroupLevel = null;
						$firstTable.find("tr").each(function() {
							if ($(this).find("td").first().hasClass("releaseGrouppingLevel")) {
								var $releaseGroupName = $(this).find("td").first().find(".releaseGroupName");
								var groupLevel = -1;
								if ($releaseGroupName.length > 0) {
									groupLevel = parseInt($releaseGroupName.attr("data-releaseId"), 10);
								}
								if (lastGroupLevel != null && lastGroupLevel == groupLevel) {
									$(this).next("tr").remove();
									$(this).remove();
								}
								lastGroupLevel = groupLevel;
							}
						});
					}

					codebeamer.ReportSupport.initHeaderContextMenu($container.attr("id"));
					$("body").trigger("issueListLoaded");
					initializeItemContextMenus();

					setupColoredRelationsLoader(false, function () {
						var $container = $(".relations-accordion.accordion-content .color-filters");
						$container.sortable({
							items: "li.grouped",
							handle: ".issueHandle",
							placeholder: "sortablePlaceholder",
							// helper: commonHelper,
							update: function (e, ui) {
								var busy = ajaxBusyIndicator.showBusysign($("#plannerCenterPane"));
								var containerId = $(".reportSelectorTag").attr("id");
								var $row = $(ui.item);
								var cbQLVariable = $row.attr("data-cbql-variable");

								var $reference = null;
								var position = "after";
								if ($row.prevAll("li.grouped.colored").size() > 0) {
									$reference = $row.prevAll("li.grouped.colored").first();
								} else {
									$reference = $row.nextAll("li.grouped.colored").first();
									position = "before";
								}

								var data = {
									releaseId: codebeamer.ReportSupport.getReleaseId(containerId),
									releaseTrackerId: codebeamer.ReportSupport.getReleaseTrackerId(containerId),
									cbQLVariable: cbQLVariable,
									referenceId: $reference.attr("data-id"),
									position: position,
									taskId: $row.attr("data-id")
								};
								var order = [];
								$container.find("li.grouped[data-cbql-variable='" + cbQLVariable + "']").each(function () {
									order.push($(this).attr("data-id"));
								});
								data["order"] = order.join(",");

								$.post(
									contextPath + "/ajax/planner/refreshGroupOrder.spr", data,
									function (response) {
										if (response) {
											ajaxBusyIndicator.close(busy);
											forceReportSelectorSearch();
											showOverlayMessage();
										}
									}
								).fail(function (jqXHR) {
									ajaxBusyIndicator.close(busy);
									showOverlayMessage(jqXHR && jqXHR.hasOwnProperty("responseText") ? jqXHR.responseText : i18n.message("planner.move.all.items.from.sprint.error"), null, true);
									$table.find("tbody").sortable("cancel");
								});
							}
						});
					});

                    firstLoad = false;

				}).fail(function() {
					hideAjaxLoading();
				});
			} else {
				hideAjaxLoading();
			}

		});

		if ($("#planner").find("table.trackerItems").length == 0) {
			hideAjaxLoading();
		}

		initializeReleaseContextMenus();
	};

	var refreshGroupOrder = function($table, $row, cbQLVariable, skipForceSearch) {
		var busy = ajaxBusyIndicator.showBusysign($("#plannerCenterPane"));
		var containerId = $(".reportSelectorTag").attr("id");
		var releaseId = codebeamer.ReportSupport.getReleaseId(containerId);
		var order = [];
		$table.find("tr.groupRow[data-cbqlvariable='" + cbQLVariable + "']").each(function() {
			order.push($(this).attr("data-id"));
		});
		var $reference = null;
		var position = "after";
		if ($row.prevAll(".groupRow.rankable.firstLevel").size() > 0) {
			$reference = $row.prevAll(".groupRow.rankable.firstLevel").first();
		} else {
			$reference = $row.nextAll(".groupRow.rankable.firstLevel").first();
			position = "before";
		}

		var data = {
			releaseId: releaseId,
			releaseTrackerId: codebeamer.ReportSupport.getReleaseTrackerId(containerId),
			cbQLVariable: cbQLVariable,
			order: order.join(","),
			referenceId: $reference.attr("data-id"),
			position: position,
			taskId: $row.attr("data-id")
		};

		$.post(
			contextPath + "/ajax/planner/refreshGroupOrder.spr", data,
			function(response) {
				if (response) {
					ajaxBusyIndicator.close(busy);
					if (!skipForceSearch) {
						forceReportSelectorSearch();
					}
					showOverlayMessage();
				}
			}
		).fail(function (jqXHR) {
			ajaxBusyIndicator.close(busy);
			showOverlayMessage(jqXHR && jqXHR.hasOwnProperty("responseText") ? jqXHR.responseText : i18n.message("planner.move.all.items.from.sprint.error"), null, true);
			$table.find("tbody").sortable("cancel");
		});
	};

	var initNewGroupItem = function($table) {
		var $firstGroup = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
		var firstGroupFieldObject = $firstGroup.data("fieldObject");
		$table.find(".newGroupItem").each(function() {
			$(this).click(function() {
				var $newGroupItemLink = $(this);
				var $releaseName = $newGroupItemLink.closest(".releaseGrouppingLevel").find(".releaseGroupName");
				var releaseId = -1;
				if ($releaseName.length > 0) {
					releaseId = $releaseName.attr("data-releaseId");
				}
				codebeamer.planner["groupItemButton"] = $(this);
				var url = contextUrl + "/planner/createIssue.spr?cbQLVariable=" + encodeURIComponent(firstGroupFieldObject.cbQLGroupByAttributeName);
				url += "&tracker_id=" + codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));
				url += "&task_id=" + releaseId;
				url += "&isPopup=true";
				showPopupInline(url);
			});
		});
	};

	var initNewItemWithinGroup = function($table) {
		$table.off("click.addItemToGroup");
		$table.on("click.addItemToGroup", ".add-new-item-to-group", function() {
			var $groupRow, $groupRows, $releaseRow, url, releaseTrackerId;

			codebeamer.planner["groupItemButton"] = null;

			$groupRow = $(this).closest(".groupRow");
			$groupRows = $groupRow;
			if (!$groupRow.hasClass("firstLevel")) {
				$groupRows = $groupRow.prevUntil(".groupRow.firstLevel", ".groupRow[data-isworkitem=true]").addBack().prevAll(".groupRow.firstLevel:first").addBack();
			}

			$releaseRow = $groupRow.prevAll(".releaseGroupRow").first();

			releaseTrackerId = codebeamer.ReportSupport.getReleaseTrackerId($(".reportSelectorTag").attr("id"));
			url = contextUrl + "/planner/createIssueWithPrefilledFields.spr";
			url += "?releaseTrackerId=" + (releaseTrackerId ? releaseTrackerId : -1);
			url += "&releaseId=" + ($releaseRow.find(".releaseGroupName").data("releaseid") ? $releaseRow.find(".releaseGroupName").data("releaseid") : -1);
			url += "&isPopup=true";

			$groupRows.each(function() {
				var $self = $(this);

				if ($self.data("cbqlvariable") && $self.data("typed-value")) {
					// Replace brackets to prevent Spring from messing up the variable name
					url += "&" + encodeURIComponent("prefilledFields[" + $self.data("cbqlvariable").replace("[", "(").replace("]", ")") + "]")
							+ "=" + encodeURIComponent($self.data("typed-value"))
							+ "&" + encodeURIComponent("prefilledValues[" + $self.data("typed-value")	+ "]") + "="
							+ encodeURIComponent($self.data("name"));
				}
			});

			showPopupInline(url);
		});
	};

	var initializeItemContextMenus = function () {
		// Planner content loads with AJAX, so remove the listener attacher earlier
		$(document).off("click", ".trackerItems .itemMenuArrowDown");

		$(document).on("click", ".trackerItems .itemMenuArrowDown", function (e) {
			e.stopPropagation();
			var $menuArrow = $(this);

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				var id = $menuArrow.closest('tr').attr("data-tt-id");
				var currentVersionId = $menuArrow.closest('tr').attr("data-releaseId");

				if (currentVersionId == "") {
					currentVersionId = -1;
				}

				// Download and create context menu
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					'task_id': id,
					'cssClass': 'inlineActionMenu',
					'builder': 'plannerItemActionMenuBuilder',
					'currentVersionId': currentVersionId,
					'releaseTrackerId': $("#currentTracker").attr("data-id")
				});

				$("body").one("issueListLoaded", function() {
					$.contextMenu("destroy", "#" + $menuArrow.attr("id"));
				});

			}
		});

		$(document).off("click", ".editInOverlayIcon");

		$(document).on("click", ".editInOverlayIcon", function(e) {
			editItemInOverlay($(this).closest("tr").attr("data-tt-id"), false);
		});
		
		$(document).off('click', '.editInOverlayGroupIcon');
		$(document).on('click', '.editInOverlayGroupIcon', function(e) {
			editItemInOverlay($(this).closest('tr').attr('data-id'), false);
		});
	};

	var initializeReleaseContextMenus = function () {
		$(document).off("click", ".releaseMenu");
		$(document).off("click", ".extendedReleaseMenu");

		$(document).on("click", ".releaseMenu", function (e) {
			e.stopPropagation();

			var $menuArrow = $(this);

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				var id = $menuArrow.data("id");

				// Download and create context menu
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					'task_id': id,
					'cssClass': 'inlineActionMenu',
					'builder': 'plannerReleaseActionMenuBuilder'
				});

				$("body").one("issueListLoaded", function() {
					$.contextMenu("destroy", "#" + $menuArrow.attr("id"));
				})
			}
		});

		$(document).on("click", ".extendedReleaseMenu", function (e) {
			e.stopPropagation();

			var $menuArrow = $(this);

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				var id = $menuArrow.data("id");

				// Download and create context menu
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					'task_id': id,
					'cssClass': 'inlineActionMenu',
					'builder': 'plannerExtendedReleaseActionMenuBuilder',
					'menuKeys':  $menuArrow.data('keys')
				});

				$("body").one("issueListLoaded", function() {
					$.contextMenu("destroy", "#" + $menuArrow.attr("id"));
				})
			}
		});

	};

	var reportSelectorTagCallback = function($container, result) {
		$.waypoints("destroy");
		addRankHandlers($container);
		addBacklogControls();
		// Fix layout after loading result
		$(window).resize();
	};

	var addBacklogControls = function() {
		var $container = $(".reportSelectorTag");
		var releaseId = codebeamer.ReportSupport.getReleaseId($container.attr("id"));
		var $centerPane = $("#plannerCenterPane");
		$centerPane.prev(".backlogControlContainer").remove();
		if (releaseId == -1) {
			var $controlDiv = $("<div>", { "class" : "backlogControlContainer"});

			var $backlogSpan = $("<span>", { "class" : "backlogControl backlog active"});
			var $backlogA = $("<a>", { href : "#"}).text(i18n.message("planner.project.backlog"));
			$backlogA.click(function() {
				if (!$(this).closest(".backlogControl").hasClass("active")) {
					$(this).closest(".backlogControl").addClass("active");
					$(this).closest(".backlogControlContainer").find(".history").removeClass("active");
					forceReportSelectorSearch();
				}
			});
			$backlogSpan.append($backlogA);
			$backlogSpan.append($("<span>", { "class" : "indicatorCont"}).append($("<span>", { "class" : "indicator"})));

			var $historySpan = $("<span>", { "class" : "backlogControl history"});
			var $historyA = $("<a>", { href : "#"}).text(i18n.message("History"));
			$historyA.click(function() {
				if (!$(this).closest(".backlogControl").hasClass("active")) {
					var busy = ajaxBusyIndicator.showBusysign($centerPane);
					$(this).closest(".backlogControl").addClass("active");
					$(this).closest(".backlogControlContainer").find(".backlog").removeClass("active");
					var data = {};
					var fields = codebeamer.ReportSupport.getFieldsFromTable($container.attr("id"));
					if (fields.length > 0) {
						data["fields"] = JSON.stringify(fields);
					}
					$.post(
						contextPath + "/planner/getHistoryItems.spr", data,
						function(response) {
							ajaxBusyIndicator.close(busy);
							$centerPane.html(response);
							addRankHandlers($container, true);
						}
					).fail(function() {
						ajaxBusyIndicator.close(busy);
						forceReportSelectorSearch();
					});
				}
			});
			$historySpan.append($historyA);
			$historySpan.append($("<span>", { "class" : "indicatorCont"}).append($("<span>", { "class" : "indicator"})));

			$controlDiv.append($backlogSpan);
			$controlDiv.append($historySpan);

			$centerPane.before($controlDiv);

			var $droppableField = $(".reportSelectorTag").find(".groupArea").find(".droppableField").first();
			$centerPane.find(".newGroupItemContainer").remove();
			if ($droppableField.length === 1) {
				var fieldObject = $droppableField.data("fieldObject");
				if (fieldObject.id !== 72 && fieldObject.id !== -1 && fieldObject.id !== 1 && fieldObject.typeName === "references") {
					var $newGroupItemContainer = $("<div>", { "class" : "newGroupItemContainer backlogNewGroupItem"});
					$newGroupItemContainer.append($("<a>", { "class" : "newGroupItem", href: "#"}).text(i18n.message("planner.new.group.item")));
					$centerPane.prepend($newGroupItemContainer);
					initNewGroupItem($centerPane);
				}
			}

		}
	};

	var afterMassReleaseUpdate = function(currentReleaseId, newReleaseId) {
		forceReportSelectorSearch();
		reloadLeftPane(newReleaseId);
	};

	var forceReportSelectorSearch = function() {
		isIncrementalScroll = false;
		$(".reportSelectorTag").find(".searchButton").click();
	};

	var exportToExcel = function() {
		var widgetContainerId = $(".reportSelectorTag").attr("id");
		var cbQl = codebeamer.ReportSupport.getCbQl(widgetContainerId);
		if (cbQl.trim() != "") {
			var data = {
				releaseId : codebeamer.ReportSupport.getReleaseId(widgetContainerId),
				releaseTrackerId: codebeamer.ReportSupport.getReleaseTrackerId(widgetContainerId),
				filterProjectIds: codebeamer.ReportSupport.getFilterProjectIds(widgetContainerId),
				filterTrackerIds: codebeamer.ReportSupport.getFilterTrackerIds(widgetContainerId),
				cbQl: cbQl
			};
			var fields = codebeamer.ReportSupport.getFieldsFromTable(widgetContainerId);
			if (fields.length > 0) {
				data["fields"] = JSON.stringify(fields);
			}
			if ($("#currentVersion").length > 0) {
				data["recursive"] = true;
			}
			var url = contextPath + '/planner/export.spr?' + $.param(data);
			showPopupInline(url, { width: 1000, height: 480 });
		}
	};

	var initShowParentItems = function() {
		$("#showParentItems").change(function() {
			var $that = $(this);
			$.post(contextPath + "/userSetting.spr", {
				"name": "PLANNER_SHOW_PARENTS",
				"value": $that.is(":checked") ? "true" : "false"
			});
			if ($that.is(":checked")) {
				addParents();
				showParentItemsChecked = true;
			} else {
				removeParents();
				showParentItemsChecked = false;
			}
		});
	};

	var addMultipleSelectionHandlers = function() {
		if ($("#trackerItems tbody tr").first().hasClass("empty")) {
			return;
		}
		$("#trackerItems .rankTh").addClass("withMultipleSelection");
		$("#trackerItems .rankTh").each(function() {
			var $allHandler = $("<input>", { "class": "allMultipleSelectionCheckbox", type: "checkbox", "title" : i18n.message("planner.check.uncheck.all.label")});
			$allHandler.change(function() {
				var $that = $(this);
				var $rows = $that.closest("tr").nextUntil(".headerRow");
				if ($rows.length == 0) {
					$rows = $that.closest("table").find("tr[data-tt-id]");
				}
				var $checkboxes = $rows.find(".multipleSelectionCheckbox");
				if ($that.is(":checked")) {
					$checkboxes.each(function() {
						if (!$(this).closest("tr").hasClass("itemType_Release")) {
							$(this).prop("checked", true);
						}
					});
				} else {
					$checkboxes.prop("checked", false);
				}
			});
			$(this).prepend($allHandler);
		});
		$("#trackerItems tr.trackerItem").each(function() {
			var $row = $(this);
			var unOrdered = $(this).find(".sendToOrderedBacklog").length > 0;
			var $multipleSelectionInput = $("<input>", { "class": "multipleSelectionCheckbox", type: "checkbox", "data-id" : $row.attr("data-tt-id"), "data-unordered" : unOrdered });
			if ($row.hasClass("itemType_Release")) {
				$multipleSelectionInput.prop("disabled", true);
				$multipleSelectionInput.attr("title", i18n.message("planner.release.checkbox.warning"));
			}
			$(this).find(".rankTd").addClass("withMultipleSelection").prepend($multipleSelectionInput);
			$multipleSelectionInput.change(function() {
				if ($(this).is(":checked")) {
					$(this).closest("tr").addClass("multipleSelected");
				} else {
					$(this).closest("tr").removeClass("multipleSelected");
				}
			});
		});
	};

	var removeMultipleSelectionHandlers = function() {
		$("#trackerItems .rankTh").removeClass("withMultipleSelection");
		$("#trackerItems tr.trackerItem .rankTd").each(function() {
			$(this).removeClass("withMultipleSelection");
			$(this).find(".multipleSelectionCheckbox").remove();
		});
		$("#trackerItems .rankTh").each(function() {
			$(this).find(".allMultipleSelectionCheckbox").remove();
		});
	};

	var initMultipleSelection = function() {
		$("#multipleSelection").change(function() {
			if ($(this).is(":checked")) {
				addMultipleSelectionHandlers();
				multipleSelectionEnabled = true;
			} else {
				removeMultipleSelectionHandlers();
				multipleSelectionEnabled = false;
			}
		});
	};

	var getMultipleSelectionEnabled = function() {
		return multipleSelectionEnabled;
	};

	var showAjaxLoading = function() {
		if (!isIncrementalScroll) {
			$("#plannerCenterPane").css("visibility", "hidden");
			$(".reportSelectorTag .searchButton").prop("disabled", true);
			$("#plannerAjaxLoading").show();
		}
		if (codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
			toggleCenterPaneContextMenuIcons(false);
		}
	};

	var hideAjaxLoading = function() {
		if (!isIncrementalScroll) {
			$("#plannerAjaxLoading").hide();
			$("#plannerCenterPane").css("visibility", "visible");
			$(".reportSelectorTag .searchButton").prop("disabled", false);
		}
		if (codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
			toggleCenterPaneContextMenuIcons(true);
		}
		// Fix layout after loading result
		$(window).resize();
	};

	var toggleCenterPaneContextMenuIcons = function(isVisible) {
		$('#plannerCenterPane .itemMenuArrowDown, #plannerCenterPane .menuArrowDown').toggleClass('always-display-context-menu', isVisible);
	};

	var updateLeftPaneContextMenuIcons = function() {
		if (codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
			$('#west .extendedReleaseMenu, #west .menuArrowDown').addClass('always-display-context-menu');
		}
	}

	var clearIncrementalScroll = function() {
		isIncrementalScroll = false;
	};

	var initIssuePropertiesHandlers = function() {
		var $centerPane = $("#plannerCenterPane"),
			$rightAccordion = getRightAccordion();

		var callback = function() {
			$rightAccordion
				.cbMultiAccordion("enable", [0, 1, 2, 3, 4])
				.cbMultiAccordion("open", 0);
		};

		var selectIssue = function($selectedRow, id) {
			$centerPane.find("tr[data-tt-id]").removeClass("selected");
			$centerPane.find(".groupRow[data-id]").removeClass("selected");
			$selectedRow.addClass("selected");					
			emptyIssueInfoBoxes();
			reloadSelectedIssue(callback, id);			
		};	
		
		var handler = function($selectedRow, id) {
			var $editors = $rightAccordion.find('.editor-wrapper textarea');
			
			if ($editors.length) {
				var oldSelectedIssueId = $centerPane.find('tr[data-tt-id].selected').attr('data-tt-id');
				showFancyConfirmDialogWithCallbacks(i18n.message('tracker.view.layout.document.locked.node.confirm'), function () {
					$editors.each(function() {
						var editorId = $(this).attr('id');

						if (editorId) {
							var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);

							editor && editor.destroy();
						}
					});
					unlockTrackerItem(oldSelectedIssueId, true);
					codebeamer.DisplaytagTrackerItemsInlineEdit.clearNavigateAway();
					selectIssue($selectedRow, id);
				});	
			} else {
				selectIssue($selectedRow, id);
			}
		};

		$centerPane.on("click", ".groupRow[data-isWorkItem=true]", function() {
			var $this = $(this), 
				id = $this.attr("data-id"),
				wasSelected = $this.is(".selected");
			
			if (!wasSelected) {
				handler($this, id);
			}
		});
		$centerPane.on("click", "tr[data-tt-id]", function() {
			var $this = $(this),
				wasSelected = $this.is(".selected");
			
			if (!wasSelected) {
				handler($this, null);
			}
		});
	};

	var init = function() {
		$(".reportSelectorTag .searchButton").prop("disabled", true);
		$("#planner").on("issueChanged", function() {
			var lastSelectedIssueId = findSelectedIssueId();
			cardEditorSaveHandler(lastSelectedIssueId);
		});
		initIssuePropertiesHandlers();
	};

	return {
		"adjustLayout": adjustLayout,
		"cardEditorSaveHandler": cardEditorSaveHandler,
		"reloadCenterPane": reloadIssuesList,
		"sendIssueToTop": sendIssueToTop,
		"moveIssueUpOrDown": moveIssueUpOrDown,
		"sendIssueToBottom": sendIssueToBottom,
		"sendIssueToAnOtherVersion": sendIssueToAnOtherVersion,
		"sendIssueToBacklogAndResetRank": sendIssueToBacklogAndResetRank,
		"sendIssueToBacklogTop": sendIssueToBacklogTop,
		"sendIssueToBacklogMiddle": sendIssueToBacklogMiddle,
		"sendIssueToBacklogBottom": sendIssueToBacklogBottom,
		"sendIssueToBacklogNonRanked": sendIssueToBacklogNonRanked,
		"sendIssueToBacklogTopFromRelease": sendIssueToBacklogTopFromRelease,
		"sendIssueToBacklogMiddleFromRelease": sendIssueToBacklogMiddleFromRelease,
		"sendIssueToBacklogBottomFromRelease": sendIssueToBacklogBottomFromRelease,
		"updateParentRelease": updateParentRelease,
		"editRelease": editRelease,
		"deleteRelease": deleteRelease,
		"editItemInOverlay": editItemInOverlay,
		"init": init,
		"reloadSelectedIssue": reloadSelectedIssue,
		"setupColoredRelationsLoader": setupColoredRelationsLoader,
		"addVersion": addVersion,
		"reloadLeftPane": reloadLeftPane,
		"interruptSuggestionsRendering": isInterruptSuggestionsRendering,
		"retrieveProjectId": retrieveProjectId,
		"reportSelectorTagCallback" : reportSelectorTagCallback,
		"forceReportSelectorSearch" : forceReportSelectorSearch,
		"setPlannerFilters" : setPlannerFilters,
		"setCbQLForPlannerFilters" : setCbQLForPlannerFilters,
		"exportToExcel" : exportToExcel,
		"afterMassReleaseUpdate": afterMassReleaseUpdate,
		"getMultipleSelectionEnabled": getMultipleSelectionEnabled,
		"addClosedGroupHeaders" : addClosedGroupHeaders,
		"showAjaxLoading" : showAjaxLoading,
		"hideAjaxLoading" : hideAjaxLoading,
		"clearIncrementalScroll" : clearIncrementalScroll,
		"updateUrl": updateUrl
	};
}(jQuery));

function executeTransitionCallback(data) {
	codebeamer.planner.forceReportSelectorSearch();
	codebeamer.planner.reloadLeftPane();
	showOverlayMessage();
}

function reloadEditedIssue() {
	executeTransitionCallback();
}

function showColorPicker(id) {
	// close the other color pickers
	$(".colorPickerDialog:not(.reportColorPicker) .ui-icon-close").click()

	var $el = $(".level-2[data-id=" + id + "]");
	var $field = $('<input>', {type: 'hidden', id: 'colorPickerMenuField'});
	$field.one("change", function () {
		var color = $(this).val();
		$.post(contextPath + "/ajax/planner/updateColor.spr", {
			"issue_id": id,
			"color": color
		}, function (data) {
			showOverlayMessage();
			codebeamer.planner.setupColoredRelationsLoader();
			codebeamer.planner.forceReportSelectorSearch();
			$.contextMenu("destroy", ".color-filters .level-2[data-id=" + id + "]  .simpleDropdownMenu");
		});
		$(this).remove();
	});
	$el.append($field);
	colorPicker.showPalette($el.find(".context-menu-anchor"), 'colorPickerMenuField', true);
}

function refreshSelectedIssueProperties() {
	codebeamer.planner.reloadSelectedIssue();
}