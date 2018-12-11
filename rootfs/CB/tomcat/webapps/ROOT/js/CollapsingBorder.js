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
 * Javascript for collapsingBorder.tag
 */
var CollapsingBorder = CollapsingBorder || {

	CSS_CLASS: "collapsingBorder_collapsed",
	EXPANDED_CSS_CLASS: "collapsingBorder_expanded",

	/**
	 * Toggle the collapsing-border
	 * @param legendLink The link inside the legend clicked on
	 * @param onChange Optional javascript function callback when toggle changes. The "this" contains the legend item, the 1st param is if the item is open
	 * @param toggle The optional CSS selector for the element(s) to toggle with this
	 */
	toggle:function(legendLink, onChange, toggle) {
		// find the parent fieldset
		var $fieldset = $(legendLink).closest("fieldset");
		if ($fieldset != null && $fieldset.length >0) {
			var open;
			if ($fieldset.hasClass(CollapsingBorder.CSS_CLASS)) {
				open = false;
				$fieldset.removeClass(CollapsingBorder.CSS_CLASS).addClass(CollapsingBorder.EXPANDED_CSS_CLASS);
			} else {
				open = true;
				$fieldset.addClass(CollapsingBorder.CSS_CLASS).removeClass(CollapsingBorder.EXPANDED_CSS_CLASS);
			}

			if (onChange != null) {
				onChange.call($fieldset, open);
			}

			CollapsingBorder.update(legendLink, toggle);
		}
	},

	/**
	 * Find the fieldset and update the visibility of the "toggle" item
	 * @param legendLink
	 * @param toggle The optional CSS selector for the element(s) to toggle with this
	 * @return The fieldset
	 */
	update: function(legendLink, toggle) {
		// find the parent fieldset
		var $fieldset = $(legendLink).closest("fieldset");
		if ($fieldset != null && $fieldset.length >0) {
			var open = !( $fieldset.hasClass(CollapsingBorder.CSS_CLASS));

			if (toggle) {
				if (open) {
					$(toggle).show();
				} else {
					$(toggle).hide();
				}
			}
		}
		return $fieldset;
	},

	/**
	 * Toggle the collapsing border
	 * @param htmlId the HTML id of the collapsing border (id param of collapsingBorder.tag)
	 */
	toggleById:function(htmlId) {
		// clicking only on the first collapsingborder child, because all the sub-repos are also children
		$("#" + htmlId +" .collapsingBorder_legend a").first().trigger("click");
	}
};
