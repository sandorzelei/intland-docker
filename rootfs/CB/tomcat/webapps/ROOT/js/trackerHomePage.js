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
codebeamer.TrackerHomePage = codebeamer.TrackerHomePage || (function($) {

	var $treePane;
	var tree;
	var editable = false;
	var referenceMode = false;
	var revision = null;

	var getTree = function() {
		if (tree != null) {
			return tree;
		}
		return $.jstree.reference($treePane);
	};

	var checkMoveHandler = function(targetNode, node) {

		if (node.hasOwnProperty("li_attr") && node.li_attr.hasOwnProperty("data-disableOrder") && node.li_attr["data-disableOrder"]) {
			return false;
		}
		if (targetNode.hasOwnProperty("li_attr") && node.li_attr.hasOwnProperty("data-disableOrder") && targetNode.li_attr["data-disableOrder"]) {
			return false;
		}

		return true;
	};

	var moveNodeHandler = function(node, newParentNode) {
		var tree = getTree();
		tree.delete_node(node);
		tree.open_node(newParentNode);
		refreshExtraInfo();
		if (newParentNode.id != "#") {
			addExtraInfoToNode($treePane.find("#" + newParentNode.id));
		}
		saveStructure();
	};

	var renameNodeHandler = function(node, text, old) {
		if (node.li_attr.hasOwnProperty("data-isFolder") && node.li_attr["data-isFolder"] == "true") {
			saveStructure();
		} else {
			var tree = getTree();
			var trackerId = node.li_attr.hasOwnProperty("data-trackerId") ? node.li_attr["data-trackerId"] : null;
			if (trackerId !== null) {
				var data = {
					"tracker_id" : trackerId,
					"name" : text
				};
				$.ajax({
					url: contextPath + "/ajax/renameTrackerFromTree.spr",
					type: "POST",
					data: data,
					dataType: "json"
				}).done(function(result) {
					if (result.hasOwnProperty("error")) {
						showOverlayMessage(result["error"], null, true);
						tree.set_text(node, old);
					} else if (result.hasOwnProperty("success") && result["success"]) {
						showOverlayMessage(i18n.message("tracker.homepage.successfully.renamed"));
					}
				}).fail(function() {
					showOverlayMessage(i18n.message("tracker.homepage.rename.warning"), null, true);
					tree.set_text(node, old);
				}).always(function() {
					refreshExtraInfo();
				});
			}
		}
	};

	var renameNode = function(nodeId) {
		var tree = getTree();
		var node = tree.get_node(nodeId);
		tree.edit(node);
	};

	var createNewFolder = function(nodeId) {
		var tree= getTree();
		var node = tree.get_node(nodeId);
		tree.create_node(node, {
			text: i18n.message("tracker.view.layout.document.new.folder"),
			icon: contextPath + "/images/issuetypes/folder.gif",
			li_attr: {
				"data-isFolder": "true"
			}
		}, "last", function(createdNode) {
			tree.open_node(node);
			renameNode(createdNode);
			saveStructure();
			refreshExtraInfo();
		});
	};

	var removeFolder = function(nodeId) {
		var tree = getTree();
		var node = tree.get_node(nodeId);
		var $children = tree.get_children_dom(node);
		if ($children.length > 0) {
			$($children.get().reverse()).each(function() {
				tree.move_node(tree.get_node($(this)), tree.get_node(tree.get_parent(node)), "first");
			});
		}
		tree.delete_node(node);
		saveStructure();
		refreshExtraInfo();
	};

	var populateReferenceModeContextMenuFunction = function() {
		// Disable context menu for all nodes
		return {};
	};

	var getStructure = function() {
		var json = tree.get_json("#", {
			"no_id" : true
		});

		var processNode = function(node) {
			var result = {};
			if (node.li_attr.hasOwnProperty("data-disableOrder") && node.li_attr["data-disableOrder"]) {
				return result;
			}
			if (node.li_attr.hasOwnProperty("data-isFolder")) {
				result["isFolder"] = true;
				result["text"] = node.text;
			} else {
				result["trackerId"] = node.li_attr["data-trackerId"];
			}
			if (node.hasOwnProperty("children") && node.children.length > 0) {
				var childNodes = [];
				for (var i = 0; i < node.children.length; i++) {
					var child = processNode(node.children[i]);
					if (!$.isEmptyObject(child)) {
						childNodes.push(child);
					}
				}
				result["children"] = childNodes;
			}
			return result;
		};

		var structure = [];
		if (json && json.length > 0) {
			for (var j = 0; j < json.length; j++) {
				var res = processNode(json[j]);
				if (!$.isEmptyObject(res)) {
					structure.push(res);
				}
			}
		}

		return structure;
	};

	var saveStructure = function() {
		var data = {
			"proj_id" : $treePane.attr("data-projectId"),
			"structure" : JSON.stringify(getStructure())
		};
		$.ajax({
			url: contextPath + "/ajax/saveTrackerHomePageStructure.spr",
			type: "POST",
			data: data,
			dataType: "json"
		}).done(function(result) {
			if (result.hasOwnProperty("success") && result["success"]) {
				showOverlayMessage(i18n.message("tracker.homepage.tree.successfully.saved"));
			} else {
				showOverlayMessage(i18n.message("tracker.homepage.save.tree.warning"), null, true);
			}

			// make sure that the branch node colors are always initialized correctly after a move
			initializeTreeIconColors($treePane);
		}).fail(function() {
			showOverlayMessage(i18n.message("tracker.homepage.save.tree.warning"), null, true);
		});
	};

	var addExtraInfoToNode = function($li) {
		if ($li.attr("data-trackerId") && !$li.attr("data-noPermission") && $li.children(".trackerItemStat").length == 0) {
			var openItems = $li.attr("data-openItems");
			var allItems = $li.attr("data-allItems");
			var modifiedAt = $li.attr("data-modifiedAt");
			var tooltip = i18n.message("user.issues.open") + ": " + openItems + ", " +
				i18n.message("user.issues.all") + ": " + allItems + ", " +
				i18n.message("tracker.homepage.last.modified.at.label") + ": " + modifiedAt;
			var $itemNumberSpan = $("<span>", { "class" : "trackerItemStat"}).attr("title", tooltip).html("<b>" + openItems + "</b> / " + allItems);
			if (revision != null) {
				$itemNumberSpan = $("<span>", { "class" : "trackerItemStat"}).attr("title", i18n.message("tracker.homepage.na.tooltip")).html(i18n.message("tracker.homepage.na.label"));
			}
			var $modifiedAtSpan = $("<span>", { "class" : "trackerModifiedAt"}).attr("title", tooltip).html(modifiedAt);
			var trackerKey = $li.attr("data-trackerKey");
			if (trackerKey.length > 0) {
				var $trackerKeyBadge = $("<span>", { "class" : "trackerKey"}).html(trackerKey);
				$li.find("a").first().after($trackerKeyBadge);
			}
			$li.find("a").first().after($modifiedAtSpan);
			$li.find("a").first().after($itemNumberSpan);
		}
		if ($li.attr("data-noPermission") == "true") {
			$li.children(".jstree-anchor").first().attr("title", i18n.message("tracker.homepage.not.visible.tooltip"));
		}
	};

	var refreshExtraInfo = function() {
		tree = getTree();
		$(tree.get_json($treePane, { flat: true})).each(function() {
			var $li = $treePane.find("#" + this.id);
			addExtraInfoToNode($li);
		});
	};

	var initSearch = function() {
		$treePane.bind("search.jstree", function() {
			setTimeout(function() {
				refreshExtraInfo();
			}, 1);
		});
		$treePane.bind("clear_search.jstree", function() {
			setTimeout(function() {
				refreshExtraInfo();
			}, 1);
		});
	};

	var initTree = function(selectedIds) {

		var openItemInNewTab = function(trackerUrl) {
			window.open(contextPath + trackerUrl, "_blank");
		};

		// open item in new tab in case of middle click
		$treePane.on("mousedown", function(event) {
			if (event.which == 2) {
				var $target = $(event.target);
				if ($target.is(".jstree-anchor")) {
					var $node = $target.closest("li");
					var trackerUrl = $node.attr("data-trackerUrl");
					if ($node.attr("data-trackerUrl")) {
						openItemInNewTab(trackerUrl);
					}
				}
			}
		});
		$("body").on( "mousedown", ".jstree-contextmenu", function(event) {
			if (event.which == 2) {
				var $target = $(event.target);
				var trackerUrl = $target.find(".tableIcon").attr("data-trackerUrl");
				if (trackerUrl) {
					openItemInNewTab(trackerUrl);
				}
			}
		});

		$treePane.bind("open_node.jstree", function(event, data) {
			var node = data.node;
			if (node.hasOwnProperty("children_d")) {
				var ids = node.children_d;
				for (var i = 0; i < ids.length; i++) {
					var $li = $treePane.find("#" + ids[i]);
					addExtraInfoToNode($li);
				}
			}
		});
		$treePane.bind("loaded.jstree", function() {
			tree = $.jstree.reference($treePane);
			setTimeout(function() {
				if (!referenceMode) {
					tree.deselect_all();
					tree.select_node("#");
					if ($.jStore.get("CB-trackerHomePage-" + $treePane.attr("data-projectId")) == null) {
						tree.open_all();
					}
				} else {
					tree.deselect_all(true);
					if (selectedIds && selectedIds.length > 0) {
						tree.select_node(selectedIds, true);
						callSaveTrackers($treePane, selectedIds.join(','));
					} else {
						callSaveTrackers($treePane, "-1");
						showFancyAlertDialog(i18n.message("tracker.class.diagram.empty.warning"));
					}
					setTimeout(function() {
						codebeamer.ClassDiagram.refreshDiagram();
					}, 300);
				}
				refreshExtraInfo();
			}, 1);
		});
		initSearch();
		setTimeout(function() {
			if (editable) {
				$treePane.bind("rename_node.jstree", function(event, data) {
					renameNodeHandler(data.node, data.text, data.old);
				});
			}
			refreshExtraInfo();
		}, 200);
	};

	var callSaveTrackers = function($treePane, selectedTrackers) {
		$.post(contextPath + "/proj/tracker/classDiagramSave.spr", {
			"proj_id": $treePane.attr("data-projectId"),
			"selectedTrackers": selectedTrackers
		});
	};

	var initConfiguration = function($treePane) {
		$(".trackerHomePageConfiguration").click(function() {
			showPopupInline(contextPath + "/trackers/trackerHomePageConfiguration.spr?proj_id=" + $treePane.attr("data-projectId"), { width: 600 });
		});
	};

	var init = function($providedTreePane, providedEditable, providedReferenceMode, selectedIds, providedRevision) {
		$treePane = $providedTreePane;
		editable = providedEditable;
		if (providedReferenceMode) {
			referenceMode = providedReferenceMode;
		}
		if (providedRevision) {
			revision = providedRevision;
		}
		initTree(selectedIds);
		initConfiguration($providedTreePane);
	};

	return {
		"init" : init,
		"checkMoveHandler" : checkMoveHandler,
		"moveNodeHandler": moveNodeHandler,
		"populateReferenceModeContextMenuFunction" : populateReferenceModeContextMenuFunction,
		"callSaveTrackers" : callSaveTrackers,
		"createNewFolder" : createNewFolder,
		"removeFolder" : removeFolder,
		"renameNode" : renameNode
	};

})(jQuery);

var showCreateBranchDialog = function (url) {
	inlinePopup.close();
	showPopupInline(url);
}