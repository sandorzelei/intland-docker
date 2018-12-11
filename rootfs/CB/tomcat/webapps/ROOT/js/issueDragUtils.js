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
codebeamer.issueDragUtils = codebeamer.issueDragUtils || (function () {
	var MOUSE_OVER_CLASS = 'target-association-type';

	var drawTargetBoxes = function($target, config) {
		if ($target.size() == 0) {
			return;
		}
		var settings = $.extend({}, config);

		// don't draw a new box when there's already one
		if ($target.find('.drop-target').size() > 0) {
			return;
		}
		// remove the previously added drop targets
		clearDragTargets();

		// find the row of the tracker item
		var $row = $target.closest('.requirementTr');
		var $description = $row.find('.description');

		if ($description.size() > 0 && !$description.find('.fr-box').length) {

			var canCreateAssociations = settings.hasOwnProperty("canCreateAssociations") ? settings.canCreateAssociations : false;

			// create the drop area
			var $dropTarget = $('<div>', {'class': 'drop-target'}).css({'top': $description.position().top});
			appendTargetBox($dropTarget, i18n.message('tracker.view.layout.document.association.linkToThis'), {'type': 'reference'});
			if (canCreateAssociations) {
				appendTargetBox($dropTarget, i18n.message('tracker.view.layout.document.association.dependsOn'), {'type': 'association', 'id': 1});
				appendTargetBox($dropTarget, i18n.message('tracker.view.layout.document.association.relatedTo'), {'type': 'association', 'id': 4});
			}

			$description.append($dropTarget);

			$dropTarget.on('mouseover', '.target-box', function() {
				$(this).addClass(MOUSE_OVER_CLASS);
			}).on('mouseout', '.target-box', function () {
				$(this).removeClass(MOUSE_OVER_CLASS);
			});

			$dropTarget.on('drop', '.target-box', function(e) {
				e.preventDefault();
				var type = $('body').is('.IE') ? 'text' : 'text/plain';
				var data = e.originalEvent.dataTransfer.getData(type);
				if (parseInt(data)) { // process the request only if the data contains an int id
					makeLinks(parseInt(data), $(this).closest('.requirementTr'), $(this));
				}
				clearDragTargets();
			}).on('dragenter', '.target-box', function(e) {
				e.preventDefault(); // cancel this event, otherwise drop doesn't work
				$(this).addClass(MOUSE_OVER_CLASS);
			}).on('dragleave', '.target-box', function(e) {
				e.preventDefault(); // cancel this event, otherwise drop doesn't work
				$(this).removeClass(MOUSE_OVER_CLASS);
			}).on('dragover', '.target-box', function(e) {
				e.preventDefault(); // cancel this event, otherwise drop doesn't work
				$(this).addClass(MOUSE_OVER_CLASS);
			});
		}
	};

	var appendTargetBox = function($parent, label, data) {
		var $box = $('<span>', {'class': 'target-box'})
				.html(label)
				.data(data);
		$parent.append($box);
	};

	var clearDragTargets = function() {
		$('.drop-target').remove();
	};

	var findAssociationTarget = function()  {
		return $('.target-box.' + MOUSE_OVER_CLASS);
	};

	var makeLinks = function(id, $target, $associationTarget) {
		$associationTarget = $associationTarget || findAssociationTarget();
		if ($associationTarget.size() > 0) {
			if ($associationTarget.data('type') == 'association') {
				makeAssociation(id, $target, $associationTarget.data('id'));
			} else {
				makeReference(id, $target);
			}
		}
	};

	var makeAssociation = function(id, $target, typeId) {
		// each tr in doc view is a drop zone
		var $row = $target.closest("tr.requirementTr");
		var targetId = $row.attr("id");

		$.ajax({
			"url": contextPath + "/trackers/ajax/createAssociations.spr",
			"type": "POST",
			"data": {
				"trackerItemId": targetId,
				"referringIds": id,
				"typeId": typeId
			},
			"success": function(data) {
				if (data.error) {
					showOverlayMessage(data.message, 5, true);
				} else {
					$row.trigger('associationcreated');
					showOverlayMessage(i18n.message('tracker.view.layout.document.association.created.message'));

					reloadNode(targetId);
				}
			},
			"error": function(response) {
				showOverlayMessage(response.statusText, 5, true);
			}
		});
	};

	var makeReference = function(id, $target) {
		// each tr in doc view is a drop zone
		var $row = $target.closest("tr.requirementTr");
		var targetId = $row.attr("id");

		$.ajax({
			"url": contextPath + "/trackers/ajax/createReference.spr",
			"type": "POST",
			"data": {
				"trackerItemId": targetId,
				"referringId": id
			},
			"success": function(data) {
				if (data.error) {
					showOverlayMessage(data.message, 5, true);
				} else {
					$row.trigger('referencecreated');
					showOverlayMessage(i18n.message('tracker.view.layout.document.reference.created.message'));
					trackerObject.reloadIssue(id);

					reloadNode(targetId);
				}
			},
			"error": function(response) {
				showOverlayMessage(response.statusText, 5, true);
			}
		});
	};

	/**
	 * reloads the issue properties and selects the node with id in the tree without scrolling the center panel.
	 */
	var reloadNode = function (id) {
		var tree = $.jstree.reference("#treePane")

		if (!tree.is_selected(id)) {
			tree.deselect_all();
			$("#treePane #" + id + "> a").addClass("jstree-clicked");
		}

		var $issueProperties = $('#issuePropertiesPane');
		trackerObject.showIssueProperties(id, trackerObject.config.id, $issueProperties, trackerObject.config.editable, true);
	};

	return {
		'drawTargetBoxes': drawTargetBoxes,
		'clearDragTargets': clearDragTargets,
		'makeLinks': makeLinks
	}
})();
