var codebeamer = codebeamer || {};
codebeamer.trackerItemRelationsExpander = codebeamer.trackerItemRelationsExpander || (function () {

	function attachEventHandlers() {
		// Remove listener first. This makes it possible to directly or indirectly load the script several times on the same page.
		$(".relationsExpander").off("click.trackerItemRelationsExpander");
		$(".relationsExpander").on("click.trackerItemRelationsExpander", "tr fieldset.collapsingBorder legend a", function(event) {
			$(this).closest("fieldset.collapsingBorder").toggleClass("collapsingBorder_collapsed");
			event.preventDefault();
			event.stopPropagation();
		});
	}

	return {
		"attachEventHandlers": attachEventHandlers
	};

})();

jQuery(function($) {
	codebeamer.trackerItemRelationsExpander.attachEventHandlers();
});