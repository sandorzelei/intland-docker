$(document).ready(function() {

	var editorId, editor, modalId;

	function onFilterKeyUp(event) {
		var filterTextField, filterValue;

		filterTextField = event.currentTarget;
		filterValue = $.trim(filterTextField.value).toLocaleLowerCase();

		if (filterValue.length >= 2) {
			$('#wikiHistoryLinkTable .filterable').each(function(index, item) {
				var $item, text;

				$item = $(item);
				text = $item.text().toLocaleLowerCase();

				var show = (text.indexOf(filterValue) != -1);
				$item.closest('tr').toggle(show);
			});
		} else {
			$('tbody tr').show();
		}
		event.stopPropagation();
	}

	function onTableRowClick(event) {
		var trElement, radioButtonElement;

		trElement = $(event.currentTarget);
		radioButtonElement = trElement.find('input[type=radio]');
		$(radioButtonElement).prop('checked', true);
	}

	function onTableRowDoubleClick(event) {
		onTableRowClick(event);
		onInsertHistoryLinkButtonClick();
	}

	function hash(str) {
		var hash = 0,
		strlen = str.length, i, c;
		if ( strlen === 0 ) {
			return hash;
		}
		for ( i = 0; i < strlen; i++ ) {
			c = str.charCodeAt( i );
			hash = ((hash << 5) - hash) + c;
			hash = hash & hash; // Convert to 32bit integer
		}
		return hash;
	}

	function onInsertHistoryLinkButtonClick() {
		var selectedRadioButtons, siblingLink, wikiLinkHtml;

		if ($("#searchTab-tab").hasClass("ditch-focused")) {
			selectedRadioButtons = $('input[name=searchItem]:checked');
			if (selectedRadioButtons.length > 0) {
				siblingLink = selectedRadioButtons.closest('tr').find('input');
				var id = $(siblingLink[0]).val().trim();
				id = id.substring(id.indexOf('-') + 1);
				$.post(contextPath + "/mxGraph/exportById.spr", { artifactId: id}).done(function( data ) {
					pngImage = data;

					var wikiAsHtml = "<img class='mxGraph' border='0' src='data:image/png;base64," + pngImage + "' alt='ALT_WIKI:MxGraph;" + btoa("[{MxGraph artifactId='" + id + "' format='image'}]") + "' data-image-hash='" + hash(pngImage) + "'/>";
					editor.$oel.froalaEditor("html.insert", wikiAsHtml, true);
					editor.$oel.addClass('dirty');
					editor.modals.hide(modalId);
				}).fail(function(response) {
					showFancyAlertDialog(i18n.message("mxgraph.editor.wrong.format"), null, "200px");
				});
			}

		} else {

			try {
				selectedRadioButtons = $('#wikiLinkHistoryTabPane input[type=radio]:checked');
				if (selectedRadioButtons.length > 0) {
					siblingLink = selectedRadioButtons.closest('tr').find('a');
					var id = $(siblingLink[0]).text().trim();
					id = id.substring(id.indexOf('-') + 1, id.indexOf(']'));
					$.post(contextPath + "/mxGraph/exportById.spr", { artifactId: id}).done(function( data ) {
						pngImage = data;

						var wikiAsHtml = "<img class='mxGraph' border='0' src='data:image/png;base64," + pngImage + "' alt='ALT_WIKI:MxGraph;" + btoa("[{MxGraph artifactId='" + id + "' format='image'}]") + "' data-image-hash='" + hash(pngImage) + "'/>";
						editor.$oel.froalaEditor("html.insert", wikiAsHtml, true);
						editor.$oel.addClass('dirty');
						editor.modals.hide(modalId);
					}).fail(function(response) {
						showFancyAlertDialog(i18n.message("mxgraph.editor.wrong.format"), null, "200px");
					});
				}
			} catch(ex) {
				console.log("Error:" + ex);
				editor.modals.hide(modalId);
			}
		}
	}

	function onWikiLinkClick(event) {
		event.preventDefault();
	}

	function onFilterableClick(index, item) {
		var $item, text;

		$item = $(item);
		text = $item.text().toLocaleLowerCase();

		if (!text.endsWith(".cbmxml")) {
			$item.closest('tr').remove();
		}
	}

	function onDocumentLinkClick() {
		// modify click on name
		$(this).click(onWikiLinkClick);
		// modify click on icon
		$(this).prev().click(onWikiLinkClick);
	}

	function onDocumentMiscLinkClick() {
		if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
			this.setAttribute("target", "_blank");
		}
	}

	function onCancelButtonClick() {
		editor.modals.hide(modalId);
	}

	function initModal(editor) {

		$('#linkFilter').keyup(onFilterKeyUp);

		$('#wikiHistoryLinkTable tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);

		$('#wikiHistoryLinkTable tbody a').click(onWikiLinkClick);

		$('#searchDocumentItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);

		$('#searchDocumentItem a.documentLink').each(onDocumentLinkClick);

		$('#wikiHistoryLinkTable .filterable').each(onFilterableClick);

		$('.actionBar input[name=insert]').click(function() {
			onInsertHistoryLinkButtonClick();
		});
		$('.cancelButton').click(onCancelButtonClick);

		// find anchors and add target to open pages on new tab (not in this iframe) except where links set the parent href (for ex.: properties menu item)
		$("#searchDocumentItem").find("a").each(onDocumentMiscLinkClick);
	}


    modalId = window.frameElement.getAttribute("data-modal-id");
	editorId = window.frameElement.getAttribute("data-editor-id");
	editor = parent.codebeamer.WYSIWYG.getEditorInstance(editorId);

	initModal(editor);
});