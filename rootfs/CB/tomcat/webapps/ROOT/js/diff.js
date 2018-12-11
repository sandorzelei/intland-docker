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

    /**
     * moves a value between the source and the target cell
     * @param isChecked
     * @param row
     * @param targetValue
     * @param sourceValue
     */
	function moveChange(isChecked, row, targetValue, sourceValue) {
        var copyContents = targetValue.html();
        var originalContents = sourceValue.html();
        row.toggleClass("highlighted");
        if (isChecked) {
            targetValue.prop("initial", copyContents);
            targetValue.html(originalContents);
        } else {
            targetValue.html(targetValue.prop("initial"));
            showSelectedFormat.call(row.find(".copy .formatSelector")); // so the correct format will be displayed
        }
    }

	function initializeEventandlers() {
		if (table.data("initialized")) {
			return;
		}

		$(".applyCheckbox.all:not(.biDirectional)").click(function() {
			var selectedTable = $(this).closest('.diffTable');
			var cb = $(this);
			var others = selectedTable.find(".applyCheckbox").not(cb);
			if (cb.hasClass("checked")) {
				others.trigger("check");
			} else {
				others.trigger("uncheck");
			}
		});

		// handle bidirectional apply all event
		var clearFieldSelection = function (selectedTable) {
            selectedTable.find('.applyCheckbox:not(.all)').removeClass('left right checked');
		};

		$.each(['.applyToRight', '.applyToLeft'], function (index, selector) {
            $(".applyCheckbox.all " + selector).click(function (event) {
                var selectedTable = $(this).closest('.diffTable');

                clearFieldSelection(selectedTable);

                var others = selectedTable.find(".applyCheckbox:not(.all) " + selector + ":visible:not(.disabled)");
                others.trigger('click');

            });
		});

		$(document).on('click', '.applyCheckbox.biDirectional.all.checked', function() {
            var selectedTable = $(this).closest('.diffTable');

            selectedTable.find('.applyCheckbox:not(.all)').trigger('click');
		}).on('click', '.showDifferentFieldsOnly', function () {
            var selectedTable = $(this).closest('.contentWithMargins').find('.diffTable');
            var checked = $(this).is(":checked");
            selectedTable.find("> tbody > tr:not(.different)").filter(tableRowFilter).toggle(!checked);
            selectedTable.toggleClass("highlightDifferent", !checked);
            zebraTable(selectedTable);
		});

		table.find(".formatSelector").click(showSelectedFormat);

        /*
         * handle normal checkboxes, that are not bidirectional
         */
		table.find(".applyCheckbox:not(.biDirectional)").not(all).click(function () {
			var cb = $(this);

			var row = cb.closest("tr");
			var copy = row.find(".copy.value");
			var original = row.find(".original.value");

            moveChange(cb.is(".checked"), row, copy, original);
		});

        /**
         * handle bidirectional apply checkboxes
         */
        var bidirectApplyCheckboxes = table.find('.applyCheckbox.biDirectional:not(.all)');
        bidirectApplyCheckboxes.click(function (event) {
            var $target = $(event.target);
            var isChecked = false;
            var direction = $target.is('.left') ? 'left' : 'right';

            if ($target.is('.applyIcon')) {
                isChecked = true;
                direction = $target.data('direction');
            }

            var row = $target.closest("tr");
            var copy = row.find(".copy.value");
            var original = row.find(".original.value");

            if (direction == 'left') {
                moveChange(isChecked, row, copy, original);
            } else {
                moveChange(isChecked, row, original, copy);
            }
        });

        /**
         * collects the applycheckbox values selected.
         * @param selector collects the values from only those applycheckboxes that match this selector
         * @returns {Array}
         */
		var collectCopiedFieldvalues = function (selector) {
            var data = []; // the fields to be copied from the right to the left
            table.find("tbody .applyCheckbox" + selector + " input[type=checkbox]").each(function(index, e) {
                var id = $(e).attr("data-field-id");
                var checked = $(e).is(":checked");
                if (checked) {
                    data.push.apply(data, id.split(","));
                }
            });

            return data;
        };

		$(".actionBar input[name=submit]").click(function() {
			var button = $(this);
			button.attr("disabled", "disabled");
			// collect the right to left checkbox values
            var rightToLeftFields = collectCopiedFieldvalues('.left');
            var leftToRightFields = collectCopiedFieldvalues('.right');

			var form = $("#diffDataForm");
			form.find("[name=originalToCopyFieldIds]").val(rightToLeftFields.join(","));
			form.find("[name=copyToOriginalFieldIds]").val(leftToRightFields.join(","));

			var originalId = parseInt(form.find("[name=original_id]").val());
			var copyId = parseInt(form.find("[name=copy_id]").val());
			var associationId = $("#associationId").val();
			$.ajax({
				type: "POST",
				url: form.attr('action'),
				data: form.serialize(),
				success: function() {
					var allBadges = parent.$(".suspectedLinkBadge").not(".aggregated");
					allBadges.trigger("clear", { id: originalId });
					var panes = parent.$("#panes"); // use parent jQuery instance, so we can trigger events
					if (panes.length > 0) {
						panes.trigger("reload");
						parent.trackerObject.reloadIssue(copyId);

						if (associationId) {
							var $badge = panes.find(".referenceSettingBadge[data-association-id=" + associationId +"]")

							var targetItemId = $badge.attr("data-target-tracker-item-id");

							// reload the item on doc view
							if (parent.trackerObject) {
								var $target = panes.find('#issuePropertiesPane');
								if ($target.data("showingIssue")) {
									parent.trackerObject.showIssueProperties($target.data("showingIssue"), parent.trackerObject.config.id, $target,
											parent.trackerObject.config.revision == null || parent.trackerObject.config.revision == "", true);
								}
							}
						}
						inlinePopup.close();
					} else {
						window.top.location.reload(true);
					}
				},
				error: function(e) {
					showOverlayMessage(e.responseText, 5,  "error")
					button.removeAttr("disabled");
				}
			});
			return false;
		});

		$(".actionBar input[name=clearSuspect]").click(function() {
			var associationId = $("#associationId").val();
			var isReference = $("#isReference").val() == "true";
			var $body = $("body", parent.document);
			var taskId = $("#taskId").val();
			if (isReference) {
				var $clearBadge = parent.$(".referenceSettingBadgeClearSuspect[data-association-id=" + associationId + "]");
				parent.codebeamer.ReferenceSettingBadges.clearSuspect($clearBadge, associationId, function() {
					$body.trigger("codebeamer.clearSuspect", [taskId])
					inlinePopup.close();
				}, true);
				return false;
			} else {
				var associationTaskId = $("#associationTaskId").val();
				parent.codebeamer.suspectedLinkBadge.deleteSuspectedLink(associationId, associationTaskId, taskId, true, function() {
					inlinePopup.close();
				});
				return false;
			}
		});

		table.data("initialized", true);
	};

	var showSelectedFormat = function() {
		var selector = $(this);
		var isWiki = selector.val() == "wiki";
		var row = selector.closest("tr");
		row.find(".formatSelector").val(selector.val());
		row.find("td.value > .wiki").toggle(isWiki);
		row.find("td.value > .html").toggle(!isWiki);
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

    $(".actionBar input[name=cancel]").click(function() {
        inlinePopup.close();
        return false;
    });

});
