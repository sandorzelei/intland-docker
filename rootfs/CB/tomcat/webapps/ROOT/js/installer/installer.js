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
codebeamer.installer = codebeamer.installer || (function ($) {
	var maskPage = function (text) {
		var $mask = $("<div>", {"id": "mask"});
		var $animation = $("<div>", {"class": "busy-sign" + ((typeof text != 'undefined') ? "-text" : "")});
		if (typeof text != 'undefined') {
			$animation.append(text);
		}

		$("body").append($mask);
		$mask.after($animation);
	};

	var removeMask = function () {
		$("#mask").remove();
		$(".busy-sign").remove();
		$(".busy-sign-text").remove();
	};

	var displayLicenseSkipConfirmDialog = function (callback){

		var $mask = $("<div>", {"id": "mask"});
		var $overlay = $("<div>", {"class": "overlay"});

		$overlay.append('<div class="overlayMessage confirm">If you choose skip you will have only 7 days until free license is expired! Are you sure? </div>');
		var $button = $('<button class="button">OK</button>');
		var $cancelButton = $('<button class="button">Cancel</button>');
		$button.click(function() {
			$mask.remove();
			$overlay.remove();
			callback();
		});
		$cancelButton .click(function() {
			$mask.remove();
			$overlay.remove();
		});
		var $buttonCont = $('<div class="buttons"></div>');
		$buttonCont.append($button);
		$buttonCont.append($cancelButton);
		$overlay.append($buttonCont);

		$("body").append($mask);
		$mask.after($overlay);

		$button.focus();
	}

	var displayOverlay = function(typeCssClass, message) {
		var $mask = $("<div>", {"id": "mask"});
		var $overlay = $("<div>", {"class": "overlay"});

		$overlay.append('<div class="overlayMessage '+ typeCssClass + '">' + message + '</div>');
		var $button = $('<button class="button">OK</button>');
		$button.click(function() {
			$mask.remove();
			$overlay.remove();
		});
		var $buttonCont = $('<div class="buttons"></div>');
		$buttonCont.append($button);
		$overlay.append($buttonCont);

		$("body").append($mask);
		$mask.after($overlay);

		$button.focus();
	};

	var initForm = function() {
		var inputs = $('input, textarea, select');
		var selects = $('select');

		var nextButton = $('input[name="_eventId_next"][type="submit"]');
		// Enable inputs before posting
		nextButton.click(function() {
			inputs.prop('readonly', false);
			selects.prop('disabled', false);
			return true;
		});
		// Load existing license button
		$('#loadExistingLicense').click(function() {
			$('textarea#license').val($('input[name="existingLicense"]').val());
		});
		// Hide next button
		nextButton.hide();
		$("#saveLicenseNotification").hide();
	};

	var ajaxCrossDomainIe = function (url) {
		var iframe = document.createElement("iframe");
		iframe.id = "ajaxProxy";
		document.body.appendChild(iframe);
		iframe.style.display = "none";
		iframe.src = url;

		$('#ajaxProxy').load(function (e) {
			displayErrorMessages(null, "Error while saving user data. Please try again!", null);  // TODO i18n
			removeMask();
			$("iframe").remove();
		});

	};

	var receiveMessage = function(e, m) {
		var response = $.parseJSON(e.originalEvent.data);
		if (response["error"] || response["errors"]) {
			errorHandler(response);
		} else {
			successHandler(response);
		}
	};

	var submitNewUserData = function($form) {
		if (validateMandatoryInputs($form, ["address", "city", "zip", "country", "phone"])) {
			maskPage();

			$.ajax({
				"url": cbApiUrl + "/postinstall/registerUser.spr",
				"type": "POST",
				"data": JSON.stringify($form.serializeObject()),
				"timeout": 10000,
				"dataType": "json",
				"contentType": "application/json"
			})
				.done(function (data) {
					$('#license').val(data['license']);
					reInitForm();
					displaySuccessMessage("User data successfully saved. You can view and save your license key in the form.");
				})
				.fail(function (jqXHR) {
					var response = {
						error : jqXHR.statusText
					}
					try {
						if (jqXHR.status == 0) {
							response = "Could not connect to " + cbApiUrl + ". Please check your internet connection or remote server availability.";
						} else {
							response = $.parseJSON(jqXHR.responseText);
						}
					}
					catch(err){
						// catch parse exception
					}
					displayErrorMessages(response, "Error during the registration process on " + cbApiUrl + ". Please try again!", $form);
				})
				.always(function () {
						removeMask();
					});
		}
	};

	var submitExistingUserData = function($form) {
		if (validateMandatoryInputs($form, ["hostId"])) {
			maskPage();

			$.ajax({
				url: cbApiUrl + "/postinstall/login.spr",
				type: 'POST',
				data: JSON.stringify($form.serializeObject()),
				dataType: "json",
				timeout: 10000,
				contentType: "application/json"
			})
				.done(function (data) {
					var response = $.parseJSON(JSON.stringify(data));
					$('#license').val(data['license']);
					reInitForm();
					displaySuccessMessage("Successfully logged in. You can view and save your license key in the form.");
				})
				.fail(function (jqXHR) {
					var response = {
						error : jqXHR.statusText
					}
					try {
						if (jqXHR.status == 0)  {
							response = "Could not connect to " + cbApiUrl + ". Please check your internet connection or remote server availability.";
						} else {
							response = $.parseJSON(jqXHR.responseText);
						}
					}
					catch(err){
						// catch parse exception
					}
					displayErrorMessages(response, "Error during the login process on " + cbApiUrl + ". Please try again!", $form);
				})
				.always(function () {
					removeMask();
				});
		}
	};

	var successHandler = function (data) {
		$('#license').html($("<div>").text(data['license']).html());
		reInitForm();
		displaySuccessMessage("Successfully logged in. You can view and save your license key in the form."); // TODO i18n
		removeMask();
		$("iframe").remove();
	};

	var errorHandler = function (data) {
		displayErrorMessages(data, "Error while logging in. Please try again!", $("form"));  // TODO i18n
		removeMask();
		$("iframe").remove();
	};

	var testConnection = function(contextPath, $form) {
		$("#windowsMysqlInstallInfo").hide();
		maskPage();
		var databaseType = $("[name=type]:checked").val();
		var json = "{" +
			"\"type\": \"" + databaseType + "\"," +
			"\"host\": \"" + $("#host").val() + "\"," +
			"\"schema\": \"" + $("#schema").val() + "\"," +
			"\"schemaUser\": \"" + $("#schemaUser").val() + "\"," +
			"\"schemaPassword\": \"" + $("#schemaPassword").val() + "\"," +
			"\"adminUser\": \"" + $("#adminUser").val() + "\"," +
			"\"adminPassword\": \"" + $("#adminPassword").val() + "\"," +
			"\"oracleAdminCheckbox\": \"" + $("#oracleAdminCheckbox").is(':checked') + "\"," +
			"\"port\": " + $("#port").val() + "}";

		$.ajax({"url": contextPath + "/installer/testconnection.spr",
			"data": json,
			"contentType": "application/json; charset=utf-8",
			"dataType": "json",
			"type": "POST",
			"cache": false
		})
			.done(function(data) {
				if (data["success"]) {
					displaySuccessMessage(data["message"]);
					if ($("#nextButton").length) {
						$("#nextButton").removeAttr('disabled');
						$("#nextButton").removeClass('next-button-disabled');
					}
				} else {
					displayErrorMessage(data["message"]);
					showWindowsInstallHelpForMysql(databaseType);
				}
			})
			.fail(function() {
				displayErrorMessage("Cannot connect to database, please revise database settings!");
				showWindowsInstallHelpForMysql(databaseType);
			})
			.always(function() {
				removeMask();
			});
	};

	var testSmtp = function(contextPath, $form) {
		if (validateMandatoryInputs($form, ["ssl", "fromAddress", "testEmail"])) {
			maskPage();
			var dataObj = $form.serializeObject();
			
			dataObj["ssl"] = dataObj["ssl"] ? true : false;
			delete dataObj["_ssl"];
			
			dataObj["startTls"] = (dataObj["startTls"] == "true");
			delete dataObj["_startTls"];

			var data = JSON.stringify(dataObj);

			$.ajax({
				url: contextPath + "/installer/testMailSettings.spr",
				type: 'POST',
				data: data,
				dataType: "json",
				contentType: "application/json"
			})
				.done(function (data, textStatus, jqXHR) {
					if (data['success']) {
						displaySuccessMessage("Successfully sent test email.");
					} else {
						displayErrorMessage(data['message']);
					}
				})
				.fail(function() {
					displayErrorMessage("Failed to send test email, please revise mail server settings!");
				})
				.always(function () {
					removeMask();
				});
		}
	};

	var validateSmtpForm = function($form) {
		var exclude = ["ssl", "fromAddress", "testEmail"];
		if ($("input[name=host]").val() == "#"){
			exclude = ["host", "user", "password", "ssl", "port", "fromAddress", "testEmail", "serverHost", "serverScheme", "serverPort"];
		}
		return validateMandatoryInputs($form, exclude);
	};

	var validateMandatoryInputs = function($form, exceptions) {
		var exceptions = exceptions || [];
		var isValid = true;
		$form.find('input').each(function() {
			if ($.inArray($(this).attr("name"), exceptions) == -1) {
				if ($.trim($(this).val()).length == 0) {
					$(this).addClass('error');
					isValid = false;
				}
			}
		});
		if (!isValid) {
			displayErrorMessage("Please fill out mandatory fields!");
		}
		return isValid;
	};

	var showWindowsInstallHelpForMysql = function (databaseType) {
		if (databaseType == "mysql" && windowsPlatform == "true") {
			$("#windowsMysqlInstallInfo").show();
		}
		else {
			$("#windowsMysqlInstallInfo").hide();
		}
	};

	var reInitForm = function () {
		// Display next button (continue the flow)
		$('input[name="_eventId_next"][type="submit"]').show();
		// Hide ajax button
		$('input[name="ajax"][type="button"]').hide();
		// Disable input edit
		//$('input, textarea').prop('readonly', true);
		//$('select').prop('disabled', true);
		$("#saveLicenseNotification").show();
		// Remove Load existing license link
		$("#loadExistingLicense").remove();
	};

	var displayErrorMessage = function (text) {
		displayOverlay("error", text);
	};

	var displaySuccessMessage = function (text) {
		displayOverlay("success", text);
	};

	var displayErrorMessages = function(response, text, $form) {
		var errorHtml = "";
		if (response != null && response.hasOwnProperty("errors")) {
			var errors = response["errors"];
			var i = 0;
			for (var error in errors) {
				for (var key in errors[error]) {
					errorHtml += errors[error][key];
					$form.find('input[name=' + key + ']').addClass('error');
					if (i != errors.length - 1) {
						errorHtml += "<br>";
					}
				}
				i++;
			}
		} else if (response != null && response.hasOwnProperty("error")) {
			errorHtml += response["error"];
		} else {
			errorHtml += text;
			if (response != null) {
				errorHtml += "<br><br>";
				errorHtml += response;	
			}
		}
		displayErrorMessage(errorHtml);
	};

	var bindCrossDomainIe = function () {
		$(window).bind("message", receiveMessage);
	};

	return {
		"maskPage": maskPage,
		"removeMask": removeMask,
		"initForm": initForm,
		"submitNewUserData": submitNewUserData,
		"submitExistingUserData": submitExistingUserData,
		"testConnection" : testConnection,
		"testSmtp": testSmtp,
		"displayErrorMessage": displayErrorMessage,
		"displayLicenseSkipConfirmDialog": displayLicenseSkipConfirmDialog,
		"validateSmtpForm" : validateSmtpForm,
		"successHandler": successHandler,
		"errorHandler": errorHandler,
		"bindCrossDomainIe": bindCrossDomainIe
	};
})(jQuery);


