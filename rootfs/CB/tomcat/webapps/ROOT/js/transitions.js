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
var codebeamer = codebeamer || {};
codebeamer.transitions = codebeamer.transitions || {
	executeTransition: function(issueId, transitionId, callback) {
		$.ajax({
			"url": contextPath + "/ajax/documentView/executeTransition.spr",
			"type": "POST",
			"data": {
				"task_id": issueId,
				"transition_id": transitionId
			},
			"success": function(data) {
				if (data.success) {
					if (callback) {
						callback.apply(this, [data]);
					}
				} else {
					showOverlayMessage(data.error, 3, true);
				}
			}
		});
	},

	updateStatus: function(issueId, statusId, callback) {
		$.ajax({
			"url": contextPath + "/ajax/documentView/updateStatus.spr",
			"type": "POST",
			"data": {
				"task_id": issueId,
				"statusId": statusId
			},
			"success": function(data) {
				if (data.success) {
					if (callback) {
						callback.apply(this, [data]);
					}
					showOverlayMessage();
				} else {
					showOverlayMessage(data.error, 3, true);
				}
			}
		});
	}

};