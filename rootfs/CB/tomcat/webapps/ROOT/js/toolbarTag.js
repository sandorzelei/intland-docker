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

/**
	Javascript used by ToolbarTag to render the top menubar and ActionMenuItem tag.
 */

function initPopupMenu(id, params, displayMenu) {
	var showMenu = new ShowMenu(id, params);
	showMenu.init(displayMenu);
	return showMenu;
}

function initInlineMenu(id, params) {
	var showMenu = new ShowMenu(id, params);
	showMenu.setupInlineMenu();
	showMenu.init();
}

function initTopMenu(id, params) {
	var showMenu = new ShowMenu(id, params);
	showMenu.setupTopMenu();
	showMenu.init();
}

function popupMenuLazyClickHandler($target) {
	var $menubar = $target.closest(".yuimenubar");
	if (!$menubar.is(".initialized")) {
		initPopupMenu($menubar.attr("id"), {}, true);
	}
}

/**
 * Class/Constructor to show/control the menu.
 */
function ShowMenu(id, params) {
	if (this == window) {
		// create new object
		return new ShowMenu(id, params);
	}

	this.id = id;
	this.params = params;

	this.menuLabel = $("#" + this.id);
	this.menu = $("#" + this.id + "popup ul");
	this.menuPopup = $("#" + this.id + "popup");

	this.isInlineMenu = false;
	this.isTopMenu = false;
}

ShowMenu.prototype = {

	ANIM_DURATION: 200, // ms

	init: function(displayMenu)
	{

		var id = this.id;
		var params = this.params;
		var menuPopup = this.menuPopup;
		menuPopup.hide();
		var menuLabel = this.menuLabel;

		menuLabel.addClass("initialized");

		// Arrow separator controls
		var currentMenuContainer = menuLabel.closest('.menuContainer');
		var arrowSeparator = currentMenuContainer.find('.arrowSeparator');
		currentMenuContainer.hover(function() {
			var bgColor = $(this).hasClass('currentTabCenter') && !$(this).hasClass('menuIsOpen') ? '#666666' : '#d1d1d1';
			arrowSeparator.css('background-color', bgColor);
		}, function() {
			arrowSeparator.css('background', 'none');
		});
		menuLabel.click(function() {
			arrowSeparator.css('background', 'none');
		});

		function getContext(params) {
			if (!params.hasOwnProperty('context')) {
				return menuLabel;
			}
			var el = params.context[0];
			// Check if jQuery object
			if (el instanceof $) {
				return el;
			}
			// Check if DOM element
			if (typeof HTMLElement === "object" ? el instanceof HTMLElement :
				el && typeof o === "object" && el !== null && el.nodeType === 1 && typeof el.nodeName==="string") {
				return $(el);
			}
			// Check if string
			if ($.type(el) == "string") {
				var $el = $('#' + el);
				return $el.length == 1 ? $el : menuLabel;
			}
			return menuLabel;
		}

		var context = getContext(params);
		var menuArrowDownButton = context.siblings('img.menuArrowDown').add(context.find('img.menuArrowDown')).first();
		if (menuArrowDownButton.length > 0) {
			context = menuArrowDownButton;
		}
		var layout = context.parents(".ui-layout-pane").first();
		if (layout.length == 0) {
			layout = $(window);
		}
		if (params.hasOwnProperty("ignoreLayout") && params["ignoreLayout"]) {
			layout = $(window);
		}

		// Planner position fixes
		var isPlanner = context.parents('#planner').length > 0;
		var isWithinPlannerSprints = isPlanner && context.parents('.sprints-accordion').length > 0;
		var isWithinPlannerCenter = isPlanner && context.parents('.center-pane').length > 0;
		if (isWithinPlannerCenter || isWithinPlannerSprints) {
			layout = $(window);
		}

		var isInlineMenu = this.isInlineMenu;
		var isTopMenu = this.isTopMenu;
		var menuContainer = menuLabel.closest(".menuContainer").addBack().first();
		menuContainer.css('cursor', 'pointer');

		var setTopMenuPosition = function() {
			var label = $("#" + id);
			var pos = label.offset();

			// Browser specific position alignment
			var browserSpecificPos = { top: 1, left: -1 };
			var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
			var isIE6or7 = $("body").hasClass("IE6or7");
			if (isFirefox) {
				browserSpecificPos.top = 1;
			}
			if (isIE6or7) {
				browserSpecificPos.left = -3;
			}

			menuPopup.css({
				position: 'absolute',
				top: (parseInt(pos.top, 10) + parseInt(label.height()) + browserSpecificPos.top) + 'px',
				left: (parseInt(pos.left) + browserSpecificPos.left) + 'px'
			});
		};

		this.menu.menu({
			create: function() {
				if (isTopMenu) {
					setTopMenuPosition();
				}
			}
		});

		var documentClickHandler = function() {
			hide();
		};

		var documentMouseDownHandler = function() {
			setTimeout(function() {
				hide();
			}, 1000);
		};

		var windowResizeHandler = function() {
			hide();
		};

		var bindHandlers = function() {
			$(document).on('click', documentClickHandler );
			if (!$('body').hasClass('IE8')) {
				$(document).on('mousedown', documentMouseDownHandler );
				$(window).on('resize', windowResizeHandler );
			}
		};

		var unbindHandlers = function() {
			$(document).off('click', documentClickHandler );
			if (!$('body').hasClass('IE8')) {
				$(document).off('mousedown', documentMouseDownHandler );
				$(window).off('resize', windowResizeHandler );
			}
		};

		var callCallbackFunction = function() {
			var callbackFunctionName = menuContainer.data("js-callback-function-after-show");
			var argumentString = menuContainer.data("js-callback-function-after-show-args");
			if (callbackFunctionName) {
				var menu = $("#" + id + "popup");
				window[callbackFunctionName].call(menu, argumentString);
			}
		};

		var show = function() {
			fixMenuPosition();
			fixContentAreaLayout(false);
			menuPopup.fadeIn(ShowMenu.prototype.ANIM_DURATION, function() {
				fixMenuPosition();
				fixContentAreaLayout(true);
				bindHandlers();
			});
			menuLabel.closest(".version").addClass("menu-open");
			menuPopup.css('visibility', 'visible');
			showMenuArrowButton();
			if (isInlineMenu) {
				callCallbackFunction();
			}
			if (isTopMenu) {
				menuContainer.addClass('menuIsOpen');
			}
		};

		var hide = function() {
			menuPopup.fadeOut(ShowMenu.prototype.ANIM_DURATION, function() {
				unbindHandlers();
				resetMenuArrowButtonVisibility();
				menuLabel.closest(".version").removeClass("menu-open");
				if (isInlineMenu) {
					menuPopup.css('visibility', 'hidden');
				}
				if (isTopMenu) {
					menuContainer.removeClass('menuIsOpen');
				}
			});
		};

		// Note: in Chrome in some cases layout is broken, a placeholder of the vertical scrollbar appears if
		// action menu is opening in the right side of the page. This fix set the width of the pane's
		// "contentArea" div to 100% to avoid the scrollbar placeholder (restore = false), then after menu is shown
		// it removes the 100% width value from the div (restore = true).
		var fixContentAreaLayout = function(restore) {
			if (window.chrome) {
				var contentArea = context.parents(".ui-layout-pane").first().find('div.contentArea').first();
				if (contentArea.length > 0) {
					var width = restore ? '' : '100%';
					contentArea.css('width', width);
				}
			}
		};

		// Note: if context menu is within planner sprints area, menu position is not always correct
		var fixMenuPosition = function() {
			if (isWithinPlannerSprints || isWithinPlannerCenter) {
				menuPopup.find('.bd').position(getMenuPosition());
			}
		};

		// Note: IE8 not always hides other context menus, force hiding them
		var hideOtherMenus = function() {
			if ($('body').hasClass('IE8')) {
				$('.yuimenu').each(function() {
					$(this).hide();
					$(this).parent().find('img.menuArrowDown').css('visibility', '');
				});
			}
		};

		var showMenuArrowButton = function() {
			menuLabel.find('img.menuArrowDown').css('visibility', 'visible');
		};

		var resetMenuArrowButtonVisibility = function() {
			menuLabel.find('img.menuArrowDown').css('visibility', '');
		};

		var getMenuPosition = function() {
			return {
				my : "left top",
				at : "left bottom",
				of : context.length ? context : undefined,
				collision : params.ignoreCollision ? "none" : "flipfit",
				within : layout
			};
		};

		var updateMenuPositionWithDataAttributes = function($element, menuPosition) {
			var $link = $element.find("a");

			if ($link.data("my")) {
				menuPosition.my = $link.data("my");
			}

			if ($link.data("at")) {
				menuPosition.at = $link.data("at");
			}
		}

		var clickHandler = function(e) {
			if (e && $(e.target).hasClass("displayTitleWrapper")) {
				e.preventDefault();
			}
			if (isTopMenu) {
				setTopMenuPosition();
			}
			if (!menuPopup.is(':visible')) {
				if (!isTopMenu) {
					var menuPosition = getMenuPosition();

					updateMenuPositionWithDataAttributes($(e.currentTarget), menuPosition);

					var inPlanner = isWithinPlannerSprints || isWithinPlannerCenter;
					hideOtherMenus();
					if (!inPlanner) {
						menuPopup.show();
					}
					// Planner sprint menu position fix
					if (inPlanner) {
						// set overflow hidden to avoid unnecessary scrollbar
						$('#rightPane').css('overflow', 'hidden');
					} else {
						menuPopup.position(menuPosition);
					}
					menuPopup.find('.bd').position(menuPosition);
					menuPopup.hide();
				}
				show();
			}
		};

		menuLabel.click(clickHandler);

		if (displayMenu) {
			clickHandler({ currentTarget: this.menuLabel[0] });
		}
	},

	setupInlineMenu: function() {
		this.isInlineMenu = true;
	},

	setupTopMenu: function() {
		this.isInlineMenu  = true;
		this.isTopMenu = true;
		this.menuLabel = $("#" + this.id).find('img.menuArrowDown');
		this.menuPopup.children('div').children('ul').children('li').first().addClass('first-of-type');
	}

};

function getToolbarTab(menuHtmlId) {
	var el = $('#' + menuHtmlId).closest('.toolbarTab').get(0);

	// moving the toolbar menus outside of the jquery-layout because that is causing z-index problems and menus jumping randomly
	// create the container for toolbar menus if it is not there yet
	if ($("#toolbarMenus").length == 0) {
		$(document.body).append("<div id='toolbarMenus'></div>");
	}
	$('#' + menuHtmlId + "popup").appendTo("#toolbarMenus");
	return el;
}

/**
 * builds the transition menu for a tracker item.
 *
 * @param $menuContainer the dom element to append the downloaded menu to
 * @param args accepts only a subset of the ActionMenuTag arguments
 */
function buildAjaxTransitionMenu($menuContainer, args) {
	buildInlineMenu($menuContainer, '/trackers/ajax/trackerItemMenu.spr', args);
}

/**
 * Builds an inline AJAX menu
 * @param $menuContainer the dom element to append the downloaded menu to
 * @param url AJAX url
 * @param args accepts only a subset of the ActionMenuTag arguments
 */
function buildInlineMenu($menuContainer, url, args) {
	if ($menuContainer.is(".menu-downloaded")) {
		$menuContainer.find(".yuimenubar.dynamic-menu").click();
	} else {
		$.get(contextPath + url, args).done(function (data) {
			var $menubar = $(data.menu);
			$menubar.addClass("dynamic-menu");
			$menuContainer.append($menubar);
			$menuContainer.addClass("menu-downloaded");
			popupMenuLazyClickHandler($menubar);
			$menuContainer.trigger("codebeamer.menuloaded");
		});
	}
}

function buildInlineMenuFromJson($menuContainer, selector, args, within) {
	if (!$menuContainer.is('.menu-downloaded')) {
		$menuContainer.data("taskId", args["task_id"]);
		var taskId = args["task_id"];
		var menuBuildFunction = createMenuBuildFunction($menuContainer);
		downloadMenu(selector, args, menuBuildFunction, $menuContainer, within);
	}
}

function downloadMenu(selector, args, menuBuildFunction, $menuContainer, within) {
	$.get(contextPath + '/trackers/ajax/trackerItemMenuAsJson.spr', args).done(function (data) {

		if (data["items"]) { // if the menu is empty do nothing
			$menuContainer.data("menujson", data);
			var menuOptions = {
				selector: selector,
				build: menuBuildFunction,
				trigger: "left"
			};
			if (within) {
				var position = {
					within : within
				};

				menuOptions['customPosition'] = position;
			}

			var contextMenu = new ContextMenuManager(menuOptions);
			contextMenu.render();
			$menuContainer.addClass("menu-downloaded");
			$menuContainer.click();
		}
	});
}

function createMenuBuildFunction($menuContainer) {
	return function ($trigger, event) {
		var taskId = $trigger.closest(".menu-downloaded").data("taskId");
		var _data = $trigger.data("menujson");
		if (_data) {
			preprocessItems(_data.items);
			addSeparators(_data.items);
			computeCallbacks(_data.items, taskId);
		}

		return _data;
	}
}

function preprocessItems(items) {
	var key, menuItem, iconUrl, html;

	for (key in items) {
		if (items.hasOwnProperty(key)) {
			menuItem = items[key];

			if (menuItem && menuItem.hasOwnProperty("icon") && menuItem.icon && !$.isFunction(menuItem.icon)) {
				menuItem.iconUrl = menuItem.icon;

				menuItem.icon = function (opt, $itemElement, itemKey, item) {
					var iconUrl;

					if ($itemElement.find("img").size() === 0) {
						iconUrl = item.iconUrl;

						if (iconUrl.indexOf(contextPath) < 0) {
							iconUrl = contextPath + iconUrl;
						}

						html = '<img class="tableIcon" src="';
						html = html.concat(iconUrl);
						html = html.concat('"');
						if (item.hasOwnProperty("iconBgColor") && item.iconBgColor) {
							html = html.concat(' style="background-color: ')
							html = html.concat(item.iconBgColor)
							html = html.concat(';"');
						}
						html = html.concat('></img>');
						$itemElement.prepend(html);
						result = "icon-added";
					}

					return "";
				};
			}

			menuItem.isHtmlName = true;
		}
	}

}

function addSeparators(items) {
	for (var key in items) {
		var item = items[key];
		if (item.separator) {
			items[key] = item.name;
		}

		if (item.items) {
			addSeparators(item.items);
		}
	}
}

function computeCallbacks(items, id) {
	for (var key in items) {
		var item = items[key];

		if (item.onClick) {
			item.callback = createCallbackFromOnClick(item.onClick, id, item.attributes);
		} else if (item.url) {
			item.callback = createOverlayFunction(item.url);
		}

		if (item.items) {
			computeCallbacks(item.items, id, item.attributes);
		}
	}
}

function createCallbackFromOnClick(onClick, id, attributes) {
	return function () {
		var functionName, functionAttributes;
		if (onClick.indexOf(".") < 0) {
			window[onClick](id, attributes);
		} else {
			if (onClick.indexOf("(") > 0) {
				if (onClick.indexOf("return") > 0) {
					eval(onClick.substring(0, onClick.indexOf("return")));
				} else {
					eval(onClick);
				}
			} else {
				var parts = onClick.split(".");

				var func = window[parts[0]];
				for (var i = 1; i < parts.length; i++) {
					func = func[parts[i]];
				}

				func(id, attributes);
			}

		}

	}
}

function createOverlayFunction(url) {
	return function () {
		showPopupInline(url, {geometry: 'large'});
	}
}

