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
 * $Id$
*/

/**
 * Utility class for scrolling around
 */
var ScrollUtil = {

	/**
	 * Scroll the page to an element
	 * @param el The element
	 * @param dur The duration of the scroll
	 * @param delta Integer: the scroll won't go exactly to the element, but with this difference
	 */
	scrollPageToElement: function(el, dur, delta) {
		if (delta == null) {
			delta = 0;
		}
		if (dur == null) {
			dur = 200;
		}
		$('html, body').animate({
			scrollTop: $(el).offset().top + delta
		}, dur);
	},

	/**
	 * Scroll a container to an element
	 * @param container The container to scroll
	 * @param el The element
	 * @param dur The duration of the scroll
	 * @param delta Integer: the scroll won't go exactly to the element, but with this difference
	 */
	scrollContainerToElement:function (container, el, dur, delta) {
	  if (! (container && el)) {
		  return;
	  }	  
	  if (delta == null) {
		  delta = 0;
	  }
	  if (dur == null) {
		  dur = 200;
	  }
		$(container).animate({
			scrollTop: $(el).offset().top - $(container).offset().top + $(container).scrollTop() + delta
		}, dur);
	}

};


