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
codebeamer.sticky = codebeamer.sticky || (function($) {

	/* Based on Waypoint.Sticky */
	/* http://imakewebthings.com/waypoints/shortcuts/sticky-elements */

	var $ = window.jQuery;

	function StickyElement(options) {
		this.options = $.extend({}, StickyElement.defaults, options);
		this.element = this.options.element;
		this.$element = $(this.element);
	}

	StickyElement.prototype.createWaypoint = function(referenceElement) {
		var originalHandler, target;
		originalHandler = this.options.handler;
		target = referenceElement ?  referenceElement : this.$sticky;

		this.waypoint = target.waypoint($.extend({}, this.options, {
			handler: $.proxy(function(direction) {
				var shouldBeStuck, wrapperHeight;
				shouldBeStuck = this.options.direction.indexOf(direction) > -1;
				wrapperHeight = shouldBeStuck ? this.$element.outerHeight(true) : '';

				this.$sticky.height(wrapperHeight);
				this.$element.toggleClass(this.options.stuckClass, shouldBeStuck);

				if (originalHandler) {
					originalHandler.call(this, direction);
				}
			}, this)
		}))
	};

	StickyElement.prototype.createWrapper = function() {
		var wrapper = $(this.options.wrapper);
		if (this.options.wrapper) {
			this.$element.wrap(this.options.wrapper);
		}
		this.$sticky = this.$element.parent();
		this.$sticky.addClass(this.options.wrapperClass);
		this.sticky = this.$sticky[0];
	};

	StickyElement.defaults = {
		wrapper: "<div></div>",
		wrapperClass: "sticky-wrapper",
		stuckClass: "stuck",
		direction: "down right"
	};

	function makeStickyWithWrapper(options) {
		var sticky;

		sticky = new StickyElement(options);

		sticky.createWrapper();
		sticky.createWaypoint();
	}

	function makeTableHeaderSticky(options) {
		var $tableHeader, sticky, $stickyTableHeader, $stickyTable, finalOptions, originalHandler;

		function resizeStickyTable() {
			var columnWidths;

			columnWidths = [];

			$tableHeader.find(options.columnTag).each(function() {
				// This gives more precision than comparable jQuery methods
				var width = window.getComputedStyle(this).width;

				columnWidths.push(parseFloat(width));
			});

			$stickyTable.find(options.columnTag).each(function(index) {
				$(this).css("width", columnWidths[index]);
			});
		}

		$tableHeader = $(options.headerRow);

		$stickyTableHeader = $tableHeader.clone();

		if (options.afterClone && $.isFunction(options.afterClone)) {
			$stickyTable = options.afterClone($stickyTableHeader);
		} else {
			$stickyTable = $("<table>");
			$stickyTable.append($("<thead>").append($stickyTableHeader));
		}

		$("body").append($stickyTable);

		originalHandler = options.handler;

		finalOptions = $.extend({}, StickyElement.defaults, options, {
			element: $stickyTable,
			handler: function(direction) {

				resizeStickyTable();

				if (originalHandler) {
					originalHandler(direction, $tableHeader, $stickyTable);
				}
			}
		});

		sticky = new StickyElement(finalOptions);

		sticky.createWrapper();

		sticky.createWaypoint(options.headerRow);

		if (options.hasOwnProperty("dynamic") && options.dynamic) {
			sticky.resizeHandler = $(window).resize(resizeStickyTable);

			// Add the object to the wrapper parent
			$stickyTable.parent().data("sticky", sticky);
		}
	}

	function destroyAll(options) {
		var finalOptions, wrapper, sticky;

		finalOptions = $.extend({}, StickyElement.defaults, options);

		$.waypoints("destroy");

		wrapper = $("." + finalOptions.wrapperClass);

		sticky = wrapper.data("sticky");
		if (sticky && sticky.resizeHandler) {
			$(window).off("resize", sticky.resizeHandler);
		}

		wrapper.remove();
	}

	return {
		"makeStickyByWrapping": makeStickyWithWrapper,
		"makeTableHeaderSticky": makeTableHeaderSticky,
		"destroyAll": destroyAll
	}

})(jQuery);
