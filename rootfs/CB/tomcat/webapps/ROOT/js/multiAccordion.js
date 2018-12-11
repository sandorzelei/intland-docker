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

(function($) {

	/**
	 * CodeBeamer multi-accordion plugin.
	 * Allows opening more than one section at the same time (jQuery UI's Accordion widget does not support this feature).
	 *
	 * Usage:
	 *
	 *    $(elem).cbMultiAccordion();
	 *
	 *    $(elem).cbMultiAccordion({
	 *    	active: 1,
	 *    	allowOneOpen: true
	 *    });
	 *
	 *    $(elem).cbMultiAccordion();
	 *    $(elem).cbMultiAccordion("open", 2);
	 *
	 *    $(elem).cbMultiAccordion()
	 *    	.addClass("someTestClass")
	 *    	.cbMultiAccordion("disable", 0);
	 * @param method Method to call or initialization options.
	 * @author Gabor Nagy (gabor.nagy@intland.com)
	 * @returns {*} Allows jQuery method chaining.
	 */
	$.fn.cbMultiAccordion = function(method) {

		method = method || "init";

		var container = this;

		var accordionToggleAnimationDuration = 100;
		var headerSelector = "h1,h2,h3,h4,h5,h6";

		$.fn.cbMultiAccordion.defaults = {
			active: 0,  // which tab index should be open initially (indexing starts from 0)
			allowOneOpen: false,  // true if accordion should allow opening at most one section at the same time
			fixedHeight: 0  // If non-zero, a fixed height is set to the whole accordion container, similar to how jQuery accordion works.
						    // If its value is a function, it will be invoked on window resize to update accordion height dynamically.
		};

		var methods = {

			init : function(options) {
				var settings = $.extend({}, this.cbMultiAccordion.defaults, options);
				return this.each(function() {
					initSingleElement(settings);
				});
			},

			"open": open,  // Open a tab with a specified index (indexing starts from 0)
			"openAll" : openAll,
			"close": close,  // Close a tab with a specified index (indexing starts from 0)
			"closeAll": closeAll,
			"isOpen": isOpen,  // True if tab with the specified index is open (indexing starts from 0)
			"isClosed": isClosed,  // True if tab with the specified index is closed (indexing starts from 0)
			"hasOpened": hasOpened, // True if there is at lease one opened tab
			"toggle": toggleState,  // Toggles a tab with a specified index (indexing starts from 0)
			"enable": enable,  // Enable a tab with a specified index (indexing starts from 0)
			"disable": disable,  // Disable a tab with a specified index (indexing starts from 0)
			"scrollToHeader": scrollToHeader,  // Scrolls to the specified tab (indexing starts from 0). You need to specify the container to scroll!
			"saveState": saveState,  // Return a descriptor object that stores current open/close state of named sections
			"restoreState": restoreState  // Restore a previously saved open/close state for the entire accordion control
		};

		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method "' +  method + '" does not exist in cbMultiAccordion plugin!');
		}

		function initSingleElement(options) {
			if (container.prop("initialized") === true) {
				return ;
			}
			container.prop({
				"initialized": true,
				"cbMultiAccordionOptions": options
			}).removeClass("hiddenBeforeInit");
			var accordionHeaders = container.children(headerSelector);
			accordionHeaders.each(function(index, header) {
				header = $(header);
				header.addClass("accordion-header");
				var content = header.nextUntil(headerSelector);
				content.addClass("accordion-content");
				if (index == options.active) {
					header.addClass("opened");
					content.addClass("opened");
				} else {
					content.hide();
				}
				header.click(function() {
					if (!header.hasClass("disabled")) {
						content.toggleClass("opened");
						if (container.prop("animationsEnabled") !== false) {
							content.slideToggle(accordionToggleAnimationDuration);
						} else {
							content.toggle();
						}
						var headerIndex = accordionHeaders.index(header);
						header.toggleClass("opened");
						if (header.hasClass("opened")) {
							options["allowOneOpen"] && closeOthers(header);
						}
						if (content.hasClass("opened")) {
							container.trigger("open", headerIndex);
						} else {
							container.trigger("close", headerIndex);
						}
						container.trigger("openOrClose", headerIndex);
					}
					return false;
				});
			});

			var quickIconsId = container.data("quick-icons");
			if (quickIconsId) {
				initQuickIcons($("#" + quickIconsId));
			}

			var isDynamicHeight = $.isFunction(options.fixedHeight);
			if (isDynamicHeight || options.fixedHeight > 0) {
				var contents = container.children("div");
				var headers = container.children(headerSelector);
				var headersTotalHeight = 0;
				$(headers).each(function() {
					headersTotalHeight += $(this).outerHeight();
				});
				var height = isDynamicHeight ? options.fixedHeight.call() : options.fixedHeight;
				contents.height(height - headersTotalHeight)
					.css("overflow", "auto");
				if (isDynamicHeight) {
					var resizeCallback = throttleWrapper(function() {
						contents.height(options.fixedHeight.call() - headersTotalHeight);
					});
					$(window).resize(resizeCallback);
				}
			}
		}

		function getHeader(index) {
			var accordionHeaders = $(container).children(headerSelector);
			return $(accordionHeaders.get(index));
		}

		function toggleState(index, open) {
			if ($.isArray(index)) {
				$.map(index, function(i) { toggleState(i, open); });
			} else {
				var header = getHeader(index);
				if (header.length > 0) {
					var isOpen = header.hasClass("opened");
					if (typeof open == "undefined" || open != isOpen) {
						$(header).click();
					}
					var options = container.prop("cbMultiAccordionOptions");
					if (options["allowOneOpen"] && open) {
						closeOthers(header);
					}
				}
			}
			return container;
		}

		function toggleEnabled(index, enabled) {
			if ($.isArray(index)) {
				$.map(index, function(i) { toggleEnabled(i, enabled); });
			} else {
				var header = getHeader(index);
				if (header.length > 0) {
					if (!enabled) {
						close(index);
					}
					header.toggleClass("disabled", !enabled);
				}
			}
			return container;
		}

		function closeOthers(ignoreHeader) {
			var headers = $(container).children(headerSelector);
			headers.each(function() {
				var header = $(this);
				var isOpen = header.hasClass("opened");
				if (ignoreHeader.get(0) != header.get(0) && isOpen) {
					header.click();
				}
			});
			return container;
		}

		function open(index) {
			return toggleState(index, true);
		}

		function openAll() {
			container.find(".accordion-header").each(function(index, el) {
				toggleState(index, true);
			});
		}

		function close(index) {
			return toggleState(index, false);
		}

		function closeAll() {
			container.find('.accordion-header').each(function(index, el) {
				toggleState(index, false);
			});
		}

		function enable(index) {
			return toggleEnabled(index, true);
		}

		function disable(index) {
			return toggleEnabled(index, false);
		}

		function isOpen(index) {
			return getHeader(index).hasClass("opened");
		}

		function isClosed(index) {
			return !isOpen(index);
		}

		function hasOpened() {
			var result = false;

			container.find('.accordion-header').each(function(index, el) {
				if (isOpen(index)) {
					result = true;
					return false;
				};
			});

			return result;
		}

		function scrollToHeader(index, scrollableContainer, delay) {
			var options = container.prop("cbMultiAccordionOptions");
			if (options["allowOneOpen"]) {
				return ;
			}
			var header = $(container.find(".accordion-header").get(index));
			setTimeout(function() {
				var p = scrollableContainer.position();
				var offset = p ? p.top : 0;
				scrollableContainer.animate({
					scrollTop: scrollableContainer.scrollTop() - offset + header.position().top
				}, 200);
			}, typeof delay == "undefined" ? accordionToggleAnimationDuration : delay);

			return container;
		}

		function initQuickIcons(icons) {
			var scrollableContainer = icons.next(".overflow");
			var accordion = scrollableContainer.find(".accordion");
			icons.children("li").not(".disabled").each(function(index, link) {
				$(link).click(function() {
					toggleState(index);
					scrollToHeader(index, scrollableContainer);
					return false;
				});
			});
		}

		function getSectionNames() {
			var ids = [];
			$(container).children(headerSelector).each(function() {
				var id = $(this).next().data("section-id");
				if (id) {
					ids.push(id);
				}
			});
			return ids;
		}

		function saveState() {
			var result = {};
			$(getSectionNames()).each(function(index, sectionName) {
				result[sectionName] = isOpen(index);
			});
			return result;
		}

		function restoreState(savedState) {
			var sections = getSectionNames();
			$(container).prop("animationsEnabled", false);
			for (var sectionName in savedState) {
				var isOpen = !!savedState[sectionName];
				toggleState(sections.indexOf(sectionName), isOpen);
			}
			$(container).prop("animationsEnabled", true);
		}
	};

})(jQuery);
