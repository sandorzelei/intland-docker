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

// custom error for handling already attached files
codebeamer.FileAlreadyAttachedError = codebeamer.FileAlreadyAttachedError || function(message) {
	this.name = 'FileAlreadyAttachedError';
    this.message = message || '';
};
codebeamer.FileAlreadyAttachedError.prototype = Error.prototype;

codebeamer.EditorFileList = codebeamer.EditorFileList || (function($) {

	function init($editor, ignorePreviouslyUploadedFiles) {
		var $editorWrapper = $editor.closest('.editor-wrapper');

		var $uploadOverlay = $('<div>', {
			'class': 'upload-overlay'
		});

		$uploadOverlay
			.append($('<ul>', {	'class': 'file-list' }))
			.append($('<span>', { 'class': 'upload-summary'	}));

		$editorWrapper.append($uploadOverlay);

		$uploadOverlay.on('click', '.file-list .fileremove', function(e) {
			var $item = $(e.currentTarget).parent();

			removeFile($editor, $item.data('fileName'));
		});

		$uploadOverlay.hover(function() {
			$uploadOverlay
				.removeAttr('style')
				.addClass('show-file-list');
		}, function() {
			$uploadOverlay.css('opacity', '0.5');
			setTimeout(function() {
				if (!$uploadOverlay.is(':hover')) {
					$uploadOverlay.removeClass('show-file-list');
				}
			}, 500);
		});

		if (!ignorePreviouslyUploadedFiles) {
			_initConversation($editor);
		}
	}

	function addFile($editor, name, size) {
		var $uploadOverlay = $editor.closest('.editor-wrapper').find('.upload-overlay'),
			$fileList = $uploadOverlay.find('ul.file-list'),
			$uploadSummary = $uploadOverlay.find('span.upload-summary');

		if (_isFileAlreadyAdded($fileList, name)) {
			throw new codebeamer.FileAlreadyAttachedError(i18n.message('dndupload.file.with.name.already.attached.error', escapeHtml(name)));
		} else {
			var $item = $('<li>')
				.append('<span class="filename">' + escapeHtml(_formatFileName(name)) + '</span>')
				.append('<span class="filesize">' + _formatSize(size) + '</span>')
				.append('<span class="fileremove"></span>');

			$fileList.append($item);
			$item.data('fileName', name);
			_updateUploadSummary($uploadSummary, $fileList);
			$uploadOverlay.addClass('has-files show-file-list');
		}
	}

	function removeFile($editor, name) {
		var $uploadOverlay = $editor.closest('.editor-wrapper').find('.upload-overlay'),
			$fileList = $uploadOverlay.find('ul.file-list'),
			$uploadSummary = $uploadOverlay.find('span.upload-summary');

		return _removeFileFromServer(name, $editor.data('uploadConversationId')).then(function() {
			// file is successfully removed from server
			$fileList.find('li').each(function() {
				var $item = $(this);
				if ($item.data('fileName') == name) {
					$item.remove();
				}
			});

			setTimeout(function() {
				if (!$uploadOverlay.is(':hover')) {
					$uploadOverlay.removeClass('show-file-list');
				}
			}, 500);

			_updateUploadSummary($uploadSummary, $fileList);
			_removeFileOrImageContent($editor, name);
		}, function() {
			// failed to remove the file
			showFancyAlertDialog(i18n.message('dndupload.file.remove.failed', escapeHtml(name)));
		});
	}

	function hasFiles($editor) {
		return $editor.closest('.editor-wrapper').find('.upload-overlay').hasClass('has-files');
	}

	function removeAllFiles($editor) {
		var $uploadOverlay = $editor.closest('.editor-wrapper').find('.upload-overlay'),
			$fileList = $uploadOverlay.find('ul.file-list'),
			promise = $.when();

		$fileList.find('li').each(function() {
			var $item = $(this);

			promise = promise.then(function() {
				return removeFile($editor, $item.data('fileName'));
			});
		});

		return promise;
	}

	function _removeFileFromServer(fileName, conversationId) {
		if (!$.trim(fileName).length) {
			return $.when();
		}

		return $.ajax({
			url: contextPath + '/dndupload/removeFile.spr?conversationId=' + conversationId,
			data: { fileName: encodeURIComponent(fileName) },
			cache: false
		});
	}

	function _removeFileOrImageContent($editor, name) {
		try {
			// remove markup from the wysiwyg editor which represents the image file
			var imageWikiMarkup = '[!' + name + '!]';

			// try to remove the image from editor
			if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
				$editor.siblings('.fr-box').find('.fr-view a, .fr-view img').each(function() {
					var $element = $(this);

					if ($element.text() == name || $element.data('filename') == name) {
						codebeamer.WYSIWYG.removeElementFromEditor($element);

						$editor.addClass('dirty');
					}
				});
			} else {
				// remove image file markups from textarea
				var content = $editor.val();

				content = content.replace(imageWikiMarkup, '');

				// remove other file markups from textarea if non image file insert is enabled
				if ($editor.data('insertNonImageAttachments')) {
					var encodedName = encodeURIComponent(name),
						fileWikiMarkup = '[' + name + '|' + 'CB:/displayDocument/' + encodedName + '?doc_id=' + encodedName + ']';
					content = content.replace(fileWikiMarkup, '');
				}

				$editor.val(content);
			}
		} catch(e) {
			console.log(e.message);
		}
	}

	function _updateUploadSummary($uploadSummary, $fileList) {
		var count = $fileList.find('li').length,
			text = count ? count + ' file(s)...' : '';

		$uploadSummary.text(text);

		if (!count) {
			$uploadSummary.parent().removeClass('has-files');
		}
	}

	function _isFileAlreadyAdded($fileList, name) {
		var result = false;
		$fileList.find('li').each(function() {
			var $item = $(this);

			if ($item.data('fileName') == name) {
				result = true;
			}
		});

		return result;
	}

	function _formatFileName(name){
		if (name.length > 33){
			name = name.slice(0, 19) + '...' + name.slice(-13);
		}
		return name;
	}

	function _formatSize(bytes){
		var i = -1;
		do {
			bytes = bytes / 1024;
			i++;
		} while (bytes > 99);

		return Math.max(bytes, 0.1).toFixed(1) + ['kB', 'MB', 'GB', 'TB', 'PB', 'EB'][i];
	}

	function _initConversation($editor) {
		var conversationId = $editor.data('uploadConversationId'),
			url = contextPath + '/dndupload/getPreviouslyUploadedFiles.spr?conversationId=' + conversationId;

		$.ajax({
			url: url,
			dataType: 'json',
			success: function(data) {
				$.each(data, function(index, item) {
					addFile($editor, item.fileName, item.size)
				});
			},
			error: function(xhr, textStatus, errorThrown) {
				console.log('error loading previously uploaded files, conversationId=' + conversationId + ', error:' + textStatus);
			}
		});
	}

	function clearList($editor) {
		var $uploadOverlay = $editor.closest('.editor-wrapper').find('.upload-overlay'),
			$fileList = $uploadOverlay.find('ul.file-list'),
			$uploadSummary = $uploadOverlay.find('span.upload-summary');

		$fileList.empty();

		_updateUploadSummary($uploadSummary, $fileList);
	}

	return {
		init: init,
		addFile: addFile,
		removeFile: removeFile,
		removeAllFiles: removeAllFiles,
		hasFiles: hasFiles,
		clearList: clearList
	}
})(jQuery);