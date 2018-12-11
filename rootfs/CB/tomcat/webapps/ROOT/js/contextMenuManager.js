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

function ContextMenuManager(options) {

	this.options = options;
	var selector = this.options['selector'];

	var mouseDownHandler = function() {
		$(selector).contextMenu("hide");
	};

	this.setTrigger = function() {
		if (!this.options.hasOwnProperty('trigger')) {
			this.options['trigger'] = 'right';
		}
	};

	this.setAnimation = function() {
		if (!this.options.hasOwnProperty('animation')) {
			this.options['animation'] = {
					duration: 200, show: "fadeIn", hide: "fadeOut"
			};
		}
	};

	this.addCustomBeforeEvents =function() {

		var customEvents = {
			show: function(opt) {
					this.find('img.menuArrowDown').css('visibility', 'visible');
			},
			hide: function(opt) {
					this.find('img.menuArrowDown').css('visibility', '');
			}
		};

		if (!this.options.hasOwnProperty('events')) {
			this.options['events'] = customEvents;
		}

	};

	this.addCustomAfterEvents = function() {
		var trigger = this.options['trigger'];
		var layer = $('context-menu-layer');
		var options = this.options;

		var setMenuPosition = function(context, opt) {
			var menu = opt.$menu;

			// Positioning only by left click triggering
			if (trigger == "left") {
				var menuArrowDown = context.find(".menuArrowDown").first();
				var layout = context.parents(".ui-layout-pane").first();
				if (options.hasOwnProperty("context")) {
					layout = options["context"];
				}
				if (!layout || layout.length == 0) {
					layout = $(window);
				}
				var position = {
					my : "left top",
					at : "left bottom",
					of : menuArrowDown.length > 0 ? menuArrowDown : context,
					collision : "flipfit",
					within : layout
				};

				if (opt.customPosition) {
					position = $.extend(position, opt.customPosition);
				}
				menu.position(position);
			}
		};
		// https://github.com/swisnl/jQuery-contextMenu/issues/128
		var fixMenuWidthBug = function($menu, nested) {
			// for nested menus the width of the widest item is used
			var maxWidth = 0;

			!!nested && $menu.show(); // nested menu need to be visible to get its width
			$menu.find('> li > span').each(function() {
				var $label = $(this);
				if ($label.width() > maxWidth) {
					maxWidth = $label.width();
				}
			});
			!!nested && $menu.hide();

			maxWidth += 50; // adjust with paddings and border around the labels

			$menu.css({
				'width': Math.max(maxWidth, $menu.width()),
				'max-width': 'none'
			});

			// calling fixMenuWidthBug for nested menus
			$menu.find('> li > ul').each(function() {
				fixMenuWidthBug($(this), true);
			});
		};

		var customAfterShowEvent = function(originalHandler) {
			return function(opt) {
				originalHandler.apply(this, arguments);
				setMenuPosition(this, opt);
				fixMenuWidthBug(opt.$menu);
				layer.on('mousedown', mouseDownHandler );
				layer.on('click', mouseDownHandler );
			}
		};

		var customAfterHideEvent = function(originalHandler) {
			return function(opt) {
				originalHandler.apply(this, arguments);
				layer.off('mousedown', mouseDownHandler );
				layer.off('click', mouseDownHandler );
			}
		};


		if (!ContextMenuManager.handlersInitialized) {
			$.contextMenu.op.show = customAfterShowEvent($.contextMenu.op.show);
			$.contextMenu.op.hide = customAfterHideEvent($.contextMenu.op.hide);
			ContextMenuManager.handlersInitialized = true;
		}
	};

	this.preprocessItems = function(items) {
		var key;

		for (key in items) {
			if (items.hasOwnProperty(key)) {
				items[key].isHtmlName = true;
			}

			if (items[key].hasOwnProperty("items")) {
				this.preprocessItems(items[key].items);
			}

		}

	}

	this.render = function() {
		if (options.hasOwnProperty("items")) {
			this.preprocessItems(options.items);
		}
		this.setTrigger();
		this.setAnimation();
		this.addCustomBeforeEvents();
		$.contextMenu(this.options);
		this.addCustomAfterEvents();
	};

}
