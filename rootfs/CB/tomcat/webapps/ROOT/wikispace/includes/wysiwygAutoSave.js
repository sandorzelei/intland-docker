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
 * $Revision: 20791:389b48c1e59b $ $Date: 2009-03-27 07:21 +0000 $
 */

/**
 * Javascript object for automatically saving the content of the wysiwyg editor or text-area periodically
 * and restore it on demand.
 *
 * @param id The unique id of the content being edited, for example the wiki document's id plus its revision like "WIKIPAGE-<id>-<revision>"
 * @param editorId The html-id and id of the editor
 * @param lastModifiedTimeStamp The optional last modification time-stamp of the content being edited
 */
function wysiwygAutoSave(id, editorId, lastModifiedTimeStamp) {
	this.init(id, editorId, lastModifiedTimeStamp);
}

wysiwygAutoSave.prototype = {

	maximumSizePerWikiPage : 100000, // maximum size in chars of each Wiki Page to be stored

	init: function(id, editorId, lastModifiedTimeStamp) {
		if (id == null || editorId == null) {
			return;
		}

		this.id = id;
		this.editorId = editorId;
		this.lastModifiedTimeStamp = lastModifiedTimeStamp;
		this._initStorage();
		this.load();
		this._scheduleAutoSave();
	},

	_initStorage: function() {
		try {
			if ($.jStore.Availability) {
				if (!$.jStore.CurrentEngine) {
					// TODO: why are these necessary?
					$.jStore.use('local', 'cbwiki', 'edit');
					$.jStore.setCurrentEngine('edit.cbwiki.local');
				}
				return true;
			}
		} catch(e) {
			console.log(e);
		}
	},

	// remove all content may have been saved
	_clear: function() {
		this._setValue(null);
	},

	_setValue: function(content) {
		var key = "CodeBeamer.wysiwygAutoSave." + this.id;
		if (content == null || content == '') {
			$.jStore.remove(key + ".timestamp");
			$.jStore.remove(key + ".content");
		} else {
			var timestamp = new Date().getTime(); //TODO: there might be a bug, because the server time and client time may differ!
			$.jStore.store(key + ".timestamp", timestamp);
			$.jStore.store(key + ".content", content);
		}
	},

	/**
	 * Check if we have some content backed up previously, and ask if that should be recovered
	 */
	load: function() {
		try {
			// check if we have some newer content saved
			var key = "CodeBeamer.wysiwygAutoSave." + this.id;
			var storedTimestamp = $.jStore.get(key + ".timestamp");
			var storedContent = $.jStore.get(key + ".content");
			if (!storedContent || !storedTimestamp || (this.lastModifiedTimeStamp && this.lastModifiedTimeStamp >= storedTimestamp )) {
				this._clear();
				return;
			}
			// check if the contents are the same, and don't bother asking if they are
			var content = $('#' + this.editorId).val();
			if (content == storedContent) {
				this._clear();
				return;
			}

			// ask the user if he wants to restore?
			var localSaveDate = new Date(storedTimestamp).toString();
			var confirmMessage = i18n.message('wiki.edit.loadlocal.confirm', localSaveDate);
			if(confirm(confirmMessage)) {
				// restore the content
				var $editor = $('#' + this.editorId);

				codebeamer.WYSIWYG.toggleConversionInProgress($editor, true);
				codebeamer.WikiConversion.wikiToHtml(storedContent, this.editorId)
					.then(function(result) {
						$editor.froalaEditor('html.set', result.content);
						$editor.addClass('dirty');
					})
					.always(function() {
						codebeamer.WYSIWYG.toggleConversionInProgress($editor, false);
					});
			}
			this._clear();
		} catch (e) {
			console.log(e);
		}
	},

	// how often the content is auto-saved in seconds?
	_autoSaveFrequency: 60,

	_scheduleAutoSave: function() {
		var self = this;
		setTimeout(function() {
			self._autoSave();
			self._scheduleAutoSave();
		}, this._autoSaveFrequency * 1000);
	},

	// Save the content of the current wysiwyg editor
	_autoSave: function() {
		try {
			if (this._initStorage()) {
				var self = this,
					$editor = $('#' + self.editorId),
					promise = codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg' ? codebeamer.WikiConversion.saveEditor(self.editorId) : $.when();

				promise.then(function() {
					var content = $editor.val();
					if (content.length < self.maximumSizePerWikiPage) {
						self._setValue(content);
					} else {
						console.debug("Size of Wiki Page exceeds limit (" + self.maximumSizePerWikiPage + ")!");
					}
				});
			}
//			// TODO: it would be nice to show a message about auto-save, for example using globalMessages like this:
//			var msg = "Content is auto saved"; // TODO: i18n
//			GlobalMessages.showMessage("information", msg, function(msgEl) {
//				setTimeout(function() {
//					GlobalMessages.hideMessage(msgEl);
//				}, 2000);
//			});
		} catch(e) {
			console.log(e);
		}
	}

};
