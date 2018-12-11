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
codebeamer.ReferenceSettingBadges = codebeamer.ReferenceSettingBadges || (function($) {

	var initClearSuspect = function($container) {
		$container.find(".referenceSettingBadge.active").off("click");
		$container.find(".referenceSettingBadge.active").click(function() {
			var $badge = $(this);
			var associationId = $badge.attr("data-association-id");
			var trackerItemId = $badge.attr("data-tracker-item-id");
			var targetTrackerItemId = $badge.attr("data-target-tracker-item-id");
			var associationId = $badge.attr("data-association-id");
			var revision = $badge.attr('data-revision');
			showPopupInline(contextPath + "/issuediff/diffCombined.spr?association_id=" + associationId + "&copy_id=" + trackerItemId +
					(targetTrackerItemId ? "&original_id=" + targetTrackerItemId :"") +
					(revision ? "&revision=" + revision : ""), { geometry: "large"});
		});
		$container.find(".referenceSettingBadgeClearSuspect").off("click");
		$container.find(".referenceSettingBadgeClearSuspect").click(function(e) {
			e.stopPropagation();
			var $clearBadge = $(this),
				associationId = $clearBadge.attr("data-association-id");

			showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.reference.clear.confirm"), function() {
				clearSuspect($clearBadge, associationId, null, false);
			});
		});
	};

	var clearAllSuspectBadgesForAssociation = function(associationId) {
		var $suspectClearIcons = $('.referenceSettingBadge span.referenceSettingBadgeClearSuspect').filter(function() {
			return $(this).attr('data-association-id') == associationId;
		});

		$suspectClearIcons.each(function() {
			var $clearIcon = $(this),
				$suspectBadge = $clearIcon.closest('.referenceSettingBadge'),
				$directionArrows = $suspectBadge.siblings('span.arrow');
			
			$clearIcon.remove();
			$suspectBadge.removeClass('active');
			$suspectBadge.removeClass('clearable');
			$directionArrows.removeClass('active');
			$suspectBadge.off("click");
		});
	};

	var clearSuspect = function($clearBadge, associationId, callback, triggerEvent) {
		var $suspectBadge = $clearBadge.closest('.referenceSettingBadge'),
			$directionArrows = $suspectBadge.siblings('span.arrow');
		$.ajax({
			type: "delete",
			url: contextPath + "/ajax/referenceSetting/clearSuspectedReference.spr?association_id=" + associationId,
			dataType: "html",
			success: function() {
				$clearBadge.remove();
				$suspectBadge.removeClass("active");
				$suspectBadge.removeClass("clearable");
				$directionArrows.removeClass('active');
				$suspectBadge.off("click");
				clearAllSuspectBadgesForAssociation(associationId);

				if (callback) {
					callback();
				}

				if (triggerEvent) {
					$("body").trigger("codebeamer.clearSuspect");
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				var win = window;
				var $body = $("iframe").contents().find("body");
				if ($body.size()) {
					// if there is an overlay already open then show the message box in the context of the iframe
					var doc = $body[0].ownerDocument;
					win = doc.defaultView || doc.parentWindow;
				}

				win.showFancyAlertDialog(i18n.message(jqXHR.responseText));
			}
		});
	};

	var initVersionBadgeTooltip = function($container) {
		$container.tooltip({
			show: {
				duration: 300,
				delay: 300
			},
			items: ".versionSettingBadge",
			tooltipClass: "item-ui-tooltip",
			position: {
				my: "right top",
				at: "left-5 top",
				collision: "flipfit flipfit"
			},
			content: function(callback) {
				var $this, versionId, trackerItemId, progressCursorHandlerId;

				$this = $(this);
				versionId = $this.data("version-id");
				trackerItemId = $this.data("item-id");

				if (versionId && trackerItemId) {
					// Show progress indicator after a while to show that the code is working in the background.
					progressCursorHandlerId = setTimeout(function() {
						$this.removeClass("default-cursor");
						$this.addClass("progress-cursor");
					}, 100);

					 $.get({
			 			url: contextPath + "/ajax/referenceSetting/getBaselinesForTrackerItemVersion.spr",
			 			data: {
			 				trackerItemId: trackerItemId,
			 				versionId: versionId
						},
			 			cache: false,
			 			success:  function(data) {
							if ($this.hasClass("progress-cursor")) {
								// Switch back the progress indicator if it was set.
								setTimeout(function() {
									$this.removeClass("progress-cursor");
									$this.addClass("default-cursor");
								}, 10);
							} else {
								// Cancel the timer when the ajax request was fast.
								clearTimeout(progressCursorHandlerId);
							}
							callback(data);
						}
			 		});
				}

			},
			close: function(event, ui) {
				jquery_ui_keepTooltipOpen(ui);
			}
		});
	};

	var init = function($container) {
		initClearSuspect($container);
		initVersionBadgeTooltip($container);
		codebeamer.UnresolvedDependenciesBadges.init($container);
	};

	return {
		"init": init,
		"clearSuspect": clearSuspect,
		"clearAllSuspectBadgesForAssociation" : clearAllSuspectBadgesForAssociation
	};

})(jQuery);
