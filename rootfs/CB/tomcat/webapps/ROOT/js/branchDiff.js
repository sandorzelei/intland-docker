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
	var submit = function () {
		parameters = collectParameters();
		if (validateParameters(parameters)) {
			var busyPage = ajaxBusyIndicator.showBusyPage();
			$.ajax({
				url: contextPath + '/branching/merge.spr',
				data: JSON.stringify(parameters),
				contentType: 'application/json',
				method: 'POST',
				dataType: 'json'
			}).done(function (data) {
				showOverlayMessage(i18n.message('tracker.branching.merge.successful.message'));

				redirectToBranch(true, data.url);
			}).error(function (err) {
				console.log("error", err);
				showOverlayMessage(i18n.message(err.responseText), 5, true);
			}).always(function () {
				busyPage.remove();
			});
		} else {
			showOverlayMessage(i18n.message("tracker.branching.merge.missing.selection.message"), 5, true);
		}

	};

	var validateParameters = function (parameters) {
		var copyCount = parameters.copyToTarget.length;
		var deleteCount = parameters.deleteOnTarget.length;
		var markedCount = parameters.markAsMerged.length;
		var downstreamCount = Object.keys(parameters.downstreamReferencesToUpdate).length;
		var updatedCount = Object.keys(parameters.updatedFields).length;

		if (copyCount + deleteCount + markedCount + updatedCount + downstreamCount == 0) {
			return false;
		}

		return true;
	};

	var collectParameters = function () {
		var branchId = $("[name=branchId]").val();
		var mergeRequestId = $("[name=mergeRequestId]").val();
		var targetBranchId = $("[name=targetBranchId]").val();
		var mergeFromMaster = $("[name=mergeFromMaster]").val();
		var comment = $("[name=comment]").val();

		var updatedFields = {};
		var copyToMaster = [];
		var deleteOnMaster = [];
		var markAsMerged = [];

		// the incoming references of the branch item that are selected to be updated
		var downstreamReferencesToUpdate = {};

		// for each item box
		$('.item-box').each(function () {
			var $box = $(this);

			var fieldIds = [];
			// find all checked apply boxes
			var $checkboxes = $box.find(".applyCheckbox.checked input");
			$checkboxes.each(function () {
				var $checkbox = $(this);
				var fieldId = $checkbox.data('fieldId');
				if (fieldId) {

					if ($checkbox.parent().is('.tableField')) {
						// when this is a table field then the fieldId is a comma separated list of ids
						fieldIds = fieldIds.concat(fieldId.split(','));
					} else {
						fieldIds.push(fieldId);
					}
				}
			});

			var $copyToMaster = $box.find("[name=copyToTarget]");
			if ($copyToMaster.is(":checked")) {
				copyToMaster.push($copyToMaster.val());
			}

			var $deleteOnMaster = $box.find("[name=deleteOnTarget]");
			if ($deleteOnMaster.is(":checked")) {
				deleteOnMaster.push($deleteOnMaster.val());
			}

			var $markAsMerged = $box.find("[name=markAsMerged]");
			if ($markAsMerged.is(":checked")) {
				markAsMerged.push($markAsMerged.val());
			}

			if (fieldIds.length) {
				updatedFields[$box.data('id') + ""] = fieldIds;
			}
		});

		// find the selected downstream references to update
		$('.updated-downstream-references').each(function () {
			var $box = $(this);

			var referredId = $box.data('itemId');

			var checked = $box.find('input:checked:not(:disabled)');
			if (checked.size()) {
				downstreamReferencesToUpdate[referredId] = checked.map(function() { return this.value; }).toArray();
			}
		});

		return {
			'branchId': branchId,
			'mergeRequestId': mergeRequestId,
			'updatedFields': updatedFields,
			'copyToTarget': copyToMaster,
			'deleteOnTarget': deleteOnMaster,
			'mergeFromMaster': mergeFromMaster,
			'markAsMerged': markAsMerged,
			'targetBranchId': targetBranchId,
			'downstreamReferencesToUpdate': downstreamReferencesToUpdate,
			'comment': comment
		};
	};

	$('.merge-action').click(submit);


	// when a copytotarget checkbox is checked we need to enable the downstream reference update checkboxes too
	$('[name=copyToTarget]').change(function () {
		var $checkbox = $(this);

		var $downstreamCheckboxes = $checkbox.closest('.item-box').find('.updated-downstream-references input[type=checkbox].editable');

		$downstreamCheckboxes.prop('disabled', !$checkbox.is(':checked'))
	});
});

var redirectToBranch = function (refresh, url) {
	var isPopup = $("body").is(".popupBody");
	var mergeRequestId = $("[name=mergeRequestId]").val();

	if (!mergeRequestId && isPopup) {
		var toReload = $("#issuePropertiesPane", parent.document).data("showingIssue");
		if (parent['trackerObject']) {
			parent.trackerObject.reloadIssue(toReload);
		}
		closePopupInline();
	} else {
		if (isPopup) {
			parent.location.href = contextPath + url;
		} else {
			location.href = contextPath + url;
		}
	}
};