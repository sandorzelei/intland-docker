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
*/
/*
   Javascript functions for documentView.jsp
*/
function addEditorForTarget($target, onOpen, onSubmit, onSubmitted, defaults) {
	var $editable = $target.find(".description-container");

	var $row = $target.closest("tr[id]");
	var rowId = $row.attr("id");

	if ($row.data("hasemptyrequired")) {
		var updateUrl = contextPath + "/proj/tracker/addUpdateTrackerItem.spr?task_id=" + rowId + "&isPopup=true&layoutMode=mandatory&minimal=true";
		inlinePopup.show(updateUrl, {"geometry": "large"});
	} else {
		if($editable.hasClass("edited")) {
			return;
		}

		var loadEditor = function () {
			if ($editable.size() == 0) {
				console.log("$editable was empty, couldn't reload the editor");
				return;
			}

			var oldHtml = $editable.html();
			$editable.get(0).oldHtml = oldHtml;

			var url = contextPath + "/requirement/" + rowId;
			var processorFunction = function (data) {
				processJson(data, $editable, onOpen, onSubmit, onSubmitted, url);
			};

			if ($editable.is(".new-item")) {
				var newItemId = $target.parents(".requirementTr").attr("id");
				var newItemData = {
						"requirement": {
							"id": newItemId,
							"description": ""
						}
				};

				// use the tracker field defaults in the new editor instance
				if (defaults && defaults.description) {
					newItemData.requirement.description = defaults.description;
				}

				if (defaults && defaults.name) {
					newItemData.requirement.nameUnescaped = defaults.name;
				}

				newItemData.requirement.editorOverlayHeader = i18n.message("wysiwyg.new.document.view.item.overlay.header");

				// the default description format is always wiki
				newItemData.requirement.descriptionFormat = 'W';

				processorFunction(newItemData);
			} else {
				$.getJSON(
					url,
					{
						showEmptyName: true
					},
					processorFunction
				);
			}


			clearSelection();
		};

		loadEditor();
	}
}

function addEditor($editables, onOpen, onSubmit, onSubmitted) {
	$editables.dblclick(function(e) {
		var $target = $(e.target);
		addEditorForTarget($target, onOpen, onSubmit, onSubmitted);
	});
}

function createEditorHandler(onOpen, onSubmit, onSubmitted, selector) {
	return function(e) {
		var $target = $(e.target).parents('tr').find(selector);
		addEditorForTarget($target, onOpen, onSubmit, onSubmitted);
	};
}

function removeEditedClass(id) {
	$("#" + id).removeClass("edited");
}

function processJson(data, $editable, onOpen, onSubmit, onSubmitted, url) {
	// the onOpen may return a string or an object where the "html" property contains the html string
	onOpen(data, function() {
		// data.requirement.id, 'uploadForRequirement-' + requirementId
		var $inlineEditor = codebeamer.WYSIWYG.createInlineEditorTextarea(data.requirement.description),
			newEditorId = $inlineEditor.attr('id');

		var $name = $editable.closest('.name');
		$name.data('originaldraggable', $name.attr('draggable'));
		$name.attr('draggable', false)

		$editable.addClass('editor-wrapper');
		try {
			$editable.append($inlineEditor);

			// remove the plainText or wikicontent from the editable area and replace it with the editor
			$editable.find('.wikiContent,.plainTextContent').remove();
			var $summaryEditor = createNestedSummaryEditor(data, newEditorId);

			$editable.prepend($summaryEditor);

			$inlineEditor.on('saveChanges wysiwyg:save', function() {
				var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);
				editor.toolbar.disable();
				saveChanges(editor, onSubmit, onSubmitted, url);
			});

			$inlineEditor.on('cancelEditing', function() {
				var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId),
					$editable = editor.$oel.closest('.description-container');

				editor.toolbar.disable();
				codebeamer.EditorFileList.removeAllFiles(editor.$oel).then(function() {
					editor.destroy();
					cancelChanges($editable);
					autoAdjustPanesHeight();
				});
			});

			var options = {
			    heightMin: 200,
			    toolbarBottom: false,
			    toolbarContainer: '#toolbarContainer',
			    toolbarSticky: false
			};

			var additionalOptions = {
				save: function() {
					this.$oel.trigger('saveChanges');
				},
				cancel: function() {
					this.$oel.trigger('cancelEditing');
				},
			    uploadConversationId: 'uploadForRequirement-' + data.requirement.id,
			    insertNonImageAttachments: true,
			    useAutoResize: true,
			    overlayHeader: data.requirement.editorOverlayHeader,
			    readonly: !$editable.is('.editable'),
			    disableFormattingOptionsOpening: true,
			    ignorePreviouslyUploadedFiles: true,
                editorFormat: data.requirement.descriptionFormat,
                useFormatSelector: false,
                extraButtons: ['cbSave', 'cbCancel']
			};

			$editable.on('cbEditorPostRender', function() {
				$editable.find('.nested-summary-editor').focus();
			});

			codebeamer.WikiConversion.bindEditorToEntity(newEditorId, '[ISSUE:' + data.requirement.id + ']');
			codebeamer.WYSIWYG.initEditor(newEditorId, options, additionalOptions, true);

			$summaryEditor.on('keydown', function(e) {
				var ctrlKey = codebeamer.WYSIWYG.isMac() ? e.metaKey : e.ctrlKey,
					keycode = e.which;

				if (ctrlKey && !e.shiftKey && !e.altKey && keycode == $.FE.KEYCODE.S) {
					additionalOptions.save.call(codebeamer.WYSIWYG.getEditorInstance(newEditorId));
					return false;
				}
			});
			$summaryEditor.on('focus click', function() {
				codebeamer.WysiwygShortcuts.setActualEditor(codebeamer.WYSIWYG.getEditorInstance(newEditorId));
			});
		} catch (e) {
			console.log('Error in init inline editor:' + e);
		}
	});
}

function saveChanges(editorInstance, onSubmit, onSubmitted, url) {
	var $input = editorInstance.$oel,
		$editable = $input.closest('.description-container');

	if ($editable.hasClass('processing')) {
		return;
	}

	$editable.addClass('processing');

	var data = onSubmit($input);

	if (data === "error") {
		$editable.removeClass('processing');
		showFancyAlertDialog(i18n.message("tracker.view.layout.document.summar.required.message"));
		editorInstance.toolbar.enable();
		return;
	}

	var $row = $input.closest("tr[id]");
	var id = $row.attr("id");
	var url = contextPath + "/ajax/proj/tracker/updaterequirement.spr?task_id=" + id;

	data = $.extend(data, {
		remove_query_plugin_row_ids: true
	});

	if (!$.isNumeric(id)) {
		// submitting a new item
		url = contextPath + "/ajax/proj/tracker/createtrackeritem.spr"

		var newNodeParams = $row.data("newNodeParams");

		$.extend(data, newNodeParams, {
				_method: "post",
				uploadConversationId: "uploadForRequirement-" + id,
				tracker_id: trackerObject.config.id
		});

		var filterParameters = getFilterParameters();
		$.extend(data, filterParameters);

		if (data.position == "after" || data.position == "before") {
			var tree = $.jstree.reference("#treePane");
			var $referenceNode = tree.get_node("#" + data["parent.id"]);
			var parentId = tree.get_parent($referenceNode);
			if (parentId) {
				var parent = tree.get_node(parentId);
				parentId = parent.li_attr["type"] != "tracker" ? parentId : "-1";
			}
			parentId = parentId || "-1";

			data["parent.id"] = parentId;
		}

		if (trackerObject.config.branchId) {
			data["branchItem"] = true;
		}
	}
	//var updateUrl = contextPath + "/ajax/proj/tracker/updaterequirement.spr?task_id=" + id;
	$.ajax({
		type: "post",
		url: url,
		data: data,
		dataType: "json",
		success: function(data_) {
			if (data_.success == 'false') {
				showOverlayMessage(data_.errorMessage || i18n.message('ajax.changes.error.try.reload'), 3, true);
				$editable.removeClass('processing');
				$input.trigger('cancelEditing');
				return;
			}
			var newItem = $row.find(".new-item").size() != 0;

			var tree = $.jstree.reference("#treePane");
			if (newItem) {
				codebeamer.common.handleAddNewItem(data_, $row);
			} else {
				tree.refresh(data_.requirement.id);
			}

			// restore view

			if (!newItem || data_.matchesFilters) {
				editorInstance.destroy();
				var htmlOnSubmitted = onSubmitted(data_);
				$editable.html(htmlOnSubmitted);
				$editable.removeClass("edited");
				//enableHighlight($editable, true);

				if (trackerObject.config.branchId) {
					// if this is a branch then show the Updated on Branch badge
					var $branchBadgeGroup = $editable.closest('.requirementTr').find('.branch-badge-group');

					// only add the badge if it was not already added
					if ($branchBadgeGroup.find('.updatedBadge.branchDivergedBadge:not(.masterDivergedBadge),.updatedBadge.createdBadge').size() == 0) {
						var title = i18n.message('tracker.branching.item.diverged.from.master.label');
						var $badge = $("<span>", {
							'class': 'referenceSettingBadge updatedBadge branchDivergedBadge',
							'data-issue-id': data_.requirement.id,
							'data-original-id': '',
							'title': title
						}).html(title);

						$branchBadgeGroup.append($badge);
					}
				}

				// update the issue version to the latest to prevent errors
				$row.find("[name=item-version]").val(data_.requirement.version);

				// flash edited part
				flashChanged($editable);

				// show the summary after editing only if it is not empty
				$row.find(".name:not(.empty-name)").show();
			} else {
				editorInstance.destroy();
				$editable.remove();
			}

			if (data_.changedParagraphs) {
				// replace the paragraph ids that changed
				$.each(data_.changedParagraphs, function (key, value) {
					$("#" + key + ".requirementTr .releaseid").html(value);
				});
			}

			initializeMinimalJSPWikiScripts($row);

			removeEditedClass(id);

			$editable.removeClass('processing');
			autoAdjustPanesHeight();
		},
		error: function(jqXHR, textStatus, errorThrown) {
			showOverlayMessage(jqXHR.responseText || i18n.message('ajax.changes.error.try.reload'), 3, true);
			$editable.removeClass('processing');
			$input.trigger('cancelEditing');
		}
	});
}

function reloadAfterChange(issueId) {
	//refresh the tree if available
	if ($.jstree.reference(trackerObject.config.treePaneId)) {
		trackerObject.reload("rightPane", true);
	}

	// reload the contents of the properties panel
	issueId = issueId || $("#task_id").val();
	if (issueId) {
		trackerObject.showIssueProperties(issueId, trackerObject.config.id, $("#issuePropertiesPane"), trackerObject.config.revision.length == 0, true);
	}
}

function cancelChanges($editable) {
	codebeamer.NavigationAwayProtection.removeInspectedElement($editable.find('.nested-summary-editor'));

	var oldHtml = $editable.get(0).oldHtml;
	$editable.html(oldHtml);
	$editable.removeClass("edited");

	var $row = $editable.closest('.requirementTr');
	var $name = $row.find('.name');

	$row.removeClass('initialized');

	// show the name
	if (!$name.is('.empty-name')) {
		$name.show();
	}

	var id = $row.attr("id");

	$name.removeAttr("draggable");
	// if this is just a placeholder for a new item remove it on cancel
	if ($editable.is('.new-item')) {
		// i have no idea why but ie11 needs this settimeout otherwise the tree nodes get blocked after the remove (issue 739234)
		setTimeout(function () {
			// if there are no other items, show the empty message
			if ($row.closest("table").find("tr").length == 1) {
				$("#emptyViewMessage").show();
			}
			$row.remove();
		}, 300);
	}

	$name.attr('draggable', $name.data('originaldraggable'));

//	// unlock the item
	unlockTrackerItem(id);

	removeEditedClass(id);
}

function getIssueVersion($input) {
	var version = $input.parents(".requirementTr").find("[name=item-version]").val();
	return version;
}

function onNameSubmitted(data_) {
	var t = $.jstree.reference("#treePane");
	var id = data_.requirement.id;
	if (t) {
		/*var $node = $("li[id=" + id + "]");
		var prefix = $node.attr("prefix");
		t.set_text($node.attr("id"), (prefix ? prefix : '') + data_.requirement.name);*/
        var node = t.get_node("#" + id);
        trackerObject.loadNode(node);
	}
	// Refresh name
	var issueTr = $("tr#" + id);
	if (issueTr.length > 0) {
		var $name = issueTr.find(".name");
		$name.find("span.editable").html(data_.requirement.name);
		if (!data_.requirement.name) {
			$name.addClass("empty-name");
		} else {
			$name.removeClass("empty-name");
		}
		// Load issue if first saved (newly created)
		if (issueTr.data("newNodeParams")) {
			trackerObject.reloadIssue(id, null, trackerObject.config.id, trackerObject.config.revision, trackerObject.config.selectedView);
		}
	}
	return data_.requirement.name;
}

function refreshProperties(id, skipReloadIssue) {
	if (window.trackerObject) {
		trackerObject.showIssueProperties(id, trackerObject.config.id, $('#issuePropertiesPane'), true, true);
		if (!skipReloadIssue) {
			trackerObject.reloadIssue(id);
		}
	}
}

function refreshSelectedIssueProperties(skipReloadIssue) {
	var selectedId = $('#issuePropertiesPane').data('showingIssue');
	refreshProperties(selectedId, skipReloadIssue);
}

function isNewItem($row) {
	var newItem = $row.find(".new-item").size() != 0;
	return newItem;
}

// global event-handler for nested-summary editors using event-bubbling
function initNestedSummaryEditorEvents() {
	// if tab or enter is pressed in the nested-summary then move to the wysiwyg editor
	$(document).on('keydown', '.nested-summary-editor', function(event) {
		var keyCode = event.keyCode;
		if (keyCode ==  $.ui.keyCode.TAB || keyCode ==  $.ui.keyCode.ENTER) {
			var $editor = $('#' + $(this).data('editorId'));
			if ($editor.closest('.editable').hasClass('wysiwyg')) {
				$editor.froalaEditor('events.focus');
			} else {
				$editor.focus();
			}
			return false;
		}
	});

	$(document).on('input', '.nested-summary-editor', function(event) {
		throttle(function() {
			codebeamer.NavigationAwayProtection.checkElement($(event.target));
		});
	});
}

function createNestedSummaryEditor(data, editorId) {
	var $requirementTr = $(".requirementTr#" + data.requirement.id);
	var summaryEditable = $requirementTr.data("summaryEditable");
	var descriptionEditable  = $requirementTr.data("descriptionEditable");
	var name = data.requirement.name ? data.requirement.nameUnescaped : "";
	var $summaryEditor = $("<input>", {"class": "nested-summary-editor", "value": data.requirement.nameUnescaped, "data-editor-id": editorId});
	if (!summaryEditable) {
		$summaryEditor.attr("disabled", "disabled");
	} else {
		codebeamer.NavigationAwayProtection.addInspectedElement($summaryEditor);
	}
	var $paragraphId = $(".requirementTr#" + data.requirement.id + " .releaseid:first").clone()
	var $div = $("<div>", {"class": "nested-summary-container"});
	$div.append($paragraphId);
	$div.append($summaryEditor);

	return $div.wrap('<div class="nested-summary"></div>').parent();
}

function onDescriptionOpen(data, resolve) {
	// check if the item is locked
	var lockHandler = isItemLocked(data.requirement.id);

	/*
	 * this functions is a promise-like handler. if the item is locked it displays a message, otherwise it makes the item
	 * editable and calls the resolve function.
	 */
	lockHandler.done(function(response) {
		if (response.result == true) {
			showOverlayMessage(i18n.message("document.lockedBy.info", data.requirement.name, response.user), 5, true);
		} else {
			var requirementId = data.requirement.id;
			var t = $.jstree.reference("#treePane");
			if (t) {
				t.deselect_all();
				t.select_node($("li[id=" + data.requirement.id + "]")); // select the node so after refreshing the tree it gets reloaded
			}

			var $requirementTr = $(".requirementTr#" + requirementId);

			// lock the item. we don't need to wait for the locking result
			lockTrackerItem(data.requirement.id);

			// set the item as edited
			$requirementTr.addClass("edited");

			// hide the summary header because it's already displayed in the editor
			$requirementTr.find(".name").hide();

			resolve();
		}
	});
}

function onDescriptionSubmit($input) {
	var id = $input.attr("id"),
		$row = $("#" + id).closest('.requirementTr'),
		$summaryInput = $row.find('.nested-summary-editor'),
		name = $summaryInput.val();

	if ($row.data("summaryRequired") && name === "") {
		return "error";
	}

	codebeamer.NavigationAwayProtection.removeInspectedElement($summaryInput);

	var $name = $row.find('h2.name');
	$name.attr('draggable', $name.data('draggableoriginal'));

	if (codebeamer.WYSIWYG.getEditorMode($input) == 'wysiwyg') {
		codebeamer.WikiConversion.saveEditor(id, true);
	}

	var data = {
		_method: 'post',
		name: name,
		version: getIssueVersion($input),
		description: $input.val()
	};

	$row.find('.nested-summary').remove();

	return data;
}

function onDescriptionSubmitted(data_) {
	var id = data_.requirement.id;
	refreshProperties(id, true);

	// also refresh the item name in the tree, because it may have been modified
	onNameSubmitted(data_);

	return data_.requirement.descriptionHtml;
}

function saveIssueProperties() {

	var submitPropertyEditor = function() {
		var pane = $("#issuePropertiesPane");

		var $form = $("#addUpdateTaskForm");
		var formDataString = "";

		// we need to save the editors before submitting the form data
		$form.find('.editor-wrapper textarea').each(function() {
			var $editor = $(this);

			if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
				codebeamer.WikiConversion.saveEditor($editor.attr('id'), true);
			}
		});

		if (trackerObject.config.extended) {
			var centerPanelFormData = codebeamer.trackers.extended.loadMergedForms();
			var id = pane.data("showingIssue");

			if (centerPanelFormData[id]) {
				var formData = centerPanelFormData[id];
				for (var key in formData) {
					if (key == 'task_id' || key == 'tracker_id') {
						continue;
					}
					formDataString += encodeURIComponent(key) + "=" + encodeURIComponent(formData[key]) + "&";

					// if the field was modified on the center form remove the it from the right form to prevent addig them twice
					var escapedSelector = key.replace('[', '\\[').replace(']', '\\]');
					$form.find("[name='" + escapedSelector + "']").remove();
				}
			}

			formDataString += $form.serialize();

		} else {
			formDataString = $form.serialize();
		}

		var $p = pane.find(".button");
		$p.attr("disabled", "disabled");
		$.post(contextPath + "/trackers/ajax/saveIssueProperties.spr", formDataString)
			.success(function (data) {
				if (data && data["messages"]) {
					var message = i18n.message("tracker.view.layout.document.update.error") + "<ul>";
					for (var i = 0; i < data["messages"].length; i++) {
						message += "<li>" + data["messages"][i] + "</li>";
					}
					message += "</ul>";
					showOverlayMessage(message, 5, true);
					$p.removeAttr("disabled");
				} else {
					// release the locked state of the panel
					pane.data("locked", false);

					reloadEditedIssue();
				}
			}).fail(function (response) {
				$p.removeAttr("disabled");
				showOverlayMessage(response.responseText, 5, true);
			});
	};

	if (trackerObject._isEdited()) {
		showFancyConfirmDialogWithCallbacks(i18n.message("tracker.view.layout.document.navigate.from.subtree.confirm"), function () {
			submitPropertyEditor();
		});
	} else {
		submitPropertyEditor();
	}
}

function reloadTestCase(issueId, edit) {
	var $stepsTable, $editingEnabledInput, $expandable, $saveButton, $testCaseRows;;

	$stepsTable = $("#et_" + issueId);

	$expandable = $stepsTable.parents(".expandable");

	$editingEnabledInput = $expandable.find("input[name=editingEnabled]");
	if (edit) {
		$editingEnabledInput.val(edit);

		$expandable.on('testSteps:updated', function() {
			$expandable.find('> .testStepTable > tbody > tr:first-child > td.actionCell').click();
			$expandable.off('testSteps:updated');
		});
	} else {
		if ($editingEnabledInput.val() === "true") {
			$editingEnabledInput.val(edit);
		}
	}

	loadTestSteps(issueId, $expandable, true);

	$testCaseRows = $stepsTable.find("td");
	if (edit && codebeamer.TestStepEditor && $testCaseRows.size() === 0) {
		// Not exposed API variable, contains the number of active AJAX requests
		if ($.active > 0) {
			$(document).one("ajaxStop", function() {
				codebeamer.TestStepEditor.get("et_" + issueId).addNewRow("et_" + issueId);
			});
		} else {
			codebeamer.TestStepEditor.get("et_" + issueId).addNewRow("et_" + issueId);
		}
	}
}

function saveSteps(issueId) {
	var $stepsTable = $("#et_" + issueId);
	var save = codebeamer.TestStepEditor.showChangingReferencedWarning($stepsTable);
	if (!save) {
		return;
	}
	codebeamer.TestStepEditor.closeOpenEditorInTable($stepsTable).then(function() {
		var $inputs = $stepsTable.find("input,textarea");
		var serialized = $inputs.serialize();

		var uploadConversationId = $("tr#" + issueId + " [name=uploadConversationId]").val();

		$.ajax({
			"url": contextPath + "/testcase/ajax/updateSteps.spr?task_id=" + issueId +"&uploadConversationId=" + uploadConversationId,
			"type": "POST",
			"data": serialized,
			"success": function(data) {
				var $stepsTable = $("#et_" + issueId);
				var $expandable = $stepsTable.parents(".expandable");
				$expandable.removeClass("edited");
				showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
				// update the counter
				var $allRows = $stepsTable.find("tr");
				var count = removeEmptyRows($allRows);
				TreeToTableDNDIntegration.handleEmptyTable($stepsTable);
				var empty = false;
				for (var i = 0; i < $allRows.length; i++) {
					if ($($allRows[i]).hasClass("empty")) {
						empty = true;
						break;
					}
				}
				var steps = count; // the rows of the table - 1
				if (empty) {
					steps = 0;
				}

				var $row = $("#" + issueId);

				$expandable.one("testSteps:updated", function() {
					var $testStepTable, $rows;

					$testStepTable = $("#et_" + issueId);
					$rows = $testStepTable.find("tbody tr").not(".emptyIndicatorRow");

					$row.find(".testStepCount").html("&nbsp;" + $rows.size() + "&nbsp;" + i18n.message("tracker.field.Test Steps.label"));
				});

				$row.find("[name=item-version]").val(data["version"]); // if the update was successful we can safely update the issue version

				loadTestSteps(issueId, $expandable, true);
				$stepsTable.removeClass("edited");

				// reload the properties panel
				trackerObject.showIssueProperties(issueId, "", $('#issuePropertiesPane'), true, true);

				var tree = $.jstree.reference("#treePane");
				var node = tree.get_node("#" + issueId);
				trackerObject.loadNode(node);
			},
			"error": function (res) {
				showOverlayMessage(res.responseText, 5, true);
			}
		});
	});
}

function removeEmptyRows($allRows) {
	var count = $allRows.size() - 1;
	$allRows.each(function (a,b) {
		var $inputs = $(b).find(".inlineInput");
		if ($inputs && $inputs.length > 0) {

			if ($($inputs[0]).val().length == 0 && $($inputs[1]).val().length == 0) {
				$(b).remove();
				count--;
			}
		}
	});
	return count;
}

function loadTestSteps(id, $target, force) {
	var callback = function () {
		$target.keypress(function (event) {
			$target.addClass("edited");
		});

		$target.bind("teststep.insert", function (event, $newRow) {
			var uploadConversationId = $target.find("[name=uploadConversationId]").val();
			$target.find("[name=actions_upload]").val(uploadConversationId);
			$target.find("[name=expectedResults_upload]").val(uploadConversationId);
		});

		// scroll back to the top of the edited item
		codebeamer.common._scrollToElement($("tr#" + id + " .teststepwrapper"));
	};
	var revision = UrlUtils.getParameter("revision");
	codebeamer.common.loadContentFromUrl(id, $target, "/trackers/ajax/getTestSteps.spr", callback, revision, force);
}

function showAddCommentPopup(url, event) {
	inlinePopup.show(url, {canSwitchOffModal: false, padding: 130 , cssClass: "overlayButtonsOnWhite" });
	if (event) {
		var jqEvent = jQuery.Event(event);
		jqEvent.stopPropagation();
	}
}

function initDoubleClickOnNameAnywhereStartsEditing() {
	// if you double click on anywhere in the header of the requirement then the name gets edited
	$("#rightPane").on("dblclick", "#requirements .name", null, function(event) {
		var target = event.target;
		// check if event target is the ".editable", and ignore that to avoid infinite loop
		if ($(target).closest(".editable").length > 0) {
			return;
		}

		$(this).find(".editable").first().dblclick();
	});
}
function reloadIncompleteNode(id) {
	var $tree = $.jstree.reference("#treePane");
	$tree.deselect_all();
	$tree.select_node($("li[id=" + id + "]"));
	trackerObject.reloadSubissues("rightPane", false, null, id, true);
}

$(function() {
	initNestedSummaryEditorEvents();

	$(document).on("mouseenter", ".teststepwrapper", function(event) {
		$(event.target).closest(".teststepwrapper").addClass("mouseOver");
	});

	$(document).on("mouseleave", ".teststepwrapper", function(event) {
		$(event.target).closest(".teststepwrapper").removeClass("mouseOver");
	});
});

function initializeTabs($container, $icons) {
	function initTree(t) {
		if (!t.jstree) {
			t.init(); // initialize the tree if it is not initialized yet
		}
	}

	$icons.addClass("icons-" + $icons.find("li").size());

	$icons.on("click", "li", function (event) {
		$(".quick-icons li").removeClass("active");
		var $selected = $(this);
		$selected.addClass("active");

		// open the tab
		$container.find(".tab").hide();

		var selectedTabId = $selected.data("tab");
		$("#" + selectedTabId).show();

		$container.trigger("codebeamer:afterOpen", [selectedTabId]);
	});

	$container.on("codebeamer:afterOpen", function (event, selectedTabId) {
		if (selectedTabId === "release-pane") {
			initTree(releaseTree);
		} else if (selectedTabId === "library-tab") {
			initTree(libraryTree);
		}
	});
};