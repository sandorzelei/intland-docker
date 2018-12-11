//$Revision: 21889:59ac1a6c6b77 $ $Date: 2009-07-13 05:26 +0000 $

function cb_help_window(url) {
	window.open('' + url,'CBHelpWindow','scrollbars=yes,resizable=yes,toolbar=no,height=410,width=500');
}

/**
 * Calculate a desired window/popup geometry from the screen size
 * @param geometry Various string constants for desired geometry, see code below...
 * @param container Optional selector for container to calculate geometry relative to. If empty then the geometry is relative to screen width/height
 * @return The calculated geometry object with properties "width" and "height"
 */
function calculateWindowGeometry(geometry, container) {
	var width = null,
		height = null,
		min_height = null,
		containerWidth = null,
		containerHeight = null;

	if (container) {
		containerWidth = $(container).width();
		containerHeight = $(container).height();
	} else {
		containerWidth = screen.width;
		containerHeight = screen.height;
	}

	// you can provide the geometry as percentages like "60%_80%" means 60% width 80% height of the screen
	// or you can also used fixed values like 800_400
	var percents = new RegExp("(\\d*)%_(\\d*)%");
	var fixed = new RegExp("(\\d+)_(\\d+)");
	var match = percents.exec(geometry);
	var matchFixed = fixed.exec(geometry);
	if (match != null) {
		var widthpercent = parseInt(match[1]);
		var heightpercent = parseInt(match[2]);
		width = Math.round(containerWidth * widthpercent / 100.0);
		height = Math.round(containerHeight * heightpercent / 100.0);
	} else if (matchFixed != null) {
		width = parseInt(matchFixed[1]);
		height = parseInt(matchFixed[2]);
	} else if (geometry == null) {
		width = Math.round(containerWidth *  6 / 10);
		height = Math.round(containerHeight * 6 / 10);
		min_height = 600;
	} else if (geometry == 'large') {
		width = Math.round(containerWidth *  8 / 10);
		height = Math.round(containerHeight * 9 / 10);
		min_height = 100;
	} else if (geometry == 'half_half') {
		width = Math.round(containerWidth *  5 / 10);
		height = Math.round(containerHeight * 5 / 10);
		min_height = 100;
	} else if (geometry == 'thin_wide') {
		width = Math.round(containerWidth *  5 / 10);
		height = Math.round(containerHeight * 3 / 10);
		min_height = 100;
	} else if (geometry == 'small_wide') {
		width = Math.round(containerWidth *  45 / 100);
		height = Math.round(containerHeight * 5 / 10);
		min_height = 100;
	} else if (geometry == 'minimal') {
		width = 1;
		height = 1;
	} else if (geometry == 'full_half') {	// a full width, but "nearly-half" height
		width = containerWidth;
		height = Math.round(containerHeight * 0.6);
	} else {
		width = Math.round(containerWidth *  5 / 10);
		height = Math.round(containerHeight * 5 / 10);
		min_height = 300;
	}
	if (height < min_height) {
		height = min_height;
	}
	return {width: width, height: height};
}

/**
 * Open the URL in a (new) popup window
 *
 * @param gotourl The URL to open
 * @param geometry The various geometry options. If this is a function that will be called and which can return the window size and position like a "width=x,height=x,left=x,top=x" string which will be used to position the window
 * @param windowName Optional: the window name to open into. If missing then it will be always an new window
 * @param centered
 * @param showConfirmationOnParentNavigation
 * @returns
 */
function launch_url(gotourl, geometry, windowName, centered, showConfirmationOnParentNavigation) {
	var windowFeatures = "toolbar=no,location=no,directories=no,status=no,"
		+ "menubar=no,scrollbars=yes,resizable=yes";

	if (typeof geometry === "function") {
		// the geometry is a function, call this to decide about position & size of the window
		var positionAndSize = geometry();
		if (positionAndSize) {
			windowFeatures +="," + positionAndSize;
		}
	} else {
		var dimensions = calculateWindowGeometry(geometry);
		windowFeatures += ",width=" + dimensions.width + ",height=" + dimensions.height;

		if (centered) {
			var x = parseInt((screen.width - dimensions.width) / 2, 10);
			var y = parseInt((screen.height - dimensions.height) / 2, 10);

			windowFeatures += ",left=" + x + ",top=" + y;
		}
	}

	if (windowName == null) {
		windowName = '_blank';
	}

	var popupWindow = window.open(gotourl, windowName, windowFeatures);
	if (showConfirmationOnParentNavigation) {
		linkToCurrentWindowViaEventHandlers(popupWindow);
		(function() {
			var popupIsStillOpen = true;
			window.onbeforeunload = function() {
				if (popupIsStillOpen) {
					return i18n.message("cb.confirmation.popupStillOpen");
				}
			};
			$(window).one("popupEditorClosed", function() {
				popupIsStillOpen = false;
			});
		})();
	}

	return false;
}

function linkToCurrentWindowViaEventHandlers(popupWindow) {

	(function($) {
		function addEvent(obj, type, fn) { // from http://ejohn.org/projects/flexible-javascript-events/
			if (obj.attachEvent) {
				obj['e' + type + fn] = fn;
				obj[type + fn] = function() {
					obj['e' + type + fn](window.event);
				};
				obj.attachEvent('on' + type, obj[type + fn]);
			} else {
				obj.addEventListener(type, fn, false);
			}
		}

		var unloadCallback = function() {
			thisWindow.trigger("popupEditorClosed");
		};

		var thisWindow = $(window);
		var body = $("body");

		if (body.hasClass("IE8")) {
			$(popupWindow.document).ready(function() {
				var oldFunction = popupWindow.onbeforeunload;
				popupWindow && addEvent(popupWindow, "beforeunload",  function(e) {
					oldFunction && oldFunction.call(this, e);
					unloadCallback.call();

					(e || window.event).returnValue = null;
					return null;
				});
			});
		}
		if (body.hasClass("IE")) {
			// IE does not fire onload event and document.ready runs too early so setting beforeunload has no effect
			$(popupWindow.document).ready(function() {
				var oldFunction = popupWindow.onbeforeunload;
				var loop = 0;

				for (var to = 100; to < 6000; to += 1000) {
					setTimeout(function() {
						loop++;
						if (!oldFunction && popupWindow.onbeforeunload){
							oldFunction = popupWindow.onbeforeunload;
						}

						if (oldFunction || loop > 5){
							popupWindow && (popupWindow.onbeforeunload = function(e) {
								oldFunction && oldFunction.call(this, e);
								unloadCallback.call();
							});
						}
					}, to);

				}
			});
		} else {
			$(popupWindow).load(function() {
				var oldFunction = popupWindow.onbeforeunload;
				$(popupWindow).on("beforeunload", function(e) {
					$.isFunction(oldFunction) && oldFunction.call(this, e);
					unloadCallback.call();
				});
			});
		}
	})(jQuery);
}

var setAllStatesFilters = {

	/**
	 * Creates a closure/filter function to filter elements by their property name
	 * @param property The property name, can contain a "*" for name patter matching
	 * @returns {Function}
	 */
	hasPropertyName: function(propertyName) {
		var prefix = null;
		var suffix = null;
		var wildcard = propertyName.indexOf('*');
		if (wildcard != -1) {
			prefix = propertyName.substring(0, wildcard);
			suffix = propertyName.substring(wildcard + 1);
		}
		return function(e) {
			// check if the form elem has value property, for example "fieldset" does not have it
			if (e.name) {
				if (wildcard != -1) {
					if(e.name.indexOf(prefix) == 0 && e.name.endsWith(suffix)) {
						return true;
					}
				} else {
					if(e.name.indexOf(propertyName) != -1) {
						return true;
					}
				}
			}
			return false;
		};
	},

	/**
	 * Creates a closure/filter function to filter elements by the css class
	 */
	hasCssClass: function(cssClass) {
		return function(e) {
				if (!cssClass) {
					return true;
				}
				return $(e).hasClass(cssClass);
			};
	}

};

/**
 * Set all checkboxes
 * @param selector
 * @param property The property wildcard
 * @param cssClass The optional cssClass filter. If not null only those are checked which are matching the filter
 */
function setAllStatesByProperty(selector, property, cssClass) {
	var filters = [ setAllStatesFilters.hasPropertyName(property),
					  setAllStatesFilters.hasCssClass(cssClass) ];
	setAllStatesByClosures(selector, filters);
}

function setAllStatesByValue(selector, property) { // TODO: should use setAllStatesFromClosures()
	var val = selector.checked;
	var frm = selector.form;

	var length = frm.elements.length;
	var endsWith = property.indexOf('*') == 0;
	if (endsWith) {
		property = property.substring(1);
	}

	if (!property) {
		return;
	}

	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		// check if the form elem has value property, for example "fieldset" does not have it
		if (e.value) {
			if (endsWith) {
				if(e.value.endsWith(property)) {
					setChecked(e, val);
				}
			} else {
				if(e.value.indexOf(property) == 0) {
					setChecked(e, val);
				}
			}
		}
	}
}

function setAllStatesByPropertyAndValue(selector, property, valfil) { // TODO: should use setAllStatesFromClosures()
	var val = selector.checked;
	var frm = selector.form;

	var length = frm.elements.length;
	var endsWith = valfil.indexOf('*') == 0;
	if (endsWith) {
		valfil = valfil.substring(1);
	}

	if (!property) {
		return;
	}

	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		if (e.name && e.name.indexOf(property) != -1) {
			// check if the form elem has value property, for example "fieldset" does not have it
			if (e.value) {
				if (endsWith) {
					if(e.value.endsWith(valfil)) {
						setChecked(e, val);
					}
				} else {
					if(e.value.indexOf(valfil) == 0) {
						setChecked(e, val);
					}
				}
			}
		}
	}
}

/**
 * Set all states from all checkboxes to same value as a checkbox. Filtered by closures
 * @param fromSelector The orginal checkbox to copy values from
 * @param filters The array closures will be called with the form element as parameter,
 * 					and should return with true if the form element should be updated
 */
function setAllStatesByClosures(fromSelector, filters) {
	if (!filters || !fromSelector) {
		return;
	}

	var val = fromSelector.checked;
	var frm = fromSelector.form;

	var length = frm.elements.length;
	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		var match = true;
		for (var j=0; j<filters.length; j++) {
			var filter = filters[j];
			if (filter) {
				match = match && filter.call(this, e);
			}
		}

		if (match) {
			setChecked(e, val);
		}
	}
}

/**
 * Set all states from all checkboxes to same value as a checkbox
 * @param fromSelector The orginal checkbox to copy values from
 * @param property The property name filter, only checkboxes with this name will change
 * @param filter Optional closure function, determines if the checkbox is checked
 */
function setAllStatesFrom(fromSelector, property, closure) {
	setAllStatesByClosures(fromSelector, [function(e) {
		// check if the form elem has name property, for example "fieldset" does not have it
		var match = (e.name && e.name.indexOf(property) != -1);
		// call the closure (if provided) to see if value changes
		match = match && (closure == null || closure.call(this,e));
		return match;
	}]);
}

/**
 * closure function class matches elements within the same table table as an original element.
 * Use as below, where the element, the element which is in the current table to filter for...
 * var closureFunc = new InSameTableClosure(element);
 *
 * @param element The reference element of-which the other elements must be in the same table
 * @return the closure function to call with other elements.
 */
function InSameTableClosure(element) {
	this.parentTable = this.findParentTable(element);
	var THIS = this;
	return function(e) {
			return THIS.isInSameTable.call(THIS, e);
		};
}

// functions for InSameTableClosure class
InSameTableClosure.prototype = {
	// parent table found
	parentTable: null,

	// function finds parent table
	// @param element The element to start at
	// @return the parent table, or null if not found
	findParentTable: function(element) {
		while (element != null && element.tagName != "TABLE") {
			element = element.parentNode;
		}
		return element;
	},

	// closure function checks if the given element is in the same table as the original
	isInSameTable: function(element) {
		var elemParentTable = this.findParentTable(element);
		return elemParentTable == this.parentTable;
	}

}

/**
 * Sets all checkbox states of a certain property.
 * @param frm The form
 * @param the checkboxes with this name will get the new value
 * @param forcedValue Boolean: if not null this value will be set as value to all checkboxes, if null then the current value of the 1st checkbox is copied to the others
 */
function setAllStates(frm, property, forcedValue) {
	var val = false;
	var firstOccurrence = true;
	if (typeof forcedValue != 'undefined') {
		firstOccurrence = false;
		val = forcedValue;
	}

	var length = frm.elements.length;
	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		// check if the form elem has name property, for example "fieldset" does not have it
		if(e.name && e.name.indexOf(property) != -1) {
			if (firstOccurrence) {
				firstOccurrence = false;
				val = !e.checked;	// If the first is set, unset all vica versa.
			}
			setChecked(e, val);
		}
	}
}

/*
 * Set a checkbox checked, so it will update the colors using TableHighlighter.js
 */
function setChecked(e, val) {
	// do not change the <input type="hidden" ... > fields, they are there just to fix the issue with checkboxes
	if (e.type == "hidden") {
		return;
	}

	e.checked = val;

	// notify tableHighlighter to update the row colors
	if (typeof tableHighlighter !="undefined" && tableHighlighter) {
		tableHighlighter.updateRowOfCheckbox(e);
	}
	// call event handler, because changing e.checked won't fire events
	// check if has onchange event-handler, and call it,
	if (typeof e.onchange == "function") {
		e.onchange.call(e);
	}
	// check if has onclick event-handler, and call it
	if (typeof e.onclick == "function") {
		e.onclick.call(e);
	}
}

/**
 * Check if the form is submittable if at least one checkbox selected.
 * @param frm The form to submit
 * @param property The checkbox property on the from to check
 */
function hasSelectedCheckbox(frm, property) {
	var found = ! forAllFields(frm, property, function(e) {
		// is it a checked checkbox?
		if (e.checked) {
			return false;
		}
		// not checkbox, continue
		return true;
	});

	return found;
}

/**
  Check if the form is submittable  if at least one checkbox selected.
  @param frm The form to submit
  @param property The checkbox property on the from to check
  @param url Optional parameter, if provided this url will be pulled if at least one checkbox is selected
  @return true if the form was submitted successfully
 */
function submitIfSelected(frm, property, url) {
	var found = hasSelectedCheckbox(frm, property);

	if (found) {
		if (url != null && url.length != 0) {
			document.location.href=url;
		}
	} else {
		alert(i18n.message("no.item.selected"));
	}
	return found;
}

/**
 * Find all fields in a form with a certain name
 * @param frm The form to search checkboxes inside
 * @param property the checkbox's name to look for
 * @param funct The function will be called back with the form element as first parameter,
 * 					it should return true to continue iteration,
 *					if false returned iteration will stop
 * @return true if all fields iterated, or false if the function returned false at least once, so iteration stopped
 */
function forAllFields(frm, property, func) {
	var length = frm.elements.length;
	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		// check if the form elem has name property, for example "fieldset" does not have it
		if(e && e.name && e.name.indexOf(property) != -1) {
			var cont = func.call(this, e);
			// exit if function says return false
			if (!cont) {
				return false;
			}
		}
	}
	return true;
}

/**
 * Get all "value" of the checked checkboxes.
 * @param frm The form where checkboxes are
 * @param property checkbox field name
 * @return array of values of checked checkboxes
 */
function findAllCheckedCheckboxValues(frm, property) {
	var values = new Array();
	forAllFields(frm, property, function(e) {
		if (e.checked) {
			values[values.length] = e.value;
		}
		return true;
	});
	return values;
}

/**
 * Set all input boxes/fields disabled or enabled on a form.
 * Won't disable/enable buttons though, to be able to click on "cancel" for example.
 *
 * @param form The form to search on
 * @param disabled if the fields will be disabled
 */
function setEditFieldsDisabled(frm, disabled) {
	var length = frm.elements.length;
	for (var i=0; i < length; i++) {
		var e = frm.elements[i];
		var inputfield = (e.tagName == "INPUT");
		// do not disable buttons, so we can still navigate
		var isbutton = inputfield && (e.type == "submit" || e.type == "button");
		// hidden fields are not disabled as they may contain required fields like tracker_id, which are not submitted
		var ishidden = inputfield && (e.type == "hidden");
		if (!isbutton && !ishidden) {
			e.disabled = disabled;
		}
	}
}

