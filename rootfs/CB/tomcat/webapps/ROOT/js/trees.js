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
 */
var codebeamer = codebeamer || {};
codebeamer.trees = codebeamer.trees || {};
(function () {
	"use strict";

	/**
	 * The constructor of Tree, that initializes the tree based on the config object. The config must contain
	 * these attributes
	 * <ul>
	 * <li>treeContainerId: the id of the div where the tree will be rendered</li>
	 * <li>url: the url used to populate the tree</li>
	 * <li>data: the data sent to the server when populating the tree. Can be a function or an object</li>
	 * <li>contextPath</li>
	 * <li>settingsUrl</li>
	 * </ul>
	 * Optional attributes:
	 * <ul>
	 * <li>clicked: a function that will be invoked after a node was clicked</li>
	 * <li>selected: a callback function will be called after a node was selected.
	 * 			This can be either a select by the tree itself when initializing and restoring the previous selection or a user-click.
	 * 			If you want only the users' clicks then use the clicked event!
	 * </li>
	 *
	 * <li>created: a function that will be called when a node was created</li>
	 * <li>moved: a function that will be called when a node moved</li>
	 * <li>renamed: a function that will be called when a node was renamed</li>
	 * <li>contextmenu: a function or a json array that will be used to create the context menu for the nodes</li>
	 * <li>notificationsDivId: the id of the div where the notifications can be printed</li>
	 * <li>chackMove: a function that will be called when you hover a node while dragging</li>
	 * <li>editable: if set to false, dnd and renaming is disabled</li>
	 * </ul>
	 * @param config
	 */
	codebeamer.trees.Tree = function (config) {
		this.config = config;
	};

	codebeamer.trees.Tree.prototype = {
		init: function () {
			var self = this;

			$(document).ready(function () {

			$(function () {
				var $tree = $("#" + self.config.treeContainerId);

				var plugins = ["json_data", // building the tree from json data
								"ui",
								"crrm", // for handling copy, rename, remove, move events
								"search"
						];

				if (!self.config.disableCookies) {
					plugins.push("state");
				}

				if (self.config.editable !== false && !self.config.dndDisabled) {
					plugins.push("dnd");
				}
				if (self.config.disableContextMenu !== true) {
					plugins.push("contextmenu");
				}
				if (self.config.useCheckboxPlugin === true) {
					plugins.push("checkbox");
				}

				// jstree started to use the ctrl + enter combination to clear the currently selected node using hotkeys.
				// Although our own hotkey handler is called, it won't function properly without a selected node in the tree.
				// This event handler catches the ctrl + enter combination and prevents jstree to deselect the currently active node.
				// It also triggers the same event on the document, so the our own hotkey handler can run properly.
				$tree.on('keydown.jstree', '.jstree-anchor', function(e) {
					switch(e.which) {
						case 13: // enter
							if(e.ctrlKey) {
								$(document).trigger($.Event(e.type, e));
								e.stopPropagation();
								e.preventDefault();
								return false;
							}
							break;
						case 113: // F2
							var tree = $.jstree.reference(self.config.treeContainerId);
							var node = tree.get_node($(this).attr("id"));
							var doc = new DOMParser().parseFromString(node.text, "text/html");
							tree.edit(node, doc.documentElement.textContent);
					}
				});

				var searchConfig = $.extend({
							"case_insensitive": true,
							"show_only_matches": true
						}, self.config.searchConfig);

				var treeConfig = {
					"plugins": plugins,
					"core": {
						"check_callback" : function (operation, node, parent, position, more) {
							if(operation === "copy_node" || operation === "move_node") {
								if (more.ref) { // this case is called during moving the node
									if (self.config.checkMove) {
										var oldParent = more.ref ? more.origin.get_node(node.parent) : null;
										var isCopy = $.jstree.reference(node) != $.jstree.reference(parent);
										var isOk = self.config.checkMove(parent, node, oldParent, more.origin, isCopy);
										return isOk;
									}
								} else { // this case is called when the node was dropped somewhere
									// in this case we can return true because the node was already checked
									return true;
								}

							}
						},
						"animation": 0, // turns animations off
						"strings": {
							"loading": i18n.message("ajax.loading")
						},
						"data" : {
							"url": self.config.url,
							"data": self.config.data,
							"success": function(data) {
								// only for IE and https fix the relative icon urls, and convert them to absolute
								if ($("body").hasClass('IE') && location.protocol === 'https:') {
									self.fixHttpsIconUrls(data);
								}
								return data;
							},
							"error": function (data, result) {
								if (result == "error") {
									showOverlayMessageWithOptions(i18n.message("tracker.view.layout.document.tree.loading.error.message"), {error: true});
								}
							}
						}
					},
					"dnd": {
							"drop": function (data) {
								if (self.config.externalDrop) {
									self.config.externalDrop(data.o, data.r, data.e /* event */);
								}
							},
							"dnd_move": function (data) {
								// Disable release tree drag
								if (data.hasOwnProperty("element") && $(data.element).closest("div.jstree").is("#releaseTreePane")) {
									return false;
								}
								$tree.trigger("drop_check", data);
								if (self.config.externalDropCheck) {
									return self.config.externalDropCheck(data.data.node, data.event.target, data.event /* event */, self.config);
								}
								return true;
							},
							// disabled dnd on touch devices
							'touch': false,
							"always_copy": true
						},
					"search": searchConfig
				};

				if (self.config.stateConfig) {
					treeConfig["state"] = self.config.stateConfig;
				}

				if (self.config.hasOwnProperty("cookieNameOpenNodes") && self.config.cookieNameOpenNodes && self.config.cookieNameOpenNodes.length > 0) {
					if (treeConfig.hasOwnProperty("state")) {
						treeConfig["state"]["key"] = self.config.cookieNameOpenNodes;
					} else {
						treeConfig["state"] = {
							key: self.config.cookieNameOpenNodes
						}
					}
				}

				if (self.config.useCheckboxPlugin === true) {
					treeConfig.checkbox = {
						"real_checkboxes": true,
						"three_state": false
					};

					if (self.config.restrictCheckboxCascade === true) {
						treeConfig.checkbox = {
							"cascade": "down",
							"three_state": false
						}
					};

					if (self.config.checkboxName) {
						treeConfig.checkbox.real_checkboxes_names = function(n) {
							return [self.config.checkboxName, n.li_attr["id"]];
						};
					}

					if (self.config.checkbox) {
						$.extend(treeConfig.checkbox, self.config.checkbox);
					}

					var getLiNodes = function (data) {
						var nodes = null;
						var $ref = $.jstree.reference(self.config.treeContainerId);
						if (data.node) {
							var node = data.node;
							nodes = $('li#' + node.id);
						} else {
							nodes = $(data.rslt.obj).find("li");
						}

						return nodes;
					};

					$("#" + self.config.treeContainerId).bind("check_node.jstree", function(e, data){
						var nodes = getLiNodes(data);
						$.jstree.reference(self.config.treeContainerId).select_node(nodes);
					});
					$("#" + self.config.treeContainerId).bind("uncheck_node.jstree", function(e, data){
						var nodes = getLiNodes(data);
						$.jstree.reference(self.config.treeContainerId).deselect_node(nodes);
					});
					$("#" + self.config.treeContainerId).bind("loaded.jstree", function() {
						var $treePane = $("#" + self.config.treeContainerId);
						var $root = $tree.find("li").first();
						$.jstree.reference($treePane).check_node($root);
					});
				}

				$("#" + self.config.treeContainerId).bind("set_state.jstree", function() {
					var $treePane = $("#" + self.config.treeContainerId);
					$treePane.trigger("loaded.codebeamer.jstree");
					$treePane.unbind("loaded.codebeamer.jstree");
				});

				var openAction = function(id, revision, versionParameterName, useSameTab) {
					versionParameterName = versionParameterName || "revision";
					var version = revision || self.config.revision;
					var url = self.config.contextPath + "/issue/" + id + (version ? "?" + versionParameterName + "=" + version : "");

					if (self.config.openExtraParameters) {
						var sep = url.indexOf('?') >= 0 ? '&' : '?';
						url = url + sep + self.config.openExtraParameters;
					}
					window.open(url, useSameTab ? '_top' : '_blank');
				};

				// initialize the context menu
				var handler = function(node) {
					var cm = {};

					var tree = $.jstree.reference(node);
					var selectedNodes = tree.get_selected();
					if (selectedNodes && selectedNodes.length > 1) {
						// if there are more than one selected node don't add the items to the menu
						$.extend(cm, self.config.contextmenu.items(node));
						return cm;
					}

					if (node.li_attr["type"] == "tracker_item" || node.li_attr["type"] == "folder") {
						var version = node.li_attr["version"] || node.li_attr["revision"];
						var versionParameterName = node.li_attr["version"] ? "version" : "revision";
						
						cm['open'] = {
							"label": i18n.message("tracker.view.layout.document.open.label"),
							"action": function() {
								openAction(node.id, version, versionParameterName, true);
							}
						};
						cm['openInNewTab'] = {
							"label": i18n.message("tracker.view.layout.document.open.in.new.tab"),
							"action": function() {
								openAction(node.id, version, versionParameterName);
							},
							"separator_after": true
						};
					}

					var skipExpandCollapse = self.config.hasOwnProperty("skipExpandCollapseInContextMenu") && self.config.skipExpandCollapseInContextMenu;
					if (!skipExpandCollapse) {
						var topLevelNode = $(node.original).parent().parent().attr("id") == self.config.treeContainerId;
						if (!topLevelNode && !$(node.original).hasClass("jstree-leaf")) {
							cm["collapseNode"] = {
								"label": i18n.message("tree.collapsenode"),
								"action": function () {
									$.jstree.reference(node).close_all(node);
								}
							};
							cm["expandNode"] = {
								"label": i18n.message("tree.expandnode"),
								"action": function () {
									$.jstree.reference(self.config.treeContainerId).open_all(node);
								},
								"separator_after": typeof self.config.contextmenu != "undefined"
							};
						} else if (!node.hasClass("jstree-leaf")) {
							if (!node.hasClass("jstree-closed")) {
								cm["collapseNode"] = {
									"label": i18n.message("tree.collapsenode"),
									"action": function (obj) {
										$.jstree.reference(self.config.treeContainerId).close_all(node);
									}
								};
							} else {
								// opens only the first two levels of the tree
								cm["expandNode"] = {
									"label": i18n.message("tree.expandnode"),
									"action": function (obj) {
										self.openTwoLevels(node);
									},
									"separator_after": true
								};
							}
						}
					}

					if (!self.config.onlyTopLevel) {
						if (self.config.contextmenu) {
							var i = self.config.contextmenu.items(node);
							if (!skipExpandCollapse && $.isEmptyObject(i)) {
								delete (cm["expandNode"])["separator_after"];
							} else {
								for (var m in i) {
									cm[m] = i[m];
								}
							}
						}
					}

					return cm;
				};


				// add the default menu items (expand node/collapse node) to the menu)
				treeConfig.contextmenu = {
						"items": handler,
						"show_at_node": false,
						"select_node": false // prevents node selection on right click (issue 703366)
				};
				if (self.config.disableMultipleSelection) {
					treeConfig.ui = {"select_limit": 1};
				}

				// allow additional overrides in the treeConfig object
				if (self.config.treeConfig) {
					treeConfig = $.extend(true /* =deep merging the config trees */, treeConfig, self.config.treeConfig);
				}

				var jt = $tree.jstree(treeConfig);
				self.jstree = jt;

				if (self.config.ajaxContextMenuUrl) {
					$tree.bind("show_contextmenu.jstree", function(event, obj) {
						var node = obj.node;
						var instance = obj.instance;
						// Load back menu if once loaded
						if (node.hasOwnProperty("ajaxContextMenuItems")) {
							if (codebeamer.contextMenuShown) {
								codebeamer.contextMenuShown = false;
								return;
							}

							if(instance.settings.contextmenu.items != node.ajaxContextMenuItems){
								instance.settings.contextmenu.items = node.ajaxContextMenuItems;
							}

							if (node.hasOwnProperty("ajaxContextMenuPosition")) {
								$(".vakata-context.jstree-contextmenu").css("left", node.ajaxContextMenuPosition.x);
								$(".vakata-context.jstree-contextmenu").css("top", node.ajaxContextMenuPosition.y);
								delete node.ajaxContextMenuPosition;
							}

							codebeamer.contextMenuShown = true;
							$(".vakata-context.jstree-contextmenu").show();
							$tree.jstree("show_contextmenu", node);
						} else {
							// Load via AJAX if the context menu is not present for the node
							$(".vakata-context.jstree-contextmenu").hide();
							instance.settings.contextmenu.items = {};
							var data = {
								"node_id" : node.id
							};
							if (self.config.ajaxContextMenuLiAttr != null && self.config.ajaxContextMenuLiAttr != "null") {
								data["id"] = node.li_attr[self.config.ajaxContextMenuLiAttr];
							}
							if (self.config.revision != null && self.config.revision != "null") {
								data["revision"] = self.config.revision;
							}
							$.ajax({
								url: contextPath + self.config.ajaxContextMenuUrl,
								type: "GET",
								dataType: "json",
								data: data
							}).done(function(result) {
								var menu = {};
								for (var itemKey in result) {
									var item = result[itemKey];
									menu[itemKey] = {
										"label" : item.label,
										"action" : new Function("node", item.action)
									};
									if (item.separator_before == "true") {
										menu[itemKey]["separator_before"] = true;
									}
								}
								instance.settings.contextmenu.items = menu;
								node["ajaxContextMenuItems"] = menu;
								node["ajaxContextMenuPosition"] = {x : obj.x, y: obj.y};
								$(".vakata-context.jstree-contextmenu").show();
								$tree.jstree("show_contextmenu", node);
							});
						}
					});
				}

				var treeColorInitializer = function (data) {
					// initialize icon background colors
					initializeTreeIconColors($tree);
				};
				// fire the custom event after the tree is initialized
				var fireTreeInitialized = function(event, data) {
					$tree.trigger("treeInitialized", data);
				};

				var collectDraggedNodes = function (data) {
					var nodes = [];
					var tree = $.jstree.reference(data.element);

					if (tree) {
						for (var i = 0; i < data.data.nodes.length; i++) {
							nodes.push(tree.get_node(data.data.nodes[i]));
						}
					}

					return nodes;
				};

				// the external drop check is now only possible by listening to specific events
				$(document)
				.on('dnd_move.vakata', function (event, data) {

					// Disable release tree drag
					if (data.hasOwnProperty("element") && $(data.element).closest("div.jstree").is("#releaseTreePane")) {
						return false;
					}

					$("body").addClass("drag");
					$tree.trigger("drop_check", data);

					var nodes = collectDraggedNodes(data);

					// to decide if the item under cursor is a valid drop target call the externaldropcheck function (if available)
					var dropPossible = true;
					if (self.config.externalDropCheck) {
						dropPossible =  self.config.externalDropCheck(nodes, $(data.event.target), data.event /* event */, self.config);
					}

					if (self.config.updateDropIcon) {
						// update the icons on the helper object to reflect if the drop is possible to that location
						var $icon = data.helper.find('.jstree-icon');
						$icon.toggleClass('jstree-ok', dropPossible).toggleClass('jstree-er', !dropPossible);
					}
				})
				.on('dnd_stop.vakata', function (event, data) {
					// check if this is an external drop; if no do nothing
					var target = $(data.event.target);
					if (target.is(".jstree-anchor")) {
						return;
					}

					$("body").removeClass("drag");
					if (self.config.externalDrop) {
						var dropPossible = true;

						var nodes = collectDraggedNodes(data);

						if (self.config.externalDropCheck) {
							dropPossible = self.config.externalDropCheck(nodes, $(data.event.target), data.event /* event */, self.config);
						}

						if (dropPossible) {
							self.config.externalDrop(nodes, $(data.event.target), data.event /* event */);
						}
					}
				});

				var bindDblClickEvent = function() {
					$tree.off('dblclick');
					$tree.on('dblclick', function(event) {
						var $target = $(event.target);
						if (!$target.is(".jstree-rename-input")
								&& !$target.is('.jstree-icon.jstree-ocl')) { // do not allow double clicking on the +/- opener buttons
							var node = $(event.target).closest("li");
							if (node.attr("type") == "tracker_item" && node.attr("id") != "0") {
								var version = node.attr("version") || node.attr("revision");
								var versionParameterName = node.attr("version") ? "version" : "revision";
								openAction(node.attr("id"), version, versionParameterName);
							} else if (node.attr("data-trackerUrl")) {
								var revision = self.config.version && self.config.version !== "null" ? self.config.version : null;
								window.location.href = contextPath + node.attr("data-trackerUrl") + (revision ? "?revision=" + revision : "");
							}
						}
					});
				};

				// bind the rename event to the nodes
				$tree.bind("loaded.jstree", function (event, data) {
//					if (codebeamer.resizeHandler) {
//						codebeamer.resizeHandler();
//					}
					treeColorInitializer(data);

					setTimeout(function () {
						fireTreeInitialized(event, data);
						bindDblClickEvent();
					}, 1000);

				});

				$tree.bind("reopen.jstree", function (event, data) {
					// if there are no open nodes in the tree then open the first two levels by default
					var idSelector = "#" + self.config.treeContainerId;
					var $rootNode = $(idSelector + " > ul > li");
					var $tree = $(idSelector);
					if (!$tree.jstree("is_open", $rootNode)) {
						self.openTwoLevels();
					}
				});

				$tree.bind("search.jstree clear_search.jstree", function (event, node) {
					//bindDblClickEvent();
					initializeTreeIconColors($tree);
				});

				$tree.bind("after_open.jstree", function (event, data) {
					throttle(function () {
						bindDblClickEvent();
						initializeTreeIconColors($tree);
					});
				})

				$tree.bind("refresh.jstree", function (event, data) {
					bindDblClickEvent();
					treeColorInitializer(data);
					fireTreeInitialized(event, data);
				});

				$tree.jstree("set_theme", "default");
				$tree.bind("select_node.jstree", function (event, data) {
						var throttledSelects = function() {
							var node = data.node;

							if (self.config.clicked) {
								// check if this is really caused by an user-click ?
								//if (data.args != null && data.args.length >=2) {
									// the data.args[2] contains the original event. This is only present when the user clicks on the node
									// var originalEvent = data.args[2];
									if (self.config.eventHandlerScope) {
										self.config.clicked.apply(self.config.eventHandlerScope, [node, data]);
									} else {
										self.config.clicked(node, data);
									}
								//}
							}
						};
						// throttle the selects to avoid event storm
						throttle(throttledSelects, this, this, 200);
					});
					$tree.bind("create_node.jstree", function(event, data) {
						if(self.config.created) {
							if (self.config.eventHandlerScope) {
								self.config.created.apply(self.config.eventHandlerScope, [event, data]);
							} else {
								self.config.created(event, data);
							}
						}
					});

					var nodeCopyMoveHandler = function (event, data, nodes, isCopy) {
						var node = data.old_instance.get_node(data.original);
						$.jstree.reference(node).deselect_all();

						var newParent = data.new_instance.get_node(data.parent);
						var position = data.position;

						/*
						 * we need to adjust the position value because:
						 * when collecting the nodes using debounce data.position contains the position of the last moved node.
						 * but we need the position of the first moved node and that we can get using this formula.
						 */
						position = position - nodes.length + 1;
						var targetNode = newParent;

						// the new jstree implementation returns numeric positions. we need to map these to our old position values
						var computedPosition = "Before";

						// find the reference node: the node after which we must insert the dropped node
						var tree = data.new_instance;

						/* some child ids may not be numeric. these are virtual nodes created by jstree. skip these nodes
						 * when finding the target node (the one used as reference)
						 */
						var children = newParent.children.filter(function (a) {
							return $.isNumeric(a);
						});
						if (children.length != 0) {
							if (position == children.length) {
								/*
								 * when the node was dropped after the current last one the position value is
								 * equal to the number of childrens of the parent (that is it points to a non-existing item in the array).
								 * in this case we use the last node as reference and the after position specifier.
								 */
								computedPosition = "After";
								position = position - 1;
							}
							// the first node in the child list is the node itself
							targetNode = tree.get_node(children[position]);
						} else {
							// the moved node is the first one under the target
							computedPosition = "First";
						}

						if (self.config.moved) {
							if (self.config.eventHandlerScope) {
								self.config.moved.apply(trackerObject, [nodes, newParent, computedPosition, targetNode, isCopy, data.rslt]);
							} else {
								self.config.moved(nodes, newParent, computedPosition, targetNode, isCopy, data.rslt);
							}
						}
					};

					/**
					 * in the new jstree the move_node and copy_node events are fired for each node individually.
					 * this debounce function can collect the node arguments for all of these events and call the handler fr
					 * all of them at once.
					 */
					function debounce(fn, delay) {
						var timer = null;
						var nodes = [];
						return function (event, data) {
							var node = data.old_instance.get_node(data.original);
							nodes.push(node);
							var context = this, args = arguments;
							clearTimeout(timer);
							timer = setTimeout(function () {
								var argsArray = [];
								for (var i = 0; i < args.length; i++) {
									argsArray.push(args[i]);
								}
								argsArray.push(nodes);
								fn.apply(context, argsArray);
								nodes = [];
							}, delay);
						};
					}

					$tree.bind("move_node.jstree", debounce(function (event, data, nodes) {
						var isCopy = data.new_instance !== data.old_instance;
						nodeCopyMoveHandler(event, data, nodes, isCopy);
					}, 250));

					$tree.bind("copy_node.jstree", debounce(function (event, data, nodes) {
						var isCopy = data.new_instance !== data.old_instance;
						nodeCopyMoveHandler(event, data, nodes, isCopy);
					}, 250));

					$tree.bind("after_close.jstree", function (event, data) {
						var node = data.node;
						data.instance.close_all(node, false);
					});
				});

			});
		},
		inlineEditHandler: function (event) {
			$("#" + this.config.treeContainerId).jstree("rename", "#" + event.currentTarget.id);
			event.stopPropagation();
		},

		fixHttpsIconUrls: function(data) {
			if (!data) {
				return;
			}
			for(var i=0; i<data.length; i++) {
				var node = data[i];
				var icon = node.data && node.data.icon;
				if (icon && icon.indexOf("/") == 0) {
					// convert the relative icon url to absolute
					node.data.icon = location.protocol + "//" + location.host + icon;
				}
				// go recursive to children
				this.fixHttpsIconUrls(node.children);
			}
		},

		openTwoLevels: function (node) {
			var idSelector = "#" + this.config.treeContainerId;
			node = node || $(idSelector);

			var root = node.find(" > ul > li");
			var secondLevel = node.find(" > ul > li > ul > li");
			$(idSelector).jstree("open_node", root);
			if (secondLevel.find("li").size() > 0) {
				// if there's a second level of nodes (that is the tree not an ajax tree), open that level
				$(idSelector).jstree("open_node", secondLevel);
			}
		}

	};

	$.extend(codebeamer.trees.Tree, {
		// redo the current filter/search expression on a jstree, useful to repaint the tree nodes after drag-and-drop
		redoSearch: function($tree) {
			if ($tree.data) {
				$tree.search($tree.data.search.str);
			}
		}
	});

}());

