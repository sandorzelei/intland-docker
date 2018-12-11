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
 *
 */

var codebeamer = codebeamer || {};
codebeamer.DisplaytagTrackerItemsInlineEdit = codebeamer.DisplaytagTrackerItemsInlineEdit || (function($) {

	// On Planner we shoud reload the left pane to refresh counters if some of the fields are modified (e.g. Team, Release)
	var PLANNER_RELOAD_LEFT_PANE_FIELD_IDS = [5,19,21,31];

	// Always readonly fields (e.g. Submitted ad, Submitted by, Modified at, etc.)
	var READ_ONLY_FIELD_IDS = [0,4,6,7,11,74,75,76,79,81];

	var STORY_POINT_FIELD_ID = 19;

	// default values are added to config with false in order to easily find the possible config options:
	var config = {
		plannerMode: false,
		buildRelations: false,
		buildTransitionMenu: false,
		documentViewMode: false,
		rightPaneMode: false,
		itemDetailsMode: false		
	};

	var currentItemId = null;
	var navigateAway = false;

	var clearNavigateAway = function() {
		navigateAway = false;
	};

	/**
	 * Save reference field
	 * @param itemId
	 * @param fieldId
	 * @param newValue
	 * @param valueToUpdate If not null, this existing value will be updated for the new value (other values remains)
	 * @param successCallback
	 * @param failureCallback
	 */
	var saveReferenceField = function(itemId, fieldId, newValue, valueToUpdate, successCallback, failureCallback) {
		saveField(itemId, fieldId, newValue, null, null, successCallback, null, failureCallback, valueToUpdate);
	};

	var saveField = function(itemId, fieldId, newValue, $column, $original, successCallback, editor, failureCallback, valueToUpdate) {
		fieldId = parseInt(fieldId, 10);
		var updateColumn = true;
		if (typeof $column === "undefined" || $column == null) {
			// Search for tracker items row inside the table if $column not present
			var selector = 'tr[data-tt-id="' + itemId + '"] > td.fieldId_' + fieldId;
			$original = $(selector).contents();
			$column = $(selector);
		}
		var $releaseFieldHeader = $column.closest('table.inlineEditEnabled').find('th.release-field-header');
		var hasWikiLink = false;
		if ($column.length == 0) {
			updateColumn = false;
		} else {
			hasWikiLink = $column.find(".wikiLink").length > 0;
		}
		var data = {
			itemId : itemId,
			fieldId : fieldId,
			value : newValue
		};
		if (valueToUpdate) {
			data["valueToUpdate"] = valueToUpdate;
		}
		if (editor && editor.$oel) {
			var uploadConversationId = editor.$oel.data('uploadConversationId');
			if (uploadConversationId) {
				data['uploadConversationId'] = uploadConversationId;
			}
		}
		
		if (config.documentViewMode || config.rightPaneMode || config.itemDetailsMode) {
			data['renderAssignedAt'] = true;
		}
		
		$.ajax({
			url: contextPath + "/ajax/inlineEdit/saveField.spr",
			method: "POST",
			dataType: "json",
			data : data,
			success: function(result) {
				// Destroy WYSIWYG editor instance before it is removed from DOM
				if (editor) {
					editor.destroy();
				}
				if (result.hasOwnProperty("error")) {
					showOverlayMessage(result.error, null, true);
					if (updateColumn) {
						$column.empty();
						$column.append($original);
					}
				} else {
					showOverlayMessage();
					if (updateColumn) {
						if (hasWikiLink) {
							var $wikiLinkContainer = $column.find('.wikiLinkContainer');
							$wikiLinkContainer.empty();
							$wikiLinkContainer.append($(result.value).find(".wikiLink"));
							
							if ($wikiLinkContainer.data('UDBadge')) {
								$wikiLinkContainer.find('.wikiLink').append($wikiLinkContainer.data('UDBadge'));
							}
						} else {
							if (fieldId == 31) {
								$column.children(':not(div.sprint-history)').remove();
								$column.prepend(result.value);
							} else {
								$column.empty();
								$column.html(result.value);
							}
						}
						if (fieldId == 31 && $releaseFieldHeader.length && $releaseFieldHeader.attr('data-sprintHistory') == 'true') {
							refreshSprintHistory(itemId);
						}
					}
				}

				unlockTrackerItem(itemId);
				removeEditInProgressFromTable($column);

				if (config && config.hasOwnProperty("plannerMode") && config.plannerMode) {
					if (config.rightPaneMode) {
						codebeamer.planner.reloadLeftPane();
						codebeamer.planner.forceReportSelectorSearch();
					} else {
						if (PLANNER_RELOAD_LEFT_PANE_FIELD_IDS.indexOf(fieldId) !== -1) {
							codebeamer.planner.reloadLeftPane();
						}
						if (fieldId == 31) {
							codebeamer.planner.forceReportSelectorSearch();
						}
						codebeamer.planner.reloadSelectedIssue();
					}
				}
				
				if (config.documentViewMode) {
					reloadEditedIssue(itemId, undefined, true);
				}
				
				$column.data("dblclickFired", false);

				if (result.hasOwnProperty("type") && result.type == "references" && config && config.hasOwnProperty("buildRelations") && config.buildRelations) {
					refreshRelationBox(itemId);
				}
				// fixing the priority label, because it is also used in the right pane
				if (config.rightPaneMode && fieldId == 2) {
					var statusImg = $column.find('img');
					if (statusImg.length) {
						statusImg.wrap('<span class="tableIcon"></span>');
						$column.append(statusImg.attr('title'));
					}
				}
				
				if (result.hasOwnProperty("error") && failureCallback) {
					failureCallback();
				} else if (successCallback) {
					successCallback();
				}
			},
			fail: function() {
				if (updateColumn) {
					$column.empty();
					$column.append($original);
					$column.data("dblclickFired", false);
					unlockTrackerItem(itemId);
					removeEditInProgressFromTable($column);
				}
				if (failureCallback) {
					failureCallback();
				}
			}
		});
	};

	var refreshRelationBox = function(itemId) {
		$.post(
			contextPath + "/ajax/inlineEdit/reloadRelationBox.spr", { itemId: itemId },
			function(response) {
				var $response = $(response);
				var $responseSummaryTd = $response.find('tr[data-tt-id="' + itemId +'"] td.textSummaryData');
				var $summaryTds = $('tr[data-tt-id="' + itemId +'"] td.textSummaryData');
				if ($summaryTds.length > 0) {
					$summaryTds.each(function() {
						$(this).find(".relationItems").remove();
						$(this).append($responseSummaryTd.find(".relationItems"));
					});
				}
			}
		).fail(function() {
			//
		});
	};
	
	var refreshSprintHistory = function(itemId) {
		$.post(contextPath + '/ajax/inlineEdit/reloadSprintHistory.spr', 
			{ itemId: itemId },
			function(response) {
				var $response = $(response);
				var $responseReleaseCell = $response.find('tr[data-tt-id="' + itemId +'"] td.fieldId_31');
				var $releaseCell = $('tr[data-tt-id="' + itemId +'"] td.fieldId_31');
				if ($releaseCell.length) {
					$releaseCell.find('div.sprint-history').remove();
					$releaseCell.append($responseReleaseCell.find('div.sprint-history'));
				}
			}
		);
	}

	var removeEditInProgressFromTable = function($column) {
		$column.removeClass("columnEditingInProgress");
		$column.closest("table").removeClass("editingInProgress");
		currentItemId = null;
	};

	var renderEditor = function($column, itemId, fieldId, name) {

		var $original = $column.contents().clone(true);
		var data = {
			"itemId" : itemId,
			"fieldId" : fieldId
		};

		var cancelEditing = function() {
			$column.empty();
			$column.append($original);
			$column.data("dblclickFired", false);
			unlockTrackerItem(itemId);
			removeEditInProgressFromTable($column);
		};

		var renderTextAndNumberEditor = function(value, isInteger) {

			var endEditing = function($editor) {
				var newValue = $editor.val();
				if (newValue !== value) {
					saveField(itemId, fieldId, newValue, $column, $original);
				} else {
					cancelEditing();
				}
			};

			var $editor = $("<input>", { "type" : isInteger ? "number" : "text", "class" : "inlineEditor"});
			if (fieldId == STORY_POINT_FIELD_ID) {
				$editor.attr("min", 0);
			}
			$editor.val(value);
			var $wikiLink = $column.find(".wikiLink");
			if ($wikiLink.length > 0) {
				var $UDBadge = $wikiLink.find('.udBadge');
				if ($UDBadge.length) {
					$wikiLink.closest('.wikiLinkContainer').data('UDBadge', $UDBadge.detach());
				}
				$wikiLink.empty();
				$wikiLink.append($editor);
			} else {
				$column.empty();
				$column.append($editor);
			}
			$editor.focus();
			$editor.blur(function() {
				endEditing($(this));
			});
			$editor.keyup(function(e) {
				if (e.keyCode == 27) {
					cancelEditing();
				} else if (e.keyCode == 13) {
					endEditing($editor);
				}
			});
		};

		var renderMemberAndReferenceEditor = function() {

			var endEditing = function($editor, oldValue) {
				var newValue = $editor.val();
				if (newValue != oldValue) {
					saveField(itemId, fieldId, newValue, $column, $original);
				} else {
					cancelEditing();
				}
			};

			$.post(
				contextPath + "/ajax/inlineEdit/renderReferenceAndMemberFieldEditor.spr", data,
				function(response) {
					var $inputElem = $(response),
						$sprintHistory = $column.find('div.sprint-history');
					if ($sprintHistory.length) {
						$column.children(':not(div.sprint-history)').remove();
						$column.prepend($inputElem);
					} else {
						$column.html($inputElem);
					}
					setTimeout(function() {
						var $tokenInput = $inputElem.find('input[type="text"]').first();
						$tokenInput.focus();
						var $valueInput = $inputElem.find('input[type="hidden"]');
						var oldValue = $valueInput.val();
						$tokenInput.click(function(e) {
							e.stopPropagation();
						});
						$("html").on("click", function(e) {
							var $target = $(e.target).hasClass(".chooseReferences") ? $(e.target) : $(e.target).closest(".chooseReferences");
							var $referenceSettingDialog = $(e.target).hasClass(".referenceSettingDialog") ? $(e.target) : $(e.target).closest(".referenceSettingDialog");
							if ($target.length == 0 && $referenceSettingDialog.length == 0) {
								endEditing($valueInput, oldValue);
								$(".referenceSettingDialog").remove();
								$("html").off("click");
							}
						});
						$tokenInput.keyup(function(e) {
							if (e.keyCode == 27) {
								cancelEditing();
								$("html").off("click");
							} else if (e.keyCode == 13) {
								endEditing($valueInput, oldValue);
								$("html").off("click");
							}
						});
					}, 100);
				}
			).fail(function() {
				cancelEditing();
			});
		};

		var renderDateEditor = function(fieldLabel) {

			var endEditing = function($editor) {
				setTimeout(function() {
					if (!$(".xdsoft_datetimepicker").is(":visible")) {
						var newValue = $editor.val();
						if (newValue != $original.text()) {
							saveField(itemId, fieldId, newValue, $column, $original);
						} else {
							cancelEditing();
						}
						jQueryDatepickerHelper.destroyCalendar(inputId);
					}
				}, 300);
			};

			$column.empty();
			var inputId = "inlineEdit_date_" + itemId + "_" + fieldId;
			var $dateContainer = $("<span>", { "class" : "inlineEditDateContainer"});
			var $dateInput = $("<input>", { id: inputId });
			$dateInput.val($.trim($original.text()));
			var $datePickerImg = $("<img>", { id: "calendarLink_" + inputId, "class": "calendarAnchorLink", src: contextPath + "/images/newskin/action/calendar.png"});
			$dateContainer.append($dateInput);
			$dateContainer.append($datePickerImg);
			setTimeout(function() {
				$dateInput.focus();
			}, 1);
			$datePickerImg.click(function(e) {
				e.stopPropagation();
				jQueryDatepickerHelper.initCalendar(inputId, "", fieldLabel, true);
			});
			$column.append($dateContainer);
			$dateInput.blur(function(e) {
				endEditing($(this));
			});
			$dateInput.keyup(function(e) {
				if (e.keyCode == 27) {
					cancelEditing();
				} else if (e.keyCode == 13) {
					endEditing($dateInput);
				}
			});
		};

		var renderChoiceEditor = function(result) {
			$column.empty();
			if (result.hasOwnProperty("selectedOptionId")) {
				// Single choice
				var $select = $("<select>");
				$select.append($("<option>", { value: -1 }).text("--"));
				for (var i = 0; i < result.choiceOptions.length; i++) {
					var option = result.choiceOptions[i];
					$select.append($("<option>", { value : option.id }).text(option.name));
				}
				if (result.selectedOptionId == null) {
					$select.val(-1);
				} else {
					$select.val(result.selectedOptionId);
				}
				$column.append($select);
				$select.focus();
				$select.blur(function(e) {
					var newValue = $select.val();
					if (newValue != result.selectedOptionId) {
						saveField(itemId, fieldId, newValue, $column, $original);
					} else {
						cancelEditing();
					}
				});
			} else {
				renderMemberAndReferenceEditor();
			}
		};

		var renderBoolEditor = function(value) {
			$column.empty();
			var $select = $("<select>");
			$select.append($("<option>", { value: "none" }).text("--"));
			$select.append($("<option>", { value: "true" }).text(i18n.message("boolean.true.label")));
			$select.append($("<option>", { value: "false" }).text(i18n.message("boolean.false.label")));
			if (value == null) {
				$select.val("none");
			} else {
				$select.val(value.toString());
			}
			$column.append($select);
			$select.blur(function(e) {
				var newValue = $select.val();
				saveField(itemId, fieldId, newValue, $column, $original);
			});
		};

		var renderColorField = function() {

			var endEditing = function($editor, oldValue) {
				var newValue = $editor.val();
				if (newValue != oldValue) {
					saveField(itemId, fieldId, newValue, $column, $original);
				} else {
					cancelEditing();
				}
			};

			$.post(
				contextPath + "/ajax/inlineEdit/renderColorField.spr", data,
				function(response) {
					$column.html(response);
					var $valueInput = $("#inlineEditColorFieldEditor");
					$valueInput.focus();
					var oldValue = $valueInput.val();
					$("html").on("click", function(e) {
						var $target = $(e.target);
						if (!$target.closest("a").is(".colorPicker") && !$target.is(".colorPickerDialog") && $target.closest(".colorPickerDialog").length == 0) {
							endEditing($valueInput, oldValue);
							$(".colorPickerDialog:not(.reportColorPicker)").remove();
							$("html").off("click");
						}
					});
				}
			).fail(function() {
				cancelEditing();
				$(".colorPickerDialog:not(.reportColorPicker)").remove();
			});
		};

		var renderWikiTextEditor = function(value, name, uploadConversationId) {

			var hideTableHeaderContextMenus = function() {
				$column.closest("table").find("th > .tracker-context-menu").hide();
			};

			var showTableHeaderContextMenus = function() {
				$column.closest("table").find("th > .tracker-context-menu").show();
			};

			var setStickyToolBar = function(editor) {

				var $toolBar = $(editor.opts.toolbarContainer);
				var toolBarOffset = $toolBar.offset().top;

				var scrollHandler = function() {
					var scrollTop = $(this).scrollTop();
					if (scrollTop >= toolBarOffset) {
						var topOffset = 0;
						if ($(".reportSelectorActionBar").length > 0) {
							topOffset = $(".reportSelectorActionBar").outerHeight();
						}
						$toolBar.css("position", "fixed");
						$toolBar.css("top", topOffset);
						$toolBar.css("width", "100%");
						$toolBar.css("z-index", 2);
					} else {
						$toolBar.css("position", "static");
						$toolBar.css("width", "");
						$toolBar.css("top", "");
					}
				};

				$(window).scroll(scrollHandler);

			};

			navigateAway = true;

			var isPlanner = config && config.hasOwnProperty("plannerMode") && config.plannerMode && !config.rightPaneMode;

			if (isPlanner) {
				var toolBarContainerHeight;
				var $plannerCenterPane = $("#plannerCenterPane");
			}

			hideTableHeaderContextMenus();

			var $inlineEditor = codebeamer.WYSIWYG.createInlineEditorTextarea(value),
				newEditorId = $inlineEditor.attr('id');

			var $editorContainer = $("<div>", { "id" : "containerId" + newEditorId.replace('editorTA-', ''), "class" : "edited editor-wrapper"});
			$editorContainer.append($inlineEditor);

			$column.empty();
			$column.append($editorContainer);

			$inlineEditor.on('saveChanges', function() {
				var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);
				editor.toolbar.disable();
				var $textarea = $("#" + newEditorId);
				var promise = codebeamer.WYSIWYG.getEditorMode($textarea) == 'wysiwyg' ? codebeamer.WikiConversion.saveEditor(newEditorId) : $.when();
				promise.then(function() {
					saveField(itemId, fieldId, $textarea.val(), $column, $original, function() {}, editor);
					navigateAway = false;
					showTableHeaderContextMenus();
					if (isPlanner) {
						$plannerCenterPane.height($plannerCenterPane.height() + toolBarContainerHeight);
					}
				});
			});

			$inlineEditor.on('cancelEditing', function() {
				var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);
				editor.toolbar.disable();
				codebeamer.EditorFileList.removeAllFiles(editor.$oel).then(function() {
					if (isPlanner) {
						$plannerCenterPane.height($plannerCenterPane.height() + toolBarContainerHeight);
					}
					editor.destroy();
					navigateAway = false;
					$column.empty();
					$column.append($original);
					unlockTrackerItem(itemId);
					removeEditInProgressFromTable($column);
					showTableHeaderContextMenus();
				});
			});

			$inlineEditor.on('froalaEditor.initialized', function() {
				var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);
				if (isPlanner) {
					toolBarContainerHeight = $(editor.opts.toolbarContainer).height();
					$plannerCenterPane.height($plannerCenterPane.height() - toolBarContainerHeight);
				}
				if ($(editor.opts.toolbarContainer).closest("#panes").length == 0 && !config.rightPaneMode) {
					setStickyToolBar(editor);
				}
			});

			var options = {
				heightMin: config.rightPaneMode ? 100 : 0,
				toolbarBottom: config.rightPaneMode,
				toolbarSticky: false,
				toolbarContainer: config.rightPaneMode ? '' : '#toolbarContainer'
			};
			
			var createOverlayHeader = function(id, name) {
				var result;

				result = "<span class='editor-overlay-item-name'>" + name + "</span> <span class='breadcrumbs-separator'>&raquo;</span>";
				result = result + i18n.message("wysiwyg.default.item.overlay.header") + " <span class='editor-overlay-item-id'>#" + id + "</span>";

				return result;
			};

			var additionalOptions = {
				save: function() {
					this.$oel.trigger('saveChanges');
				},
				cancel: function() {
					this.$oel.trigger('cancelEditing');
				},
				useAutoResize: true,
				focus: true,
				overlayHeader: createOverlayHeader(itemId, name),
				uploadConversationId: uploadConversationId,
				hideQuickInsert: config.rightPaneMode && fieldId == 80 ? true : false, // do not display quick insert for description field in right pane
				ignorePreviouslyUploadedFiles: true,
				insertNonImageAttachments: true
			};

			codebeamer.WikiConversion.bindEditorToEntity(newEditorId, '[ISSUE:' + itemId + ']');
			codebeamer.WYSIWYG.initEditor(newEditorId, options, additionalOptions, true);

		};

		var renderURLEditor = function(value) {
			var endEditing = function($editor) {
				var newValue = $editor.val();
				if (newValue !== value) {
					saveField(itemId, fieldId, newValue, $column, $original);
				} else {
					cancelEditing();
				}
			};

			var $editor = $("<input>", { "type" : "text", "class" : "inlineEditor"});
			var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
			$editor.attr("id", "url_editor_" + uniqueId);
			$editor.val(value);
			var $div = $("<div>", { "class" : "urlFieldEditor"});
			$div.append($editor);
			var $pencil = $("<span>", { "class" : "urlFieldPencilIcon"});
			$pencil.click(function() {
				showPopupInline(contextPath + '/wysiwyg/plugins/plugin.spr?pageName=wikiHistoryLink&fieldId=' + 'url_editor_' + uniqueId, { geometry: '90%_90%' }); return false;
			});
			$div.append($pencil);
			$column.empty();
			$column.append($div);
			$editor.focus();
			$("html").on("click", function(e) {
				var $target = $(e.target);
				if ($target.closest(".urlFieldEditor").length == 0) {
					endEditing($("#url_editor_" + uniqueId));
					$("html").off("click");
				}
			});
			$editor.keyup(function(e) {
				if (e.keyCode == 27) {
					cancelEditing();
				} else if (e.keyCode == 13) {
					endEditing($editor);
				}
			});
		};
		
		$.ajax({
			url: contextPath + "/ajax/inlineEdit/validateField.spr",
			method: "POST",
			dataType: "json",
			data: data,
			success: function(result) {
				if (result && result.hasOwnProperty("editable") && result.editable) {
					$column.addClass("columnEditingInProgress");
					$column.closest("table").addClass("editingInProgress");
					lockTrackerItem(itemId);
					if (result.type == "integer" || result.type == "decimal" || result.type == "text" || result.type == "duration") {
						renderTextAndNumberEditor(result.value, result.type == "integer");
					} else if (result.type == "member" || result.type == "references" || result.type == "country" || result.type == "language") {
						renderMemberAndReferenceEditor();
					} else if (result.type == "date") {
						renderDateEditor(result.fieldLabel);
					} else if (result.type == "choice") {
						renderChoiceEditor(result);
					} else if (result.type == "bool") {
						renderBoolEditor(result.value);
					} else if (result.type == "color") {
						renderColorField();
					} else if (result.type == "wikitext") {
						renderWikiTextEditor(result.value, name, result.uploadConversationId);
					} else if (result.type == "url") {
						renderURLEditor(result.value);
					} else {
						unlockTrackerItem(itemId);
						removeEditInProgressFromTable($column);
					}
				} else if (result && result.hasOwnProperty("noFieldForItem") && result.noFieldForItem) {
					showFancyAlertDialog(i18n.message("displaytag.tracker.items.inline.edit.no.field"));
				} else if (result && result.hasOwnProperty("type") && result.type == "table") {
					showFancyAlertDialog(i18n.message("displaytag.tracker.items.inline.edit.not.editable.table.field"))
				} else {
					showFancyAlertDialog(i18n.message("displaytag.tracker.items.inline.edit.no.permission"));
				}
			},
			fail: function() {
				unlockTrackerItem(itemId);
			}
		});
	};

	var startsWith = function(string, prefix) {
		return string.slice(0, prefix.length) == prefix;
	};

	var buildTransitionMenu = function($container) {
		$container.on("click", "tr:not(.itemType_Testrun) .textSummaryData .trackerImage", function(e) {
			var $target = $(e.target);
			var $trigger = $target.next(".menu-container").first();
			if ($trigger.length == 0) {
				var $menuContainer = $("<span>", { "class" : "menu-container"});
				$target.after($menuContainer);
				$trigger = $menuContainer;
			}
			var rowId = $trigger.closest("tr").attr("id");
			var id = rowId;
			var revision;
			if (!$.isNumeric(rowId)) {
				var parts = rowId.split("/");
				id = parts[0];
				revision = parts[1];
			}
			buildAjaxTransitionMenu($trigger, {
				'task_id': id,
				'cssClass': 'inlineActionMenu transition-action-menu',
				'builder': 'trackerItemTransitionsOverlayActionsMenuBuilder',
				'revision': revision
			});
		});
	};

	var handleLinks = function($container) {
		$container.on("click", ".fieldColumn a:not(.ui-menu-item-wrapper):not(.popupButton):not(.timeRecording)", function(e) {
			e.preventDefault();
			var $link = $(this);
			var $column = $link.closest(".fieldColumn");
			setTimeout(function() {
				if (!$column.data("dblclickFired")) {
					var isCtrlKey = codebeamer.HotkeyFormatter.isMac ? e.metaKey : e.ctrlKey, 
						target = isCtrlKey ? '_blank' : codebeamer.userPreferences.newWindowTarget,
						newWindow = window.open($link.attr("href"), target);
					
					if (newWindow) {
						newWindow.focus();
					}
				}
			}, 300);
		});
	};

	var initUnloadEvents = function() {
		$(window).on('beforeunload', function() {
			if (navigateAway) {
				return true;
			}
		});
		$(window).on('unload', function() {
			if (currentItemId) {
				unlockTrackerItem(currentItemId, false);
			}
		});
	};

	var preventFormSubmitOnEnter = function() {
		if ($("#browseTrackerForm").length > 0) {
			$(document).on("keypress", "#browseTrackerForm", function(event) {
				var $target = $(event.target);
				if ($target.is("textarea") || $target.is(".contextualSearchBox")) {
					return true;
				}
				return event.keyCode != 13;
			});
		}
	};

	var startItemEditing = function($column, itemId, fieldId, name) {
		isItemLocked(itemId).done(function(response) {
			if (response.result == true) {
				showFancyAlertDialog(i18n.message("This item is locked by an other user. Please try again later."));
			} else {
				$column.data("dblclickFired", true);
				currentItemId = itemId;
				renderEditor($column, itemId, fieldId, name);
			}
		});
	}
	
	var init = function($container, settings) {

		$.extend(config, settings || {});

		handleLinks($container);
		preventFormSubmitOnEnter();
		initUnloadEvents();

		if (config.buildTransitionMenu) {
			buildTransitionMenu($container);
		}

		$container.on("dblclick", ".fieldColumn, .fieldColumn a", function(e) {
			e.preventDefault();
			e.stopPropagation();

			var $column = $(e.target);
			if (!$column.hasClass("fieldColumn")) {
				$column = $column.closest(".fieldColumn");
			}

			config.rightPaneMode = !!$column.closest('table.propertyTable.inlineEditEnabled').length;

			// Disable editing if an other edit is in progress
			if ($column.closest("table").hasClass("editingInProgress")) {
				return false;
			}

			var itemId, name;
			if ($column.attr("data-item-id")) {
				itemId = $column.attr("data-item-id");
				name = $column.attr("data-name");
			} else {
				itemId = $column.closest("tr").attr("id");
				name = $column.closest("tr").data("name");
			}
			if (!itemId) {
				 var $propertyTable = $column.closest('table.propertyTable');
				 if ($propertyTable.length) {
					 itemId = $propertyTable.attr('data-item-id');
					 name = $propertyTable.attr('data-item-name');
				 }
			}

			var classes = $column.attr("class").toString().split(" ");
			var fieldId = null;
			for (var i = 0; i < classes.length; i++) {
				if (startsWith(classes[i], "fieldId_")) {
					fieldId = parseInt(classes[i].replace("fieldId_", ""), 10);
					break;
				}
			}

			
			if (!itemId || !fieldId || READ_ONLY_FIELD_IDS.indexOf(fieldId) > -1) { // Disable editing for always readonly and status fields
				return false;
			}

			if (config.documentViewMode && $('#' + itemId).is('.edited')) {
				showFancyConfirmDialogWithCallbacks(i18n.message('tracker.view.layout.document.navigate.from.subtree.confirm'), function() {
					startItemEditing($column, itemId, fieldId, name);
				});
			} else {
				startItemEditing($column, itemId, fieldId, name);
			}		
		});
	};

	var initForField = function($field, rightPaneMode) {
		var itemId, name, fieldId;
		var classes = $field.attr('class').toString().split(' ');

		initUnloadEvents();

		if ($field.attr('data-item-id')) {
			itemId = $field.attr('data-item-id');
			name = $field.attr('data-item-name');
		} 

		for (var i = 0; i < classes.length; i++) {
			if (startsWith(classes[i], 'fieldId_')) {
				fieldId = parseInt(classes[i].replace('fieldId_', ''), 10);
				break;
			}
		}

		if (!itemId || !fieldId || READ_ONLY_FIELD_IDS.indexOf(fieldId) > -1) {
			return;
		}
	
		$field.on('dblclick', function(e) {
			if ($field.hasClass('columnEditingInProgress')) {
				return;
			}

			e.preventDefault();
			e.stopPropagation();
			
			config.rightPaneMode = rightPaneMode;
			
			isItemLocked(itemId).done(function(response) {
				if (response.result == true) {
					showFancyAlertDialog(i18n.message('This item is locked by an other user. Please try again later.'));
				} else {
					$field.data('dblclickFired', true);
					currentItemId = itemId;
					renderEditor($field, itemId, fieldId, name);
				}
			});
		});
	};
	
	return {
		"init": init,
		"initForField": initForField,
		"saveField": saveField,
		"saveReferenceField": saveReferenceField,
		"clearNavigateAway" : clearNavigateAway
	};

})(jQuery);

