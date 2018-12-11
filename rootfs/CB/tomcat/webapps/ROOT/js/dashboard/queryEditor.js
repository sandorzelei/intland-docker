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
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.queryEditor = codebeamer.dashboard.queryEditor || (function($) {

	var queryIdStore, fieldType = [];

	function transformResult(result, array) {
		var i;
		for (i = 0; i < result.length; i++) {
			if (result[i].children != null && result[i].children.length > 0) {
				var children = [];
				fieldType.push(result[i].text);
				getLeafNodes(result[i], children);
				array.push(children);
			}
		}
	}

	function getLeafNodes(node, array) {
		if (node.children != null && node.children.length > 0) {
			var i;
			for (i = 0; i < node.children.length; ++i) {
				getLeafNodes(node.children[i], array);
			}
		} else {
			var column = [Number(node.attr["data-fieldlayoutid"]), node.attr["title"], node.attr["data-customfieldtrackerid"] === undefined ? null : Number(node.attr["data-customfieldtrackerid"])];
			array.push(column);
		}
	}

	function findObjects(obj, key, val, ids) {
		var result = false;
		for ( var i in obj) {
			if (!obj.hasOwnProperty(i))
				continue;
			if (typeof obj[i] == 'object') {
				if (findObjects(obj[i], key, val, ids)) {
					for (var j = 0; j < obj['right'].value.length; ++j) {
						ids.push(obj['right'].value[j].value);
					}
				}
			} else if (i == key && obj[key] == val) {
				result = true;
			}
		}
		return result;
	}

	function renderQueryColumns(result, $selector, queryColumnsByIdUrl, selectedValues, isGrouped, queryId, eventName) {

		$selector.empty();

		var leafNodes = new Array();

		transformResult(result, leafNodes);

		$.getJSON(queryColumnsByIdUrl, {"queryId" : queryId}).success(function(queryColumns) {

			for (var i = 0; i < leafNodes.length; i++) {
				var columns = leafNodes[i];

				var $fieldGroup = $("<optgroup>", { label: fieldType[i] });

				for (var j = 0; j < columns.length; j++) {
					var column = columns[j];

					var $option = $("<option>", { value : encodeURIComponent(JSON.stringify(column)) }).text(column[1]);

					// set checked
					if (queryIdStore.isInitialQuerySelected() && selectedValues.length > 0) {
						var selectedIndex;
						for (selectedIndex = 0; selectedIndex < selectedValues.length; ++selectedIndex) {
							if (selectedValues[selectedIndex][0] === column[0]) {
								if (!codebeamer.dashboard.shared.isCustomField(column[0])
										|| codebeamer.dashboard.shared.isSameCustomField(selectedValues[selectedIndex][2], column[2])) {
									$option.attr("selected", "selected");
								}
							}
						}
					} else {
						if (queryIdStore.isInitialQuerySelected() && selectedValues.length === 0 && isGrouped) {
							// List is intentionally empty, do not select anything
						} else {
							var selectedIndex;
							for (selectedIndex = 0; selectedIndex < queryColumns.length; ++selectedIndex) {
								if (queryColumns[selectedIndex].layoutFieldId === column[0]) {
									if (!codebeamer.dashboard.shared.isCustomField(queryColumns[selectedIndex].layoutFieldId)
											|| codebeamer.dashboard.shared.isSameCustomField(queryColumns[selectedIndex].customFieldTracker, column[2])) {
										$option.attr("selected", "selected");
									}
								}
							}
						}
					}
					$fieldGroup.append($option);
				}

				$selector.append($fieldGroup);
			}

			$("body").trigger("queryColumnsSelector:columns:loaded", [queryId, queryColumns]);
			codebeamer.dashboard.multiSelect.refreshSelection($selector.attr("id"), eventName);
		});
	};

	function getQueryChoicesJSON(projectIds, trackerIds, queryColumnsUrl, $selector, queryColumnsByIdUrl, selectedValues, isGrouped, queryId, eventName) {
		$.getJSON(queryColumnsUrl, {"project_ids" : projectIds.join(), "tracker_ids" : trackerIds.join() }).done(function(result) {
			renderQueryColumns(result, $selector, queryColumnsByIdUrl, selectedValues, isGrouped, queryId, eventName);
		});
	};

	function getQueryColumns(queryCustomColumnsUrl, queryColumnsUrl, selectorId, queryColumnsByIdUrl, selectedValues, isGrouped, queryId, eventName) {
		if (queryId) {
			if (!queryIdStore) {
				queryIdStore = codebeamer.dashboard.shared.createQueryIdStore(queryId);
			};
			queryIdStore.update(queryId);

			$.post(queryCustomColumnsUrl, {"query_id" : queryId}).success(function(result) {
				var projectIds = [];
				var trackerIds = [];

				findObjects(result, "value", "project.id", projectIds);
				findObjects(result, "value", "tracker.id", trackerIds);

				var aggrFunc = [];
				if (result.hasOwnProperty('select')) {
					$.each(result['select']['value'], function(i, val) {
						if (val.hasOwnProperty('function') && val.hasOwnProperty('extraInformation')) {
							var extraInfo = JSON.parse(val['extraInformation']);
							aggrFunc.push([extraInfo['id'], extraInfo['name'], extraInfo['trackerId'],val["function"]]);
						}
					});
				}
				codebeamer.dashboard.multiSelect.triggerEvent("query:orderByAggregate", aggrFunc);

				getQueryChoicesJSON(projectIds, trackerIds, queryColumnsUrl, $("#" + selectorId), queryColumnsByIdUrl, selectedValues, isGrouped, queryId, eventName);
			});
		}
	};

	function getQueryOrderBy(value, selectedValue, selectorId, eventName) {
		var $selector = $("#" + selectorId);
		var selectedValueArr = null;

		if (!!selectedValue) {
			selectedValueArr = $.parseJSON(decodeURIComponent(selectedValue));
		}

		$selector.empty();

		var parsedValues = [];
		$.each(value, function(index, object) {
			parsedValues.push($.parseJSON(decodeURIComponent(object)));
		});
		parsedValues.sort(function(first, second) {
			if (first === second) {
				return 0;
			} else {
				if (first[1] < second[1]) {
					return -1;
				} else {
					return 1;
				}
			}
		});

		var aggrFunc = $selector.data('aggrFunc');
		$.each(aggrFunc, function(index, object) {
			parsedValues.push(object);
		});

		for (var i = 0; i < parsedValues.length; i++) {
			var column = parsedValues[i];
			var text = column.length > 3 ? column[1] + " - " + column[3] : column[1];

			var $option = $("<option>", { value : encodeURIComponent(JSON.stringify(column)) }).text(text);
			if (queryIdStore.isInitialQuerySelected() && selectedValueArr != null) {
				if (selectedValueArr[0] == column[0] &&
					selectedValueArr[2] == column[2] &&
					selectedValueArr[3] == column[3]) {
					$option.attr("selected", "selected");
				}
			}

			$selector.append($option);
		}
		codebeamer.dashboard.multiSelect.refreshSelection(selectorId, eventName);
	};

	return {
		"getQueryColumns": getQueryColumns,
		"getQueryOrderBy": getQueryOrderBy
	};

})(jQuery);