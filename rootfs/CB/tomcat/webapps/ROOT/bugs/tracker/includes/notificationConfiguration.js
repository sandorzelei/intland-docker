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

	// Tracker notification list Plugin definition.
	$.fn.notificationList = function(tracker, notifications, options) {
		var settings = $.extend( {}, $.fn.notificationList.defaults, options );

		function addSubscription(row, tracker, notification) {
			if (settings.canSubscribeOthers) {
				var subscribers = $('<td>', { "class" : 'subscribers textData columnSeparator' });
				row.append(subscribers);

				subscribers.membersField(notification.subscribers, {
					htmlName	: 'subscribers',
					name		: settings.subscribersLabel,
					editable	: settings.editable,
					trackerId	: tracker.id,
					statusId    : notification.eventFilter && notification.eventFilter.statusId ? notification.eventFilter.statusId : null,
					memberType	: 26, // Users, Roles and Member fields but no Groups
					multiple	: true
				});

				subscribers.referenceFieldAutoComplete();

				if (!settings.simpleSelect) {
					var onlyMembers = $('<td>', { "class" : 'onlyMembers', style : "width: 5%; text-align: center" });
					row.append(onlyMembers);

					onlyMembers.append($('<input>', { type : "checkbox", title : settings.onlyMembersTitle, checked : notification.eventFilter.onlyMembers, disabled : !settings.editable }));
				}
			} else {
				var subscribed = $('<td>', { "class" : 'subscribed', style : "width: 5%; text-align: center" });
				row.append(subscribed);

				subscribed.append($('<input>', { type : "checkbox", checked : notification.eventFilter.onlyMembers, disabled : !settings.editable }));
			}
		}

		function addNotification(body, tracker, notification) {
			var notificationEventFilter = notification != null && notification.hasOwnProperty("eventFilter") ? notification.eventFilter : null;
			if (notificationEventFilter != null && (notificationEventFilter.hasOwnProperty("eventMask") || notificationEventFilter.hasOwnProperty("statusId"))) {
				return null;
			}

			if (!$.isPlainObject(notification)) {
				notification = { eventFilter : { eventMask : null, onlyMembers : false }, subscribers : [] };
			}

			var row = $('<tr>', { "class" : (settings.editable ? 'notification even editable' : 'notification even') }).data('notification', notification);
			body.append(row);

			addSubscription(row, tracker, notification);

			return row;
		}

		function renderTrackerStatusBox(tracker, container) {

			function renderAnyStatusNotificationBox() {

				var getAnyStatusNotification = function() {
					for (var i=0; i < notifications.length; i++) {
						var notification = notifications[i];
						var eventFilter = notification.eventFilter;
						if (eventFilter && eventFilter.eventMask == 34) {
							return notification;
						}
					}
					return null;
				};

				var anyStatusNotification = getAnyStatusNotification();

				if (!$.isPlainObject(anyStatusNotification)) {
					anyStatusNotification = {
						eventFilter : {
							eventMask : 34
						},
						subscribers : []
					};
				}

				container.append($('<h2 style="margin-top: 2em">' + i18n.message('tracker.notification.any.status.change.label') + '' +
				'<span class="subtext">(' + i18n.message('tracker.notification.any.status.change.description') + ')</span></h2>'));

				var table = $('<table>', { "class" : 'displaytag notifications' }).data('tracker', tracker);
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>');

				if (settings.canSubscribeOthers) {
					headline.append($('<th>', { "class" : 'textData  columnSeparator' }).text(settings.subscribersLabel));
					if (!settings.simpleSelect) {
						headline.append($('<th>', { "style" : 'width: 5%; text-align: center"' }).text(settings.onlyMembersLabel));
					}
				} else {
					headline.append($('<th>', { style : 'width: 5%; text-align: center"' }).text(settings.subscribedLabel));
				}

				header.append(headline);

				var body = $('<tbody>');
				table.append(body);

				var row = $('<tr>', { "class" : (settings.editable ? 'notification even editable' : 'notification even') }).data("notification", anyStatusNotification);
				body.append(row);

				addSubscription(row, tracker, anyStatusNotification);
			}

			function renderStatusNotificationBox(statuses) {

				var getCurrentNotification = function(currentFilterId) {
					if (currentFilterId == null) {
						return null;
					}
					for (var i=0; i < notifications.length; i++) {
						var notification = notifications[i];
						var eventFilter = notification.eventFilter;
						if (eventFilter && eventFilter.statusId == currentFilterId) {
							return notification;
						}
					}
					return null;
				};

				container.append($('<h2 style="margin-top: 2em">' + i18n.message('tracker.notification.by.statuses.label') + '' +
				'<span class="subtext">(' + i18n.message('tracker.notification.by.statuses.description') + ')</span></h2>'));

				var table = $('<table>', { "class" : 'displaytag notifications' }).data('tracker', tracker);
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>');

				headline.append($('<th>', { "class" : 'textData  columnSeparator', "style": "text-align: center; width: 10%" }).text(i18n.message("tracker.field.Status.label")));
				if (settings.canSubscribeOthers) {
					headline.append($('<th>', {"class": 'textData  columnSeparator'}).text(settings.subscribersLabel));
					if (!settings.simpleSelect) {
						headline.append($('<th>', {"style": 'width: 5%; text-align: center"'}).text(settings.onlyMembersLabel));
					}
				} else {
					headline.append($('<th>', { style : 'width: 5%; text-align: center"' }).text(settings.subscribedLabel));
				}

				header.append(headline);

				var body = $('<tbody>');
				table.append(body);

				for (var i=0; i < statuses.length; i++) {
					var status = statuses[i];
					var currentNotification = getCurrentNotification(status.id);

					if (!$.isPlainObject(currentNotification)) {
						currentNotification = {
							eventFilter : {
								statusId : status.id
							},
							subscribers : []
						};
					}

					var row = $('<tr>', { "class" : (settings.editable ? 'notification even editable' : 'notification even') }).data("notification", currentNotification);
					body.append(row);

					var otherStyle = '';
					if (status.hasOwnProperty("style")) {
						otherStyle = ' style="background-color: ' + status.style +'"';
					}
					var statusTd = $('<td class="status"><span class="issueStatus ' + status.cssClass + '"' + otherStyle +'>' + escapeHtml(status.name) + '</span></td>');
					row.append(statusTd);

					addSubscription(row, tracker, currentNotification);
				}
			}

			renderAnyStatusNotificationBox();

			$.ajax(settings.statusOptionsUrl, {type: 'GET', dataType: 'json', cache: false}).done(function(statuses) {
				renderStatusNotificationBox(statuses);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			});
		}

		function init(container, tracker, notifications) {
			if (!$.isArray(notifications)) {
				notifications = [];
			}

			container.append($('<h2>' + i18n.message('tracker.notification.any.label') + '' +
				'<span class="subtext">(' + i18n.message('tracker.notification.any.description') + ')</span></h2>'));

			var table = $('<table>', { "class" : 'displaytag notifications' }).data('tracker', tracker);
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>');

			if (settings.canSubscribeOthers) {
				headline.append($('<th>', { "class" : 'textData  columnSeparator' }).text(settings.subscribersLabel));

				if (!settings.simpleSelect) {
					headline.append($('<th>', { style : 'width: 5%; text-align: center"' }).text(settings.onlyMembersLabel));
				}
			} else {
				headline.append($('<th>', { style : 'width: 5%; text-align: center"' }).text(settings.subscribedLabel));
			}

			header.append(headline);

			var body = $('<tbody>');
			table.append(body);

			var hasAnyNotification = false;

			for (var i = 0; i < notifications.length; ++i) {
				if (addNotification(body, tracker, notifications[i]) != null) {
					hasAnyNotification = true;
				}
			}
			if (!hasAnyNotification) {
				// create new row if it is simple select
				addNotification(body, tracker, null);
			}

			/**
			 * If there is no subscribe others and admin public view permission, do not display the notification tables
			 * by statuses (for creating status notification we need change filters or event filters, and for that we
			 * need to create public views)
			 */
			if (settings.canSubscribeOthers) {
				renderTrackerStatusBox(tracker, container);
			}
		}

		return this.each(function() {
			init($(this), tracker, notifications);
		});
	};


	$.fn.notificationList.defaults = {
		editable			: false,
		simpleSelect		: false,
		canSubscribeOthers  : false,
		subscribedLabel		: 'Subscribed',
		subscribersLabel	: 'Subscribers',
		onlyMembersLabel	: 'Only Members',
		onlyMembersTitle	: 'Only notify direct project members in the specified roles, no indirect members'
	};


	// Get the configured tracker/item notifications
	$.fn.getNotifications = function() {
		var notifications = [];

		$('table.notifications tr.notification', this).each(function() {
			var row = $(this);
			var notification = row.data('notification');
			if (notification) {
				var subscribers = $('td.subscribers', row);
				if (subscribers.length > 0) {
					notification.subscribers = subscribers.getReferences();
					notification.eventFilter.onlyMembers = $('td.onlyMembers > input[type="checkbox"]', row).is(':checked');
				} else {
					notification.subscribers = [];
					notification.eventFilter.onlyMembers = $('td.subscribed > input[type="checkbox"]', row).is(':checked');
				}

				notifications.push(notification);
			}
		});

		return notifications;
	};


})( jQuery );
