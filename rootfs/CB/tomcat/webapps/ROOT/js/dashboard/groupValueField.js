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
codebeamer.dashboard.groupValueField = codebeamer.dashboard.groupValueField || (function($) {
	
	var queryString = "";
	var queryId = "";
	var aggregationType = "";
	
	function setQueryString(queryStringParam) {
		queryString = queryStringParam;
		queryId = "";
		aggregationType = "";
	}
	
	function setQueryId(queryIdParam) {
		queryId = queryIdParam;
		queryString = "";
		aggregationType = "";
	}
	
	function setAggregationType(aggregationTypeParam) {
		aggregationType = aggregationTypeParam;
	}

	function processGroupingData(data, selectorId, selectedValue) {
		if (data && data[aggregationType] && data[aggregationType].length) {
			for (var i = 0; i < data[aggregationType].length; i++) {
				var groupingValue = data[aggregationType][i];
	
				var $selector = $("#" + selectorId);
				
				var $option = $("<option>", { value : groupingValue.key + ':' + aggregationType }).text(groupingValue.key + ' (' + groupingValue.value + ')');
	
				// set checked
				if (selectedValue == (groupingValue.key + ':' + aggregationType)) {
					$option.attr("selected", "selected");
				}
				
				$selector.append($option);
			}
		}
		// disable field and show an error message
		if (data == null || data[aggregationType] == null || data[aggregationType].length == 0) {
			$("#emptyValueWarning").css('display', 'block');
			$("#" + selectorId).attr("disabled", "disabled");
		}
		
		$('#' + selectorId + '-ajaxLoadingImg').hide();
		$("select[name*='params[aggregationFunction]'").removeAttr('disabled');
	}
	
	function loadGroupingValues(selectorId, groupingValuesOptionsUrl, groupingValuesOptionsUrlByQueryString, selectedValue) {
		$("select[name*='params[aggregationFunction]'").attr('disabled','disabled');
		$('#' + selectorId + '-ajaxLoadingImg').show();
		
		var groupSelect = $("#" + selectorId);
		
		groupSelect.empty();
		
		if (queryString == "") {
			$.get(groupingValuesOptionsUrl, {
				queryId: queryId
			}, function (data) {
				processGroupingData(data, selectorId, selectedValue);
			});
		} else {
			$.get(groupingValuesOptionsUrlByQueryString, {
				query: queryString
			}, function (data) {
				processGroupingData(data, selectorId, selectedValue);
			});
		}
	}

	return {
		"setQueryString": setQueryString,
		"setQueryId": setQueryId,
		"setAggregationType": setAggregationType,
		"loadGroupingValues": loadGroupingValues
		
	};
})(jQuery);
