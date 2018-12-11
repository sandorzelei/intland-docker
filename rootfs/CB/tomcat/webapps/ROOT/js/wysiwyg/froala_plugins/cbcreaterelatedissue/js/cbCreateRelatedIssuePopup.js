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
 *
 * $Revision$ $Date$
 */

$(function() {
    var modalId = window.frameElement.getAttribute('data-modal-id'),
		editorId = window.frameElement.getAttribute('data-editor-id'),
		editor = parent.codebeamer.WYSIWYG.getEditorInstance(editorId);

	init();

	function init() {
		var $input = $('#trackerId'),
			$useSelectionAsDescription = $('#useSelectionAsDescription'),
			$projectId = $('#projectId');

		if ($input.length && $useSelectionAsDescription.length) {
			showCreateRelatedIssueDialog($input.val(), $useSelectionAsDescription.val());
		} else {
			loadTrackersOfProject($projectId.val() || parent.codebeamer.projectId || parent.parent.codebeamer.projectId || '').always(function() {
				initEvents();
			});

			$('.actionBar .insertButton').on('click', createWorkItem);
			$('.actionBar .cancelButton').on('click', editor.cbCreateRelatedIssue.hideModal);
		}
	}

	function showCreateRelatedIssueDialog(trackerId, useSelectionAsDescription) {
		var dialog;

		/**
		 * Attach callback method to the window object. It creates a wiki
		 * link based on the task id, and replaces the currently selected
		 * content with the link.
		 *
		 * @param {string}
		 *            taskId Id of the new issue
		 */
		window.onRelatedIssueCreatedFromWysiwygEditor = function(taskId) {
			if (taskId) {
				// var wikiLink = '[' + selectionAsText + '|ISSUE:' + taskId + ']';
				// replace the selection with the link points to the newly created work-item
				var wikiLink = '[ISSUE:' + taskId + ']';

				// convert wiki->html so this gets the correct name of the new work-item
				codebeamer.WikiConversion.wikiToHtml(wikiLink, editorId, false, true).then(function(result) {
					editor.html.insert(result.content);
				});
			}

			editor.cbCreateRelatedIssue.hideModal();
		};

		// Create the popup based on the id stored in a hidden input field
		dialog = inlinePopup.show(contextPath + '/tracker/' + trackerId +
			 '/create?discard_template_field=true&isPopup=true&noReload=true&callback=onRelatedIssueCreatedFromWysiwygEditor', { geometry: '100%_100%', hideMinifyDialogLink: true });

		dialog.closest(".inlinePopupDialog").show().css("width", "100%").css("height", "100%");
		dialog.css("width", "100%").css("height","100%");

		// Close the popup, when the dialog closes
		dialog.on('dialogclose', function() {
			try {
				editor.cbCreateRelatedIssue.hideModal();
			} catch (e) { } // we can ignore the error here
		});

		$('#inlinedPopupIframe').on('load', function() {

			$(".container-close").click(function() {
				try {
					editor.cbCreateRelatedIssue.hideModal();
			    } catch (e) { } // we can ignore the error here
			});

			var iframeContentWindow = $('#inlinedPopupIframe')[0].contentWindow;

			// Set the content of the embedded editor with the wiki content.
			// Here we have to execute code inside the dialog's iframe's window
			iframeContentWindow.updateEditor = function(content) {
				try {
					var editorInside = iframeContentWindow.$ && iframeContentWindow.$.FroalaEditor.INSTANCES[0];
					if (editorInside) {
						// only set the content if the editor is empty, do not change otherwise
						if (! editorInside.core.isEmpty()) {
							console.log("Not setting content because editor is not empty");
							return;
						}

						editorInside.html.set(content);
						editorInside.$oel.addClass('dirty');
					}
				} catch (ex) {
					console.log("Failed to set content on the editor" + ex, ex);
				}
			};

			var content;
			if (useSelectionAsDescription == 'true') {
				content = editor.selection.text();
			} else {
				content = editor.html.get();
			}

			iframeContentWindow.updateEditor(content);
		});
	}


	function createWorkItem() {
		var selectedTrackerId = $("#chooseTracker").val();
		if (!selectedTrackerId) {
			alert("Please choose the target Tracker where Work Items will be created!");
		} else {
			editor.cbCreateRelatedIssue.hideModal();

			var useSelectionAsDescription = $("#useSelectionAsDescription").val();
			editor.cbCreateRelatedIssue.showModal('trackerId=' + selectedTrackerId + '&useSelectionAsDescription=' + useSelectionAsDescription);
		}
	}

	function initEvents() {
		$("#chooseProject").change(function() {
			var projId = $(this).val();

			loadTrackersOfProject(projId);
		});
	}

	function loadTrackersOfProject(proj_id) {
		if (proj_id == null) {
			proj_id = "";
		}
		console.log("Loading trackers of project " + proj_id);

		return $.ajax({
			type: "get",
			url: contextPath + '/proj/getTrackers.spr?proj_id=' + proj_id,
			dataType: "json",
			success: function(data_) {
				function fillSelect(select, data, selectedValue) {
					var $select = $(select);
					$select.empty();

					for (var i=0; i<data.length; i++) {
						var t = data[i];
						var id = t.id;
						if (id) {
							var name = t.name;
							$select.append("<option value='" + id + "' " +
									(id == selectedValue ? "checked='checked'": "")
									+ " >" + name +"</option>");
						}
					}

					if (selectedValue != null && selectedValue != "") {
						$select.val(selectedValue);
					}
				}

				if (data_.projects == null || data_.projects.length == 0) {
					alert("No Projects available, please create at least one project first to use this functionality!");

					editor.cbCreateRelatedIssue.hideModal();
					return;
				}

				fillSelect("#chooseTracker", data_.trackers, null);
				fillSelect("#chooseProject", data_.projects, proj_id);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log("Failed to get list of trackers: " + errorThrown);

				editor.cbCreateRelatedIssue.hideModal();
			}
		});
	}
});