var codebeamer = codebeamer || {};
codebeamer.stats = codebeamer.stats ||  (function($) {

	var filterPanelState, persistFilterStateAfterDelay;

	filterPanelState = {
		issueStatsByTeam: true,
		issueStatsByAssignee: true,
		issueStatsByProject: true,
		issueStatsByPriority: true,
		issueStatsByType: true,
		issueStatsByStatus: true
	};

	persistFilterStateAfterDelay = throttleWrapper(persistFilterState, 500);

	function initializeStatFilters() {
		$(document).ready(function() {
			var accordion = $('.versionStatsBoxAccordion');

			$('#versionStatsBox table').treetable({
				expandable: true
			});

			//Prevent clicking on the expander triggering the filtering as well
			$('.indenter').on('click.treetable', function(e) {
				e.stopPropagation();
			})

			accordion.cbMultiAccordion();

			$.get(contextPath + "/userSetting.spr?name=RELEASE_STATS_FILTER_PANEL_STATE", function(response) {
				var stateObject = $.parseJSON(response);

				if (!stateObject) {
					accordion.prop("default-accordion-state", filterPanelState);
					accordion.cbMultiAccordion("restoreState", filterPanelState);
				} else {
					accordion.prop("default-accordion-state", stateObject);
					accordion.cbMultiAccordion("restoreState", stateObject);
				}

				accordion.on("openOrClose", function() {
					filterPanelState = accordion.cbMultiAccordion("saveState");
					persistFilterStateAfterDelay();
				});
			});

		});
	}

	function persistFilterState() {
		if (filterPanelState) {
			$.post(contextPath + "/userSetting.spr", {
				"name": "RELEASE_STATS_FILTER_PANEL_STATE",
				"value": JSON.stringify(filterPanelState)
			});
		}
	}

	return {
		initializeStatFilters: initializeStatFilters
	};
})(jQuery);

codebeamer.stats.initializeStatFilters();
