
/**
 * Finds all "selectedRevision" checkboxes of below the parentEL DOM element.
 * If only two of this checkboxes selected will open a popup with the compareURL as url,
 * plus the selected-checkboxes' value as "revision1" and revision2.
 *
 * @param parentEl The parent DOM elmenet where checkboxes are sought.
 * @param compareURL the popup url
 */
function compareRevisions(parentEl, compareURL) {

	var $selectedCheckboxes = $(parentEl).find("input:checked");
	if ($selectedCheckboxes.length != 2) {
		alert(i18n.message("ajax.compareRevisions.select.two.revisions"));
		return false;
	}
	var requestURL = compareURL + "&revision1=" + encodeURIComponent($selectedCheckboxes.get(1).value) +
								  "&revision2=" + encodeURIComponent($selectedCheckboxes.get(0).value);
	console.log("opening compareRevisions' requestURL:" + requestURL);
	launch_url(requestURL, "full_half");
	return false;
}

