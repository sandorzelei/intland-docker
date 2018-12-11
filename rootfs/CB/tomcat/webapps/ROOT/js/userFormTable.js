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

$(document).ready(function() {

	function onSaveButtonClick(e) {
		var self = $(this);
		showFancyConfirmDialogWithCallbacks(i18n.message("user.encrypt.save.warning"), function() {
			self.closest("form").submit();
		});
		e.stopPropagation();
		e.preventDefault();
	}

	function encryptSensitiveData() {
		var random;

		random = $(this).data("encryption-base");

		$("input.sensitive, textarea.sensitive").each(function() {
			var value, encryptedValue;

			value = $(this).val();
			encryptedValue = JSON.parse(sjcl.encrypt(random, value));

			$(this).val(encryptedValue.ct);
		});

		$("select.sensitive").each(function() {
			$(this).val("--").change();
		});

		$("input.encryptionRequest").val(true);

		$("input[data-purpose=submit]").click(onSaveButtonClick);

	}

	$(".encryptButton").click(function(e) {
		showFancyConfirmDialogWithCallbacks(i18n.message("user.encrypt.warning"), encryptSensitiveData.bind(this));
	});

	$(".userStatusDropdown").change(function(event) {
		var value, $self;

		function handleStatusChangeCancel() {
			$self.val($self.data("original-value"));
		}

		$self = $(this);
		value = $self.val();

		if (value === "disabled") {
			showFancyConfirmDialogWithCallbacks(i18n.message("user.reactivation.warning"), function() {}, handleStatusChangeCancel);
		}

	});

	$(".userStatusDropdown").data("original-value", $(".userStatusDropdown").val());

	codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());

});