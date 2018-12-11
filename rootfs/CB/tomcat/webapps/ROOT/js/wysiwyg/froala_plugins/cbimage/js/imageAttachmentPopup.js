$(document).ready(function() {
	var editorId, editor, modalId;

	function insertAttachedImage(imageName, baseUrl) {
		var linkUrl = baseUrl + '&fileName=' + imageName;

		var link = '<img alt="ALT_WIKI:' + escape('[!') + imageName + escape('!]') + '" src="' + linkUrl + '" />';

		editor.$oel.froalaEditor("html.insert", link, true);
	}

	function insertAttachedImages() {
		$("[name='selectedImage']:checked").each(function() {
			var imageName, baseUrl;

			imageName =  $(this).val();
			baseUrl = $(this).data("base-url");

			insertAttachedImage(imageName, baseUrl);
		});
	}

	function closeModal() {
		editor.$oel.addClass('dirty');
		editor.modals.hide(modalId);
	}

	function onCancelButtonClick() {
		editor.modals.hide(modalId);
	}

	function onInsertImageClick() {
		insertAttachedImages();
		closeModal();
	}

	function onSingleImageInserted(event) {
		var imageName, baseUrl;

		imageName = $(event.currentTarget).data("file-name");
		baseUrl = $(event.currentTarget).data("base-url");

		insertAttachedImage(imageName, baseUrl);
		closeModal();
	}

	function initModal(editor) {
		$('.actionBar input[name=insertImagesButton]').click(onInsertImageClick);

		$('.cancelButton').click(onCancelButtonClick);

		$('.attachmentImage').click(onSingleImageInserted);
	}

    modalId = window.frameElement.getAttribute("data-modal-id");
	editorId = window.frameElement.getAttribute("data-editor-id");
	editor = parent.codebeamer.WYSIWYG.getEditorInstance(editorId);

	initModal(editor);
});
