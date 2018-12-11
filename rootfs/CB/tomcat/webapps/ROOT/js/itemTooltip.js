var codebeamer = codebeamer || {};
codebeamer.tooltips = codebeamer.tooltips || (function($) {
	var trackerItemTooltip, actionBarIconTooltip;

	trackerItemTooltip = {
		options: {
			show: {
				duration: 300,
				delay: 300
			},
			hide: {
				duration: 300,
				delay: 300
			},
			position: {
				my: "right top",
				at: "left-5 top",
				collision: "flipfit flipfit"
			}
		},
		isTarget: function(element) {
			var result = false;

			if (element && ($(element).parent().is("[data-hover-tooltip-target]") || $(element).is("[data-hover-tooltip-target]"))) {
				result = true;
			}

			return result;
		},
		handler: function(callback) {
			var $element, $parent, $wikiLinkContainer, interWikiLink, progressCursorHandlerId, localImgAttribute, data, revision;

			$parent = $(this).parent();
			$element = $parent.closest("[data-hover-tooltip=true]");

			localImgAttribute = $parent.data("hover-tooltip-local-img");

			// Get the content from the target node
			if (localImgAttribute) {
				callback("<img src='" +  $element.attr("href") + "' />");
			} else {
				// Get the content from ajax call using the defined wikilink
				interWikiLink = $element.data("wikilink");
				if (!interWikiLink) {
					$wikiLinkContainer = $element.find("[data-wikilink]");
					if ($wikiLinkContainer.length > 0) {
						interWikiLink = $wikiLinkContainer.data("wikilink");
					}
				}

				if (interWikiLink) {
					// Show progress indicator after a while to show that the code is working in the background.
					progressCursorHandlerId = setTimeout(function() {
						$parent.removeClass("default-cursor");
						$parent.addClass("progress-cursor");
					}, 100);

					data =  {
						interWikiLink: interWikiLink
					};

					revision = $element.data("revision");
					if (!revision) {
						$wikiLinkContainer = $element.find("[data-wikilink][data-revision]");
						if ($wikiLinkContainer.length > 0) {
							revision = $wikiLinkContainer.data("revision");
						}
					}

					if (revision) {
						data.revision = revision;
					}

					 $.get({
			 			url: contextPath + "/ajax/tooltip/getDescription.spr",
			 			data: data,
			 			cache: false,
			 			success:  function(data) {
							if ($parent.hasClass("progress-cursor")) {
								// Switch back the progress indicator if it was set.
								setTimeout(function() {
									$parent.removeClass("progress-cursor");
									$parent.addClass("default-cursor");
								}, 10);
							} else {
								// Cancel the timer when the ajax request was fast.
								clearTimeout(progressCursorHandlerId);
							}
							callback(data);
						}
			 		});
				}
			}
		}

	};

	actionBarIconTooltip = {
		options: {
			classes: {
				"ui-tooltip" : "actionBarIconTooltip"
			},
			hide: false,
			position: {
				my: "left top",
				at: "left bottom+15",
				collision: "flipfit"
			},
			show: false
		},
		isTarget: function(element) {
			var result = false;

			if (element && $(element).hasClass("actionBarIcon")) {
				result = true;
			}

			return result;
		},
		handler: function(callback) {
			var result, tooltip;

			tooltip = $(this).attr("data-tooltip");
			if (tooltip && tooltip.length > 0) {
				result = tooltip;
			} else {
				result = $(this).attr("title");
			}

			callback(result);
		}
	};

	return [actionBarIconTooltip, trackerItemTooltip];
}(jQuery));

$(document).ready(function() {
	$("body").tooltip({
		items: "[data-hover-tooltip=true] [data-hover-tooltip-target]>img, [data-hover-tooltip=true] img[data-hover-tooltip-target], .actionBarIcon",
		tooltipClass: "item-ui-tooltip",
		content: function(callback) {
			var i, tooltipConfiguration;

			for (i = 0; i < codebeamer.tooltips.length; i++) {
				tooltipConfiguration = codebeamer.tooltips[i];

				if (tooltipConfiguration.isTarget($(this))) {

					if (tooltipConfiguration.hasOwnProperty("options")) {
						$( "body" ).tooltip( "option", tooltipConfiguration.options);
					}

					tooltipConfiguration.handler.call(this, callback);

					break;
				}

			}

		},
		close: function(event, ui) {
			jquery_ui_keepTooltipOpen(ui);
		}
	});

	// Hide all tooltips if clicking an element
	$("body").on("click", "[data-hover-tooltip=true] [data-hover-tooltip-target], [data-hover-tooltip=true] img[data-hover-tooltip-target], .actionBarIcon", function() {
		$('.ui-tooltip').hide();
	});
});