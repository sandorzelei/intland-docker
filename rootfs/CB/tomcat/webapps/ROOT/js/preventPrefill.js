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
 */

var codebeamer = codebeamer || {};
codebeamer.prefill = codebeamer.prefill || (function($) {

	function ignoreEnterKey(e) {
		// prevent form close in IE
		if (e.which == 13) {
			return false;
		}
	};

	function prevent($input, browserType) {

		$input.addClass("noPrefill");

		$input.attr("autocomplete", "new-password");

		if (browserType === "IE") {
			$input.attr("type", "password");
		}

		$input.attr("readonly", "readonly");

		// Prevent password autofill; ugly workaround because ALL SUPPORTED BROWSERS just ignore the autocomplete attribute.
		$input.on("focus", function(e) {
			var len;

			// Chrome started to show the autofill menu, when the input is in text field mode. This means that the saved password is revealed. (Status as of  66.0.3359.181)
			// This change does not prevent the autofill menu to appear, but makes sure that the field is in password mode, so no one will see the readable form of the saved password.
			if (browserType === "CHROME") {
				$(this).attr("type", "password");
			}

			$(this).removeAttr("readonly");

			// Lazy IE does not update the readonly attribute, so another click is required to write into the field.
			// An extra blur/focus would fix this, but in our case this would just cause an infinite loop.
			// Moving the cursor to the end of the text does the trick as well.
			if (browserType === "IE") {
				len = $(this).val() ? $(this).val().length : 0;
				this.setSelectionRange(len, len);
			}
		}).on("blur", function(e, preventModification) {
			$(this).attr("readonly", "readonly");
		}).keydown(function(e) {
			var $self = $(this);

			if (browserType === "FF") {
				$input.attr("type", "password");
			}

			if (e.which === 13) {
				ignoreEnterKey(e);
				// Set the type again to text to prevent autofill
				if (browserType === "FF") {
					$self.attr("type", "text");
				}
			} else {
				// Last character deleted (delete or backspace), or the whole text is selected and deleted
				if ((e.which === 8 || e.which === 46) && ($self.val().length === 1 || (this.selectionStart === 0  && this.selectionEnd === $self.val().length))) {
					$self.val("");
					// Set the type again to text to prevent autofill
					if (browserType === "FF") {
						$self.attr("type", "text");
					}
					e.preventDefault();
					e.stopPropagation();
				} else {
					if (browserType === "CHROME") {
						// Set the type to password to hide content
						setTimeout(function() {
							$self.attr("type", "password");
						}, 1);
					}
				}
			}
		}).change(function(e) {
			var $self = $(this);
			// Delete autofilled content, Chrome only.
			if (browserType === "CHROME") {
				window.setTimeout(function() {
					if ($self.is("input:-webkit-autofill")) {
						$self.val("");
						e.preventDefault();
						e.stopPropagation();
					}
				}, 10);
			}
		});

	}

	return {
		"prevent": prevent,
		"ignoreEnterKey": ignoreEnterKey
	};
}(jQuery));