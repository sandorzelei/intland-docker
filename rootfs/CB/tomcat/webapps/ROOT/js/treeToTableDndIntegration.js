
/**
 * Javascript code to integrate a tree->table drag-drop operation
 */
var TreeToTableDNDIntegration = {

	hideTreeNodesAppearInTable: false,

	/**
	 *
	 * @param table
	 * @param tree
	 * @param emptyTableMessage The message will appear when the tree empty
	 * @param idFieldSelector Used for hiding those tree-nodes which already appear in the table. Use null to turn off this feature.
	 * 			This selector of the "hidden" input field inside the table's rows' which contains the same ids as the related tree-ids. U
	 */
	init: function(table, tree, emptyTableMessage, idFieldSelector) {
		var $table = $(table);

		$(document).bind("dnd_stop.vakata", function(event, data) {
			TreeToTableDNDIntegration.drag_stop(data.event, table, emptyTableMessage);
		});
		$(document).bind("mousemove", TreeToTableDNDIntegration._indicateWhereRowWillBeDropped);

		// all code here will trigger a "changed" custom event on the table after the table contents' has changed
		$(table).bind("changed", function(event, changedRows) {
			// console.log("Table " + table +" has changed!");
			var $table = $(this);
			// remove/hide the empty row
			TreeToTableDNDIntegration.handleEmptyTable($table, emptyTableMessage);
			TreeToTableDNDIntegration.fixZebraTable($table);
			TreeToTableDNDIntegration._hideTreeNodesAppearInTable($table, tree, changedRows, idFieldSelector);
		});

		// when the tree is fully-loaded (ready) hide the nodes of the already selected testcases
		$(tree).bind("ready.jstree", function(event, data) {
		    // console.log("ready event on tree:" + tree);
            var initWhenReady = function() {
                var $rows = $(table).find("tbody tr");
                var success = TreeToTableDNDIntegration._hideTreeNodesAppearInTable(table, tree, $rows, idFieldSelector);
                TreeToTableDNDIntegration._fixTreeGraphics(tree);
                return success;
            }
            // allow some time for jstree to get then nodes appear in the DOM
            setTimeout(initWhenReady, 2000);
		});
        $(tree).bind("drop_check", function(event, data) {
			if ($table.has(data.event.target).length) {
				TreeToTableDNDIntegration.markElementAsDroppingOver(data.event.target);
			}
		});
	},

	/**
	 * When the table is empty ensure that the "empty" row appears
	 * also remove the empty-row when the table is not empty any more
	 * @param emptyRowMessage the message code will appear in the "empty" row
	 */
	handleEmptyTable: function($table, emptyRowMessageCode) {
		$table = $table.closest("table");

		// remove all "empty" rows
		$table.find("tbody tr.empty").remove();

		var $rows = $table.find("tbody tr");
		if ($rows.length == 0) {
			// if the table is empty add 1 "empty" row
			if (! emptyRowMessageCode) {
				emptyRowMessageCode = "table.nothing.found"; // TODO: change empty message to a more helpful, like "Drop TestCases here" ?
			}
			var emptyRowMessage = i18n.message(emptyRowMessageCode);
			var $tbody = $table.find("tbody");
			var colspan = $table.find("thead th").length;
			$tbody.append("<tr class='empty'><td colspan='" + colspan +"'>" + emptyRowMessage + "</td></tr>");
		}
		/*
		else {
			// more than one row, ensure that empty row won't appear if there are other rows
			var $emptyRows = $table.find("tbody tr.empty");
			if ($rows.length > $emptyRows.length) {
				// there are other rows, remove the empty row
				$emptyRows.remove();
			}
		}
		*/
	},

	// update the -displaytag- table and correct striping/zebra look after the table rows are manipulated/drageed etc...
	fixZebraTable: function(table) {
		$(table).find("tbody tr").each(function(idx) {
			var odd = (idx % 2 == 0);
			$(this).toggleClass("odd", odd).toggleClass("even", !odd);
		});
	},

	markElementAsDroppingOver: function(element) {
		if (element) {
			$(element).closest("table").addClass("treeDroppingOver");
		} else {
			$(".treeDroppingOver").removeClass("treeDroppingOver");
		}
	},

	/**
	 * @return the {$rowToDrop, before} object
	 */
	findRowToDrop: function($target, event) {
		// TODO: find the row to drop, and also figure out if the row will be dropped before or after
		// TODO: during dragging should indicate where the selected items will be dropped to
		var $rowToDrop = $target.closest("tbody tr");
		if ($rowToDrop.size() == 0 || $rowToDrop.hasClass("treeToTableDropPlaceHolder")) {
			return { $rowToDrop: null };
		}

		var middlePoint =$rowToDrop.offset().top + ($rowToDrop.height()/2);
		var mouseY = event.pageY;
		var before = mouseY < middlePoint;
		//console.log("Dragging over row, middle-y:" + middlePoint +", mouse-y:" + mouseY +", will be inserted before:" + before);
		return { $rowToDrop: $rowToDrop, before: before };
	},

	// check if the "element" is child of the "parent" ?
	isChildOf:function(parent, element) {
		var parents = $(element).parents().get();
		for (var i = 0; i < parents.length; i++ ) {
	         if ( $(parents[i]).is(parent) ) {
	        	 	return true;
	         }
	    }
		return false;
	},

	drag_stop: function(event, table, emptyTableMessage) {
		// is dropped over a table?
		var currentTarget = event.target;
		var tableBody = $(table).children("tbody").get(0);
		var isDroppedOverChild = TreeToTableDNDIntegration.isChildOf(tableBody, currentTarget);
		var droppedOverTable = (currentTarget == table || isDroppedOverChild);
		//console.log("dropped over table:" + droppedOverTable);

		TreeToTableDNDIntegration.markElementAsDroppingOver(null);
		// when drop finishes only hide the placeholder, because we need that to remember the position where the stuff will be dropped to
		TreeToTableDNDIntegration._removeAllPlaceHolders(droppedOverTable);

		// is dropped over a table?
		if (! droppedOverTable) {
			// dropped outside, reset the table to the defaults
			TreeToTableDNDIntegration.handleEmptyTable($(table), emptyTableMessage);
		}
	},

	_removeAllPlaceHolders: function(hideOnly) {
		if (hideOnly) {
			$(".treeToTableDropPlaceHolder").hide();
		} else {
			$(".treeToTableDropPlaceHolder").remove();
		}
	},

	_indicateWhereRowWillBeDropped: function(event) {
		// as for optimization the update is delayed a bit
		if (TreeToTableDNDIntegration.updater) {
			clearTimeout(TreeToTableDNDIntegration.updater);
			TreeToTableDNDIntegration.updater = null;
		}

		TreeToTableDNDIntegration.updater = setTimeout(function() {
			var $rowMouseOver = $(event.target).closest("tr");
			if ($rowMouseOver.size() == null) {
				return;
			}
			var $table = $rowMouseOver.closest("table");
			if ($table.hasClass("treeDroppingOver")) {
				//console.log("updating row during drop!");
				var dropTarget = TreeToTableDNDIntegration.findRowToDrop($rowMouseOver, event);
				var $row = dropTarget.$rowToDrop;
				if ($row) {
					var colspan = $table.find("thead th").length;
					var placeholder = "<tr class='treeToTableDropPlaceHolder'><td colspan='" + colspan +"'><div>" + i18n.message("testset.editor.testcases.drop.placeholder") +"</div></td></tr>";
					// if only an empty row is present then replace it with the placeholder
					var $emptyRows = $table.find("tbody tr.empty");
					if ($emptyRows.length == $table.find("tbody tr").length) {
						// table is empty except the "empty" row, remove that, and put the drop message instead of
						$emptyRows.after(placeholder);
						$emptyRows.remove();
					} else {
						if (dropTarget.before) {
							if ($row.prev().hasClass("treeToTableDropPlaceHolder")) {
								// nothing to do already there is a place-holder at the previous position
							} else {
								TreeToTableDNDIntegration._removeAllPlaceHolders();
								$row.before(placeholder);
							}
						} else {
							if ($row.next().hasClass("treeToTableDropPlaceHolder")) {
								// nothing to do already there is a place-holder at the next position
							} else {
								TreeToTableDNDIntegration._removeAllPlaceHolders();
								$row.after(placeholder);
							}
						}
					}
				};
				TreeToTableDNDIntegration.updater = null;
			};
		}, 20);
	},

	/**
	 * Hide the nodes of the jstree which are added to the TestCases' table
	 * @param idFieldSelector The selector of the "hidden" input field inside the table's rows' which contains the same ids as the related tree-ids
	 * @return If the tree-nodes was found and succesfully updated
	 */
	_hideTreeNodesAppearInTable: function(table, tree, changedRows, idFieldSelector) {
		if (!changedRows || !idFieldSelector) {
			return;
		}
		var LOG = "_hideTreeNodesAppearInTable: ";
		var start = new Date().getTime();

		var removed = $(table).find(changedRows).length == 0;
		// console.log("rows removed or added?:" + removed);

        // collect the node-ids
		var nodeIds = [];
		$(changedRows).each(function() {
            var nodeId = $(this).find(idFieldSelector).val();
            nodeIds.push(nodeId);
        });
        if (nodeIds.length == 0) {
            console.log(LOG + "No rows changed!");
            return true;
        }

        var BULK = (changedRows.length > 5); // a more optimal way to find the tree nodes when lots of nodes change
        var $treeNodes = null;
        if (! BULK) {
            var treeNodesSelectors = $.map(nodeIds, function(nodeId) {
                return "#" + nodeId;
            });
            $treeNodes = $(tree).find(treeNodesSelectors.join(","));
        } else {
            var nodeIdsMap = {};
            $.map(nodeIds, function(nodeId) {
                nodeIdsMap[nodeId] = true;
            });

            // when lots of elements dropped then it is more optimal to check all nodes in the tree rather than using JQuery's findById() or document.getElementById()
            var matchingTreeNodes = [];
            $(tree).find("[role='treeitem']").each(function() {
                var $n = $(this);
                var id = $n.attr("id");
                if (nodeIdsMap[id] != null) {
                    matchingTreeNodes.push(this);
                }
            });
            $treeNodes = $(matchingTreeNodes);
        }
//        var findTime = new Date().getTime();
//        console.log(LOG + "Find time:" + (findTime - start) +" ms");

        // only hide the "issue"nodes. this is used because there might be accidental of the ids in a tree:
        // it may have a Tracker typed node with id 1005 and an issue typed node with same id
        $treeNodes = $treeNodes.filter('[typeid="9"]');

        if (removed) {
            $treeNodes.removeClass("treeNodeDisabled");
            if (TreeToTableDNDIntegration.hideTreeNodesAppearInTable) {
                TreeToTableDNDIntegration.toggleJstreeNode($treeNodes, true);
            }
        } else {
            // only gray out the non-leaf nodes because can not hide these
            // as these may have children that is not added or removed from the TestCase selection
            $treeNodes.addClass("treeNodeDisabled");

            if (TreeToTableDNDIntegration.hideTreeNodesAppearInTable) {
                // hide the leaf node
                if ($treeNodes.hasClass("jstree-leaf")) {
                    TreeToTableDNDIntegration.toggleJstreeNode($treeNodes, false);
                }
            }
        }

		var end = new Date().getTime();
		console.log(LOG + "took " + (end - start) + "ms for " + changedRows.length + " elements");

		return $treeNodes.length > 0;
	},

	_fixTreeGraphics: function(tree) {
		if (!TreeToTableDNDIntegration.hideTreeNodesAppearInTable) {
			return;
		}

		// find the leaf nodes that have no next visible sibling and add the jstree-last class to them
		var $visible = $(tree + " li").not(".hidden-node");
		$visible.each(function(idx, node) {
			TreeToTableDNDIntegration._fixTreeGraphicsOfNode(node);
		});
	},

	_fixTreeGraphicsOfNode: function(treeNode) {
		var $n = $(treeNode);
		if ($n.hasClass("jstree-leaf")) {
			var last = $n.nextAll().not(".hidden-node").last();
			if (last.length != 0) {
				last.addClass("jstree-last");
			} else {
				$n.addClass("jstree-last");
			}
		} else {
			var c = $n.children("li").not(".hidden-node");
			if (c.length == 0) {
				var next = $n.nextAll().not(".hidden-node");
				if (next.length == 0) {
					$n.addClass("jstree-last");
				}
			}
		}
	},

	/**
	 * Helper to show/hide a jstree node and correct the look of the tree-lines at the last node still visible
	 * see "show_only_matches" in the jstree.js for sample
	 */
	toggleJstreeNode: function($treeNodes, visible) {
	    $($treeNodes).each(function() {
            var $treeNode = $(this);
            if (visible) {
                $treeNode.show();
            } else {
                $treeNode.hide();
                $treeNode.children("ul").find("li").hide().removeClass("jstree-last"); // remove jstree-last on all children
                $treeNode.toggleClass("hidden-node");
            }

            // correct the "jstree-last" css class on last nodes
            $treeNode.siblings().removeClass("jstree-last");
            var $parentsToCorrect = $treeNode.parentsUntil(".jstree");
            if (visible) {
                $parentsToCorrect = $parentsToCorrect.addBack();
            }
            $parentsToCorrect.filter("ul").each(function () {
                $(this).children("li:visible").eq(-1).addClass("jstree-last");
            });
        });
	},

	highlightTable: function($table) {
		$table.addClass("highlighted");
	},

	removeHighlightTable: function($table) {
		$table.removeClass("highlighted");
	}

};
