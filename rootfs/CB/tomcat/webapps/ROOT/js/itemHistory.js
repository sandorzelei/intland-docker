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

var codebeamer = codebeamer || {};
codebeamer.item = codebeamer.item || {};
codebeamer.item.history = codebeamer.item.history || (function($) {

	function init() {

		$(".show-all-history-link").click(function(event) {
			var itemId, $element, $container, busy;

			$element = $(this);
			itemId = $element.data("item-id");
			$container = $("#itemHistory");

			busy = ajaxBusyIndicator.showBusysign($container.parent());
			$.get(contextPath + "/itemdetails/itemHistory.spr?allhistory=true&itemId=" + itemId, function(result) {
				$container.html(result);
				ajaxBusyIndicator.close(busy);
			}).fail(function() {
				ajaxBusyIndicator.close(busy);
				showFancyAlertDialog(i18n.message("tracker.item.details.tab.warning"));
			}).always(function() {
				$('body').trigger('cbUpdateHistoryItemBorders');
			});

			event.preventDefault();
			event.stopPropagation();
		});

		$(".compare-versions-link").click(function(event) {
			var $element, targetItemId, itemId, $selectedVersions, versions, newVersion, version, tmp;

			$element = $(this);

			newVersion = $element.data("head-version");
			$selectedVersions = $("input[name=selectedVersion]:checked");

			if ($selectedVersions.size() >= 1) {
				var $firstSelected = $selectedVersions.first();

				if ($selectedVersions.size() == 1) {
					// when there is only one history checkbox selected compare it with the head version of the currently viewed item
					targetItemId = $element.data("item-id");
				} else {
					// otherwise compare the two selected items and versions
					targetItemId = $firstSelected.data("item-id");
				}

				// when the item is a branch item there are two types of history items in the list: the ones for the original item and the ones for the branched items.
				var isBranch = $firstSelected.data('is-branch');
				version = $firstSelected.val();
				itemId = $firstSelected.data("item-id");

				if ($selectedVersions.size() === 2) {
					var $secondSelected = $($selectedVersions[1]);
					var secondIsBranch = $secondSelected.data("is-branch");
					newVersion = $secondSelected.val();
					// always set the branch item as the target version in the compare because it was created later than the original item
					if (newVersion < version || isBranch && !secondIsBranch) {
						tmp = newVersion;
						newVersion = version;
						version = tmp;
						itemId = $secondSelected.data("item-id");
					}
				}

				inlinePopup.show(contextPath + "/issuediff/editable/diffVersion.spr?issue_id=" + itemId + "&revision=" + version +
						"&newVersion=" + newVersion + "&editable=false&targetItemId=" + targetItemId, {
					geometry: "large"
				});
			}

			event.preventDefault();
			event.stopPropagation();
		});

	}

	return {
		"init": init
	};
}(jQuery));