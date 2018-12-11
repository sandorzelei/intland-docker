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

// the delimiters used in search indexing
codebeamer.DELIMITERS = ["+", "-", "_", ".", "。", ",", ";", ":", "[", "]", "{", "}", "(", ")", "=", "!", "@", "#", "$", "%", "^",
	"&", "<", ">", "|", "'", "\"", "\\", "?", "~", "/", "´", "`"];

// set up defaults for ajax
$.ajaxSetup({
	cache: false	// turn off caching for any ajax calls as default
});

// fix for that IE does not know Array.indexOf() function:
if(!Array.indexOf){
	Array.prototype.indexOf = function(obj){
		for(var i=0; i<this.length; i++){
			if(this[i]==obj){
				return i;
			}
		}
		return -1;
	};
}

// formats a string replacing the {0} type of placeholders in it
if (!String.format) {
	String.prototype.format = function() {
		var str = this;
		for (var i = 0; i < arguments.length; i++) {
			var reg = new RegExp("\\{" + i + "\\}", "gm");
			str = str.replace(reg, arguments[i]);
		}
		return str;
	}
}

// startsWith and endsWith methods for IE
if (!String.prototype.startsWith) {
	String.prototype.startsWith = function(search, pos) {
		return this.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search;
	};
}
if (!String.prototype.endsWith) {
	String.prototype.endsWith = function(search, this_len) {
		if (this_len === undefined || this_len > this.length) {
			this_len = this.length;
		}
		return this.substring(this_len - search.length, this_len) === search;
	};
}

// function for detecting if URL exceeds the maximum length

var MAXIMUM_URL_LENGTH = 2000;

function exceedMaximumUrlLength(url) {
    try {
        return window.location.origin.length + url.length > MAXIMUM_URL_LENGTH;
    } catch (e) {
        return false;
    }
    return false;
}

// Escape/quote a string so Regexp won't do anything with that
RegExp.quote = function(str) {
    return (str+'').replace(/[.?*+^$[\]\\(){}|-]/g, "\\$&");
};

// replace a text without regexp:
// use because in the .replace(search,replace) the replace must not contain a $ character
function replaceLiteral(str, search, replace) {
	return (str + '').split(search).join(replace);
}

function initializeJSPWikiScripts() {
	TabbedSection.onPageLoad();
	SearchBox.onPageLoad();
	Wiki.onPageLoad();
	Sortable.onPageLoad();
	ZebraTable.onPageLoad();
	HighlightWord.onPageLoad();
	Collapsable.onPageLoad();
	GraphBar.onPageLoad();
	/* INCLUDERESOURCES (jsfunction) */
}

/**
 * initializes teh minimal set of jsp wiki scripts that are needed on document view and simple pages.
 * this list excludes some of the initializers that are needed only on the display wiki page. also
 * the function uses a context object (a jquery object) to reduce the dom search space for jquery.
 */
function initializeMinimalJSPWikiScripts(context) {
	TabbedSection.onPageLoad(context);
	Sortable.onPageLoad(context);
	ZebraTable.onPageLoad();
	Collapsable.onPageLoad(context);
}


$(window).on("load", initializeJSPWikiScripts);
$(window).on("load", function() {
	// jump the page to the anchor in the url when the page is fully loaded. See [ISSUE:25681]
	// DO NOT add any javascript after this!
	var hash = location.hash;
	if (hash.indexOf("#!") !== 0) { // only if it's not a special purpose hash string
		jumpToHash(hash);
	}

	// save clicked DOM element to parent form when a submit button is clicked,
	// this way an onSubmit event handler can later access it if needed
	addEventHandlerToStoreSourceDomElementOnFormSubmit();

	// Hide reference setting dialogs if click outside
	$("html").click(function(e) {
		if ($(e.target).closest(".referenceSettingDialog").length == 0) {
			$(".referenceSettingDialog").hide();
		}
	});

});

/**
 * Get a value of a URL parameter based on its key.
 * @param key Key of URL parameter
 * @param url URL query string to use, defaults to current browser query string
 * @returns {string} Parameter value or empty string if not found
 */
function getUrlParameter(key, url) {
	if (key != "") {
		var result = new RegExp(key + "=([^&]*)", "i").exec(url || window.location.search);
		if (result) {
			return decodeURI(result[1]);
		}
	}
	return "";
}

function addParameterToUrl(url, name, value) {
	var re = new RegExp("([?&]" + name + "=)[^&]+", "");
	function add(sep) {
		url += sep + name + "=" + encodeURIComponent(value);
	}
	function change() {
		url = url.replace(re, "$1" + encodeURIComponent(value));
	}
	if (url.indexOf("?") === -1) {
		add("?");
	} else {
		if (re.test(url)) {
			change();
		} else {
			add("&");
		}
	}
	return url;
}

/**
 * Jump to an anchor's hash like in the url "http://localhost:8080/cb/wiki/1003#section-Members+plugin".
 * This function automatically switches the appropriate JSPWiki's tab to show the desired anchor.
 *
 * @param hash The hash string of the anchor
 */
function jumpToHash(hash) {
	if (!hash || hash == "") {
		return;
	}

	// Open the JSPWiki's tabbedsection where this anchor is inside
	if (hash.indexOf("#") == 0 && hash.length > 1) { // hash must start with a #
		/*
		 walk up in the DOM tree to find the parent "tabbedSection"
		 the DOM structure looks like, and open the parent tab(s) to be sure that the anchor gets visible

		 <div class="tabbedSection tabs">
		 <div id="tab-Graphs" class="tab-Graphs">
		 ... somewhere below...
		 <a id="${anchorId}">...</a>
		 </div>
		 </div>
		 */
		$(hash).parents(".tabbedSection >div").each(function() {
			// select the parent tab
			TabbedSection.onclick(this.id);
		});
	}

	// force the browser to jump to anchor
	location.hash = hash;
}

/*
 * Toggles the visibility of an HTML DOM element and
 * updates the "toggle" image.
 */
function toggleElement(elementId, imageId, showImageUrl, hideImageUrl) {
	var element = document.getElementById(elementId);
	var image = document.getElementById(imageId);
	if (element.style.display == 'none'){
		element.style.display = 'block';
		image.src = showImageUrl;
	} else {
		element.style.display = 'none';
		image.src = hideImageUrl;
	}

	return false;
}

var asciiBack       = 8;
var asciiTab        = 9;
var asciiSHIFT      = 16;
var asciiCTRL       = 17;
var asciiALT        = 18;
var asciiHome       = 36;
var asciiLeftArrow  = 37;
var asciiRightArrow = 39;
var asciiMS         = 92;
var asciiView       = 93;
var asciiF1         = 112;
var asciiF2         = 113;
var asciiF3         = 114;
var asciiF4         = 115;
var asciiF5         = 116;
var asciiF6         = 117;
var asciiF7         = 118;
var asciiF8         = 119;
var asciiF9         = 120;
var asciiF10        = 121;
var asciiF11        = 122;
var asciiF12        = 123;

function KeyInfo () {
	this.character = null;
	this.keyCode = null;
	this.altPressed = false;
	this.shiftPressed = false;
	this.ctrlPressed = false;
};

function getKeyPressed(evt) {
	//get the event object
	var oEvent = (window.event) ? window.event : evt;

	//hmmm in mozilla this is jacked, so i have to record these seperate
	//what key was pressed
	var nKeyCode =  oEvent.keyCode ? oEvent.keyCode :
		oEvent.which ? oEvent.which :
			void 0;

	var bIsFunctionKey = false;

	//hmmm in mozilla the keycode would contain a function key ONLY IF the charcode IS 0
	//else key code and charcode read funny, the charcode for 't'
	//returns 116, which is the same as the ascii for F5
	//SOOO,... to check if a the keycode is truly a function key,
	//ONLY check when the charcode is null OR 0, IE returns null, mozilla returns 0
	if(oEvent.charCode == null || oEvent.charCode == 0) {
		bIsFunctionKey = (nKeyCode >= asciiF1 && nKeyCode <= asciiF12) ||
			(
				nKeyCode == asciiALT
					|| nKeyCode == asciiMS
					|| nKeyCode == asciiView
					|| nKeyCode == asciiHome
					|| nKeyCode == asciiBack
				);
	}

	var keyInfo = new KeyInfo();

	//convert the key to a character, makes for more readable code
	keyInfo.character = String.fromCharCode(nKeyCode).toUpperCase();
	keyInfo.keyCode = nKeyCode;

	//get the active tag that has the focus on the page, and its tag type
	var oTarget = (oEvent.target) ? oEvent.target : oEvent.srcElement;
	var sTag = oTarget.tagName.toLowerCase();
	var sTagType = oTarget.getAttribute("type");

	keyInfo.altPressed = (oEvent.altKey) ? oEvent.altKey : oEvent.modifiers & 1 > 0;
	keyInfo.shiftPressed = (oEvent.shiftKey) ? oEvent.shiftKey : oEvent.modifiers & 4 > 0;
	keyInfo.ctrlPressed = (oEvent.ctrlKey) ? oEvent.ctrlKey : oEvent.modifiers & 2 > 0;

	return keyInfo;
}

function unloadBtnPressed(evt) {
	var keyInfo = getKeyPressed(evt);

	if (keyInfo.ctrlPressed && keyInfo.character == 'R') {
		return true;
	} else if (keyInfo.altPressed && (keyInfo.keyCode == asciiLeftArrow || keyInfo.keyCode == asciiRightArrow)) {
		return true;
	} else if (keyInfo.keyCode == asciiF5) {
		return true;
	}
	return false;
}

function tabBtnPressed(evt) {
	var keyInfo = getKeyPressed(evt);
	return (keyInfo.keyCode == 9 && !keyInfo.shiftPressed);
}

function enterBtnPressed(evt) {
	var keyInfo = getKeyPressed(evt);
	return (keyInfo.keyCode == 13);
}

/* - Single-click subscription --------------------------------------------- */

function setNotifications(setNotificationAjaxRequestUrl, callback, entityTypeId, entityId, subscribed) {
	$.ajax({
		url: setNotificationAjaxRequestUrl,
		type: 'POST',
		data: {
			"entityTypeId": entityTypeId,
			"entityId": entityId,
			"subscribed": subscribed
		},
		success: callback
	});
}

function setNotificationsWithDefaults(entityTypeId, entityId, subscribed) {
	setNotifications(contextPath + "/ajax/setNotification.spr",  function() { location.reload();} , entityTypeId, entityId, !subscribed);
}

// Checking if the Object exists
function isDefined(o) {
	var varToStr=eval("' "+o+"'");
	if (varToStr==" undefined") {
		return false;
	} else {
		return true;
	}
}

// String.replaceAll function
String.prototype.replaceAll=function(s1, s2) {return this.split(s1).join(s2)};

//Trim whitespace from left and right sides of s.
function trim(s) {
	return s.replace( /^\s*/, "" ).replace( /\s*$/, "" );
}

/**
 * Deprecated, use showModalDialogWithArgs() below.
 * @param width of the dialog in "em"-s. Optional, defaults to 30
 */
function showModalDialog(style, message, buttons, width, dialogName, openCallback, closeCallback) {
	if (! width) {
		width = "40";
	}
	var args = {
		width: width +"em"
	};
	if (openCallback) {
		args["open"] = openCallback;
	}
	if (closeCallback) {
		args['close'] = closeCallback;
	}
	return showModalDialogWithArgs(style, message, buttons, dialogName, true, args);
}

function showModalDialogWithArgs(style, message, buttons, dialogName, show, args) {
	if (!dialogName) {
		dialogName = "cbModalDialog";
	}
	var defaultArgs = {
		dialogClass: dialogName,
		modal: true,
		visible: false,
		draggable: false,
		buttons: buttons,
		minHeight: "auto"
	};
	var mergedArgs = $.extend({}, defaultArgs, args);
	var body = "<div><span class='" + style +"' ";
	if (buttons == null) {
		body += " style='margin-bottom:5px;'";
	}
	body +=">" + message +"</span></div>";
	var content = $(body);
	content.dialog(mergedArgs);
	if (show) {
		content.dialog("open");
	}

	return content;
}

/**
 * A simpler form of the showModalDialog(), with only Yes and Cancel options, can be used as drop-in replacement for the standard confirm() function.
 * This method differs from the other showFancyConfirmDialog, that it can be attached to a combo-box too, the other function needs a button!
 *
 * @param msg The message to show
 * @param handleYes Optional callback function when yes is pressed
 * @param handeCancel Optional callback function when cancel is pressed
 * @param style Optional style for the dialog
 * @param openCallback callback function for 'open' dialog event
 * @param closeCallback callback function for 'close' dialog event
 */
function showFancyConfirmDialogWithCallbacks(msg, handleYes, handleCancel, style, openCallback, closeCallback) {
	var handleYesWrapper = function() {
		try {
			if (handleYes) {
				handleYes.call($(this));
			}
		} finally {
			$(this).dialog("destroy");
		}
	};
	var handleCancelWrapper = function() {
		try {
			if (handleCancel) {
				handleCancel.call($(this));
			}
		} finally {
			$(this).dialog("destroy");
		}
	};
	var buttonYesText=i18n.message("button.yes");
	var buttonCancelText=i18n.message("button.cancel");

	var myButtons = [ { text:buttonYesText,  click:handleYesWrapper, "class": "button" },
		{ text:buttonCancelText, click:handleCancelWrapper, "class": "cancelButton" }];
	if (style == null) {
		style = "warning";
	}
	return showModalDialog(style, msg, myButtons, null, null, openCallback, closeCallback);
}

/**
 * A simpler form of the showModalDialog(), with only Yes and Cancel options, can be used as drop-in replacement for the standard confirm() function.
 * Attach this confirm dialog to any submit buttons' onclick, like: onclick="return showFancyConfirmDialog(this, 'message')"
 *
 * @param button The button attached to
 * @param msg The message to show
 * @return True if the button is confirmed, false if not.
 */
function showFancyConfirmDialog(button, msg) {
	if (button.confirmed) {
		return true;
	}
	var handleYes = function() {
		button.confirmed = true;
		button.click();
	};
	var handleCancel = function() {
		button.confirmed = false;
	};
	showFancyConfirmDialogWithCallbacks(msg, handleYes, handleCancel);
	return false;
}

/**
 * Fancy alert dialog with an OK button.
 * @param msg The mesage to show
 * @param style Optional style for the dialog
 */
function showFancyAlertDialog(msg, style, width, callback) {
	var buttons = [{
		text: i18n.message("button.ok"),
		click: function() {
			if (callback) {
				callback.call();
			}
			$(this).dialog("destroy");
		},
		"class": "button"
	}];
	if (style == null) {
		style = "warning";
	}
	return showModalDialog(style, msg, buttons, width);
}

/* - Artifact approvals ---------------------------------------------------- */

/**
 * Delete an artifact approval workflow after confirmation.
 */
function deleteArtifactApprovalConfirm(approvalName, approvalId, deleteApprovalUrl) {
	var handleYes = function() {
		document.location = deleteApprovalUrl;
		$(this).dialog("destroy");
	};
	var handleNo = function() {
		$(this).dialog("destroy");
	};
	var showArtifacts = function() {
		$(this).dialog("destroy");
		var location = contextPath + "/listArtifactsInApproval.spr?approvalworkflow_id=" + approvalId + "&onlyActive=true";
		document.location = location;
	};

	var myButtons = [ { text:i18n.message("button.yes"),  click:handleYes },
		{ text:i18n.message("button.cancel"), click:handleNo, isDefault:true },
		{ text:i18n.message("artifact.approval.workflow.delete.show.artifacts"), click: showArtifacts } ];
	var msg = i18n.message("artifact.approval.workflow.delete.confirm", escapeHtml(approvalName));
	showModalDialog("warning", msg, myButtons, 50);
}

function deleteArtifactApprovalStep(approvalStepName) {
	var answer = confirm(i18n.message("artifact.approval.workflow.step.delete.confirm", approvalStepName));
	return answer;
}

// This function submits the form if ENTER was pressed in a text field.
function submitOnEnter(textField, evt) {
	if (enterBtnPressed(evt)) {
		textField.form.submit();
		return false;
	}
	return true;
}

function addEventHandlerToStoreSourceDomElementOnFormSubmit() {
	$("form input[type=submit]").click(function() {
		$(this).closest("form").prop("clicked-submit-button", this);
		return true;
	});
}

/**
 * Create an input box which will show an hint text until it is focused, when hint disappears.
 * Like our search box.
 *
 * IMPORTANT: This script won't clear the "hintText" value from the input box when the form is submitted from javascript code
 * by calling the form.submit() method. This is happening because the "onsubmit" event is not fired in this case.
 * So if your form is submitted like that either handle the hint text from the server code, or clear the hint in the js code!
 *
 * @param selector The JQuery/css selector for the input box to show hint inside
 * @param hintText The hint text shown when the input box is empty (and not focused)
 */
function applyHintInputBox(selector, hintText) {
	var el = $(selector);
	var applyHint = function(element) {
		$(element).each(function() {
			if ($(this).val() == '' || $(this).val() == hintText) {
				$(this).val(hintText).addClass("inputboxWithHint");
			}
		});
	};
	var removeHint = function(element, showalert) {
		$(element).each(function() {
			if($(this).val() == hintText) {
				$(this).val('').removeClass("inputboxWithHint");
			}
		});
	};

	el.bind("focus", function(e) {
		removeHint(this);
	});
	el.bind("blur", function(e) {
		applyHint(this);
	});
	applyHint(el);

	// before submitting the form remove the hint text
	var parentForm = el.closest('form');
	parentForm.submit(function(e) {
		removeHint(el);
	});
}

/**
 * load an GET URL when it is very long using an ajax's post:
 * this can be useful when the GET url is too long > 2k limit for the GET requests
 *
 * @param url The GET url: should support a POST request too !
 * @return html The loaded full html (with Sitemesh decoraton)
 */
var loadGetUrlWithAjaxPost = function(url) {

	// rebuild the url to make it shorter
	var parts = url.split("&");
	var rebuildURL = [];
	var postData = [];
	var len = 0;
	for (var i=0; i< parts.length; i++) {
		var part = parts[i];
		if (part.length <100 && (len + part.length < 1900)) {
			len += part.length + 1;
			rebuildURL.push(part);
		} else {
			postData.push(part);
		}
	}
	url = rebuildURL.join("&");
	postData = postData.join("&");

	var loadedContent = null;
	$.post({
		url: url,
		data: postData,
		async: false,
		cache: false,
		success:function(html,result,state) {
			loadedContent = html;
		},
		headers: {
			"SitemeshDecorationEnabled": "true"		// Sitemesh normally does not decorate ajax requests: but here we need a decorated page
		}
	});
	return loadedContent;
}

/**
 * Put a full HTML page into the iframe
 * @param iframe The iframe
 * @param html The full HTML page including the head and body
 */
var putHTMLtoIframe = function(iframe, html) {
	var idoc = iframe.contentWindow.document;
	idoc.open();
	idoc.write(html);
	idoc.close();
}

var inlinePopup = {

	idGen: 0,

	show: function(url, args) {
		var defaultArgs = {
			dialogClass: "inlinePopupDialog",
			autoOpen: false,
			modal: true,
			resizable: false,
			draggable: false,
			title: null,
			removePreviousOverlay: false,
			hideMinifyDialogLink: false
		};
		var mergedArgs = $.extend({}, defaultArgs, args);

		var calculateDimensions = function(iframeContent) {

			var container = mergedArgs.geometryRelativeTo || window;
			var containerHeight = $(container).height();
			var maxHeight = parseInt(containerHeight * 0.8, 10);

			var width = mergedArgs.width || 800;
			var height = "auto";
			var minHeight = mergedArgs.minHeight;
			if (mergedArgs.height) {
				height = mergedArgs.height;
			} else {
				try {
					height = iframeContent.outerHeight();
					if (height < minHeight) {
						height = minHeight;
					}
				} catch (e) {
					// Note: iframe content is not reachable by cross-domain requests (remote issue reporting)
				}
				if (height > maxHeight) {
					height = maxHeight;
				}
			}
			if (mergedArgs.geometry != null) {
				var geometryRelativeTo = mergedArgs.geometryRelativeTo || window; // the geometry will be calculated relative to the window as default
				var dimensions = calculateWindowGeometry(mergedArgs.geometry, geometryRelativeTo);
				width = dimensions.width;
				height = dimensions.height;
			}
			var windowWidth = $(window).width();
			var windowHeight = $(window).height();
			if (width > windowWidth) {
				width = windowWidth;
			}
			if (height > windowHeight) {
				height = windowHeight;
			}
			return {
				width: width,
				height: height
			}
		};

		// if ctrl-click is pressed then this will open a new window
		if (typeof window.event !== "undefined" && window.event.ctrlKey && window.event.constructor.name == "MouseEvent") {
			window.open(url, "_blank");
			return;
		}

		if (codebeamer.MinifiedOverlay.isMinifiedOverlayPresent()) {
			showFancyAlertDialog(i18n.message('inline.editor.overlay.opening.warning'));
			return;
		}

		// remove the previous instances of the iframe if this argument is true
		// in some cases this might be necessary to prevent id collisions
		if (mergedArgs.removePreviousOverlay) {
			var previousOverlay = document.getElementById("inlinedPopupIframe");
			if (previousOverlay && previousOverlay.remove) {
				previousOverlay.remove();
			}
		}

		var busyDialog = ajaxBusyIndicator.showBusyPage();
		var id = inlinePopup.idGen++;
		var dialogId = "inlinedPopup" + id;

		// Create and append elements using native Javascript, as IE browsers can crash
		var dialog = document.createElement("div");
		dialog.id = dialogId;
		var iframe = document.createElement("iframe");
		iframe.id = "inlinedPopupIframe";
		var closeButton = document.createElement("a");
		closeButton.className = "container-close";

		if (!mergedArgs.hideMinifyDialogLink) {
			var minifyDialogLink = document.createElement('a');
			minifyDialogLink.className = 'minify-dialog-link';
			dialog.appendChild(minifyDialogLink);
		}

		dialog.appendChild(closeButton);
		dialog.appendChild(iframe);
		document.body.appendChild(dialog);

		var $dialog = $(dialog);
		var $iframe = $(iframe);

		$dialog.dialog(mergedArgs);

		// check if the url is too long ? then send it as POST request instead of get
		var loadIframeContent = null;
		if (url.length > 1900) {
			console.log("URL is too long, trying to send it as POST. url:" + url);
            loadIframeContent = function() {
                return loadGetUrlWithAjaxPost(url);
            }

            // load an empty page so iframe's load event is fired
            $iframe.attr('src', contextPath +"/empty.jsp");
        } else {
			$iframe.attr('src', url);	// FF sends 2 request to iframe url otherwise
		}

		$iframe.on("load", function() {
			var openDialog;

			if (busyDialog) {
				try {
					busyDialog.dialog("destroy").remove();
				} catch(ex) {
					//
				}
			}

			if (loadIframeContent != null) {
			    var content = loadIframeContent();
				putHTMLtoIframe(this, content);

				// clear the content after this is loaded to avoid that this is displayed again
                loadIframeContent = null;
			}

			try {
				var $iframeDocument = $(this).contents(),
					$iframeContent = $iframeDocument.find("html"),
					$iframeBody = $iframeContent.find("body");

				$iframeBody.addClass("insideInlinedPopup");
			} catch(e) {
				console.log("couldn't access iframe body: " + e.message);
			}

			openDialog = inlinePopup._processMetaTags();

			if (openDialog) {
				$dialog.data('reference', dialog);
				$dialog.find(".container-close").click(function() {
					if (iframe && iframe.contentWindow) {
						try {
							iframe.contentWindow.$("body").trigger("beforeInlinePopupDestroy");
							iframe.contentWindow.codebeamer.NavigationAwayProtection.reset();
						} catch (e) {
							// ignore this if popup is a cross-origin frame
						}
					}

					inlinePopup.closeAndDestroyDialog($dialog);
					if (mergedArgs.isEditWikiInOverlay) {
						delete wikiEditorOverlay.editWikiInOverlayContainer;
					}
					if (codebeamer.MinifiedOverlay.isMinifiedOverlayPresent()) {
						codebeamer.MinifiedOverlay.remove();
					}
				});
				$dialog.find('.minify-dialog-link').click(function() {
					codebeamer.MinifiedOverlay.minimize();
				});
				var isIE = $('body').hasClass('IE');
				$dialog.on("dialogopen", function() {
					var dimensions = calculateDimensions($iframeContent);
					$dialog.dialog("option", "width", dimensions.width);
					$dialog.dialog("option", "height", dimensions.height);
				});
				$dialog.dialog("open");
			}

			try {
				if (typeof args.afterLoad == 'function') {
					args.afterLoad.call();
				}
			} catch (ignored) {
			}

			if (isIE) {
				$iframe[0].contentWindow.document.body.focus();
			} else {
				$iframe.focus();
			}
		});

		return $dialog;
	},

	/**
	 * Check if this is inside of a popup?
	 * @return Returns the dialog object if inside of a popup, otherwise null
	 */
	findPopup: function() {
		try {
			if (parent == null) {
				return null;
			}

			var $dialog = parent.$('.inlinePopupDialog .ui-dialog-content').first();
			if ($dialog == null || $dialog.length == 0) {
				return null;
			}

			return $dialog;
		} catch (ignored) {
			return null;
		}
	},

	close: function(message) {
		var myParent = parent;
		if (message) {
			myParent.GlobalMessages.showInfoMessage(message);
		}

		var $dialog = inlinePopup.findPopup();
		if ($dialog != null) {
			inlinePopup.closeAndDestroyDialog($dialog);
		}
		return !!$dialog;
	},

	closeAndDestroyDialog: function($dialog) {
		// the "destroy" of the dialog submits the url of the iframe in Firefox
		// and can occur problems in IE, so must clear it before
		$dialog.find("iframe").attr("src", "about:blank");
		$dialog.trigger("dialogclose");
		if ($dialog.hasClass("ui-dialog-content")) {
			$dialog.dialog("destroy");
		}
		$dialog.remove();
	},

	closeAndReload: function(targetUrl) {
		if (targetUrl != null && targetUrl != '') {
			document.location.href = targetUrl;
		} else {
			document.location.reload();
		}
		inlinePopup.close();
	},

	executeJS: function(js) {
		if (js) {
			// wrap in a function so if the js script contains a "return" statement that won't throw an exception
			// , so this can run scripts normally used in onclick event-function
			js = "(function(){" + js +"})();"
			parent.jQuery.globalEval(js);
		}
	},

	// process the meta tags appearing in the body of the iframe
	_processMetaTags: function() {
		var iframe = document.getElementById('inlinedPopupIframe');
		// if we find the <meta name="decorator" content="main"/> then automatically close the inline-dialog and
		// reload the main page with the same url
		var action = {
			cancelled: false,
			closeInlinePopup: false,
			targetUrl: null,
			noReload: null,
			callback: null,
			taskId: null,
			executeJS:null	// execute some js after page has been closed
		};

		// Note: iframe content is not reachable in case of cross-domain requests
		try {
			$(iframe).contents().find("meta").each(function() {
				if (this.name == "decorator" && this.content== "main") {
					action.closeInlinePopup = true;
					try {
						// get iframe's url and reload the main window with that url
						action.targetUrl = $(iframe).contents().get(0).location.href;
					} catch (ex) {
						console.log("Could not determine url of inlinedPopup's iframe, just reloading page. Exception:" + ex);
					}
				} else if (this.name == "closeInlinePopup") {
					action.closeInlinePopup = true;
					action.targetUrl = this.content;
				} else {
					// the othe meta-data just passed to the action
					// these are: "noReload", "callback", "taskId", "executeJS"
					action[this.name] = this.content;
				}
			});

			// trigger an event after the inline-popup is reloaded
			$(document).trigger("inlinePopupReloaded", action);

			if (action.closeInlinePopup) {
				// execute the action
				console.log("Executing action after page reload inside inline-popup :" + action);
				// trigger a global event, so the pages behind the inline-popup	can cancel the close or prevent the reload
				// or otherwise modify what is happening here
				$(document).trigger("beforeCloseInlinePopup", action);

				if (! action.cancelled) {
					if (action.noReload == "true") {
						if (action.callback) {
							executeFunctionByName(action.callback, window, action.taskId);
						}

						inlinePopup.close();
					} else {
						inlinePopup.closeAndReload(action.targetUrl);
					}
				} else {
					console.log("Close-inline popup action is cancelled:" + action);
				}
			}
			inlinePopup.executeJS(action.executeJS);
		} catch (e) {
			console.log("couldn't access iframe contents:" + e);
		}

		var isOpen = (inlinePopup.findPopup() != null) || inlinePopup.isInIframe();
		return isOpen;
	},

	isInIframe: function() {
	    try {
	        return window.self !== window.top;
	    } catch (e) {
	        return true;
	    }
	}
};

// @deprecated
function showPopupInline(url, args) {
	inlinePopup.show(url, args);
}

// @deprecated
function closePopupInline() {
	inlinePopup.close();
}

/**
 * Submit an URL with a POST request. The url may contain parameters like x.spr?color=red&more=true
 */
function submitWithPost(url) {
	var id = "submitWithPostForm";
	var form = "<form style='display:none' action='" + url +"' method='post' id='" + id +"'></form>";
	$("body").append(form);
	$("#" + id).submit();
	return false;
}

var ajaxBusyIndicator = {

	AJAX_IMAGE_PATH : contextPath + "/js/yui/assets/skins/sam/ajax-loader.gif",

	getBusysignHTML: function(message, closeable) {
		var closeIcon = "<img src='" + contextPath + "/images/newskin/action/closewindow-round-bgwhite.png'/>";
		var closeButton = (closeable ? "<a href='#' title='" + i18n.message("ajax.ajaxBusyIndicator.enable.access.to.page") + "' onclick='ajaxBusyIndicator.close();' style='float:right; text-decoration: none; font-size:70%;'>" + closeIcon +"</a>": "");

		var html = "<div style='padding: 5px;position: relative;background-color: white'>" +
			closeButton +
			"<img style='margin-right: 25px;' src=\"" + ajaxBusyIndicator.AJAX_IMAGE_PATH + "\"></img>" +
			"<span style='position:relative; top:-5px;margin-right:25px'>"
			+ (message == null ? '' : message) + "</span>" +
			"</div>";
		return $(html);
	},

	showProcessingPage:function() {
		return ajaxBusyIndicator.showBusyPage("wiki.import.processing");
	},

	/**
	 * Convenience method for covering the WHOLE page and showing a message
	 * @return The dialog created
	 */
	showBusyPage: function(message, closeable, args) {
		try {
			if (!message) {
				message = "ajax.loading";
			}
			if (typeof closeable === "undefined") {
				closeable = false;	// don't allow close
			}

			var defaults = {
				modal: true,
				position: { my: "center", at: "center", of: $(window) }
			};
			var merged = $.extend({}, defaults, args);

			var busyDialog = ajaxBusyIndicator.showBusysign($("body"), i18n.message(message), closeable, merged);
			return busyDialog;
		} catch (ignored) {
		}
		return null;
	},

	/**
	 * Shows the busy sign.
	 * @param alignTo
	 * @param message
	 * @param closeable
	 * @param args optional object to override defaults
	 */
	showBusysign : function(alignTo, message, closeable, args) {

		if ($(alignTo).is(":hidden")) {
			return;
		}

		var html = ajaxBusyIndicator.getBusysignHTML(message, closeable);

		var defaultArgs = {
			dialogClass: "showBusySignDialog",
			autoOpen: false,
			modal: false,
			title: null,
			width: "auto",
			height: "auto",
			minHeight: 20,
			resizable: false,
			position: { my: "center top", at: "center top", of: $(alignTo) }
		};
		var mergedArgs = $.extend({}, defaultArgs, args);

		var dialog = html.appendTo($(alignTo)).dialog(mergedArgs);
		dialog.dialog('open');

		ajaxBusyIndicator.dialog = html;

		return html;
	},

	close: function(dialog) {
		if (dialog) {
			try {
				dialog.dialog("destroy").remove();
			} catch(ex) {
				//
			}
		} else {
			if (ajaxBusyIndicator.dialog != null) {
				try {
					ajaxBusyIndicator.dialog.dialog("destroy").remove();
				} catch(ex) {
					//
				}
				ajaxBusyIndicator.dialog = null;
			}
		}
	},

    showBusySignOnPanel: function (selector) {
        var $panel = $(selector).first();
        var p = $panel[0];
        return ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
            width: "12em",
            context: [p, "tl", "tl", null, [($panel.width() > 0 ? ($panel.width() - 12) / 2 : 200), 10]]
        });
    }

};

/**
 * Check if the fork to be deleted has changes compared to its parent
 *
 * @return The warning message to be shown if there are changes
 */
function getforkChangesComparedToParent(repositoryId) {
	var msg = "<div style='margin-top:10px;' id='containsChangesInfo'>" +
		"<img src='" + contextPath + "/images/ajax-loading_16.gif'></img>" +
		i18n.message("scm.repository.action.delete.wait.computing.changes") +
		"</div>";
	$.ajax({
		url: contextPath + "/ajax/proj/scm/repository/hasChanges.spr?repositoryId=" + repositoryId,
		dataType: "json",
		async: true,
		success: function(data) {
			var resultMsg = "";
			if (data.length>0) {
				var branchNames = data.join(", ");
				resultMsg = "<b>" + i18n.message("scm.repository.action.delete.fork.contains.unmerged.changes", branchNames) +"</b>";
			} else {
				resultMsg = i18n.message("scm.repository.action.delete.no.unmerged.changes");
			}
			$('#containsChangesInfo').html(resultMsg);
		}
	});
	return msg;
}

function ajaxErrorHandler (event, xhr, s, e) {
	if (xhr.status === 401 && $(".sessionClosedMessage").length == 0) {
	    // disable navigation away protection
        codebeamer.skipDirtyCheck = true;
        window.aysHasPrompted = true;

        showFancyAlertDialog(i18n.message("ajax.session.closed.message"), "warning", null, function () {
            location.reload(contextPath + "/login.spr");
        });
	}
}

/**
 * "floating-overlay" can be used to show a small overlay box on the page which is always visible even when scrolling away,
 *  and floating over other elements of the page. This box can be also dragged away if it is at a wrong position.
 *
 *  Usage:
 *  1. create a div element with this markup which contains the HTML code should be inside the floating overlay like this:
 *  <div class="floatingOverlay" id="myId">
 *     ...content...
 *  </div>
 *  2. initialize with some javascript like this:
 *    floatingOverlay.show("myId", "anchorId");
 *
 *  The "anchorId" is an id of some html element on the page. The floating-overlay will be aligned to this initially.
 */
var floatingOverlay = {

	/**
	 * @param elementId the html element's id to show as floating overlay
	 * @param alignTo The element (or its id) which this floating overlay will be aligned to. can be overridden in the config
	 * @param config Any overriding configuration parameters for YUI panel
	 * @return The panel. To use .close
	 */
	show: function(elementId, alignTo, config) {
		var $element = $("#" + elementId);
		$element.addClass("floatingOverlay");
		// the 'hd' class is the header of the YUI panel, if that is missing everything will go to the header
		if ($element.find('.hd').length == 0) {
			// everything moves to the header
			$element.contents().wrapAll("<div class='hd allInHeader'></div>");
		}

		// merge the configuration with the defaults
		var defaultConfig = {
			dialogClass: "floatingOverlay",
			autoOpen : false,
			draggable: false,
			resizable: false,
			modal: false,
			title: null,
			minHeight: 0,
			minWidth: 0,
			width: "auto",
			height: "auto",
			appendTo: $('#' + alignTo),
			position: { my: "top", at: "right bottom", of: $('#' + alignTo) }
		};
		var mergedConfig = $.extend(defaultConfig, config);

		$element.dialog(mergedConfig).parent().draggable();
		$element.parent().css({position : "fixed"}).end().dialog('open');

		$(window).resize(function() {
			$element.dialog("option", "position", { my: "top", at: "right bottom", of: $('#' + alignTo) });
		});

		return $element;
	}
};

/**
 * Move a relative positoned element that it will be fully visible in the viewport (it won't be outside of the screen)
 * @param element
 */
function moveRelativePositionedElementToViewPort(element, padding) {
	var viewportWidth = $(window).width(),
		viewportHeight = $(window).height(),
		$el = $(element),
		elWidth = $el.width(),
		elHeight = $el.height(),
		elOffset = $el.offset(),
		viewportLeft = $(window).scrollLeft(),
		viewportTop = $(window).scrollTop();

	if (padding == null) {
		padding = 5;
	}

	// check if the element is out on the right
	var deltaX = ((elOffset.left + elWidth - viewportLeft) - viewportWidth);
	var changed = false;
	if (deltaX > 0) {
		// Note: jQuery.position() can not be used as not working here on IE
		var previousLeft = $el.css("left");
		previousLeft = parseInt(previousLeft);

		$el.css("left", previousLeft - (deltaX + padding));
		changed = true;
	}
	// check if the element is out on the bottom
	var deltaY = ((elOffset.top + elHeight- viewportTop) - viewportHeight);
	if (deltaY > 0) {
		var previousTop = $el.css("top");
		previousTop = parseInt(previousTop);

		$el.css("top", previousTop - (deltaY + padding));
		changed = true;
	}

	// On Chrome the scrollbars remain visible. I've tried to repaint the window many ways but it does not work
	return changed;
}

var issueLinkCollector = function () {
	var elements = [];
	var links = $("a");

	if (links && links.length > 0) {
		for (var i = 0; i < links.length; i++) {
			var l = $(links[i]);
			var href = l.attr("href");
			if (href) {
				var matching = href.match(".*/issue/.*");
				if (matching) {
					elements.push(l);
				}
			}
		}
	}
	return elements;
};

var getTooltipContentForIssueLink = function (tt, el) {
	var href = el.attr("href");
	var parts = href.split("/");
	var issueId = parts[3];
	var j = issueId.indexOf("?");
	if (j >= 0) {
		issueId = issueId.substr(0, j);
	}
	tt["issueId"] = issueId;

	$.ajax({
		"url": contextPath + "/trackers/ajax/getTrackerItemPreview.spr",
		"type": "GET",
		"data": {
			"issue_id": tt["issueId"]
		},
		"success": function (data) {
			tt.cfg.setProperty("text", data);
			// set the loaded property
			tt["loaded"] = true; // set the loaded flag
		},
		"error": function () {
			tt.hide();
		}
	});
};

var traceabilityMatrixTooltipContent = function (tt, el) {
	var issueId = $(el).children("input").val();
	showTooltipContent(tt, issueId);
};

var coverageBrowserTooltipContent = function (tt, el) {
	var issueId = $(el).attr("id");
	showTooltipContent(tt, issueId);
};

var showTooltipContent = function (tt, issueId) {
	tt["issueId"] = issueId;
	$.ajax({
		"url": contextPath + "/trackers/ajax/getTrackerItemPreview.spr",
		"type": "GET",
		"data": {
			"issue_id": tt["issueId"]
		},
		"success": function (data) {
			tt.cfg.setProperty("text", data);
			// set the loaded property
			tt["loaded"] = true; // set the loaded flag
		},
		"error": function () {
			tt.hide();
		}
	});
};

var alignElementsToViewportEdge = {

	/**
	 * Initialize.
	 * @param selector
	 * @param alignTo Element ID
	 */
	init: function(selector, alignTo) {
		var doAlign = function() {
			alignElementsToViewportEdge.align(selector, alignTo);
		};

		// resize and scroll is fired too often, so delay the realign a bit so UI will keep responsive
		var doAlignTimer = null;
		var lazyDoAlign = function() {
			clearTimeout(doAlignTimer);
			doAlignTimer = setTimeout(doAlign, 200);
		};
		lazyDoAlign(); // load lazily the first time too - this will make the page load faster

		$(window).resize(lazyDoAlign);
		$("#" + alignTo).scroll(lazyDoAlign);
		try {
			$(".ui-layout-resizer-west").bind("dragstop", lazyDoAlign);
		} catch (e) {}

		try {
			$(".ui-layout-resizer-east").bind("dragstop", lazyDoAlign);
		} catch (e) {}
	},

	align: function(selector, alignTo) {
		try {
			var $alignTo = $("#" + alignTo);
			var width = $alignTo.offset().left + $alignTo.width();

			$(selector).each(function() {
				var $this = $(this);
				var off = $this.offset();
				if (off.left >= width - $this.width() || $this.attr("moved")) {
					$this.offset({"left": width - $this.width() - 27, "top": off.top});
					$this.attr("moved", true);
				}
			});
		} catch (e) {
			console.log("alignElementsToViewportEdge.align() error:" + e);
		}
	}
};

/**
 * Ajax call mark a wiki page for copying
 * @param pageId
 * @param revision
 */
function markPageForCopying(pageId, revision) {
	var postData = {
		"doc_id" : pageId
	};
	if (revision) {
		postData.revision = revision;
	}

	$.ajax({
		url: contextPath + "/ajax/wikis/markPageForCopying.spr",
		data: postData,
		type: "POST",
		cache: false,
		dataType: "json",
		success: function(data) {
			// nothing, the page just marked for copying
		},
		error: function(xhr, textStatus, errorThrown) {
			alert("Error: " + textStatus + " - " + errorThrown);
		}
	});
}

/**
 * Managing the "border" layout of the page plus the header collapsing/expanding
 */
var layoutScripts = {

	applyLayout: false,

	// check if the header is hidden by the cookie
	isHeaderHiddenCookie: function() {
		return $.cookie("CB-headerHidden") === "true";
	},

	setHeaderHiddenCookie: function(hidden) {
		$.cookie("CB-headerHidden", hidden,
			{ path: "/", expires: 90, secure: (location.protocol === 'https:') }
		);
	},

	init: function(applyLayout, buttonTitle, searchHint) {
		layoutScripts.applyLayout = applyLayout;

		layoutScripts.ie9layoutfix();

		applyHintInputBox("#searchFilterOnPopup", searchHint);
		$("#searchFilterOnPopup").keydown(function(e){e.stopPropagation();}); // issue 41027

		// adding toggle toolbar button to header
		var toggler = '<a href="#" onclick="layoutScripts.toggleHeader();return false;" title="' + buttonTitle +'" class="toolbarIcon" id="headerToggler"/>';
		$("#headerTogglerContainer").html(toggler);
	},

	/**
	 * show/hide header according to the cookie
	 * @param toggle If the header state should be toggled
	*/
	updateHeader: function(toggle) {
		var isHeaderHidden = layoutScripts.isHeaderHiddenCookie();
		if (toggle) {
			isHeaderHidden = !isHeaderHidden;
			layoutScripts.setHeaderHiddenCookie(isHeaderHidden);
		}

		$("body").toggleClass("headerCollapsed", isHeaderHidden);
		$("body").trigger("header:visibility:change", isHeaderHidden);

	},

	doLayout: function() {
		if (layoutScripts.applyLayout) {
			$("body").layout().resizeAll();
		}
		if (codebeamer.resizeHandler) {
			codebeamer.resizeHandler.call();
		}

		// recompute the size of all nested layouts as well
		if ($.isArray(codebeamer.nestedLayouts)) {
			$(codebeamer.nestedLayouts).each(function (i, t) {
				t.resizeAll();
			});
		}
	},

	toggleHeader: function() {
		layoutScripts.updateHeader(true);
		jQuery(window).resize(); // trigger some elements in the layout to adjust their size/position
	},

	// IE9 layout fix for issue #256224
	ie9layoutfix: function() {
		if ($('body').hasClass('IE9')) {
			$(document).on("mousemove mouseleave", ".ui-layout-north", function() {
				var $toolbar = $(".toolbar").first();
				var height = $toolbar.height();
				$toolbar.css("height", height);
				// console.log("Fixing toolbar height to " + height);
			});
			var reset = function() {
				//console.log("Removing fixed toolbar height");
				$(".toolbar").first().css("height", "auto");
				layoutScripts.doLayout();
			};
			$(window).resize(function(){
				throttle(reset);
			});
		}
	},

	initLayout: function() {
		layoutScripts.initLayoutFor('body');
	},

	initLayoutFor: function(selector, settings) {
		var defaultSettings = { "applyDefaultStyles": false, "useStateCookie": false,
			"onresize": "codebeamer.resizeHandler",
			"north": {"showOverflowOnHover": true, "spacing_open": 0, "spacing_closed": 0},
			"south": {"spacing_open": 0, "spacing_closed": 0},
			"north__pane_spacing": 0, "south__pane_spacing": 0,
			"resizerClass": "hiddenResizer"
		};
		if (settings) {
			$.extend(defaultSettings, settings);
		}
		var layout = $(selector).layout(defaultSettings);
		return layout;
	}

};

// disables tab-stop to the Tabs and other controls in the header above the wysiwyg editor
// for accessibility and better usability
function disableTabbingToWysiwygTabs() {
	$(".wysiwyg-tabs .ditch-tab-wrap *").each(function() {
		// don't add tabIndex=-1 on select's option otherwise FireFox won't allow clicking on it
		var is_element_option = $(this).is("option") || $(this).is("optgroup");
		if (!is_element_option) {
			$(this).attr("tabIndex", "-1");
		}
	});
	// also disable tabbing to the file upload control
	$(".qq-uploader input[type='file']").attr("tabIndex", "-1");
}

/**
 * Animate/flash/highlight the changed parts, so user can see the changes.
 *
 * Can be called in two ways:
 * 		flashChanged(elements [,targetColor] [,callback] [,duration])
 * 		flashChanged(elements, [,callback] [,duration])
 *
 * @param elements Elements to flash
 * @param targetColor Target color to animate into
 * @param callback The callback function to invoke after the animation ends
 * @param duration Duration of the full animation in millisecs
 * @param onDark If true only the second half of the animation is executed. It looks better on dark elements.
 */
function flashChanged(elements, targetColor, callback, duration, onDark) {
	var $elements = $(elements);
	var originalColor = $elements.css("background-color") || "inherit";
	if (jQuery.isFunction(targetColor)) {
		duration = callback;
		callback = targetColor;
		targetColor = originalColor;
	}
	callback = callback || function() {};
	duration = duration || 1000;
	targetColor = targetColor || originalColor;

	if (onDark) {
		$elements.css({ backgroundColor: 'yellow' });
		$elements.animate({ backgroundColor: targetColor }, duration / 2, "linear", callback);
	} else {
		$elements.animate({ backgroundColor: "yellow" }, duration / 2, "linear", function() {
			$(this).animate({ backgroundColor: targetColor }, duration / 2, "linear", callback);
		});
	}
}

function getLocationHash() {
	var hash = window.location.hash;

	if (hash && hash.length > 0){
		hash = hash.substring(1);
	}
	return hash;
}

/**
 * Convert a time-duration in seconds to String for humans in "4h 5m 12s" format
 * @param d The duration in seconds
 * @returns
 */
function secondsToHms(d) {
	d = Number(d);
	var h = Math.floor(d / 3600);
	var m = Math.floor(d % 3600 / 60);
	var s = Math.floor(d % 3600 % 60);
	var sep = " ";
	var res = [];
	if (h >0) {
		res.push(h +"h");
	}
	if (m >0) {
		res.push(m +"m");
	}
	if (s >0) {
		res.push(s +"s");
	}
	return res.join(sep);
}

/**
 * Serialize the form's data plus add the parameters in the form's action
 * @param form The form element/selector
 */
function serializeFormWithAction(form) {
	var $form=$(form);
	var formdata = $form.serialize();
	// also add the parameters from the form's action
	var formaction = $form.prop("action");
	if (formaction && formaction.indexOf("?") != -1) {
		formaction = formaction.substring(formaction.indexOf("?")+1);
		if (formaction) {
			formdata = formaction + "&" + formdata;
		}
	}
	return formdata;
}

function showOverlayMessage(message, secondsToShow, error, warning) {
	var opts = {
		error: error,
		warning: warning
	};

	if (secondsToShow) {
		opts.secondsToShow = secondsToShow;
	}

	showOverlayMessageWithOptions(message, opts);
}

function showOverlayMessageWithOptions(message, options) {
	codebeamer.overlayNotification.showOverlayMessageWithOptions(message, options);
}

function initializeTreeIconColors($tree) {
	$tree.find("li[iconBgColor] > a .jstree-icon").each(function(index) {
		var color = $(this).closest("li").attr("iconBgColor");
		$(this).css("background-color", color);
	});
}

/**
 * Use this method if you want to handle a series of events that are fired close after each other.
 *
 * see: http://www.nczonline.net/blog/2007/11/30/the-throttle-function/
 *
 * @param method Method to call
 * @param scope This will be the "this"
 * @param throttleScope Several/different methods can be grouped in a throttle, this is the throttle-scope. If null the method param itself is the scope
 * @param timeout Optional timeout in ms how long the function call is throttled.
 */
function throttle(method, scope, throttleScope, timeout) {
	if (!timeout) {
		timeout = 150;
	}
	if (!throttleScope) {
		throttleScope = method;
	}
	clearTimeout(throttleScope._tId);
	throttleScope._tId= setTimeout(function(){
		method.call(scope);
	}, timeout);
}

/**
 * Throttle function wrapper. Takes the input function and creates a new, wrapped one that is
 * identical to the input but can only be called once asynchronously in a specified timeframe.
 * If it's called again before the first execution starts, it will still be called once but
 * gets deferred. If timeframe is over, the wrapped function will be executed.
 *
 * Can be used e.g. to avoid executing resource-expensive AJAX-based event handlers too many times.
 */
function throttleWrapper(callback, millisec) {
	millisec = millisec || 150;
	var timer = null;
	return function () {
		var that = this,
			args = arguments;
		if (timer) {
			clearTimeout(timer);
			timer = null;
		}
		timer = setTimeout(function () {
			callback.apply(that, args);
		}, millisec);
	};
}

/**
 * Wraps a function so that it will behave identically to the original one except the fact that if you call it more
 * than once in the specified timeframe, it will never be executed.
 * @param callback Callback function to wrap
 * @param millisec Timeframe size
 * @returns {Function} Wrapped function
 */
function singleCallWrapper(callback, millisec) {
	millisec = millisec || 150;
	var timer = null;
	var called = false;
	return function () {
		var that = this,
			args = arguments;
		if (!called) {
			timer = setTimeout(function () {
				callback.apply(that, args);
				called = false;
			}, millisec);
		} else {
			clearTimeout(timer);
			timer = setTimeout(function () {
				called = false;
			}, millisec);
		}
		called = true;
	};
}

/**
 * Disables double submit on a form, and shows a message on the second submit
 * @param form
 */
function disableDoubleSubmit(form) {
	var $form = $(form);
	if ($form.prop("noDoubleSubmit")) {
		// avoid double subscribing to the submit event
		return;
	}
	$form.prop("noDoubleSubmit", true);

	$form.submit(function(event) {
		// if the event is already cancelled do nothing
		if (event.isDefaultPrevented()) {
			return false;
		}

		var PROP = "alreadySubmitted";
		if ($(this).prop(PROP) != null) {
			return false;
		}
		$(this).prop(PROP, "true");
	});
}

/**
 * Detect if the browser supports certain css3 features like drop shadow.
 * See: http://net.tutsplus.com/tutorials/html-css-techniques/quick-tip-detect-css-support-in-browsers-with-javascript/
 * If we need more we should bring in http://modernizr.com/
 */
var supports = (function() {
	var div = document.createElement('div'),
		vendors = 'Khtml Ms O Moz Webkit'.split(' '),
		len = vendors.length,
		cache = {};
	var detect = function(prop) {
		if (prop in div.style ) {
			return true;
		}
		prop = prop.replace(/^[a-z]/, function(val) {
			return val.toUpperCase();
		});
		while(len--) {
			if ( vendors[len] + prop in div.style ) {
				// browser supports box-shadow. Do what you need.
				// Or use a bang (!) to test if the browser doesn't.
				return true;
			}
		}
		return false;
	};

	return function(prop) {
		if (cache[prop] != null) {
			return cache[prop];
		}
		var startTime = (new Date()).getTime();
		var value = detect(prop);
		var endTime = (new Date()).getTime();
		console.log("Detected if browser supports " + prop +", value=" + value +", took:" + (endTime-startTime) +"ms");
		cache[prop] = value;
		return value;
	};
})();

/*
 * add outerHtml() function to jquery, becaues Firefox <11 does not support outerHtml natively
 * see: http://stackoverflow.com/questions/2419749/get-selected-elements-outer-html
 */
$.fn.outerHTML = function() {
	$t = $(this);
	if( "outerHTML" in $t[0] ) return $t[0].outerHTML;
	else return $t.clone().wrap('<p>').parent().html();
};

/**
 * escapes the special caracters in a jquery selector. Prepends the \\ string to them (for example '.' is transformed to '\\.')
 * @param selector
 * @returns
 */
function escapeSelector(selector) {
	return selector.replace(/[!"#$%&'()*+,.\/:;<=>?@\[\\\]^`{|}~]/g, '\\$&');
}

/**
 * Escapes HTML entities in a string
 * @param str String to escape
 * @returns {string} Escaped string
 */
function escapeHtmlEntities(str) {
	return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

/**
 * Escape HTML
 * @param str
 * @returns
 */
function escapeHtml(str) {
	return $('<div/>').text(str).html();
}

/**
 * Clear all selection being made on the browser
 * Use to clear selection after the double clicking starts the inplace editing...
 */
function clearSelection() {
	if(document.selection && document.selection.empty) {
		document.selection.empty();
	} else if(window.getSelection) {
		var sel = window.getSelection();
		sel.removeAllRanges();
	}
}

/**
 * Get the text which is selected anywhere on the page.
 * see: http://stackoverflow.com/questions/5379120/get-the-highlighted-selected-text
 * @returns {String}
 */
function getSelectionText() {
    var text = "";
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != "Control") {
        text = document.selection.createRange().text;
    }
    return text;
}

/**
 * If anything is selected on the page ?
 */
function hasSelection() {
	var selectionText = getSelectionText();
	return (selectionText != null && selectionText != "");
}

/**
 * prevents submitting a form on pressing enter. instead, ctrl+enter wil trigger the submission.
 * @param form the id of the form
 */
function setupKeyboardShortcuts(formId) {
	var $form = $('#' + formId);

	var triggerSubmitForm = function () {
		var $form = $('#' + formId);

		// add "noAutoSubmit" class to container if you want to prevent auto submitting of this form
		if ($form.closest(".noAutoSubmit").length == 0) {
			var $submitButton = $form.find("[type=submit]").first();
			$submitButton.click();
		}
	};

	$form.find('input, select').keypress(function(event) {
		if (event.keyCode == 13) {
			if (!event.ctrlKey) {
				event.preventDefault();
				return false;
			}
		}
	});
}

var UrlUtils = (function() {

	/**
	 * Extract URL-style parameters from URL hash part.
	 * Example: #!a=1&b=2&c
	 * Result: {a:1, b:2, c:undefined}
	 * @returns object An object containing the extracted key-value pairs.
	 */
	function getHashParameters() {
		var result = {};
		if (window.location.hash.indexOf("#!") === 0) {
			var hash = window.location.hash.substring(2);
			if (hash != "") {
				jQuery.each(hash.split("&"), function() {
					var a = this.split("=");
					result[a[0]] = a[1];
				});
			}
		}
		return result;
	}

	/**
	 * Generate a hash parameter string from the specified object that can be used in a URL.
	 * Example: {a:1, b:2}
	 * Result: #!a=1&b=2
	 * @param params Input parameter object
	 * @returns {string} Encoded hash string
	 */
	function generateHashParameters(params) {
		return "#!" + $.map(params, function(value, key) {
				return key + "=" + encodeURIComponent(value);
			}).join("&");
	}

	/**
	 * Add or replace parameter(s) inside a URL.
	 * @param url URL to update
	 * @param paramName Parameter name (can be an array of parameter names, all will be replaced in this case)
	 * @param paramValue Parameter value
	 */
	function addOrReplaceParameter(url, paramName, paramValue) {
		if ($.isArray(paramName)) {
			$(paramName).each(function() {
				url = addOrReplaceParameter(url, this, paramValue);
			});
			return url;
		} else {
			var containsParam = new RegExp("[\\?&]" + paramName + "=").test(url);
			if (containsParam) {
				var pattern = new RegExp("([^\\w])" + paramName + "(=[\\w\\-\\.]*)");
				if (paramValue) {
					return url.replace(pattern, "$1" + paramName + "=" + encodeURIComponent(paramValue));
				} else {
					return url.replace(pattern, "$1").replace(/\?&/, "?").replace(/[\?&]$/, "");
				}
			} else {
				if (url.substr(url.length - 1) == "#") {
					url = url.substr(0, url.length - 1); // remove the hashmark from the end of the url
				}
				return url + (url.indexOf("?") == -1 ? "?" : "&") + paramName + "=" + paramValue;
			}
		}
	}

	function getParameter(url, paramName) {
		if (arguments.length == 1) {
			paramName = url;
			url = window.location.href;
		}
		var questionMarkPos = url.indexOf("?");
		if (questionMarkPos != -1) {
			url = url.substr(questionMarkPos + 1);
		}
		var hashMarkPos = url.indexOf("#");
		if (hashMarkPos != -1) {
			url = url.substr(0, hashMarkPos);
		}
		var parts = url.split("&");
		for (var i = 0; i < parts.length; i++) {
			var part = parts[i];
			var pair = part.split("=");
			var name = pair[0];
			var value = pair.length > 1 ? pair[1] : "";
			if (name == paramName) {
				return value;
			}
		}
		return "";
	}

	function removeParameter(url, paramName) {
		var rtn = url.split("?")[0],
			param,
			params_arr = [],
			queryString = (url.indexOf("?") !== -1) ? url.split("?")[1] : "";
		if (queryString !== "") {
			params_arr = queryString.split("&");
			for (var i = params_arr.length - 1; i >= 0; i -= 1) {
				param = params_arr[i].split("=")[0];
				if (param === paramName) {
					params_arr.splice(i, 1);
				}
			}
			rtn = rtn + "?" + params_arr.join("&");
		}
		return rtn;
	}

	return {
		getHashParameters: getHashParameters,
		generateHashParameters: generateHashParameters,
		addOrReplaceParameter: addOrReplaceParameter,
		getParameter: getParameter,
		removeParameter: removeParameter
	};
})();

function loadToolbarMenuitems(argumentString) {
	var initParams = {context:[getToolbarTab(toolBarId), 'tl', 'bl', ['beforeShow', 'windowResize'], [0,1]], openOnClick:true, constraintoviewport:false};
	var menu = $(this);
	var tabId = menu.selector.substring(1, menu.selector.lastIndexOf('_'));
	var toolBarId = tabId + '_ToolBarItem';
	var popupCount = $('#' + toolBarId + 'popup li').length;

	var data = {
		'tabId' : tabId,
		'projectId' : codebeamer.projectId,
		'revision' : getUrlParameter('revision')
	};
	if (argumentString) {
		var args = argumentString.split(",");
		for (var i = 0; i < args.length; i++) {
			var arg = args[i];
			var argParts = arg.split("=");
			data[argParts[0]] = argParts[1];
		}
	}

	if (popupCount === 0) {
		var img = $('#' + toolBarId).find('.menuArrowDown');
		img.addClass('loadingBgImg');

		$.ajax({
			method: 'GET',
			url: contextPath + '/toolbarPopupItems.spr',
			data: data
		}).done(function(data) {
			var html = $(data).find('.yuimenu').html();
			menu.html(html);

			initTopMenu(toolBarId, initParams);
			menu.show();

		}).always(function() {
			img.removeClass('loadingBgImg');
		});
	}
}

/**
 * Workaround to keep the jquery.ui.tooltip open when the mouse hovers over,
 * so users can interact/click on the tooltip's content
 * see: http://stackoverflow.com/questions/13286514/jquery-ui-tooltip-set-timeout-and-set-hover-events-freeze-tooltip-on-mouseover/15014759#15014759
 *
 * Usage: call this in the close() event handler of tooltip!
 */
function jquery_ui_keepTooltipOpen(ui, delay) {
	if (! delay) {
		delay = 400;
	}
	ui.tooltip.hover(
		function () {
			$(this).stop(true).fadeTo(delay, 1);
			//.fadeIn("slow"); // doesn't work because of stop()
		},
		function () {
			$(this).fadeOut(delay, function(){ $(this).remove(); });
		}
	);
}

/**
 * Helper function to check if user wants to navigate away with a mouse click, based on the mouse event.
 * @param event Mouse event (native or jQuery-normalized)
 * @returns boolean True if left mouse button is pressed WITHOUT ctrl key down (that would indicate an 'open in new tab' action
 */
function isLeftClickWithoutCtrl(event) {
	event = jQuery.event.fix(event); // if a native event is passed
	var leftMouseButtonPressed = (event.button == 0);
	var ctrlBeingPressed = (typeof event.ctrlKey != "undefined") && (event.ctrlKey === true);
	return leftMouseButtonPressed && !ctrlBeingPressed;
}

/**
 * Show something (for example a dialog) on hover, but:
 * - only show if the mouse stays over the element for a short period to avoid that the dialog appears when mosue moves over the element accidenttaly
 * - automatically hide the element when the mouse leaves it
 *
 * @param trigger The element will show the "overlay" element when mouse moves over
 * @param overlay The overlay element will be shown
 * @param showFunction The callback function will show the "overlay" element
 * @param hideFunction The callback function will hide the "overlay" element
 * @param showDelay Optional delay (300ms) the overlay will be only shown if the mouse longer stays over the "trigger" than this
 * @param hideDelay When mouse leaves triver AND overlay the overlay will be hidden after that many ms
 */
function showOnHoverAndAutoHide(trigger, overlay, showFunction, hideFunction, showDelay, hideDelay) {
	if (showDelay == null) {
		showDelay = 300;
	}
	if (hideDelay == null) {
		hideDelay = 3000;
	}

	// only show the overlay if the mouse stays on the trigger for a short time to avoid accidentally displaying it
	var cancelShow = function() {
		var showTimer = $(overlay).data("showTimer");
		window.clearTimeout(showTimer);
	};
	var scheduleShow = function() {
		var showTimer = setTimeout(showFunction, showDelay);
		$(overlay).data("showTimer", showTimer);
	};
	$(trigger).off("hover").hover(scheduleShow, cancelShow);

	// automatically hiding the overlay if the mouse leaves it after few seconds
	var cancelHide = function() {
		var hideTimer = $(overlay).data("hideTimer");
		window.clearTimeout(hideTimer);
	};
	var scheduleHide = function() {
		cancelHide();
		// hide the dialog xxx seconds after moved out from that
		var hideTimer = setTimeout(hideFunction, hideDelay);
		$(overlay).data("hideTimer", hideTimer);
	};
	$(overlay).off("hover").add(trigger).hover(cancelHide, scheduleHide);
}

/**
 * Force image relaods inside elements
 * @param elements
 */
function forceImageReload(elements) {
	$(elements).find("img").each(function() {
		// force reloading images, because the browser does not always do this
		var src = $(this).attr("src");
		src += (src.indexOf("?") == -1 ? "?" : "&") + "rnd=" + Math.random();
		$(this).attr("src", src);
	});
}

// IE8 polyfill for Array.prototype.filter(), source: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array/filter
if (!Array.prototype.filter) {
	Array.prototype.filter = function(fun /*, thisArg */) {
		"use strict";

		if (this === void 0 || this === null)
			throw new TypeError();

		var t = Object(this);
		var len = t.length >>> 0;
		if (typeof fun !== "function")
			throw new TypeError();

		var res = [];
		var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
		for (var i = 0; i < len; i++) {
			if (i in t) {
				var val = t[i];

				// NOTE: Technically this should Object.defineProperty at
				//       the next index, as push can be affected by
				//       properties on Object.prototype and Array.prototype.
				//       But that method's new, and collisions should be
				//       rare, so use the more-compatible alternative.
				if (fun.call(thisArg, val, i, t))
					res.push(val);
			}
		}

		return res;
	};
};

function handleDateFilter(formId, interval) {
	var $form = $("#" + formId);
	var $input = $("<input>", {"name": "lastModifiedAtDuration", "type": "hidden"}).val(interval);
	$form.prepend($input);
	$form.submit();
}

function findElementUnderCursor($elements, offsetX, offsetY) {
	var $result = null;
	$elements.each(function() {
		var e = $(this);
		var pos = _getAbsolutePosition(e);
		var x1 = pos.left;
		var y1 = pos.top;
		var x2 = x1 + e.width();
		var y2 = y1 + e.height();
		if (offsetX <= x2
			&& offsetX >= x1
			&& offsetY <= y2
			&& offsetY >= y1) {
			$result = e;
		}
	});
	return $result;
}

/**
 * computes the absolute position of an element.
 * @param $e
 * @returns
 */
function _getAbsolutePosition($e) {
	var left = 0;
	var top = 0;
	if ($e.offsetParent()) {
		do {
			left += $e.position().left;
			top += $e.position().top;
			var g = $e.offsetParent();
			if ($e.is("body") || $e.is("html") || $e == $e.offsetParent()) {
				break;
			}
		} while ($e = $e.offsetParent());
	}
	return {
		"left": left,
		"top": top
	};
}

function autoAdjustPanesHeight($window) {
	var $window = $window || $(window);
	var panes = $("#panes");
	if (panes.length == 0) {
		return;
	}
	var sidePanes = panes.find("#east,#west");
	var rightPane = panes.find("#rightPane");

	var footerHeight = $("#footer").outerHeight();
	var newPanesHeight = $window.innerHeight() - panes.offset().top - footerHeight;
	panes.height(newPanesHeight);
	autoAdjustResizerHeight(newPanesHeight);
	var centerPane = panes.find(".ui-layout-center");
	var actionBarHeight = centerPane.find(".actionBar").first().outerHeight();
	centerPane.add(sidePanes).height(newPanesHeight);

	var $toolbarContainer = $('#toolbarContainer');
	rightPane.height(newPanesHeight - actionBarHeight - $toolbarContainer.height());
}

function autoAdjustResizerHeight(height) {
	var resizer = $("#panes").find(".ui-layout-resizer");
	resizer.height(height);
}

function createInfoMessageBox(htmlMessage, classes) {
	var li = $("<li>").html(htmlMessage);
	var ul = $("<ul>").append(li);
	var message = $("<div>", {
		"class": (classes ? classes : "") + " onlyOneMessage"
	}).append(ul);
	return $("<div>", {
		"class": "infoMessages"
	}).append(message);
}

$.fn.setCursorToTextEnd = function() {
	var elem = this.get(0);
	var elemLen = elem.value.length;
	try { // not supported in Chrome for input type "number"
		elem.selectionStart = elemLen;
		elem.selectionEnd = elemLen;
	} catch(ex) { }

	elem.focus();
};

/**
 * Parses a reference ID string to obtain its parts. Format is: [groupType-]id[/revision].
 * Examples: 5-12345/32, 5-12345, 12345/32, 12345
 * @param referenceId A reference ID string
 * @returns {{groupType: (T|*), id: (T|*), revision: (T|*)}}
 */
function parseReferenceId(referenceId) {
	var parts = referenceId.match(/(?:(\d+)\-)?(\d+)(?:\/(\d+))?/).slice(1);
	return {
		groupType: parts[0],
		id: parts[1],
		revision: parts[2]
	};
}

function hangoutsButton(id) {
	// see: https://developers.google.com/+/hangouts/button

	var render = function() {
		var invitesVal = $("#invites_" + id).val();

		// split by space or ","
		var invites = invitesVal.split(/[ \s,]+/);
		var invitesArr = [];
		for (var i=0; i<invites.length; i++) {
			invitesArr.push({"id": invites[i], "invite_type" : "EMAIL"});
		}

		var button = "placeholder-div" + id;
		gapi.hangout.render(button, {
			'render': 'createhangout',
			'initial_apps': [{'app_id' : '184219133185', 'start_data' : 'dQw4w9WgXcQ', 'app_type' : 'ROOM_APP' }],
		    'widget_size': 72,
		    'invites' : invitesArr
		});
	};

	// check if gapi/platform.js is loaded ?
	if(typeof gapi === 'undefined'){
		window.renderButtons = render;
		// load platform.js dynamically, it will can renderButtons when loaded !
		(function(){
			var po = document.createElement('script');
			po.type = 'text/javascript';
			po.async = true;
			po.src = 'https://apis.google.com/js/platform.js?onload=renderButtons';
			var s = document.getElementsByTagName('script')[0];
			s.parentNode.insertBefore(po, s);
			})();
	} else {
		render();
	}

}

/**
 * Set all elements to their max height.
 * Usage: $(‘div.unevenheights’).setAllToMaxHeight()
 * @returns {*}
 */
jQuery.fn.setAllToMaxHeight = function(){
	return this.height(Math.max.apply(this, $.map(this, function(e) {
		return $(e).height();
	})));
};

function filterList(selector, phrase) {
	var $allListElements = $(selector);
	filterElementList($allListElements, phrase);
}

function filterElementList($elements, phrase) {
	if (phrase && phrase.length > 1) {
		var $matchingListElements = $elements.filter(function(i, el){
			return $(el).text().toLowerCase().indexOf(phrase) !== -1;
		});

		$elements.hide();
		$matchingListElements.show();
	} else {
		$elements.show();
	}
}


/**
 * Show/hide wikiErrorDetails on click
 */
$(document).on("click", ".error", function() {
	$(this).find(".wikiErrorDetails").toggle();
});

/**
 * executes  a javascript function by name. it works also for namespaced functions.
 * @param functionName
 * @param context
 * @returns
 */
function executeFunctionByName(functionName, context /*, args */) {
	var args = [].slice.call(arguments).splice(2);
	var namespaces = functionName.split(".");
	var func = namespaces.pop();
	for(var i = 0; i < namespaces.length; i++) {
		context = context[namespaces[i]];
	}
	return context[func].apply(this, args);
}

/**
 * Show context help when mouse moves over an html element with "withContextHelp" css class.
 *
 * The context-help will be:
 * * shown in an small tooltip
 * * the "title" of the element is shown in the tooltip. This can just contain an i18n code, the tooltip will resolve this automatically!
 * * the tooltip can contain rich text and links
 * * the tooltip will stay open so users can move the mouse over and click on the links in the tooltip text
 */
function initContextHelps() {
	var selector = ".withContextHelp";
	$(document).tooltip({
		items: selector,
		tooltipClass : "tooltip contextHelpTooltip",
		position: {my: "left top+5" , collision: "flipfit"},
		content: function() {
			var contextHelp = $(this).attr("title");
			var text = i18n.message(contextHelp);
			return text;
		},
		close: function(event, ui) {
			jquery_ui_keepTooltipOpen(ui);	// keep it open so mouse can move over the tooltip and click on links inside
		}
	});
}
$(initContextHelps);

/**
 * When clicking on a table's row it will select a checkbox or radio button inside of that row
 */
function clickOnTableRowSelectsInside(tableSelector, checkboxSelector) {
	$(tableSelector).click(function(event) {
		var $target = $(event.target);
		if ($target.is(checkboxSelector)) {
			return;	// do nothing if clicked on the radio button itself
		}

		var $tr = $(this).closest("tr");
		$tr.find(checkboxSelector).first().prop('checked', true);
		return false;
	});
}

function setThumbnailPluginImageSize(img) {
	var width = img.naturalWidth;
	var height = img.naturalHeight;

	var thumbnailWidth = $(img).attr("thumbnailWidth");
	var thumbnailHeight = $(img).attr("thumbnailHeight");

	// only resize if the image is larger than the desired size, smaller images are not enlarged
	if (!(width < thumbnailWidth && height < thumbnailHeight)) {
		if (width != thumbnailWidth || height != thumbnailHeight) {
			var ratio = Math.min(thumbnailWidth / width, thumbnailHeight / height);
			width = width * ratio;
			height = height * ratio;
		}

		$(img).width(width);
		$(img).height(height);
	}
	$(img).show();
}

/**
 * Method prevents double-click, but will call handler on the single-click (after some short time)
 *
 * @param event The click event
 * @param handler The handler method called a bit later when single clicked on an element
 * @param log The name of the click-element apparing in the log
 */
function onlyOnSingleClick(event, handler, log) {
	var doubleClickTimeout = 300; // ms

	var $clicked = $(event.target);
	if ($clicked.length == 0) {
		return;
	}

	var WILL_CALL = "onlyOnSingleClick_willCallHandler";
	var CANCEL_CALL = "onlyOnSingleClick_cancelCall";

	// don't call handler for the same event multiple times
	if (event.onlyOnSingleClickHandled) {
		console.log("Avoid calling the same event twice on " + log);
		return;
	}
	event.onlyOnSingleClickHandled = true;

	console.log("Clicked on:" + log);
	if ($clicked.hasClass(WILL_CALL)) {
		$clicked.addClass(CANCEL_CALL);
		console.log("Preventing double click on " + log);
		return;
	}

	$clicked.addClass(WILL_CALL);
	setTimeout(function () {
		if ($clicked.hasClass(CANCEL_CALL)) {
			console.log("Not calling handler because double-click detected" + log);
		} else {
			handler();
		}
		$clicked.removeClass(WILL_CALL + " " + CANCEL_CALL);
	}, doubleClickTimeout);
}

var thumbnailImages = {

	// if already initialized?
	initialized: false,

	// the selector for container of thumbnailImages
	selector: ".thumbnailImages,.thumbnailImages200px,.thumbnailImages300px,.thumbnailImages400px,.thumbnailImages480px,.thumbnailImages600px,.thumbnailImages800px,.thumbnailImages1000px,.thumbnailImages1200px," +
			  ".thumbnailImages20pct,.thumbnailImages25pct,.thumbnailImages33pct,.thumbnailImages50pct,.thumbnailImages75pct,.thumbnailImages150pct",

	init:function() {
		thumbnailImages.initLightbox();

		if (thumbnailImages.initialized) {
			return;
		}
		console.log("initializing ThumbnailImages");
		thumbnailImages.initialized = true;
		// if a mouse moves over a .thumbnailImages, then ensure that is initialized
		// DOM is not always ready on mouseenter, so this initialisation is done sometimes too early...
		$('body').on("mouseenter", thumbnailImages.selector, function() {
			if ($(this).closest('.editor-wrapper').length) {
				return;
			}
			thumbnailImages.initThumbnailImageControl(this);
		});

		// if an image inside an .thumbnailImages is clicked then start lightbox
		$('body').on("click", thumbnailImages.selector, function(event) {
			var $clicked = $(event.target);
			if (thumbnailImages.shouldDisplayLightBox($clicked)) {
				var src = $clicked.attr("src");

				// FIX for #982896
				if (!$clicked.attr('data-lightbox')) {
					var $container = $clicked.closest(thumbnailImages.selector);
					if ($container.length) {
						// reinitialize container
						thumbnailImages.initThumbnailImageControl($container[0]);
					}
				}

				onlyOnSingleClick(event, function() {
					lightbox.start($clicked);
				}, src);
			}
		});
	},

	/**
	 * If this image should be displayed in lightbox?
	 * @param element The image element
	 * @returns {Boolean}
	 */
	shouldDisplayLightBox: function(element) {
		var $element = $(element);
		if ($element.is("img")) {
			// if this img is inside an <a> element that is just a image-link, don't show lightbox there
			var $parentLinks = $element.parents("a");
			if ($parentLinks.length >0) {
				for (var i=0; i<$parentLinks.length; i++) {
					var $a = $($parentLinks.get(i));
					var link = $a.attr("href");
					if (link != null && link != "") {
						return false;
					}
				}
			}

			var src = $element.attr("src");
			// don't show lightbox for local images/icons in /cb/images directory
			if (src == null || src.indexOf(contextPath + "/images/") == 0) {
//				console.log("Will not show thumbnail for " + src);
				return false;
			}
			return true;
		}
		return false;
	},

	/**
	 * initialize lightbox on page
	 * @returns {Boolean}
	 */
	initLightbox: function() {
		if (typeof lightboxIncluded === 'undefined') {
			lightboxIncluded = true;
			lightbox.init();
			//console.log("Initialized lightbox!");
			return true;
		}
		return false;
	},

	/**
	 * Initialize thumbnail-image control for the container
	 * @param control The container with .thumbnailImages css class
	 */
	initThumbnailImageControl: function(control) {
		initImagesForLightbox = function($control, lightboxId) {
			$control.find("img").each(function() {
				var $element = $(this);
				// check if already has lightbox-id, then skip
				if ($element.attr("data-lightbox") != null) {
					return;
				}

				if (thumbnailImages.shouldDisplayLightBox($element)) {
					$element.attr("data-lightbox", lightboxId);
					// lightbox expects the href attribute
					var src = $element.attr("src");
					$element.attr("href", src);
				}
			});
		}

		var $control = $(control);
		var lightboxId = $control.attr("data-lightbox");
		if (lightboxId == null) {
			$control.addClass("thumbnailImagesInitialized");
			// does not have lightbox-id, create one and add to all children images
			var lightboxId = "thumbnailImages_" + (new Date().getTime());
			$control.attr("data-lightbox", lightboxId);
		} else {
			console.log("Reinitializing already initialized control:" + lightboxId);
		}

		initImagesForLightbox($control, lightboxId);
	}
};

$(thumbnailImages.init);

/**
 * Load/Save an UserSetting with ajax
 */
var userSettings = {
	save : function(userSetting, value) {
//		throttleWrapper(function() {		// TODO: should throttle saving automatically?
		$.post(contextPath + "/userSetting.spr?name=" + userSetting , {
		    "value": value
        });
//		}, 1000);
	},

	/**
     * Async load of user settings
	 * @param userSetting The userSetting to load
	 * @param success Callback function gets the userSetting value
	 * @param fail Optional callback function called when setting is missing, can be null, can be used to set the default value
     * @param sync If set to true then the usersetting load is waited
	 */
	load : function(userSetting, success, fail, async) {
	    if (async == null) {
	        async = true;
        }

        return $.ajax({type: "GET",
            url: contextPath + "/userSetting.spr?name=" + userSetting,
            async: async
        }).success(function(data) {
            success(data);
        }).fail(function(data) {
            if (fail != null) {
                fail(data);
            }
        });
	},

    /**
     * Synchronous load of user-settings
     */
	loadSync : function(userSetting, success, fail) {
	    return load(userSetting, success, fail, false);
	}
};

/**
 * Save and restore a window's position and size in a UserSetting variable
 * @param userSetting The UserSetting's name
 * @param load If it should load the window's dimension and move the window ?
 */
function keepWindowDimensions(userSetting, load) {

	// get the window's dimensions string
	var getDimensions = function() {
		// dimensions is window's "left,top,width,height" values comma separated
		var	left = window.screenX;
		var	top = window.screenY;
		var width = window.innerWidth;
		var height = window.innerHeight;

		var dim = left +"," + top +"," + width +"," + height;
		return dim;
	};

	// Check if the dimensions has changed and keep the value for next check
	// @param dim The new dimensions
	// @return Null if this is same dimensions as previously, or the previous dimensions
	var setPrevDimensions = function(dim) {
		// init if null
		keepWindowDimensions.previousDimensions = keepWindowDimensions.previousDimensions || {};
		var previousDimensions = keepWindowDimensions.previousDimensions;

		var prev = previousDimensions[userSetting];
		previousDimensions[userSetting] = dim;

		if (prev == dim) {
			// same as before: return null
			return null;
		}
		return prev;
	};

	// set up the initial window dimension to avoid always saving window position at startup in TestRunner
	setPrevDimensions(getDimensions());

	var saveDimensions = function() {
		var dim = getDimensions();

		// don't save if already have the same value
		var changed = setPrevDimensions(dim);
		if (changed) {
			console.log("Saving dimensions <" + dim +"> to " + userSetting +", previous value:<" + changed +">");
			userSettings.save(userSetting, dim);
		} else {
			// same as before
			// console.log("Not saving dimensions to " + userSetting +" because same as before <" + dim +">");
		}
	};

	var startSaving = function() {
		// save the location periodically, using a timer because there is no event when the window is moved
		setInterval(function() {
			saveDimensions();
		}, 2000);
	};

	if (load) {
		// restore dimensions
		userSettings.load(userSetting, function(dim) {
			try {
				setPrevDimensions(dim);
				if (dim == null) {
					startSaving();
				} else {
					var parts = dim.split(",");
					// console.log("Moving/Resizing window to " + dim +" (" + parts +")");

					var setDimensions = function() {
						// not a mistake: somehow this is the way it works
						window.moveTo(parts[0], parts[1]);
						window.resizeTo(parts[2], parts[3]);
						window.moveTo(parts[0], parts[1]);

						startSaving();
					}

					// change location/size a bit later
					window.setTimeout(setDimensions, 200);
				}
			} catch(ex) {
				console.log("Can not load window dimension <" + dim +">");
				startSaving();
			}
		}, function() {
			startSaving();
		});
	} else {
		startSaving();
	}
}

/**
 * stick the footer to the bottom
 */
function setupStickFooterToBottom() {
	var $body = $("body");
	var $window = $(window);
	var isIE = $body.hasClass('IE');
	var isIE8 = $body.hasClass('IE8');
	var footer = $("#footer");
	var isAutoAdjust = $('#panes').hasClass('autoAdjustPanesHeight');
	codebeamer.enableFooterAutoPositioning = true;
	var stickFooterToBottom = function() {
		if (!codebeamer.enableFooterAutoPositioning) {
			return ;
		}
		if (isIE && isAutoAdjust) { // Adjust panes' heights in IE8
			footer.addClass("stickToBottom").css("visibility", "visible");
			autoAdjustPanesHeight();
		} else {
			var docHeight = $body.height();
			var windowHeight = $window.height();
			var stickToBottom = docHeight < windowHeight;
			// console.log("stick to bottom: " + stickToBottom +", body-height:" + docheight +", win-height:" + windowheight);
			footer.toggleClass("stickToBottom", stickToBottom).css("visibility", "visible");
		}
	};
	// Note: if throttleWrapper is used, footer is vibrating in IE8, so disabled throttling in IE8
	var throttledStickFooterToBottom = isIE8 ? stickFooterToBottom : throttleWrapper(stickFooterToBottom, 100);
	$(throttledStickFooterToBottom);
	$(window).scroll(throttledStickFooterToBottom)
			.resize(throttledStickFooterToBottom);
	setInterval(throttledStickFooterToBottom, 500); // periodically update in case the document dynamically changes
}


/**
 * bins a map of hotkeys (with special care for textareas)
 * @param hotkeyMap
 */
function mapHotKeys(hotkeyMap) {
	$(function() {
		//  hotkeys...
		$(document).mapHotKeys(hotkeyMap);
		if ($("body").hasClass("popupBody")) {
			// special binding to textareas because these seems to not bubble the key events up
			$(document).find("textarea,.imagePasteAwareEditor").mapHotKeys(hotkeyMap);
		}
	});
}

// build the hotkeys table based on the registered hotkeys
function buildHotkeysTable() {
	var registeredHotkeys = codebeamer.HotkeyRegistry.getRegisteredHotkeys();
	if (registeredHotkeys) {
		if (typeof hotkeysTableBuilt !== "undefined") {
			return;
		}
		hotkeysTableBuilt = true;
		//console.log("Building hotkeys table:" + registeredHotkeys);

		var $table = $("#hotkeysHint table");
		for (var i = 0; i < registeredHotkeys.length; i++) {
			var mapping = registeredHotkeys[i];
			if (mapping && mapping.documentation) {
				var $tr = $("<tr>");
				var $keyTd = $("<td>", {"class": "hotkey-description"}).html(codebeamer.HotkeyFormatter.getLabel(mapping.key));
				var $documentationTd = $("<td>").html(i18n.message(mapping.documentation));
				$tr.append($keyTd);
				$tr.append($documentationTd);
				$table.append($tr);
			}
		}
	}
};

// toggle hotkeys on footer
function toggleHotkeys(conf) {
	var left, right;

	// ensure that hotkeys table is built
	buildHotkeysTable();

	$("#hotkeysHint table").toggle();

	var $hints = $("#hotkeysHint");
	$hints.toggle();

	if (conf && conf.align && conf.align === "right") {
		left = 'auto';
		right = $("#hotkey-toggle").position().right;
	} else {
		left = $("#hotkey-toggle").position().left;
		right = 'auto';
	}

	if (!$hints.is(".initialized")) {
		var height = $hints.height();
		var $toggle = $("#hotkey-toggle");
		//var layoutApplied= $("meta[name=applyLayout]").attr("content") == "true";
		var layoutApplied = $(document).height() <= $(window).height();
		$hints.css({
			left: left,
			top: layoutApplied ? 'auto' : $toggle.position().top - 20 - $hints.height(),
			right: right,
			height: height
		});
		$hints.addClass("initialized");
	}
}

function reloadLibraryTree(paneId, type, option) {
	var tree = $.jstree.reference("#" + paneId);
	if (tree) {
		var $treePane = $("#" + paneId);

		$treePane.one("refresh.jstree", null, function () {
			var filterText = $("#searchBox_" + paneId).val();
			if (filterText && filterText.length > 2) {
				tree.search(filterText);
			}
		});

		tree.refresh();
	}

	userSettings.load("LIBRARY_TREE_FILTERS", function (settings) {
		settings =  settings ? JSON.parse(settings) : {};

		settings[type] = option;

		userSettings.save("LIBRARY_TREE_FILTERS", JSON.stringify(settings));
	});


};

/**
 * Get an image's natural height/width from an url.
 * Because this has to wait for the image to be loaded it is using a callback function, which is called as soon as
 * the image is loaded, or can time-out if the image is not loaded
 * @param url The image's url
 * @param callback The callback called with width/height after the image loaded. The width/height migt be null if the image size can not be determined
 * @param timeout The time-out how long you can wait for the image. Optional, defaults to 200ms
 */
function fetchImageSize(url, callback, timeout) {
	var img = new Image();

	// timer for timeout
	if (timeout == null|| timeout <= 0) {
		timeout = 200;
	}
	var timer = setTimeout(function() { passResult(null) }, timeout);

	var passResult = function(width, height) {
		if (! callback.called) {	// ensure the callback is only called once
			callback.called = true;
			callback(width, height);
			// clear the timer if that still runs
			clearTimeout(timer);
		}
	}

	img.onload = function() {
		var width = this.width;
		var height = this.height;
		passResult(width, height);
	}
	img.src = url;
}

function initializeHighchartLocalization(thousandsSep, decimalPoint) {
	if (Highcharts) {
		var weekdays = i18n.message("calendar.weekdays_long");
		var months = i18n.message("calendar.months_long");
		var shortMonths = i18n.message("calendar.months_short");

		var langOptions = {};

		if (thousandsSep) {
			langOptions["thousandsSep"] = thousandsSep;
		}

		if (decimalPoint) {
			langOptions["decimalPoint"] = decimalPoint;
		}

		var config = [
		   [weekdays, 'weekdays'],
		   [months, 'months'],
		   [shortMonths, 'shortMonths']
		];

		$.each(config, function (i, part) {
			if (part[0]) {
				langOptions[part[1]] = part[0].split(",");
			}
		})


		Highcharts.setOptions({
			lang: langOptions,
			global: {
				// don't normalize to UTC otherwise the dates on the axes will be of by some hours that can result to showing wrong dates
				useUTC: false
			}
		});
	}
}

function showDocumentDiagramEditor(url) {
	$.post(contextPath + "/mxGraph/artifactPermission.spr", {proj_id: getParameterByName("proj_id", url), dir_id: getParameterByName("dir_id", url), doc_id: getParameterByName("doc_id", url)}).done(function(data) {
		// diagram editor should be displayed in full screen
		var param = {};
		if (url.indexOf("revision=") != -1) {
			// viewer
			param["geometry"] = "90%_90%";
		} else {
			// editor
			param["geometry"] = "100%_100%";
		}
		// check the permission from response
		if (data == "read-write") {
			showPopupInline(url, param);
		} else if (data == "read") {
			url += "&viewer=true";
			showPopupInline(url, param);
		} else {
			showFancyAlertDialog(i18n.message("mxgraph.editor.no.read.permission"), null, "200px");
		}
	}).fail(function(response) {
		showFancyAlertDialog(i18n.message("mxgraph.editor.no.permission"), null, "200px");
	});
}

function generateReports() {
	// find selected items
    var Tracker = codebeamer.trackers.Tracker.prototype;
    var items = Tracker.getSelectedIssuesFromTree();

    // when the table view is shown collect the ids of the selected checkboxes
    $("input[name='clipboard_task_id']:checked").each(function() {
        items.push($(this).val());
    });

	for (var i = 0; i < items.length; ++i) {
		items[i] = parseInt(items[i]);
	}
	if (items === undefined || items.length == 0) {
		showFancyAlertDialog(i18n.message("rpe.not.selected"), null);
	} else {

		if (items.length > 1) {
            showFancyAlertDialog(i18n.message("rpe.not.selected"), null);
            return;
        }

		var busyDialog = ajaxBusyIndicator.showBusyPage()
		// send it to document generator
		$.post(contextPath + "/rpe/generate.spr", { "itemId" : parseInt(items[0]) }).always(function() {
			// close busy dialog and refresh page
			if (busyDialog) {
				try {
					busyDialog.dialog("destroy").remove();
				} catch(ex) {
					//
				}
			}
			location.reload();
		});
	}
}

function showTrackerConfigurationDiagram(url) {
	showPopupInline(url, { geometry: "90%_90%" });
}
function getParameterByName(name, url) {
	name = name.replace(/[\[\]]/g, "\\$&");
	var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
		results = regex.exec(url);
	if (!results) return null;
	if (!results[2]) return '';
	return decodeURIComponent(results[2].replace(/\+/g, " "));
}

/**
 * the original $.support.boxSizingReliable() function misses error handling. this small extension reuses that function and wraps it
 * into a try catch block. this is necessary because on hidden iframes (example: opening a popup dialog) this function always
 * throws an exception in firefox which block all the other scripts on the page (https://bugzilla.mozilla.org/show_bug.cgi?id=548397).
 * issue #673741
 */
(function() {
	function fixFFGetComputedStyleBug() {
		// workaround for a FF bug:  https://bugzilla.mozilla.org/show_bug.cgi?id=548397
		// see: http://stackoverflow.com/questions/32659801/javascript-workaround-for-firefox-iframe-getcomputedstyle-bug
		console.log("Fixing Firefox bug for missing getComputedStyle() bug in hidden iframes");
		window.oldGetComputedStyle = window.getComputedStyle;
  	    window.getComputedStyle = function (element, pseudoElt) {
		      var t = window.oldGetComputedStyle(element, pseudoElt);
		      if (t === null) {
		         return {
		            getPropertyValue: function(){}
		         };
		      } else{
		         return t;
		      }
		   };
	}

	if ($.support && $.support.boxSizingReliable) {
		var original = $.support.boxSizingReliable;

		$.support.boxSizingReliable = function  () {
			try {
				return original();
			} catch(e) {
				console.log("Couldn't call boxSizingReliable", e);
			}

			fixFFGetComputedStyleBug();

		    try {
				return original();
			} catch(e) {
				console.log("Couldn't call boxSizingReliable after patching FF", e);
			}

			return false;
		}
	}
})();


function unlockTrackerItem(itemId, async) {
	if (itemId) {
		if (typeof async === "undefined") {
			async = true;
		}
		$.ajax({
			type: 'POST',
			url: contextPath + "/ajax/trackers/unlockItem.spr",
			data: {
				"task_id": itemId
			},
			async: async
		}).done(function (response) {
			console.log("response for unlocking item " + itemId + ": " + response);
		});
	}
}

function unlockTrackerItems(itemIds) {
	if (itemIds && Array.isArray(itemIds)) {
        $.ajax({
            type: 'POST',
            url: contextPath + "/ajax/trackers/unlockItems.spr",
            data: {
                "taskIds": itemIds.join(',')
            }
        }).done(function (response) {
            console.log("response for unlocking items " + itemIds + ": " + response);
        });
	}
}

function lockTrackerItem(itemId) {
	if (itemId) {
		$.post(contextPath + "/ajax/trackers/lockItem.spr", {
			"task_id": itemId
		}).done(function (response) {
			console.log("response for locking item " + itemId + ": " + response);
		});
	}
}

function isItemLocked(itemId) {
	if (itemId) {
		return $.get(contextPath + "/ajax/trackers/isItemLocked.spr", {
			"task_id": itemId
		});
	}
}

function disableAllInputs($context) {
	$context.find("input,textarea,select,button").not(".cancelButton").attr("disabled", "disabled");
}

/**
 * http://clubajax.org/files/lang/plain-text.js
 *
 * gets the plaintext content of a dom element
 *
 * @param node
 * @returns
 */
getPlainText = function(node){
	// used for testing:
	//return node.innerText || node.textContent;


	var normalize = function(a){
		// clean up double line breaks and spaces
		if(!a) return "";
		return a.replace(/ +/g, " ")
				.replace(/[\t]+/gm, "")
				.replace(/[ ]+$/gm, "")
				.replace(/^[ ]+/gm, "")
				.replace(/\n+/g, "\n")
				.replace(/\n+$/, "")
				.replace(/^\n+/, "")
				.replace(/\nNEWLINE\n/g, "\n\n")
				.replace(/NEWLINE\n/g, "\n\n"); // IE
	}
	var removeWhiteSpace = function(node){
		// getting rid of empty text nodes
		var isWhite = function(node) {
			return !(/[^\t\n\r ]/.test(node.nodeValue));
		}
		var ws = [];
		var findWhite = function(node){
			for(var i=0; i<node.childNodes.length;i++){
				var n = node.childNodes[i];
				if (n.nodeType==3 && isWhite(n)){
					ws.push(n)
				}else if(n.hasChildNodes()){
					findWhite(n);
				}
			}
		}
		findWhite(node);
		for(var i=0;i<ws.length;i++){
			ws[i].parentNode.removeChild(ws[i])
		}

	}
	var sty = function(n, prop){
		// Get the style of the node.
		// Assumptions are made here based on tagName.
		if(n.style[prop]) return n.style[prop];
		var s = n.currentStyle || n.ownerDocument.defaultView.getComputedStyle(n, null);
		if(n.tagName == "SCRIPT") return "none";
		if(!s[prop]) return "LI,P,TR".indexOf(n.tagName) > -1 ? "block" : n.style[prop];
		if(s[prop] =="block" && n.tagName=="TD") return "feaux-inline";
		return s[prop];
	}

	var blockTypeNodes = "table-row,block,list-item";
	var isBlock = function(n){
		// diaply:block or something else
		var s = sty(n, "display") || "feaux-inline";
		if(blockTypeNodes.indexOf(s) > -1) return true;
		return false;
	}
	var recurse = function(n){
		// Loop through all the child nodes
		// and collect the text, noting whether
		// spaces or line breaks are needed.
		if(/pre/.test(sty(n, "whiteSpace"))) {
			t += n.innerHTML
				.replace(/\t/g, " ")
				.replace(/\n/g, " "); // to match IE
			return "";
		}
		var s = sty(n, "display");
		var gap = isBlock(n) ? "\n" : " ";
		t += gap;
		for(var i=0; i<n.childNodes.length;i++){
			var c = n.childNodes[i];
			if(c.nodeType == 3) t += c.nodeValue;
			if(c.childNodes.length) recurse(c);
		}
		t += gap;
		return t;
	}
	// Use a copy because stuff gets changed
	node = node.cloneNode(true);
	// Line breaks aren't picked up by textContent
	node.innerHTML = node.innerHTML.replace(/<br>/g, "\n");

	// Double line breaks after P tags are desired, but would get
	// stripped by the final RegExp. Using placeholder text.
	var paras = node.getElementsByTagName("p");
	for(var i=0; i<paras.length;i++){
		paras[i].innerHTML += "NEWLINE";
	}

	var t = "";
	removeWhiteSpace(node);
	// Make the call!
	return normalize(recurse(node));
}


function alignLabels(context) {
	if (!context) {
		context = $("body");
	}
	var $formFields = context.find(".form-field label").not(".checkboxLabel");
	var labeWidths = $formFields.map(function () {return $(this).width();})
	var maxWidth = Math.max.apply(null, labeWidths);

	if (maxWidth > 10) {
		$formFields.width(maxWidth);
	}

	var $checkboxes = context.find(".form-field .checkboxInput");
	$checkboxes.css("margin-left", parseInt(maxWidth, 10) + 23 + "px");
}

var showCommentSaveResult = function() {
	showOverlayMessage(i18n.message("comment.successfully.saved"));
};

function moveCursorToEndOfContentEditable(contentEditableElement) {
    var range,selection;

    if (document.createRange) {
    	// Create a range (a range is a like the selection but invisible)
        range = document.createRange();
        // Select the entire contents of the element with the range
        range.selectNodeContents(contentEditableElement);
        // Collapse the range to the end point. false means collapse to end rather than the start
        range.collapse(false);
        // Get the selection object (allows you to change selection)
        selection = window.getSelection();
        // Remove any selections already made
        selection.removeAllRanges();
        // Make the range you have just created the visible selection
        selection.addRange(range);

        contentEditableElement.focus();
    }
};

var testRuns = {
	/**
	 * Run a TestSetRun -either in normal TestRunner or in Excel
	 *
	 * @param runMode If this is a normal Testrun or Excel TestRun.
	 * @param params
	 * @param allowOverlay If this can open an overlay or should use a popup always !
	 */
	runTestRun: function(runMode, params, allowOverlay) {
		params += "&runMode=" + runMode;
		params += "&allowOverlay=" + allowOverlay;

		$.ajax({
			url: contextPath + '/ajax/testmanagement/getTestRunnerAction.spr',
			async: false,	// must be sync otherwis popup blocker will prevent the popups opening
			cache: false,
			data: params,
			success: function(data) {
				testRuns.executeAction(data);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				var msg = jqXHR.responseText;
				if (! msg) {
					msg = "Can not run this TestRun due to an error:" + textStatus;
				}
				showFancyAlertDialog(msg);
				console.log("Error: " + jqXHR +", status:" + textStatus);
			}
		});
	},

	/**
	 * Execute the ActionItem arrives back from an ajax call from test-management as json
	 */
	executeAction: function(data) {
		try {
			if (data.actionExec) {
				var js = data.actionExec;
				// wrap in a function so if the js script contains a "return" statement that won't throw an exception
				// , so this can run scripts normally used in onclick event-function
				js = "(function(){" + js +"})();"
				jQuery.globalEval(js);

				if (js.indexOf("inlinePopup") == -1) {
   					// because the TestRunner runs in an overlay we reload this page
   					document.location.href = data.forward;
				} else {
					console.log("The js opens an overlay, so can not reload the page");
				}
			} else if (data.actionURL) {
				document.location.href = data.actionURL;
			}
		} catch (ex) {
			console.log("Can not execute:" + data +", exception:" + ex);
		}
	}
}

/**
 * updates the behaviour of issue links in containerSelector. the issue links (instead of redirecting according to their href)
 * just select a node in a tree (with the dom id treeId). see issue 752846.
 * if the item that the link points to is not in the current view then everything works as usual (the link redirects to an other page).
 *
 *
 * @param containerSelector
 * @param treeId
 */
function setIssueClickSelectNodeInTree(containerSelector, treeId) {
	var ISSUE_INTERWIKI_LINK_REGEXP = /\[(.+\|)?ISSUE:(\d+)\]/;

	var selector = containerSelector + " a.interwikilink";
	$(document).on("click", selector, function (event) {
		// keep the original behaviour when the user ctrl/cmd clicks
		if (event.ctrlKey || event.metaKey) {
			return;
		}
		var tree = $.jstree.reference(treeId);

		// if the tree cannot be found then do nothing
		if (!tree) {
			return;
		}

		var wikiLink = $(this).data("wikilink");

		var match = ISSUE_INTERWIKI_LINK_REGEXP.exec(wikiLink);
		if (!match) {
			// not an issue link
			return;
		}

		// get the issue id from the wikilink and select the node in the tree
		var issueId = match[2];
		var node = tree.get_node(issueId);

		if (node) {
			tree.deselect_all();
			tree.select_node(node);
			event.preventDefault();
			event.stopPropagation();
		}
	});
}

// @param url The url to call if the confirm successful to delete the association
function confirmDeleteAttachment(url) {
	if (confirm(i18n.message("tracker.delete.attachment.confirm"))) {
		document.location.href = url;
	}
}

var showReviewLicenseWarning = function () {
	showFancyAlertDialog(i18n.message("license.reviews.nolicense.message"));
};

/**
 * This function filters the options of a select tag (got by parameter).
 * The filter is based on the input checkbox named "exportKind". Therefore
 * the checkbox should be present (mainly included from selectExportTemplateFragment.jsp)
 * If the exportKind is "word" then only files with the doc* extension remains after the filter
 * and if the exportKind is "excel" then only files with xl* extension remains, every
 * other file will be filtered out.
 *
 * This function is mainly used for the solution of the BUG #1119829
 * */
function filterTemplateFilesByType($templateSelect) {

	var templateOptions = $templateSelect.data("templateOptions");
	if (templateOptions == null) {
		// save current options as template options
		templateOptions = $templateSelect.html();
		$templateSelect.data("templateOptions", templateOptions);
	} else {
		$templateSelect.html(templateOptions);	// restore original/unfiltered content
	}
	var $selectedKind = $("input[name=exportKind]:checked");
	var exportKind = $selectedKind.val();

	$templateSelect.find("option").each(function() {
		var templateName = $(this).val();
	   	var keep = false;
	   	if (exportKind.toLowerCase().indexOf("word") != -1) {
	   		// keep only word files
	   		keep = templateName.indexOf(".doc") != -1;
	   	} else {
	   		// Excel: keep only excel files
	   		keep = templateName.indexOf(".xl") != -1;
	   	}
	   	if (templateName == "") {
	   		keep = true;	// keep the "default" always
	   	}
	   	if (!keep) {
	   		$(this).remove();
	   	}
	});
	$("select.templateName").multiselect('refresh');
}

$.fn.hasHorizontalScrollBar = function() {
    return this.get(0).scrollWidth > this.width();
};

/**
 * Show the warning dialog if switching into an other branch.
 * @param sourceId Source tracker or branch ID
 * @param targetId Target tracker or branch ID
 * @param itemId Work Item ID (optional, used on Item details screen)
 * @param skip Warning should not display in some cases, set to true to skip
 */
function showBranchSwitchWarning(targetName, targetId, branchesJSON) {
	var html = "<div>" + i18n.message("tracker.branching.switch.warning", targetName) + "</div>";
	html += "<ul class='branchSwitchWarningList'>";
	for (var i = 0; i < branchesJSON.length; i++) {
		var branch = branchesJSON[i];
		var itemIdPart = branch.hasOwnProperty("itemId") ? " data-itemId='" + branch.itemId + "'" : "";
		var itemIsNotOnBranch = false;
		if (branch.hasOwnProperty("notOnBranch") && branch.notOnBranch) {
			itemIsNotOnBranch = true;
		}
		var linkPart = "<a" + itemIdPart + " data-branchId='" + branch.id + "' href='#'>";
		if (i == 0) {
			if (targetId > 0) {
				html += "<li>" + (!itemIsNotOnBranch ? linkPart : "") + i18n.message("tracker.branching.master.name") + (!itemIsNotOnBranch ? "</a>" : "") + "</li>";
			} else {
                html += "<li><b>" + i18n.message("tracker.branching.master.name") + "</b> <i>(" + i18n.message("tracker.branching.current.label") + ")</i></li>";
			}
		} else {
			if (targetId == branch.id) {
                html += "<li style='padding-left: " + (branch.level * 10) + "px;'><b>" + branch.name + "</b> <i>(" + i18n.message("tracker.branching.current.label") + ")</i></li>";
			} else {
                html += "<li style='padding-left: " + (branch.level * 10) + "px;'>" + (!itemIsNotOnBranch ? linkPart : "") + branch.name + (!itemIsNotOnBranch ? "</a>" : "") + "</li>";
			}
		}
	}
	html += "</ul>";
	$("body").on("click", ".branchSwitchWarningList li a", function() {
        var url = UrlUtils.addOrReplaceParameter(window.location.href, "branchId", $(this).attr("data-branchId"));
		if ($(this).attr("data-itemId")) {
			url = contextPath + "/issue/" + $(this).attr("data-itemId");
		}
        url = UrlUtils.addOrReplaceParameter(url, "skipBranchSwitchWarning", "true");
        window.location.href = url;
    });
	showFancyAlertDialog(html);
}

function initializeJumpToDocumentViewHandler() {
	$("body").on("click", ".jumpToDocumentView", function(e) {
		e.preventDefault();
		var trackerId = $(this).attr("data-trackerId");
		var trackerItemId = $(this).attr("data-trackerItemId");
		var url = $(this).attr("data-url");
		var revision = UrlUtils.getParameter("revision");
		if (revision && revision.length > 0) {
			url += "&revision=" + revision;
		}
		if (codebeamer && codebeamer.hasOwnProperty("documentViewTrackerId") && codebeamer.documentViewTrackerId == trackerId) {
			try {
				var tree = $.jstree.reference("#treePane");
				if (trackerItemId) {
					var node = tree.get_node(trackerItemId);
					if (node) {
						tree.deselect_all();
						tree.select_node(node);
					}
				}
			} catch (e) {
				window.location.href = contextPath + url;
			}
		} else {
			window.location.href = contextPath + url;
		}
	});
}

function refreshTimeRecordingField(itemId, newValue) {
	if (newValue && newValue.length > 0) {
		$('.timeRecording[data-item-id="' + itemId + '"]').each(function() {
			$(this).parent().contents()[0].textContent = newValue + " ";
		});
	}
	if (codebeamer && codebeamer.planner) {
		codebeamer.planner.reloadSelectedIssue();
	}
}

/**
 * Cookies/local storage which should be deleted after logging out
 */
function clearCookiesAndLocaleStorage() {
	// Clear Report Selector locale storage
	$.jStore.remove("CB-reportSelectorData");
	// Clear jstree/reviewTree open-state data from local storage
	$.jStore.remove("jstree");
	$.jStore.remove("reviewTree");
	// Clear WYSIWYG auto save local storage
	clearWysiwygAutoSaveLocalStorage();

	// clear the extended doc view keys from the local storage
	for (var key in localStorage) {
		if (key.indexOf('codebeamer.item-editor-state') >= 0) {
			localStorage.removeItem(key);
		}
	}

	// remove tab cookies
	var allCookies = getCookies();
	for (var key in allCookies) {
		if (key.indexOf("org.ditchnet.jsp.tabs") >= 0) {
			$.cookie(key, null, { path: "/"});
		}
	}
}

function clearWysiwygAutoSaveLocalStorage() {
	try {
        var prefix = "CodeBeamer.wysiwygAutoSave";
        var currentKeys = $.jStore.CurrentEngine.db;
        var wysiwygAutoSaveKeys = [];
        for (var key in currentKeys) {
            if (key.slice(0, prefix.length) == prefix) {
                wysiwygAutoSaveKeys.push(key);
            }
        }
        for (var i = 0; i < wysiwygAutoSaveKeys.length; i++) {
			$.jStore.remove(wysiwygAutoSaveKeys[i]);
        }
	} catch (e) {
		//
	}
}

function getCookies() {
	var pairs = document.cookie.split(";");
	var cookies = {};
	for (var i=0; i<pairs.length; i++){
		var pair = pairs[i].split("=");
		cookies[(pair[0]+'').trim()] = decodeURIComponent(pair[1]);
	}
	return cookies;
}

function hasVerticalScrollbar(element) {
	var $element;

	$element = element;

	return $element.get(0) ? $element.get(0).scrollWidth > $element.innerWidth() : false;
}

// remove duplicates from an array: https://stackoverflow.com/questions/9229645/remove-duplicates-from-javascript-array
function uniq(a) {
    var seen = {};
    return a.filter(function(item) {
        return seen.hasOwnProperty(item) ? false : (seen[item] = true);
    });
}

/**
 * lazy load an element inside a ditchnet-tab: when the element becomes visible or tab changed only then it is loaded
 * @param element The element to lazy-load
 * @param url The url to load the data from with ajax: the data is the html output
 * @param forceLoad if true then the url will be loaded immediately and even if already loaded
 * @return a jquery-Promise called when the data is loaded
 */
function loadWhenVisibleOrOnTabChange(element, url, forceLoad) {
	var $el = $(element);
	var promise = $.Deferred();

	var loadIfVisible = function() {
		// only load when element is visible and only load once
		if (forceLoad || $el.is(":visible")) {
			// check if the same content is already loaded?
			var loadedUrl = $el.data("lazy-loaded-url");
			if (loadedUrl == url) {
			    var data = $el.data("lazy-loaded-data");
			    $el.html(data);

			    promise.resolve(data);

				console.log("Already loaded the same data to element, not loading it:" + url);
				return promise;
			}
			console.log("Loading:" + url);

			$.get({
				"url": url,
				"cache": false
				},
			function(data) {
				// remember url to only load once
				$el.data("lazy-loaded-url", url);
				$el.data("lazy-loaded-data", data);

				$el.html(data);
			}).fail(function(err) {
				$el.html("<div class='error'>" + escapeHtml(err.responseText) +"</div>");
			}).done(function(data) {
				promise.resolve(data); // finish
			});
		}
	}
	loadIfVisible();

	// find the ditchnet tabs and load the content when tab switched
	var $tab = $el.closest(".ditch-tab-skin-cb-box");
	var $tabs = $tab.find(".ditch-tab-wrap > .ditch-tab");
	$tabs.on("click", function(event) {
		loadIfVisible();
	});
	return promise;
}

/**
 * Lazy/ajax load of reported bugs of a TestCase
 * @param element The html element to load the bugs into
 * @param testCaseId The TestCase's id
 * @param params additional parameters
 * @param forceLoad If the content is loaded even when item is not visible
 * @return a jquery-Promise called when the data is loaded
 */
function reportedBugsLazyLoad(element, testCaseId, params, forceLoad) {
	// show loading animation
	$(element).html("<img src='"+ contextPath +"/images/ajax_loading_horizontal_bar.gif'/>");
	// load when visible
	var url = contextPath + "/ajax/testCaseReportedBugs.spr?testCaseId=" + testCaseId;
	if (params != null) {
		url += "&" + params;
	}

	return loadWhenVisibleOrOnTabChange(element, url, forceLoad);
}

function getBrowserType() {
	var browserType = "FF";

	if ($("body").hasClass("IE")) {
		browserType = "IE";
	} else {
		if ($("body").hasClass("Chrome")) {
			browserType = "CHROME";
		}
	}

	return browserType;
}

function initEntityLabelAutocomplete($input, options) {
	options = options || {};
	var split = function(val) {
		return val.split(/;\s*/);
	};

	var extractLast = function(term) {
		return split(term).pop();
	};

	$input.bind( "keydown", function( event ) {
		if (event.keyCode === $.ui.keyCode.TAB && $(this).autocomplete( "instance" ).menu.active) {
			event.preventDefault();
		}
	}).autocomplete({
		source: function( request, response ) {
			var data = {
				labelPrefix: extractLast(request.term)
			};

			if (options.ignorePrivateLabels) {
				data.ignorePrivateLabels = true;
			}
			$.ajax({
				url: contextPath + "/ajax/getLabelSuggestions.spr",
				dataType: "json",
				data: data,
				success: function(data) {
					var names = [];
					for (var i=0; i < data["resultset"].length; i++) {
						names.push(data["resultset"][i]["name"]);
					}
					response(names);
				}
			});
		},
		search: function() {
			var term = extractLast( this.value );
			if ( term.length < 2 ) {
				return false;
			}
		},
		focus: function() {
			return false;
		},
		select: function( event, ui ) {
			var terms = split( this.value );
			terms.pop();
			terms.push( ui.item.value );
			terms.push( "" );
			this.value = terms.join( "; " );
			return false;
		}
	});
}

function isElementOnScreen(element) {
    var $window = $(window),
    	viewport_top = $window.scrollTop(),
    	viewport_height = $window.height(),
    	viewport_bottom = viewport_top + viewport_height,
    	$element = $(element),
    	top = $element.offset().top,
    	height = $element.height(),
    	bottom = top + height;

    return (top >= viewport_top && top < viewport_bottom) ||
           (bottom > viewport_top && bottom <= viewport_bottom) ||
           (height > viewport_height && top <= viewport_top && bottom >= viewport_bottom);

}

function reloadReleasePageAfterUserPreferenceChange() {
	var url = window.parent.document.location.href;

	if (url.indexOf("/planner") > 0) {
		window.parent.document.location = url.substring(0, url.indexOf("/planner"));
	} else {
		document.location.reload();
	}
}

function preventPopStateTriggeringIfHashmarkChange() {
	$("a[href=\"#\"]").click(function(e) {
		e.preventDefault();
	});
}
