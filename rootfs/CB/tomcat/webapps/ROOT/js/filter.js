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

// initialize the search filters
jQuery(function($) {
	var searchInProjects = document.getElementById('searchInProjects');
	var searchInWorkingSet = document.getElementById('searchInWorkingSet');
	var projIdList = document.getElementById('projIdList');
	var wsIdList = document.getElementById('wsId');

	var setAllOptionsSelected = function(selectElement, selected) {
		if (selectElement.selectedIndex == -1) {
			$(selectElement).find(">option").attr("selected", selected);
		}
	};

	if (searchInProjects && searchInProjects.checked) {
		if (searchInWorkingSet) {
			// deselect all working sets
			setAllOptionsSelected(wsIdList, false);
		}
		// select all projects
		setAllOptionsSelected(projIdList, true);
	} else if (searchInWorkingSet && searchInWorkingSet.checked) {
		if (searchInProjects) {
			// deselect all projects
			setAllOptionsSelected(projIdList, false);
		}
		// select one working set
		if (wsIdList.selectedIndex == -1 && wsIdList.length > 0) {
			wsIdList.selectedIndex = 0;
		}
	}

	codebeamer.toolbar.initProjectSelector($("#searchPageProjectSelector"), false, "advancedSearchProjectSelector");
	codebeamer.toolbar.preloadProjectSelector($("#searchPageProjectSelector"));
	codebeamer.toolbar.handleSubmit($("#searchForm"));

});
