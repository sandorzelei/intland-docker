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

codebeamer.WysiwygShortcuts = codebeamer.WysiwygShortcuts || (function($) {

	var actualEditor;

	function setActualEditor(editor) {
		actualEditor = editor;
	}

	function getActualEditor() {
		return actualEditor;
	}

	function registerSaveButtonShortcut() {
		$.FE.RegisterShortcut($.FE.KEYCODE.S, "cbSave", null, "S", false, false);
	}

	function registerSaveEventShortcut() {
		$.FE.RegisterShortcut($.FE.KEYCODE.S, "cbSaveEvent", null, "S", false, false);
	}

	function registerDirectShortcuts() {
		$(document).off("keydown.codebeamer-wysiwyg");
		$(document).on("keydown.codebeamer-wysiwyg", onKeyDown);
	}
	
	function _isEscNotSupportedInForm() {
		var $form = actualEditor.$oel.closest('form');
		
		// not supported in doc view right panel and in test runner
		return $form.length && ($form.attr('action').indexOf('getIssueProperties') != -1 || $form.attr('action').indexOf('testRunner') != -1);
	}
	
	function _isOnExtendedDocView() {
		return typeof trackerObject != 'undefined' && trackerObject.config.extended;
	}
	
	function onKeyDown(e) {
		try {
			if (actualEditor && actualEditor.$box.is(':visible')) {
			    handleSave(e);
			    handleModeSwitching.call(actualEditor, e);
				if (!e.isDefaultPrevented() && !_isEscNotSupportedInForm() && !_isOnExtendedDocView()) {
					handleCancel(e);
				}
			}
		} catch(e) {
			console.warn('Failed to handle save/cancel/mode switching editor shortcuts', e);
		}
	}

	function handleCancel(e) {
	    var ctrlKey = codebeamer.WYSIWYG.isMac() ? e.metaKey : e.ctrlKey,
    		keycode = e.which,
    		$target = $(e.target),
    		options = actualEditor.$oel.data('shortcutOptions') || {};
	    
        if (keycode === $.FE.KEYCODE.ESC && !ctrlKey && !e.shiftKey && !e.altKey && 
        		codebeamer.WYSIWYG.isEditorInDom(actualEditor)) {
        	showFancyConfirmDialogWithCallbacks(
    			i18n.message('close.editing.confirmation.label'),
    			function() {
    				if (options.cancelAction) {
    					$.FE.COMMANDS[options.cancelAction].callback.apply(actualEditor);
    				} else {
    					actualEditor.$oel.trigger('wysiwyg:cancel');
    				}    			
    			},
    			null,
    			'warning',
    			function() { 
    				$(this).closest('.ui-dialog').find('.ui-dialog-buttonpane button').first().focus(); 
    			},
    			function() {
    				if ($target.attr('contenteditable')) {
    					actualEditor.events.focus();
    				}
    			}
    		);
	    }
	}
	
	function handleSave(e) {
		var ctrlKey, keycode, saveAction, options = actualEditor.$oel.data('shortcutOptions') || {};

	    ctrlKey = codebeamer.WYSIWYG.isMac() ? e.metaKey : e.ctrlKey;
	    keycode = e.which;

        if (ctrlKey && !e.shiftKey && !e.altKey && codebeamer.WYSIWYG.isEditorInDom(actualEditor) && actualEditor.$el.closest(".editor-wrapper").hasClass("markup")) {

        	if (keycode === $.FE.KEYCODE.S) {
        		saveAction = options && options.hasOwnProperty("saveAction") ? options["saveAction"] : "event";

        		if (saveAction === "command" ) {
        			$.FE.COMMANDS.cbSave.callback.apply(actualEditor);
        		} else {
            		actualEditor.$oel.trigger("wysiwyg:save");
        		}

        		e.preventDefault();
    	        e.stopPropagation();
        	}

	    }

	}

	function handleModeSwitching(e) {
		var ctrlKey, keycode;

	    ctrlKey = codebeamer.WYSIWYG.isMac() ? e.metaKey : e.ctrlKey;
	    keycode = e.which;

        if (!ctrlKey && !e.shiftKey && e.altKey && codebeamer.WYSIWYG.isEditorInDom(actualEditor)) {

        	if (keycode === $.FE.KEYCODE.ONE) {
        		if (!actualEditor.$box.closest('.editor-wrapper').hasClass('wysiwyg')) {
            		$.FE.COMMANDS.cbWysiwyg.callback.apply(actualEditor);
        		}
        		e.preventDefault();
    	        e.stopPropagation();
        	} else {
        		if (keycode === $.FE.KEYCODE.TWO) {
        			if (!actualEditor.$box.closest('.editor-wrapper').hasClass('markup')) {
            			$.FE.COMMANDS.cbMarkup.callback.apply(actualEditor);
        			}
        			e.preventDefault();
        	        e.stopPropagation();
        		} else {
        			if (keycode === $.FE.KEYCODE.THREE && !actualEditor.$oel.data('disablePreview')) {
        				if (!actualEditor.$box.closest('.editor-wrapper').hasClass('preview')) {
            				$.FE.COMMANDS.cbPreview.callback.apply(actualEditor);
        				}
        				e.preventDefault();
        		        e.stopPropagation();
        			}
        		}
        	}

	    }

	}

	function registerIndent() {
		delete $.FE.SHORTCUTS_MAP[$.FE.KEYCODE.CLOSE_SQUARE_BRACKET]; // indent
		$.FE.RegisterShortcut($.FE.KEYCODE.K, 'indent', null, 'K', false, false);
	}

	function registerOutdent() {
		delete $.FE.SHORTCUTS_MAP[$.FE.KEYCODE.OPEN_SQUARE_BRACKET]; // outdent
		$.FE.RegisterShortcut($.FE.KEYCODE.K, 'outdent', null, 'K', true, false);
	}
	
	function registerListShortCuts() {
		$.FE.RegisterShortcut($.FE.KEYCODE.L, 'formatUL', null, 'L', true, false);
		$.FE.RegisterShortcut($.FE.KEYCODE.O, 'formatOL', null, 'O', true, false);
	}

	return {
		setActualEditor: setActualEditor,
		getActualEditor: getActualEditor,
		registerSaveButtonShortcut: registerSaveButtonShortcut,
		registerSaveEventShortcut: registerSaveEventShortcut,
		registerDirectShortcuts: registerDirectShortcuts,
		registerIndent: registerIndent,
		registerOutdent: registerOutdent,
		registerListShortCuts: registerListShortCuts
	}

})(jQuery);
