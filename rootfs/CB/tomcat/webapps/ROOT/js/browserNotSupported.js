
var browserNotSupportedWarning = {
	cookieName : "codebeamer.hide.browser.not.supported",

	// supported browsers
	browsers : ["Internet Explorer 9+", i18n.message("not.supported.browser.latest.stable.label") + " Firefox",
	            i18n.message("not.supported.browser.latest.stable.label") + " Chrome"],
	urls : ["http://www.microsoft.com/windows/Internet-explorer/default.aspx",
            "http://www.mozilla.com/firefox/",
            "http://www.google.com/chrome"],

	show:function (msg, dontShowMsg, browsers) {
		var c = $.cookie(browserNotSupportedWarning.cookieName);
		if (!c) {
			dontShowMsg = "<a href='#' onclick='browserNotSupportedWarning.disable(this); return false;' style='float:right; width: auto; font-size:smaller' >" +
						dontShowMsg + "</a>";
			msg += "<br/><ul>";
			if (!browsers) {
				browsers = browserNotSupportedWarning.browsers;
			}
			for (var i=0; i<browsers.length; i++) {
				msg += "<li>" +
					   "<a href='" + browserNotSupportedWarning.urls[i] + "'>" +
					   		browsers[i] +
					   "</a>" +
					   "</li>";
			}
			msg += "</ul>";
			msg += dontShowMsg;
			GlobalMessages.showWarningMessage(msg);
		}
	},

	disable:function(el) {
		$.cookie(browserNotSupportedWarning.cookieName, 'true', { expires: 100000 });
		var msgEl = $(el).closest("li");
		GlobalMessages.hideMessage(msgEl[0]);
	}
};
