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

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['jquery'], factory);
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        module.exports = function( root, jQuery ) {
            if ( jQuery === undefined ) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if ( typeof window !== 'undefined' ) {
                    jQuery = require('jquery');
                }
                else {
                    jQuery = require('jquery')(root);
                }
            }
            return factory(jQuery);
        };
    } else {
        // Browser globals
        factory(window.jQuery);
    }
}(function ($) {
	var customButtons = ['cbReorderTableColumns', 'cbReorderTableColumnsPushColumnLeft', 'cbReorderTableColumnsPushColumnRight', 'cbReorderTableColumnsPushRowDown', 'cbReorderTableColumnsPushRowUp'];

	$.FroalaEditor.PLUGINS.cbTable = function(editor) {

		var buttonStateFunctions = {
			cbReorderTableColumnsPushColumnLeft: _canMoveColumns.bind(null, -1),
			cbReorderTableColumnsPushColumnRight: _canMoveColumns.bind(null, 1),
			cbReorderTableColumnsPushRowDown: _canMoveRows.bind(null, 1),
			cbReorderTableColumnsPushRowUp: _canMoveRows.bind(null, -1)
		};

		function _updateButtonStates() {
			var $editPopup = editor.popups.get('table.edit'),
			$table = editor.table.selectedTable();

			$editPopup.find('button.fr-btn').each(function() {
				var $button = $(this);

				if (customButtons.indexOf($button.data('cmd')) > -1) {
					var	enabled = $table.length > 0 && !hasColspans($table) && $table.find('tr:first').find('>td,>th').length > 1;

					if (enabled) {
						var buttonStateFn = buttonStateFunctions[$button.data('cmd')];

						if (buttonStateFn) {
							enabled = buttonStateFn();
						}
					}

					$button[enabled ? 'removeClass' : 'addClass']('fr-disabled');
				}
			});
		}

		function tableEditPopupShownHandler() {
			var $popup = editor.popups.get('table.edit');
			if ($popup && $popup.length && $popup.hasClass('fr-active')) {
				$popup.css('z-index', 10);
				_updateButtonStates();
			}
		}

		editor.popups.onShow('table.edit', tableEditPopupShownHandler);

		// when multiple cells are selected, and the table.edit popup is shown, the onShow event for the table.edit popup is not triggered
		// so using mouseup event as well...
		editor.$el.on('mouseup', function(e) {
			setTimeout(tableEditPopupShownHandler);
		});

		function hasColspans($editorTable) {
			var colspans = $editorTable.find('td[colspan], th[colspan]').filter(function() {
				 return $(this).attr('colspan') > 1;
			});

			return colspans.length > 0;
		}

		function _getTime() {
			return (new Date()).getTime();
		}

		// find the selected table where the cursor is in the editor or based on selected cells
		function _getTable(editor) {
			if (editor.selection == null) {
				return [];
			}

			var node = editor.selection.element(),
				$editorTable = $(node).closest('table');

			if (!$editorTable.closest('.fr-element').length) {
				return editor.table.selectedTable();
			}

			return $editorTable;
		}

		// get the immediate rows TR-s of the table without the nested tables' rows
		function _getTableRows(table) {
			return $(table).find('thead>tr:first,tbody>tr:first').siblings('tr').addBack(); // immediate tr-s only: avoid nested tables
		}

		// reorder the table's columns to some new order
		function applyOrder(editorTable, columnOrder) {
			console.log("Applying new column order:" + columnOrder);
			if (columnOrder == null) {
				return;
			}

			var $editorTable = $(editorTable);

			var startTime = _getTime();
			var oldToNewColumnMap = {}
			for (var i=0; i<columnOrder.length; i++) {
				var c = columnOrder[i];
				oldToNewColumnMap[c] = i;
			}

			// TODO: detach the table for performance ?
			// $editorTable.detach();

			try {
				// walk the original table and set the new order on each column
				var $trs = _getTableRows($editorTable); // only direct row children without nested tables
				$trs.each(function() {
					var $tr = $(this);
					var tdsInNewOrder = [];
					var $tds = $tr.find(">td,>th");
					$tds.each(function(index) {
						var newIdx = oldToNewColumnMap[index];
						tdsInNewOrder[newIdx] = this;
					});
					// remove all tds and append back in the new order
					$tds.detach();
					$tr.append(tdsInNewOrder);
				});

				var endTime = _getTime();
				console.log("Reordering of table took " + (endTime - startTime) +"ms");
			} catch (ex) {
				console.log("Error reordering the table:" + ex);
			}
		}

		function _getSelectedCells() {
			var $cells = $(editor.table.selectedCells());

			if (!$cells.length) {
				// select the cursor's cell
				$cells = $(editor.selection.get()).closest('td,th');
			}

			return $cells;
		}

		/**
		 * Check which columns are selected, and if the move of the columns is possible to the given direction ?
		 *
		 * @return The new order of columns after the move, or null if the move is not possible
		 */
		function _determineNewOrderForMoveColumns(direction, highlight) {
			// get the selected columns
			var $selectedCols = _getSelectedCells();
			if ($selectedCols.length == 0) {
				console.log("No rows/cols is seleted, skipping");
				return null;
			}

			// find the 1st row, and inside that find the index of columns
			var $tr = $selectedCols.closest("tr").first();
			var $tds = $tr.find("td,th");
			function isSelected(td) {
				var sel = $selectedCols.is(td);
				return sel;
			}

			// if the 1st column is selected then moving to left is not possible
			if (direction == -1 && isSelected($tds.first())) {
				console.log("Moving to left is not possible because the selection is on the left side");
				return null;
			}
			if (direction == +1 && isSelected($tds.last())) {
				console.log("Moving to right is not possible because the selection is on the right side");
				return null;
			}

			// compute the new column order in this array
			var newOrder = [];
			for (var i=0; i< $tds.length; i++) {
				newOrder.push(i);
			}

			// swap two elements in the array
			function swap(arr, idx1, idx2) {
				var e1 = arr[idx1];
				arr[idx1] = arr[idx2];
				arr[idx2] = e1;
			}

			if (direction == -1) {
				for (var i=0; i<$tds.length; i++) {
					var td = $tds[i];
					if (isSelected(td)) {
						swap(newOrder, i-1, i);
					}
				}
			}
			if (direction == +1) {
				for (var i=$tds.length-1; i>=0; i--) {
					var td = $tds[i];
					if (isSelected(td)) {
						swap(newOrder, i, i + 1);
					}
				}
			}

			return newOrder;
		}

		/**
		 * Check if the selected columns can be moved to the give diretion
		 * @return true if the move is possible
		 */
		function _canMoveColumns(direction) {
			var newOrder = _determineNewOrderForMoveColumns(direction);
			return newOrder != null;
		}


		var moveColsLeft = _moveColumns.bind(null, -1);
		var moveColsRight = _moveColumns.bind(null,  1);
		var moveRowsUp = _moveRows.bind(null, -1);
		var moveRowsDown = _moveRows.bind(null, 1);

		/**
		 * move selected columns to left/right
		 * @param editor The editor instance
		 * @param direction +1 to move to right or -1 to move to left
		 */
		function _moveColumns(direction) {
			var $table = _getTable(editor);
			if ($table.length == 0) {
				console.log("Table is not found");
				return false;
			}

			var newOrder = _determineNewOrderForMoveColumns(direction, true);
			if (newOrder != null) {
				console.log("Moving table columns by " + direction + ", new order is:" + newOrder);
				applyOrder($table, newOrder);
			}

			_updateButtonStates();
		}

		function _canMoveRows(direction) {
			// get the selected columns
			var $selected = _getSelectedCells();
			if ($selected.length == 0) {
				// console.log("No rows/cols is seleted, skipping");
				return false;
			}
			// check if first row is selected
			var $table = $selected.closest("table");
			var $selectedRows = $selected.closest("tr");

			var $rows = _getTableRows($table);

			function isSelected(tr) {
				var sel = $selectedRows.is(tr);
				return sel;
			}

			var firstRow = $rows.first();
			if (direction == -1 && isSelected(firstRow)) {
				console.log("Moving to up is not possible because the selection is on the top row");
				return false;
			}
			var lastRow = $rows.last();
			if (direction == +1 && isSelected(lastRow)) {
				console.log("Moving to down is not possible because the selection is on the bottom row");
				return false;
			}
			return true;
		}

		function _moveRows(direction) {
			// get the selected columns
			var $selected = _getSelectedCells();
			if ($selected.length == 0) {
				console.log("No rows/cols is seleted, skipping");
				return false;
			}

			var $selectedRows = $selected.closest("tr");

			console.log("Moving table rows by " + direction);

			if (direction == -1) {
				// move rows up
				$selectedRows.each(function() {
					var $tr = $(this);
					$tr.prev().before($tr);
				});
			}
			if (direction == +1) {
				// move rows down
				// go reverse direction
				$rev = $($selectedRows.get().reverse());
				$rev.each(function() {
					var $tr = $(this);
					$tr.next().after($tr);
				});
			}

			_updateButtonStates();
		}

		function _init() {
			var modifier = editor.helpers.isMac() ? 'Alt+Shift+' : 'Alt+';

			$.FroalaEditor.DefineIcon('cbReorderTableColumnsIcon', { NAME: 'arrows-h' });
			$.FroalaEditor.DefineIcon('cbReorderTableColumnsPushColumnLeftIcon', { NAME: 'arrow-left' });
			$.FroalaEditor.DefineIcon('cbReorderTableColumnsPushColumnRightIcon', { NAME: 'arrow-right' });
			$.FroalaEditor.DefineIcon('cbReorderTableColumnsPushRowDownIcon', { NAME: 'arrow-down' });
			$.FroalaEditor.DefineIcon('cbReorderTableColumnsPushRowUpIcon', { NAME: 'arrow-up' });

			$.FroalaEditor.RegisterCommand('cbReorderTableColumnsPushColumnLeft', {
				title: i18n.message('wysiwyg.cb.table.plugin.push.column.left.label', modifier),
				icon: 'cbReorderTableColumnsPushColumnLeftIcon',
				callback: function() {
					this.cbTable.moveColsLeft();
				}
			});

			$.FroalaEditor.RegisterCommand('cbReorderTableColumnsPushColumnRight', {
				title: i18n.message('wysiwyg.cb.table.plugin.push.column.right.label', modifier),
				icon: 'cbReorderTableColumnsPushColumnRightIcon',
				callback: function() {
					this.cbTable.moveColsRight();
				}
			});


			$.FroalaEditor.RegisterCommand('cbReorderTableColumnsPushRowDown', {
				title: i18n.message('wysiwyg.cb.table.plugin.push.row.down.label', modifier),
				icon: 'cbReorderTableColumnsPushRowDownIcon',
				callback: function() {
					this.cbTable.moveRowsDown();
				}
			});

			$.FroalaEditor.RegisterCommand('cbReorderTableColumnsPushRowUp', {
				title: i18n.message('wysiwyg.cb.table.plugin.push.row.up.label', modifier),
				icon: 'cbReorderTableColumnsPushRowUpIcon',
				callback: function() {
					this.cbTable.moveRowsUp();
				}
			});

			// TODO: shortcuts
			/*ed.addShortcut(modifier + $.ui.keyCode.LEFT, '', moveColsLeft);
			ed.addShortcut(modifier + $.ui.keyCode.RIGHT, '', moveColsRight);
			ed.addShortcut(modifier + $.ui.keyCode.UP, '', moveRowsUp);
			ed.addShortcut(modifier + $.ui.keyCode.DOWN, '', moveRowsDown);*/
		}

		return {
			_init: _init,
			applyOrder: applyOrder,
			hasColspans: hasColspans,
			moveColsLeft: moveColsLeft,
			moveColsRight: moveColsRight,
			moveRowsUp: moveRowsUp,
			moveRowsDown: moveRowsDown
		}
	}


	$.FroalaEditor.RegisterCommand('cbReorderTableColumns', {
		title: i18n.message('wysiwyg.cb.table.plugin.reorder.button.label'),
		icon: 'cbReorderTableColumnsIcon',
		callback: function() {
			var $table = this.table.selectedTable();
			if (this.cbTable.hasColspans($table)) {
				showFancyAlertDialog(i18n.message('wysiwyg.cb.table.plugin.disabled.has.colspans'));
				return;
			}

			this.cbReorderTableColumns.showModal();
			this.popups.hide('table.edit');
		}
	});
}));