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
codebeamer.IntelligentTableView = codebeamer.IntelligentTableView || (function($) {

	var config = {};

	var removeResultFromLevel = function($addButton) {
		$addButton.closest("tr").removeClass("ignoredLevel");
		$addButton.closest(".levelContainer").find(".numberOfItems").hide();
	};

	var extendLevels = function($addButton) {
		var $tr = $addButton.closest("tr");
		var $table = $(".controlContainer table.levelsTable");
		var $lastTr = $table.find("tr.levelTr").last();
		if ($lastTr.get(0) == $tr.get(0)) {
			var $newTr = $lastTr.clone();
			$newTr.find(".addButton").removeClass("context-menu-active");
			$newTr.find(".entityContainer").remove();
			var index = parseInt($newTr.find(".number").text(), 10);
			$newTr.find(".number").text(index + 1);
			$table.append($newTr);
		}
	};

	var cleanupLevels = function() {
		var $levels = $(".levelContainer:not(.initialLevelContainer)");
		var $lastLevel = $levels.last();
		$levels.each(function() {
			if ($(this).get(0) != $lastLevel.get(0) && $(this).find(".entityContainer").length == 0) {
				$(this).closest("tr").remove();
				$(this).closest("tr").next("tr").remove();
			}
		});
		var index = 1;
		$(".levelContainer:not(.initialLevelContainer)").each(function() {
			$(this).closest("tr").find(".number").text(index);
			index++;
		});
	};

	var refreshFieldNames = function($tr) {
		var trackerIds = [];
		$tr.find("td.entities").find(".entityContainer.trackerEntity").each(function() {
			trackerIds.push($(this).data("id"));
		});
		var $fieldRow = $tr.nextAll(".fieldControlTr").first();
		var newFieldNames = {};
		$.ajax({
			url: contextPath + "/ajax/queries/getFields.spr",
			dataType: "json",
			data: {
				"tracker_ids" : trackerIds.join(",")
			},
			async: false,
			success: function(result) {
				var defaultFields = result[0];
				var referenceFields = result[1];
				for (var i = 0; i < defaultFields.children.length; i++) {
					newFieldNames[defaultFields.children[i].id] = defaultFields.children[i].text;
				}
				for (var i = 0; i < referenceFields.children.length; i++) {
					newFieldNames[referenceFields.children[i].id] = referenceFields.children[i].text;
				}
				$fieldRow.find(".entityContainer.fieldContainer").each(function() {
					var newName = newFieldNames[$(this).data("id")];
					$(this).data("name", newName);
					$(this).find(".name").html(newName);
				});
			}
		});
	};

	var addFieldControlRow = function($table, id, trackerTypeId, skipDefaultFields) {
		var $tr = $("<tr>", { "data-id" : id, "data-trackerTypeId" : trackerTypeId});
		var $controlTd = $("<td>", { "class" : "entities"});
		var $controlCont = $("<div>", { "class" : "controlContainer"});
		var $addFieldButton = $("<span>", { "class" : "addFieldButton"}).text("+ " + i18n.message("intelligent.table.view.add.field.label"));
		$addFieldButton.click(function() {
			var fieldIds = [];
			$(this).closest(".controlContainer").find(".fieldContainer:not(.placeholderContainer)").each(function() {
				var fieldId = $(this).data("id");
				var trackerId = $(this).data("customFieldTrackerId");
				if (trackerId && trackerId != config.trackerId) {
					fieldId = trackerId + "_" + fieldId;
				}
				fieldIds.push(fieldId.toString());
			});
			$(this).data("fieldIds", fieldIds);
			$("#addFieldSelector").data("addButton", $(this));
			getFieldSelector($(this));
		});
		$controlCont.append($("<span>", { "class" : "entityContainer fieldContainer placeholderContainer"}));
		$controlCont.append($addFieldButton);
		$controlTd.append($controlCont);
		$tr.append($controlTd);
		$table.append($tr);
		$controlCont.sortable({
			items: "> .entityContainer",
			handle: ".issueHandle",
			axis: "x"
		});
		if (!skipDefaultFields) {
			if (config.fieldList && config.fieldList.length > 0) {
				for (var i = 0; i < config.fieldList.length; i++) {
					var field = config.fieldList[i];
					addFieldToLevel($addFieldButton, field.name, field.id, false);
				}
			} else {
				addFieldToLevel($addFieldButton, i18n.message("tracker.field.Summary.label"), 3);
			}
		}
	};

	var appendDirectionTr = function($tr, id, trackerTypeId, isUpstream, isDownstream) {
		if (!isUpstream && !isDownstream) {
			isUpstream = true;
		}
		var $directionTr = $("<tr>", { "class" : "directionTr"});
		$directionTr.data("id", id);
		$directionTr.data("trackerTypeId", trackerTypeId);
		$directionTr.append($("<td>", { "class" : "directionTrLabel"}).text(i18n.message("intelligent.table.view.direction.label") + ":"));
		var $controlTd = $("<td>", { "class" : "directionControl"});
		var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
		$controlTd.append($("<input>", { "type": "checkbox", "id" : "upstream_" + uniqueId, "value" : "upstream" }).prop("checked", isUpstream));
		$controlTd.append($("<label>", { "for" : "upstream_" + uniqueId}).text(i18n.message("intelligent.table.view.upstream.label")));
		$controlTd.append($("<input>", { "type": "checkbox", "id" : "downstream_" + uniqueId, "value" : "downstream" }).prop("checked", isDownstream));
		$controlTd.append($("<label>", { "for" : "downstream_" + uniqueId}).text(i18n.message("intelligent.table.view.downstream.label")));
		$directionTr.append($controlTd);
		$tr.after($directionTr);
	};

	var appendFieldTr = function($tr, id, trackerTypeId, skipDefaultFields) {
		var $fieldTr = $("<tr>", { "class" : "fieldControlTr"});
		$fieldTr.append($("<td>", { "class" : "fieldControlLabel"}).text(i18n.message("intelligent.table.view.field.settings.label") + ":"));
		var $controlTd = $("<td>", { "class" : "fieldControlTr"});
		var $controlDiv = $("<div>", { "class" : "fieldControl"});

		var $table = $("<table>", { "class" : "fieldControlTable"});
		addFieldControlRow($table, id, trackerTypeId, skipDefaultFields);
		$controlDiv.append($table);

		$controlTd.append($controlDiv);
		$fieldTr.append($controlTd);
		$tr.after($fieldTr);
	};

	var addEntityToLevel = function($addButton, name, id, trackerTypeId, iconUrl, skipDefaultFields, isUpstream, isDownstream) {

		var addEntity = function() {
			id = parseInt(id, 10);
			var isTracker = id > 1000;

			var $entityContainer = $("<span>", { "class" : "entityContainer" + (isTracker ? " trackerEntity" : "") });
			$entityContainer.append($("<span>", { "class" : "issueHandle"}));
			var $iconSpan = $("<span>", { "class" : "icon"});
			$iconSpan.append($("<img>", { "src" : iconUrl, "style" : "background-color: #5f5f5f" }));
			$entityContainer.append($iconSpan);
			$entityContainer.append($("<span>", { "class" : "name"}).html(name));
			$entityContainer.append($("<span>", { "class" : "deleteButton"}));
			$entityContainer.data("id", id);
			$entityContainer.data("trackerTypeId", trackerTypeId);
			$addButton.before($entityContainer);

			removeResultFromLevel($addButton);
			extendLevels($addButton);

			var $tr = $addButton.closest("tr");
			var $nextTr = $tr.next("tr");

			if (!$nextTr.is(".directionTr")) {
				appendFieldTr($tr, id, trackerTypeId, skipDefaultFields);
				appendDirectionTr($tr, id, trackerTypeId, isUpstream, isDownstream);
			}

			refreshFieldNames($tr);
		};

		addEntity();
	};

	var initControls = function() {

		var initRemoveButtons = function() {
			$(".controlContainer").on("click", ".deleteButton", function(e) {
				var $button = $(e.target);
				var $tr = $button.closest("tr");
				if ($tr.hasClass("levelTr")) {
					var $addButton = $tr.find(".addButton");
					$addButton.show();
					var $entityContainer = $button.closest(".entityContainer");
					$entityContainer.remove();
					removeResultFromLevel($addButton);
					if ($tr.find(".entityContainer").length == 0) {
						$tr.next(".directionTr").remove();
						$tr.next(".fieldControlTr").remove();
					}
					refreshFieldNames($tr);
					cleanupLevels();
				} else {
					$button.closest(".fieldContainer").remove();
				}
			});
		};

		initRemoveButtons();
	};

	var populateFieldContextMenu = function(field, items, index, callback, disabledCallback) {
		var key = index < 10 ? ("0" + index.toString()) : index.toString();
		items[key + "@" + field.id] = {
			name: field.text,
			callback: function(itemKey) {
				callback(itemKey, $(this));
			},
			disabled : function(itemKey) {
				return disabledCallback(itemKey, field);
			}
		}
	};

	var createContextMenuStructure = function(result, callback, disabledCallback) {
		var items = {};
		for (var i = 0; i < result.length; i++) {
			var folder = result[i];
			var subItems = {};
			for (var j = 0; j < folder.children.length; j++) {
				var node = folder.children[j];
				if (node.attr["data-isFolder"]) {
					// Tracker
					var tracker = node;
					var subSubItems = {};
					for (var k = 0; k < tracker.children.length; k++) {
						populateFieldContextMenu(tracker.children[k], subSubItems, k, callback, disabledCallback);
					}
					subItems[tracker.id] = {
						name: tracker.text,
						items: subSubItems
					}
				} else {
					populateFieldContextMenu(node, subItems, j, callback, disabledCallback);
				}
			}
			items[folder.id] = {
				name: folder.text,
				items: subItems
			};
		}
		return items;
	};

	var addFieldToLevel = function($addButton, name, id, customFieldTrackerId) {
		var $entityContainer = $("<span>", { "class" : "entityContainer fieldContainer" });
		$entityContainer.append($("<span>", { "class" : "issueHandle"}));
		$entityContainer.append($("<span>", { "class" : "name"}).html(name));
		$entityContainer.append($("<span>", { "class" : "deleteButton"}));
		$entityContainer.data("id", id);
		$entityContainer.data("name", name);
		$entityContainer.data("customFieldTrackerId", customFieldTrackerId);
		$addButton.before($entityContainer);
		$addButton.closest(".controlContainer").sortable("refresh");
	};

	var populateFieldNodes = function($selector, $originalSelector, nodes, disabledFieldIds) {
		for (var i = 0; i < nodes.length; i++) {
			var node = nodes[i];
			if (node.id == "recent" || (node.hasOwnProperty("children") &&  node.children.length > 0)) {
				var $optGroup = $("<optgroup>", { label: node.text });
				$originalSelector.append($optGroup);
				populateFieldNodes($optGroup, $originalSelector, node.children, disabledFieldIds);
			} else {
				var $option = $("<option>", { value: node.id }).text(node.text);
				if ($.inArray(node.id.toString(), disabledFieldIds) > -1) {
					$option.prop("disabled", true);
				}
				$selector.append($option);
			}
		}
	};

	var getFieldSelector = function($addButton) {
		var $levelTr = $addButton.closest("tr.fieldControlTr").prevAll(".levelTr").first();
		var trackerIds = [];
		$levelTr.find("td.entities").find(".entityContainer.trackerEntity").each(function() {
			trackerIds.push($(this).data("id"));
		});
		var disabledFieldIds = $addButton.data("fieldIds");
		$.ajax({
			url: contextPath + "/ajax/queries/getFields.spr",
			dataType: "json",
			data: {
				"tracker_ids" : trackerIds.join(",")
			},
			async: false,
			success: function(result) {
				var $selector = $("select#addFieldSelector");
				$selector.empty();
				populateFieldNodes($selector, $selector, result, disabledFieldIds);
				var optGroupLabel = null;
				$selector.find("optgroup:not(.recentFilters)").each(function() {
					if (optGroupLabel != null && $(this).children().length > 0) {
						$(this).attr("label", optGroupLabel + " → " + $(this).attr("label"));
					}
					if ($(this).children().length == 0) {
						optGroupLabel = $(this).attr("label");
					}
				});
				$selector.multiselect("refresh");
				$selector.multiselect("open");
			}
		});
	};

	var initContextMenus = function(trackerTypeItems, trackerItems) {
		var menu = new ContextMenuManager( {
			selector: ".controlContainer .addButton",
			trigger: "left",
			className: "traceabilityContextMenu",
			build: function($triggerElement, e) {
				var items = {
					"trackers" : {
						name: i18n.message("Trackers"),
						items: trackerItems
					},
					"trackerTypes" : {
						name: i18n.message("tracker.traceability.browser.tracker.types"),
						items: trackerTypeItems
					},
					"separator1" : "------",
					"addCustomTracker": {
						name: i18n.message("tracker.traceability.browser.custom.tracker"),
						callback: function(key, opt) {
							addCustomTracker($(this));
						}
					}
				};
				var existingEntities = [];
				$triggerElement.closest(".levelContainer").find(".entityContainer").each(function() {
					existingEntities.push($(this).find(".name").text() + '-' + $(this).data('id'));
				});

				for (var key in items["trackers"].items) {
					items["trackers"].items[key].disabled = $.inArray(key, existingEntities) > -1;
				}
				for (var key in items["trackerTypes"].items) {
					items["trackerTypes"].items[key].disabled = $.inArray(key, existingEntities) > -1;
				}
				return {
					items: items
				};
			}
		});
		menu.render();

		var initFieldSelector = function() {
			var $filterSelector = $("select#addFieldSelector");

			var setPosition = function($widget, $toPosition) {
				$widget.position({
					my: "left top",
					at: "left bottom+10",
					of: $toPosition,
					collision: "flipfit",
					using : null,
					within: window
				});
			};

			var settings = {
				classes: "queryConditionSelector filterSelector",
				minWidth: 100,
				height: 400,
				menuHeight: "auto",
				checkAllText : "",
				uncheckAllText: "",
				open: function() {
					var $widget = $(this).multiselect("widget");
					setPosition($widget, $(this).data("addButton"));
					setTimeout(function() {
						$widget.find(".ui-multiselect-filter input").focus();
					}, 100);
				},
				create: function() {
					$(".filterSelector .ui-multiselect-all").closest("ul").remove();
				},
				click: function(event, ui) {
					var fieldId = ui.value;
					var trackerId = null;
					var fieldProps = fieldId.split("_");
					if (fieldProps.length > 1) {
						fieldId = fieldProps[1];
						trackerId = fieldProps[0];
					}
					addFieldToLevel($(this).data("addButton"), ui.text, fieldId, trackerId);
					$(this).multiselect("close");
				}
			};
			$filterSelector.multiselect(settings).multiselectfilter({
				label: "",
				placeholder: i18n.message("Filter")
			});
		};

		initFieldSelector();

		initAddCustomTrackerDialog();

	};

	var getConfiguration = function() {
		var renderingMethod = "HORIZONTALLY";
		$("input[name='renderingMethod']").each(function() {
			if ($(this).is(":checked")) {
				renderingMethod = $(this).val();
			}
		});

		var initialFieldIds = [];
		$(".fieldControlTable").first().find(".fieldContainer:not(.placeholderContainer)").each(function() {
			initialFieldIds.push(parseInt($(this).data("id"), 10));
		});

		var level = 1;
		var levelSettings = {};
		var isValid = true;
		$(".levelsTable .levelTr:not(.initialTrackers)").each(function() {
			var $entities = $(this).find(".entities .entityContainer");
			if ($entities.length > 0) {
				var entities = [];
				$entities.each(function() {
					entities.push($(this).data("id"));
				});

				var $directionRow = $(this).next(".directionTr");
				var isUpstream = $directionRow.find("input[value='upstream']").is(":checked");
				var isDownstream = $directionRow.find("input[value='downstream']").is(":checked");

				var $fieldRow = $directionRow.next(".fieldControlTr");

				var fieldIds = [];
				var $fields = $fieldRow.find(".entities .entityContainer:not(.placeholderContainer)");
				if ($fields.length == 0) {
					isValid = false;
					return false;
				}
				$fields.each(function() {
					var customFieldTrackerId = $(this).data("customFieldTrackerId");
					if (typeof customFieldTrackerId === "undefined" || customFieldTrackerId == null || customFieldTrackerId == "null") {
						customFieldTrackerId = 0;
					} else {
						customFieldTrackerId = parseInt(customFieldTrackerId, 10);
					}
					var fieldId = parseInt($(this).data("id"), 10);
					fieldIds.push({
						fieldId: fieldId,
						trackerId: customFieldTrackerId
					});
				});
				levelSettings[level] = {
					entityIds : entities,
					fieldIds: fieldIds,
					upstream: isUpstream,
					downstream: isDownstream
				};
				level++;
			}
		});

		return !isValid ? null : {
			"renderingMethod" : renderingMethod,
			"levelSettings" : levelSettings,
			"initialFieldIds" : initialFieldIds
		};
	};

	var saveConfiguration = function(reportId) {
		var cbQL = null;
		var data = {
			reportId: reportId
		};
		try {
			var cbQL = parent.codebeamer.ReportSupport.getCbQl(parent.$(".reportSelectorTag").first().attr("id"));
		} catch (e) {
			//
		}
		if (cbQL != null) {
			data["cbQL"] = cbQL;
		}
		data["configuration"] = JSON.stringify(getConfiguration());
		if (data["configuration"] === "null") {
			showFancyAlertDialog(i18n.message("intelligent.table.view.validation.alert"));
			return false;
		}
		$.ajax({
			url: contextPath + "/intelligentTableView/saveConfiguration.spr",
			method: "POST",
			dataType: "json",
			data: data,
			success: function(result) {
				if (result.hasOwnProperty("errorMessage")) {
					showOverlayMessage(result.errorMessage, null, true);
				} else if (result.hasOwnProperty("success") && result.success) {
					parent.showOverlayMessage(i18n.message("intelligent.table.view.saved.configuration"));
					var view = parent.$(".reportPickerContainer").find("input[value='" + reportId + "']");
					var storedData = view.data("storedReport");
					storedData.cbQL = cbQL;
					view.data("storedReport", storedData);
					view.click();
					inlinePopup.close();
				}
			}
		});
		return false;
	};

	var initConfiguration = function(settings) {
		config = settings;
		var accordion = $('.accordion');
		accordion.cbMultiAccordion();
		accordion.cbMultiAccordion("open", 0);
		accordion.cbMultiAccordion("open", 1);
		initContextMenus(config.trackerTypeMenuItems, config.trackerMenuItems);
		initControls(config);
		if (config.hasOwnProperty("existing") && config.existing) {

			var getNodeFromId = function(menuItems, id) {
				for (var key in menuItems) {
					if (menuItems[key].hasOwnProperty("id") && menuItems[key].id == id) {
						return menuItems[key];
					}
				}
				return null;
			};

			var getFieldProperties = function(fieldId, trackerId) {
				var fieldObject = null;
				var data = {
					field_id: fieldId
				};
				if (trackerId !== null) {
					data["tracker_id"] = trackerId;
				}
				$.ajax(contextPath + "/ajax/queryCondition/getField.spr", {
					dataType: "json",
					data: data,
					async: false
				}).done(function(newFieldObject) {
					fieldObject = newFieldObject;
				});
				return fieldObject;
			};

			var existingJSON = $.parseJSON(config.existing);
			$("input[name='renderingMethod'][value='" + existingJSON.renderingMethod +"']").prop("checked", true);

			if (existingJSON.hasOwnProperty("initialFieldIds") && existingJSON.initialFieldIds && existingJSON.initialFieldIds.length > 0) {
				appendFieldTr($(".initialTrackers"), config.trackerId, null, true);
				for (var i = 0; i < existingJSON.initialFieldIds.length; i++) {
					var fieldId = existingJSON.initialFieldIds[i];
					var fieldProperties = getFieldProperties(fieldId, config.trackerId);
					if (fieldProperties != null) {
						addFieldToLevel($($(".levelsTable").find(".addFieldButton")[0]), fieldProperties.name, fieldId, config.trackerId);
					}
				}
			} else {
				appendFieldTr($(".initialTrackers"), config.trackerId, null);
			}

			for (var key in existingJSON.levelSettings) {
				var $addButton = $($(".levelsTable").find(".addButton:not(.firstLevelAddButton)")[key - 1]);
				var levelSetting = existingJSON.levelSettings[key];
				var entityIds = levelSetting.entityIds;
				var isUpstream = levelSetting.hasOwnProperty("upstream") ? levelSetting.upstream : false;
				var isDownstream = levelSetting.hasOwnProperty("downstream") ? levelSetting.downstream : false;
				for (var i = 0; i < entityIds.length; i++) {
					var id = entityIds[i];
					var node = id < 1000 ? getNodeFromId(config.trackerTypeMenuItems, id) : getNodeFromId(config.trackerMenuItems, id);
					if (!node) {
						$.ajax({
							url: contextPath + "/intelligentTableView/getCustomTrackerInfo.spr?trackerId=" + id,
							dataType: "json",
							async: false,
							success: function(result) {
								if (result && result.hasOwnProperty("name")) {
									node = result;
								}
							}
						});
					}
					if (node) {
						addEntityToLevel($addButton, node.name, node.id, null, node.iconUrl, true, isUpstream, isDownstream);
					}
				}
				var $addFieldButton = $($(".levelsTable").find(".addFieldButton")[key]);
				var fieldIds = levelSetting.fieldIds;
				for (var i = 0; i < fieldIds.length; i++) {
					var fieldId = fieldIds[i]["fieldId"];
					var trackerId = fieldIds[i]["trackerId"];
					var fieldProperties = getFieldProperties(fieldId, trackerId == 0 ? null : trackerId);
					if (fieldProperties != null) {
						addFieldToLevel($addFieldButton, fieldProperties.name, fieldId, trackerId == 0 ? null : trackerId);
					}
				}
			}
		} else {
			$("input[name='renderingMethod'][value='DISABLED']").prop("checked", true);
			appendFieldTr($(".initialTrackers"), config.trackerId, null);
		}
	};

	var forceReportSelectorSearch = function() {
		$(".reportSelectorTag").first().find(".searchButton").click();
	};

	var getConfigurationFromPage = function() {
		var json = $("#intelligentTableViewConfiguration").val();
		return JSON.parse(json);
	};

	var moveElementInArray = function(arr, oldIndex, newIndex) {
		if (newIndex >= arr.length) {
			var k = newIndex - arr.length + 1;
			while (k--) {
				arr.push(undefined);
			}
		}
		arr.splice(newIndex, 0, arr.splice(oldIndex, 1)[0]);
		return arr;
	};

	var swapColumns = function($th, direction) {
		var level = parseInt($th.attr("data-level"));
		var fieldId = parseInt($th.attr("data-fieldlayoutid"));
		var trackerId = parseInt($th.attr("data-customfieldtrackerid"));
		var configuration = getConfigurationFromPage();
		try {
			if (level > 0) {
				var fieldIds = configuration["levelSettings"][level]["fieldIds"];
				var fieldIndex = 0;
				for (var i = 1; i < fieldIds.length; i++) {
					if (fieldIds[i].fieldId == fieldId && fieldIds[i].trackerId == trackerId) {
						fieldIndex = i;
						break;
					}
				}
				var newFieldIds = moveElementInArray(fieldIds, fieldIndex, fieldIndex + (direction == "right" ? 1 : -1));
				configuration["levelSettings"][level]["fieldIds"] = newFieldIds;
			} else {
				var fieldIndex = configuration.initialFieldIds.indexOf(fieldId);
				configuration.initialFieldIds = moveElementInArray(configuration.initialFieldIds, fieldIndex, fieldIndex + (direction == "right" ? 1 : -1));
			}
		} catch (e) {
			//
		}
		var jsonString = JSON.stringify(configuration);
		$("#intelligentTableViewConfiguration").text(jsonString).val(jsonString);
		forceReportSelectorSearch();
	};

	var moveColumnLeft = function($th) {
		swapColumns($th, "left");
	};

	var moveColumnRight = function($th) {
		swapColumns($th, "right");
	};

	var removeColumn = function($th) {
		var level = parseInt($th.attr("data-level"));
		var fieldId = parseInt($th.attr("data-fieldlayoutid"));
		var trackerId = parseInt($th.attr("data-customfieldtrackerid"));
		var configuration = getConfigurationFromPage();
		try {
			if (level > 0) {
				var fieldIds = configuration["levelSettings"][level]["fieldIds"];
				var fieldIndex = 0;
				for (var i = 1; i < fieldIds.length; i++) {
					if (fieldIds[i].fieldId == fieldId && fieldIds[i].trackerId == trackerId) {
						fieldIndex = i;
						break;
					}
				}
				configuration["levelSettings"][level]["fieldIds"].splice(fieldIndex, 1);
			} else {
				var fieldIndex = configuration.initialFieldIds.indexOf(fieldId);
				configuration.initialFieldIds.splice(fieldIndex, 1);
			}
		} catch (e) {
			//
		}
		var jsonString = JSON.stringify(configuration);
		$("#intelligentTableViewConfiguration").text(jsonString).val(jsonString);
		forceReportSelectorSearch();
	};

	var addFieldToTable = function($th, key) {
		var fieldIdToAdd = key;
		var fieldTrackerIdToAdd = 0;
		var fieldProps = key.split("_");
		if (fieldProps.length > 1) {
			fieldIdToAdd = parseInt(fieldProps[1]);
			fieldTrackerIdToAdd = parseInt(fieldProps[0]);
		} else {
			fieldIdToAdd = parseInt(key);
		}
		var level = parseInt($th.attr("data-level"));
		var fieldId = parseInt($th.attr("data-fieldlayoutid"));
		var trackerId = parseInt($th.attr("data-customfieldtrackerid"));
		var configuration = getConfigurationFromPage();
		try {
			if (level > 0) {
				var fieldIds = configuration["levelSettings"][level]["fieldIds"];
				var fieldIndex = 0;
				for (var i = 0; i < fieldIds.length; i++) {
					if (fieldIds[i].fieldId == fieldId && fieldIds[i].trackerId == trackerId) {
						fieldIndex = i;
						break;
					}
				}
				if (fieldIndex == fieldIds.length - 1) {
					configuration["levelSettings"][level]["fieldIds"].push({
						fieldId : fieldIdToAdd,
						trackerId: fieldTrackerIdToAdd
					});
				} else {
					configuration["levelSettings"][level]["fieldIds"].splice(fieldIndex + 1, 0, {
						fieldId : fieldIdToAdd,
						trackerId: fieldTrackerIdToAdd
					});
				}
			} else {
				var fieldIndex = configuration.initialFieldIds.indexOf(fieldId);
				if (fieldIndex == configuration.initialFieldIds.length - 1) {
					configuration.initialFieldIds.push(fieldIdToAdd);
				} else {
					configuration.initialFieldIds.splice(fieldIndex, 0, fieldIdToAdd);
				}
			}
		} catch (e) {
			//
		}
		var jsonString = JSON.stringify(configuration);
		$("#intelligentTableViewConfiguration").text(jsonString).val(jsonString);
		forceReportSelectorSearch();
	};

	var initInlineEdit = function() {
		codebeamer.DisplaytagTrackerItemsInlineEdit.init($("#reportSelectorResult"), {
			plannerMode : false,
			buildTransitionMenu : false,
			buildRelations: false
		});
	};

	var initAddCustomTrackerDialog = function() {
		var $dialog = $("#traceabilityAddCustomTrackerDialog");
		var $projectSelector = $dialog.find(".project");
		var $trackerSelectorHelper = $dialog.find(".trackerSelectorHelper");
		var $trackerSelector = $dialog.find(".tracker");
		$projectSelector.change(function() {
			var projectId = $(this).val();
			$trackerSelector.empty();
			$trackerSelector.append($trackerSelectorHelper.find('option[data-project-id="' + projectId + '"]').clone());
		});
		$dialog.dialog({
			autoOpen: false,
			dialogClass: 'popup',
			modal: true,
			width: "auto",
			buttons: [{
				text: i18n.message("button.ok"),
				"class": "button",
				click: function() {
					var $projectSelector = $(this).find(".project");
					var projectName = $projectSelector.find('option[value="' + $projectSelector.val() + '"]').text();
					var $trackerSelector = $(this).find(".tracker");
					var trackerId = $trackerSelector.val();
					var $tracker = $trackerSelector.find('option[value="' + trackerId + '"]');
					var trackerName = $.trim($tracker.text());
					var iconUrl = contextPath + $tracker.attr("data-icon-url");
					var trackerTypeId = $tracker.attr("data-tracker-type-id");
					addEntityToLevel($dialog.data("addButton"), projectName + " → " + trackerName, trackerId, trackerTypeId, iconUrl, true);
					$(this).dialog("close");
				}
			}, {
				text: i18n.message("button.cancel"),
				"class": "button cancelButton",
				click: function() {
					$(this).dialog("close");
				}
			}]
		});
	};

	var addCustomTracker = function($addButton) {

		var $dialog = $("#traceabilityAddCustomTrackerDialog");
		$dialog.data("addButton", $addButton);
		$dialog.data("isInitial", $addButton.hasClass("addInitialButton"));
		var $projectSelector = $dialog.find(".project");
		var $trackerSelector = $dialog.find(".tracker");
		var $trackerSelectorHelper = $dialog.find(".trackerSelectorHelper");

		$projectSelector.empty();
		$trackerSelector.empty();
		$trackerSelectorHelper.empty();

		var busy = ajaxBusyIndicator.showBusyPage();
		$.getJSON(contextPath + "/ajax/traceabilityBrowser/addCustomTracker.spr", { trackerId: config.trackerId, initial : false }).done(function(result) {

			var $recentProjectGroup = $("<optgroup>", { label: i18n.message("recent.projects.label") });
			for (var i = 0; i < result.recentProjects.length; i++) {
				var project = result.recentProjects[i];
				$recentProjectGroup.append($("<option>", { value: project.id }).text(project.name));
			}
			$projectSelector.append($recentProjectGroup);

			var $otherProjectGroup = $("<optgroup>", { label: i18n.message("Projects") });
			for (var i = 0; i < result.projects.length; i++) {
				var project = result.projects[i];
				$otherProjectGroup.append($("<option>", { value: project.id }).text(project.name));
			}
			$projectSelector.append($otherProjectGroup);

			for (var i = 0; i < result.trackers.length; i++) {
				var tracker = result.trackers[i];
				var name = "";
				if (tracker.isBranch) {
					for (var n = 0; n < (tracker.branchLevel * 5); n++) {
						name += "&nbsp;";
					}
				}
				name += tracker.name;
				$trackerSelectorHelper.append($("<option>", {
					value: tracker.id,
					"class" : tracker.isBranch ? "branchTracker" : "",
					"data-project-id": tracker.projectId,
					"data-tracker-type-id": tracker.trackerTypeId,
					"data-icon-url" : tracker.iconUrl
				}).html(name));
			}

			ajaxBusyIndicator.close(busy);

			$dialog.dialog("open");
			$projectSelector.change();

		});
	};

	var initHeader = function() {

		var $resultContainer = $("#reportSelectorResult");

		var contextMenu = new ContextMenuManager({
			"selector": "#reportSelectorResult th .tracker-context-menu",
			"trigger": "left",
			"className": "reportContextMenu",
			"zIndex": 30,
			events : {
				show: function(opt) {
					opt.$trigger.addClass("activeMenu");
				},
				hide: function() {
					$resultContainer.find(".tracker-context-menu").removeClass("activeMenu");
				}
			},
			build: function($trigger, e) {
				var items = {};
				items["addField"] = {
					name: i18n.message("queries.contextmenu.add.field"),
					'callback' : function() {
						var $th = $trigger.closest("th");
						var entityIds = $th.attr("data-entityids").split(',');
						var trackerIds = [];
						for (var i = 0; i < entityIds.length; i++) {
							if (entityIds[i] > 1000) {
								trackerIds.push(entityIds[i]);
							}
						}
						var containerId = $(".reportSelectorTag").first().attr("id");
						$.ajax({
							url: contextPath + "/ajax/queries/getFields.spr",
							dataType: "json",
							data: {
								"tracker_ids" : trackerIds.join(",")
							},
							async: false,
							success: function(result) {
								var $selector = $("select#addFieldSelector_" + containerId);
								codebeamer.ReportSupport.createSelector(containerId, "addFieldSelector", result);
								var $th = $trigger.closest("th");
								var level = $th.attr("data-level");
								var fieldsOnLevel = [];
								$th.closest("tr").find("[data-level=\"" + level + "\"]").each(function() {
									var trackerId = $(this).attr("data-customfieldtrackerid").toString();
									var fieldId = $(this).attr("data-fieldlayoutid").toString();
									if (trackerId == "0") {
										fieldsOnLevel.push(fieldId);
									} else {
										fieldsOnLevel.push(trackerId + "_" + fieldId);
									}
								});
								$selector.find("option").each(function() {
									if ($.inArray($(this).attr("value"), fieldsOnLevel) > -1) {
										$(this).prop("disabled", true);
									}
								});
								$selector.data("triggeringColumn", $trigger.closest("th"));
								$selector.multiselect("refresh");
								$selector.multiselect("open");
							}
						});
					}
				};
				items["separator1"] = "---";
				items['removeColumn'] = {
					name: i18n.message("queries.contextmenu.removecolumn"),
					'callback': function() {
						removeColumn($trigger.closest("th"));
					},
					'icon': 'removeColumn',
					'disabled' : function() {
						var $th = $trigger.closest("th");
						return $th.closest("tr").find("th[data-level='" + $th.attr("data-level") + "']").length == 1;
					}
				};
				items['moveLeft'] = {
					name: i18n.message("queries.contextmenu.moveleft"),
					'callback': function() {
						moveColumnLeft($trigger.closest("th"));
					},
					'icon': 'left',
					'disabled': function() {
						var $th = $trigger.closest("th");
						return $th.closest("tr").find("th[data-level='" + $th.attr("data-level") + "']").first().get(0) == $th.get(0);
					}
				};
				items['moveRight'] = {
					name: i18n.message("queries.contextmenu.moveright"),
					'callback': function() {
						moveColumnRight($trigger.closest("th"));
					},
					'icon': 'right',
					'disabled': function() {
						var $th = $trigger.closest("th");
						return $th.closest("tr").find("th[data-level='" + $th.attr("data-level") + "']").last().get(0) == $th.get(0);
					}
				};

				return {items: items};
			}
		});

		$resultContainer.off("click", "th .removeColumn");
		$resultContainer.on("click", "th .removeColumn", function() {
			removeColumn($(this).closest("th"));
		});

		contextMenu.render();

	};

	return {
		"initConfiguration": initConfiguration,
		"saveConfiguration": saveConfiguration,
		"addEntityToLevel": addEntityToLevel,
		"initHeader" : initHeader,
		"initInlineEdit" : initInlineEdit,
		"addFieldToTable" : addFieldToTable
	};

})(jQuery);

