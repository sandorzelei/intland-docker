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

// $Id$
// Javascript for highlighting table rows which contain checkboxes checked.

// static class
var tableHighlighter = {

	// find all tables, and highlight them if they have checkboxes
	init: function() {
		var oddRows = $('tr.odd');
		var evenRows =  $('tr.even');
		//alert("found rows: odd:" + oddRows.length + ", even:" + evenRows.length);

		tableHighlighter.initRows(oddRows);
		tableHighlighter.initRows(evenRows);
	},

	// init some rows, find checkboxes inside and add event listeners on them
	initRows: function(rows) {
		for (var i=0; i<rows.length; i++) {
			var row = rows[i];
			var checkboxes = tableHighlighter.findChildCheckboxes(row);

			// add event listener to update row color when checkboxes change
			for (var j=0; j<checkboxes.length; j++) {
				var callback = function(e, row) {
					tableHighlighter.updateRowHighlight(row);
				};
				// pass the row as 2nd param to callback function,so we don't need to search for it
				$(checkboxes[j]).click(function(e) {
					callback(e, row);
				});
			};

			// update row's highlighted state
			tableHighlighter.updateRowHighlight(row);
		}
	},

	// find child checkboxes for a html element
	// @param elem the element to look inside
	// @return an array containing child checkboxes
	findChildCheckboxes: function(elem) {
		var checkboxes = new Array();
		for (var i=0; i<elem.childNodes.length; i++) {
			var child = elem.childNodes[i];
			if (child.type == "checkbox") {
				checkboxes.push(child);
			} else {
				// go deeper
				var subresult = tableHighlighter.findChildCheckboxes(child);
				checkboxes = checkboxes.concat(subresult);
			}
		}
		return checkboxes;
	},

	CSS_CLASS_CHECKED_ODD : "tableRowSelected_odd",
	CSS_CLASS_CHECKED_EVEN : "tableRowSelected_even",

	// update the highlight style of the row to match with checkboxes inside
	updateRowHighlight: function(row) {
		// find all checkboxes below the row
		var checkboxes = tableHighlighter.findChildCheckboxes(row);
		// check all checkboxes if any of them checked
		var checked = false;
		for (var i=0; i<checkboxes.length && !checked; i++) {
			checked = checked || checkboxes[i].checked;
		}

		// add or remove CSS class depending on checkedness
		if (checked) {
			var isOdd = $(row).hasClass("odd");
			var newclass = isOdd ? tableHighlighter.CSS_CLASS_CHECKED_ODD : tableHighlighter.CSS_CLASS_CHECKED_EVEN;
			$(row).addClass(newclass);
		} else {
			$(row).removeClass(tableHighlighter.CSS_CLASS_CHECKED_ODD);
			$(row).removeClass(tableHighlighter.CSS_CLASS_CHECKED_EVEN);
		}
	},

	/*
		Update the row-parent of a checkbox.
		@param checkbox the checkbox changed
	 */
	updateRowOfCheckbox: function(checkbox) {
		// find parent row
		var parent = checkbox;
		do {
			parent = parent.parentNode;
		} while (parent && parent.tagName != "TR");
		// check if parent row found, update its style
		if (parent) {
			tableHighlighter.updateRowHighlight(parent);
		}
	}

};

// init table highlighter when page loaded
$(function() {
	tableHighlighter.init();
});
