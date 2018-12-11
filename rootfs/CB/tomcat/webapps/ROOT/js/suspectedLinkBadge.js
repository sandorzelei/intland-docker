var codebeamer = codebeamer || {};

codebeamer.suspectedLinkBadge = codebeamer.suspectedLinkBadge || (function($) {

	var relationsBox = $("#relations-box");

	function getRelationsBoxHeader() {
		return relationsBox.find("legend").first();
	}

	function getRelationsBoxContent() {
		return getRelationsBoxHeader().next();
	}

	function countBadges() {
		return getRelationsBoxContent().find(".suspectedLinkBadge.clearable, .referenceSettingBadge.clearable.active").length;
	}

	function countClearableBadges() {
		return getRelationsBoxContent().find(".suspectedLinkBadge .clearIcon, .referenceSettingBadgeClearSuspect").length;
	}

	function getAggregatedBadges() {
		return relationsBox.find(".suspectedLinkBadge.aggregated");
	}

	function getCounterBadge(count) {
		var counterBadge = $("<div>", {
			"class": "suspectedLinkBadge aggregated counter",
			"title": i18n.message("layout.document.reference.aggregatedBadge.tooltip")
		}).html(i18n.message('tracker.view.layout.document.reference.suspected'));

		$('<span>', { 'class': 'aggregatedCounter' })
			.append(' (')
			.append($('<span>', { 'class': 'value' }).html(count))
			.append(')')
			.appendTo(counterBadge);

		counterBadge.on('click', function() {
			$(this).closest("#relations-box").find(".collapseToggle").click(); // toggle border collapse
		});

		return counterBadge;
	}

	function addSuspectLinkClearers($clearer) {
		$clearer.each(function() {
			var $this = $(this);
			var badge = $this.hasClass("suspectedLinkBadge") ? $this : $this.closest(".suspectedLinkBadge");
			var clearer = badge.find(".clearIcon img");
			// get source and target
			var badgeId = badge.attr("data-name");
			var revision = badge.attr("data-revision");
			var ids = badgeId.split("-");
			var taskId = ids[1];
			var targetTaskId = ids[2];
			var associationId = badge.attr("data-association-id");

			if (badge.hasClass("clearable")) {
				badge.click(function() {

					if (badge.hasClass("artifactSuspectLink")) {
						showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.reference.clear.confirm"), function() {
							relationsBox = $("#relations-box");
							$.ajax({
								type: "delete",
								url: contextPath + "/ajax/referenceSetting/clearSuspectedReference.spr?association_id=" + associationId,
								dataType: "html",
								success: function() {
									removeCurrentBadge(associationId, taskId, targetTaskId);
								},
								error: function(jqXHR, textStatus, errorThrown) {
									alert("Error: " + textStatus + " - " + errorThrown);
								}
							});
						});
					} else if (badge.hasClass("showDiff")) {
						inlinePopup.show(contextPath + "/issuediff/diffCombined.spr?copy_id=" + taskId + "&association_id=" + associationId
							+ (targetTaskId ? "&original_id=" + targetTaskId : ""), {geometry: "large"});
                    } else {
						inlinePopup.show(contextPath + "/issuediff/diffSuspected.spr?issue_id=" + targetTaskId
								+ "&association_id=" + associationId + "&association_task_id=" + taskId, { geometry: "large"});
					}
				});
			} else {
                if (badge.hasClass("showDiff")) {
                    badge.click(function() {
                        inlinePopup.show(contextPath + "/issuediff/diffCombined.spr?copy_id=" + taskId + "&association_id=" + associationId
                            + (targetTaskId ? "&original_id=" + targetTaskId : "") +
							(revision ? "&revision=" + revision : ""), {geometry: "large"});
                    });
                }
			}



			badge.on("clear", function(e, args) {
				if (targetTaskId == args.id) {
					removeCurrentBadge(associationId, taskId, targetTaskId);
				}
			});
		});
	}

	var removeCurrentBadge = function(associationId, taskId, targetTaskId, isPopup) {
		// remove the suspected tablets
		var outgoingTabletsSelector = "span[data-name=suspect-" + taskId + "-" + targetTaskId + "]";
		var outgoingTablets = isPopup ? parent.$(outgoingTabletsSelector) : $(outgoingTabletsSelector);
		var incomingTabletsSelector = "span[data-name=suspect-" + targetTaskId + "-" + taskId + "]";
		var incomingTablets = isPopup ? parent.$(incomingTabletsSelector) : $(incomingTabletsSelector);

		outgoingTablets.add(incomingTablets);
		// Reset style so it will look like inactive suspect links
		// Remove spans
		outgoingTablets.find(".aggregatedCounter, .clearIcon").remove();
		// Clear all listeners
		outgoingTablets.off();
		// Remove icon
		outgoingTablets.siblings(".depends-on-icon").remove();
		// Change class to inactive
		outgoingTablets.removeClass("clearable");
		outgoingTablets.addClass("inactiveSuspectedLinkBadge");
		// Set new title
		outgoingTablets.attr("title", i18n.message("association.propagatingSuspects.info"));

		codebeamer.ReferenceSettingBadges.clearAllSuspectBadgesForAssociation(associationId);

	};

	var deleteSuspectedLink = function(associationId, taskId, targetTaskId, isPopup, callback) {
		relationsBox = $("#relations-box");
		$.ajax({
			type: "delete",
			url: contextPath + "/proj/tracker/clearsuspectedlink.spr?task_id=" + taskId + "&target_task_id=" + targetTaskId,
			dataType: "html",
			success: function() {
				removeCurrentBadge(associationId, taskId, targetTaskId, isPopup);
				if (callback) {
					callback();
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				alert("Error: " + textStatus + " - " + errorThrown);
			}
		});
	};

	function init($container) {
		relationsBox = $("#relations-box");

		var $badges = $(".suspectedLinkBadge").not(".aggregated").not('.inactiveSuspectedLinkBadge');
		if ($container) {
			$badges = $container.find(".suspectedLinkBadge").not(".aggregated").not('.inactiveSuspectedLinkBadge');
		}
        $badges.each(function() {
			var badge = $(this);
			if (badge.prop("initialized") !== true) {
				addSuspectLinkClearers(badge);
				badge.prop("initialized", true);
			}
		});

	}

	return {
		init: init,
		deleteSuspectedLink: deleteSuspectedLink
	};

}(jQuery));

jQuery(function() {
	codebeamer.suspectedLinkBadge.init();
});
