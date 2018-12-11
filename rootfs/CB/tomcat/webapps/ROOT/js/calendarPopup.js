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
 *
 * $Revision$ $Date$
 */

/*
 * $Id$
 * Javascript functions for calendarPopup.tag
 *
 * Note using date.js for date formatting/parsing same format as java's SimpleDateFormat
 */
var DateParsing = {

	simpleDateFormatMapping: {
		"MMM dd yyyy" 			: "M d Y",
		"MMM dd, yy" 			: "M d, y",
		"MMM dd, yyyy" 			: "M d, Y",
		"dd/MM/yy" 				: "d/m/y",
		"dd/MM/yyyy" 			: "d/m/Y",
		"dd MMM yyyy" 			: "d M Y",
		"yyyy/MM/dd" 			: "Y/m/d",
		"EEEE, MMMM d, yyyy" 	: "l, F d, Y",
		"dd. MMM. yyyy" 		: "d. M. Y",
		"dd. MMM. yy" 			: "d. M. y",
		"dd.MM.yyyy" 			: "d.m.Y",
		"dd.MM.yy" 				: "d.m.y",
		"MMMM d, yyyy" 			: "F d, y",
		"dd. MMMM yyyy" 		: "d. M Y",
		"EEE, MMM d, yy" 		: "D, M d, y",
		"EEE d/MM yy" 			: "D d/m y",
		"EEE MMMM d, yyyy"		: "D F d, Y",
		"MM-dd" 				: "m-d",
		"yy-MM-dd" 				: "y-m-d",
		"yyyy-MM-dd" 			: "Y-m-d",
		"yyyy.MM.dd" 			: "Y.m.d",
		"dd-MMM-yyyy" 			: "d-M-Y",
		"dd-MMM-yy" 			: "d-M-y",
		"MMM dd" 				: "M d",
		"MMM/dd/yyyy"			: "M/d/Y",
		"MM/dd/yyyy"			: "m/d/Y"
	},

	dateFormat : "M dd yy",

	defaultLocaleData : {
		"locale" : "en",
		"firstDayOfWeek": 0,
		"country" : "EN"
	},

	localeData: null,

	/**
	 * Tiny wrapper around date.js's parseString() method
	 * corrects SimpleDateFormat vs date.js differences
	 */
	parseDateToString:function (dateString, format, allowAjax) {
		DateParsing._localizeDate_js();
		if (format) {
			var withtime = format.indexOf("HH:mm") != -1;
			if (!withtime) {
				// first try to parse with time
				var dt = DateParsing.parseDateToString(dateString, format + " HH:mm", false);
				if (dt != null) {
					return dt;	// sucessfully parsed with time
				}
			}

			format = DateParsing._fixFormatStringDifferences(format);
		}
		var dt = Date.parseString(dateString, format);
		if (dt != null) {
			return dt;
		}

		if (allowAjax == null || allowAjax == true) {
			// finally do an ajax call to the server and ask it to parse our date string
			return DateParsing.ajaxParseDateString(dateString);
		}
		return null;
	},

	// Change the format string so it will be compatible with date.js
	_fixFormatStringDifferences: function(format) {
		if (format.indexOf("EEEE") != -1) {
			format = format.replace("EEEE", "EE");
		} else if (format.indexOf("EEE") != -1) {
			format = format.replace("EEE", "E");
		} else {
			format = format.replace("EE", "E");
		}

		if (format.indexOf("MMMM") != -1) {
			format = format.replace("MMMM", "MMM");
		} else if (format.indexOf("MMM") != -1) {
			format = format.replace("MMM","NNN");
		}

		// Note: time zone parsing is not supported by date.js
		// format = format.replace("z", ""); // ignoring time zone

		return format;
	},

	/**
	 * @param date
	 * @param format
	 * @param withTime If the formatted date should include time (hour/min) too
	 * @returns The formatted time
	 */
	formatDateToString: function(date, format, withTime) {
		DateParsing._localizeDate_js();

		if (format) {
			format = DateParsing._fixFormatStringDifferences(format);
			if (withTime) {
				format += " HH:mm";
			}
		}
		return date.format(format);
	},

	/**
	 * Private method to initialize date.js with localized month names etc...
	 */
	_localizeDate_js: function() {
		if (DateParsing._localizeDate_js_has_run) {
			return;
		}
		DateParsing._localizeDate_js_has_run = true;

		// localizing constants from date.js
		Date.monthNames = i18n.message("calendar.months_long").split(",");
		Date.monthAbbreviations = i18n.message("calendar.months_short").split(",");
		Date.dayNames = i18n.message("calendar.weekdays_long").split(",");
		Date.dayAbbreviations = i18n.message("calendar.weekdays_medium").split(",");
	},

	/**
	 * As final resort do an ajax call to the server to ask it for date parsing
	 * @param dateString The date string to parse to date
	 * @return The parsed date, or null if failed
	 */
	ajaxParseDateString:function(dateString) {
		if (dateString == null || dateString == "") {
			return null;
		}

		var result = {};
		$.ajax({
			 url: contextPath + '/ajax/parseDateString.spr',
			 type: 'POST',
			 data: {"dateString" : dateString},
			 async: false,
			 success: function(data) {
				if (data) {
					var date = new Date(0);
					date.setFullYear(data.year, data.month, data.day);
					date.setHours(data.hour, data.minute, data.sec);
					result.date = date; // passing back the date from the closure via the "result" object
				}
			 }
		});
		return result.date;
	}

};

var jQueryDatepickerHelper = {

	// helper to get the calendar init value from one field or an other if the 1st is empty
	getCalendarInitValue: function(fieldId, otherFieldId) {
		var field = document.getElementById(fieldId);
		if (field.value == "" && otherFieldId != "") {
			var otherfield = document.getElementById(otherFieldId);
			if (otherfield) {
				return otherfield.value;
			}
		}
		return field.value;
	},

	getDate: function(textFieldId, otherFieldId) {
		var txtValue = jQueryDatepickerHelper.getCalendarInitValue(textFieldId, otherFieldId);
		var dateTime = DateParsing.parseDateToString(txtValue, DateParsing.dateFormat);
		return dateTime;
	},

	initCalendar: function(textFieldId, otherFieldId, fieldLabel, showTime) {
		DateParsing._localizeDate_js();

		if (DateParsing.localeData === null) {
			$.ajax({
				dataType: "json",
				url: contextPath + "/ajax/date/getLocaleData.spr",
				async: false
			}).done(function(result) {
				DateParsing.localeData = result;
			}).fail(function() {
				DateParsing.localeData = DateParsing.defaultLocaleData;
			});
		}

		var field = $(document.getElementById(textFieldId));
		var dateTime = jQueryDatepickerHelper.getDate(textFieldId, otherFieldId);

		// Hide others
		$(".xdsoft_datetimepicker").hide();

		if (field.hasClass('hasDatepicker')) {
			field.datetimepicker("show");
			return;
		}

		field.keyup(function(e) {
			if (e.which == 27) {
				try {
					field.datetimepicker("hide");
				} catch (e) {
					// ignore if datetimepicker is not yet initialized
				}
			}
		});

		$.datetimepicker.setLocale(DateParsing.localeData.locale);
		field.datetimepicker({
			defaultTime: "00:00",
			defaultDate: dateTime,
			lang: DateParsing.localeData.locale,
			format: DateParsing.simpleDateFormatMapping[DateParsing.dateFormat] + (showTime ? " H:i" : ""),
			formatDate: DateParsing.simpleDateFormatMapping[DateParsing.dateFormat],
			formatTime: "H:i",
			dayOfWeekStart: DateParsing.localeData.firstDayOfWeek,
			timepicker: showTime ? true : false,
			step: 30,
			validateOnBlur: false,
			onShow: function(ct, $input) {
				$input.addClass("hasDatepicker");
			}
		});
		field.datetimepicker('show');

	},
	
	destroyCalendar: function(inputId) {
		$('#' + inputId).datetimepicker('destroy');
	}
};
