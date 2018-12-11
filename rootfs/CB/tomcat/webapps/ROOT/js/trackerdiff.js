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
 */

jQuery(function($) {
	var table = $(".diffTable");
	var all = table.find(".applyCheckbox[name=all]");

	function tableRowFilter() {
		return !$(this).hasClass("table-field-row");
	}

	function initializeEventandlers() {
		if (table.data("initialized")) {
			return;
		}

		$(".applyCheckbox.all").click(function() {
			var selectedTable = $(this).closest('.diffTable');
			var cb = $(this);
			var others = selectedTable.find(".applyCheckbox").not(cb);
			if (cb.hasClass("checked")) {
				others.trigger("check");
			} else {
				others.trigger("uncheck");
			}
		});

		$(".showDifferentFieldsOnly").click(function() {
			var selectedTable = $(this).closest('.contentWithMargins').find('.diffTable');
			var checked = $(this).is(":checked");
			selectedTable.find("tbody tr:not(.different)").filter(tableRowFilter).toggle(!checked);
			selectedTable.toggleClass("highlightDifferent", !checked);
			zebraTable(selectedTable);
		});

		table.find(".applyCheckbox").not(all).click(function() {
			var cb = $(this);
			var row = cb.closest("tr");
			var copy = row.find(".copy.value");
			var original = row.find(".original.value");
			var copyContents = copy.html();
			var originalContents = original.html();
			row.toggleClass("highlighted");
			if (cb.is(".checked")) {
				copy.prop("initial", copyContents);
				copy.html(originalContents);
			} else {
				copy.html(copy.prop("initial"));
			}
		});

		$(".actionBar input[name=submit]").click(function() {
			var data = [];
			var button = $(this);
			table.find("tbody .applyCheckbox input[type=checkbox]").each(function(index, e) {
				var id = $(e).attr("data-field-id");
				var checked = $(e).is(":checked");
				if (checked) {
					data.push(id);
				}
			});
			if (data.length > 0) {
				button.attr("disabled", "disabled");
				var form = $("#diffDataForm");
				form.find("[name=trackerFieldIds]").val(data.join(","));
				$.ajax({
					type: "POST",
					url: form.attr('action'),
					data: form.serialize(),
					success: function() {
						window.top.location.reload(true);
					},
					error: function(e) {
						showFancyAlertDialog(i18n.message('tracker.configuration.history.plugin.revert.error'));
						button.removeAttr("disabled");
					}
				});
			} else {
				showFancyAlertDialog(i18n.message('tracker.configuration.history.plugin.revert.no.field'));
			}
			return false;
		});

		$(".actionBar input[name=cancel]").click(function() {
			inlinePopup.close();
			return false;
		});

		table.data("initialized", true);
	};

	var zebraTable = function (selectedTable) {
		selectedTable = selectedTable || table;
		selectedTable.find("tbody tr:visible").filter(tableRowFilter).each(function(idx) {
			var odd = (idx % 2 == 0);
			$(this).toggleClass("odd", odd).toggleClass("even", !odd);
		});
	};

	initializeEventandlers();

	setTimeout(function() {
		zebraTable();
	}, 10);

});
