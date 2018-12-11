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
codebeamer.ReportSupport = codebeamer.ReportSupport || (function($) {

	// Extend array if we support other attributes in the future!
	var SUPPORTED_ATTRIBUTES = [
		"project.id",
		"tracker.id",
		"item.id",
		"accruedTime",
		"category",
		"owner",
		"submittedAt",
		"modifiedAt",
		"modifiedBy",
		"startDate",
		"endDate",
		"assignedTo",
		"assignedAt",
		"detectedIn",
		"hasIncomingReference",
		"hasDownstreamReference",
		"hasOutgoingReference",
		"hasUpstreamReference",
		"hasReview",
		"underReview",
		"priority",
		"referenceToTracker",
		"referenceToId",
		"referenceFromTracker",
		"referenceFromId",
		"ReleaseID",
		"resolution",
		"severity",
		"status",
		"submittedBy",
		"summary",
		"workItemStatus",
		"workItemResolution",
		"spentEstimatedTime",
		"spentTime",
		"estimatedTime",
		"SubjectID",
		"TeamID",
		"parentId",
		"childId",
		"storyPoints",
		"platformId",
		"description",
		"type",
		"hasIncomingSuspectedLink",
		"hasDownstreamSuspectedLink",
		"hasOutgoingSuspectedLink",
		"hasUpstreamSuspectedLink",
		"hasSuspectedLink",
		"PlatformID",
		"closedAt",
		"projectTag",
		"trackerTag",
		"trackerItemTag",
		"releaseTag"
	];

	var DEFAULT_TRUNCATE_CHARS = 60;

	var MAXIMUM_RESIZEABLE_FIELD_NUMBER = 18;

	var booleanLabelValueMap = {
		"true" : i18n.message("boolean.true.label"),
		"false" : i18n.message("boolean.false.label")
	};

	var numberTypeMap = {
		">" : i18n.message("query.widget.greater.than.label"),
		">=" : i18n.message("query.widget.greater.than.equals.label"),
		"=" : i18n.message("query.widget.equals.label"),
		"<=" : i18n.message("query.widget.less.than.equals.label"),
		"<" : i18n.message("query.widget.less.than.label")
	};

	var notNumberOperators = {
		">" : "<=",
		">=" : "<",
		"="	: "!=",
		"<=" : ">",
		"<"	: ">="
	};

	var durationTimeMap = {
		"h" : i18n.message("query.widget.hours.label"),
		"min" : i18n.message("query.widget.minutes.label"),
		"s" : i18n.message("query.widget.seconds.label")
	};

	var customDateRangeMap = {
		"-" : i18n.message("date.range.before.label"),
		"+" : i18n.message("date.range.after.label"),
		"d" : i18n.message("date.range.day.label"),
		"wd" : i18n.message("date.range.workday.label"),
		"w" : i18n.message("date.range.week.label"),
		"m" : i18n.message("date.range.month.label"),
		"q" : i18n.message("date.range.quarter.label"),
		"y" : i18n.message("date.range.year.label")
	};

	var truncateValues = {
		"TO_DAY" : i18n.message("date.range.group.Day.label"),
		"TO_WEEK" : i18n.message("date.range.group.Week.label"),
		"TO_MONTH" : i18n.message("date.range.group.Month.label"),
		"TO_QUARTER" : i18n.message("date.range.group.Quarter.label"),
		"TO_YEAR" : i18n.message("date.range.group.Year.label")
	};
	var truncateValueArray = ["TO_DAY", "TO_WEEK", "TO_MONTH", "TO_QUARTER", "TO_YEAR"];

	var aggregateValues = {
		"none" : "NONE",
		"sum" : "SUM",
		"avg" : "AVG",
		"min" : "MIN",
		"max" : "MAX"
	};


	function startsWith(string, prefix) {
		return string.slice(0, prefix.length) == prefix;
	}

	function endsWith(str, suffix) {
		return str.indexOf(suffix, str.length - suffix.length) !== -1;
	}

	var startsWithNumber = function(value) {
		return !isNaN(parseInt(value[0], 10));
	};

	var truncateText = function(text, numberOfChars) {
		numberOfChars = numberOfChars || DEFAULT_TRUNCATE_CHARS;
		if (text.length > numberOfChars) {
			return (text.substring(0, numberOfChars) + "...");
		}
		return text;
	};

	var removeApostrophes = function(value) {
		value = value.toString();
		if (value.lastIndexOf("\'", 0) === 0) {
			value = value.substring(1, value.length - 1);
		}
		return value;
	};

	var getCbQLFunction = function(values) {
		if (!values) {
			return null;
		}
		var cbQLFunction = values[0].cbQLFunction;
		if (cbQLFunction) {
			return cbQLFunction;
		}
		return null;
	};


	var getParamFromUrl = function(url, param) {
		var tempArray = url.split("?");
		if (tempArray[1]) { // check for url without query string -> /cb/query/73203
			var paramsURL = tempArray[1];
			tempArray = paramsURL.split("&");
			for (i=0; i<tempArray.length; i++) {
				var index = tempArray[i].indexOf("=");
				if (index != -1) {
					var paramName = tempArray[i].substring(0, index);
					if(paramName == param) {
						var paramValue = tempArray[i].substring(index + 1);
						return paramValue;
					}
				}
			}
		}
		return "";
	};

	var addToRecentFields = function(containerId, fieldObject) {
		var $filterSelector = $("#filterSelector_" + containerId);
		var $recentGroup = $filterSelector.find("optgroup.recentFilters");
		$recentGroup.find("option[value='" + (fieldObject.customField ? (fieldObject.trackerId + "_" + fieldObject.id) : fieldObject.id) + "']").remove();
		$recentGroup.prepend($("<option>", { "class" : "recentFilter", value: (fieldObject.customField ? (fieldObject.trackerId + "_" + fieldObject.id) : fieldObject.id) }).text(fieldObject.label));
		var $recentFilters = $filterSelector.find("optgroup.recentFilters").find("option");
		if ($recentFilters.length > 5) {
			$recentFilters.last().remove();
		}
		$filterSelector.multiselect("refresh");
	};

	var storeRecentField = function(containerId, fieldObject) {
		addToRecentFields(containerId, fieldObject);
		$.post(contextPath + "/ajax/queryCondition/storeRecentFilter.spr", { fieldId: fieldObject.customField ? (fieldObject.trackerId + "_" + fieldObject.id) : fieldObject.id });
	};

	var hideOtherMenus = function(uniqueId) {
		$('div.queryConditionSelector:not([data-uniqueId="' + uniqueId + '"])').hide();
	};

	var renderField = function(containerId, fieldObject, forceOpen, values) {

		if (fieldObject.id === 0) {
			return; // do not render ID field
		}

		if (!fieldObject.customField && fieldObject.fieldTypeName != "text" &&
			($.inArray(fieldObject.cbQLAttributeName, SUPPORTED_ATTRIBUTES) == -1 &&
			$.inArray(fieldObject.cbQLIdAttributeName, SUPPORTED_ATTRIBUTES) == -1)) {
			throw i18n.message("query.widget.unsupported.attribute", fieldObject.cbQLAttributeName);
		}

		var fieldTypeName = fieldObject.fieldTypeName;
		if (fieldObject.cbQLAttributeName == "type") {
			// Do not render type
			//renderChoiceField(containerId, fieldObject, forceOpen, values); TODO
		} else if (fieldObject.id == -7 || fieldObject.id == -29) {
			var value = values == null ? "true" : removeApostrophes(values[0].right.value);
			renderBooleanField(containerId, i18n.message("query.widget.hasIncomingRelation.label"), "hasDownstreamReference", value, getCbQLFunction(values), forceOpen, true, fieldObject);
		} else if (fieldObject.id == -6 || fieldObject.id == -28) {
			var value = values == null ? "true" : removeApostrophes(values[0].right.value);
			renderBooleanField(containerId, i18n.message("query.widget.hasOutgoingRelation.label"), "hasUpstreamReference", value, getCbQLFunction(values), forceOpen, true, fieldObject);
		} else if (fieldObject.cbQLAttributeName == "hasReview") {
			var value = values == null ? "true" : removeApostrophes(values[0].right.value);
			renderBooleanField(containerId, i18n.message("tracker.field.hasReview.label"), "hasReview", value, null, forceOpen, false, fieldObject);
		} else if (fieldObject.cbQLAttributeName == "underReview") {
			var value = values == null ? "true" : removeApostrophes(values[0].right.value);
			renderBooleanField(containerId, i18n.message("tracker.field.underReview.label"), "underReview", value, null, forceOpen, false, fieldObject);
		} else if (fieldObject.id == -25 || fieldObject.id == -26 || fieldObject.id == -27 || fieldObject.id == -30 || fieldObject.id == -31) {
			var value = values == null ? "true" : removeApostrophes(values[0].right.value);
			var label = fieldObject.id == -25 || fieldObject.id == -30 ? i18n.message("tracker.field.hasOutgoingSuspectedLink.label") :
				(fieldObject.id == -26 || fieldObject.id == -31 ? i18n.message("tracker.field.hasIncomingSuspectedLink.label") : i18n.message("tracker.field.hasSuspectedLink.label"));
			var cbQLAttrName = fieldObject.id == -25 || fieldObject.id == -30 ? "hasUpstreamSuspectedLink" :
				(fieldObject.id == -26 || fieldObject.id == -31 ? "hasDownstreamSuspectedLink" : "hasSuspectedLink");
			renderBooleanField(containerId, label, cbQLAttrName, value, getCbQLFunction(values), forceOpen, false, fieldObject);
		} else if (fieldObject.id == -17 || fieldObject.id == -18 || fieldObject.id == -19 || fieldObject.id == -33) {
			var value = values == null ? [] : values[0].right.value;
			renderTagField(containerId, fieldObject, forceOpen, value, values == null ? "IN" : values[0].operator.toUpperCase());
		} else {
			switch (fieldTypeName) {
				case "member" :
					renderMemberField(containerId, fieldObject, forceOpen, values);
					break;
				case "choice" :
					renderChoiceField(containerId, fieldObject, forceOpen, values);
					break;
				case "reference" :
					if (values && values.length == 1 && values[0].hasOwnProperty("cbQLFunction") && !values[0].hasOwnProperty("left")) {
						renderReferenceField(containerId, fieldObject, forceOpen, null, values[0].cbQLFunction);
					} else {
						renderReferenceField(containerId, fieldObject, forceOpen, values, getCbQLFunction(values));
					}
					break;
				case "date" :
					renderDateField(containerId, fieldObject, forceOpen, values);
					break;
				case "text" :
					renderTextField(containerId, fieldObject, forceOpen, values);
					break;
				case "number" :
					renderNumberField(containerId, fieldObject, forceOpen, values);
					break;
				case "duration" :
					renderDurationField(containerId, fieldObject, forceOpen, values);
					break;
				case "boolean" :
					var value = values == null ? "true" : removeApostrophes(values[0].right.value);
					renderBooleanField(containerId, fieldObject.label, fieldObject.cbQLAttributeName, value, null, forceOpen, false, fieldObject);
					break;
				case "color" :
					renderColorField(containerId, fieldObject, forceOpen, values);
					break;
				case "url" :
					renderTextField(containerId, fieldObject, forceOpen, values, true);
					break;
			}
		}

		if (forceOpen) {
			storeRecentField(containerId, fieldObject);
		}

		if (configByInstance[containerId]["logicEnabled"] && forceOpen) {
			validateLogicString(containerId);
		}
	};

	var normalizeValues = function(values, fieldTypeName) {
		var normalizedValues = [];
		if (values) {
			for (var i=0; i < values.length; i++) {
				if (values[i] && values[i].value) {
					var value = removeApostrophes(values[i].value);
					if (fieldTypeName == "member" && value == "'current user'") {
						value = -1;
					}
					normalizedValues.push(value);
				}
			}
		}
		return normalizedValues;
	};

	// User type fields
	var renderMemberField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var isNot = false;
		var allValues = [];
		var isIndirect = false;
		if (values && values.length > 0) {
			for (var i = 0; i < values.length; i++) {
				var value = values[i];
				if (value.operator == "IN" || value.operator == "NOT IN") {
					var valueArray = value.right.value;
					for (var j = 0; j < valueArray.length; j++) {
						var valueArrayValue = valueArray[j].value;
						if (valueArrayValue == "'current user'") {
							allValues.push(-1);
						} else {
							var normalizedValue = removeApostrophes(valueArrayValue);
							if (endsWith(value.left.value, "Role") || value.left.value.indexOf("roleList") > -1) {
								allValues.push("role_" + normalizedValue);
							} else {
								allValues.push("user_" + normalizedValue);
							}
						}
					}
					if (value.left.value == "assignedToIndirect") {
						isIndirect = true;
					}
				}
				if (value.operator == "=" || value.operator == "!=") {
					var normalizedValue = removeApostrophes(value.right.value);
					if (endsWith(value.left.value, "Role")) {
						allValues.push("role_" + normalizedValue);
					} else {
						allValues.push("user_" + normalizedValue);
					}
					if (value.left.value == "assignedToIndirect") {
						isIndirect = true;
					}
				}
				if (value.operator == "NOT IN" || value.operator == "!=") {
					isNot = true;
				}
			}
		}

		var $selector = $("<select>", { "class" : "selector userSelector", multiple : "multiple"});
		$selector.data("fieldObject", fieldObject);
		if (isIndirect) {
			$selector.data("indirectUser", true);
		}
		config.container.find(".addButton").before($selector);
		$selector.hide();

		var isEmpty = false;
		if (values && (values.length == 1 || (values.length > 0 && fieldObject.customField && fieldObject.cbQLRoleAttributeName != null))) {
			if (values[0].operator.toUpperCase() == "IS NULL") {
				isEmpty = true;
			}
			if (values[0].operator.toUpperCase() == "IS NOT NULL") {
				isEmpty = true;
				isNot = true;
			}
		}

		getUserChoicesJSON(containerId, function(result) {
			$selector.show();
			renderUsers(result, $selector);
			initMultiSelect(containerId, $selector, null, isNot, isEmpty, true, fieldObject.id == 5, null, true);
			var valuesLength = 0;
			if (allValues.length > 0) {
				checkSelectedValues($selector, allValues, true);
				valuesLength += allValues.length;
			}
			if (valuesLength == 0) {
				checkFirstOption($selector);
			}

			if (isIndirect) {
				$selector.multiselect("getButton").data("indirectUser", true);
				$selector.multiselect("getButton").find(".labelValueIndirectUser").show();
				$selector.multiselect("widget").find(".indirectUserBadge").addClass("active").data("indirectUser", true);
			}

			if (forceOpen) {
				$selector.multiselect("getButton").click();
			}
		});
	};

	var renderSpecialChoiceField = function(containerId, name, label, values, forceOpen) {
		var config = configByInstance[containerId];
		var $selector = $("<select>", { "class" : "selector specialChoiceFieldSelector " + name, multiple : "multiple"});
		$selector.data("fieldObject", {
			label: label
		});
		$selector.append($("<option>", { value: 0, "class": "anyValue" }).text(i18n.message("tracker.field.value.any")));
		if (name == "documentViewRating") {
			$selector.append($("<option>", { value: "from1to15"}).text("1 - 1.5"));
			$selector.append($("<option>", { value: "from15to25"}).text("1.5 - 2.5"));
			$selector.append($("<option>", { value: "from25to35"}).text("2.5 - 3.5"));
			$selector.append($("<option>", { value: "from35to45"}).text("3.5 - 4.5"));
			$selector.append($("<option>", { value: "from45to5"}).text("4.5 - 5"));
			$selector.append($("<option>", { value: "noRating"}).text(i18n.message("tracker.view.layout.document.filter.no.rating.label")));
			$selector.append($("<option>", { value: "ratedByMe"}).text(i18n.message("tracker.view.layout.document.filter.rated.by.me.label")));
			$selector.append($("<option>", { value: "notRatedByMe"}).text(i18n.message("tracker.view.layout.document.filter.not.rated.by.me.label")));
		} else if (name == "documentViewReference") {
			$selector.append($("<option>", { value: "Orphan"}).text(i18n.message("tracker.view.layout.document.filter.references.orphan.label")));
			$selector.append($("<option>", { value: "Specified"}).text(i18n.message("tracker.view.layout.document.filter.references.specified.label")));
		} else if (name == "documentViewBranchStatus") {
			$selector.append($("<option>", { value: "UpdatedOnBranch"}).text(i18n.message("tracker.branching.item.diverged.from.master.label")));
			$selector.append($("<option>", { value: "UpdatedOnMaster"}).text(i18n.message("tracker.branching.master.diverged.from.branch.label")));
			$selector.append($("<option>", { value: "CreatedOnBranch"}).text(i18n.message("tracker.branching.item.crested.on.branch.label")));
			$selector.append($("<option>", { value: "DeletedOnBranch"}).text(i18n.message("tracker.branching.item.deleted.on.branch.label")));

		}
		config.container.find(".addButton").before($selector);
		$selector.hide();
		initMultiSelect(containerId, $selector, null);
		if (values != null) {
			var valueArray = values.split(",");
			checkSelectedValues($selector, valueArray);
		} else {
			checkFirstOption($selector);
		}
		if (forceOpen) {
			$selector.multiselect("getButton").click();
		}
	};

	// Choice type fields
	var renderChoiceField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var isCountry = fieldObject.inputType == 9;
		var isLanguage = fieldObject.inputType == 8;

		if (values && values.length == 1) {
			var node = values[0];
			if (node.left.value == "workItemStatus") {
				var nodeValues = node.right.value;
				if (nodeValues.length === 1 && removeApostrophes(nodeValues[0]["value"]) == "HasUnresolvedDependency") {
					renderBooleanField(containerId, i18n.message("query.widget.hasUnresolvedDependency.label"), "hasUnresolvedDependency", node.operator == "IN" ? "true" : "false");
					return;
				}
			}
		}

		var isNot = false;
		var allValues = [];
		if (values && values.length > 0) {
			for (var i = 0; i < values.length; i++) {
				var value = values[i];
				if (value.operator == "IN" || value.operator == "NOT IN") {
					var valueArray = value.right.value;
					if (startsWithNumber(removeApostrophes(value.left.value))) {
						var options = value.right.value;
						for (var k = 0; k < options.length; k++) {
							var option = (isCountry || isLanguage) ? options[k].value : removeApostrophes(options[k].value);
							if (isCountry || isLanguage) {
								allValues.push(option);
							} else if (fieldObject.customField) {
								allValues.push(fieldObject.projectId + "_" + fieldObject.trackerId + "_" + option);
							} else {
								var fieldValue = removeApostrophes(value.left.value).split(".");
								var projectId = fieldValue[0];
								var trackerId = fieldValue[1];
								allValues.push(projectId + "_" + trackerId + "_" + option);
							}
						}
					} else {
						for (var j = 0; j < valueArray.length; j++) {
							var valueArrayValue = valueArray[j].value;
							allValues.push((isCountry || isLanguage) ? valueArrayValue : removeApostrophes(valueArrayValue));
						}
					}
				} else if (value.operator == "=" || value.operator == "!=") {
					var option = removeApostrophes(value.right.value);
					if (fieldObject.customField) {
						allValues.push(fieldObject.projectId + "_" + fieldObject.trackerId + "_" + option);
					} else {
						var fieldValue = removeApostrophes(value.left.value).split(".");
						var projectId = fieldValue[0];
						var trackerId = fieldValue[1];
						allValues.push(projectId + "_" + trackerId + "_" + option);
					}
				}
				if (value.operator == "NOT IN" || value.operator == "!=") {
					isNot = true;
				}
			}
		}

		var $selector = $("<select>", { "class" : "selector choiceFieldSelector", multiple : "multiple"});
		$selector.data("fieldObject", fieldObject);
		config.container.find(".addButton").before($selector);
		$selector.hide();

		var isEmpty = false;

		if (values && values.length == 1) {
			if (values[0].operator.toUpperCase() == "IS NULL") {
				isEmpty = true;
			}
			if (values[0].operator.toUpperCase() == "IS NOT NULL") {
				isEmpty = true;
				isNot = true;
			}
		}

		var customFieldTrackerId = fieldObject.customField ? fieldObject.trackerId : null;
		getFieldChoicesJSON(containerId, fieldObject.id, isCountry ? "true" : "false", isLanguage ? "true" : "false", customFieldTrackerId, function(result) {
			$selector.show();
			renderFieldChoices(result, $selector);
			initMultiSelect(containerId, $selector, null, isNot, isEmpty, false, false, null, true);
			$selector.data("isCountry", isCountry ? "true" : "false");
			$selector.data("isLanguage", isLanguage ? "true" : "false");
			var valuesLength = 0;
			if (allValues.length > 0) {
				var fixedExistingValues = [];
				checkSelectedValues($selector, allValues);
				valuesLength += values.length;
			}
			if (valuesLength == 0) {
				checkFirstOption($selector);
			}
			if (forceOpen) {
				$selector.multiselect("getButton").click();
			}
		});
	};

	// Include overlay
	var renderIncludePart = function(containerId, forceOpen, existingValue, existingValueIsReport) {
		var config = configByInstance[containerId];
		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));

		var $include = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector includePart" });
		$include.attr("data-uniqueId", uniqueId);
		$include.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $includeLabel = $("<span>").html("<b>" + i18n.message("queries.include.label") + "</b>:");
		$include.append($includeLabel);
		$include.append($("<span>", { "class": "labelValue"}).text(" -"));
		config.container.find(".addButton").before($include);

		addDeleteButton(containerId, $include, uniqueId);
		addFilterCounter(containerId, $include);

		var refreshIncludePart = function($dialog) {
			var referencesString = " -";
			var isReport = $dialog.find(".collapsingBorder.report").hasClass("collapsingBorder_expanded");
			var span = isReport ? "reportSpan" : "referenceSpan";
			$dialog.find("." + span + " ul li.token-input-token-facebook").each(function() {
				referencesString = ($(this).find("p").text());
			});
			var value = $dialog.find('.' + span + ' input[type="hidden"]').val();
			var decodedReferenceValues = decodeReferences(value);
			$include.data("id", decodedReferenceValues.length > 0 ? decodedReferenceValues[0] : null);
			$include.data("isReport", isReport);
			$include.find(".labelValue").text(" " + referencesString);
			$dialog.dialog("close");
		};

		var loadDialog = function(existingData) {

			if (config.reportPage || forceOpen) {
				if (ajaxBusyIndicator.dialog != null) {
					var busy = ajaxBusyIndicator.showBusyPage();
				}
			}

			var $dialog = $("<div>", { "class": "referenceDialog includeDialog", "data-uniqueId" : uniqueId });

			var $collapsingBorderCont1 = $("<fieldset>", { "class" : "collapsingBorder report separatorLikeCollapsingBorder " + (!existingData || (existingData && existingData.hasOwnProperty("report")) ? "collapsingBorder_expanded" : "collapsingBorder_collapsed") });
			var $collapsingBorderLegend1 = $("<legend>", { "class" : "collapsingBorder_legend report"});
			$collapsingBorderLegend1.append($("<a>", { "href" : "#", "class" : "collapseToggle", "onclick" : "CollapsingBorder.toggle(this, null);CollapsingBorder.toggle('.collapsingBorder_legend.workItem a', null);return false;"}).text(i18n.message("queries.include.report.label")));
			$collapsingBorderCont1.append($collapsingBorderLegend1);
			var $collapsingBorderContent1 = $("<div>", { "class" : "collapsingBorder_content"});

			var $reportSpan = $("<span>", { "class" : "reportSpan", "data-uniqueId": uniqueId});
			$dialog.append($reportSpan);
			$reportSpan.referenceField(existingData && existingData.hasOwnProperty("report") ? [existingData.report] : [], {
				reportMode: true,
				multiple: false
			});
			setTimeout(function() {
				$reportSpan.referenceFieldAutoComplete();
				if (!forceOpen && existingData.hasOwnProperty("report")) {
					refreshIncludePart($dialog, uniqueId);
				}
			}, 300);

			$collapsingBorderContent1.append($reportSpan);
			$collapsingBorderCont1.append($collapsingBorderContent1);
			$dialog.append($collapsingBorderCont1);

			var $collapsingBorderCont2 = $("<fieldset>", { "class" : "collapsingBorder workItem separatorLikeCollapsingBorder " + (existingData && existingData.hasOwnProperty("trackerItem") ? "collapsingBorder_expanded" : "collapsingBorder_collapsed") });
			var $collapsingBorderLegend2 = $("<legend>", { "class" : "collapsingBorder_legend workItem"});
			$collapsingBorderLegend2.append($("<a>", { "href" : "#", "class" : "collapseToggle", "onclick" : "CollapsingBorder.toggle(this, null);CollapsingBorder.toggle('.collapsingBorder_legend.report a', null);return false;"}).text(i18n.message("queries.include.from.work.item.label")));
			$collapsingBorderCont2.append($collapsingBorderLegend2);
			var $collapsingBorderContent2 = $("<div>", { "class" : "collapsingBorder_content"});

			var $selector = $("<select>", { "class" : "selector referenceProjectSelector", multiple : "multiple", "data-uniqueId": uniqueId});
			var $trackerSelector = $("<select>", { "class" : "selector referenceTrackerSelector", multiple : "multiple", "data-uniqueId" : uniqueId});

			$collapsingBorderContent2.append($("<div>", { class: "referenceStep"}).html(i18n.message("Project") + ":"));

			$.getJSON(contextPath + "/ajax/queryCondition/getProjects.spr").done(function(result) {
				var recent = result.recent;
				var all = result.all;
				var $recentGroup = $("<optgroup>", { label: i18n.message("recent.projects.label") });
				for (var i=0; i < recent.length; i++) {
					var project = recent[i];
					$recentGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
				}
				$selector.append($recentGroup);
				var $allGroup = $("<optgroup>", { label: i18n.message("my.open.issues.all.projects") });
				for (var i=0; i < all.length; i++) {
					var project = all[i];
					$allGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
				}
				$selector.append($allGroup);
				$collapsingBorderContent2.append($selector);
				initMultiSelect(containerId, $selector, { label: i18n.message("project.label") }, false, false, false, false, $dialog.closest(".ui-dialog"));
				$selector.attr("data-uniqueId", uniqueId);

				if (existingData && existingData.hasOwnProperty("trackerItem")) {
					checkSelectedValues($selector, [existingData.trackerItem.projectId]);
				} else {
					checkFirstOption($selector);
				}
				$selector.change(function() {
					reloadTrackerSelectorIfProjectChange(uniqueId);
				});

				$collapsingBorderContent2.append($("<div>", { class: "referenceStep"}).html(i18n.message("Tracker") + ":"));
				var existingProjectIds = existingData && existingData.hasOwnProperty("trackerItem") ? [existingData.trackerItem.projectId] : $selector.val();
				var getTrackersData = {
					project_id_list: existingProjectIds.join(",")
				};
				var $trackerLoading = $("<img>", { "class" : "referenceTrackerAjaxLoading", src : contextPath + "/images/ajax-loading_16.gif"});
				$collapsingBorderContent2.append($trackerLoading);
				$.getJSON(contextPath + "/ajax/queryCondition/getTrackers.spr", getTrackersData).done(function(trackerResult) {
					renderTrackers(trackerResult, $trackerSelector, true);
					$trackerLoading.before($trackerSelector);
					$trackerLoading.hide();
					initMultiSelect(containerId, $trackerSelector, { label: i18n.message("tracker.label") }, false, false, false, false, $dialog.closest(".ui-dialog"));
					$trackerSelector.attr("data-uniqueId", uniqueId);
					if (existingData && existingData.hasOwnProperty("trackerItem")) {
						checkSelectedValues($trackerSelector, [existingData.trackerItem.trackerId]);
					} else {
						checkFirstOption($trackerSelector);
					}

					$trackerSelector.change(function() {
						initAutoComplete($dialog, uniqueId, [], refreshIncludePart, true);
					});

					$collapsingBorderContent2.append($("<div>", { class: "referenceStep lastReferenceStep"}).html(i18n.message("issue.label")));
					$collapsingBorderCont2.append($collapsingBorderContent2);
					$dialog.append($collapsingBorderCont2);

					initAutoComplete($dialog, uniqueId, existingData && existingData.hasOwnProperty("trackerItem") ? [existingData.trackerItem] : [], refreshIncludePart, true);
					if (existingData && existingData.hasOwnProperty("trackerItem")) {
						refreshIncludePart($dialog, uniqueId);
					}

				});
			});

			$("body").append($dialog);

			$('.referenceDialog.includeDialog[data-uniqueId="' + uniqueId + '"]').dialog({
				autoOpen: false,
				modal: true,
				dialogClass: 'popup',
				width: 600,
				title: i18n.message("queries.include.label"),
				create: function() {
					if (!forceOpen) {
						var $that = $(this);
						setTimeout(function() {
							refreshIncludePart($that, uniqueId);
						}, 200);
					}
				},
				buttons: [
					{
						text: i18n.message("button.ok"),
						"class": "button",
						click: function() {
							refreshIncludePart($(this), uniqueId);
						}
					},
					{
						text: i18n.message("button.cancel"),
						"class": "cancelButton",
						click: function() {
							$(this).dialog("close");
						}
					}
				]
			});

			setTimeout(function() {
				if (config.reportPage || forceOpen) {
					ajaxBusyIndicator.close(busy);
				}
				if (forceOpen) {
					$('.referenceDialog.includeDialog[data-uniqueId="' + uniqueId + '"]').dialog("open");
				}
			}, 200);

		};

		if (existingValue) {
			$.ajax({
				url: contextPath + "/ajax/queryCondition/getIncludeData.spr",
				dataType: "json",
				data: { "id": existingValue, "isReport": existingValueIsReport },
				async: false,
				success: function (result) {
					loadDialog(result);
				}
			});
		} else {
			loadDialog();
		}

		$include.click(function(e) {
			e.stopPropagation();
			$('.referenceDialog.includeDialog[data-uniqueId="' + uniqueId + '"]').dialog("open");
		});

	};

	var getReferenceProjectIds = function(uniqueId) {
		var projectIds = [];
		$('.referenceProjectSelector[data-uniqueId="' + uniqueId + '"]').each(function () {
			var selected = $(this).multiselect("getChecked");
			selected.each(function () {
				projectIds.push(parseInt($(this).val(), 10));
			});
		});
		return $.unique(projectIds);
	};

	var getReferenceTrackerIds = function(uniqueId) {
		var trackerIds = [];
		$('.referenceTrackerSelector[data-uniqueId="' + uniqueId + '"]').each(function () {
			var selected = $(this).multiselect("getChecked");
			selected.each(function () {
				trackerIds.push(parseInt($(this).val(), 10));
			});
		});
		return $.unique(trackerIds);
	};

	var reloadTrackerSelectorIfProjectChange = function(uniqueId) {
		var projectIds = getReferenceProjectIds(uniqueId);
		var $trackerLoading = $('.referenceTrackerSelector[data-uniqueId="' + uniqueId + '"] .referenceTrackerAjaxLoading');
		$trackerLoading.show();
		$.getJSON(contextPath + "/ajax/queryCondition/getTrackers.spr", { project_id_list : projectIds.join(",")}).done(function(result) {
			// Reload trackers
			$('.referenceTrackerSelector[data-uniqueId="' + uniqueId + '"]').each(function() {
				var originalValues = $(this).val();
				renderTrackers(result, $(this), true);
				var checkedNum = 0;
				if (originalValues && originalValues.length > 0) {
					checkedNum = checkSelectedValues($(this), originalValues);
				}
				if (checkedNum == 0) {
					checkFirstOption($(this));
				}
				$(this).multiselect("refresh");
				$trackerLoading.hide();
				$(this).change();
			});
		});
	};

	var initAutoComplete = function($dialog, uniqueId, existing, callback, skipOkButton) {
		$dialog.find('.referenceSpan[data-uniqueId="' + uniqueId + '"]').remove();
		var $lastStep = $dialog.find(".lastReferenceStep");
		var $okButton = $dialog.closest(".ui-dialog").find(".ui-dialog-buttonpane").find(".button");
		var trackerIds = getReferenceTrackerIds(uniqueId);
		var $referenceSpan = $("<span>", { "class" : "referenceSpan", "data-uniqueId": uniqueId});
		if (trackerIds.length > 0) {
			$referenceSpan.referenceField(existing, {
				workItemMode: true,
				multiple: true,
				workItemTrackerIds: trackerIds.join(",")
			});
			$lastStep.after($referenceSpan);
			setTimeout(function() {
				$referenceSpan.referenceFieldAutoComplete();
				if (existing.length > 0) {
					callback($dialog, uniqueId);
				}
			}, 300);
			if (!skipOkButton) {
				$okButton.prop("disabled", false);
			}
		} else {
			$referenceSpan.append($("<div>", { "class" : "warning"}).text(i18n.message("query.condition.widget.reference.select.tracker")));
			$lastStep.after($referenceSpan);
			if (!skipOkButton) {
				$okButton.prop("disabled", true);
			}
		}
	};

	// Reference type fields
	var renderReferenceField = function(containerId, fieldObject, forceOpen, values, cbQlFunction) {

		var trackerMode = false;
		// Handle referenceFromTracker / referenceToTracker
		if (fieldObject.id == -2 || fieldObject.id == -3) {
			trackerMode = true;
			var fieldId = fieldObject.id == -2 ? -5 : -4;
			$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
				dataType: "json",
				data: { field_id: fieldId },
				async: false
			}).done(function(newFieldObject) {
				fieldObject = newFieldObject;
			});
		}

		var config = configByInstance[containerId];

		var isProjectReferenceField = fieldObject.referenceType == 2;
		var isTrackerReferenceField = fieldObject.referenceType == 3;

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));

		var trackerItemIds = [];
		var referenceTrackerIds = [];
		var isNot = false;
		var isEmpty = false;
		if (values && (values[0].operator.toUpperCase() == "IS NULL" || values[0].operator.toUpperCase() == "IS NOT NULL")) {
			isEmpty = true;
			if (values[0].operator.toUpperCase() == "IS NOT NULL") {
				isNot = true;
			}
		} else {
			if (values && values[0].operator.toUpperCase() == "NOT IN") {
				isNot = true;
			}
			values = values ? values[0].right.value : null;
			if (trackerMode) {
				referenceTrackerIds = normalizeValues(values) || [];
			} else {
				trackerItemIds = normalizeValues(values) || [];
			}
		}

		var refreshReferenceButton = function($dialog, uniqueId) {

			var isEmpty = false;
			var isNot = false;
			var notEmptyString = "";
			if ($dialog.data("isNot")) {
				isNot = true;
				notEmptyString += i18n.message("query.condition.widget.not") + " ";
			}
			if ($dialog.data("isEmpty")) {
				isEmpty = true;
				notEmptyString += i18n.message("query.condition.widget.empty");
			}

			try {
				var $widget = $dialog.dialog("widget");
			} catch (e) {
				// avoid JS error which can occur if the dialog is not in the DOM any more (change the filters fast)
				return;
			}

			var references = [];
			var referencesString = "";
			var $field = $('.referenceField[data-uniqueId="' + uniqueId + '"]');

			if (isProjectReferenceField || isTrackerReferenceField) {
				var $checked = $dialog.find(isProjectReferenceField ? ".referenceProjectSelector" : ".referenceTrackerSelector").multiselect("getChecked");
				var referenceValues = [];
				$checked.each(function() {
					referenceValues.push($(this).attr("value"));
					references.push($(this).next("span").text());
				});
				referencesString = references.join(", ");
				$field.data("referenceValue", referenceValues);
			} else {
				$widget.find(".referenceSpan ul li.token-input-token-facebook").each(function() {
					references.push($(this).find("p").text());
				});
				referencesString = references.join(", ");
				// Store tracker IDs for Reference to and Reference from fields
				var $collapsingBorder = $widget.find(".collapsingBorder");
				if ((references.length == 0 || ($collapsingBorder.length > 0 && $collapsingBorder.hasClass("collapsingBorder_collapsed"))) && (fieldObject.id == -4 || fieldObject.id == -5)) {
					var $referenceTrackerSelector = $widget.find(".referenceTrackerSelector");
					var selectedTrackerIds = $referenceTrackerSelector.val();
					$field.data("referenceTrackerIds", selectedTrackerIds);
					var selectedTrackerNames = [];
					$referenceTrackerSelector.find("option").each(function() {
						if ($.inArray($(this).val(), selectedTrackerIds) > -1) {
							selectedTrackerNames.push($(this).text());
						}
					});
					referencesString = selectedTrackerNames.join(", ");
					$field.data("referenceValue", null);
				} else {
					$field.data("referenceTrackerIds", null);
					var value = $widget.find('.referenceSpan input[type="hidden"]').val();
					var decodedReferenceValues = decodeReferences(value);
					$field.data("referenceValue", decodedReferenceValues.length > 0 ? decodedReferenceValues : null);
				}
				if (referencesString.length > 100) {
					referencesString = referencesString.substring(0, 100) + "...";
				}

				var suspectedFilter = $widget.find(".suspectedFilterSelector").val();
				if (suspectedFilter == "0") {
					$field.data("cbQLFunction", null);
				} else {
					$field.data("cbQLFunction", suspectedFilter);
				}
				if (suspectedFilter == "isSuspected") {
					referencesString += " (" + i18n.message("query.widget.suspected.only.suspected.label") + ")";
				} else if (suspectedFilter == "isNotSuspected") {
					referencesString += " (" + i18n.message("query.widget.suspected.only.not.suspected.label") + ")";
				}
			}

			$field.data("isNot", isNot);
			$field.data("isEmpty", isEmpty);

			$field.find(".labelValue").text(" " + notEmptyString  + (isEmpty ? "" : referencesString));
			$dialog.dialog("close");
		};

		var loadDialog = function(projectIds, trackerIds, existingReferences, uniqueId, $selector, $trackerSelector, $button, isNot, isEmpty) {

			if (config.reportPage || forceOpen) {
				if (ajaxBusyIndicator.dialog != null) {
					var busy = ajaxBusyIndicator.showBusyPage();
				}
			}

			var activateNotReferences = function($cont) {
				$cont.data("isNot", true);
			};

			var deactivateNotReferences = function($cont) {
				$cont.data("isNot", false);
			};

			var activateEmptyReferences = function($cont) {
				$cont.data("isEmpty", true);
				$cont.find(".referenceProjectSelector").multiselect("disable");
				$cont.find(".referenceTrackerSelector").multiselect("disable");
				$cont.find(".chooseReferences").addClass("disabled");
				$cont.find("input, select").prop("disabled", true);
			};

			var deActivateEmptyReferences = function($cont) {
				$cont.data("isEmpty", false);
				$cont.find(".referenceProjectSelector").multiselect("enable");
				$cont.find(".referenceTrackerSelector").multiselect("enable");
				$cont.find(".chooseReferences").removeClass("disabled");
				$cont.find("input, select").prop("disabled", false);
			};

			var $dialog = $("<div>", { "class": "referenceDialog" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
			addNotAndEmptyBadges($dialog, $button, fieldObject.id == -4 || fieldObject.id == -5, activateNotReferences, deactivateNotReferences, activateEmptyReferences, deActivateEmptyReferences, isNot, isEmpty);
			$dialog.append($("<div>", { "class": "referenceStep"}).html(i18n.message("query.condition.widget.reference.step1")));

			var finalizeDialog = function() {
				setTimeout(function() {
					if (config.reportPage || forceOpen) {
						ajaxBusyIndicator.close(busy);
					}
					refreshReferenceButton($dialog, uniqueId);
					if (forceOpen) {
						$('.referenceDialog[data-uniqueId="' + uniqueId + '"]').dialog("open");
					}
				}, 200);
			};

			$.getJSON(contextPath + "/ajax/queryCondition/getProjects.spr").done(function(result) {
				var recent = result.recent;
				var all = result.all;
				var $recentGroup = $("<optgroup>", { label: i18n.message("recent.projects.label") });
				for (var i=0; i < recent.length; i++) {
					var project = recent[i];
					$recentGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
				}
				$selector.append($recentGroup);
				var $allGroup = $("<optgroup>", { label: i18n.message("my.open.issues.all.projects") });
				for (var i=0; i < all.length; i++) {
					var project = all[i];
					$allGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
				}
				$selector.append($allGroup);
				$dialog.append($selector);
				initMultiSelect(containerId, $selector, { label: i18n.message("project.label") }, false, false);
				$selector.attr("data-uniqueId", uniqueId);
				if (isProjectReferenceField) {
					projectIds = trackerItemIds;
				}
				if (projectIds.length > 0) {
					checkSelectedValues($selector, projectIds);
				} else {
					checkFirstOption($selector);
				}
				$selector.change(function() {
					reloadTrackerSelectorIfProjectChange(uniqueId);
				});

				if (!isProjectReferenceField) {
					$dialog.append($("<div>", { class: "referenceStep"}).html(i18n.message("query.condition.widget.reference.step2")));
					var existingProjectIds = getReferenceProjectIds(uniqueId);
					var getTrackersData = {
						project_id_list: existingProjectIds.join(",")
					};
					if (trackerIds.length > 0) {
						getTrackersData["tracker_id_list"] = trackerIds.join(",");
					}

					var $trackerLoading = $("<img>", { "class" : "referenceTrackerAjaxLoading", src : contextPath + "/images/ajax-loading_16.gif"});
					$dialog.append($trackerLoading);
					$.getJSON(contextPath + "/ajax/queryCondition/getTrackers.spr", getTrackersData).done(function(trackerResult) {
						renderTrackers(trackerResult, $trackerSelector, true);
						$trackerLoading.before($trackerSelector);
						$trackerLoading.hide();
						initMultiSelect(containerId, $trackerSelector, { label: i18n.message("tracker.label") }, false, false);
						$trackerSelector.attr("data-uniqueId", uniqueId);
						var checkedNum = 0;
						if (isTrackerReferenceField) {
							trackerIds = trackerItemIds;
						}
						if (trackerIds.length > 0) {
							checkedNum = checkSelectedValues($trackerSelector, trackerIds);
						}
						if (checkedNum == 0) {
							checkFirstOption($trackerSelector);
						}

						if (!isTrackerReferenceField) {
							$trackerSelector.change(function() {
								initAutoComplete($dialog, uniqueId, [], refreshReferenceButton);
							});

							// Render suspected selector except Parent and Children fields
							if (fieldObject.id != 76 && fieldObject.id != 79) {
								$dialog.append($("<div>", { class: "referenceStep"}).html(i18n.message("query.condition.widget.reference.step4") + (fieldObject.id > 0 ? " " + i18n.message("query.condition.widget.reference.step4.additional") : "")));
								renderSuspectedFilterSelector($dialog, null, cbQlFunction);
							}

							var step3Text = i18n.message("query.condition.widget.reference.step3");
							if (fieldObject.id == -4 || fieldObject.id == -5) {
								var $collapsingBorderCont = $("<fieldset>", { "class" : "collapsingBorder separatorLikeCollapsingBorder " + (existingReferences.length > 0 ? "collapsingBorder_expanded" : "collapsingBorder_collapsed") });
								var $collapsingBorderLegend = $("<legend>", { "class" : "collapsingBorder_legend"});
								$collapsingBorderLegend.append($("<a>", { "href" : "#", "class" : "collapseToggle", "onclick" : "CollapsingBorder.toggle(this, null, '');return false;"}).text(i18n.message("query.condition.widget.filter.by.work.items")));
								$collapsingBorderCont.append($collapsingBorderLegend);
								var $collapsingBorderContent = $("<div>", { "class" : "collapsingBorder_content"});
								$collapsingBorderContent.append($("<div>", { class: "referenceStep lastReferenceStep"}).html(step3Text));
								$collapsingBorderCont.append($collapsingBorderContent);
								$dialog.append($collapsingBorderCont);
							} else {
								$dialog.append($("<div>", { class: "referenceStep lastReferenceStep"}).html(step3Text));
							}

							initAutoComplete($dialog, uniqueId, existingReferences, refreshReferenceButton);
							if (referenceTrackerIds.length > 0) {
								refreshReferenceButton($dialog, uniqueId);
							}
						}
						finalizeDialog();
					});
				} else {
					finalizeDialog();
				}
			});

			$("body").append($dialog);

			$('.referenceDialog[data-uniqueId="' + uniqueId + '"]').dialog({
				autoOpen: false,
				modal: true,
				dialogClass: 'popup',
				width: 600,
				title: fieldObject.label,
				create: function() {
					if (!forceOpen) {
						var $that = $(this);
						setTimeout(function() {
							refreshReferenceButton($that, uniqueId);
						}, 200);
					}
				},
				buttons: [
					{
						text: i18n.message("button.ok"),
						"class": "button",
						click: function() {
							refreshReferenceButton($(this), uniqueId);
						}
					},
					{
						text: i18n.message("button.cancel"),
						"class": "cancelButton",
						click: function() {
							$(this).dialog("close");
						}
					}
				]
			});

		};

		var $textField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector referenceField" + getClassName(fieldObject) });
		$textField.data("fieldObject", fieldObject);

		$textField.attr("data-uniqueId", uniqueId);

		$textField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $textFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>:");
		$textField.append($textFieldLabel);
		$textField.append($("<span>", { "class": "labelValue"}).text(" -"));
		config.container.find(".addButton").before($textField);

		addDeleteButton(containerId, $textField, uniqueId);
		addFilterCounter(containerId, $textField);

		var $selector = $("<select>", { "class" : "selector referenceProjectSelector", multiple : "multiple", "data-uniqueId": uniqueId});
		var $trackerSelector = $("<select>", { "class" : "selector referenceTrackerSelector", multiple : "multiple", "data-uniqueId" : uniqueId});

		if (trackerItemIds.length > 0) {
			$.ajax({
				url: contextPath + "/ajax/queryCondition/getExistingReferenceData.spr",
				dataType: "json",
				data: {"tracker_item_id_list": trackerItemIds.join(",")},
				async: false,
				success: function (result) {
					loadDialog(result.projectIds, result.trackerIds, result.trackerItems, uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
				}
			});
		} else if (referenceTrackerIds.length > 0) {
			$.ajax({
				url: contextPath + "/ajax/queryCondition/getProjectIdsForTrackers.spr",
				dataType: "json",
				data: {"tracker_id_list" : referenceTrackerIds.join(",")},
				async: false,
				success: function(result) {
					loadDialog(result.projectIds, referenceTrackerIds, [], uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
				}
			});
		} else {
			if (fieldObject.customField && fieldObject.trackerId && fieldObject.id) {
				$.ajax({
					url: contextPath + "/ajax/queryCondition/getTrackerIdsForReferenceField.spr",
					dataType: "json",
					data: { trackerId: fieldObject.trackerId, fieldId: fieldObject.id},
					async: false,
					success: function(result) {
						loadDialog(result.projectIds, result.trackerIds, [], uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
					}
				});
			} else if (fieldObject.dedicatedReferenceField) {
				var trackerIds = getTrackerIds(containerId);
				if (trackerIds.length > 0) {
					$.ajax({
						url: contextPath + "/ajax/queryCondition/getTrackerIdsForReferenceFields.spr",
						dataType: "json",
						data: { trackerIdList: trackerIds.join(","), fieldId: fieldObject.id},
						async: false,
						success: function(result) {
							loadDialog(result.projectIds, result.trackerIds, [], uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
						}
					});
				} else {
					loadDialog([], [], [], uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
				}
			} else {
				loadDialog([], [], [], uniqueId, $selector, $trackerSelector, $textField, isNot, isEmpty);
			}
		}

		$textField.click(function(e) {
			e.stopPropagation();
			$('.referenceDialog[data-uniqueId="' + uniqueId + '"]').dialog("open");
		});


		config.nextReferenceSelectorId++;
	};

	// Date type fields
	var renderDateField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var existingFromDate = "";
		var existingToDate = "";

		var isNot = false;
		var isEmpty = false;
		if (values && values.length == 1) {
			if (values[0].operator.toUpperCase() == "IS NULL") {
				isEmpty = true;
			}
			if (values[0].operator.toUpperCase() == "IS NOT NULL") {
				isEmpty = true;
				isNot = true;
			}
		}

		if (values && values.length > 0) {
			for (var i = 0; i < values.length; i++) {
				var value = values[i];
				if (value.hasOwnProperty("right") && (value.operator == ">=" || value.operator == "<")) {
					existingFromDate = removeApostrophes(value.right.value);
				}
				if (value.hasOwnProperty("right") && (value.operator == "<=" || value.operator == ">")) {
					existingToDate = removeApostrophes(value.right.value);
				}
				if (value.operator == "<" || value.operator == ">") {
					isNot = true;
				}
			}
		}

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));

		var $dateField = $("<button>", { id: "dateField_" + uniqueId, "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector dateField" + getClassName(fieldObject) });
		$dateField.data("fieldObject", fieldObject);

		$dateField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $dateFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>:");
		$dateField.append($dateFieldLabel);
		$dateField.append($("<span>", { "class" : "range"}));
		$dateField.append($("<span>", { "class" : "fromDate"}).text(existingFromDate ? " " + i18n.message("query.condition.widget.from") + " " + existingFromDate : ""));
		$dateField.append($("<span>", { "class" : "toDate"}).text(existingToDate ? " " + i18n.message("query.condition.widget.to") + " " + existingToDate : ""));
		config.container.find(".addButton").before($dateField);

		addDeleteButton(containerId, $dateField);
		addFilterCounter(containerId, $dateField);

		var dateInputChangeCallback = function($container, $fromDateInput, $toDateInput) {
			$container.find(".range").text("");
			if ($fromDateInput.val().length > 0) {
				$container.find(".fromDate").text(" " + i18n.message("query.condition.widget.from") + " " + $fromDateInput.val());
			} else {
				$container.find(".fromDate").text("");
			}
			if ($toDateInput.val().length > 0) {
				$container.find(".toDate").text(" " + i18n.message("query.condition.widget.to") + " " + $toDateInput.val());
			} else {
				$container.find(".toDate").text("");
			}
		};

		$dateField.dateRangeSelector({
			id : uniqueId,
			fieldName: fieldObject.name,
			fieldLabel: fieldObject.label,
			forceOpen: forceOpen,
			existingFromDate: existingFromDate,
			existingToDate: existingToDate,
			dialogClasses: "queryConditionSelector dateField" + getClassName(fieldObject),
			showRelativeCustomRange: true,
			selectCallback: function($container, $selectedOption, $fromDateInput, $toDateInput, fromRange, toRange) {
				var $rangeSpan = $container.find(".range");
				var $fromDateSpan = $container.find(".fromDate");
				var $toDateSpan = $container.find(".toDate");
				if ($selectedOption.val() == "custom" && fromRange == null && toRange == null) {
					$rangeSpan.text("");
					if ($fromDateInput.val().length > 0) {
						$fromDateSpan.text(" " + i18n.message("query.condition.widget.from") + " " + $fromDateInput.val());
					} else {
						$fromDateSpan.text("");
					}
					if ($toDateInput.val().length > 0) {
						$toDateSpan.text(" " + i18n.message("query.condition.widget.to") + " " + $toDateInput.val());
					} else {
						$toDateSpan.text();
					}
				} else if ($selectedOption.val() == "custom" && (fromRange != null || toRange != null)) {
					var text = "";
					if (fromRange != null) {
						text += " " + i18n.message("query.condition.widget.from") + " " + fromRange.numberVal.toString() + " ";
						text += customDateRangeMap[fromRange.range] + " " + customDateRangeMap[fromRange.direction] + " " + i18n.message("date.range.today.label");
					}
					if (toRange != null) {
						text += " " + i18n.message("query.condition.widget.to") + " " + toRange.numberVal.toString() + " ";
						text += customDateRangeMap[toRange.range] + " " + customDateRangeMap[toRange.direction] + " " + i18n.message("date.range.today.label");
					}
					$rangeSpan.text(text);
					$fromDateSpan.text("");
					$toDateSpan.text("");
				} else {
					$rangeSpan.text(" " + $selectedOption.text());
					$fromDateSpan.text("");
					$toDateSpan.text("");
				}
			},
			afterCreateCallback: function($dialog) {
				$dateField.find(".range").before($("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " "));
				$dateField.find(".range").before($("<span>", { "class": "labelValueEmpty"}).text(" " + i18n.message("query.condition.widget.empty") + " "));
				if (!isNot) {
					$dateField.find(".labelValueNot").hide();
				}
				if (!isEmpty) {
					$dateField.find(".labelValueEmpty").hide();
				}
				addNotAndEmptyBadges($dialog.find(".rangeContainer"), $dateField, false, activateNotDate, deactivateNotDate, activateEmptyDate, deactivateEmptyDate, isNot, isEmpty);
			},
			fromDateInputCallback : dateInputChangeCallback,
			toDateInputCallback: dateInputChangeCallback
		});
	};

	var activateNotDate = function($container, $button) {
		$button.data("isNot", true);
		$button.find(".labelValueNot").show();
		if ($button.find(".labelValueEmpty").is(":visible")) {
			$button.find(".range, .fromDate, .toDate").hide();
		}
	};
	var deactivateNotDate = function($container, $button) {
		$button.data("isNot", false);
		$button.find(".labelValueNot").hide();
		if (!$button.find(".labelValueEmpty").is(":visible")) {
			$button.find(".range, .fromDate, .toDate").show();
		}
	};
	var activateEmptyDate = function($container, $button) {
		$button.data("isEmpty", true);
		$button.find(".labelValueEmpty").show();
		$button.find(".range, .fromDate, .toDate").hide();
		$container.closest(".queryConditionSelector").find("input, select").prop("disabled", "disabled");
	};
	var deactivateEmptyDate = function($container, $button) {
		$button.data("isEmpty", false);
		$button.find(".labelValueEmpty").hide();
		$button.find(".range, .fromDate, .toDate").show();
		$container.closest(".queryConditionSelector").find("input, select").prop("disabled", "");
	};

	var renderTagField = function(containerId, fieldObject, forceOpen, values, operator) {
		var config = configByInstance[containerId];
		var isNot = operator == "NOT IN";

		var tags = [];
		for (var i = 0; i < values.length; i++) {
			tags.push(removeApostrophes(values[i].value));
		}

		var $tagField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector tagField" + getClassName(fieldObject) });
		$tagField.data("fieldObject", fieldObject);
		$tagField.data("cbQLAttrName", fieldObject.cbQLAttributeName);

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$tagField.attr("data-uniqueId", uniqueId);

		$tagField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $textFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>:");
		$tagField.append($textFieldLabel);
		var $labelValue = $("<span>", { "class": "labelValue"});
		var $labelValueNot = $("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " ");
		$labelValueNot.hide();
		$labelValue.append($labelValueNot);

		var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + (tags && tags.length > 0 ? tags.join("; ") : "-"));
		$labelValue.append($labelValueText);
		$tagField.append($labelValue);
		config.container.find(".addButton").before($tagField);

		addDeleteButton(containerId, $tagField);
		addFilterCounter(containerId, $tagField);

		var fixMenuPosition = function() {
			var $menu = $('.tagFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.position({
				of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
				my: "left top",
				at: "left bottom"
			});
		};

		var tagFieldChangeHandler = function(element, uniqueId) {
			var $menuCont = element.closest(".tagFieldMenu");
			var inputValue = $menuCont.find(".inputValue").val();
			var inputValues = [];
			if (inputValue && inputValue.length > 0) {
				inputValues = inputValue.split(";");
			}
			var normalizedValues = [];
			for (var i = 0; i < inputValues.length; i++) {
				var value = $.trim(inputValues[i].replace("'", "\\'"));
				if (value.length > 0) {
					normalizedValues.push(value);
				}
			}
			var $field = config.container.find('button[data-uniqueId="' + uniqueId + '"]');
			var labelValue = inputValue != null && inputValue.length > 0 ? inputValue : "-";
			$field.data("inputValue", normalizedValues);
			config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(" " + labelValue);
		};

		var $textFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector tagFieldMenu" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
		$textFieldMenu.click(function(e) {
			e.stopPropagation();
		});

		var $textMenuCont1 = $("<span>", { "class" : "textMenuCont"});
		var $fieldLabel = $("<span>", { "class": "fieldLabel"});
		$fieldLabel.text(i18n.message("tags.label") + ": ");
		$textMenuCont1.append($fieldLabel);
		var $inputField = $("<input>", { "class": "inputValue", "type": "text", "value" : (tags && tags.length > 0 ? tags.join("; ") : "")});
		initEntityLabelAutocomplete($inputField);
		$inputField.change(function() {
			tagFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($inputField);

		var $textMenuCont2 = $("<span>", { "class" : "textMenuCont"});
		addNotAndEmptyBadges($textMenuCont2, $tagField, true, activateNot, deactivateNot, null, null, isNot, false, fieldObject.id == -33);

		$textFieldMenu.append($textMenuCont1);
		$textFieldMenu.append($textMenuCont2);

		$("body").append($textFieldMenu);

		$inputField.change();

		$tagField.click(function(e) {
			e.stopPropagation();
			$(".ui-multiselect-menu").hide();
			var $menu = $('.tagFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.toggle();
			fixMenuPosition();
			$menu.find('input[type="text"]').focus();
		});

		$("html").click(function(e) {
			if (!$(e.target).is(".ui-menu-item-wrapper")) {
				$(".queryConditionSelector.tagFieldMenu").each(function() {
					if ($(this).is(":visible")) {
						$(this).hide();
					}
				});
			} else {
				$inputField.change();
			}
		});

		if (forceOpen) {
			setTimeout(function() {
				$tagField.click();
			}, 200);
		}

	};

	// Text / URL type fields
	var renderTextField = function(containerId, fieldObject, forceOpen, values, isUrlField) {

		var config = configByInstance[containerId];

		var operator = values ? values[0].operator.toUpperCase() : null;

		var isNot = operator == "NOT LIKE" || operator == "IS NOT NULL";
		var isEmpty = operator == "IS NULL" || operator == "IS NOT NULL";

		values = values && values[0].hasOwnProperty("right") ? removeApostrophes(values[0].right.value) : null;

		var $textField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector textField" + getClassName(fieldObject) });
		$textField.data("fieldObject", fieldObject);

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$textField.attr("data-uniqueId", uniqueId);

		$textField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $textFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>:");
		$textField.append($textFieldLabel);
		var $labelValue = $("<span>", { "class": "labelValue"});
		var $labelValueNot = $("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " ");
		$labelValueNot.hide();
		$labelValue.append($labelValueNot);

		var $labelValueEmpty = $("<span>", { "class": "labelValueEmpty"}).text(" " + i18n.message("query.condition.widget.empty") + " ");
		$labelValueEmpty.hide();
		$labelValue.append($labelValueEmpty);

		var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + i18n.message("query.condition.widget.like") + " " + (values && values.length > 0 ? values : "-"));
		$labelValue.append($labelValueText);
		$textField.append($labelValue);
		config.container.find(".addButton").before($textField);

		addDeleteButton(containerId, $textField);
		addFilterCounter(containerId, $textField);

		var fixMenuPosition = function() {
			var $menu = $('.textFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.position({
				of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
				my: "left top",
				at: "left bottom"
			});
		};

		var textFieldChangeHandler = function(element, uniqueId) {
			var $menuCont = element.closest(".textFieldMenu");
			var inputValue = $menuCont.find(".inputValue").val();
			var $field = config.container.find('button[data-uniqueId="' + uniqueId + '"]');
			var label = " " + i18n.message("query.condition.widget.like") + " ";
			var labelValue = inputValue != null && inputValue.length > 0 ? inputValue : "-";
			$field.data("inputValue", inputValue.replace("'", "\\'"));
			config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(label + labelValue);
			fixMenuPosition();
		};

		var $textFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector textFieldMenu" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
		$textFieldMenu.click(function(e) {
			e.stopPropagation();
		});

		var $textMenuCont1 = $("<span>", { "class" : "textMenuCont"});
		var $fieldLabel = $("<span>", { "class": "fieldLabel"});
		$fieldLabel.text(isUrlField ? i18n.message("tracker.field.valueType.url.label"): i18n.message("query.condition.widget.text"));
		$textMenuCont1.append($fieldLabel);
		var $inputField = $("<input>", { "class": "inputValue", "type": "text", "value" : values && values.length > 0 ? values : ""});
		if (isUrlField) {
			$inputField.attr("id", "url_editor_" + uniqueId);
		}
		$inputField.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($inputField);
		if (isUrlField) {
			var $pencil = $("<span>", { "class" : "urlFieldPencilIcon"});
			$pencil.click(function() {
				showPopupInline(contextPath + '/wysiwyg/plugins/plugin.spr?pageName=wikiHistoryLink&fieldId=' + 'url_editor_' + uniqueId, { geometry: '90%_90%' }); return false;
			});
			$textMenuCont1.append($pencil);
		}

		var $textMenuCont2 = $("<span>", { "class" : "textMenuCont"});
		addNotAndEmptyBadges($textMenuCont2, $textField, false, activateNot, deactivateNot, activateEmpty, deactivateEmpty, isNot, isEmpty);

		$textFieldMenu.append($textMenuCont1);
		$textFieldMenu.append($textMenuCont2);

		if (!isUrlField) {
			$textFieldMenu.append($("<div>", { "class": "textMenuContInfo"}).text(i18n.message("query.condition.widget.text.field.info")));
		}

		$("body").append($textFieldMenu);

		$inputField.change();

		$textField.click(function(e) {
			e.stopPropagation();
			var $menu = $('.textFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.is(":visible") ? $menu.hide() : $menu.show();
			fixMenuPosition();
			$menu.find('input[type="text"]').focus();
			hideOtherMenus(uniqueId);
		});

		$("html").click(function() {
			$(".queryConditionSelector.textFieldMenu").each(function() {
				if ($(this).is(":visible")) {
					if (isUrlField) {
						$("#url_editor_" + uniqueId).change();
					}
					$(this).hide();
				}
			});
		});

		if (forceOpen) {
			setTimeout(function() {
				$textField.click();
			}, 200);
		}
	};

	// Number (decimal, integer) type fields
	var renderNumberField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var operator = values ? values[0].operator.toUpperCase() : null;
		values = values && values[0].hasOwnProperty("right") ? values[0].right.value : null;

		var $textField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector numberField" + getClassName(fieldObject) });
		$textField.data("fieldObject", fieldObject);

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$textField.attr("data-uniqueId", uniqueId);

		$textField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var isNot = operator == "IS NOT NULL" || operator == "!=";
		var isEmpty = operator == "IS NULL" || operator == "IS NOT NULL";
		if (operator == "!=") {
			operator = "=";
		}

		var $textFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>: ");
		$textField.append($textFieldLabel);
		var $labelValue = $("<span>", { "class": "labelValue"});

		var $labelValueNot = $("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " ");
		$labelValueNot.hide();
		$labelValue.append($labelValueNot);

		var $labelValueEmpty = $("<span>", { "class": "labelValueEmpty"}).text(" " + i18n.message("query.condition.widget.empty") + " ");
		$labelValueEmpty.hide();
		$labelValue.append($labelValueEmpty);

		var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + (numberTypeMap[operator] ? numberTypeMap[operator] : "-") + " " + (values ? values : ""));
		$labelValue.append($labelValueText);
		$textField.append($labelValue);
		config.container.find(".addButton").before($textField);

		if (!isNot) {
			$labelValueNot.hide();
		}
		if (isEmpty) {
			$labelValueText.hide();
		} else {
			$labelValueEmpty.hide();
		}

		addDeleteButton(containerId, $textField);
		addFilterCounter(containerId, $textField);

		var fixMenuPosition = function() {
			var $menu = $('.numberFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.position({
				of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
				my: "left top",
				at: "left bottom"
			});
		};

		var textFieldChangeHandler = function(element, uniqueId) {
			var $menuCont = element.closest(".numberFieldMenu");
			var selectedOperator = $menuCont.find(".operatorType").val();
			var fieldLabel = $menuCont.find('.operatorType option[value="' + selectedOperator + '"]').text();
			var number = $menuCont.find(".numberInput").val();
			if (!number || (number && number.length == "")) {
				number = 0;
			}
			var labelValue = fieldLabel + " " + number;
			$('button[data-uniqueId="' + uniqueId + '"]').data("operator", selectedOperator);
			$('button[data-uniqueId="' + uniqueId + '"]').data("numberValue", number);
			config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(labelValue);
			fixMenuPosition();
		};

		var $textFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector numberFieldMenu" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
		$textFieldMenu.click(function(e) {
			e.stopPropagation();
		});

		var $textMenuCont1 = $("<span>", { "class" : "textMenuCont"});
		var $fieldLabel = $("<span>", { "class": "fieldLabel"});
		$fieldLabel.text(i18n.message("query.widget.number.label"));
		$textMenuCont1.append($fieldLabel);
		var $typeSelector = $("<select>", { "class": "operatorType" });
		for (var key in numberTypeMap) {
			var $option = $("<option>", { value: key}).text(numberTypeMap[key]);
			if (operator == key) {
				$option.prop("selected", "selected");
			}
			$typeSelector.append($option);
		}
		$typeSelector.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($typeSelector);
		var $inputField = $("<input>", { class: "numberInput", "type": "number", "value" : values});
		$inputField.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($inputField);

		$textFieldMenu.append($textMenuCont1);

		addNotAndEmptyBadges($textMenuCont1, $textField, false, activateNot, deactivateNot, activateEmpty, deactivateEmpty, isNot, isEmpty);

		$("body").append($textFieldMenu);

		$inputField.change();

		$textField.click(function(e) {
			e.stopPropagation();
			var $menu = $('.numberFieldMenu[data-uniqueId="' + uniqueId + '"]');
			$menu.toggle();
			fixMenuPosition();
			$menu.find('input[type="number"]').focus();
			hideOtherMenus(uniqueId);
		});

		$("html").click(function() {
			$(".queryConditionSelector.numberFieldMenu").each(function() {
				if ($(this).is(":visible")) {
					$(this).hide();
				}
			});
		});

		if (forceOpen) {
			setTimeout(function() {
				$textField.click();
			}, 200);
		}
	};

	// Duration type fields
	var renderDurationField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var operator = values ? values[0].operator.toUpperCase() : null;
		values = values && values[0].hasOwnProperty("right") ? values[0].right.value : null;

		var $textField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector durationField" + getClassName(fieldObject) });
		$textField.data("fieldObject", fieldObject);

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$textField.attr("data-uniqueId", uniqueId);

		$textField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var isNot = operator == "IS NOT NULL" || operator == "!=";
		var isEmpty = operator == "IS NULL" || operator == "IS NOT NULL";
		if (operator == "!=") {
			operator = "=";
		}

		var value;
		if (values) {
			value = parseDurationValues(values);
		}

		var $textFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>: ");
		$textField.append($textFieldLabel);

		var $labelValue = $("<span>", { "class": "labelValue"});
		var $labelValueNot = $("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " ");
		$labelValueNot.hide();
		$labelValue.append($labelValueNot);

		var $labelValueEmpty = $("<span>", { "class": "labelValueEmpty"}).text(" " + i18n.message("query.condition.widget.empty") + " ");
		$labelValueEmpty.hide();
		$labelValue.append($labelValueEmpty);

		var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + (numberTypeMap[operator] ? numberTypeMap[operator] : "-") + " " + (value && value.numberValue ? value.numberValue : "") + (value && value.time ? durationTimeMap[value.time] : ""));
		$labelValue.append($labelValueText);
		$textField.append($labelValue);

		config.container.find(".addButton").before($textField);

		addDeleteButton(containerId, $textField);
		addFilterCounter(containerId, $textField);

		var fixMenuPosition = function() {
			var $menu = $('.durationFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.position({
				of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
				my: "left top",
				at: "left bottom"
			});
		};

		var textFieldChangeHandler = function(element, uniqueId) {
			var $menuCont = element.closest(".durationFieldMenu");
			var selectedOperator = $menuCont.find(".operatorType").val();
			var selectedTime = $menuCont.find(".timeType").val();
			var fieldLabel = $menuCont.find('.operatorType option[value="' + selectedOperator + '"]').text();
			var timeLabel = $menuCont.find('.timeType option[value="' + selectedTime + '"]').text();
			var number = $menuCont.find(".numberInput").val();
			if (!number || (number && (number.length == "" || number < 0))) {
				number = 0;
			}
			var labelValue = fieldLabel + " " + number + " " + timeLabel;
			$('button[data-uniqueId="' + uniqueId + '"]').data("operator", selectedOperator);
			$('button[data-uniqueId="' + uniqueId + '"]').data("numberAndTime", number + selectedTime);
			config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(labelValue);
			fixMenuPosition();
		};

		var $textFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector durationFieldMenu" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
		$textFieldMenu.click(function(e) {
			e.stopPropagation();
		});

		var $textMenuCont1 = $("<span>", { "class" : "textMenuCont"});
		var $fieldLabel = $("<span>", { "class": "fieldLabel"});
		$fieldLabel.text(i18n.message("query.widget.duration.label"));
		$textMenuCont1.append($fieldLabel);
		var $typeSelector = $("<select>", { "class": "operatorType" });
		for (var key in numberTypeMap) {
			var $option = $("<option>", { value: key}).text(numberTypeMap[key]);
			if (operator == key) {
				$option.prop("selected", "selected");
			}
			$typeSelector.append($option);
		}
		$typeSelector.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($typeSelector);
		var $inputField = $("<input>", { class: "numberInput", "type": "number", "value" : value && value.numberValue ? value.numberValue : ""});
		$inputField.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($inputField);

		var $timeSelector = $("<select>", { "class": "timeType" });
		for (var key in durationTimeMap) {
			var $option = $("<option>", { value: key}).text(durationTimeMap[key]);
			if (value && value.time == key) {
				$option.prop("selected", "selected");
			}
			$timeSelector.append($option);
		}
		$timeSelector.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($timeSelector);

		addNotAndEmptyBadges($textMenuCont1, $textField, false, activateNot, deactivateNot, activateEmpty, deactivateEmpty, isNot, isEmpty);

		$textFieldMenu.append($textMenuCont1);

		$("body").append($textFieldMenu);

		$inputField.change();

		$textField.click(function(e) {
			e.stopPropagation();
			var $menu = $('.durationFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.toggle();
			fixMenuPosition();
			$menu.find('input[type="number"]').focus();
			hideOtherMenus(uniqueId);
		});

		$("html").click(function() {
			$(".queryConditionSelector.durationFieldMenu").each(function() {
				if ($(this).is(":visible")) {
					$(this).hide();
				}
			});
		});

		if (forceOpen) {
			setTimeout(function() {
				$textField.click();
			}, 200);
		}
	};

	var renderSuspectedFilterSelector = function($appendTo, $button, selected) {
		if ($button && $button != null) {
			$button.find(".labelValueText").after($("<span>", { "class" : "labelValueFiltering"}));
		}
		var $selectorCont = $("<span>", { "class" : "suspectedFilterSelectorContainer"});
		if ($button && $button != null) {
			$selectorCont.append($("<span>", { "class" : "suspectedFilterSelectorLabel"}).text(i18n.message("query.widget.filter.by.suspected.label") + ": "));
		}
		var $selector = $("<select>", { "class" : "suspectedFilterSelector"});
		$selector.append($("<option>", { value: "0"}).text(i18n.message("query.widget.suspected.do.not.filter.label")));
		$selector.append($("<option>", { value: "isSuspected"}).text(i18n.message("query.widget.suspected.only.suspected.label")));
		$selector.append($("<option>", { value: "isNotSuspected"}).text(i18n.message("query.widget.suspected.only.not.suspected.label")));
		if ($button && $button != null) {
			$selector.change(function() {
				$button.data("cbQLFunction", $(this).val() == "0" ? null : $(this).val());
				var $filteringPart = $button.find(".labelValueFiltering");
				if ($(this).val() == "isSuspected") {
					$filteringPart.text(" (" + i18n.message("query.widget.suspected.only.suspected.label") + ")");
				} else if ($(this).val() == "isNotSuspected") {
					$filteringPart.text(" (" + i18n.message("query.widget.suspected.only.not.suspected.label") + ")");
				} else {
					$filteringPart.text("");
				}
			});
		}
		$selector.val(selected == null ? "0" : selected);
		$selector.change();
		$selectorCont.append($selector);
		$appendTo.append($selectorCont);
	};

	var renderBooleanField = function(containerId, label, cbQLAttrName, value, cbQLFunction, forceOpen, isReference, fieldObject) {

		var config = configByInstance[containerId];

		var $textField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector booleanField " + cbQLAttrName });
		$textField.data("cbQLAttrName", cbQLAttrName);
		if (fieldObject) {
			$textField.data("fieldObject", fieldObject);
		}

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$textField.attr("data-uniqueId", uniqueId);

		$textField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

		var $textFieldLabel = $("<span>").html("<b>" + label + "</b>: ");
		$textField.append($textFieldLabel);

		var $labelValue = $("<span>", { "class": "labelValue"});
		var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + (typeof value !== "undefined" && value != null ? booleanLabelValueMap[value.toString()] : "true"));
		$labelValue.append($labelValueText);
		$textField.append($labelValue);

		config.container.find(".addButton").before($textField);

		addDeleteButton(containerId, $textField);
		addFilterCounter(containerId, $textField);

		var fixMenuPosition = function() {
			var $menu = $('.booleanFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.position({
				of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
				my: "left top",
				at: "left bottom"
			});
		};

		var textFieldChangeHandler = function(element, uniqueId) {
			var $menuCont = element.closest(".booleanFieldMenu");
			var selectedValue = $menuCont.find(".valueType").val();
			$('button[data-uniqueId="' + uniqueId + '"]').data("value", selectedValue);
			config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(booleanLabelValueMap[selectedValue.toString()]);
			fixMenuPosition();
		};

		var $textFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector booleanFieldMenu " + cbQLAttrName, "data-uniqueId" : uniqueId });
		$textFieldMenu.click(function(e) {
			e.stopPropagation();
		});

		var $textMenuCont1 = $("<span>", { "class" : "textMenuCont"});
		var $fieldLabel = $("<span>", { "class": "fieldLabel"});
		$fieldLabel.text(label);
		$textMenuCont1.append($fieldLabel);
		var $valueSelector = $("<select>", { "class": "valueType" });
		$valueSelector.append($("<option>", { value: "true"}).text(i18n.message("boolean.true.label")));
		$valueSelector.append($("<option>", { value: "false"}).text(i18n.message("boolean.false.label")));
		$valueSelector.change(function() {
			textFieldChangeHandler($(this), uniqueId);
		});
		$textMenuCont1.append($valueSelector);

		$textFieldMenu.append($textMenuCont1);

		if (isReference) {
			renderSuspectedFilterSelector($textFieldMenu, $textField, cbQLFunction);
		}

		$("body").append($textFieldMenu);

		if (typeof value !== "undefined") {
			$valueSelector.val(value.toString());
			$valueSelector.change();
		}

		$textField.click(function(e) {
			e.stopPropagation();
			var $menu = $('.booleanFieldMenu[data-uniqueId="'+ uniqueId + '"]');
			$menu.toggle();
			fixMenuPosition();
			$menu.find('input[type="number"]').focus();
			hideOtherMenus(uniqueId);
		});

		$("html").click(function() {
			$(".queryConditionSelector.booleanFieldMenu").each(function() {
				if ($(this).is(":visible")) {
					$(this).hide();
				}
			});
		});

		if (forceOpen) {
			setTimeout(function() {
				$textField.click();
			}, 200);
		}
	};

	var renderColorField = function(containerId, fieldObject, forceOpen, values) {

		var config = configByInstance[containerId];

		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));

		$.post(
			contextPath + "/ajax/queryCondition/renderColorField.spr", { uniqueId: uniqueId },
			function(response) {

				var operator = values ? values[0].operator.toUpperCase() : null;

				var isNot = operator == "NOT IN" || operator == "IS NOT NULL";
				var isEmpty = operator == "IS NULL" || operator == "IS NOT NULL";

				var value = values && values[0].hasOwnProperty("right") && values[0].right.value[0].hasOwnProperty("value") ? removeApostrophes(values[0].right.value[0].value) : null;

				var $colorField = $("<button>", { "type": "button", "class" : "ui-multiselect ui-widget ui-state-default ui-corner-all queryConditionSelector reportColorField" + getClassName(fieldObject) });
				$colorField.data("fieldObject", fieldObject);
				$colorField.attr("data-uniqueId", uniqueId);

				$colorField.append($("<span>", {"class" : "ui-icon ui-icon-triangle-1-s"}));

				var $colorFieldLabel = $("<span>").html("<b>" + fieldObject.label + "</b>:");
				$colorField.append($colorFieldLabel);
				var $labelValue = $("<span>", { "class": "labelValue"});
				var $labelValueNot = $("<span>", { "class": "labelValueNot"}).text(" " + i18n.message("query.condition.widget.not") + " ");
				$labelValueNot.hide();
				$labelValue.append($labelValueNot);

				var $labelValueEmpty = $("<span>", { "class": "labelValueEmpty"}).text(" " + i18n.message("query.condition.widget.empty") + " ");
				$labelValueEmpty.hide();
				$labelValue.append($labelValueEmpty);

				var $labelValueText = $("<span>", { "class": "labelValueText"}).text(" " + (value && value.length > 0 ? value : "-"));
				$labelValue.append($labelValueText);
				$colorField.append($labelValue);
				config.container.find(".addButton").before($colorField);

				addDeleteButton(containerId, $colorField);
				addFilterCounter(containerId, $colorField);

				var colorFieldChangeHandler = function(element, uniqueId) {
					var $menuCont = element.closest(".colorFieldMenu");
					var inputValue = $menuCont.find("input[type='text']").val();
					var $field = config.container.find('button[data-uniqueId="' + uniqueId + '"]');
					var labelValue = inputValue != null && inputValue.length > 0 ? inputValue : "-";
					$field.data("inputValue", inputValue.replace("'", "\\'"));
					config.container.find('button[data-uniqueId="' + uniqueId + '"] .labelValueText').text(" " + labelValue);
					fixMenuPosition();
				};

				var $colorFieldMenu = $("<div>", { "class": "ui-multiselect-menu ui-widget ui-widget-content ui-corner-all queryConditionSelector colorFieldMenu" + getClassName(fieldObject), "data-uniqueId" : uniqueId });
				$colorFieldMenu.click(function(e) {
					e.stopPropagation();
				});

				var $colorMenuCont1 = $("<span>", { "class" : "colorMenuCont"});
				var $fieldLabel = $("<span>", { "class": "fieldLabel"});
				$fieldLabel.text(i18n.message("tracker.field.valueType.color.label"));
				$colorMenuCont1.append($fieldLabel);
				var $colorPicker = $("<span>");
				$colorPicker.html(response);
				if (value != null) {
					$colorPicker.find("input").val(value);
				}
				$colorPicker.find("input").change();
				$colorMenuCont1.append($colorPicker);

				var $colorMenuCont2 = $("<span>", { "class" : "colorMenuCont"});
				addNotAndEmptyBadges($colorMenuCont2, $colorField, false, activateNot, deactivateNot, activateEmpty, deactivateEmpty, isNot, isEmpty);

				$colorFieldMenu.append($colorMenuCont1);
				$colorFieldMenu.append($colorMenuCont2);

				$("body").append($colorFieldMenu);

				$colorPicker.find("input").change(function() {
					colorFieldChangeHandler($(this), uniqueId);
				});

				var fixMenuPosition = function() {
					var $menu = $('.colorFieldMenu[data-uniqueId="'+ uniqueId + '"]');
					$menu.position({
						of: config.container.find('button[data-uniqueId="' + uniqueId + '"]'),
						my: "left top",
						at: "left bottom"
					});
				};

				$colorField.click(function(e) {
					e.stopPropagation();
					var $menu = $('.colorFieldMenu[data-uniqueId="'+ uniqueId + '"]');
					$menu.toggle();
					fixMenuPosition();
					$menu.find('input[type="text"]').focus();
					hideOtherMenus(uniqueId);
				});

				$("html").click(function() {
					$(".queryConditionSelector.colorFieldMenu, .reportColorPicker").each(function() {
						if ($(this).is(":visible")) {
							$(this).hide();
						}
					});
				});

				if (forceOpen) {
					setTimeout(function() {
						$colorField.click();
					}, 200);
				}

			}
		);

	};

	var activateNot = function($container, $button) {
		$button.data("isNot", true);
		$button.find(".labelValueNot").show();
		if ($button.find(".labelValueEmpty").is(":visible")) {
			$button.find(".labelValueText").hide();
		}
	};
	var deactivateNot = function($container, $button) {
		$button.data("isNot", false);
		$button.find(".labelValueNot").hide();
		if (!$button.find(".labelValueEmpty").is(":visible")) {
			$button.find(".labelValueText").show();
		}
	};
	var activateEmpty = function($container, $button) {
		$button.data("isEmpty", true);
		$button.find(".labelValueEmpty").show();
		$button.find(".labelValueText").hide();
		$container.closest(".queryConditionSelector").find("input, select").prop("disabled", "disabled");
		$container.closest(".queryConditionSelector").find(".addExtraUserContainer").hide();
	};
	var deactivateEmpty = function($container, $button) {
		$button.data("isEmpty", false);
		$button.find(".labelValueEmpty").hide();
		$button.find(".labelValueText").show();
		$container.closest(".queryConditionSelector").find("input, select").prop("disabled", "");
		$container.closest(".queryConditionSelector").find(".addExtraUserContainer").show();
	};

	var getClassName = function(fieldObject) {
		if (fieldObject.hasOwnProperty("cbQLAttributeName")) {
			var label = fieldObject.cbQLAttributeName;
			if (label && label.length > 0) {
				label = label.replace(".", "").replace("[", "").replace("]", "");
				return " " + label + "Selector";
			}
		}
		return "";
	};

	var refreshMultiselect = function($selector) {
		$selector.multiselect("refresh");
		setTimeout(function() {
			$selector.multiselect("refresh");
		}, 1);
	};

	var checkSelectedValues = function($selector, values, isUserField) {
		var checkedNum = 0;
		for (var i=0; i < values.length; i++) {
			var optionVal = values[i];
			try {
				optionVal = removeApostrophes(values[i].toLowerCase());
			} catch (e) {
				// skip if value is not a string
			}
			if (optionVal == "0") {
				continue;
			}
			var option = null;
			$selector.find("option").each(function() {
				var optionValue = removeApostrophes($(this).attr("value").toLowerCase());
				optionValue = optionValue.replace(/"/g, '\\"').replace(/'/g, "\\'");
				if (optionVal == optionValue) {
					option = $(this);
				}
			});
			// try to load group members also if it is not present in select list
			if (isUserField && option == null) {
				var userIds = [];
				var optionValParts = optionVal.split("_");
				userIds.push(optionValParts[1]);
				loadExtraUsers(userIds, $selector);
			} else {
				if (option != null) {
					option.prop("selected", "selected");
					checkedNum++;
				}
			}
		}
		refreshMultiselect($selector);
		return checkedNum;
	};

	var checkFirstOption = function($selector) {
		$selector.find("option").first().prop("selected", "selected");
		refreshMultiselect($selector);
	};

	var uncheckFirstOption = function($selector) {
		$selector.find("option").first().prop("selected", "");
		refreshMultiselect($selector);
	};

	var addNotAndEmptyBadges = function($container, $button, skipEmpty, activateNotCallback, deactivateNotCallback, activateEmptyCallback, deactivateEmptyCallback, isNot, isEmpty, skipNot) {
		var $badgeCont = $("<span>", { "class" : "notEmptyBadgeContainer"});
		if (!skipNot) {
			var $notBadge = ($("<span>", { "class": "notBadge" + (isNot ? " active" : "")}).text(i18n.message("query.condition.widget.not")));
			$notBadge.click(function() {
				$(this).toggleClass("active");
				if ($(this).hasClass("active") && activateNotCallback) {
					activateNotCallback($container, $button);
				}
				if (!$(this).hasClass("active") && deactivateNotCallback) {
					deactivateNotCallback($container, $button);
				}
			});
			$badgeCont.append($notBadge);
		}
		if (isNot && activateNotCallback) {
			setTimeout(function() {
				activateNotCallback($container, $button);
			}, 200);
		}
		if (!skipEmpty) {
			var $emptyBadge = ($("<span>", { "class": "emptyBadge" + (isEmpty ? " active" : "")}).text(i18n.message("query.condition.widget.empty")));
			$emptyBadge.click(function() {
				$(this).toggleClass("active");
				if ($(this).hasClass("active") && activateEmptyCallback) {
					activateEmptyCallback($container, $button);
				}
				if (!$(this).hasClass("active") && activateEmptyCallback) {
					deactivateEmptyCallback($container, $button);
				}
			});
			$badgeCont.append($emptyBadge);
			if (isEmpty && activateEmptyCallback) {
				setTimeout(function() {
					activateEmptyCallback($container, $button);
				}, 200);
			}
		}
		$container.append($badgeCont);
	};

	var initMultiSelect = function(containerId, $selector, referenceDialogObject, isNot, isEmpty, isUserField, isAssignedToField, $dialog, forceResult) {
		var config = configByInstance[containerId];
		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		if (!referenceDialogObject) {
			var fieldObject = $selector.data("fieldObject");
			var label = fieldObject.label;
		} else {
			var label = referenceDialogObject.label;
		}
		var settings = {
			classes: "queryConditionSelector" + (!referenceDialogObject ? getClassName(fieldObject) : ""),
			minWidth: 100,
			height: 230,
			menuHeight: "auto",
			checkAllText : "",
			uncheckAllText: "",
			selectedText: function(numChecked, numTotal, checkedItems) {
				var value = [];
				var $checkedItems = $(checkedItems);
				var labelValueNot = referenceDialogObject ? "" : "<span class=\"labelValueNot\" style=\"display: none\"> " + i18n.message("query.condition.widget.not") + " </span>";
				var labelValueEmpty = referenceDialogObject ? "" : "<span class=\"labelValueEmpty\" style=\"display: none\"> "  + i18n.message("query.condition.widget.empty") +  " </span>";
				if ($checkedItems.first().closest("li").hasClass("anyValue")) {
					return "<b>" + label + ":</b> " + labelValueNot + labelValueEmpty + "<span class=\"labelValueText\">" + i18n.message("tracker.field.value.any") + "</span>";
				}
				$checkedItems.each(function(){
					var valueString = $(this).next().html();
					if ($checkedItems.first().closest(".queryConditionSelector").hasClass("user")
						&& !$(this).closest("li").hasClass("roleOption") && !$(this).closest("li").hasClass("currentUser")) {
						// trim name and email domain, only show username
						valueString = valueString.substring(0, valueString.indexOf(' ('));
					}
					value.push(valueString);
				});
				var extraText = "";
				if (isAssignedToField) {
					extraText = "<span class=\"labelValueIndirectUser\"" + (!$selector.data("indirectUser") ? " style=\"display: none\"" : "") + "> (" + i18n.message("query.condition.widget.indirect.user.label") + ")</span>";
				}
				var joinedText = value.join(", ");
				return "<b>" + label + ":</b> " + labelValueNot + labelValueEmpty + "<span class=\"labelValueText\">" + truncateText(joinedText) + "</span>" + extraText;
			},
			noneSelectedText: function() {
				return "<b>" + label + ":</b> - ";
			},
			open: function() {
				var $widget = $(this).multiselect("widget");
				$widget.css("height", "auto");
				var $button = $(this).multiselect("getButton");
				if (referenceDialogObject) {
					$widget.css("width", (parseInt($button.width(), 10) + 5) + "px");
				}
				$widget.position({
					my: "left top",
					at: "left bottom",
					of: $button,
					collision: "flipfit",
					using : null,
					within: window
				});
				setTimeout(function() {
					$widget.find(".ui-multiselect-filter input").focus();
				}, 100);
				$("div.queryConditionSelector").hide();
				$widget.show();
			},
			create: function(event, ui) {
				// remove check/uncheck all/close buttons
				$(".queryConditionSelector .ui-multiselect-all").closest("ul").remove();

				$(this).attr("data-uniqueId", uniqueId);

				var $widget = $(this).multiselect("widget");
				$widget.css("height", "auto");
				var $widgetHeader = $widget.find(".ui-widget-header");
				var $button = $(this).multiselect("getButton");

				if (!referenceDialogObject) {
					addFilterCounter(containerId, $button);
					if (!$selector.hasClass("specialChoiceFieldSelector")) {
						addNotAndEmptyBadges($widgetHeader, $button, false, activateNot, deactivateNot, activateEmpty, deactivateEmpty, isNot, isEmpty);
					}
					if (isAssignedToField) {
						addIndirectUserBadge($widgetHeader, $selector, $button);
					}
					if (isUserField) {
						addExtraUsersLink($widgetHeader, $selector, $button);
					}
					$button.data("fieldObject", fieldObject);
					var $deleteButtonPlaceholder = $("<span>",{ "class" : "ui-icon deletePlaceholder"});
					$button.prepend($deleteButtonPlaceholder);
					var $deleteButton = $("<span>",{ "class" : "ui-icon removeIcon"});
					$deleteButton.attr("data-uniqueId", uniqueId);
					$deleteButton.click(function(e) {
						e.preventDefault();
						destroyMultiSelect($(this));
						$(this).remove();
						refreshFilterCounters(containerId);
						validateLogicString(containerId);
					});
					$button.after($deleteButton);
				}
			},
			click: function(event, ui) {
				var $menu = $(this).multiselect("widget");
				var $button = $(this).multiselect("getButton");
				var buttonIsNot = $button.data("isNot");
				if (buttonIsNot) {
					setTimeout(function() {
						$button.find(".labelValueNot").show();
					}, 100);
				}
				if (ui.value != "on") {
					var selected = $(this).multiselect("getChecked").filter(":not(.additionalCheckbox)");
					if (selected.length == 0) {
						$menu.find("[value=0]").attr("checked", true);
					}
					if (ui.checked) {
						if (ui.value == 0) {
							$menu.find(":checkbox:checked").filter(":not(.additionalCheckbox)").each(function() {
								var $that = $(this);
								if ($that.val() != 0 && $that.is(":checked")) {
									$that.attr("checked", false);
								}
							});
						} else if (ui.value != "indirectUser") {
							$menu.find("[value=0]").attr("checked", false);
						}
					} else if (!ui.checked && ui.value == 0) {
						$menu.find("[value=0]").attr("checked", true);
					}
				}
				if (forceResult && !config.reportPage && !referenceDialogObject && !config.isDocumentView && !config.isDocumentExtendedView) {
					config.container.find(".searchButton").click();
				}
			}
		};
		if ($dialog && $dialog.length > 0) {
			settings["appendTo"] = $dialog;
		}
		$selector.multiselect(settings).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});
	};

	var destroyMultiSelect = function($deleteButton) {
		var uniqueId = $deleteButton.attr("data-uniqueId");
		var $selector = $('select[data-uniqueId="' + uniqueId + '"]');
		$selector.multiselect("destroy");
		$selector.remove();
		$selector.next(".removeIcon").remove();
	};

	var loadExtraUsers = function(userIds, $selector, $button, $dialog) {
		$.ajax({
			url: contextPath + "/ajax/queryCondition/getUsersInfo.spr",
			dataType: "json",
			async: false,
			data: {
				"user_id_list" : userIds.join(",")
			},
			success: function(result) {
				if (result && result.length > 0) {
					var $usersOptGroup = $selector.find("optgroup.users");
					var userIdValues = [];
					for (var i=0; i < result.length; i++) {
						var user = result[i];
						if ($selector.find('option[value="user_' + user.id + '"]').length == 0) {
							$usersOptGroup.append($("<option>", { "class": user.disabled ? "disabledUser" : "", value : "user_" + user.id }).text(user.aliasName + " (" + user.realName + (user.emailDomain.length > 0 ? ", " + user.emailDomain : "") + ")"));
						}
						userIdValues.push("user_" + user.id);
					}
					checkSelectedValues($selector, userIdValues);
					uncheckFirstOption($selector);
					if ($button) {
						setTimeout(function() {
							$button.click();
						}, 200);
					}
				}
				if ($dialog) {
					$dialog.dialog("destroy");
				}
			}
		});
	};

	var addIndirectUserBadge = function($widgetHeader, $selector, $button) {
		var $badgeSpan = $("<span>", { "class" : "extraBadge indirectUserBadge", "title" : i18n.message("query.condition.widget.indirect.user.tooltip")}).text(i18n.message("query.condition.widget.indirect.user.label"));
		$badgeSpan.click(function() {
			if ($(this).hasClass("active")) {
				$(this).removeClass("active");
				$(this).data("indirectUser", false);
				$button.data("indirectUser", false);
				$button.find(".labelValueIndirectUser").hide();
			} else {
				$(this).addClass("active");
				$(this).data("indirectUser", true);
				$button.data("indirectUser", true);
				$button.find(".labelValueIndirectUser").show();
			}
		});

		$widgetHeader.find(".notEmptyBadgeContainer").append($badgeSpan);

	};

	var addExtraUsersLink = function($widgetHeader, $selector, $button) {
		var $extraUserContainer = $("<div>", { "class" : "addExtraUserContainer"});
		var $extraUserLabel = $("<a>").text(i18n.message("query.condition.widget.add.extra.users"));

		$extraUserLabel.click(function() {
			$selector.multiselect("widget").hide();
			var $dialog = $("<div>", { id: "extraUserDialog"});
			$dialog.append($("<div>", {"class": "extraUserDialogInfo"}).text(i18n.message("query.condition.widget.extra.users.info")));
			$dialog.append($("<span>", { "class": "extraUserSpan"}));
			$("body").append($dialog);

			var $span = $dialog.find(".extraUserSpan");
			$span.membersField([], {
				searchOnAllUsers : true,
				multiple: true,
				includeDisabledUsers: true
			});
			setTimeout(function() {
				$span.referenceFieldAutoComplete();
				$span.find("ul input").first().focus();
				$span.find(".popupButton").hide();
			}, 200);

			$dialog.dialog({
				autoOpen: true,
				modal: true,
				dialogClass: 'popup',
				width: 600,
				title: i18n.message("query.condition.widget.add.extra.users"),
				buttons: [
					{
						text: i18n.message("button.ok"),
						"class": "button",
						click: function() {
							var inputValue = $dialog.find('input[type="hidden"]').val();
							if (inputValue == null || inputValue == "") {
								$(this).dialog("destroy");
								return;
							}
							var userIds = [];
							var values = inputValue.split(",");
							for (var i = 0; i < values.length; i++) {
								var value = values[i];
								var valueParts = value.split("-");
								userIds.add(valueParts[1]);
							}
							loadExtraUsers(userIds, $selector, $button, $dialog);
						}
					},
					{
						text: i18n.message("button.cancel"),
						"class": "cancelButton",
						click: function() {
							$(this).dialog("destroy");
						}
					}
				]
			});
		});
		$extraUserContainer.append($extraUserLabel);
		$widgetHeader.append($extraUserContainer);
	};

	var getProjectIds = function(containerId) {
		var config = configByInstance[containerId];
		if (config.projectId && config.projectId != 0) {
			return [config.projectId];
		}
		var projectIds = [];
		config.container.find(".projectSelector").each(function () {
			var selected = $(this).multiselect("getChecked");
			selected.each(function () {
				var projectId = parseInt($(this).val(), 10);
				if (projectId != 0) {
					projectIds.push(projectId);
				}
			});
		});
		return $.unique(projectIds);
	};

	// Choice lists

	var renderFieldChoices = function(result, $selector) {
		$selector.empty();
		$selector.append($("<option>", { value: 0, "class": "anyValue" }).text(i18n.message("tracker.field.value.any")));
		if (result.hasOwnProperty("countries")) {
			for (var country in result.countries) {
				$selector.append($("<option>", { value: "'" + result.countries[country] + "'"}).text(country));
			}
		}
		if (result.hasOwnProperty("languages")) {
			for (var language in result.languages) {
				$selector.append($("<option>", { value: "'" + result.languages[language] + "'"}).text(language));
			}
		}
		if (result.hasOwnProperty("meanings")) {
			var $meaningOptGroup = $("<optgroup>", { "class": "meaning", "label" : i18n.message("tracker.choice.flags.label")});
			var cbQlAttrName = result.hasOwnProperty("meaningCbQLAttrName") ? result.meaningCbQLAttrName : "";
			$meaningOptGroup.data("cbQlAttrName", cbQlAttrName);
			for (var i=0; i < result.meanings.length; i++) {
				var meaning = result.meanings[i];
				$meaningOptGroup.append($("<option>", { "class" : "meaningOption", value : meaning.id }).text(meaning.name));
			}
			$selector.append($meaningOptGroup);
		}
		if (result.hasOwnProperty("choices")) {
			var optionsByTracker = result.choices;
			for (var i=0; i < optionsByTracker.length; i++) {
				var tracker = optionsByTracker[i];
				var $trackerOptGroup = $("<optgroup>", { "label" : truncateText(tracker.name) });
				var options = tracker.fieldOptions;
				for (var j=0; j < options.length; j++) {
					var option = options[j];
					var optionValueId = "" + tracker.projectId + "_" + tracker.trackerId + "_" + option.name;
					$trackerOptGroup.append($("<option>", { value : optionValueId }).text(option.localizedName));
				}
				$selector.append($trackerOptGroup);
			}
		}
	};

	var getFieldChoicesJSON = function(containerId, fieldId, isCountry, isLanguage, customFieldTrackerId, callback) {
		var projectIds = getProjectIds(containerId);
		var trackerIds = customFieldTrackerId == null ? getTrackerIds(containerId) : [customFieldTrackerId];
		var data = {
			field_id: fieldId,
			is_country: isCountry,
			is_language: isLanguage
		};
		if (projectIds.length > 0) {
			data["project_id_list"] = projectIds.join(",");
		}
		if (trackerIds.length > 0) {
			data["tracker_id_list"] = trackerIds.join(",");
		}
		showAjaxLoading(containerId);
		$.ajax({
			url: contextPath + "/ajax/queryCondition/getFieldChoices.spr",
			dataType: "json",
			data: data,
			async: false,
			success: function(result) {
				hideAjaxLoading(containerId);
				callback(result);
			}
		});
	};

	// Users

	var batchSize = 500;

	var renderUsersInBatch = function(users, $optGroup, $selector) {
		var index = 0;
		function doBatch() {
			var count = batchSize;
			while (count-- && index < users.length) {
				var user = users[index];
				if (user) {
					$optGroup.append($("<option>", { value : "user_" + user.id }).text(user.aliasName + " (" + user.realName + (user.emailDomain.length > 0 ? ", " + user.emailDomain : "") + ")"));
				}
				++index;
			}
			if (index < users.length) {
				setTimeout(doBatch(), 500);
			}
		}
		doBatch();
	};

	var renderUsers = function(result, $selector, inBatch) {
		if (inBatch) {
			var busy = ajaxBusyIndicator.showBusyPage();
		}
		var fieldObject = $selector.data("fieldObject");
		$selector.empty();
		$selector.append($("<option>", { value: 0, "class": "anyValue" }).text(i18n.message("tracker.field.value.any")));
		$selector.append($("<option>", { value: -1, "class": "currentUser" }).text(i18n.message("query.condition.widget.current.user")));
		if (result.hasOwnProperty("users")) {
			var $usersOptGroup = $("<optgroup>", { "class" : "users", "label" : i18n.message("tracker.field.Users.label")});
			if (inBatch) {
				$selector.append($usersOptGroup);
				renderUsersInBatch(result.users, $usersOptGroup, $selector);
			} else {
				for (var i=0; i < result.users.length; i++) {
					var user = result.users[i];
					$usersOptGroup.append($("<option>", { "class": user.disabled ? "disabledUser" : "", value : "user_" + user.id }).text(user.aliasName + " (" + user.realName + (user.emailDomain.length > 0 ? ", " + user.emailDomain : "") + ")"));
				}
				$selector.append($usersOptGroup);
			}
		}
		if (inBatch) {
			ajaxBusyIndicator.close(busy);
		}
		if (fieldObject.cbQLAttributeName != "submittedBy" && fieldObject.cbQLAttributeName != "modifiedBy" && result.hasOwnProperty("roles")) {
			var $roleOptGroup = $("<optgroup>", { "label" : i18n.message("tracker.fieldAccess.roles.label")});
			for (var i=0; i < result.roles.length; i++) {
				var role = result.roles[i];
				$roleOptGroup.append($("<option>", { value : "role_" + role.roleId, "class": "roleOption" }).text(role.roleLabel));
			}
			$selector.append($roleOptGroup);
		}
	};

	var getUserChoicesJSON = function(containerId, callback, async) {
		async = async || false;
		var projectIds = getProjectIds(containerId);
		var data = {};
		if (projectIds.length > 0) {
			data["project_id_list"] = projectIds.join(",");
		}
		showAjaxLoading(containerId);
		if (!async) {
			var busy = ajaxBusyIndicator.showBusyPage();
		}
		$.ajax({
			url: contextPath + "/ajax/queryCondition/getUsers.spr",
			dataType: "json",
			data: data,
			async: async,
			success: function(result) {
				hideAjaxLoading(containerId);
				if (!async) {
					ajaxBusyIndicator.close(busy);
				}
				callback(result);
			}
		});
	};

	var getProjects = function(containerId, callback) {
		var config = configByInstance[containerId];
		if (config.projectId && config.trackerId) {
			hideAjaxLoading(containerId);
			callback();
			return;
		}
		var filterProjectIdList = null;
		if (config.filterProjectIds != null || config.filterProjectIds !== "null") {
			filterProjectIdList = config.filterProjectIds;
		}
		$.getJSON(contextPath + "/ajax/queryCondition/getProjects.spr", { filter_project_id_list : filterProjectIdList}).done(function(result) {
			var recent = result.recent;
			var all = result.all;
			var $selector = config.container.find(".projectSelector");
			$selector.empty();
			$selector.append($("<option>", { value: 0, "class": "anyValue" }).text(i18n.message("tracker.field.value.any")));
			if (config.reportPage) {
				$selector.append($("<option>", { value: -1, "class": "currentProject" }).text(i18n.message("query.condition.widget.current.project")));
			}
			var $recentGroup = $("<optgroup>", { label: i18n.message("recent.projects.label") });
			for (var i=0; i < recent.length; i++) {
				var project = recent[i];
				$recentGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
			}
			$selector.append($recentGroup);
			var $allGroup = $("<optgroup>", { label: i18n.message("my.open.issues.all.projects") });
			for (var i=0; i < all.length; i++) {
				var project = all[i];
				$allGroup.append($("<option>", { value : project.id }).text(truncateText(project.name)));
			}
			$selector.append($allGroup);
			$selector.multiselect("refresh");
			$selector.change(function() {
				reloadIfProjectChange(containerId);
			});
			if (config.initData.hasOwnProperty("projectIds") && config.initData.projectIds.length > 0) {
				checkSelectedValues($selector, config.initData.projectIds);
			} else {
				checkFirstOption($selector);
			}
			hideAjaxLoading(containerId);
			callback();
		});
	};

	var reloadIfProjectChange = function(containerId) {
		if (configByInstance[containerId].projectId && configByInstance[containerId].trackerId) {
			return;
		}
		getTrackersJSON(containerId, function(result) {
			// Reload trackers
			configByInstance[containerId]["container"].find(".trackerSelector").each(function() {
				var originalValues = $(this).val();
				renderTrackers(result, $(this));
				var checkedNum = 0;
				if (originalValues && originalValues.length > 0) {
					checkedNum = checkSelectedValues($(this), originalValues);
				}
				if (checkedNum == 0) {
					checkFirstOption($(this));
				}
				$(this).multiselect("refresh");
				reloadIfTrackerChange(containerId);
			});
		});
	};

	var reloadIfTrackerChange = function(containerId) {
		var config = configByInstance[containerId];
		if (config.projectId && config.trackerId) {
			return;
		}
		getFields(containerId);
		if (config.reportPage) {
			$('#treePane').jstree(true).refresh();
		}
		config.container.find(".choiceFieldSelector").each(function() {
			var $choiceFieldSelector = $(this);
			var originalValues = $choiceFieldSelector.val();
			var fieldObject = $choiceFieldSelector.data("fieldObject");
			var fieldId = fieldObject.id;
			var isCountry = fieldObject.inputType == 9;
			var isLanguage = fieldObject.inputType == 8;
			var customFieldTrackerId = fieldObject.customField ? fieldObject.trackerId : null;
			getFieldChoicesJSON(containerId, fieldId, isCountry, isLanguage, customFieldTrackerId, function(result) {
				renderFieldChoices(result, $choiceFieldSelector);
				var checkedNum = 0;
				if (originalValues && originalValues.length > 0) {
					checkedNum = checkSelectedValues($choiceFieldSelector, originalValues);
				}
				if (checkedNum == 0) {
					checkFirstOption($choiceFieldSelector);
				}
				$choiceFieldSelector.multiselect("refresh");
				var $button = $choiceFieldSelector.multiselect("getButton");
				var $widget = $choiceFieldSelector.multiselect("widget");
				var $widgetHeader = $widget.find(".ui-widget-header");
				if ($button.data("isNot")) {
					setTimeout(function() {
						activateNot($widgetHeader, $button);
					}, 200);
				}
				if ($button.data("isEmpty")) {
					setTimeout(function() {
						activateEmpty($widgetHeader, $button);
					}, 200);
				}
			});
		});
		var trackerIds = getTrackerIds(containerId);
		if (trackerIds.length !== 1) {
			config.container.find(".groupArea").find(".droppableField").each(function() {
				var fieldObject = $(this).data("fieldObject");
				if (fieldObject.customField) {
					$(this).find(".removeDroppableButton").click();
				}
			});
		}
	};

	var getProjectIds = function(containerId) {
		var config = configByInstance[containerId];
		if (config.projectId && config.projectId != 0) {
			return [config.projectId];
		}
		var projectIds = [];
		config.container.find(".projectSelector").each(function () {
			var selected = $(this).multiselect("getChecked");
			selected.each(function () {
				var projectId = 0;
				try {
					projectId = parseInt($(this).val(), 10);
				} catch (e) {
					//
				}
				if (projectId != 0) {
					projectIds.push(projectId);
				}
			});
		});
		return $.unique(projectIds);
	};

	var getTrackerIds = function(containerId) {
		var config = configByInstance[containerId];
		if (config.trackerId && config.trackerId != 0) {
			return [config.trackerId];
		}
		var trackerIds = [];
		config.container.find(".trackerSelector").each(function () {
			var selected = $(this).multiselect("getChecked");
			selected.each(function () {
				var trackerId = parseInt($(this).val(), 10);
				if (trackerId != 0) {
					trackerIds.push(trackerId);
				}
			});
		});
		return $.unique(trackerIds);
	};

	var renderTrackers = function(result, $selector, withoutAny) {
		$selector.empty();
		if (!withoutAny) {
			$selector.append($("<option>", { value: 0, "class": "anyValue" }).text(i18n.message("tracker.field.value.any")));
		}
		for (var i=0; i < result.length; i++) {
			var project = result[i];
			var $projectGroup = $("<optgroup>", { label: i18n.message("project.label") + ": " + truncateText(project.name) });
			var trackers = project.trackers;
			for (var j=0; j < trackers.length; j++) {
				var tracker = trackers[j];
				if (!tracker.hidden || tracker.forceDisplay) {
					var optionProperties = { value : tracker.id, "data-hidden":  tracker.hidden };
					if (tracker.hasOwnProperty("isBranch") && tracker.isBranch) {
						var clazz = "branchTracker ";
						if (tracker.hasOwnProperty("level")) {
							var level = tracker["level"];
							level = Math.min(level, 6); // maximum six depth of levels is supported in the list.
							clazz += "level-" + level;
						}
						optionProperties["class"] = clazz;
					}
					var $option = $("<option>", optionProperties).text(truncateText(tracker.name));
					$projectGroup.append($option);
				}
			}
			for (var j=0; j < trackers.length; j++) {
				var tracker = trackers[j];
				if (!tracker.isRepository && tracker.hidden && !tracker.forceDisplay) {
					var optionProperties = { value : tracker.id, "data-hidden":  true, "class" : "hiddenTracker", title: i18n.message("report.selector.hidden.tracker.label") };
					var $option = $("<option>", optionProperties).text(truncateText(tracker.name));
					$projectGroup.append($option);
				}
			}
			$selector.append($projectGroup);
		}
	};

	var getTrackersJSON = function(containerId, callback, withoutProjects) {
		var projectIds = withoutProjects ? [] : getProjectIds(containerId);
		showAjaxLoading(containerId);
		var config = configByInstance[containerId];
		var filterTrackerIdList = null;
		if (config.filterTrackerIds != null || config.filterTrackerIds !== "null") {
			filterTrackerIdList = config.filterTrackerIds;
		}

		var onlyBranchableTrackers = false;
		if (config.onlyBranchableTrackers) {
			onlyBranchableTrackers = config.onlyBranchableTrackers;
		}
		$.getJSON(contextPath + "/ajax/queryCondition/getTrackers.spr", {
				project_id_list : projectIds.join(","),
				filter_tracker_id_list: filterTrackerIdList,
				onlyBranchableTrackers: onlyBranchableTrackers
			}).done(function(result) {
			hideAjaxLoading(containerId);
			callback(result);
		});
	};

	var getTrackers = function(containerId, callback) {
		var config = configByInstance[containerId];
		if (config.projectId && config.trackerId) {
			hideAjaxLoading(containerId);
			callback();
			return;
		}
		getTrackersJSON(containerId, function(result) {
			var $selector = config.container.find(".trackerSelector");
			renderTrackers(result, $selector);
			$selector.multiselect("refresh");
			$selector.change(function() {
				reloadIfTrackerChange(containerId);
			});
			var checkedNum = 0;
			if (config.initData.hasOwnProperty("trackerIds") && config.initData.trackerIds.length > 0) {
				checkedNum = checkSelectedValues($selector, config.initData.trackerIds);
			}
			if (checkedNum == 0) {
				checkFirstOption($selector);
			}
			// wait a bit to ensure finishing multiselect refresh
			setTimeout(function() {
				callback();
			}, 100);
		});
	};

	var getProjectSelectorMultiselectOptions = function(containerId) {
		var config = configByInstance[containerId];
		return {
			classes: "queryConditionSelector projectAndTrackerSelector",
			minWidth: 100,
			checkAllText : "",
			uncheckAllText: "",
			menuHeight: "auto",
			selectedText: function(numChecked, numTotal, checkedItems) {
				if (config.useSimpleSelectedText && numChecked > 1 && $(this.element).is('.trackerSelector')) {
					return i18n.message('report.selector.selected.label', numChecked);
				}
				var value = [];
				var $checkedItems = $(checkedItems);
				var isNot = false;
				var labelValueNot = "<span class=\"labelValueNot\"" + (!isNot ? "style=\"display: none\"" : "") + "> " + i18n.message("query.condition.widget.not") + " </span>";
				if ($checkedItems.first().closest("li").hasClass("anyValue")) {
					return labelValueNot + "<span class=\"labelValueText\">" + i18n.message("tracker.field.value.any") + "</span>";
				}
				$checkedItems.each(function(){
					var valueString = $(this).next().html();
					value.push(valueString);
				});
				var joinedText = value.join(", ");
				return labelValueNot + "<span class=\"labelValueText\">" + truncateText(joinedText) + "</span>";
			},
			noneSelectedText: function() {
				return " - ";
			},
			create: function(event, ui) {
				// remove check/uncheck all/close buttons
				$(".queryConditionSelector .ui-multiselect-all").closest("ul").remove();
				var $button = $(this).multiselect("getButton");
				if ($(this).hasClass("projectSelector") && config.projectId) {
					$button.hide();
					config.container.find(".projectSelectorLabel").hide();
				}
				if ($(this).hasClass("trackerSelector") && config.trackerId) {
					$button.hide();
					config.container.find(".trackerSelectorLabel").hide();
				}
			},
			open: function() {
				var $widget = $(this).multiselect("widget");
				var $button = $(this).multiselect("getButton");
				$widget.position({
					my: "left top",
					at: "left bottom",
					of: $button,
					collision: "flipfit",
					using : null,
					within: window
				});
				setTimeout(function() {
					$widget.find(".ui-multiselect-filter input").focus();
				}, 100);
				$("div.queryConditionSelector").hide();
				$widget.show();
			},
			click: function(event, ui) {
				var $menu = $(this).multiselect("widget");
				if ($(this).hasClass("projectSelector") && ui.value == "-1" && !ui.checked) {
					clearCurrentProject(containerId);
				}
				if (ui.value != "on") {
					var selected = $(this).multiselect("getChecked").filter(":not(.additionalCheckbox)");
					if (selected.length == 0) {
						$menu.find("[value=0]").attr("checked", true);
					}
					if (ui.checked) {
						if (ui.value == 0) {
							$menu.find(":checkbox:checked").filter(":not(.additionalCheckbox)").each(function() {
								var $that = $(this);
								if ($that.val() != 0 && $that.is(":checked")) {
									$that.attr("checked", false);
								}
							});
						} else {
							$menu.find("[value=0]").attr("checked", false);
						}
					} else if (!ui.checked && ui.value == 0) {
						$menu.find("[value=0]").attr("checked", true);
					}
				}
			}
		};
	};

	var initProjectSelector = function(containerId, $selector, singleSelect, classes) {
		var multiSelectOptions = getProjectSelectorMultiselectOptions(containerId);
		multiSelectOptions["classes"] = "queryConditionSelector projectAndTrackerSelector " + classes;
		if (singleSelect) {
			multiSelectOptions["multiple"] = false;
		}
		$selector.multiselect(multiSelectOptions).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});
	};

	var initProjectAndTrackerSelector = function(containerId) {
		var config = configByInstance[containerId];
		config.container.find(".projectSelector").data("cbQLAttrName", "project.id");
		config.container.find(".trackerSelector").data("cbQLAttrName", "tracker.id");

		if (config.projectId && config.trackerId) {
			return;
		}

		var multiselectOptions = getProjectSelectorMultiselectOptions(containerId);

		if (!config.autoHeight) {
			multiselectOptions['height'] = 230;
		}

		config.container.find(".projectSelector, .trackerSelector").multiselect(multiselectOptions).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});

		config.container.find(".currentProjectPlaceholder a.setCurrentProjectButton").click(function() {
			var currentProjectId = config.container.find(".currentProjectPlaceholder").attr("data-id");
			showCurrentProjectWarning(containerId, currentProjectId);
			return false;
		});

		config.container.find(".currentProjectPlaceholder a.clearCurrentProjectButton").click(function() {
			clearCurrentProject(containerId);
			return false;
		});
	};

	var decodeReferences = function(values) {
		var result = [];
		if (values && values.length > 0) {
			var parts = values.split(",");
			if (parts.length > 0) {
				for (var i = 0; i < parts.length; i++) {
					var value = parts[i];
					var decodedValue = decodeReferenceValue(value);
					if (decodedValue !== null) {
						result.push(decodedValue);
					}
				}
			}
		}
		return result;
	};

	var decodeReferenceValue = function(value) {
		var parts = value.split("-");
		try {
			return parseInt(parts[1], 10);
		} catch (ex) {
			try {
				return parseInt(value);
			} catch (ex2) {
				return null;
			}
		}
		return null;
	};

	var getDataFromContextMenuItemKey = function(itemKey, trackerIds) {
		var fieldId = itemKey;
		var fieldTrackerId = null;
		var fieldProps = itemKey.split("_");
		if (fieldProps.length > 1) {
			fieldId = fieldProps[1];
			fieldTrackerId = fieldProps[0];
		}
		var data = {
			field_id: fieldId
		};
		if (fieldTrackerId == null && trackerIds.length == 1) {
			fieldTrackerId = trackerIds[0];
		}
		if (fieldTrackerId != null) {
			data["tracker_id"] = fieldTrackerId;
		}
		return data;
	};

	var insertFieldContextMenuCallback = function(containerId, itemKey, trackerIds, $trigger) {
		var config = configByInstance[containerId];
		if (isLogicInvalid(containerId, config.logicEnabled)) {
			return showInvalidLogicWarning(containerId);
		}
		if (isResizeableColumnsEnabled(containerId) && config.resultContainer.find("th[data-fieldlayoutid]").length > MAXIMUM_RESIZEABLE_FIELD_NUMBER) {
			showMaximumResizeableColumnsWarning();
			return false;
		}
		var data = getDataFromContextMenuItemKey(itemKey, trackerIds);
		insertColumn(containerId, $trigger.closest("th"), $("<span>", { "data-fieldlayoutid" : data.field_id, "data-customfieldtrackerid" : data.tracker_id }));
	};

	var insertFieldContextMenuDisabledCallback = function(containerId, itemKey, trackerIds) {
		var data = getDataFromContextMenuItemKey(itemKey, trackerIds);
		var existingFields = getFieldsFromTable(containerId);
		for (var i = 0; i < existingFields.length; i++) {
			var existingField = existingFields[i];
			var existingFieldId = existingField[0];
			var existingFieldTrackerId = existingField[1];
			if (parseInt(data.field_id, 10) == existingFieldId &&
				((existingFieldTrackerId == null && !data.hasOwnProperty("tracker_id")) ||
					parseInt(data.tracker_id, 10) == existingFieldTrackerId)) {
				return true;
			}
		}
		return false;
	};

	var initFilterSelectors = function(containerId) {
		var config = configByInstance[containerId];

		var initSelector = function(htmlId, $toPosition, callback) {
			var $filterSelector = $("select#" + htmlId + "_" + containerId);
			var isGroupBy = htmlId == "groupBySelector";
			var isOrderBy = htmlId == "orderBySelector";
			var isAddField = htmlId == "addFieldSelector";

			var setPosition = function($widget, $position) {
				$widget.position({
					my: "left top",
					at: "left bottom" + (!config.reportPage ? "+8" : ""),
					of: $position ? $position : $toPosition,
					collision: "flipfit",
					using : null,
					within: window
				});
			};

			var settings = {
				classes: "queryConditionSelector filterSelector " + htmlId,
				minWidth: 100,
				height: 400,
				menuHeight: "auto",
				checkAllText : "",
				uncheckAllText: "",
				open: function() {
					var $widget = $(this).multiselect("widget");
					setPosition($widget, $toPosition == null ? $(this).data("triggeringColumn") : null);
					setTimeout(function() {
						$widget.find(".ui-multiselect-filter input").focus();
					}, 100);
				},
				create: function() {
					$(".filterSelector .ui-multiselect-all").closest("ul").remove();
					var $that = $(this);
					var $widget = $(this).multiselect("widget");
					var $widgetHeader = $widget.find(".ui-widget-header");

					if ((!config.reportPage || (config.reportPage && (isGroupBy || isOrderBy))) && !isAddField) {
						var $clearLink = $("<a>", { "class": "clearAllButton", href: "#", title: i18n.message("report.selector.clear.filters.tooltip")}).text(i18n.message("report.selector.clear.filters.label"));
						$clearLink.click(function() {
							if ($widget.is(".groupBySelector")) {
								config.container.find(".groupArea").find(".droppableField").each(function() {
									$(this).find(".removeDroppableButton").click();
								});
							} else if ($widget.is(".orderBySelector")) {
								config.container.find(".orderByArea").find(".droppableField").each(function() {
									$(this).find(".removeDroppableButton").click();
								});
							} else {
								config.container.find(".fieldArea .modifiableArea").find(".removeIcon").each(function() {
									$(this).click();
								});
							}
							$that.multiselect("close");
						});
						$widgetHeader.append($clearLink);
					}

				},
				click: callback
			};
			$filterSelector.multiselect(settings).multiselectfilter({
				label: "",
				placeholder: i18n.message("Filter")
			});
		};

		var getFieldProperties = function($multiSelect, ui, callback) {
			var data = getFieldData(containerId, ui.value);
			$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
				dataType: "json",
				data: data,
				async: false
			}).done(function (fieldObject) {
				if (fieldObject == null) {
					showFancyAlertDialog(i18n.message("query.widget.unsupported.field"));
					return false;
				}
				try {
					$multiSelect.multiselect("close");
					callback(containerId, fieldObject);
				} catch (e) {
					showFancyAlertDialog(e);
					return false;
				}
			});
		};

		initSelector("filterSelector", config.container.find(config.reportPage ? ".addButton" : ".filterLabel"), function(event, ui) {
			var $multiSelect = $(this);
			if (ui.value == "include") {
				$multiSelect.multiselect("close");
				renderIncludePart(containerId, true);
			} else if (ui.value == "documentViewRating" || ui.value == "documentViewReference" || ui.value == "documentViewBranchStatus") {
				$multiSelect.multiselect("close");
				renderSpecialChoiceField(containerId, ui.value, ui.text, null, true);
			} else if (ui.value == "-34") { // unresolved dependency
				renderBooleanField(containerId, i18n.message("query.widget.hasUnresolvedDependency.label"), "hasUnresolvedDependency", "true", null, true);
				storeRecentField(containerId, {
					id: -34,
					customField: false,
					label: i18n.message("query.widget.hasUnresolvedDependency.label")
				});
			} else {
				getFieldProperties($multiSelect, ui, function(containerId, fieldObject) {
					renderField(containerId, fieldObject, true, null);
				});
			}
		});

		if (config.showGroupBy) {
			initSelector("groupBySelector", config.container.find(config.reportPage ? ".addGroupByButton" : ".groupByLabel"), function(event, ui) {
				var $multiSelect = $(this);
				getFieldProperties($multiSelect, ui, function(containerId, fieldObject) {
					addOrderByOrGroupByBadge(containerId, config.container.find(".groupArea .selectorContainer"), fieldObject, false, "TO_DAY");
				});
			});
		}

		if (config.showOrderBy) {
			initSelector("orderBySelector", config.container.find(config.reportPage ? ".addOrderByButton" : ".orderByLabel"), function(event, ui) {
				var $multiSelect = $(this);
				getFieldProperties($multiSelect, ui, function(containerId, fieldObject) {
					addOrderByOrGroupByBadge(containerId, config.container.find(".orderByArea .selectorContainer"), fieldObject, false);
				});
			});
		}

		initSelector("addFieldSelector", null, function(event, ui) {
			var $addFieldSelector = $("select#addFieldSelector_" + containerId);
			if (intelligentTableViewIsEnabled(containerId)) {
				codebeamer.IntelligentTableView.addFieldToTable($addFieldSelector.data("triggeringColumn"), ui.value);
			} else {
				insertFieldContextMenuCallback(containerId, ui.value, getTrackerIds(containerId), $addFieldSelector.data("triggeringColumn"));
			}
			$addFieldSelector.multiselect("close");
			createSelector(containerId, "addFieldSelector", config.fieldResult);
		});

	};

	var disableGroupsForGroupBy = ["recent", "extraReference", "extraSuspected", "extraReview"];
	var disableGroupsForOrderBy = ["recent", "extraReference", "extraSuspected", "extraReview", "extraTag"];
	var disableGroupsForAddField = ["recent", "extraReference", "extraSuspected", "extraReview", "extraTag"];

	var PLANNER_EXCLUDE_FIELD_IDS = ["31", "81"];

	var populateFieldNodes = function(containerId, $selector, $originalSelector, nodes, isGroupBy, isOrderBy, isAddField) {
		for (var i = 0; i < nodes.length; i++) {
			var node = nodes[i];
			if (node.id == "recent" || (node.hasOwnProperty("children") &&  node.children.length > 0)) {
				if ((isGroupBy && $.inArray(node.id, disableGroupsForGroupBy) > -1) ||
					(isOrderBy && $.inArray(node.id, disableGroupsForOrderBy) > -1) ||
					(isAddField && $.inArray(node.id, disableGroupsForAddField) > -1)) {
					continue;
				}
				var $optGroup = $("<optgroup>", { label: node.text });
				if (node.id == "recent") {
					$optGroup.attr("class", "recentFilters");
				}
				$originalSelector.append($optGroup);
				populateFieldNodes(containerId, $optGroup, $originalSelector, node.children, isGroupBy, isOrderBy, isAddField);
			} else {
				if (!isOrderBy && node.id === "0") {
					continue;
				}
				if (configByInstance[containerId].isPlanner && $.inArray(node.id, PLANNER_EXCLUDE_FIELD_IDS) > -1) {
					continue;
				}
				$selector.append($("<option>", { value: node.id }).text(node.text));
			}
		}
	};

	var createSelector = function(containerId, htmlId, result, callback) {
		if (!result) {
			result = configByInstance[containerId].fieldResult;
		}
		var $selector = $("select#" + htmlId + "_" + containerId);
		$selector.empty();
		populateFieldNodes(containerId, $selector, $selector, result, htmlId == "groupBySelector", htmlId == "orderBySelector", htmlId == "addFieldSelector");
		var optGroupLabel = null;
		$selector.find("optgroup:not(.recentFilters)").each(function() {
			if (optGroupLabel != null && $(this).children().length > 0) {
				$(this).attr("label", optGroupLabel + " → " + $(this).attr("label"));
			}
			if ($(this).children().length == 0) {
				optGroupLabel = $(this).attr("label");
			}
		});
		if (typeof callback !== "undefined") {
			callback($selector);
		}
		$selector.multiselect("refresh");
	};

	var createFilterSelectors = function(containerId, result) {

		var config = configByInstance[containerId];

		createSelector(containerId, "filterSelector", result, function($selector) {
			var $other = $("<optgroup>", { label: i18n.message("queries.extra.other.label")});
			$other.append($("<option>", { value: "include" }).text(i18n.message("queries.include.label")));
			if (config.isPlanner || config.isDocumentView) {
				$other.append($("<option>", { value: "documentViewRating"}).text(i18n.message("rating.average.rating.label")));
			}
			if (config.isDocumentView) {
				$other.append($("<option>", { value: "documentViewReference"}).text(i18n.message("tracker.view.filtering.references")));
				if (config.isBranchMode) {
					$other.append($("<option>", { value: "documentViewBranchStatus"}).text(i18n.message("tracker.branching.branch.status.filter")));
				}
			}
			$selector.append($other);
		});
		if (config.showGroupBy) {
			createSelector(containerId, "groupBySelector", result, function($selector) {
				var $other = $("<optgroup>", { label: i18n.message("queries.extra.other.label")});
				if (!config.projectId) {
					$other.append($("<option>", { value: 72 }).text(i18n.message("project.label")));
				}
				if (!config.trackerId) {
					$other.append($("<option>", { value: -1 }).text(i18n.message("tracker.label")));
					$other.append($("<option>", { value: 1 }).text(i18n.message("query.widget.tracker.type.label")));
				}
				if ($other.find("option").length > 0) {
					$selector.append($other);
				}
			});
		}
		if (config.showOrderBy) {
			createSelector(containerId, "orderBySelector", result, function($selector) {
				var $other = $("<optgroup>", { label: i18n.message("queries.extra.other.label")});
				if (!config.trackerId) {
					$other.append($("<option>", { value: -14 }).text(i18n.message("query.condition.widget.order.by.tracker")));
				}
				if ($other.find("option").length > 0) {
					$selector.append($other);
				}
			});
		}

		createSelector(containerId, "addFieldSelector", result);

	};

	var getTrackerIdsForField = function(containerId) {
		var config = configByInstance[containerId];
		var trackerIds = getTrackerIds(containerId);
		var data = {};
		if (trackerIds.length > 0) {
			return trackerIds;
		}
		if (config.filterTrackerIds) {
			return config.filterTrackerIds.split(",");
		}
		return trackerIds;
	};

	var getFieldData = function(containerId, fieldId) {
		var trackerIds = getTrackerIdsForField(containerId);
		var fieldTrackerId = null;
		var fieldProps = fieldId.split("_");
		if (fieldProps.length > 1) {
			fieldId = fieldProps[1];
			fieldTrackerId = fieldProps[0];
		}
		var data = {
			field_id: fieldId
		};
		if (fieldTrackerId == null && trackerIds.length == 1) {
			fieldTrackerId = trackerIds[0];
		}
		if (fieldTrackerId != null) {
			data["tracker_id"] = fieldTrackerId;
		}
		return data;
	};


	var getFields = function(containerId) {
		var config = configByInstance[containerId];
		var trackerIds = getTrackerIds(containerId);
		var projectIds = getProjectIds(containerId);
		var data = {
			addExtraFields : true
		};
		if (projectIds.length > 0) {
			data["project_ids"] = projectIds.join(",");
		} else if (config.filterProjectIds) {
			data["project_ids"] = config.filterProjectIds;
		}
		if (trackerIds.length > 0) {
			data["tracker_ids"] = trackerIds.join(",");
		} else if (config.filterTrackerIds) {
			data["tracker_ids"] = config.filterTrackerIds;
			trackerIds = config.filterTrackerIds.split(",");
		}

		$.ajax({
			url: contextPath + "/ajax/queries/getFields.spr",
			dataType: "json",
			data: data,
			async: false,
			success: function(result) {
				createFilterSelectors(containerId, result);
				config.fieldResult = result;
				refreshExistingFieldLabels(containerId, result);
			}
		});
	};

	var refreshExistingFieldLabels = function(containerId, result) {
		var config = configByInstance[containerId];

		var createFieldIdAndNameMap = function(result) {
			var fieldMap = {};
			// Get only Default and Common Reference Fields
			for (j = 0; j <= 1; j++) {
				for (var i = 0; i < result[j].children.length; i++) {
					var field = result[j].children[i];
					var fieldId = parseInt(field.id, 10);
					fieldMap[fieldId] = field.text;
				}
			}
			return fieldMap;
		};

		var fields = createFieldIdAndNameMap(result);
		var $filterContainer = config.container.find(".fieldArea");
		$filterContainer.find(".queryConditionSelector").each(function() {
			var fieldObject = $(this).data("fieldObject");
			if (fieldObject && fieldObject.id < 1000) { //only default fields
				var fieldName = fields[fieldObject.id];
				if (typeof fieldName !== "undefined") {
					$(this).find("span b").text(fieldName);
				}
			}
		});
		var $groupAndOrderByArea = config.container.find(".groupArea, .orderByArea");
		$groupAndOrderByArea.find(".droppableField").each(function() {
			var fieldObject = $(this).data("fieldObject");
			var fieldName = fields[fieldObject.id];
			if (typeof fieldName !== "undefined") {
				$(this).contents().first().replaceWith(fieldName);
			}
		});
	};

	var disableFieldsIfNecessary = function(containerId, $selector) {
		$selector.find("option").prop("disabled", false);
		var fieldIds = $selector.data("disabledFieldIds");
		if (fieldIds && fieldIds.length > 0) {
			for (var i = 0; i < fieldIds.length; i++) {
				$selector.find('option[value="' + fieldIds[i] + '"]').prop("disabled", true);
			}
		}
		$selector.multiselect("refresh");
	};

	var toggleDisabledActionsBecauseOfIntelligentTableView = function(containerId) {
		var config = configByInstance[containerId];
		var $groupByLabel = config.container.find(".groupByLabel");
		var $resizeableCont = config.container.find(".reportPickerContainer").find(".resizeableColumns");
		if (intelligentTableViewIsEnabled(containerId)) {
			$groupByLabel.addClass("inactive");
			$groupByLabel.attr("data-tooltip", i18n.message("intelligent.table.view.group.by.warning"));
			$resizeableCont.find("input").prop("disabled", true);
			$resizeableCont.attr("title", i18n.message("intelligent.table.view.resizable.warning"));
		} else {
			$groupByLabel.removeClass("inactive");
			$groupByLabel.attr("data-tooltip", i18n.message("query.widget.add.group.by"));
			$resizeableCont.find("input").prop("disabled", false);
			$resizeableCont.attr("title", "");
		}
	};

	var initAddButton = function(containerId) {

		var config = configByInstance[containerId];

		// Enhance Project-Tracker field context menu layout
		config.container.find(config.reportPage ? ".addButton" : ".filterLabel").click(function() {
			$("select#filterSelector_" + containerId).multiselect("open");
		});

		if (!config.reportPage) {
			config.container.find(".addButton").hide();
		}

		if (config.showGroupBy) {
			config.container.find(config.reportPage ? ".addGroupByButton" : ".groupByLabel:not(.inactive)").click(function() {
				if ($(this).is(".inactive")) {
					return false;
				}
				disableFieldsIfNecessary(containerId, $("select#groupBySelector_" + containerId));
				$("select#groupBySelector_" + containerId).multiselect("open");
			});
		}

		if (config.showOrderBy) {
			config.container.find(config.reportPage ? ".addOrderByButton" : ".orderByLabel:not(.inactive)").click(function() {
				if ($(this).is(".inactive")) {
					return false;
				}
				disableFieldsIfNecessary(containerId, $("select#orderBySelector_" + containerId));
				$("select#orderBySelector_" + containerId).multiselect("open");
			});
		}

	};

	var parseDurationValues = function(value) {
		var values = {
			"time": "h",
			"numberValue": 0
		};
		if (startsWith(value, "+")) {
			if (endsWith(value, "h")) {
				values["time"] = "h";
			} else if (endsWith(value, "min")) {
				values["time"] = "min";
			} else if (endsWith(value, "s")) {
				values["time"] = "s";
			} else {
				values["time"] = "h";
			}
			values["numberValue"] = value.replace(/[^0-9]/g,'');
		}
		return values;
	};

	var initContainer = function(containerId, queryId, queryString, doShowAlert, initial, filterAttributes) {

		var config = configByInstance[containerId];

		if (config.reportPage) {
			var busyPage = ajaxBusyIndicator.showBusyPage();
			$(document).ajaxStop(function() {
				setTimeout(function() {
					ajaxBusyIndicator.close(busyPage);
				}, 300);
			});
		}

		// Reset filter counter before initialization
		config.filterCounter = 1;

		config.initData.projectIds = [];
		config.initData.trackerIds = [];

		var showAlert = function(e) {
			if (doShowAlert) {
				var errorMessage = i18n.message(config.reportPage ? "query.widget.invalid.query.alert" : "query.widget.report.selector.invalid.alert");
				if (e && typeof e === 'string') {
					errorMessage = e;
				}
				errorMessage += " " + i18n.message("query.cbQl.error.help");
				showFancyAlertDialog(errorMessage, null, null, function() {
					if (!config.reportPage) {
						config.container.find(".searchButton").click();
					}
				});
			}
			if (config.reportPage) {
				showAdvanced(containerId, false, initial, queryString);
			}
		};

		var getProjectAndTrackerIds = function(node) {
			if (node && !$.isEmptyObject(node) && node.hasOwnProperty("left")) {
				if (node.left.hasOwnProperty("value")) {
					if (node.left.value == "project.id") {
						if (node.operator == "OR") {
							config.initData.projectIds.push(node.right.value == "current project" ? "-1" : node.right.value);
						} else if (node.operator == "IN") {
							for (var i=0; i < node.right.value.length; i++) {
								config.initData.projectIds.push(removeApostrophes(node.right.value[i].value) == "current project" ? "-1" : node.right.value[i].value);
							}
						}
					} else if (node.left.value == "tracker.id") {
						if (node.operator == "OR") {
							config.initData.trackerIds.push(node.right.value);
						} else if (node.operator == "IN") {
							for (var i=0; i < node.right.value.length; i++) {
								config.initData.trackerIds.push(removeApostrophes(node.right.value[i].value));
							}
						}
					}
				} else {
					getProjectAndTrackerIds(node.left);
				}
			}
			if (node && !$.isEmptyObject(node) && node.hasOwnProperty("right")) {
				getProjectAndTrackerIds(node.right);
			}
		};

		var decodeInclude = function(node) {
			var includeParts = node.value.split("[");
			var idParts = includeParts[1].split(":");
			return {
				includeId: parseInt(idParts[1].substring(0, idParts[1].length - 1), 10),
				isReport: idParts[0] == "REPORT"
			};
		};

		var nodesWithValues = [];
		var populateNodesWithValues = function(node, parentNode) {
			if (node && !$.isEmptyObject(node)) {
				if (node.hasOwnProperty("left") && node.left.hasOwnProperty("value") &&
					node.hasOwnProperty("right") && node.right.hasOwnProperty("value") &&
					!startsWith(node.left.value, "include") && !startsWith(node.right.value, "include")) {
					if (node.left.value != "project.id" && node.left.value != "tracker.id") {
						nodesWithValues.push({
							node: node,
							parentNodeOperator: parentNode !== null && parentNode.hasOwnProperty("operator") ? parentNode.operator : null
						});
					}
				} else if (node.hasOwnProperty("left") && node.left.hasOwnProperty("value") && node.hasOwnProperty("operator") &&
					(node.operator.toUpperCase() == "IS NULL" || node.operator.toUpperCase() == "IS NOT NULL")) {
					nodesWithValues.push({
						node: node,
						parentNodeOperator: parentNode !== null && parentNode.hasOwnProperty("operator") ? parentNode.operator : null
					});
				} else if (node.hasOwnProperty("cbQLFunction")) {
					nodesWithValues.push({
						node: node
					});
				} else {
					if (node.hasOwnProperty("left")) {
						populateNodesWithValues(node.left, node);
					}
					if (node.hasOwnProperty("right")) {
						populateNodesWithValues(node.right, node);
					}
					if (node.hasOwnProperty("value") && startsWith(node.value, "include")) {
						var includeParts = node.value.split("[");
						var idParts = includeParts[1].split(":");
						nodesWithValues.push({
							includeId: parseInt(idParts[1].substring(0, idParts[1].length - 1), 10),
							isReport: idParts[0] == "REPORT"
						});
					}
				}
			}
		};

		var isNodeUnresolvedDependency = function(node) {
			// Try to parse "workItemStatus" field if this is unresolved dependency or not - it should be handled later as a separate filter option
			var isUnresolvedDependency = false;
			try {
				isUnresolvedDependency = node.left.value == "workItemStatus" && removeApostrophes(node.right.value[0].value) == "HasUnresolvedDependency";
			} catch (e) {
				//
			}
			return isUnresolvedDependency;
		};

		var groupBySameFields = function(nodes) {
			var groupedNodes = [];
			var usedDateField = [];
			for (var i = 0; i < nodes.length; i++) {
				if (nodes[i].hasOwnProperty("node")) {
					var node = nodes[i].node;
					if (node.hasOwnProperty("left")) {
						var parentNodeOperator = nodes[i].parentNodeOperator;
						var field = node.left;
						var fieldObjectString = field.extraInformation;
						var fieldObject = $.parseJSON(fieldObjectString);
						var fieldName = fieldObject.name;
						var fieldTypeName = fieldObject.fieldTypeName;
						var isCustomMemberField = fieldObject.customField && fieldObject.cbQLRoleAttributeName != null;
						if (!isNodeUnresolvedDependency(node) && ((fieldTypeName == "choice" || fieldTypeName == "member") && ((parentNodeOperator == "OR" || ((node.operator == "NOT IN" || node.operator == "!=") && parentNodeOperator == "AND")) ||
							(isCustomMemberField && ((parentNodeOperator == "AND" && node.operator.toUpperCase() == "IS NULL") || (parentNodeOperator == "OR" && node.operator.toUpperCase() == "IS NOT NULL"))))) ||
							(fieldTypeName == "date" && (parentNodeOperator == "AND" || parentNodeOperator == "OR"))) {
							var nodeArray = [];
							nodeArray.push(node);
							for (var j = i + 1; j < nodes.length; j++) {
								var otherParentNodeOperator = nodes[j].parentNodeOperator;
								var otherNode = nodes[j].node;
								var otherField = otherNode.left;
								var otherFieldObject = $.parseJSON(otherField.extraInformation);
								var otherFieldName = otherFieldObject.name;
								var sameField = otherFieldName == fieldName;
								if (fieldObject.customField && otherFieldObject.customField) {
									sameField = fieldObject.trackerId == otherFieldObject.trackerId && fieldName == otherFieldName;
								}
								if (!isNodeUnresolvedDependency(otherNode) && sameField && (fieldTypeName == "choice" || fieldTypeName == "member") && ((otherParentNodeOperator == "OR" || ((otherNode.operator == "NOT IN" || otherNode.operator == "!=") && parentNodeOperator == "AND")) ||
									(isCustomMemberField && ((parentNodeOperator == "AND" && node.operator.toUpperCase() == "IS NULL") || (parentNodeOperator == "OR" && node.operator.toUpperCase() == "IS NOT NULL"))))) {
									nodeArray.push(otherNode);
									i = j;
								}
								if (sameField && fieldTypeName == "date") {
									nodeArray.push(otherNode);
								}
							}
							if (fieldTypeName == "date" && $.inArray(fieldName, usedDateField) > -1) {
								continue;
							} else {
								groupedNodes.push({
									fieldObject: fieldObjectString,
									fieldName: fieldName,
									nodes: nodeArray
								});
							}
							if (fieldTypeName == "date") {
								usedDateField.push(fieldName);
							}
						} else {
							var nodeArray = [];
							nodeArray.push(node);
							groupedNodes.push({
								fieldObject: fieldObjectString,
								fieldName: fieldName,
								nodes: nodeArray
							});
						}
					} else if (node.hasOwnProperty("cbQLFunction")) {
						var nodeArray = [node];
						$.ajax({
							url: contextPath + "/ajax/queryCondition/getFieldByName.spr",
							dataType: "json",
							data: {
								"field_name": removeApostrophes(node.value[0].value)
							},
							async: false,
							success: function (extraInfoResult) {
								groupedNodes.push({
									fieldObject: JSON.stringify(extraInfoResult),
									fieldName: extraInfoResult.name,
									nodes: nodeArray
								});
							}
						});
					}
				} else if (nodes[i].hasOwnProperty("includeId")) {
					groupedNodes.push({
						includeId: nodes[i].includeId,
						isReport: nodes[i].isReport
					});
				}
			}

			var normalizedGroupNodes = [];
			for (var i = 0; i < groupedNodes.length; i++) {
				var node = groupedNodes[i];
				if (!node.hasOwnProperty("includeId")) {
					var fieldObject = $.parseJSON(node.fieldObject);
					if (fieldObject.typeName == "date") {
						for (var j = 0; j < node.nodes.length; j++) {
							var fieldNode = node.nodes[j];
							var nextFieldNode = j == node.nodes.length ? null : node.nodes[j + 1];
							if (fieldNode.operator == "is null" || fieldNode.operator == "is not null" || nextFieldNode == null) {
								var nodeArray = [];
								nodeArray.push(fieldNode);
								normalizedGroupNodes.push({
									fieldObject: node.fieldObject,
									fieldName: fieldName,
									nodes: nodeArray
								});
							} else if ((fieldNode.operator == ">=" && nextFieldNode.operator == "<=") ||
								(fieldNode.operator == "<" && nextFieldNode.operator == ">")) {
								var nodeArray = [];
								nodeArray.push(node.nodes[j]);
								nodeArray.push(node.nodes[j + 1]);
								normalizedGroupNodes.push({
									fieldObject: node.fieldObject,
									fieldName: fieldName,
									nodes: nodeArray
								});
								j++;
							}
						}
					} else {
						normalizedGroupNodes.push(node);
					}
				} else {
					normalizedGroupNodes.push(node);
				}
			}

			return normalizedGroupNodes;
		};

		var initDefault = function(clear) {
			if (clear) {
				config.container.find(".selectorSection").children().each(function() {
					if ($(this).hasClass("addButton") || $(this).is("#ajaxLoadingImg")) {
						return;
					}
					$(this).remove();
				});
			}
			getProjects(containerId, function() {
				getTrackers(containerId, function() {
					//
				});
			});
		};

		var getLogicSliceNodes = function(logicSlices) {
			var oneTrackerId = null;
			var trackerIds = getTrackerIds(containerId);
			if (trackerIds.length == 1) {
				oneTrackerId = trackerIds[0];
			}
			var orderedSlices = {};
			for (var key in logicSlices) {
				if (key != "@@-1@@" && key != "@@-2@@" && key != "@@0@@") {
					var logicSlice = logicSlices[key];
					var index = parseInt(key.substring(2, key.length - 2), 10);
					orderedSlices[index] = logicSlice;
				}
			}
			var result = [];
			for (var key in orderedSlices) {
				var slice = orderedSlices[key];
				nodesWithValues = [];
				populateNodesWithValues(slice, null);
				result.push(nodesWithValues);
			}
			for (var i = 0; i < result.length; i++) {
				for (var j = 0; j < result[i].length; j++) {
					if (result[i][j].hasOwnProperty("node") &&
						result[i][j].node.hasOwnProperty("left") &&
						result[i][j].node.left.hasOwnProperty("value") &&
						!result[i][j].node.left.hasOwnProperty("extraInformation")) {
						var data = {
							"field_name" : removeApostrophes(result[i][j].node.left.value)
						};
						if (oneTrackerId != null) {
							data["tracker_id"] = oneTrackerId;
						}
						$.ajax({
							url: contextPath + "/ajax/queryCondition/getFieldByName.spr",
							dataType: "json",
							data: data,
							async: false,
							success: function (extraInfoResult) {
								result[i][j].node.left["extraInformation"] = JSON.stringify(extraInfoResult);
							}
						});
					} else if (result[i][j].hasOwnProperty("node") &&
						result[i][j].node.hasOwnProperty("cbQLFunction")) {
						$.ajax({
							url: contextPath + "/ajax/queryCondition/getFieldByName.spr",
							dataType: "json",
							data: {
								"field_name" : removeApostrophes(result[i][j].node.value)
							},
							async: false,
							success: function (extraInfoResult) {
								result[i][j].node["name"] = extraInfoResult.name;
								result[i][j].node["extraInformation"] = JSON.stringify(extraInfoResult);
							}
						});
					}
				}
			}
			var groupedNodes = [];
			for (var i = 0; i < result.length; i++) {
				var slice = result[i];
				var nodes = [];
				for (var j = 0; j < slice.length; j++) {
					nodes.push(slice[j].node);
				}
				if (slice[0].node.hasOwnProperty("left")) {
					groupedNodes.push({
						"fieldName" : slice[0].node.left.value,
						"fieldObject" : slice[0].node.left.extraInformation,
						"nodes" : nodes
					});
				} else if (slice[0].node.hasOwnProperty("cbQLFunction")) {
					groupedNodes.push({
						"fieldName" : slice[0].node.name,
						"fieldObject" : slice[0].node.extraInformation,
						"nodes" : nodes
					});
				}
			}
			return groupedNodes;
		};

		config.container.find(".fieldArea .droppableArea .modifiableArea").children(":not(.droppableAreaButton)").remove();
		config.container.find(".groupArea, .orderByArea").find(".droppableField").remove();
		config.container.find(".groupArea, .orderByArea").find(".addDroppableButton").show();

		if (config.contextualSearch) {
			config.container.find(".contextualSearchBox").val("");
			if (filterAttributes && filterAttributes != null && filterAttributes.hasOwnProperty("filter")) {
				config.container.find(".contextualSearchBox").val(filterAttributes.filter);
			}
		}

		if (typeof queryString !== "undefined" && (queryString || (queryString != null && queryString.length == 0))) {
			config.queryString = queryString;
		}

		if ((config.queryId == null || config.queryId === 0) && (config.queryString === null || config.queryString == 'null' || config.queryString.length == 0)) {
			initDefault(false);
		} else {
			var data = {};
			if (config.queryString !== null && config.queryString != 'null') {
				data.query_string = config.queryString;

				if (config.isDocumentView) {
					config["lastSelectedCbQl"] = config.queryString;
				}
			} else if (queryId != null) {
				data.query_id = queryId;
			}

			$.ajax({
				url: contextPath + "/ajax/queryCondition/getQueryStructure.spr",
				dataType: "json",
				data: data,
				type: "POST",
				async: false,
				success: function (result) {
					try {
						getProjectAndTrackerIds(result.where);
						if (config.initData.trackerIds.length > 0 && config.initData.projectIds.length == 0) {
							showAlert();
						} else {
							getProjects(containerId, function () {
								getTrackers(containerId, function () {
									reloadIfTrackerChange(containerId);
									var groupedNodes = [];
									if (config.logicEnabled) {
										groupedNodes = getLogicSliceNodes(config.logicSlices);
									} else {
										populateNodesWithValues(result.where, null);
										groupedNodes = groupBySameFields(nodesWithValues);
									}

									if (filterAttributes && filterAttributes != null) {
										if (filterAttributes.hasOwnProperty("ratingFilters") && (config.isDocumentView || config.isPlanner)) {
											renderSpecialChoiceField(containerId, "documentViewRating", i18n.message("rating.average.rating.label"), filterAttributes.ratingFilters, false);
										}
										if (filterAttributes.hasOwnProperty("referenceFilter") && config.isDocumentView) {
											renderSpecialChoiceField(containerId, "documentViewReference", i18n.message("tracker.view.filtering.references"), filterAttributes.referenceFilter, false);
										}
										if (filterAttributes.hasOwnProperty("branchStatusFilters") && config.isDocumentView) {
											renderSpecialChoiceField(containerId, "documentViewBranchStatus", i18n.message("tracker.branching.branch.status.filter"), filterAttributes.branchStatusFilters, false);
										}
									}

									for (var i = 0; i < groupedNodes.length; i++) {
										var groupedNode = groupedNodes[i];
										if (groupedNode.hasOwnProperty("includeId")) {
											renderIncludePart(containerId, false, groupedNode.includeId, groupedNode.isReport);
										} else {
											var fieldObject = $.parseJSON(groupedNode.fieldObject);
											renderField(containerId, fieldObject, false, groupedNode.nodes);
										}
									}

									if (result.hasOwnProperty("groupBy") && result.groupBy.hasOwnProperty("value")) {
										var groupByArray = result.groupBy.value;
										for (var i = 0; i < groupByArray.length; i++) {
											var groupBy = groupByArray[i];
											var fieldObject = $.parseJSON(groupBy.extraInformation);
											var truncateValue = "TO_DAY";
											for (var j = 0; j < result.select.value.length; j++) {
												var selectObject = result.select.value[j];
												if (groupBy.field == selectObject.alias) {
													truncateValue = selectObject["function"];
												}
											}
											addOrderByOrGroupByBadge(containerId, config.container.find(".groupArea .selectorContainer"), fieldObject, false, truncateValue);
										}
									}

									if (result.hasOwnProperty("orderBy") && result.orderBy.hasOwnProperty("value")) {
										var orderByArray = result.orderBy.value;
										for (var i = 0; i < orderByArray.length; i++) {
											var orderBy = orderByArray[i];
											var fieldObject = $.parseJSON(orderBy.extraInformation);
											var aggregateValue = orderBy.hasOwnProperty("cbQLFunction") ? orderBy["cbQLFunction"] : null;
											addOrderByOrGroupByBadge(containerId, config.container.find(".orderByArea .selectorContainer"), fieldObject, orderBy.direction == "DESC", "TO_DAY", aggregateValue);
										}
									}

									config.queryId = queryId;
								});
							});
						}
					} catch (e) {
						showAlert(e);
					}
				},
				error: function() {
					showAlert();
				}
			});
		}

	};

	var addDeleteButton = function(containerId, $button, dialogUniqueId) {
		var $deleteButtonPlaceholder = $("<span>",{ "class" : "ui-icon deletePlaceholder"});
		$button.prepend($deleteButtonPlaceholder);
		var $deleteButton = $("<span>",{ "class" : "ui-icon removeIcon"});
		$deleteButton.click(function(e) {
			e.preventDefault();
			$(this).prev("button").remove();
			$(this).remove();
			refreshFilterCounters(containerId);
			validateLogicString(containerId);
			if (dialogUniqueId) {
				$('.referenceDialog[data-uniqueId="' + dialogUniqueId + '"]').remove();
			}
		});
		$button.after($deleteButton);
	};

	var getJsonDataAttributeFromWidget = function(containerId, attrName) {
		var $widget = configByInstance[containerId]["container"];
		var format = $widget.data(attrName) != undefined && $widget.data(attrName).trim() != "" ? JSON.parse($widget.data(attrName)) : {};
		return format;
	};

	var getFieldFormat = function(containerId) {
		return getJsonDataAttributeFromWidget(containerId, 'format');
	};

	var getAggregateFunctions = function(containerId) {
		return getJsonDataAttributeFromWidget(containerId, 'aggregatefunctions');
	};

	var setAggregateFunctions = function(containerId, functions) {
		var $widget = configByInstance[containerId].container;
		$widget.data('aggregatefunctions', JSON.stringify(functions));
		toggleOrderByAggregateFunctions(containerId);
	};

	var pushAggregateFunctions = function(containerId, select) {
		var aggrFunctions = getAggregateFunctions(containerId);
		var keys = Object.keys(aggrFunctions);
		$.each(keys, function (e, key) {
			$.each(aggrFunctions[key], function (e, aggrObject) {
				select.push(aggrObject);
			});
		});
	};

	var getCbQl = function(containerId) {
		var $container = configByInstance[containerId]["container"];
		var $inputSection = $container.find(".inputSection");
		if ($inputSection.data("viewMode") || $inputSection.is(':visible')) {
			return getAdvancedQueryString(containerId, true);
		} else {
			buildQueryString(containerId);
			return $container.data('queryString');
		}
	};

	var getAdvancedQueryString = function(containerId, includeAggregates) {
		var $container = configByInstance[containerId]["container"];
		var $inputSection = $container.find(".inputSection");
		var inputSectionTextarea = $inputSection.find("textarea");
		var advancedEditor = getAdvancedEditor(containerId);
		if (advancedEditor != null) {
			var advancedEditorValue = advancedEditor.getDoc().getValue();
			inputSectionTextarea.val(advancedEditorValue.replace(/[\r\n]+/g," "));
		}
		var cbQl = inputSectionTextarea.val();
		if (includeAggregates) {
			var whereIndex = cbQl.toLowerCase().indexOf('where');
			if (whereIndex > -1) {
				var aggrArray = [];
				pushAggregateFunctions(containerId, aggrArray);
				if (aggrArray.length > 0) {
					aggrArray = $.map(aggrArray, function(e) {return e["function"] +  "(" + e.field + ") as " + e.alias });
					var aggrArrayStr = "," + aggrArray.join(',') +" ";
					cbQl = cbQl.substr(0, whereIndex) + aggrArrayStr + cbQl.substr(whereIndex);
				}
			}
		}
		return cbQl;
	};

	var buildQueryStructure = function(containerId, ignoreAggregates, logicEnabled) {
		var config = configByInstance[containerId];
		var $container = config.container;

		function generateNodes(nodes, operator, parenthesis) {
			var res = {};
			if ($.isEmptyObject(nodes)) {
				return;
			}
			parenthesis = parenthesis || false;
			for (var i = 0; i < nodes.length; i++) {
				var node = nodes[i];
				if ($.isEmptyObject(res)) {
					res = node;
				} else {
					var previous = res;
					res = {
						left: node,
						operator: operator,
						parenthesis: parenthesis,
						right: previous
					}
				}
			}
			return res;
		}

		function generateOrNodes(nodes, parenthesis) {
			return generateNodes(nodes, "OR", parenthesis);
		}

		function generateAndNodes(nodes, parenthesis) {
			return generateNodes(nodes, "AND", parenthesis);
		}

		var buildChoices = function(cbQLAttrName, values, isNot, isProjectSelector) {
			var valuesForValue = [];
			for (var i=0; i < values.length; i++) {
				var value = values[i]
				if (isProjectSelector && values[i] == -1) {
					value = "'current project'";
				}
				valuesForValue.push({
					value: value
				});
			}
			return {
				left : {
					value: cbQLAttrName
				},
				operator: isNot ? "NOT IN" : "IN",
				parenthesis: false,
				right: {
					value: valuesForValue
				}
			}
		};

		var isAny = function(selected) {
			return ($(selected.get(0)).closest("li").hasClass("anyValue"));
		};

		var convertMultiselectSelectedToArray = function(selected) {
			var values = [];
			selected.each(function(i) {
				var value = $(this).val();
				values.push(value);
			});
			return values;
		};

		var buildProjectAndTrackerField = function($selector) {
			var isProjectSelector = $selector.is(".projectSelector");
			if (config.projectId && config.trackerId) {
				return {
					left : {
						value: $selector.data("cbQLAttrName")
					},
					operator: "IN",
					parenthesis: false,
					right: {
						value: [{ value: isProjectSelector ? config.projectId : config.trackerId }]
					}
				};
			}
			var selected = $selector.multiselect("getChecked");
			var $button = $selector.multiselect("getButton");
			if (isProjectSelector) {
				var selectedOptions = convertMultiselectSelectedToArray(selected);
				var currentProjectIndex = selectedOptions.indexOf("-1");
				if (currentProjectIndex !== -1 && getCurrentProjectId(containerId) !== 0) {
					selectedOptions[currentProjectIndex] = getCurrentProjectId(containerId);
				}
			}
			if (!isAny(selected)) {
				return buildChoices($selector.data("cbQLAttrName"), isProjectSelector ? selectedOptions : convertMultiselectSelectedToArray(selected), $button.data("isNot"), isProjectSelector);
			}
			return {};
		};

		var buildChoiceField = function($button, fieldObject) {
			var $selector = $button.prev("select");
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName
					}
				};
			}
			var isCountryOrLanguage = $selector.data("isCountry") == "true" || $selector.data("isLanguage") == "true";
			var selected = $selector.multiselect("getChecked");
			if (isAny(selected)) {
				return {};
			}
			var selectedValues = convertMultiselectSelectedToArray(selected);
			var meanings = [];
			var valuesByKey = {};
			for (var i = 0; i < selectedValues.length; i++) {
				if (startsWithNumber(selectedValues[i])) {
					var valueParts = selectedValues[i].split("_");
					var projectId = valueParts[0];
					var trackerId = valueParts[1];
					var slice = selectedValues[i].substr(selectedValues[i].indexOf("_") + 1, selectedValues[i].length - 1);
					var option = slice.substr(slice.indexOf("_") + 1, slice.length - 1);
					var keyValue = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : ("'" + projectId + "." + trackerId + "." + fieldObject.cbQLAttributeName + "'");
					var value = "'" + option.replace(/"/g, '\\"').replace(/'/g, "\\'") + "'";
					if (valuesByKey.hasOwnProperty(keyValue)) {
						valuesByKey[keyValue].push(value);
					} else {
						valuesByKey[keyValue] = [value];
					}
				} else {
					meanings.push({
						value: isCountryOrLanguage ? selectedValues[i] : "'" + selectedValues[i] + "'"
					});
				}
			}

			var nodesBySameKey = [];
			for (var valueKey in valuesByKey) {
				var values = [];
				for (var i = 0; i < valuesByKey[valueKey].length; i++) {
					values.push({ value: valuesByKey[valueKey][i]});
				}
				nodesBySameKey.push({
					left: {
						value: valueKey
					},
					operator: isNot ? "NOT IN" : "IN",
					right: {
						value: values
					}
				});
			}

			var valueNodes = {};
			if (nodesBySameKey.length > 0) {
				valueNodes = generateOrNodes(nodesBySameKey, true);
			}

			var meaningNode = {};
			if (meanings.length > 0) {
				meaningNode = {
					operator: isNot ? "NOT IN" : "IN",
					left: {
						value: isCountryOrLanguage ? "'" + fieldObject.cbQLAttributeName + "'" : fieldObject.cbQLMeaningAttributeName
					},
					right: {
						value: meanings
					}
				};
			}

			if ($.isEmptyObject(valueNodes)) {
				return meaningNode;
			}

			if ($.isEmptyObject(meaningNode)) {
				return valueNodes;
			}

			var resultArray = [];
			resultArray.push(valueNodes);
			resultArray.push(meaningNode);
			return isNot ? generateAndNodes(resultArray) : generateOrNodes(resultArray, true);

		};

		var buildMemberField = function($button, fieldObject) {
			var $selector = $button.prev("select");
			var selected = $selector.multiselect("getChecked");
			var $button = $selector.multiselect("getButton");
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				var memberPart = {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName
					}
				};
				if (fieldObject.customField && fieldObject.cbQLRoleAttributeName != null) {
					var rolePart = {
						operator: "IS" + (isNot ? " NOT" : "") + " NULL",
						left: {
							value: "'" + fieldObject.cbQLRoleAttributeName + "'"
						}
					};
					var resultArray  = [];
					resultArray.push(memberPart);
					resultArray.push(rolePart);
					return isNot ? generateOrNodes(resultArray, true) : generateAndNodes(resultArray, true);
				} else {
					return memberPart;
				}
			}
			if (isAny(selected)) {
				return {};
			}
			var selectedValues = convertMultiselectSelectedToArray(selected);
			var users = [];
			var roles = [];

			for (var i = 0; i < selectedValues.length; i++) {
				var selected = selectedValues[i];
				if (selected == -1) {
					users.push({
						value: "'current user'"
					});
				} else if (selected != "indirectUser") {
					var selectedParts = selected.split("_");
					if (selectedParts[0] == "user") {
						users.push({
							value: selectedParts[1]
						});
					} else {
						roles.push({
							value: selectedParts[1]
						});
					}
				}
			}

			var userNode = {};
			var cbQLAttr = $button.data("indirectUser") ? "assignedToIndirect" :
				(fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName);
			if (users.length > 0) {
				userNode = {
					operator: isNot ? "NOT IN" : "IN",
					left: {
						value: cbQLAttr
					},
					right: {
						value: users
					}
				};
			}

			var roleNode = {};
			if (roles.length > 0) {
				var cbQLAttrName = fieldObject.customField ? ("'" + fieldObject.cbQLRoleAttributeName + "'") : fieldObject.cbQLRoleAttributeName;
				roleNode = {
					operator: isNot ? "NOT IN" : "IN",
					left: {
						value: cbQLAttrName
					},
					right: {
						value: roles
					}
				};
			}

			if ($.isEmptyObject(roleNode)) {
				return userNode;
			}
			if ($.isEmptyObject(userNode)) {
				return roleNode;
			}

			var resultArray = [];
			resultArray.push(userNode);
			resultArray.push(roleNode);
			return isNot ? generateAndNodes(resultArray, true) : generateOrNodes(resultArray, true);

		};

		var buildDateField = function($button, fieldObject) {
			var fromDateISO = $button.data("fromDateISO");
			var toDateISO = $button.data("toDateISO");
			if ($button.data("isoDate")) {
				var fromDate = $button.data("cbQLFrom") ? $button.data("cbQLFrom") : ("'" + fromDateISO + (fromDateISO != null ? " 00:00:00'" : "'"));
				var toDate = $button.data("cbQLTo") ? $button.data("cbQLTo") : ("'" + toDateISO + (toDateISO != null ? " 23:59:59'" : "'"));
			} else {
				var fromDate = $button.data("cbQLFrom") ? $button.data("cbQLFrom") : "";
				var toDate = $button.data("cbQLTo") ? $button.data("cbQLTo") : "";
			}

			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName;

			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName
					}
				};
			}

			if ((fromDate == "'null'" || fromDate.length == 0) && (toDate == "'null'" || toDate.length == 0)) {
				return {};
			}

			if (fromDate == "'null'" || fromDate.length == 0) {
				return {
					parenthesis: true,
					operator: isNot ? ">" : "<=",
					left: {
						value: cbQLAttr
					},
					right: {
						value: toDate
					}
				}
			}

			if (toDate == "'null'" || toDate.length == 0) {
				return {
					parenthesis: true,
					operator: isNot ? "<" : ">=",
					left: {
						value: cbQLAttr
					},
					right: {
						value: fromDate
					}
				}
			}

			return {
				parenthesis: true,
				operator: isNot ? "OR" : "AND",
				left: {
					operator: isNot ? "<" : ">=",
					left: {
						value: cbQLAttr
					},
					right: {
						value: fromDate
					}
				},
				right: {
					operator: isNot ? ">" : "<=",
					left: {
						value: cbQLAttr
					},
					right: {
						value: toDate
					}
				}
			}
		};

		var buildReferenceField = function($button, fieldObject) {
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLIdAttributeName;
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: cbQLAttr
					}
				};
			}

			var cbQLFunction = $button.data("cbQLFunction");
			var referenceIds = $button.data("referenceValue");
			var referenceTrackerIds = $button.data("referenceTrackerIds");
			if (referenceTrackerIds && referenceTrackerIds != null) {
				var trackerCbQLAttr = fieldObject.id == -4 ? "referenceFromTracker" : "referenceToTracker";
				var values = [];
				for (var i = 0; i  < referenceTrackerIds.length; i++) {
					values.push({
						value: referenceTrackerIds[i]
					});
				}
				var result = {
					parenthesis: false,
					operator: isNot ? "NOT IN" : "IN",
					left: {
						value: trackerCbQLAttr
					},
					right: {
						value: values
					}
				};
				if (cbQLFunction && cbQLFunction != null) {
					result["cbQLFunction"] = cbQLFunction;
				}
				return result;
			}
			if (!referenceIds || referenceIds == null || referenceIds.length == 0) {
				if (cbQLFunction == "isSuspected" || cbQLFunction == "isNotSuspected") {
					return {
						"cbQLFunction" : cbQLFunction,
						value : cbQLAttr
					}
				} else {
					return {};
				}
			}
			var values = [];
			for (var i = 0; i  < referenceIds.length; i++) {
				values.push({
					value: referenceIds[i]
				});
			}
			var result = {
				parenthesis: false,
				operator: isNot ? "NOT IN" : "IN",
				left: {
					value: cbQLAttr
				},
				right: {
					value: values
				}
			};
			if (cbQLFunction && cbQLFunction != null) {
				result["cbQLFunction"] = cbQLFunction;
			}
			return result;
		};

		var buildTextField = function($button, fieldObject) {
			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName;
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: cbQLAttr
					}
				};
			}
			return {
				parenthesis: false,
				operator: isNot ? "NOT LIKE" : "LIKE",
				left: {
					value: cbQLAttr
				},
				right: {
					value: "'" + $button.data("inputValue") + "'"
				}
			}
		};

		var buildNumberField = function($button, fieldObject) {
			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName;
			var numberValue =$button.data("numberValue");
			var value = numberValue == 0 ? numberValue.toString() : numberValue;
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: cbQLAttr
					}
				};
			}
			var operator = $button.data("operator");
			return {
				parenthesis: false,
				operator: isNot ? notNumberOperators[operator] : operator,
				left: {
					value: cbQLAttr
				},
				right: {
					value: value
				}
			}
		};

		var buildDurationField = function($button, fieldObject) {
			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName;
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: cbQLAttr
					}
				};
			}
			var operator = $button.data("operator");
			return {
				parenthesis: false,
				operator: isNot ? notNumberOperators[operator] : operator,
				left: {
					value: cbQLAttr
				},
				right: {
					value: $button.data("numberAndTime")
				}
			}
		};

		var buildBooleanField = function(cbQLAttrName, selectedValue, cbQLFunction, isCustomField) {
			var result = {
				parenthesis: false,
				operator: "=",
				left: {
					value: isCustomField ? ("'" + cbQLAttrName + "'") : cbQLAttrName
				},
				right: {
					value: "'" + selectedValue.toString()  + "'"
				}
			};
			if (cbQLFunction && cbQLFunction != null) {
				result["cbQLFunction"] = cbQLFunction;
			}
			return result;
		};

		var buildColorField = function($button, fieldObject) {
			var cbQLAttr = fieldObject.customField ? ("'" + fieldObject.cbQLAttributeName + "'") : fieldObject.cbQLAttributeName;
			var isNot = $button.data("isNot");
			var isEmpty = $button.data("isEmpty");
			if (isEmpty) {
				return {
					operator: "IS" + (isNot ? " NOT" : "") + " NULL",
					left: {
						value: cbQLAttr
					}
				};
			}
			var values = [];
			values.push({
				value : "'" + $button.data("inputValue") + "'"
			});
			return {
				parenthesis: false,
				operator: isNot ? "NOT IN" : "IN",
				left: {
					value: cbQLAttr
				},
				right: {
					value: values
				}
			}
		};

		var buildTagField = function($button, fieldObject) {
			var cbQLAttr = fieldObject.cbQLAttributeName;
			var isNot = $button.data("isNot");
			var inputValue = $button.data("inputValue");
			var values = [];
			if (inputValue.length == 0) {
				values.push({
					value: "''"
				});
			} else {
				for (var i = 0; i < inputValue.length; i++) {
					values.push({
						value: "'" + inputValue[i] + "'"
					});
				}
			}
			return {
				parenthesis: false,
				operator: isNot ? "NOT IN" : "IN",
				left: {
					value: cbQLAttr
				},
				right: {
					value: values
				}
			}
		};

		function buildUnresolvedDependencies(isNot) {
			return {
				operator: isNot ? "NOT IN" : "IN",
					left: {
					value: "workItemStatus"
				},
				right: {
					value: [{ value: "'HasUnresolvedDependency'"}]
				}
			}
		}

		function pushToArray(resultArray, node, resultMap, resultMapKey) {
			if (!$.isEmptyObject(node)) {
				if (logicEnabled && resultMap) {
					resultMap["@@" + resultMapKey + "@@"] = node;
				} else {
					resultArray.push(node);
				}
			}
		}

		var resultArray = [];
		var resultMap = {};

		var $fieldArea = $container.find(".fieldArea");
		var $buttons = $fieldArea.find("button");
		var $reversed = $($buttons.get().reverse());
		$reversed.each(function() {
			var fieldObject = $(this).data("fieldObject");
			var resultMapKey;
			if (logicEnabled) {
				resultMapKey = $(this).find(".filterCounter").attr("data-count");
			}
			var cbQLAttrName = $(this).data("cbQLAttrName");
			if (fieldObject) {
				var typeName = fieldObject.fieldTypeName;
				if (cbQLAttrName && (cbQLAttrName == "projectTag" || cbQLAttrName == "trackerTag" || cbQLAttrName == "trackerItemTag" || cbQLAttrName == "releaseTag")) {
					pushToArray(resultArray, buildTagField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "choice") {
					pushToArray(resultArray, buildChoiceField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "member") {
					pushToArray(resultArray, buildMemberField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "reference") {
					pushToArray(resultArray, buildReferenceField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "date") {
					pushToArray(resultArray, buildDateField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "text" || typeName == "url") {
					pushToArray(resultArray, buildTextField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "number") {
					pushToArray(resultArray, buildNumberField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "duration") {
					pushToArray(resultArray, buildDurationField($(this), fieldObject), resultMap, resultMapKey);
				} else if (typeName == "boolean") {
					pushToArray(resultArray, buildBooleanField(fieldObject.cbQLAttributeName, $(this).data("value"), null, fieldObject.customField), resultMap, resultMapKey);
				} else if (typeName == "color") {
					pushToArray(resultArray, buildColorField($(this), fieldObject), resultMap, resultMapKey);
				}
			} else if (cbQLAttrName) {
				if (cbQLAttrName == "hasIncomingReference" || cbQLAttrName == "hasOutgoingReference" ||
					cbQLAttrName == "hasDownstreamReference" || cbQLAttrName == "hasUpstreamReference" ||
					cbQLAttrName == "hasSuspectedLink" ||
					cbQLAttrName == "hasIncomingSuspectedLink" || cbQLAttrName == "hasOutgoingSuspectedLink" ||
					cbQLAttrName == "hasDownstreamSuspectedLink" || cbQLAttrName == "hasUpstreamSuspectedLink") {
					pushToArray(resultArray, buildBooleanField(cbQLAttrName, $(this).data("value"), $(this).data("cbQLFunction")), resultMap, resultMapKey);
				}
				if (cbQLAttrName == "hasUnresolvedDependency") {
					pushToArray(resultArray, buildUnresolvedDependencies($(this).data("value") !== "true"), resultMap, resultMapKey);
				}
				if (cbQLAttrName == "hasReview" || cbQLAttrName == "underReview") {
					pushToArray(resultArray, buildBooleanField(cbQLAttrName, $(this).data("value"), null), resultMap, resultMapKey);
				}
			} else if ($(this).is(".includePart")) {
				var id = $(this).data("id");
				if (id != null) {
					var isReport = $(this).data("isReport");
					pushToArray(resultArray, { value: "include[" + (isReport ? "REPORT:" : "ITEM:") + id + "]"}, resultMap, resultMapKey);
				}
			}
		});

		var projects = buildProjectAndTrackerField($container.find("select.projectSelector"));
		var trackers = buildProjectAndTrackerField($container.find("select.trackerSelector"));
		if (!$.isEmptyObject(trackers)) {
			pushToArray(resultArray, trackers, resultMap, "-1");
		}
		if (!$.isEmptyObject(projects)) {
			pushToArray(resultArray, projects, resultMap, "-2");
		}

		// Note: Release filter part of the cbQL will be added in CardboardController, so if we are in Release context
		// we add a placeholder filter which is always true to ensure the correct cbQL using Group by / Order by
		// if there are no other filters
		if (resultArray.length == 0 && (configByInstance[containerId].releaseId || configByInstance[containerId].isPlanner)) {
			var trueFilter = {
				left : {
					value: "item.id"
				},
				operator: "NOT IN",
				parenthesis: false,
				right: {
					value: [{value: 0}]
				}
			};
			pushToArray(resultArray, trueFilter, null);
		}

		var where = {};

		if (logicEnabled) {
			where = resultMap;
			configByInstance[containerId].logicSlices = where;
		} else {
			if (resultArray.length == 0) {
				return null;
			}
			if (resultArray.length == 1) {
				where = resultArray[0];
			} else {
				where = generateAndNodes(resultArray);
			}
		}

		var orderBy = [];
		var $orderByArea = $container.find(".orderByArea");
		$orderByArea.find(".droppableField").each(function() {
			var fieldObject = $(this).data("fieldObject");
			var isDesc = $(this).data("isDesc");
			var orderByData = {
				field: fieldObject.customField ? "'" + fieldObject.cbQLAttributeName + "'" : fieldObject.cbQLOrderByAttributeName,
				direction: isDesc ? "DESC" : "ASC"
			};
			var $aggregateButton = $(this).find(".aggregateDroppableButton");
			if ($aggregateButton.is(":visible")) {
				var aggregateValue = $aggregateButton.data("aggregateValue");
				if (aggregateValue && aggregateValue !== "none") {
					orderByData["cbQLFunction"] = aggregateValue;
				}
			}
			orderBy.push(orderByData);
		});

		var groupBy = [];
		var select = [];
		var $groupByArea = $container.find(".groupArea");
		$groupByArea.find(".droppableField").each(function() {
			var fieldObject = $(this).data("fieldObject");
			var truncateValue = $(this).find(".truncateDroppableButton").data("truncateValue");
			groupBy.push({
				field: "'" + fieldObject.label +  "'"
			});
			var selectObject = {
				field: fieldObject.customField ? "'" + fieldObject.cbQLAttributeName + "'" : fieldObject.cbQLGroupByAttributeName,
				alias: "'" + fieldObject.label +  "'"
			};
			if (truncateValue) {
				selectObject["function"] = truncateValue;
			}
			select.push(selectObject);
		});
		if (select.length > 0) {
			if (!ignoreAggregates) {
				pushAggregateFunctions(containerId, select);
			}

			select.push({
				field: "1",
				alias: "COUNT",
				"function": "COUNT"
			});
		}

		var result = {
			where: where
		};
		if (orderBy.length > 0) {
			result["orderBy"] = {
				value: orderBy
			};
		}
		if (groupBy.length > 0) {
			result["groupBy"] = {
				value: groupBy
			};
			result["select"] = {
				value: select
			};
		}

		return result;
	};

	var buildQueryString = function(containerId, ignoreAggregates) {
		var config = configByInstance[containerId];
		var logicEnabled = config.logicEnabled;
		var queryString = "";
		var success = false;
		try {
			var queryStructure = buildQueryStructure(containerId, ignoreAggregates, logicEnabled);
			if (queryStructure != null) {
				var logicSlices = null;
				if (logicEnabled && queryStructure.hasOwnProperty("where")) {
					logicSlices = queryStructure.where;
					delete queryStructure.where;
				}
				var data = {
					jsonString: JSON.stringify(queryStructure)
				};
				if (logicEnabled) {
					data["logicSlicesString"] = JSON.stringify(logicSlices);
					config.logicSlicesString = JSON.stringify(logicSlices);
					data["logicString"] = getLogicString(containerId);
				}
				$.ajax(contextPath + "/ajax/queryCondition/getCbQLString.spr", {
					dataType: "json",
					method: 'POST',
					data: data,
					async: false
				}).done(function(result) {
					if (result.hasOwnProperty("success") && result.success) {
						queryString = result.cbQL;
						success = true;
					} else if (result.hasOwnProperty("exceptionMessage")) {
						showFancyAlertDialog(result.exceptionMessage);
					} else {
						showFancyAlertDialog("Unable to generate query string!");
					}
				});
			} else {
				success = true;
			}
		} catch (ex){
			//
		}

		if (success) {
			config.container.data("queryString", queryString);
			console.log("Query string: ", queryString);
		}

	};

	var isLogicInvalid = function(containerId, logicEnabled) {
		if (logicEnabled) {
			var logicString = getLogicString(containerId);
			if (logicString == null || logicString.length == 0) {
				return true;
			}
			validateLogicString(containerId);
			if (configByInstance[containerId]["container"].find(".logicString").hasClass("invalidLogic")) {
				return true;
			}
		}
		return false;
	};

	var showInvalidLogicWarning = function(containerId) {
		if (!configByInstance[containerId].hasOwnProperty("extraLogicWarning") || !configByInstance[containerId].extraLogicWarning) {
			showFancyAlertDialog(i18n.message("query.widget.invalid.or.empty.logic.warning"));
		}
		return false;
	};

	var showAdvanced = function(containerId, doBuildQueryString, initial, initialQueryString) {
		var config = configByInstance[containerId];
		if (isLogicInvalid(containerId, config.logicEnabled)) {
			return showInvalidLogicWarning(containerId);
		}
		if (doBuildQueryString) {
			buildQueryString(containerId, true);
		}
		var inputSection = config.container.find(".inputSection");
		var selectorSection = config.container.find(".selectorSection");
		var advancedLink = config.container.find(".advancedLink");
		advancedLink.text(i18n.message("queries.simple.label"));
		if (initial && initialQueryString) {
			config.container.data("queryString", initialQueryString);
		}
		if (doBuildQueryString || (initial && initialQueryString)) {
			inputSection.find("textarea").val(config.container.data("queryString"));
			initAdvancedEditorWithQueryString(containerId, config.container.data("queryString"), config.logicEnabled);
		}
		inputSection.show();
		selectorSection.hide();
		setTimeout(function() {
			inputSection.show();
			selectorSection.hide();
			config.advancedMode = true;
			try {
				$(config.advancedEditor.display.wrapper).find("textarea").first().focus();
			} catch (e) {
				//
			}
		}, 100);
		config.advancedMode = true;
	};

	var showSimple = function(containerId, doBuildQueryString, doInitContainer) {
		var config = configByInstance[containerId];
		var $textarea = config.container.find(".inputSection textarea");
		if (config.advancedEditor != null) {
			var advancedEditorValue = config.advancedEditor.getDoc().getValue();
			$textarea.val(advancedEditorValue.replace(/[\r\n]+/g," "));
		}
		var isEmptyQueryString = $textarea.val().trim().length == 0;
		if (doBuildQueryString && !isEmptyQueryString && !isLogicEnabled(containerId)) {
			buildQueryString(containerId);
		}
		var inputSection = config.container.find(".inputSection");
		var selectorSection = config.container.find(".selectorSection");
		var advancedLink = config.container.find(".advancedLink");
		advancedLink.text(i18n.message("queries.advanced.label"));
		if (doInitContainer && !config.logicEnabled) {
			if (!isEmptyQueryString) {
				initContainer(containerId, null, $textarea.val(), true);
				config.container.data("queryString", $textarea.val());
			} else {
				initContainer(containerId, null, "", true);
				config.container.data("queryString", "");
			}
		}
		selectorSection.show();
		inputSection.hide();
		config.advancedMode = false;
	};

	var initAdvancedEditorWithQueryString = function(containerId, queryString, readOnly) {
		var config = configByInstance[containerId];
		if (config.advancedEditor != null) {
			config.advancedEditor.off();
			config.advancedEditor.toTextArea();
			config.advancedEditor = null;
		}
		var $textarea = config.container.find(".inputSection textarea");
		config.advancedEditor = CodeMirror.fromTextArea($textarea.get(0), {
			mode: "text/x-sql",
			indentWithTabs: true,
			smartIndent: true,
			matchBrackets : true,
			autofocus: true,
			lineWrapping: true
		});
		config.advancedEditor.setSize(null, 120);
		if (!queryString) {
			queryString = "";
		}
		config.advancedEditor.getDoc().setValue(queryString);
		if (readOnly) {
			$(config.advancedEditor.getWrapperElement()).attr("title", i18n.message("query.widget.logic.advanced.tooltip"));
			$(config.advancedEditor.getWrapperElement()).css("background-color", "#f5f5f5");
			config.advancedEditor.setOption("readOnly", true);
		}
		setTimeout(function() {
			config.advancedEditor.refresh();
		}, 100);
	};

	var initAdvanced = function(containerId) {
		var config =  configByInstance[containerId];
		var inputSection = config.container.find(".inputSection");
		if (config.viewMode) {
			inputSection.data("viewMode", config.viewMode);
			config.container.find(".inputSection textarea").text(config.queryString);
		} else {
			var advancedLink = config.container.find(".advancedLink");
			advancedLink.click(function() {
				if (!config.advancedMode) {
					showAdvanced(containerId, true);
				} else {
					showSimple(containerId, true, true);
				}
			});
			if (config.advanced) {
				showAdvanced(containerId, false);
				config.container.find(".inputSection textarea").val(config.queryString);
			}
			initAdvancedEditorWithQueryString(containerId, config.queryString, config.logicEnabled);
		}
	};

	var initNavigateAwayProtection = function(containerId) {
		$(window).on('beforeunload', function() {
			if (configByInstance[containerId]["navigateAwayProtection"]) {
				return true;
			}
		});
	};

	var showUnsavedWarning = function(containerId, queryString) {
		var config = configByInstance[containerId];
		if (config.queryId && config.queryId > 0) {
			config.queryHeaderTop.find("#unsavedWarning").fadeIn();
			if (queryString) {
				config.currentQueryString = queryString;
			}
			configByInstance[containerId]["navigateAwayProtection"] = true;
		}
	};

	var hideUnsavedWarning = function(containerId, queryString) {
		var config = configByInstance[containerId];
		config.queryHeaderTop.find("#unsavedWarning").fadeOut();
		if (queryString) {
			config.currentQueryString = queryString;
		}
		configByInstance[containerId]["navigateAwayProtection"] = false;
	};

	var getCurrentProjectId = function(containerId) {
		var config = configByInstance[containerId];
		return config.container.find(".currentProjectPlaceholder").length == 1 ? parseInt(config.container.find(".currentProjectPlaceholder").attr("data-id"), 10) : 0;
	};

	var setCurrentProject = function(containerId, projectId, projectName) {
		var config = configByInstance[containerId];
		var $currentProjectPlaceholder = config.container.find(".currentProjectPlaceholder");
		if ($currentProjectPlaceholder.length > 0) {
			$currentProjectPlaceholder.attr("data-id", projectId);
			$currentProjectPlaceholder.find(".projectName").text(projectName);
			$currentProjectPlaceholder.show();
		}
	};

	var clearCurrentProject = function(containerId) {
		var config = configByInstance[containerId];
		var $currentProjectPlaceholder = config.container.find(".currentProjectPlaceholder");
		if ($currentProjectPlaceholder.length > 0) {
			$currentProjectPlaceholder.hide();
			$currentProjectPlaceholder.attr("data-id", "0");
			$currentProjectPlaceholder.find(".projectName").text("");
		}
	};

	var showCurrentProjectWarning = function(containerId, currentProjectId) {
		var config = configByInstance[containerId];
		var html = "<div>" + i18n.message("query.condition.widget.current.project.warning") + "</div>";
		var $clonedProjectSelector = config.container.find(".projectSelector").clone();
		$clonedProjectSelector.find("option.currentProject").remove();
		$clonedProjectSelector.find("option.anyValue").remove();
		html += "<div><select class=\"currentProjectSelector\">" + $clonedProjectSelector.html() + "</select></div>";
		showFancyConfirmDialogWithCallbacks(html, function(dialog) {
			var projectId = $(this).find(".currentProjectSelector").val();
			var projectName = $(this).find(".currentProjectSelector option[value='" + projectId + "']").text();
			setCurrentProject(containerId, projectId, projectName);
			config.container.find(".searchButton").click();
		}, null, "warning", function(event, ui) {
			var $selector = $(event.target).find(".currentProjectSelector");
			if (currentProjectId) {
				$selector.val(currentProjectId);
			}
			initProjectSelector(containerId, $selector, true, "currentProjectSelector");
		});
	};

	var initReportPageSearchButton = function(containerId) {
		var config = configByInstance[containerId];
		config.container.find(".searchButton").click(function() {
			var projectIds = getProjectIds(containerId);
			var currentProjectId = getCurrentProjectId(containerId);
			if (currentProjectId === 0 && projectIds.length == 1 && projectIds.indexOf(-1) > -1) {
				showCurrentProjectWarning(containerId);
				return false;
			}
			if (isLogicInvalid(containerId, config.logicEnabled)) {
				return showInvalidLogicWarning(containerId);
			}
			var queryString = getCbQl(containerId);
			if (config.currentQueryString && config.currentQueryString.length > 0 &&
				queryString && queryString.length > 0 && queryString != config.currentQueryString) {
				showUnsavedWarning(containerId, queryString);
			}
			initAdvancedEditorWithQueryString(containerId, getAdvancedQueryString(containerId, false), config.logicEnabled);
			config.queryString = queryString;
			if (queryString && queryString.length > 0) {
				codebeamer.ReportPage.fetchQueryResults(queryString, config.queryId, config.advancedMode, null, config.resultContainer, !config.viewMode);
			} else {
				codebeamer.ReportPage.showEmptyQueryAlert();
			}
		});
	};

	var toggleAddButton = function(containerId, $area) {
		var config = configByInstance[containerId];
		var isOrderByArea = $area.closest("td").hasClass("orderByArea");
		var isGroupByArea = $area.closest("td").hasClass("groupArea");
		var maximumLength = isOrderByArea ? config.maxOrderByElements : (isGroupByArea ? config.maxGroupByElements : 3);
		var $droppableFields = $area.find(".droppableField");
		if (config.reportPage) {
			var $addButton = $area.find(".addDroppableButton");
			if ($droppableFields.length >= maximumLength) {
				$addButton.hide();
			} else {
				$addButton.show();
			}
		} else {
			var $button = $area.find(".groupByOrderByLabel");
			if ($droppableFields.length >= maximumLength) {
				$button.addClass("inactive");
				$button.removeClass("actionBarIcon");
			} else {
				$button.removeClass("inactive");
				$button.addClass("actionBarIcon");
			}
		}
	};

	var toggleOrderByAggregateFunctions = function(containerId) {
		var config = configByInstance[containerId];
		config.container.find(".orderByArea").find(".droppableField").each(function() {
			var possibleAggregateValues = getPossibleAggregateOrderByFunctions(containerId, $(this).data("fieldObject"));
			var $aggregateButton = $(this).find(".aggregateDroppableButton");
			$aggregateButton.data("possibleAggregateValues", possibleAggregateValues);
			var currentAggregateValue = $aggregateButton.data("aggregateValue");
			if ($.inArray(currentAggregateValue, possibleAggregateValues) == -1) {
				$aggregateButton.data("aggregateValue", "none");
				$aggregateButton.text(aggregateValues["none"]);
			}
			if (config.container.find(".groupArea").find(".droppableField").length == 1 && possibleAggregateValues.length > 1) {
				$aggregateButton.show();
			} else {
				$aggregateButton.hide();
			}
		});
	};

	var getPossibleAggregateOrderByFunctions = function(containerId, fieldObject) {
		var config = configByInstance[containerId];
		var possibleFunctions = ["none"];
		if (config.container.find(".groupArea").find(".droppableField").length > 1) {
			return possibleFunctions;
		}
		var cbQlAttributeName = fieldObject.cbQLOrderByAttributeName;
		var aggregateFunctions = getAggregateFunctions(containerId);
		if (aggregateFunctions && aggregateFunctions != null && !$.isEmptyObject(aggregateFunctions)) {
			if (aggregateFunctions.hasOwnProperty(cbQlAttributeName)) {
				for (var i = 0; i < aggregateFunctions[cbQlAttributeName].length; i++) {
					possibleFunctions.push(aggregateFunctions[cbQlAttributeName][i]["function"]);
				}
			}
		}
		return possibleFunctions;
	};

	var enableAllMenuItems = function($selector) {
		$selector.data("disabledFieldIds", []);
	};

	var addOrderByOrGroupByBadge = function(containerId, $area, fieldObject, isDesc, truncateValue, aggregateValue) {

		var config = configByInstance[containerId];

		var isOrderByArea = $area.closest("td").hasClass("orderByArea");
		var isGroupByArea = $area.closest("td").hasClass("groupArea");

		if (isOrderByArea && !fieldObject.orderByAble) {
			showFancyAlertDialog(i18n.message("query.widget.field.order.by.warning"));
			return;
		}
		if (isGroupByArea && !fieldObject.groupByAble) {
			showFancyAlertDialog(i18n.message("query.widget.field.group.by.warning"));
			return;
		}

		var $addButton = $area.find(".addDroppableButton");
		var $badge = $("<span>", { "class": "droppableField" });
		var fieldLabel = fieldObject.label;
		$badge.data("fieldObject", fieldObject);
		$badge.data("isDesc", isDesc);

		var fieldId = parseInt(fieldObject.id, 10);
		var fieldIdForDisable = fieldObject.customField ? (fieldObject.trackerId + "_" + fieldId) : fieldId;
		var $selector = isOrderByArea ? $("#orderBySelector_" + containerId) : $("#groupBySelector_" + containerId);
		var disabledFieldIds = $selector.data("disabledFieldIds");
		if (!disabledFieldIds) {
			disabledFieldIds = [];
		}
		disabledFieldIds.push(fieldIdForDisable);
		$selector.data("disabledFieldIds", disabledFieldIds);

		$badge.text(fieldLabel);

		var isDateField = false;
		if (fieldObject.fieldTypeName == "date") {
			isDateField = true;
		}

		if (isOrderByArea) {
			var $descButton = $("<span>", { "class" : "descDroppableButton"}).text(isDesc ? "DESC" : "ASC");
			if (isDesc) {
				$descButton.addClass("descActive");
			}
			$descButton.click(function() {
				if ($(this).hasClass("descActive")) {
					$(this).removeClass("descActive");
					$badge.data("isDesc", false);
					$(this).text("ASC");
				} else {
					$(this).addClass("descActive");
					$badge.data("isDesc", true);
					$(this).text("DESC");
				}
			});
			$badge.append($descButton);

			// ordering by aggregate functions
			var possibleAggregateFunctions = getPossibleAggregateOrderByFunctions(containerId, fieldObject);
			if (!aggregateValue) {
				aggregateValue = "none";
			}
			var $aggregateOrderButton =  $("<span>", { "class" : "aggregateDroppableButton"}).text(aggregateValues[aggregateValue]);
			$aggregateOrderButton.data("aggregateValue", aggregateValue);
			$aggregateOrderButton.data("possibleAggregateValues", possibleAggregateFunctions);
			$aggregateOrderButton.click(function() {
				var currentValue = $(this).data("aggregateValue");
				var possibleValues = $(this).data("possibleAggregateValues");
				var index = possibleValues.indexOf(currentValue);
				var nextIndex = index == possibleValues.length - 1 ? 0 : index + 1;
				$(this).data("aggregateValue", possibleValues[nextIndex]);
				$(this).text(aggregateValues[possibleValues[nextIndex]]);
			});
			if (possibleAggregateFunctions.length == 1) {
				$aggregateOrderButton.hide();
			} else {
				$aggregateOrderButton.show();
			}
			$badge.append($aggregateOrderButton);
		}

		if (isGroupByArea && isDateField) {
			var $truncateButton = $("<span>", { "class" : "truncateDroppableButton"}).text(truncateValues[truncateValue]);
			$truncateButton.data("truncateValue", truncateValue);
			$truncateButton.click(function() {
				var currentTruncateValue = $(this).data("truncateValue");
				var index = truncateValueArray.indexOf(currentTruncateValue);
				var nextIndex = index == truncateValueArray.length - 1 ? 0 : index + 1;
				$(this).data("truncateValue", truncateValueArray[nextIndex]);
				$(this).text(truncateValues[truncateValueArray[nextIndex]]);
			});
			$badge.append($truncateButton);
		}

		var $removeButton = $("<span>", {"class" : "removeDroppableButton"});
		$removeButton.click(function() {
			var fieldId = fieldObject.customField ? (fieldObject.trackerId + "_" + fieldObject.id) : parseInt(fieldObject.id, 10);
			var $selector = isOrderByArea ? $("#orderBySelector_" + containerId) : $("#groupBySelector_" + containerId);
			var disabledFieldIds = $selector.data("disabledFieldIds");
			if (!disabledFieldIds) {
				disabledFieldIds = [];
			}
			disabledFieldIds.splice(disabledFieldIds.indexOf(fieldId), 1);
			$selector.data("disabledFieldIds", disabledFieldIds);
			$selector.multiselect("refresh");
			$(this).closest(".droppableField").remove();
			toggleAddButton(containerId, $area);
			if (isGroupByArea) {
				toggleOrderByAggregateFunctions(containerId);
			}
		});
		$badge.append($removeButton);

		$addButton.before($badge);
		if (isGroupByArea) {
			toggleOrderByAggregateFunctions(containerId);
		}
		toggleAddButton(containerId, $area);
	};

	var addFilterCounterSpan = function(containerId, $container) {
		var config = configByInstance[containerId];
		var $counterSpan = $("<span>", {"class": "filterCounter", "data-count" : config.filterCounter}).text(config.filterCounter.toString() + ". ");
		$container.prepend($counterSpan);
		config.filterCounter++;
	};

	var addFilterCounter = function(containerId, $container) {
		if (configByInstance[containerId]["logicEnabled"]) {
			// Mark special selectors, they are not part of the cbQL that's why they cannot be part of the logic
			if ($container.prev("select").length > 0 && $container.prev("select").hasClass("specialChoiceFieldSelector")) {
				$container.prepend($("<span>", { "class" : "specialChoiceFieldWarning"}));
				$container.attr("title", i18n.message("query.widget.special.field.logic.warning"));
				$container.attr("data-specialChoiceFieldWarning", true);
				return;
			}
			addFilterCounterSpan(containerId, $container);
		}
	};

	var addFilterCounters = function(containerId) {
		configByInstance[containerId]["container"].find(".fieldArea .modifiableArea").find(".queryConditionSelector").each(function() {
			addFilterCounter(containerId, $(this));
		});
	};

	var removeFilterCounters = function(containerId) {
		configByInstance[containerId]["container"].find(".filterCounter").remove();
		configByInstance[containerId]["container"].find(".specialChoiceFieldWarning").remove();
		configByInstance[containerId]["container"].find('button[data-specialChoiceFieldWarning="true"]').attr("title", "");
		configByInstance[containerId]["filterCounter"] = 1;
	};

	var refreshFilterCounters = function(containerId) {
		removeFilterCounters(containerId);
		addFilterCounters(containerId);
	};

	var showLogicStripe = function(containerId) {
		var config = configByInstance[containerId];
		config.logicEnabled = true;
		var $logicStripe = config.container.find(".logicStripe");
		var height = config.reportPage ? "32px" : "18px";
		$logicStripe.show().css("display", "block").animate({ height: height }, 200);
		addFilterCounters(containerId);
		var $advancedTextArea = config.container.find(".queryWidgetAdvanced");
		$advancedTextArea.attr("readonly", "readonly");
		config.container.find("#logicString").focus();
	};

	var hideLogicStripe = function(containerId, $logicButton) {
		var config = configByInstance[containerId];
		config.logicEnabled = false;
		var $logicStripe = config.container.find(".logicStripe");
		var $logicStringInput = config.container.find(".logicString");
		$logicStringInput.removeClass("invalidLogic");
		$logicStringInput.removeClass("validLogic");
		$logicStringInput.tooltip("close");
		$logicStringInput.tooltip("disable");
		$logicStripe.animate({ height: "0"}, {
			duration: 200,
			complete: function() {
				$(this).hide();
				$logicButton.show();
				var $advancedTextArea = config.container.find(".queryWidgetAdvanced");
				$advancedTextArea.removeAttr("readonly");
				$advancedTextArea.removeAttr("title");
			}
		});
		removeFilterCounters(containerId);
	};

	var validateLogicString = function(containerId) {
		var config = configByInstance[containerId];
		if (config.logicEnabled) {
			var $logicStringInput = config.container.find(".logicString");
			var logicString = getLogicString(containerId);
			if (logicString.length > 0) {
				var result = buildQueryStructure(containerId, true, true);
				var logicSlices = result.where;
				delete result.where;
				var extraInfo = result;
				$.ajax(contextPath + "/ajax/queryCondition/validateLogic.spr", {
					dataType: "json",
					method: 'POST',
					data: {
						logicString: logicString,
						logicSlicesString: JSON.stringify(logicSlices),
						extraInfoString: JSON.stringify(extraInfo)
					},
					async: false
				}).done(function(result) {
					if (result.hasOwnProperty("groupCustomFieldException") && result.groupCustomFieldException) {
						$logicStringInput.removeClass("validLogic");
						$logicStringInput.addClass("invalidLogic");
						showFancyAlertDialog(i18n.message("query.tooManyTrackerCustomFieldGroup.message"), null, null, function() {
							config["extraLogicWarning"] = false;
						});
						config["extraLogicWarning"] = true;
					} else if (result.hasOwnProperty("success") && result.success) {
						$logicStringInput.removeClass("invalidLogic");
						$logicStringInput.addClass("validLogic");
						$logicStringInput.tooltip("close");
						$logicStringInput.tooltip("disable");
						$logicStringInput.attr("title", "");
					} else if (result.hasOwnProperty("exceptionMessage")) {
						$logicStringInput.removeClass("validLogic");
						$logicStringInput.addClass("invalidLogic");
						$logicStringInput.attr("title", result.exceptionMessage);
						$logicStringInput.tooltip("enable");
						$logicStringInput.tooltip("open");
					}
				});
			} else {
				$logicStringInput.removeClass("invalidLogic");
				$logicStringInput.removeClass("validLogic");
				$logicStringInput.tooltip("close");
				$logicStringInput.tooltip("disable");
			}
		}
	};

	var initLogicButton = function(containerId) {
		var config = configByInstance[containerId];
		var $logicButton = config.container.find(".logicButton");
		var existingLogic = config.logic && $.trim(config.logic.length) > 0 ? config.logic : null;
		$logicButton.click(function() {
			$(this).hide();
			showLogicStripe(containerId);
		});
		var $removeLogic = config.container.find(".removeLogic");
		$removeLogic.click(function() {
			hideLogicStripe(containerId, $logicButton);
		});
		if (existingLogic !== null) {
			config.container.find(".logicString").val(existingLogic);
			$logicButton.click();
		}

		var validateLogicStringThrottle = throttleWrapper(function() {
			validateLogicString(containerId);
		}, 500);
		var $logicStringInput = $(".logicString");
		$logicStringInput.tooltip({
			classes: {
				"ui-tooltip": "invalidLogicTooltip"
			},
			position: {
				my: "left top",
				at: "left bottom"
			}
		});
		$logicStringInput.keyup(validateLogicStringThrottle);
		$logicStringInput.focus(validateLogicStringThrottle);
	};

	var getLogicString = function(containerId) {
		var logicString = $.trim(configByInstance[containerId]["container"].find(".logicString").val());
		if (logicString.length == 0) {
			return "";
		}
		logicString = "(" + logicString + ")";
		return logicString.replace(/\d+/g, function(match) {
			return "@@" + match + "@@";
		});
	};

	var showAjaxLoading = function(containerId) {
		configByInstance[containerId].container.find(".reportAjaxLoading").show();
	};

	var hideAjaxLoading = function(containerId) {
		configByInstance[containerId].container.find(".reportAjaxLoading").hide();
	};

	var isLogicEnabled = function(containerId) {
		return configByInstance[containerId]["logicEnabled"];
	};

	var getAdvancedEditor = function(containerId) {
		return configByInstance[containerId]["advancedEditor"];
	};

	var findTableIndex = function(containerId, $th) {
		var tableIndex = 0;
		var $headerRow = configByInstance[containerId]["resultContainer"].find("th[data-fieldlayoutid]").first().closest("tr");
		$headerRow.find("th").each(function(index, e) {
			if ($th.attr("data-fieldlayoutid") == $(this).attr("data-fieldlayoutid") && $th.attr("data-customfieldtrackerid") == $(this).attr("data-customfieldtrackerid")) {
				tableIndex = index;
				return false;
			}
		});
		return tableIndex;
	};

	var swapColumnsWithIndex = function(containerId, sourceIndex, targetIndex, hasAdditionalColumn, hasAdditionalTargetColumn) {
		var $rows = configByInstance[containerId]["resultContainer"].find('table.trackerItems > tbody > tr:not(.embeddedTableHeader,.embeddedTableRow),' +
			'table.trackerItems > thead > tr:not(.embeddedTableHeader,.embeddedTableRow)');
		$rows.each(function() {
			var tr = $(this);
			var grouppingRow = $(tr.find("td")).length == 1;
			if (!grouppingRow) {
				var selector = ">td:not(.embeddedTableCell,.embeddedTableHeader),>th";
				var element1 = tr.find(selector).eq(sourceIndex);
				if (hasAdditionalColumn) {
					var element1Additional = tr.find(selector).eq(sourceIndex + 1);
				}
				var element2 = tr.find(selector).eq(targetIndex + (hasAdditionalTargetColumn ? 1 : 0));

				if (hasAdditionalColumn) {
					element1Additional.detach().insertAfter(element2);
				}
				element1.detach().insertAfter(element2);
			}
		});
		if (configByInstance[containerId]["reportPage"]) {
			showUnsavedWarning(containerId);
		}
		if (isResizeableColumnsEnabled(containerId)) {
			codebeamer.DisplaytagTrackerItemsResizeableColumns.reInit($("#trackerItems"));
		}
	};

	var swapColumns = function(containerId, $source, $target) {
		if ($source.get(0) == $target.get(0)) {
			return;
		}
		var hasAdditionalSourceColumn = isResizeableColumnsEnabled(containerId) ? false : $source.attr("data-fieldlayoutname") == "Status";
		var hasAdditionalTargetColumn = isResizeableColumnsEnabled(containerId) ? false : $target.attr("data-fieldlayoutname") == "Status";
		swapColumnsWithIndex(containerId, findTableIndex(containerId, $source), findTableIndex(containerId, $target), hasAdditionalSourceColumn, hasAdditionalTargetColumn);
	};

	var findNextColumn = function(containerId, $th) {
		var $headerRow = configByInstance[containerId]["resultContainer"].find("th[data-fieldlayoutid]").first().closest("tr");
		var $ths = $headerRow.find("th:not(.skipColumn)");
		var tableIndex = 0;
		$ths.each(function(index, el) {
			if ($th.attr("data-fieldlayoutid") == $(this).attr("data-fieldlayoutid")) {
				tableIndex = index;
			}
		});
		return $($ths.get(tableIndex == ($ths.length - 1) ? $ths.length - 1 : tableIndex + 1));
	};

	var findPreviousColumn = function(containerId, $th) {
		var $headerRow = configByInstance[containerId]["resultContainer"].find("th[data-fieldlayoutid]").first().closest("tr");
		var $ths = $headerRow.find("th:not(.skipColumn)");
		var tableIndex = 0;
		$ths.each(function(index, el) {
			if ($th.attr("data-fieldlayoutid") == $(this).attr("data-fieldlayoutid")) {
				tableIndex = index;
			}
		});
		return $($ths.get(tableIndex == 0 ? 0 : tableIndex - 1));
	};

	var moveColumnLeft = function(containerId, key, root) {
		var $source = root.$trigger.parent();
		swapColumns(containerId, findPreviousColumn(containerId, $source), $source);
	};

	var moveColumnRight = function(containerId, key, root) {
		var $source = root.$trigger.parent();
		swapColumns(containerId, $source, findNextColumn(containerId, $source));
	};

	var getTrackerLabelKey = function($elem) {
		return $elem.data('cbqlattr');
	};

	var getFieldIdAndMame = function($selector) {
		var fieldId = $selector.data("fieldlayoutid");
		var customTracker = $selector.data("customfieldtrackerid");

		return [fieldId, customTracker];
	};

	var getFieldsFromTable = function(containerId) {
		var config = configByInstance[containerId];
		var fields = [];

		var headerSelector = "th[data-fieldlayoutid]";
		var trackerItemTableId = config['trackerItemTableId'];
		if (trackerItemTableId) {
			headerSelector = "#" + trackerItemTableId + " " + headerSelector;
		}
		var $headerRow = config.resultContainer.find(headerSelector).first().closest("tr");
		$headerRow.find('th[data-fieldlayoutid]').each(function(key, value) {
			var field = getFieldIdAndMame($(value));
			if (typeof field[0] !== "undefined" && field[0] !== null) {
				fields.push([field[0], field[1]]);
			}
		});

		// BUG-750917 removed columns re-appear afterthe report had no results
		if (fields.length == 0) {
			var lastFields = $('#' + containerId).data('lastFields');
			if (typeof lastFields !== 'undefined' && lastFields !== null && lastFields.length > 0) {
				fields = lastFields;
			}
		} else {
			$('#' + containerId).data('lastFields', fields);
		}

		return fields;
	};

	var showMaximumResizeableColumnsWarning = function() {
		showFancyAlertDialog(i18n.message("report.selector.maximum.resizeable.column.warning", MAXIMUM_RESIZEABLE_FIELD_NUMBER));
	};

	var initResizeableColumns = function(containerId) {
		var config = configByInstance[containerId];
		config.showResizeableColumns = true;
		$("#resizeableColumns").on("click", function() {
			if ($(this).is(":checked") && config.resultContainer.find("th[data-fieldlayoutid]").length > MAXIMUM_RESIZEABLE_FIELD_NUMBER) {
				showMaximumResizeableColumnsWarning();
				return false;
			}
			if (config.reportPage) {
				showUnsavedWarning(containerId);
			}
			config.container.find(".searchButton").click();
		});
	};

	var isResizeableColumnsEnabled = function(containerId) {
		if (configByInstance[containerId].showResizeableColumns) {
			return $("#resizeableColumns").length == 1 ? $("#resizeableColumns").is(":checked") : false;
		}
		return false;
	};

	var isSprintHistory = function(containerId) {
		var resultContainer = configByInstance[containerId].resultContainer,
			$releaseFieldHeader = resultContainer.find('th.release-field-header'),
			result = false;

		if ($releaseFieldHeader.length) {
			$releaseFieldHeader.each(function() {
				if ($(this).attr('data-sprintHistory') == 'true') {
					result = true;
				}
			});
			return result;
		} else {
			return undefined;
		}
	}

	var setSprintHistory = function(containerId, sprintHistory) {
		var resultContainer = configByInstance[containerId].resultContainer,
			$releaseFieldHeader = resultContainer.find('th.release-field-header');

		$releaseFieldHeader.each(function() {
			$(this).attr('data-sprintHistory', sprintHistory);
		});
	}

	var getColumnPercentages = function(containerId) {
		var result = {};
		var config = configByInstance[containerId];
		var headerSelector = "th[data-fieldlayoutid]";
		var trackerItemTableId = config['trackerItemTableId'];
		if (trackerItemTableId) {
			headerSelector = "#" + trackerItemTableId + " " + headerSelector;
		}
		var $headerRow = config.resultContainer.find(headerSelector).first().closest("tr");
		var rowWidth = $headerRow.outerWidth();
		$headerRow.find('th[data-fieldlayoutid]').each(function(key, value) {
			var field = getFieldIdAndMame($(value));
			if (typeof field[0] !== "undefined" && field[0] !== null) {
				result[field[0]] = ($(this).outerWidth() / rowWidth) * 100;
			}
		});
		return result;
	};

	var findColumnIndexInTable = function(fields, $target) {
		var targetField = getFieldIdAndMame($target);
		var index = -1;

		for (var i = 0; i < fields.length; i++) {
			if (fields[i][0] == targetField[0] && fields[i][1] == targetField[1]) {
				index = i;
				break;
			}
		}

		return index;
	};

	var removeColumn = function(containerId, $th) {
		var config = configByInstance[containerId];
		if (isLogicInvalid(containerId, config.logicEnabled)) {
			return showInvalidLogicWarning(containerId);
		}

		var fields = getFieldsFromTable(containerId);
		var index = findColumnIndexInTable(fields, $th);
		fields.splice(index, 1);

		//remove aggregates with column
		var aggrFunctions = getAggregateFunctions(containerId);
		var key = getTrackerLabelKey($th);
		delete aggrFunctions[key];
		setAggregateFunctions(containerId, aggrFunctions);

		var queryString = getCbQl(containerId);
		var extraParam = {'fields': fields};

		initAdvancedEditorWithQueryString(containerId, getAdvancedQueryString(containerId, false), isLogicEnabled(containerId));
		var config = configByInstance[containerId];
		if (config.reportPage) {
			codebeamer.ReportPage.fetchQueryResults(queryString, config.queryId, config.advancedMode, extraParam, config.resultContainer, !config.viewMode);
			showUnsavedWarning(containerId);
		} else {
			getReportSelectorResult(containerId, queryString, null, null, fields);
		}
	};

	var insertColumn = function(containerId, $target, $source, toLast) {
		var fields = getFieldsFromTable(containerId);
		var index = toLast ? (fields.length - 1) : findColumnIndexInTable(fields, $target);

		var sourceField = getFieldIdAndMame($source);
		fields.splice(index + 1, 0, sourceField);

		var queryString = getCbQl(containerId);
		var extraParam = {'fields': fields};

		var config = configByInstance[containerId];
		if (config.reportPage) {
			codebeamer.ReportPage.fetchQueryResults(queryString, config.queryId, config.advancedMode, extraParam, config.resultContainer, !config.viewMode);
			showUnsavedWarning(containerId);
		} else {
			getReportSelectorResult(containerId, queryString, null, null, fields);
		}
		initAdvancedEditorWithQueryString(containerId, getAdvancedQueryString(containerId, false), isLogicEnabled(containerId));
	};

	var resetDroppables = function(containerId) {
		$('#' + containerId).find(".droppableArea").each(function() {
			if ($(this).data("ui-droppable")) {
				$(this).droppable("destroy");
			}
		});

		configByInstance[containerId]["resultContainer"].find("#trackerItems>thead").find('th').each(function() {
			if ($(this).data("ui-droppable")) {
				$(this).droppable("destroy");
			}
		});
	};

	var setDragHelper = function(originalItem, helper) {
		helper.find(".tracker-context-menu").remove();
		helper.addClass("duringDragHelper");
	};

	var isDroppableAcceptsElement = function($element) {
		return ($element.hasClass("jstree-node") || $element.closest("table").hasClass("trackerItems"));
	};

	var getDroppableAreas = function(containerId, fieldObject) {
		var trackers = getTrackerIds(containerId);
		var config = configByInstance[containerId];
		var $result = $();
		if (fieldObject) {
			var $widgetContainer = $("#" + containerId);
			$widgetContainer.find(".fieldArea .droppableArea").each(function() {
				if (fieldObject.fieldTypeName != "table" && fieldObject.id != "0") {
					$result = $result.add($(this));
				}
			});
			$widgetContainer.find(".orderByArea .droppableArea").each(function() {
				if (!fieldObject.orderByAble) {
					return false;
				}
				var existingFieldNames = [];
				$(this).find(".droppableField").each(function() {
					var existingFieldObject = $(this).data("fieldObject");
					existingFieldNames.push(existingFieldObject.cbQLOrderByAttributeName);
				});
				if (existingFieldNames.length >= config.maxOrderByElements) {
					return;
				}
				if (!fieldObject.customField && $.inArray(fieldObject.cbQLOrderByAttributeName, existingFieldNames) == -1) {
					$result = $result.add($(this));
				}
				if (fieldObject.customField && trackers.length == 1) {
					$result = $result.add($(this));
				}
			});
			$widgetContainer.find(".groupArea .droppableArea").each(function() {
				if (!fieldObject.groupByAble || fieldObject.id == "0") {
					return false;
				}
				var existingFieldNames = [];
				$(this).find(".droppableField").each(function() {
					var existingFieldObject = $(this).data("fieldObject");
					existingFieldNames.push(existingFieldObject.cbQLGroupByAttributeName);
				});
				if (existingFieldNames.length >= config.maxGroupByElements) {
					return;
				}
				if (!fieldObject.customField && $.inArray(fieldObject.cbQLGroupByAttributeName, existingFieldNames) == -1) {
					$result = $result.add($(this));
				}
				if (fieldObject.customField  && trackers.length == 1) {
					$result = $result.add($(this));
				}
			});
		}
		return $result;
	};

	var initDrag = function(containerId, appendTo) {
		var config = configByInstance[containerId];
		var selector = "#trackerItems>thead, #trackerItems>tbody>.headerRow";
		config.resultContainer.find(selector).first().find('th:not(.skipColumn,.extraInfoColumn)').draggable({
			appendTo : appendTo,
			cursor : 'move',
			helper : 'clone',
			delay: 300,
			stop : function(e, ui) {
				$("#" + containerId).find(".droppableArea").removeClass("highlighted");
				config.resultContainer.find(selector).first().find('th').removeClass("highlighted");
			},
			start : function(e, ui) {
				setDragHelper($(this), ui.helper);
				var fieldName = ui.helper.attr("data-fieldLayoutName");
				var fieldId = ui.helper.attr("data-fieldLayoutId");
				var customFieldTrackerId = ui.helper.attr("data-customfieldtrackerid");
				resetDroppables(containerId);
				config.resultContainer.find(selector).first().find('th').addClass("highlighted");
				config.resultContainer.find(selector).first().find('th:not(.skipColumn)').droppable({
					accept: function($element) {
						return isDroppableAcceptsElement($element);
					},
					drop : function(event, ui) {
						var $element = $(this).find(".drop-marker");
						swapColumns(containerId, $(ui.draggable), $(event.target));
						$element.remove();
						$(this).css("overflow", "");
					},
					over: function (event, ui) {
						var $draggable = $(ui.draggable);
						var $hoveredElement = $(this);
						if ($draggable.prev().attr("data-fieldlayoutid") == $hoveredElement.attr("data-fieldlayoutid")) {
							return;
						}
						// Handle status column with context menu column
						if (!config.resizeableColumns && $hoveredElement.attr("data-fieldlayoutid") == 7 && $hoveredElement.next().next().attr("data-fieldlayoutid") == $draggable.attr("data-fieldlayoutid")) {
							return;
						}
						var $dropMarker = $("<div>", { "class": "drop-marker"});
						$dropMarker.css("left", $hoveredElement.width() + 5);
						$dropMarker.css("height", config.resultContainer.find("table").height());
						$hoveredElement.append($dropMarker);
						$(this).css("overflow", "visible");
					},
					out: function (event, ui) {
						var element = $(this).find(".drop-marker");
						element.remove();
						$(this).css("overflow", "");
					}
				});

				var data = {
					field_id: fieldId
				};
				// If only one tracker is selected, pass this tracker ID because of the correct field label
				var trackers = getTrackerIds(containerId);
				if (trackers.length == 1) {
					data["tracker_id"] = trackers[0]
				}
				// If field is a custom field, pass its tracker ID
				if (customFieldTrackerId && customFieldTrackerId != null && customFieldTrackerId != "null") {
					data["tracker_id"] = customFieldTrackerId
				}
				$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
					dataType: "json",
					data: data,
					async: false
				}).done(function(fieldObject) {

					if (fieldObject == null) {
						showFancyAlertDialog(i18n.message("query.widget.unsupported.field"));
						return false;
					}

					var $droppable = getDroppableAreas(containerId, fieldObject);
					$droppable.addClass("highlighted");

					$droppable.droppable({
						accept: function($element) {
							return isDroppableAcceptsElement($element);
						},
						hoverClass : "dropHover",
						drop: function(event, ui) {
							if ($(this).find(".selectorContainer").length > 0) {
								addOrderByOrGroupByBadge(containerId, $(this), fieldObject, false, "TO_DAY");
							} else {
								try {
									renderField(containerId, fieldObject, true, null);
								} catch (e) {
									showFancyAlertDialog(e);
									return false;
								}
							}
						}
					});
				});

			}
		});
	};

	var setContextMenuMaxWidth = function() {
		var $leafContextMenuLists = $(".reportContextMenu").first().find(".context-menu-list:not(:has(.context-menu-submenu))");
		$leafContextMenuLists.css("max-height", "400px");
		$leafContextMenuLists.css("overflow-y", "auto");
		setTimeout(function() {
			$leafContextMenuLists = $(".reportFilterContextMenu").first().find(".context-menu-list:not(:has(.context-menu-submenu))");
			$leafContextMenuLists.each(function() {
				var $lis = $(this).find("li");
				if ($lis.length == 0 || ($lis.length == 1 && $lis.first().hasClass("disabled"))) {
					$(this).append($("<li>", { "class": "placeHolder"}).text("--"));
				}
			});
		}, 100);
	};

	var orderByFieldImmediately = function(containerId, key, root) {
		var config = configByInstance[containerId];
		var $header = root.$trigger.parent();
		var fieldId = $header.attr("data-fieldlayoutid");
		var data = {
			field_id: fieldId
		};
		var trackers = getTrackerIds(containerId);
		if (trackers.length == 1) {
			data["tracker_id"] = trackers[0]
		}
		var customFieldTrackerId = $header.attr("data-customfieldtrackerid");
		if (customFieldTrackerId && customFieldTrackerId != null && customFieldTrackerId != "null") {
			data["tracker_id"] = customFieldTrackerId
		}
		$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
			dataType: "json",
			data: data,
			async: false
		}).done(function(fieldObject) {
			if (fieldObject == null || !fieldObject.orderByAble) {
				showFancyAlertDialog(i18n.message("query.widget.unsupported.field"));
				return false;
			}
			var $orderByArea = config.container.find(".orderByArea .selectorContainer");
			var exists = false;
			$orderByArea.find(".droppableField").each(function() {
				var existingFieldObject = $(this).data("fieldObject");
				if (existingFieldObject.id != fieldObject.id) {
					$(this).find(".removeDroppableButton").click();
				} else {
					exists = true;
					$(this).find(".descDroppableButton").click();
				}
			});
			if (!exists) {
				addOrderByOrGroupByBadge(containerId, $orderByArea, fieldObject, false, "TO_DAY");
			}
			config.container.find(".searchButton").click();
		});
	};

	var initHeaderContextMenu = function(containerId) {
		var config = configByInstance[containerId];
		var $resultContainer = config.resultContainer;

		createSelector(containerId, "addFieldSelector", config.fieldResult);

		var contextMenu = new ContextMenuManager({
			"selector": "#" + $resultContainer.attr("id") + " th .tracker-context-menu",
			"trigger": "left",
			"className": "reportContextMenu",
			"zIndex": 30,
			events : {
				show: function(opt) {
					opt.$trigger.addClass("activeMenu");
					setContextMenuMaxWidth();
				},
				hide: function() {
					$resultContainer.find(".tracker-context-menu").removeClass("activeMenu");
				}
			},
			build: function($trigger, e) {

				var $tr = $trigger.closest("tr");
				var $contextMenus = $tr.find(".tracker-context-menu");
				var $releaseFieldHeader = $trigger.closest('th.release-field-header');

				var items = {};

				items["addField"] = {
					name: i18n.message("queries.contextmenu.add.field"),
					'callback' : function(key, root) {
						var $selector = $("select#addFieldSelector_" + containerId);
						var menuItemsToDisable = getFieldsFromTable(containerId);
						for (var i = 0; i < menuItemsToDisable.length; i++) {
							var key1 = menuItemsToDisable[i][0];
							var key2 = menuItemsToDisable[i][1] + "_" + menuItemsToDisable[i][0];
							$selector.find("option[value='" + key1 + "']").prop("disabled", true);
							$selector.find("option[value='" + key2 + "']").prop("disabled", true);
						}
						$selector.multiselect("refresh");
						$selector.data("triggeringColumn", $trigger);
						$selector.data("itemKey", key);
						$selector.multiselect("open");
					}
				};
				items["separator1"] = "---";

				items['removeColumn'] = {
					name: i18n.message("queries.contextmenu.removecolumn"),
					'callback': function(key, root) {
						removeColumn(containerId, root.$trigger.parent());
					},
					'icon': 'removeColumn',
					'disabled' : $trigger.closest("th").attr("data-fieldlayoutid") == "3"
				};
				items['moveLeft'] = {
					name: i18n.message("queries.contextmenu.moveleft"),
					'callback': function(key, root) {
						moveColumnLeft(containerId, key, root);
					},
					'icon': 'left',
					'disabled': $trigger.get(0) == $contextMenus.first().get(0)
				};
				items['moveRight'] = {
					name: i18n.message("queries.contextmenu.moveright"),
					'callback': function(key, root) {
						moveColumnRight(containerId, key, root);
					},
					'icon': 'right',
					'disabled': $trigger.get(0) == $contextMenus.last().get(0)
				};

				if (config.reportPage) {
					var isNumber = $trigger.parent().data('isnumeric') == true;
					var isDuration = $trigger.parent().data('isduration') == true;
					if (isNumber || isDuration) {
						items['groupBy'] = {name: i18n.message("queries.contextmenu.groupby"), 'callback': function(key, root) {
							initAggregateFunctionDialog(containerId, key, root);
						}, 'icon': 'summarize'};
					}
					if (isNumber) {
						items['format'] = {name: i18n.message("queries.contextmenu.format"), 'callback': function(key, root) {
							initFieldFormatDialog(containerId, key, root);
						}};
					}
				}

				if (config.showOrderBy) {
					items["separator2"] = "---";
					var fieldId = parseInt($trigger.closest("th").attr("data-fieldlayoutid"), 10);
					var fieldName = $trigger.closest("th").attr("data-fieldlayoutname");
					var direction = i18n.message("queries.contextmenu.ascending");
					var $orderByArea = config.container.find(".orderByArea .selectorContainer");
					$orderByArea.find(".droppableField").each(function() {
						var existingFieldObject = $(this).data("fieldObject");
						if (existingFieldObject.id == fieldId && !$(this).find(".descDroppableButton").hasClass("descActive")) {
							direction = i18n.message("queries.contextmenu.descending");
							return false;
						}
					});
					items["orderBy"] = {
						name: i18n.message("query.widget.order.by") + " " + fieldName + " " + direction,
						'callback': function(key, root) {
							orderByFieldImmediately(containerId, key, root);
						}
					};
				}

				if ($releaseFieldHeader.length) { // menu for a Release field
					var sprintHistory = isSprintHistory(containerId),
						sprintHistoryLabel = (sprintHistory ? 'hide' : 'show') + 'SprintHistory';

					items[sprintHistoryLabel] = {
						name: i18n.message('query.widget.' + sprintHistoryLabel + '.label'),
						callback: function(key, root) {
							setSprintHistory(containerId, !sprintHistory);
							config.container.find('.searchButton').click();
							if (config.reportPage) {
								showUnsavedWarning(containerId);
							}
						}
					};
				}

				return {items: items};
			}
		});

		$resultContainer.off("click", "th .removeColumn");
		$resultContainer.on("click", "th .removeColumn", function() {
			removeColumn(containerId, $(this).closest("th"));
		});

		contextMenu.render();
	};

	var getAggregateValue = function($dialog, $checkbox) {
		var isCustom = $dialog.data('iscustom');
		var cbqlattr = isCustom ? "'" + $dialog.data('cbqlattr') + "'" : $dialog.data('cbqlattr');
		var aggrFunction = $checkbox.data('function');
		var alias = "'_" + aggrFunction + "_" + cbqlattr.replace(/'/g, '') + "'";
		return {'field': cbqlattr, 'alias': alias, 'function': aggrFunction};
	};

	var initAggregateFunctionDialog = function(containerId, key, root) {
		var $dialog = $("#aggregateFunctionDialog");
		var layoutName = root.$trigger.parent().data('fieldlayoutname');
		var fieldI18nCode = "tracker.field." + layoutName + ".label";
		$("#summaryFieldName").text(i18n.messageCodes[fieldI18nCode] == undefined ? layoutName : i18n.message(fieldI18nCode));

		$dialog.data('fieldlayoutname', layoutName);
		$dialog.data('fieldlayoutid', root.$trigger.parent().data('fieldlayoutid'));
		$dialog.data('customfieldtrackerid', root.$trigger.parent().data('customfieldtrackerid'));
		$dialog.data('cbqlattr', root.$trigger.parent().data('cbqlattr'));
		$dialog.data('iscustom', root.$trigger.parent().data('iscustom'));

		// Toggle computed field warning
		var isComputed = root.$trigger.parent().data('iscomputed');
		if (isComputed) {
			$dialog.find(".computedFieldWarning").show();
		} else {
			$dialog.find(".computedFieldWarning").hide();
		}

		var $inputs = $dialog.find("input[type='checkbox']");
		var aggrFunctions = getAggregateFunctions(containerId);
		var key = getTrackerLabelKey($dialog);

		$inputs.each(function(k, value) {
			var $value = $(value);
			var checkboxFunction = $value.data('function');
			var alias = getAggregateValue($dialog, $value);

			var check = false;
			if (aggrFunctions[key] != undefined) {
				var result = $.grep(aggrFunctions[key], function(e){ return e['function'] === checkboxFunction; });
				check = result.length > 0;
			}

			$value.prop('checked', check);
		});

		$dialog.dialog({
			autoOpen: true,
			dialogClass: 'popup',
			modal: true,
			width: "385",
			height: isComputed ? "200" : "135"
		});
	};

	var initFieldFormatDialog = function(containerId, key, root) {
		var $dialog = $("#fieldFormatDialog");
		var layoutName = root.$trigger.parent().data('fieldlayoutname');
		var fieldI18nCode = "tracker.field." + layoutName + ".label";
		$("#formatFieldName").text(i18n.messageCodes[fieldI18nCode] == undefined ? layoutName : i18n.message(fieldI18nCode));

		$dialog.data('fieldlayoutname', layoutName);
		$dialog.data('fieldlayoutid', root.$trigger.parent().data('fieldlayoutid'));
		$dialog.data('customfieldtrackerid', root.$trigger.parent().data('customfieldtrackerid'));
		$dialog.data('cbqlattr', root.$trigger.parent().data('cbqlattr'));

		var format = getFieldFormat(containerId);
		var key = getTrackerLabelKey($dialog);

		if (format[key] != undefined) {
			if (format[key]['numberFormat'] != undefined) {
				$dialog.find("#numberFormat option[value='" + format[key]['numberFormat'] +"']").prop('selected', true);
			}

			if (format[key]['decimalFormat'] != undefined) {
				$dialog.find("#decimalFormat option[value='" + format[key]['decimalFormat'] +"']").prop('selected', true);
			}
		} else {
			$dialog.find("#numberFormat option[value='number']").prop('selected', true);
			$dialog.find("#decimalFormat option[value='0']").prop('selected', true);
		}

		$dialog.dialog({
			autoOpen: true,
			dialogClass: 'popup',
			modal: true,
			width: "385",
			height: "135"
		});
	};

	var initContextualSearch = function(containerId) {
		var config = configByInstance[containerId];
		var $searchBox = config.container.find(".contextualSearchBox");
		$searchBox.focusin(function() {
			$(this).animate({
				width: 200
			});
		});
		$searchBox.focusout(function() {
			if ($(this).val() == "") {
				$(this).animate({
					width: 100
				});
			}
		});
		fixContextualSearchBoxPosition(containerId);
	};

	var fixContextualSearchBoxPosition = function(containerId) {
		var config = configByInstance[containerId];
		var fixPosition = function() {
			var $searchBox = config.container.find(".contextualSearchBox");
			var $table = config.container.find(".reportSelectorTable");
			$searchBox.css("top", ($table.height() + 30) * -1);
		};
		fixPosition();
		setInterval(fixPosition, 200);
	};

	var initActionBar = function(containerId) {
		var config = configByInstance[containerId];
		config.container.closest(".actionBar").addClass("reportSelectorActionBar");
	};

	var setSticky = function(containerId) {
		var config = configByInstance[containerId];
		var $placeholder = null;

		var scrollHandler = function() {
			var currentConfig = configByInstance[containerId];
			var $container = config.mergeToActionBar ? currentConfig.container.closest(".actionBar") : currentConfig.container;
			var scrollTop = $(this).scrollTop();
			if (scrollTop >= currentConfig.containerOffset) {
				if ($placeholder === null) {
					// Placeholder element with the same size as the container.
					// Position change of the scroll element can trigger a scroll event depending on the height of the page (page reflow).
					// This might cause an immediate scoll back after reaching the bottom of the page (flickering).
					$placeholder = $("<div></div>").css({
						height: $container.height(),
						width: $container.width()
					});
				}
				$container.css("position", "fixed");
				$container.css("top", 0);
				if (config.mergeToActionBar) {
					$container.css("width", "100%");
					$container.find(".reportSelectorActionBarTable").css("width", "99%");
				}
				if ($placeholder !== null) {
					$container.after($placeholder);
				}
			} else {
				if ($placeholder !== null) {
					$placeholder.remove();
					$placeholder = null;
				}
				$container.css("position", "static");
				$container.css("top", "");
				if (config.mergeToActionBar) {
					$container.css("width", "");
					$container.find(".reportSelectorActionBarTable").css("width", "100%");
				}

			}
		};

		var layoutScrollHandler = function() {
			var currentConfig = configByInstance[containerId];
			var $container = currentConfig.container;
			var scrollTop = $(this).scrollTop();
			if (scrollTop > currentConfig.containerOffset) {
				$container.css("position", "fixed");
				$container.css("width", $(this).find("#requirements").width());
				$container.find(".contextualSearchBox").hide();
			} else {
				$container.css("position", "static");
				$container.css("top", "");
				$container.css("width", "");
				$container.find(".contextualSearchBox").hide();
			}
		};

		var containerOffset = config.mergeToActionBar ? config.container.closest(".actionBar").offset().top : config.container.offset().top;
		config["containerOffset"] = containerOffset;
		var $pane = config.container.closest("#rightPane");
		var layout = $pane.length > 0;
		if (layout) {
			$pane.scroll(layoutScrollHandler);
			// Fixed "bouncing" scrollbar
			setInterval(function() {
				var delta = $pane.height() - config.resultContainer.height();
				if (delta > 0) {
					$pane.css("overflow-y", "hidden");
				} else {
					$pane.css("overflow-y", "auto");
				}
			}, 100);
		} else {
			$(window).scroll(scrollHandler);
		}
	};

	/**
	 * returns the selected option values for a filter that is not a field in the tracker (reference filter, rating filter etc).
	 */
	var getDocumentViewSpecialFieldValues = function(containerId, filterSelector) {
		var $container = configByInstance[containerId]["container"];
		var $select = $container.find(".selectorSection").find(filterSelector);
		if ($select.length > 0) {
			var $inputs = $select.multiselect("getChecked");
			var values = [];
			for (var i = 0; i < $inputs.length; i++) {
				values.push($($inputs[i]).val());
			}
			if (values[0] == "0") {
				return null;
			}
			return values.join(",");
		}
		return null;
	};

	var getDocumentViewRatingValues = function(containerId) {
		return getDocumentViewSpecialFieldValues(containerId, ".documentViewRating");
	};

	var getDocumentViewBranchStatusValues = function(containerId) {
		return getDocumentViewSpecialFieldValues(containerId, ".documentViewBranchStatus");
	};

	var getDocumentViewReferenceValue = function(containerId) {
		var $container = configByInstance[containerId]["container"];
		var $select = $container.find(".selectorSection").find(".documentViewReference");
		if ($select.length > 0) {
			var values = $select.multiselect("getChecked");
			var $inputs = $select.multiselect("getChecked");
			var values = [];
			for (var i = 0; i < $inputs.length; i++) {
				values.push($($inputs[i]).val());
			}
			return values[0] == "0" ? null : values[0];
		}
		return null;
	};

	var getStorageId = function(containerId) {
		var config = configByInstance[containerId];
		var id = config.releaseId;
		if (config.traceabilityTrackerId) {
			return config.traceabilityTrackerId;
		}
		if (config.releaseTrackerId) {
			return config.releaseTrackerId;
		}
		if (config.trackerId) {
			return config.trackerId;
		}
		if (config.projectId) {
			return config.projectId;
		}
		return id;
	};

	var setReportSelectorStorage = function(containerId, data) {
		var cookieId = getStorageId(containerId);
		var storedData = $.jStore.get("CB-reportSelectorData");
		var allData = {};
		if (storedData) {
			allData = storedData;
		}
		allData[cookieId] = data;
		$.jStore.set("CB-reportSelectorData", JSON.stringify(allData));
	};

	var getReportSelectorStorageData = function(containerId) {
		var storedData = $.jStore.get("CB-reportSelectorData");
		if (storedData) {
			var cookieId = getStorageId(containerId);
			if (storedData.hasOwnProperty(cookieId)) {
				var json = storedData[cookieId];
				var result = {
					"cbQL" : json["cbQL"]
				};
				var filterAttributes = {};
				if (json.hasOwnProperty("filter")) {
					filterAttributes["filter"] = json["filter"];
				}
				if (json.hasOwnProperty("ratingFilters")) {
					filterAttributes["ratingFilters"] = json["ratingFilters"];
				}
				if (json.hasOwnProperty("referenceFilter")) {
					filterAttributes["referenceFilter"] = json["referenceFilter"];
				}
				if (!$.isEmptyObject(filterAttributes)) {
					result["filterAttributes"] = filterAttributes;
				}
				if (json.hasOwnProperty("logicString")) {
					result["logicString"] = json["logicString"];
				}
				if (json.hasOwnProperty("logicSlicesString")) {
					result["logicSlicesString"] = json["logicSlicesString"];
				}
				if (json.hasOwnProperty("queryId")) {
					result["queryId"] = json["queryId"];
				}
				if (json.hasOwnProperty("resizeableColumns")) {
					result["resizeableColumns"] = json["resizeableColumns"];
				}
				return result;
			}
			return null;
		}
		return null;
	};

	var getSpecialFilterValues = function (containerId) {
		var config = configByInstance[containerId];

		var data = {};

		var rating = getDocumentViewRatingValues(containerId);
		if (rating != null) {
			data["ratingFilters"] = rating;
		}
		var reference = getDocumentViewReferenceValue(containerId);
		if (reference != null) {
			data["referenceFilter"] = reference;
		}

		if (config.isBranchMode) {
			var branchStatus = getDocumentViewBranchStatusValues(containerId);
			if (branchStatus != null) {
				data["branchStatusFilters"] = branchStatus;
			}
		}

		return data;
	};

	var getReportId = function (containerId) {
		var config = configByInstance[containerId];
		if (!config) {
			return null;
		}
		return config.queryId;
	};

	var intelligentTableViewIsEnabled = function(containerId) {
		return configByInstance[containerId].resultContainer.find("#intelligentTableViewConfiguration").length > 0;
	};

	var getIntelligentTableViewConfiguration = function(containerId) {
		return configByInstance[containerId].resultContainer.find("#intelligentTableViewConfiguration").val();
	};

	var getReportSelectorResult = function(containerId, queryString, page, pageSize, fields, ignoreFields, filterAttributes, callback, isIncrementalScroll, skipIntelligentTableViewConfig) {
		var config = configByInstance[containerId];

		var busy = null;
		if (config.isPlanner) {
			codebeamer.planner.setCbQLForPlannerFilters(queryString);
			if (!isIncrementalScroll) {
				codebeamer.planner.clearIncrementalScroll();
				codebeamer.planner.showAjaxLoading();
			}
		} else {
			busy = ajaxBusyIndicator.showBusyPage();
		}

		var data = {
			"cbQL" : queryString,
			"reportId" : config.queryId,
			"projectId" : config.projectId,
			"trackerId" : config.trackerId,
			"releaseId" : config.releaseId
		};
		if (typeof page !== "undefined" && page !== null) {
			data["page"] = page;
		} else {
			var pageParameter = getParameterByName('page', window.location.href);

			if (pageParameter && parseInt(pageParameter, 10)) {
				data['page'] = pageParameter;
			}
		}
		if (!ignoreFields) {
			fields = fields ? fields : getFieldsFromTable(containerId);
			if (fields.length > 0) {
				data["fields"] = JSON.stringify(fields);
			}
		}
		if (pageSize) {
			data["pagesize"] = pageSize;
		} else {
			var showAllParameter = getParameterByName('showAll', window.location.href);

			if (showAllParameter) {
				data['showAll'] = true;
			}
		}
		// Add tracker_id parameter if it is Document View for supporting existing structure
		if (config.isDocumentView) {
			data["tracker_id"] = config.trackerId;
			var subtreeRoot = getParameterByName("subtreeRoot", window.location.href);
			data["subtreeRoot"] = subtreeRoot;
		}

		if (config.isDocumentView || config.isPlanner) {
			if (typeof trackerObject !== "undefined" && trackerObject.config.extended) {
				data['currentFieldList'] = codebeamer.trackers.extended.getCurrentFieldList();
			}

			var specialFilterValues = filterAttributes ? filterAttributes : getSpecialFilterValues(containerId);
			data = $.extend(data, specialFilterValues);
		}

		if (config.contextualSearch) {
			var filterString = config.container.find(".contextualSearchBox").val();
			if (filterString && filterString != "") {
				data["filter"] = filterString;
			}
		}

		if (config.releaseTrackerId) {
			data["releaseTrackerId"] = config.releaseTrackerId;
		}
		if (config.hasOwnProperty("recursiveRelease")) {
			data["recursive"] = config.recursiveRelease;
		}

		if (config.filterProjectIds) {
			data["filterProjectIds"] = config.filterProjectIds;
		}
		if (config.filterTrackerIds) {
			data["filterTrackerIds"] = config.filterTrackerIds;
		}

		if (config.showResizeableColumns && isResizeableColumnsEnabled(containerId)) {
			data["resizeableColumns"] = true;
		} else if (config.queryId > 0) {
			data["resizeableColumns"] = false;
		}

		if (skipIntelligentTableViewConfig) {
			data["intelligentTableViewConfiguration"] = null;
		} else if (intelligentTableViewIsEnabled(containerId)) {
			data["intelligentTableViewConfiguration"] = getIntelligentTableViewConfiguration(containerId);
		}

		if (UrlUtils.getParameter('view_id') == config.queryId) {
			var sprintHistory = isSprintHistory(containerId);
			if (typeof sprintHistory != 'undefined') {
				data['sprintHistory'] = sprintHistory;
			}
		}

		$.ajax(contextPath + config.resultRenderUrl, {
			method: "POST",
			type: "json",
			data: data
		}).done(function(result) {
			if (config.logicEnabled) {
				data["logicString"] = config.container.find(".logicString").val();
				if (config.logicSlicesString && config.logicSlicesString.length > 0) {
					data["logicSlicesString"] = config.logicSlicesString;
				} else if (config.logic && config.logic.length > 0) {
					data["logicSlicesString"] = JSON.stringify(config.logicSlices);
				} else {
					var queryStructure = buildQueryStructure(containerId, true, true);
					var logicSlices = queryStructure.where;
					data["logicSlicesString"] = JSON.stringify(logicSlices);
				}
			}

			// destroy wysiwyg editor if present
			var $columnInProgress = config.resultContainer.find(".columnEditingInProgress");
			if ($columnInProgress.length > 0) {
				var editorId = $columnInProgress.find(".editor-wrapper textarea").attr("id");
				if (editorId) {
					var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);
					editor.destroy();
					if (codebeamer && codebeamer.DisplaytagTrackerItemsInlineEdit) {
						codebeamer.DisplaytagTrackerItemsInlineEdit.clearNavigateAway();
					}
				}
			}

			if (typeof callback !== "undefined") {
				callback(result);
			} else {
				config.resultContainer.html(result);
			}
			if (config.resultJsCallback) {
				executeFunctionByName(config.resultJsCallback, window, config.container, result, config.resultContainer);
			}
			data["queryId"] = config.queryId;
			if (config.trackerId || config.releaseTrackerId || config.releaseId) {
				setReportSelectorStorage(containerId, data);
			}

			createSelector(containerId, "addFieldSelector", config.fieldResult);

			applyContextMenuUserPreference(containerId);
		}).always(function() {
			if (busy !== null) {
				ajaxBusyIndicator.close(busy);
			}
		});
	};

	var initReportSelectorSearchButton = function(containerId) {
		var config = configByInstance[containerId];
		config.container.find(".searchButton").click(function(e) {
			e.preventDefault();
			if (isLogicInvalid(containerId, config.logicEnabled)) {
				return showInvalidLogicWarning(containerId);
			}
			buildQueryString(containerId, false);
			getReportSelectorResult(containerId, config.container.data("queryString"));
			if (config.isPlanner) {
				$("#plannerCenterPane").animate({ scrollTop: 0 }, 100);
			}
		});
	};

	// Default callback in Table View
	var defaultReportTagSelectorResultCallback = function($container, result, $resultContainer) {
		$("html, body").animate({ scrollTop: 0 }, 500);
		var containerId = $container.attr("id");
		toggleDisabledActionsBecauseOfIntelligentTableView(containerId);
		if (intelligentTableViewIsEnabled(containerId)) {
			configByInstance[containerId]["intelligentTableView"] = true;
		}
		if (configByInstance[containerId]["intelligentTableView"]) {
			codebeamer.IntelligentTableView.initHeader();
		} else {
			initHeaderContextMenu(containerId);
			initDrag(containerId, "body");
		}
		$resultContainer.find(".pagebanner>a, .pagelinks>a").click(function(e) {
			e.preventDefault();
			var nextLocation = $(e.target).attr('href');
			var queryString = getCbQl(containerId);
			var pageParam = getParamFromUrl(nextLocation, "page");
			var pagesizeParam = getParamFromUrl(nextLocation, "pagesize");
			getReportSelectorResult(containerId, queryString, pageParam, pagesizeParam);

			if (pageParam) {
				var urlUpdate = UrlUtils.addOrReplaceParameter(window.location.href, 'page', pageParam);
				History.pushState({ url : urlUpdate }, document.title, urlUpdate);
			}

			if (pagesizeParam && !pageParam) {
				var urlUpdate = UrlUtils.removeParameter(window.location.href, 'page');
				urlUpdate = UrlUtils.addOrReplaceParameter(urlUpdate, 'showAll', 'true');
				History.pushState({ url : urlUpdate }, document.title, urlUpdate);
			}
		});

		preventPopStateTriggeringIfHashmarkChange();
		var stateChangeHandler = function(e) {
			// There might be a better way for detecting browser back button, but popstate event is triggered on pushstate as well...
			if (e.originalEvent) {
				var queryString = getCbQl($container.attr('id'));
				var pageParam = getParamFromUrl(window.location.href, 'page');
				var pagesizeParam = getParamFromUrl(window.location.href, 'pagesize');
				getReportSelectorResult($container.attr("id"), queryString, pageParam, pagesizeParam);
			}
			$(window).off('popstate', stateChangeHandler);
		};
		$(window).on('popstate', stateChangeHandler);
	};

	var refreshPickerContainer = function(containerId) {
		var config = configByInstance[containerId];
		var $reportPickerContainer = $("#reportPickerContainer_" + containerId);
		var $reportPickerMenuHeader = $reportPickerContainer.find(".reportPickerMenuHeader");
		var reportIdToCheck = config.queryId;
		var isPredefined = false;
		if (reportIdToCheck < 0) {
			isPredefined = true;
		}
		// Display the set default view (or All Items) if no queryId provided
		if (!config.queryId) {
			reportIdToCheck = config.defaultViewId ? config.defaultViewId : -2;
		}
		if (reportIdToCheck == -11) {
			reportIdToCheck = -2;
		}
		if (!config.isDocumentView) {
			updateUrl(reportIdToCheck);
		}
		rewriteTraceabilityBrowserUrl(reportIdToCheck);
		if (typeof reportIdToCheck == "undefined" || reportIdToCheck == null) {
			$reportPickerMenuHeader.find(".save").show();
			$reportPickerMenuHeader.find(".saveAs").hide();
			$reportPickerMenuHeader.find(".properties").hide();
			$reportPickerMenuHeader.find(".delete").hide();
			$reportPickerContainer.find(".reportPickerIntelligentTableView").hide();
			$reportPickerContainer.find(".reportPickerCurrentHeader").hide();
		} else {
			var $input = $reportPickerContainer.find('input[value="' + reportIdToCheck + '"]');
			$reportPickerContainer.find('input[type="radio"]').prop("checked", false);
			$input.prop("checked", true);
			var reportName = $input.next(".reportName").text();
			$reportPickerContainer.find(".reportPickerCurrentHeader").find(".reportName").text(reportName);
			$(".reportSelectorSelectedViewLabel").text(reportName);
			$reportPickerContainer.find(".reportPickerCurrentHeader").show();
			var isPublic = $input.closest(".reportTypeListContainer").prev(".reportTypeHeader").hasClass("publicReports");
			if (isPublic) {
				if (reportIdToCheck == config.defaultViewId) {
					$reportPickerContainer.find(".setAsDefault").hide();
					$reportPickerContainer.find(".clearDefault").show();
				} else {
					$reportPickerContainer.find(".setAsDefault").show();
					$reportPickerContainer.find(".clearDefault").hide();
				}
			} else {
				$reportPickerContainer.find(".setAsDefault").hide();
				$reportPickerContainer.find(".clearDefault").hide();
			}
			if (!isPredefined && ((isPublic && config.canUserAdminPublicReport) || !isPublic)) {
				$reportPickerMenuHeader.find(".save").show();
			} else {
				$reportPickerMenuHeader.find(".save").hide();
			}
			$reportPickerMenuHeader.find(".saveAs").show();
			if (!isPredefined) {
				$reportPickerMenuHeader.find(".properties").show();
				$reportPickerMenuHeader.find(".delete").show();
				$reportPickerContainer.find(".reportPickerIntelligentTableView").show();
			} else {
				$reportPickerMenuHeader.find(".properties").hide();
				$reportPickerMenuHeader.find(".delete").hide();
				$reportPickerContainer.find(".reportPickerIntelligentTableView").hide();
			}
		}
	};

	var rewriteTraceabilityBrowserUrl = function(reportId) {
		var $link = $(".traceabilityBrowserActionIcon");
		if (typeof reportId !== "undefined" && reportId != null && $link.length > 0) {
			var urlUpdate = addParameterToUrl($link.attr("href"), "view_id", reportId);
			$link.attr("href", urlUpdate);
		}
	};

	var updateUrl = function(reportId) {
		var urlUpdate = addParameterToUrl(location.href, "view_id", reportId);
		History.pushState({ "url" : urlUpdate }, document.title, urlUpdate);
	};

	var loadExistingReports =function(containerId) {
		var config = configByInstance[containerId];

		var createReportList = function($appendTo, reports, disableEdit) {
			var $ul = $("<ul>");
			for (var i = 0; i < reports.length; i++) {
				var report = reports[i];
				var $input = $("<input>", { type: "radio", value: report.id});
				$input.data("storedReport", report);
				$input.click(function() {
					codebeamer.columnsDirty = false;

					var storedReport = $(this).data("storedReport");
					var filterAttributes = storedReport.hasOwnProperty("filterAttributes") ? storedReport.filterAttributes : null;
					if (storedReport.logic && storedReport.logic.length > 0) {
						config.logicEnabled = true;
						var logic = storedReport.logic;
						logic = logic.replaceAll("@", "");
						logic = logic.slice(1, -1); // remove brackets, they will be added back by saving/validating
						config.logic = logic;
						config.logicSlices = JSON.parse(storedReport.logicSlices);
						config.container.find(".logicString").val(config.logic);
						config.container.find(".logicButton").click();
					} else {
						config.logicEnabled = false;
						config.container.find(".logicString").val("");
						config.container.find(".removeLogic").click();
					}
					if (storedReport.resizeableColumns) {
						$("#resizeableColumns").prop("checked", true);
					} else {
						$("#resizeableColumns").prop("checked", false);
					}
					enableAllMenuItems($("#orderBySelector_" + containerId));
					enableAllMenuItems($("#groupBySelector_" + containerId));
					initContainer(containerId, storedReport.id, storedReport.cbQL, true, true, filterAttributes);
					config.queryId = storedReport.id;
					var cbQL = storedReport.cbQL;
					if (config.isDocumentView) {
						config["initialCbQL"] = storedReport.cbQL;
						config["initialCbQLForTree"] = storedReport.cbQL;
					}
					config.queryString = cbQL;
					getReportSelectorResult(containerId, cbQL, null, null, null, true, filterAttributes, undefined, false, true);
					refreshPickerContainer(containerId);
					$("#reportPickerContainer_" + containerId).hide();
				});
				var $reportName = $("<span>", { "class" : "reportName"}).text(report.name);
				$reportName.click(function() {
					$(this).prev("input").click();
				});
				var $li = $("<li>");
				$li.append($input);
				$li.append($reportName);
				if (!disableEdit) {
					var $reportEdit = $("<span>", { "class" : "reportEdit", title : i18n.message("queries.contextmenu.properties")});
					$reportEdit.click(function(e) {
						e.stopPropagation();
						showProperties(containerId, $(this).closest("li").find("input").first().val());
					});
					var $reportDelete = $("<span>", { "class" : "reportDelete", title : i18n.message("queries.contextmenu.delete")});
					$reportDelete.click(function(e) {
						e.stopPropagation();
						var $that = $(this);
						var reportId = $that.closest("li").find("input").first().val();
						showFancyConfirmDialogWithCallbacks(i18n.message("queries.delete.warning"),function() {
							deleteReport(containerId, reportId, function() {
								if (reportId == config.queryId) {
									refreshPickerContainer(containerId);
									$("#reportPickerContainer_" + containerId).find('input[value="-2"]').click();
								} else {
									loadExistingReports(containerId);
								}
							})
						}, function(){});
					});
					$li.append($reportDelete);
					$li.append($reportEdit);
				}
				$ul.append($li);
			}
			$appendTo.append($ul);
		};

		$.ajax({
			url: contextPath + "/reportselector/loadReports.spr",
			method: "GET",
			dataType: "json",
			data: {
				"projectId" : config.projectId,
				"trackerId" : config.releaseTrackerId ? config.releaseTrackerId : config.trackerId,
				"releaseId" : config.releaseId
			},
			success: function(result) {
				var $picker = $("#reportPickerContainer_" + containerId).find(".userDefinedReportPicker");
				var $publicReports = $("#reportPickerContainer_" + containerId).find(".publicReportPicker");
				$picker.empty();
				$publicReports.empty();
				if (result.hasOwnProperty("own")) {
					var ownReports = result.own;
					if (ownReports.length > 0) {
						createReportList($picker, ownReports);
					} else {
						$picker.html(i18n.message("report.selector.no.private.reports"));
					}
				} else {
					$picker.html(i18n.message("report.selector.no.private.reports"));
				}
				if (result.hasOwnProperty("public")) {
					var publicReports = result["public"];
					if (publicReports.length > 0) {
						createReportList($publicReports, publicReports, !config.canUserAdminPublicReport);
					}
				}
				refreshPickerContainer(containerId);
			}
		});
	};

	var saveReport = function(containerId, name, description, isPublic, logicString, logicSlicesString, extraInfoString, callback) {
		var config = configByInstance[containerId];
		if (isLogicInvalid(containerId, config.logicEnabled)) {
			return showInvalidLogicWarning(containerId);
		}
		var reportId = config.queryId;
		var fields = getFieldsFromTable(containerId);

		var data = {
			"cbQL" : getCbQl(containerId),
			"fields" : JSON.stringify(fields),
			"name" : name,
			"isPublic" : isPublic
		};

		if (isResizeableColumnsEnabled(containerId)) {
			data["columnWidths"] = encodeURIComponent(JSON.stringify(getColumnPercentages(containerId)));
		}

		data['sprintHistory'] = isSprintHistory(containerId);

		// Do not save fields for cardboard
		if (config.releaseId && !config.isPlanner) {
			data["fields"] = null;
		}
		// Do not save field in Document View, but save in Document Extended View (Document Edit View)!
		if (config.isDocumentView && !config.isDocumentExtendedView) {
			data["fields"] = null;
		}
		if (description !== null) {
			data["description"] = description;
		}
		if (reportId != "false") {
			data["reportId"] = reportId;
		}
		if (config.releaseTrackerId) {
			data["trackerId"] = config.releaseTrackerId;
		} else if (config.trackerId) {
			data["trackerId"] = config.trackerId;
		} else if (config.projectId) {
			data["projectId"] = config.projectId;
		} else if (config.releaseId) {
			data["releaseId"] = config.releaseId;
		}
		if (isLogicEnabled(containerId)) {
			data["logicString"] = logicString;
			data["logicSlicesString"] = logicSlicesString;
			data["extraInfoString"] = extraInfoString;
		}

		var rating = getDocumentViewRatingValues(containerId);
		if (rating != null) {
			data["ratingFilters"] = rating;
		}
		if (config.isDocumentView) {
			var reference = getDocumentViewReferenceValue(containerId);
			if (reference != null) {
				data["referenceFilter"] = reference;
			}

			if (config.isBranchMode) {
				var branchStatus = getDocumentViewBranchStatusValues(containerId);
				if (branchStatus != null) {
					data["branchStatusFilters"] = branchStatus;
				}
			}
		}
		if (config.contextualSearch) {
			var filterString = config.container.find(".contextualSearchBox").val();
			if (filterString && filterString != "") {
				data["filter"] = filterString;
			}
		}

		if (intelligentTableViewIsEnabled(containerId)) {
			data["intelligentTableViewConfiguration"] = getIntelligentTableViewConfiguration(containerId);
		}

		$.ajax({
			url: contextPath + "/reportselector/saveReport.spr",
			method: "POST",
			dataType: "json",
			data: data,
			success: function(result) {
				if (result.hasOwnProperty("reportId")) {
					config.queryId = result.reportId;
					showOverlayMessage(i18n.message("report.selector.saved.successfully"));
					loadExistingReports(containerId);
					if (!config.isDocumentView) {
						updateUrl(result.reportId);
					}
					rewriteTraceabilityBrowserUrl(reportId);

					$('body').trigger('codebeamer.reportSaved', [result.reportId]);
				} else if (result.hasOwnProperty("errorMessage")) {
					showOverlayMessage(result.errorMessage, null, true);
				} else {
					showOverlayMessage(i18n.message("report.selector.save.error"), null, true);
				}
				configByInstance[containerId]["navigateAwayProtection"] = false;
			}
		});
	};

	var afterSavedPropertiesCallback = function(containerId) {
		loadExistingReports(containerId);
	};

	var deleteReport = function(containerId, reportId, callback) {
		$.ajax({
			url: contextPath + "/reportselector/deleteReport.spr",
			method: "GET",
			dataType: "json",
			data: {
				"reportId": reportId
			},
			success: function () {
				showOverlayMessage(i18n.message("report.selector.deleted.successfully"));
				loadExistingReports(containerId);
				callback();
			},
			fail: function() {
				showOverlayMessage(i18n.message("report.selector.save.error"), null, true);
			}
		});
	};

	var showProperties = function(containerId, reportId) {
		var config = configByInstance[containerId];
		var url = contextPath + "/proj/query/permission.spr?queryId=" + reportId + "&reportSelectorContainerId=" + containerId;
		if (config.trackerId) {
			url += "&reportSelectorTrackerId=" + config.trackerId;
		}
		if (config.releaseId) {
			url += "&reportSelectorReleaseId=" + config.releaseId;
		}
		configByInstance[containerId]["navigateAwayProtection"] = false;
		showPopupInline(url);
	};

	var initReportPicker = function(containerId) {
		var config = configByInstance[containerId];
		var $pickerButton = config.container.find(".reportSelectorButton");

		config.container.find(".reportPickerContainer").attr("id", "reportPickerContainer_" + containerId);

		var fixPickerContainerPosition = function() {
			var topOffset = "";
			if (config.mergeToActionBar) {
				topOffset = "+5";
				if (config.isDocumentView) {
					topOffset = "+4";
				}
			}
			$("#reportPickerContainer_" + containerId).position({
				of: config.container,
				my: "right top" + topOffset,
				at: "right bottom"
			});
		};

		if (config.sticky) {
			$(window).scroll(function() {
				setTimeout(function() {
					fixPickerContainerPosition();
				}, 100);
			});
		}

		$(window).resize(function() {
			setTimeout(function() {
				fixPickerContainerPosition();
			}, 100);
		});

		$pickerButton.click(function(e) {
			e.stopPropagation();
			var $pickerContainer = config.container.find(".reportPickerContainer");

			if ((config.isDocumentView && config.mergeToActionBar) || config.isPlanner) {
				$("#panes").append($pickerContainer.clone());
				$pickerContainer.detach();
				$pickerContainer = $("#reportPickerContainer_" + containerId);
			}
			var initialized = $pickerContainer.data("initialized");
			if ($pickerContainer.is(":visible")) {
				$pickerContainer.hide();
			} else {
				$pickerContainer.show();
				fixPickerContainerPosition();
				refreshPickerContainer(containerId);

				if (!initialized) {
					if (config.showResizeableColumns) {
						initResizeableColumns(containerId);
					}
					loadExistingReports(containerId);
					$pickerContainer.find("li.predefined input").click(function() {
						var reportId = $(this).val();
						config.queryId = reportId;
						$.ajax({
							url: contextPath + "/reportselector/getPredefinedReport.spr",
							method: "GET",
							dataType: "json",
							data: {
								"trackerId": config.releaseTrackerId ? null : config.trackerId,
								"reportId": reportId
							},
							success: function (resultCbQL) {
								config.queryString = resultCbQL;
								config.logicEnabled = false;
								config.logic = null;
								config.container.find(".logicString").val("");
								config.container.find(".removeLogic").click();
								enableAllMenuItems($("#orderBySelector_" + containerId));
								enableAllMenuItems($("#groupBySelector_" + containerId));
								initContainer(containerId, reportId, resultCbQL, true, true);
								getReportSelectorResult(containerId, resultCbQL, null, null, null, true);
								refreshPickerContainer(containerId);
							}
						});
						$pickerContainer.hide();
					});
					$pickerContainer.find("li.predefined .reportName").click(function(e) {
						e.stopPropagation();
						$(this).prev("input").click();
					});

					var save = function() {
						if (isLogicInvalid(containerId, config.logicEnabled)) {
							return showInvalidLogicWarning(containerId);
						}
						getCbQl(containerId);
						var url = contextPath + "/proj/query/permission.spr?reportSelectorSaveMode=true&reportSelectorContainerId=" + containerId;
						if (config.trackerId || config.releaseTrackerId) {
							url += "&reportSelectorTrackerId=" + (config.releaseTrackerId ? config.releaseTrackerId : config.trackerId);
						}
						if (config.releaseId) {
							url += "&reportSelectorReleaseId=" + config.releaseId;
						}
						showPopupInline(url);
					};

					$pickerContainer.find(".save").click(function(e) {
						e.stopPropagation();
						if (!config.queryId || config.queryId < 0) {
							save();
						} else {
							var logicString = isLogicEnabled(containerId) ? getLogicString(containerId) : "";
							var logicSlices = null;
							var extraInfo = null;
							if (isLogicEnabled(containerId) && logicString.length > 0) {
								var result = buildQueryStructure(containerId, false, true);
								logicSlices = result.where;
								delete result.where;
								extraInfo = result;
							}
							saveReport(containerId, null, null, config.currentIsPublic, logicString, JSON.stringify(logicSlices), JSON.stringify(extraInfo));
						}
					});
					$pickerContainer.find(".saveAs").click(function(e) {
						e.stopPropagation();
						save();
					});
					$pickerContainer.find(".properties").click(function(e) {
						e.stopPropagation();
						showProperties(containerId, config.queryId);
					});
					$pickerContainer.find(".delete").click(function(e) {
						e.stopPropagation();
						showFancyConfirmDialogWithCallbacks(i18n.message("queries.delete.warning"),function() {
							deleteReport(containerId, config.queryId, function() {
								refreshPickerContainer(containerId);
								$pickerContainer.find('input[value="-2"]').click();
							})
						}, function(){});
					});
					$pickerContainer.find(".revert").click(function() {
						initContainer(containerId, config.queryId, config.queryString, true, true);
						getReportSelectorResult(containerId, config.queryString);
						$pickerContainer.hide();
					});
					$pickerContainer.find(".setAsDefault").click(function(e) {
						e.stopPropagation();
						$.ajax({
							url: contextPath + "/reportselector/setDefaultReport.spr",
							method: "GET",
							dataType: "json",
							data: {
								"trackerId": config.releaseTrackerId ? config.releaseTrackerId : config.trackerId,
								"reportId": config.queryId,
								"releaseId" : config.releaseId
							},
							success: function () {
								showOverlayMessage(i18n.message("report.selector.saved.default"));
								config["defaultViewId"] = config.queryId;
								refreshPickerContainer(containerId);
							},
							fail: function() {
								showOverlayMessage(i18n.message("report.selector.save.error"), null, true);
							}
						});
						return false;
					});
					$pickerContainer.find(".clearDefault").click(function(e) {
						e.stopPropagation();
						$.ajax({
							url: contextPath + "/reportselector/removeDefaultReport.spr",
							method: "GET",
							dataType: "json",
							data: {
								"trackerId": config.releaseTrackerId ? config.releaseTrackerId :config.trackerId
							},
							success: function () {
								showOverlayMessage(i18n.message("report.selector.cleared.default"));
								config["defaultViewId"] = null;
								refreshPickerContainer(containerId);
							},
							fail: function() {
								showOverlayMessage(i18n.message("report.selector.save.error"), null, true);
							}
						});
						return false;
					});

					// Intelligent Table View
					if (config.trackerId && !config.isDocumentView && !config.isDocumentExtendedView) {
						$pickerContainer.find(".reportPickerIntelligentTableView a").click(function() {

							var validationMessages = [];
							if (config.container.find(".groupArea").find(".droppableField").length > 0) {
								validationMessages.push(i18n.message("intelligent.table.view.group.by.warning"));
							}
							if (config.container.find(".reportPickerContainer").find(".resizeableColumns input").is(":checked")) {
								validationMessages.push(i18n.message("intelligent.table.view.resizable.warning"));
							}
							if (validationMessages.length > 0) {
								showFancyAlertDialog(validationMessages.join("<br>"));
								return false;
							}

							var url = contextPath + '/intelligentTableView/showConfiguration.spr?trackerId=' + config.trackerId;
							if (config.hasOwnProperty("queryId") && config.queryId !== null && typeof config.queryId !== "undefined") {
								url += "&reportId=" + config.queryId;
							}
							var fieldList = getFieldsFromTable(containerId);
							if (fieldList && fieldList.length > 0) {
								url += "&fields=" + encodeURIComponent(JSON.stringify(fieldList));
							}
							showPopupInline(url, { geometry: 'large'});
							return false;
						});
					}

					$pickerContainer.data("initialized", true);
				}
			}
		});

		$("html").click(function(e) {
			if ($(e.target).is(".collapsingBorder") || $(e.target).closest(".collapsingBorder").length > 0) {
				return false;
			}
			$(".reportPickerContainer").each(function() {
				if ($(this).is(":visible")) {
					$(this).hide();
				}
			});
		});
	};

	var setRelease = function(containerId, releaseId, releaseTrackerId, recursive) {
		configByInstance[containerId]["releaseId"] = releaseId;
		configByInstance[containerId]["releaseTrackerId"] = releaseTrackerId;
		configByInstance[containerId]["recursiveRelease"] = recursive;
	};

	var setReleaseId = function(containerId, releaseId) {
		setRelease(containerId, releaseId, null);
	};

	var getReleaseId = function(containerId, releaseId) {
		return configByInstance[containerId]["releaseId"];
	};

	var setReleaseTrackerId = function(containerId, releaseTrackerId) {
		setRelease(containerId, null, releaseTrackerId);
	};

	var getRecursiveRelease = function(containerId) {
		if (configByInstance[containerId].hasOwnProperty("recursiveRelease")) {
			return configByInstance[containerId]["recursiveRelease"];
		} else {
			return false;
		}
	};

	var getReleaseTrackerId = function(containerId) {
		return configByInstance[containerId]["releaseTrackerId"];
	};

	var getFilterProjectIds = function(containerId) {
		return configByInstance[containerId]["filterProjectIds"];
	};

	var getFilterTrackerIds = function(containerId) {
		return configByInstance[containerId]["filterTrackerIds"];
	};

	var getInitialCbQL = function(containerId) {
		var config = configByInstance[containerId];
		if (config.hasOwnProperty("initialCbQL")) {
			return config.initialCbQL;
		}
		return null;
	};

	var clearInitialCbQL = function(containerId) {
		configByInstance[containerId]["initialCbQL"] = null;
	};

	var getInitialCbQLForTree = function(containerId) {
		var config = configByInstance[containerId];
		if (config.hasOwnProperty("initialCbQLForTree") && config.initialCbQLForTree != null) {
			return config.initialCbQLForTree;
		}

		if (config.hasOwnProperty("lastSelectedCbQl")) {
			return config.lastSelectedCbQl;
		}

		return null;
	};

	var clearInitialCbQLForTree = function(containerId) {
		configByInstance[containerId]["initialCbQLForTree"] = null;
		configByInstance[containerId]["lastSelectedCbQl"] = null;
	};

	var initReportSelectorTag = function($container, config) {
		var containerId = $container.attr("id");
		config = $.extend({}, codebeamer.ReportSupportDefaults, config);
		configByInstance[containerId] = config;

		configByInstance[containerId]["container"] = $container;
		if (config.resultContainer) {
			initReportSelectorSearchButton(containerId);
		}
		initFilterSelectors(containerId);
		initProjectAndTrackerSelector(containerId);
		var selectedItemId = null;
		if (config.isDocumentView) {
			var urlSelectedItemId = UrlUtils.getParameter("selectedItemId");
			if (urlSelectedItemId) {
				selectedItemId = urlSelectedItemId;
			}
		}
		initLogicButton(containerId);
		if (config.trackerId || config.releaseTrackerId || config.releaseId || (config.traceabilityTrackerId && config.queryString == "")) {
			var cookieData = getReportSelectorStorageData(containerId);
			if (config.queryId == -11 || (!config.isPlanner && config.queryId == -2) || config.queryId == -18 || config.queryId == config.defaultViewId) {
				if (selectedItemId == null && cookieData) {
					if (cookieData["cbQL"]) {
						config.queryString = cookieData["cbQL"];
					}
					if (cookieData["queryId"]) {
						config.queryId = cookieData["queryId"];
					}
					if (cookieData["logicString"] && cookieData["logicString"].length > 0) {
						config.logic = cookieData["logicString"];
						config.logicSlices = cookieData["logicSlicesString"] ? JSON.parse(cookieData["logicSlicesString"]) : {};
						config.container.find(".logicString").val(config.logic);
						config.container.find(".logicButton").click();
					}
					if (cookieData.hasOwnProperty("filterAttributes")) {
						config.filterAttributes = cookieData["filterAttributes"];
					}
					if (cookieData.hasOwnProperty("resizeableColumns") && cookieData["resizeableColumns"]) {
						$("#resizeableColumns").prop("checked", true);
					}
				}
			}
			if (selectedItemId) {
				config.queryString = "tracker.id IN (" + config.trackerId +")";
				config.queryId = -2;
			}
		}
		if (config.traceabilityTrackerId && config.queryString == "") {
			config.queryString = "tracker.id IN (" + config.traceabilityTrackerId + ")";
		}
		configByInstance[containerId]["logicEnabled"] = config.logic && config.logic.length > 0;
		initContainer(containerId, config.queryId, config.queryString, true, true, config.filterAttributes);
		getFields(containerId);
		initAddButton(containerId);

		if (config.resultContainer) {
			initReportPicker(containerId);
			if (config.trackerId || config.releaseTrackerId || config.releaseId) {
				loadExistingReports(containerId);
			}
		}

		if (!config.mergeToActionBar && config.contextualSearch) {
			initContextualSearch(containerId);
		}

		if (config.mergeToActionBar) {
			initActionBar(containerId);
		}

		config.container.css("display", config.mergeToActionBar ? "inline-block" : "block");

		if (config.sticky) {
			setSticky(containerId);
		}

		// Note: Release filter part of the cbQL will be added in CardboardController, so if we are in Release context and
		// the cbQL is empty, we add a placeholder filter which is always true
		if ((config.releaseId || config.isPlanner) && (!config.queryString || config.queryString == "")) {
			config.queryString = "item.id NOT IN (0)";
		}
		if (config.triggerResultAfterInit && (config.releaseTrackerId || (config.queryString && config.queryString != ""))) {
			var cbQL = config.queryString;
			config["initialCbQL"] = cbQL;
			config["initialCbQLForTree"] = cbQL;
			if ($("#currentVersion").length > 0) {
				config["recursiveRelease"] = true;
			}
			if (config.isPlanner) {
				if (codebeamer.plannerConfig.openProductBacklog) {
					$(".left-pane .version-list .project-backlog").addClass("selected");
					setRelease(containerId, "-1", $("#currentTracker").attr("data-id"), false);
					codebeamer.planner.updateUrl("-1");
				}
				getReportSelectorResult(containerId, cbQL, null, null, null, true, null, function(result) {
					config.resultContainer.html(result);
					codebeamer.planner.addClosedGroupHeaders();
				});
			} else {
				getReportSelectorResult(containerId, cbQL, null, null, null, true);
			}
		}

	};

	var initReportWidget = function($container, config) {
		var containerId = $container.attr("id");
		config = $.extend({}, codebeamer.ReportSupportDefaults, config);
		configByInstance[containerId] = config;

		configByInstance[containerId]["container"] = $container;
		configByInstance[containerId].queryHeaderTop = $container.siblings('.headerTop');
		if (!config.viewMode) {
			hideAjaxLoading(containerId);
			configByInstance[containerId]["currentQueryString"] = config.queryString;
			initReportPageSearchButton(containerId);
			initAdvanced(containerId);
			initFilterSelectors(containerId);
			initProjectAndTrackerSelector(containerId);
			configByInstance[containerId]["logicEnabled"] = config.logic && config.logic.length > 0;
			initContainer(containerId, config.queryId, config.queryString, !config.advanced, true);
			getFields(containerId);
			initAddButton(containerId);
			initLogicButton(containerId);
			initNavigateAwayProtection(containerId);
		} else {
			initAdvanced(containerId);
		}

	};

	var applyContextMenuUserPreference = function(containerId) {
		var config = configByInstance[containerId];
		if (!config.isPlanner && codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
			config.resultContainer.find('.tracker-context-menu img.menuArrowDown').addClass('always-display-context-menu');
		}
	};

	// config and other variables stored by instance identified by HTML DOM Element ID
	// e.g. config["container1"]
	var configByInstance = {};

	return {
		"initReportWidget" : initReportWidget,
		"initReportSelectorTag" : initReportSelectorTag,
		"defaultReportTagSelectorResultCallback": defaultReportTagSelectorResultCallback,
		"addOrderByOrGroupBy" : addOrderByOrGroupByBadge,
		"getProjectIds": getProjectIds,
		"getTrackerIds": getTrackerIds,
		"renderField": renderField,
		"logicEnabled" : isLogicEnabled,
		"getLogicString" : getLogicString,
		"isLogicInvalid" : isLogicInvalid,
		"buildQueryStructure" : buildQueryStructure,
		"getCbQl" : getCbQl,
		"getFieldFormat" : getFieldFormat,
		"getAggregateFunctions" : getAggregateFunctions,
		"setAggregateFunctions" : setAggregateFunctions,
		"toggleOrderByAggregateFunctions" : toggleOrderByAggregateFunctions,
		"initAdvancedEditorWithQueryString" : initAdvancedEditorWithQueryString,
		"getParamFromUrl" : getParamFromUrl,
		"initHeaderContextMenu" : initHeaderContextMenu,
		"initDrag" : initDrag,
		"setDragHelper" : setDragHelper,
		"resetDroppables" : resetDroppables,
		"getDroppableAreas" : getDroppableAreas,
		"isDroppableAcceptsElement" : isDroppableAcceptsElement,
		"insertColumn" : insertColumn,
		"getFieldsFromTable" : getFieldsFromTable,
		"initResizeableColumns" : initResizeableColumns,
		"isResizeableColumnsEnabled" : isResizeableColumnsEnabled,
		"getColumnPercentages" : getColumnPercentages,
		"findColumnIndexInTable" : findColumnIndexInTable,
		"getTrackerLabelKey" : getTrackerLabelKey,
		"afterSavedPropertiesCallback" : afterSavedPropertiesCallback,
		"getAdvancedEditor" : getAdvancedEditor,
		"saveReport" : saveReport,
		"getSpecialFilterValues": getSpecialFilterValues,
		"hideUnsavedWarning" : hideUnsavedWarning,
		"getInitialCbQL" : getInitialCbQL,
		"clearInitialCbQL" : clearInitialCbQL,
		"getInitialCbQLForTree" : getInitialCbQLForTree,
		"clearInitialCbQLForTree" : clearInitialCbQLForTree,
		"getReportId": getReportId,
		"getReportSelectorStorageData": getReportSelectorStorageData,
		"setReportSelectorStorage": setReportSelectorStorage,
		"setReleaseId" : setReleaseId,
		"getReleaseId" : getReleaseId,
		"setRelease" : setRelease,
		"setReleaseTrackerId" : setReleaseTrackerId,
		"getReleaseTrackerId" : getReleaseTrackerId,
		"getRecursiveRelease" : getRecursiveRelease,
		"getReportSelectorResult" : getReportSelectorResult,
		"getAdvancedQueryString" : getAdvancedQueryString,
		"getFilterProjectIds" : getFilterProjectIds,
		"getFilterTrackerIds" : getFilterTrackerIds,
		"clearCurrentProject" : clearCurrentProject,
		"createSelector" : createSelector,
		"applyContextMenuUserPreference" : applyContextMenuUserPreference,
		"hideOtherMenus" : hideOtherMenus,
		"isSprintHistory" : isSprintHistory,
		"intelligentTableViewIsEnabled" : intelligentTableViewIsEnabled,
		"getIntelligentTableViewConfiguration" : getIntelligentTableViewConfiguration
	};

})(jQuery);

codebeamer.ReportSupportDefaults = codebeamer.ReportSupportDefaults || {
	"container" : null,
	"reportPage" : false,
	"viewMode" : false,
	"queryId" : null,
	"queryString" : null,
	"filterAttributes" : null,
	"advanced" : false,
	"initData" : {},
	"advancedMode" : false,
	"advancedEditor" : null,
	"nextReferenceSelectorId" : 0,
	"currentQueryString" : null,
	"fieldResult" : {},
	"logicEnabled" : false,
	"logic" : null,
	"logicSlices" : null,
	"filterCounter" : 1,
	"resultContainer" : null,
	"resultRenderUrl" : null,
	"resultJsCallback" : null,
	"projectId" : null,
	"trackerId" : null,
	"releaseId" : null,
	"defaultViewId" : null,
	"showOrderBy" : true,
	"showGroupBy" : true,
	"maxGroupByElements" : 3,
	"maxOrderByElements" : 3,
	"triggerResultAfterInit" : false,
	"triggerResultAfterSelectGroupBy" : false,
	"triggerResultAfterSelectOrderBy" : false,
	"isDocumentView" : false,
	"isDocumentExtendedView": false,
	"isBranchMode" : false,
	"contextualSearch" : false,
	"canUserAdminPublicReport" : false,
	"sticky" : false,
	"mergeToActionBar" : false,
	"filterProjectIds" : null,
	"filterTrackerIds" : null,
	"traceabilityTrackerId" : null,
	"showResizeableColumns" : false,
	"intelligentTableView" : false
};
