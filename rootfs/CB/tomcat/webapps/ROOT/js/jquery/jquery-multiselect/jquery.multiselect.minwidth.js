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

// This is a patch/plugin for the JQuery multiselect plugin, that overrides the default method of setting the field/popup width
(function($) {

    $.ech.multiselect.prototype._setButtonWidth = function() {
		var width = this.element.outerWidth();
		var minVal = this._getMinWidth();

		if(width < minVal) {
			width = minVal;
		}
		// set widths
		// this.button.outerWidth(width);
        this.button.css({
      	   "min-width": width
        });
    };

    // set menu width
    $.ech.multiselect.prototype._setMenuWidth = function() {
        var width = this.element.outerWidth();
        var o = this.options;

        if (/\d/.test(o.minWidth) && width < o.minWidth) {
        	width = o.minWidth;
        }

        //this.menu.outerWidth(this.button.outerWidth());
        this.menu.css({
       	   "min-width": width
        });
    };

	$.ech.multiselect.prototype._setButtonValue = function(value) {
		this.buttonlabel.html(value);
	};

})( jQuery );