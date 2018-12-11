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
 */

/*  dashboard related functionality */

var codebeamer = codebeamer || {};
codebeamer.dashboard = codebeamer.dashboard || (function($) {

	var actualRequest = null;

	var config = {};

	/**
	 * initializes the dashboard based on the configuration.
	 *
	 * @param config the configuration object
	 * 		config.dashboardId: the dashboard id
	 * 		config.projectId: the project of the dashboard (or empty if this is a toplevel dashboard)
	 * 		config.$container: the dome element to load the dashboard to
	 */
	var init = function (options) {
		config = options;
		setUpEventHandlers(config);
		loadDashboard(config);
		initializeContextMenus();
		initializeRefreshButton();
		initializePasteButton();

		startWidgetHeightMonitor();

		$(document).on("beforeCloseInlinePopup", function(event, action) {
			if (action && action.hasOwnProperty("executeJS") && action.executeJS === "codebeamer.dashboard.showEditorErrorNotification") {
				showEditorErrorNotification();
			}
		});
	};

	var initWikiPageLoadingIndicator = function(loadingIndicatorContainer, dashboardContainer) {
		var busySignHTML;

		busySignHTML = ajaxBusyIndicator.getBusysignHTML('', false);
		$(loadingIndicatorContainer).append(busySignHTML);

		$(dashboardContainer).one("dashboard:loading:finished", function() {
			$(loadingIndicatorContainer).remove();
		});
	};

	/**
	 * loads the dashboard through ajax.
	 */
	var loadDashboard = function () {
		var showBusyPage = true;
		if (config.hasOwnProperty("showBusyPage") && !config.showBusyPage) {
			showBusyPage = false;
		}

		var bs = null;
		if (showBusyPage) {
			bs = ajaxBusyIndicator.showBusyPage();
		}

		var parameters = {
				dashboardId: config.dashboardId,
				projectId: config.projectId
			};

		if (config.parameters) {
			$.extend(parameters, config.parameters);
		}


		if (actualRequest) {
			actualRequest.abort();
		}

		actualRequest = $.get({
			url: contextPath + '/dashboard/retrieve.spr' + location.search,
			data: parameters,
			cache: false
		}).done(function (response) {
			config.$container.html(response);

			if (config.hasOwnProperty("editable") && config.editable) {
				$(".dashboard-container").addClass("editable");
				initializeDnd(config);
			}

			// initialize the wiki plugin jsp scripts
			initializeMinimalJSPWikiScripts(config.$container);
		}).fail(function (response) {
			config.$container.html(response.responseText);
			console.log(response);
		}).always(function () {
			actualRequest = null;

			if (bs) {
				bs.remove();
			}

			config.$container.trigger("dashboard:loading:finished");
		});
	};

	var editWidget = function (widgetId) {
		var editUrl = contextPath + "/dashboard/widgetEditor.spr?dashboardId=" + config.dashboardId + "&widgetId=" + widgetId;
		showPopupInline(editUrl, {'geometry': 'large', 'afterLoad': function (event, ui) {
			alignLabels($("iframe#inlinedPopupIframe").contents());
		}});
	};

	/**
	 * initializes the widget context menus
	 */
	var initializeContextMenus = function () {
		var items = {};

		if (config.editable) {
			$.extend(items, {
				'edit' : {
					name: i18n.message('button.edit'),
					callback: function(key, options) {
						var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');
						editWidget(widgetId);
					}
				}
			});
		}

		$.extend(items, {
			'refresh': {
				name: i18n.message('dashboard.widget.refresh.label'),
				className: "refreshMenuItem",
				callback: function (key, options) {
					var $widget = $(options.$trigger).closest('.widget-container');
					var widgetId = $widget.data('widgetId');
					refreshWidget(widgetId);
				}
			},
			'copy' : {
				name: i18n.message('button.copy'),
				callback: function(key, options) {
					var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');
					copyWidget(widgetId);
				}
			}
		});

		if (config.editable) {
			$.extend(items, {
				'cut' : {
					name: i18n.message('button.cut'),
					callback: function(key, options) {
						var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');
						cutWidget(widgetId);
					}
				},
				'edit' : {
					name: i18n.message('button.edit'),
					callback: function(key, options) {
						var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');
						editWidget(widgetId);
					}
				},
				'delete' : {
					name: i18n.message('button.delete'),
					callback: function(key, options) {
						var $widget = $(options.$trigger).closest('.widget-container');
						var widgetId = $widget.data('widgetId');

						showFancyConfirmDialogWithCallbacks(i18n.message('dashboard.widget.delete.label'), function() {
							$.get(contextPath + '/dashboard/removeWidget.spr', {
								'dashboardId': config.dashboardId,
								'widgetId': widgetId
							}, function (data) {
								if (data.success) {
									showOverlayMessage();
									$widget.remove();
								} else {
									showOverlayMessage(i18n.message('dashboard.widget.delete.error.label'), 5, true);
								}

							}).error(function (response) {
								showOverlayMessage(response, 3, true);
							});
						});
					}
				},
				'pin': {
					name: i18n.message("dashboard.pin.label"),
					callback: function (key, options) {
						showFancyConfirmDialogWithCallbacks(i18n.message('dashboard.widget.unpin.confirm.label'), function() {
							var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');
							pinWidget(widgetId);
						});
					},
					disabled: function (key, opt) {
						if($(opt.$trigger).closest('.dashboard-column').is('.pinned')){
			                return true;
			            }

						return false;
					},
					className: "pin-menu"
				},
				'unpin': {
					name: i18n.message("dashboard.unpin.label"),
					callback: function (key, options) {
						var widgetId = $(options.$trigger).closest('.widget-container').data('widgetId');

						unpinWidget(widgetId);
					},
					disabled: function (key, opt) {
						if(!$(opt.$trigger).closest('.dashboard-column').is('.pinned')){
			                return true;
			            }

						return false;
					},
					className: "pin-menu"
				}
			});
		}

		// Clean up previous instances in case of ajax reload (switching dashboards using the tree.)
		$.contextMenu("destroy");

		var contextMenu = new ContextMenuManager({
			selector: '.widget-title .menuArrowDown',
			items:  items,
			trigger: "left"
		});
		contextMenu.render();
	};

	var unpinWidget = function (widgetId) {
		pinUnpinWidget(widgetId, false);
	};

	var pinWidget = function (widgetId) {
		pinUnpinWidget(widgetId, true);
	};

	var pinUnpinWidget = function (widgetId, pinned) {
		$.post(contextPath + '/dashboard/pinUnpinWidget.spr', {
			'dashboardId': config.dashboardId,
			'widgetId': widgetId,
			'pinned': pinned
		}, function (data) {
			if (data.success) {
				showOverlayMessage();
				loadDashboard();
			} else {
				showOverlayMessage(i18n.message('dashboard.widget.delete.error.label'), 5, true);
			}

		}).error(function (response) {
			showOverlayMessage(response, 3, true);
		});
	};

	var initializeRefreshButton = function () {
		$("body").off("dashboard:refresh");
		$("body").on("dashboard:refresh", function() {
			var $widgets = $("#dashboard .widget-container");

			$widgets.each(function() {
				var widgetId = $(this).data('widgetId');
				setTimeout(function() {
					refreshWidget(widgetId);
				}, 10);
			});
		});
	};

	var initializePasteButton = function () {
		$("body").off("dashboard:paste");
		$("body").on("dashboard:paste", function() {
			$.get({
				url: contextPath + '/dashboard/pasteWidget.spr',
				data: {
					dashboardId: config.dashboardId
				},
				cache: false
			}).done(function (response, textStatus, jqXhr) {
				var $newWidget

				$("body").trigger("dashboard:paste:done");

				// The same dashboard changed after a cut operation, reload to refresh all the content including the deleted widget.
				if (jqXhr.status === 201) {
					loadDashboard();
				} else {
					$newWidget = $(response);
					$(".dashboard-column:not(.pinned)").first().prepend($newWidget);
					flashChanged($newWidget);
					showOverlayMessage(i18n.message('dashboard.widget.paste.success.label'), 5, false, false);
				}

			}).fail(function (jqXhr) {
				if (jqXhr.status === 403) {
					showOverlayMessage(i18n.message('dashboard.widget.copy.paste.permission.label'), 5, true);
				} else {
					if (jqXhr.status === 404) {
						showOverlayMessage(i18n.message('dashboard.widget.paste.no.widget.label'), 5, true);
					} else {
						showOverlayMessage(i18n.message('dashboard.widget.paste.failed.label'), 5, true);
					}
				}
			});
		});
	};

	/**
	 * initialized the DND on widgets.
	 */
	var initializeDnd = function () {
		var handleUpdate = function (event, ui) {
			// the widget container was dropped to a new position
			var $widget = $(ui.item);
			var widgetId = $widget.data('widgetId');
			var dashboardId = $widget.data('dashboardId');

			// find the new column and row number
			var $newColumn = $widget.parents('.dashboard-column');
			var columnNumber = $('.dashboard-column.ui-sortable').index($newColumn)
			var rowNumber = $newColumn.children('.widget-container').index($widget);

			$.get(contextPath + '/dashboard/moveWidget.spr', {
				dashboardId: dashboardId,
				widgetId: widgetId,
				columnNumber: columnNumber,
				rowNumber: rowNumber,
				projectId: config.projectId
			}).done(function () {
				showOverlayMessage();
			}).fail(function () {
				//showOverlayMessage("error when moving widget", 5,true);
			}).always(function() {
				loadWidgetsAfterMovingWidget();
			});
		};

		 var dragstart = function (event, ui) {
			// add the hint to the DND placeholder
			var $placeholder = $('.ui-state-highlight');

			var $hint = $("<span>").html(i18n.message('dashboard.widget.dragdrop.label'));

			$placeholder.append($hint);

			$(".column-footer").trigger("dashboard:hideFooter");

			equalizeColumnHeight();
		};

		var dragStop = function (event, ui) {
			var $column, $widgetContainers;

			$column = ui.item.closest(".dashboard-column");
			$widgetContainers = $column.find(".widget-container");

			// Move the column footer after the widget if the target column was empty before the dnd.
			if ($widgetContainers.size() === 1) {
				$column.find(".column-footer").detach().appendTo($column).css({"display": "block"});
			}

		};

		$(".dashboard-column:not(.pinned)").sortable({
			connectWith: '.dashboard-column',
			items: '.widget-container:not(.full-width)',
			handle: '.widget-title',
			cancel: '.menuArrowDown', // disable dragging by the menu icon
			placeholder: 'ui-state-highlight dnd-placeholder',
			update: function (event, ui) {
				// Prevent handling the event twice.
				// connectWith options causes the update event two fire multiple times.
				// Handle only the drop from one column to another column.
				if (this === ui.item.parent()[0]) {
					handleUpdate(event, ui);
				}
			},
			start: dragstart,
			helper: function (event, element) {
				return element.find(".widget-title").clone();
			},
			stop: dragStop,
			tolerance: "pointer"
		});

	};

	/**
	 * sets up the event handlers on the page;
	 */
	var setUpEventHandlers = function () {
		var $context = $(document);
		if ($context.data("eventsInitialized")) {
			return;
		}

		$context.on('click', '.layout-button', function (event) {
			var $button = $(this);
			var layoutType = $button.data('layoutType');

			$.get(contextPath + '/dashboard/resize.spr', {
				dashboardId: config.dashboardId,
				layoutType: layoutType
			}).done(function () {
				$('.layout-button.actual-layout').removeClass("actual-layout");
				$button.addClass("actual-layout");
				showOverlayMessage();
				loadDashboard();
			}).fail(function () {
				showOverlayMessage(i18n.message('dashboard.widget.layout.error.label'), 5, true);
			});
		}).on('click', 'a.addWidget', function () {
			var url = contextPath + '/dashboard/widgetPicker.spr?dashboardId=' + config.dashboardId;
			showPopupInline(url, {'geometry': 'large'});
		}).on('click', '.editInOverlayIcon', function () {
			var widgetId = $(this).closest(".widget-container").data("widgetId");
			editWidget(widgetId);
		});

		if (config.editable) {
			$context.on('dblclick', '.dashboard-name', function () {
				// the inline editor for the dashboard name
				var $label = $(this);
				initializeNameEditor($label);

			}).on('click', '.dashboard-name .inplaceEditableIcon', function () {
				var $dashboardName = $(this).closest('.dashboard-name');
				initializeNameEditor($dashboardName);
			});

			initializeColumnFooters($context);
		}

		$context.data("eventsInitialized", true);
	};

	var showOrHideColumnFooter = function($column, show) {
		var $lastWidget, $visibleDndPlaceholders;

		if (show) {
			// Do not show these footers when there is an active dnd operation
			$visibleDndPlaceholders = $('.ui-state-highlight').filter(":visible");
			if ($visibleDndPlaceholders.size() === 0) {
				$column.find(".column-footer").trigger("dashboard:showFooter");
			}
		} else {
			$column.find(".column-footer").trigger("dashboard:hideFooter");
		}
	}

	var initializeColumnFooters = function($context) {

		function getNumberOfWidgets($columnFooter) {
			var column, widgetContainers;

			column = $columnFooter.closest(".dashboard-column");
			widgetContainers = column.find(".widget-container");

			return widgetContainers.length;
		}

		$context.on("click", ".column-footer", function() {
			var classes, i, columnNumber, url, column, widgetContainers;

			column = $(this).closest(".dashboard-column");
			widgetContainers = column.find(".widget-container");
			classes = column.attr("class").split(" ");

			columnNumber = 0;
			for (i = 0; i < classes.length; i++) {
				if (classes[i].indexOf("column-") === 0) {
					columnNumber = parseInt(classes[i].substring(7), 10);
				}
			}

			url = contextPath + '/dashboard/widgetPicker.spr?dashboardId='
					+ config.dashboardId + "&columnNumber=" + columnNumber.toString()
					+ "&rowNumber=" + (widgetContainers.size() === 0 ? "0" : widgetContainers.size().toString());
			showPopupInline(url, {'geometry': 'large'});
		});

		$context.on("mouseenter", ".dashboard-column", function() {
			showOrHideColumnFooter($(this), true);
		});

		$context.on("mouseleave", ".dashboard-column", function() {
			showOrHideColumnFooter($(this), false);
		});

		$context.on("dashboard:showFooter", ".column-footer", function() {
			var	$this = $(this);

			if ($this.is(":hidden")) {
				$this.show();
			} else {
				$this.css("visibility", "visible");
			}

		});

		$context.on("dashboard:hideFooter", ".column-footer", function() {
			var $this = $(this);

			if (getNumberOfWidgets($this) === 0) {
				$this.hide();
			} else {
				$this.css("visibility", "hidden");
			}
		});
	}

	var initializeNameEditor = function ($dashboardName) {
		var $input = $("<input>", {"class": "inline-edit-field", "value": $dashboardName.data("unescaped"), "type": "text"});
		$dashboardName.hide();
		$dashboardName.after($input);
		$input.focus();

		$input.keyup(function (event) {
			if (event.keyCode == jQuery.ui.keyCode.ENTER) {
				var name = $.trim($input.val());

				updateDashboard({
					name: name,
					dashboardId: config.dashboardId
				}, function (data) {
					$dashboardName.find("span").html(data["name"]);
					$dashboardName.data("unescaped", data["name"]);
					$input.remove();
					$dashboardName.show();
					showOverlayMessage();
				});
			} else if (event.keyCode == jQuery.ui.keyCode.ESCAPE) {
				$input.remove();
				$dashboardName.show();
			}
		});
	};

	var startWidgetHeightMonitor = function() {
		window.dashboardMonitorProcessId = setInterval(function() {
			var isRefreshRequired = false;

			$(".widget-container.loaded").each(function(index, element) {
				var $element = $(element);

				if ($element.data("height") !== $element.height()) {
					$element.data("height", $element.height());
					isRefreshRequired = true;
				}

			});

			if (isRefreshRequired) {
				$.waypoints("refresh");
			}

		}, 2000);
	};

	var updateDashboard = function (params, success) {
		$.ajax(contextPath + "/dashboard/update.spr", {
			"type": "POST",
			"data": params,
			"success": success
		}).fail(function (response) {
			showOverlayMessage(response.responseText, 5, true);
		});
	}

	var refreshWidget = function (widgetId, opts) {
		var $widgetContainer = $("[data-widget-id=" + widgetId + "]");

		var bs;

		if (!opts || (opts && opts.hasOwnProperty("showLoadingIndicator") && opts.showLoadingIndicator)) {
			bs = ajaxBusyIndicator.showBusysign($widgetContainer, i18n.message('ajax.loading'));
		}

		// Pass the detailed_layout parameter of the Tracker List Plugin (8.1 backward compatibility)
		var trackerListDetailedLayout = getUrlParameter("detailed_layout") == "true";
		var additionalUrlParams = trackerListDetailedLayout ? "?detailed_layout=true" : "";

		$.get({
			url: contextPath + '/dashboard/widget.spr' + additionalUrlParams,
			data: {
				dashboardId: config.dashboardId,
				widgetId: widgetId,
				revision: config.revision ? config.revision : null
			},
			cache: false
		}).done(function (response) {
			$widgetContainer.replaceWith(response);
			initializeMinimalJSPWikiScripts($widgetContainer);
			$widgetContainer = 	$("[data-widget-id=" + widgetId + "]");
			$widgetContainer.addClass("loaded");
			$widgetContainer.data("height", $widgetContainer.height());
		}).fail(function () {
			var $error = $("<div>", {"class": "error"}).html(i18n.message('dashboard.permission.ui.error'));
			$widgetContainer.html($error);
		}).always(function () {
			if (bs) {
				bs.remove();
			}
			if (opts && opts.hasOwnProperty("always")) {
				opts.always();
			}
		});
	};

	function copyWidget(widgetId, opts) {
		var $widgetContainer;

		$widgetContainer = $("[data-widget-id=" + widgetId + "]");

		$.get({
			url: opts && opts.hasOwnProperty("path") ? opts.path : contextPath + '/dashboard/copyWidget.spr',
			data: {
				dashboardId: config.dashboardId,
				widgetId: widgetId
			},
			cache: false
		}).done(function (response) {
			showOverlayMessage(opts && opts.hasOwnProperty("successLabel") ? opts.successLabel : i18n.message('dashboard.widget.copy.label'), 5, false, false);
			$("body").trigger("dashboard:copy:done");
		}).fail(function (jqXhr) {
			if (jqXhr.status === 403) {
				showOverlayMessage(opts && opts.hasOwnProperty("permissionFailureLabel") ? opts.permissionFailureLabel : i18n.message('dashboard.widget.copy.paste.permission.label'), 5, true);
			} else {
				showOverlayMessage(opts && opts.hasOwnProperty("failureLabel") ? opts.failureLabel : i18n.message('dashboard.widget.copy.failed.label'), 5, true);
			}
		});
	}

	function cutWidget(widgetId) {
		copyWidget(widgetId, {
			path: contextPath + '/dashboard/cutWidget.spr',
			successLabel: i18n.message('dashboard.widget.cut.label'),
			failureLabel: i18n.message('dashboard.widget.cut.failed.label')
		});
	}

	function copyWidget(widgetId, opts) {
		var $widgetContainer;

		$widgetContainer = $("[data-widget-id=" + widgetId + "]");

		$.get({
			url: opts && opts.hasOwnProperty("path") ? opts.path : contextPath + '/dashboard/copyWidget.spr',
			data: {
				dashboardId: config.dashboardId,
				widgetId: widgetId
			},
			cache: false
		}).done(function (response) {
			showOverlayMessage(opts && opts.hasOwnProperty("successLabel") ? opts.successLabel : i18n.message('dashboard.widget.copy.label'), 5, false, false);
			$("body").trigger("dashboard:copy:done");
		}).fail(function (jqXhr) {
			if (jqXhr.status === 403) {
				showOverlayMessage(opts && opts.hasOwnProperty("permissionFailureLabel") ? opts.permissionFailureLabel : i18n.message('dashboard.widget.copy.paste.permission.label'), 5, true);
			} else {
				showOverlayMessage(opts && opts.hasOwnProperty("failureLabel") ? opts.failureLabel : i18n.message('dashboard.widget.copy.failed.label'), 5, true);
			}
		});
	}

	function cutWidget(widgetId) {
		copyWidget(widgetId, {
			path: contextPath + '/dashboard/cutWidget.spr',
			successLabel: i18n.message('dashboard.widget.cut.label'),
			failureLabel: i18n.message('dashboard.widget.cut.failed.label')
		});
	}

	function isElementInViewport(el) {

	    if (typeof jQuery === "function" && el instanceof jQuery) {
	        el = el[0];
	    }

	    var rect = el.getBoundingClientRect();

	    return (
	        rect.top >= 0 &&
	        rect.left >= 0 &&
	        rect.bottom <= (window.innerHeight || $(window).height()) &&
	        rect.right <= (window.innerWidth || $(window).width())
	    );
	};

	function loadWidget(widgetId) {

		refreshWidget(widgetId, {
			always: function() {

				var nextWidgets, waypointConfig, currentWidget;

				currentWidget = $("div[data-widget-id=" + widgetId + "]")
				nextWidgets = currentWidget.next(".widget-container");
				// If there is a pinned widget on the dashboard, then try to find the first widget, which is not pinned
				if (currentWidget.parent().hasClass("pinned")) {
					nextWidgets = $(".dashboard-column:not(.pinned) .widget-container:first-child");
				}

				 $('.dashboard-column.ui-sortable').sortable("refresh");

				 nextWidgets.each(function(index, element) {
					var nextWidgetId, nextWidget;

					nextWidget = $(element);
					nextWidgetId = nextWidget.data("widget-id");

					if (isElementInViewport(nextWidget)) {
						loadWidget(nextWidgetId);
					} else {
						nextWidget.waypoint("destroy");

						if (nextWidget.scrollParent()[0] == document) {
						    waypointConfig = {
								offset: "90%",
								handler: function() {
									loadWidget(nextWidgetId);
									$("[data-widget-id=" + nextWidgetId + "]").waypoint("destroy");
								}
							};
						} else {
						    waypointConfig = {
						        context: nextWidget.scrollParent(),
								offset: "90%",
								handler: function() {
									loadWidget(nextWidgetId);
									$("[data-widget-id=" + nextWidgetId + "]").waypoint("destroy");
								}
							};
						}

						nextWidget.waypoint(waypointConfig);
					}
				});
			}
		});
	};

	function equalizeColumnHeight() {
		function findLongestColumnHeight() {
			var maxHeight;

			maxHeight = 0

			$(".dashboard-column").each(function(index, element) {
				var elementHeight = $(element).height();
				if (maxHeight <= elementHeight) {
					maxHeight = elementHeight;
				}
			});

			return maxHeight;
		}

		var maxHeight = findLongestColumnHeight();
		$(".dashboard-column:not(.pinned)").each(function(index, element) {
			if ($(element).height() < maxHeight) {
				$(element).css("min-height", maxHeight + "px");
			}
		});
	};

	// After moving a big widget others might be revealed in the column you are moving the widget from.
	// This method takes care of them, so the dynamic loading works just like before moving any widgets from the column.
	function loadWidgetsAfterMovingWidget() {
		var column, nextWidget;

		$.waypoints("destroy");

		$('.dashboard-column.ui-sortable').each(function(index, element) {
			column = $(".column-" + index);
			nextWidget = column.find(".widget-container:has(.loaderImage)");
			if (nextWidget.size() !== 0) {
				loadWidget($(nextWidget).data("widget-id"));
			}
		});
	};

	function addWidget(html, columnNumber, isFirst) {
		var $column, $firstWidgetContainer, $newWidget;

		if (html && jQuery.isNumeric(columnNumber)) {
			$column = $('.dashboard-column.ui-sortable').get(columnNumber);

			if ($column) {

				$firstWidgetContainer = $($column).find(".widget-container").first();
				$newWidget = $(html);

				if (isFirst && $firstWidgetContainer.size() > 0) {
					$firstWidgetContainer.before($newWidget);
				} else {
					$($column).find(".column-footer").before($newWidget);
				}

				codebeamer.common._scrollToElement($newWidget);
				flashChanged($newWidget);
			}
		}

	};

	function updateFormAlignment(maxWidth) {
		var formFieldWidth, labelWidth, inputWidth;

		alignLabels();

		formFieldWidth = $(".form-field").width();
		labelWidth = $(".form-field label").outerWidth();

		inputWidth = formFieldWidth - labelWidth - 15;

		if ($.isNumeric(maxWidth) && inputWidth > maxWidth) {
			inputWidth = maxWidth;
		}

		$(".form-field input[type=text]").not("input[readonly=readonly]").css("width", inputWidth);
		$("span.hint").css("max-width", inputWidth - 10);
		$(".form-field select").css("width", inputWidth);
		$(".form-field button.ui-multiselect").css("width", inputWidth).css("min-width", inputWidth);
		$(".ui-multiselect-menu.ui-widget-content").css("min-width", inputWidth).css("width", inputWidth);
		$(".chartSelector").css("max-width", inputWidth - 10);
		$(".color-editor-container").css("max-width", inputWidth - 10);
		$(".form-field .auto-width").css("width", inputWidth);

	};

	function showEditorErrorNotification() {
		showOverlayMessage(i18n.message("dashboard.widget.not.found.editor"), 5, false, true);
	};

	return {
		"init": init,
		"initWikiPageLoadingIndicator": initWikiPageLoadingIndicator,
		"loadDashboard": loadDashboard,
		"refreshWidget": refreshWidget,
		"loadWidget": loadWidget,
		"addWidget": addWidget,
		"updateFormAlignment": updateFormAlignment
	};
}(jQuery));

