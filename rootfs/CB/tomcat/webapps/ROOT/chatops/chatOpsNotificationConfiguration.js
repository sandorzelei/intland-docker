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
 * $Revision$ $Date$
 */
(function($) {

	$.fn.chatOpsNotificationChannelSelector = function(tracker, options) {
		var settings = $.extend({}, $.fn.chatOpsNotificationChannelSelector.defaults, options);

		function hideMessages(ctx) {
			$('.error', ctx).hide();
			$('.notification', ctx).hide();
		}

		function showErrorMessage(message, ctx) {
			hideMessages(ctx);
			$('.error', ctx).text(i18n.message(message)).show();
		}

		function showSuccessMessage(message, ctx) {
			hideMessages(ctx);
			$('.notification', ctx).text(i18n.message(message)).show();
		}

		function showCreateChannelConfirmation(options, container, tracker, channelName, confirmMessage, callback) {
			showFancyConfirmDialogWithCallbacks(i18n.message(confirmMessage),
				function() {
					var bs = ajaxBusyIndicator.showBusyPage();
					$.ajax({
						url: contextPath + "/chatops/createNotificationChannelOfTracker.spr?tracker_id=" + tracker.id,
						type: 'post',
						dataType: 'json',
						processData: false,
						data: channelName,
						async: false,
						contentType: 'text/plain',
						success: function(result) {
							if (result) {
								if (result.success) {
									$('#notificationChannelInput').val(channelName);
									options.formSubmitButton.trigger("click");
								} else {
									showErrorMessage(result.error, container);
									if (callback) {
										callback()
									}
								}
							} else {
								showErrorMessage(i18n.message("slack.errorOccurred"));
								if (callback) {
									callback()
								}
							}
						},
						complete: function() {
							if (bs) {
								ajaxBusyIndicator.close(bs);
							}
						}
					});
				});
		}

		function saveChatOpsNotificationChannel(options, container, tracker, channelName, callback) {
			hideMessages(container);
			if ($.fn.chatOpsNotificationChannelSelector.previousNotificationChannelName == channelName) {
				return;
			}
			$.ajax({
				url: contextPath + "/chatops/saveNotificationChannelOfTracker.spr?tracker_id=" + tracker.id,
				type: 'post',
				dataType: 'json',
				processData: false,
				data: channelName,
				async: false,
				contentType: 'text/plain',
				success: function(result) {
					if (result) {
						if (result.error) {
							showErrorMessage(result.error, container);
							if (callback) {
								callback();
							}
							if (result.createChannel) {
								showCreateChannelConfirmation(options, container, tracker, channelName, result.createChannel, callback);
							}
						}
					} else {
						showErrorMessage("slack.errorOccurred", container);
						if (callback) {
							callback()
						}
					}
				},
				complete: function() {
				}
			});
		}

		function getSavedChatOpsNotificationChannel(container, tracker) {
			hideMessages(container);
			$.ajax({
				url: contextPath + "/chatops/getNotificationChannelOfTracker.spr?tracker_id=" + tracker.id,
				type: 'get',
				dataType: 'json',
				success: function(result) {
					var notificationChannelName = null;
					if (result) {
						if (result.notificationChannel) {
							notificationChannelName = result.notificationChannel.name;
							$('#notificationChannelInput').val(notificationChannelName);
						} else {
							if (result.error) {
								console.log(result.error);
							}
						}
					} else {
						console.log("error");
					}
					$.fn.chatOpsNotificationChannelSelector.previousNotificationChannelName = notificationChannelName || "";
				},
				complete: function() {
				}
			});
		}

		function renderChatOpsChannelInput(container, tracker, options) {
			var errorSpan = $('<span></span>').attr("class", "error");
			var successSpan = $('<span></span>').attr("class", "notification");
			var input = $('<input></input>').attr('id', 'notificationChannelInput').attr('type', 'text');

			var channelWarning = $('<span></span>')
				.attr("class", "warning")
				.attr("style", "display: inline-block; line-height: 30px;")
				.text(i18n.message("slack.notifications.notificationChannel.warning"));

			container.append(errorSpan);
			container.append(successSpan);
			if (!options.formSubmitButton) {
				input.append(" ");
				var saveButton = $('<input type="button"></input>').attr('class', "button").attr('value', i18n.message("slack.notifications.notificationChannel.saveButton"));
				container.append(saveButton);

				saveButton.on('click', function() {
					saveChatOpsNotificationChannel(options, container, tracker, input.val());
				});
			} else {
				var clicks = null;
				if (options.formSubmitButton.data("events") && options.formSubmitButton.data("events").click) {
					clicks = options.formSubmitButton.data("events").click.slice();
					options.formSubmitButton.unbind("click")
				}
				options.formSubmitButton.click(function(e) {
							saveChatOpsNotificationChannel(options, container, tracker, input.val(), function() {
								e.preventDefault();
								e.stopImmediatePropagation();
							});
						});
				if (clicks) {
					$.each(clicks, function(i, v) {
						options.formSubmitButton.on('click', v);
					});
				}
			}
			container.append(input).append(" ").append(channelWarning);
		}

		function renderInfo(container) {
			var span = $('<span></span>').attr("class", "warning");
			span.text(i18n.message("slack.notifications.error.chatopsNotEnabled"));
			container.append(span);
		}

		function init(container, tracker, options) {
			if (!options.chatOpsEnabled) {
				renderInfo(container);
			} else {
				renderChatOpsChannelInput(container, tracker, options);
				getSavedChatOpsNotificationChannel(container, tracker);
			}
			hideMessages(container);
		}

		return this.each(function() {
			init($(this), tracker, options);
		});
	};


	$.fn.chatOpsNotificationChannelSelector.defaults = {
		chatOpsEnabled: false,
		formSubmitButton: null
	};

	$.fn.chatOpsNotificationChannelSelector.previousNotificationChannelName = null;
})(jQuery);