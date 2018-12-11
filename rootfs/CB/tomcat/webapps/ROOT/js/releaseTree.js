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
 */
var codebeamer = codebeamer || {};
codebeamer.releaseTree = codebeamer.releaseTree || (function () {

	var releaseCheckMove = function (np, o, op, oldTree, isCopy) {
		if (!np || np.id == "#" || o.id == "#" || np.li_attr["type"] === "tracker" || o.li_attr["type"] == "tracker") {
			return false;
		}

		// don't allow moving releases under issues or change the issue hierarchy under a release
		var $domNode = $("li#" + np.id);
		if (!$domNode.hasClass("release-node")) {
			return false;
		}

		// don't allow moving test cases of requirements under releases
		if (o.li_attr["trackerId"] != trackerObject.config.id) {
			return false;
		}

		return true;
	};

	var releaseNodeMoved = function (nodes, parent, oldParent, isCopy) {
		var ids = [];
		for (var i = 0; i < nodes.length; i++) {
			ids.push(nodes[i].id);
		}

		if (isCopy || oldParent.id !== parent.id) {
			// when the node comes from the left tree just add the issue to the release
			addToRelease(parent.id, ids, nodes[0].li_attr["trackerId"], oldParent.id);
		}
	};

	var addToRelease = function (releaseId, issueIds, trackerId, originalRelease, callback) {
		var treePane = "releaseTreePane";

		var refreshTree = function(tree) {
			$("#" + treePane).one("refresh.jstree", null, function () {
				var filterText = $("#searchBox_releaseTreePane").val();
				if (filterText.length > 2) {
					tree.search(filterText);
				}
			});
			tree.refresh();
		};

		$.ajax({
			"url": contextPath + "/trackers/ajax/addToVersion.spr",
			"type": "POST",
			"data": {"targetVersionId": releaseId,
					"trackerItemIds": issueIds.join(","),
					"tracker_id": trackerId,
					"releasesFor": trackerObject.config.id,
					"oldRelease": originalRelease,
					"keepInOriginalRelease": true
			},
			"success": function(data) {
				showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
				refreshTree($.jstree.reference(treePane));
				var $props = $('#issuePropertiesPane');
				var loadedIssueId = $props.data("showingIssue");
				if (issueIds.indexOf(loadedIssueId) >= 0) {
					trackerObject.showIssueProperties(loadedIssueId, trackerObject.config.id, $props,
							trackerObject.config.revision == null || trackerObject.config.revision == "", true);
				}

				if (callback) {
					callback.apply(this);
				}
			},
			"error": function(data) {
				showOverlayMessage(data.responseText.length > 100 ? data.responseText.substr(0,99) : data.responseText, 6, true);
				refreshTree($.jstree.reference(treePane));
			}
		});
	};

	var releaseTreeContextMenu = function (node) {
		var elements = {};
		var $domNode = $("#releaseTreePane li#" + node.id);
		if ($domNode.hasClass("requirement-node")) {
			// menu items that are available on the requirements in the release tree
			var parentId = $.jstree.reference("releaseTreePane").get_parent(node);
			elements["remove"] = { "label": i18n.message("tracker.view.layout.document.remove.from.release"), "action": function () {
				$.ajax({
					"url": contextPath + "/trackers/ajax/removeFromVersion.spr",
					"type": "POST",
					"data": {"targetVersionId": parentId,
							"issue_id": node.li_attr["id"],
							"tracker_id": node.li_attr["trackerId"],
							"releasesFor": trackerObject.config.id
					},
					"success": function(data) {
						//trackerObject.reload("rightPane", false);
						$.jstree.reference("releaseTreePane").refresh();
					}
				});
			}};
		} else {
			// menu items available only on versions
			// TODO: check permissions
			var isTracker = node.li_attr["type"] == "tracker"
			elements["newChild"] = { "label": (isTracker ? i18n.message("tracker.type.Release.create.label")
					: i18n.message("cmdb.version.newsprint.label")), "action": function () {addNewRelease(node); }};
			if (node.li_attr["type"] != "tracker") {
				var url = contextPath + "/item/" + node.id + "/stats";

				elements['open'] = {
					"label": i18n.message("tracker.view.layout.document.open.label"),
					"action": function() {
						window.open(url, '_top');
					}
				};
				elements['openInNewTab'] = {
					"label": i18n.message("tracker.view.layout.document.open.in.new.tab"),
					"action": function() {
						window.open(url, '_blank');
					},
					"separator_after": true
				};
				

				elements["rename"] = {"label": i18n.message("action.rename.label"), action: function () {
					$.jstree.reference("releaseTreePane").edit(node);
					}
				};

				elements["coverageBrowser"] = {"label": i18n.message("tracker.show.in.coverage.browser.label"),
						"separator_before": true,
						"action": function () {
							location.href = contextPath + "/trackers/coverage/coverage.spr?tracker_id=" + trackerObject.config.id + "&requirementReleases=" + node.id;
						}
				};
			}
		}
		return elements;
	};

	var addNewRelease = function(node) {
		var trackerId = node.li_attr["trackerId"];
		var $treePane = $("#releaseTreePane");
		$treePane.jstree("create_node", node, { "li_attr": {
				"id": "0",
				"type": "tracker_item",
				"trackerid": trackerId
			},
			"text":"New Node"

			}, "last",
			function(newNode) {
				var $parent = $("li#" + newNode.parent);
				$treePane.jstree("open_node", $parent);
				$treePane.jstree("edit", newNode);
				var $parentIcon = $parent.siblings("a").children(".jstree-icon");

				var $thisIcon = $("#releaseTreePane li#0 a .jstree-icon");
				$thisIcon.attr("style", $parentIcon.attr("style"));
			}, false);
	};

	var newReleaseAdded = function (e, data_) {
		var $node = $("#releaseTreePane li#0");
		var trackerId = $node.attr("trackerid");
		var p = $node.closest("li[id != '0']");
		var parentType = p.attr("type");
		var parentId = parentType === "tracker" ? "-1" : p.attr("id");
		var referenceId = data_.parent;
		var position =  "last";
		var name = data_.node.text;

		if(name == i18n.message("tracker.type.Version.create.label")) {
			$("#releaseTreePane").jstree("remove", $node);
			return;
		}

		var data = {
				"tracker.id": trackerId,
				"parent.id": parentId,
				"reference.id": parentId,
				"position": position,
				"name": name,
				"type": $node.attr("type")
		};

		$.ajax({
			type: "post",
			url: contextPath + "/release-tracker/" + trackerId + "/create",
			data: data,
			dataType: "json",
			success: function(data) {
				$.jstree.reference("releaseTreePane").refresh();
			},
			error: function(xhr, textStatus, errorThrown) {
				alert("Error: " + textStatus + " - " + errorThrown);
			}
		});
	};

	return {
		"newReleaseAdded": newReleaseAdded,
		"releaseTreeContextMenu": releaseTreeContextMenu,
		"releaseNodeMoved": releaseNodeMoved,
		"releaseCheckMove": releaseCheckMove,
		"addToRelease": addToRelease
	};
})();
