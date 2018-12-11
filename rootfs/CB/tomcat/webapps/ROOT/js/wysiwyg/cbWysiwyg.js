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
var codebeamer = codebeamer || {};

codebeamer.WYSIWYG = codebeamer.WYSIWYG || (function($) {
	var newEditorId = 0,
		iconsInited = false,
		isMacOs,
		isInIE,
		isInChrome;

	function overrideFroalaFunctions() {
		if (!$.FE.MODULES.hasOwnProperty('shortcutsOriginal')) {
			$.FE.MODULES.shortcutsOriginal = $.FE.MODULES.shortcuts;

			$.FE.MODULES.shortcuts = function (editor) {
				var shortcuts, get;

				shortcuts = $.FE.MODULES.shortcutsOriginal(editor);
				get = shortcuts.get;

				shortcuts.get = function(cmd) {
					var label, result, i;

					if (cmd == 'cbCancel.') {
						return 'Esc';
					}
					
					label = get(cmd);

					result = '';

					if (label && codebeamer.HotkeyFormatter.isMac) {
						for (i = 0; i < label.length; i++) {
							if (i < label.length - 1) {
								result = result + label.charAt(i) + ' + ';
							} else {
								result = result + label.charAt(i);
							}
						}
					} else {
						result = label;
					}

					return result;
				}

				return shortcuts;
			}
		}

		if (!$.FE.MODULES.hasOwnProperty('refreshOriginal')) {
			$.FE.MODULES.refreshOriginal = $.FE.MODULES.refresh;

			$.FE.MODULES.refresh = function(editor) {
				var refresh = $.FE.MODULES.refreshOriginal(editor),
					indent = refresh.indent;

				refresh.indent = function($btn) {
					var result = indent($btn),
						liInSelection = editor.selection.blocks().filter(function(block) { return block.tagName == 'LI'; }).length;

					if (!liInSelection) {
						$btn.addClass('fr-disabled');
					}
					return result;
				}

				return refresh;
			}
		}
		
		// #1938364 - supporting smb protocol
		if ($.FE.LinkProtocols.indexOf('smb') < 0) {
			$.FE.LinkProtocols.push('smb');
		}
	}

	function initSaveCancelIcons() {
		if (!iconsInited) {
			$.FroalaEditor.DefineIcon('cbSaveIcon', { NAME: 'save' });
			$.FroalaEditor.DefineIcon('cbCancelIcon', { NAME: 'times' });
			iconsInited = true;
		}
	}

	function getEditorInstance(editorId) {
		// the froala editor instance can be found in the data of the editor's textarea
		return $('#' + editorId).data('froala.editor');
	}

	function _createCancelButton(cancelFn) {
		$.FroalaEditor.RegisterCommand('cbCancel', {
			title: i18n.message('button.cancel'),
			icon: 'cbCancelIcon',
			callback: cancelFn
		});
	}

	function _createSaveButton(saveFn) {
		$.FroalaEditor.RegisterCommand('cbSave', {
			title: i18n.message('button.save'),
			icon: 'cbSaveIcon',
			callback: saveFn
		});
	}

	function _createSaveEventCommand() {
		$.FroalaEditor.RegisterCommand('cbSaveEvent', {
			title: '',
			icon: '',
			callback: function() {
				if (this != window) {
					this.$oel.trigger('wysiwyg:save');
				} else {
					var actualEditor = codebeamer.WysiwygShortcuts.getActualEditor();
					actualEditor && actualEditor.$oel.trigger('wysiwyg:save');
				}
			}
		});
	}

	function _isFileDragAndDropEvent(e) {
		var dt = e.originalEvent.dataTransfer,
			result = false;

		if (dt) {
			$.each(dt.types, function(i, type) {
				if (type && type.toLowerCase && type.toLowerCase() == 'files') {
					result = true;
				}
			});
		}

		return result;
	}

	function initDragAndDrop($editorWrapper, editor, $dragAndDropOverlay) {
		var $document = $(document);
		// if dragover on document element is not prevented, then the drag and drop doesn't work
		if (!$document.data('dragPrevented')) {
			$document[0].addEventListener('dragover', function(e) {
				e.dataTransfer && e.preventDefault();
			});
			$document.data('dragPrevented', true);
		}

		editor.$el.on('dragenter', function(e) {
			if (_isFileDragAndDropEvent(e)) {
				$editorWrapper.addClass('upload-drop-area-active');
				e.preventDefault();
			}
		});

		editor.$oel.on('dragenter', function(e) {
			if (_isFileDragAndDropEvent(e)) {
				$editorWrapper.addClass('upload-drop-area-active');
				e.preventDefault();
			}
		});

		$dragAndDropOverlay.on('dragleave', function(e) {
			$editorWrapper.removeClass('upload-drop-area-active');
			e.preventDefault();
		});

		$dragAndDropOverlay.on('drop', function(e) {
			$editorWrapper.removeClass('upload-drop-area-active');
			e.preventDefault();
			//editor.events.trigger(e.type, [e]);
			var dt = e.originalEvent.dataTransfer;

			if (_isFileDragAndDropEvent(e) && dt.files && dt.files.length) {
				$editorWrapper.addClass('file-upload-after-drop');
				// TODO: review the below after parallel file upload is supported by Froala
				if (dt.files[0].type.indexOf('image') > -1) {
					if (getEditorMode(editor.$oel) == 'markup') {
						editor.$oel.data('selection', editor.$oel.getSelection());
					}
					editor.image.upload(dt.files);
				} else {
					editor.file.showInsertPopup();
					editor.file.upload(dt.files);
				}
			}
		});
	}

	function _extendOptionsWithUploadOptions(options, uploadConversationId) {
		options.fileUploadURL = contextPath + '/dndupload/uploadfile.spr';
		options.fileUploadParams = {
			conversationId: uploadConversationId
		};

		options.imageUploadURL = contextPath + '/dndupload/uploadfile.spr';
		options.imageUploadParams = {
			conversationId: uploadConversationId
		};
	}

	function removeElementFromEditor($element) {
		var $parentParagraph = $element.closest('p');

		$element.remove();
		if ($parentParagraph.length && !$parentParagraph.children(':not(br)').length && !$parentParagraph.text()) {
			$parentParagraph.remove();
		}
	}

	function _handleImageInsert(e, editor, $img, response) {
		try {
			var responseObj = JSON.parse(response);

			codebeamer.EditorFileList.addFile(editor.$oel, responseObj.fileName, responseObj.size);

			$img.attr('data-filename', escapeHtml(responseObj.fileName));

			if (getEditorMode(editor.$oel) == 'markup') {
				var selection = editor.$oel.data('selection');
				if (selection) {
					editor.$oel.setSelection(selection.start, selection.end);
				}				
				
				var wikiMarkup = '[!' + responseObj.fileName + '!]';

				editor.$oel.focus();
				editor.$oel.replaceSelectedText(wikiMarkup);
				// hide image edit popup
				setTimeout(function() {
					editor.popups.hide('image.edit');
				});
			}
		} catch(e) {
			if (e.name == 'FileAlreadyAttachedError') {
				removeElementFromEditor($img);
				editor.popups.hide('image.insert');
				showFancyAlertDialog(e.message);
			}
			console.log('Failed to post process inserted file: ' + e);
		}
	}

	function _handleFileInsert(e, editor, $file, response) {
		try {
			var responseObj = JSON.parse(response),
				fileNameEncoded = encodeURIComponent(responseObj.fileName),
				fileName = responseObj.fileName,
				isImage = responseObj.mimeType && responseObj.mimeType.indexOf('image') > -1;

			var url = 'CB:/displayDocument/' + fileNameEncoded + '?doc_id=' + fileNameEncoded,
				wikiMarkup = '[' + fileName + '|' + url + ']';

			if (getEditorMode(editor.$oel) == 'wysiwyg') {
				if (isImage) {
					codebeamer.EditorFileList.addFile(editor.$oel, fileName, responseObj.size);
					// an image is inserted as a file...
					var $img = $('<img>', {
						src: $file.attr('href'),
						'class': 'fr-fic fr-dii fr-draggable'
					});

					$img.attr('data-filename', escapeHtml(fileName));

					$file.replaceWith($img);
					// with triggering a click on the image we make it selected by default, delay is needed to let the browser ready with refreshing the dom
					setTimeout(function() { $img.trigger('click'); }, 250);
				} else {
					codebeamer.EditorFileList.addFile(editor.$oel, fileName, responseObj.size);
					if (editor.$oel.data('insertNonImageAttachments')) {
						$file.removeClass('fr-file')
							.removeAttr('target')
							.addClass('interwiki')
							.attr('rev', url)
							.attr('href', '#');

						$file.attr('data-filename', escapeHtml(fileName));
					} else {
						removeElementFromEditor($file);
					}
				}
			} else {
				var selection = editor.$oel.data('selection');
				if (selection) {
					editor.$oel.setSelection(selection.start, selection.end);
				}

				if (isImage) {
					var wikiMarkup = '[!' + responseObj.fileName + '!]';

					codebeamer.EditorFileList.addFile(editor.$oel, fileName, responseObj.size);

					editor.$oel.focus();
					editor.$oel.replaceSelectedText(wikiMarkup);

					// hide image edit popup
					setTimeout(function() {
						editor.popups.hide('image.edit');
					});
				} else {
					codebeamer.EditorFileList.addFile(editor.$oel, fileName, responseObj.size);
					if (editor.$oel.data('insertNonImageAttachments')) {
						editor.$oel.focus();
						editor.$oel.replaceSelectedText(wikiMarkup);
					} else {
						removeElementFromEditor($file);
					}
				}
			}
		} catch(e) {
			if (e.name == 'FileAlreadyAttachedError') {
				removeElementFromEditor($file);
				showFancyAlertDialog(e.message);
			}

			console.log('Failed to post process inserted file: ' + e);
		}
	}

	function _setToolbarVisible($toolbarContainer, editor) {
		if (editor.$tb) {
			$toolbarContainer.find('.fr-toolbar').each(function() {
				$(this)[editor.$tb[0] !== this ? 'hide' : 'show']();
			});
		}

		autoAdjustPanesHeight();
	}

	function _updateEditorOnOverlayModeChange($editorWrapper, editor) {
		var isActive = $.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor);
		
		if (editor.$tb) {
			var $toolbar = editor.$tb.detach();
	
			if (isActive) {
				$editorWrapper.find(".fr-box").append($toolbar);
			} else {
				if (editor.opts.toolbarContainer) {
					$(editor.opts.toolbarContainer).append($toolbar);
				} else {
					editor.$wp.after($toolbar);
					editor.position.refresh();
				}
			}
		}
	}

	var getDefaultEditorOptions = function (buttons) {
		return {
				charCounterCount: false,
				fileMaxSize: 5 * 1024 * 1024 * 1024, // 5GB (application.xml "uploadLimit" bean)
				imageDefaultDisplay: 'inline',
				imageDefaultWidth: 0,
				imageMaxSize: 5 * 1024 * 1024 * 1024, // 5GB (application.xml "uploadLimit" bean)
				indentMargin: 0,
				key: '9H4A2D3A4B-16D4E3C2D1C3H2C1B10B2A1pBKBOg1a2PQa1ERGRi1B==',
				language: language == 'en' ? 'en_gb' : language,
				linkEditButtons: ['linkOpen', 'linkEdit', 'linkRemove'],
				linkInsertButtons: [],
				linkAlwaysBlank: true,
				listAdvancedTypes: false,
				paragraphFormat: {
					  N: 'Normal',
					  H1: 'Heading 1',
					  H2: 'Heading 2',
					  H3: 'Heading 3',
					  H4: 'Heading 4',
					  H5: 'Heading 5',
					  PRE: 'Preformatted',
					  BLOCKQUOTE: 'Blockquote'
				},
				paragraphFormatSelection: true,
				placeholderText: '',
				quickInsertButtons: ['image', 'table', 'ul', 'ol'],
				toolbarBottom: true,
				toolbarButtons: buttons,
				toolbarButtonsXS: buttons,
				toolbarButtonsSM: buttons,
				toolbarButtonsMD: buttons,
				tableEditButtons: ['tableHeader', 'tableRows', 'tableColumns', 'tableCells', 'tableCellBackground',
								   'tableCellVerticalAlign', 'tableCellHorizontalAlign', '-','cbReorderTableColumns',
								   'cbReorderTableColumnsPushColumnLeft', 'cbReorderTableColumnsPushColumnRight', 'cbReorderTableColumnsPushRowDown',
								   'cbReorderTableColumnsPushRowUp', 'tableRemove'],
				imageEditButtons: ['imageCaption', 'imageRemove', '|', 'imageLink', 'linkOpen', 'linkEdit', 'linkRemove', '|', 'imageAlt', 'imageSize'],
				wordPasteModal: false
		};
	};

	function _removeButton(buttonList, buttonToRemove) {
		var index = buttonList.indexOf(buttonToRemove);
		if (index != -1) {
			buttonList.splice(index, 1);
		}
	}

	function _getAvailableEditorHeight(editor, isInsideIframe) {
		if (isInsideIframe) {
			var $window = $(window),
				windowHeight = $window.height(),
				$body = editor.$wp.closest('body'),
				northPaneHeight = $body.find('.ui-layout-north').height(),
				southPaneHeight = $body.find('.ui-layout-south').outerHeight(),
				$centerPane = $body.find('.ui-layout-center'),

				northPaneHeight = northPaneHeight || 0,
				southPaneHeight = southPaneHeight || 0
				otherElementsHeightInCenterPane = 0;

			$centerPane.children(':not(.editor-wrapper)').each(function() {
				var $element = $(this);
				if ($element.css('position') == 'static') {
					otherElementsHeightInCenterPane += $element.height();
				}
			});

			if (!$centerPane.length && !northPaneHeight && !southPaneHeight) {
				var $editorWrapper = editor.$oel.closest('.editor-wrapper');

				$editorWrapper.hide();
				var value = windowHeight - $body.height() - 40;
				$editorWrapper.show();

				return value;
			} else {
				return windowHeight - northPaneHeight - southPaneHeight - otherElementsHeightInCenterPane - 70; // 30px padding + 28px toolbar + 2px border = 60px + 10px adjustment to make it look better
			}
		} else {
			var $window = $(window),
				existingHeight = editor.$oel.closest('.editor-wrapper').height(),
				windowHeight = $window.height(),
				bodyHeight = editor.$wp.closest('body').height(),
				otherElementsHeight = bodyHeight - existingHeight;

			return windowHeight - otherElementsHeight - (editor.$wp.closest('body').find('#footer').length ? 70 : 40);
		}
	}

	function resizeEditorToFillParent(editor) {
		if ($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor)) {
			return;
		}

		try {
			var editorMode = getEditorMode(editor.$oel),
				editorHeight = _getAvailableEditorHeight(editor, window.parent != window),
				$window = $(window);

			if (editorHeight < 100) {
				editorHeight = 100;
			}

			if (editorMode == 'markup') {
				editor.$oel.css('height', editorHeight + 2);
			} else {
				editor.$wp.css({
					height: editorHeight,
					overflow: 'auto'
				});
				editor.$el.css('min-height', editorHeight);
			}

			if (!editor.$oel.data('resizeHandlerAdded')) {
				$window.resize(throttleWrapper(function() {
					resizeEditorToFillParent(editor);
				}));

				editor.$oel.data('resizeHandlerAdded', true);
			}
		} catch(e) {
			console.log(e);
		}

		editor.$box.removeClass('offscreen');
	}

	function beforeEditorOverlay(e, editor, cmd) {
		var $popup, parent = editor.$oel.parents('.document-view-container');

		if (cmd === 'cbOverlayEditor') {
			codebeamer.EditorToolbars.hideOpenPopups(editor);

			if (parent.size() > 0 && $.isFunction($.waypoints) && editor.opts.toolbarContainer) {
				$.waypoints($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor) ? 'enable' : 'disable');
			}
		} else {
			if (cmd === 'insertFile') {
				$popup = editor.popups.get('file.insert');

				// Clean-up code required when the user opens the file browser, but clicks on cancel. File insert popup not terminates properlz in this case.
				if ($popup && $popup.size() > 0 && $popup.hasClass('hide-insert-file-popup')) {
					if (getEditorMode(editor.$oel) == 'markup') {
						setTimeout(function() { $popup.removeClass('fr-active').removeClass('fr-above'); });
					} else {
						$popup.removeClass('fr-active').removeClass('fr-above');
					}
				} else {
					if ($popup && $popup.size() > 0) {
						$popup.addClass('hide-insert-file-popup')
					}
				}
			}
		}
	}

	function afterEditorOverlay(e, editor, cmd) {
		var parent = editor.$oel.parents('.document-view-container, .wikiSectionEditor, #plannerCenterPane, #browseTrackerForm, #queriesPageContent');

		if (cmd == 'cbOverlayEditor') {
			if (parent.size() > 0) {
				_updateEditorOnOverlayModeChange(editor.$oel.closest('.editor-wrapper'), editor);
			}

			if (editor.$oel.data('resizeEditorToFillParent')) {
				resizeEditorToFillParent(editor);
			}
			if (!$.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor) && getEditorMode(editor.$oel) == 'markup' &&
					editor.$oel.data('useAutoSize') && editor.$oel.css('min-height') == '0px') {
				// it is already markup mode, but switchMode() could be called for 'markup' mode in order to update the min-height of the editor textarea
				// codebeamer.EditorToolbars.switchMode(editor, 'markup');
				editor.$oel.css('min-height', editor.$wp.height() + 2); // but simple doing this instead of calling switchMode()
			}
		}
	}

	function _updateToolbarPositionOnEditorWidthChange($editorWrapper, editor) {
		$editorWrapper.data('width', $editorWrapper.width());

		var interval = setInterval(function() {
			if ($editorWrapper.data('editorMode') == 'wysiwyg' && $editorWrapper.is(':visible')) {
				var newWidth = $editorWrapper.width(),
					oldWidth = $editorWrapper.data('width');

				if (newWidth != oldWidth) {
					$editorWrapper.data('width', newWidth);
					var $popup = editor.popups.areVisible(); // only one popup can be visible at a time
					if ($popup && $popup.length && $popup.is('.cb-custom-popup')) {
						$popup.css('top', -1 * ($popup.height() - 10));
					}
				}
			}
		}, 250);

		editor.$oel.on('froalaEditor.destroy', function(e, editor) {
			clearInterval(interval);
		});
	}

	function _leaveOverlayEditing(e, editor) {
		beforeEditorOverlay(e, editor, 'cbOverlayEditor');
		$.FroalaEditor.COMMANDS.cbOverlayEditor.callback.call(editor);
		afterEditorOverlay(e, editor, 'cbOverlayEditor');
	}

	function uploadDialogHandler(editor, $editorWrapper) {
		if ($editorWrapper.hasClass('file-upload-after-drop')) {
			$editorWrapper.removeClass('file-upload-after-drop');
		} else {
			var $popup = editor.popups.get('file.insert');

			$popup.addClass('hide-insert-file-popup');

			$popup.find('input[type=file]').change(function () {
				$popup.removeClass('hide-insert-file-popup');
			});
			$popup.find('input[type=file]').click();
		}
	}

	function preventUploadDialog(editor, $editorWrapper) {
		$editorWrapper.on('froalaEditor.commands.before', beforeEditorOverlay);

		editor.events.on('popups.show.file.insert', function() {
			uploadDialogHandler(editor, $editorWrapper);
		});
	}
	
	function _handleContentChanged(e) {
		var $target = $(e.target),
			hasDirtyEditor = $.FE.INSTANCES.filter(function(editor) {
				return editor.$oel.hasClass('dirty');
			}).length;

		var isActionMenu = ($target[0].tagName === 'A' && $target.attr('onclick') && !$target.closest('.editor-wrapper').length && !$target.is(".collapseToggle")) &&
			($target.closest(".inlinemenu").length > 0 || $target.closest(".inlineActionMenu").length > 0 || $target.is(".actionLink"));
		if (hasDirtyEditor && isActionMenu) {
			if (confirm(i18n.message('wysiwyg.unsaved.warning.label'))) {
				$.FE.INSTANCES.forEach(function(editor) {
					editor.$oel.addClass('skip-dirty');
				});
				document.removeEventListener('click', _handleContentChanged, true);
			} else {
				e.preventDefault();
				e.stopPropagation();
			}					
		}
	}
	
	function _editorInitializedHandler($editor, $editorWrapper, editor, markupText, options, additionalOptions) {
		var $dragAndDropOverlay = $('<div class="drag-and-drop-overlay"></div>'),
			editorId = $editor.attr('id'),
			buttonsToHide = [];

		editor.$tb.on('mousedown', '#commentType', function(e) {
			e.stopImmediatePropagation();
		});

		// since the editor buttons are not specific to an editor instance but they are global buttons, if there are more editor instances in the DOM with different buttons we have to do this
		if (!additionalOptions.showSaveCancel) {
			!additionalOptions.save && buttonsToHide.push('cbSave');
			!additionalOptions.cancel && buttonsToHide.push('cbCancel');
		}

		$.each(buttonsToHide, function(i, command) {
			editor.button.getButtons('button[data-cmd="' + command + '"]').hide();
		});

		$editorWrapper.append($dragAndDropOverlay);

		$editor.closest('.description-container').trigger('cbEditorPostRender');

		// if the editor is inside a form then registering a callback for 'submit' event, and save editor before form submit
		var $form = $editor.closest('form');
		if (additionalOptions.saveOnFormSubmit && $form.length) {
			// adding the uploadConversationId to the form in a hidden input if not already added
			if ($.trim(additionalOptions.uploadConversationId).length && !$form.find('input[name="uploadConversationId"]').length) {
				$form.append($('<input>', {
					type: 'hidden',
					name: 'uploadConversationId',
					value: additionalOptions.uploadConversationId
				}));
			}

			$form.on('submit', function() {
				// checking if upload is in progress and return false if files are still being uploaded
				if (isFileUploadInProgress(editorId)) {
					showFancyAlertDialog(i18n.message('dndupload.uploadsareinprogress'));
					return false;
				}

				if (getEditorMode($editor) == 'wysiwyg') {
					codebeamer.WikiConversion.saveEditor(editorId, true);
				} else {
					$editor.removeClass('dirty');
				}
				disableDoubleSubmit($form)
			});
		}

		$editor.on('froalaEditor.commands.before', beforeEditorOverlay);

		$editor.on('froalaEditor.commands.after', afterEditorOverlay);

		// Handle save or cancel within an overlay
		$editor.on('froalaEditor.destroy', function(e, editor) {
			if ($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor)) {
				_leaveOverlayEditing(e, editor);
			}
		});

		bindFileInsertHandlers($editor);

		// avoid execution of Froala form.submit event handler...
		editor.events.on('form.submit', function() { return false; }, true);

		// adds 'dirty' class to the textarea of the editor when the editor content is changed, and avoid execution of froala's handler
		editor.events.on('contentChanged', function() {
			$editor.removeClass('skip-dirty');
			if (getEditorMode($editor) == 'wysiwyg' && editor.$el.is(':visible') && !$editor.hasClass('dirty')) {
				$editor.addClass('dirty');
				document.addEventListener('click', _handleContentChanged, true);
			}
			return false;
		}, true);
		
		$editor.on('input change', function() {
			$editor.removeClass('skip-dirty');
			if (getEditorMode($editor) == 'markup' && !$editor.hasClass('dirty')) {
				$editor.addClass('dirty');
				document.addEventListener('click', _handleContentChanged, true);
			}
		});

		// hide the intial file upload dialog, show the progress bar when the upload starts
		editor.events.on('popups.show.file.insert', function() {
			if (getEditorMode($editor) == 'markup') {
				$editor.data('selection', $editor.getSelection());
			}
			uploadDialogHandler(editor, $editorWrapper);
		});

		// Clean up artifact links, so it is possble to change them with link editor.
		editor.events.on('link.beforeInsert', function(href, text, attrs) {
			var $currentImage, $link;

			$currentImage = editor.image ? editor.image.get() : null;
			$link = editor.link.get() ? $(editor.link.get()): null;

			if (!$currentImage && $link && $link.hasClass('interwikilink')) {
				$link.removeAttr('data-targetdesc').removeAttr('data-wikilink').removeAttr('title').removeClass('interwikilink');
			}

		});

		$editor.on('froalaEditor.image.beforePasteUpload', function(e, editor) {
			codebeamer.EditorToolbars.hideOpenPopups(editor);
		});

		$editor.on('froalaEditor.paste.afterCleanup', function(e, editor, clipboard_html) {
			var $wrapper = $('<div>' + clipboard_html + '</div>'),
				$pastedImages = $wrapper.find('img');

			if ($pastedImages.length) {
				var isImagePastedWithContent = false;
				$.each($pastedImages, function() {
					var $img = $(this);
					if (!$img.data('fr-image-pasted')) {
						$img.attr('data-pasted-with-content', true); // adding special data attribute to images in pasted content
						isImagePastedWithContent = true;
					}
				});

				if (isImagePastedWithContent) {
					return $wrapper.html(); // the returned html will be inserted in the editor
				}
			}
		});

		// #1610771
		// dirty hack for "Newline characters are removed when copy pasting preformatted text | Ticket #2985"
		$editor.on('froalaEditor.paste.before', function(e, editor, originalEvent) {
			if (originalEvent.clipboardData && originalEvent.clipboardData.getData) {
				var originalGetDataFn = originalEvent.clipboardData.getData;

				originalEvent.clipboardData.getData = function(mimeType) {
					if (editor.opts.pastePlain) {
						var plainText = originalGetDataFn.call(this, 'text/plain');
						return plainText.replace(/(?:\r\n|\r|\n)/g, '<br>');
					}

					var clipboardHtml = originalGetDataFn.call(this, mimeType);

					if (clipboardHtml.indexOf('<html>') > -1) {
						clipboardHtml = clipboardHtml
						.replace('<html>', '')
						.replace('<body>', '')
						.replace('</body>', '')
						.replace('</html>', '')
					}

					return clipboardHtml;
				};
			}
		});

		editor.$box.on('click', function() {
			codebeamer.WysiwygShortcuts.setActualEditor(editor);
		});

		// it makes sense to set the just initialized editor as active editor, except it's on the right panel in doc/edit view
		if (!$form.length || $form.attr('action').indexOf('getIssueProperties') < 0) {
			codebeamer.WysiwygShortcuts.setActualEditor(editor);
		}

		editor.$oel.data('shortcutOptions', {
			saveAction: additionalOptions.save || additionalOptions.showSaveCancel ? 'command' : 'event',
			cancelAction: additionalOptions.cancel || additionalOptions.showSaveCancel ? 'cbCancel' : ''
		});
		codebeamer.WysiwygShortcuts.registerDirectShortcuts();

		// by default froala disables the toolbar when the image edit popup is shown, let's enable it
		editor.popups.onShow('image.edit', function() {
			var element, alt;

			this.toolbar.enable();

			element = editor.image.get();

			if (element && element.attr("alt")) {
				alt = element.attr("alt");
				if (alt && (alt.indexOf("MxGraph") > -1 || alt.indexOf("EMOTICON") > -1)) {
					this.popups.hide('image.edit');
					this.$wp.find('.fr-image-resizer').removeClass('fr-active');
				}
			}

		});

		editor.popups.onShow('link.edit', function() {
			var $link = $(editor.link.get()),
				$popup = editor.popups.get('link.edit'),
				toggleFn = $link.length && $link.attr('href').indexOf('CB:/') == 0 ? 'hide' : 'show';

			if ($popup && $popup.length) {
				$popup.find('.fr-command[data-cmd="linkOpen"]')[toggleFn]();
			}
		});

		editor.$el.on("dblclick", "img", function(event) {
			var alt;

			if (event.target.hasAttribute("alt")) {
				alt = event.target.getAttribute("alt");
				if (alt && alt.indexOf("MxGraph") > -1) {
					editor.mxgraph.showModal(event.target);
				}
			}

		});

		if ($.trim(additionalOptions.uploadConversationId).length) {
			initDragAndDrop($editorWrapper, editor, $dragAndDropOverlay);
		}

		if (additionalOptions.useAutoResize && !additionalOptions.resizeEditorToFillParent) {
			$editor.data('useAutoSize', true);
			setTimeout(function() {
				$editor.autosize();
			}, isChrome() ? 1 : 500);
		}

		// adds event handlers to hide the other toolbar popups when showing a toolbar popup
		codebeamer.EditorToolbars.initHidingEditorPopups(editor);

		// in the $.FE.MODULES.core._init() function the Froala updates the value of the editor textarea with the content of the editor,
		// we revert it here to the original wiki markup... It's important if the default mode is 'markup'.
		$editor.val(editor._original_html);

		var $formatTypeInput = $editorWrapper.find('input[type=hidden]'),
			editorMode = additionalOptions.mode || 'wysiwyg',
			editorFormat = additionalOptions.hasOwnProperty('editorFormat')
				? additionalOptions.editorFormat
				: ($formatTypeInput.length ? $formatTypeInput.val() : 'W');

		$editorWrapper.data('defaultEditorMode', editorMode);

		if (editorFormat == 'W') {
			// inits the selected editor mode
			codebeamer.EditorToolbars.switchMode(editor, editorMode);
		} else {
			// inits the selected editor format if it's other than wiki
			editorMode = 'markup'; // if editor format is not W then the mode is 'markup'!
			codebeamer.EditorToolbars.updateToolbarForEditorFormat(editor,
				codebeamer.EditorToolbars.formatMapping[editorFormat],
				additionalOptions.extraButtons);
		}

		// Saving the old wiki markup and setting it into the editor after the html conversion
		$editor.data('oldMarkup', markupText);

		if (editorMode != 'markup') {
			toggleConversionInProgress($editor, true);
			codebeamer.WikiConversion.wikiToHtml(markupText, editorId)
				.then(function(result) {
					$editor.froalaEditor('html.set', result.content);
				})
				.always(function() {
					toggleConversionInProgress($editor, false);
					editor.opts.tollbarSticky &&  editor.position.refresh();
					if (window.localStorage.wysiwygFormattingOptionsVisible == 'true' && !additionalOptions.readonly && !additionalOptions.disableFormattingOptionsOpening) {
						setTimeout(function() {
							if ($editorWrapper.is(':visible')) {
								var $focused = $(':focus');
								editor.commands.exec('cbFormattingOptions');
								$focused.focus();
							}
						}, window.parent != window ? 900 : 500);
					}
					$editor.trigger('froalaEditor.CB.contentInitialized', [editor]);
				});
		} else {
			// in markup mode we apply the min height for the textarea if specified
			if (options.heightMin) {
				$editor.css('min-height', options.heightMin + 2);
			}
		}

		// allowing <tt> tags for monospaced text
		editor.opts.htmlAllowedTags.add('tt');

		// editor toolbar is in a container in document view, we make the toolbar of the 'active' editor visible
		if (editor.opts.toolbarContainer) {
			var handlerFn = _setToolbarVisible.bind(null, $(editor.opts.toolbarContainer), editor);

			handlerFn();

			$editorWrapper.on('click', handlerFn);
		} else {
			// if the editor toolbar is not in a container then we start watching the width of the editor in order to refresh toolbar positions
			_updateToolbarPositionOnEditorWidthChange($editorWrapper, editor);
		}

		if (additionalOptions.resizeEditorToFillParent) {
			editor.$oel.data('resizeEditorToFillParent', true);
			editor.$box.addClass('offscreen');
			setTimeout(resizeEditorToFillParent.bind(null, editor), 400);
		}

		// updates sticky element positions (shows the toolbar by default)
		setTimeout(editor.position.refresh, 500);

		// a custom event which can be triggered on the body to make the editor refresh the sticky positions (toolbar)
		$('body').on('cbRefreshEditorPositions', editor.position.refresh);

		if (additionalOptions.focus) {
			var timeout = $editor.data('inline') ? 100 : 500;
			if (editorMode == 'wysiwyg') {
				setTimeout(function() { editor.events.focus(); }, timeout);
			} else {
				// use timeout even when the editor mode is markup because in an overlay it will take a few milliseconds
				// for the textarea to appear
                setTimeout(function() { $editor.focus(); }, timeout);
			}
		}

		editor.events.on('url.linked', function(anchor) {
			var $anchor = $(anchor),
				href = $anchor.attr('href');

			if (href && href.length && href.match("^\/\/")) {
				// fixing missing protocol
				$anchor.attr('href', 'http:' + $anchor.attr('href'));
			}
		});

		if (editor.opts.height || additionalOptions.resizeEditorToFillParent) { // if the editor has fix height
			$editor.on('froalaEditor.keydown', function(e, editor, keydownEvent) {
				if (keydownEvent.keyCode == $.FE.KEYCODE.ENTER) {
					// we don't let the last line hidden by a subtoolbar
					var element = editor.selection.element();
					if (element && element.getBoundingClientRect &&
							(editor.$tb[0].getBoundingClientRect().top - element.getBoundingClientRect().top < 30)) {
						editor.$wp.scrollTop(editor.$wp[0].scrollHeight);
					}
				}
			});
		}

		if (additionalOptions.readonly) {
			var readOnlyButtons = ['cbSave', 'cbCancel'];
			editor.$oel.attr('readonly', true);
			editor.$el.css({'pointer-events': 'none'});
			editor.button.getButtons('*').each(function() {
				var $button = $(this);

				$button[readOnlyButtons.indexOf($button.data('cmd')) > -1 ? 'show' : 'hide']();
			});
		}
	}

	function initEditor(editorId, editorOptions, additionalOptions, isInline) {
		var $editor = $('#' + editorId),
			$editorWrapper = $editor.closest('.editor-wrapper'),
			markupText = $editor.val();

		overrideFroalaFunctions();

		additionalOptions = additionalOptions || {};

		if (additionalOptions.hasOwnProperty('getMarkup') && additionalOptions.getMarkup) {
			markupText = additionalOptions.getMarkup.call();
			$editor.val(markupText);
		}

		if (isInline) {
			var $froalaOptions = $('#froalaOptions');
			if ($froalaOptions.length) {
				editorOptions.pastePlain = $froalaOptions.attr('data-pasteplain') == 'true';
				additionalOptions.mode = $froalaOptions.attr('data-mode');
			} else {
				console.warn('Inline Froala editor created without necessary froala options in the dom!');
			}
			$editor.data('inline', true);
		}

		initSaveCancelIcons();
		codebeamer.EditorToolbars.initToolbarsAndButtons();

		var buttons = codebeamer.EditorToolbars.getMainToolbarButtons();
		if (additionalOptions.cancel) {
			_createCancelButton(additionalOptions.cancel);
			buttons.unshift('cbCancel');
		} else {
			$editor.on('wysiwyg:cancel', function() {
				// cancel the closest form
				var $form = $editor.closest('form').not('#browseTrackerForm');
				if ($form.length) {
					var editor = getEditorInstance(editorId);

					if ($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor)) {
						_leaveOverlayEditing(undefined, editor);
					}

					var $cancelBtn = $form.find('.cancelButton');

					if ($cancelBtn.length) {
						$($cancelBtn.get(0)).click();
					}
				}
			});
		}

		if (additionalOptions.save) {
			_createSaveButton(additionalOptions.save);
			buttons.unshift('cbSave');
			codebeamer.WysiwygShortcuts.registerSaveButtonShortcut();
		} else {
			_createSaveEventCommand();
			buttons.push('cbSaveEvent');
			codebeamer.WysiwygShortcuts.registerSaveEventShortcut();

			$editor.on('wysiwyg:save', function() {
				// submit the closest form
				var $form = $editor.closest('form').not('#browseTrackerForm');
				if ($form.length) {
					var editor = getEditorInstance(editorId);

					if ($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor)) {
						_leaveOverlayEditing(undefined, editor);
					}

					// in document view right panel
					if ($form.attr('action').indexOf('getIssueProperties') != -1) {
						$.isFunction(saveIssueProperties) && saveIssueProperties();
					} else {
						var $saveBtn = $form.find('input[type=submit].button');

						if ($saveBtn.length) {
							$($saveBtn.get(0)).click();
						}
					}
				}
			});
		}

		if (additionalOptions.showSaveCancel) {
			_createCancelButton(additionalOptions.cancel || $.noop);
			buttons.unshift('cbCancel');
			_createSaveButton(additionalOptions.save || $.noop);
			buttons.unshift('cbSave');
			codebeamer.WysiwygShortcuts.registerSaveButtonShortcut();
		}

		$editor.data('useFormatSelector', additionalOptions.useFormatSelector);

		// Init froala with the options
		var options = getDefaultEditorOptions(buttons);
		$.extend(options, editorOptions);

		if (additionalOptions.hasOwnProperty('overlayHeader') && additionalOptions.overlayHeader) {
			$.extend(options, {
				overlayHeader: additionalOptions.overlayHeader
			});
		} else {
			$.extend(options, {
				overlayHeader: i18n.message('wysiwyg.default.overlay.header')
			});
		}

		if ($.trim(additionalOptions.uploadConversationId).length) {
			_extendOptionsWithUploadOptions(options, additionalOptions.uploadConversationId);
			$editor.data('uploadConversationId', additionalOptions.uploadConversationId);
			codebeamer.EditorFileList.init($editor, additionalOptions.ignorePreviouslyUploadedFiles);
		} else {
			// if uploadConversationId parameter is not used then remove the insert file button
			_removeButton(options.toolbarButtons, 'insertFile');
			options.fileUpload = false;
			options.imageUpload = false;
			options.videoUpload = false;
			options.imagePaste = false;
			var quickInsertImageIndex = options.quickInsertButtons.indexOf("image");
			if (quickInsertImageIndex > -1) {
				options.quickInsertButtons.splice(quickInsertImageIndex, 1);
			}
		}

		// the overlay button should not be displayed if we are already in an iframe (overlay)
		if (window.parent != window || additionalOptions.hideOverlayEditor) {
			_removeButton(options.toolbarButtons, 'cbOverlayEditor');
		}

		if (additionalOptions.insertNonImageAttachments) {
			$editor.data('insertNonImageAttachments', true);
		}

		// the default for this became true in #1852045
		if (!additionalOptions.hasOwnProperty('disableFormattingOptionsOpening')) {
			$editor.data('disableFormattingOptionsOpening', true);
		} else {
			$editor.data('disableFormattingOptionsOpening', additionalOptions.disableFormattingOptionsOpening);
		}
		
		if ($editor.data('disableFormattingOptionsOpening')) {
			window.localStorage.wysiwygFormattingOptionsVisible = false;
		}

		if (additionalOptions.hideUndoRedo) {
			$editor.data('hideUndoRedo', true);
		}

		if (additionalOptions.hideQuickInsert) {
			$editorWrapper.addClass('hide-quick-insert');
		}

		if (additionalOptions.disablePreview) {
			_removeButton(options.toolbarButtons, 'cbPreview');
			$editor.data('disablePreview', true);
		}

		if (additionalOptions.allowTestParameters) {
			$editor.data('allowTestParameters', true);
		}

		// if the editor textarea is disabled then we set the editor to readonly mode
		if ($editor.is(':disabled')) {
			additionalOptions.readonly = true;
		}

		$editor.on('froalaEditor.initialized', function(event, editor) {
			_editorInitializedHandler($editor, $editorWrapper, editor, markupText, options, additionalOptions);
		});

		$editor.froalaEditor(options);
	}

	function _isEmptyFileInUploads(uploads) {
		// TODO: review the below after parallel file upload is supported by Froala
		return uploads.length && !uploads[0].size;
	}
	function bindFileInsertHandlers($context) {
		$context.on('froalaEditor.image.inserted', _handleImageInsert);

		// update wiki markup of the inserted file in both wysiwyg and markup modes
		$context.on('froalaEditor.file.inserted', _handleFileInsert);

		$context.on('froalaEditor.image.beforeUpload', function(e, editor, images) {
			if (_isEmptyFileInUploads(images)) {
				editor.popups.hide('image.insert');
				showFancyAlertDialog(i18n.message('wysiwyg.fileupload.empty.file.error'));
				return false;
			}
		});

		$context.on('froalaEditor.file.beforeUpload', function(e, editor, files) {
			var $popup = editor.popups.get('file.insert');

			if (_isEmptyFileInUploads(files)) {
				editor.popups.hide('file.insert');
				showFancyAlertDialog(i18n.message('wysiwyg.fileupload.empty.file.error'));
				return false;
			}
			editor.edit.off();

			if ($popup && $popup.length && !$popup.data('cbEscHandlerAdded')) {
				editor.events.$on($popup.children().not('.fr-buttons'), 'keydown', '[tabIndex]', function(e) {
					if (e.which == $.FE.KEYCODE.ESC) {
						editor.edit.on();
					}
				}, true);
				$popup.data('cbEscHandlerAdded', true);
			}
		});

		$context.on('froalaEditor.file.uploaded', function(e, editor, response) {
			editor.edit.on();
		});

		$context.each(function() {
			var editor = getEditorInstance($(this).attr('id'));

			if (editor) {
				editor.events.on('image.error file.error', function(error, response) {
					var errorMessage = '';
					if (response) {
						try {
							errorMessage = JSON.parse(response).error;
						} catch(e) {
							console.warn('Failed to parse server response to get proper error message!', e);
						}
					}

					if (!errorMessage && error && error.message) {
						errorMessage = error.message; // using the error message of Froala
					}

					if (errorMessage) {
						editor.popups.hideAll();
						showFancyAlertDialog(errorMessage);
					}

					return false;
				});
			}
		});
	}

	/**
	 * Disables or enables the editing in Froala
	 * @param $element The froala element div
	 * @param isEditable If true then the editor is editable
	 */
	function toggleEditing($element, isEditable) {
		$element.attr('contenteditable', isEditable);
	}

	function createInlineEditorTextarea(content) {
		return $('<textarea>', {
			id: 'editorTA-' + newEditorId++
		}).html(content);
	}

	function toggleConversionInProgress($editor, isInProgress) {
		var toggleFn = isInProgress ? 'addClass' : 'removeClass',
			editor = getEditorInstance($editor.attr('id'));

		editor.edit[isInProgress ? 'off' : 'on']();
		$editor.closest('.editor-wrapper')[toggleFn]('loadingInProgress');
		$editor.trigger(isInProgress ? 'cbConversionStart' : 'cbConversionEnd');
	}

	function getEditorMode($editor) {
		return $editor.closest('.editor-wrapper').data('editorMode');
	}

	function getDefaultEditorMode($editor) {
		return $editor.closest('.editor-wrapper').data('defaultEditorMode');
	}

	function setDefaultEditorMode($editor, callback) {
		var mode = getEditorMode($editor),
			modeText = i18n.message('wysiwyg.compact.layout.' + mode + '.tooltip');

		$editor.closest('.editor-wrapper').data('defaultEditorMode', mode);
		
		showFancyConfirmDialogWithCallbacks(i18n.message('wiki.wysiwyg.set.default.mode', modeText), function() {
			$.ajax({
				type: 'post',
				url: contextPath + '/wysiwyg/setDefaultEditingMode.spr?mode=' + mode,
				dataType: 'json',
				success: function(data_) {
					if (data_.success == true) {
						console.log('Default editor mode set to ' + mode);
					} else {
						console.log('Failed to set editor mode!');
					}

					if (callback) {
						callback(mode);
					}
				},
				error: function(jqXHR, textStatus, errorThrown) {
					var errmsg = i18n.message('wiki.wysiwyg.failed.to.set.default.mode', textStatus);
					alert(errmsg);
					console.log(errmsg);
				}
			});
		});
	}

	function updateInlineOptions(options) {
		var $froalaOptions = $('#froalaOptions');

		if ($froalaOptions.length) {
			$.each(options, function(key, value) {
				$froalaOptions.attr('data-' + key, value);
			});
		}
	}

	function isFileUploadInProgress(editorId) {
		var editor = getEditorInstance(editorId);

		return editor.popups.isVisible('image.insert') || editor.popups.isVisible('file.insert');
	}

	function clearEditor(editorId) {
		var editor = getEditorInstance(editorId);
		editor.html.set('');
		editor.$oel.val('');
		editor.$oel.data('oldMarkup', '');
		editor.$oel.removeClass('dirty');

		codebeamer.EditorFileList.clearList(editor.$oel);

		if ($.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor)) {
			_leaveOverlayEditing(undefined, editor);
		}
		editor.events.trigger('blur');
	}

	// destroys the editor instance, cleans up the DOM and saves the markup in the textarea if needed
	function destroyEditor($editor, doSave, isSynchronous, ignoreEditorDestroyedEvent) {
		var promise = $.when();

		if ($editor.length) {
			if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg' && doSave) {
				promise = codebeamer.WikiConversion.saveEditor($editor, isSynchronous);
			}

			return promise.then(function() {
				var markup = $editor.val(),
					editor = getEditorInstance($editor.attr('id'));

				editor && editor.destroy();

				$editor
					.val(markup) // the destroy function updates the value of the textarea so we have to set our "saved" markup
					.unwrap()
					.siblings('.upload-overlay, .drag-and-drop-overlay').remove();

				if (!ignoreEditorDestroyedEvent) {
					$editor.trigger('cbEditorDestroyed');
				}
				$editor.off('wysiwyg:save');
			});
		}

		return promise;
	}

	function isMac() {
		if (isMacOs === undefined) {
			isMacOs = navigator.platform.toUpperCase().indexOf('MAC') >= 0;
		}
		return isMacOs;
	}

	function isIE() {
		if (isInIE === undefined) {
			isInIE = $('body').hasClass('IE');
		}
		return isInIE;
	}

	function isChrome() {
		if (isInChrome === undefined) {
			isInChrome = $('body').hasClass('Chrome');
		}
		return isInChrome;
	}

	function isEditorInDom(editor) {
		try {
			var editorId = editor && editor.$oel ? editor.$oel.attr('id') : '';

			return editorId.length && $.FroalaEditor && $.FroalaEditor.INSTANCES.map(function(instance) {
				return instance.$oel.attr('id');
			}).indexOf(editorId) > -1;
		} catch(e) {
			return false;
		}
	}
	return {
		getEditorInstance: getEditorInstance,
		initEditor: initEditor,
		createInlineEditorTextarea: createInlineEditorTextarea,
		toggleEditing: toggleEditing,
		toggleConversionInProgress: toggleConversionInProgress,
		getEditorMode: getEditorMode,
		getDefaultEditorMode: getDefaultEditorMode,
		setDefaultEditorMode: setDefaultEditorMode,
		updateInlineOptions: updateInlineOptions,
		bindFileInsertHandlers: bindFileInsertHandlers,
		isFileUploadInProgress: isFileUploadInProgress,
		clearEditor: clearEditor,
		getDefaultEditorOptions: getDefaultEditorOptions,
		removeElementFromEditor: removeElementFromEditor,
		resizeEditorToFillParent: resizeEditorToFillParent,
		isMac: isMac,
		isIE: isIE,
		isChrome: isChrome,
		initDragAndDrop: initDragAndDrop,
		_createSaveButton: _createSaveButton,
		overrideFroalaFunctions: overrideFroalaFunctions,
		preventUploadDialog: preventUploadDialog,
		destroyEditor: destroyEditor,
		isEditorInDom: isEditorInDom
	}
})(jQuery);