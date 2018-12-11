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

/*
 * JavaScript for versionStats.jsp
 */
var VersionStats = {

	localFilterState: {},

	categoryFilters: {},

	independentFilters: {},

	pageLayout: null,

	clearFilter: function() {
 		$("#versionStatsBox").find(".selected").removeClass("selected");
	},

	showOrHideFilters: function(trackerItems) {
		var $versionStatsBox = $("#versionStatsBox");
		if (trackerItems && trackerItems.length > 0) {
			$versionStatsBox.show();
		} else {
			$versionStatsBox.hide();
		}
	},

	setupEditMode: function() {
		// in editable mode add the handlers to the issue rows and initialize the dnd
		if (VersionStats.mode !== "edit") {
			return;
		}

		// all "versionIssues" block shows the issues of each releases
		// because it might happen that a release is not editable we have to iterate to all releases
		// and add drag-and-drop only if that release is editable
		$(".versionIssues").each(function() {
			var $versionIssues = $(this);

			// find the parent <div id="versionIssues_2913"> because this contains the id of the Release contains the dragged issue
			var $versionIssuesContainer = $versionIssues.closest("[id^='versionIssues_']");
			var parentReleaseId = $versionIssuesContainer.attr("id");
			parentReleaseId = parseInt(parentReleaseId.substring("versionIssues_".length));

			// check if this release is editable
			var releaseEditable = $.inArray(parentReleaseId, editableReleasesIds) != -1;
			if (! releaseEditable) {
				return;
			}

			/*VersionStats.makeTableSortable($versionIssues, parentReleaseId, {
				"containment": $(this).closest(".version")
			});*/
			$(".issuelist tbody td").css("cursor", "default"); // TODO: remove

		});
	},

	initLayout: function(resizable, minHeight) {
		var container, releaseGanttChartLoaded, footerHeight, newHeight, pageLayout;

		function updateContainerDimensions() {
			container = $('.container');
			footerHeight = $("#footer").outerHeight();
			newHeight = $(window).innerHeight() - container.offset().top - footerHeight - 5;
			container.height(newHeight);

			container.width($(window).innerWidth());
		}

		// Calculate the initial size for the content area. (Required by the JQuery layout plugin)
		updateContainerDimensions();

		// Configure the JQuery layout plugin
		this.pageLayout = $('.container').layout({
			applyDefaultStyles: false,
			// This makes margins look good and prevents jumping
			center__applyDefaultStyles: true,
			useStateCookie: false,
			initClosed: true,
			spacing_open: 5,
			spacing_closed: 0,
			minSize: minHeight !==null && minHeight !== undefined ? minHeight : 136,
			resizeWithWindow: false,
			onresize: $.proxy(this.onJQueryPanelResize, this),
			resizable: resizable
		});

		pageLayout = this.pageLayout;

		$(window).resize(throttleWrapper(function() {
			updateContainerDimensions();
			pageLayout.resizeAll();
		}, 100));

	},

	initGanttChart: function(releaseId) {
		$(".ganttAccordion .accordion-header").one("click", $.proxy(function() {
			var releaseGanttChartCont, container, mainTypeFilter;

			this.paneSize = 0;

			this.showGanttLoadingIndicator();

			releaseGanttChartCont = $("#releaseGanttChart");

			mainTypeFilter = this.getMainTypeFilter();

			releaseGanttChartCont.load(contextPath + "/ajax/renderGanttChart.spr?releaseId=" + releaseId + (mainTypeFilter ? "&trackerTypes=" + mainTypeFilter : ""),
				$.proxy(function() {
					this.hideGanttLoadingIndicator();
					this.initNortPanelTogglerGanttChart(this.pageLayout);
					this.attachListenersForCustomGanttChartEvents();
					this.pageLayout.resizeAll();
				}, this));
		}, this));

	},

	getMainTypeFilter: function() {
		return $("#versionsTable").data("type-main");
	},

	attachListenersForCustomGanttChartEvents: function() {
		var self, ganttChartContainer;

		self = this;
		ganttChartContainer = $("div[id^=ganttChartContainer]");

		ganttChartContainer.on("ganttChartUpdateFailed", function() {
			self.reloadGanttChart();
			self.hideGanttLoadingIndicator();
		});

		ganttChartContainer.on("ganttChartLoaded", function() {
			self.hideGanttLoadingIndicator();
		});
	},

	clearListenersForCustomGanttChartEvents: function() {
		$("div[id^=ganttChartContainer]").off();
	},

	showGanttLoadingIndicator: function() {
		$(".ganttChartInlineLoadingIndicator").show();
	},

	hideGanttLoadingIndicator: function() {
		$(".ganttChartInlineLoadingIndicator").hide();
	},

	initNortPanelTogglerGanttChart: function(pageLayout) {
		var toggled;

		function open(pageLayout) {
			if (pageLayout != null) {
				toggled = true;
				pageLayout.enableResizable("north");
				$(".ganttAccordion .accordion-header").addClass("opened");
				pageLayout.toggle("north");
				$(".ui-layout-resizer").show();
			}
		}

		function close(pageLayout) {
			if (pageLayout != null) {
				toggled = false;
				pageLayout.disableResizable("north");
				$(".ganttAccordion .accordion-header").removeClass("opened");
				pageLayout.toggle("north");
				$(".ui-layout-resizer").hide();
			}
		}

		$(".accordion.ganttAccordion").off();

		//Open right after init
		$("div[id^=ganttChartContainer").one("ganttChartLoaded", $.proxy(function() {
			open(pageLayout);
		}, this));

		// Controls the north panel toggler
		$(".ganttAccordion .accordion-header").on("click", $.proxy(function(event) {
			if (pageLayout) {
				if (toggled) {
					close(pageLayout);
				} else {
					open(pageLayout);
				}
			}

			event.stopPropagation();
			event.preventDefault();
		}, this));
	},

	initNortPanelTogglerGanttChartTeaser: function(pageLayout) {
		var toggled;

		function open(pageLayout) {
			if (pageLayout != null) {
				toggled = true;
				$(".ganttAccordion .accordion-header").addClass("opened");
				pageLayout.toggle("north");
			}
		}

		function close(pageLayout) {
			if (pageLayout != null) {
				toggled = false;
				$(".ganttAccordion .accordion-header").removeClass("opened");
				pageLayout.toggle("north");
			}
		}

		$(".accordion.ganttAccordion").off();

		// Controls the north panel toggler
		$(".ganttAccordion .accordion-header").on("click", $.proxy(function(event) {
			if (pageLayout) {
				if (toggled) {
					close(pageLayout);
				} else {
					open(pageLayout);
				}
			}

			event.stopPropagation();
			event.preventDefault();
		}, this));

		open(pageLayout);
	},

	onJQueryPanelResize: function(name, pane, config) {
		var difference, ganttContainerHeight;

		// Resizing the north panel and it has a valid height
		if (name === "north") {
			if (this.paneSize === 0) {
				this.paneSize = config.outerHeight;

				this.calculateInitialHeightAndRenderGanttChart();
			}

			// Calculate the pane size change
			difference = config.outerHeight - this.paneSize;
			this.paneSize = config.outerHeight;

			// Calculate the new height of the gantt chart
			ganttContainerHeight = $('div[id^=ganttChartContainer').outerHeight();
			ganttContainerHeight = ganttContainerHeight + difference;

			this.renderGanttChart(ganttContainerHeight);

			$(".ui-layout-north .releaseGanttChart_plugin").height(this.calculatePluginHeight());

			userSettings.save("RELEASE_GANTT_CHART_HEIGHT", $(".ui-layout-north .releaseGanttChart_plugin").height());
		}
	},

	renderGanttChart: function(desiredHeight) {
		var difference, ganttContainerHeight, ganttInformationBarHeight;

		ganttContainerHeight = desiredHeight;

		if (ganttContainerHeight > 100) {
			// If the information bar is visible, or there is no information bar then just use the calculated size
			if ($(".ui-layout-north .information").is(":visible") || $(".ui-layout-north .information").outerHeight() === null) {
				$('div[id^=ganttChartContainer').height(ganttContainerHeight);
			} else {
				// If the information bar is currently hidden, then calculate whether it is possible to show it again
				ganttInformationBarHeight = $(".ui-layout-north .information").outerHeight();
				if (ganttContainerHeight - ganttInformationBarHeight >= 100) {
					//If the gantt chart becomes at least 100 px tall after we show the information bar, then show it
					$(".ui-layout-north .information").show();
					ganttContainerHeight = ganttContainerHeight - ganttInformationBarHeight;
				}
				$('div[id^=ganttChartContainer').height(ganttContainerHeight);
			}

			gantt.render();

		} else {
			// If the gantt chart would become too small and the information bar is still visible, then hide the information bar and use the space to make the gantt bigger
			if ($(".ui-layout-north .information").is(":visible")) {
				ganttInformationBarHeight = $(".ui-layout-north .information").outerHeight();
				$(".ui-layout-north .information").hide();
				ganttContainerHeight = ganttInformationBarHeight + ganttContainerHeight;
				$("div[id^=ganttChartContainer").height(ganttContainerHeight);
			} else {
				// Set the gantt chart size to the allowed minimum
				ganttContainerHeight = 100;
				$("div[id^=ganttChartContainer").height(ganttContainerHeight);
			}

			gantt.render();
		}
	},

	calculateInitialHeightAndRenderGanttChart: function() {
		var ganttInformationBarHeight, ganttActionLinkHeight, ganttPluginHeight;

		ganttActionLinkHeight = $(".renderingModeLinkContainer").outerHeight();
		ganttInformationBarHeight = $(".ui-layout-north .information").outerHeight();
		ganttPluginHeight = $(".ui-layout-north .releaseGanttChart_plugin").outerHeight();

		codebeamer.gantt.sortGanttChartByPlannedReleaseDate(false);

		this.renderGanttChart(ganttPluginHeight - ganttInformationBarHeight - ganttActionLinkHeight);

	},

	reloadGanttChartForCurrentRelease: function() {
		this.reloadGanttChart(this.releaseId);
	},

	reloadGanttChart: function(releaseId) {
		var accordion, pluginHeight, self;

		if (gantt) {
			self = this;

			this.showGanttLoadingIndicator();

			pluginHeight = this.calculatePluginHeight();

			this.clearListenersForCustomGanttChartEvents();
			releaseGanttChartCont = $("#releaseGanttChart");
			releaseGanttChartCont.empty();
			gantt.clearAll();
			mainTypeFilter = this.getMainTypeFilter();

			releaseGanttChartCont.load(
					contextPath + "/ajax/renderGanttChart.spr?releaseId=" + releaseId + "&height=" + pluginHeight
					+ (mainTypeFilter ? "&trackerTypes=" + mainTypeFilter : ""),
					function() {
						self.calculateInitialHeightAndRenderGanttChart();

						self.attachListenersForCustomGanttChartEvents();

						self.hideGanttLoadingIndicator();
					}
			);
		}
	},

	calculatePluginHeight: function() {
		var ganttInformationBarHeight, ganttActionLinkHeight, ganttContainerHeight;

		ganttActionLinkHeight = $(".renderingModeLinkContainer").outerHeight();
		if ($(".ui-layout-north .information").is(":visible")) {
			ganttInformationBarHeight = $(".ui-layout-north .information").outerHeight();
		} else {
			ganttInformationBarHeight = 0;
		}
		ganttContainerHeight = $("div[id^=ganttChartContainer").outerHeight();

		return ganttContainerHeight + ganttInformationBarHeight + ganttActionLinkHeight;
	},

	initGanttChartTeaser: function() {
		var releaseGanttChartCont;

		$(".ganttAccordion .accordion-header").one("click", $.proxy(function() {
			var releaseGanttChartCont, container;

			this.showGanttLoadingIndicator();

			this.paneSize = 0;

			releaseGanttChartCont = $("#releaseGanttChart");

			releaseGanttChartCont.load(contextPath + "/ajax/renderGanttChartTeaser.spr", $.proxy(function() {
				this.hideGanttLoadingIndicator();
				this.pageLayout.resizeAll();
				this.initNortPanelTogglerGanttChartTeaser(this.pageLayout);
			}, this));

		}, this));

	},

	init:function(mode, releaseId, ganttChartAllowed) {
		var pageLayout, toggled;

		VersionStats["mode"] = "edit";
		VersionStats["releaseId"] = releaseId;

		$(document).on("release:filter:update", $.proxy(function(event, checkedFilters) {
			var isBurndownOutdated = false;

			if (checkedFilters) {
				this.localFilterState = checkedFilters;
				this.independentFilters.mainTypeFilter = this.calculateTrackerTypeFilter();
				this.independentFilters.mainStatusFilter = this.localFilterState.status;
				this.reloadPageWithFilters();
			}
		}, this));

		this.initLayout(ganttChartAllowed, ganttChartAllowed ? 136 : 513);

		if (ganttChartAllowed) {
			this.initGanttChart(releaseId);
		} else {
			this.initGanttChartTeaser();
		}

		this.initTransitionMenu();

	},

	initTransitionMenu: function() {
		$("[data-role=status-icon]").on("click", function (event) {
			if ($(event.target).is("[data-role=status-icon]")) {
				var $target = $(event.target).find("[data-role=status-menu]");
				buildAjaxTransitionMenu($target, {
					"task_id": $target.data("id"),
					"cssClass": "inlineActionMenu transition-action-menu",
					"builder": "trackerItemTransitionsOverlayActionsMenuBuilder"
				});
			}
		});

	},

	installExecuteTransitionCallback: function() {
		window.executeTransitionCallback = function(data) {
			location.reload();
		};

		window.reloadEditedIssue = window.executeTransitionCallback;
	},

	updateTableItemPosition:function(releaseId, projectId, movedIssueId, referenceId, position, successCallback, failureCallback) {
		var busyPage, finalTaskId, finalProjectId;

		var busyPage = ajaxBusyIndicator.showBusyPage();

		finalTaskId = -1;
		if (releaseId) {
			finalTaskId = $.isFunction(releaseId) ? releaseId(movedIssueId) : releaseId;
		};

		finalProjectId = -1;
		if (projectId) {
			finalProjectId = projectId;
		};

		$.ajax({
			"url": contextPath + "/ajax/moveIssue.spr",
			"type": "POST",
			"data": {
				"taskId": finalTaskId,
				"movedIssueId": movedIssueId,
				"referenceId": referenceId,
				"position": position,
				"projectId": finalProjectId
			},
			"success": function(response) {
				var message;

				busyPage.remove();
				if (response["success"] == true) {
					if (successCallback) {
						successCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.successfully.saved");
						showOverlayMessage(message);
					}
				} else {
					if (failureCallback) {
						failureCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.error.try.reload");
						showOverlayMessage(message, 6, true);
					}
				}
			},
			"error": function(data, status, error) {
				var message;

				if (data.status === 401) {
					location.reload(contextPath + "/login.spr");
				}

				if (failureCallback) {
					failureCallback(data);
				} else {
					message = data["responseText"] ? data["responseText"] : i18n.message("ajax.changes.error.try.reload");
					showOverlayMessage(message, 6, true);
				}

				busyPage.remove();
			}
		});
	},

	moveIssueInBacklog: function(projectId, movedIssueId, position, successCallback, failureCallback, releaseTrackerId, ignoreBusyPage) {

		if (!ignoreBusyPage) {
			var busyPage = ajaxBusyIndicator.showBusyPage();
		}

		$.ajax({
			"url": contextPath + "/ajax/moveIssueInBacklog.spr",
			"type": "POST",
			"data": {
				"movedIssueId": movedIssueId,
				"position": position,
				"projectId": projectId,
				"releaseTrackerId": releaseTrackerId
			},
			"success": function(response) {
				if (!ignoreBusyPage) {
					busyPage.remove();
				}
				if (response["success"] == true) {
					if (successCallback) {
						successCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.successfully.saved");
						showOverlayMessage(message);
					}
				} else {
					if (failureCallback) {
						failureCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.error.try.reload");
						showOverlayMessage(message, 6, true);
					}
				}
			},
			"error": function(data, status, error) {
				var message;

				if (data.status === 401) {
					location.reload(contextPath + "/login.spr");
				}

				if (failureCallback) {
					failureCallback(data);
				} else {
					message = data["responseText"] ? data["responseText"] : i18n.message("ajax.changes.error.try.reload");
					showOverlayMessage(message, 6, true);
				}

				if (!ignoreBusyPage) {
					busyPage.remove();
				}
			}
		});
	},

	resetRankInBacklog: function(projectId, movedIssueId, successCallback, failureCallback) {

		var busyPage = ajaxBusyIndicator.showBusyPage();

		$.ajax({
			"url": contextPath + "/ajax/resetRankInBacklog.spr",
			"type": "POST",
			"data": {
				"movedIssueId": movedIssueId,
				"projectId": projectId
			},
			"success": function(response) {
				busyPage.remove();
				if (response["success"] == true) {
					if (successCallback) {
						successCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.successfully.saved");
						showOverlayMessage(message);
					}
				} else {
					if (failureCallback) {
						failureCallback(response);
					} else {
						message = response["message"] ? response["message"] : i18n.message("ajax.changes.error.try.reload");
						showOverlayMessage(message, 6, true);
					}
				}
			},
			"error": function(data, status, error) {
				var message;

				if (data.status === 401) {
					location.reload(contextPath + "/login.spr");
				}

				if (failureCallback) {
					failureCallback(data);
				} else {
					message = data["responseText"] ? data["responseText"] : i18n.message("ajax.changes.error.try.reload");
					showOverlayMessage(message, 6, true);
				}

				busyPage.remove();
			}
		});
	},

	makeTableSortable: function ($issueTableContainer, releaseId, parameters, completeCallback) {
		// add the handle to each row
		var hint = i18n.message("cmdb.version.stats.drag.drop.hint");
		$issueTableContainer.find('tr:not(.dnd-initialized)').each(function () {
			var $tr = $(this);
			var tableHeader = $tr.is(".tableHeader");
			if (!tableHeader) {
				var handle;
				var rankCell = $tr.find("td[data-rank]");
				// Only intialize issue handle for issues, which has a rannk. Only these issues can be reordered in the backlog.
				// In case of releases all issues are ordered, so has a rank.
				if ($tr.hasClass("open")) {
					if($.isNumeric(rankCell.data("rank"))) {
						handle = $("<td class='issueHandle' title='" + hint + "'></td>");
					} else {
						handle = $("<td class='issueHandle''></td>");
					}
					$tr.prepend(handle);
				} else {
					handle = $("<td class='emptyIssueHandle'></td>");
					$tr.prepend(handle);
				}
				$tr.addClass("dnd-initialized");
				var categoryColor = $tr.data("category-color");
				if (categoryColor) {
					handle.css("background-color", categoryColor);
				}
			}
		});

		// initialize drag-and-drop sorting
		$issueTableContainer.find("tbody").sortable($.extend({
			"placeholder": "issuePlaceHolder",
			"items": "tr.open",
			"start": function(event, ui) { codebeamer.is_dragging = true; },
			"stop": function() { codebeamer.is_dragging = false; },
			"update": function (event, ui) { // triggered when the card was moved and the new place is different from the original
				VersionStats.updateHandler(releaseId, codebeamer.planner.retrieveProjectId(), event, ui, function () {
					if (completeCallback) {
						completeCallback(ui);
					}
				});
			}
		}, parameters));

		$issueTableContainer.bind("mousemove", function() {
			var placeholder = "<td colspan='8'> " + i18n.message("tracker.view.layout.cardboard.story.drop.placeholder.hint") +"</div></td>";
			$(".issuePlaceHolder").html(placeholder);
		});

		$issueTableContainer.find("table.issuelist").addClass("edited");
	},

	updateHandler: function (releaseId, projectId, event, ui, successCallback, failureCallback) { // triggered when the card was moved and the new place is different from the original
		var $underCursor = $(document.elementFromPoint(event.clientX, event.clientY));
		if ($underCursor.parents(".ui-sortable").size() == 0) {
			// don't do anything if the element was dropped outside of the sortable
			// this can happen when there are droppables on the page
			return;
		}
		var $row = $(ui.item);
		var $reference = null;
		var position = "after";
		if ($row.prev(".open").size() > 0) {
			$reference = $row.prev();
		} else {
			$reference = $row.next(".open");
			position = "before";
		}

		var movedIssueId = $row.attr("id");
		var referenceId = $reference.attr("id");

		VersionStats.updateTableItemPosition(releaseId, projectId, movedIssueId, referenceId, position, successCallback, failureCallback);
	},

	retrieveFilterParameters: function() {
		var filterArgs = {};

		$.extend(filterArgs,
			{
 				"task_id": this.releaseId,
			},
			this.categoryFilters,
			this.independentFilters
		);

		return filterArgs;
	},

	reloadPageWithFilters:function() {
		var filterArgs = this.retrieveFilterParameters();
		window.location = window.location.pathname + "?" + $.param(filterArgs);
	},


	/**
	 * generates aprint schedule for the release based on the release settings.
	 */
	generateSprintSchedule: function(releaseId, callback) {
		$.post(contextPath + "/ajax/agile/generateReleaseSchedule.spr", {
			"task_id": releaseId
		}, function (data) {
			if (data.success) {
				showOverlayMessage();
				if (callback && $.isFunction(callback)) {
					callback.apply();
				}
			} else {
				showOverlayMessage(data.message, 5, true);
			}
		});
	},

	/**
	 * generates aprint schedule for the release based on the release settings.
	 */
	generateNextSprint: function(releaseId, callback) {
		$.post(contextPath + "/ajax/agile/generateNextSprint.spr", {
			"task_id": releaseId
		}, function (data) {
			if (data.success) {
				showOverlayMessage();
				if (callback && $.isFunction(callback)) {
					callback.apply();
				}
			} else {
				showOverlayMessage(data.message, 5, true);
			}
		});
	},

	calculateTrackerTypeFilter: function() {
		var result = "default";

		if (this.localFilterState && this.localFilterState.testRunVisibility) {
			result = this.localFilterState.testRunVisibility;
		}

		return result;
	},

	initEventHandlers: function() {
		var self = this;

		$("tr.data-row td.filterCell").on('click', function(event) {
			var filterArgs, clearing, $element;

			$element = $(this);
			filterArgs = {};
			filterArgs[$element.data("filter-category")] = $element.data("filter-value");

			if ($element.data("status-open") !== undefined && $element.data("status-open") !== null) {
				filterArgs.open = $element.data("status-open").toString();
			}

			if (self.independentFilters && !self.independentFilters.mainTypeFilter) {
				self.independentFilters.mainTypeFilter = self.calculateTrackerTypeFilter();
			}

			clearing = $element.closest("td.selected").length > 0;

			if (clearing) {
				// no filtering
				self.categoryFilters = {};
			} else {
				self.categoryFilters = filterArgs;
			}

			self.reloadPageWithFilters();
		});

		$("body .version.expander-delegate").on("click", function(event) {
			var currentTarget = $(event.currentTarget);

			currentTarget.siblings(".expander").click();

			event.preventDefault();
			event.stopPropagation();
		});

		$(document).on("click", ".versionMoreMenu", "click", function (e) {
			e.stopPropagation();
			e.preventDefault();

			var $menuArrow = $(this);

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				var id = $menuArrow.data("id");

				// Download and create context menu
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					"task_id": id,
					"cssClass": "inlineActionMenu",
					"builder": "versionsViewExtendedActionMenuBuilder"
				});
			}
		});

	},

	loadFilterState: function() {
		var versionsTable = $("#versionsTable");

		this.categoryFilters[versionsTable.data("filter-category")] = versionsTable.data("filter-value");
		if (versionsTable.data("status-open")) {
			this.categoryFilters.open  = versionsTable.data("status-open").toString();
		}
		this.categoryFilters.taskId = this.releaseId;
		if (versionsTable.data("type-main")) {
			this.independentFilters.mainTypeFilter = versionsTable.data("type-main");
		}
		if (versionsTable.data("status-main")) {
			this.independentFilters.mainStatusFilter = versionsTable.data("status-main");
		}
	},

	afterMassReleaseUpdate: function() {
		window.location.reload();
	},

	afterMassReleaseFailure: function() {
		// Release Dashboard needs to reload, give a chance to the user to read the error message and reload when he or she tries to close the popup.
		$(".overlayMessageBoxContainer .closer").click(function() {
			window.location.reload();
		});
	}
};

$(document).ready(function() {
	VersionStats.initEventHandlers();
	VersionStats.loadFilterState();
})
