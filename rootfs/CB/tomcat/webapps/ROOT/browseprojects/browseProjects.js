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
codebeamer.projects = codebeamer.projects || (function($) {

	var config = {};

	var packeryOptions = {
		rowHeight: 90,
		columnWidth: 90,
		gutter: 10,
		transitionDuration: '0.4s'
	};

	var getProjectInfo = function ($projectCard) {
		var projectId = $projectCard.data("projectid");
		var bs = ajaxBusyIndicator.showBusyPage();
		$.ajax(contextPath + "/ajax/projects/getProjectInfo.spr", {
			"data": {
				"projectId": projectId
			},
			"success": function (data) {
				ajaxBusyIndicator.close(bs);
				var clone = $projectCard.clone();
				clone.find(".knob").remove();

				clone.on('click', function() { return false; });
				var infoContent = $("<div>");
				infoContent.dialog({"title": i18n.message("project.details.label", $projectCard.data("name")),
					"modal": true,
					"draggable": false,
					"resizable": false,
					"dialogClass": "project-info-dialog",
					"height": $(window).height() - 50,
					"width": 800,
					"close": function () {
						// remove the ajax loaders initiated by the content of the overlay dialog
						// (the user might close the dialog before those ajax requests finish)
						$(".showBusySignDialog").remove()
						clone.remove();
					},
					"open": function () {
						$("body").append(clone);
						clone.position({"my": "right top", "at": "left top", "of": ".ui-dialog:visible"});
						clone.addClass("in-front");

						infoContent.append(data);
					}
				});
			},
			"complete": function () {
				ajaxBusyIndicator.close(bs);
			}
		});
	};

	var addEventHandlers = function () {
		var $wrapper = $(".ditch-tab-pane-wrap");

		$wrapper.on("click", ".menuArrowDown", function () {
			var $element = $(this);
			if (!$element.is(".initialized")) {
				addMenu($element);
			}
		}).on("click", ".details-arrow", function (event) {
			var $card = $(event.target).parents(".project-card");
			if ($card.is(".dragged")) {
				$card.removeClass("dragged");
			} else {
				getProjectInfo($card);
			}
			return false;
		}).on("click", ".working-set-name", function () {
			// the inline edit event
			var $label = $(this);
			var $input = $("<input>", {"class": "inline-edit-field", "value": $label.data("unescaped"), "type": "text"});
			$label.hide();
			$label.after($input);
			var $hintElem = createHelperMessages();
			$input.after($hintElem);
			var $set = $input.closest(".set");
			$set.addClass("disable-controls");
			$input.keyup(function (event) {
				if (event.keyCode == jQuery.ui.keyCode.ENTER) {
					var name = $.trim($input.val());
					if (name.length == 0) {
						toggleValidationErrorMessage($set, true);
					} else {
						var workingSetId = $label.parents(".set").data("name");
						$.ajax(contextPath + "/ajax/projects/renameSet.spr", {
							"type": "POST",
							"data": {
								"workingSetId": workingSetId,
								"name": name
							},
							"success": function(data) {
								$label.html(data["name"]);
								$input.remove();
								$label.show();
								$hintElem.remove();
								$set.removeClass("disable-controls");
								showOverlayMessage();
								$("label[for=category-" + workingSetId + "]").html(data["name"]);
								$label.data("unescaped", data["unescaped"]);
							}
						});
					}
				} else if (event.keyCode == jQuery.ui.keyCode.ESCAPE) {
					$input.remove();
					$label.show();
					$hintElem.remove();
					$set.removeClass("disable-controls");
				} else {
					toggleValidationErrorMessage($set, false);
				}
			});
		}).on("click", ".new-set-placeholder", function() {
			var $t = $(this);
			var first = $t.is(".first");
			var $set = createEmptySet(first);
			if (first) {
				$t.after($set);
			} else {
				$t.before($set);
			}
		});

		if (config["editable"]) {
			$wrapper.on("click", ".add-project-icon", function () {
				var $setContainer = $(this).parents(".set").find(".set-container");
				var workingSetId = $setContainer.data("workingsetid");
				showAddProjectsDialog(workingSetId);
			}).on("click", ".remove-set-icon", function () {
				var $set = $(this).parents(".set");
				var $placeholder = $set.next(".new-set-placeholder");
				var workingSetId = $set.find(".set-container").data("workingsetid");
				showFancyConfirmDialogWithCallbacks("Do you really want to delete this working set?", function() {
					$.ajax(contextPath + "/ajax/projects/deleteSet.spr", {
						"data": {
							"workingSetId": workingSetId
						},
						"type": "post",
						"success": function () {
							$set.remove();
							$("#category-" + workingSetId).parent(".category-label").remove(); // remove the category filter, too
							$placeholder.remove();
						}
					});
				});
			});
		}

		// clcking on any other poin of the card will open it on a new tab
		$wrapper.on('click', '.project-card', function(event) {
			var $target = $(event.target);
			if (!$target.is(".menuArrowDown,.details-arrow")) {
				var $card = $target.closest(".project-card");
				if ($card.size() == 0 || $card.is(".dragged")) {
					$card.removeClass("dragged");
				} 
			}
		});

		var $leftPanel = $("#left-content");
		$leftPanel.on("click", ".category-box", function () {
			filterByCategory(this);
		}).on("mousemove", ".category-list", function() {
			var placeholder = "<span>" + i18n.message("tracker.view.layout.cardboard.story.drop.placeholder.hint") +"</span>";
			$(".issuePlaceHolder").html(placeholder);
		});

		if (config["editable"]) {
			$leftPanel.on("mousemove", ".category-label", function() {
				if ($(this).is(".acceptsDrop") && !$(this).is(".highlighted")) {
					$(".highlighted").removeClass("highlighted");
					$(this).addClass("highlighted");
				} else if (!$(this).is(".acceptsDrop")) {
					$(".highlighted").removeClass("highlighted");
				}
			});
		}
	};

	var clearFilterClasses = function () {
		$(".filtered-out").removeClass("filtered-out");
		$(".matches-filter").removeClass("matches-filter");
	};

	var filter = function (filter) {
		var lowerCase = filter.toLowerCase();
		var $containers = $(".set-container");
		var $sets = $(".set");
		var $colorFilter = $(".color-filter.selected");
		var $checkboxes = $colorFilter.find("input[type=checkbox]");
		var $checked =  $checkboxes.filter(":checked");
		var property = $colorFilter.data("property");
		var hasUnchecked = $checked.size() != $checkboxes.size();
		var colors = [];

		for (var i = 0; i < $checked.size(); i++) {
			colors.push($($checked.get(i)).data("color"));
		}
		clearFilterClasses();

		// using custom filtering instead of isotope's built-in function
		var criteria = function($card) {
			var name = "" + $card.data("name");
			var color = $card.data(property);
			var matches = name.toLowerCase().indexOf(lowerCase) >= 0 && (colors.contains(color));

			$card.toggleClass("matches-filter", matches);

			return matches;
		};

		var matched = [];
		var unmatched = [];
		$(".project-card").each(function () {
			var $card = $(this);
			var matchesFilter = criteria($card);

			if (matchesFilter) {
				matched.push($card);
			} else {
				unmatched.push($card);
			}
		});

		for (var i = 0; i < matched.length; i++) {
			matched[i].show();
		}
		for (var i = 0; i < unmatched.length; i++) {
			unmatched[i].hide();
		}

		if (hasUnchecked || lowerCase.length > 0) {
			$sets.each(function () {
				var $set = $(this);
				var isEmpty = $set.find(".project-card.matches-filter").length == 0;
				$set.toggleClass("filtered-out", isEmpty);
				$set.next(".new-set-placeholder").toggleClass("filtered-out", isEmpty);
			});
		}

		$containers.packery("layout");

		// filter the compact, deleted and join tabs (all filterable tabs)
		filterList('.filterable li', lowerCase);

		//chop the extra & sign from the end og the url param list
		var extraParams = location.search ? location.search : "";
		if (extraParams.charAt(extraParams.length - 1) == '&') {
			extraParams = extraParams.substr(0, extraParams.length - 1);
		}

		// reload the join table via ajax
		var params = {};
		if (lowerCase && lowerCase.length > 0) {
			params["filter"] = lowerCase;
		}
		$.get(contextPath + "/projects/getProjectJoinTab.spr" + extraParams,
				params,
		function (result) {
			$("#project-join").html(result);
		});

		// TODO: currently we have to filter tables and lists with different functions because uitablefilter has limited capabilities
		// replace this plugin with a better one
	};

	var goToPage = function (href) {
		var $filterBox = $(".filter-text");
		var pattern = $filterBox.data("filter");

		var redirectUrl = href;

		// if there's already a filter parameter in the original href just remove it
		var m = redirectUrl.match("filter=[^&]*")
		if (m && m.length > 0) {
			redirectUrl = redirectUrl.replace(m[0], "");
		}

		// add the new filter parameter if the page is filtered
		if (pattern) {
			redirectUrl += "&filter=" + encodeURIComponent(pattern);

			// this is necessary because
			redirectUrl = redirectUrl.replace("&&", "&");
		}
		location.href = redirectUrl;
	};

	var filterByColor = function () {
		var $filterBox = $(".filter-text");
		var pattern = $filterBox.data("filter");
		if (!pattern) {
			pattern = "";
		}
		filter(pattern);
		storeCheckboxState();
	};

	var colorBy = function (property) {
		$(".project-card").each(function () {
			var $card = $(this);
			$card.css({"background-color": $card.data(property)});
		});
	};

	var exportView = function () {
		var categories = [];
		$("#category-togglers input:not(#show-all-categories):checked").each(function () {
			categories.push(escape($(this).data("name")));
		});

		var $filterBox = $(".filter-text");
		var filter = "";
		if ($filterBox.val() != i18n.message("association.search.as.you.type.label") && $filterBox.val().length > 2) {
			filter = $filterBox.val();
		}

		var colorMode = $(".active").data("property");
		var colors = [];
		$(".color-filter[data-property=" + colorMode + "] input:checked").each(function () {
			if (colorMode == "statuscolor") {
				colors.push(escape($(this).data("name")));
			} else {
				colors.push(escape($(this).data("color")));
			}
		});

		location.href = contextPath + "/projects/export.spr?filter=" + filter + "&categories=" + categories.join(",") + "&colorMode=" +
			colorMode + "&colors=" + colors.join(",");
	};

	var updateProjectProperties = function (projectId, color, size, workingSetId) {
		$.ajax(contextPath +"/ajax/projects/updateProjectSettings.spr", {
			"type": "POST",
			"data": {
				"size": size,
				"color": color,
				"projectId": projectId,
				"workingSetId": workingSetId
			},
			"success": function () {
				showOverlayMessage();
			},
			"error": function () {
				showOverlayMessage(i18n.message("project.browser.update.failed"), null, true);
			}
		});
	};

	var updateCategory = function ($card, categoryId) {
		var projectId = $card.data("projectid");
		var $input = $(".category-box[data-id=" + categoryId + "]");
		var categoryName = $input.data("name");
		var data = {
				"projectId": projectId,
				"category": categoryName
		};
		moveProjectToCategory($card, categoryId, "/ajax/projects/updateCategory.spr", data);
	};

	var resize = function (e, size) {
		var $card = $(e).parents(".project-card");
		var all = "size-medium size-large size-small";
		var projectId = $card.data("projectid");
		var workingSetId = $card.parents(".set-container").data("workingsetid");

		// update all project cards that might be in different categories
		$(".project-card[data-projectid=" + projectId + "]").each(function () {
			var $c = $(this);
			$c.removeClass(all).addClass("size-" + size);
			$c.parents(".set-container").packery("layout");
			$c.data("size", size);
		});

		updateProjectProperties($card.data("projectid"), $card.data("color"), size, workingSetId);
	};

	var repaint = function (e, color) {
		var $card = $(e).parents(".project-card");
		var projectId = $card.data("projectid");
		var workingSetId = $card.parents(".set-container").data("workingsetid");

		var computeColors = $(".switch a.active").data("property") == "color";
		$(".project-card[data-projectid=" + projectId + "]").each(function (){
			var $c = $(this);
			$c.data("color", color);
			if (computeColors) {
				$c.css({"background-color": color});
			}
		});

		updateProjectProperties($card.data("projectid"), color, $card.data("size"), workingSetId);
	};

	var updateStatus = function (e, status, color) {
		var $card = $(e).parents(".project-card");
		var projectId = $card.data("projectid");
		var workingSetId = $card.parents(".set-container").data("workingsetid");
		var computeColors = $(".switch a.active").data("property") == "statuscolor";
		$(".project-card[data-projectid=" + projectId + "]").each(function (){
			var $c = $(this);
			$c.data("status", status);
			$c.data("statuscolor", color);
			if (computeColors) {
				$c.css({"background-color": color});
			}
		});

		saveStatus($card.data("projectid"), status);
	};

	var saveStatus = function (projectId, status) {
		$.post(contextPath + "/ajax/projects/updateStatus.spr", {
			"projectId": projectId,
			"status": status
		}, function (data) {
			showOverlayMessage();
		});
	}

	var getColorMenuItem = function (color) {
		var col = $("<span>", {"class": "predefined-color", "style": "background-color: " + color + ";"});
		 return {"name": $("<div>").append(col).html(),
			"callback": function (key, options) {
				repaint(options.$trigger, color);
			}
		};
	};

	var addMenu = function ($element) {
		var colors = ["#0093b8", "#00a85d", "#e88d5d", "#ffab46", "#187a6d", "#8e44ad", "#086bb0", "#b31317", "#5f5f5f"];
		var colorSubMenu = {};
		for (var i = 0; i < colors.length; i++) {
			colorSubMenu[i] = getColorMenuItem(colors[i]);
		}

		var defaultItems = {
			"resizeToSmall": {
				"name": "Small",
				"callback": function (key, options) {
					resize(options.$trigger, "small");
				}
			},

			"resizeToMedium": {
				"name": "Medium",
				"callback": function (key, options) {
					resize(options.$trigger, "medium");
				}
			},

			"resizeToLarge": {
				"name": "Large",
				"callback": function (key, options) {
					resize(options.$trigger, "large");
				}
			},

			"color": {
				"name": "Color",
				"items": colorSubMenu,
				"className": "project-color-menu-item"
			}
		};

		var $card = $element.parents(".project-card");

		var items = defaultItems;

		if ($card.data("editable")) {

			items = $.extend(items, {
				"setStatus": {
					"name": "Set status",
					"items": {
						"ok": {
							"name": "<a class='color-box ok project-status'></a>&nbsp;" + i18n.message("project.status.ok.label"),
							"callback": function (key, options) {
								updateStatus(options.$trigger, "ok", "#00a85d");
							}
						},
						"warning": {
							"name": "<a class='color-box warning project-status'></a>&nbsp;" + i18n.message("project.status.warning.label"),
							"callback": function (key, options) {
								updateStatus(options.$trigger, "warning", "#ffab46");
							}
						},
						"alert": {
							"name": "<a class='color-box alert project-status'></a>&nbsp;" + i18n.message("project.status.alert.label"),
							"callback": function (key, options) {
								updateStatus(options.$trigger, "alert", "#b31317");
							}
						}
					}
				},
				"edit": {
					"name": i18n.message("action.edit.label"),
					"callback": function (key, options){
						var url = contextPath + "/proj/admin.spr?proj_id=" + options.$trigger.parents(".project-card").data("projectid");
						window.open(url, '_top');
					}
				}
			});
		}

		if ($card.parents(".set-container").data("type") == "set") {
			items = $.extend(items, {
				"removeFromSet": {
					"name": "Remove from set",
					"callback": function (key, options) {
						removeFromSet(options.$trigger.parents(".project-card"));
					}
				}
			});
		}

		var selector = "#" + $card.attr("id") + " .yuimenubaritemlabel";
		var menu = new ContextMenuManager({
			"selector": selector,
			"trigger": "left",
			"items": items,
			"zIndex": 30
		});
		menu.render();

		$element.addClass("initialized");
	};

	var removeFromSet = function ($projectCard) {
		var projectId = $projectCard.data("projectid");
		var $container = $projectCard.parents(".set-container");
		var workingSetId = $container.data("workingsetid");

		$.ajax(contextPath + "/ajax/projects/removeFromSet.spr", {
			"type": "POST",
			"data": {
				"projectId": projectId,
				"workingSetId": workingSetId
			},
			"success": function () {
				removeCard($container, $projectCard);
				showOverlayMessage();
			}
		});
	};

	var removeCard = function ($container, $card) {
		$container.packery("remove", $card);
		$container.packery("layout");

		updateCounter($container);
	};

	var updateCounter = function ($container) {
		var count = $container.packery('getItemElements').length;
		var name = $container.closest(".set").data("name");
		var safeName = getSafeName(name);
		$("#category-" + safeName).siblings(".set-count").html(count);
	};

	var wasMovedInsideSet = function ($set, event) {
		var offset = $set.offset();
		var x = event.clientX + 5;
		var y = event.clientY + 5;
		if (offset.left <= x && x <= offset.left + $set.width() && offset.top <= y && y <= offset.top + $set.height()) {
			return true;
		}
		return false;
	};

	/**
	 * updates the "items" property of packery in order to keep it in sync with
	 * the order after the dnd.
	 */
	var updateSetAfterMove = function ($set, $moved) {
		var $itemElements = $set.packery('getItemElements');

		// find the item coming immediately after the new position of the moved card
		var projids = $.map($itemElements, function (a) { return $(a).data("projectid");});
		var index = projids.indexOf($moved.data("projectid"));
		var next = -1;
		if (index < $itemElements.length - 1) {
			next = $($itemElements[index + 1]).data("projectid");
		}

		var updated = [];
		for (var i = 0; i < $itemElements.length; i++) {
			if ($($itemElements[i]).data("projectid") == next) {
				updated.push($moved.get(0));
			}

			if ($($itemElements[i]).data("projectid") != $moved.data("projectid")) {
				updated.push($itemElements[i]);
			}
		}

		if (next == -1) {
			updated.push($moved.get(0));
		}

		var ids = $.map(updated, function (a) {
			return $(a).data("projectid");
		});

		var setData = $set.data("packery");
		var storedItems = setData.items;

		var newItems = new Array(updated.length);
		for (var i = 0; i < storedItems.length; i++) {
			var j = ids.indexOf($(storedItems[i].element).data("projectid"));
			newItems[j] = storedItems[i];
		}

		setData.items = newItems;
		$set.data("packery", setData);
	};

	var makeDraggable = function ($set, $elements, disableOrdering) {
		$elements.draggable({
			"cursorAt": {left: -5},
			"distance": 10,
			"start": function (e, f) {
				$("body").addClass("is-dragging");
				var $target = $(e.originalEvent.target);
				highlightPossibleCategories($target);
				if ($target.is(".project-name")) {
					$(e.target).addClass("dragged");
				}
				var $container = $target.closest(".set-container");
				$container.addClass("acceptsDrop");
			},
			"stop": function(e, ui) {
				$("body").removeClass("is-dragging");
				var $set = $(e.target).parents(".set-container");
				var $targetLabel = $(".category-label.acceptsDrop.highlighted");

				if (wasMovedInsideSet($set, e)){
					if (!disableOrdering) {
						setTimeout(function () {
							updateSetAfterMove($set, $(e.currentTarget));

							$set.packery("layout"); // prevent leaving "gaps" on the layout

							var ids = $.map($set.packery("getItemElements"), function (a) {
								return $(a).data("projectid");
							});

							var data = {
								"projectIds": ids.join(",")
							};

							var url = "/ajax/projects/saveSetProjectOrder.spr";
							if ($set.data("type") == "category") {
								data["categoryName"] = $set.data("workingsetid");
								url = "/ajax/projects/saveCategoryProjectOrder.spr";
							} else {
								data["workingSetId"] = $set.data("workingsetid");
							}
							$.ajax(contextPath + url, {
								"type": "POST",
								"data": data,
								"success": function () {
									showOverlayMessage();

									// update the isotope data instance to keep the two plugins in sync
									// this will keep the orther when filtering with isotope
									var items = $set.data("packery").items;
									var isoData = $set.data("isotope");
									isoData.items = items;

									// also update the filteredItems property
									var filteredItems = [];
									for (var i = 0; i < items.length; i++) {
										if ($(items[i]).is(":visible")) {
											filteredItems.push(items[i]);
										}
									}
									isoData.filteredItems = filteredItems;

									$set.data("isotope", isoData);
								}
							});
						}, 600);
					} else {
						$set.packery("layout");
					}
				} else if ($targetLabel.size() > 0) {
					var $card = $(ui.helper);
					if ($set.data("type") == "category") {
						var categoryId = $targetLabel.find(".category-box").data("id");
						updateCategory($card, categoryId);
					} else {
						var id = $targetLabel.find(".category-box").data("id");
						moveProjectToSet($card, id);
					}
					if (disableOrdering) {
						$set.packery("layout");
					}
				} else {
					// when the ordering is disabled or the card was dropped outside of any sets
					delayedLayout($set);
				}
				removeHighlighting();
			}

		});
		$set.packery(packeryOptions);
		if (!disableOrdering) {
			$set.packery('bindUIDraggableEvents', $elements);
		}
	};

	var moveProjectToSet = function ($card, workingSetId) {
		var projectId = $card.data("projectid");
		var data = {
				"projectId": projectId,
				"workingSetId": workingSetId
		};
		moveProjectToCategory($card, workingSetId, "/ajax/projects/moveProjectToSet.spr", data);
	};

	var moveProjectToCategory = function ($card, categoryId, url, parameters) {
		var projectId = $card.data("projectid");
		$.ajax(contextPath + url, {
			"type": "POST",
			"data": parameters,
			"success": function (data) {
				showOverlayMessage();
				if (data["moved"]) {
					// remove from the set and move to the new one
					var $newSet = $(".set[data-id=" + categoryId + "] .set-container");

					var $cardNew = $card.clone();
					$newSet.append($cardNew);
					$newSet.packery("appended", $cardNew);
					$newSet.packery("layout");
					makeDraggable($newSet, $cardNew);
					updateCounter($newSet);

					$(".project-card[data-projectid=" + projectId + "]:visible").each(function () {
						var $t = $(this);

						if ($t.closest(".set[data-name=Recent]").size() == 0 && $t.closest(".set[data-id=" + categoryId + "]").size() == 0) {
							var $container = $t.closest(".set-container");

							$container.packery("remove", $t);

							updateCounter($container);
							delayedLayout($container);
						}
					});
				}
			},
			"error": function () {
				showOverlayMessage(i18n.message("project.browser.update.failed"), null, true);
			}
		});
	};

	var delayedLayout = function ($set) {
		setTimeout(function () { $set.packery("layout");}, 500);
	};

	var initFilter = function () {
		var $filter = $(".filter-text");
		var filterProjects = throttleWrapper(filter, 200);

		var placeholder = i18n.message("association.search.as.you.type.label");
		$filter.keyup(function (e) {
			if (e.altKey || e.ctrlKey) {
				return;
			}

			var $this = $(this);
			var val = $this.val();
			if (val.length > 2) {
				filterProjects(val);
				$this.data("filter", val);
			} else {
				filterProjects("");
				$this.data("filter", "");
				clearFilterClasses();
			}
		}).prop("placeholder", placeholder);
		$("#project-filter").ready(function() {
			$("#project-filter").focus();
		});
	};

	var initSet = function ($container, editable) {
		$container.isotope({
			itemSelector: '.project-card',
			layoutMode: 'packery',
			packery: packeryOptions,
			transitionDuration: '0.4s'
		});
	};

	var filterByCategory = function (checkbox) {
		var $box = $(checkbox);
		var dataId = $box.data("id");

		var $set = $(".set[data-id=\"" + dataId + "\"]");
		var $placeholder = $set.next(".new-set-placeholder");
		if ($box.is(":checked")) {
			$set.show();
			$placeholder.show();

			var $container = $set.find(".set-container");
			if ($container.data("workingsetid") != "-1") {
				$container.packery("layout");
			} else {
				$container.isotope("layout");
			}
		} else {
			$set.hide();
			$placeholder.hide();
		}
		storeCheckboxState();
	};

	var tabChangeListener = function (event) {
		var tabId = event.getTabPane().id;
		toggleTogglers(tabId);
		History.pushState({}, i18n.message("project.browser.page.title"), contextPath + "/projects/browse.spr");

		var $defaultTabLink = $(".make-default-link");
		if (codebeamer.projects.defaultTab == tabId) {
			$defaultTabLink.hide();
		} else {
			$defaultTabLink.show();
		}
		$("#project-filter").focus();
	};

	var tabStates = {
		"project-mySets": {
			"hidden": ["#category-togglers", "#excel-export-link"],
			"visible": ["#workingSet-togglers", "#accordion-container", ".filter-header"]
		},
		"project-categories": {
			"hidden": ["#workingSet-togglers"],
			"visible": ["#category-togglers", "#excel-export-link", "#accordion-container", ".filter-header"]
		},
		"default": {
			"hidden": ["#category-togglers", "#workingSet-togglers", "#excel-export-link", "#accordion-container"],
			"visible": [".filter-header"]
		}
	};

	var toggleTogglers = function (tabId) {

		if (tabStates[tabId]) {
			$(tabStates[tabId].hidden.join(",")).hide();
			$(tabStates[tabId].visible.join(",")).show();
		} else {
			$(tabStates["default"].hidden.join(",")).hide();
		}

		if (tabId == "project-mySets") {
			$("#" + tabId + " .set-container").packery("layout");
		} else if (tabId == "project-categories") {
			$("#" + tabId + " .set-container").packery("layout");
		}
	};

	var addToSet = function (workingSetId) {
		var ids = [];
		$("#projectSelectorList input:checked").each(function () {
			ids.push($(this).val());
		});
		addProjectsToSet(workingSetId, ids.join(","), function () {
			location.href = contextPath + "/projects/browse.spr?orgDitchnetTabPaneId=project-mySets";
		});
	};

	var addProjectsToSet = function (workingSetId, projectIds, callback) {
		$.ajax(contextPath + "/ajax/projects/addProjectsToSet.spr", {
			"type": "POST",
			"data": {
				"workingSetId": workingSetId,
				"ids": projectIds
			},
			"success": function () {
				if (callback) {
					callback();
				}
			}
		});
	};

	var showAddProjectsDialog = function (workingSetId) {
		$.ajax(contextPath + "/ajax/projects/getPossibleProjects.spr", {
			"data": {
				"workingSetId": workingSetId
			},
			"success": function (data) {
				var $div = $("<div>", {"id": "projectSelectorList"});
				var $table = $("<table>");
				$div.append($table);
				for (p in data) {
					var $li = $("<tr>");
					var $td = $("<td>");
					var $box = $("<input>", {"type": "checkbox", "name": "projectId", "value": data[p], "id": "box" + data[p]});
					var $label = $("<label>", {"for": "box" + data[p]}).html(p);
					$li.append($td);
					$td.append($box);
					$td.append($label);
					$table.append($li);
				}

				var $dialogContent = $("<div>");

				if ($table.find("tr").size() > 0) {
					// only show the tabel if it is not empty (there are project to add to the working set)
					var $filterBox = $("<input>", {"type": "text", "id": "filterBox"});

					$filterBox.keyup(function() {
						$.uiTableFilter($table, this.value);
					}).Watermark(i18n.message("user.history.filter.label"));

					$dialogContent.append($filterBox);
					$dialogContent.append($div);
					var $button = $("<input>", {"type": "button", "class" : "button", "value": i18n.message("button.add"), "onclick": "codebeamer.projects.addToSet(" + workingSetId +")"});
					$dialogContent.append($button);
				} else {
					$dialogContent.html(i18n.message("project.browser.select.projects.dialog.no.projects"));
				}

				$($dialogContent).dialog({"title": i18n.message("project.browser.select.projects.dialog.title"),
					"modal": true,
					"draggable": false,
					"resizable": false,
					"dialogClass": "project-info-dialog"
				});
			}
		});
	};

	var createHelperMessages = function() {
		var container = $("<div>", {"class": "helper-messages"});
		var helpMessage = i18n.message("project.browser.create.set.hint");
		var validationErrorMessage = i18n.message("project.browser.create.set.error.empty");
		$("<span>", {"class": "validation-error"}).html(validationErrorMessage).appendTo(container);
		$("<span>", {"class": "help-message"}).html(helpMessage).appendTo(container);
		return container;
	};

	var toggleValidationErrorMessage = function($set, show) {
		$set.find(".helper-messages").toggleClass("invalid", show);
	};

	var createEmptySet = function (first) {
		var $set = $("<div>", {"class": "set disable-controls"});
		var $input = $("<input>", {"type": "text"});
		var $setHeader = $("<div>", {"class": "set-header"}).append($input);
		var $setBody = $("<div>", {"class": "set-container"});

		$setHeader.append($("<span>", {"class": "remove-set-icon"}));
		$setHeader.append($("<span>", {"class": "add-project-icon"}));
		$setHeader.append(createHelperMessages());
		$set.append($setHeader);
		$set.append($setBody);

		$input.keyup(function (event) {
			if (event.keyCode == jQuery.ui.keyCode.ENTER) {
				if ($.trim($input.val()).length == 0) {
					toggleValidationErrorMessage($set, true);
				} else {
					createNewSet($set, first);
				}
			} else if (event.keyCode == jQuery.ui.keyCode.ESCAPE) {
				$set.remove();
			} else {
				toggleValidationErrorMessage($set, false);
			}
		});

		var placeholderValue = i18n.message("project.browser.default.set.name");
		applyHintInputBox($input, placeholderValue);

		return $set;
	};

	var createNewSet = function ($setPlaceholder, first) {
		var prev, $previousWorkingSet;

		if (first) {
			prev = "-1";
		} else {
			$previousWorkingSet = $setPlaceholder.prev(".set");
			while ($previousWorkingSet.length > 0) {
				if ($previousWorkingSet.data("name")) {
					prev = $previousWorkingSet.data("name");
					break;
				} else {
					$previousWorkingSet = $previousWorkingSet.prev(".set");
				}
			}
		}

		$.ajax(contextPath + "/ajax/projects/addNewSet.spr", {
			"type": "POST",
			"data": {
				"name": $.trim($setPlaceholder.find("input").val()),
				"prev": prev
			},
			"success": function (data) {
				var $newPlaceholder = $("<div>", {"class": "new-set-placeholder"});
				var $hint = $("<span>", {"class": "insert-here-hint"}).html(i18n.message("project.browser.insert.set.hint"));
				$newPlaceholder.append($hint);

				if (first) {
					$setPlaceholder.after($newPlaceholder);
				} else {
					$setPlaceholder.before($newPlaceholder);
				}

				$setPlaceholder.attr("data-name", data["id"]);
				$setPlaceholder.find(".set-container").data("workingsetid", data["id"]);

				var $workingSetNameContainer = $("<span>", {"class": "working-set-name"}).html(data["name"]);
				$workingSetNameContainer.attr("data-unescaped", data["name"]);
				$setPlaceholder.find("input").replaceWith($workingSetNameContainer);
				$setPlaceholder.find(".set-container").packery(packeryOptions);

				var $newLabel = $($("#category-label-template").html().replaceAll("$name", data["name"]).replaceAll("$id", data["id"]));
				if (first) {
					$("#workingSet-togglers .category-label.toggler").after($newLabel);
				} else {
					$("input[data-name=" + prev + "]").closest(".category-label").after($newLabel);
				}

				$setPlaceholder.removeClass("disable-controls")
					.find(".helper-messages").remove();
			}
		});
	};

	var highlightPossibleCategories = function ($target) {
		var $card = $target.closest(".project-card");
		var groupedByCategories = $("#category-togglers").is(":visible");

		if (!$card.data("editable") && groupedByCategories) {
			return;
		}

		var $set = $card.closest(".set");
		var safeName = getSafeName($set.data("name"));
		var $categories = $(".category-list input:not(#show-all-categories):not(#show-all-workingSets):not(#category-Recent):not(#category-"
				+ safeName + ")").parents(".category-label");
		$categories.addClass("acceptsDrop");
	};

	var removeHighlighting = function () {
		$(".acceptsDrop").removeClass("acceptsDrop").removeClass("highlighted");
	};

	var makeCategoriesSortable = function () {
		$(".category-list").sortable({
			"items": ".category-label:not(.toggler)",
			"placeholder": "issuePlaceHolder",
			"start": function () {
				codebeamer.is_dragging = true;
			},
			"stop": function (event, ui) {
				codebeamer.is_dragging = false;
			},
			"update": function (event, ui) {
				var $label = $(ui.item);
				var isWorkingSet = $label.closest("#workingSet-togglers").size() > 0;

				var $checkboxes = isWorkingSet ? $("#workingSet-togglers .category-box") : $("#category-togglers .category-box");
				var names = [];
				for (var i = 0; i < $checkboxes.size(); i++) {
					names.push($($checkboxes.get(i)).data("name"));
				}

				var url = isWorkingSet ? "/ajax/projects/updateWorkingSetOrder.spr" : "/ajax/projects/updateCategoryOrder.spr";
				$.ajax(contextPath + url, {
					"type": "POST",
					"data": {
						"names": names.join(",")
					},
					"success": function () {
						var $prev = $label.prev(".category-label");
						var $set = $(".set[data-name=\"" + $label.find("input").data("name") + "\"]");
						var $placeholder = $set.next(".new-set-placeholder");

						if ($prev.is(".toggler")) {
							var $target = isWorkingSet ? $(".categories.workingSets .set:first") : $(".categories .set:first");
							$target.before($set);
						} else {
							var $prevSet = $(".set[data-name=\"" + $prev.find("input").data("name") + "\"]");
							var $target = isWorkingSet ? $prevSet.next(".new-set-placeholder") : $prevSet;
							$target.after($set);
						}
						$set.after($placeholder);
						showOverlayMessage();
					},
					"error": function () {
						showOverlayMessage(i18n.message("project.browser.update.order.failed"), null, true);
					}
				});
			}
		});

		var $accordionContainer = $("#accordion-container");
		setupCenterAutoScrollOnDnD($accordionContainer, $accordionContainer, -20);
	};

	var init = function (editable) {
		config["editable"] = editable;

		var $containers = $('.set-container');
		$containers.each(function () {
			var $container = $(this);
			var recent = $container.data("workingsetid") == "Recent";

			initSet($container);

			var $itemElems = $($container.isotope('getItemElements'));

			if (editable) {
				makeDraggable($container, $itemElems, recent);
			}
		});

		addEventHandlers();

		initFilter();
		toggleTogglers($(".ditch-focused").attr("id").replace("-tab", ""));

		setTimeout(function(){$containers.isotope("layout");}, 200);

		$("#project-browser-tabs").prepend($("<div>", {"class": "tab-placeholder"}));

		setupLeftPanel();

	};

	var setupLeftPanel = function () {
		var $leftPanel = $("#left-content");

		$("#accordion-container").cbMultiAccordion({"active": 1});

		$leftPanel.resizable({
			"minWidth": 260,
			"maxWidth": 500,
			"handles": "e",
			"resize": function (e) {
				var $t = $(this);
				var $tabs = $("#project-browser-tabs");
				$tabs.width($(window).width() - $t.width() - 20);
				$tabs.offset({left: $t.width()});
				$tabs.find(".ditch-tab-wrap").offset({left: $t.width()});
			},
			"stop": function () {
				$(".set-container").isotope("layout");
			}
		});

		if (config.editable) {
			makeCategoriesSortable();
		}

		$(".switch a").click(function () {
			var $target = $(this);
			if (!$target.is(".active")) {
				var property = $target.data("property");
				$(".active").removeClass("active");
				$target.addClass("active");
				colorBy(property);
				$(".color-filter").removeClass("selected").hide();
				$(".color-filter[data-property=" + property + "]").addClass("selected").show();
				filterByColor();
				$.cookie("codebeamer.projectBrowser.coloring", property);
				$(".ditch-tab-pane:visible .set-container").packery("layout");
			}
		});

		$(".set-container").isotope("once", "layoutComplete", function () {
			loadState();
		});

		$(".color-filter[data-property=color] .color-box").click(function () {
			var $box = $(this);
			$box.toggleClass("state-checked");

			var option = $box.data("name");
			$("[id='option-" + option + "']").prop("checked", $box.is(".state-checked"));
			filterByColor();
		});

		var resizeHandler = throttleWrapper(adjustAccordionDimensions, 500);
		$("#panes").on("codebeamer.resizeEnd", function () {
			resizeHandler();
		});
	};

	var toggleCheckboxes = function(checkbox) {
		var $box = $(checkbox);
		var $checkboxes = $box.closest(".category-list").find(".category-box");
		var checked = $box.is(":checked");

		$checkboxes.each(function () {
			var $b = $(this);
			this.checked = checked;
			filterByCategory($b);
		});

		return true;
	};

	var storeCheckboxState = function (){
		var unchecked = [];

		if ($("#category-togglers :checked").size() == 0) {
			unchecked.push("show-all-categories");
		} else {
			$("#category-togglers .category-box:not(:checked):not(#show-all-categories)").each(function () {
				unchecked.push(this.id);
			});
		}

		if ($("#workingSet-togglers :checked").size() == 0) {
			unchecked.push("show-all-workingSets");
		} else {
			$("#workingSet-togglers .category-box:not(:checked):not(#show-all-workingSets)").each(function () {
				unchecked.push(this.id);
			});
		}

		$(".color-filter input:not(:checked)").each(function () {
			unchecked.push(this.id);
		});
		$.cookie("codebeamer.projectBrowser.checkboxes", unchecked.join(":::"), {expires: 90, secure: (location.protocol === 'https:')});
	};

	var loadState = function () {
		var checkBoxState = $.cookie("codebeamer.projectBrowser.checkboxes");
		if (checkBoxState) {
			if (checkBoxState.indexOf("show-all-categories") >= 0) {
				toggleCheckboxes($("#show-all-categories").prop("checked", false));
			}

			if (checkBoxState.indexOf("show-all-workingSets") >= 0) {
				toggleCheckboxes($("#show-all-workingSets").prop("checked", false));
			}

			var isFilteredByColor = false;
			var ids = checkBoxState.split(":::");
			for (var i = 0; i < ids.length; i++) {
				var $checkbox = $("[id='" + ids[i] + "']");
				$checkbox.prop("checked", false);
				filterByCategory($checkbox);

				var name = $checkbox.data("name");
				if (name) {
					$(".color-box[data-name='" + name + "']").removeClass("state-checked");
				}

				if ($checkbox.closest(".selected").size() != 0) {
					isFilteredByColor = true;
				}
			}

			if (isFilteredByColor) {
				$("#accordion-container").cbMultiAccordion("open", 0);
			}

			setTimeout(function () {
				filterByColor();
			}, 200);
		}
	};

	var adjustAccordionDimensions = function () {
		var $panel = $("#project-browser-tabs");
		var $leftContent = $("#left-content");
		var $actionMenuBar = $(".actionMenuBar");
		var height = $panel.height();

		$("#accordion-container").height(height - 30);
		$leftContent.height(height);
		$panel.find(".ditch-tab-wrap").width($actionMenuBar.width() - $leftContent.width() + 12 - ($("body").hasClass("IE9") ? 30 : 0));

		// Adjust panes' heights in IE8
		if ($("body").hasClass("IE8")) {
			autoAdjustPanesHeight();
			// Sometimes the horizontal scrollbar appears, disable horizontal scrolling
			//(hidden overflow property occurs wrong height calculation so it can't be used here)
			var scrollPos = 0;
			$('#centerDiv').scroll(function() {
				var scrollLeft = $('#centerDiv').scrollLeft();
				if (scrollPos != scrollLeft) {
					$('#centerDiv').scrollLeft(0);
				}
			});
		}

		$(".set-container").packery("layout");
	};

	var setDefaultTab = function() {
		var tabId = org.ditchnet.jsp.TabUtils.tab.id;
		var tab = tabId.substring(0, tabId.lastIndexOf('-'));
		$.ajax({
			type: "post",
			url: contextPath + "/ajax/project/setDefaultProjectBrowserTab.spr?tab="+tab,
			dataType: "json",
			success: function(data) {
				if (data.success) {
					codebeamer.projects.defaultTab = tab;
					$(".make-default-link").hide();
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log(textStatus);
			}
		});
	};

	/**
	 * removes the special characters from the category name so that it can be used in jquery selectors.
	 * important: must be kept in sync eith the server code
	 */
	var getSafeName = function(categoryName) {
		if (categoryName) {
			return toString(categoryName).replaceAll(" ", "_").replaceAll(/[^a-zA-Z0-9-_]/, "");
		}
	};

	return {
		"init": init,
		"filterByCategory": filterByCategory,
		"tabChangeListener": tabChangeListener,
		"addToSet": addToSet,
		"toggleCheckboxes": toggleCheckboxes,
		"exportView": exportView,
		"filterByColor": filterByColor,
		"setDefaultTab": setDefaultTab,
		"goToPage": goToPage
	};
})(jQuery);
