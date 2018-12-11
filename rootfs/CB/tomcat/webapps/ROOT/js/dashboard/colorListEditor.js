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
codebeamer.dashboard.colorListEditor = codebeamer.dashboard.colorListEditor || (function($) {

	function init(selectorId) {
		var $container, $colorCodeField, numberOfBadges, $newColorBadge;

		$container = $("#" + selectorId).find(".color-container");

		$("#" + selectorId + "_color_code").on("change", function(event) {
			var value = this.value;

			if (value) {
				numberOfBadges = $container.find(".color-badge").size();
				$newColorBadge = $("<div></div>").addClass("color-badge").css("background-color", value).data("color", value);
				$("<span/>").addClass("color-name").text(i18n.message("widget.editor.field.label.seriesPaint.text") + " " +(numberOfBadges + 1)).appendTo($newColorBadge);
				$("<span title='" + i18n.message("widget.editor.field.label.seriesPaint.title") + "'></span>").addClass("delete").appendTo($newColorBadge);
				$newColorBadge.appendTo($container);

				this.value = "";

				refreshColors(selectorId);
			}

		});

		$container.on("click", ".delete", function(event) {
			var $target = $(event.currentTarget);
			$target.closest(".color-badge").remove();

			refreshColors(selectorId);

			event.preventDefault();
		});

		$("#" + selectorId + "_color_picker_link").on("click", function(event) {
			$("#" + selectorId + " .colorPicker").click();
			event.stopPropagation();
			event.preventDefault();
		});

		$container.sortable({
			stop: function() {
				refreshFieldValue(selectorId);
				refreshColorNames(selectorId);
			}
		});
	}

	function refreshColors(selectorId) {
		refreshFieldValue(selectorId);
		refreshColorNames(selectorId);
		$("#" + selectorId).find(".color-container").sortable("refresh");
	}

	function refreshColorNames(selectorId) {
		$("#" + selectorId).find(".color-badge").each(function(index, element) {
			$(element).find(".color-name").text(i18n.message("widget.editor.field.label.seriesPaint.text") + " " +(index + 1));
		});
	}

	function refreshFieldValue(selectorId) {
		var field = $("#" + selectorId + "_selected_colors");

		var value = "";

		$("#" + selectorId).find(".color-badge").each(function(index, element) {
			if (value) {
				value += ",";
			}

			value += $(element).data("color");
		});

		field.val(value);

		field.trigger("change");
	}

	return {
		"init": init
	};

})(jQuery);