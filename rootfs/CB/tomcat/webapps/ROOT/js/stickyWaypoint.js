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
codebeamer.waypoint = codebeamer.waypoint || {};
codebeamer.waypoint.sticky = codebeamer.waypoint.sticky || (function($) {

	/* Backported from Waypoint.Sticky */
	/* http://imakewebthings.com/waypoints/shortcuts/sticky-elements */

	var $ = window.jQuery

	function Sticky(options) {
		this.options = $.extend({}, Sticky.defaults, options)
		this.element = this.options.element
		this.$element = $(this.element)
		this.createWrapper()
		this.createWaypoint()
	}

	/* Private */
	Sticky.prototype.createWaypoint = function() {
		var originalHandler = this.options.handler

		this.waypoint = this.$wrapper.waypoint($.extend({}, this.options, {
			handler: $.proxy(function(direction) {
				var shouldBeStuck = this.options.direction.indexOf(direction) > -1
				var wrapperHeight = shouldBeStuck ? this.$element.outerHeight(true) : ''

				this.$wrapper.height(wrapperHeight)
				this.$element.toggleClass(this.options.stuckClass, shouldBeStuck)

				if (originalHandler) {
					originalHandler.call(this, direction)
				}
			}, this)
		}))
	}

	/* Private */
	Sticky.prototype.createWrapper = function() {
		if (this.options.wrapper) {
			this.$element.wrap(this.options.wrapper)
		}
		this.$wrapper = this.$element.parent()
		this.wrapper = this.$wrapper[0]
	}

	/* Public */
	Sticky.prototype.destroy = function() {
		if (this.$element.parent()[0] === this.wrapper) {
			this.waypoint.destroy()
			this.$element.removeClass(this.options.stuckClass)
			if (this.options.wrapper) {
				this.$element.unwrap()
			}
		}
	}

	Sticky.defaults = {
		wrapper: '<div class="sticky-wrapper" />',
		stuckClass: 'stuck',
		direction: 'down right'
	}

	function makeSticky(element) {
		var sticky = new Sticky({
			element: element
		});
	}

	return {
		"makeSticky": makeSticky
	}

}(jQuery));
