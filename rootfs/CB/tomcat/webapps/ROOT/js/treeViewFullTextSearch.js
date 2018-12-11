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
// Create a custom jQuery selector and set it as the default for our jsTree's search function.
function searchIdMatches(filterText, node) {
	var idAttr = node.id;
	return filterMatching(filterText, idAttr);
};

$.expr[':'].id_matches = function(a, i, m) {
	var idAttr = $(a).closest("li").attr("id");

	return filterMatching(m[3], idAttr);
};

function filterMatching(filterText, idAttr) {
	var id = parseInt(parseReferenceId(idAttr).id);
	var matchedIdsMap = $("#treePane").prop("searchMatches") || {};
	var subFilter = filterText;
	// If a valid match type is provided (e.g. TITLE or DESCRIPTION), filter against that only
	if (subFilter != '-') {
		return jQuery.inArray(id, matchedIdsMap[subFilter] || []) !== -1;
	} else {
		var match = false;
		for (var matchedIdsKey in matchedIdsMap) {
			var matchedIds = matchedIdsMap[matchedIdsKey];
			if (jQuery.inArray(id, matchedIds) !== -1) {
				match = true;
				break;
			}
		}
		return match;
	}
}

codebeamer.fullTextSearch = jQuery.extend(codebeamer.fullTextSearch || {}, {
	searchConfig: {
		search_callback: searchIdMatches
	}
});

/**
 * Initialize full text search for a specified tree pane.
 * @param treePane Tree pane
 * @param contextName Either 'wiki' or 'documentView'
 * @param artifactId For wiki mode, this is the project ID, in document view mode, this is the tracker ID
 */
function initTreeViewSearch(treePane, contextName, artifactId) {

	var isWikiContext = (contextName == 'wiki');
	var isDocumentViewContext = (contextName == 'documentView');

	if (!isWikiContext && !isDocumentViewContext) {
		throw "Unknown tree filter context!";
	}

	var prepareRequest = isWikiContext ? function(filterText) {
		var projectId = artifactId;
		var dataToSend = {
			pattern: filterText,
			project_id: projectId
		};
		if (!projectId) { // is a user wiki page tree
			var userWikiPageRootReference = treePane.find("li").first().attr("id");
			dataToSend["user_page_root_reference"] = userWikiPageRootReference;
		}
		return dataToSend;
	} : function(filterText) {
		var trackerId = artifactId;
		return {
			pattern: filterText,
			tracker_id: trackerId
		};
	};

	var ajaxSearchUrl = isWikiContext ? "/ajax/wikis/search.spr" : "/ajax/documentView/search.spr";

	var doAjaxFilter = throttleWrapper(function(filterText, callback) {
		$.ajax({
			"type": "post",
			"url": contextPath + ajaxSearchUrl,
			"data": prepareRequest(filterText)
		}).done(function(response) {
			treePane.prop("searchMatches", response)
				.jstree("search", "-");
			treePane.find("a:id_matches(TITLE)").parent().addClass("result titleResult");
			treePane.find("a:id_matches(DESCRIPTION)").parent().addClass("result descriptionResult");
			treePane.find("a:id_matches(ISSUE_ID)").parent().addClass("result idResult");
			treePane.find("a:id_matches(WIKI_ID)").parent().addClass("result idResult");

			if ($.isFunction(callback)) {
				callback.call(response);
			}
		}).fail(function() {
			var threeSeconds = 3;
			showOverlayMessage(i18n.message("ajax.genericError"), threeSeconds, true);
		});
	}, 500);

	var containsDelimiterCharacters = function (filterText) {
		if (filterText.match("\"([^\"]*)\"")) {
			// when the filter text is between quotes we don't check if it contains delimiter characters
			return false;
		}
        return codebeamer.DELIMITERS.some(function (character) {
        	return filterText.indexOf(character) >= 0;
		});
	};

	treePane.on("codebeamer.filtered", function(event, tree, filterText) {
        var warningId = 'delimiterSearchWarning';
        $('#' + warningId).remove();

		if (filterText.length < 2 || filterText == i18n.message("association.search.as.you.type.label")) {
			tree.jstree("clear_search").removeClass("searchFiltered");
			tree.find(".result").removeClass("result");
		} else {
			tree.find(".result").removeClass("result");
			tree.addClass("searchFiltered");

			doAjaxFilter(filterText, function () {
                if (containsDelimiterCharacters(filterText)) {
                    var $warning = $('<div>', {'class': 'smallWarning', 'id': warningId});
                    $warning.html(i18n.message('search.delimiter.character.warning'));
                    $('#treePane').before($warning);
                }
			});
		}
	});
}
