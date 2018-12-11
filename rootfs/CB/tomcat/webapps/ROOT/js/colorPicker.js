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
 */

/**
 * Javascript part for ui:colorPicker tag.
 */
var colorPicker = {

	showUnselect: false,

	// palette/background colors as keys and their font/foreground colors as values
	// note: the values here are overwritten by the palette colors from IssueStatusStyles.java (see colorPicker.tag), and these are here only for testing purposes
	paletteColors: {"#8c0f14":"white","#d9923b":"white","#008248":"white","#005c50":"white","#007491":"white","#454545":"white","#b31317":"white","#ffab46":"white","#00a85d":"white","#187a6d":"white","#0093b8":"white","#5f5f5f":"white","#cc3f44":"white","#ffbc6b":"white","#27c27c":"white","#3d998d":"white","#2ab0d1":"white","#858585":"white","#e57579":"white","#ffd9ab":"white","#58dba0":"white","#6eb8ae":"white","#5eceeb":"white","#ababab":"white"},

	createPaletteBody: function(showClear) {
		var body = '<div class="palette">';
		if (colorPicker.showUnselect) {
			var defaultColorTitle = 'Revert to default color determined from label and status';	// TODO: i18n
			var defaultColorLabel = 'Use default color';	// TODO: i18n
			body +="<a class='paletteElement paletteDefaultColor' title='" + defaultColorTitle +"'>" + defaultColorLabel +"</a>";
		}
		for (var color in colorPicker.paletteColors) {
			body += "<a class='paletteElement' style='background-color:" + color +";'></a>";
		}
		body +='<div style="clear:both;"></div>';
		if (showClear === true) {
			body += '<span class="clearButton"><p>' + i18n.message('colorpicker.clear') + '</p></span>';
		}
		body +='</div>';
		return body;
	},

	getFontColorForBackgroundColor: function(backgroundColor) {
		if (backgroundColor) {
			backgroundColor = backgroundColor.toUpperCase();
			for (var paletteColor in colorPicker.paletteColors) {
				if (backgroundColor == paletteColor.toUpperCase()) {
					var color = colorPicker.paletteColors[paletteColor];
					return color;
				}
			}
		}
		return "white";
	},

	// converts rgb(0,0,0) string to RGB hex code
	// used because "backgroundColor" css returns the color this way
	// http://stackoverflow.com/questions/638948/background-color-hex-to-javascript-variable-jquery
	rgb2hex:function(rgb) {
		if (rgb == null) {
			return null;
		}
		var rgbMatch = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
		if (!rgbMatch) {
			return rgb;
		}
		function hex(x) {
			return ("0" + parseInt(x).toString(16)).slice(-2);
		}
		return "#" + hex(rgbMatch[1]) + hex(rgbMatch[2]) + hex(rgbMatch[3]);
	},

	/**
	 * @param el The colorPicker's html element
	 * @param fieldId The html-id of the field to write the selected color into
	 * @param showClear Whether clear option is shown
	 */
	showPalette: function(el, fieldId, indicatorId, showClear, dialogClass) {
		var colorPickerPanel = $(el).data("colorPickerPanel");
		if (colorPickerPanel) {
			colorPickerPanel.dialog("open");
			return;
		}

		var id = $(el).attr("id");

		var body = colorPicker.createPaletteBody(showClear);
		var palette = $(body);
		palette.appendTo("body").dialog({
			dialogClass: "colorPickerDialog" + (dialogClass ? (" " + dialogClass) : ""),
			autoOpen: false,
			modal: false,
			title: i18n.message('colorpicker.title'),
			resizable: false,
			draggable: false,
			width: '138px',
			height: 'auto',
			minHeight: '100px',
			position: { my: "left top", at: "left bottom", of: $(el) },
			create: function(event, ui) {
				var widget = $(this).dialog("widget");
				$(".ui-dialog-titlebar-close", widget)
					.removeClass("ui-icon-closethick")
					.addClass("ui-icon-close");
			}
		});
		palette.dialog("open");

		palette.find(".paletteElement").click(function() {
			var $pe = $(this);
			$pe.siblings().removeClass('paletteSelected');
			$pe.addClass('paletteSelected');

			var colorSelected = colorPicker._getColorOfPaletteElement($pe);
			colorPicker.selectColor(el, fieldId, indicatorId, colorSelected);

			return false; // stop propagation
		});

		if (showClear === true) {
			palette.find(".clearButton").click(function() {
				colorPicker.selectColor(el, fieldId, indicatorId, ""); // Set empty stringS
				return false;
			});
		}

		$(el).data("colorPickerPanel", palette);

		var value = $("#" + fieldId).val();
		colorPicker._selectPaletteElementWithColor(palette, value);
	},

	_getColorOfPaletteElement: function(paletteElement) {
		var $pe = $(paletteElement);
		var color = $pe.css('backgroundColor');
		if ($pe.hasClass('paletteDefaultColor')) {
			color = null;
		}
		color = colorPicker.rgb2hex(color);
		return color;
	},

	_selectPaletteElementWithColor: function(panelElement, colorValue) {
		// remove selection
		var $paletteElements = $(panelElement).find(".paletteElement");
		$paletteElements.removeClass("paletteSelected");
		if (colorValue != null && colorValue !='') {
			// select the same as the color value
			$paletteElements.each(function() {
				var color = colorPicker._getColorOfPaletteElement(this);
				if (color && colorValue && color.toUpperCase() == colorValue.toUpperCase()) {
					$(this).addClass('paletteSelected');
				}
			});
		}
	},

	/**
	 * @param colorSelected The color code selected, null if the default colors should be used
	 */
	selectColor: function(el, fieldId, indicatorId, colorSelected) {
		// hide the panel after color is selected
		console.log("color selected for " + fieldId +" :" + colorSelected);	// TODO: comment out
		colorPicker.hidePalette(el);

		// set the value and fire change event on the field so anybody can subscribe it
		$("#" + fieldId).val(colorSelected).change();

		if (indicatorId) {
			if (colorSelected) {
				$("#" + indicatorId).css("background-color", colorSelected);
				$("#" + indicatorId).show();
			} else {
				$("#" + indicatorId).css("background-color", "#FFFFFF");
				$("#" + indicatorId).hide();
			}
		}
	},

	hidePalette: function(el) {
		var colorPickerPanel = $(el).data("colorPickerPanel");
		if (colorPickerPanel) {
			colorPickerPanel.dialog("destroy").remove();
			$(el).data("colorPickerPanel", null);
		}
	}
};
