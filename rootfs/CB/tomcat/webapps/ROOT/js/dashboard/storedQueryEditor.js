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
codebeamer.dashboard.storedQueryEditor = codebeamer.dashboard.storedQueryEditor || (function($) {

	function decodeReferenceValue(value) {
		var parts = value.split("-");
		try {
			return parseInt(parts[1], 10);
		} catch (ex) {
			try {
				return parseInt(value);
			} catch (ex2) {
				return null;
			}
		}
		return null;
	};

	function init(settings) {
		$("#storedQuery-" + settings.selectorId + " .query-autocomplete-container").referenceField(settings.storedReport && settings.storedReport.hasOwnProperty("report") ? [settings.storedReport.report]: [], {
			reportMode: true,
			multiple: false,
			callback: function() {
				var $element, value, decodedValue;

				$element = $("#storedQuery-" + settings.selectorId + " .query-autocomplete-container input[type=hidden]");
				value = $element.val();

				if (value) {
					var decodedValue = decodeReferenceValue(value);
					$.get(contextPath + "/ajax/select/getQueryInfo.spr", {queryId: decodedValue})
						.done(function(data) {
							if (!jQuery.isEmptyObject(data)) {
								if (!settings.isRestrictedToGroupedQueries || (settings.isRestrictedToGroupedQueries && data.groupCount > 0)) {
									codebeamer.dashboard.multiSelect.triggerEvent("querySelector:query:before:change", data);
									$("#combinedValue").val(decodedValue);
									$("#combinedValue").data("name", data.name);
									$("#combinedValue").data("group-count", data.groupCount);
									$("#combinedValue").data("grouped-by-date", data.groupedByDate);
									codebeamer.dashboard.multiSelect.triggerEvent("querySelector:query:changed", data);
								} else {
									showOverlayMessage(settings.acceptedTypesMessages + ". " + i18n.message("widget.editor.type.warning"), 5, false, true);
									clear(settings.selectorId);
								}
							} else {
								showOverlayMessage(i18n.message("widget.editor.permission.warning"), 5, false, true);
								clear(settings.selectorId);
							}
						})
						.fail(function() {
							showOverlayMessage(i18n.message("widget.editor.general.warning"), 5, false, true);
							clear(settings.selectorId);
						});

				} else {
					clear(settings.selectorId);
				}

			}
		});

		$("#storedQuery-" + settings.selectorId + " .query-autocomplete-container").referenceFieldAutoComplete();

	}

	function clear(selectorId) {
		$("#storedQuery-" +  selectorId + " .query-autocomplete-container .token-input-delete-token-facebook").click();
		$("#combinedValue").val(-1);
		$("#combinedValue").data("name", "");
		$("#combinedValue").data("group-count", "");
		$("#combinedValue").data("grouped-by-date", "");
		codebeamer.dashboard.multiSelect.triggerEvent("querySelector:query:cleared");
	}

	function triggerStoredQueryEvent() {
		var $combinedValue = $("#combinedValue");

		$("body").trigger("querySelector:query:changed", {id: $("#combinedValue").val(), name: $combinedValue.data("name"), groupCount: $combinedValue.data("group-count"), groupedByDate: $combinedValue.data("grouped-by-date")});
	}

	return {
		"init": init,
		"triggerStoredQueryEvent": triggerStoredQueryEvent
	};
})(jQuery);
