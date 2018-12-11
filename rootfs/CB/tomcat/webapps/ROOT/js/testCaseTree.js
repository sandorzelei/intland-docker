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
codebeamer.testCaseTree = codebeamer.testCaseTree || (function () {
	var testCaseCheckExternalDrop = function (node, $target) {
		return false;
	};

	var tectCaseCheckMove = function(np, o, op, oldTree, isCopy) {
		var type = np.li_attr["type"];
		if (type == "tracker" || type == "project" || np.li_attr["trackerId"] == op.li_attr["trackerId"] || np.li_attr["trackerId"] == o.li_attr["trackerId"]) {
			return false;
		}
		return true;
	};

	var testCaseMoved = function (o, np, position, r, isCopy, rslt) {
		var referenceNodeId = r.li_attr["id"];

		var data = {"newParentId": o.li_attr["id"],
				"trackerItemIds": np.li_attr["id"],
				"tracker_id": np.li_attr["trackerId"],
				"position": position,
				"referenceNodeId": referenceNodeId
		};
		var url = contextPath + "/trackers/ajax/moveTrackerItem.spr";
		var bs = null;
		if (isCopy) {
			showPopupInline(contextPath + "/docview/ajax/linkTestCases.spr?testCaseIds=" + np.li_attr["id"] + "&requirementId=" + o.li_attr["id"], {geometry: 'large'});
			return;
		}
		$.ajax({
			"url": url,
			"type": "POST",
			"data": data,
			"success": function(data) {
				if (bs != null) {
					ajaxBusyIndicator.close(bs);
				}

				if (data) {
					_handleInvalidLinking(data["notUpdated"]);
				}

				if (!isCopy) {
					trackerObject.reload("rightPane");
				} else {
					$.jstree.reference(trackerObject.config.treePaneId).refresh();
				}


				// refresh the testcase tree, too
				$("#testTreePane").jstree("refresh");
			}
		});
	};

	return {
		"testCaseCheckExternalDrop": testCaseCheckExternalDrop,
		"tectCaseCheckMove": tectCaseCheckMove,
		"testCaseMoved":testCaseMoved
	};
})();
