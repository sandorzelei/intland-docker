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
codebeamer.QuerySubscription = codebeamer.QuerySubscription || (function($) {

	var initRecipients = function(roles, isPersonalSubscription) {
		$(".roleWarning").hide();

		$("#recipients").multiselect({
			classes: "queryConditionSelector",
			checkAllText : "",
			uncheckAllText: "",
			minWidth: 400,
			width: 400,
			selectedText: function(numChecked, numTotal, checkedItems) {
				var value = [];
				var $checkedItems = $(checkedItems);
				var isRoleSelected = false;
				$checkedItems.each(function(){
					var valueString = "";
					var $optGroup = $(this).closest("li").prevAll(".ui-multiselect-optgroup").first();
					if ($optGroup.length > 0) {
						isRoleSelected = true;
						valueString += $optGroup.find("a").text() + " → ";
					}
					valueString += $(this).next().html();
					value.push(valueString);
				});
				if (isRoleSelected) {
					$(".roleWarning").show();
				} else {
					$(".roleWarning").hide();
				}
				return value.join(", ");
			},
			noneSelectedText: function() {
				return "-";
			},
			create: function(event, ui) {
				// remove check/uncheck all/close buttons
				$(".queryConditionSelector .ui-multiselect-all").closest("ul").remove();
			},
			click: function() {
				var selected = $(this).multiselect("getChecked");
				if (selected.length == 0) {
                    $(this).val([0]);
					$(this).multiselect("refresh");
				}
				$(this).multiselect("getButton").css("width", "400px");
				$(this).multiselect("getButton").css("min-width", "400px");
				$(this).multiselect("widget").css("min-width", "400px");
				$(this).multiselect("widget").css("min-width", "400px");
			}
		}).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});
		var selectedOptions = roles.length > 0 ? roles.split(",") : [];
		if (isPersonalSubscription) {
			selectedOptions.push("0");
		}
		if (selectedOptions.length == 0) {
			selectedOptions.push("0");
		}
		$("#recipients").val(selectedOptions);
		$("#recipients").multiselect("refresh");
	};

	var initFrequency = function(cron, weekdays) {
		$('.frequency input[name="frequency"]').change(function() {
			$(".frequencyOptions").hide();
			$("#frequency_" + $(this).val() + "Div").show();
		});

		$("#monthOption_specificDay_day").change(function() {
			$("#monthOption_specificDay").prop("checked", "checked");
		});

		$("#monthOption_specificWeekDay_number, #monthOption_specificWeekDay_day").change(function() {
			$("#monthOption_specificWeekDay").prop("checked", "checked");
		});

		if (weekdays && weekdays != "null" && weekdays.length > 0) {
			var dayOfWeekParts = weekdays.split(",");
			for (var i = 0; i < dayOfWeekParts.length; i++) {
				$("#dayOfWeek" + dayOfWeekParts[i]).prop("checked", "checked");
			}
		}
	};

	var initSaveButton = function(queryId, subscriptionId, refererUrl) {
		$("#saveButton").click(function() {
			var name = $.trim($("#subscriptionName").val());
			if (name.length == 0) {
				showFancyAlertDialog("Please fill out name!"); // TODO i18n
			} else {
				var busy = ajaxBusyIndicator.showBusyPage();
				var recipients = [];
                $("#recipients").multiselect("getChecked").each(function() {
					recipients.push($(this).val());
				});
                if (recipients.length == 0) {
                	recipients = [0];
				}
				var data = {
					queryId: queryId,
					name: name,
					cron: buildCron(),
					recipients: recipients.join(","),
					daily: $("#frequency_daily").is(":checked"),
					weekly: $("#frequency_weekly").is(":checked"),
					monthly: $("#frequency_monthly").is(":checked"),
					oncePerDay: $("#frequencyDay").val() == "ONCE_PER_DAY",
					every4Hours: $("#frequencyDay").val() == "EVERY_4_HOURS",
					frequencyAt: $("#frequencyAt").val(),
					weekdays: getSelectedDayOfWeeks().join(","),
					dayOfMonth: $("#monthOption_specificDay").is(":checked") ? $("#monthOption_specificDay_day").val() : null,
					monthlyWeekdayNumber: $("#monthOption_specificWeekDay").is(":checked") ? $("#monthOption_specificWeekDay_number").val() : null,
					monthlyWeekdayDay: $("#monthOption_specificWeekDay").is(":checked") ? $("#monthOption_specificWeekDay_day").val() : null
				};
				if (subscriptionId) {
					data["subscriptionId"] = subscriptionId;
				}
				if ($("#thresholdCheckbox").is(":checked")) {
					var thresholdValue = $("#thresholdNumber").val();
					if (thresholdValue.toString().length == 0) {
						thresholdValue = $("#thresholdNumber").attr("placeholder");
					}
					data["resultThreshold"] = thresholdValue;
				}
				$.ajax({
					url: contextPath + "/ajax/queries/saveSubscription.spr",
					method: "POST",
					dataType: "json",
					data: data
				}).done(function(result) {
					if (result.hasOwnProperty("subscriptionId")) {
						if (refererUrl && refererUrl.length > 0) {
							window.parent.location = refererUrl;
						} else {
							window.parent.$("#editSubscription").attr("data-subscription-id", result.subscriptionId).show();
							window.parent.$("#newSubscription").hide();
							window.parent.showOverlayMessage(i18n.message("queries.subscription.successfully.saved"));
						}
						closePopupInline();
					} else if (result.hasOwnProperty("error")) {
						showFancyAlertDialog(result.error);
						ajaxBusyIndicator.close(busy);
					}
				}).fail(function() {
					showOverlayMessage(i18n.message("queries.subscription.unable.to.save"), null, true);
					ajaxBusyIndicator.close(busy);
				});
			}
		});
	};

	var getSelectedDayOfWeeks = function() {
		var selectedDayOfWeeks = [];
		if ($("#dayOfWeek1").is(":checked")) { selectedDayOfWeeks.push(1); }
		if ($("#dayOfWeek2").is(":checked")) { selectedDayOfWeeks.push(2); }
		if ($("#dayOfWeek3").is(":checked")) { selectedDayOfWeeks.push(3); }
		if ($("#dayOfWeek4").is(":checked")) { selectedDayOfWeeks.push(4); }
		if ($("#dayOfWeek5").is(":checked")) { selectedDayOfWeeks.push(5); }
		if ($("#dayOfWeek6").is(":checked")) { selectedDayOfWeeks.push(6); }
		if ($("#dayOfWeek7").is(":checked")) { selectedDayOfWeeks.push(7); }
		return selectedDayOfWeeks;
	};

	var buildCron = function() {

		// Defaults
		var seconds = "0";
		var minutes = "0";
		var hours = "0";
		var dayOfMonth = "*";
		var month = "*";
		var dayOfWeek = "?";
		var year = "*";

		// Parse daily
		var frequencyDay = $("#frequencyDay").val();
		var frequencyAt = parseInt($("#frequencyAt").val(), 10);
		if (frequencyDay == "ONCE_PER_DAY" || frequencyDay == "ONCE_PER_WEEKDAY") {
			hours = frequencyAt;
		} else if (frequencyDay == "EVERY_4_HOURS" || frequencyDay == "EVERY_4_HOURS_WEEKDAY") {
			var every4Hours = [];
			for (var i = 0; i < 6; i++) {
				var nextFrequencyAt = frequencyAt + (i * 4);
				if (nextFrequencyAt > 23) {
					break;
				}
				every4Hours.push(nextFrequencyAt);
			}
			hours = every4Hours.join(",");
		}
		if (frequencyDay == "ONCE_PER_WEEKDAY" || frequencyDay == "EVERY_4_HOURS_WEEKDAY") {
			dayOfWeek = "MON-FRI";
		}

		if ($("#frequency_weekly").is(":checked")) {

			// Parse weekly
			var selectedDayOfWeeks = getSelectedDayOfWeeks();
			dayOfMonth = "?";
			dayOfWeek = selectedDayOfWeeks.join(",");

		} else if ($("#frequency_monthly").is(":checked")) {

			// Parse monthly
			if ($("#monthOption_specificDay").is(":checked")) {
				dayOfMonth = $("#monthOption_specificDay_day").val();
			} else if ($("#monthOption_specificWeekDay").is(":checked")) {
				var selectedDayOfWeek = parseInt($("#monthOption_specificWeekDay_day").val(), 10);
				var selectedDayOfWeekNumber = $("#monthOption_specificWeekDay_number").val();
				dayOfMonth = "?";
				dayOfWeek = selectedDayOfWeek + (selectedDayOfWeekNumber != "L" ? "#" : "") + selectedDayOfWeekNumber;
			}
		}

		var cron = seconds + " " + minutes + " " + hours + " " + dayOfMonth + " " + month + " " + dayOfWeek + " " + year;
		return cron;
	};

	var init = function(queryId, subscriptionId, cron, roles, isPersonalSubscription, weekdays, refererUrl) {
		initRecipients(roles, isPersonalSubscription);
		initFrequency(cron, weekdays);
		initSaveButton(queryId, subscriptionId, refererUrl);
	};

	return {
		init: init
	}

})(jQuery);