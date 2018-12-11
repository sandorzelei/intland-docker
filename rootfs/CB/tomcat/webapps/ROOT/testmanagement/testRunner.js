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

/**
 * Javascript object to step through the steps of the TestCase, and edit/add actual results...
 */
function Stepper(table, owner, previousRunData) {
	this.init(table, owner, previousRunData);
}

$.extend(Stepper.prototype, {

	MARK_ALL_STEPS_FAILED_IF_CRITICAL_STEP_FAILS: false,

	editorOptions: {
		heightMin: 150,
		toolbarSticky: false
	},

	additionalEditorOptions: {
		disableFormattingOptionsOpening: true,
		useAutoResize: true,
		ignorePreviouslyUploadedFiles: true,
		focus: true
	},
	/**
	 * @param previousRunData the initial steps' data to show, optional, this is an array of each step with the step result and the expected result fields like this:
	 * an example:
  				[{
			    	'actualResult' : 'good',
			    	'stepResult'   : 'PASSED'
			    },
			    {
			    	'actualResult' : 'this is failed',
			    	'stepResult'   : 'FAILED'
			    }]
	 */
	init: function(table, owner, previousRunData) {
		this.table = table;
		this.owner = owner;
		this.previousRunData = previousRunData;
		this._addExtraColumnsToTable();
		this.moveToFirst();
		var self = this;

		var $rows = $(table).find(">tbody tr");
		$rows.click(function(event) {
			var $row = $(this);
			self.copyCurrentToTable();
			// if user has some selection on page then don't select or focus this row, because he may want to just select some text and not "clicking" for selecting this row !
			if (! hasSelection()) {
				self.selectRow($row);
			}
		});
	},

	_addExtraColumnsToTable: function() {
		var $table = $(this.table);
		// add a new column for the actual result
		var actualResultHeader = i18n.message("tracker.field.Actual result.label");
		$table.find(">thead >tr")
			//.prepend("<th></th>")
							   .append("<th>" + actualResultHeader +"</th>");
		var self = this;
		var $tableRows = $table.find(">tbody >tr");
		$tableRows.each(function(stepIndex) {
			var $row = $(this);
			if (!$row.find('.editor-wrapper').length) {
				$row.append("<td class='actualResult'></td>");
				self._initResultCell($row, "", stepIndex);
			}
		});

		$table.find(">thead >tr >th").first().addClass("firstColumn");

		// mark the first column with a special css class
		$tableRows.each(function() {
			$(this).find("td").first().addClass("firstColumn").append("<div class='currentStepIndicator'></div>");
		});
	},

	/**
	 * @param $row The row to select
	 * @param scroll Optional if the step should be scrolled to. Defaults to true
	 */
	selectRow:function($row , scroll) {
		if ($row.hasClass("currentStep")) {
			// do nothing, the current row is selected
			return;
		}

		// remove previous selection
		var $previousSelection = $row.closest("table").find(">tbody tr.currentStep");
		if ($previousSelection.length > 0) {
			this._renderActualResult($previousSelection);
			if ($previousSelection.find('.editor-wrapper').length) {
				var $textarea = $previousSelection.find('.editor-wrapper textarea');
				codebeamer.WYSIWYG.destroyEditor($textarea, false);
				$textarea.removeData('wikiContentUpdatedOnCopy');

			}
			$previousSelection.removeClass("currentStep");
		}
		$row.addClass("currentStep");

		this._copyDataToEditor($row);

		if (scroll == null || scroll) {
			//scroll to the current step
			var $container = $row.closest(".ui-layout-center");
			ScrollUtil.scrollContainerToElement($container.get(0), $row.get(0));
		}
		this._initEditor($row.find("textarea[name='actualResults']").first());
	},

	_initEditor: function($textarea) {
		var editorId = $textarea.attr('id'),
			entityRef = this.owner,
			conversationId = $('input[name="uploadConversationId"]').val();

		this.additionalEditorOptions.uploadConversationId = conversationId;

		$textarea.wrap('<div class="editor-wrapper" ></div>');

		codebeamer.WikiConversion.bindEditorToEntity(editorId, entityRef);
		codebeamer.WYSIWYG.initEditor(editorId,	this.editorOptions,	this.additionalEditorOptions, true);
	},

	// copy data to the editor area when starting the editing
	_copyDataToEditor:function($row) {
		// TODO: remove!
		$("#action").html($row.find("td:eq(0)").html());
		$("#expectedResult").html($row.find("td:eq(1)").html());

		var resultsEditor = $row.find("[name='actualResults']");
		var result = resultsEditor.val();
		$("#actualResult").val(result);
	},

	// find and populate the result cell
	_initResultCell: function($row, html, stepIndex) {
		var $cell = $row.find('td.actualResult');
		if (html != null) {
			var actualResult = null;
			var stepResult = null;
			try {
				if (this.previousRunData) {
					var dataRow = this.previousRunData[stepIndex];
					actualResult = dataRow["actualResult"];
					stepResult = dataRow["stepResult"]
				}
			} catch(ex) {
				console.log("Can not read data from previous run: " + ex);
			}
			if (actualResult == null) {
				actualResult = "";
			}
			if (stepResult == null) {
				stepResult = "";
			}

			$cell.html(html)
			 .append("<div class='renderedActualResult'></div>"+
					 "<textarea id='actualResult_" + stepIndex + "' name='actualResults'></textarea>" +
					 "<input type='hidden' name='stepResult' value='" + stepResult +"'/>");

			if (actualResult != null && actualResult != "") {
				this._renderActualResult($row, actualResult);
			}

			if (stepResult != null && stepResult != "") {
				this._markRowWithStepResult($row, stepResult, true);
			}
		}
		return $cell;
	},

	/**
	 * Render the actual result from wiki->html
	 * @param $row The row to render the actual result
	 * @param value Optional wiki value override, null means that the wiki in the text-area is used
	 * @returns The table-cell (td) for the actual result field
	 */
	_renderActualResult: function ($row, value) {
		var $actualResultCell = $row.find('td.actualResult');
		var $actualResult = $actualResultCell.find("[name='actualResults']");
		var editorMode = codebeamer.WYSIWYG.getEditorMode($actualResult);

		if (value != null) {
			$actualResult.html(value);
		} else {
			if ($actualResultCell.find('.editor-wrapper').length && !$actualResult.data('wikiContentUpdatedOnCopy')) {
				if (editorMode == 'wysiwyg') {
					codebeamer.WikiConversion.saveEditor($actualResult, true);
				}
			}
		}

		var $renderedActualResult = $actualResultCell.find(".renderedActualResult");
		var wiki = $actualResult.val();
		// don't do anything if there is no change
		if ($actualResultCell.data("lastContent") == wiki) {
			return $actualResultCell;
		}

		$actualResultCell.data("lastContent", wiki);

		$renderedActualResult.html(wiki);
		if (wiki != "") {
			console.log("prerendering file upload conversation-id:" + codebeamer.conversationId);
			// render wiki to HTML and put the result to the cell
			var ajaxArgs = {
				async: false,
				success: function(result) {
					$renderedActualResult.html(result.content);
				}, error: function(jqXHR, textStatus, errorThrown) {
					$renderedActualResult.html("<div class='error'>" + errorThrown +"</div>");
					console.log('Failed to get wiki preview, error: ' + errorThrown);
				}
			}
			codebeamer.WikiConversion.convertWikiToHtml(contextPath + '/wysiwyg/wikipreview.spr', wiki, ajaxArgs, this.owner, codebeamer.conversationId);
		}
		return $actualResultCell;
	},

	// copy the completed data to the hidden fields
	_copyDataFromEditor:function(result, $row) {
//		// copy the actual result value to the table
//		var actualResult = $("#actualResult").val();
		var $actualResultCell = this._renderActualResult($row /*, actualResult */);

		if (result != null) {
			this.setStepResult($actualResultCell, result);
		}
	},

	setStepResult: function($row, result) {
		var $stepResult = $row.find("[name='stepResult']");
		$stepResult.val(result);
	},

	getStepResult: function($row) {
		var $stepResult = $row.find("[name='stepResult']");
		var result = $stepResult.val();
		return result;
	},

	// select the 1st TestStep which has no result yet. Or if all has result then select the 1st
	moveToFirst: function() {
		var $rows = $(this.table).find(">tbody tr");
		var self = this;
		// find the first row which has no result, and move there
		$rows.each(function() {
			var $row = $(this);

			var result = self.getStepResult($row);

			if (result == "") {
				// has no result, select this
				self.selectRow($row);
				return false;
			}
			return true;
		});

		// check if has selection? if none then select the first
		if (this.findSelectedRow().length == 0) {
			this.selectRow($rows.first());
		}
	},

	_getRows: function() {
		var $rows = $(this.table).find(">tbody tr");
		return $rows;
	},

	findSelectedRow: function() {
		var $row = $(this.table).find(".currentStep");
		return $row;
	},

	prevStep: function() {
		var $row = this.findSelectedRow();
		if ($row && $row.length >0) {
			var $prev = $row.prev("tr");
			this.selectRow($prev);
		} else {
			var $rows = this._getRows();
			this.selectRow($rows.first());
		}
	},

	nextStep: function() {
		var $row = this.findSelectedRow();
		if ($row && $row.length >0) {
			var $next = $row.next("tr");
			this.selectRow($next);
		} else {
			var $rows = this._getRows();
			this.selectRow($rows.last());
		}
	},

	copyCurrentToTable: function(result) {
		var $row, $expectedResultsWikiContent, owner, $editor, editorInstance;

		$row = this.findSelectedRow();

		if ($row) {
			$editor = $row.find('.editor-wrapper textarea');
			var editorId = $editor.attr('id');
			editorInstance = codebeamer.WYSIWYG.getEditorInstance(editorId);
            $expectedResultsWikiContent = $row.find(".expectedResultColumn .expectedResultsWikiContent");

            if (result === "PASSED" && editorInstance && editorInstance.core.isEmpty() && $expectedResultsWikiContent.size() > 0) {
                var val = $editor.val();
                if (! (val)) {
                    // empty actual-result: copy the expected-result to here
                    var expectedResultsWikiText = $expectedResultsWikiContent.text();
                    owner = $expectedResultsWikiContent.data("owner");

                    // Add reference to the test case, when copying the expected results cell.
                    // Otherwise images would not display, as the owner with which the wiki text is rendered the test run instance
                    // owner must be a wiki link
                    if (owner && owner.length) {
                        expectedResultsWikiText = codebeamer.TestStepEditor.attachmentRelinkingInWikiMarkup(expectedResultsWikiText, owner.match(/\d+/g)[0]);
                    }

                    $editor.val(expectedResultsWikiText);
                    $editor.data('wikiContentUpdatedOnCopy', true);
                }
			}
			this._copyDataFromEditor(result, $row);

			this.autoSaveSteps($row);
		}
		return $row;
	},

	_markRowWithStepResult:function($row, result, removeCurrentStep) {
		if ($row) {
			$row.removeClass("stepBLOCKED stepPASSED stepFAILED")
				.addClass("step" + result);

			if (removeCurrentStep) {
				$row.removeClass("currentStep");
			}
		}
	},

	_markCurrentStep: function(result) {
		var $row = this.copyCurrentToTable(result);

		if ($row) {
			this._markRowWithStepResult($row, result, true);
			if ($row.find('.editor-wrapper').length) {
				var $textarea = $row.find('.editor-wrapper textarea');
				codebeamer.WYSIWYG.destroyEditor($textarea, false);
				$textarea.removeData('wikiContentUpdatedOnCopy');
			}
		}

		return $row;
	},

	_isCriticalStep: function($row) {
		return ($row.find(".criticalColumn img").length > 0);
	},

	markCurrent: function(result, canSubmit) {
		var $row = this._markCurrentStep(result);
		if ($row) {
			// before moving to the next check if this was critical step?
			var criticalStep = this._isCriticalStep($row);
			// move to next
			var $next = $row.next();
			var hasNextStep = $next.length > 0;
			if (hasNextStep) {
				this.selectRow($next);
			}

			// check if this is critical step?
			var failed = (result == "BLOCKED" || result == "FAILED");
			if (failed && criticalStep) {
				if (Stepper.prototype.MARK_ALL_STEPS_FAILED_IF_CRITICAL_STEP_FAILS) {
					// failing a critical step will make all other steps failing!
					this.markAllRemainingSteps(result);
				}
				SubmitDialog.submitForm(null, null, true);
			} else {
				if (!hasNextStep) {
					// no more steps, submit the form
					SubmitDialog.submitForm();
				}
			}
		}
	},

	clearStep: function() {
		var $row = this.findSelectedRow();
		if ($row) {
			var previousResult = this.getStepResult($row);
			console.log("Removing result <" + previousResult +"> from row:" + $row);

			var clearActualResults = function(askConfirm) {
				// as question if the user wants to clear text?
				var $cell = $row.find("td.actualResult");

				var $actualResults = $row.find("[name='actualResults']");
				var val = $actualResults.val();
				val = jQuery.trim(val);
				if (val != "") {
					var msg = i18n.message("testrunner.clear.step.clear.actual.result.question");
					var doClear = function() {
						$actualResults .val("");
					};

					if (askConfirm) {
						showFancyConfirmDialogWithCallbacks(msg, doClear);
					} else {
						doClear();
					}
				}
			}

			// remove the Result and the clear the actual-result
			if (previousResult != "") {
				this._markRowWithStepResult($row, "", false);
				this.setStepResult($row, "");
			}

			// clearActualResults(false);
		}
	},

	// mark the current and the following steps with a certain result
	// used by "Pass All" and similar buttons
	markAllRemainingSteps: function(result) {
		var $row = this._markCurrentStep(result);
		while ($row) {
			var $next = $row.next();
			if ($next.length >0) {
				this.selectRow($next);
				$row = this._markCurrentStep(result);
			} else {
				$row = null;
			}
		}
	},

	/**
	 * Automatically save steps to server via an ajax call
	 */
	autoSaveSteps: function($row) {
		var $form = $($row).closest("form");
		autoSaveForm($form);
	}
});

var SubmitDialog= {
	hasMoreTests: true,

	/**
	 * Get the number of steps complete vs pending
	 * @return an object with number of complete and pending steps
	 */
	getStepsComplete: function() {
		var result = {
			numComplete: 0,
			numPending:0,
			numFailed:0
		};
		$("[name='stepResult']").each(function() {
			var stepResult = $(this).val();
			if (stepResult) {
				result.numComplete ++;
			} else {
				result.numPending ++;
			}
			if (stepResult != '' && stepResult != 'PASSED') {
				result.numFailed++;
			};
		});
		return result;
	},

	// write back the conclusion inside of the overlay to the form behind
	writeBackConclusion: function() {
		  var $conclusionInDialog = $("#conclusionInDialog");
		  if ($conclusionInDialog.length > 0) {
			  var updatedConclusion = $conclusionInDialog.val();
			  $("#conclusion").val(updatedConclusion);
		  }
	},

	/**
	 *  Show the submit-form confirm dialog
	 *
	 *  @param result The (optional) result of the form. Used when pass-all/fail-all or similar buttons pressed
	 *  @param failed If the test has failed
	 *  @param failBecauseCriticalStep
	 *  @param warnNotAllStepsComplete
	 */
	submitForm: function(result, failed, failBecauseCriticalStep, warnNotAllStepsComplete) {
		try {
			var $form = $("#command");
			var $defaultResult = $("[name='defaultResult']");
			$defaultResult.val(result);

			var hasBugsReported = $form.find("[name='reportedBugIds']").val() != '';

			var stepsComplete = SubmitDialog.getStepsComplete();
			var allStepsCompleted = (stepsComplete.numPending == 0);
			if (warnNotAllStepsComplete == false) {
				allStepsCompleted = true;
			}

			var hasSteps = (stepsComplete.numPending + stepsComplete.numComplete > 0);

			var buttonYesText=i18n.message("button.save");
			var buttonCancelText=i18n.message("button.cancel");

			var showConclusion = true;
			var alreadySubmitting = false;

			var submitButWaitForUploads = function() {
				return waitForFileUploadsFinished(function() {
					if (alreadySubmitting) {	// avoid multiple messages
						console.log("Already submitting...");
						return;
					}

					try {
						// close the overlay dialog
						SubmitDialog.dialog.dialog("destroy");
					} catch (ex) {
						console.log("Failed to close dialog:" + ex);
					}

					// cover the page, the save is in progress
					console.log("Showing save in progress dialog!");
					ajaxBusyIndicator.showBusyPage(i18n.message("button.saving"), true);

					$form.submit();

					alreadySubmitting = true;
				}, true);
			}

			var html = [];
			html.push("<div class='warning'>");

			html.push("<h3 style='margin: 0 0 1em 0;'>");
			if ((failed == null || failed == false) && hasSteps) {
				// calculate failed from the steps if not provided by the caller button
				failed = (stepsComplete.numComplete >0) && (stepsComplete.numFailed >0);

				if (failBecauseCriticalStep/* && !allStepsCompleted*/) {
					var msg = Stepper.prototype.MARK_ALL_STEPS_FAILED_IF_CRITICAL_STEP_FAILS ? "testrunner.message.all.fails.because.critical.step" : "testrunner.message.all.skipped.because.critical.step";
					msg = i18n.message(msg);
					html.push(msg);
				} else {
					if (allStepsCompleted) {
						var msg;
						if (SubmitDialog.hasMoreTests) {
							msg = i18n.message("testrunner.no.more.steps.move.to.next.confirm");
						} else {
							msg = i18n.message("testrunner.no.more.steps.confirm.when.no.more.tests");
						}
						html.push(msg);
					} else {
						if (stepsComplete.numComplete == 0) {
							var msg = i18n.message("testrunner.save.and.next.can.not.move.none.complete");
							buttonYesText = null; // don't show the yes button
							buttonCancelText = i18n.message('button.ok');
							html.push(msg);

							// don't show conclusion: there is just a cancel in the dialog so pointless to show
							showConclusion = false;
						} else {
							var msg = i18n.message("testrunner.save.and.next.not.all.steps.complete",
									stepsComplete.numComplete, (stepsComplete.numComplete + stepsComplete.numPending));
							html.push(msg);
						};
					};
				}
			} else {
				if (!failed || hasBugsReported) {
					//save immediately if no failure or there are already bugs reported
					return submitButWaitForUploads();
				}
			}
			html.push("</h3>");

			var reportBugButtonFragment = $("#reportBugButton").first().outerHTML();
			reportBugButtonFragment = reportBugButtonFragment.replace(/<img[^>]*>/g,"");
			reportBugButtonFragment = reportBugButtonFragment.replace("reportBugbutton", ""); // remove the id
			//var reportBugButtonFragment = "<a href='#' onclick='return SubmitDialog.reportBug();'>" + $("#reportBugButton").html() +"</a>";
			reportBugButtonFragment = "<a id='reportBugLink' href='#' onclick='return SubmitDialog._reportBug();'>" + reportBugButtonFragment +"</a>";

			// this will show the submit message-overlay again after the report-bug overlay closes/finishes/cancelled
			SubmitDialog.onReportBugClose=function() {
				SubmitDialog.submitForm(result, null, failBecauseCriticalStep, warnNotAllStepsComplete);
			};

			if (failed && hasBugsReported == false) {
				var msg = i18n.message("testrunner.failed.but.has.no.bug.reported", reportBugButtonFragment);
				html.push(msg);
			};
			html.push("</div>");


			if (showConclusion) {
				// show conclusion overlay before saving
				var conclusion = $("#conclusion").val();
				html.push("<h4 style='margin:0;'>" + i18n.message("testrun.field.conclusion") +"</h4>");
				html.push("<textarea id='conclusionInDialog' title='" + i18n.message("testrun.field.conclusion.hint")+ " onchange='SubmitDialog.writeBackConclusion();' >" + conclusion +"</textarea>");
			}

			// show the dialog
			var buttons = [];
			if (buttonYesText) {
				buttons.push(
					{ text:buttonYesText,
					  click:function() {
						  SubmitDialog.writeBackConclusion();
						  submitButWaitForUploads();
					  }
					}
				);
			}
			if (buttonCancelText) {
				buttons.push(
						{ text:buttonCancelText,
							"class": "cancelButton",
							click:function() {
								SubmitDialog.writeBackConclusion();

								$defaultResult.val("");
								$(this).dialog("destroy");
							}
						}
					);
			}
			// first button is the default
			buttons[0].isDefault = true;

			var msg = html.join('');
			var dialog = showModalDialogWithArgs(null, msg, buttons, "cbModalDialog", true, {
				width: 500,
				beforeClose: function(event, ui) {
					SubmitDialog.writeBackConclusion();
				}
			});
			SubmitDialog.dialog = dialog;
		} catch (ex) {
			console.log(ex);
		}
		return false;
	},

	_reportBug: function() {
		var dialog = SubmitDialog.dialog;
		dialog.dialog("destroy");

		reportBug.showOverlay($("#reportBugButton"), SubmitDialog.onReportBugClose);
		return false;
	}

};

/**
 * Javascript to measures time and updates controls on page, with pause/continue
 */
var timer = {
	startTime: new Date(),
	timeAdd: 0, // the seconds to add because there was some time collected in the previous timing
	suspended: false,
	// if the timer is allowed at all?
	allowTiming: true,

	init: function(totalTimeStart, timeStart) {
		timer.totalTimeStart = totalTimeStart;
		timer.timeAdd = timeStart;
		setInterval(function() {
				timer.measureTime();
			}, 800);
		timer._showTime(timeStart); // render the time as soon as possible

		$("form").submit(function() { timer.measureTime(); });

		$(".pauseButton").click(timer.toggleTimer);
		$(".continueButton").click(timer.toggleTimer);
	},

	_showTime: function(timeSpent) {
		if (! timer.allowTiming) {
			console.log("Timer is disabled");
			return;
		}

		var formattedDate = secondsToHms(timeSpent);
		$("#timer").html(formattedDate);
		$("input[name='timeSpent']").val(timeSpent);
		$("#totalTime").html(secondsToHms(timeSpent + timer.totalTimeStart));
	},

	/**
	 * Update the timer controls
	 * @return The time spent so far in seconds
	 */
	measureTime: function() {
		try {
			// console.log("measure time called");
			var now = new Date().getTime();
			var timeSpent = Math.round((now - timer.startTime) / 1000) + timer.timeAdd;
			if (!timer.suspended) {
				timer._showTime(timeSpent);
			}
			return timeSpent;
		} catch (e) {
			console.log("error in measureTime:" + e);
		}
	},

	// suspend/resume timer
	toggleTimer: function() {
		if (timer.suspended == false) {
			// preserve the time collected so far during pause/resume
			timer.timeAdd = timer.measureTime();
		}
		timer.suspended = !timer.suspended;
		console.log("timer suspended:" + timer.suspended);
		timer.startTime = new Date(); // start counting from now

		$("body").toggleClass("timerSuspended", timer.suspended);
		return false;
	},

	isRunning: function() {
		return !timer.suspended;
	},

	// suspend timer
	suspend: function() {
		if (! timer.suspended) {
			timer.toggleTimer();
		}
	},

	// resume timer
	resume: function() {
		if (timer.suspended) {
			timer.toggleTimer();
		}
	}

};

function saveCurrentStepData() {
	try {
		if (window.hasOwnProperty('stepper') && stepper) {
			stepper.copyCurrentToTable(null);
		} else {
			console.log("Can not save step data, stepper is not initialized!");
		}
	} catch(ignored) {
		console.log("Error in saveCurrentStepData()" + ignored);
	}
}

var reportBug = {

	stopTimerWhileRepotingBug: false,

	/**
	 * Handling the "report-bug" button, showing bug-report in an overlay...
	 * @param button The button to click
	 * @param onClose Optional function will be called back when the overlay is closed
	 */
	showOverlay: function(button, onClose) {
		saveCurrentStepData();

		var wasRunning = timer.isRunning();
		if (reportBug.stopTimerWhileRepotingBug) {
			timer.suspend();
		}

		// sending the current data to the server with an ajax call
		// so the bug will contain the current information about the steps
		var $form = $(button).closest("form");
		var formdata = serializeFormWithAction($form);

		$.ajax({
			url: contextPath + "/ajax/testRunnerReportBug.spr",
			type: "POST",
			data: formdata,
			success: function(data, textStatus, jqXHR) {
						// will receive an special url from the ajax call
						// for the page that should show the prepared bug in the overlay
						var addBugOverlayUrl = data.addBugOverlayUrl;
						if (addBugOverlayUrl) {
							var dlg = inlinePopup.show(addBugOverlayUrl, { dialogClass: "inlinePopupDialog reportBugDialog"});

							var doOnClose = function(e) {
								// restart the timer if that was running and stopped by report-bug
								if (reportBug.stopTimerWhileRepotingBug && wasRunning) {
									timer.resume();
								}
								if (onClose) {
									onClose(dlg);
								}
							};

							dlg.on("dialogclose", doOnClose);
						}
					}
				,
			error: function(data, textStatus, jqXHR) {
				}
			}
		);
	},

	/**
	 * Called back by the report-bug overlay when the bug added or when the overlay was just closing
	 * @param bugId The issue id added
	 * @param addd True/null if the bug added, false to remove
	 * @return if the bug was successfully added or removed
	 */
	bugAdded: function(bugId, add) {
		if (add == null) {
			add = true;
		}

		var $reportedBugIds = $("form input[name='reportedBugIds']");
		var val = $reportedBugIds.val();
		var bugIds = [];
		if (val != "") {
			bugIds = val.split(",");
		}
		var idx = bugIds.indexOf(bugId);
		if (add == null || add) {
			if (idx != -1) {
				return false;
			}
			bugIds.push(bugId);
		} else {
			// remove
			if (idx == -1) {
				return false;
			}
			bugIds.splice(idx, 1); // remove the bugId
		}

		$reportedBugIds.val(bugIds.join(","));
		return true;
	},

	showBugAddedMessage:function(bugId, bugName, url) {
		// this will show the globalMessage on the ui about the issue being added
		var deleteBugIcon = "<img style='padding: 2px 5px;' src='" + contextPath +"/images/newskin/action/delete-red-xs.png' title='Disassociatie this bug'" +
				" onclick='reportBug.disassociateBug(this, " + bugId  +");return false;' />";
		var msg = i18n.message("testrunner.bug.added.message", "<a class='bugAdded' href='" + url +"' target='_blank'>" + bugName +"</a>");
		msg += deleteBugIcon;
		GlobalMessages.showInfoMessage(msg);
	},

	disassociateBug: function(message, bugId) {
		reportBug.bugAdded(bugId, false);
		GlobalMessages.hideMessage(message);
	}
};

$(document).ajaxError(ajaxErrorHandler);

// default hotkeys:
mapHotKeys([
	{ key: 'alt+shift+p' , action: function() { $("[name='passAll']").click(); return false;} },
	{ key: 'alt+shift+f' , action: function() { $("[name='failAll']").click(); return false;} },
	{ key: 'alt+shift+b' , action: function() { $("[name='blockAll']").click(); return false;} },
	{ key: 'alt+r' , action: function() { $("[name='reportBugButton']").click(); return false;} },
	{ key: 'alt+n' , action: function() { $("#next").click(); return false;} }
]);

function handleReferenceResolutionProblems() {
	$("body").addClass("hasReferenceResolutionProblem");
	stepper.markAllRemainingSteps('BLOCKED');

	$(".testStepTable .linkToReferenced .warning").each(function() {
		var $tr = $(this).closest("tr");
		var actualResult = i18n.message("testcase.runner.a.step.can.not.be.resolved.actualResult");
		$tr.find("textarea,.renderedActualResult").text(actualResult);
	});

	showFancyAlertDialog(i18n.message('testcase.runner.a.step.can.not.be.resolved'), null, "50em");
}

function showSelectParameterDialog(currentParametersHash) {
	var current = window.location.href;
	var params = current.substring(current.indexOf("?"));
	var url = contextPath + "/testset/testRunner/selectParameter.spr" + params +"&selectedParameterHash=" + currentParametersHash;
	inlinePopup.show(url);
}

function skipCurrentParameters() {
	 var currentParameters = $("input[name='currentParametersHash']").val();
   	 var $skippedParametersInput = $("input[name='skippedParameters']");
   	 $skippedParametersInput.val($skippedParametersInput.val() + "," + currentParameters);
   	 $("#command").submit(); // submit the form
}

function showSelectTestDialog() {
	var current = window.location.href;
	var params = current.substring(current.indexOf("?"));
	var url = contextPath + "/testset/testRunner/selectTest.spr" + params
	inlinePopup.show(url);
}


// if the auto-save is running?
var autoSaveRunning = false;

var setAutoSavingRunning = function(running) {
	if (running) {
		// avoid saving it parallel
		if (autoSaveRunning) {
			console.log("Auto-saving is already in progress...");
			return false;
		}
	}
	autoSaveRunning = running;

	return true;
}

/**
 * Save all data on the screen to the TestRun. This prevents multiple concurrent save operation.
 */
function autoSaveForm($form) {
	// avoid saving it parallel
	if (! setAutoSavingRunning(true)) {
		return;
	}

	function executeAutoSave($form, args) {
		// ensure all data is saved from editors
		saveCurrentStepData();

		var formData = serializeFormWithAction($form);
		console.log("Auto-saving changes:" + formData);

		var mergedArgs = $.extend(
			{
		        type:'POST',
		        url: contextPath + "/testset/testRunnerAutoSave.spr",
		        data:formData,
		        success:function(result) {
		        	console.log("Successfully auto-saved changes:" + result);
		        },
		        error: function(jqXHR, textStatus, errorThrown) {
		        	console.log("Failed to auto-save:" + textStatus);
		        }

			}, args);

		setTimeout(function() { $.ajax(mergedArgs); }, 1000);
	}

	executeAutoSave($form, {
        complete:function() {
        	console.log("Saved changes");
        	setAutoSavingRunning(false);
        }
	});
};

function reloadOpener() {
	try {
		window.opener.location.reload();
		return true;
	} catch (ignored) {
		console.log("Can not reload opener window");
		return false;
	}
}

function pauseRun() {
	saveCurrentStepData();
	navigation.saveBeforeNavigatingAway(null, function() {
		showHiddenConfirmationFormAsDialog("#pauseRunDialog", null, null, submitWithMainForm);
	});
}

function initMissingParameterDialog(show) {
	var missingParameterDialog = $('#missingParameterDialog').dialog({
		autoOpen: false,
		modal: true,
		dialogClass: 'popup',
		width: 600,
		buttons: [
			{
				text: i18n.message("button.save"),
				click: function() {
					var parameterMap = {};
					$(".missingParameterTableContainer").find("textarea").each(function() {
						parameterMap[$(this).attr("name")] = $(this).val();
					});
					$('input[name="missingParameterValues"]').val(encodeURIComponent(JSON.stringify(parameterMap)));
					$("form#command.ui-layout-container").submit();
				}
			},
			{
				text: i18n.message("button.cancel"),
				"class": "cancelButton",
				click: function() {
					$(this).dialog("close");
				}
			}
		]
	});

	var $link = $(".missingParameterValuesLink");
	$link.click(function() {
		navigation.saveBeforeNavigatingAway(null, function() {
			missingParameterDialog.dialog("open");
		});
	});

	if (show == null || show) {
		$link.click();
	}
}

var navigation = {

    // if the navigation automatically saves the steps and all data ?
	autoSave: true,	// Note: tested only with "true" setting recently

	/* Save the current data before navigating away from the current TestCaseRun
	  @param $form The form to save
	   @param callback The callback function to execute when the save is completed:
			  necessary because the save is always asynchronous, because an async save might be in progress already when navigating away
	*/
	saveBeforeNavigatingAway: function($form, callback) {
		if ($form == null) {
			// use the default form
			$form = $("form#command");
		}

		var callTheCallback = function() {
			console.log("Calling saveBeforeNavigatingAway() callback:" + callback);
			callback();
		}

		if (navigation.autoSave) {
			autoSaveForm($form);
			$(document).one("ajaxStop",callTheCallback);	// when the ajax request completed then execute the callback function: only called once!
		} else {
			callTheCallback();
		}
	},

	// set up navigation links' scripts
	initNavigationLinks: function() {
		console.log("initializin navigation links' events");
		var submitWithNavigation = function(element, action) {
			var $form = $(element).closest("form");

			navigation.saveBeforeNavigatingAway($form, function() {
				$("[name='navigation']").val(action);
				$form.submit();
			});
		};

		$("#jumpTo").keypress(function(event) {
			if (event.which == 13) {
				try {
					// submit on enter key
					var val = $(this).val();
					submitWithNavigation(this, val);
				} finally {
					// the default event must not happen
					event.preventDefault();
					return false;
				}
			}
		});
		$(".navigationLinks a").click(function(event) {
			var $linkClicked = $(this);
			if ($linkClicked.hasClass('navDisabled') || $linkClicked.hasClass('nowarn') ) {
				// button is disabled, do nothing
				return false;
			}

			var submitNavLink = function() {
				var action = $linkClicked.attr("id");
				submitWithNavigation($linkClicked, action);
			};

			if (navigation.autoSave) {
				submitNavLink();
			} else {
				var stepsComplete = SubmitDialog.getStepsComplete();
				if (stepsComplete.numComplete > 0) {
					var msg = i18n.message("testrunner.navigationlinks.confirm.loosing.steps");
					showFancyConfirmDialogWithCallbacks(msg, submitNavLink);
				} else {
					submitNavLink();
				}
			}

			return false;
		});

	}

}

function prevStep() {
	console.log("Previous step!");

	if (stepper) {
		stepper.prevStep();
	}
}

function nextStep() {
	console.log("Next step!");

	if (stepper) {
		stepper.nextStep();
	}
}

// set up event handlers so when clicking somewhere outside of "Pass All" and similar menus then other menus will be hidden
function autoHideMenus() {
	$(document).click(function(event) {
		//var $target = $(event.target);

		var $menus = $(".autoHideMenu:visible");
		$menus.each(function() {
			var target = event.target;
			var $parents = $(this).parents(); // check if clicked on the parent of this?
			var clickedOnParent = $.inArray(target, $parents) != -1;
			if (this == target|| clickedOnParent) {
				// don't close this
			} else {
				$(this).hide();
			}
		});
	});
}

