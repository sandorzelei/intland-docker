function _computeRequestParams() {
	var requestParams = {
		"groupByFieldId": -1,
		"subjectId": codebeamer.cardboard.getConfig().originalReleaseId
	};

	if ($("#groupBySelector")) {
		requestParams["swimlanes"] = $("#groupBySelector").val();
	}

	var roleIds = [];
	var userIds = [];
	var typeIds = [];
	var domains = [];
	var teams = [];
	var viewId;

	$("#roleSelector").multiselect("getChecked").each(function() {
		var $li = $(this).parents("li");
		if ($li.is(".modified-in")) {
			requestParams["modifiedIn"] = this.value;
		} else if ($li.is(".release")) {
			requestParams[codebeamer.cardboard.getConfig().type == "release" ? "subjectId" : "releaseId"] = this.value;
		} else if ($li.is(".user")) {
			userIds.push(this.value);
		} else if ($li.is(".role")) {
			roleIds.push(this.value);
		} else if ($li.is(".type")) {
			typeIds.push(this.value);
		} else if ($li.is(".domain")) {
			domains.push(this.value);
		}  else if ($li.is(".team")) {
			teams.push(this.value);
		} else if ($li.is(".view")) {
			viewId = this.value;
		}
	});

	if (userIds.length > 0) {
		requestParams["userIds"] = userIds.join(",");
	}

	if (roleIds.length > 0) {
		requestParams["roleIds"] = roleIds.join(",");
	}

	if (typeIds.length > 0) {
		requestParams["typeIds"] = typeIds.join(",");
	}

	if (domains.length > 0) {
		requestParams["domains"] = domains.join(",");
	}

	if (teams.length > 0) {
		requestParams["teams"] = teams.join(",");
	}

	if (viewId) {
		requestParams["view_id"] = viewId;
	}

	return requestParams;
}

function submitForm(callback) {
	inlinePopup.close();
	var $reportSelector = $(".reportSelectorTag");
	if ($reportSelector.length > 0) {
		$reportSelector.first().find(".searchButton").click();
	} else {
		var bs = ajaxBusyIndicator.showBusyPage();
		var requestParams = _computeRequestParams();
		$.ajax({
			"url": contextPath + "/proj/tracker/quickFilterCardboardView.spr",
			"type": "GET",
			"data": requestParams,
			"success": function(data) {
				if (bs) {
					ajaxBusyIndicator.close(bs);
				}
				$("#cardboard").html(data);
				codebeamer.cardboard.init();
				_updatePermanentLink(requestParams);
				_storeSelection(requestParams);
				_checkLimit();
				_setupDetailsLinks();
				if ($.isFunction(callback)) {
					callback.call();
				}
			},
			"error": function() {
				if (bs) {
					ajaxBusyIndicator.close(bs);
				}
			}
		});
	}
}

function _checkLimit() {
	codebeamer.cardboard.checkLimit();
}

function _setupDetailsLinks($target) {
	codebeamer.cardboard.setupDetailsLinks($target);
}

function _updatePermanentLink(requestParams) {
	var releaseId = requestParams["releaseId"];
	if (!releaseId) {
		releaseId = codebeamer.cardboard.getConfig().releaseId;
	}
	var url = contextPath + codebeamer.cardboard.getConfig().baseUrl;
	var urlParams = "";
	if (requestParams["swimlanes"]) {
		urlParams += "swimlanes=" + requestParams["swimlanes"];
	}

	if (requestParams["roleIds"]) {
		urlParams += "&roleIds=" + requestParams["roleIds"];
	}

	if (requestParams["userIds"]) {
		urlParams += "&userIds=" + requestParams["userIds"];
	}

	if (requestParams["modifiedIn"] && requestParams["modifiedIn"] != "") {
		urlParams += "&modifiedIn=" + requestParams["modifiedIn"];
	}

	if (requestParams["typeIds"]) {
		urlParams += "&typeIds=" + requestParams["typeIds"];
	}

	if (urlParams.length > 0) {
		var alreadyHasParameters = url.indexOf('?') >= 0;
		url += (alreadyHasParameters ? "&" : "?") + urlParams;
	}

	$("a.permaLink").attr("href", url);

	History.pushState({}, i18n.message("tracker.view.layout.cardboard.for.release.label", $("#roleSelector [value=" + releaseId + "]").text()), url);
}

function _storeSelection(requestParams) {
	var cookies = ["roleIds", "userIds", "typeIds", "modifiedIn"];
	$.each(cookies, function(index, name) {
		var value = "";
		if (requestParams[name] != "") {
			value = requestParams[name];
		}
		$.cookie("codebeamer.cardboard." + codebeamer.cardboard.getConfig().releaseId + "." + name, value); // TODO: remove global
	});
}

function _restoreSelection() {
	var anythingChecked = $(".modified-in :checkbox:checked, .user :checkbox:checked, .role :checkbox:checked, .type :checkbox:checked, .view :checkbox:checked").size() > 0;

	if (!anythingChecked) {
		var modifiedInCookie = $.cookie("codebeamer.cardboard." + codebeamer.cardboard.getConfig().releaseId + ".modifiedIn");
		var userCookie = $.cookie("codebeamer.cardboard." + codebeamer.cardboard.getConfig().releaseId + ".userIds");
		var roleCookie = $.cookie("codebeamer.cardboard." + codebeamer.cardboard.getConfig().releaseId + ".roleIds");
		var typeCookie = $.cookie("codebeamer.cardboard." + codebeamer.cardboard.getConfig().releaseId + ".typeIds");

		if (modifiedInCookie) {
			$(".modified-in :checkbox:checked").click();
			$(".modified-in :checkbox[value=" + modifiedInCookie + "]").click();
		}

		if (userCookie) {
			$(".user :checkbox:checked").click();
			var ids = userCookie.split(",");
			for (var i = 0; i < ids.length; i++) {
				$(".user :checkbox[value=" + ids[i] + "]").click();
			}
		}

		if (roleCookie) {
			$(".role :checkbox:checked").click();
			var ids = roleCookie.split(",");
			for (var i = 0; i < ids.length; i++) {
				$(".role :checkbox[value=" + ids[i] + "]").click();
			}
		}

		if (typeCookie) {
			$(".type :checkbox:checked").click();
			var ids = typeCookie.split(",");
			for (var i = 0; i < ids.length; i++) {
				$(".type :checkbox[value=" + ids[i] + "]").click();
			}
		}
	}

	if (anythingChecked || $(".release :checkbox:checked").size() > 0) {
		$(".ui-multiselect-menu :checkbox:checked").each(function() {
			$(this).siblings(".checker").addClass("checked");
		});
	}
}

function showApplyButton() {
	$(".ui-multiselect-header").show();
}

function showHideClearers() {
	$("li.ui-multiselect-optgroup").each(function() {
		var $this = $(this);
		var $items = $this.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
		var hasChecked = $items.find(":checkbox:checked").size() > 0;
		if (hasChecked) {
			$this.find(".optgroup-clearer").show();
		} else {
			$this.find(".optgroup-clearer").hide();
		}
	});
}

function selectOne(value, cssClass) {
	$("#roleSelector").multiselect("widget").find("." + cssClass + " :checkbox:checked").each(function() {
		var $this = $(this);
		if ($this.val() != value && $this.is(":checked")) {
			$this.attr("checked", false);
			$this.siblings(".checker").removeClass("checked");
		}
	});
}

var hashParams = UrlUtils.getHashParameters();

jQuery(function($) {
	var clearFilter = function () {
		var $allListElements = $('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)');
		$allListElements.show();
		$("#optionFilter").val("");
	};

	function setTeamColors() {
		var selector, colorMap, teamListElements;

		colorMap = {};
		selector = $("#roleSelector optgroup[label=Teams] option");

		selector.each(function(index, element) {
			var $element = $(element);

			colorMap[$element.attr("value")] = $element.data("color");
		});

		inputs = $(".ui-multiselect-menu li.team input");

		inputs.each(function(index, element) {
			var $element = $(element);
			$element.siblings(".checker").css("background-color", colorMap[$element.attr("value")]);
		});
	}

	$("#roleSelector").multiselect({
		"header": "Apply",
		"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
		"height": 245,
		"close": function () {
			clearFilter();
		},
		"open": function () {
			$("#optionFilter").focus();
		},
		"create": function() {
			// move the header to the bottom
			var $header = $(".ui-multiselect-header");
			$(".ui-multiselect-menu").append($header);
			$header.find("ul").addClass("button");
			$header.click(function() {
				submitForm();
				$("#roleSelector").multiselect("close");
				$(".ui-multiselect-header").hide();
			});
			$("#roleSelector").multiselect("close");

			$(".ui-multiselect-checkboxes li label").each(function() {
				var $this = $(this);
				$this.find("input").hide().click(function() {
					return false;
				});
				var $checker = $("<div class='checker'>");
				$this.prepend($checker);

				$this.click(function(e) {
					var $this = $(this);
					var checker = $this.find(".checker");
					var input = $this.find("input");
					var wasChecked = input.is(":checked");
					input.attr("checked", !wasChecked);
					checker.toggleClass("checked", !wasChecked);

					showApplyButton();
					var uniqueSelectClasses = ["modified-in", "release", "view"];
					var $item = $this.closest("li");
					$.each(uniqueSelectClasses, function () {
						var cl = this;
						if ($item.hasClass(cl)) {
							selectOne(input.val(), cl);
						}
					});

					showHideClearers();

					$("#roleSelector").multiselect("update");

					return false;
				});
			});

			// prevent the select all/none operation on clicking the optgroup headers
			$("li.ui-multiselect-optgroup a").bind("click.multiselect", function (e) {
				e.stopPropagation();
			});
			$("li.ui-multiselect-optgroup").each(function() {
				var $groupHeader = $(this);
				var $clearer = $("<div>").addClass("optgroup-clearer ui-icon ui-icon-circle-close").attr("title", "Clear selection in this group");
				$groupHeader.append($clearer);
			});

			$(".optgroup-clearer").click(function() {
				var $header = $(this).parent();
				var $items = $header.nextUntil("li.ui-multiselect-optgroup").not(".ui-multiselect-disabled");
				$items.find(":checkbox:checked").closest("label").click();
				showApplyButton();
				$(this).hide();
			});

			_restoreSelection();
			showHideClearers();

			// add the filter box for options
			var li = $("<div>").addClass("filter").append($("<input>").attr("type", "text").attr("id", "optionFilter"));
			li.append($("<div>").addClass("ui-icon ui-icon-circle-close"));
			$(".ui-multiselect-menu").prepend(li);

			$("#optionFilter").keyup(function () {
				var searchText = $(this).val().toLowerCase();
				filterList('.ui-multiselect-checkboxes > li:not(.ui-multiselect-optgroup,.filter)', searchText);
			});

			$("div.filter .ui-icon").click(clearFilter);

		},
		"selectedText": function(numChecked, numTotal, checked) {
			return $.map(checked, function(a) {
				return $(a).attr("title");
			}).join(", ");
		}
	});

	setTeamColors();

	// codebeamer.cardboard.init(); // TODO: global variable
	//
	// submitForm(function() {
	// 	if (!$.isEmptyObject(hashParams)) {
	// 		codebeamer.cardboard.selectCard(hashParams["select"], true);
	// 		window.location.hash = "#" + hashParams["select"];
	// 	}
	// });

	$(".add-new-item-link").click(function () {
		var releaseId = $("li.release :checked").val();
		if (!releaseId) {
			releaseId = codebeamer.cardboard.getConfig().originalReleaseId;
		}
		var url = contextPath + "/planner/createIssue.spr?task_id=" + releaseId;

		inlinePopup.show(url);
	});
});
