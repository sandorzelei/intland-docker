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
 * Javascript for editing wikis in an overlay
 */
var wikiEditorOverlay = wikiEditorOverlay || {

	// the reference to the field's container being edited
	editWikiInOverlayContainer: null,

	initialized: false,

	// initialize on page load
	init: function() {
		if (this.initialized) {
			return ;
		}

		this.initialized = true;

		var editClicked = function() {
			wikiEditorOverlay.edit(this);
		};

		$(document)
			.off("click", ".editWikiInOverlayContainer", editClicked)	//first call off to avoid multiple event calls
			.on("click", ".editWikiInOverlayContainer", editClicked);

	},


	edit: function(editWikiInOverlayContainer) {
		var $field = $(editWikiInOverlayContainer);
		wikiEditorOverlay.editWikiInOverlayContainer = $field;
		if ($field.length == 0) {
			return;
		}

		var url = contextPath + "/menu/wikiEditorOverlay.jsp";
		// find title on the field or its parents
		var	title = $field.closest("[title]").attr("title");
		if (title == null) {
			title = "";
		}
		var attrs = ["uploadConversationId", "projectId", "entityTypeId", "entityId", "entityRef"];
		var data = { "title": title, "callback": "wikiEditorOverlay.afterValueUpdated" };
		for (var i=0; i<attrs.length;i++) {
			var attr = attrs[i];
			data[attr] = $field.attr(attr);
		}
		var params = $.param(data);
		url += "?" + params;

		inlinePopup.show(url, { geometry:'large', isEditWikiInOverlay: true });
	},

	getWikiMarkup: function() {
		var $field = $(wikiEditorOverlay.getTargetField());
		var wiki = $field.val();
		console.log("Initialising wysiwyg editor with test:<" + wiki +">");
		return wiki;
	},

	getTargetField: function() {
		var container = window.parent.wikiEditorOverlay.editWikiInOverlayContainer;
		var $body =  $(container).find(".editWikiInOverlayBody");
		var $field = $body.find("textarea").first();
		if ($field.length == 0) {
			// no textarea found, then try with a normal input field
			$field = $body.find("input").first();
		}

		return $field;
	},

	// write back the html to the original control
	_writebackHtml:function(html) {
		var $field = $(window.parent.wikiEditorOverlay.editWikiInOverlayContainer);
		var $htmlPart = $field.closest(".editWikiInOverlayContainer").find(".editWikiInOverlayHTML");
		if ($htmlPart.length > 0) {
			$htmlPart.empty().html(html);

			// Chrome does not always load the images, forcing a reload there
			forceImageReload($htmlPart);
		}
	},


	save: function($container, editorId) {
			var $field, editor, html, isDirty;

			editor = codebeamer.WYSIWYG.getEditorInstance("wiki");
			$field = $(wikiEditorOverlay.getTargetField());
			
			isDirty = editor && editor.$oel && editor.$oel.hasClass('dirty');
		
			if (codebeamer.WYSIWYG.isFileUploadInProgress("wiki")) {
				showFancyAlertDialog(i18n.message('dndupload.uploadsareinprogress'));
				return false;
			}

			editor.edit.off();

			html = editor.$el.html();

			if (codebeamer.WYSIWYG.getEditorMode(editor.$el) == 'wysiwyg') {
				codebeamer.WikiConversion.saveEditor("wiki", true);
			} else {
				codebeamer.WikiConversion.wikiToHtml(editor.$oel.val(), "wiki", false, true).then(function(result) {
					html = result.content;
				});
				editor.$el.removeClass('dirty');
			}

			$field.val(editor.$oel.val());

			wikiEditorOverlay._writebackHtml(html);
			try {
				if (isDirty) {
					var isExtendedDocumentView = typeof parent.trackerObject != 'undefined' && parent.trackerObject.config.extended;
					
					if (isExtendedDocumentView) {
						// TODO: Akos please trigger dirty checking for the edited row in doc edit view both if the center pane is edited
						// and when a wiki text is edited in the right panel 
					} else {
						$field.closest('form.dirty-form-check').addClass('dirty');
					}
				}
			} catch(e) {
				console.warn('Failed to dirty check the form', e);
			}
			wikiEditorOverlay.close();
	},


	close: function() {
		inlinePopup.close();
		return true;
	}
};
