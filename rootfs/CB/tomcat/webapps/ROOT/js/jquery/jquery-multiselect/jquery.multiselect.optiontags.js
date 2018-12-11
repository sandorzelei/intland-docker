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
 *
 * $Revision$ $Date$
 */

// This is a patch/plugin for the JQuery multiselect plugin, that supports tags in option items
(function($) {

	$.ech.multiselect.prototype._makeOption = function(option) {
		var title = option.title ? option.title : null;
		var value = option.value;
		var id = this.element.attr('id') || this.multiselectID; // unique ID for the label & option tags
		var inputID = 'ui-multiselect-' + this.multiselectID + '-' + (option.id || id + '-option-' + this.inputIdCounter++);
		var isDisabled = option.disabled;
		var isSelected = option.selected;
		var labelClasses = [ 'ui-corner-all' ];
		var liClasses = [];
		var o = this.options;

		if(isDisabled) {
			liClasses.push('ui-multiselect-disabled');
			labelClasses.push('ui-state-disabled');
		}
		if(option.className) {
			liClasses.push(option.className);
		}
		if(isSelected && !o.multiple) {
			labelClasses.push('ui-state-active');
		}

		var $item = $("<li/>").addClass(liClasses.join(' '));
		var $label = $("<label/>").attr({
			"for": inputID,
			"title": title
		}).addClass(labelClasses.join(' ')).appendTo($item);
		var $input = $("<input/>").attr({
			"name": "multiselect_" + id,
			"type": o.multiple ? "checkbox" : "radio",
			"value": value,
			"title": title,
			"id": inputID,
			"checked": isSelected ? "checked" : null,
			"aria-selected": isSelected ? "true" : null,
			"disabled": isDisabled ? "disabled" : null,
			"aria-disabled": isDisabled ? "true" : null
		}).data($(option).data()).appendTo($label);

		var $span = $("<span/>").html($(option).html());
		if($input.data("image-src")) {
			$span.prepend($("<img/>").attr({"src": $input.data("image-src")}));
		}
		$span.appendTo($label);

		return $item;
	};
	
	$.ech.multiselect.prototype.update = function(isDefault) {
		var o = this.options;
		var $inputs = this.inputs;
		var $checked = $inputs.filter(':checked');
		var numChecked = $checked.length;
		var value;

		if(numChecked === 0) {
			value = o.noneSelectedText;
		} else {
			if($.isFunction(o.selectedText)) {
				value = o.selectedText.call(this, numChecked, $inputs.length, $checked.get());
			} else if(/\d/.test(o.selectedList) && o.selectedList > 0 && numChecked <= o.selectedList) {
				value = $checked.map(function() { return $(this).next().html(); }).get().join(o.selectedListSeparator);
			} else {
				value = o.selectedText.replace('#', numChecked).replace('#', $inputs.length);
			}
		}

		this._setButtonValue(value);
		if(isDefault) {
			this.button[0].defaultValue = value;
		}
	}

})( jQuery );