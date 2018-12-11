var codebeamer = codebeamer || {};
codebeamer.history = codebeamer.history || (function($) {

	function initializeHistoryList(tableSelector) {
		jQuery(function($) {
			var table = $(tableSelector);

			$("#filterInput").keyup(function() {
				$.uiTableFilter(table, this.value);
			}).Watermark(i18n.message("user.history.filter.label"));

			setTimeout(function() {
				$("#filterInput").focus();
			}, 100);
		});
	}

	function initilizeLinkHandler() {
		$(".itemUrl").on("click", function(event) {
			event.stopPropagation();
			event.preventDefault();

			parent.window.location.href = this.href;
		});
	}

	function initilizeAdvancedSearchLinkHandler() {
		$(".goToAdvancedSearchLink").on("click", function(event) {
			event.stopPropagation();
			event.preventDefault();

			parent.window.location.href = $(".goToAdvancedSearchLink").attr("href");
		});
	}

	return {
		"initializeHistoryList": initializeHistoryList,
		"initilizeLinkHandler": initilizeLinkHandler,
		"initilizeAdvancedSearchLinkHandler": initilizeAdvancedSearchLinkHandler
	};
}(jQuery));