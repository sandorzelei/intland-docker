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
codebeamer.item.history = codebeamer.item.history || {};
codebeamer.item.history.table = codebeamer.item.history.table || (function($) {

	function init(historyEntryVersionReferences) {
		if (historyEntryVersionReferences) {
			$("a[data-version]").each(function(index, element) {
				var version, $row, $element, $indicator, index, historyEntryVersionReference, text, $revertButton;

				$element = $(element);
				version = $element.data("version");
				if (historyEntryVersionReferences.hasOwnProperty(version) && historyEntryVersionReferences[version]) {
					historyEntryVersionReference = historyEntryVersionReferences[version];
					for (index in historyEntryVersionReferences[version]) {
						if (historyEntryVersionReference.hasOwnProperty(index)) {
							$row = $element.closest("tr");
							text = historyEntryVersionReference[index].baselineId ? i18n.message("issue.history.baseline.text") : i18n.message("issue.history.branch.text");
							$indicator = $("<tr class='version-indicator'><td></td><td class='textData columnSeparator' colspan='6'>"
									+ "<div class='version-indicator-content'>"
									+ "<div class='user-photo'><a href='" + contextPath + historyEntryVersionReference[index].ownerUrl + "'>"
									+ "<img class='smallPhoto photoBox' src='" + contextPath + historyEntryVersionReference[index].photoUrl + "' title='" + historyEntryVersionReference[index].ownerName + "'></a></div>"
									+ "<div class='entry-info'><a href='" + contextPath + historyEntryVersionReference[index].ownerUrl + "'>" + historyEntryVersionReference[index].ownerName + "</a><div>"
									+ historyEntryVersionReference[index].date + "</div></div>"
									+ "<div class='version-label-wrapper'><img class='info-image' src='" + contextPath + "/images/newskin/message/info-stripes.png'/>"
									+ "<a target='" + codebeamer.userPreferences.newWindowTarget + "' href='" + contextPath + historyEntryVersionReference[index].url + "'>" + historyEntryVersionReference[index].name + "</a>"
									+ " "
									+ text
									+ "</div></div>"
									+ "</td></tr>");
							$row.before($indicator);
							$revertButton = $(".action.revert[data-version=" + version + "]").first().clone();
							$indicator.find(".version-label-wrapper").append($revertButton);
						}
					}
				}
			});
		}

		$(".action.revert").click(function() {
			var $element, version, headVersion, itemId, targetItemId;

			$element = $(this);

			version = $element.data("version");
			headVersion = $element.data("head-version");
			itemId = $element.data("item-id");
			isEditable = $element.data("editable");
			targetItemId = $element.data("target-item-id");

			inlinePopup.show(contextPath + "/issuediff/editable/diffVersion.spr?issue_id=" + itemId + "&revision=" + version +
					"&newVersion=" + headVersion + "&editable=" + isEditable + "&targetItemId=" + targetItemId, {
				geometry: "large"
			});
		});

		$("input[name=selectedVersion]").click(function() {
			var numberOfCheckedInputs = $("input[name=selectedVersion]:checked").size();

			if (numberOfCheckedInputs == 2) {
				$("input[name=selectedVersion]").not(":checked").attr("disabled", "disabled");
			} else {
				$("input[name=selectedVersion]").not(":checked").removeAttr("disabled");
			}
		});
	}

	return {
		"init": init
	};
}(jQuery));
