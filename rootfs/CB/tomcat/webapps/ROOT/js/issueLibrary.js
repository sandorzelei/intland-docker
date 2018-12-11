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
codebeamer.issueLibrary = codebeamer.issueLibrary || (function () {
	function libraryCheckExternalDrop(nodes, $target, event, config) {
		var node = nodes[0];
		var settings = $.extend({}, config);

		var validDrop = true;
		// prevent dropping the issue to the middle panel for now
		var type = node.li_attr["type"];
		if (type == "tracker" || type == "project") {
			validDrop = false;
		}
		var nodeId = node.li_attr["id"];
		var $tr = $target.closest("tr");
		var targetId = $target.closest("tr").attr("id");
		if (nodeId == targetId) {
			validDrop = false;
		}

		// drawing the association box design here because unfortunately there's no other function for this
		if (validDrop) {
			codebeamer.issueDragUtils.drawTargetBoxes($tr, settings);
		} else {
			codebeamer.issueDragUtils.clearDragTargets();
		}

		if (validDrop && $target.is(".target-box")) {
			$(".jstree-er").removeClass("jstree-er").addClass("jstree-ok");
		}

		return validDrop;
	}

	function libraryCheckDrop() {
		// disable moving inside the tree
		return false;
	}

	function libraryExternalDrop(nodes, $target) {
		if ($target.is('.target-box')) {
			var ids = $.map(nodes, function (node, index) { return node.li_attr['id'];});
			codebeamer.issueDragUtils.makeLinks(ids.join(","), $target);
		}

		codebeamer.issueDragUtils.clearDragTargets();
	}

	var searchConfig = {
		"ajax": {
			"url": contextPath + "/trackers/ajax/library/search.spr",
			"data":  {
				"tracker_type": "requirement"
			},
			"success": function (data) {
				return data;
			},
			"error": function(err) {
				console.log("error", err);
			}
		}
	};

	return {
		"libraryExternalDrop": libraryExternalDrop,
		"libraryCheckDrop": libraryCheckDrop,
		"libraryCheckExternalDrop": libraryCheckExternalDrop,
		"searchConfig": searchConfig
	};
})();