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
 * Javascript functions used in addUpdateTask.jsp
 */
var addUpdateTask = {

	/**
	 * The wiki-typed fields will remember their sizes in the user-settings
	 * @param trackerId
	 * @param wikiFieldSizes The javascript object for wiki fields' sizes settings
	 */
	makeWikiFieldsRememberTheirSizes: function(trackerId, wikiFieldSizes) {
		if (! wikiEditorOverlay.ALLOW_RESIZE) {
			return;
		}

		try {
			trackerId = parseInt(trackerId);
			if (wikiFieldSizes == null) {
				wikiFieldSizes = {};
			}
		} catch (ex) {
			console.warn("An error occurred while initializing wiki field sizes.");
			return ;
		}

		var settings = wikiFieldSizes[trackerId];
		if (typeof settings == "undefined") {
			console.warn("No user settings found for wiki field sizes for this tracker.");
			settings = {};
		}

		(function setWikiFieldSizes() {
			setTimeout(function() {
				// set default size first
				$(".fieldType_wikitext").each(function() {
					var cell = $(this);
					var textarea = cell.find("textarea").first();
					var contentArea = cell.find(wikiEditorOverlay.RESIZABLE_SELECTOR);
					var rows = textarea.attr("rows");
					var cols = textarea.attr("cols");
					contentArea.css("max-height", "none");
					var size = null;
					if (rows && cols) {
						size = {
							"width": cols + "em",
							"height": rows + "em"
						};
					}

					// check if has custom size stored?, use that!
					var fieldId = cell.data("field-id");
					if (fieldId) {
						var fieldSettings = settings[fieldId];
						if (fieldSettings) {
							var width = fieldSettings["w"];
							var height = fieldSettings["h"];
							if (width && height) {
								size = {
									"width": width,
									"height": height
								};
							}
						}
					}

					if (size) {
						contentArea.css(size);
					}
				});
			}, 100); // wait a bit because other code might override these changes
		})();

		var saveWikiFieldSizes = throttleWrapper(function() {
			var settings = {};
			$(".fieldType_wikitext[data-field-id]").each(function() {
				var cell = $(this);
				var fieldId = cell.data("field-id");
				var contentArea = cell.find(wikiEditorOverlay.RESIZABLE_SELECTOR);
				// round the sizes to pixel because this might be something like 16.16666666 if percentages is used
				var width = Math.round(contentArea.width());
				var height = Math.round(contentArea.height());
				settings[fieldId] = {
					"w": width,
					"h": height
				};
			});
			wikiFieldSizes[trackerId.toString()] = settings;
			$.post(contextPath + "/userSetting.spr?name=ISSUE_WIKI_FIELD_SIZES", {
				"value": JSON.stringify(wikiFieldSizes)
			});
		}, 1000);

		$("body").on("wikiFieldSizesChanged", saveWikiFieldSizes);
	}

};
