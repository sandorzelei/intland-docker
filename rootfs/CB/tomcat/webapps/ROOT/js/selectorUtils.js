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
 * $Revision$ $Date$
 */

(function($) {

	var dateRangeCache = [];
	var localeDataCache = null;
	var defaultLocaleData = {
		"locale" : "en",
		"firstDayOfWeek": 0,
		"country" : "EN"
	};

	var nextSelectorUtilUniqueId = 1;

	var fixSelectorDialogPosition = function(containerId, dialogId) {
		var $dialog = $('#' + dialogId);
		$dialog.position({
			of: $('#' + containerId),
			my: "left top",
			at: "left bottom"
		});
	};

	// jQuery plugin for Date Range Selector

	$.fn.dateRangeSelector = function(config) {

		var settings = $.extend( {}, $.fn.dateRangeSelector.defaults, config);

		if (DateParsing && DateParsing.localeData !== null) {
			localeDataCache = DateParsing.localeData;
		} else if (localeDataCache == null) {
			$.ajax({
				dataType: "json",
				url: settings.getLocaleDataUrl,
				async: false
			}).done(function(result) {
				localeDataCache = result;
			}).fail(function() {
				localeDataCache = defaultLocaleData;
			});
		}

		function drawDialog($container) {

			function startsWith(string, prefix) {
				return string.slice(0, prefix.length) == prefix;
			}

			var isPredefined = false;
			var existingFromDate = settings.existingFromDate;
			var existingToDate = settings.existingToDate;
			var fromDateIsRange = existingFromDate && existingFromDate.length > 0 && (startsWith(existingFromDate, "+") || startsWith(existingFromDate, "-"));
			var toDateIsRange = existingToDate && existingToDate.length > 0 && (startsWith(existingToDate, "+") || startsWith(existingToDate, "-"));
			if (fromDateIsRange || toDateIsRange) {
				isPredefined = true;
			}
			if (!existingFromDate || existingFromDate.length == 0) {
				$container.data("fromDate", null);
				$container.data("fromDateISO", null);
				existingFromDate = "";
			}
			if (!existingToDate || existingToDate.length == 0) {
				$container.data("toDate", null);
				$container.data("toDateISO", null);
				existingToDate = "";
			}

			var $dialog = $("<div>", { id: settings.dialogIdPrefix + "_" + settings.id, "data-uniqueid" : settings.id, "class": settings.defaultDialogClass + " " + settings.dialogClasses });
			$dialog.click(function(e) {
				e.stopPropagation();
			});

			var parseCustomRelative = function(value) {
				var result = {
					numberVal: 0,
					range: "d",
					direction: "-"
				};
				if (!value || value.length == 0) {
					return result;
				}
				try {
					return {
						numberVal: value.match(/\d+/g)[0],
						range: value.match(/[a-zA-z]+/g)[0],
						direction: value.charAt(0)
					}
				} catch (e) {
					return result;
				}
			};

			var relativeCheckboxHandler = function($input, $container) {
				var $controls = $container.find('input[type="number"], select');
				if ($input.is(":checked")) {
					$controls.prop("disabled", false);
				} else {
					$controls.prop("disabled", true);
				}
			};

			var $rangeContainer = $("<div>", { "class": "rangeContainer"});
			$rangeContainer.append($("<label>").text(i18n.message("date.range.selector.range.label") + ":"));
			var $predefinedSelector = $("<select>");
			$predefinedSelector.change(function() {
				var $dateDialog = $("#" + settings.dialogIdPrefix + "_" + settings.id);
				var $fromDateInput = $dateDialog.find(".fromDate");
				var $toDateInput = $dateDialog.find(".toDate");
				var $selectedOption = $(this).find("option:selected");
				var jsFromFunction = $selectedOption.data("jsFrom");
				var jsToFunction = $selectedOption.data("jsTo");
				if (typeof jsFromFunction !== 'undefined' && typeof jsToFunction !== 'undefined') {
					moment.locale(localeDataCache["country"]);
					var fromDate = eval(jsFromFunction);
					var toDate = eval(jsToFunction);
					if (typeof fromDate !== 'undefined' && typeof toDate !== 'undefined') {
						var fromDateISO = fromDate.format("YYYY-MM-DD");
						var toDateISO = toDate.format("YYYY-MM-DD");
						var fromDateFormatted = DateParsing.formatDateToString(fromDate.toDate(), DateParsing.dateFormat, false);
						var toDateFormatted = DateParsing.formatDateToString(toDate.toDate(), DateParsing.dateFormat, false);
						$fromDateInput.val(fromDateFormatted);
						$toDateInput.val(toDateFormatted);
						$container.data("fromDateISO", fromDateISO);
						$container.data("toDateISO", toDateISO);
						$container.data("cbQLFrom", $selectedOption.data("cbQLFrom"));
						$container.data("cbQLTo", $selectedOption.data("cbQLTo"));
						$container.data("fromDate", $selectedOption.data("cbQLFrom"));
						$container.data("toDate", $selectedOption.data("cbQLTo"));
					}
				}
				var fromRange = null;
				var toRange = null;
				if (settings.showRelativeCustomRange) {
					var $dialogCont = $(this).closest(".selectorUtilDialog");
					if ($(this).val() != "custom") {
						var $relativeFromCheckbox = $dialogCont.find(".relativeFromCheckbox");
						$relativeFromCheckbox.prop("checked", true);
						relativeCheckboxHandler($relativeFromCheckbox, $relativeFromCheckbox.closest(".fromContainer"));
						var $relativeToCheckbox = $dialogCont.find(".relativeToCheckbox");
						$relativeToCheckbox.prop("checked", true);
						relativeCheckboxHandler($relativeToCheckbox, $relativeToCheckbox.closest(".toContainer"));
						var fromRange = parseCustomRelative($selectedOption.data("cbQLFrom"));
						var toRange = parseCustomRelative($selectedOption.data("cbQLTo"));
						$dialogCont.find(".relativeFromNumber").val(fromRange.numberVal);
						$dialogCont.find(".relativeFromRange").val(fromRange.range);
						$dialogCont.find(".relativeFromDirection").val(fromRange.direction);
						$dialogCont.find(".relativeToNumber").val(toRange.numberVal);
						$dialogCont.find(".relativeToRange").val(toRange.range);
						$dialogCont.find(".relativeToDirection").val(toRange.direction);
					}
				}
				settings.selectCallback($container, $selectedOption, $fromDateInput, $toDateInput, fromRange, toRange);
			});
			$rangeContainer.append($predefinedSelector);
			$dialog.append($rangeContainer);

			var fromDateId = settings.dialogIdPrefix + "_" + settings.id + "_fromDate";
			var toDateId = settings.dialogIdPrefix + "_" + settings.id + "_toDate";
			var $dateContainer = $("<div>", { "class" : "dateContainer"});
			$dateContainer.append($("<label>").text(i18n.message("date.range.selector.dates.label") + ":"));
			if (settings.showRelativeCustomRange) {
				var $customDateRadio = $("<input>", { type: "radio", name: "customSelector", value: "customDate"});
				$dateContainer.append($customDateRadio);
				$customDateRadio.click(function() {
					try {
						setToCustomDate();
						settings.fromDateInputCallback($container, $("#" + fromDateId), $("#" + toDateId));
						settings.toDateInputCallback($container, $("#" + fromDateId), $("#" + toDateId));
					} catch (e) {
						// ignore if empty
					}
				});
				if (!isPredefined) {
					$customDateRadio.click();
				}
			}
			$dateContainer.append($("<span>", { "class" : "labelHeader"}).text(i18n.message("date.range.selector.specific.dates.label") + ": "));
			$dateContainer.append($("<span>", { "class": "labelSpan"}).text(i18n.message("date.range.selector.from.label")));
			$dateContainer.append($("<input>", { id: fromDateId, "class": "fromDate", type: "text", value: !isPredefined && !fromDateIsRange && existingFromDate.length > 0 ? DateParsing.formatDateToString(moment(existingFromDate).toDate(), DateParsing.dateFormat, false) : ""}));
			$dateContainer.append($("<span>", { "class": "labelSpan"}).text(i18n.message("date.range.selector.to.label")));
			$dateContainer.append($("<input>", { id: toDateId, "class": "toDate", type: "text", value: !isPredefined && !toDateIsRange && existingToDate.length > 0 ? DateParsing.formatDateToString(moment(existingToDate).toDate(), DateParsing.dateFormat, false) : ""}));
			$dateContainer.append($("<span class='invalidDateRange'>").html(i18n.message("date.range.selector.invalid.range.warning")));
			$dialog.append($dateContainer);

			var validateFromAndToDates = function() {
				var fromDate = jQueryDatepickerHelper.getDate(fromDateId);
				var toDate = jQueryDatepickerHelper.getDate(toDateId);
				var $invalidCont = $dialog.find(".invalidDateRange");
				if (fromDate != null && toDate != null && fromDate > toDate) {
					$invalidCont.show();
				} else {
					$invalidCont.hide();
				}
			};

			if (settings.showRelativeCustomRange) {

				var setToCustomRelative = function($input) {
					var $dailogCont = $input.closest(".selectorUtilDialog");
					var fromNumber = $dailogCont.find(".relativeFromNumber").val();
					if (!fromNumber || $.trim(fromNumber).length == 0) {
						fromNumber = 0;
					}
					var fromRange = $dailogCont.find(".relativeFromRange").val();
					var fromDirection = $dailogCont.find(".relativeFromDirection").val();

					var toNumber = $dailogCont.find(".relativeToNumber").val();
					if (!toNumber || $.trim(toNumber).length == 0) {
						toNumber = 0;
					}
					var toRange = $dailogCont.find(".relativeToRange").val();
					var toDirection = $dailogCont.find(".relativeToDirection").val();

					var cbQLFrom = null;
					var cbQLTo = null;
					if ($dailogCont.find(".relativeFromCheckbox").is(":checked")) {
						cbQLFrom = fromDirection + fromNumber + fromRange;
					}
					if ($dailogCont.find(".relativeToCheckbox").is(":checked")) {
						cbQLTo = toDirection + toNumber + toRange;
					}

					$container.data("cbQLFrom", cbQLFrom);
					$container.data("cbQLTo", cbQLTo);
					$container.data("fromDate", cbQLFrom);
					$container.data("toDate", cbQLTo);

					$container.data("isoDate", false);

					var isCustomPredefined = false;
					$predefinedSelector.find("option").each(function() {
						if ($(this).data("cbQLFrom") == cbQLFrom && $(this).data("cbQLTo") == cbQLTo) {
							isCustomPredefined = true;
							$(this).prop("selected", true);
							$predefinedSelector.change();
							return false;
						}
					});
					if (!isCustomPredefined) {
						$predefinedSelector.val("custom");
					}
				};

				var drawRelativeCustomRangeControls = function($relativeContainer, cssClassName, $radio, existingRange) {

					var $numberInput = $("<input>", { "class": "relative" + cssClassName + "Number", type: "number", min: 0, step: 1, placeholder: 0 });
					$relativeContainer.append($numberInput);
					$numberInput.on("change click", function() {
						$radio.click();
					});
					var $rangeSelect = $("<select>", { "class": "relative" + cssClassName + "Range"});
					$rangeSelect.append($("<option>", { "value": "d"}).text(i18n.message("date.range.day.label")));
					$rangeSelect.append($("<option>", { "value": "wd"}).text(i18n.message("date.range.workday.label")));
					$rangeSelect.append($("<option>", { "value": "w"}).text(i18n.message("date.range.week.label")));
					$rangeSelect.append($("<option>", { "value": "m"}).text(i18n.message("date.range.month.label")));
					$rangeSelect.append($("<option>", { "value": "q"}).text(i18n.message("date.range.quarter.label")));
					$rangeSelect.append($("<option>", { "value": "y"}).text(i18n.message("date.range.year.label")));
					$relativeContainer.append($rangeSelect);
					$rangeSelect.on("change click", function() {
						$radio.click();
					});
					var $directionSelect = $("<select>", { "class": "relative" + cssClassName + "Direction"});
					$directionSelect.append($("<option>", { "value": "-"}).text(i18n.message("date.range.before.label")));
					$directionSelect.append($("<option>", { "value": "+"}).text(i18n.message("date.range.after.label")));
					$relativeContainer.append($directionSelect);
					$directionSelect.on("change click", function() {
						$radio.click();
					});
					$relativeContainer.append($("<span>").text(i18n.message("date.range.today.label")));
					if (existingRange != null) {
						$relativeContainer.find(".relative" + cssClassName + "Number").val(existingRange.numberVal);
						$relativeContainer.find(".relative" + cssClassName + "Range").val(existingRange.range);
						$relativeContainer.find(".relative" + cssClassName + "Direction").val(existingRange.direction);
						setTimeout(function() {
							$radio.click();
						}, 200);
					}
				};

				var $relativeContainer = $("<div>", { "class" : "relativeContainer"});
				$relativeContainer.append($("<label>"));
				var $customRelativeRadio = $("<input>", { "class": "customRelativeRadio", type: "radio", name: "customSelector", value: "customRelative"});

				$customRelativeRadio.click(function() {
					var $dailogCont = $(this).closest(".selectorUtilDialog");
					setToCustomRelative($(this));
					var $fromDateInput = $dailogCont.find(".fromDate");
					var $toDateInput = $dailogCont.find(".toDate");
					var $selectedOption = $dailogCont.find(".rangeContainer select").find("option:selected");
					var fromRange = null;
					if ($dailogCont.find(".relativeFromCheckbox").is(":checked")) {
						fromRange = parseCustomRelative($container.data("cbQLFrom"));
					}
					var toRange = null;
					if ($dailogCont.find(".relativeToCheckbox").is(":checked")) {
						toRange = parseCustomRelative($container.data("cbQLTo"));
					}
					settings.selectCallback($container, $selectedOption, $fromDateInput, $toDateInput, fromRange, toRange);
				});

				$relativeContainer.append($customRelativeRadio);
				$relativeContainer.append($("<span>", { "class" : "labelHeader"}).text(i18n.message("date.range.selector.relative.ranges.label")));
				var $fromContainer = $("<span>", { "class" : "fromContainer"});
				var $fromInput = $("<input>", { "class" : "relativeFromCheckbox", type: "checkbox", checked: "checked"});
				$fromContainer.append($fromInput);
				$fromContainer.append($("<span>", { "class": "labelSpan"}).text(i18n.message("date.range.selector.from.label")));
				drawRelativeCustomRangeControls($fromContainer, "From", $customRelativeRadio, isPredefined ? parseCustomRelative(existingFromDate) : null);
				$relativeContainer.append($fromContainer);
				var $toContainer = $("<span>", { "class" : "toContainer"});
				var $toInput = $("<input>", { "class" : "relativeToCheckbox", type: "checkbox", checked: "checked"});
				$toContainer.append($toInput);
				$toContainer.append($("<span>", { "class": "labelSpan"}).text(i18n.message("date.range.selector.to.label")));
				drawRelativeCustomRangeControls($toContainer, "To", $customRelativeRadio, isPredefined ? parseCustomRelative(existingToDate) : null);
				$relativeContainer.append($toContainer);
				$dialog.append($relativeContainer);

				$fromInput.change(function() {
					relativeCheckboxHandler($(this), $(this).closest(".fromContainer"));
					$customRelativeRadio.click();
				});
				if (!existingFromDate || existingFromDate.length == 0) {
					$fromInput.prop("checked", false);
					$fromInput.trigger("change");
				}

				$toInput.change(function() {
					relativeCheckboxHandler($(this), $(this).closest(".toContainer"));
					$customRelativeRadio.click();
				});
				if (!existingToDate || existingToDate.length == 0) {
					$toInput.prop("checked", false);
					$toInput.trigger("change");
				}
			}

			settings.appendDialogTo.append($dialog);

			validateFromAndToDates();

			settings.afterCreateCallback($dialog);

			$("#" + fromDateId).click(function() {
				jQueryDatepickerHelper.initCalendar(fromDateId, toDateId, '', false);
				if (settings.showRelativeCustomRange) {
					$customDateRadio.click();
				}
			});
			$("#" + toDateId).click(function() {
				jQueryDatepickerHelper.initCalendar(toDateId, fromDateId, '', false);
				if (settings.showRelativeCustomRange) {
					$customDateRadio.click();
				}
			});

			var getISODate = function(date) {
				return $.datepicker.formatDate("yy-mm-dd", date);
			};

			var setToCustomDate = function() {
				$predefinedSelector.change();
				$predefinedSelector.val("custom");
				if ($("#" + fromDateId).val().length == 0) {
					$container.data("fromDateISO", null);
					$container.data("fromDate", null);
				} else {
					var fromIsoDate = getISODate(jQueryDatepickerHelper.getDate(fromDateId, toDateId));
					$container.data("fromDateISO", fromIsoDate);
					$container.data("fromDate", fromIsoDate);
				}
				$container.data("cbQLFrom", null);
				if ($("#" + toDateId).val().length == 0) {
					$container.data("toDateISO", null);
					$container.data("toDate", null);
				} else {
					var toIsoDate = getISODate(jQueryDatepickerHelper.getDate(toDateId, fromDateId));
					$container.data("toDateISO", toIsoDate);
					$container.data("toDate", toIsoDate);
				}
				$container.data("cbQLTo", null);
				$container.data("isoDate", true);
			};

			$("#" + fromDateId).click(function() {
				setToCustomDate();
				settings.fromDateInputCallback($container, $(this), $("#" + toDateId));
			});
			$("#" + toDateId).click(function() {
				setToCustomDate();
				settings.toDateInputCallback($container, $("#" + fromDateId), $(this));
			});
			$("#" + fromDateId).change(function() {
				setToCustomDate();
				settings.fromDateInputCallback($container, $(this), $("#" + toDateId));
				validateFromAndToDates();
			});
			$("#" + toDateId).change(function() {
				setToCustomDate();
				settings.toDateInputCallback($container, $("#" + fromDateId), $(this));
				validateFromAndToDates();
			});
			if (!isPredefined) {
				setToCustomDate();
				settings.fromDateInputCallback($container, $("#" + fromDateId), $("#" + toDateId));
				settings.toDateInputCallback($container, $("#" + fromDateId), $("#" + toDateId));
			}

			var fillOutPredefinedSelector = function($predefinedSelector) {
				var $customOption = $("<option>", { value: "custom" }).text(i18n.message("date.range.selector.custom.label"));
				$predefinedSelector.append($customOption);
				if (!isPredefined) {
					$customOption.prop("selected", true);
				}
				for (var i=0; i < dateRangeCache.length; i++) {
					var group = dateRangeCache[i];
					var $optGroup = $("<optgroup>", { "label" : group.label && group.label.length > 0 ? group.label : group.name });
					for (var j=0; j < group.dateRanges.length; j++) {
						var range = group.dateRanges[j];
						var $option = $("<option>");
						$option.text(range.label && range.label.length > 0 ? range.label : range.name);
						for (property in range) {
							$option.data(property, range[property]);
						}
						if (isPredefined && existingFromDate == range.cbQLFrom && existingToDate == range.cbQLTo) {
							$option.prop("selected", true);
						}
						$optGroup.append($option);
					}
					$predefinedSelector.append($optGroup);
					if (isPredefined) {
						$predefinedSelector.change();
					}
				}
			};

			if (dateRangeCache.length == 0) {
				$.getJSON(settings.getPredefinedRangesUrl).done(function(result) {
					dateRangeCache = result;
					fillOutPredefinedSelector($predefinedSelector);
				}).fail(function() {
					alert("Unable to load predefined date ranges.");
				});
			} else {
				fillOutPredefinedSelector($predefinedSelector);
			}
		}

		function initEvents($container) {

			$container.click(function(e) {
				e.stopPropagation();
				$("." + settings.defaultDialogClass + ":not([data-uniqueid='" + settings.id + "'])").hide();
				var $dialog = $('#' + settings.dialogIdPrefix + '_' + settings.id);
				$dialog.toggle();
				fixSelectorDialogPosition($container.attr("id"), settings.dialogIdPrefix + '_' + settings.id);
				if (codebeamer && codebeamer.ReportSupport) {
					codebeamer.ReportSupport.hideOtherMenus(settings.id);
				}
			});

			$("html").click(function(e) {
				// If datepicker is visible, do not close the dialog
				if ($(".xdsoft_datetimepicker").is(":visible")) {
					return;
				}
				$("." + settings.defaultDialogClass).each(function() {
					if ($(this).is(":visible")) {
						$(this).hide();
					}
				});
			});

			if (settings.forceOpen) {
				setTimeout(function() {
					$container.click();
				}, 200);
			}

		}

		function init($container) {
			if (settings.id === null) {
				settings.id = "selectorUtilUnique_" + nextSelectorUtilUniqueId;
				nextSelectorUtilUniqueId++;
			}
			drawDialog($container);
			initEvents($container);
		}

		return this.each(function() {
			init($(this));
		});

	};

	$.fn.dateRangeSelector.defaults = {
		id : null, // should represent a unique ID, e.g. fieldId
		fieldName : "",
		fieldLabel : "",
		existingFromDate: "",
		existingToDate: "",
		customFieldTrackerId: "",
		forceOpen : false,
		appendDialogTo: $('body'),
		getPredefinedRangesUrl : contextPath + 	"/ajax/date/getPredefinedDateRanges.spr",
		getLocaleDataUrl: contextPath + "/ajax/date/getLocaleData.spr",
		dialogIdPrefix : "dateRangeSelectorDialog",
		defaultDialogClass : "selectorUtilDialog",
		dialogClasses : "",
		showRelativeCustomRange : false,
		selectCallback: function() {},
		fromDateInputCallback : function() {},
		toDateInputCallback: function() {},
		afterCreateCallback: function() {}
	};


	// jQuery plugin for Project Selector

	$.fn.projectSelector = function() {

		function init() {

		}

		return this.each(function() {
			init($(this));
		});

	};


	// jQuery plugin for Tracker Selector

	$.fn.trackerSelector = function($projectSelectorContainer) {

		function init($container, $projectSelectorContainer) {

		}

		return this.each(function() {
			init($(this), $projectSelectorContainer);
		});

	};

})(jQuery);

var codebeamer = codebeamer || {};
codebeamer.SelectorUtils = codebeamer.SelectorUtils || (function($) {

	var truncateText = function(text, numberOfChars) {
		numberOfChars = numberOfChars || 100;
		if (text.length > numberOfChars) {
			return (text.substring(0, numberOfChars) + "...");
		}
		return text;
	};

	var initTrackerSelector = function($container, config) {
		$container.multiselect({
			"classes" : "trackerSelectorTag",
			checkAllText : "",
			uncheckAllText: "",
			multiple: config.multiple,
			"selectedText": function(numChecked, numTotal, checked) {
				var value = [];
				$(checked).each(function(){
					value.push($(this).next().html());
				});
				return truncateText(value.join(", "));
			},
			open: function() {
				var $widget = $(this).multiselect("widget");
				setTimeout(function() {
					$widget.find(".ui-multiselect-filter input").focus();
				}, 100);
			},
			create: function() {
				$container.trigger("codebeamer:multiselectcreate");
			}
		}).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});

		var data = {
			"project_id_list" : config.projectId
		};
		if (config.filterTrackerIds != null && config.filterTrackerIds !== "null") {
			data["filter_tracker_id_list"] = config.filterTrackerIds;
		}

		if (config.listBranchesOnTopLevel) {
			data['list_branches_on_top_level'] = config.listBranchesOnTopLevel;
		}

		if (config.onlyFilteredTrackers) {
			data['onlyFilteredTrackers'] = config.onlyFilteredTrackers;
		}

		if (config.listBranchesOnTopLevel) {
			data['list_branches_on_top_level'] = config.listBranchesOnTopLevel;
		}

		$.getJSON(contextPath + "/ajax/queryCondition/getTrackers.spr", data).done(function(result) {
			for (var i=0; i < result.length; i++) {
				var project = result[i];
				var $projectGroup = $("<optgroup>", { label: i18n.message("project.label") + ": " + truncateText(project.name) });
				var trackers = project.trackers;

				for (var j=0; j < trackers.length; j++) {
					var tracker = trackers[j];
					if (!tracker.hidden || tracker.forceDisplay) {
						if (config.notAllowedTypes == null || ($.inArray(tracker.type, config.notAllowedTypes) == -1)) {
							var optionProperties = { value : tracker.id, "data-hidden":  tracker.hidden };
							if (tracker.hasOwnProperty("isBranch") && tracker.isBranch) {
								var clazz = "branchTracker ";

								if (config.listBranchesOnTopLevel) {
									clazz += " top-level ";
								}

								if (tracker.hasOwnProperty("level")) {
									var level = tracker["level"];
									level = Math.min(level, 6); // maximum six depth of levels is supported in the list.
									clazz += "level-" + level;
								}

								optionProperties["class"] = clazz;
								optionProperties["data-tracker-id"] = tracker["trackerId"];

							}

							if (config.selectedValue && config.selectedValue == tracker.id) {
								optionProperties['selected'] = 'selected';
							}

							var truncatedTrackerName = truncateText(tracker.name);
							optionProperties['title'] = truncatedTrackerName;

							var $option = $("<option>", optionProperties).text(truncatedTrackerName);
							$projectGroup.append($option);
						}
					}
				}
				$container.append($projectGroup);
			}
			$container.multiselect("refresh");
			if (config.callbackFunctionName) {
				executeFunctionByName(config.callbackFunctionName, window);
			}
		});
	};

	return {
		"initTrackerSelector" : initTrackerSelector
	};

})(jQuery);