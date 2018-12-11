
$(document).ready(function() {

	var currentlySelectedNode, editorId, editor, modalId;

	function getContainerPluginSourceBlock(selectedNode) {
		return $(selectedNode).closest('.pluginSource');
	}

	function onInsertMarkupClick() {
		var selectedNode, wikiText;

		wikiText = $('textarea[name=wikiMarkup]').val();

		try {
			if (wikiText) {
				var style = $("#style select").val();

				if (style) {	// add the info/warn/error decoration
					var prefix = "%%" + style +"\n";
					var postfix = "%!\n";

					if (style === "preformatted") {
						prefix = "{{{\n";
						postfix = "}}}\n";
					}

					if ($.trim(wikiText).indexOf($.trim(prefix)) == 0) {
						console.log("Already has " + style + " style, don't add again!");
					} else {
						wikiText = prefix + wikiText + postfix;
					}
				}

				var wikiAsHtml = codebeamer.WikiConversion.escapeWikiToHtml(wikiText);

				if (wikiAsHtml) {
					selectedNode = $(editor.$oel.froalaEditor("selection.element"));

					var $pluginSource = getContainerPluginSourceBlock(selectedNode);
					if ($pluginSource && $pluginSource.length > 0) {
						$pluginSource.replaceWith(wikiAsHtml);
					} else {
						editor.$oel.froalaEditor("html.insert", wikiAsHtml, true);
					}
				}
				editor.$oel.addClass('dirty');
				editor.modals.hide(modalId);
			}
		} catch(ex) {
			console.log("Failed to insert markup:" + wikiText, ex);
			editor.modals.hide(modalId);
		}
	}

	function onCancelButtonClick() {
		editor.modals.hide(modalId);
	}

	function initModal(editor) {
		currentlySelectedNode = $(editor.$oel.froalaEditor("selection.element"));

		var $pluginSource = getContainerPluginSourceBlock(currentlySelectedNode);

		if ($pluginSource && $pluginSource.length > 0) {
			try {
				var html = $pluginSource.outerHTML();
				// unescape: convert back the html which contains escaped wiki markup to the wiki markup
				// simply calling the html->wiki conversion will do this for us
				var promise = codebeamer.WikiConversion.htmlToWiki(html, editorId, true);

				var wikiMarkup = '';
				promise.done(function(data) {
					if (data && data.hasOwnProperty("content")) {
						wikiMarkup = data.content;
					}
				});

				$('textarea[name=wikiMarkup]').val(wikiMarkup);
			} catch (ex) {
				console.log("Failed to get existing markup:" + ex);
			}
		}

		$('.actionBar input[name=insertMarkupButton]').click(onInsertMarkupClick);

		$('.cancelButton').click(onCancelButtonClick);

		// Timeout is required to focus reliably in IE browsers
		setTimeout(function() {
			$('textarea[name=wikiMarkup]').focus();
		}, 100);
	}

    modalId = window.frameElement.getAttribute("data-modal-id");
	editorId = window.frameElement.getAttribute("data-editor-id");
	editor = parent.codebeamer.WYSIWYG.getEditorInstance(editorId);

	initModal(editor);
});