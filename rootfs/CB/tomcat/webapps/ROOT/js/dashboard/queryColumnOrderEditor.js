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
codebeamer.dashboard.queryColumnOrderEditor = codebeamer.dashboard.queryColumnOrderEditor || (function($) {

	var queryIdStore, selectorId, fieldName, renderedArray = [], defaultQueryColumns;

	function createInputFieldValue(id, tracker) {
		return encodeURIComponent(JSON.stringify([String(id), tracker ? String(tracker) : tracker]));
	};

	function createElement(id, title, tracker) {
		var $cell, $input;

		$cell = $("<div>", {"class" : "cell"});
		$input = $("<input>", {
			type: "hidden",
			name: "params[" + fieldName + "]",
			value: createInputFieldValue(id, tracker)});
		$input.attr("data-id", id + "_" +  tracker);
		$cell.append($input);
		$cell.append($("<label>", {title: title}).text(title));

		return $cell;
	}

	function processValues(values, callback) {
		$.each(values, function(index, value) {
			var $cell;

			$cell = createElement(value[0], value[1], value[2]);

			callback(value, $cell);
		});
	};

	function renderColumnAsDraggableList(values) {
		var $field, $row, cellsMap, cellsArray, initialOrder, key;

		cellsMap = {};

		if (values && $.isArray(values)) {
			$row = $("#query-column-order-" + selectorId + " .row");
			$row.empty();
			$field = $("#query-column-order-" + selectorId);
			if (decodeURIComponent($field.data("order"))) {
				initialOrder = JSON.parse(decodeURIComponent($field.data("order")));
			} else {
				initialOrder = [];
			}

			// Create div and hidden input elements
			processValues(values, function(value, $cell) {
				cellsMap[value[0] + "_" + value[2]] = $cell;
				renderedArray.push({
					fieldId: value[0],
					trackerId: value[2]
				});
			});

			/*
			 * Apply stored order if:
			 * - There is a valid stored order.
			 * - Query identifier is the same as the one, which triggered rendering first. (saved query id)
			 */
			if (queryIdStore.isInitialQuerySelected() && initialOrder && $.isArray(initialOrder) && initialOrder.length > 0) {
				// Apply saved order
				$.each(initialOrder, function(index, value) {
					key = value[0] + "_" + value[1];
					$row.append(cellsMap[key]);
					delete cellsMap[key];
				});
			} else {
				// Apply default order otherwise
				$.each(defaultQueryColumnOrder, function(index, value) {
					key = value.fieldId + "_" + value.trackerId;
					$row.append(cellsMap[key]);
					delete cellsMap[key];
				});
			}

			// If there are remaining columns, then add them after the ordered list
			$.map(cellsMap, function(value, key) {
				$row.append(value);
			});

			// Set up dnd
			$row.sortable({
				items: "> div.cell",
				axis: "x",
				cursor: "move",
				delay: 150,
				distance: 5
			});
		}
	};

	function updateColumns(values) {
		var $row, currentlySelectedColumns, newRenderedArray, $element, value;

		function arrayContains(array, value) {
			var result = false;

			$.each(array, function(index, object) {
				if (object && object.fieldId === value.fieldId && object.trackerId === value.trackerId) {
					result = true;
				}
			});

			return result;
		};

		$row = $("#query-column-order-" + selectorId + " .row");
		currentlySelectedColumns = [];
		newRenderedArray = [];

		// Add new columns
		$.each(values, function(index, value) {
			// If the value is not rendered, then add it to the column list
			actualValue = {
				fieldId: value[0],
				trackerId: value[2]
			};
			if (!arrayContains(renderedArray, actualValue)) {
				var $cell;

				$cell = createElement(value[0], value[1], value[2]);
				$row.append($cell);
				renderedArray.push(actualValue);
			}

			currentlySelectedColumns.push(actualValue);

		});

		// Check that any column was removed
		$.each(renderedArray, function(index, value) {
			if (!arrayContains(currentlySelectedColumns, value)) {
				$element = $row.find("input[data-id=" + value.fieldId + "_" +  value.trackerId + "]").closest(".cell");
				$element.remove();
			} else {
				newRenderedArray.push(value);
			}
		});

		renderedArray = newRenderedArray;
		$row.sortable("refresh");
	};

	function onColumnsChanged(values) {
		var columns = [];

		$.each(values, function(index, value) {
			var column = JSON.parse(decodeURIComponent(value));
			columns.push(column);
		});

		if ($("#query-column-order-" + selectorId + " .row").is(":empty")) {
			renderColumnAsDraggableList(columns);
		} else {
			updateColumns(columns);
		}
	};

	function init(id, field) {
		selectorId = id;
		fieldName = field;
	};

	function onColumsLoaded(value, defaultQueryColumns) {
		if (!queryIdStore) {
			queryIdStore = codebeamer.dashboard.shared.createQueryIdStore(value);
		};
		queryIdStore.update(value);

		// Rebuild column list on query change
		$("#query-column-order-" + selectorId + " .row").empty();
		renderedArray = [];
		defaultQueryColumnOrder = $.map(defaultQueryColumns, function(value, key) {
			return {
				fieldId: value.layoutFieldId,
				trackerId: codebeamer.dashboard.shared.isCustomField(value.layoutFieldId) ? value.customFieldTracker : null
			};
		});
	};

	function clear(selectorId) {
		$row = $("#query-column-order-" + selectorId + " .row");
		$row.empty();
	}

	return {
		"init": init,
		"onColumnsChanged": onColumnsChanged,
		"onColumsLoaded": onColumsLoaded,
		"clear": clear
	};
})(jQuery);