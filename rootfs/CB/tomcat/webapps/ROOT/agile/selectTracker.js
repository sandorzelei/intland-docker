
/**
 * Javascript object for selecting project/tracker select boxes on selectTracker.jsp and selectTrackerWidget.jsp
 */
var selectTracker = {

	showProjectTrackers: function() {
		var $projects = $("#project");
		var $trackers = $("#tracker");
		$trackers.parent('span').find('.trackerSelector').remove();
		var projectId = $projects.val();
		var $showing = $trackers.find('[data-projectid="' + projectId + '"]');
		$trackers.hide();
		var $filteredSelect = $('<select name="tracker_id" class="trackerSelector dataCell">');
		$filteredSelect.change(function() {
			selectTracker.storeSelections();
		});
		$filteredSelect.append($showing.clone());
		var $first = $($showing.get(0));
		$filteredSelect.val($first.val());
		$trackers.after($filteredSelect);
		$(".trackerSelector option").first().attr("selected", "selected");
		selectTracker.storeSelections();
	},

	// store the selections somewhere, cookies or else ?, you can replace this method if you need some custom logic to store selection
	storeSelections: function() {
		// empty
	},

	// initialize and select a project/tracker pair
	init: function(selectedProject, selectedTracker) {
		if (selectedProject) {
			$("#project").val(selectedProject);

			selectTracker.showProjectTrackers();

			if (selectedTracker) {
				$(".trackerSelector").val(selectedTracker);
			} else {
				$(".trackerSelector option").first().attr("selected", "selected");
			}
		}
		selectTracker.storeSelections();
	}

}