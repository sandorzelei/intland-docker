/**
 *
 */
var codebeamer = codebeamer || {};
codebeamer.initLayout = function (layoutContainerId, leftHeaderDivId, rightHeaderDivId, closerButtonId, layoutCookie, leftMinWidth, rightMinWidth, rightQuickOpenDisabled, disableCloserButtons, config, isPopup) {

	function init() {
		if (layoutContainerId) {

			var layoutContainer = $("#" + layoutContainerId);

			codebeamer.resizeHandler = function() {
				var p = $("#" + layoutContainerId);
				var mt = null;
				try {
					mt = $("div[class=messagetext]");
				} catch (e) {}

				// handling if the globalMessages is outside of the layout
				var $globalMessages = $("#globalMessages");
				var gmh = 0;
				if ($globalMessages.closest(".ui-layout-center").length > 0) {
					// console.log("The global-messages is inside the layout container, not doing anything");
				} else {
					gmh = $globalMessages.height();
				}

				var diff = 0;
				var west = $(".ui-layout-west");
				if (west && west.length > 0) {
					diff = $(".actionMenuBar").height() +  (mt != null && mt.height() != null && mt.height() != 0 ? mt.height() + 20 : 0)
						+ (gmh != null && gmh != 0 ? gmh + 20 : 0);
				}
				var h = $(window).height() - $(".ui-layout-south").height() - $(".ui-layout-north").height() - diff - 15;
				$(p).height(h);
				if (codebeamer.nestedLayouts && codebeamer.nestedLayouts.length > 0) {
//					codebeamer.nestedLayouts[0].resizeAll();
				}

				p.trigger("codebeamer.resizeEnd");
			};

			layoutContainer.css({"display": "block"});
			codebeamer.resizeHandler();
			$(window).resize(function() {
				throttle(codebeamer.resizeHandler, this, null, 350);
			});

			var maxSize = window.innerWidth ? window.innerWidth * 0.4 : 500;
			var layoutConfig = {
				"applyDefaultStyles": false,
				"resizeWithWindowDelay": 400,
				"resizerDblClickToggle" : false,
				"west": {
					"resizeWhileDragging": true,
					"spacing_closed": 1,
					"spacing_open": 1,
					"togglerLength_closed": 15,
					"togglerAlign_closed": "top",
					"togglerLength_open": 0,
					"slideTrigger_open": "click",
					"fxName_close": "slide",
					"enableCursorHotkey": false,
					"minSize": (typeof leftMinWidth === "number") ? leftMinWidth : 220,
					"maxSize": maxSize,
					"onresize": function () {
						layoutContainer.trigger("westResize");
					},
					"onopen_end": function () {
						layoutContainer.trigger("westOpen");
					},
					"onclose_end": function () {
						layoutContainer.trigger("westClose");
					}
				},
				"east": {
					"resizeWhileDragging": true,
					"enableCursorHotkey": false,
					"spacing_open": 1,
					"spacing_closed": rightQuickOpenDisabled ? 0 : 1,
					"minSize": (typeof rightMinWidth === "number") ? rightMinWidth : 220,
					"maxSize": maxSize,
					"onresize": function () {
						layoutContainer.trigger("eastResize");
					},
					"onopen_end": function () {
						layoutContainer.trigger("eastOpen");
					},
					"onclose_end": function () {
						layoutContainer.trigger("eastClose");
					}
				},
				"center": {
					"spacing_open": 0
				},
				"useStateCookie" : true,
				"showErrorMessages": false
			};

			if (layoutCookie) {
				var cookieConfig = {
					"name": layoutCookie,
					"path": "/",
					"secure": (location.protocol === 'https:')	// use the appropriate secure cookie to avoid IE warnings about mixed content
				};
				layoutConfig.cookie = cookieConfig;
			}

			if (config) {
				$.extend(true, layoutConfig, config);
			}

			var l = layoutContainer.layout(layoutConfig);
			if (!disableCloserButtons && leftHeaderDivId && leftHeaderDivId.length > 0) {
				codebeamer.addCloserButton(l, "closer-west", leftHeaderDivId, "west");
			}

			if (!disableCloserButtons && rightHeaderDivId && rightHeaderDivId.length > 0) {
				codebeamer.addCloserButton(l, "closer-east", rightHeaderDivId, "east");
			}

			// store the layout
			if ($.isArray(codebeamer.nestedLayouts)) {
				codebeamer.nestedLayouts.push(l);
			} else {
				codebeamer.nestedLayouts = [l];
			}

			$(document).ready(function () {
				if (leftHeaderDivId && leftHeaderDivId.length > 0) {
					codebeamer.addOpenerButton(l, "west");
				}
				if (rightHeaderDivId && rightHeaderDivId.length > 0) {
					codebeamer.addOpenerButton(l, "east");
				}
			});

			$(["west", "east"]).each(function() {
				var side = this;
				var panelHidden = $("#" + side).is(":visible") == false;
				layoutContainer.toggleClass(side + "PaneHidden", panelHidden);
			})
		}
	}

	if (isPopup) {
		window.parent.$("#inlinedPopupIframe").load(function() {
			init();
		});
	} else {
		$(document).ready(function () {
			init();
		});
	}
};

codebeamer.createLayoutToggleButtonHandler = function(button, side, isCloseEvent) {
	var container = $(button).closest(".ui-layout-container");
	return function() {
		if (isCloseEvent) {
			codebeamer.closeSideButton(side);
		} else {
			$('#opener-' + side).hide();
		}
		var customEventName = side + (isCloseEvent ? "Close" : "Open");
		container.toggleClass(side + "PaneHidden", isCloseEvent)
			.trigger(customEventName);
		return false;
	};
};

/**
 *
 * @param l
 * @param side east or west
 */
codebeamer.addOpenerButton = function(l, side) {
	if (!side) {
		side = "west";
	}
	var west = side === "west";
	var existingOpenerId = "#opener-" + side;
	var $existingOpener = $(existingOpenerId);
	if ($existingOpener && $existingOpener.length > 0) {
		var $leftPanel = $("#" + side);
		var hovering = $("#panes").layout().state.west.isSliding;
		if ($leftPanel && $leftPanel.is(":visible") && !hovering) {
			// hide the opener button if the panel is open (but keep it when its only hovering)
			$existingOpener.hide();
		} else {
			$existingOpener.show();
		}
		return;
	}
	var container = west ? $("#middleHeaderDiv") : $("#rightPane");
	var b = $("<span></span>")
		.attr({
			"id": "opener-" + side,
			"title": "Show panel",
			"onKeyPress": "return false;"
		}).click(codebeamer.createLayoutToggleButtonHandler(container, side, false));
	if (west) {
		b.appendTo(container);
	} else {
		b.prependTo(container);
	}
	l.addOpenBtn(b, side);

	if (!l.state[side].isClosed && !(l.state[side].isSliding && l.state[side].isVisible)) {
		b.hide();
	} else {
		b.show();
	}
};

codebeamer.closeSideButton = function (side) {
	$('#opener-container-' + side).hide();
	$('#opener-' + side).hide();
	$('#opener-container-' + side ).show();
	$('#opener-' + side ).show();
	$('#opener-container-' + side).attr('style', (side === "west" ? "left:16px;" : ""));
	return false;
};

codebeamer.addCloserButton = function(layout, closerButtonId, containerId, side) {
	if (!side) {
		side = "west";
	}

	var container = $("#" + containerId);

	var west = side === "west";
	var b = $("<span></span>")
		.attr({
			"id": closerButtonId,
			"title": "Hide tree",
			"onKeyPress": "return false;"
		}).click(codebeamer.createLayoutToggleButtonHandler(container, side, true));
	if (west) {
		b.appendTo(container);
	} else {
		b.prependTo(container);
	}

	var $closerButton = $("#" + closerButtonId);
	if ($closerButton && $closerButton.length > 0) {
		layout.addCloseBtn("#" + closerButtonId, side);
	}
};

