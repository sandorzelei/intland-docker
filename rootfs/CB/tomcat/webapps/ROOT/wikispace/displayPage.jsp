<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%-- if this is true then the tree on the left of the wiki page browser is hidden --%>

<head>
    <%@include file="../decorators/includes/userAgentCSS.jsp" %>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/wikiDisplayPage.less' />" type="text/css" media="all" />
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/treeViewFullTextSearch.less' />" type="text/css" media="all" />
	<script src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>
	<c:if test="${wikiPage.trackerPage}">
		<link type="text/css" rel="stylesheet" href="<ui:urlversioned value="/stylesheet/trackerHomePage.less"/>"/>
		<script type="text/javascript" src="<ui:urlversioned value="/js/trackerHomePage.js" />"></script>
	</c:if>
</head>

<wysiwyg:froalaConfig />

<c:set var="simpleWikiPage" scope="request" value="false" />

<c:set var="treePaneHeightOffset">
    <c:choose>
        <c:when test="${fn:containsIgnoreCase(userAgentClass, 'ie')}">36px</c:when>
        <c:otherwise>30px</c:otherwise>
    </c:choose>
</c:set>
<meta name="decorator" content="main"/>

<c:choose>
	<c:when test="${wikiPage.trackerPage}">
		<meta name="module" content="tracker"/>
		<meta name="moduleCSSClass" content="newskin trackersModule ${not empty pageRevision.baseline ? "tracker-baseline" : ""}"/>
	</c:when>
	<c:otherwise>
		<meta name="module" content="${wikiPage.userPage ? 'mystart' : 'wikispace'}"/>
		<meta name="moduleCSSClass" content="newskin wikiModule ${not empty pageRevision.baseline ? "tracker-baseline" : ""}"/>

		<%-- this flag turns off several things: rating, tagging, notification --%>
		<c:set var="simpleWikiPage" scope="request" value="true" />

		<meta name="applyLayout" content="true"/>
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${not empty errorMessages}">
		<div class="error">
			${ui:sanitizeHtml(errorMessages)}
		</div>
	</c:when>

	<c:when test="${wikiPage.trackerPage}">

		<ui:pageTitle printBody="false">
			<c:out value="${wikiPage.name}"/>
		</ui:pageTitle>

		<ui:actionMenuBar>
			<jsp:attribute name="rightAligned">
				<c:if test="${not empty pageRevision.baseline}">
					<ui:branchBaselineBadge baseline="${pageRevision.baseline}"/>
				</c:if>
			</jsp:attribute>
			<jsp:body>
				<ui:breadcrumbs showProjects="false"/>
			</jsp:body>
		</ui:actionMenuBar>

		<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight trackerHomePage">
			<jsp:attribute name="leftPaneActionBar">
				<a class="scalerButton"></a>
				<div class="filterBoxContainer">
					<ui:treeFilterBox treeId="treePane" />
					<c:if test="${canCreateTracker && empty pageRevision.baseline}">
						<a title="<spring:message code="tracker.create.label"/>" class="createTracker" href="${pageContext.request.contextPath}/proj/tracker/newTracker.spr?proj_id=${wikiPage.project.id}"></a>
					</c:if>
					<span class="trackerHomePageConfiguration" title="<spring:message code="tracker.homepage.configuration.label" text="Tracker Home Page Configuration"/>"></span>
				</div>
			</jsp:attribute>
			<jsp:attribute name="leftContent">
				<div id="treePane" data-projectId="${wikiPage.project.id}" style="height: calc(100% - ${treePaneHeightOffset});overflow:auto;"></div>
			</jsp:attribute>
			<jsp:attribute name="middlePaneActionBar">
				<jsp:include page="includes/trackerPageActionBar.jsp"/>
			</jsp:attribute>
			<jsp:body>
				<ui:globalMessages/>
				<c:if test="${not empty pageRevision.baseline && empty dashboard}">
					<ui:baselineInfoBar projectId="${wikiPage.project.id}" baselineName="${pageRevision.baseline.name}" baselineParamName="revision" />
				</c:if>
				<jsp:include page="/dashboard/dashboardContent.jsp"/>
			</jsp:body>
		</ui:splitTwoColumnLayoutJQuery>

		<acl:isUserInRole var="isUserProjectAdmin" value="project_admin" />
		<c:set var="trackerHomePageUrl" value="${pageContext.request.contextPath}/ajax/getTrackerHomePageTree.spr?proj_id=${wikiPage.project.id}"/>
		<c:if test="${not empty pageRevision.baseline}">
			<c:set var="trackerHomePageUrl" value="${pageContext.request.contextPath}/ajax/getTrackerHomePageTree.spr?proj_id=${wikiPage.project.id}&revision=${pageRevision.baseline.id}"/>
		</c:if>
		<ui:treeControl containerId="treePane" url="${trackerHomePageUrl}"
						layoutContainerId="panes" rightPaneId="rightPane" headerDivId="headerDiv" cookieNameOpenNodes="CB-trackerHomePage-${wikiPage.project.id}"
						editable="${isUserProjectAdmin && empty pageRevision.baseline}" revision="${not empty pageRevision.baseline ? pageRevision.baseline.id : 'null'}"
						layoutCookie="codebeamer-tracker-homepage-layout" skipExpandCollapseInContextMenu="true"
						nodeMovedHandler="codebeamer.TrackerHomePage.moveNodeHandler" checkMoveFnName="codebeamer.TrackerHomePage.checkMoveHandler"
						ajaxContextMenuUrl="/ajax/getTrackerHomePageContextMenu.spr" ajaxContextMenuLiAttr="data-trackerId"/>

		<script type="text/javascript">
			$(document).ready(function() {
				codebeamer.TrackerHomePage.init($("#treePane"), ${isUserProjectAdmin && empty pageRevision.baseline}, null, null, ${not empty pageRevision.baseline ? pageRevision.baseline.id : 'null'});
			});
		</script>

	</c:when>
	<c:otherwise>
		<c:set var="showRating" value="${!simpleWikiPage and (!wikiPage.userPage and empty pageRevision.baseline)}" />
		<div id="mainActionBar">
			<jsp:include page="includes/displayPageActionBar.jsp" >
				<jsp:param name="showActionBar" value="false" />
				<jsp:param name="showRating" value="${showRating}" />
			</jsp:include>
		</div>

        <c:if test="${wikiPage.userPage and empty wikiPage.parent}">
			<%-- sticky text appears on the user's wiki-home, can be configured by sysadmins --%>
			<div class="messagetext">
				<fmt:bundle basename="com.intland.codebeamer.utils.Bundle">
					<fmt:message var="welcomeText" key="welcome.text" />
					<fmt:message var="welcomeTextFormat" key="welcome.format" />
					<tag:transformText value="${welcomeText}" format="${welcomeTextFormat}" />
				</fmt:bundle>
			</div>
		</c:if>

				<c:choose>
					<c:when test="${wikiPage.dashboard }">
						<c:set var="wikiPageRendered">
							<jsp:include page="/dashboard/dashboardContent.jsp"/>
						</c:set>
					</c:when>
					<c:otherwise>
						<c:set var="wikiPageRendered">
							<jsp:include page="includes/wikiPageContent.jsp">
								<jsp:param value="${showRating}" name="showRating"/>
								<jsp:param value="${wikiPage}" name="wikiPage"/>
								<jsp:param value="${pageRevision}" name="pageRevision"/>
								<jsp:param value="${GROUP_OBJECT}" name="GROUP_OBJECT"/>
								<jsp:param value="${simpleWikiPage}" name="simpleWikiPage"/>
								<jsp:param value="${navBarPage}" name="navBarPage"/>
							</jsp:include>
						</c:set>
					</c:otherwise>
				</c:choose>

				<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight">
					<jsp:attribute name="leftPaneActionBar">
						<a class="scalerButton"></a>
						<div class="filterBoxContainer">
							<ui:treeFilterBox treeId="treePane" disableNativeFiltering="true" />
							<spring:message code="tracker.tree.settings.title" text="Settings" var="settingsTitle"/>
							<img class="action" src="<ui:urlversioned value='/images/newskin/actionIcons/settings-s_14.png'/>" title="${settingsTitle}" onclick="showPopupInline('${pageContext.request.contextPath}/wikis/viewTreeConfig.spr', {'width': 600 }); return false;">
						</div>
					</jsp:attribute>
					<jsp:attribute name="leftContent">
						<div id="treePane" style="height: calc(100% - ${treePaneHeightOffset});overflow:auto;"></div>
					</jsp:attribute>
					<jsp:attribute name="middlePaneActionBar">
						<c:choose>
							<c:when test="${wikiPage.dashboard }">
								<jsp:include page="/dashboard/dashboardActionBar.jsp" />
							</c:when>
							<c:otherwise>
								<jsp:include page="includes/wikiPageHeader.jsp" />
							</c:otherwise>
						</c:choose>
					</jsp:attribute>
					<jsp:body>
						<ui:globalMessages/>
						${wikiPageRendered}
						<script type="text/javascript">
							codebeamer.loadedWikiPage = "${groupTypeId}-${wikiPage.id}";
							if( "${param.revision}" ) {
								codebeamer.loadedWikiPage = codebeamer.loadedWikiPage + "/" + "${param.revision}";
							}
						</script>
					</jsp:body>
				</ui:splitTwoColumnLayoutJQuery>

				<c:set var="browsingHistory" value="${! empty param.revision}" />

				<script type="text/javascript">
				function hasPushStateFeature() {
					return typeof window.history.pushState !== "undefined";
				}

				function getSelectedWikiId() {
					var id = "${wikiPage.id}";
					var hash = window.location.hash;
					if (hasPushStateFeature() || hash.indexOf("#wiki/") < 0) {
						return id;
					}

					var wikiId = getWikiIdFromHash();
					return wikiId ? wikiId : id;
				}

				function getWikiVersionId(node) {
					var parts = node.id.split("-");
					if (parts[1] != "${wikiPage.id}") {
						return null;
					}

					return "${param.version}";
				}

				function getWikiIdFromHash(hash){
					if (!hash){
						hash =  window.location.hash;
					}

					var wikiHash = hash.replace("#wiki/", "");
					var docId = wikiHash.substring(0, wikiHash.indexOf("?"));

					if ($.isNumeric(docId)){
						return docId;
					}
					return null;
				}

				var browsingHistory = ${browsingHistory};
				var canEdit = ${canEdit};
				$(document).ready(function() {

					<c:if test="${sectionNumberingEnabled}">codebeamer.sectionNumberHierarchyEnabled = true;</c:if>

					var treePane = $("#treePane");
					treePane.bind("rename_node.jstree", function (event, data) {
						var oldName, newName, nodeId;

						oldName = data.old;
						newName = data.text;
						nodeId = data.node.id;

						$.ajax({
							"url": contextPath + "/ajax/wikis/renamePage.spr",
							"type": "POST",
							"data": {
								"nodeId": data.node.id,
								"newName": data.text
							},
							"success": function(data) {
								if (data.hasOwnProperty("success") && data.success === false) {
									$("#treePane").jstree("set_text", "#" + nodeId, oldName)
									showOverlayMessage(i18n.message("wiki.rename.error", oldName, newName), 3, true);

								} else {
									location.reload();
								}
							}
						});
					});

					treePane.bind("state_ready.jstree", function () {
						var tree = $.jstree.reference("#treePane");
						var revision = "${param.revision}";

						// open the root node if it is closed
						if ($("#treePane .jstree-open").size() == 0) {
							var root = $("#treePane .jstree-node:first")
							tree.open_node(root);
						}

						// scroll to the selected node if it's not visible
						var nodeId = "${groupTypeId}-" + getSelectedWikiId() + (revision ? "/" + revision : "");
						var $selected = $("[id='" + nodeId + "']");
						if ($selected.length == 0) {
							// open the node
							var treeNode = tree.get_node(nodeId);
							var parents = treeNode.parents;

							if (parents) {
								for (var i = 0; i < parents.length; i++) {
									var parentId = parents[i];
									if (parentId != "#") {
										tree.open_node(parentId);
									}
								}
								$selected = $("[id='" + nodeId + "']");
							}
						}
						if ($selected.length > 0) {
							tree.select_node($selected);

							var $container = $("#treePane");
							$container.animate({"scrollTop": $selected.offset().top - $container.offset().top + $container.scrollTop()}, 0);
						}

					});

					codebeamer.initializeInlineSectionEditing("${wikiPage.id}", !browsingHistory && canEdit);

					if (!hasPushStateFeature()) {
						treePane.bind('loaded.jstree', function(e, data) {
							if (window.location.hash.length > 1) {

								var hash = window.location.hash;
								if (hash.indexOf("#wiki/") < 0) {
									return;
								}

								var docId = getWikiIdFromHash();
								var $node = $("#treePane #${groupTypeId}-" + docId);

								if ($node.size() > 0) {
									if ($.isNumeric(docId)) {
										var tree = $.jstree._focused();
										var wikiPageTitle = $($node.find("a").get(0)).text();
										//tree.deselect_all();
										//tree.select_node($node);
										loadWikiPageToRight(docId, null, wikiPageTitle, true);
										document.title = wikiPageTitle;
									}
								}
							}
						});
					}

					initTreeViewSearch(treePane, "wiki", "${wikiPage.project.id}");
				});
				var populateTree = function (node) {
					return {
						"project_id": "${wikiPage.project.id}",
						"nodeId": node.id == '#' ? null : node.id
					};
				};

				// current wikipage's id and revision
				var wikiPageId = ${wikiPage.id};
				var wikiPageRevision = null;
			    <c:if test="${! empty param.revision}">wikiPageRevision = ${param.revision};</c:if>

				function onNodeClicked(node, data) {
					if (codebeamer.loadedWikiPage == node.id) {
						return;
					}
					var docId = node.id;
					docId = docId.split("-")[1];

					var revision = null; // the baseline id
					if (docId.indexOf("/") >= 0) {
						var s = docId.split("/");
						docId = s[0];
						revision = s[1];
					}

					var version = getWikiVersionId(node); // the wiki version id

					var wikiPageTitle = node.text;
					loadWikiPageToRight(docId, revision || version, wikiPageTitle);
					if (hasPushStateFeature()) {
						// change the url in the address bar & title, so it is always in sync with the currently shown wiki page
						var wikiPageUrl = contextPath + "/wiki/" + docId + (revision ? "?revision=" + revision : "") + (version ? "?version=" + version : "");
						History.pushState({wikiId: docId}, wikiPageTitle, wikiPageUrl);
					} else {
						// for old browsers
						History.pushState({wikiId: docId}, wikiPageTitle, "wiki/" + docId + (revision ? "?revision=" + revision : ""));
					}

					codebeamer.loadedWikiPage = node.id;
				}

				function reloadWikiPageDisplayed() {
					// save the scroll position of the center div, so we can restore it later
					var $scrolled = $("#centerDiv");
					var oldScrollTop = $scrolled.scrollTop();
					// scroll back to the original location when the page is loaded and section editing is initialized, because that changes the page content
					$("body").bind("sectionEditingInitialized", function(event) {
						$scrolled.scrollTop(oldScrollTop); // scroll back to where we were...
						// unbind to avoid execution several times
						$(this).unbind(event);
					});
					loadWikiPageToRight(wikiPageId, wikiPageRevision, null);
				}

				function showLoadingIndicatorInRightPane() {
					var rightPane, busySignHTML, d;

					rightPane = $("#rightPane");

					// showing the ajax loading indicator
					busySignHTML = ajaxBusyIndicator.getBusysignHTML('', false);
					d = $("<div>").attr("style", "text-align:center;width:100%;");
					d.append(busySignHTML);
					rightPane.empty();
					rightPane.prepend(d);

					return d;
				}

				function loadWikiPageToRight(docId, revision, wikiPageTitle, forceKeepGlobalMessages) {
					wikiPageId = docId;
					wikiPageRevision = revision;

					var rightPane = $("#rightPane");
					var currentWikiPageId = rightPane.find("#wikiPageContent").data("wiki-page-id");
					var samePageIsBeingReloaded = docId == currentWikiPageId;

					// unlocking current wiki if editor is active
					if (rightPane.find(".wikiSectionEditor.edited").length > 0){
						$.ajax({
						    url: contextPath + '/ajax/wiki/releaseLock.spr?wikiId=' + currentWikiPageId,
						    type: 'GET'
						});
					}
					// destroy open editor instances (and remove editor toolbar)
					rightPane.find('.editor-wrapper textarea').each(function() {
						var editorId = $(this).attr('id');

						if (editorId) {
							var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);

							editor && editor.destroy();
						}
					});

					var data = {"doc_id": docId};
					var editable = true;
					if ((typeof revision) !== "undefined" && revision !== null) {
						data["revision"] = revision;
						editable = false;
					}

					var saveGlobalMessages = function() {
						if (forceKeepGlobalMessages || samePageIsBeingReloaded) {
							var globalMessages = $("#globalMessages");
							if (globalMessages.length > 0) {
								return globalMessages.detach();
							}
						}
						return null;
					};

					var restoreGlobalMessages = function(messages) {
						if (messages) {
							messages.prependTo(rightPane);
						}
					};

					var messages = saveGlobalMessages();

					var loadingIndicator = showLoadingIndicatorInRightPane();

					$.waypoints("destroy");
					if (window.hasOwnProperty("dashboardMonitorProcessId")) {
						window.clearInterval(window.dashboardMonitorProcessId);
					}

					$.ajax({
							"type": "GET",
							"url": contextPath + "/ajax/wiki/getWikiContentAsHtml.spr",
							"data": data,
							"success": function (data) {
								// handle out-of-ordes responses (issue 675870)
								if (wikiPageId != data.docId) {
									return;
								}
								var editable = data.editable;
								var container = rightPane;
								try {
									if (data.isDashboard) {
										container.prepend(data.content);
									} else {
										container.html(data.content);
									}
								} catch (e) {}
								try {
									$("#mainActionBar").html(data.actionBar);
								} catch(e) {}

								var layout = $("#panes").layout();
								codebeamer.addOpenerButton(layout);

								restoreGlobalMessages(messages);

								// trigger a custom event indicating that the rightPane reloaded
								container.trigger("wikiContentChanged", [docId, revision, wikiPageTitle]);

								container.find(".yuimenubar,.inlinemenuTrigger").each(function() {
									initPopupMenu($(this).attr("id"), {});
								});

								if (data.isDashboard) {
									var config = {
											dashboardId: data.docId,
											projectId: data.projectId,
											$container: $("#dashboard"),
											editable: data.editable,
											eventHandlerContext: "#rightPane",
											showBusyPage: false
									};

									if ("${param.revision}" != "") {
										config['revision'] = "${param.revision}";
									}

									$("#dashboard").one("dashboard:loading:finished", function() {
										if (loadingIndicator) {
											loadingIndicator.remove();
										}
									});

									codebeamer.dashboard.init(config);
								} else {
									codebeamer.initializeInlineSectionEditing(docId, editable);
									initializeJSPWikiScripts();
									loadingIndicator = null;

									alignElementsToViewportEdge.init(".editsection", "centerDiv");
								}

								var freshActionBar = $(".freshWikiActionBarContents");
								if (freshActionBar.length > 0) {
									freshActionBar = freshActionBar.detach();
									var menuBar = $("#rightPane").parent().find(".actionBar");
									menuBar.empty();
									freshActionBar.appendTo(menuBar).contents().unwrap();
									var layout = $("#panes").layout();
									codebeamer.addOpenerButton(layout);

									if (data.isDashboard) {
										menuBar.addClass("dashboard-actionbar");
									} else {
										menuBar.removeClass("dashboard-actionbar");
									}
									container.trigger('wikiActionBarChanged');
								}
							}
					});
				}

				// see: http://www.jstree.com/documentation/core.html#move_node
				function wikiNodeMoved (nodesMoved, newParent, position, targetNode) {
					// collect the ids of nodes moved
					var nodesMovedIds = [];
					for (var i = 0; i < nodesMoved.length; i++) {
						nodesMovedIds.push(nodesMoved[i].id);
					}

					// collect the ids of the siblings where the node(s) are moved to.
					// used for storing the order/ordinals of the wiki nodes
					var $tree = $.jstree.reference("#" + this.treeContainerId);
					var $parent = $tree.get_parent(nodesMoved[0] );

					var $siblings = $tree.get_children_dom($parent);
					var siblingIds = [];
					for (var j = 0; j < $siblings.length; j++) {
						var sibling = $($siblings[j]);
						var id = sibling.attr("id");

						var moved = false;
						for (var k = 0; k < nodesMoved.length; k++) {
							if (nodesMoved[k].id == id) {
								moved = true;
								break;
							}
						}

						if (!moved) {
							siblingIds.push(sibling.data("id"));
						}
					}
					// console.log("sibling ids of moved node:" + siblingIds.join(","));

					$.ajax({
						"url": contextPath + "/ajax/wikis/movePage.spr",
						"type": "POST",
						"data": {
							"newParentId": newParent == null ? null : newParent.id,
							"nodesMoved": nodesMovedIds.join(","),
							"siblingIds": siblingIds.join(",")
						},
						success: function(data) {
							if (data.success == false || data.oneOfTheParentsChanged) {
								location.reload();
							} else {
								// console.log("No need to reload, because parent of the wiki page is not changed, just reordering on the same level...");
								// redo the search to repaint the broken lines of the tree when filtered and drag-dropped
								$tree.refresh();
								codebeamer.trees.Tree.redoSearch($tree);
							}
						},
						failure: function(data) {
							location.reload();
						}
					});
				}

				function checkMove (np, o, op) {
					return true; // allow any moves, including reordering and changing parents
				}

				function confirmActionWithRecursiveOption(node, msg, confirmCallback) {
					var dirName = $.trim($(node).children("a").text());
					msg = i18n.message(msg, dirName)
							+ "<br/><label style='font-weight:normal; font-size: 12px; margin-top: 5px;' >"
							+ "<input type='checkbox' checked='checked' style='vertical-align:text-bottom;'>"+ i18n.message("document.remember.order.recursively.option")
							+ "</input></label>";
					showFancyConfirmDialogWithCallbacks(msg,
								function() {
									var recursive = $(this.body).find("input[type='checkbox']").is(':checked');
									confirmCallback(node, recursive);
								}
							);
				}

				function rememberOrForgetOrder(node, recursive, remember) {
					$.ajax({
						"url": contextPath + "/ajax/wikis/rememberOrForgetOrder.spr",
						"type": "POST",
						"data": {
							"nodeId": node.id,
							"recursive": recursive,
							"remember": remember
						},
						success: function(data) {
							location.reload();
						},
						failure: function(data) {
							location.reload();
						}
					});
				}

				function rememberOrder(node) {
					confirmActionWithRecursiveOption(node, "document.remember.order.confirm.question",
							function(node, recursive) {
								rememberOrForgetOrder(node, recursive, true);
							}
					);
				}
				function orderByName(node) {
					confirmActionWithRecursiveOption(node, "document.order.by.name.confirm.question",
							function(node, recursive) {
								rememberOrForgetOrder(node, recursive, false);
							}
					);
				}

				function populateContextMenu (node) {
					var canEdit = ${canEdit};
					if (browsingHistory || !canEdit) {
						return {};
					}

					var menu = {
						"rename": { "label": i18n.message("document.rename.label"), "action": function() {renameWikiPage(node);}}
					};

					// only add these menus to folders
					var $domNode = $("li#" + node.id);
					var leaf = $domNode.hasClass("jstree-leaf");
					if (!leaf) {
						$.extend(menu, {
							"rememberOrder" : {"label": i18n.message("document.remember.order.action"), "action": function() {rememberOrder(node);}},
							"orderByName" : {"label": i18n.message("document.order.by.name.action"), "action": function() { orderByName(node);}}
						});
					}

					return menu;
				}

				function renameWikiPage (node) {
					var tree = $.jstree.reference("treePane");
					tree.edit(node);
				}

				function clickOnTreeItem(wikiDocumentId){
					var wikiTreeLink = $( "#${groupTypeId}-" + wikiDocumentId + " a" ).first();

			        if (!wikiTreeLink.hasClass( "jstree-clicked" )){
			      	  	wikiTreeLink.click();
			        }
				}

				/**
				* filters the jstree state so that the selected nodes are not restored
				*/
				function filterRestoreState(state) {
					// remove the selection info from the state because the actiual node always  will be selected
					state.core.selected = [];
					return state;
				}

				History.Adapter.bind(window, 'statechange', function(){
					var state = History.getState();
			        var wikiDocumentId = state.data['wikiId'];
			        clickOnTreeItem(wikiDocumentId);
			    });

				</script>

				<c:url var="treeUrl" value="/ajax/wikis/tree.spr">
					<c:param name="revision" value="${param.revision}"/>
				</c:url>

				<script type="text/javascript" src="<ui:urlversioned value='/js/treeViewFullTextSearch.js'/>"></script>

				<ui:treeControl containerId="treePane" url="${treeUrl}" populateFnName="populateTree"
						layoutContainerId="panes" rightPaneId="rightPane" editable="${! browsingHistory}" headerDivId="headerDiv"
						nodeClickedHandler="onNodeClicked" nodeMovedHandler="wikiNodeMoved"
						checkMoveFnName="checkMove" populateContextMenuFnName="populateContextMenu"
						layoutCookie="codebeamer-wiki-layout" searchConfig="codebeamer.fullTextSearch.searchConfig"
						config="{stateConfig: {filter: filterRestoreState}}" />
	</c:otherwise>
</c:choose>

<c:if test="${wikiPage.dashboard }">
	<script type="text/javascript">
		$(document).ready(function () {
			$("#middleHeaderDiv").addClass("dashboard-actionbar");
		});
	</script>
</c:if>

<wysiwyg:editorInline />