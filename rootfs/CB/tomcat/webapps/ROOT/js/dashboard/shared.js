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
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.shared = codebeamer.dashboard.shared || (function($) {

	function QueryIdStore(initialQueryId) {
		this.initialQueryId = initialQueryId;
		this.actualQueryId = initialQueryId;
	};

	QueryIdStore.prototype.isInitialQuerySelected = function() {
		return this.actualQueryId === this.initialQueryId;
	};

	QueryIdStore.prototype.update = function(newQueryId) {
		if (newQueryId) {
			this.actualQueryId = newQueryId;
		}
	};

	function createQueryIdStore(value) {
		return new QueryIdStore(value);
	};

	function isCustomField(field) {
		// All values under QueryConditionWidgetSupport.referenceFieldIds must be here as well, otherwise these fields might be not processed correctly.
		return field > 1000 || field === 79 || field === 76 || field === 31 || field === 21 || field === 17 || field === 16;
	}

	function isSameCustomField(field1, field2) {
		var result = false;

		if (field1 === field2) {
			result = true;
		}

		return result;
	}

	return {
		"createQueryIdStore": createQueryIdStore,
		"isCustomField": isCustomField,
		"isSameCustomField": isSameCustomField
	};
})(jQuery);