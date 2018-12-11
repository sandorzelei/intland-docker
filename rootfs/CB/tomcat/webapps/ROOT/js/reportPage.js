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
codebeamer.ReportPage = codebeamer.ReportPage || (function($) {

	var initAccordion = function() {
		var accordion = $('#queriesAccordion');
		accordion.cbMultiAccordion();
	};

	var exportToExcel = function() {
		var cbQl = codebeamer.ReportSupport.getCbQl(widgetContainerId);
		if (cbQl.trim() != "") {
			cbQl = encodeURIComponent(cbQl);
			var sprintHistory = codebeamer.ReportSupport.isSprintHistory(widgetContainerId);
			var url = contextPath + '/proj/queries/export.spr?queryId=' + queryId + '&cbQl=' + cbQl + (sprintHistory ? '&sprintHistory=true' : '');
			var fields = codebeamer.ReportSupport.getFieldsFromTable(widgetContainerId);
			if (fields.length > 0) {
				url += "&fields=" + encodeURIComponent(JSON.stringify(fields));
			}
			showPopupInline(url, { width: 1000, height: 480 });
		} else {
			showEmptyQueryAlert();
		}
	};

	var initHandlers = function() {
		$('.queryList>li>.text').click(function(event) {
			var queryId = $(event.target).data('queryid');
			if (queryId) {
				document.location = contextPath + "/query/" + queryId;
			}
		});

		$(".queryList>li>.image").on("click", function(e) {
			handleStarClick(e);
		});

		$('#saveButton').click(function(e) {
			if (codebeamer.ReportSupport.logicEnabled(widgetContainerId) && isAdvanced()) {
				showFancyAlertDialog(i18n.message("query.widget.logic.advanced.save.warning"));
				return false;
			}
			if (codebeamer.ReportSupport.logicEnabled(widgetContainerId) && codebeamer.ReportSupport.isLogicInvalid(widgetContainerId, true)) {
				showFancyAlertDialog(i18n.message("query.widget.invalid.or.empty.logic.warning"));
				return false;
			}
			codebeamer.ReportSupport.clearCurrentProject(widgetContainerId);
			var cbQl = codebeamer.ReportSupport.getCbQl(widgetContainerId);
			if (cbQl.trim() != "") {
				if (queryId < 1) {
					codebeamer.ReportSupport.initAdvancedEditorWithQueryString(widgetContainerId, codebeamer.ReportSupport.getAdvancedQueryString(widgetContainerId, false));
					openProperties(false);
				} else {
					var fields = codebeamer.ReportSupport.getFieldsFromTable(widgetContainerId);
					var format = $('#' + widgetContainerId).data('format') || {};
					var data = {
						'queryId' : queryId,
						'cbQl': cbQl,
						'advanced': isAdvanced(),
						'fields' : JSON.stringify(fields),
						'format': format,
						'ajax' : true
					};
					if (codebeamer.ReportSupport.isResizeableColumnsEnabled(widgetContainerId)) {
						data["columnWidths"] = encodeURIComponent(JSON.stringify(codebeamer.ReportSupport.getColumnPercentages(widgetContainerId)));
					}
					data['sprintHistory'] = codebeamer.ReportSupport.isSprintHistory(widgetContainerId);
					
					if (codebeamer.ReportSupport.logicEnabled(widgetContainerId)) {
						var result = codebeamer.ReportSupport.buildQueryStructure(widgetContainerId, false, true);
						data["logicString"] = codebeamer.ReportSupport.getLogicString(widgetContainerId);
						data["logicSlicesString"] = JSON.stringify(result.where);
						delete result.where;
						data["extraInfoString"] = JSON.stringify(result);
					} else {
						data["logicString"] = null;
					}
					$.ajax({
						type: "POST",
						url: contextPath + '/proj/query/permission.spr',
						data: data,
						success: function() {
							showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
							codebeamer.ReportSupport.initAdvancedEditorWithQueryString(widgetContainerId, codebeamer.ReportSupport.getAdvancedQueryString(widgetContainerId, false));
							codebeamer.ReportSupport.hideUnsavedWarning(widgetContainerId, cbQl);
						}
					});
				}
			} else {
				showEmptyQueryAlert();
			}
		});

		$('#findQueries').click(function(e) {
			openFindQueries();
			return false;
		});

		//issue 612850 - links don't escape cbQl (like 'In progress'), so get cbQl form current url
		resultContainer.on('click', '.pagebanner>a,.pagelinks>a', function(e) {
			e.preventDefault();
			var nextLocation = $(e.target).attr('href');
			var queryString = codebeamer.ReportSupport.getCbQl(widgetContainerId);
			var advancedMode = isAdvanced();
			var pageParam = codebeamer.ReportSupport.getParamFromUrl(nextLocation, "page");
			var pageSizeParam = codebeamer.ReportSupport.getParamFromUrl(nextLocation, "pagesize");
			var showAll = codebeamer.ReportSupport.getParamFromUrl(window.location.href, 'showAll');
			var extraParamObj = {};
			if (pageParam) extraParamObj['page'] = pageParam;
			if (pageSizeParam) {
				//if pagesize is set keep it until page is reloaded
				extraParam = {'pagesize': pageSizeParam};
				extraParamObj['pagesize'] = pageSizeParam;
			}
			fetchQueryResults(queryString, queryId, advancedMode, extraParamObj, resultContainer, editMode, showAll);
			
			if (pageParam) {
				var urlUpdate = UrlUtils.addOrReplaceParameter(window.location.href, 'page', pageParam);
				History.pushState({ url : urlUpdate }, document.title, urlUpdate);
			}
			
			if (pageSizeParam && !pageParam) {
				var urlUpdate = UrlUtils.removeParameter(window.location.href, 'page');
				urlUpdate = UrlUtils.addOrReplaceParameter(urlUpdate, 'showAll', 'true');
				History.pushState({ url : urlUpdate }, document.title, urlUpdate);
			}
		});

		$("#searchBox_treePane").keyup(function() {
			var searchText = this.value.trim().toLowerCase();
			$("#treePane").jstree("open_all");
			var items = $('#west li');
			items.each(function(index, v) {
				var $item = $(v);
				var itemText = $item.text().trim().toLowerCase();
				if (itemText.indexOf(searchText) != -1) {
					$item.show();
				} else {
					$item.hide();
				}
			});
		});

		$("#aggregateFunctionDialog .okButton").click(function() {
			var $dialog = $('#aggregateFunctionDialog');
			var $inputs = $dialog.find('input');
			var aliases = [];

			$inputs.each(function(key, value) {
				var $value = $(value);

				if ($value.is(':checked')) {
					var alias = getAggregateValue($dialog, $value);
					aliases.push(alias);
				}
			});

			var aggrFunctions = codebeamer.ReportSupport.getAggregateFunctions(widgetContainerId);
			var key = codebeamer.ReportSupport.getTrackerLabelKey($dialog);
			aggrFunctions[key] = aliases;
			codebeamer.ReportSupport.setAggregateFunctions(widgetContainerId, aggrFunctions);

			$dialog.dialog("close");
			$('.searchButton').click();
		});

		$("#fieldFormatDialog .okButton").click(function() {
			var $dialog = $('#fieldFormatDialog');

			var format = codebeamer.ReportSupport.getFieldFormat(widgetContainerId);
			var key = codebeamer.ReportSupport.getTrackerLabelKey($dialog);
			if (!format[key]) format[key] = {};

			format[key]["numberFormat"] = $dialog.find('#numberFormat').val();
			format[key]["decimalFormat"] = $dialog.find('#decimalFormat').val();
			$("#" + widgetContainerId).data('format', JSON.stringify(format));
			$dialog.dialog("close");
			$('.searchButton').click();
		});

		$("#aggregateFunctionDialog .cancelButton").click(function() {
			$('#aggregateFunctionDialog').dialog("close");
		});

		$("#fieldFormatDialog .cancelButton").click(function() {
			$('#fieldFormatDialog').dialog("close");
		});

		$("#" + widgetContainerId).find(".inputSection textarea").keypress(function (e) {
			if (e.which == 13) {
				$('.searchButton').click();
				return false;
			}
		});

		$("#" + widgetContainerId).find(".clearButton").click(function() {
			$("#" + widgetContainerId).find(".fieldArea .modifiableArea").find(".removeIcon").each(function() {
				$(this).click();
			});
		});

		preventPopStateTriggeringIfHashmarkChange();
		$(window).on('popstate', stateChangeHandler);
	};

	var handleStarClick = function(e) {
		var target = $(e.target);
		var queryId = target.parent().data("queryid");
		var star = target.parent().data("star");

		$.ajax({
			type: "POST",
			url: contextPath + "/proj/queries/star.spr",
			data: {"queryId": queryId, "star": star},
			success: function() {
				switchStar(target, star);
			}
		});
	};

	var switchStar = function(target, star) {
		if (star) {
			var newStarValue = false;
			var imgSrc = contextPath + "/images/newskin/action/star-active-12x12.png";
		} else {
			var newStarValue = true;
			var imgSrc = contextPath + "/images/newskin/action/star-inactive-12x12.png";
		}

		target.parent().data("star", newStarValue);
		target.attr("src", imgSrc);
	};

	var showEmptyQueryAlert = function() {
		showFancyAlertDialog(i18n.message("queries.empty.query.alert"));
	};

	var stateChangeHandler = function(e) {
		// There might be a better way for detecting browser back button, but popstate event is triggered on pushstate as well...
		if (e.originalEvent) {
			var queryString = codebeamer.ReportSupport.getCbQl(widgetContainerId);
			var advancedMode = isAdvanced();
			var pageParam = codebeamer.ReportSupport.getParamFromUrl(window.location.href, "page");
			var pageSizeParam = codebeamer.ReportSupport.getParamFromUrl(window.location.href, "pagesize");
			var showAll = codebeamer.ReportSupport.getParamFromUrl(window.location.href, 'showAll');
			var extraParamObj = {
				page: pageParam,
				pagesize: pageSizeParam
			};
			fetchQueryResults(queryString, queryId, advancedMode, extraParamObj, resultContainer, editMode, showAll);
		}
		$(window).off('popstate', stateChangeHandler);
	};
	
	var fetchQueryResults = function(queryString, queryId, advancedMode, extraParams, $resultContainer, editMode, isShowAll) {
		var busy = ajaxBusyIndicator.showBusyPage();
		var baseUrl = contextPath + "/proj/queries/runQuery.spr";

		var data = {};
		data['cbQl'] = queryString;
		data['advancedMode'] = advancedMode ? true : false;

		if (queryId != null && queryId > 0) {
			data['queryId'] = queryId;
		}

		jQuery.extend(data, extraParams);
		jQuery.extend(data, extraParam);
		
		if (isShowAll) {
			data['showAll'] = true;
		}
		
		if (!data['fields']) {
			var fields = codebeamer.ReportSupport.getFieldsFromTable(widgetContainerId);
			if (fields.length > 0) {
				data['fields'] = fields
			}
		}

		data['fields'] = data['fields'] ? JSON.stringify(data['fields']) : null;

		var format = $("#" + widgetContainerId).data('format');
		if (format != undefined) {
			data['format'] = format;
		}

		var resizeableColumns = $("#resizeableColumns").is(":checked");
		if (resizeableColumns) {
			data["resizeableColumns"] = resizeableColumns;
		}

		var sprintHistory = codebeamer.ReportSupport.isSprintHistory(widgetContainerId);
		if (sprintHistory) {
			data['sprintHistory'] = sprintHistory;
		}
		$.ajax({
			method: 'POST',
			url: baseUrl,
			data: data
		}).done(function(data) {
			$resultContainer.html(data);
			if (isAdvanced()) {
				codebeamer.ReportSupport.initAdvancedEditorWithQueryString(widgetContainerId, codebeamer.ReportSupport.getAdvancedQueryString(widgetContainerId, false), codebeamer.ReportSupport.logicEnabled(widgetContainerId));
				setTimeout(function(){ $("#" + widgetContainerId).find('.inputSection textarea').focus(); }, 0); //focus not working without timeout
			}
			if (editMode) {
				codebeamer.ReportSupport.createSelector(widgetContainerId, "addFieldSelector");
			}
			codebeamer.ReportSupport.applyContextMenuUserPreference(widgetContainerId);
		}).always(function() {
			ajaxBusyIndicator.close(busy);
			initDrag(true);
			if (editMode) {
				$("#rightPane").animate({ scrollTop: 0 }, 500);
			} else {
				$("html, body").animate({ scrollTop: 0 }, 500);
			}
			preventPopStateTriggeringIfHashmarkChange();
			$(window).on('popstate', stateChangeHandler);	
		});
	};

	var initAggregateFunctionDialog = function(key, root) {
		var $dialog = $("#aggregateFunctionDialog");
		var layoutName = root.$trigger.parent().data('fieldlayoutname');
		var fieldI18nCode = "tracker.field." + layoutName + ".label";
		$("#summaryFieldName").text(i18n.messageCodes[fieldI18nCode] == undefined ? layoutName : i18n.message(fieldI18nCode));

		$dialog.data('fieldlayoutname', layoutName);
		$dialog.data('fieldlayoutid', root.$trigger.parent().data('fieldlayoutid'));
		$dialog.data('customfieldtrackerid', root.$trigger.parent().data('customfieldtrackerid'));
		$dialog.data('cbqlattr', root.$trigger.parent().data('cbqlattr'));
		$dialog.data('iscustom', root.$trigger.parent().data('iscustom'));

		var $inputs = $dialog.find("input[type='checkbox']");
		var aggrFunctions = codebeamer.ReportSupport.getAggregateFunctions(widgetContainerId);
		var key = codebeamer.ReportSupport.getTrackerLabelKey($dialog);

		$inputs.each(function(k, value) {
			var $value = $(value);
			var checkboxFunction = $value.data('function');
			var alias = getAggregateValue($dialog, $value);

			var check = false;
			if (aggrFunctions[key] != undefined) {
				var result = $.grep(aggrFunctions[key], function(e){ return e['function'] === checkboxFunction; });
				check = result.length > 0;
			}

			$value.prop('checked', check);
		});

		$dialog.dialog({
			autoOpen: true,
			dialogClass: 'popup',
			modal: true,
			width: "385",
			height: "135"
		});
	};

	var initFieldFormatDialog = function(key, root) {
		var $dialog = $("#fieldFormatDialog");
		var layoutName = root.$trigger.parent().data('fieldlayoutname');
		var fieldI18nCode = "tracker.field." + layoutName + ".label";
		$("#formatFieldName").text(i18n.messageCodes[fieldI18nCode] == undefined ? layoutName : i18n.message(fieldI18nCode));

		$dialog.data('fieldlayoutname', layoutName);
		$dialog.data('fieldlayoutid', root.$trigger.parent().data('fieldlayoutid'));
		$dialog.data('customfieldtrackerid', root.$trigger.parent().data('customfieldtrackerid'));
		$dialog.data('cbqlattr', root.$trigger.parent().data('cbqlattr'));

		var format = codebeamer.ReportSupport.getFieldFormat(widgetContainerId);
		var key = codebeamer.ReportSupport.getTrackerLabelKey($dialog);

		if (format[key] != undefined) {
			if (format[key]['numberFormat'] != undefined) {
				$dialog.find("#numberFormat option[value='" + format[key]['numberFormat'] +"']").prop('selected', true);
			}

			if (format[key]['decimalFormat'] != undefined) {
				$dialog.find("#decimalFormat option[value='" + format[key]['decimalFormat'] +"']").prop('selected', true);
			}
		} else {
			$dialog.find("#numberFormat option[value='number']").prop('selected', true);
			$dialog.find("#decimalFormat option[value='0']").prop('selected', true);
		}

		$dialog.dialog({
			autoOpen: true,
			dialogClass: 'popup',
			modal: true,
			width: "385",
			height: "135"
		});
	};

	var initHeaderContextMenu = function() {
		codebeamer.ReportSupport.initHeaderContextMenu(widgetContainerId);
	};

	var isTableDroppable = function(fieldId, customFieldTrackerId) {
		var trackerId = typeof customFieldTrackerId === "undefined" || customFieldTrackerId == "null" ? "null" : parseInt(customFieldTrackerId, 10);
		var fieldIsPresent = false;
		$("#trackerItems>thead").find("th").each(function() {
			var isCustom = $(this).attr("data-iscustom") == "true";
			var existingTrackerId = isCustom ? $(this).attr("data-customfieldtrackerid") : "null";
			existingTrackerId = existingTrackerId == "null" ? "null" : parseInt(existingTrackerId, 10);
			if (parseInt(fieldId, 10) == parseInt($(this).attr("data-fieldlayoutid"), 10) && existingTrackerId == trackerId) {
				fieldIsPresent = true;
				return false;
			}
		});
		return !fieldIsPresent;
	};

	var initTreeDrag = function() {

		$('#treePane li.jstree-leaf').each(function() {
			if ($(this).data("ui-draggable")) {
				$(this).draggable("destroy");
			}
		});

		$('#treePane li.jstree-leaf').draggable({
			appendTo : '#west',
			cursor : 'move',
			helper : 'clone',
			stop : function(e, ui) {
				$('#' + widgetContainerId).find(".droppableArea").removeClass("highlighted");
				$("#trackerItems>thead").find("th").removeClass("highlighted");
			},
			start : function(e, ui) {
				codebeamer.ReportSupport.resetDroppables(widgetContainerId);

				var fieldId = ui.helper.attr("data-fieldLayoutId");
				var customFieldTrackerId = ui.helper.attr("data-customfieldtrackerid");
				var data = {
					field_id: fieldId
				};
				// If only one tracker is selected, pass this tracker ID because of the correct field label
				var trackers = codebeamer.ReportSupport.getTrackerIds(widgetContainerId);
				if (trackers.length == 1) {
					data["tracker_id"] = trackers[0];
				}
				// If field is a custom field, pass its tracker ID
				if (customFieldTrackerId) {
					data["tracker_id"] = customFieldTrackerId;
				}
				$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
					dataType: "json",
					data: data,
					async: false
				}).done(function(fieldObject) {
					$("#treePane").jstree("deselect_all");
					$("#treePane").jstree("select_node", $(this).attr("id"));
					codebeamer.ReportSupport.setDragHelper($(this), ui.helper);

					// if field is not supported, do not allow to drop
					if (typeof fieldObject === "undefined" || fieldObject === null) {
						return;
					}

					var $droppable = codebeamer.ReportSupport.getDroppableAreas(widgetContainerId, fieldObject);
					$droppable.addClass("highlighted");

					$droppable.droppable({
						hoverClass : "dropHover",
						accept: function($element) {
							return codebeamer.ReportSupport.isDroppableAcceptsElement($element);
						},
						drop: function(event, ui) {
							if ($(this).find(".selectorContainer").length > 0) {
								codebeamer.ReportSupport.addOrderByOrGroupBy(widgetContainerId, $(this), fieldObject, false, "TO_DAY");
							} else {
								try {
									codebeamer.ReportSupport.renderField(widgetContainerId, fieldObject, true, null);
								} catch (e) {
									showFancyAlertDialog(e);
									return false;
								}
							}
						}
					});

					if (isTableDroppable(fieldId, customFieldTrackerId)) {
						$("#trackerItems>thead").find("th").addClass("highlighted");
						$("#trackerItems>thead").find("th:not(.skipColumn)").droppable({
							accept: function($element) {
								return codebeamer.ReportSupport.isDroppableAcceptsElement($element);
							},
							drop : function(event, ui) {
								var $element = $(this).find(".drop-marker");
								codebeamer.ReportSupport.insertColumn(widgetContainerId, $(event.target), $(ui.draggable));
								$element.remove();
								$(this).css("overflow", "");
							},
							over: function (event, ui) {
								var $hoveredElement = $(this);
								var $dropMarker = $("<div>", { "class": "drop-marker"});
								$dropMarker.css("left", $hoveredElement.width() + 5);
								$dropMarker.css("height", $("#trackerItems").height());
								$hoveredElement.append($dropMarker);
								$(this).css("overflow", "visible");
							},
							out: function (event, ui) {
								var element = $(this).find(".drop-marker");
								element.remove();
								$(this).css("overflow", "");
							}
						});
					}

				});

			}
		});

		$('#treePane li.jstree-leaf').off("dblclick");
		$('#treePane li.jstree-leaf').dblclick(function(e) {
			if (isTableDroppable($(this).attr("data-fieldlayoutid"), $(this).attr("data-customfieldtrackerid"))) {
				var $that = $(this);
				codebeamer.ReportSupport.insertColumn(widgetContainerId, $(e.target), $that, true);
			}
		});

	};

	var initDrag = function(skipFieldList) {
		if (!skipFieldList) {
			initTreeDrag();
		}
		codebeamer.ReportSupport.initDrag(widgetContainerId, "#west");
	};

	var isAdvanced = function() {
		return $("#" + widgetContainerId).find(".inputSection textarea").is(':visible');
	};

	var getAggregateValue = function($dialog, $checkbox) {
		var isCustom = $dialog.data('iscustom');
		var cbqlattr = isCustom ? "'" + $dialog.data('cbqlattr') + "'" : $dialog.data('cbqlattr');
		var aggrFunction = $checkbox.data('function');
		var alias = "'_" + aggrFunction + "_" + cbqlattr.replace(/'/g, '') + "'";
		return {'field': cbqlattr, 'alias': alias, 'function': aggrFunction};
	};

	var updateTrackerCustomFields = function(trackerIds) {
		var $customFields = $("#customFields");
		if (trackerIds.length > 0) {
			var baseUrl = "/proj/queries/customFields.spr?trackerIds=";
			var url = contextPath + baseUrl + trackerIds.join(",");

			$.get(url).done(function(data) {
				$customFields.html(data);
			});
		} else {
			$customFields.html("");
		}
	};

	var filterTree = function(type, ignoreKeyup) {
		var $searchBox = $("#searchBox_treePane");
		if (!ignoreKeyup && $searchBox.val() != i18n.message("association.search.as.you.type.label")) {
			$searchBox.trigger("keyup");
		}
		$("#treePane").find("li.jstree-leaf").each(function() {
			if ($(this).is(":visible")) {
				if (type == "all") {
					$(this).show();
				} else {
					if ($(this).attr("data-fieldtypename") == type) {
						$(this).show();
					} else {
						$(this).hide();
					}
				}
			}
		});
	};

	var initTree = function() {
		$("#treePane").bind("ready.jstree", function() {
			setTimeout(function() {
				initTreeDrag();
				$("#treePane").jstree("open_all");
			}, 500);
		});
		$("#treePane").bind("refresh.jstree", function() {
			setTimeout(function() {
				initTreeDrag();
				$("#treePane").jstree("open_all");
			}, 500);
		});
		$("#treePane").bind("after_open.jstree", function() {
			initTreeDrag();
			if ($("#searchBox_treePane").val() != i18n.message("association.search.as.you.type.label")) {
				$("#searchBox_treePane").trigger("keyup");
			}
		});
	};

	var initFieldTypeSelector = function() {

		$(".fieldTypeSelector").change(function() {
			$("#treePane").find("li.jstree-leaf").show();
			filterTree($(this).val(), false);
		});
		$("#searchBox_treePane").keyup(function() {
			setTimeout(function() {
				filterTree($(".fieldTypeSelector").val(), true);
			}, 1);
		});
	};

	var populateFieldTree = function() {
		return {
			project_ids: codebeamer.ReportSupport.getProjectIds(widgetContainerId).join(","),
			tracker_ids: codebeamer.ReportSupport.getTrackerIds(widgetContainerId).join(",")
		}
	};

	var fixIELayout = function() {
		setInterval(function() {
			if ($("body").hasClass("IE")) {
				var $rightPane = $("#rightPane");
				var headerWith = $(".queryContainer .header").width();
				var resultWith = $("#trackerItems").width();
				if (resultWith && ((resultWith + 30) > headerWith)) {
					$rightPane.css("overflow-x", "auto");
				} else {
					$rightPane.css("overflow-x", "hidden");
				}
			}
		}, 1000);
	};

	function openFindQueries() {
		showPopupInline(contextPath + '/proj/queries/picker.spr', {'geometry': 'large'});
	}

	var openProperties = function(duplicate) {
		if (codebeamer.ReportSupport.logicEnabled(widgetContainerId) && isAdvanced()) {
			showFancyAlertDialog(i18n.message("query.widget.logic.advanced.save.warning"));
			return false;
		}

		if (codebeamer.ReportSupport.logicEnabled(widgetContainerId) && codebeamer.ReportSupport.isLogicInvalid(widgetContainerId, true)) {
			showFancyAlertDialog(i18n.message("query.widget.invalid.or.empty.logic.warning"));
			return false;
		}

		codebeamer.ReportSupport.clearCurrentProject(widgetContainerId);

		var param = queryId > 0 ? '?queryId='+queryId : '?';

		param += "&advanced=" + isAdvanced();
		param += "&duplicate=" + duplicate;

		try {
			var fields = codebeamer.ReportSupport.getFieldsFromTable(widgetContainerId);
			if (fields.length > 0) {
				param += "&fields=" + encodeURIComponent(JSON.stringify(fields));
			}

			var projectIds = $("#" + widgetContainerId).find(".projectSelector").multiselect("getChecked").map(function(key, value){return $(value).val()});
			if (projectIds.length > 0) {
				param += "&selectedProjectId=" + projectIds[0];
			}
		} catch (ex) {
			//
		}

		if (codebeamer.ReportSupport.isResizeableColumnsEnabled(widgetContainerId)) {
			param += "&columnWidths=" + encodeURIComponent(JSON.stringify(codebeamer.ReportSupport.getColumnPercentages(widgetContainerId)));
		}

		codebeamer.ReportSupport.hideUnsavedWarning(widgetContainerId);
		showPopupInline(contextPath + '/proj/query/permission.spr' + param, { width: 1000, height: 550 });
	};

	var deleteQuery = function() {
		showFancyConfirmDialogWithCallbacks(i18n.message("queries.delete.warning"),
			function(){
				$.ajax({
					type: "POST",
					url: contextPath + '/proj/queries/delete.spr',
					data: {'queryId' : queryId},
					success: function() {window.location=contextPath + '/query'}
				});
			}
		);
	};

	var starQuery = function(star) {
		$.ajax({
			type: "POST",
			url: contextPath + "/proj/queries/star.spr",
			data: {"queryId": queryId, "star": star},
			success: function() {window.location.reload(); }
		});
	};

	var openEditMode = function() {
		window.location.href = contextPath + "/query/" + queryId + "/edit";
	};

	function buildMenuItems() {
		var items = {};
		if (editable && !editMode) {
			items['edit'] = { name: i18n.message("queries.edit.label"), 'callback' : function() { openEditMode(); }};
			items['sep1'] = "---------";
		}
		if (editable && editMode) {
			items['properties'] = {name: i18n.message("queries.contextmenu.properties"), 'callback': function(){ openProperties(false) }};
			items['sep1'] = "---------";
		}
		if (editMode) {
			items['revert'] = {name: i18n.message("queries.contextmenu.revert"), 'callback': function() {
				document.location.href = contextPath + "/query/" + queryId;
			}};
		}
		items['duplicate'] = {name: i18n.message("queries.contextmenu.duplicate"), 'callback': function() { openProperties(true); }};
		if (editable) {
			items['delete'] = {name: i18n.message("queries.contextmenu.delete"), 'callback': function(){ deleteQuery() }};
		}
		if (starred) {
			items['unstarit'] = {name: i18n.message("queries.contextmenu.unstarit"), 'callback': function(){ starQuery(false) }, 'icon': "star"};
		} else {
			items['starit'] = {name: i18n.message("queries.contextmenu.starit"), 'callback': function(){ starQuery(true) }, 'icon': "unstar"};
		}
		return items;
	}

	var initSubscriptionMenus = function() {
		$("#newSubscription").click(function() {
			showPopupInline(contextPath + '/proj/query/newSubscription.spr?queryId=' + queryId, { width: 1000, height: 600 });
			return false;
		});
		$("#editSubscription").click(function() {
			showPopupInline(contextPath + '/proj/query/editSubscription.spr?queryId=' + queryId + '&subscriptionId=' + $(this).attr("data-subscription-id"), { width: 1000, height: 600 });
			return false;
		});
		$("#manageSubscriptions").click(function() {
			showPopupInline(contextPath + '/proj/query/manageSubscriptions.spr', { width: 1000, height: 600 });
			return false;
		});
	};

	var initMenuItems = function() {
		var menu = new ContextMenuManager({
			"selector": ".settings",
			"trigger": "left",
			"items": buildMenuItems(),
			"zIndex": 30
		});
		menu.render();
	};

	var widgetContainerId = null;
	var resultContainer = null;
	var editMode = false;
	var queryId = null;
	var editable = false;
	var starred = false;
	var extraParam = {};

	var init = function(config) {
		widgetContainerId = config.widgetContainer.attr("id");
		resultContainer = config.resultContainer;
		editMode = config.editMode;
		queryId = config.queryId;
		editable = config.editable;
		starred = config.starred;
		initAccordion();
		initHandlers();
		initSubscriptionMenus();
		initMenuItems();
		if (editMode) {
			initDrag(true);
			initTree();
			initHeaderContextMenu();
			initFieldTypeSelector();
			fixIELayout();
		}
		if (config.findQueries) {
			openFindQueries();
		}
		if (config.showResizeableColumns) {
			codebeamer.ReportSupport.initResizeableColumns(widgetContainerId);
		}
	};

	return {
		"init": init,
		"showEmptyQueryAlert": showEmptyQueryAlert,
		"fetchQueryResults" : fetchQueryResults,
		"populateFieldTree" : populateFieldTree,
		"openFindQueries" : openFindQueries,
		"exportToExcel" : exportToExcel
	};

})(jQuery);

