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

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['jquery'], factory);
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        module.exports = function( root, jQuery ) {
            if ( jQuery === undefined ) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if ( typeof window !== 'undefined' ) {
                    jQuery = require('jquery');
                }
                else {
                    jQuery = require('jquery')(root);
                }
            }
            return factory(jQuery);
        };
    } else {
        // Browser globals
        factory(window.jQuery);
    }
}(function ($) {
	$.FroalaEditor.PLUGINS.cbColors = function() {
		function _updateColorsPopup(editor, $btn) {
			var $popup = editor.popups.get('colors.picker'),
				left = $btn.position().left + $btn.outerWidth() / 2 - $popup.outerWidth() / 2,
				top = $popup.hasClass('fr-above') ? -1 * ($popup.height() + 19) : 45,
				val = $btn.data('cmd') == 'cbColorText' ? 'text' : 'background',
				$colorTab = $popup.find('.fr-command[data-cmd="colorChangeSet"][data-param1="' + val + '"]'),
				$otherColorTab = $popup.find('.fr-command[data-cmd="colorChangeSet"][data-param1="' + (val == 'text' ? 'background' : 'text')+ '"]');

			$popup.css({
				left: left,
				top: top
			});

			$popup.data('cbcolor', $btn.data('cmd'));
			$colorTab.show();
			$otherColorTab.hide();
			editor.colors.changeSet($colorTab, val);
		}

		function _cbColorCallback(editor, cmd) {
			if (!editor.popups.isVisible('colors.picker')) {
				editor.colors.showColorsPopup();
				_updateColorsPopup(editor, editor.button.getButtons('button[data-cmd="' + cmd + '"]'));
			} else {
				var $popup = editor.popups.get('colors.picker');
				if ($popup.data('cbcolor') != cmd) {
					_updateColorsPopup(editor, editor.button.getButtons('button[data-cmd="' + cmd + '"]'));
				} else {
					if (editor.$el.find('.fr-marker').length) {
						editor.events.disableBlur();
						editor.selection.restore();
					}
					editor.popups.hide('colors.picker');
				}
			}
		}

		$.FE.DefineIcon('cbColorTextIcon', { NAME: 'font' });
		$.FE.DefineIcon('cbColorBackgroundIcon', { NAME: 'paint-brush' });

		$.FE.RegisterCommand('cbColorText', {
			title: i18n.message('wysiwyg.toolbar.colors.text.title'),
			icon: 'cbColorTextIcon',
			undo: false,
			focus: true,
			refreshOnCallback: false,
			popup: true,
			callback: function () {
				_cbColorCallback(this, 'cbColorText');
			},
			plugin: 'colors'
		});

		$.FE.RegisterCommand('cbColorBackground', {
			title: i18n.message('wysiwyg.toolbar.colors.background.title'),
			icon: 'cbColorBackgroundIcon',
			undo: false,
			focus: true,
			refreshOnCallback: false,
			popup: true,
			callback: function () {
				_cbColorCallback(this, 'cbColorBackground');
			},
			plugin: 'colors'
		});
	}
}));