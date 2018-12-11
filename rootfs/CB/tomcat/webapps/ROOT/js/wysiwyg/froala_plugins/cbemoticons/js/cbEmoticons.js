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
	var popupName = 'cbEmoticons.popup';

	// Define popup template
	$.FroalaEditor.POPUP_TEMPLATES[popupName] = '[_CUSTOM_LAYER_]';

	// The custom popup is defined inside a plugin
	$.FroalaEditor.PLUGINS.cbEmoticons = function(editor) {
    	var emoticons = [
    	                 [{image: 'smile', code: ':)'}, {image: 'sad', code: ':('}, {image: 'wink', code: ';)'},
    	                 {image: 'grin', code: ':D'}, {image: 'shocked', code: ':O'}, {image: 'tongue', code: ':P'}],
    	                 [{image: 'cool', code: 'B-)'}, {image: 'angry', code: ':@'}, {image: 'doh', code: '(doh)'},
    	                 {image: 'rotfl', code: '(rotfl)'}, {image: 'heart', code: '<3'}, {image: 'check', code: '(/)'}],
    	                 [{image: 'error', code: '(x)'}, {image: 'warning', code: '(!)'}, {image: 'plus', code: '(+)'},
    	                 {image: 'minus', code: '(-)'}, {image: 'question', code: '(?)'}, {image: 'star', code: '(*)'}],
    	                 [{image: 'yes', code: '(y)'}, {image: 'no', code: '(n)'}]
    	];

		function _getHtml() {
			var emoticonsHtml;

			emoticonsHtml = '<table role="list" class="cb-table-grid">';

			$.each(emoticons, function(index, row) {
				emoticonsHtml += '<tr>';

				$.each(row, function(index, emoticon) {
					var emoticonUrl = contextPath + '/images/emoticons/' + emoticon.image + '.png';
					var icon = emoticon.code;

					emoticonsHtml += '<td><a href="#" data-url="' + emoticonUrl + '" data-alt="' + icon + '" tabindex="-1" ' +
						'role="option" aria-label="' + icon + '"><img src="' +
						emoticonUrl + '" style="width: 18px; height: 18px" role="presentation" /></a></td>';
				});

				emoticonsHtml += '</tr>';
			});

			emoticonsHtml += '</table>';

			return emoticonsHtml;
		}

		// Create custom popup
		function _initPopup() {
			var template = {
				custom_layer: _getHtml()
			};

			var $popup = editor.popups.create(popupName, template);

			$popup.attr('data-command', 'cbEmoticons');

			$popup.on('click', 'a', function(e) {
				var $linkElm = $(e.currentTarget),
					wiki = ' ' + $linkElm.attr('data-alt') + ' ',
					html = '<img src="' + $linkElm.attr('data-url') + '" class="emoticon" alt="ALT_WIKI:EMOTICON:' + encodeURIComponent(wiki) + '" />';

				editor.html.insert(html);
				editor.$oel.addClass('dirty');
				hidePopup();

				return false;
			});
			return $popup;
		}

		function showPopup() {
			var $btn = editor.$tb.find('.fr-command[data-cmd="cbEmoticons"]'),
				$popup = editor.popups.get(popupName);

			if (!$popup) $popup = _initPopup();

			editor.popups.setContainer(popupName, editor.$tb);

			// Set the popup's position.
			var left = $btn.offset().left + $popup.outerWidth() / 2,
				top = $btn.offset().top	+ (editor.opts.toolbarBottom ? 10 : $btn.outerHeight() - 10);

			editor.popups.show(popupName, left, top, $btn.outerHeight());
		}

		// Hide the custom popup.
		function hidePopup() {
			editor.popups.hide(popupName);
		}

		return {
			showPopup : showPopup,
			hidePopup : hidePopup
		}
	}
}));