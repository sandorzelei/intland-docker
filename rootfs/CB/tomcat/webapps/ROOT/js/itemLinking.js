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

/*
* javascript file for common functions of linking test cases and requirements
*/

var codebeamer = codebeamer || {};
codebeamer.itemLinking = codebeamer.itemLinking || (function($) {
	function loadFieldMapping ($fieldMappingBox, sourceTrackerId, destinationTrackerId, optionListName, skipLoadingAnimation, label, url) {
		optionListName = optionListName || "fieldMappings";
		url = url || "/docview/ajax/getFieldMapping.spr";
		if (!skipLoadingAnimation) {
			ajaxBusyIndicator.showBusysign($fieldMappingBox, i18n.message("tracker.view.layout.document.linking.load.message"));
		}
		$("input[type=submit]").attr("disabled", "disabled");

		$.get(contextPath + url + "?sourceTrackerId=" + sourceTrackerId + "&destinationTrackerId=" + destinationTrackerId, null, function (mapping) {
			$fieldMappingBox.empty();
			ajaxBusyIndicator.close();
			$("input[type=submit]").removeAttr("disabled");

			// display the possible mappings
			if (mapping.possible) {

				if (label) {
					var $span = $("<label>", {style: 'font-weight: bold; padding-left: 11px;'}).text(label);
					$fieldMappingBox.append($span);
				}

				var $notAvailableOption = $("<option>", {value: -1});
				$notAvailableOption.html(i18n.message("issue.paste.assign.target.none"));

				var $fieldset = $("<fieldset>");
				$fieldMappingBox.append($fieldset);

				var $legend = $("<legend>");
				$legend.html(i18n.message("issue.paste.assign.hint"));
				$fieldset.append($legend);

				var $table = $("<table>", {"class": "fieldMapping formTableWithSpacing"});
				$fieldset.append($table);

				for (var i = 0; i < mapping.possible.length; i++) {
					var field = mapping.possible[i].field;
					var targets = mapping.possible[i].targets;

					var $row = $("<tr>");
					$table.append($row);

					var $sourceField = $("<td>", {"class": "optional"});
					$sourceField.html(field.name);
					$row.append($sourceField);

					var $targetFields = $("<td>");
					$row.append($targetFields);

					var $select = $("<select>", {name: optionListName});
					$targetFields.append($select);

					$select.append($notAvailableOption.clone());

					for (var j = 0; j < targets.length; j++) {
						var $option = $("<option>", {value: field.id + "#" + targets[j].id});
						$option.html(targets[j].name);
						$select.append($option);
					}

				}
			}
			// display lost fields
			if (mapping.lost) {
				var $div = $("<div>", {"class": "error"});
				$div.html(i18n.message("issue.paste.lost.warning"));

				var $list = $("<ul>");
				$div.append($list);

				for (var i = 0; i < mapping.lost.length; i++) {
					var $li = $("<li>");
					$li.html(mapping.lost[i].name);
					$list.append($li);
				}

				$fieldMappingBox.append($div);
			}
		});
	};

	return {
		'loadFieldMapping': loadFieldMapping
	};
})(jQuery);