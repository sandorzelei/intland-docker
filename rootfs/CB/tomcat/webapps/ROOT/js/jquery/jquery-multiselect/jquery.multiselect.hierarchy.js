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

(function($){

	$.fn.multiselectHierarchy = function() {
		var instance, $select, $inputs, $input, level, value;

		$select = $(this);
		instance = $select.multiselect("instance");
		$inputs = instance.inputs;

		$select.find("option").each(function(index, element) {
			level = $(element).data("level");
			value = $(element).val();

			if ($.isNumeric(level) && level >= 0 && $.isNumeric(value) && value > 0) {
				$input = $inputs.filter("[value=" + value + "]");
				$input.next().css("margin-left", level * 15 + "px");
			}
		});

	};

}(jQuery));