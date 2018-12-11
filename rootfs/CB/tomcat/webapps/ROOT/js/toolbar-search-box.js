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
codebeamer.toolbar = codebeamer.toolbar || (function($) {

	function isFullSizeSearchFieldSupported(cont) {
		return !hasVerticalScrollbar(cont.closest(".toolbar")) && (cont.closest(".toolbarIconContainer").width() - cont.closest(".searchBoxContainer").siblings(".userLinkContainer").width()) >= 205;
	}

	function isCurrentTargetMultiSelectDialog(e) {
		var $multiSelect;

		$multiSelect = $(e.target).closest(".ui-multiselect-menu");

		return $multiSelect.size() > 0 ? true : false;
	}

	function cancelEditingAndClose(input, searchButton) {
		input.val("");
		searchButton.click();
	}

	function openDropdown(searchOptions, container, state) {
		if (isDropdownClosed(searchOptions)) {
			searchOptions.fadeIn(200, function() {
				searchOptions.data("open", true);
			});

			if (!state.isDropdownInitialized) {
				state.isDropdownInitialized = true;

				searchOptions.position({
					my: "left top",
					at: "left bottom+5",
					collision: "flipfit",
					of: container
				});
			}

		}
	}

	function closeDropdown(searchOptions, animate) {
		if (!isDropdownClosed(searchOptions)) {
			searchOptions.fadeOut(animate ? 200 : 0, function() {
				searchOptions.data("open", false);
			});
		}
	};

	var closeDropdownOnResize = function(searchOptions, input, dropdownState) {
		if (!$.browser.mobile) {
			dropdownState.isDropdownInitialized = false;
			input.blur();
			closeDropdown(searchOptions);
		}
	};

	function isDropdownClosed(searchOptions) {
		var result = true;

		if (searchOptions.data("open") && searchOptions.data("open") === true) {
			result = false;
		}

		return result;
	}

	function toggleDropdown(searchOptions, container, dropdownState) {
		if (isDropdownClosed(searchOptions)) {
			openDropdown(searchOptions, container, dropdownState);
		} else {
			closeDropdown(searchOptions);
		}
	}

	function handleSearchRequest(input, searchButton) {
		var term = $.trim(input.val());

		if (term) {
			searchButton.click();
		} else {
			input.focus();
			input.closest(".searchContainer").css("border-color", "#b31317");
		}
	}

	function disableButton(button) {
		$(button).attr("disabled", "disabled");
	}

	function enableButton(button) {
		$(button).removeAttr("disabled");
	}

	function removeRedBorder(cont) {
		cont.css("border-color", "");
	}

	function getMultiselectValuesAsString(select) {
		var result, checked, i;

		result = [];

		if (select) {
			checked = select.multiselect("getChecked").serializeArray();

			if (checked && checked.length > 0) {
				for (i = 0; i < checked.length; i++) {
					result.push(checked[i].value);
				}
			}
		}

		return result;
	}

	function loadFiltersAndSearch(searchOptions) {
		var currentProjectFilter, selectedProjects;

		currentProjectFilter = "";
		selectedProjects = getMultiselectValuesAsString(searchOptions.find(".projectIdSelector"));
		if (selectedProjects && selectedProjects.length > 0) {
			for (i = 0; i < selectedProjects.length; i++) {
				if (currentProjectFilter) {
					currentProjectFilter = currentProjectFilter + ",";
				}
				currentProjectFilter = currentProjectFilter + selectedProjects[i];
			}
		}
		searchOptions.find('input[name="projId"]').val(currentProjectFilter);

		submitSearchForm(searchOptions);
	}

	function submitSearchForm(searchOptions) {
		searchOptions.closest("form").trigger("submit");
	}

	function reloadMultiselectWithGroups($element, data) {
		var selectOptionGroup, $selectOptionGroup, selectOption, $selectOption, i, j;

		if (data && $.isArray(data)) {
			for (i = 0; i < data.length; i++) {
				selectOptionGroup = data[i];
				$selectOptionGroup = $("<optgroup label='" + selectOptionGroup.name + "'></optgroup>");
				$element.append($selectOptionGroup);

				for (j = 0; j < selectOptionGroup.options.length; j++) {
					selectOption = selectOptionGroup.options[j];
					$selectOption = "<option value='" + selectOption.id +"'";
					if (selectOption.selected) {
						$selectOption = $selectOption + " selected='selected '>";
					} else {
						$selectOption = $selectOption + "'>";
					}
					$selectOption = $selectOption + selectOption.value + "</option>";

					$selectOptionGroup.append($($selectOption));
				}

			}

			$element.multiselect("refresh");
		}
	}

	function reloadMultiselect($element, data) {
		var selectOption, $selectOption, i, j;

		if (data && $.isArray(data)) {
			for (i = 0; i < data.length; i++) {
				selectOption = data[i];

				$selectOption = "<option value='" + selectOption.id +"'";
				if (selectOption.selected) {
					$selectOption = $selectOption + " selected='selected '>";
				} else {
					$selectOption = $selectOption + "'>";
				}
				$selectOption = $selectOption + selectOption.value + "</option>";

				$element.append($($selectOption));

			}

			$element.multiselect("refresh");
		}
	}

	function preloadProjectSelector(selector) {
		$.ajax({
			type: "GET",
			url: contextPath + "/ajax/search/preloadProjects.spr",
			async: false,
			success: function(data) {
				reloadMultiselect($(selector), data);
			}
		});
	}

	function initProjectSelector(selector, hideByDefault, extraClasses) {
		var classes, initialized = false;

		classes = "searchBoxProjectSelector";
		if (extraClasses) {
			classes = classes + " " + extraClasses;
		}

		$("#" + selector.attr("id")).multiselect({
			classes: classes,
			header: true,
            multiple: true,
			selectedList: 5,
			checkAllText: "",
			uncheckAllText: "",
			noneSelectedText: i18n.message("search.project.default.value"),
			beforeopen: function(event, ui) {
				var $element = $("#" + selector.attr("id"));

				$element.empty();

				if (!initialized) {
					$.ajax({
						type: "GET",
						url: contextPath + "/ajax/search/getProjects.spr",
						async: false,
						success: function(data) {
							reloadMultiselectWithGroups($element, data);
							initialized = true;
						}
					});
				}

			}
        }).multiselectfilter({
			label: "",
			placeholder: i18n.message("Filter")
		});

		if (hideByDefault) {
			selector.multiselect("widget").hide();
		}
	}

	function initClearAllLink(searchOptions) {
		var $searchOptions = $(searchOptions);

		$searchOptions.find(".clearAllLink").on("click", function(event) {
			$searchOptions.find("input[name=searchOnArtifact]").removeAttr("checked");
			event.preventDefault();
			event.stopPropagation();
		});

	}

	function initGoToHistoryLink(searchOptions) {
		var $searchOptions = $(searchOptions);

		$searchOptions.find(".goToHistoryLink").on("click", function(event) {
			closeDropdown($searchOptions, false);
			inlinePopup.show(contextPath + "/history.do");
			event.preventDefault();
			event.stopPropagation();
		});
	}

	function initCombinedListElement(searchOptions) {
		var $searchOptions = $(searchOptions);

		$searchOptions.find(".combinedListElement").on("click", function(event) {
			var checked, $hiddenElement, $combinedListElement;

			$hiddenElement = $searchOptions.find(".hiddenListElement input[type=checkbox]");
			$combinedListElement = $searchOptions.find(".combinedListElement input[type=checkbox]");
			checked = $combinedListElement.attr("checked");

			if (checked) {
				$hiddenElement.attr("checked", "checked");
			} else {
				$hiddenElement.removeAttr("checked");
			};
		});

		var initTrackerItemCheckbox = function ($checkbox) {
			var checked = $checkbox.is(':checked');

			$(".inputContainer input[name=searchOnArtifact][value=32]").prop("disabled", !checked);
			$(".inputContainer input[name=searchOnArtifact][value=1024]").prop("disabled", !checked);
		};

		var $trackerCheckbox = $(".inputContainer input[name=searchOnArtifact][value=4]");
		$trackerCheckbox.change(function () {
			initTrackerItemCheckbox($(this));
		});
	}

	function initCollapsedSearchField(container) {

		var $ = jQuery;

		var cont = $(container);
		var toolbar = cont.closest(".toolbar");
		var input = cont.find(".searchInput");
		var searchButton = cont.find(".toggleButton");
		var searchOptions = cont.siblings(".searchOptions");
		var dropdownState = {
			isDropdownInitialized: false
		};

		var cancelIfClickedOutside = function() {
			$(document).mouseup(function(e) {
				if (!cont.is(e.target) // if the target of the click isn't the container
					&& cont.has(e.target).length === 0 // nor a descendant of the container
					&& !$(e.target).is(".date-filters a") // clicking on a date filter must keep the box open
					&& !searchOptions.is(e.target)
					&& searchOptions.has(e.target).length === 0
					&& !isCurrentTargetMultiSelectDialog(e))
				{
					removeRedBorder(cont);
					if (isFullSizeSearchFieldSupported(cont)) {
						closeDropdown(searchOptions);
					} else {
						cancelEditingAndClose(input, searchButton);
					}
				}
			});
		};


		var toggleCollapsedSearchField = function(event, preventOpeningDropdown) {
			if (!cont.hasClass("anim-in-progress")) {
				if (!isFullSizeSearchFieldSupported(cont)) {
					cont.addClass("anim-in-progress");
				}
				var inner = cont.find(".searchField");
				var closedWidth = searchButton.width();
				var duration = 150;

				var afterInnerElementOpenAnimationFinished = function() {
					cont.removeClass("anim-in-progress");
					cancelIfClickedOutside();
				};

				var afterInnerElementCloseAnimationFinished = function() {
					cont.removeClass("anim-in-progress").css("position", "static");
					$(document).unbind("mouseup");
					cont.prop("clone").remove();
					toolbar.unbind("scroll");
				};

				var close = function() {
					var oldWidth = cont.width();

					cont.data("original-width", oldWidth);
					cont.animate({width: closedWidth + "px"}, duration);
					inner.animate({marginLeft: (-oldWidth + closedWidth) + "px"}, duration, afterInnerElementCloseAnimationFinished);

					closeDropdown(searchOptions);
				};

				var open = function(animate) {
					var newWidth = cont.data("original-width");
					var right = toolbar.width() - cont.offset().left - cont.outerWidth() - parseInt(cont.css("margin-right"));
					var clone = cont.clone().css("visibility", "hidden").insertBefore(cont);

					clone.find("input").attr("disabled", "true");

					cont.css({
						"position": "absolute",
						"right": right,
						"top": cont.offset().top
					});

					if (animate) {
						cont.animate({width: newWidth + "px"}, duration).prop({
							"clone": clone,
							"originalScrollLeft": toolbar.scrollLeft()
						});
						inner.animate({marginLeft: "0px"}, duration, function() {
							afterInnerElementOpenAnimationFinished();
							input.focus();
							openDropdown(searchOptions, cont, dropdownState);
						});
					} else {
						cont.css("width", newWidth + "px").prop({
							"clone": clone,
							"originalScrollLeft": toolbar.scrollLeft()
						});
						inner.css("margin-left", "0px");
						afterInnerElementOpenAnimationFinished();
					}

					toolbar.scroll(function() {
						var originalScrollLeft = cont.prop("originalScrollLeft");
						cont.css("right", right + ($(this).scrollLeft() - originalScrollLeft));
					});

				};

				if (cont.is(".closed")) {
					open(isFullSizeSearchFieldSupported(cont) ? false : true);
					cont.toggleClass("closed");
				} else {
					// search field is already opened, if term is not empty, button should function as a submit button
					var term = $.trim(input.val());
					if (term.length > 0) {
						loadFiltersAndSearch(searchOptions);
					} else {
						removeRedBorder(cont);
						if (isFullSizeSearchFieldSupported(cont)) {
							if (!preventOpeningDropdown) {
								toggleDropdown(searchOptions, cont, dropdownState);
							}
						} else {
							close();
							cont.toggleClass("closed");
						}
					}
				}
			}

			return false;
		};

		var closeCollapsedSearchBoxDropdownOnResize = function() {
			if ($("body").hasClass("headerCollapsed")) {
				closeDropdownOnResize(searchOptions, input, dropdownState);
			}
		};

		var collapseOnResize = function() {
			if (!$.browser.mobile && $("body").hasClass("headerCollapsed")) {
				removeRedBorder(cont);
				// Close the search box, when changing the screen to small
				if (!isFullSizeSearchFieldSupported(cont) && !cont.is(".closed")) {
					cancelEditingAndClose(input, searchButton);
				} else {
					// Open the search box, when changing the screen to large
					if (isFullSizeSearchFieldSupported(cont) && cont.is(".closed")) {
						cancelEditingAndClose(input, searchButton);
					}
				}
			}
		};

		var openSearchBoxByDefault = function() {
			toggleCollapsedSearchField(null, true);
			cont.removeClass("anim-in-progress");
			cont.closest(".searchBoxContainer").css("opacity", 1);
		};

		var toggleOnHeaderVisibilityChange = function(event, isHeaderHidden) {
			if (isHeaderHidden) {
				if (isFullSizeSearchFieldSupported(cont)) {
					openSearchBoxByDefault();
				} else {
					cont.closest(".searchBoxContainer").css("opacity", 1);
				}
			} else {
				cont.closest(".searchBoxContainer").css("opacity", 0);
			}
		};

		$(function() {
			var preloadedProjects = false;

			searchButton.click(toggleCollapsedSearchField);

			// Open the search field by default on large screens
			toggleOnHeaderVisibilityChange(null, $("body").hasClass("headerCollapsed"));

			$("body").on("header:visibility:change", toggleOnHeaderVisibilityChange);

			input.on("focus", function() {
				if (!preloadedProjects) {
					preloadProjectSelector(cont.siblings(".searchOptions").find(".projectIdSelector"));
					preloadedProjects = true;
				}
				openDropdown(searchOptions, cont, dropdownState);
			});

			input.keyup(function(e) {
				if (e.keyCode == 13) {
					handleSearchRequest(input, searchButton);
					disableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
					e.stopPropagation();
					e.preventDefault();
				} else {
					if (e.keyCode == 27) {
						input.val("");
						searchButton.click();
					} else {
						removeRedBorder(cont);
						enableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
					}
				}
			});

			input.on("input", function(event) {
				removeRedBorder(cont);
				enableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
			});

			$(window).resize(throttleWrapper(closeCollapsedSearchBoxDropdownOnResize, 10));
			$(window).resize(throttleWrapper(collapseOnResize, 200));

			initProjectSelector(searchOptions.find(".projectIdSelector"), true);

			cont.siblings(".searchOptions").find(".searchOptionsButton").click(function() {
				handleSearchRequest(input, searchButton);
				disableButton($(this));
			});
		});
	}

	function initSearchField(container) {

		var $ = jQuery;

		var cont = $(container);
		var input = cont.find(".searchInput");
		var searchButton = cont.find(".toggleButton");
		var searchOptions = cont.siblings(".searchOptions");
		var dropdownState = {
			isDropdownInitialized: false
		};

		var cancelIfClickedOutside = function() {
			$(document).mouseup(function(e) {
				if (!cont.is(e.target) // if the target of the click isn't the container
					&& cont.has(e.target).length === 0 // nor a descendant of the container
					&& !$(e.target).is(".date-filters a") // clicking on a date filter must keep the box open
					&& !searchOptions.is(e.target)
					&& searchOptions.has(e.target).length === 0
					&& !isCurrentTargetMultiSelectDialog(e))
				{
					removeRedBorder(cont);
					closeDropdown(searchOptions);
					input.val("");
				}
			});
		};

		var toggleSearchField = function() {
			var term = $.trim(input.val());
			if (term.length > 0) {
				loadFiltersAndSearch(searchOptions);
			} else {
				removeRedBorder(cont);
				toggleDropdown(searchOptions, cont, dropdownState);
			}

			return false;
		};

		var toggleOnHeaderVisibilityChange = function(event, isHeaderHidden) {
			if (isHeaderHidden) {
				closeDropdown(searchOptions);
			}
		};

		var closeSearchBoxDropdownOnResize = function() {
			closeDropdownOnResize(searchOptions, input, dropdownState);
		};

		$(function() {
			var preloadedProjects = false;

			searchButton.on("click", toggleSearchField);

			cancelIfClickedOutside();

			$("body").on("header:visibility:change", toggleOnHeaderVisibilityChange);

			input.on("focus", function() {
				if (!preloadedProjects) {
					preloadProjectSelector(cont.siblings(".searchOptions").find(".projectIdSelector"));
					preloadedProjects = true;
				}
				openDropdown(searchOptions, cont, dropdownState);
			});

			input.keyup(function(e) {
				if (e.keyCode == 13) {
					handleSearchRequest(input, searchButton);
					disableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
					e.stopPropagation();
					e.preventDefault();
				} else {
					if (e.keyCode == 27) {
						input.val("");
						searchButton.click();
					} else {
						removeRedBorder(cont);
						enableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
					}
				}
			});

			input.on("input", function(event) {
				removeRedBorder(cont);
				enableButton(cont.siblings(".searchOptions").find(".searchOptionsButton"));
			});

			cont.siblings(".searchOptions").find(".searchOptionsButton").click(function() {
				handleSearchRequest(input, searchButton);
				disableButton($(this));
			});

			cont.closest("form").submit(function(e) {
				var term = $.trim(input.val());

				if (!term) {
					e.preventDefault();
				}
			});

			initProjectSelector(searchOptions.find(".projectIdSelector"), true);

			$(window).resize(throttleWrapper(closeSearchBoxDropdownOnResize, 10));
		});

	}

	function handleSubmit($container) {
		// Manipulate project ids from multiselect to be able to submit correctly
		$container.submit(function() {
			var checked = $("#searchPageProjectSelector").val();
			if (checked) {
				$("#selectedProjectIds").val(checked.join(","));
			}
			$("#searchPageProjectSelector").val("");
			$('input[name="_projIdList"]').remove();
			return true;
		});
	}

	return {
		initCollapsedSearchField: initCollapsedSearchField,
		initSearchField: initSearchField,
		initProjectSelector: initProjectSelector,
		preloadProjectSelector: preloadProjectSelector,
		initClearAllLink: initClearAllLink,
		initGoToHistoryLink: initGoToHistoryLink,
		initCombinedListElement: initCombinedListElement,
		handleSubmit: handleSubmit
	};
})(jQuery);