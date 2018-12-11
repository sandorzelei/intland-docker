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
 *
 * $Revision$ $Date$
 */

$(function() {
    var modalId = window.frameElement.getAttribute('data-modal-id'),
		editorId = window.frameElement.getAttribute('data-editor-id'),
		editor = parent.codebeamer.WYSIWYG.getEditorInstance(editorId),
		$editorTable = editor.table.selectedTable();

    attachSaveCancelEventHandlers();
	init();

	/**
	 * Get the order of columns or null if everything is in the original order
	 */
	function getColumnOrder() {
		var columnOrder = [];
		$("#tablePlaceHolder").find("table tr:first th").each(function() {
	    	var col = $(this).data("column");
	    	if (col != null) {
	    		columnOrder.push(col);
	    	}
		});

		// check if there is any change?
		var changed = false;
		for (var i=0; i<columnOrder.length;i++) {
			if (columnOrder[i] != i) {
				changed = true;
			}
		}
		return changed ? columnOrder: null;
	}

	function getTime() {
		return (new Date()).getTime();
	}

	function saveNewOrder() {
		disableSave();

		var columnOrder = getColumnOrder();
		if (columnOrder != null) {
			console.log("Saving new order of columns " + columnOrder);
			editor.cbTable.applyOrder($editorTable, columnOrder);
		}

		editor.cbReorderTableColumns.hideModal();
	}

	function disableSave() {
		$(".saveButton").hide();
	}

	function init() {
		var startTime = getTime();
		var $clone = $editorTable.clone();
		$clone[0].style.cssText = "";

		// only keep first few rows, rest is removed for performance
		var $rows = $clone.find("tr");
		$rows.each(function(index) {
			if (index > 10) {
				$(this).remove();
			}
		});

		var removeTime = getTime()-startTime;

		// does it have a head? if not then create one because this is needed for drag-handle THEAD > TR > TH
		if ($clone.find("tr:first th").length == 0) {
			// add a thead so we can drag using that
			var cols = $clone.find("tr").first().find("td").length;
			var $thead = $("<tr></tr>");

			for(var i=0; i<cols; i++) {
				$thead.append("<th>Col #" + i +"</th>");
			}
			$clone.find("tbody").prepend($thead);
		}

		// add a data element so we know what was the original index of this column
		$clone.find("tr:first th").each(function(index) {
			$(this).data("column", index).addClass("columnDraggable");
		});

		$("#tablePlaceHolder")
			.append($clone)
			.find("table").first().dragtable({
				persistState: function(table) {
				    console.log("column order changed to:" + getColumnOrder());
				}
			});

		var initTime = getTime() - startTime;
		console.log("Init time:" + initTime);
	}

	function attachSaveCancelEventHandlers() {
		$('.actionBar .saveButton').on('click', saveNewOrder);

		$('.actionBar .cancelButton').on('click', editor.cbReorderTableColumns.hideModal);
	}
});