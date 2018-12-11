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
var codebeamer = codebeamer || {};
codebeamer.trackers = codebeamer.trackers || {};
codebeamer.trackers.extended = (function ($) {

	var intervalPause = false;

	var contextMenuItems = {};

	var init = function (config) {

		registerHotkeys();

		listenMainFormCssChange();

		makeColumnsDraggable(config, "#requirements>thead");
		initializeNewEditors();
		initTableHeaderMenus(config);
		stickHeaderCellsHorizontally(config);
		clearLocalStorageWhenUserNavigates();

		initReportSavedEvent();

		if (config.resizeableColumns) {
			codebeamer.DisplaytagTrackerItemsResizeableColumns.init($("#requirements"), { isDocumentExtendedView: true });
			// Not the best solution, but DOM can change many times dinamically which breaks the resizer handlers
			setInterval(function() {
				if (!intervalPause) {
					$(window).trigger("resize.JColResizer");
				}
			}, 500);
			$(document).on('click', function(e) {
				intervalPause = $(e.target).is("select");
			});
		}

		// initialize the validation error link click handlers
		$(document).on('click', '.validation-error a', function () {
			var taskId = $(this).data('taskId');
			if ($.isNumeric(taskId)) {
				// the item already exists, use the normal method to scroll to id
				var $tree = getTree();
				$tree.select_node(taskId);
			} else {
				codebeamer.common._scrollToElement($("#" + taskId), $("#rightPane"))
			}

		});
	};

	/**
	 * this function overrides the addClass function to be able to trigger an event when a new class is added to an element.
	 * then we listen on this event and when the main form gets the dirty class immediately remove it.
	 * this is necessary because otherwise the areYouYure plugin won't trigger the change function (because it doesn't wotk very
	 * well with nested forms)
	 */
	var listenMainFormCssChange = function () {
		$.each(['addClass'],function(i,methodname){
		      var oldmethod = $.fn[methodname];
		      $.fn[methodname] = function(){
	            oldmethod.apply( this, arguments );

	            this.trigger('codebeamer:' + methodname);

	            return this;
		      }
		});

		$('#browseTrackerForm').on('codebeamer:addClass', function (event) {
			$(this).removeClass('dirty');
		});
	};

	var registerHotkeys = function () {
		var fieldSelector = '.field-editor input:not([type=hidden]):visible, .field-editor select:visible, .field-editor textarea:visible, .field-editor .fr-element';

		/**
		 * focuses the same field in $row that is focused in the current row. if that field is not editable then focuses the closes
		 * editable field.
		 *
		 * @param $row the row where to focus a field
		 * @param $currentField the currently focused field
		 */
		var focusFirstEditableField = function ($row, $currentField) {

			if ($row.is('.fr-element')) {
				// the target item is a froala editor
				var $fieldEditor = prev.closest('.field-editor.highlight-on-hover');
				var editor = $fieldEditor.data('froala.editor');
				if (editor) {
					editor.$oel.focus();
				}
			} else {
				// find the index of the field in the current row
				var $currentRow = $currentField.closest('.requirementTr');
				var index = $currentRow.find(fieldSelector).index($currentField);

				// focus the same field in the target row
				var $nextField = $row.find(fieldSelector).eq(index);

				if ($nextField.is(':disabled')) {
					focusNextEditableField($nextField);
				} else {
					$nextField.focus();
				}
			}
		};

		var focusNextEditableField = function ($input) {
			focusEditableFieldInDirection($input, 1);
		};

		var focusPreviousEditableField = function ($input) {
			focusEditableFieldInDirection($input, -1);
		};

		var focusEditableFieldInDirection = function ($input, dir) {
			var $target = $input.closest(fieldSelector);
			var $fields = $(fieldSelector).filter(function() { return $(this).css("display") != "none" });
			var index = ($fields.index($target) + dir);
			var $next = $fields.eq(index);

			// update the index until we find a field that is not disabled
			// we can assume that such field exists because the event itself was triggered on a non disabled field
			while ($next.is(':disabled')) {
				index += dir;
				$next = $fields.eq(index);
			}

			$next.focus();
		};

		var isIe = $("body").is(".IE");
		$(document).on('keydown', function (event) {
			if (event.altKey) {
				switch (event.which) {
				case 38: {
					// alt + up
					event.preventDefault();
					event.stopPropagation();
					var $row = $(event.target).closest('.requirementTr');
					var $prev = $row.prev();

					focusFirstEditableField($prev, $(event.target));
					break;
				}
				case 40: {
					// alt + down
					event.preventDefault();
					event.stopPropagation();

					var $row = $(event.target).closest('.requirementTr');
					var $next = $row.next();
					focusFirstEditableField($next, $(event.target));
					break;
				}
				case 39:  {
					if (isIe) {
						break;
					}
					event.preventDefault();
					event.stopPropagation();

					focusNextEditableField($(event.target));
					break;
				}
				case 37: {
					if (isIe) {
						break;
					}
					event.preventDefault();
					event.stopPropagation();

					focusPreviousEditableField($(event.target));
					break;
				}
				default: break;
				}
			}
		});

		var hotkeyList = [
 				 {key: 'alt+up', documentation: 'hotkey.docview.extended.previous.item.description'},
				 {key: 'alt+down', documentation: 'hotkey.docview.extended.next.item.description'}
		 ];

		if (!isIe) {
			hotkeyList.push({key: 'alt+left', documentation: 'hotkey.docview.extended.previous.field.description'});
			hotkeyList.push({key: 'alt+right', documentation: 'hotkey.docview.extended.next.field.description'});
		}

		codebeamer.HotkeyRegistry.registerHotkeys();

		// register the cmd+s hotkey on the froala editors
		codebeamer.WysiwygShortcuts.registerSaveEventShortcut();
	};

	var makeColumnsDraggable = function (config, selector) {

		var swapColumnsWithIndex = function(sourceIndex, targetIndex, hasAdditionalColumn, hasAdditionalTargetColumn) {
			var $rows = $('#requirements > tbody > tr:not(.embeddedTableHeader,.embeddedTableRow),#requirements > thead > tr:not(.embeddedTableHeader,.embeddedTableRow), #main-header-sticky > tr');
			$rows.each(function() {
				var tr = $(this);
					var selector = ">td:not(.embeddedTableCell,.embeddedTableHeader),>th";
					var element1 = tr.find(selector).eq(sourceIndex);
					if (hasAdditionalColumn) {
						var element1Additional = tr.find(selector).eq(sourceIndex + 1);
					}
					var element2 = tr.find(selector).eq(targetIndex + (hasAdditionalTargetColumn ? 1 : 0));

					if (hasAdditionalColumn) {
						element1Additional.detach().insertAfter(element2);
					}
					element1.detach().insertAfter(element2);
			});
			if (config.resizeableColumns) {
				codebeamer.DisplaytagTrackerItemsResizeableColumns.reInit($("#requirements"));
			}
		};

		var findTableIndex = function($th) {
			var tableIndex = 0;
			var $headerRow = $("#requirements").find("th[data-fieldlayoutid]").first().closest("tr");
			$headerRow.find("th").each(function(index, e) {
				if ($th.attr("data-fieldlayoutid") == $(this).attr("data-fieldlayoutid")) {
					tableIndex = index;
					return false;
				}
			});
			return tableIndex;
		};

		var swapColumns = function($source, $target) {
			if ($source.get(0) == $target.get(0)) {
				return;
			}
			var hasAdditionalSourceColumn = $source.attr("data-fieldlayoutname") == "Status";
			var hasAdditionalTargetColumn = $target.attr("data-fieldlayoutname") == "Status";
			swapColumnsWithIndex(findTableIndex($source), findTableIndex($target), hasAdditionalSourceColumn, hasAdditionalTargetColumn);
		};

		var setDragHelper = function(originalItem, helper) {
			helper.find(".tracker-context-menu").remove();
			helper.css("width", "");
			helper.addClass("duringDragHelper");
		};

		var resetDroppables = function() {
			$("#requirements>thead").find('th').each(function() {
				if ($(this).data("ui-droppable")) {
					$(this).droppable("destroy");
				}
			});
		};

		$(selector).first().find('th:not(.skipColumn,.extraInfoColumn,.control-bar)').draggable({
			appendTo : $("#rightPane"),
			cursor : 'move',
			helper : 'clone',
			delay: 300,
			stop : function(e, ui) {
				$(selector).first().find('th').removeClass("highlighted");
			},
			start : function(e, ui) {
				setDragHelper($(this), ui.helper);
				resetDroppables();
				$(selector).first().find('th').addClass("highlighted");
				$(selector).first().find('th:not(.skipColumn)').droppable({
					accept: function($element) {
						return $element.closest("table").hasClass("displaytag");
					},
					drop : function(event, ui) {
						var $element = $(this).find(".drop-marker");
						swapColumns($(ui.draggable), $(event.target));
						$element.remove();
						$(this).css("overflow", "");
						$(window).resize();
					},
					over: function (event, ui) {
						var $draggable = $(ui.draggable);
						var $hoveredElement = $(this);
						if ($draggable.prev().attr("data-fieldlayoutid") == $hoveredElement.attr("data-fieldlayoutid")) {
							return;
						}
						var $dropMarker = $("<div>", { "class": "drop-marker"});
						$dropMarker.css("left", $hoveredElement.width() + 10);
						$dropMarker.css("height", $("#requirements").height());
						$hoveredElement.append($dropMarker);
						$(this).css("overflow", "visible");
					},
					out: function () {
						var element = $(this).find(".drop-marker");
						element.remove();
						$(this).css("overflow", "");
					}
				});

			}
		});

	};

	/**
	 * initializes the editors (including the dirty check) that were recently loaded.
	 */
	var initializeNewEditors = function () {
		initializeDescriptionEditor();
		initializeFormFieldEditorDirtyCheck();

		var $rows = $('.requirementTr:not(.initialized)');
		markEmptyRequiredFields($rows.filter('.dirty'));
		$rows.addClass('initialized');

		// set the right pane height so that the horizontal scrollbar is visible
		autoAdjustPanesHeight($(window));

		// prevent the individual field forms triggering a submit when the user hits enter
		$rows.find(".field-editor-form").submit(function (event) {
			event.preventDefault();
			event.stopPropagation();
		})

	};

	var initializeFormFieldEditorDirtyCheck = function () {
		$('.requirementTr:not(.initialized) form.field-editor-form').areYouSure({
			'silent':true,
			'externalValueInitialization': true,
            'fieldEvents' : 'change paste propertychange input',
            'change': function () {
				var $form = $($(this).get(0));

				// set the whole requirement row as dirty
				var $row = $form.closest('.requirementTr');
				var taskId = $row.attr('id');
				if ($row.find('.dirty').size() > 0) {
					$row.addClass('dirty');

					// lock the tracker item
					lockIfUnlocked(taskId);
				} else {
					$row.removeClass('dirty');

					// no fields are updated, unlock the item
					unlockTrackerItem(taskId);
				}

				if($row.is('.dirty')) {
					markEmptyRequiredFields($row);
				} else {
					clearAllEmpty($row);
				}
			}
		});

		$('.field-editor-form input').change(function () {
			var $row = $(this).closest('.requirementTr');
			if($row.is('.dirty')) {
				markEmptyRequiredFields($row);
			} else {
				clearAllEmpty($row);
			}
		});

		$('.requirementTr').on('codebeamer.tableFieldUpdated', function () {
			var $row = $(this);
			$row.addClass('dirty');
			$row.find('.field-editor-form').addClass('dirty');
			markEmptyRequiredFields($row);
		});
	};

	/**
	 * finds the empty required fields in $row and marks them with the empty class
	 */
	var markEmptyRequiredFields = function ($row) {
		// if the form has a mandatory field and it is empty then add the empty class to the field
		var $mandatory = $row.find('.fieldInputControl.mandatory');
		if($mandatory.size()) {
			$mandatory.each(function () {
				var $field = $(this);
				var $input = $field.find('input');
				var isEmpty = !$input.val();
				$field.toggleClass('empty', isEmpty);
			});

		}
	};

	var initializeDescriptionEditor = function () {
		codebeamer.WYSIWYG.overrideFroalaFunctions();

		codebeamer.EditorToolbars.initToolbarsAndButtons();

		var buttons = codebeamer.EditorToolbars.getMainToolbarButtons();

		// remove some buttons that are not needed on the shared editor toolbar
		var removedButtons = ["cbWysiwygOptions", "fullscreen", "cbWysiwyg", "cbPreview", "cbSaveEvent", "cbMarkup", "cbMakeDefault", "cbEditorFormat", "cbOverlayEditor"];
		for (var i = 0; i < removedButtons.length; i++) {
			buttons.remove(removedButtons[i]);
		}

		//buttons.push('cbSave');

		var EDITOR_OPTIONS = {
	      'toolbarInline': false,
	      'toolbarContainer': '#toolbarContainer', // this element will contain the shared editor toolbar
	      'toolbarBottom': false,
	      'toolbarSticky': false,
	      'charCounterCount': false,
	      'toolbarButtons': buttons,
	      'fileUploadURL': contextPath + '/dndupload/uploadfile.spr',
	      'imageUploadURL': contextPath + '/dndupload/uploadfile.spr'
		};

		EDITOR_OPTIONS = $.extend(codebeamer.WYSIWYG.getDefaultEditorOptions(buttons), EDITOR_OPTIONS);

		var froalaSelector = "#requirements .requirementTr:not(.initialized) .description-field .field-editor.highlight-on-hover";
		var $froalaEditors = $(froalaSelector);

		$froalaEditors.each(function() {
			var $editor = $(this),
				html = codebeamer.WikiConversion.replaceTextDecorationSpans($editor.html());

			$editor.html(codebeamer.WikiConversion.replaceEmptyParagraphsWithBrs(html));
		});

		$froalaEditors
			.on('froalaEditor.initialized', function(event, editor) {
				var $toolbars = $("#toolbarContainer .fr-toolbar");
				// remove the extra toolbars
				if ($toolbars.size() > 1) {
					$toolbars.first().remove();
				}
				var $editorWrapper = $(event.currentTarget);

//				$editorWrapper.froalaEditor('html.set', $editorWrapper.prev('textarea').html());

				var $dragAndDropOverlay = $('<div class="drag-and-drop-overlay"></div>');
				$editorWrapper.append($dragAndDropOverlay);

				codebeamer.WYSIWYG.initDragAndDrop($editorWrapper, editor, $dragAndDropOverlay);

				codebeamer.WYSIWYG.preventUploadDialog(editor, $editorWrapper);

				codebeamer.EditorToolbars.initHidingEditorPopups(editor);

				codebeamer.WYSIWYG.bindFileInsertHandlers($froalaEditors);

				editor.events.on('contentChanged', function() {
					var $row = editor.$el.closest('.requirementTr');

					if (!$row.is('.dirty')) {
						// if the row is not already dirty (the whole row) then add the class
						$row.addClass('dirty');

						// lock the tracker item
						lockIfUnlocked($row.attr('id'));
					}

					if ($row.is('.dirty')) {
						markEmptyRequiredFields($row);
					} else {
						clearAllEmpty($row);
					}

					// this is only to trigger the areYouSure plugin
					var $helperTextarea = $('#description-editor-' + $row.attr('id'));
					$helperTextarea.closest('.field-editor-form').addClass('dirty');

					// TODO: do the unlocking then the original text is restored
					// mark the changed editor content as dirty
					editor.$el.addClass('dirty');
					codebeamer.WysiwygShortcuts.setActualEditor(editor);
					return false; // avoid the execution of default Froala contentChanged handler
				}, true);
				
				editor.$oel.on('wysiwyg:save', save);
			})
			.froalaEditor(EDITOR_OPTIONS)
			.on('froalaEditor.file.beforeUpload froalaEditor.image.beforeUpload', function (e, editor, files) {
				var conversationId = editor.$el.closest('.editor-wrapper').data('conversationId');

				// set the image params and upload params: add the conversation id
				$.extend(editor.opts.imageUploadParams, { conversationId: conversationId });
				$.extend(editor.opts.fileUploadParams, { conversationId: conversationId });
			}).data('insertNonImageAttachments', true);

		// making sure the active popups have the active editor instance
		$('.document-view-container').on('click', '.editor-wrapper', function() {
			var $activePopup = $('#toolbarContainer .fr-popup.fr-active');

			if ($activePopup.length) {
				$activePopup.data('instance', codebeamer.WYSIWYG.getEditorInstance($(this).attr('id')));
			}
		});
	};

	/**
	 * collects the changed form values and merges to them the updated form values stored in the local storage.
	 */
	var loadMergedForms = function () {
		var forms = collectUpdatedFormValues();

		// load the form values stored in local storage and combine the two
		var storedForms = loadFormData();
		$.extend(true, storedForms, forms);

		return storedForms;
	};

	/**
	 * saves all the changes on all the items in one go.
	 * the function collects the field editor values in each row (that have changed) and creates an addupdatetaskform object
	 * from them. the sends the forms to the server as an array.
	 *
	 * TODO: error handling. or we should add a mass edit?
	 */
	var save = function () {
		// clear the error messages from the previous save
		removeErrorMessages();

		// submit each updated form
		var forms = loadMergedForms();

		// the id of the issue edited on the right panel
		var itemEditedOnPanel = $("#issuePropertiesPane").data("showingIssue");

		var failedForms = {};
		var validationErrors = {};
		var hasFailure = false;

		if ($.isEmptyObject(forms)) {
			// tell the user that there are no changes to save
			showFancyAlertDialog(i18n.message("tracker.view.layout.document.extended.no.changes"), "information");
			return;
		}

		var busyPage = ajaxBusyIndicator.showBusyPage()
		var newItemForms = {};
		var updatedItemForms = {};
		var itemsToReload = [];

		for (var taskId in forms) {
			if (taskId == itemEditedOnPanel) {
				// if the item is also edited on the right panel then call the normal save function
				saveIssueProperties();
				continue;
			}
			var $row = $('.requirementTr#' + taskId);
			var simpleFormValues = forms[taskId];

			var newNodeParams = $row.data("newNodeParams");

			var url = contextPath + '/trackers/ajax/saveIssueProperties.spr';

			var newItem = !!newNodeParams;
			if (newItem) {
				// this is a new item, we must store it
				url = contextPath + "/ajax/proj/tracker/createtrackeritemEditableView.spr"

				simpleFormValues = $.extend(simpleFormValues, newNodeParams);

				if (newNodeParams.position == "after" || newNodeParams.position == "before") {
					var tree = $.jstree.reference("#treePane");
					var $referenceNode = tree.get_node("#" + newNodeParams["parent.id"]);
					var parentId = tree.get_parent($referenceNode);
					if (parentId) {
						var parent = tree.get_node(parentId);
						parentId = parent.li_attr["type"] != "tracker" ? parentId : "-1";
					}
					parentId = parentId || "-1";

					newNodeParams["parent.id"] = parentId;
				}

				if (trackerObject.config.branchId) {
					newNodeParams["branchItem"] = true;
				}

				simpleFormValues['task_id'] = -1;
				newItemForms[taskId] = simpleFormValues;
				continue;
			}

            updatedItemForms[taskId] = simpleFormValues;

			// TODO: reduce the number of requests sent
			/*var promise = $.post(url, simpleFormValues)
			.done(function (data) {
				if (data['task_id']) {
					taskId = data['task_id'];
				}

				var $row = $('.requirementTr#' + taskId);
				if (data['messages']) {
					// there are the validation errors

					// store the failed form values
					failedForms[taskId] = simpleFormValues;
					validationErrors[taskId] = data['messages'];

					hasFailure = true;
				} else {
					showOverlayMessage();

					clearAllDirty($row);
					trackerObject.reloadIssue(taskId);
					unlockTrackerItem(taskId);
				}
			}).fail(function (data) {
				showOverlayMessage(data.responseText, 5, true);
				hasFailure = true;
				failedForms[taskId] = simpleFormValues;
			});*/

		}

		// update all the items in a single request
		if (updatedItemForms) {
			$.post(contextPath + '/ajax/saveMultipleIssueProperties.spr',{
				'forms': JSON.stringify(updatedItemForms),
				'tracker_id': trackerObject.config.id
            })
			.done(function (data) {
				// go through all task ids and check if there are any errors
				for (var taskId in data) {
                    var $row = $('.requirementTr#' + taskId);
                    var taskData = data[taskId];
                    if (taskData['messages']) {
                        // there are the validation errors

                        // store the failed form values
                        failedForms[taskId] = simpleFormValues;
                        validationErrors[taskId] = taskData['messages'];

                        hasFailure = true;
                    } else {
                        itemsToReload.push(taskId);
                        showOverlayMessage();

                        clearAllDirty($row);
                        // TODO: remove this reload and reload the issues in stopAjax
                        //trackerObject.reloadIssue(taskId);
                        //unlockTrackerItem(taskId);
                    }
				}
			}).fail(function (data) {
                showOverlayMessage(data.responseText, 5, true);
                hasFailure = true;
            });
		}

		// create the new items
		if (newItemForms) {
			$.post(contextPath + '/ajax/proj/tracker/createMultipleTrackeritemsEditableView.spr', {
				'formParameters': JSON.stringify(newItemForms),
				'branchItem': !!trackerObject.config.branchId,
				'tracker_id': trackerObject.config.id
			}).done(function (data) {
				for (var key in data) {
					var itemData = data[key];
					var $row = $('.requirementTr#' + key);
					var newNodeParams = $row.data("newNodeParams");
					if (itemData['messages']) {
						failedForms[key] = simpleFormValues;
						validationErrors[key] = itemData['messages'];
						hasFailure = true;
					} else {
						codebeamer.common.handleAddNewItem(itemData, $row);
						trackerObject.loadNewParagraphIds($row.attr('id'));

						// clear the new node params to prevent the item from being created twice
						$row.data("newNodeParams", null);

						trackerObject.refreshNode(newNodeParams['parent.id'] == '-1' ? null : newNodeParams['parent.id']);

						// reload the item to make sure that all mandatory field markings are cleared
						trackerObject.reloadIssue(itemData.requirement.id);

						clearAllDirty($row);

                        itemsToReload.push(taskId);
                    }
				}
			}).fail(function (data) {

			});
		}

		$(document).ajaxStop(function() { // this function executes after all ajax requests (updates and new item creations) finished
			if (busyPage) {
				busyPage.remove();
			}
			clearFormData();

			// for each item where the name was  updated we need to refresh the item in the tree
			for (var taskId in forms) {
				if (failedForms[taskId]) {
					// if the task was not saved due to errors then do not refresh the item in the tree yet
					continue;
				}

				var formValues = forms[taskId];
				if (!formValues || !formValues['summary']) {
					// the summary was not updated
					continue;
				}

				var escaped = $('<div>').text(formValues['summary']).html();
				var nodeData = {'requirement': {'id': taskId, 'name': escaped}};
				delete forms[taskId];
				onNameSubmitted(nodeData);
			}

			// reload and unlock the successfully saved items in one request
			if (itemsToReload.length > 0) {
				var tail = itemsToReload.slice(1);
				var head = itemsToReload[0];

                itemsToReload = [];
                trackerObject.reloadIssue(head, tail);

                unlockTrackerItems([head].concat(tail));
            }
			// if there were forms with errors
			if (hasFailure) {
				// we need to store the data of the failed forms to the local storage
				storeFormData(failedForms);

				// we need to show invalid items in an error box
				var errorHtml = buildValidationErrorMessage(validationErrors);

				// we need to add the validation errors for each item to the respective row
				for (var taskId in validationErrors) {
					var $container = $('.requirementTr#' + taskId + ' .error-container');
					$container.addClass('error');

					var errorList = '<ul>';
					for (var i = 0; i < validationErrors[taskId].length; i++) {
						var message = validationErrors[taskId][i];
						errorList += '<li>';
						errorList += message;
						errorList += '</li>';
					}

					errorList += '</ul>';

					$container.html(errorList);
				}

				showOverlayMessage(errorHtml, 5, true);

				failedForms = {};
				hasFailure = false;
				validationErrors = {};
				forms = [];
			}
		});
	};

	var buildValidationErrorMessage = function (validationErrors) {
		var message = i18n.message('tracker.view.layout.document.extended.save.error');
		var errorHtml = "<div>" + message + ":</div>";
		var $tree = getTree();

		errorHtml += "<ul>";

		for (var taskId in validationErrors) {
			var node = $tree.get_node(taskId);
			var name = node ? node.text : i18n.message('tracker.view.layout.document.extended.new.item.label');

			errorHtml += "<li class=\"validation-error\"><a href=\"#\" data-task-id=\"" + taskId + "\">" + name + "</a></li>";
		}

		errorHtml += "</ul>";

		return errorHtml;
	};

	var getTree = function () {
		return $.jstree.reference(trackerObject.config.treePaneId);
	};

	var clearFormData = function () {
		var key = getLocalStorageKey();

		localStorage.removeItem(key);
	};

	/**
	 * stores the updated form values to the local storage as a json string. used by infinite scrolling when a page is removed from the dom.
	 */
	var storeFormData = function (forms) {
		forms = forms || collectUpdatedFormValues();
		if (forms.length == 0) {
			return;
		}

		var key = getLocalStorageKey();

		var presiousForms = loadFormData();

		// load the previously stored values
		if (presiousForms) {
			forms = $.extend(true, presiousForms, forms);
		}

		//TODO: handle the case when the local storage is full
		var json = JSON.stringify(forms);
		localStorage.setItem(key, json);
	};

	/**
	 * loads the form data previously stored in local storage.
	 */
	var loadFormData = function () {
		var key = getLocalStorageKey();

		var prevForms = localStorage.getItem(key);
		if (prevForms) {
			var formsParsed = JSON.parse(prevForms);
			return formsParsed;
		}

		return {};
	};

	var getLocalStorageKey = function () {
		return 'codebeamer.item-editor-state' + trackerObject.config.id;
	};

	/**
	 * returns the updated form values as an array. in the array there is a row for each updated item
	 */
	var collectUpdatedFormValues = function () {
		var forms = {};
		$('.requirementTr').each(function () {
			var $row = $(this);
			var $updatedForms = $row.find(".field-editor-form.dirty");

			var $updatedDescription = $row.find(".description-field .fr-view.dirty");

			if ($updatedForms.size() == 0 && $updatedDescription.size() == 0) {
				// don't do anything if there are no updated fields on the item
				return;
			}

			// if there are any updated fields in the row we need to add the mandatory fields to the payload
			// reason: mandatory fields may have defaults. without sending the default values to the server the validation
			// would reject these fields (incorrectly)
			var $mandatory = $row.find(".field-editor-form.mandatory");

			// for each form in the row get the name and the current value of the field
			var formValues = {};
			var simpleFormValues = {};
			var fieldValue = {};
			var fieldReferenceData = [];


			var updatedAndMandatory = $updatedForms.toArray().concat($mandatory.toArray());
			$.each(updatedAndMandatory, function () {
				var $form = $(this);
				var $input = $form.find('input,select,textarea');
				var $parent = $input.parent();

				var fieldName = $input.attr('name');
				var value = $input.val();

				simpleFormValues[fieldName] = value;

				if ($parent.is('.editWikiInOverlayBody')) {
					simpleFormValues['uploadConversationId'] = $parent.parent().attr('uploadconversationid');
				}
			});

			var taskId = $row.attr('id');
			simpleFormValues['task_id'] = taskId;
			simpleFormValues['version'] = $row.data('version');
			simpleFormValues['tracker_id'] = $row.data('trackerId');

			if ($updatedDescription.size() == 1) {
				// set the description html, this will be converted to wiki on the server side
				var descriptionHtml = codebeamer.WikiConversion.getCleanHtml($updatedDescription.html());

				descriptionHtml = codebeamer.WikiConversion.replaceUnderlineAndStrikeThroughTags(descriptionHtml);

				simpleFormValues['descriptionHtml'] = descriptionHtml;

				// send the conversation id so that the uploaded files do not get lost
				var conversationId = $updatedDescription.closest('.editor-wrapper').data('conversationId');
				if (simpleFormValues['uploadConversationId'] && simpleFormValues['uploadConversationId'] != conversationId) {
					console.warn('More than one conversation id is used for a tracker item!');
				}
				simpleFormValues['uploadConversationId'] = conversationId;
			}

			forms[taskId] = simpleFormValues;
		});

		return forms;
	};

	/**
	 * updated the form fields in $data based on the values stored in the local storage.
	 */
	var updateFormFields = function ($data) {
		var formData = loadFormData();

		// if there are no stored field values then return
		if (formData.length == 0) {
			return;
		}

		// otherwise for each form update the respective row in $data
		for (var taskId in formData) {
			var values = formData[taskId];

			var $row = $data.find('.requirementTr#' + taskId);

			for (var key in values) {
				var escapedSelector = key.replace('[', '\\[').replace(']', '\\]');
				var $input = $row.find('[name=' + escapedSelector + ']');
				$input.val(values[key]);
			}
		}
	};

	/**
	 * parses a field name and converts it to a javascript object along with the value
	 */
	var parseField = function (fieldName, value) {
		var regex = /(fieldReferenceData|fieldValues)\[(\S+)\](\.(\S+))?/g;

		var match = regex.exec(fieldName);

		if (!match) {
			// this is a simple field name, like storyPoints -> {storyPoints: value}
			var result = {};
			result[fieldName] = value;
		}

		if (match.length < 5 || !match[3]) {
			// this is a map field without subproperty like: fieldValue[1221] -> {fieldValue: {1221: value}}
			var result = {};

			result[match[1]] = {};

			result[match[1]][match[2]] = value;

			return result
		}

		// this is a complex field definition. like:
		// "fieldReferenceData[aaa].customFieldValue" -> {fieldReferenceData: {aaa: {customFieldValue: value}}}
		var result = {};
		result[match[1]] = {};
		result[match[1]][match[2]] = {};
		result[match[1]][match[2]][match[4]] = value;

		return result;
	};

	/**
	 * if the tracker item with id is not locked by an other user then this function locks it. otherwise the function
	 * just displays the information about the other user locking the item.
	 */
	var lockIfUnlocked = function (id) {
		// check if the item could be locked
		var promise = isItemLocked(id);
		if (!promise) {
			return;
		}

		promise.done(function (response) {
			if (response.result == true) {
				var message = i18n.message('tracker.view.layout.document.item.locked.message');
				showOverlayMessage(message, 5, true);
			} else {
				// lock the selected item and store the info to the panel data
				lockTrackerItem(id);
			}
		});
	};

	/**
	 * removes all dirty classes inside the context
	 */
	var clearAllDirty = function ($context) {
		$context.removeClass('dirty');
		$context.find('.dirty').removeClass('dirty');

		// reinitialize the dirty watch with the new values
		$context.find('form.field-editor-form').trigger('reinitialize.areYouSure');

		$("#browseTrackerForm").removeClass('dirty');
	};

	/**
	 * removed the empty class from each form in the context
	 */
	var clearAllEmpty = function ($context) {
		$context.find('.empty').removeClass('empty');
	};

	/**
	 * when the window is unloaded the local storage data is completely cleared.
	 */
	var clearLocalStorageWhenUserNavigates = function () {
		$(window).on('unload', function() {
			var forms = loadMergedForms();
			for (var taskId in forms) {
				if ($.isNumeric(taskId)) {
					unlockTrackerItem(taskId, false);
				}
			}
			clearFormData();
	    });
	};

	var showNormalView = function (trackerUrl) {
		location.href = contextPath + trackerUrl;
	};

	var removeErrorMessages = function () {
		$('.requirementTr .error-container').empty().removeClass('error');
		$(".overlayMessageBoxContainer").remove();
	};


	var addSubmenuItems = function (group, mainItem) {
		var subitems = {};
		for (var j = 0; j < group.children.length; j++) {
			var subitem = group.children[j];

			var descriptor = {
				'name': subitem['text'],
				'disabled': function (key, options) {
					// disable this field if it is already added to the table
					return $('#main-header th[data-field-id=' + key + ']').size() > 0;
				}
			};

			if (subitem.children && subitem.children.length) {
				addSubmenuItems(subitem, descriptor);
			} else {
				descriptor['callback'] = function (key, options) {
					var $th = options.$trigger.closest('th');
					addColumnAfter($th, key);
				};
			}

			subitems[subitem['attr']['data-fieldlayoutid']] = descriptor;
		}

		mainItem['items'] = subitems;
	};

	var initContextMenu = function(selector) {
		var menu = new ContextMenuManager({
			"selector": selector,
			"trigger": "left",
			"items": contextMenuItems,
			events : {
				show: function(opt) {
					opt.$trigger.closest(".tracker-context-menu").addClass("activeMenu");
				},
				hide: function() {
					$("#main-header .tracker-context-menu, #main-header-sticky .tracker-context-menu").removeClass("activeMenu");
				}
			}
		});
		menu.render();
	};

	/**
	 * initializes the table header context menus and delete column icons
	 */
	var initTableHeaderMenus = function (config) {
		// download the available fields
		$.ajax(contextPath + '/ajax/queries/getFields.spr', { type: "GET", async: false, data : {
			'tracker_ids': trackerObject.config.id,
			'project_ids': trackerObject.config.projectId,
			'hideBuiltInFields': true
		}}).done(function (data) {
			// add the menu
			var selector = "#main-header .tracker-context-menu .menuArrowDown";
			var items = {};
			for (var i = 0; i < data.length; i++) {
				var group = data[i];

				items[group['id']] = {
					'name': group['text'],
					'callback': function (key, options) {

					}
				};

				addSubmenuItems(group, items[group['id']]);

			}

			items["separator1"] = "---";

			items['removeColumn'] = {
				'name': i18n.message('queries.contextmenu.removecolumn'),
				'callback': function (key, options) {
					var $th = options.$trigger.closest('th');
					removeColumn(config, $th);
				},
				'icon': 'removeColumn',
				'disabled': function (key, options) {
					// disable removing the description column
					var $th = options.$trigger.closest('th');
					var fieldId = $th.data('fieldId');
					return fieldId == 80 || $th.is('.required');
				}
			};

			contextMenuItems = items;

			initContextMenu(selector);

		});
		$("#main-header").on("click", "th .removeColumn", function() {
			removeColumn(config, $(this).closest("th"));
		});
	};

	var addColumnAfter = function ($th, key) {
		var fieldId = $th.data('fieldId');

		var $target = $('#requirements th[data-field-id=' + fieldId + ']');
		var $inserted = $('<th>');
		$inserted.attr('data-fieldlayoutid', key);
		$inserted.attr('data-field-id', key);
		$inserted.attr('data-customfieldtrackerid', trackerObject.config.id);

		$target.after($inserted);

		codebeamer.columnsDirty = true;

		$('.reportSelectorTable .searchButton').click();

		$("#reportSelectorResult").empty();
	};

	var removeColumn = function (config, $th) {
		var fieldId = $th.data('fieldId');

		// remove the columns with this field ids
		$('div[data-field-id=' + fieldId + ']').closest("td").remove();
		$('th[data-field-id=' + fieldId + ']').remove();

		setHeaderWidths(config);

		codebeamer.columnsDirty = true;

		if (config.resizeableColumns) {
			codebeamer.DisplaytagTrackerItemsResizeableColumns.reInit($("#requirements"));
		}

	};

	/**
	 */
	var initReportSavedEvent = function () {
		// when the report was saved select the new report as default
		$('body').on('codebeamer.reportSaved', function (event, reportId) {
			codebeamer.columnsDirty = false;
			// save the newly created view id
			var reportSelectorId = $(".reportSelectorTag").attr("id");

			if (reportSelectorId) {
				var data = codebeamer.ReportSupport.getReportSelectorStorageData(reportSelectorId) || {};
				data['queryId'] = reportId;
				codebeamer.ReportSupport.setReportSelectorStorage(reportSelectorId, data);
			}

		});
	};

	/**
	 * returns the currently selected field ids (this may contain field ids that are not yet stored on the server)
	 */
	var getCurrentFieldList = function (skipColumsDirtyCheck) {
		if (!skipColumsDirtyCheck && !codebeamer.columnsDirty) {
			return [];
		}
		var fieldIds = $('#requirements th').map(function () {
			return $(this).data('fieldId');
		});

		return fieldIds.toArray().join(',');
	};

	var getHeaderWidths = function() {
		var $header = $("#main-header");
		var widths = [];
		$header.find("th").each(function() {
			widths.push($(this).outerWidth());
		});
		return widths;
	};

	var setHeaderWidths = function(config) {
		if ($("#main-header-sticky").length > 0) {
			var $stickyContainer = $(".stickyContainer");
			$stickyContainer.find(".stickyTable").css("width", $("#main-header").closest("table").outerWidth());
			var index = 0;
			var widths = getHeaderWidths();
			$("#main-header-sticky").find("th").each(function() {
				$(this).css("width", config.resizeableColumns && $(this).is(".control-bar") ? widths[index] - 13 : widths[index] - 10);
				index++;
			});
			$stickyContainer.css("left", $("#rightPane").offset().left - $("#rightPane").scrollLeft());
		}
	};

	var stickHeaderCellsHorizontally = function (config) {

		var scrollHandler = function() {
			var scrollTop = $("#rightPane").scrollTop();
			if (scrollTop > $("#main-header").outerHeight()) {
				if ($("#main-header-sticky").length == 0) {
					var $stickyDiv = $("<div>", {"class" : "stickyContainer"} );
					var $stickyTable = $("<table>", { "class" : "displaytag stickyTable" + (config.resizeableColumns ? " resizeableColumns" : ""), "style" : "table-layout: fixed"});
					var $cloned = $("#main-header").clone();
					$cloned.attr("id", "main-header-sticky");
					$stickyTable.append($cloned);
					$stickyDiv.append($stickyTable);
					$("#rightPane").prepend($stickyDiv);
					initContextMenu("#main-header-sticky .tracker-context-menu .menuArrowDown");
					$("#main-header-sticky").on("click", "th .removeColumn", function() {
						removeColumn(config, $(this).closest("th"));
					});
					makeColumnsDraggable(config, "#main-header-sticky");
				}
				setHeaderWidths(config);
			} else {
				$(".stickyContainer").remove();
			}
		};

		$('#rightPane').scroll(scrollHandler);
		$(window).resize(scrollHandler);
		$("#panes").on("eastClose eastOpen westClose westOpen westResize eastResize checkform.areYouSure", scrollHandler);

		// when typing into an autocomplete reference field the field size increases automatically.
		// this handler will adjust the cell sizes in this cases
		$("#rightPane").on("keyup keydown blur update", "li.token-input-input-token-facebook input, .fr-element", scrollHandler)
		// when the reference fields are initialzed we need to realign as well
			.on('codebeamer:referenceFieldInitialized', scrollHandler);

	};

	return {
		'init': init,
		'save': save,
		'storeFormData': storeFormData,
		'loadFormData': loadFormData,
		'updateFormFields': updateFormFields,
		'loadMergedForms': loadMergedForms,
		'initializeNewEditors': initializeNewEditors,
		'showNormalView': showNormalView,
		'initTableHeaderMenus': initTableHeaderMenus,
		'getCurrentFieldList': getCurrentFieldList
	};
})(jQuery);