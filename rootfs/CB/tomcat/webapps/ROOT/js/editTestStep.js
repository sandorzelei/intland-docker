codebeamer = codebeamer || {};
codebeamer.TestStepEditor = function() {
};

$.extend(codebeamer.TestStepEditor, {

	editorOptions: {
		heightMin: 150,
		toolbarSticky: false
	},
	additionalEditorOptions: {
		disableFormattingOptionsOpening: true,
		useAutoResize: true,
		ignorePreviouslyUploadedFiles: true,
		focus: true,
		allowTestParameters: true
	},

	// map contains the instances indexed by their table's ids
	instances: {},

	// get the TestStepEditor instance by using its id or element inside
	// @param id or element inside the table/editor
	get:function(idOrElement) {
		var instances = codebeamer.TestStepEditor.instances;
		var instance = instances[idOrElement];
		if (instance != null) {
			return instance;
		}
		var $table = $(idOrElement).closest("table");
		var id = $table.attr("id");
		instance = instances[id];
		return instance;
	},

	initGlobalEventHandlers:function() {
		// avoid double init
		if (codebeamer.TestStepEditor.globalEventsInitialized) {
			console.log("initGlobalEventHandlers is already called, skipping");
			return;
		};
		codebeamer.TestStepEditor.globalEventsInitialized = true;
		console.log("initGlobalEventHandlers()");

		// checkbox handler
		$(document).on("mousedown", ".criticalCheckbox", function(event) {
			var $target = $(event.target);
			var checked = $target.is(":checked");
			var $hidden = $($target.siblings("[name=critical]")[0]);
			$hidden.val(!checked);
		});

		// disable checkbox if it is readonly, see: http://stackoverflow.com/questions/155291/can-html-checkboxes-be-set-to-readonly
		$(document).on("click", ".criticalCheckbox", function(event) {
			var $target = $(event.target);
			return !($target.is("[readonly]"));
		});

		var showChangingReferencedWarning = function(element) {
			var $tr = $(element).closest("tr");
			// check if already shows warning ?
			if ($tr.hasClass("changingReusedStep")) {
				return;
			}

			// show a warning that changing a Referenced Test Step!
			var $container = $tr.find(".reusingMe");
			$tr.addClass("changingReusedStep");

			var warning = i18n.message("testcase.editor.step.changing.a.referenced.warning");
			$container.append("<span class='warning' style='display:none;'>" + warning +"</span>");
			$container.find(".warning").fadeIn(500);
		}

		// handle tab keypress: when hitting tab on the last will add a new test-step row
		$(document).on("keydown", ".testStepTable .inlineInput", function(event) {
			var $target = $(event.target);
			if (event.keyCode == '9' && !event.shiftKey) { // will fire for TAB but not for SHIFT+TAB
				var $table = $target.closest(".testStepTable");
				var $last = $table.find(".inlineInput").last();
				// is this the last ?
				if ($last.get(0) == $target.get(0)) {
					// create a new row on tab press
					var editor = codebeamer.TestStepEditor.get($target);
					editor.addNewRow(editor.tableId);
					event.preventDefault();
				}
			}
			// check if user presses alphanumeric? show an explanation, why this is read-only
			var changing = (
						event.keyCode != $.ui.keyCode.TAB &&
						event.keyCode != $.ui.keyCode.UP &&
						event.keyCode != $.ui.keyCode.DOWN &&
						event.keyCode != $.ui.keyCode.LEFT &&
						event.keyCode != $.ui.keyCode.RIGHT
					);
			var $tr = $target.closest("tr");
			if (($target.is("[readonly]") || $target.is("[contenteditable=false]")) && $tr.hasClass("referrencingStep")) {
				if (changing) {
					var msg = i18n.message("testcase.editor.step.referencing.step.read.only");
					var $td = $tr.find("td:eq(3)");
					if ($td.find(".readOnlyWarning").length == 0) { // only add the warning once!
						$td.append("<div class='readOnlyWarning warning' style='clear:both;display:none;'>" + msg +"</div>");
						$td.find(".readOnlyWarning").fadeIn(500);
					}
				}
			}

			if ($tr.hasClass("referencedStep")) {
				if (changing) {
					showChangingReferencedWarning($target);
				}
			}
		});

		// show warning on any change of the referenced-step
		$(document).on("change", ".testStepTable .inlineInput, .testStepTable .criticalCheckbox", function(event) {
			var $target = $(event.target);
			if ($target.closest("tr").hasClass("referencedStep")) {
				showChangingReferencedWarning($target);
			}
		});

		$(document).on("click", ".breakReferenceButton", function() {
			var $button = $(this);
			var $tr = $button.closest("tr");
			var $referredTestSteps = $tr.find("[name='referredTestSteps']");
			var reference = $referredTestSteps.val();
			var $editFields = $tr.find("input,textarea");
			if (reference != "") {
				// break the reference !
				$referredTestSteps.val("");
				$button.attr("previousReference", reference);
				$button.val(i18n.message("testcase.editor.reset.reference.button"))
					   .prop("title", i18n.message("testcase.editor.reset.reference.button.title"));
				$editFields.prop("readonly", ""); //make controls editable
				$tr.find('.readOnlyWarning').remove();

				$tr.find('td.actionCell textarea, td.expectedResultCell textarea').each(function() {
					var $textarea = $(this),
						referencedItem = $textarea.attr('data-entity-id'),
						markup = $textarea.html();

					if (markup.length) {
						$textarea.html(codebeamer.TestStepEditor.attachmentRelinkingInWikiMarkup(markup, referencedItem));
					}
					$textarea.attr('data-entity-id', $('#testStepsOwnerId').val());
				});
			} else {
				// reset broken reference !
				reference = $button.attr("previousReference");
				$referredTestSteps.val(reference);
				$button.val(i18n.message("testcase.editor.break.reference.button"))
				   .prop("title", i18n.message("testcase.editor.break.reference.button.title"));
				$editFields.prop("readonly", true); //make controls read-only

				codebeamer.WYSIWYG.destroyEditor($tr.find('.editor-wrapper textarea'), false);
			}

			// avoid propagation
			return false;
		});
	},

	isReferencedStep:function(target) {
		var referenced =  $(target).closest("tr").hasClass("referencedStep");
		return referenced;
	},

	/**
	 * @param table The test-steps' table
	 */
	showChangingReferencedWarning:function(table) {
		var changed = $(table).find(".changingReusedStep").length >0;
		if (changed) {
			var msg = i18n.message("testcase.editor.step.changing.referenced.form.warning");

//			var submittedButton = event.target;
//			showFancyConfirmDialog(event.target, msg);
//			var save = confirm(msg);
//			return false;	// don't submit now, just later when confirmed
			var save = confirm(msg);
			return save;
		}
		return true;
	},

	/**
	 * Update the look of the TestStep editor after a change inside
	 */
	updateTestStepEditorLook: function(table) {
		var $table = $(table).closest("table");
		TreeToTableDNDIntegration.handleEmptyTable($table,
				$table.hasClass('jstree-drop') ? 'testcase.editor.teststeps.table.drop.teststeps.here' : 'testcase.editor.no.steps'
		);
		TreeToTableDNDIntegration.fixZebraTable($table);
		$table.find("tbody tr").each(function() {
			// add the correct CSS classes to rows to show if this is "outgoing"/referencing or "incoming"/referenced step
			// displaytag can not add the CSS class to TR that's why needed, plus the referencing status of the row may change too
			var $tr = $(this);

			var $referredTestSteps = $tr.find("[name='referredTestSteps']");
			var ref = $referredTestSteps.val();
			var isReferencing = $referredTestSteps.length > 0 && (ref != null && ref != "");
			$tr.toggleClass("referrencingStep", isReferencing);

			// add the button which can be used to break reference (and reset it)
			var $testStepControls = $tr.find(".testStepControls");
			if ($testStepControls.length > 0) {
				var $breakReferenceButton = $testStepControls.find(".breakReferenceButton");
				if ($breakReferenceButton.length == 0) {
					var value = i18n.message("testcase.editor.break.reference.button");
					var title = i18n.message("testcase.editor.break.reference.button.title");
					$testStepControls.append("<input type='button' class='breakReferenceButton button' value='" + value + "' title='" + title +"' />");
				}
			}

			// make controls read-only depending if this is "referencing"
			var $editFields = $tr.find("input,textarea");

			$editFields.prop("readonly", isReferencing ? true : ""); //make controls editable

			// add css class if reusing
			var $reusingMe = $tr.find(".reusingMe");
			var isReferenced = $reusingMe.length > 0;
			$tr.toggleClass("referencedStep", isReferenced);
		});
	},

	/**
	 * When clicking on a referenced Test Step's url the anchor will contain the TestStep's id. This highlights that Step and puts the focus there
	 */
	focusTestStepInHash: function() {
		var hash = getLocationHash();

		if (hash) {
			var $testStep = $("a[name='" + hash +"']").first();
			if ($testStep.length > 0) {
				var $tr = $testStep.closest("tr");
				var $textarea = $tr.find("textarea").first();
				flashChanged($tr.find("td"), null, function() {$textarea.focus();});
			}
		}
	},

	closeOpenEditorInTable: function($table) {
		var openEditor = $table.find('.editor-wrapper textarea');
		if (openEditor.length) {
			return codebeamer.WYSIWYG.destroyEditor(openEditor, true);
		}
		return $.when();
	},

	renderHtmlForCell: function($cell, $editor, entityRef, conversationId) {
		var markup = $editor.val();
		if (markup.length) {
			var ajaxArgs = {
				success: function(result) {
					var $wikiContent = $cell.find('.wikiContent');
					if ($wikiContent.length) {
						$wikiContent.replaceWith(result.content);
					} else {
						$cell.append(result.content);
					}

					$cell.find('.wikiContent').attr('tabindex', 0);

				}, error: function(jqXHR, textStatus, errorThrown) {
					$cell.prepend("<div class='error'>" + errorThrown +"</div>");
					console.log('Failed to get wiki preview, error:', errorThrown);
				}
			}
			codebeamer.WikiConversion.convertWikiToHtml(contextPath + '/wysiwyg/wikipreview.spr', markup, ajaxArgs, entityRef, conversationId);
		} else {
			var $wikiContent = $cell.find('.wikiContent');
			if ($wikiContent.length) {
				$wikiContent.html('');
			}
		}
	},

	attachmentRelinkingInWikiMarkup: function(markup, issueId) {
		// [!attachment.gif!] -> [![ISSUE:9999]/attachment.gif!] (AttachmentsRelinkingWikiMarkupRewriter.java)
		if (!markup) return;

		return markup.replace(/\[\!.+?\!\]/g, function(matchedImage) {
			if (matchedImage.indexOf('[ISSUE:') > -1) {
				return matchedImage;
			}
			return '[![ISSUE:' + issueId + ']/' + matchedImage.substring(2, matchedImage.length - 2) + '!]';
		});
	}
});


codebeamer.TestStepEditor.prototype = {
	init: function(tableId) {
		var self = this;
		this.tableId = tableId;
		var instances = codebeamer.TestStepEditor.instances;
		instances[tableId] = this;

		$(document).ready(function() {
			var $tr, $table = $("#" + self.tableId);
			TreeToTableDNDIntegration.init($table);
			$table.find('> tbody').sortable({
				"stop": function(e, ui) {
					codebeamer.TestStepEditor.updateTestStepEditorLook($table);
					$table.addClass("edited"); // mark the table as edited after the rows were moved
				},
				"axis" : "y",
				"placeholder": {
					element: function() {
						var colspan = $table.find("thead th").length;
						return $("<tr class='dragRowPlaceholder'><td colspan='" + colspan +"'><div></div></td></tr>");
					},
					update: function() {
						return;
					}
				},
				"cancel": ".inlineInput",
				distance: 5,
				delay: 150,
				handle: '.dragColumn'
			});

			codebeamer.TestStepEditor.initGlobalEventHandlers();

			$table.find('.wikiContent').attr('tabindex', 0);

			$table.on('click focusin', '.actionCell:not(.edited), .expectedResultCell:not(.edited)', function(e) {
				var $cell = $(this),
					$textarea = $cell.find('textarea');

				codebeamer.TestStepEditor.closeOpenEditorInTable($table);

				if (!$textarea.attr('readonly')) {
					var editorId = $textarea.attr('id'),
						entityRef = $textarea.attr('data-entity-id') ? '[ISSUE:' + $textarea.attr('data-entity-id') + ']' : undefined,
						conversationId = $textarea.siblings('input[type="hidden"]').val();

					if (!$.isNumeric(conversationId)) {
						// Document view mode, get the conversation id, which belongs to the currently edited test case
						conversationId = $table.siblings("input[name=uploadConversationId]").val();
					}

					$cell.addClass('edited');
					codebeamer.TestStepEditor.additionalEditorOptions.uploadConversationId = conversationId;

					$textarea.wrap('<div class="editor-wrapper" ></div>');

					$textarea.on('froalaEditor.initialized', function(event, editor) {
						editor.events.on('keydown', function(e) {
							if (e.which == $.FE.KEYCODE.TAB) {
								if (!e.shiftKey) {
								    var $table = $textarea.closest('.testStepTable'),
										$last = $table.find('.inlineInput').last();

									// is this the last ?
									if ($last.get(0) == $textarea.get(0)) {
										// create a new row on tab press
										var editor = codebeamer.TestStepEditor.get($textarea);
										editor.addNewRow(editor.tableId);
										e.preventDefault();
									} else {
										if (codebeamer.WYSIWYG.isIE()) {
											if ($textarea.closest('td.actionCell').length) {
												$textarea.closest('td.actionCell').next().click();
											} else if ($textarea.closest('td.expectedResultCell').length) {
												$textarea.closest('tr').next().find('td.criticalColumn .criticalCheckbox').focus();
											}
										}
									}
								}
								return false;
							} else if (!e.shiftKey) {
								// #1609866 - 'contentChanged' is not always triggered
								$textarea.addClass('dirty');
							}
						}, true);
					});

					codebeamer.WikiConversion.bindEditorToEntity(editorId, entityRef);
					codebeamer.WYSIWYG.initEditor(
						editorId,
						codebeamer.TestStepEditor.editorOptions,
						codebeamer.TestStepEditor.additionalEditorOptions,
						true
					);

					$textarea.on('cbEditorDestroyed', function() {
						$textarea.closest('td.edited').removeClass('edited');
						codebeamer.TestStepEditor.renderHtmlForCell($cell, $textarea, entityRef, conversationId);
						$textarea.off('cbEditorDestroyed');
						$textarea.off('froalaEditor.CB.contentInitialized');
					});

					$textarea.on('wysiwyg:save', function() {
						if (typeof saveSteps !== 'undefined' && $.isFunction(saveSteps)) {
							var issueId = $textarea.closest('.testStepTable').attr('id').replace('et_', '');
							if (issueId) {
								saveSteps(issueId);
							}
						}
					});
				}

				return false;
			});
		});
	},

	addNewRow: function(tableId) {
		var $table = $('#' + this.tableId + '> tbody');
		var $last = $table.find('> tr').last();
		if ($last.length == 0) {
			// empty table, add one row
			$table.append("<tr class='temporary' style='display:none;'></tr>");
			$last = $table.find("tr").last();
		}

		this.insertRow($last, "after");

		// remove temporary row
		$table.find("tr.temporary").remove();
	},

	insertRow: function($referenceRow, fn) {
		var $table = $("#" + this.tableId);
		var rowId = Math.random().toString(36).substring(2) + "_";
		var rowAsHtml = $("#newRowTemplate").find("tbody").first().html();
		rowAsHtml = rowAsHtml.replaceAll("___tableId___", this.tableId).replaceAll("__uniqueId__", rowId);
		$referenceRow[fn](rowAsHtml);
		var $row;

		// then remove the empty row (the one saying "no results")
		try {
			var $empty = $("#" + this.tableId + " tr.empty");
			if ($empty) {
				$empty.remove();
			}
		} catch (e) {}

		if ($referenceRow.is(".empty")) {
			$row = $($("#" + this.tableId).find("tr")[1]);
		} else {
			if (fn === "after") {
				$row = $referenceRow.next();
			} else {
				$row = $referenceRow.prev();
			}
		}
		// clear the stepId: this will be a new row
		var $stepIds = $row.find("[name='stepIds']");
		$stepIds.val("");

		$table.addClass("edited");

		ScrollUtil.scrollContainerToElement(document.getElementById("centerDiv"), $row.get(0));

		// init the tab handler
		codebeamer.TestStepEditor.updateTestStepEditorLook($referenceRow.closest("table"));

		//remove the critical checkbox if the critical column is hidden
		var $critCol = $table.find("th.criticalColumn");
		if ($critCol.length == 0) {
			$row.find(".criticalColumn").find("input:visible").remove();
		}

		$table.trigger("teststep.insert", [$row]);

		setTimeout(function() {
			$row.find('.actionCell').click();
		});

		return $row;
	},

	deleteTestStep: function(b) {
		var $btn = $(b);
		var doDelete = function() {
			var $table = $btn.closest("table");	// get the reference to table before row is removed from DOM, otherwise table ref won't work properly

			var $row = $btn.closest("tr");
			var generatedId = $row.find("[name=generatedId]").val();

			$row.find('.editor-wrapper textarea').each(function() {
				var editorId = $(this).attr('id');

				if (editorId) {
					var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);
					editor && editor.destroy();
				}
			});

			$row.remove();

			$table.find(".treeToTableDropPlaceHolder").remove();
			codebeamer.TestStepEditor.updateTestStepEditorLook($table);
			$table.addClass("edited");

			// if the table is empty then add an "empty" row
			if ($table.find("tbody tr:visible").length == 0) {
				var emptyRow = "<tr class='empty odd'><td colspan='3'>" + i18n.message("table.nothing.found") + "</td></tr>";
				$table.find("tbody").append(emptyRow);
			}
			$table.trigger("teststep.delete", [generatedId]);
		}
		var isReferenedStep = codebeamer.TestStepEditor.isReferencedStep($btn);
		if (isReferenedStep) {
			// when deleting a referenced/reused test-step show a warning
			showFancyConfirmDialogWithCallbacks(i18n.message("testcase.editor.step.referenced.delete.warning"), function() {
				doDelete();
			}, null);
		} else {
			doDelete();
		}
	},

	insertStepBefore: function(b) {
		var $btn = $(b);
		var $row = $btn.parentsUntil("table", "tr");
		this.insertRow($row, "before");
	},

	insertStepAfter: function(b) {
		var $btn = $(b);
		var $row = $btn.parentsUntil("table", "tr");
		this.insertRow($row, "after");
	}

};
