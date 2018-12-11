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
 *
 * $Revision$ $Date$
 */

/**
 * Javascript loads diffs in an ajax call, and displays them on click.
 * See showDiff.jsp and changeSetFiles.tag
 */
var showDiff = {

	// loadAllDiffsEnabled
	loadAllDiffsEnabled: true,

	// the reference objects created by createRefs, indexed by the HTTP parameter string
	refs: {},
	// html-id -> reference object map for quick access references for html-ids
	htmlIdToRef: {},

	toggleDiff: function(linkElement, open, oneFileDiff) {
		var link = $(linkElement);
		var diffElementId = link.attr("rel");	// the related diff element is in the "rel" attribute
		var diffContainer = $("#" + diffElementId);

		var loadingPlaceholder = diffContainer.find('.diff-loading-placeholder');
		if (!showDiff.loadAllDiffsEnabled && oneFileDiff && loadingPlaceholder.size() > 0) {
			return;
		}

		link.toggleClass("toggleLinkOpen", open);
		if(link.hasClass("toggleLinkOpen")) {
			diffContainer.show();
		} else {
			diffContainer.hide();
		}
	},

	/**
	 * Toggle (open/close) all diffs of a changeset
	 * @param linkElement The toggle html element clicked, its css contains the toggle status
	 * @param diffsParentId The html-id of the parent-element for the changeset
	 */
	toggleAllDiffs: function(linkElement, diffsParentId) {
		$(linkElement).toggleClass("toggleLinkOpen");
		var open = $(linkElement).hasClass("toggleLinkOpen");

		var toggleLinks = $("#"+diffsParentId).find(".toggleLink");

		// open/close all diffs below this changeset
		toggleLinks.each(function(index, toggleLink) {
			showDiff.toggleDiff(toggleLink, open);
		});

		if (open) {
			// check if all diffs of the toggled diffs are loaded
			var refsToLoad = {};
			for(var i=0; i < toggleLinks.length; i++) {
				var link = $(toggleLinks[i]);
				var diffElementId = link.attr("rel");	// the related diff element is in the "rel" attribute
				var ref = showDiff.htmlIdToRef[diffElementId];
				if (ref != null) {
					refsToLoad[ref.key] = ref;
				}
			}
			showDiff._loadDiffs(refsToLoad);
		}
	},

	/**
	 * Load the diffs for the html-elements - if not yet loaded-
	 * @param htmlIds The html-id array
	 */
	_loadDiffsForHtmlIds: function(htmlIds) {
		var refsToLoad = {};
		var ref = showDiff.htmlIdToRef[diffElementId];
		if (ref != null) {
			refsToLoad[ref.key] = ref;
		}
		showDiff._loadDiffs(refsToLoad);
	},

	// create or get the reference to the changeset
	getRef: function(repositoryId, oldRevision, newRevision, filePath) {
		var obj = { repositoryId: repositoryId, oldRevision: oldRevision, newRevision: newRevision, filePath:filePath};
		var key = $.param(obj);	// the parameter string is the unique parameter identifies this diff
		var sameObject = showDiff.refs[key];
		if (sameObject != null) {
			return sameObject;
		}
		obj.key = key;
		showDiff.refs[key] = obj;
		return obj;
	},

	registerDiffPlaceHolder:function(htmlId, repositoryId, oldRevision, newRevision, filePath) {
		var ref = showDiff.getRef(repositoryId, oldRevision, newRevision, filePath);
		if (ref.diffs == null) {
			ref.diffs = new Array();
		}
		ref.diffs.push(htmlId);
		showDiff.htmlIdToRef[htmlId] = ref;

		// indicate that this is loading...
		$('#' + htmlId).html("<img class='diff-loading-placeholder' src='" + contextPath + "/images/ajax-loading_16.gif'>" + i18n.message("ajax.loading") +"</img>");
	},

	// load all diffs and render all diffs and diff-stats which are registered
	loadAllDiffs: function() {
		if (showDiff.loadAllDiffsEnabled) {
			showDiff._loadDiffs(showDiff.refs);
		}
	},

	// load few diffs and render diff and diff-stats
	_loadDiffs: function(refs) {
		var url = contextPath + "/proj/scm/ajax/renderChangeFileDiff.spr?includeHeader=false";
		var params = new Array();
		for (var param in refs) {
			var ref = refs[param];
			if (ref.rendered != true) {	// don't load those diffs which are already loaded & rendered
				params.push(param);
			}
		}
		if (params.length >0) {
			var dataObj = params.join("&");
			$.ajax({
				url: url,
				type: "POST",
				data: dataObj,
				cache: false
				})
				.success(function(data, status,jqXHR) {
					var result = data.result;
					for (var i=0; i<result.length; i++) {
						var r = result[i];
						showDiff._renderResult(r);
					}

					$(document).trigger("diffsRendered");
				})
				.error(function(jqXHR, textStatus, errorThrown) {
					console.log("Failed to load diffs:" + errorThrown +", response:\n" + jqXHR.responseText);
				});
		}
	},

	_renderResult:function(oneDiff) {
		var ref = showDiff.getRef(oneDiff.repositoryId, oneDiff.oldRevision, oneDiff.newRevision, oneDiff.filePath);
		ref.rendered = true;	// mark this reference as rendered

		// render diffs and statistics
		var diffHTMLElements = ref.diffs;
		if (diffHTMLElements != null) {
			for (var i=0; i<diffHTMLElements.length; i++) {
				var htmlId = diffHTMLElements[i];
				$("#"+htmlId).html(oneDiff.diffHTML);

				// the "statistics" placeholder always has the same html-id as the diff element + "_stats"
				var statsHtmlId = htmlId + "_stats";
				if (oneDiff.linesAdded != null) {
					var htmlFrag = "<span class=\"linesAdded\">+" + oneDiff.linesAdded +"</span>&nbsp;" +
								   "<span class=\"linesRemoved\">-" + oneDiff.linesRemoved +"</span>";
					$("#"+statsHtmlId).html(htmlFrag)
								      .show();
					$("#"+statsHtmlId).closest("a").show();
				}
			}
		}
	}

}

// when the DOM is readly load all diffs
$(document).ready(showDiff.loadAllDiffs);
