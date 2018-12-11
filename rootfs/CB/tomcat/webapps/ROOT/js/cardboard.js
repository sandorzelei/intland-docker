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
codebeamer.cardboard = codebeamer.cardboard || (function($) {
	var config = {};
	var originalSibling, validDrop;

	var MINIMUM_CARD_HEIGHT = 130;
	var WIDTH_TO_HEIGHT_RATIO = 1; // default width:height ratio, but MINIMUM_CARD_HEIGHT might override final height
	var CARD_LEFT_SPACE = 16; // handle + border + margin
	var COLUMN_RIGHT_MARGIN = 7;
	var MINIMUM_PLACEHOLDER_HEIGHT = 200;

	var setConfig = function(c) {
		config = c;
	};

	var getConfig = function() {
		return config;
	};

	var extendConfigWith = function(c) {
		config = $.extend(config, c);
	};

	var init = function() {

		_toggleFirstLaneAsNeeded();

		// initialize the sortable plugin
		$(config.sortableSelector).sortable({ "connectWith": config.sortableSelector,
			"handle": ".dragHandle.editable",
			"tolerance": "pointer",
			//"containment": "body",
			"out": _sortableOut,
			"start": _sortableStart,
			"stop": _sortableStop,
			"beforeStop": _sortableBeforeStop,
			"cursorAt": {"left": -5, "top": -5},
			"cursor": "move"
		});

		// initialize the column collapser buttons
		$(".columnCollapser").click(function() {
			var $head = $(this).parents("td");
			var index = $head.parent().children().index($head);
			var id = $head.data("id");
			_toggleColumn(index, id);
		});

		$(".swimlaneToggler").click(function() {
			var $swimlaneHeader = $(this).closest("tr");
			_toggleSwimlane($swimlaneHeader);
		});

		$(window).scroll(throttleWrapper(function() {
			// recompute the visible area of the floating placeholders after scrolling
			$(".floatingPlaceholder").each(function() {
				_realignPlaceholder(this);
			});
		}, 100));

		$(window).resize(function() {
			resizeCards();
			_alignCollapserButtons();
		});
		resizeCards();

		_checkAllCounts();

		_setGroupCounts();

		_setupCardSelectability();

		(function maintainSelectionBetweenViews() {
			$("a.append-selection-id").click(function() {
				var href = $(this).attr("href");
				var selectedCards = $(".userStory.selected");
				if (selectedCards.length > 0) {
					href += UrlUtils.generateHashParameters({"select": selectedCards.first().attr("id")});
				}
				window.location.href = href;
				return false;
			});
		})();

		var cookie = $.cookie("codebeamer.cardboard." + config.releaseId);
		if (cookie != null && cookie.length > 0) {
			var indices = cookie.split(",");
			for (var i = 0; i < indices.length; i++) {
				if (indices[i].length > 0) {
					_collapseColumn(indices[i]);
				}
			}
		}

		_alignCollapserButtons();
		resizeCards();

		$(".groupHeader").tooltip({
			show: {
				duration: 300,
				delay: 300
			},
			tooltipClass: "item-ui-tooltip",
			items: "td",
			position: {
				my: "left top",
				at: "left+15 bottom",
				collision: "flipfit flipfit"
			},
			create: function() {
				$(this).data("ui-tooltip").liveRegion.remove();
			},
			content: function(callback) {
				var $this = $(this);

				callback($this.parent().find(".nameLabel").html());
			},
			close: function(event, ui) {
				jquery_ui_keepTooltipOpen(ui);
			}
		});

		$(".swimlaneToggler").on("mouseover", throttleWrapper(function() {
			$(".groupHeader").tooltip("close");
			$(".groupHeader").tooltip("disable");
		}, 300));

		$(".swimlaneToggler").on("mouseleave", throttleWrapper(function() {
			$(".groupHeader").tooltip("enable");
		}, 300));

		$("#userStories").tooltip({
			show: {
				duration: 300,
				delay: 300
			},
			tooltipClass: "item-ui-tooltip",
			items: ".assigneeList a, .assigneeList span, .versionList a, .versionList span",
			position: {
				my: "left top",
				at: "left+15 bottom",
				collision: "flipfit flipfit"
			},
			create: function() {
				$(this).data("ui-tooltip").liveRegion.remove();
			},
			content: function(callback) {
				var $element, $this, values;

				$this = $(this);

				$element = $this.closest(".assigneeList");

				if ($element.size() === 0) {
					$element = $this.closest(".versionList");
				}

				values = $element.clone().removeClass();

				callback(values);
			},
			close: function(event, ui) {
				jquery_ui_keepTooltipOpen(ui);
			}
		});

		initializeStickyTableHeader();

		$(document).on("click", ".extendedCardboardMoreMenu", "click", function (e) {
			e.stopPropagation();
			e.preventDefault();

			var $menuArrow = $(this);

			// Create context menu only it it is not already initialized
			if (!$menuArrow.data("menujson")) {
				var id = $menuArrow.data("id");

				// Download and create context menu
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					"task_id": id,
					"cssClass": "inlineActionMenu",
					"builder": "cardboardExtendedActionMenuBuilder"
				});
			}
		});

	};

	/** 'Today' lane is always rendered if grouping is set to 'Modified at'.
	 * However, if it's currently empty, we must hide it.
	 * @private
	 */
	var _toggleFirstLaneAsNeeded = function() {
		var isModifiedAtSelected = $("#groupBySelector").val() == "modifiedAt";
		if (isModifiedAtSelected) {
			var firstLane = $("tr.body").first();
			var firstLaneHeader = firstLane.prev(".groupHeader");
			var isFirstLaneEmpty = firstLane.find(".userStory").length == 0;
			$([firstLane, firstLaneHeader]).toggle(!isFirstLaneEmpty);
		}
	};

	var _findCardsById = function(cardId) {
		return $("[name=" + cardId + "]");
	};

	var _findTargetCell = function(columnIndex, groupId) {
		return $("[name=" + columnIndex + "][group=" + groupId + "]");
	};

	var _findClones = function(cardOrChild) {
		var cardId = _getCardId(cardOrChild);
		return _findCardsById(cardId);
	};

	var _getCard = function(cardOrChild) {
		cardOrChild = $(cardOrChild);
		return cardOrChild.hasClass("userStory") ? cardOrChild : cardOrChild.closest(".userStory");
	};

	var _getCardId = function(cardOrChild) {
		return _getCard(cardOrChild).attr("id");
	};

	var _getCardGroupId = function(cardOrChild) {
		return _getCard(cardOrChild).attr("group");
	};

	var _setCardGroupId = function(cardOrChild, groupId) {
		_getCard(cardOrChild).attr("group", groupId);
	};

	var _alignCollapserButtons = function() {
		// align the collapser buttons
		$(".columnCollapser").each(function() {
			var $collapser = $(this);
			if ($collapser.is(".rotated")) {
				$collapser.css({"left": ""});
			}
		});
	};

	var _realignPlaceholder = function(floatingPlaceholder) {
		floatingPlaceholder = $(floatingPlaceholder);
		var alignTo = floatingPlaceholder.parent();

		var calculateMaxHeight = function(currentTop) {
			var container = $("#userStories");
			var containerBottom = container.offset().top + container.height();
			var scrollBottom = $(document).scrollTop() + $(window).height();
			var bottom = Math.min(containerBottom, scrollBottom) - 5;
			return Math.max(bottom - currentTop, MINIMUM_PLACEHOLDER_HEIGHT);
		};

		var top = Math.max(alignTo.offset().top, $(document).scrollTop() + 5);
		floatingPlaceholder.css({
			"height": calculateMaxHeight(top),
			"width": alignTo.width() - 10,
			"top": top
		});

		var statusPlaceholders = floatingPlaceholder.find(".statusPlaceholder");
		if (statusPlaceholders.length > 0) {
			var totalHeight = floatingPlaceholder.height();
			var statusHeight = totalHeight / statusPlaceholders.length;
			statusPlaceholders.each(function() {
				$(this).height(statusHeight);
			});
		}
	};

	var _drawStatusPlaceholder = function($column, $card, deniedTransitions) {
		function findTransitionName(sourceStatusId, targetStatusId) {
			var transitionName, result = null;

			transitionName = transitionNames[sourceStatusId + "-" + targetStatusId];
			if (transitionName) {
				result = transitionName;
			}

			return result;
		};

		var placeholder = $column.find(".floatingPlaceholder").first();
		if (placeholder.size() == 0) {
			// if the user can NOT drop to this column
			return ;
		}

		var trackerId = $card.attr("trackerId");
		var statusId = $card.attr("statusId");

		var statuses = config.statusesPerColumns[trackerId][$column.attr("name")];
		var statusNames = config.statusNames[trackerId];
		var statusStyles = config.statusStyles[trackerId];
		var transitionNames = config.transitionNames[trackerId];
		var height = placeholder.height() / (statuses && statuses.length ? statuses.length : 1);
		if (transitionNames) {
			// filter the statuses for which there are no valid transitions
			var validStatuses = _findValidStatuses(statuses, transitionNames, statusId);

			height = placeholder.height() / validStatuses.length;
			// if there are transitions to this column than show the options
			var $placeholderHtml = $("<div>");
			for (var i = 0; i < validStatuses.length; i++) {
				// check if the target status has any required fields
				var cl = "acceptsDrop statusPlaceholder";
				var explanation = "";
				if (validStatuses[i].targetStatusId == statusId) {
					// mark the original status (the status where the card is dragged from)
					cl = "original statusPlaceholder";
				} else if (deniedTransitions.contains(validStatuses[i].sourceStatusId + "-" + validStatuses[i].targetStatusId)) {
					// the user has no permission to the transition
					cl = "deniesDrop statusPlaceholder";
				} else if (config.statusesWithRequiredField[trackerId] && config.statusesWithRequiredField[trackerId].contains(validStatuses[i].targetStatusId)) {
					// the statuses with required field get this class
					cl += " restricted";
				}

				// render a placeholder box for this transition
				var transitionName = findTransitionName(validStatuses[i].sourceStatusId, validStatuses[i].targetStatusId);
				var $d = $("<div>").attr("statusId", validStatuses[i].targetStatusId).addClass("storyPlaceholder").addClass(cl).height(height);

				// create the placeholder on-the-fly and append it to the parent
				var style = statusStyles[validStatuses[i].targetStatusId];
				var $nameTablet = $("<div>");
				if (typeof style !== "undefined") { // empty status has no styles
					$nameTablet.addClass(style.cssClass).addClass("issueStatus").css({
						"background-color": style.backgroundColor,
						"color": style.color}).html(statusNames[validStatuses[i].targetStatusId]);
				}
				if (validStatuses[i].targetStatusId == statusId) {
					// the placeholder foe the original status will contain only the status name
					$d.append($nameTablet);
					$placeholderHtml.append($d);
				} else {
					var $s = $("<span>").addClass("transitionName").html(transitionName + " " + config.issueTypes[trackerId]);
					var $exp = $("<div>").addClass("explanation").html(explanation);
					var $arrow = $("<div>").addClass("statusName");
					$d.append($s);
					$d.append($arrow);
					$d.append($nameTablet);
					$d.append($exp);
					$placeholderHtml.append($d);
				}
			}

			// append the placeholders to the big green box
			$column.find(".floatingPlaceholder").html($placeholderHtml);
		} else {
			height = placeholder.height() / statuses.length;
			var $placeholderHtml = $("<div>");
			for (var i = 0; i < statuses.length; i++) {
				// Verify that the status is a valid id
				if (statuses[i] > 0) {
					var cl = "acceptsDrop statusPlaceholder";
					var explanation = "";
					if (statuses[i] == statusId) {
						cl = "original statusPlaceholder";
					} else if (config.statusesWithRequiredField[trackerId] && config.statusesWithRequiredField[trackerId].contains(statuses[i])) {
						cl += " restricted";
					}
					var $exp = $("<div>").addClass("explanation").html(explanation);
					var style = statusStyles[statuses[i]];
					var $nameTablet = $("<div>").addClass(style.cssClass).addClass("issueStatus").css({
						"background-color": style.backgroundColor,
						"color": style.color}).html(statusNames[statuses[i]]);
					var $d = $("<div>").attr("statusId", statuses[i]).addClass("storyPlaceholder").addClass(cl).height(height).html($nameTablet);
					$placeholderHtml.append($d);
					$d.append($exp);
				}
			}
			$column.find(".floatingPlaceholder").html($placeholderHtml);
		}
	};

	var _removeEmptyFloatingPlaceholders = function(floatingPlaceholder) {
		if (floatingPlaceholder.find(".storyPlaceholder").size() == 0) {
			floatingPlaceholder.remove();
		}
	};

	var _addHighlightOnMouseMoveEventHandlers = function() {
		$(".storyPlaceholder").mousemove(function() {
			if (!$(this).is(".highlighted")) {
				$(".highlighted").removeClass("highlighted");
				$(this).addClass("highlighted");
			}
		});
	};

	var _sortableOut = function(event, ui) {
		$(".highlighted").removeClass("highlighted");
	};

	var _sortableStart = function(event, ui) {
		codebeamer.isDragging = true;
		var card = $(ui.item[0]);
		var prev = card.prev();
		// store the original sibling of the card. after an unsuccessful drop it will be placed after this
		if (prev.attr("id") && card.attr("id") != prev.attr("id")) {
			originalSibling = prev;
		}
		// highlight the columns that will accept the card
		var trackerId = card.attr("trackerId");
		var $column = card.closest(".lane");
		if ($column.find(".userStory").not(".ui-sortable-placeholder").size() == 1) {
			// when this is the only card in the column show the hidden card; otherwise the column would collapse
			$column.find(".hiddenUserStory").css("display", "block");
		}
		var availableTransitions = config.transitions[trackerId];
		if (availableTransitions) {
			// if there are transitions defined for the tracker of this card
			var columnId = $column.attr("name");
			var targets = availableTransitions[columnId];

			// Add star transitions
			var starTransitionTargets = availableTransitions[-1];
			if (starTransitionTargets) {

				// If there are no ordinary transitions from this state, then create an empty array
				if (!targets) {
					targets = [];
				}

				targets = targets.concat(starTransitionTargets);
			}

			// add the original column to the targets list so the floating placeholder gets drawn there too
			if (!targets.contains(columnId)) {
				targets.push(columnId);
			}
			_drawFloatingPlaceholders(targets, card);
		} else {
			// find the columns to which the card can be dropped
			// these are the columns that contain at least one status from the card's tracker
			var possibleColumns = config.statusesPerColumns[trackerId];
			var ids = [];
			$.each(possibleColumns, function(key, value) {
				ids.push(key);
			});
			_drawFloatingPlaceholders(ids, card);
		}
		ui.placeholder.html("<div>" + i18n.message("tracker.view.layout.cardboard.story.drop.placeholder.hint") + "</div>");
	};

	var _sortableBeforeStop = function(event, ui) {
		var card = $(ui.item[0]);
		var $miniPlaceholders = $(".storyPlaceholder");
		var isValidDrop = false;

		// find the placeholder under the cursor
		// TODO: don't compute this again; just find the divs with "highlighted" css class
		var $underCursor = _findPlaceholderUnderCursor($miniPlaceholders, ui.offset.left, ui.offset.top);
		if ($underCursor != null && $underCursor.hasClass("acceptsDrop")) { // check if the user can drop to this status
			if (!$underCursor.hasClass("restricted")) {
				// the card was dropped to this placeholder
				isValidDrop = true;
				_updateStory(card.attr("id"), $underCursor.attr("statusId"), $(event.target));
			} else {
				// the target area is restricted, meaning that the user have to set a mandatory field
				var transitionIds = config.transitionIds[card.attr("trackerId")];
				var swimlanes = $("#groupBySelector").val();
				var statusId = $underCursor.attr("statusId");
				var transitionId = null;
				if (transitionIds) {
					transitionId = transitionIds[card.attr("statusId") + "-" + statusId];
				}
				var cardId = card.attr("id");
				var data = {
					"status_id": statusId,
					"issue_id": cardId
				};
				if (transitionId) {
					data["transition_id"] = transitionId;
				}
				$.getJSON(contextPath + "/ajax/cardboard/hasEmptyFieldRequired.spr",
					data, function(d) {
						if (d["hasEmptyField"]) {
							if (transitionId) {
								showPopupInline(contextPath + "/cardboard/editCard.spr?task_id=" + cardId + "&transition_id=" + transitionId + "&swimlanes=" + swimlanes, {geometry: 'large'});
							} else {
								showPopupInline(contextPath + "/cardboard/editCard.spr?task_id=" + cardId + "&statusId=" + statusId + "&swimlanes=" + swimlanes, {geometry: 'large'});
							}
						} else {
							_updateStory(card.attr("id"), $underCursor.attr("statusId"), $(event.target));
						}
					}
				);

				isValidDrop = true;
			}
		}

		$(".floatingPlaceholder").remove();
		validDrop = isValidDrop;
	};

	var _findPlaceholderUnderCursor = function($placeholders, offsetX, offsetY) {
		return findElementUnderCursor($placeholders, offsetX, offsetY);
	};

	var _sortableStop = function(event, ui) {
		$(".hiddenUserStory").hide();
		if (validDrop == false) {
			// put the card back where it came from
			if (originalSibling) {
				originalSibling.after($(ui.item[0]));
			} else {
				$(event.target).prepend($(ui.item[0]));
			}
			validDrop = true;
		} else {
			// always put the new card to the first place in the column
			var $card = $(ui.item[0]);
			$card.prependTo($card.closest(".lane"));
		}

		originalSibling = null;
		codebeamer.isDragging = false;
	};

	var _findValidStatuses = function(statuses, transitionNames, statusId) {
		var i, key, transitionName, parts, status, validStatuses = [];

		function testStatus(currentStatusId, targetStatusId) {
			var transitionName, result = null;

			transitionName = transitionNames[currentStatusId + "-" + targetStatusId];
			if (transitionName || targetStatusId === currentStatusId) {
				result = {
					sourceStatusId: currentStatusId,
					targetStatusId: targetStatusId
				}
			}

			return result;
		};

		function containsStatus(currentStatus) {
			var j, result;

			result = false;
			for (j = 0; j < validStatuses.length; j++) {
				if ((currentStatus.sourceStatusId === validStatuses[j].sourceStatusId)
						&& (currentStatus.targetStatusId === validStatuses[j].targetStatusId)) {
					result = true;
					break;
				}

			}

			return result;
		}

		for (i = 0; i < statuses.length; i++) {
			status = testStatus(statusId, statuses[i]);
			if (status) {
				validStatuses.push(status);
			}

			// *** transitions start with -1
			status = testStatus("-1", statuses[i]);
			if (status && !containsStatus(status)) {
				validStatuses.push(status);
			}
		}

		return validStatuses;
	};

	var _updateStory = function(storyId, valueId, $originalColumn) {
		var fieldId = $("#groupingSelector").val();
		var $s = $("div#" + storyId);
		$s.find(".userStoryHandle").removeClass("editable"); // disable the editing on this card until it's updated
		var bgImage = $s.css("background-image");
		$s.css("background-image", "none");
		$s.css("background-color", "yellow");
		var swimlanes = $("#groupBySelector").val();
		$.ajax({
			"url": contextPath + "/ajax/cardboard/updateField.spr",
			"type": "POST",
			"data": {
				"issue_id": storyId,
				"valueId": valueId,
				"fieldId": fieldId,
				"releaseId": config.originalReleaseId,
				"swimlanes": swimlanes
			},
			"success": function(data) {
				$(".reportSelectorTag").first().find(".searchButton").click(); //TODO
				// var $originalHeader = $("#info_" + $originalColumn.attr("name"));
				// var originalCount = $originalHeader.data("unfilteredcount");
				// if (originalCount > 0) {
				// 	$originalHeader.data("unfilteredcount", originalCount - 1);
				// }
				// var $targetHeader = $("#info_" + $s.parents(".lane").attr("name"));
				// var newCount = $targetHeader.data("unfilteredcount");
				// if (newCount > 0) {
				// 	$targetHeader.data("unfilteredcount", newCount + 1);
				// }
				// _afterUpdate($s, valueId, data);
				// $s.find(".userStoryHandle").addClass("editable");
				//
				// (function scrollToDroppedElementIfNecessary() {
				// 	var droppedCard = $("#" + storyId);
				// 	var cardHeight = droppedCard.outerHeight();
				// 	var padding = 30;
				// 	var cardTop = droppedCard.offset().top - padding;
				// 	var cardBottom = cardTop + cardHeight + 2 * padding;
				//
				// 	var $window = $(window);
				// 	var viewPortStart = $window.scrollTop();
				// 	var viewPortEnd = viewPortStart + $window.height();
				//
				// 	var needToScrollUp = (cardTop < viewPortStart);
				// 	var needToScrollDown = (cardBottom > viewPortEnd);
				//
				// 	if (needToScrollUp || needToScrollDown) {
				// 		var targetTop = needToScrollUp ? cardTop : cardBottom - $window.height();
				// 		if (targetTop < 0) {
				// 			targetTop = 0;
				// 		}
				// 		$("html, body").animate({ scrollTop: targetTop }, 1000);
				// 	}
				// })();
			},
			"error": function(data, status, error) {
				if (data.status === 401) {
					location.reload(contextPath + "/login.spr");
				}
				showOverlayMessage(data.responseText, 6, true);
				// undo the last drop
				if (originalSibling) {
					originalSibling.after($s);
				} else {
					$originalColumn.prepend($s);
				}
				$s.find(".userStoryHandle").addClass("editable");
				$s.css("background-image", bgImage);
				$s.css("background-color", "#f5f5f5");
			}
		});
	};

	var _refreshCard = function(cardId, success) {
		$(".reportSelectorTag").first().find(".searchButton").click(); //TODO
		// var $roleSelector = $("#roleSelector");
		// var roleIds = "";
		// var userIds = "";
		// var releaseId = config.releaseId;
		// var modifiedIn = "";
		// var swimlanes = $("#groupBySelector").val();
		// if ($roleSelector) {
		// 	userIds = $.map($roleSelector.find(":selected.user"), function(o) {
		// 		return o.value;
		// 	}).join(",");
		// 	roleIds = $.map($roleSelector.find(":selected.role"), function(o) {
		// 		return o.value;
		// 	}).join(",");
		// 	modifiedIn = $roleSelector.find(":selected.modified-in").val();
		// 	var selectedReleaseId = $roleSelector.find(":selected.release").val();
		// 	if (selectedReleaseId) {
		// 		releaseId = selectedReleaseId;
		// 	}
		// }
		// $.ajax({
		// 	"url": contextPath + "/ajax/cardboard/getCardInfo.spr",
		// 	"data": {
		// 		"issue_id": cardId,
		// 		"releaseId": releaseId,
		// 		"userIds": userIds,
		// 		"roleIds": roleIds,
		// 		"modifiedIn": modifiedIn,
		// 		"swimlanes": swimlanes
		// 	},
		// 	"type": "GET",
		// 	"success": success
		// });
	};

	/**
	 * Card was moved to another release; remove it (and all of its clones) from the board if so
	 * @param card
	 * @param positions
	 * @private
	 */
	var _removeCardIfWasMovedToAnotherRelease = function(card, positions) {
		var cardId = _getCardId(card);
		var removeCard = true;
		if (positions) {
			for (var p in positions) {
				if (positions[p].hasOwnProperty(cardId)) {
					removeCard = false;
					break;
				}
			}
		}
		if (removeCard) {
			_findClones(card).remove();
		}
	};

	/**
	 * Find all instances of the same card and replace them with the rendered one. Group ID is kept for all cards
	 * unless <code>forceUseRenderedGroupId</code> is set to true.
	 * @param card Card to update clones for
	 * @param renderedCard Rendered markup for card's fresh content
	 * @param forceUseRenderedGroupId If true, the renedered group ID will be kept, otherwise the old ones
	 * @returns {*}
	 * @private
	 */
	var _replaceCardsMarkup = function(card, renderedCard, forceUseRenderedGroupId) {
		_findClones(card).each(function() {
			var oldCard = $(this);
			var newCard = $(renderedCard);
			if (!forceUseRenderedGroupId) {
				var newGroupId = _getCardGroupId(oldCard);
				_setCardGroupId(newCard, newGroupId);
			}
			oldCard.replaceWith(newCard);
		});
		return _findClones(card);
	};

	/**
	 * If the assignee was changed on the overlay and the new assignee doesn't match the selected filter then
	 * remove the card from the page.
	 * @private
	 */
	var _checkFilterInvariant = function(clones, matchesFilterByRole) {
		var selected = $("#roleSelector").find("option:selected");
		if (selected.is(".user")) {
			if (matchesFilterByRole == false) {
				clones.fadeOut(400, function() {
					$(this).remove();
				});
			}
		}
	};

	var _setCardName = function(card, name) {
		$(card).find(".cardName").html(name);
	};

	var _countCardsInColumn = function(columnIndex) {
		return $("td.lane[name=" + columnIndex + "] .userStory").size();
	};

	var _updateTableHeaderCounts = function() {
		for (var i = 0; i < _countColumns(); i++) {
			var $counter = $("#header_" + i).find(".numberLabel");
			$counter.html(_countCardsInColumn(i));
		}
	};

	var _markAsRecentlyMoved = function(cards) {
		$(cards).addClass("recentlyMoved");
	};

	var _flashMovedCards = function() {
		var $moved = $(".recentlyMoved");
		var bgImage = $moved.css("background-image");
		$moved.css("background-image", "none");
		flashChanged($moved, function() {
			$moved.css({
				"background-image": bgImage != "none" ? bgImage : "",
				"background-color": ""
			}).removeClass("recentlyMoved");
		}, 1000);
	};

	var _findColumnForStatus = function($card, statusId) {
		var targetColumn = 0;
		var trackerId = $card.attr("trackerId");
		var statusesPerColumns = config.statusesPerColumns[trackerId];
		for (var column in statusesPerColumns) {
			if (statusesPerColumns[column].contains(statusId)) {
				targetColumn = column;
				break;
			}
		}
		return targetColumn;
	};

	/**
	 * This function keeps the cards of a column in order. after the last card was placed to the target column
	 * it iterates through each card in the order specified by positions and appends them to the end of the column.
	 * @param baseGroupId
	 * @param targetColumn
	 * @param positions
	 * @private
	 */
	var _reorderCards = function(baseGroupId, targetColumn, positions) {

		var invert = function(positionsOfGroup) {
			var invertedPositions = [];
			for (cardId in positionsOfGroup) {
				positionOfCard = positionsOfGroup[cardId];
				invertedPositions[positionOfCard] = cardId;
			}
			return invertedPositions;
		};

		for (var groupId in positions) {
			var cardId, positionOfCard;
			var invertedPositions = invert(positions[groupId]);
			for (positionOfCard in invertedPositions) {
				if (invertedPositions.hasOwnProperty(positionOfCard)) {
					cardId = invertedPositions[positionOfCard];

					// there might be multiple cards for the same issue (when the cards are grouped to swimlanes)
					var $cards = _findCardsById(cardId);
					$cards.each(function() {
						var $c = $(this);
						var currentGroupId = $c.attr("group");
						//console.debug("Taking card ", $c, " to group " + currentGroupId);
						// find the target column in the current row
						var $rowTarget = _findTargetCell(targetColumn, currentGroupId);
						if (groupId == baseGroupId) {
							$rowTarget.append($c);
						} else {
							// move the card's duplications in the other groups
							$rowTarget.find(".hiddenUserStory").before($c);
						}
					});
				}
			}
			var $target = _findTargetCell(targetColumn, groupId);
			$target.find(".hiddenUserStory").appendTo($target);
		}
	};

	var _afterUpdate = function($card, valueId, data) {
		var positions = data["positions"];
		var name = data["summary"];
		var renderedCard = data["rendered"];
		var forceUseRenderedGroupId = !!data["forceUseRenderedGroupId"];
		var matchesFilterByRole = data["matchesFilterByRole"];

		if ($card.size() == 0) {
			$card = $(renderedCard);
		}

		_removeCardIfWasMovedToAnotherRelease($card, positions);
		showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));

		var cards = _replaceCardsMarkup($card, renderedCard, forceUseRenderedGroupId);

		_setCardName(name);
		_checkFilterInvariant(cards, matchesFilterByRole);

		// the whole html of the updated cards is reloaded so we need to resize them
		resizeCards();

		_setupDetailsLinks(cards);
		_markAsRecentlyMoved(cards);
		_setupCardSelectability(cards);

		var completedCallback = function() {
			var targetColumn = _findColumnForStatus($card, valueId);
			_reorderCards(_getCardGroupId($card), targetColumn, positions);
			_updateTableHeaderCounts();
			_setGroupCounts();
			_checkAllCounts();
			_flashMovedCards();
			_toggleFirstLaneAsNeeded();
		};
		if (data["affected"]) {
			_updateAffected(data["affected"], $card.attr("trackerId"), positions, completedCallback);
		} else {
			completedCallback();
		}
	};

	var _updateAffected = function(affected, trackerId, positions, completedCallback) {
		// get the size of affected
		var e = [];
		for (var k in affected) {
			if (affected.hasOwnProperty(k)) {
				e.push(k);
			}
		}
		var size = e.length;
		if (size == 0 && completedCallback) {
			completedCallback.call(positions);
		}
		var statusesPerColumns = config.statusesPerColumns[trackerId];
		var index = 0;
		var anyMoved = false;
		for (var id in affected) {
			var $card = $("#" + id);
			var newStatusId = affected[id].statusId;
			if ($card.attr("statusId") != newStatusId) {
				$card.attr("statusId", newStatusId);
				$card.find(".issueIcon").css({"background-color": affected[id].bgColor});
				$card.find(".userStoryHandle").css({"background-color": affected[id].bgColor});
				// find the lane to put the card in
				for (var column in statusesPerColumns) {
					if (statusesPerColumns[column].contains(newStatusId)) {
						$card.addClass("recentlyMoved");
						_moveRelatedCard($card, column, index, newStatusId, positions);
						index += 1;
						anyMoved = true;
						break;
					}
				}
			}

			var callback = function(data) {
				var cardId = data["cardId"];
				var $duplicates = $("[name=" + cardId + "]");
				if ($duplicates.size() > 0) {
					$duplicates.each(function() {
						var $t = $(this);
						var $sp = $t.find(".storyPoints");
						$sp.html(data["storyPoints"]);
						$sp.attr("data-points", data["storyPoints"]);
						_setGroupCounts();
					});
				}
			};
			_refreshCard(id, callback);
		}
		if (completedCallback) {
			if (anyMoved) {
				setTimeout(completedCallback, 1100 + index * 50);
			} else {
				completedCallback.call();
			}
		}
		_toggleFirstLaneAsNeeded();
	};

	var _moveRelatedCard = function($card, column, index, statusId, positions, completedCallback) {
		var $lane = $("#" + column);
		if ($lane) {
			setTimeout(function() {
				// set the card ready for moving
				$card.css($.extend($card.position(), {"position": "absolute"}));
				// animate the card to the first place of the target column
				$card.animate($lane.position(), 800, function() {
					// after the card was moved prepend it to the target column
					$card.css({"top": "", "left": "", "position": "relative"});
					if (completedCallback) {
						completedCallback.call(positions);
					}
				});
			}, 200 + index * 50);
		}
	};

	/**
	 * toggles a column with the given index.
	 *
	 * @param index
	 */
	var _toggleColumn = function(index, id) {
		var $cl = $($("tr.body > td").get(index));
		var cookie = $.cookie("codebeamer.cardboard." + config.releaseId);
		var collapsed = cookie == null ? [] : cookie.split(",");
		if ($cl.hasClass("collapsedColumn")) {
			_expandColumn(id);
			collapsed.remove(id);
		} else {
			_collapseColumn(id);
			collapsed.push(id);
		}
		$.cookie("codebeamer.cardboard." + config.releaseId, collapsed);
		_alignCollapserButtons();
		resizeCards();
	};

	var _collapseColumn = function(id) {
		var $header = $("#userStories .header td[data-id=" + id + "]");
		$header.find(".numberLabel").show();
		$header.find("div").addClass("rotate");
		$header.find(".columnCollapser").addClass("rotated");
		var groups = $(".groupHeader").size();
		$header.attr("rowspan", $("#userStories tr").size() - 1);
		$header.css({"width": ".5%"});

		$(".lane[data-id=" + id + "]").addClass("collapsedColumn");
		$(".groupHeader").each(function() {
			$($(this).find("td[data-id=" + id + "]")).addClass("collapsedColumn");
		});
		//$($("tr.body > td").get(index)).addClass("collapsedColumn");
		$(".infoHeader .minMaxInfo[data-id=" + id + "]").hide();

		resizeOpenColumns();
		_relocateSwimlaneHeader();
		_relocateLegend();

	};

	var _expandColumn = function(id) {
		var columns = $("#userStories").find(".header td");
		var $header = $(".header td[data-id=" + id + "]");
		$header.find("div").removeClass("rotate");
		$header.find(".columnCollapser").removeClass("rotated");
		$header.attr("rowspan", "1");
		$header.css({"width": (100 / columns.size()) + "%"});
		$(".lane[data-id=" + id + "]").removeClass("collapsedColumn");
		$(".groupHeader").each(function() {
			$(this).find("td[data-id=" + id + "]").removeClass("collapsedColumn");
		});
		//$($("tr.body > td").get(index)).removeClass("collapsedColumn");
		$(".infoHeader .minMaxInfo[data-id=" + id + "]").show();

		resizeOpenColumns();
		_relocateSwimlaneHeader();
		_relocateLegend();

	};

	var resizeOpenColumns = function () {
		var collapsed = $("tr.body:first").find(".collapsedColumn").size();
		var columns = $("#userStories").find(".header td").size();

		$(".lane:not(.collapsedColumn)").css({"width": (100 / (columns - collapsed)) + "%"});
	};

	var _relocateLegend = function() {
		$("#cardboard-legend").css("margin-top", $("#userStories").height() < 200 ? "200px" : "");
	};

	var _toggleSwimlane = function($swimlaneHeader) {

		var toggleUntil = function($toggleUntil) {
			if ($swimlaneHeader.hasClass("collapsed")) {
				$toggleUntil.show();
				$toggleUntil.removeClass("collapsed");
			} else {
				$toggleUntil.hide();
				$toggleUntil.addClass("collapsed");
			}
		};

		var level0 = $swimlaneHeader.hasClass("headerLevel0");
		var level1 = $swimlaneHeader.hasClass("headerLevel1");
		var level2 = $swimlaneHeader.hasClass("headerLevel2");
		var $untilLevel0 = $swimlaneHeader.nextUntil(".headerLevel0");
		if (level0) {
			toggleUntil($untilLevel0);
		} else if (level1) {
			var $nextLevel1 = $untilLevel0.filter(".headerLevel1").first();
			if ($nextLevel1.length > 0) {
				var $untilLevel1 = $swimlaneHeader.nextUntil(".headerLevel1");
				toggleUntil($untilLevel1);
			} else {
				toggleUntil($untilLevel0);
			}
		} else if (level2) {
			toggleUntil($swimlaneHeader.next("tr.body"));
		}
		$swimlaneHeader.toggleClass("collapsed");
	};

	var _relocateSwimlaneHeader = function() {
		var $collapsed = $(".lane").not(".collapsedColumn");
		// when a column gets collapsed move the swimlane headers to the next available column
		var firstOpen = $collapsed.attr("name");
		if (firstOpen) {
			_moveToColumn(".swimlaneHeader", firstOpen);
		}

		// also, move the planner icon to the LAST open column
		var lastOpen = $collapsed.last().attr("name");
		if (lastOpen) {
			_moveToColumn(".planner-link", lastOpen);
		}
	};

	var _moveToColumn = function(selector, column) {
		$(selector).each(function() {
			var p = $(this).parents("tr");
			$(p.find("td").get(column)).append($(this));
		});
	};

	/**
	 * draws the floating placeholders above some columns. target contains the
	 * column ids.
	 * @param targets
	 * @param $card
	 */
	var _drawFloatingPlaceholders = function(targets, $card) {
		if (!targets) {
			return ;
		}

		$.getJSON(contextPath + "/ajax/cardboard/getDeniedWorkflows.spr",
			{
				"issue_id": $card.attr("id")
			},
			function(data) {
				/*
				 * do not display nothing if the user finished the dragging BEFORE the rsponse to this
				 * request arrived.
				 */
				if (codebeamer.isDragging && $.isArray(data)) {
					var $rows = $(".body");
					var firstVisibleRow = $rows.filter(":visible").first();
					var firstVisibleRowIndex = $rows.index(firstVisibleRow);
					$(targets).each(function(index, target) {
						var cellsInColumn = $("[name=" + target + "].lane");
						var firstVisibleCell = $(cellsInColumn.get(firstVisibleRowIndex));
						var floatingPlaceholder = $("<div>").addClass("floatingPlaceholder acceptsDrop");
						firstVisibleCell.prepend(floatingPlaceholder);

						_realignPlaceholder(floatingPlaceholder);
						_drawStatusPlaceholder(firstVisibleCell, $card, data);
						_removeEmptyFloatingPlaceholders(floatingPlaceholder);
					});
					_addHighlightOnMouseMoveEventHandlers();
				}
			}
		);

	};

	var verticalDifference = function(elem1, elem2) {
		var top1 = $(elem1).offset().top;
		var top2 = $(elem2).offset().top;
		return Math.abs(top2 - top1);
	};

	var resizeCards = function() {
		var $lanes = $(".lane").not(".collapsedColumn");
		if ($lanes.length == 0) {
			return ;
		}
		var columnWidth = _calculateColumnWidth();
		var maxCardsPerColumn = _findMaxCardsCountInExpandedColumns();
		var parameters = _calculateOptimalParameters(maxCardsPerColumn, columnWidth - COLUMN_RIGHT_MARGIN,
			config.limits.minWidth, config.limits.maxWidth, 2, CARD_LEFT_SPACE);
		var width = parameters.cardWidth;
		$lanes.toggleClass("multiColumn", parameters.cardsPerColumn > 1);
		var height = _calculateFinalCardHeight(width);
		$(".userStory,.hiddenUserStory").width(width).height(height);
		$(".userStory .card-content,.hiddenUserStory .card-content").width(width - 10).height(height - 10);
	};

	var _checkCounts = function($columns) {
		var id = $columns.first().attr("name");
		var $header = $(".infoHeader #info_" + id);
		var unfilteredCount = $header.data("unfilteredcount");
		var count = unfilteredCount > 0 ? unfilteredCount : $columns.find(".userStory").not(".hiddenUserStory").size();
		$header.removeClass("belowMin");
		$header.removeClass("aboveMax");
		var minimum = $header.find(".minimum").val();
		var maximum = $header.find(".maximum").val();
		if (minimum && minimum.length > 0 && minimum > count) {
			$header.addClass("belowMin");
			$header.find(".minMaxInfo").html("<span>" + i18n.message("tracker.view.layout.cardboard.freeCapacity.message") + "</span>");
		} else if (maximum && maximum.length > 0 && maximum < count) {
			$header.addClass("aboveMax");
			$header.find(".minMaxInfo").html("<span>" + i18n.message("tracker.view.layout.cardboard.overloaded.message") + "</span>");
		}
	};

	var _checkAllCounts = function() {
		$("tr.body .lane:not(.grouped)").each(function() {
			_checkCounts($(this));
		});
		// If swimlanes used, we have to aggregate the count of columns with the same dataId
		var $grouped = $("tr.body .lane.grouped");
		if ($grouped.length > 0) {
			var dataIds = [];
			$grouped.each(function() {
				var dataId = $(this).data("id");
				if ($.inArray(dataId, dataIds) == -1) {
					dataIds.push(dataId);
				}
			});
			for (var i = 0; i < dataIds.length; i++) {
				var currentDataId = dataIds[i];
				var $columns = $();
				$grouped.filter('[data-id="' + currentDataId + '"]').each(function() {
					$columns = $columns.add($(this));
				});
				_checkCounts($columns);
			}
		}

	};

	var _setGroupCounts = function() {
		var $headers = $(".groupHeader");
		var $usedHeaders = $();
		$headers.each(function() {
			var $group = $(this).next("tr.body");
			if ($group.length > 0) {
				var count = $group.find(".userStory").not(".hiddenUserStory").size();
				$(this).find(".groupCount").html(count);
				$usedHeaders = $usedHeaders.add($(this));
			}
		});

		var $headerTds = $(".header td");
		var $bodyTds = $(".body td");
		var icon = '<span class="storyPointsIcon"></span>';

		for (var i = 0; i < $headerTds.size(); i++) {
			var sum = 0;
			var name = $($headerTds.get(i)).data("name");
			$($bodyTds.get(i)).find("[data-points]:not(.ignore)").each(function() {
				sum += parseInt($(this).attr("data-points"));
			});
			var $label = $($($headerTds.get(i)).find(".storyPointsLabel"));
			$label.html(sum + icon);
			if (sum == 0) {
				$label.hide();
			} else {
				$label.show();
			}
		}

		$headers.each(function() {
			var $group = $(this).next("tr");
			var $storiesWithPoint = $group.find("[data-points]");
			var sum = 0;
			$storiesWithPoint.each(function() {
				sum += parseInt($(this).attr("data-points"), 10);
			});
			var $label = $(this).find(".storyPointsLabel");
			$label.attr("data-points", sum);
			$label.html(sum + icon);
			if (sum == 0) {
				$label.hide();
			} else {
				$label.show();
			}
		});


		var setAggregatedCount = function($levelHeader, $allLevelHeaders) {
			var allGroupCount = 0;
			$allLevelHeaders.each(function() {
				allGroupCount += parseInt($(this).find(".groupCount").text(), 10);
			});
			$levelHeader.find(".groupCount").html(allGroupCount);

			var storyPointsCount = 0;
			$allLevelHeaders.each(function() {
				storyPointsCount += parseInt($(this).find(".storyPointsLabel").attr("data-points"), 10);
			});
			var $storyPointsLabel = $levelHeader.find(".storyPointsLabel");
			$storyPointsLabel.html(storyPointsCount + icon);
			$storyPointsLabel.attr("data-points", storyPointsCount);
			if (storyPointsCount == 0) {
				$storyPointsLabel.hide();
			} else {
				$storyPointsLabel.show();
			}
		};

		var countTopHeaders = false;
		$usedHeaders.each(function() {
			var $previousHeader = $(this).prev(".groupHeader");
			if ($previousHeader.length > 0) {
				if ($previousHeader.hasClass("headerLevel1")) {
					var $untilLevel0 = $previousHeader.nextUntil(".headerLevel0");
					var $nextLevel1 = $untilLevel0.filter(".headerLevel1").first();
					if ($nextLevel1.length > 0) {
						var $untilLevel1 = $previousHeader.nextUntil(".headerLevel1");
						var $level2Headers = $untilLevel1.filter(".headerLevel2");
						setAggregatedCount($previousHeader, $level2Headers);
					} else {
						var $level2Headers = $untilLevel0.filter(".headerLevel2");
						setAggregatedCount($previousHeader, $level2Headers);
					}
					countTopHeaders = true;
				} else if ($previousHeader.hasClass("headerLevel0")) {
					var $untilLevel0 = $previousHeader.nextUntil(".headerLevel0");
					var $level1Headers = $untilLevel0.filter(".headerLevel1");
					setAggregatedCount($previousHeader, $level1Headers);
				}
			}
		});

		if (countTopHeaders) {
			var $level0Headers = $headers.filter(".headerLevel0");
			$level0Headers.each(function() {
				var $untilLevel0 = $(this).nextUntil(".headerLevel0");
				var $level1Headers = $untilLevel0.filter(".headerLevel1");
				setAggregatedCount($(this), $level1Headers);
			});
		}
	};

	var _setupCardSelectability = function($cards) {
		($cards || $(".userStory")).each(function() {
			var card = $(this);
			card.click(function() {
				var id = $(this).attr("id");
				_selectCard(id);
			});
			card.find("a").click(function(e) {
				e.stopPropagation();
			});
		});
	};

	var _selectCard = function(id, select) {
		var card = $(".userStory[id=" + id + "]");
		$(".userStory").not(card).removeClass("selected");
		card.toggleClass("selected", select);
	};

	var _cancel = function(itemId) {
		$(config.sortableSelector).sortable("cancel");
	};

	var _updated = function(cardId) {
		var $card = $("#" + cardId);
		_refreshCard(cardId, function(data) {
			var valueId = data["statusId"];
			_afterUpdate($card, valueId, data);
		});
	};

	var _countColumns = function() {
		return $("#userStories").find("tr.header").children("td").length;
	};

	var _countCollapsedColumns = function() {
		return $("#userStories").find("tr.header").find("> td > .rotate").length;
	};

	var _findMaxCardsCountInExpandedColumns = function() {
		var max = 0;
		var lanes = $(".lane").not(".collapsedColumn");
		lanes.each(function() {
			var lane = $(this);
			var cardCount = lane.find(".userStory").length;
			if (cardCount > max) {
				max = cardCount;
			}
		});
		return max;
	};

	var _calculateColumnWidth = function() {
		var collapsedColumnCount = _countCollapsedColumns();
		var expandedColumnCount = _countColumns() - collapsedColumnCount;
		var spaceNeededForCollapsedColumns = collapsedColumnCount * 50;
		var spaceRemainingForExpandedColumns = $("#cardboard").width() - spaceNeededForCollapsedColumns;
		return Math.max(spaceRemainingForExpandedColumns / expandedColumnCount, config.limits.minWidth);
	};

	var _calculateFinalCardHeight = function(width) {
		var height = Math.floor(width / WIDTH_TO_HEIGHT_RATIO);
		if (height < MINIMUM_CARD_HEIGHT) {
			height = MINIMUM_CARD_HEIGHT;
		}
		return height;
	};

	var _calculateOptimalParameters = function(maxCardsPerColumn, columnWidth, minWidth, maxWidth, step, extraSpacePerCard) {
		var minCardsPerColumn = Math.floor(columnWidth / maxWidth);
		if (maxCardsPerColumn <= minCardsPerColumn) {
			maxCardsPerColumn = minCardsPerColumn;
		}
		var bestCardsPerColumn = 1;
		var bestCardWidth = maxWidth;
		var smallestError = 1000000;
		for (var i = minCardsPerColumn; i <= maxCardsPerColumn; i++) {
			for (var w = minWidth; w < maxWidth; w += step) {
				var error = columnWidth - (w + extraSpacePerCard) * i;
				if (error >= 0 && error < smallestError) {
					smallestError = error;
					bestCardsPerColumn = i;
					bestCardWidth = w;
				}
			}
		}
		return {
			"cardsPerColumn": bestCardsPerColumn,
			"cardWidth": bestCardWidth
		};
	};

	var sendToReview = function (mergeRequest) {
		var $cards = $(".userStory");
		if ($cards.size() == 0) {
			showFancyAlertDialog("There are no items to review on the current board");
			return;
		}

		var ids = $cards.map(function() {return this.id}).toArray().join(",");

		var urlAction = mergeRequest ? 'createMergeRequest' : 'createTrackerItemReview';
		var url = contextPath + "/review/create/" + urlAction + ".spr?reviewType=trackerItemReview" + "&sourceIds=" + ids;
		showPopupInline(url, {geometry: 'large'});
	};

	var checkLimit = function() {
		if ($("#trimmed").size() > 0) {
			$("#globalMessages").show();
			GlobalMessages.showWarningMessage(i18n.message("cardboard.display.maximum", getConfig().maximumCards));
		} else {
			$("#globalMessages").hide();
		}
	};

	var setupDetailsLinks = function($target) {
		if (!$target) {
			$target = $(".userStory");
		}

		$target.find(".cardLink").click(function (e) {
			if (e.ctrlKey) {
				e.preventDefault();
				window.open($(this).data("detailsUrl"), "_blank");
			}
		});
	};

	var reportSelectorTagCallback = function($container, result) {
		init();
		// _updatePermanentLink(requestParams);
		// _storeSelection(requestParams);
		checkLimit();
		_setupDetailsLinks();
		// TODO
	};

	var initializeStickyTableHeader = function() {

		codebeamer.sticky.destroyAll();

		codebeamer.sticky.makeTableHeaderSticky({
			headerRow: $("#userStories .header"),
			columnTag: "td",
			afterClone: function($stickyTableHeader) {
				var $stickyTable = $("<table>", {"class": "userStories"});

				$stickyTable.append($("<tbody>").append($stickyTableHeader));
				$stickyTableHeader.find(".columnCollapser").remove();

				return $stickyTable;
			},
			dynamic: true,
			offset: 32,
			handler: function(direction, $tableHeader, $stickyTable) {
				var classes, divs;

				classes = [];

				divs = $tableHeader.find("td>div");

				divs.each(function() {
					classes.push($(this).attr("class"));
				});

				$stickyTable.find("td>div").each(function(index) {
					if (classes[index]) {
						$(this).removeClass().addClass(classes[index]);
					}
				});

				if ($stickyTable.hasClass("stuck")) {
					divs.css("visibility", "hidden");
				} else {
					divs.css("visibility", "visible");
				}

			}
		});

	};

	var afterMassReleaseUpdate = function(currentReleaseId, newReleaseId) {
		var $moreMenu = $(".extendedCardboardMoreMenu");
		$(".reportSelectorTag").first().find(".searchButton").click();
		$.contextMenu("destroy", "#" + $moreMenu.attr("id"));
		$moreMenu.removeData("menujson");
		$moreMenu.removeClass("menu-downloaded");
	};

	return {
		"setConfig": setConfig,
		"getConfig": getConfig,
		"extendConfigWith": extendConfigWith,
		"init": init,
		"selectCard": _selectCard,
		"cancelHandler": _cancel,
		"updateHandler": _updated,
		"sendToReview": sendToReview,
		"checkLimit" : checkLimit,
		"setupDetailsLinks" : setupDetailsLinks,
		"reportSelectorTagCallback" : reportSelectorTagCallback,
		"afterMassReleaseUpdate": afterMassReleaseUpdate
	};
})(jQuery);
