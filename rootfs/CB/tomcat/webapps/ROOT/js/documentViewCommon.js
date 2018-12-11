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

/* some common functions from document view that are also used on the review page */

var codebeamer = codebeamer || {};
codebeamer.common = codebeamer.common || (function($) {
	var initRightPaneInlineEditing = function($propertyTable) {
		if ($propertyTable.length) {
			codebeamer.DisplaytagTrackerItemsInlineEdit.init($propertyTable, { documentViewMode: true });
		}
	};
	var loadProperties = function(id, $target, revision, editable, callback, url, filterFields) {
		var pane = $("#issuePropertiesPane"),
			isExtendedDocumentView = typeof trackerObject != 'undefined' && trackerObject.config.extended;
		
		// unlock the previously edited item
		if ($target.data("showingIssue")) {
			unlockTrackerItem($target.data("showingIssue"));
		}
		pane.data("locked", false);

		/* disable the focusTabbable function of the dialog api.
		 * otherwise the dialod will focus the first tabbable element in the loading overlay and
		 * remove the focus from the manually selected input field
		 * issue #739252
		 */
		$.ui.dialog.prototype._focusTabbable = $.noop;

		var p = $target[0];
		var busySign = ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
			width: "12em",
			context: [ p, "tl", "tl", null, [200, 10] ]
		});

		var data = {
			"task_id": id,
			"editable": editable,
			"filterFields": filterFields,
			"extendedDocumentView": isExtendedDocumentView
		};
		if (revision != null && revision != "") {
			data["revision"] = revision;
		}

		$target.css({'visibility': 'hidden'});
		$.ajax({
			"url": url ? url : contextPath + "/trackers/ajax/getIssueProperties.spr",
			"type": "GET",
			"data": data,
			"success": function(data) {
				if (busySign) {
					ajaxBusyIndicator.close(busySign);
				}

				if (editable) {
					// destroying froala editors properly if there are editors being removed from the DOM
					$target.find('.editor-wrapper textarea').froalaEditor('destroy');
				}

				$target.trigger("codebeamer:issueLoaded");

				$target.html(data);
				
				if (!isExtendedDocumentView) {
					initRightPaneInlineEditing($target.find('.propertyTable.inlineEditEnabled'));				
				}
				
				(function initializeInnerAccordion() {
					var originalState = $("#accordion").data("item-inner-accordion-state");
					var accordion = $target.find(".accordion");
					accordion.prop("animationsEnabled", false);
					accordion.cbMultiAccordion({"active": -1});

					itemAccordionStatePersistence = false;
					accordion.cbMultiAccordion("restoreState", originalState);
					accordion.on("openOrClose", function(data) {
						var lastState = $("#accordion").data("item-inner-accordion-state");
						var state = accordion.cbMultiAccordion("saveState");

						// we can't just overwrite the state because there might be properties that are missing from this view but are present on planner
						// example: description accordion
						var mergedState = $.extend(lastState, state);
						$("#accordion").data("item-inner-accordion-state", mergedState);
						storeItemAccordionState(mergedState);
					});
					itemAccordionStatePersistence = true;
				})();

				$target.data("showingIssue", id);

				codebeamer.ReferenceSettingBadges.init($target.find(".issue-associations, .issue-references"));

				pane.find(".accordion").on("refreshCommentCount", function() {
					reloadAfterChange(id);
				});

				/*
				 * locking. when the user starts editing the properties the issue must be locked. when he tries
				 * to navigate from a locked issue we must ask him if he really wants to switch.
				 */
				pane.find(".issue-details").change(function (event) {
					var id = pane.data("showingIssue");

					// check if the item could be locked
					isItemLocked(id).done(function (response) {
						if (response.result == true) {
							showOverlayMessage("The item is locked by an other user. Please reload the editor.", 5, true);
						} else {
							// lock the selected item and store the info to the panel data
							lockTrackerItem(id);
							pane.data("locked", true);
						}
					});
				});

				// store the original form value serialized
				// this will be used in determining if any of the fields were changed by the user
				var $form = $target.find("#addUpdateTaskForm");
				if ($form.size()) {
					var serialized = $form.serialize();
					$form.data("originalValues", serialized);
				}

				if (callback && $.isFunction(callback)) {
					callback();
				}
			},
			"error": function(data) {
				if (busySign) {
					ajaxBusyIndicator.close(busySign);
				}

				// empty the target box and show some message to the user
				var $errorDiv = $("<div>", {"class": "error"}).html(i18n.message("tracker.view.layout.document.load.properties.error"));
				$target.html($errorDiv).data("showingIssue", null);
			},
			"complete": function (data) {
				$target.css({'visibility': 'visible'});
			},
			"cache": false // no caching because IE cannot handle it correctly
		});
	};

	var itemAccordionStatePersistence = true;
	var storeItemAccordionState = throttleWrapper(function(state) {
		if (itemAccordionStatePersistence) {
			$.post(contextPath + "/userSetting.spr", {
				"name": "DOCUMENT_VIEW_ITEM_ACCORDION_STATE",
				"value": JSON.stringify(state)
			});
		}
	}, 500);

	var adjustDocumentViewAccordionLayout = function () {
		var iconOuterHeight = $("#main-quick-icons:visible").parent().height();

		var pane = $("#issuePropertiesPane");
		var attributes = pane.find("> .attributes");
		var overflow = pane.find(".overflow").first();
		var height = $("#accordion").height();
		var overflowHeight = height - iconOuterHeight;

		pane.css("height", height);
		attributes.css("height", height);
		overflow.height( overflowHeight);

		$("#test-plan-pane, #library-tab, #release-pane").css({height: height - iconOuterHeight - 20, "overflow-y": 'scroll', "overflow-x": "hidden" });
	}

	var reloadIssue = function (url, id, affectedIssueIds, trackerId, revision, selectedView) {
		var urlData = {
				"tracker_id": trackerId,
				"view_id": selectedView,
				"revision": revision,
				"issue_id": id,
				"task_id": id
		};

		var idsToUpdate = affectedIssueIds || [];
		idsToUpdate.push(id);

		$.ajax({
			"url": contextPath + url,
			"type": "GET",
			"data": urlData,
			"success": function(d) {
				$.each(idsToUpdate, function(index, idToUpdate) {
					var $old = $("tr#" + idToUpdate);
					var $new = $(d).find("#" + idToUpdate);
					$old.replaceWith($new);

					flashChanged($new, null, function () {
						if ($old.hasClass("selected")) {
							$new.addClass("selected");
						}
					});
				});
			}
		});
	};

	var selectItemInTree = function ($row, callback, treePaneId, trackerId) {
		if ($row.size() > 0) {
			var rowId = $row.attr("id");

			// show the issue properties when the user clicks on any part of the requirement
			setTimeout(callback, 100);


			// select the node in the tree when the user clicks on an issue in the center panel
			// this will automatically load the properties panel
			var tree = $.jstree.reference(treePaneId);
			if (rowId && !tree.is_selected(rowId)) {
				tree.deselect_all();

				// check if the node is visible
				var $node = $("#" + treePaneId + " li#" + rowId);
				if ($node.size() == 0) { // the tree is not available in the dom currently
					// open the node
					var treeNode = tree.get_node(rowId);
					var parents = treeNode.parents;
					if (parents) {
						for (var i = 0; i < parents.length; i++) {
							var parentId = parents[i];
							if (parentId != "#" && parentId != trackerId) {
								tree.open_node(parentId);
							}
						}
					}
					$node = $("#" + treePaneId + " li#" + rowId);
				}

				// check if the node is visible. if not scroll to it
				var $treePane = $("#" + treePaneId);
				var top = $treePane.offset().top;
				var bottom = top + $treePane.height();

				var isInView = $node.offset() && top < $node.offset().top && bottom > $node.offset().top + $node.height();
				if (!isInView) {
					_scrollToElement($node, $treePane);
				}

				$node.find("> .jstree-anchor").addClass("jstree-clicked");

				// mark the row as selected
				$(".selected").removeClass("selected");
				$row.addClass("selected");

				// store the selected id in the tree config
				tree._data.core.selected = [rowId];
			}
		}
	};

	var _scrollToElement = function ($element, $container) {
		// if the browser can't figure out the offset of the element don't try to scroll to it
		if (!$element.offset()) {
			return;
		}
		if (!$container) {
			$container = $("#rightPane");
		}
		// Add additional offset if the page contains Report selector tag
		var additionalOffset = 0;
		if ($container.find(".reportSelectorTag").length > 0) {
			additionalOffset = $container.find(".reportSelectorTag").outerHeight() + 30;
		}
		if (codebeamer && codebeamer.hasOwnProperty("trackers") && codebeamer.trackers.hasOwnProperty("extended")) {
			additionalOffset = $("#main-header").outerHeight() - 2;
		}
		$('.requirement-active').removeClass('requirement-active');
		$('.selected').removeClass('selected');
		$element.addClass('requirement-active selected');
		$container.animate({"scrollTop": $element.offset().top - $container.offset().top + $container.scrollTop() - additionalOffset}, 0);
	};

	var loadContentFromUrl = function (testCaseId, $target, sourceUrl, callback, revision, force) {
		var isEditableInput = $target.find("[name=editable]");
		var isEditingEnabledInput = $target.find("[name=editingEnabled]");
		if (force || isEditableInput.size() != 0 && isEditableInput.next().length == 0) { // load the steps only once
			var p = $target[0];
			var busySign = ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
				width: "12em",
				context: [ p, "tl", "tl", null, [($target.width() > 0 ? ($target.width() - 12)/2: 200), 10] ]
			});

			var isEditingEnabled = isEditingEnabledInput.size() !== 0 ? isEditingEnabledInput.val() === "true" : "false";
			var editable = (isEditableInput.val() == "true") && !revision;
			$.ajax({
				"url": contextPath + sourceUrl,
				"type": "GET",
				"data": {
					"issue_id": testCaseId,
					"editable": editable,
					"editingEnabled": isEditingEnabled,
					"revision": revision /* the baseline revision */
				},
				"success": function(data) {
					if (busySign) {
						ajaxBusyIndicator.close(busySign);
					}
					$target.html(data);

					if (callback) {
						callback();
					}

					$target.trigger("testSteps:updated");
					// TODO: initialize the scripts if neccessarry
				},
				"error": function(data) {
					if (busySign) {
						ajaxBusyIndicator.close(busySign);
					}
					$target.trigger("testSteps:updated");
				},
				"cache": false // no caching because IE cannot handle it correctly
			});
		}
	};

	/**
	 * called after a new tracker item was added to the dom. data_ is the result returned by the server and $row is the row object of the new item.
	 */
	var handleAddNewItem = function (data_, $row) {
		var tree = $.jstree.reference("#treePane");

		// replace the dummy id that we use in newly created items
		$row.attr("id", data_.requirement.id);

		// add new item to the tree
		var newNodeParams = $row.data("newNodeParams");
		var parentId = newNodeParams["parent.id"];

		if (!trackerObject.config.extended) {
			/* if there is a next row and it is a new item editor then we might update its parameters.
			 * for example we might need to update its reference node parameter (since there is a new item and new the next item
			 * must be inserted after this)
			 */
			// updating the new node params for all editors after/before the currently saved item
			var $nextRow = $row.next('.requirementTr');
			while ($nextRow.find('div.new-item').size()) {
				var nextRowParams = $nextRow.data("newNodeParams");
				if (parentId == nextRowParams['parent.id']) {
					nextRowParams['reference.id'] = data_.requirement.id;
					nextRowParams['position'] = 'after';
					$nextRow.data('newNodeParams', nextRowParams);
				} else {
					break;
				}

				$nextRow = $nextRow.next('.requirementTr');
			}

			var $prevRow = $row.prev('.requirementTr');
			while ($prevRow.find('div.new-item').size()) {
				var prevRowParams = $prevRow.data("newNodeParams");
				if (parentId == prevRowParams['parent.id']) {
					prevRowParams['reference.id'] = data_.requirement.id;
					prevRowParams['position'] = 'before';
					$prevRow.data('newNodeParams', prevRowParams);
				} else {
					break;
				}
				$prevRow = $prevRow.prev('.requirementTr');
			}
		}

		var parent = tree.get_node("#" + newNodeParams["parent.id"]);
		if (!parent) {
			parent = $("#treePane [type=tracker]");
		}

		var position = newNodeParams["position"];
		var newNode = {
				data: data_.requirement.nameUnescaped,
				attr: {
					"id": data_.requirement.id,
					"type": newNodeParams["type"],
					"trackerid": trackerObject.config.id
				}
		};

		if (trackerObject.config.subtreeRoot) {
			tree.refresh();
		} else {
			if (newNodeParams.position == "after" || newNodeParams.position == "before") {
				var $referenceNode = tree.get_node("#" + parentId);

				parentId = parentId || "-1";
			}

			if (parentId != "-1") {
				tree.refresh("#" + parentId);
			} else {
				/*
				 * instead of refreshing the whole tree when adding a new top level requirement just create a new node in the
				 * dom and add it to the tree. refreshing the whole tree is very slow on large trees.
				 */
				// find a tracker item node
				insertNewTopLevelNode(data_, tree);
			}
		}

		tree.deselect_all();
		tree.select_node('#' + data_.requirement.id);

		if (data_.changedParagraphs) {
			// replace the paragraph ids that changed
			$.each(data_.changedParagraphs, function (key, value) {
				$("#" + key + ".requirementTr .releaseid").html(value);
			});
		}
	};

	var insertNewTopLevelNode = function(data_, tree) {
		// find a tracker item node
		var $trackerItemNode = $($("#" + trackerObject.config.treePaneId + " .jstree-node[type=tracker_item]").get(0));
		if ($trackerItemNode.size()) {

			// clone the node and change its attributes to the new ones
			var $clone = $trackerItemNode.clone();

			// the cloned node might be suspected or copy, we need to remove these classes
			$clone.removeClass("suspected-node copy-node unresolved-dependencies-node");

			$clone.find("ul").remove();

			// update the id and the name of the node
			var id = data_.requirement.id;
			var anchorId = id + "_anchor";
			$clone.attr("id", id);
			$clone.attr("aria-labelledby",anchorId);
			//$clone.attr("version", 1);
			$clone.removeAttr("parent_id");
			$clone.removeClass("jstree-open").addClass("jstree-leaf").addClass("jstree-last");
			var $icon = $clone.find("a > i");
			var $anchor = $clone.find(".jstree-anchor");
			var name = data_.requirement.nameUnescaped;
			if (name == null || name.length == 0) {
				name = "--";
			}

			$anchor.text(name);
			$anchor.prepend($icon);
			$anchor.attr("id", anchorId);

			// append to the top level of the tree
			var $root = $("#" + trackerObject.config.treePaneId + " li[type=tracker]");
			var $childList =  $root.find("ul:first");
			$childList.append($clone);

			// find the previous sibling of the new item (the former last item) and remove the jstree-last class from it
			$clone.prev("li").removeClass("jstree-last");

			// reload the node config and add it to the tree model
			$.get(contextPath + "/trackers/ajax/getNodeForNewItem.spr",
					{trackerItemId: data_.requirement.id},
					function (item) {
						var parentId = $root.attr("id");
						node_object = $.extend(item, {state:{ loaded: true}, parent: $root.attr("id"), parents: [], children_d:[], a_attr: {id: anchorId}});
						node_object['original'] = item;

						// append the new item id to the child list of the parent node
						var parentNode = tree.get_node(parentId);
						if (parentNode) {
							parentNode.children.push("" + data_.requirement.id);
						}

						tree._model.data[data_.requirement.id] = node_object;

						$clone.attr("iconBgColor", item['attr']['iconBgColor']);
						$clone.attr("title", item['attr']['title']);

                        // use the text field: it already contains the prefix and the postfix and is escaped
						var name = item['text'];

						$anchor.contents().last().replaceWith(name);

						var $iconContainer = $clone.find(" > a > .jstree-icon");
						$iconContainer.css({"background-color": item['attr']['iconBgColor'], 'background-image': 'url(' + item['icon'] + ')'});
					});
		} else {
			// if there are no nodes in the tree then simply refresh
			tree.refresh();
		}
	}

	return {
		"loadProperties": loadProperties,
		"storeItemAccordionState": storeItemAccordionState,
		"adjustDocumentViewAccordionLayout": adjustDocumentViewAccordionLayout,
		"reloadIssue": reloadIssue,
		"selectItemInTree": selectItemInTree,
		"_scrollToElement": _scrollToElement,
		"loadContentFromUrl": loadContentFromUrl,
		'handleAddNewItem': handleAddNewItem
	};

})(jQuery);