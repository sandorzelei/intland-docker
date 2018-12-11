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
codebeamer.InlineComment = codebeamer.InlineComment || (function($) {

	var setVisibility = function($container) {
		$container.find('input[name="visibility"]').val($container.getCommentVisibility());
	};

	var saveEditor = function($container, editorId) {
		if (codebeamer.WYSIWYG.isFileUploadInProgress(editorId)) {
			showFancyAlertDialog(i18n.message('dndupload.uploadsareinprogress'));
			return false;
		}

		var $editor = $('#' + editorId);

		if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
			codebeamer.WikiConversion.saveEditor(editorId, true);
		}

		$container.find('input[name="description"]').val($editor.val());

		codebeamer.NavigationAwayProtection.reset();

		return true;
	};

	var showWarningAlert = function(message) {
		showFancyAlertDialog(message || i18n.message("comment.saved.fail.warning"));
	};

	var initAddCommentLink = function($container, editorId) {
		var $editor = $('#' + editorId),
			mode = codebeamer.WYSIWYG.getEditorMode($editor);

		$container.hide();
		$container.prev('.addCommentLink').find('a').click(function() {
			initSpecialEvents($container, editorId);
			$container.show();

			if (window.localStorage.wysiwygFormattingOptionsVisible == 'true' &&
				!$editor.froalaEditor('popups.isVisible', 'cbFormattingOptionsToolbar.popup')) {
				codebeamer.WYSIWYG.getEditorInstance(editorId).commands.exec('cbFormattingOptions');
			}

			if (mode == 'wysiwyg') {
				$editor.froalaEditor('events.focus');
			} else {
				$editor.focus();
			}

			$(this).closest('.addCommentLink').hide();
			return false;
		});
	};

	var initSpecialEvents = function($container, editorId) {
		var editor = codebeamer.WYSIWYG.getEditorInstance(editorId),
			isMac = editor.helpers.isMac();

		var handleHotkeyEvent = function(event) {
			if ((isMac && event.metaKey || !isMac && event.ctrlKey) && (event.which == 83)) {
				editor.commands.exec('cbSave');

				return false;
			}
		};

		// TODO: Froala currently doesn't bubble up this event
		$container.off('keydown');
		$container.on('keydown', handleHotkeyEvent);

		codebeamer.NavigationAwayProtection.init();
	};

	var cancelClickHandler = function($container, editorId) {
		var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);

		codebeamer.EditorFileList.removeAllFiles(editor.$oel);
		codebeamer.NavigationAwayProtection.removeInspectedElement(editor.$oel);
		setTimeout(codebeamer.WYSIWYG.clearEditor.bind(null, editorId));
		$container.prev('.addCommentLink').show();
		$container.hide();
		$('.ui-multiselect-menu.commentVisibilityControl').hide();
	};

	var saveClickHandler = function($container, editorId) {
		var editor = codebeamer.WYSIWYG.getEditorInstance(editorId);

		editor.edit.off();

		if (saveEditor($container, editorId)) {
			setVisibility($container);
			var artifactId = $container.find('input[name="artifact_id"]').val();
			var taskId = $container.find('input[name="task_id"]').val();
			var data = {
				"task_id" : taskId,
				"tracker_id":  $container.find('input[name="tracker_id"]').val(),
				"artifact_id": artifactId.length > 0 ? artifactId : 0,
				"visibility": $container.find('input[name="visibility"]').val(),
				"reply": $container.find('input[name="reply"]').val(),
				"description": $container.find('input[name="description"]').val(),
				"format": $container.find('input[name="format"]').val(),
				"charsetName": $container.find('input[name="charsetName"]').val(),
				"uploadConversationId": $container.find('input[name="uploadConversationId"]').val(),
				"commentType": $container.find('input[name="commentType"]').val()
			};
			var $commentSubscription = $container.find("#commentSubscription");
			if ($commentSubscription.length > 0 && !$commentSubscription.hasClass("collapsingBorder_collapsed")) {
				var subscription = $container.find('#dynamicChoice_references_commentSubscriptionSelector').val();
				var subscriptionEmailSubject = $container.find('#commentSubscriptionSubject').val();
				if (subscription.length == 0 || subscriptionEmailSubject.length == 0) {
					showFancyAlertDialog(i18n.message("comment.subscription.mandatory.alert"));
					editor.edit.on();
					return;
				}
				data["subscription"] = subscription;
				data["emailSubject"] = subscriptionEmailSubject;
			}
			$.ajax({
				type: "POST",
				url: contextPath + "/ajax/tracker/inlineComment.spr",
				dataType: "json",
				data: data
			}).done(function(result) {
				if (result.hasOwnProperty("success") && !result.success) {
					showWarningAlert(result.error);
					editor.edit.on();
				} else {
					$.ajax({
						type: "GET",
						url: contextPath + "/ajax/tracker/renderComment.spr",
						dataType: "html",
						data: {
							itemId: taskId,
							commentId: result
						}
					}).done(function(html) {
						var $result = $("<div>").html(html);
						var $commentTr = $result.find("#attachment").find("tbody:first").children("tr:first");
						var $actionMenus = $commentTr.find(".yuimenubar");
						var $emptyAttachmentTable = $("#emptyAttachment");
						if ($emptyAttachmentTable.length > 0) {
							$emptyAttachmentTable.before($result.find("#attachment"));
							$emptyAttachmentTable.remove();
						} else {
							$("#attachment tbody tr:first").before($commentTr);
						}

						editor.edit.on();
						$container.hide();
						$('.ui-multiselect-menu.commentVisibilityControl').hide();
						$container.prev(".addCommentLink").show();
						codebeamer.WYSIWYG.clearEditor(editorId);
						$actionMenus.each(function() {
							var actionMenuId = $(this).attr("id");
							initPopupMenu(actionMenuId, {
								context: [actionMenuId, 'tl', 'bl', ['beforeShow', 'windowResize']]
							});
						});
						codebeamer.NavigationAwayProtection.reset();
						flashChanged($commentTr);
						var $commentCountContainer = $("#commentCountContainer");
						if ($commentCountContainer.length > 0) {
							var text = $commentCountContainer.text();

							if (!text.length) {
								$commentCountContainer.text('(1)');
							} else {
								var commentCount = parseInt(text.substring(1, text.length-1), 10) || 0;
								$commentCountContainer.text('(' + (commentCount + 1) + ')');
							}
						}

						if ($.isFunction(window["refreshAfterComment"])) {
							refreshAfterComment();
						}
					}).fail(function() {
						showWarningAlert();
						editor.edit.on();
					});
				}
			}).fail(function() {
				showWarningAlert();
				editor.edit.on();
			});
		} else {
			editor.edit.on();
		}
		return false;
	};

	var initSaveAndCancel = function($container, editorId) {
		$.FroalaEditor.COMMANDS.cbSave.callback = function() {
			saveClickHandler($container, editorId);
		};

		$.FroalaEditor.COMMANDS.cbCancel.callback = function() {
			cancelClickHandler($container, editorId);
		};
	};

	// fix for long comment texts without whitespace
	var fixWidths = function($container) {
		setTimeout(function() {
			var $commentFilter = $container.siblings('.commentFilterContainer');
			$container.css('max-width', window.innerWidth - 100);
			$commentFilter.width() && $commentFilter.css('left', window.innerWidth - $commentFilter.width() - 90);
			$(window).on('resize', throttleWrapper(function() {
				$container.css('max-width', window.innerWidth - 100);
				$commentFilter.width() && $commentFilter.css('left', window.innerWidth - $commentFilter.width() - 90);
			}, 250));
		});
	}

	var init = function($container, editorId) {
		initAddCommentLink($container, editorId);
		initSaveAndCancel($container, editorId);
		$container.trigger('codebeamer:inilineCommentInitialized');
		fixWidths($container);
	};

	return {
		init: init,
		fixWidths: fixWidths
	};

})(jQuery);
