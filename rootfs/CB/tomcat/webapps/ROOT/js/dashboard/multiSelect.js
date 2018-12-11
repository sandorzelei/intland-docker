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
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.multiSelect = codebeamer.dashboard.multiSelect || (function($) {

	function clear(elementId) {
		var $element = $("#" + elementId);
		$element.empty();
		$element.multiselect("refresh");
	};

	function refreshSelection(elementId, eventName) {
		var checked = [];

		$("#" + elementId).multiselect("refresh");
		$("#" + elementId).multiselect("getChecked").each(function() {
			checked.push($(this).val());
		});
		$("#" + elementId).data("checked", checked);

		$("body").trigger(eventName, [checked]);
	}

	function init(elementId, changeEventName, openEventName, closeEventName, processCallback, classes, clickCallback) {
		var checked = [];
		if (!classes) {
			classes = "";
		}

		classes += (classes.length ? ' ' : '') + 'dashboard-widget-editor-select';

		$("#" + elementId + " option[selected=selected]").each(function() {
			checked.push($(this).val());
		});

		$("#" + elementId).data("checked", checked);

		$("#" + elementId).multiselect({
			classes: classes,
			header: false,
            multiple: true,
			selectedList: 5,
			menuHeight: "auto",
			open: function(event, ui) {
				var $widget = $(this).multiselect("widget");
				var $button = $(this).multiselect("getButton");
				$widget.position({
					my: "left top",
					at: "left bottom",
					of: $button,
					collision: "flipfit",
					using : null,
					within: window
				});
				if (openEventName) {
					$("body").trigger(openEventName);
				}
			},
			close:  function(event, ui) {
				if (closeEventName) {
					$("body").trigger(closeEventName);
				}
			},
			click: function(event, ui) {
				var index, checked;

				checked = $("#" + elementId).data("checked");

				if (clickCallback) {
					clickCallback(event, ui);
				}

				if (changeEventName) {
					index = checked.indexOf(ui.value);

					if (ui.checked) {
						if (index < 0) {
							checked.push(ui.value);
						}
					} else {
						if (index > -1) {
							checked.splice(index, 1);
						}
					}

					$("#" + elementId).data("checked", checked);

					if (processCallback && $.isFunction(processCallback)) {
						checked = processCallback(checked);
					}

					$("body").trigger(changeEventName, [checked]);
				}
			},
			optgrouptoggle: function(event, ui) {
				var checked = [];
				checked = $("#" + elementId).data("checked");

				var values = $.map(ui.inputs, function(checkbox) {
					return checkbox.value;
				});

				if (ui.checked) {
					for (var i = 0; i < values.length; i++) {
						index = checked.indexOf(values[i]);
						if (index < 0) {
							checked.push(values[i]);
						}
					}
				} else {
					for (var i = 0; i < values.length; i++) {
						index = checked.indexOf(values[i]);
						if (index > -1) {
							checked.splice(index, 1);
						}
					}
				}

				$("#" + elementId).data("checked", checked);

				if (processCallback && $.isFunction(processCallback)) {
					checked = processCallback(checked);
				}

				$("body").trigger(changeEventName, [checked]);
			}
        }).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		}).multiselectHierarchy();
	}

	function initSingleSelect(elementId, changeEventName, openEventName, closeEventName, processCallback) {
		var checked, $widget;

		function toggleClearAllLink(e) {
			var $clearAllLink = $widget.find(".ui-helper-reset li:first");

			if (e.target.value) {
				$clearAllLink.hide()
			} else {
				$clearAllLink.show();
			}
		}

		checked = "";

		$("#" + elementId + " option[selected=selected]").each(function() {
			checked = $(this).val();
		});

		$("#" + elementId).multiselect({
			classes: 'dashboard-widget-editor-select',
			header: i18n.message("Clear"),
            multiple: false,
			selectedList: 1,
			open: function(event, ui) {
				if (openEventName) {
					$("body").trigger(openEventName);
				}
			},
			close:  function(event, ui) {
				if (closeEventName) {
					$("body").trigger(closeEventName);
				}
			},
			click: function(event, ui) {
				var index;

				if (changeEventName) {
					if (ui.checked) {
						if (checked !== ui.value) {
							checked = ui.value;
						}
					} else {
						checked = "";
					}

					if (processCallback && $.isFunction(processCallback)) {
						checked = processCallback(checked);
					}

					$("body").trigger(changeEventName, checked);
				}
			}
        }).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		}).multiselectHierarchy();

		$widget = $($("#" + elementId).multiselect("widget"));
		$widget.find(".ui-multiselect-filter input").on("keyup", toggleClearAllLink);

		$widget.find(".ui-helper-reset li:first").on("click", function() {
			$("#" + elementId).multiselect("uncheckAll");
		});
	}

	function attachEventListener(eventName, listener, context) {
		if (eventName) {
	        $("body").on(eventName, function(event, changed) {
	        	var args = Array.prototype.slice.call(arguments, 1);
	        	listener.apply(context, args);
	        });
		}
	};

	function removeEventListener(eventName, listener) {
		if (eventName) {
	        $("body").off(eventName, listener);
		}
	};

	function removeEventListeners(eventName) {
		if (eventName) {
	        $("body").off(eventName);
		}
	};

	function triggerEvent(eventName, params) {
		if (eventName) {
	        $("body").trigger(eventName, params ? params : {});
		}
	};

	return {
		"init": init,
		"initSingleSelect": initSingleSelect,
		"attachEventListener": attachEventListener,
		"removeEventListener": removeEventListener,
		"removeEventListeners": removeEventListeners,
		"refreshSelection": refreshSelection,
		"triggerEvent": triggerEvent,
		"clear": clear
	};

})(jQuery);