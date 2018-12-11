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

/**
 * Initialize the issue filter inside the versions.
 *
 * @param buttonHTMLId The html id of the input-button element to create the filter menu on
 * @param menuHTMLId The html id of the select html element defines the menu
 */
function versionsFilter(buttonHTMLId, menuHTMLId, versionId) {
	this.init(buttonHTMLId, menuHTMLId, versionId);
}

versionsFilter.prototype = {

	/*
	 * All instances are registered here indexed by the menu-id
	 */
	_instances: {},

	/*
	 * Initialize the issue filter inside the versions.
	 *
	 * @param menuHTMLId The html id of the select html element defines the menu
	 * @param versionId The version id
	 */
	init: function(menuHTMLId, versionId) {

		this.versionId = versionId;
		this.menuHTMLId = menuHTMLId;

		versionsFilter.prototype._instances[menuHTMLId] = this;

		var self = this;
		$('#' + menuHTMLId).multiselect({
			multiple: false,
			header: false,
			selectedList: 1,
			click: function(event, ui) {
				self._applyFilter(ui.value);
			}
		});

		this.menu = $('#' + menuHTMLId);
	},

	/**
	 * Find an instance of this object by the menu's html id. static method.
	 * @param menuHTMLId
	 *
	 */
	findFilter: function(menuHTMLId) {
		return versionsFilter.prototype._instances[menuHTMLId];
	},

	findGlobalFilter: function() {
		var filterElemId = $(".actionBar .filterMenu select").first().attr("id");
		return versionsFilter.prototype.findFilter(filterElemId);
	},

	/**
	 * Reapply the filter
	 * @param cssClass Only the rows with this css class should appear. If missing/empty then all will appear
	 */
	_applyFilter: function(cssClass) {
		// show/hide the rows matching with the filter
		var $rows = $("#versionsPlaceholder").find("table.issuelist tr");
		$rows.each(
			function(i, el) {
				var hide = false;
				if (!(cssClass == null || cssClass == "")) {
					hide = $(this).hasClass(cssClass) == false;
				}
				$(this).toggle(!hide);
			}
		);
	},

	/**
	 * (Re)do the filtering as if the user was clicked again on the currently selected menu item.
	 * Used after the issue list is reloaded via ajax
	 */
	applyFilter: function() {
		// find the checked menu
		var items = this.menu.multiselect("getChecked");
		this._applyFilter(items.first().val());
	},

	applyGlobalFilter: function() {
		var filter = versionsFilter.prototype.findGlobalFilter();
		if (filter) {
			filter.applyFilter();
		}
	}

};

// new namespace for tracker functions
var codebeamer = codebeamer || {};
codebeamer.trackers = codebeamer.trackers || (function () {
	var markWithSubicon = function (nodeSelector, iconClass, attributes, node) {
		try {
			var $uncoveredNodes;
			if (node) {
				var tree = $.jstree.reference(node);
				var children = tree.get_children_dom(node);
				if (!children) {
					return;
				}

				$uncoveredNodes = children.filter(function () {return $(this).is(nodeSelector);});
			} else {
				$uncoveredNodes = $(nodeSelector);
			}

			$uncoveredNodes.each(function () {
				var $this = $(this);
				var $a = $this.find(">a");
				var $icon =  $a.find("i.jstree-icon");
				if ($a.find("." + iconClass).size() == 0) {
					attributes = attributes || {};
					var $ins = $("<ins>", attributes);
					$ins.addClass(iconClass);
					$icon.after($ins);
				}
			});
		} catch (e) {

		}
	};

	var markSuspectedNodes = function (node) {
		markWithSubicon(".suspected-node", "suspected-icon", {}, node);
	};

	var markSubtreeRoot = function () {
		markWithSubicon(".subtree-root", "pin-icon", {title: i18n.message("tracker.view.layout.document.subtree.jump.to.level.label")});
	};

	/**
	 * marks the requirement nodes that are not covered with any test cases.
	 */
	var markUncoveredNodes = function (treePaneId) {
		markWithSubicon("#" + treePaneId + " .uncovered", "uncovered-icon");
	};

	var markCopyNodes = function (treePaneId, node) {
		markWithSubicon("#" + treePaneId + " [copy]", "copy-icon", {}, node);
	};

	var copyTrackerItem = function (isTracker, trackerId, issueId, o) {
		var rev = "-1";
		if (o && o.config.revision) {
			rev = o.config.revision;
		}
		$.ajax({
			"url": contextPath + "/trackers/ajax/copyToClipboard.spr",
			"type": "POST",
			"data": {
				"id": issueId,
				"isTracker": isTracker,
				"revision": rev,
				"tracker_id": trackerId
			},
			"success": function(data) {
				codebeamer.trackers.clipboardEmpty = false;
				if (o) {
					var requestData = getFilterParameters();

					// do not reload the right panel just enable the paste action in the menus
					trackerObject._showPasteActions();
				}
			}
		});
	};

	var addPaneOpenerButton = function (l, side) {
		if (l) {
			codebeamer.addOpenerButton(l, side);
		}
	};

	var generateTreePopulator = function (projectId, trackerId, revision, onlyTopLevel, listViews, dynamicParams) {
		var fn = function (n) {
			var data =  {"project_id": projectId,
				"nodeId": n.li_attr ? (n.li_attr["type"] == "tracker" ? n.li_attr["trackerId"] : n.li_attr["id"]) : "",
				"type": n.li_attr ? n.li_attr["type"] : "",
				"tracker_id": trackerId,
				"revision": revision,
				"onlyTopLevel": onlyTopLevel,
				"listViews": listViews
			};

			if (dynamicParams && $.isFunction(dynamicParams)) {
				var extra = dynamicParams(n);
				$.extend(data, extra);
			}

			return data;
		};

		return fn;
	};

	var isPropertyFormUpdated = function ($context) {
		var $form = $context ? $context.find("#addUpdateTaskForm") : $("#addUpdateTaskForm");
		return $form.is('.dirty');
	};

	var defaultReloadCallback = function(divId, self, url, callback, infiniteScrollerMethod, initWaypointsAfterCallback) {
		var opener = $("#opener-container");

		// init jsp wiki javascript for the fresh loaded HTML content
		setTimeout(initializeJSPWikiScripts, 300);

		opener.prependTo($("#" + divId));

		var l = $("#panes").layout();
		codebeamer.trackers.addPaneOpenerButton(l, "west");
		codebeamer.trackers.addPaneOpenerButton(l, "east");


		var treePaneElement = $("#" + self.config.treePaneId);

		if (!self.config.revision) {
			self.setUpCrossWindowDnd();
		}

		// scroll to the item selected in the tree (after the center panel was loaded)
		var tree = $.jstree.reference("#" + self.config.treePaneId);
		var selectedNodes = tree.get_selected();

		codebeamer.infiniteScroller.disabled = true;

		var initWaypoints = function () {
			var reportSelectorId = $(".reportSelectorTag").attr("id");
			var reportId = null;
			if (reportSelectorId) {
				reportId = codebeamer.ReportSupport.getReportId(reportSelectorId);
			}

			var isIe11 = $("body").hasClass("IE11");
			var pageSize = self.config.pageSize; // by default use the page size in the configuration
			if (isIe11) {
				pageSize = 25; // under ie11 use the pagesize of 25
			}

			console.log("pageSize: " + pageSize);
			// the infinite scroller needs to be initialized here because after reload the waypoint trigger links are removed
			infiniteScrollerMethod = infiniteScrollerMethod || "GET";
			codebeamer.infiniteScroller.init({
				pageSize: pageSize,
				url: url,
				ajaxMethod: infiniteScrollerMethod,
				defaultParams: {
					"fragment": true,
					"tracker_id": self.config.branchId ? self.config.branchId : self.config.id,
					"view_id": self.config.selectedView,
					"revision": self.config.revision,
					'comparedBaselineId': '${param.comparedBaselineId}',
					'extended': self.config.extended,
					'reportId': reportId,
					'currentFieldList': codebeamer.trackers.extended.getCurrentFieldList()
				}
			});
		};

        if (selectedNodes.length == 1) {
            var $selectedRequiement = $("#" + selectedNodes[0]);
            setTimeout(function () {
                codebeamer.common._scrollToElement($selectedRequiement);
            }, 600);
        }

		if (callback) {
			if (initWaypointsAfterCallback) {
				callback(initWaypoints);
			} else {
				callback();
			}

		}

		if (!initWaypointsAfterCallback) {
			initWaypoints();
		}

		codebeamer.infiniteScroller.disabled = false;

		/**
		 * BUG-1110911
		 * If the description of an item contains Query (Table) Wiki plugin, same HTML ids can be present in the page
		 * which can cause problems (e.g. New Item using the + icon). The solution is to remove the HTML ids from the
		 * rows of the Query Plugin.
 		 */
		var queryPluginTables = $("#" + divId).find(".wikiContent").find(".trackerItems");
		queryPluginTables.each(function() {
			$(this).find("tr[id]").each(function() {
				$(this).removeAttr("id");
			});
		});

		if (codebeamer.trackers.clipboardEmpty) {
			self._hidePasteActions();
		}


	};

	var documentViewReportSelectorTagCallback = function() {
		setTimeout(function() {
			var leftTree = $.jstree.reference("treePane");
			if (leftTree == null) {
				tree.init();
				setTimeout(function() {
					try {
						tree.refresh();
					} catch (e) {
						//
					}
				}, 200);
			} else {
				leftTree.refresh();
			}
			trackerObject.reload("rightPane", false);
		}, 200);
	};

    var exportToOffice = function(element) {
        var url = $(element).attr("data-url");

        exportToOfficeWithUrl(url);
    };

	var exportToOfficeWithUrl = function(url) {
		var originalUrl = url;
		var popupParameters = { height: 630 };
		var $reportSelector = $(".reportSelectorTag");
		if ($reportSelector.length == 1) {
			var reportSelectorId = $reportSelector.attr("id");

			var cbQl = codebeamer.ReportSupport.getCbQl(reportSelectorId);
			var viewId = codebeamer.ReportSupport.getReportId(reportSelectorId);

			if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
				var configuration = codebeamer.ReportSupport.getIntelligentTableViewConfiguration(reportSelectorId);
				$.ajax({
					url: contextPath + "/intelligentTableView/getDataForExport.spr",
					method: "POST",
					dataType: "json",
					async: false,
					data: {
						configuration: configuration
					},
					success: function(result) {
						var exportUrl = encodeURI(contextPath + "/proj/tracker/traceabilitybrowser_export.spr" +
							'?tracker_id=' + UrlUtils.getParameter(url, "tracker_id") +
							'&initialCbQL=' + cbQl + "&depth=" + result.depth +
							'&trackerList=' + result["levels"] +
							'&levelReferenceTypes=' + result["levelReferenceTypes"]);
						inlinePopup.show(exportUrl);
					}
				});
				return;
			}

			if (codebeamer.ReportSupport.isSprintHistory(reportSelectorId)) {
				url = UrlUtils.addOrReplaceParameter(url, 'sprintHistory', 'true');
			}

			var fields = codebeamer.ReportSupport.getFieldsFromTable(reportSelectorId);
			if (viewId != null) {
            	url = UrlUtils.addOrReplaceParameter(url, "viewId", viewId);
            }
			url += "&cbQL=" + encodeURIComponent(cbQl);
			if (fields && fields.length > 0) {
				url += "&cbQLFields=" + encodeURIComponent(JSON.stringify(fields));
			}
			if (exceedMaximumUrlLength(url)) {
                // If URL exceeds the limit, use the original url
				url = originalUrl;
			}
		}
		inlinePopup.show(url, popupParameters);
	};

	return {
		"addPaneOpenerButton": addPaneOpenerButton,
		"copyTrackerItem": copyTrackerItem,
		"markCopyNodes": markCopyNodes,
		"markUncoveredNodes": markUncoveredNodes,
		"markSuspectedNodes": markSuspectedNodes,
		"markSubtreeRoot": markSubtreeRoot,
		"generateTreePopulator": generateTreePopulator,
		"isPropertyFormUpdated": isPropertyFormUpdated,
		"defaultReloadCallback" : defaultReloadCallback,
		"documentViewReportSelectorTagCallback" : documentViewReportSelectorTagCallback,
		"exportToOffice" : exportToOffice,
		"exportToOfficeWithUrl" : exportToOfficeWithUrl
	};
})();

(function () {
	"use strict";

	codebeamer.trackers.clipboardEmpty = true;

	/**
	 * the constructor
	 * @param config
	 */
	codebeamer.trackers.Tracker = function (config) {
		this.config = config;
		if (config.clipboardEmpty === false) {
			codebeamer.trackers.clipboardEmpty = false;
		}
	};

	function pasteBeforeOrAfter (node, where, s) {
		var id = (node.li_attr["type"] === "tracker" ? null : parseInt(node.li_attr["id"]));
		$(node).pasteTrackerItemsFromClipboard({
			id       : id,
			tracker  : (node.li_attr["type"] === "tracker" ? { id : parseInt(node.li_attr["trackerId"]), name : node.text } : issueCopyMoveContext.tracker),
			position : where
		}, issueCopyMoveConfig.paste, function(transition) {
			if (transition) {
				codebeamer.trackers.clipboardEmpty = true;
				s.reload("rightPane", true, null, {"issue_id": id});

				refreshReport();
			}
		});
	}

	function refreshReport() {
		$(".reportSelectorTag .searchButton").click();
	}

	// destroying editors before removing their dom
	function destroyEditors(editors, isRightPane) {
		var isToolbarRemoved = false;
		editors.each(function() {
			var editorId = $(this).attr('id');

			if (editorId) {
				var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);

				if (editor) {
					editor.destroy();
					isToolbarRemoved = true;
				}
			}
		});
		if (!isRightPane && isToolbarRemoved) {
			autoAdjustPanesHeight();
		}
	}

	// define the functions
	codebeamer.trackers.Tracker.prototype = {

		/**
		 * Export the selected issues to word
		 * @param ids The array of ids to export
		 * @param trackerId
		 * @param revision The selected revision (baseline)
		 * @param the id of the selected view (to be exported)
		 */
		exportSelectionToWord: function(ids, trackerId, revision, viewId) {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			if (ids.length == 0) {
				showFancyAlertDialog(i18n.message("tracker.view.layout.document.export.selection.to.word.empty.warning"));
				return;
			} else {
				var originalUrl = contextPath + "/exportRequirementsAsOffice.spr?tracker_id=" + trackerId +"&taskIds=" + ids.join(",") +"&revision=" + revision + (viewId ? "&viewId=" + viewId : "");
				var url = originalUrl;
				if ($reportSelector.length == 1) {
					if (codebeamer.ReportSupport.isSprintHistory(reportSelectorId)) {
						url = UrlUtils.addOrReplaceParameter(url, 'sprintHistory', 'true');
					}
					var cbQl = codebeamer.ReportSupport.getCbQl(reportSelectorId);
					var fields = codebeamer.ReportSupport.getFieldsFromTable(reportSelectorId);
					var viewId = codebeamer.ReportSupport.getReportId(reportSelectorId);
					if (viewId != null) {
						url = UrlUtils.addOrReplaceParameter(url, "viewId", viewId);
					}
					url += "&cbQL=" + encodeURIComponent(cbQl);
					if (fields && fields.length > 0) {
						url += "&cbQLFields=" + encodeURIComponent(JSON.stringify(fields));
					}
					if (exceedMaximumUrlLength(url)) {
						// If URL exceeds the limit, use the original url
						url = originalUrl;
					}
				}
				if (typeof trackerObject !== "undefined" && trackerObject.config.branchId) {
					url += '&branchId=' + trackerObject.config.branchId;
				}
				showPopupInline(url);
			}
		},

		/**
		 * sends the selected items to review
		 *
		 * @param ids The array of ids to review
		 * @param projectId
		 * @param revision The selected revision (baseline)
		 * @param mergeRequest true if this will be a merge request
		 * @param isBranch if the source tracker is a branch
		 */
		sendSelectionToReview: function(ids, projectId, revision, mergeRequest, isBranch) {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			if (ids.length == 0) {
				showFancyAlertDialog(i18n.message("tracker.view.layout.document.send.selection.to.word.empty.warning"));
			} else {
				var send = function (recursive) {
					var urlAction = mergeRequest ? "createMergeRequest" : "createTrackerItemReview";
					var url = contextPath + "/review/create/" + urlAction + ".spr?reviewType=trackerItemReview&projectIds=" + projectId +"&sourceIds=" + ids.join(",") + "&recursive=" + recursive + "&baselineId=" + revision;
					showPopupInline(url, {geometry: 'large'});
				};

				var buttons = [
					{ text: i18n.message("review.send.selection.to.review.only.selection.label"),
						click: function() {
							send(false);
						}},
					{ text: i18n.message("review.send.selection.to.review.include.children.label"),
						click: function() {
							send(true);
						}, isDefault: true },
					{ text: i18n.message("Cancel"),
						click: function() {
							$(this).dialog("destroy");
						}}
				];
				showModalDialog("warning", i18n.message("review.send.selection.to.review.confirmation"), buttons, 50);

			}
		},

		// walk the tree-nodes and visit each node once
		// @param ids The ids of nodes to visit
		// @param callback The callback will be called with the tree-node: each node is visited only once.
		// 			If the callback returns false the tree-walk will be stopped an no more nodes are visited
		// @param recursive If it will visit all descendants recursively
		visitChildren: function(ids, callback, recursive) {
			var tree = $.jstree.reference(trackerObject.config.treePaneId);

			var seen = {}; // contains the ids of nodes was already visited
			var stopped = false; // if the processing is stopped because the callback has returned false

			var visit = function(sub, depth) {
				if (sub.length == 0) {
					return;
				}

				$(sub).each(function() {
					if (stopped) {
						return;
					}

					var id = this;
					var node = tree.get_node(id);
					if (node != null) {
						stopped = (callback(node, depth) == false);
						if (stopped) {
							return;
						}

						$(node.children).each(function() {
							var childId = this;

							// don't visit this if this was already visited
							if (! seen.hasOwnProperty(childId)) {
								seen[childId] = true;	// mark as already visited

								if (depth <= 1 || recursive) { // go depth first so it will be same order as it appears in the tree
									visit([childId], depth + 1);
								}
							}
						});
					}
				});
			}

			visit(ids, 0);
		},

		// collect the ids of the TestCases from the selected nodes. This will return only the real TestCases and not the folder or other grouping items
		// returns two arrays of with TestCaseIds: the first array contains only the ids selected TestCases
		// , the 2nd (bigger) array contains the ids of the selected TestCases recursively too
		// @param ids The ids of nodes to scan recursively
		// @param stopOnFirst if the tree-walk will stop when first TestCase is found
		collectTestCaseIdsOfTree: function(ids, stopOnFirst) {
			var idsWithVersion = [];
			var idsWithVersionRecursive = [];

			codebeamer.trackers.Tracker.prototype.visitChildren(ids, function(treeNode, depth) {
				if (treeNode && treeNode.li_attr['grouping'] != 'true') { // exclude folders and information from the test run generation
					var version = treeNode.li_attr["itemVersion"];
					// add the eventual versions to the item ids
					var idWithVersion = treeNode.id + (version ? "/" + version : "");

					if (depth == 0) {
						idsWithVersion.push(idWithVersion);
					}
					idsWithVersionRecursive.push(idWithVersion);

					if (stopOnFirst) {
						return false; // stop
					}
				}
			}, true);
			return [idsWithVersion, idsWithVersionRecursive];
		},

		/**
		 * Create TestRuns for the selected TestCases or TestSets
		 * @param ids The array of ids to create runs for (TestCase ids or TestSet ids)
		 */
		createTestRuns: function(ids, testRunTrackerId) {
			if (ids.length == 0) {
				alert(i18n.message("tracker.view.layout.document.create.testruns.empty.warning"));
			} else {
				var tree = $.jstree.reference(trackerObject.config.treePaneId);

				var generate = function(idsWithVersion, recursive) {
					var url = "/proj/tracker/createtestrunmultiplesources.spr"
					var url = contextPath + url + "?isPopup=true&noReload=true&showIncludeTestsRecursively=false";
					url += "&includeTestsRecursively=" + (recursive == true);

					if (testRunTrackerId) {
						url += "&tracker_id=" + testRunTrackerId;
					}
					url += "&tests=" + idsWithVersion.join(",");
					showPopupInline(url, { geometry: "large" });
				};

				var testCaseIds = codebeamer.trackers.Tracker.prototype.collectTestCaseIdsOfTree(ids);

				var testCasesOfSelected = testCaseIds[0];
				var testCasesRecursive  = testCaseIds[1];
				if (testCasesOfSelected.length == 0 && testCasesRecursive.length == 0) {
					// no TestCases are runnable here at all
					alert(i18n.message("tracker.view.layout.document.create.testruns.empty.warning"));
					return;
				}

				if (testCasesOfSelected.length > 0 && testCasesRecursive.length > testCasesOfSelected.length) { // only ask question when the recursive items are different from the selected items
					var buttons = [
						{ text: i18n.message("tracker.view.layout.document.generate.test.case.recursive.label") + " (" + testCasesRecursive.length +")",
							click: wrapHandlerFunction(function() {
								generate(testCasesRecursive, true);
							})},
						{ text: i18n.message("tracker.view.layout.document.generate.test.case.non.recursive.label") + " (" + testCasesOfSelected.length +")",
							click: wrapHandlerFunction(function() {
								generate(testCasesOfSelected, false);
							}), isDefault: true },
						{ text: i18n.message("Cancel"),
							click: function() {
								$(this).dialog("destroy");
							}}
					];
					showModalDialog("warning", i18n.message("tracker.view.layout.document.generate.test.run.recursive.question"), buttons, 50);
				} else {
					generate(testCasesRecursive);
				}
			}
		},

		/**
		 * Get the ids of the selected issues in the selected tree
		 * @returns {Array}
		 */
		getSelectedIssuesFromTree:function(filter) {
			var ids = [];
			var tree = window["trackerObject"] ? $.jstree.reference(trackerObject.config.treePaneId) : null;
			if (tree) {
				var selected = tree.get_selected();
				if (selected) {
					// remove the tracker id from the list
					var trackerId = $("#" + trackerObject.config.treePaneId + " li[type=tracker]").attr("id");
					selected.remove(trackerId);
					return selected;
				}
			}
			return ids;
		},

		getRootNode: function() {
			return $("#" + this.config.treePaneId + " li[type=tracker]");
		},

		_handleEditorCancelAndSave: function($editorTextarea, event) {
			var isMac = codebeamer.WYSIWYG.isMac();
			if ((isMac && event.metaKey || !isMac && event.ctrlKey) && (event.which == 83)) { // cmd or ctrl+s
				$editorTextarea.trigger("saveChanges");
				event.preventDefault();
				event.stopPropagation();
				return false;
			}
		},

		draggedNodeId : null,

		init: function () {
			var self = this;

			this.selectItemInTree = function ($row) {
				if ($row.size() > 0) {
					var rowId = $row.attr("id");

					// show the issue properties when the user clicks on any part of the requirement
					setTimeout(function () {
						trackerObject.showIssueProperties(rowId, self.config.id, $('#issuePropertiesPane'),
								self.config.revision == null || self.config.revision == "");
					}, 100);


					// select the node in the tree when the user clicks on an issue in the center panel
					// this will automatically load the properties panel
					var tree = $.jstree.reference(self.config.treePaneId);
					if (tree && !tree.is_selected(rowId)) {
						tree.deselect_all();

						// check if the node is visible
						var $node = $("#" + self.config.treePaneId + " li#" + rowId);
						if ($node.size() == 0) { // the tree is not available in the dom currently
							// open the node
							var treeNode = tree.get_node(rowId);
							var parents = treeNode.parents;
							if (parents) {
								for (var i = 0; i < parents.length; i++) {
									var parentId = parents[i];
									if (parentId != "#" && parentId != self.config.id) {
										tree.open_node(parentId);
									}
								}
							}
							$node = $("#" + self.config.treePaneId + " li#" + rowId);
						}

						// check if the node is visible. if not scroll to it
						var $treePane = $("#" + self.config.treePaneId);
						var top = $treePane.offset().top;
						var bottom = top + $treePane.height();

						var isInView = $node.offset() && top < $node.offset().top && bottom > $node.offset().top + $node.height();
						if (!isInView) {
							codebeamer.common._scrollToElement($node, $treePane);
						}

						$node.find("> .jstree-anchor").addClass("jstree-clicked");

						// mark the row as selected
						$(".selected").removeClass("selected");
						$row.addClass("selected");
					}
				}
			};

			this.showBusySignOnPanel = function (divId) {
				var $panel = $("#" + divId);
				var p = $panel[0];
				return ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
					width: "12em",
					context: [ p, "tl", "tl", null, [($panel.width() > 0 ? ($panel.width() - 12)/2: 200), 10] ]
				});
			};

			/**
			 *
			 * @param divId the id of the div where the new page html will be added. the div will be cleared before adding the new content.
			 * @param refresh to refresh the tree or not
			 * @param callback the callback that will be invoked after loading the new page. when it is invoked the new page is already in the dom.
			 * @param params  extra request parameters for the url loading the page
			 * @param initWaypointsAfterCallback if this is true then the default handler won't initiaalize the waypoint handlers, it must be initialized
			 *  	in the callback. when this parameter is true callback is invoked with one parameter: the function that initializes the waypoint
			 *  	handlers. the callback function must call this function in order to get infinite scrolling work.
			 */
			this.reload = function (divId, refresh, callback, params, initWaypointsAfterCallback) {
				var contextPath = self.config.contextPath;

				if (!self.config.revision) {

					// store the currently edited item data before reloading the page
					if (self.config.extended) {
						codebeamer.trackers.extended.storeFormData();
					}

					var url = "/proj/tracker/showDocumentView.spr";

					if (params && params.issue_id) {

						// set up all the extra parameters for the request
						params = $.extend(params, {
							"fragment": true,
							"tracker_id": self.config.branchId ? self.config.branchId : self.config.id,
							"view_id": self.config.selectedView,
							'comparedBaselineId': '${param.comparedBaselineId}'
						});

                        var isIe11 = $("body").hasClass("IE11");
                        if (isIe11) {
                            params['pageSize'] = 25; // under ie11 use the pagesize of 25
                        }

						if (trackerObject.config.extended) {
							params['currentFieldList'] = codebeamer.trackers.extended.getCurrentFieldList();
							if (codebeamer.ReportSupport.isResizeableColumnsEnabled($(".reportSelectorTag").attr("id"))) {
								params["resizeableColumns"] = true;
							}
						}

						var requestData = getFilterParameters();
						params = $.extend(params, requestData);

						// when the selected issue is not loaded on the middle panel wee need to load the item first
						var busySign = self.showBusySignOnPanel("reportSelectorResult");
						$.ajax({
							"url": contextPath + url,
							"type": "POST",
							"data": params,
							"success": function(data) {
								$("#reportSelectorResult").html(data);
								if (busySign) {
									ajaxBusyIndicator.close(busySign);
								}
								codebeamer.trackers.defaultReloadCallback(divId, self, url, callback, "POST", initWaypointsAfterCallback);

								// destroy the not visible editors
								 $.each($.FE.INSTANCES, function () {
									 if (this && this.destroy && !this.$el.is(':visible')) {
									 	this.destroy();
									 }
								 });
							},
							"error": function(data) {
								if (busySign) {
									ajaxBusyIndicator.close(busySign);
								}
							},
							"cache": false
						});
					} else {
						codebeamer.trackers.defaultReloadCallback(divId, self, url, callback, "POST", initWaypointsAfterCallback);
					}

					return;
				}

				// if the refresh parameter is true then reload the tree before calling the default callback
				if (typeof refresh === 'undefined') {
					refresh = true;
				}

				if (refresh) {
					self._clearSearchBox();

					var leftTree = $.jstree.reference(self.config.treePaneId);

					// refresh the tree
					leftTree.refresh();
				}

				if (self.config.subtreeRoot && self.config.subtreeRoot != -1) {
					if (!params) {
						params = {};
					}

					// reload the selected subtree even when an other issue_id is specified
					params["issue_id"] = self.config.subtreeRoot;
				}

				var method = "GET";
				var url = self.config.docViewAjaxUrl;

				var id = "#" + divId;
				$(id).empty();
				var busySign = self.showBusySignOnPanel(divId);

				var urlData = {
					"tracker_id": self.config.id,
					"view_id": self.config.selectedView,
					"revision": self.config.revision,
					"remove_query_plugin_row_ids": true
				};
				if (params) {
					$.extend(urlData, params);
				}
				$.ajax({
					"url": contextPath + url,
					"type": method,
					"data": urlData,
					"success": function(data) {
						// wrap the html into a single element for a better performance (this reduced the time for html() by ~50%)
						$(id).html("<div class=\"document-view-container\">" + data + "</div>");
						if (busySign) {
							ajaxBusyIndicator.close(busySign);
						}
						codebeamer.trackers.defaultReloadCallback(divId, self, self.config.docViewAjaxUrl, callback);
					},
					"error": function(data) {
						if (busySign) {
							ajaxBusyIndicator.close(busySign);
						}
					},
					"cache": false // no caching because IE cannot handle it correctly
				});
			};

			this.showSubtree = function(nodeId) {
				location.href = contextPath + '/tracker/' + self.config.id + '?view_id=' + self.config.selectedView
					+ (self.config.revision ? '&revision=' + self.config.revision : '')
					+ (nodeId ? '&subtreeRoot=' + nodeId : '&subtreeRoot=-1') ;
			};

			this.setUpCrossWindowDnd = function() {
				var clearDropAreasDelayed = throttleWrapper(function() {
					codebeamer.issueDragUtils.clearDragTargets();
				}, 1000);
				// we have to use the 'originalEvent' because the jquery version of the event doesn't have the dataTransfer property
				$('#rightPane').on('dragstart', '.editable', function (e) {
					e.preventDefault();
					e.stopPropagation();
				}).on('dragstart', '.requirementTd .name .dnd-icon', function(e) {
					var $name = $(this).parents(".name").clone();

					var data = $name.attr('issueid');
					var type = $('body').is('.IE') ? 'text' : 'text/plain';
					e.originalEvent.dataTransfer.setData(type, data);
					self.draggedNodeId = data;

					// create the ghost image used while dragging
					// clone the original name div
					$name.addClass("hidden");
					$("body").append($name);

					// set the cloned element as dragimage
					e.originalEvent.dataTransfer.setDragImage($name[0], 0, 0);
				}).on('dragenter', '.requirementTr', function(e) {
					e.preventDefault(); // cancel this event, otherwise drop doesn't work
					if ($(this).attr("id") != self.draggedNodeId) {
						codebeamer.issueDragUtils.drawTargetBoxes($(this), self.config);
					} else {
						codebeamer.issueDragUtils.clearDragTargets();
					}
				}).on('dragover', '.requirementTr', function(e) {
					e.preventDefault(); // cancel this event, otherwise drop doesn't work
					clearDropAreasDelayed();
				}).on('drop', '.requirementTr', function(e) {
					e.preventDefault();
					self.draggedNodeId = null;
					codebeamer.issueDragUtils.clearDragTargets();
				});

				$(document).bind('drag_stop.vakata', function(){
					setTimeout(function() {
						self.draggedNodeId = null;
						codebeamer.issueDragUtils.clearDragTargets();
					}, 500);
				}).on('dragend', function(e) {
					setTimeout(function() {
						self.draggedNodeId = null;
						codebeamer.issueDragUtils.clearDragTargets();
					}, 500);

					// remove the hidden div elements
					$(".name.hidden").remove();
				})
			};
			this._clearSearchBox = function () {
				// clear the searchbox
				var $s = $("#searchBox");
				if ($s.size() > 0) {
					$s.blur(); // remove the focus fro the input box itherwise the watermark is not removed completely
					$s.val("");
					$s.Watermark(i18n.message("association.search.as.you.type.label"), '#d1d1d1');
				}
			};
			this.reloadSubissues = function (paneId, refreshTree, callback, issueId, forceReload) {
				if (issueId && issueId != -1) {
					// check if the subtree of the node has been already loaded
					if (forceReload === true || $("#rightPane #subtreeRoot").val() !== issueId) {
						self.reload(paneId, refreshTree, callback, {"issue_id": issueId});
					}
				} else {
					if (forceReload === true || $("#rightPane #subtreeRoot").val() != "") {
						self.reload(paneId, refreshTree);
					}
				}
			};

			/**
			 * finds the last child of a node recursively.
			 */
			this.findLastChildOfNode = function (nodeId) {
				var tree = $.jstree.reference(self.config.treePaneId);

				var node = tree.get_node(nodeId);
				if (node.children.length > 0) {
					return self.findLastChildOfNode(node.children[node.children.length - 1]);
				}

				return node;
			};

			this.addRequirement = function (oldNode, position, isFolder) {
				var nodeType = "tracker_item";
				if (isFolder) {
					nodeType = "folder";
				}

				if (!oldNode) {
					// when the old node is not found in the tree that means that someone else modified the tracker
					// this condition can come true when the user clicks the "New child" in the context menu on the right side of document view
					alert(i18n.message("tracker.tree.concurrent.modification.alert"));
					return;
				}
				var trackerId = oldNode.li_attr["trackerId"];

				if (!self.config.extended && self.config.requiredFieldWithoutDefault) {
					// if there are required field show the popup editor
					var createUrl = contextPath + "/docview/createIssue.spr?tracker_id=" + trackerId + "&isPopup=true&position=" + position;
					if (oldNode.li_attr["type"] != "tracker")  {
						createUrl += "&parent_id=" + oldNode.li_attr["id"];
					}

					if (isFolder) {
						createUrl += "&type=folder";
					}

					inlinePopup.show(createUrl, {"geometry": "large"});
				} else {
					var referenceNodeId = oldNode.li_attr["type"] == "tracker" ? oldNode.li_attr["trackerId"] : oldNode.li_attr["id"];

					/**
					 * on the extended document view the fields are shown in a table and every field is instantly editable.
					 * to add a new item row to this table we need to load it from the server. this function downloads a new
					 * editor form.
					 */
					var createEditorForExtendedView = function ($referenceRow, oldNode, position, onEditorCreated) {
						var url = contextPath + '/trackers/documentView/newEditor.spr';
						var reportId = self.getReportId();
						var params = {
							'currentFieldList': codebeamer.trackers.extended.getCurrentFieldList(),
							'trackerId': self.config.id
						};

						if (reportId) {
							params['reportId'] = reportId;
						}
						$.get(url, params).done(function (data) {
							var $table = $(data.html);
							var $row = $table.find('.requirementTr');
							var randomId = Math.round(Math.random() * 100000);

							$row.attr('id', 'new-item-' + randomId);

							// do not show any paragraph id for the newly inserted items
							$row.find('.releaseid').empty();

							insertEditorToDom($row, $referenceRow, oldNode, position, onEditorCreated, $table);

							codebeamer.common._scrollToElement($row);

							// focus the name editor
							$row.find('[name=summary]').focus();

							codebeamer.trackers.extended.initializeNewEditors();
						}).error(function () {
							showOverlayMessage("Couldn't load the new item editor", 5, true);
						});
					};

					var createEditor = function ($referenceRow, oldNode, position, onEditorCreated) {
						if (self.config.extended) {
							createEditorForExtendedView($referenceRow, oldNode, position, onEditorCreated);
							return;
						}
						// insert a new table row to the dom
						var randomId = Math.round(Math.random() * 100000);
						var newRowHtml = $("#newItemTemplate table").html().replace("#new-item-id", "new-item-" + randomId);

						var $row = $(newRowHtml).find("tr");

						insertEditorToDom($row, $referenceRow, oldNode, position, onEditorCreated);
					};

					/**
					 * when inserting multiple new items unser the same item we need to find the correct reference row.
					 *
					 * example: when I insert a new item after A (call it B), then again a new item after A (call it B)
					 * the correct order after sacing them is A, B, C. so for the second insert the correct reference row is
					 * B.
					 */
					var findLastInsertedItemAfterReferenceRow = function ($referenceRow, referenceNodeId) {
						var ordinal = 0;
						var $result = $referenceRow;
						var $prev = null;
						while ($result.next('.requirementTr') && $result.next('.requirementTr').data('new-node-params') && $prev != $result) {
							var nextParams = $result.next('.requirementTr').data("new-node-params");
							if (nextParams['reference.id'] == referenceNodeId) {
								$result = $result.next();
								ordinal++;
							} else {
								break;
							}
						}

						return [$result, ordinal];
					}

					/**
					 * @param $table: when there are no items in the view currently we need to create a new table and add the editor row to that
					 * table. when $table is defined we use that instead of creating a new table element.
					 */
					var insertEditorToDom = function ($row, $referenceRow, oldNode, position, onEditorCreated, $newTable) {
						// open the editor for the newly inserted row

						var $domNode = $("#treePane li[id='" + oldNode.id + "']");
						var $p = $domNode.closest("li[id != '0']");
						var parentId = $p.attr("type") == "tracker" ? "-1" : $p.attr("id");

						// if there is no table (this is the first item added to the tracker)
						var $table = $("#requirements");
						var $trs = [];
						$table.find("tr").each(function() {
							if ($.isNumeric($(this).attr("id"))) {
								$trs.push(this);
							}
						});

						// store the position, referenceid etc. to the new row for later use
						$row.data("new-node-params", {
							"reference.id": referenceNodeId,
							"position": position,
							"type": nodeType,
							"parent.id": parentId
						});

						if ($table.size() == 0) {
							// create the table and add the row
							$table = $newTable || $("<table>", {
								"id": "requirements",
								"class": "displaytag fullExpandTable",
								"style": "table-layout: fixed;"
							});
							$(".document-view-container").append($table);

							$("#emptyViewMessage").hide();

							if (!$newTable) {
								$table.append($row);
							}
						} else if ($trs.length == 0) {
							var $newItemEditors = [];
							$table.find("tr.requirementTr").each(function() {
								if (!$.isNumeric($(this).attr("id"))) {
									$newItemEditors.push(this);
								}
							});

							$table.append($row);
							$("#emptyViewMessage").hide();


						} else {
							// based on the position value insert the new row to the dom
							if (position == "after") {
								// if the item has children the next item is the one after the last child
								var lastChild = self.findLastChildOfNode($domNode.attr("id"));
								if (lastChild) {
									$referenceRow = $(".requirementTr#" + lastChild.id);
								}

								var lastRefData = findLastInsertedItemAfterReferenceRow($referenceRow, referenceNodeId);
								$referenceRow = lastRefData[0];

								$referenceRow.after($row);
							} else if (position == "before") {
								$referenceRow.before($row);
							} else {
								// insert the new item as the last child of the node (if there are no children then this will be the first child)
								var lastChild = self.findLastChildOfNode($domNode.attr("id"));

								if (lastChild.id == self.config.id) { // the first item in the tracker
									$referenceRow.after($row);
								} else {
									var $referenceRow = $(".requirementTr#" + lastChild.id);
									var lastRefData = findLastInsertedItemAfterReferenceRow($referenceRow, referenceNodeId);
									$referenceRow = lastRefData[0];

									$referenceRow.after($row);
								}
							}
						}
						$row.find('.description-container').on('cbEditorPostRender', function() {
							// scroll to the new item
							setTimeout(function() {
								codebeamer.common._scrollToElement($row);
								if (onEditorCreated) {
									onEditorCreated();
								}
								$row.find('.nested-summary-editor').focus();
							}, 300);
						});

						var fieldDefaults = {
								description: self.config.defaultDescription,
								name: self.config.defaultName
						};
						// open the editor for the new item
						addEditorForTarget($row.find(".description"), onDescriptionOpen, onDescriptionSubmit, onDescriptionSubmitted, fieldDefaults);

						// clear the search in the tree
						$("#" + self.config.treePaneId).jstree("clear_search");
						var $s = $("#searchBox_treePane");
						if ($s.size() > 0) {
							$s.val("");
							$s.Watermark(i18n.message("association.search.as.you.type.label"), "#d1d1d1");
						}
					};

					var $referenceRow = $(".requirementTr#" + referenceNodeId);
					var isTracker = oldNode.li_attr["type"] == "tracker";

					// if the reference item is not loaded on the right panel we must load the subtree first
					// except if the user clicked on the root node (tracker node)
					if (!isTracker && $referenceRow.size() == 0) {
						if (position == "last") {
							// if the position is last use the last child of the node as reference
							var lastChild = self.findLastChildOfNode(oldNode.id);
							if (lastChild) {
								referenceNodeId = lastChild.id;
							}
						}

						trackerObject.reload("rightPane", false, function (initWaypointsCallback) {
							var $referenceRow = $(".requirementTr#" + referenceNodeId);
							setTimeout(function () {
								var $referenceRow = $(".requirementTr#" + referenceNodeId);

								// calls the initWaypointsCallback only after the editor was created and scrolled to
								// to prevent waypoint from triggering immediately after the item page was loaded
								createEditor($referenceRow, oldNode, position, initWaypointsCallback);
							}, 500);

						}, {"issue_id": referenceNodeId}, true); // last parameter true: waypoints will be initialized in the callback, the default reload callback won't initialize them
					} else if (isTracker || position == "last") {  // when inserting a new child
						var lastChild = self.findLastChildOfNode(oldNode.id);
						if (!lastChild) {
							console.log("couldn't find the last element in the tree with parent: " + oldNode.id);
							return;
						}

						var lastChildId = lastChild.id;
						var $referenceRow = $(".requirementTr#" + lastChildId);
						var tree = $.jstree.reference(oldNode);
						var referenceNode = tree.get_node(lastChildId);

						var scrolled = trackerObject._loadItemIfNotVisible(referenceNode, function() {
							var $referenceRow = $(".requirementTr#" + lastChildId);
							createEditor($referenceRow, oldNode, position);
						});

						if (!scrolled) {
							createEditor($referenceRow, oldNode, position);
						}
					} else {
						createEditor($referenceRow, oldNode, position);
					}


				}
			};

			this._showRequiredFieldMessage = function (message) {
				var buttons = [
					{ text: i18n.message("button.ok"),
						click: function () {
							$(this).dialog("destroy");
						}}
				];
				showModalDialog("warning", i18n.message(message), buttons, 50);
			};

			this.addTopLevelRequirement = function () {
				var t = $.jstree.reference(self.config.treePaneId);
				var rootId = self.getRootId();
				if (self.config.subtreeRoot && self.config.subtreeRoot !== -1) {
					rootId = self.config.subtreeRoot;
				}
				var root = t.get_node(rootId);
				self.addRequirement(root, "last");
			};
			this.addChildRequirement = function (node) {
				self.addRequirement(node, "last");
			};
			this.addRequirementBefore = function (node) {
				self.addRequirement(node, "before");
			};
			this.addRequirementAfter = function (node) {
				self.addRequirement(node, "after");
			};

			this.createTestRuns = function (id, testRunTrackerId) {
				codebeamer.trackers.Tracker.prototype.createTestRuns([id], testRunTrackerId);
			};

			this.getNode = function (id) {
				return $.jstree.reference(self.config.treePaneId).get_node(id);
			};
			this.onNodeRenamed = function (event, d) {
				var editable = d.node.id == 0 || (self.config.editable && !self.config.revision && d.node.li_attr["editable"]);

				if (d.old === d.text || !editable) {

					if (d.node.id == 0) { // the node was renamed in the release tree
						var $node = $("#releaseTreePane li#0");
						$("#releaseTreePane").jstree("delete_node", $node);
						$("#releaseTreePane").jstree("refresh");
					} else {
						// show an error and do not save when the user has no permission to edit the summary
						if (!editable) {
							showOverlayMessage(i18n.message('tracker.view.layout.document.summary.not.editable.warning'), 5, true);
						}

						self.refreshNode(d.node.id);
					}
					return;
				}


				var id = d.node.id;
				var data = {
					"name": d.text,
					"issue_id": id
				};

				// when the id is 0 this is a special placeholder node created in the release tree. in this case
				// we need to create a new node
				if (id == 0) {
					codebeamer.releaseTree.newReleaseAdded(event, d);
				} else {
					$.ajax({
						type: "post",
						url: contextPath + "/requirement/" + id + "/rename",
						data: data,
						dataType: "json",
						success: function(data_) {
							if (self.config.id == d.node.li_attr["trackerId"]) {
								reloadEditedIssue(id);

								self.refreshNode(d.node.id);
							}
						},
						error: function(response, textStatus, errorThrown) {
							if (response.status == 403) {
								showOverlayMessage(i18n.message("tracker.view.layout.rename.locked.message"), 5, true);
							} else {
								console.log(response, textStatus, errorThrown);
								showOverlayMessage(response.responseText, 5, true);
							}

							// rollback
							var tree = $.jstree.reference(d.node.id);
							tree.refresh(d.node.id);
						}
					});
				}
			};

			this._computeNodeDepth = function ($node) {
				return $node.parents("li").length - 1;
			};

			this._loadNewRequirement = function (data) {
				var id = data.requirement.id;

				var urlData = {
						"tracker_id": self.config.id,
						"view_id": self.config.selectedView,
						"revision": self.config.revision,
						"issue_id": id
				};

				$.ajax({
					"url": contextPath + self.config.docViewAjaxUrl,
					"type": "GET",
					"data": urlData,
					"success": function(d) {
						var $newRequirement = $(d).find("#" + id);
						var $parent = null;
						if (data.precedingId == -1) {
							// if there is no preceding issue then this is the first of the tracker
							// that is: we should put it before the first issue on the right side (if any)
							// first add the requirements table to the
							var $requirements = $("#requirements");
							if ($requirements.size() == 0) {
								$requirements = $("<table id='requirements' class='displaytag fullExpandTable'>");
								var $empty = $("#emptyViewMessage");
								if ($empty.size() == 0) {
									$("#rightPane").html($requirements);
								} else {
									$empty.replaceWith($requirements);
								}
							}
							$requirements.prepend($newRequirement);
						} else {
							$parent = $("#" + data.precedingId + ".requirementTr");
							$parent.after($newRequirement);
						}

						// replace the paragraph ids that changed
						$.each(data.changedParagraphs, function (key, value) {
							$parent = $("#" + key + ".requirementTr .releaseid").html(value);
						});

						// scroll to the new issue
						codebeamer.common._scrollToElement($newRequirement);

						// flash the new requirement
						flashChanged($newRequirement);

						// select the node in the tree and refresh it
						$("#" + self.config.treePaneId).jstree("deselect_all");
						$("#" + self.config.treePaneId).jstree("select_node", $("li[id=" + id + "]"));
						$("#" + self.config.treePaneId).jstree("refresh");
					}
				});
			};

			this.getReportId = function () {
				var reportSelectorId = $(".reportSelectorTag").attr("id");
				if (reportSelectorId) {
					var reportId = codebeamer.ReportSupport.getReportId(reportSelectorId);
					if (reportId) {
						return reportId;
					}
				}

				return null;
			}

			this.reloadIssue = function (id, affectedIssueIds) {
				var urlData = {
						"tracker_id": self.config.id,
						"view_id": self.config.selectedView,
						"revision": self.config.revision,
						"issue_id": id,
						"remove_query_plugin_row_ids": true,
						"extended": self.config.extended
					};

				var reportSelectorId = $(".reportSelectorTag").attr("id");
				if (reportSelectorId) {
					var reportId = codebeamer.ReportSupport.getReportId(reportSelectorId);
					if (reportId) {
						urlData['reportId'] = reportId;
					}
				}

				if (trackerObject.config.extended) {
					urlData['currentFieldList'] = codebeamer.trackers.extended.getCurrentFieldList(true);
				}

				var idsToUpdate = affectedIssueIds || [];
				idsToUpdate.push(id);

				$.ajax({
					"url": contextPath + self.config.docViewAjaxUrl,
					"type": "GET",
					"data": urlData,
					"success": function(d) {
						$.each(idsToUpdate, function(index, idToUpdate) {
							var $old = $("tr#" + idToUpdate);
							var $new = $(d).find("#" + idToUpdate);

							destroyEditors($old.find('.editor-wrapper textarea, .field-editor.editor-wrapper'));

							$old.replaceWith($new);

							flashChanged($new, null, function () {
								if ($old.hasClass("selected")) {
									$new.addClass("selected");
								}
							});
						});

						if (self.config.extended) {
							codebeamer.trackers.extended.initializeNewEditors();
						}
					}
				});
			};

			this.deleteRequirement = function (node) {
				var ids = self.getSelectedIssuesFromTree();
				ids.remove(self.config.id); // remove the tracker id from the list
				if (ids.length <= 1) {
					ids = [node.li_attr["id"]];
				}

				var t = $.jstree.reference(self.config.treePaneId);
				var confirmationMessage = ids.length > 1 ? "tracker.delete.selected.item.confirm" : "tracker.delete.item.confirm";
				var selectedNode = ids.length == 1 ? t.get_node(ids[0]) : null;

				var selectedNodeTitle = selectedNode ? selectedNode.original.attr["title"] : "";
				selectedNodeTitle = escapeHtmlEntities(selectedNodeTitle);

				showFancyConfirmDialogWithCallbacks(i18n.message(confirmationMessage, selectedNodeTitle), function() {
					var trackerIdToUse = self.config.originalTrackerId;
					if (self.config.branchId) {
						trackerIdToUse = self.config.branchId;
					}
					$.ajax({
						type: "delete",
						url: self.config.contextPath + "/proj/tracker/deleterequirement.spr?tracker_id=" + trackerIdToUse + "&taskIds=" + ids.join(","),
						success: function() {
							var selectedNodes = ids;
							for (var i = 0; i < selectedNodes.length; i++) {
								var _node = selectedNodes[i];
								if (t.is_selected($(_node))) {
									// empty the properties panel when the selected node was deleted
									$('#issuePropertiesPane').empty();
								}

								if($("#issuePropertiesPane").data("showingIssue") == _node) {
									clearIssueProperties();
								}

								if (t) {
									t.deselect_node(_node);
									t.delete_node(_node);
								}
							}

							self.reload("rightPane", false);

							refreshReport();

							var $treePane = $("#" + self.config.treePaneId);
							if ($treePane.find(".jstree-search").size()) {
								// if the tree is filtered just refresh the icon colors
								initializeTreeIconColors($treePane);
							} else {
								var leftTree = $.jstree.reference(self.config.treePaneId);
								leftTree.refresh();
							}

							var releaseTree = $.jstree.reference("releaseTreepane");
							if (releaseTree) {
								releaseTree.refresh();
							}

							// Trigger filtering after delete
							var $searchBox = $("#searchBox_" + self.config.treePaneId);
							if ($searchBox.length > 0 && $searchBox.val().length > 0) {
								$("#go_" + self.config.treePaneId).click();
							}

						},
						error: function(xhr, textStatus, errorThrown) {
							alert("Error: " + textStatus + " - " + errorThrown);
						}
					});
				});
			};
			this.removeTestCase = function(node) {
				var ids = self.getSelectedIssuesFromTree(".testCase");
				if (ids.length == 0) {
					ids = [node.li_attr["id"]];
				}
				var confirmation = ids.length > 1 ? "tracker.remove.test.case.from.requirement.confirm.plural" : "tracker.remove.test.case.from.requirement.confirm";
				showFancyConfirmDialogWithCallbacks(i18n.message(confirmation, node.li_attr["title"]), function() {
					var p = $.jstree.reference(self.config.treePaneId).get_parent(node);
					$.ajax({
						"url": contextPath + "/trackers/ajax/removeTestCase.spr",
						"type": "POST",
						"data": {"requirementId": p.attr("id"),
								"testCaseIds": ids.join(),
								"tracker_id": self.config.id
						},
						"success": function(data) {
							// we need to refresh the tree because some nodes may become uncovered
							$.jstree.reference(self.config.treePaneId).refresh();
						}
					});
				});
			};

			this._afterScroll = function (id) {
				var $documentRow = $("tr#" + id);
				if($documentRow.size() == 1) {
					codebeamer.common._scrollToElement($documentRow);
					self.showIssueProperties(id, self.config.id, $('#issuePropertiesPane'), self.config.revision == null || self.config.revision == "");
				}
			};

			/**
			 * loads the item for the node to the middle panel is fnot visible (for example because of inifinite scrolling).
			 * if necessary this function will load the subsequent pages until the item gets visible. if there was any scrolling it returns true
			 * otherwise (if the item was already visible) it returns false.
			 * @param node
			 * @param callback
			 * @returns {Boolean}
			 */
			this._loadItemIfNotVisible = function (node, callback) {
				// no node found, return false
				if (!node) {
					return false;
				}

				var id = node.li_attr["id"];
				var $documentRow = $("tr#" + id);

				if (id) {
					if (node.li_attr["type"] != "tracker" && node.li_attr["trackerId"] === self.config.id) {

						if ($documentRow.size() == 0) {
							trackerObject.reload("rightPane", false, function () {
								codebeamer.common._scrollToElement($("tr#" + id));

								if (callback) {
									callback();
								}
							}, {issue_id: id});

							return true
						}
					}
				}
				return false;
			};

			this.nodeClicked = function (node, tree) {
				var id = node.li_attr["id"];

				var isTracker = node.li_attr["type"] == "tracker";

				var $documentRow = $("tr#" + id);

				// if the user clicked on the tracker node use the first child
				if (isTracker) {
					var rootId = self.getRootId();
					var root = $.jstree.reference(self.config.treePaneId).get_node(rootId);
					if (root.children && root.children.length != 0) {
						$documentRow = $("tr#" + root.children[0]);
					}
				}

				var isFromSourceTracker = node.li_attr["trackerId"] == self.config.id
					|| node.li_attr["trackerId"] == self.config.originalTrackerId; // when creating a branch theoriginalTrackerId is the id of the branched tracker
				var refreshPropertyPanel = function () {
					if (isFromSourceTracker && !isTracker) {
						self.showIssueProperties(id, node.li_attr["trackerId"], $("#issuePropertiesPane"), trackerObject.config.revision.length == null  || self.config.revision == "");
					} else {
						clearIssueProperties();
					}
				};

				var propertyFormUpdated = codebeamer.trackers.isPropertyFormUpdated($("#issuePropertiesPane"));
				if (propertyFormUpdated) {
					showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.issue.properties.changes.confirm"), function () {
						// remove the locked state from the panel to prevent the app from asking for confirmation again
						$("#issuePropertiesPane").data("locked", false);
						refreshPropertyPanel();
					});
				} else {
					refreshPropertyPanel();
				}

				// when the user double clicks on the center panel and the editor opens we should not scroll to the item
				if($documentRow.size() == 1) {
					var $edited = $documentRow.closest(".edited").not(".initialized");

					// if the item editing has just started don't scroll the view
					var itemIsEdited = $edited.size() > 0;
					if (!itemIsEdited) {
						codebeamer.common._scrollToElement($documentRow);
					} else {
						$edited.addClass("initialized");
					}

					return;
				}

				// don't do anything if the node is from a different tracker (eg: a test case in a requirement tree)
				if (isFromSourceTracker) {
					if (!codebeamer.treeLoaded || $documentRow.size() == 0) {
						var requestData = getFilterParameters();

						if (!isTracker) {
							$.extend(requestData, {issue_id: id});
						}

						if (self._isEdited()) {
							showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.navigate.from.subtree.confirm"), function () {
								self.reload("rightPane", false, null, requestData);
								codebeamer.treeLoaded = true;
							});
						} else {
							self.reload("rightPane", false, null, requestData);
							codebeamer.treeLoaded = true;
						}
					}
				} else {
					// the case when in a requirement tree a test case node is selected after reload
					// if nothing is loaded to the center panel select the root node
					if ($("#requirements").size() == 0) {
						var tree = $.jstree.reference(trackerObject.config.treePaneId)
						tree.deselect_all();
						tree.select_node($("li[type=tracker]"));
					}
				}
			};


			/**
			 * returns the id of the tracker node in the tree
			 * @returns
			 */
			this.getRootId = function () {
				return $("#" + self.config.treePaneId + " [type=tracker]").attr("id");
			};

			this.showIssueProperties = function (id, trackerId, $target, editable, force) {
				// don't try to load issues being created
				if (!$.isNumeric(id) && id.indexOf("new-item") != null) {
					return;
				}

				// check if the $target already shows the same issue's properties
				if (!force && $target.data("showingIssue") == id) {
					// nothing to do, already showing this issue
					return;
				}

				var pane = $("#issuePropertiesPane"),
					$editors = pane.find('.editor-wrapper textarea');
				
				if ((pane.data("locked") && self.config.extended) || $editors.length) {
					/*
					 * the currently active item may be locked (edited). to prevent data loss always ask the user if he really wants to navigate
					 * to the other issue. if yes then unlock the item and load the other one.
					 */
					showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.locked.node.confirm"),
						function () {
							if ($editors.length) {
								destroyEditors($editors, true);
								codebeamer.DisplaytagTrackerItemsInlineEdit.clearNavigateAway();
							}
							codebeamer.common.loadProperties(id, $target, self.config.revision, editable, function () {
								self["loadedProperty"] = id;
							}, null, self.config.extended);
						},
						function () { // the user clicked cancel
							// scroll back to the edited element
							var $propertiesPane = $('#issuePropertiesPane');
							var editedId = $propertiesPane.data("showingIssue");
							if (editedId) {
								codebeamer.common._scrollToElement($('tr#' + editedId));
							}
					});
				} else {
					codebeamer.common.loadProperties(id, $target, self.config.revision, editable, function () {
						self["loadedProperty"] = id;
					}, null, self.config.extended);
				}
			};

			this.generateTestCase = function (id, trackerId) {
				var generate = function (recursive) {
					var bs = ajaxBusyIndicator.showBusyPage();
					var ids = [id];
					$.ajax({
						"url": contextPath + "/trackers/ajax/generateTestCase.spr",
						"type": "POST",
						"data": {
							"issue_id": ids.join(","),
							"tracker_id": trackerId,
							"recursive": recursive
						},
						"success": function(data) {
							if (bs) {
								ajaxBusyIndicator.close(bs);
							}
							// we need to refresh the tree because some nodes may become uncovered
							$.jstree.reference(self.config.treePaneId).refresh();
							if ($("#testTreePane").size() > 0) {
								$.jstree.reference("testTreePane").refresh();
							}

							// show a message box with the success message
							showOverlayMessage(i18n.message("tracker.view.layout.document.generate.test.case.success.message"));

							// reload the issue so that the menu gets updated
							trackerObject.reloadIssue(id);

							var $propertiesPane = $("#issuePropertiesPane");
							self.showIssueProperties(id, self.config.id, $propertiesPane, true, true);

						},
						"error": function(data) {
							if (bs) {
								ajaxBusyIndicator.close(bs);
							}
						}
					});
				};

				var hasChildren = function() {
					var tree = $.jstree.reference(self.config.treePaneId);
					var node = tree.get_node(id);
					if (node.children.length > 0) {
						return true;
					}
					return false;
				};

				var $node = $("li[id='" + id + "']");
				if (self.config.testPlanHasRequiredField) {
					self._showRequiredFieldMessage("document.no.generate.test.case.hint");
				} else if ($node.attr("type") == "folder") {
					// if the node is a folder always generate recursively
					generate(true);
				} else {
					var wrapHandlerFunction = function (handler) {
						return function () {
							try {
								if (handler) {
									handler.call(this);
								}
							} finally {
								$(this).dialog("destroy");
							}
						};
					};
					var buttons = [
						{ text: i18n.message("tracker.view.layout.document.generate.test.case.recursive.label"),
							click: wrapHandlerFunction(function() {
								generate(true);
							})},
						{ text: i18n.message("tracker.view.layout.document.generate.test.case.non.recursive.label"),
							click: wrapHandlerFunction(function() {
								generate(false);
							}), isDefault: true },
						{ text: i18n.message("Cancel"),
							click: function() {
								$(this).dialog("destroy");
							}}
					];
					if (hasChildren()) {
						showModalDialog("warning", i18n.message("tracker.view.layout.document.generate.test.case.recursive.question"), buttons, 50);
					} else {
						generate(false);
					}
				}
			};

			this.goToParentLevel = function () {
				var tree = $.jstree.reference("#" + self.config.treePaneId);
				var node = tree.get_node("#" + self.config.subtreeRoot);
				var parentId = node.li_attr["parent_id"];

				// if the parent is the tracker node load the whole tree, otherwise just the parent subtree
				self.showSubtree(parentId);
			};

			this.populateContextMenu = function (node) {
				var hideContextMenu = function () {
					$(".vakata-context").hide();
				};

				var menu = {};
				if (!(self.config.rpeDisabled === undefined || self.config.rpeDisabled === null)) {
					if (self.config.rpeDisabled == 'enabled') {
						menu['generateReports'] = {
								'label': i18n.message('rpe.generate'),
								"separator_after": true,
								'action': generateReports
						};
					} else {
						menu['generateReports'] = {
								'label': i18n.message('rpe.generate'),
								"separator_after": true,
								'action': generateReports,
								"_disabled" : true
						};
					}
				}
				if (self.config.id == node.li_attr["trackerId"] || self.config.originalTrackerId == node.li_attr["trackerId"]) { // show the context menu only if the node has the same type as the tracker
					if (self.config.editable && !self.config.revision && node.li_attr["editable"]) {
						menu["rename"] = {
								"label": i18n.message("document.rename.label"),
								"action": function() {
									var tree = $.jstree.reference("treePane");
									var doc = new DOMParser().parseFromString(node.text, "text/html");
									tree.edit(node, doc.documentElement.textContent);
								}
						};
					}

					if (self.config.canCreateIssue) {
						var clipboardState = $.ajax({
						    type: "GET",
						    url: contextPath + '/trackers/ajax/getClipboardStatus.spr',
						    async: false
						}).responseJSON;

						if (clipboardState && !clipboardState.empty) {
							// if the clipboard is empty and the user can paste
							menu["paste"] = { "label": i18n.message("tracker.view.layout.document.paste.child.label"),
								"action": function () {
									pasteBeforeOrAfter(node, null, self);
								}
							};

							if (node.li_attr["type"] == "tracker_item" || node.li_attr["type"] == "folder") {
								menu["pasteBefore"] = {"label": i18n.message("tracker.view.layout.document.paste.before.label"),
										"action": function () { pasteBeforeOrAfter(node, "Before", self); }};
								menu["pasteAfter"] = {"label": i18n.message("tracker.view.layout.document.paste.after.label"),
										"action": function () { pasteBeforeOrAfter(node, "After", self); }};
							}
						}
					}

					// menu items for folders
					if ((node.li_attr["type"] === "folder" || node.li_attr["type"] === "tracker") && self.config.canCreateFolder)  {
						menu["newFolder"] = { "label": i18n.message("tracker.view.layout.document.new.folder"), "action": function() {
							self.addRequirement(node, "last", true);
						} };
					}

					if (self.config.canCreateIssue) {
						menu["newChild"] = {
								"label": i18n.message("issue.newChild.label") + " (" + codebeamer.HotkeyFormatter.getLabel("CTRL+INSERT") + ")",
								"action": function () {self.addChildRequirement(node); }
							};
						if (node.li_attr["type"] == "tracker_item" || node.li_attr["type"] == "folder") {
							// insert after/before is not available on folders
							menu["insertBefore"] = { "label": i18n.message("tracker.view.layout.document.paragraph.before.label"),
									"action": function () {self.addRequirementBefore(node); }};
							menu["insertAfter"] = {
									"label": i18n.message("tracker.view.layout.document.paragraph.after.label") + " (" + codebeamer.HotkeyFormatter.getLabel("CTRL+ENTER") + ")",
									"separator_after": !self.config.isRequirementTracker || !self.config.canCreateTestCase,
									"action": function() {self.addRequirementAfter(node); }
							};
						}
					}
					if (!self.config.revision && self.config.canDeleteIssue && node.li_attr["type"] != "tracker") {
						menu["delete"] = {
								"label": i18n.message("action.delete.label"),
								"separator_after": true,
								"action": function () {
									self.deleteRequirement(node);
								}
						};
					}
				} else if (self.config.id != node.li_attr["trackerId"]) {
					menu["showDetails"] = {
							"label": i18n.message("issue.details.view.label"),
							"action": function () {
								location.href = contextPath + "/tracker/" + node.li_attr["trackerId"] + "?view_id=-11&selectedItemId=" + node.li_attr["id"];
							}
						};
					if (self.config.canEditTestcases) {
						menu["editTestCase"] = {"label": i18n.message("action.edit.label"),
								"action": function () {
									var url = contextPath + "/ajax/editIssue.spr?task_id=" + node.li_attr["id"];
									showPopupInline(url, {"geometry": "large"});
								}};
					}
				}

				if (node.li_attr["type"] != "tracker") {
					var nodeId = node.li_attr["id"];
					// if the item has children show the "set as root" menu
					// by children I mean real children not test cases associated to the item
					if (nodeId != self.config.subtreeRoot) {
						menu["showSubtree"] = {
								"label": i18n.message("tracker.view.layout.document.show.subtree.label"),
								"action": function () {
									self.showSubtree(node.li_attr["id"]);
								}
						}
					}

					// if looking at a subtree, add the one-level-up menu
					if (node.li_attr["id"] == self.config.subtreeRoot) {
						menu["oneLevelUp"] = {
								"label": i18n.message("tracker.view.layout.document.subtree.jump.to.level.label"),
								"action": function () {
									self.goToParentLevel();
								}
						}

						menu["showWholeTracker"] = {
								"label": i18n.message("tracker.view.layout.document.show.whole.tracker"),
								"action": function () {
									self.showSubtree();
								}
						}
					}
				}

				var availableTestRunTrackers = self.config.hasOwnProperty("availableTestRunTrackers") ? self.config.availableTestRunTrackers : null;

				if (node.li_attr["type"] == "tracker") {
					menu["exportToWord"] = {
						"label": i18n.message("tracker.issues.exportToOffice.label"),
						"action": function() {
							codebeamer.trackers.exportToOfficeWithUrl(self.config.exportToWordUrl);
						},
						"separator_before" : true
					};
				} else {
					menu["exportSelectionToWord"] = {
						"label": i18n.message("tracker.view.layout.document.export.selection.to.word"),
						"action": function() {
							var ids = self.getSelectedIssuesFromTree();

							self.exportSelectionToWord(ids, self.config.id, self.config.revision, self.config.selectedView);
						},
						"separator_before" : true
					};

					var clazz = node.li_attr["class"];
					var isTestCase = clazz.indexOf('testcase-node') >= 0;
					if (isTestCase) {
						if (availableTestRunTrackers != null) {
							var availableTestRunTrackersArray = [];
							for (var testRunTrackerId in availableTestRunTrackers) {
								availableTestRunTrackersArray.push(availableTestRunTrackers[testRunTrackerId]);
							}
							availableTestRunTrackersArray = availableTestRunTrackersArray.sort();
							var sortedTestRunTrackerArray = [];
							for (var i = 0; i < availableTestRunTrackersArray.length; i++) {
								var testRunTrackerIdFromArray = null;
								for (var testRunTrackerId in availableTestRunTrackers) {
									if (availableTestRunTrackers[testRunTrackerId] == availableTestRunTrackersArray[i]) {
										testRunTrackerIdFromArray = testRunTrackerId;
										break;
									}
								}
								if (testRunTrackerIdFromArray != null) {
									sortedTestRunTrackerArray.push({
										testRunTrackerId: testRunTrackerIdFromArray,
										name: availableTestRunTrackersArray[i]
									});
								}
							}

							// check if there is at least one non folder item selected in the tree and show the generate test run dialog only if there is
							var selectedIds = self.getSelectedIssuesFromTree();
							var testCaseIds = codebeamer.trackers.Tracker.prototype.collectTestCaseIdsOfTree(selectedIds,
													true /* stop when 1st TestCase is found: we only want to know if there is any TestCase here? */);

							if (testCaseIds[1].length > 0) {
								menu["createTestRuns"] = {
									"label": i18n.message("tracker.view.layout.document.create.testruns"),
									"separator_before" : true
								};
								var testRunChildItems = {};
								for (var i = 0; i < sortedTestRunTrackerArray.length; i++) {
									var testRunTrackerId = sortedTestRunTrackerArray[i]["testRunTrackerId"];
									var name = sortedTestRunTrackerArray[i]["name"];
									testRunChildItems["createTestRun" + testRunTrackerId] = {
										"label": name,
										"testRunTrackerId": testRunTrackerId,
										"action": function(data) {
											var ids = self.getSelectedIssuesFromTree();

											// remove the tracker from the selection
											var $root = self.getRootNode();
											if ($root) {
												ids.remove($root.attr("id"));
											}
											codebeamer.trackers.Tracker.prototype.createTestRuns(ids, data.item.testRunTrackerId);
										}
									};
								}
								menu["createTestRuns"]["submenu"] = testRunChildItems;
							}
						}
					}
				}

				var ids = self.getSelectedIssuesFromTree();
				var idsForMultiActions = ids.length > 0 ? ids : [node.id];

				if (self.config.hasOwnProperty("canMassEdit") && self.config.canMassEdit) {
					menu['massEdit'] = {
							'label': i18n.message('issue.massEdit.label'),
							'separator_before': true,
							'action': function (data) {
								self.handleExtraActionForSelection("massEdit", idsForMultiActions, true);
							}
					}
				}

				if (!self.config.revision) {
					menu['cut'] = {
							'label': i18n.message('action.cut.label'),
							'separator_before': ids.length == 1,
							'action': function (data) {
								self.handleExtraActionForSelection("cut", idsForMultiActions);
							}
					}
				}

				menu['massCopy'] = {
						'label': i18n.message('issue.copy.label'),
						'tooltip': i18n.message('issue.copy.tooltip'),
						'action': function (data) {
							self.handleExtraActionForSelection("copy", idsForMultiActions);
						}
				}

				menu['copyTo'] = {
						'label': i18n.message('issue.copyTo.label'),
						'action': function (data) {
							self.handleExtraActionForSelection("copyTo", idsForMultiActions);
						}
				}

				if (!self.config.revision) {
					menu['moveTo'] = {
							'label': i18n.message('issue.moveTo.label'),
							'action': function (data) {
								self.handleExtraActionForSelection("moveTo", idsForMultiActions, false, {copy: false});
							}
					}
				}

				menu["addTag"] = {
					"label": i18n.message("tags.selected.items.and.children.label"),
					"action": function() {
						addItemIdsAndShowPopupInline(contextPath + "/proj/label/openEntityLabelPopup.do?entityTypeId=" + node.li_attr["typeId"] + "&entityId="
								+ node.li_attr["trackerId"] + "&forwardUrl=/tracker/" + node.li_attr["trackerId"] +
								"?view_id=-11");
					},
					"separator_before" : true
				};

				if (node.li_attr["type"] != "tracker") {
					menu["addTag"] = {
							"label": i18n.message("tags.selected.items.and.children.label"),
							"action": function() {
								addItemIdsAndShowPopupInline(contextPath + "/proj/label/openEntityLabelPopup.do?entityTypeId=" + node.li_attr["typeId"] + "&entityId="
										+ node.li_attr["id"] + "&forwardUrl=/tracker/" + node.li_attr["trackerId"] +
										"?view_id=-11");
							},
							"separator_before" : true
					};

				} else{
					menu["addTag"] = {
							"label": i18n.message("tags.label"),
							"action": function() {
								addItemIdsAndShowPopupInline(contextPath + "/proj/label/openEntityLabelPopup.do?entityTypeId=" + node.li_attr["typeId"] + "&entityId="
										+ node.li_attr["trackerId"] + "&forwardUrl=/tracker/" + node.li_attr["trackerId"] +
										"?view_id=-11");
							},
							"separator_before" : true
					};
				}


				if (menu["delete"] && ids.length > 1) {
					var enabledWithMultipleSelection = ["delete", "exportSelectionToWord", "createTestRuns", "massEdit", "cut", "copyTo", "moveTo", "massCopy", "addTag"];
					if (availableTestRunTrackers == null) {
						enabledWithMultipleSelection.push("createTestRuns");
					} else {
						for (var testRunTrackerId in availableTestRunTrackers) {
							enabledWithMultipleSelection.push("createTestRuns" + testRunTrackerId);
						}
					}
					// if there's a delete option and more than one nodes are selected disable all the others
					for (var k in menu) {
						if (enabledWithMultipleSelection.indexOf(k) < 0) {
							delete menu[k];
						}
					}
				}

				return menu;
			};

			this.handleExtraActionForSelection = function (action, ids, needsConfirm, extraConfig) {
				var idsToObjects = function(idList) {
					var idObjects = $.map(idList, function (id) {return {'id': parseInt(id)}});
					return idObjects;
				};

				var showDialog = function (idList) {
					var idObjects = idsToObjects(idList);
					self.handleExtraAction("body", action, idObjects, extraConfig);
				};

				ids = ids || self.getSelectedIssuesFromTree();
				ids.remove(self.config.id); // remove the tracker id from the list

				var originalLength = ids.length;
				var idsWithChildren = [];
				idsWithChildren = idsWithChildren.concat(ids);

				var tree = $.jstree.reference(self.config.treePaneId);
				// for each selected id add their children to the list
				$.each(ids, function (index, id) {
					var node = tree.get_node(id);
					if (node && node.children_d) {
						idsWithChildren = idsWithChildren.concat(node.children_d);
					}
				});

				var idsWithChildren = $.unique(idsWithChildren);
				var hasChildren = idsWithChildren.length > originalLength;

				var buttons = [
					{ text: i18n.message("tracker.view.layout.document.generate.test.case.recursive.label"),
						click: wrapHandlerFunction(function() {
							showDialog(idsWithChildren);
						})},
					{ text: i18n.message("tracker.view.layout.document.generate.test.case.non.recursive.label"),
						click: wrapHandlerFunction(function() {
							showDialog(ids);
						}), isDefault: true },
					{ text: i18n.message("Cancel"),
						click: function() {
							$(this).dialog("destroy");
						}}
				];
				if (hasChildren && needsConfirm) {
					showModalDialog("warning", i18n.message("tracker.view.layout.document.mass.edit.recursive.question"), buttons, 50);
				} else {
					showDialog(ids);
				}
			}

			this.handleExtraAction = function (selector, action, selectedItems, extraConfig) {
				var options = issueCopyMoveConfig[action];

				if (extraConfig) {
					options = $.extend(options, extraConfig);
				}

				switch (action) {
					case "cut":
					case "copy":
						$(selector).cutCopyTrackerItemsToClipboard(issueCopyMoveContext.tracker, selectedItems, options, function (successful) {
							if (successful) {
								codebeamer.trackers.clipboardEmpty = false;
								self._showPasteActions();
							}
						});
						break;
					case "paste":
						$(selector).pasteTrackerItemsFromClipboard(issueCopyMoveContext, options, function (successful) {
							if (successful) {
								codebeamer.trackers.clipboardEmpty = true;
							}
						});
						break;
					case "delete":
					case "restore":
						$(selector).removeTrackerItems(issueCopyMoveContext.tracker, selectedItems, options);
						break;
					case "massEdit":
						$(selector).massEditTrackerItems(issueCopyMoveContext.tracker, selectedItems, options);
						break;
					case "copyTo" :
					case "moveTo" :
						$(selector).showTrackerItemsCopyMoveToDialog(issueCopyMoveContext.tracker, selectedItems, options);
						break;
				}
			}

			this.addAssociationForNode = function (node) {
				showPopupInline(self.config.contextPath + "/proj/tracker/addAssociation.do?inline=true&from_type_id=9&from_id=" +
						node.li_attr["id"] + "&tracker_id=" + self.config.id + "&proj_id=" + self.config.projectId + "&callback=reloadAfterAddAssociation", { geometry: '70%_70%' });
				$("#" + node.id).addClass("adding-association");
				return false;
			};

			this.addAssociation = function (id) {
				var tree = $.jstree.reference("#" + this.config.treePaneId);
				var node = tree.get_node("#" + id);
				return this.addAssociationForNode(node);
			};

			this.setPinnedRoot = function (pinnedItemId) {

				$.post(contextPath + '/ajax/tracker/pinRoot.spr', {
					'tracker_id': self.config.id,
					'pinnedItemId': pinnedItemId

				}, function (data) {
					if (data.success) {
						showOverlayMessage();
					}
				}).error(function (data) {
					showOverlayMessage(data.thrownError, 3, true);
				});
			};

			this.nodeMoved = function (o, np, position, r, isCopy, rslt) {
				var self = this;
				// isCopy is only true when we moved an item from an other tree to this one
				var ids = [];
				for (var i = 0; i < o.length; i++) {
					ids.push(o[i].id);
				}
				var referenceNodeId = r.li_attr["id"];
				if (r.li_attr["type"] == "tracker" || (!isCopy && r.li_attr["trackerId"] != self.config.id)) {
					referenceNodeId = "";
					position = "";
				}

				var trackerIdToUse = o[0].li_attr["originalTrackerId"] ? o[0].li_attr["originalTrackerId"] : o[0].li_attr["trackerId"];
				if (self.config.branchId) {
					trackerIdToUse = self.config.branchId;
				}

				var urlParams = {"newParentId": np.li_attr["type"] == "tracker" ? -1 : np.li_attr["id"],
							"trackerItemIds": ids.join(","),
							"tracker_id": trackerIdToUse,
							"position": position,
							"referenceNodeId": referenceNodeId
				};

				var executeDrop = function () {
					var url = contextPath + "/trackers/ajax/moveTrackerItem.spr";
					var bs = null;
					var $domNode = $("li[id=" + o[0].id + "]");
					var isFromLibrary = $domNode.parents("#library-tab.library").size();
					if (isCopy) {
						if (isFromLibrary) {
							var library = { id : parseInt(o[0].li_attr["trackerId"]), name: o[0].li_attr['title'] };
							for (var i = 0; i < ids.length; i++) {
								ids[i] = parseInt(ids[i]);
							}
							showPopupInline(contextPath + "/docview/ajax/linkRequirements.spr?trackerId="
									+ self.config.id + "&itemIds=" + ids.join(",") + "&parentId=" + referenceNodeId + "&position=" + position, {geometry: 'large'});
							return;
						} else if ($domNode.is(".release-node")) {
							codebeamer.releaseTree.addToRelease(o.li_attr["id"], [parseInt(np.li_attr["id"])], np.li_attr["trackerId"], "-1", function () {
								$.jstree.reference("#" + trackerObject.config.treePaneId).refresh(np);
							});
							return;
						} else {
							showPopupInline(contextPath + "/docview/ajax/linkTestCases.spr?testCaseIds=" + ids.join(",") + "&requirementId=" + np.li_attr["id"], {geometry: 'large'});
							return;
						}
						bs = ajaxBusyIndicator.showBusyPage();
					}
					$.ajax({
						"url": url,
						"type": "POST",
						"data": urlParams,
						"success": function(responseData) {
							if (bs != null) {
								ajaxBusyIndicator.close(bs);
							}

							self._handleNodeMoveResponse(responseData, o, isCopy, np, isFromLibrary, referenceNodeId, position);
						},
						"error": function (e, d) {
							if (bs != null) {
								ajaxBusyIndicator.close(bs);
							}
							$.jstree.reference(self.config.treePaneId).refresh();
							showOverlayMessage(i18n.message("tracker.view.layout.document.tree.move.error.message"), 3, true);
						}
					});
				};
				if (self._isEdited()) {
					// the right pane is edited and the user clicked to an other node in the tree
					showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.move.node.confirm"), executeDrop, function () {
						// scroll back to the edited element
						var $propertiesPane = $('#issuePropertiesPane');
						var editedId = $propertiesPane.data("showingIssue");
						codebeamer.common._scrollToElement($('tr#' + editedId));

						// refresh the tree on cancel to undo the drop
						$.jstree.reference(self.config.treePaneId).refresh();
					});
				} else {
					executeDrop();
				}
			};

			this.loadNewParagraphIds = function (idList) {
				$.get(contextPath + "/trackers/ajax/getParagraphIdsForItems.spr", {
					itemIds: idList,
					tracker_id: self.config.id
				}, function (newReleaseIds) {
					if (newReleaseIds) {
						for (var key in newReleaseIds) {
							$(".requirementTr#" + key + " .releaseid").html(newReleaseIds[key]);
						}
					}
				});
			};

			this._handleNodeMoveResponse = function (data, node, isCopy, parent, isFromLibrary, referenceNodeId, position) {
				var isTracker = parent.li_attr["type"] == "tracker";
				if (data && data["success"] == false) {
					var msg = "";
					if (data["error"] == "mappingProblems") {
						showPopupInline(contextPath + "/trackers/library/resolveFieldProblems.spr?tracker_id=" + self.config.id
								+ "&parent_id=" + (isTracker ? "" : parent.li_attr["id"].trim()) + "&copied_id=" + node.li_attr["id"].trim());
					} else {
						msg = data["message"] ? data["message"] : i18n.message("tracker.view.layout.document.copy.error");
						showOverlayMessage(msg, 3, true);
						$.jstree.reference(self.config.treePaneId).refresh();
					}
				} else {
					var $domNode = $("li[id=" + node.id + "]");
					var isFromTestLibrary = $domNode.parents("#test-plan-pane").size();
					var targetNode = isFromTestLibrary ? parent : node;

					var filterText = $("#searchBox_treePane").val();
					var $tree = $("#" + self.config.treePaneId);
					if (filterText.length >= 2 && filterText != i18n.message("association.search.as.you.type.label")) {
						$tree.trigger("codebeamer.filtered", [$tree, filterText]);
					}

					if (!isCopy || isFromLibrary) {
						/*
						 * instead of reloading the whole right panel:
						 * find the moved items on the right panel and move them under the row of the target issue (including
						 * their children).
						 * after that refresh the issues because their status and paragraph id may change.
						 *
						 */
						var tree = $.jstree.reference(self.config.treePaneId);

						// find the moved ids and their children
						var ids = [];
						for (var i = 0; i < node.length; i++) {
							ids.push(node[i].id);
							var $node = $("#" + self.config.treePaneId + " li#" + node[i].id);
							var $children = $node.find("li");
							if ($children.size() > 0) {
								$children.each(function () {
									ids.push($(this).attr("id"));
								});
							}
						}

						// find the refrence requirement in the center panel
						var $referenceRequirement = $(".requirementTr#" + referenceNodeId);

						// it' possible that the reference requirement is not visible on the center panel because of the infinite scrolling
						// in this case no dom update is needed
						var nodesMoved = [];
						for (var i = 0; i < ids.length; i++) {
							nodesMoved.push($(".requirementTr#" + ids[i]));
						}

						if ($referenceRequirement.size() == 1) {

							// if the moved requirements are not in the dom then reload the target item's page to the center panel
							var missingFromDom = false;
							for (var i = 0; i < nodesMoved.length; i++) {
								if (nodesMoved[i].size() == 0) {
									missingFromDom = true;
									break;
								}
							}

							if (missingFromDom) {
								self.reload("rightPane", false, null, {"issue_id": referenceNodeId});
							} else {
								// put the moved items in the center panel after the target item
								if (position == "Before") {
									for (var i = 0; i < nodesMoved.length; i++) {
										var moved = nodesMoved[i];

										$referenceRequirement.before(moved);
									}
								} else {
									for (var i = ids.length - 1; i >= 0; i--) {
										var moved = nodesMoved[i];

										$referenceRequirement.after(moved);
									}
								}

								// refresh the items
//								for (var i = 0; i < ids.length; i++) {
//									self.reloadIssue(ids[i]);
//								}
							}

						} else {
							// when the reference item is not visible (due to infinite scrolling) simply remove the moved items from the dom
							for (var i = ids.length - 1; i >= 0; i--) {
								var removed = nodesMoved[i];

								removed.remove();
							}
						}

						if (data && data['items']) {
							$("#" + self.config.treePaneId).one("refresh.jstree", function () {
								var items = data["items"];
								if (items.length > 0) {
									tree.deselect_all();
									tree.select_node("#" + items[0]["new"].id);
								}
							});
						}

						// reload the paragraph id for all the visible requirements
						var visibleIds = $(".requirementTr").map(function() { if (this.id != "#new-item-id") return this.id;})
						var idList = visibleIds.toArray().join(",");
						self.loadNewParagraphIds(idList);
					} else if (isFromTestLibrary) {
						$.jstree.reference(self.config.treePaneId).refresh();
					}

					if (isTracker || (self.config.subtreeRoot && self.config.subtreeRoot != -1)) {
						// refresh all nodes
						self.refreshNode();
					} else {
						self.refreshNode(parent.li_attr["id"]);
					}

					// reload the affected issues
					if (data.affectedIssues && data.affectedIssues.length) {
						var $propertiesPane = $('#issuePropertiesPane');

						var taskId = $propertiesPane.data("showingIssue");
						if (taskId && data.affectedIssues.indexOf(parseInt(taskId)) >= 0) {
							// if the issue on the properties panel is affected reload it too
							self.showIssueProperties(taskId, self.config.id, $propertiesPane, true, true);
						}
						self.reloadIssue(data.affectedIssues[0], data.affectedIssues);
					}

					// show a message when some of the items couldn't be moved
					if (data.lockedItems && data.lockedItems.length > 0) {
						showOverlayMessage(i18n.message('tracker.view.layout.document.tree.move.locked.message'), 5, true);
					}
				}
			};
			this.checkMove = function (np, o, op, oldTree, isCopy) {
				// handle some special cases. since the upgrader node.id==# marks a "dummy" node instead of undefied, -1 or null
				if (!op || !np  || np.id == '#' || op.id == '#') {
					return false;
				}

				if (!isCopy && o.li_attr["type"] === "folder" && np.li_attr["type"] == "tracker_item") {
					// a folder can be moved under a folder or a tracker node in the same tree
					return false;
				}

				// prevent the user from dropping a node from the right release tree to the left
				if (o.li_attr["class"] == "release-node") {
					return false;
				}

				if (isCopy) {
					var $domNode = $("li[id='" + o.id + "']");
					var isFromLibrary = $domNode.parents(".library").size();
					// when moving from an other tree the target type must be from the second tracker
					// or from the library
					if (!isFromLibrary && np.li_attr["trackerId"] === op.li_attr["trackerId"]) {
						return false;
					}

					// cannot copy a requirement from the library to a test case node
					var $parentDomNode = $("li[id='" + np.id + "']");
					if (isFromLibrary && $parentDomNode.is(".testCase")) {
						return false;
					}

					if (o.li_attr["type"] == "tracker" || o.li_attr["type"] == "project") {
						// cannot move the whole tracker from an other tree
						return false;
					}

					if ((np.li_attr["type"] != "folder" && np.li_attr["type"] != "tracker") && o.li_attr["type"] == "folder") {
						return false;
					}


					if (np == -1 || (!isFromLibrary && np.li_attr["type"] !== "tracker_item")) {
						// cannot link a testcase to a folder
						return false;
					}
				} else if ((self.config.id != o.li_attr["trackerId"]  && self.config.originalTrackerId != o.li_attr["trackerId"]) ||
						!np.li_attr ||
						(self.config.id != np.li_attr["trackerId"] && self.config.originalTrackerId != np.li_attr["trackerId"])) {
					// moving test cases in the requirement tree is not allowed
					return false;
				}

				return true;
			};
			this.externalDrop = function (nodes, target) {
				codebeamer.issueLibrary.libraryExternalDrop(nodes, target);

				if (target.is("#" + self.config.treePaneId)) {

					// when the user drops the item on the empty white are under the tree
					// handle this the same way as if it was dropped to the root node
					var rootId = self.getRootId();
					var tree = $.jstree.reference(self.config.treePaneId);
					var rootNode = tree.get_node(rootId);
					var lastTopLevelChild = $("#" + rootId + " > ul > li:last-child");
					var lastChild = tree.get_node(lastTopLevelChild.attr('id'));

					self.nodeMoved(nodes, rootNode, "After", lastChild, true, null);
				}

				codebeamer.issueDragUtils.clearDragTargets();
			};
			this.checkExternalDrop = function (nodes, $target) {
				if (!nodes || nodes.length == 0) {
					return;
				}
				var node = nodes[0];
				var validDrop = true;
				if ($target.attr("type") == "tracker") {
					validDrop = false;
				}

				// true if the user tries to drop to the tree panel that contains the tree
				var targetIsPane = $target.is("#treePane");

				var nodeId = node.li_attr["id"];
				// each tr in doc view is a drop zone
				var $tr = $target.closest("tr");
				var targetId = $target.closest("tr").attr("id");
				if (nodeId == targetId) {
					validDrop = false;
				}

				if ($target.is(".jstree-node")) {
					validDrop = false;
				}
				var $domNode = $("li[id=" + node.id + "]");
				var isFromLibrary = $domNode.parents("#library-tab.library").size();

				if (targetIsPane && !isFromLibrary) {
					validDrop = false;
				}

				if (validDrop && !targetIsPane) {
					codebeamer.issueDragUtils.drawTargetBoxes($tr, self.config);
				} else {
					codebeamer.issueDragUtils.clearDragTargets();
				}

				return validDrop;
			};

			this._updateNode = function (nodes, data) {
				var node = nodes[0];
				if (!node || !node.li_attr) {
					return;
				}
				var tree = $.jstree.reference(self.config.treePaneId);
				node = tree.get_node(node.id);

				if (!node) {
					return;
				}

				// get the number of children under the node
				var childCount = node.children_d ? node.children_d.length : 0;

				var showSubitemCounts = self.config.showSubitemCounts;

				var prefix = node.li_attr["prefix"];
				var postfix = node.li_attr["postfix"];
				postfix = showSubitemCounts && childCount != 0 ? "(" + childCount + ")" : '';
				node.li_attr["postfix"] = postfix;

				var nameEscaped = escapeHtml(data.name);
				tree.set_text(node, (prefix ? prefix : '') + nameEscaped + (showSubitemCounts && postfix ? ' ' + postfix : ''));

				var backgroundColor = data.iconBgColor
				node.li_attr["iconBgColor"] = backgroundColor;

				node.li_attr["itemVersion"] = data.version;

				var $domNode = $("#" + self.config.treePaneId + " li#" + node.id);
				$domNode.attr('postfix', postfix);
				$domNode.attr("iconBgColor", backgroundColor); // also set the attribute on the li dom node as well

				var $iconContainer = $domNode.find(" > a > .jstree-icon");
				$iconContainer.css({"background-color": backgroundColor, "background-image": "url(" + data["iconUrl"] + ")"});

				if ("true" == data.isSummaryReadable) {
					$domNode.removeClass("summary-not-readable");
				} else {
					$domNode.addClass("summary-not-readable");
				}
			};

			this.loadNode = function (node) {
				if (!node || !node.li_attr) {
					return;
				}
				var id = node.li_attr["id"];
				$.get(contextPath + "/trackers/ajax/getTrackerItem.spr", {"trackerItemId": id})
				.success(function(data) {
					self._updateNode([node], data);
				});
			};

			this.refreshNode = function (id, onlyOneLevel, rename) {
				var t = $.jstree.reference("#" + trackerObject.config.treePaneId);

				if (id) {
					var node = t.get_node("#" + id);
					var trackerNode = t.get_node("[type=tracker]");

					if (node) {
						if (/*node.find("li[trackerid=" + trackerObject.config.id + "]").size() > 0 &&*/ !onlyOneLevel) {
							$("#" + trackerObject.config.treePaneId).one("refresh.jstree", function () {
								self.loadNode(node);
							});

							// refresh the children of the node
							t.refresh("#" + id);
						} else {
							self.loadNode(node);
						}
					}
				} else {
					t.refresh();
				}
			};

			/**
			 * returns true if any of the descriptions, summaries or properties is edited on the right side.
			 */
			this._isEdited = function () {
				return $("#rightPane .edited").size() > 0;
			};

			/**
			 * hides the paste items in the context menus
			 */
			this._hidePasteActions = function () {
				$(".paste-action").closest("li").hide();
			};

			/**
			 * hides the paste items in the context menus
			 */
			this._showPasteActions = function () {
				$(".paste-action").closest("li").show();
			};

			this.bindEventHandlers = function () {

				/**
				 * decides if for the $target an editor can be created.
				 */
				var canCreateEditor = function ($target) {
					var isSummary = $target.closest(".name").size() > 0;
					var $row = $target.closest(".requirementTr");

					var isEditable = $row.data("summaryEditable") || $row.data("descriptionEditable");
					var isEdited = $row.is(".edited");

					if (!isEditable) {
						showFancyAlertDialog(i18n.message("tracker.view.layout.document.not.editable.warning"));
					}

					if (isTrackerLocked()) {
						showFancyAlertDialog(i18n.message('tracker.currently.locked.warning'));
					}
					return isEditable && !isEdited && !isTrackerLocked();
				};

				var $treePane = $("#" + self.config.treePaneId);
				// add the init event handler for the left tree
				$treePane.one("init.jstree", null, function () {
					var p = $("#rightPane");
					var busySign = ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
						width: "12em",
						context: [ p[0], "tl", "tl", null, [(p.width() > 0 ? (p.width() - 12)/2: 200), 10] ]
					});

					$treePane.one("loaded.jstree", null, function () {
						busySign.remove();
					});
				});

				var $rightPane = $("div#rightPane");
				var descriptionEditorHandler = createEditorHandler(onDescriptionOpen, onDescriptionSubmit, onDescriptionSubmitted, '.description');

				$rightPane.click(function (event) {
					var $target = $(event.target);
					var $row = $target.closest(".requirementTr");
					var rowId = $row.attr("id");

					if ($target.parent().is("a.diff-link")) {
						var modifiedIn = $("#intervalSelector").val();
						inlinePopup.show(contextPath + "/issuediff/diffDate.spr?issue_id=" + rowId + "&modifiedIn=" + modifiedIn, {
							geometry: "large"
						});
					} else if ($target.closest(".testStepContainer").size() > 0) {
						var $container = $target.closest(".testStepContainer");
						// clicking on the test steps box: load test steps
						var id = $target.closest(".requirementTr").attr("id");
						var $expandable = $container.next(".expandable");
						loadTestSteps(id, $expandable);

						$expandable.toggle();

						var visible = $expandable.is(":visible");
						// change the expander [+]/[-] icon image
						$container.find("img.expander").toggleClass("expanded", visible);

						// trigger a custom event for expanding
						$container.trigger("expandedOrCollapsed");
						$rightPane.trigger('cbRightPaneHeightChanged');
					} else if ($target.is(".inplaceEditableIcon") && $target.closest(".name").size() > 0) {
						$target.closest(".name").dblclick();
					} else if ($target.is(".item-icon")) {
						var $menuContainer = $target.parent('div');

						buildAjaxTransitionMenu($menuContainer, {
							'task_id': rowId,
							'cssClass': 'inlineActionMenu transition-action-menu',
							'builder': 'trackerItemTransitionsOverlayActionsMenuBuilder'
						});
					} else if ($target.is(".referring-items")) {
						var $menuContainer = $target;
						self.lastEdited = rowId;
						if (!$menuContainer.hasClass('menu-downloaded')) { 
							buildInlineMenuFromJson($menuContainer, '.requirementTr#' + rowId + ' .referring-items', {
								'task_id': rowId,
								'cssClass': 'inlineActionMenu referring-item-menu',
								'builder': 'overlayTrackerItemReferringItemActionsMenuBuilder'
							});
							return false;
						}
					} else if ($target.is(".menuArrowDown")) {
						popupMenuLazyClickHandler($(event.target));
					} else if ($target.is('.comment-bubble')) {
						var id = $target.data('id');
						addCommentInOverlay(id);
					} else if ($target.is(".edit-description")) {
						if (canCreateEditor($target.parents(".requirementTr").find(".description-container"))) {
							descriptionEditorHandler(event);
							event.stopPropagation();
						}
					} else if ($target.is(".edit-overlay-container")) {
						if (canCreateEditor($target.parents(".requirementTr").find(".description-container"))) {
							descriptionEditorHandler(event);
							event.stopPropagation();
						}
					} else if ($target.is(".edit-in-word")) {

						OfficeEdit.doEditing(rowId, contextPath, function(){
							IssueDescriptionPoller.addIssue(rowId, new Date().getTime(), "tr#" + rowId + " > td.requirementTd > div.description > div.editable");
							IssueDescriptionPoller.startPolling(contextPath + "/checkissuechanged.spr", function(updated) {
								refreshProperties(updated.id);
							});
						});
					}

					codebeamer.common.selectItemInTree($row, function () {
						if ($row.size() > 0) {
							var rowId = $row.attr("id");
							trackerObject.showIssueProperties(rowId, self.config.id, $('#issuePropertiesPane'),
								self.config.revision == null || self.config.revision == "");
						}
					}, self.config.treePaneId, self.config.id);
				});

				if (!self.config.extended && codebeamer.userPreferences.doubleClickEditOnDocView) { // on the extended doc view do not open a summary editor on double click
					$rightPane.dblclick(function (event) {
						var $target = $(event.target),
							$descriptionContainer = $target.closest('.description-container');

						if ($target.closest(".description-container").size() == 0 && $target.closest(".name").size() == 0) {
							return;
						}

						if ($target.is(".ui-multiselect") || $target.closest('.fr-box').length) {
							return;
						}

						if ($descriptionContainer.length && ($descriptionContainer.is(':animated') || $descriptionContainer.is('.new-item'))) {
							return;
						}

						if (isTrackerLocked()) {
							showFancyAlertDialog(i18n.message('tracker.currently.locked.warning'));
							return;
						}

						if (!$target.is(".nested-summary-editor") && canCreateEditor($target)) {
							// double click to description: open editor
							descriptionEditorHandler(event);
							event.stopPropagation();
						}
					});
				}

				$rightPane.on('mouseover', '.requirementTr', function () {
					$('.requirement-active').removeClass('requirement-active');
					$('.row-preceeding-active').removeClass('row-preceeding-active');

					var $row = $(this);
					if (self.config.synchronizeTree && $(".jstree-contextmenu").size() == 0) {

						// select the item in the tree when the user moves the cursor over it on the center panel
						// but only if the context menu is not active because otherwise moving above the menu can change the selection
						codebeamer.common.selectItemInTree($row, null, self.config.treePaneId, self.config.id);
					}

					// mark the previous row with a special css class
					$row.prev('.requirementTr').addClass('row-preceeding-active');
				}).on('keydown', '.nested-summary-editor', function (event) {
					var editorId = $(this).data("editorId");

					var $editorTextarea = $("#" + editorId);
					return self._handleEditorCancelAndSave($editorTextarea, event);
				});

				var hideCompactModeMenus = function () {
					$(".control-bar.compact .controls").hide();
					$("span.compact-mode-button.active").removeClass("active");
				}

				/*
				 * delays the closing of the compact mode toolbar until there are no user actions (mouse move etc)
				 */
				var throttleCompactModeToolbar = function () {
					throttle(hideCompactModeMenus, null, null, 3000);
				};

				// bind the compact view panel event handlers
				$rightPane.on('click', 'span.compact-mode-button', function (event) {
					// hide the other control groups
					hideCompactModeMenus();

					var $button =  $(this);
					var $controls = $button.next().show();
					$controls.css({top: $button.position().top});
					$button.addClass("active");

					throttleCompactModeToolbar();
				});

				$rightPane.on('mouseleave', '.control-bar.compact .controls', function (event) {
					var $controls = $(this);
					$controls.hide();

					// remove the active class from the button
					$controls.prev().removeClass("active");
				});

				/*
				 * every time the user moves the cursor above a compact toolbar delay the closing of
				 * the toolbar a little bit more.
				 */
				$rightPane.on('mouseover', '.controls.compact', function (event) {
					throttleCompactModeToolbar();
				});

				$("#treePane").on('click', '.pin-icon', function (event) {
					trackerObject.goToParentLevel();

				});

				$(document).on("click", ".compact-view-mode-switch", function (event) {
					toggleCompactMode();
				});

				/* when opening a node inline editor in the tree replace the node prefix with the empty string (it's not part of the editable value) */
				$(document).on('focus', '.jstree-rename-input', function (event) {
					var $input = $(this);
					var text = $input.val();
					var node = $input.closest(".jstree-node");
					var tree = $.jstree.reference("treePane");
					var treeNode = tree.get_node(node.attr("id"));

					// treeNode can be null when renaming a node in the release tree (not in the main tree)
					if (!treeNode) {
						return;
					}


					var prefix = treeNode.li_attr["prefix"];
					if (prefix) {
						text = text.replace(prefix, "");
					}
					var postfix = treeNode.li_attr["postfix"];
					if (postfix) {
						text = text.replace(postfix, "");
					}

					$input.val(text);

				}).on("keydown", '.jstree-rename-input', function (event) {
					var key = event.which;
					if(key === 27) {
						var $input = $(this);
						var text = $input.val();
						var node = $input.closest(".jstree-node");
						var tree = $.jstree.reference("treePane");
						var treeNode = tree.get_node(node.attr("id"));

						var prefix = treeNode.li_attr["prefix"];
						if (prefix) {
							text = text.replace(prefix, "");
						}
						var postfix = treeNode.li_attr["postfix"];
						if (postfix) {
							text = text.replace(postfix, "");
						}
						$input.val(text);
					}
				}).on('click', '.requirementTr .branchDivergedBadge', function () {
					var $badge = $(this);
					var masterDiverged = $badge.is(".masterDivergedBadge");

					var originalId = $badge.data("originalId");
					var issueId = $badge.data("issueId");
					inlinePopup.show(contextPath + "/branching/diff.spr?isPopup=true&branchId=" + self.config.branchId + "&issueIds=" + issueId
							+ "&mergeFromMaster=" + masterDiverged, {
						geometry: "large"
					});
				});

				var $middleHeaderDiv = $("#middleHeaderDiv");
				$("#panes").on("eastClose", function () {
					$middleHeaderDiv.addClass("eastClosed");
				}).on("eastOpen", function () {
					$middleHeaderDiv.removeClass("eastClosed");
				}).on("westClose", function () {
					$middleHeaderDiv.addClass("westClosed");
				}).on("westOpen", function () {
					$middleHeaderDiv.removeClass("westClosed");
				})

				$("body").on("codebeamer.clearSuspect", function (event, taskId) {
					var $propertiesPane = $('#issuePropertiesPane');

					taskId = taskId || $propertiesPane.data("showingIssue"); // if the task id is not present use the id of the item currently edited on the right panel
					if (taskId) {
						self.reloadIssue(taskId);
						self.showIssueProperties(taskId, self.config.id, $propertiesPane, true, true);
					}
				})

				// event handlers for infinite scrolling on the extended (editable) document view
				if (self.config.extended) {
					$(document).on('codebeamer.beforePageUnload', function () {
						codebeamer.trackers.extended.storeFormData();

						// destroy the currently active editors, otherwise they will remain in the browser memory
						 $.each($.FE.INSTANCES, function () {
							 if (this && this.destroy && this.$box.hasClass('field-editor')) {
                                 this.$box.closest('.requirementTr').removeClass('initialized');
							 	this.destroy();
							 }
						 });

					}).on('codebeamer.afterPageLoad', function () {
						// after the new rows were added initialize the editors and the dirty checks
						codebeamer.trackers.extended.initializeNewEditors();
					});
				}
			};

		}
	};
}());

//enable event handling on context menu of a just loaded html elements
function initJQueryMenus(parentElement) {
	$(parentElement).find(".yuimenubar:not(.initialized)").each(function() {
		var $this = $(this);
		initPopupMenu($this.attr("id"), {context : [$this.find(".yuimenubaritemlabel a"), "br", "tr"]});
		$this.addClass("initialized");
	});
}

function createTestRunFromTestCases(testRunTrackerId) {
	var ids = [];
	$("[name=clipboard_task_id]:checked").each(function() {
		ids.push($(this).closest("tr").attr("id"));
	});
	if (ids.length == 0) {
		alert(i18n.message("no.item.selected"));
		return;
	}
	var serialized = "tests=" + (ids.join(","));	// TODO: versioning ?
	var popup = true;

	var url = "/proj/tracker/createtestrunmultiplesources.spr"
	url = contextPath + url + "?tracker_id=" + testRunTrackerId +"&noReload=true";
	url += "&" + serialized;
	if (popup) {
		url +="&isPopup=true";
		showPopupInline(url, { geometry: "large"});
	} else {
		location.href= url;
	}
}

function reloadEditedIssue(issueId, affectedIssues, skipReloadProperties) {
	$("#planner").trigger("issueChanged");
	if (typeof trackerObject != "undefined") {
		if (typeof affectedIssues != "undefined" && !$.isArray(affectedIssues)) {
			affectedIssues = [affectedIssues];
		}
		var $propertiesPane = $('#issuePropertiesPane');
		var editedInPropertyEditorId = issueId ? issueId : $propertiesPane.data("showingIssue");

		var params = {};

		var tree = $.jstree.reference(trackerObject.config.treePaneId);

		var affectedIssueIds = [];
		if (affectedIssues) {
			for (var i = 0; i < affectedIssues.length; i++) {
				affectedIssueIds.push(affectedIssues[i].id);
			}

			// refresh the affected nodes in the tree (their color and name)
			for (var i = 0; i < affectedIssues.length; i++) {
				var node = tree.get_node("#" + affectedIssues[i].id);

				if (node) {
					var bgColor = affectedIssues[i].iconBgColor;
					trackerObject._updateNode($(node), affectedIssues[i]);
				}
			}

			trackerObject.reloadIssue(editedInPropertyEditorId, affectedIssueIds);
		} else {
			var node = tree.get_node("#" + editedInPropertyEditorId);
			trackerObject.loadNode(node);
			trackerObject.reloadIssue(editedInPropertyEditorId);
		}
		if (!skipReloadProperties) {
			trackerObject.showIssueProperties(editedInPropertyEditorId, trackerObject.config.id, $propertiesPane, true, true);
		}
		issueId = issueId ? issueId : editedInPropertyEditorId;

		showOverlayMessage();
	}
}

function reloadTree() {
	$("#issuePropertiesPane").data("showingIssue", "");
	trackerObject.reload("rightPane");
}

function clearIssueProperties() {
	var $panel = $("#issuePropertiesPane");
	var hint = createInfoMessageBox(i18n.message("tracker.browse.documentView.selectAnItem"), "information");
	$panel.empty().data("showingIssue", "").append(hint);
}

/**
 * this function builds a parameter map based on the filter conditions in the multiselect list. then reloads
 * the center panel using this parameter map. if no parameters are set then reloads the center panel in normal state
 * (that is using the same parameters as on the initial page load). while filtering the center panel it also maintains the
 * tree state.
 */
function filterItems() {
	// the ids of all visible requirements
	var newlyCreatedItemIdPattern = "[id^=new-item-]";

	var $tree = $("#treePane");

	// if the tree instance is not initialized yet don't do any filtering
	if (!$.jstree.reference($tree)) {
		return;
	}

	var $intervalSelector = $("#intervalSelector");
	var $checked = $(".ui-multiselect-menu").find(".checked").siblings("[type=checkbox]");
	var checkedValues = $checked.val();
	if (!checkedValues) {
		clearFilters();
		$intervalSelector.multiselect("enable");
	} else {
		var requestData = getFilterParameters();

		// disable the filter box to prevent multiple filter requests
		$intervalSelector.multiselect("disable");

		// reload the center panel with the filter parameters
		trackerObject.reload("rightPane", true, function () { // reload the tree inly if the full text search is active
			$intervalSelector.multiselect("enable"); // enable the filter box after the request
		}, requestData);
	}
}

function getFilterParameters() {
	var $intervalSelector = $("#intervalSelector");
	var $checked = $(".ui-multiselect-menu").find(".checked").siblings("[type=checkbox]");
	var requestData = {
			ratingFilters: [],
			dateFilters: [],
			suspectedFilters: [],
			statusFilters: [],
			tracker_id: trackerObject.config.id,
			trackerId : trackerObject.config.id
	};

	$checked.each(function () {
		var $box = $(this);

		var group = [];
		if ($box.parents(".average-rating").size() > 0) {
			group = requestData.ratingFilters;
		} else if ($box.parents(".modified-in").size() > 0) {
			group = requestData.dateFilters;
		} else if ($box.parents(".suspected").size() > 0) {
			group = requestData.suspectedFilters;
		} else if ($box.parents(".status").size() > 0) {
			group = requestData.statusFilters;
		} else if ($box.parents(".reference").size() > 0) {
			requestData.referenceFilter = $box.val();
		}

		group.push($box.val());
	});

	requestData.ratingFilters = requestData.ratingFilters.join(',');
	requestData.dateFilters = requestData.dateFilters.join(',');
	requestData.suspectedFilters = requestData.suspectedFilters.join(',');
	requestData.statusFilters = requestData.statusFilters.join(',');

	var $reportSelector = $(".reportSelectorTag").first();
	if ($reportSelector.length > 0) {
		var reportSelectorId = $reportSelector.attr("id");
		var initialCbQL = codebeamer.ReportSupport.getInitialCbQL(reportSelectorId);
		if (initialCbQL) {
			requestData["cbQL"] = initialCbQL;
			codebeamer.ReportSupport.clearInitialCbQL(reportSelectorId);
		} else {
			requestData["cbQL"] = codebeamer.ReportSupport.getCbQl(reportSelectorId);
		}
	}

	if (trackerObject.config.extended) {
		var storedFormData = codebeamer.trackers.extended.loadFormData();

		requestData['formValues'] = JSON.stringify(storedFormData);

		requestData['extended'] = trackerObject.config.extended;
		requestData['currentFieldList'] = codebeamer.trackers.extended.getCurrentFieldList(true);

	}

	return requestData;
}

function clearFilters() {
	$(".diff-link").hide();
	$("#treePane").jstree("clear_search");
	trackerObject.reload("rightPane", true);
}

/**
 * returns the array of issue ids that must be displayed (because match the modification date criteria).
 *
 * @param requestData
 * @param callback
 * @returns
 */
function filterByCriteria(requestData, callback) {
	jQuery.ajax({
	   headers : {
	      'Accept' : 'application/json',
	      'Content-Type' : 'application/json'
	   },
	   'type' : 'GET',
	   'url' : contextPath + '/trackers/ajax/filterDocumentView.spr',
	   'data' : requestData,
	   'dataType' : 'json',
	   'success' : callback
	});
}

function initFilter() {
	var $intervalSelector = $("#intervalSelector");

	var selectOne = function (value, selector) {
		$intervalSelector.multiselect("widget").find(selector + " :checkbox:checked").each(function() {
			var $this = $(this);
			if ($this.val() != value && $this.is(":checked")) {
				$this.attr("checked", false);
				$this.siblings(".checker").removeClass("checked");
			}
		});
	};
	$intervalSelector.multiselect({
		"header": "Apply",
		"classes": 'status-filter-multiselect', 
		"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
		"create": function() {
			$intervalSelector.multiselect("close");

			$(".ui-multiselect-checkboxes li label").each(function() {
				var $this = $(this);
				var $input = $this.find("input");

				if ($this.parents('.status').length > 0) {
					var $option = $('option[value=' + $input.attr('value') + ']');
					var $icon = $('<img>', {src: $option.data('icon'), style: 'background-color:' + $option.data('background'), 'class': 'multiselect-option-icon'});
					$this.prepend($icon);
				}

				$input.hide();
				var $checker = $("<div class='checker'>");
				$this.prepend($checker);
			});

			$(document).on("click", ".ui-multiselect-checkboxes li label", function(event) {
				var $this = $(this);
				var checker = $this.find(".checker");
				var input = $this.find("input");
				var wasChecked = input.is(":checked");

				input.prop("checked", !wasChecked);
				checker.toggleClass("checked", !wasChecked);

				$intervalSelector.multiselect("close");
				$intervalSelector.multiselect("update");

				var $item = $(this).closest("li");
				if ($item.is(".reference")) {
					selectOne(input.val(), ".reference");
				}
			});
		},
		"selectedText": function(numChecked, numTotal, checked) {
			return $.map(checked, function(a) {
				return $(a).attr("title");
			}).join(", ");
		}
	});
	$intervalSelector.multiselect("uncheckAll"); // by default nothing is selected
}

function executeTransitionCallback(data) {
	reloadEditedIssue(data.id, data.affectedIssues);
}

function reloadAfterAddAssociation() {
	var node = $('.adding-association');
	var id = node.attr('id');
	node.removeClass('adding-association');

	$('#issuePropertiesPane').data("showingIssue", "");
	trackerObject.showIssueProperties(id, trackerObject.config.id, $('#issuePropertiesPane'),
			trackerObject.config.revision == null || trackerObject.config.revision == "");
}

function refreshAfterComment() {
	if (typeof trackerObject !== "undefined") {
		// Reload issue properties in Docuemnt View
		var $element = $('.adding-comment');
		var id = $element.data('id');
		var $propertiesPane = $('#issuePropertiesPane');
		trackerObject.reloadIssue(id);
		trackerObject.showIssueProperties(id, trackerObject.config.id, $propertiesPane, true, true);
	} else if (typeof codebeamer !== "undefined" && typeof codebeamer.planner !== "undefined") {
		// Reload issue properties in Planner
		codebeamer.planner.reloadSelectedIssue();
	}
}

function refreshAfterAddReference() {
	trackerObject.reloadIssue(trackerObject.lastEdited);
	if ($("#testTreePane").size() > 0) {
		$.jstree.reference("testTreePane").refresh();
	}
	showOverlayMessage();
	var $propertiesPane = $("#issuePropertiesPane");
	trackerObject.showIssueProperties(trackerObject.lastEdited, trackerObject.config.id, $propertiesPane, true, true);
}

function generateTestCaseForId(id, attributes) {
	trackerObject.generateTestCase(id, attributes.tracker_id);
}

function generateTestRunForId(id, attributes) {
	codebeamer.trackers.Tracker.prototype.createTestRuns([id], attributes.test_run_tracker_id);
}

function openIssue(id, attributes) {
	window.open(attributes.url, '_top');
}

function resetRatings(trackerId, viewId) {
	showFancyConfirmDialogWithCallbacks(i18n.message("tracker.reset.ratings.confirm.message"), function() {
		$.post(contextPath + '/proj/tracker/resetRatings.spr', {
			'tracker_id': trackerId,
			'view_id': viewId
		}, function (data) {
			if (data.message) {
				showOverlayMessage(i18n.message(data.message), 3, !data.success);
			} else {
				showOverlayMessage();
			}
			if (!data.noChange) {
				location.reload();
			}
		}).error(function (data) {
			showOverlayMessage(data.thrownError, 3, true);
		})
	});
}

/**
 * used for filtering the tree by the same criteria that is used for filtering the middle panel. codebeamer.matchedIds is set by the main filtering method.
 * this function simply checks if the id of the node is in this array.
 */
function statusMatchesSearch(filterText, node) {
	var idAttr = node.id;
	var id = parseInt(idAttr);

	return codebeamer.matchedIds[id];
};


function refreshTrees(id) {
	$.jstree.reference(trackerObject.config.treePaneId).refresh();

	var testTree = $.jstree.reference("testTreePane");
	if (testTree) {
		testTree.refresh();
	}

	if (id) {
	 	// reload the properties of the requirement where the new test case was linked
		var $issueProperties = $('#issuePropertiesPane');
		trackerObject.showIssueProperties(id, trackerObject.config.id, $issueProperties, trackerObject.config.editable, true);
	}
}

/**
 * delays the execution/download of the scripts in the html. script[src] elements are simply removed
 * so I added those to documentView.jsp. the inline scripts are delayed (are executed after the  content without scripts
 * was appended to $container).
 *
 * @param html
 * @param $container
 */
function delayScripts(html, $container) {
	var loadLater = function(script) {
		setTimeout(function () {
			$container.append(script);
		}, 0)
	};

	var tempDiv = document.createElement('div');
	tempDiv.innerHTML = html;

	var scripts = tempDiv.getElementsByTagName('script');
    var len = scripts.length;
    while (len--) {
    	var script = scripts[len];

    	if (script.src) {
    		console.log("removing script " + script.src);
    	} else {
    		console.log("delayed an inline script");
    		loadLater(script);
    	}

		script.parentNode.removeChild(script)
    }

    $container.html(tempDiv.innerHTML);
}


var toggleCompactMode = function () {
	// get the current compact mode setting and set the opposite
	userSettings.load("DOCUMENT_VIEW_COMPACT_MODE", function (value) {
		var compactModeEnabled = value == "true";
		if (compactModeEnabled) {
			//disable the compact mode
			$(".control-bar").removeClass("compact");
			$(".compact-view-mode-switch .switch").removeClass("on").addClass("off");
			$(".controls").show();
		} else {
			$(".control-bar").addClass("compact");
			$(".compact-view-mode-switch .switch").removeClass("off").addClass("on");
		}

		// store the new setting
		userSettings.save("DOCUMENT_VIEW_COMPACT_MODE", !compactModeEnabled);
	});
};

var addCommentInOverlay = function (id) {
	var canView = false;
	var url = contextPath + '/proj/tracker/docview/showCommentDialog.spr?task_id=' + id;

	// Check permimssion in Document View (required for comment bubble on the toolbar)
	var $target = $(".comment-bubble[data-id=" + id + "]");
	if ($target.length > 0) {
		canView = $target.data('canview');

		if (canView) {
			$target.addClass('adding-comment');
			showPopupInline(url, {'geometry': 'large'});
		}
	} else {
		// Planner right panel, permission checked in jsp
		showPopupInline(url, {'geometry': 'large'});
	}

};

var wrapHandlerFunction = function (handler) {
	return function () {
		try {
			if (handler) {
				handler.call(this);
			}
		} finally {
			$(this).dialog("destroy");
		}
	};
};

var isTrackerLocked = function() {
	var currentUserId = $('#currentUserId').val(),
		lockedByUserId = $('#lockedById').val();


	return lockedByUserId && currentUserId != lockedByUserId;
};

function addItemIdsAndShowPopupInline(url){

	var Tracker = codebeamer.trackers.Tracker.prototype;

	// get the selected issues from the tree if we're on the document view
	var ids = Tracker.getSelectedIssuesFromTree();

	var parentids = ids.length;
	//get the selected issue's children
	var tree = window["trackerObject"] ? $.jstree.reference(trackerObject.config.treePaneId) : null;
	var hasChildren = false;
	if(tree){
		for (var i = 0; i < ids.length; i++) {
			var id = ids[i];
			var node = tree.get_node(id);
			if (node.children.length > 0) {
				hasChildren = true;
				for (var j = 0; j < node.children.length; j++) {
					ids.push(node.children[j]);
				}
			}
		}
	}

	// when the table view is shown collect the ids of the selected checkboxes
	$("input[name='clipboard_task_id']:checked").each(function() {
		ids.push($(this).val());
	});

	var newUrl = url + "&itemIds=" + ids.join(';');
	if(hasChildren){
		newUrl = newUrl + "&parentIdAmount=" + parentids
	}

	showPopupInline(newUrl);
}

function confirmDeleteAttachmentAjax(url) {
	if (confirm(i18n.message("tracker.delete.attachment.confirm"))) {
		$.get(url).done(function() {
			refreshSelectedIssueProperties();
		}).error(function (err) {
			showOverlayMessageWithOptions(err.responseText, {error: true});
		});
	}
}


function testRunGenerated(testRunId, testRunTrackerId, testRunName, multipleRunsGenerated) {
	var url = contextPath + '/issue/' + testRunId;

	var message = null;
	if (multipleRunsGenerated) {
		message = i18n.message('tracker.view.layout.document.created.multiple.testruns.short');
	} else {
		var runnerUrl = "task_id=" + testRunId + "&tracker_id=" + testRunTrackerId;
		var onClick = "return testRuns.runTestRun('testRunner', '" + runnerUrl + "', false);";
		message = i18n.message('tracker.view.layout.document.created.testrun.and.run', url, testRunName, url, onClick);
	}


	showOverlayMessageWithOptions(message, {error: false, requiresManualClose: true});
}