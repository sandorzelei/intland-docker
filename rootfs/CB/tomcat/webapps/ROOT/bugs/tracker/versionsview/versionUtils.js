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
 */

var VersionUtils = (function() {

	var statePersistenceEnabled;
	var treeNodeStates = {};
	var indented;
	var relationUserSettings = {};
	var sharedSettings = {};


	var init = function(settings) {
		sharedSettings = settings;

		indented = $(".indented").length > 0;
		initExpanders();
		_initRememberTreeStateControls();

		statePersistenceEnabled = $("#autoSaveReleaseTreeState").is(":checked");

		// add the menu event handler
		$(".versions").on("click", ".menuArrowDown", function (event) {
			popupMenuLazyClickHandler($(event.target));
		});

		$.ajax({
			url: contextPath + '/ajax/versionStats/configuration/loadUserSettings.spr',
			type: "GET",
			success: function(data) {
				relationUserSettings = data;
				initIssueRelationTree($('body'));
			},
			error: function(xhr, textStatus, errorThrown) {
				alert("Error: " + textStatus + " - " + errorThrown);
			}
		});
	};

	var initExpanders = function() {
		var storedStates, json, shouldRestoreState, versionTreeState;

		var handler = function(expand) {
			return function(event) {
				var expander = $(event.target);
				toggle(expander, expand);
				return false;
			};
		};


		$(".issuesExpander, .subreleasesExpander").each(function() {
			var expander = $(this);
			expander.click(handler())
				.bind("open", handler(true))
				.bind("close", handler(false));
		});

		storedStates = {};
		try {
			versionTreeState = $(".versionTreeState").last();
			json = versionTreeState.text();
			storedStates = $.parseJSON(json) || {};
		} catch (ex) {
			// jQuery 1.9+ throws error on invalid JSON
		}
		treeNodeStates = $.extend(_getCloseAll(), storedStates);

	};

	var _initRememberTreeStateControls = function() {
		$("#autoSaveReleaseTreeState").not(".initialized").click(function() {
			var checked = this.checked;
			_persistRememberTreeState(checked);
			statePersistenceEnabled = checked;
			if (checked) {
				_persistTreeState();
			}
			return true;
		}).addClass("initialized");

		$("#saveReleaseTreeStateNow").not(".initialized").click(function() {
			_saveTreeNodeStates(true);
			var btn = $(this);
			btn.prop("disabled", true);
			var ajaxLoaderImg = $("<img>").attr("src", btn.data("loader-image-url"));
			var ajaxLoader = $("<span>").html(ajaxLoaderImg).addClass("ajaxLoader").insertBefore(btn);
			_persistTreeState(true);
			return false;
		}).addClass("initialized");

		$("#trackerFilter").keydown(function (event) {
			if (event.keyCode == 13) {
				_saveTreeNodeStates(true);
				_persistTreeStateNow(true, function () {
					$("#browseTrackerForm").submit();
				});
			}
		});
	};

	var isOpen = function(expander) {
		expander = $(expander);
		if (!expander.hasClass("expander")) {
			expander = expander.find(".expander").first();
		}
		return expander.hasClass("expanded");
	};

	var isClosed = function(expander) {
		return !isOpen(expander);
	};

	var toggle = function(expander, expand) {
		expander = $(expander);
		if (!expander.hasClass("expander")) {
			expander = expander.find(".expander").first();
		}
		if (expander.hasClass("issuesExpander")) {
			_expandOrCollapseIssues(expander, expand);
		} else if (expander.hasClass("subreleasesExpander")) {
			_expandOrCollapseSubReleases(expander, expand);
		}
		_saveTreeNodeStates();
		_persistTreeState();
	};

	var _expandOrCollapse = function($expander, expand, onExpand, onCollapse) {
		var wasClosed = isClosed($expander);
		if (expand != null && wasClosed != expand) {
			//already expanded or collapsed
			return;
		}
		if (wasClosed) {
			$expander.addClass("expanded");
			onExpand($expander);
		} else {
			$expander.removeClass("expanded");
			onCollapse($expander);
		}
	};

	var _expandOrCollapseIssues = function($expander, expand) {
		var $block = $expander.parents("div.version");
		if ($block.length == 0) {
			return;
		}
		var versionId = $block.attr("id");
		versionId = versionId.match(/\d+/)[0];	// extract the number versionId from the versionId string
		var $filterMenu = $("#filterMenu_" + versionId);

		var onExpand = function() {
			_loadIssuesViaAjax($block, $filterMenu);
		};
		var onCollapse = function() {
			// remove issue list
			$block.find(".issuelist").remove();
			$filterMenu.hide();
		};
		_expandOrCollapse($expander, expand, onExpand, onCollapse);
	};

	var _expandOrCollapseSubReleases = function($expander, expand) {
		var $block = $expander.parents("div.version");
		var versionIssuesContainer = $block.children(".versionIssuesContainer");

		if (versionIssuesContainer.length > 0) {
			versionIssuesContainer.toggle(expand);
			if (versionIssuesContainer.is(":visible")) {
				_loadIssuesViaAjax($block);
			}
		}

		// recursively toggle all direct or indirect children of a release
		var toggleChildrenOf = function(versionId, show) {
			var $children = $(".childOf_" + versionId);	// the children of each release is marked by this css class
			$children.each(function() {
				var $child = $(this);
				if ($child.hasClass("released")) {
					// only show released versions if checkbox is checked
					show = show && _needToShowReleased();
				}
				var childId = $child.attr("id");
				$child.toggle(show && _areAllParentsOpen($child));
				if (childId) {
					if (_wasTreeNodeOpen(childId)) {
						// recursively deeper...
						toggleChildrenOf(childId, show);
					} else {
						toggle(_getExpander(childId), false);
					}
				}
			});
		};

		var versionId = $block.attr("id");
		var onExpand = function() {
			toggleChildrenOf(versionId, true);
		};
		var onCollapse = function() {
			toggleChildrenOf(versionId, false);
		};
		_expandOrCollapse($expander, expand, onExpand, onCollapse);
	};

	var _loadIssuesViaAjax = function($block, $filterMenu) {

		var $expander = _getExpander($block);
		var loadIndicator = $block.find(".loading");

		// update table
		var canBeShownIfReleased = $block.hasClass("released") && _needToShowReleased();
		if (_wereAllParentsOpen($block) && canBeShownIfReleased) {
			$block.show();
		}

		loadIndicator.show();
		if (typeof $filterMenu != "undefined") {
			$filterMenu.show();
		}

		var url = $expander.attr("longdesc");

		// Disable footer auto-positioning because of performance implications: if it is invoked inside a long
		// calculation, it can consume seconds of run time on its own
		codebeamer.enableFooterAutoPositioning = false;

		var ajaxData =  {
			tree_node_states: getTreeStateAsJson()
		};

		if (typeof VersionStats !== "undefined") {
			$.extend(ajaxData, VersionStats.retrieveFilterParameters());
		}

		$.ajax({
			url: url,
			type: "POST",
			dataType: "json",
			data: ajaxData,
			success: function(data) {
				var issueListHtml = renderVersionsJSONToHTML(data.trackerItems);

				// remove previous issue list if stuck
				$block.find(".issuelist").remove();

				// insert issue list
				loadIndicator.hide();
				$block.find(".versionIssues").append(issueListHtml);
				initIssueRelationTree($block);
			},
			error: function(xhr, textStatus, errorThrown) {
				console.error("Error while loading AJAX url " + url);
				alert("Error: " + textStatus + " - " + errorThrown);
			}
		}).always(function() {
			loadIndicator.hide();
			codebeamer.enableFooterAutoPositioning = true;
		});
	};

	var getTreeStateAsJson = function() {
		return  $(".versionTreeState").last().text();
	};

	/**
	 * Tells if it is a version level view (opposed to a tracker-level view where all versions are listed.
	 * @returns {boolean} True if this is a version level view
	 * @private
	 */
	var _isVersionLevelView = function() {
		return !!$("#versionsTable").data("version-level-view");
	};

	var _getBrowsedVersionId = function() {
		return $(".version.firstRelease").data("version-id");
	};

	var _getBrowsedTrackerId = function() {
		return "" + $("#versionsTable").data("tracker-id");
	};

	var _needToShowReleased = function() {
		var releasedCheckbox = $("#showReleased");
		return (releasedCheckbox.length == 0) || releasedCheckbox.is(":checked");
	};

	var _getExpander = function(version) {
		if (typeof version == "number" || typeof version == "string") {
			return $("#" + version + " .expander");
		} else {
			return $(version).find(".expander");
		}
	};

	var _saveTreeNodeStates = function(force) {
		if (statePersistenceEnabled || force) {
			$(".version").filter(".release,.sprint,.backlog").each(function() {
				var id = $(this).attr("id");
				var expander = _getExpander(id);
				treeNodeStates[id] = isOpen(expander);
			});
			$(".versionTreeState").last().text(JSON.stringify(treeNodeStates));
		}
	};

	var _persistTreeStateNow = function(force, callback) {
		if (statePersistenceEnabled || force) {
			console.debug("Persisting ", treeNodeStates);
			$.post(contextPath + "/userSetting.spr?name=VERSION_STATS_TREE_STATE", {
				"value": getTreeStateAsJson()
			}).always(function() {
				var btn = $("#saveReleaseTreeStateNow");
				btn.prop("disabled", false).siblings(".ajaxLoader").remove();
				if (callback) {
					callback.apply(this);
				}
			});
		}
	};

	var _persistTreeState = throttleWrapper(_persistTreeStateNow, 1000);

	var _restoreTreeState = function(treeNodeStates) {
		console.debug("Restoring ", treeNodeStates);
		for (var id in treeNodeStates) {
			var state = treeNodeStates[id];
			var expander = _getExpander(id);
			// In version level view, browsed version should always be open regardless of the stored state
			if (_isVersionLevelView() && id == _getBrowsedVersionId()) {
				state = true;
			}
			toggle(expander, state);
		}
	};

	var _areAllParentsOpen = function(v) {
		var parent = _findParent(v);
		return (parent == null || parent.length == 0) || (isOpen(parent) && _areAllParentsOpen(parent));
	};

	var _wasTreeNodeOpen = function(id) {
		return typeof treeNodeStates[id] == "boolean" ? treeNodeStates[id] : false;
	};

	var _wereAllParentsOpen = function(v) {
		var wereItselfAndAllParentsOpen = function(version) {
			if (!version || version.length == 0) {
				return true;
			}
			var isRelease = version.hasClass("release");
			var parent = _findParent(version);
			var versionId = version.data("version-id");
			return _wasTreeNodeOpen(versionId) && (isRelease || wereItselfAndAllParentsOpen(parent));
		};
		if (v.hasClass("release")) {
			return true;
		}
		return wereItselfAndAllParentsOpen(_findParent(v));
	};

	var _getCloseAll = function() {
		var result = {};
		$(".version.release,.version.sprint,.version.backlog").each(function() {
			result[$(this).attr("id")] = false;
		});
		return result;
	};

	/**
	 * Render the json of TrackerItems to HTML as appears on the versions page
	 * @param jsonTrackerItems The json object contains TrackerItem data
	 * @param noIssuesMessageCode The 'code' of the message to be shown when there are no issues displayed
	 *
	 * === WARNING ===
	 * IF YOU CHANGE THIS METHOD, MAKE SURE YOU KEEP VersionIssuesRenderer.renderTrackerItemsForVersionsToHtml IN SYNC!
	 * TEAM RENDERING IS ONLY PART OF THIS SCRIPT!
	 * ===============
	 */
	var renderVersionsJSONToHTML = function(jsonTrackerItems, noIssuesMessageCode) {
		var issueListHtml = [];

		function renderTeam(teamName, teamColor) {
			if (!teamColor) {
				teamColor = "#5f5f5f";
			}
			return '<span style="color:' + teamColor + ';">' + teamName + '</span>';
		}

		function renderTeams(teams) {
			var spanElements, html;

			spanElements = [];

			$.each(teams, function(teamName, index) {
				spanElements.push(renderTeam(teamName, teams[teamName]));
			});

			html = spanElements.join(', ');

			return html;
		}

		if(jsonTrackerItems.length > 0) {
			issueListHtml.push("<table class='issuelist'>");

			for(var i = 0; i < jsonTrackerItems.length; i++) {
				var trackerItem = jsonTrackerItems[i];
				var cssClasses = (i % 2) != 0 ? "even" : "odd";
				cssClasses += " " + (trackerItem.resolvedOrClosed ? "resolvedOrClosed" : "open");
				cssClasses += (trackerItem.resolved ? " resolved" : "");
				cssClasses += (trackerItem.closed ? " closed" : "");
				cssClasses += (trackerItem.overdue ? " overdue" : "");
				cssClasses += (trackerItem.overtime ? " overtime" : "");

				if (i ==  jsonTrackerItems.length-1) {
					cssClasses += " last-child";
				}
				var keyTooltip = $.trim(trackerItem.projectKey) != "" ? trackerItem.projectKey + " &rarr; " + trackerItem.keyAndId : "";

				var treeDataAttributes = '';
				if (trackerItem.showBranchIndicator) {
					treeDataAttributes = "\" data-tt-branch=\"true\" data-tt-id=\"" + trackerItem.id;
				} else {
					treeDataAttributes = "\" data-tt-id=\"" + trackerItem.id
				}
				issueListHtml.push("<tr class='" + cssClasses + "' id=\"" + trackerItem.id + treeDataAttributes + "\">");
				issueListHtml.push("<td class='subtext priority fixedWidth'>" + trackerItem.priority + "</td>");
				issueListHtml.push("<td class='subtext issueKey'><span>" + trackerItem.keyAndId + "</span></td>");
				issueListHtml.push("<td class='issueIcon'><img style='background-color:" + trackerItem.iconBgColor + "' src='" + trackerItem.iconUrl + "'></td>");
				issueListHtml.push("<td class='issueName'>" + "<a target='" + codebeamer.userPreferences.newWindowTarget + "' href='" + trackerItem.url + "' title='" + keyTooltip + "'>" + trackerItem.name + "</a></td>");
				// name menu is only applicable in Planner at the moment
				if (trackerItem.overdue) {
					issueListHtml.push("<td class='subtext issueStatusContainer'><span class='issueStatus issueOverdue'>" + trackerItem.overdueLabel + "</span></td>");
				} else {
					issueListHtml.push("<td></td>");
				}
				var testRunHtml = "";
				if (trackerItem.hasOwnProperty("testRunResult") && trackerItem.hasOwnProperty("testRunResultCssClass")) {
					testRunHtml = "<span class='" + trackerItem.testRunResultCssClass + "'>" + trackerItem.testRunResult + "</span>";
				}
				issueListHtml.push("<td class='subtext issueStatusContainer'>" + trackerItem.status + testRunHtml + "</td>");
				// teams list is only applicable in Stats at the moment
				issueListHtml.push("<td class='subtext storyPoints'>" + trackerItem.storyPoints + "</td>");
				issueListHtml.push("<td class='subtext teamNames'>" + renderTeams(trackerItem.teams) + "</td>");
				issueListHtml.push("<td class='subtext issueAssignedTo'>" + trackerItem.assignedTo.join(", ") + "</td>");
				issueListHtml.push("<td class='subtext' style='width:20%'>" + trackerItem.project + " &rarr; " + trackerItem.tracker + "</td>");
				// target release is only applicable in Planner at the moment
				issueListHtml.push("</tr>");
			}
			issueListHtml.push("</table>");
		} else {
			if (noIssuesMessageCode == null) {
				noIssuesMessageCode = "cmdb.version.issues.no.issues";
			}
			issueListHtml.push("<div class='issuelist'></div>");
		}

		return issueListHtml.join("");
	};

	/**
	 * This function is called when user clicks a link in the small release hierarchy tree.
	 * @param versionId Version ID
	 */
	var expandVersion = function(versionId) {
		var version =  $("#" + versionId + ",#backlog_" + versionId);
		while (version && version.length > 0) {
			toggle(version, true);
			version = _findParent(version);
		}
	};

	/**
	 * Build a traversable, hierarchical tree model from the releases, sprints and backlogs.
	 */
	var _getTreeModel = (function() {
		var cached = null;
		var build = function() {
			var root = {
				"id": null,
				"children": []
			};
			var insert = function(nodes, version) {
				var push = function(n, id, isReleased) {
					n.children.push({
						"id": id,
						"isReleased": isReleased,
						"children": []
					});
				};
				var id = version.data("version-id");
				var parentId = version.data("parent-id");
				var isReleased = version.hasClass("released");
				var parentExistsInPage = _doesVersionExistInPage(parentId);
				if (!parentExistsInPage) {
					push(root, id, isReleased);
				} else {
					for (var i = 0; i < nodes.length; i++) {
						var node = nodes[i];
						if (node.id == parentId) {
							push(node, id, isReleased);
							return ;
						} else {
							insert(node.children, version);
						}
					}
				}
			};
			var versions = $("#versionsTable").find(".sprint,.release,.backlog");
			versions.each(function() {
				var version = $(this);
				insert(root.children, version);
			});
			return root;
		};
		return function() {
			if (!cached) {
				cached = build();
			}
			return cached;
		};
	})();

	/**
	 * Find a tree node based on version ID.
	 * @param versionId Version ID
	 * @param [node] Tree node to start search from. Optional, defaults to root node.
	 * @returns Tree node of the specified version ID
	 * @private
	 */
	var _findNode = function(versionId, node) {
		node = node || _getTreeModel();
		if (node.id == versionId) {
			return node;
		}
		for (var i = 0; i < node.children.length; i++) {
			var result = _findNode(versionId, node.children[i]);
			if (result) {
				return result;
			}
		}
		return null;
	};

	/**
	 * Tests if node and all of its children are released.
	 * @param nodeToScan Node to check
	 * @returns {boolean} True if noe and all children are released, otherwise false
	 * @private
	 */
	var _isChildrenHierarchyReleased = function(nodeToScan) {
		if (!nodeToScan.isReleased) {
			return false;
		}
		var result = true;
		for (var i = 0; i < nodeToScan.children.length; i++) {
			var node = nodeToScan.children[i];
			result = result && _isChildrenHierarchyReleased(node);
		}
		return result;
	};

	var findVersionById = function(id) {
		return $("#" + id); // don't use attribute selectors here because they are MUCH slower!
	};

	var _doesVersionExistInPage = function(id) {
		return findVersionById(id).length > 0;
	};

	var _findParent = function(version) {
		var parentId = version.data("parent-id");
		return parentId ? findVersionById(parentId) : null;
	};

	var _getSubTree = function(node) {
		var result = [ node ];
		for (var i = 0; i < node.children.length; i++) {
			var subTree = _getSubTree(node.children[i]);
			result = $.merge(result, subTree);
		}
		return result;
	};

	var showHideAllReleased = function(show) {
		var cb = $("#showReleased");
		var versionsMiniTree = $(".versions-mini-tree");
		if (typeof show == "undefined") {
			show = cb.is(":checked");
		}
		var versionsTable = $("#versionsTable").find(".leftColumn").first();
		var pageUrl = contextPath + "/category/" + _getBrowsedTrackerId() + (show ? "?show_released=1" : "");
		var loaderAnimation = $("<img>", {
			"class": "loading",
			"src": contextPath + "/images/ajax-loading_16.gif"
		});

		var previousTreeNodeStates = getTreeStateAsJson();
		versionsTable.html(loaderAnimation);

		$.ajax({
			url: pageUrl,
			type: "POST",
			data: {
				tree_node_states: previousTreeNodeStates
			},
			success: function(data) {
				var newVersionsTable = $(data).find("#versionsTable .leftColumn").first();
				versionsTable.empty();
				versionsTable.html(newVersionsTable.html());

				versionsMiniTree.find("li.toggle-by-released").toggle(show);
				VersionStats.initTransitionMenu();
				VersionStats.installExecuteTransitionCallback();
			},
			error: function(xhr, textStatus, errorThrown) {
				versionsTable.html("");
				console.error("Error while loading AJAX url " + pageUrl);
				alert("Error: " + textStatus + " - " + errorThrown);
			}
		});
	};

	var _persistRememberTreeState = throttleWrapper(function(state) {
		$.post(contextPath + "/userSetting.spr", {
			"name": "RELEASE_STATS_AUTO_SAVE_TREE_STATE",
			"value": JSON.stringify(state)
		});
	});

	var getRelationUserSettings = function(row) {
		var result = {};
		result.direction = relationUserSettings.direction;
		result.trackerTypes = relationUserSettings.trackerTypes;
		result.parentId = row.data('tt-parent-id');

		return result;
	}

	var initIssueRelationTree = function(root) {
		var $root = $(root);

		$root.find(".issuelist").trackerItemTreeTable({
			columnIndex :  0,
			expandString : sharedSettings.referenceNodeExpandTitle,
			collapseString : sharedSettings.referenceNodeCloseTitle,
			loadByAjax : true,
			ajaxUrl : contextPath + "/trackers/ajax/getTrackerItemRelationsInRelease.spr",
			ajaxMethod: 'POST',
			ajaxMaxDepth: 4,
			ajaxAsync : true,
			ajaxCache : false,
			ajaxItemParamName : "task_id",
			ajaxData : getRelationUserSettings,
			onBeforeExpand: function(row) {
				var $expander = $(row).find(".indenter a").first();

				var progressCursorHandlerId = setTimeout(function() {
					$expander.removeClass("default-state");
					$expander.addClass("progress-state");
					$expander.data("originalImage", $expander.css("background-image"));
					$expander.css("background-image", "url('" + contextPath + "/images/ajax-loading_16.gif')");
				}, 100)

				$expander.data("progressCursorHandlerId", progressCursorHandlerId);
			},
			onExpand: function(row) {
				var $row, level, priorityRowMinWidth, $expander, progressCursorHandlerId;

				$row = $(row);
				level = $row.data("tt-level");
				priorityRowMinWidth = 49 + level * 19;
				$row.find('td.priority').css('min-width', priorityRowMinWidth + 'px');

				$expander = $(row).find(".indenter a").first();
				if ($expander.hasClass("progress-cursor")) {
					// Switch back the progress indicator if it was set.
					setTimeout(function() {
						$expander.removeClass("progress-state");
						$expander.addClass("default-state");
						$expander.css("background-image", $expander.data("originalImage"));
					}, 10);
				} else {
					// Cancel the timer when the ajax request was fast.
					progressCursorHandlerId = $expander.data("progressCursorHandlerId");
					if (progressCursorHandlerId) {
						clearTimeout(progressCursorHandlerId);
					}
				}
			}
		});
	}

	return {
		"init": init,
		"initExpanders": initExpanders,
		"findVersionById": findVersionById,
		"isClosed": isClosed,
		"isOpen": isOpen,
		"expandVersion": expandVersion,
		"toggle": toggle,
		"showHideAllReleased": showHideAllReleased,
		"renderVersionsJSONToHTML": renderVersionsJSONToHTML,
		"getTreeStateAsJson": getTreeStateAsJson
	};

})(jQuery);
