(function($) {

	itemHistoryAlignTable ={
		init: function() {

			var initHeader = function() {
				itemHistoryAlignTable.getFieldChangesTh().each(function() {
					var table = $('<table class="itemChangesTable"></table>');
					var row = $('<tr></tr>');
					row.append($('<td class="textData field">' + i18n.message('issue.history.fieldChanges.label') + '</td>'));
					row.append($('<td class="textDataWrap newValue">' + i18n.message('issue.history.newValue.label') + '</td>'));
					row.append($('<td class="textDataWrap oldValue">' + i18n.message('issue.history.oldValue.label') + '</td>'));
					table.append(row);
					$(this).append(table);
				});
			};

			var setInsideBorders = function() {
				itemHistoryAlignTable.getItemChangesTables().each(function() {
					$(this).find('td.field, td.newValue, td.oldValue').each(function() {
						$(this).css('padding-top', '6px');
						$(this).css('padding-bottom', '6px');
						$(this).css('border-bottom', 'solid 1px #f5f5f5');
					});
					$(this).find('td.field:first, td.newValue:first, td.oldValue:first, tr.empty td').each(function() {
						$(this).css('padding-top', '0');
					});
					$(this).find('td.field:last, td.newValue:last, td.oldValue:last').each(function() {
						$(this).css('border-bottom', 'none');
					});
				});
			}

			$(document).ready(function() {

				initHeader();
				setInsideBorders();

				itemHistoryAlignTable.setWidths();
				$(window).resize(function() {
					itemHistoryAlignTable.setWidths();
				});

				$('body').on('cbUpdateHistoryItemBorders', setInsideBorders);
			});

			// Set widths after images are loaded
			$(window).load(function() {
				itemHistoryAlignTable.setWidths();
			});
		},

		getContainer: function() {
			return $('#task-details-history');
		},

		getItemChangesTables: function() {
			return itemHistoryAlignTable.getContainer().find('.itemChangesTable');
		},

		getFieldChangesTh : function() {
			return itemHistoryAlignTable.getContainer().find('#changeSet th.fieldChanges');
		},

		setWidths: function() {

			// Get column widths
			var fieldWidths = [];
			var newWidths = [];
			var oldWidth = [];
			var itemChangesTables = itemHistoryAlignTable.getItemChangesTables();
			itemChangesTables.find('td.field').each(function() {
				fieldWidths.push($(this).width());
			});
			itemChangesTables.find('td.newValue').each(function() {
				newWidths.push($(this).width());
			});
			itemChangesTables.find('td.oldValue').each(function() {
				oldWidth.push($(this).width());
			});

			// Get the maximum widths of each column
			var maxFieldWidth = Math.max.apply(Math, fieldWidths);
			var maxNewWidth = Math.max.apply(Math, newWidths);
			var maxOldWidth = Math.max.apply(Math, oldWidth);

			// Set width to the maximum
			var setTdWidth = function(td, width) {
				var existingHelper = td.find('div.helper');
				if (existingHelper.length == 0) {
					var helperDiv = $('<div class="helper" style="display: block; height: 1px"></div>');
					td.append(helperDiv);
					helperDiv.width(width);
				} else {
					existingHelper.width(width);
				}

			}

			itemChangesTables.find('td.field').each(function() {
				setTdWidth($(this), maxFieldWidth);
			});
			itemChangesTables.find('td.newValue').each(function() {
				setTdWidth($(this), maxNewWidth);
			});
			itemChangesTables.find('td.oldValue').each(function() {
				setTdWidth($(this), maxOldWidth);
			});

			itemHistoryAlignTable.getFieldChangesTh().each(function() {
				$(this).find('td.field').each(function() {
					setTdWidth($(this), maxFieldWidth - 1);
				});
				$(this).find('td.newValue').each(function() {
					setTdWidth($(this), maxNewWidth - 1);
				});
				$(this).find('td.oldValue').each(function() {
					setTdWidth($(this), maxOldWidth - 1);
				});
			});
		}
	};

}(jQuery));
