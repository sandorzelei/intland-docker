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
codebeamer.gantt = codebeamer.gantt || (function($, gantt) {

	var scaleConfigs,
		renderedView = "DEFAULT",
		cachedSettings = {},
		releaseMethods = [],
		currentTask = {};

	function initColumns(releaseColumnLabel, actualReleaseDateColumnLabel, itemsColumnLabel, missingDateLabel, contextPath) {
		gantt.config.columns = [
			{
				name: "text",
				label: releaseColumnLabel,
				width: "*",
				tree: true,
				template: function(obj) {
					var notificationText = obj.isVirtualLength ? missingDateLabel : "";
					return "<a href='" + contextPath + "/item/" + obj.releaseId + "/stats' target='_blank'>" + obj.text + "</a> <span class='missingDateLabel'>" + notificationText + "</span>";
				}
			},
			{
				name: "text",
				label: actualReleaseDateColumnLabel,
				width: "120px",
				template: function(obj) {
					var result, actualReleaseDate;
					result =  "";

					if (obj.actualReleaseDate) {
						actualReleaseDate = DateParsing.parseDateToString(obj.actualReleaseDate, "yyyy-MM-dd");
						result = "<b>" + DateParsing.formatDateToString(actualReleaseDate, DateParsing.dateFormat) + "</b>";
					}

					return result;
				},
				align: "center"
			},
			{
				name: "items",
				label: itemsColumnLabel,
				width: "100px",
				template: function(obj) {
					return "" + obj.resolvedOrClosedItemsCount + " / " + obj.allItemsCount;
				},
				align: "center"
			}
		];
	}

	function weekScaleTemplate(date) {
		var dateToStr = gantt.date.date_to_str("%d %M");
		var endDate = gantt.date.add(gantt.date.add(date, 1, "week"), -1, "day");
		return dateToStr(date) + " - " + dateToStr(endDate);
	};

	function getTypeClass(obj) {
		if (obj.isSprint) {
			return "sprint-train-icon";
		}
		if (obj.isReferenceRelease) {
			return "reference-train-icon";
		}
		return "release-train-icon";
	}

	function initTemplates(defaultTooltip, missingDateTooltip, missingPermissionTooltip, modificationTooltip, modificationAndMissingDateTooltip, startDateTooltip, endDateTooltip) {
		gantt.templates.date_scale = weekScaleTemplate;

		gantt.templates.lightbox_header = function(startDate, endDate, task) {
			return task.text;
		};

		gantt.templates.grid_folder = function(obj) {
			return "<div class='gantt_tree_icon train-icon " + getTypeClass(obj) + "' style='background-color: " + obj.issueBgColor + "'></div>";
		};

		gantt.templates.grid_file = function(obj) {
			return "<div class='gantt_tree_icon train-icon " + getTypeClass(obj) + "' style='background-color: " + obj.issueBgColor + "'></div>";
		};

		gantt.templates.grid_row_class = function(start, end, obj){
			return obj.isReferenceRelease ? "reference-row" : "sprint-row";
		};

		gantt.templates.task_text=function(start, end, obj){
			return Math.round(obj.progress*100)+"%";
		};

		gantt.templates.task_class=function(start, end, obj){
			var className = "release-task";
			if (obj.releaseMethodId == 1) {
				return className + " release-scrum";
			}
			if (obj.releaseMethodId == 2) {
				return className + " release-kanban";
			}
			if (obj.releaseMethodId == 3) {
				return className + " release-waterfall";
			}
			return className;
		};

		gantt.templates.tooltip_text = function(start, end, task) {
			var tooltip;

			tooltip = defaultTooltip;

			if (task.preventModification && !task.releaseReadonly) {
				if (task.isVirtualLength) {
					tooltip = modificationAndMissingDateTooltip;
				} else {
					tooltip = modificationTooltip;
				}
			} else {
				if (!task.readonly) {
					if (task.isVirtualLength) {
						tooltip = missingDateTooltip;
					}
				} else {
					tooltip = missingPermissionTooltip;
				}
			}

			tooltip = tooltip + "<br>";
			tooltip = tooltip + startDateTooltip + ": ";
			tooltip = tooltip + "<b>" + DateParsing.formatDateToString(start, DateParsing.dateFormat) + "</b>";
			tooltip = tooltip + "<br>";
			tooltip = tooltip + endDateTooltip + ": ";
			tooltip = tooltip + "<b>" + DateParsing.formatDateToString(end, DateParsing.dateFormat) + "</b>";

			return tooltip;
		};
	}

	function initLightbox(okButtonLabel, cancelButtonLabel, timeLabel, descriptionLabel) {
		gantt.locale.labels.section_time = timeLabel;
		gantt.locale.labels.section_description = descriptionLabel;

		gantt.form_blocks["jQuery_date_picker"] = {
			render: function (sns) {
				var html;

				html = "<div class='datePickerContainer'>";
				html = html + "<input id='start_date_input' type='text' size='30' maxlength='30' class='startDateInput' />";
				html = html + "<img id='calendarLink_start_date_input' class='calendarAnchorLink' src='" + contextPath + "/images/newskin/action/calendar.png'>";
				html = html + "<span class='connectMark'>&nbsp;-&nbsp;</span>";
				html = html + "<input id='end_date_input' type='text' size='30' maxlength='30' class='endDateInput' />";
				html = html + "<img id='calendarLink_end_date_input' class='calendarAnchorLink' src='" + contextPath + "/images/newskin/action/calendar.png'>";
				html = html + "</div>";

				return html;
			},
			set_value: function (node, value, task, data) {
				$("#start_date_input").val(DateParsing.formatDateToString(task.start_date, DateParsing.dateFormat));
				$("#end_date_input").val(DateParsing.formatDateToString(task.end_date, DateParsing.dateFormat));

				$("#calendarLink_start_date_input").click(function() {
					jQueryDatepickerHelper.initCalendar("start_date_input");
				});
				$("#calendarLink_end_date_input").click(function() {
					jQueryDatepickerHelper.initCalendar("end_date_input");
				});
			},
			get_value: function (node, task) {
				task.start_date = DateParsing.parseDateToString($("#start_date_input").val(), DateParsing.dateFormat);
				task.end_date = DateParsing.parseDateToString($("#end_date_input").val(), DateParsing.dateFormat);
			},
			focus: function (node) {
			}
		};

		if (releaseMethods && releaseMethods.length > 0) {
			gantt.config.lightbox.sections = [
    		    {
    		    	name: "description",
    		    	height: 22,
    		    	map_to: "releaseMethodId",
    		    	type: "select",
    		    	options: releaseMethods
    		    },
    			{
    				name: "time",
    				type: "jQuery_date_picker",
    				height: 100,
    				map_to: "auto"
    			}
    		];
		} else {
			gantt.config.lightbox.sections = [
      			{
      				name: "time",
      				type: "jQuery_date_picker",
      				height: 100,
      				map_to: "auto"
      			}
      		];
		}

		gantt.config.buttons_left = ["dhx_save_btn", "dhx_cancel_btn"];
		gantt.config.buttons_right = [];
		gantt.locale.labels.icon_save = okButtonLabel;
		gantt.locale.labels.icon_cancel = cancelButtonLabel;
	}

	function initConfig() {
		gantt.config.drag_resize = true;
		gantt.config.drag_progress = false;
		gantt.config.drag_move = true;
		gantt.config.drag_links = false;

		gantt.config.round_dnd_dates = false;

		gantt.config.xml_date = "%Y-%m-%d"; // like 2014-12-31

		gantt.config.scale_unit = "week";
		gantt.config.step = 1;

		gantt.config.grid_width = 500;
	}

	function attachEventHandlers(container, saveNotification, errorNotification, dateValidationNotification, emptyDateNotification) {

		function showReleaseGanttAlertDialog(message) {
			var dialog = showFancyAlertDialog(message);
			dialog.closest(".cbModalDialog").attr('style', function(i,s) { return s + ' z-index: 10005 !important;' });
		}

		function save(task) {

			if (!task.start_date || !task.end_date) {
				showReleaseGanttAlertDialog(emptyDateNotification);
				return false;
			}

			var isValid;
			isValid = (gantt.date.date_part(task.start_date) < gantt.date.date_part(task.end_date));

			if (isValid) {
				releaseUpdater(task);
			} else {
				showReleaseGanttAlertDialog(dateValidationNotification);
				task.start_date = currentTask.start_date;
				task.end_date = currentTask.end_date;
				gantt.updateTask(task.id);
				gantt.refreshData();
				return false;
			}

			return true;
		}

		function releaseUpdater(task) {
			var convert, startDate, endDate, isVirtualLength, self;

			convert = gantt.date.date_to_str("%Y-%m-%d");
			startDate = convert(task.start_date);
			endDate = convert(task.end_date);
			isVirtualLength = task.isVirtualLength;
			var releaseId = task.releaseId;

			jQuery.ajax({
				type: "POST",
				url: contextPath + "/ajax/updateRelease.spr",
				data: {
					releaseId: task.releaseId,
					startDate: startDate,
					endDate: endDate,
					releaseMethod: task.releaseMethodId
				},
				success: function(data, textStatus, jqXHR) {
					if (data.success) {
						if (isVirtualLength) {
							VersionStats.reloadGanttChartForCurrentRelease();
						} else {
							sortGanttChartByPlannedReleaseDate(false);
						}
						showOverlayMessage(saveNotification);
					} else {
						showOverlayMessage(errorNotification, 5, new Error("Updating release failed."));
						$(container).trigger("ganttChartUpdateFailed");
					}
				},
				error: function(jqXHR, textStatus, error) {
					showOverlayMessage(errorNotification, 5, error);
					$(container).trigger("ganttChartUpdateFailed");
				}
			});
		};

		if (codebeamer && $.isArray(codebeamer.gantt_events)) {
		} else {
			codebeamer.gantt_events = [];
		}

		while(codebeamer.gantt_events.length) {
			gantt.detachEvent(codebeamer.gantt_events.pop());
		}

		codebeamer.gantt_events.push(gantt.attachEvent("onBeforeTaskDrag", function(id, mode) {
			var task = gantt.getTask(id);

			currentTask = {};
			$.extend(currentTask, task);

			return true;
		}));

		codebeamer.gantt_events.push(gantt.attachEvent("onBeforeLightbox", function(id, task) {
			var task = gantt.getTask(id);

			currentTask = {};
			$.extend(currentTask, task);

			return true;
		}));

		codebeamer.gantt_events.push(gantt.attachEvent("onAfterTaskDrag", function(id, mode) {
			var task  = gantt.getTask(id);
			return save(task);
		}));

		codebeamer.gantt_events.push(gantt.attachEvent("onLightboxSave", function(id, task) {
			return save(task);
		}));

	}

	function renderZoomView() {
		saveConfig();
		zoomToFit();
		renderedView = "ZOOM";
	}

	function renderDefaultView() {
		restoreConfig();
		gantt.render();
		gantt.config.round_dnd_dates = false;
		renderedView = "DEFAULT";
	}

	function saveConfig() {
		var config = gantt.config;

		cachedSettings = {};
		cachedSettings.scale_unit = config.scale_unit;
		cachedSettings.date_scale = config.date_scale;
		cachedSettings.step = config.step;
		cachedSettings.subscales = config.subscales;
		cachedSettings.template = gantt.templates.date_scale;
		cachedSettings.start_date = config.start_date;
		cachedSettings.end_date = config.end_date;
	}

	function restoreConfig() {
		applyConfig(cachedSettings);
	}

	function applyConfig(config, dates) {
		gantt.config.scale_unit = config.scale_unit;
		if (config.date_scale) {
			gantt.config.date_scale = config.date_scale;
			gantt.templates.date_scale = null;
		}
		else {
			gantt.templates.date_scale = config.template;
		}

		gantt.config.step = config.step;
		gantt.config.subscales = config.subscales;

		if (dates) {
			gantt.config.start_date = gantt.date.add(dates.start_date, -1, config.unit);
			gantt.config.end_date = gantt.date.add(gantt.date[config.unit + "_start"](dates.end_date), 2, config.unit);
			gantt.config.round_dnd_dates = config.round_dnd_dates;
		} else {
			gantt.config.start_date = gantt.config.end_date = null;
		}
	}

	function zoomToFit() {
		var project = gantt.getSubtaskDates(),
				areaWidth = gantt.$task.offsetWidth;

		for (var i = 0; i < scaleConfigs.length; i++) {
			var columnCount = getUnitsBetween(project.start_date, project.end_date, scaleConfigs[i].unit, scaleConfigs[i].step);
			if ((columnCount + 2) * gantt.config.min_column_width <= areaWidth) {
				break;
			}
		}

		if (i == scaleConfigs.length) {
			i--;
		}

		applyConfig(scaleConfigs[i], project);
		gantt.render();
	}

	// get number of columns in timeline
	function getUnitsBetween(from, to, unit, step) {
		var start = new Date(from),
				end = new Date(to);
		var units = 0;
		while (start.valueOf() < end.valueOf()) {
			units++;
			start = gantt.date.add(start, step, unit);
		}
		return units;
	}

	function isDefaultViewActive() {
		return renderedView === "DEFAULT";
	}

	function sortGanttChartByPlannedReleaseDate(desc) {
		gantt.sort("start_date", desc);
	}

	function addReleaseMethod(newReleaseMethod) {
		var keys = $.map(releaseMethods, function(object, index) {
			return object.key;
		});

		if (keys.indexOf(newReleaseMethod.key) === -1) {
			releaseMethods.push(newReleaseMethod);
		}
	}

	function ready(container, success) {
		if (success) {
			$(container).trigger("ganttChartLoaded");
		} else {
			$(container).trigger("ganttChartLoadingError");
		}
	}

	//Setting available scales
	scaleConfigs = [
		// days
		{
			unit: "day",
			round_dnd_dates: true,
			step: 1,
			scale_unit: "month",
			date_scale: "%F",
			subscales: [
				{
					unit: "day",
					step: 1,
					date: "%j"
				}
			]
		},
		// weeks
		{
			unit: "week",
			round_dnd_dates: false,
			step: 1,
			scale_unit: "month",
			date_scale: "%F",
			subscales: [
				{
					unit: "week",
					step: 1,
					date: "%d %M"
				}
			]},
		// months
		{
			unit: "month",
			round_dnd_dates: false,
			step: 1,
			scale_unit: "year",
			date_scale: "%Y",
			subscales: [
				{
					unit: "month",
					step: 1,
					date: "%M"
				}
			]
		},
		// years
		{
			unit: "year",
			round_dnd_dates: false,
			step: 1,
			scale_unit: "year",
			date_scale: "%Y",
			subscales: []
		}
	];


	return {
		"initColumns": initColumns,
		"initTemplates": initTemplates,
		"initLightbox": initLightbox,
		"initConfig": initConfig,
		"attachEventHandlers": attachEventHandlers,
		"renderZoomView": renderZoomView,
		"renderDefaultView": renderDefaultView,
		"isDefaultViewActive": isDefaultViewActive,
		"sortGanttChartByPlannedReleaseDate": sortGanttChartByPlannedReleaseDate,
		"addReleaseMethod": addReleaseMethod,
		"ready": ready
	};
})(jQuery, gantt);
