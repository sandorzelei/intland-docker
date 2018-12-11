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
codebeamer.release = codebeamer.release || (function($) {

	function massUpdateRelease(id, attr) {
		var busy;

		if (attr.container) {
			busy = ajaxBusyIndicator.showBusysign($(attr.container));
		}

		$.post(contextPath + "/trackers/ajax/massUpdateRelease.spr", {
			"currentReleaseId": attr.currentReleaseId,
			"newReleaseId": attr.newReleaseId
		}).done(function(params) {
			if (params) {
				if (params.hasOwnProperty("success") && params.success == true) {
					if (attr.successCallback) {
						callSuccessCallback(attr.successCallback, attr.currentReleaseId, attr.newReleaseId);
					}
				} else {
					if (params.hasOwnProperty("message") && params.message) {
						failureCallback(params, attr.hasOwnProperty("failureCallback") ? attr.failureCallback: null);
					} else {
						showOverlayMessage(i18n.message("planner.move.all.items.from.sprint.error"), 5, true);
					}
				}
			}
		})
		.fail(function() {
			showOverlayMessage(i18n.message("planner.move.all.items.from.sprint.error"), 5, true);
		})
		.always(function() {
			if (busy) {
				ajaxBusyIndicator.close(busy);
			}
		});
	}

	function failureCallback(result, callback) {
		var message, i, error;

		message= null;

		if (result.hasOwnProperty("message") && result.hasOwnProperty("errors")) {
			message = "<span>";
			message = message.concat(result.message);
			message = message.concat("</span>");

			if (result.errors.length > 1) {
				message = message.concat("<br/>");
				message = message.concat("<div class='error-container'>");
			} else {
				message = message.concat("&nbsp;");
			}

			for (i = 0; i < result.errors.length; i++) {
				error = result.errors[i];
				if (error.hasOwnProperty("id") &&error.hasOwnProperty("keyAndId") && error.hasOwnProperty("message")) {
					message = message.concat("<a class='error-entry' target='_blank' href='#' data-id='");
					message = message.concat(error.id);
					message = message.concat("' title='");
					message = message.concat(error.message);
					message = message.concat(" ");
					message = message.concat(i18n.message("planner.release.update.tip"));
					message = message.concat("'>");
					message = message.concat(error.keyAndId);
					message = message.concat("</a>");
				}
			};

			if (result.errors.length > 1) {
				message = message.concat("</div>");
			}

			$("body").off("click.error");
			$("body").on("click.error", ".error-entry", function(event) {
				event.preventDefault();
				event.stopPropagation();

				showPopupInline(contextPath + "/cardboard/editCard.spr" + "?task_id=" + $(this).data("id"), {
					geometry: "large"
				});

			});

			showOverlayMessage(message, 5, true);
		} else {
			showOverlayMessage(result, 5, true);
		}

		if (callback) {
			callFunction(callback, []);
		}
	}

	function callFunction(functionName, args) {
		var parts, i;

		parts = functionName.split(".");

		var func = window[parts[0]];
		for (i = 1; i < parts.length; i++) {
			func = func[parts[i]];
		}

		func.apply(null, args);
	}

	function callSuccessCallback(functionName, currentReleaseId, newReleaseId) {
		callFunction(functionName, [currentReleaseId, newReleaseId]);
	}

	return {
		"massUpdateRelease": massUpdateRelease,
		"failureCallback": failureCallback
	};
})(jQuery);