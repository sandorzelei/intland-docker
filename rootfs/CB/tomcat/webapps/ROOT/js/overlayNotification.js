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

/*
 * module for managing the overlay notification boxes (adding them, removing them and positiooning them).
 */

var codebeamer = codebeamer || {};

codebeamer.overlayNotification = (function($) {

	/**
	 * renders a new overlay notification box
	 * @param message: the message to show
	 * @param options: the possible options:
	 * 		* secondsToShow: the number of seconds after which the overlay box will be removed from the dom. applies only for success messages
	 * 			because error messages are  note removed automatically
	 * 		* position: the jquery.Position configuration options for positioning the overlay
	 * 		* warning: if true then the message will be treated as a warning
	 * 		* error: if true then the message will be treated as an error
	 * 		* onHide: the callback function invoked when the overlay box fades out or is removed from the DOM (either automatically or by the user manually)
	 */
	var showOverlayMessageWithOptions = function (message, options) {
		var defaults = {
			secondsToShow: 3,
			position: {
					my: "center top",
					at: "center top+15",
					of: window,
					within: window
			}
		};
		options = $.extend({}, defaults, options);

		if (!message) {
			message = i18n.message("ajax.changes.successfully.saved");
		}

		// remove all other overlay notification messages
		$(".overlayMessageBoxContainer").remove();

		// if this notification requires manual close
		var requiresManualClose = options.requiresManualClose || options.error;

		// create a new message box div and append it to the body
		var $messageBoxContainer = $("<div>", {"class": "overlayMessageBoxContainer"});

		if (requiresManualClose) {
			// add the close button
			var $closer = $("<div>", {"class": "closer"});
			$messageBoxContainer.append($closer);

			$closer.click(function () {
				notificationBoxRemoveHandler($messageBoxContainer, options);
			})
		}

		var $overlayMessageBox = $('<div>', {'class': 'overlayMessageBox'});


		$messageBoxContainer.append($overlayMessageBox);

		$("body").append($messageBoxContainer);

		// clear the previously started timeout function to prevent css collisions
		var timeoutId = $overlayMessageBox.data("timeoutId");
		if (timeoutId) {
			clearTimeout(timeoutId);
		}

		$overlayMessageBox.removeClass('notification warning error');
		if (options.warning) {
			$overlayMessageBox.addClass('warning');
		} else if (options.error) {
			$overlayMessageBox.addClass('error');
		} else {
			$overlayMessageBox.addClass('notification');
		}

		$overlayMessageBox.html(message);
		// make the message box visible, but outside of the screen, so we can measure how wide this will be
		// necessary for center aligning the box, that the text will always fit into
		$messageBoxContainer.css({"width": "auto", "display": "block", "top":"-10000px"} );

		// use jquery.ui's positionioning
		$messageBoxContainer.position(options.position);

		$messageBoxContainer.fadeIn('slow');

		if (!requiresManualClose) {
			var id = setTimeout(function() {
				$messageBoxContainer.fadeOut('slow', function() {
					$overlayMessageBox.css("width", "auto");

					notificationBoxRemoveHandler($messageBoxContainer, options);
				});
			}, options.secondsToShow * 1000);

			$messageBoxContainer.data("timeoutId", id);
		}
	};

	var notificationBoxRemoveHandler = function ($messageBoxContainer, options) {
		// fire an event
		if (options.onHide) {
			options.onHide();
		}

		$messageBoxContainer.remove();
	};

	return {
		showOverlayMessageWithOptions: showOverlayMessageWithOptions
	};
}(jQuery));