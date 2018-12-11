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
	var popupName = 'cbUserSelector.popup';

	// Define popup template
	$.FroalaEditor.POPUP_TEMPLATES[popupName] = '[_CUSTOM_LAYER_]';

	$.FroalaEditor.PLUGINS.cbUserSelector = function(editor) {
		var url = contextPath + '/ajax/getUserFieldSuggestions.spr',
			isInProjectContext = false;
		
		try {
			isInProjectContext = (codebeamer.projectId && codebeamer.projectId.length) || 
								 (window.parent != window && window.parent.codebeamer.projectId && window.parent.codebeamer.projectId.length); // if the editor is in an iframe
		} catch(ignored) {
			// This can be ignored, probably cross-origin frame access on remote issue reporting
		}
		var _getUsers = throttleWrapper(function(username) {
			if (!editor.popups.isVisible(popupName)) {
				showPopup();
			}

			var $popup = editor.popups.get(popupName),
				$content = $popup.find('.content');

			$content.empty().addClass('loading');

			$.ajax({
				type: 'POST',
				cache: false,
				url: url,
				data: {
					autoCompleteFilter: username.substring(1),
					singleSelect: true,
					searchOnAllUsers: !isInProjectContext 
				},
				dataType: 'json',
				success: function(result) {
					if (result && result.resultset && result.resultset.length) {
						$content.empty().removeClass('loading');
						result.resultset.forEach(function(data) {
							$content.append(data.detailedHTML);
						});

						var $users = $content.find('table');

						$users.first().addClass('active');

						$users.hover(function(e) {
							$users.removeClass('active')
							$(this).addClass('active');
						});
						$users.on('touchend click', function() {
							_insertSelectedUser($(this));
							return false;
						});
					} else {
						hidePopup();
					}
				},
				error: function() {
					hidePopup();
				}
			});
		}, 200);

		editor.events.on('keydown', function(e) {
			var keycodes = [$.FE.KEYCODE.ARROW_UP, $.FE.KEYCODE.ARROW_DOWN, $.FE.KEYCODE.ENTER],
				closeOnKeycodes = [$.FE.KEYCODE.ESC, $.FE.KEYCODE.SPACE, $.FE.KEYCODE.TAB];

			if (editor.popups.isVisible(popupName) && closeOnKeycodes.indexOf(e.which) > -1) {
				hidePopup();
				return false;
			}

			// handling UP, DOWN and ENTER keys
			if (editor.popups.isVisible(popupName) && keycodes.indexOf(e.which) > -1) {
				e.preventDefault();
				e.stopImmediatePropagation();

				var $active = editor.popups.get(popupName).find('table.active'),
					keycodeFunctionMap = {
						prev: $.FE.KEYCODE.ARROW_UP,
						next: $.FE.KEYCODE.ARROW_DOWN
					};

				$.each(keycodeFunctionMap, function(fn, key) {
					if (e.which == key && $active[fn]().length) {
						$active.removeClass('active');
						$active[fn]().addClass('active');
					}
				});

				if (e.which == $.FE.KEYCODE.ENTER) {
					_insertSelectedUser($active);
				}

				return false;
			}

			setTimeout(function() { // setTimeout to let froala's event handler run first, in order to have the latest character as well
				try {
					var selection = editor.selection.get();
					if (selection.focusNode && selection.focusNode.nodeType == Node.TEXT_NODE) {
						var textNodeValue = selection.focusNode.nodeValue,
							isLastCharacter = textNodeValue.length == selection.focusOffset,
							charAtOffset = isLastCharacter ? '' : textNodeValue.charAt(selection.focusOffset),
							text = textNodeValue.substring(0, selection.focusOffset),
							atIndex = text.lastIndexOf('@'),
							charBeforeAtIndex = atIndex > 0 ? text.charAt(atIndex - 1) : '',
							username = atIndex > -1 && (isLastCharacter || !charAtOffset.trim().length) && !charBeforeAtIndex.trim().length ? text.substring(atIndex) : '';

						if (username.length > 2 && username.indexOf(' ') == -1) {
							_getUsers(username);
						}
					}
				} catch(e) {
					console.warn('Could not show user selector popup', e);
				}
			});
		}, true); // registering as first event handler, otherwise event is handled by froala and not propagated

		function _insertSelectedUser($user) {
			var id = $user.attr('data-id'),
				username = $user.attr('data-username'),
				fullname = $user.attr('data-fullname'),
				email = $user.attr('data-email'),
				lastLogin = $user.attr('data-lastlogin');

			try {
				var selection = editor.selection.get(),
					textNode = selection.focusNode,
					lastCharacter = selection.focusNode.nodeValue.length == selection.focusOffset ? '&nbsp;' : '';

				editor.html.insert(
					'<a href="' + contextPath + '/userdata/' + id + '" class="interwikilink" data-targetdesc="' + username + '" data-wikilink="[USER:' + id + 
					']" title="[USER:' + id + '] ' + fullname + ' (' + email + '); Last Login:' + (lastLogin || 'N/A') + '" target="_blank">' + username + '</a>' + lastCharacter		
				);

				if (textNode) {
					textNode.nodeValue = textNode.nodeValue.substring(0, textNode.nodeValue.lastIndexOf('@'));
				}

				hidePopup();
			} catch(e) {
				console.warn('Could not insert selected user', e);
			}
		}

		// Create custom popup
		function _initPopup() {
			var template = {
				custom_layer: '<div class="content"></div>'
			};

			var $popup = editor.popups.create(popupName, template);

			$popup.attr('data-command', 'cbUserSelector');

			return $popup;
		}

		function showPopup() {
			var $popup = editor.popups.get(popupName);

			if (!$popup) $popup = _initPopup();

			editor.popups.setContainer(popupName, editor.$el.closest('.editor-wrapper'));

			var offset = editor.$el.caret('offset'); // with caret.js

			if (offset.left + $popup.width() > editor.$el[0].getBoundingClientRect().right) {
				offset.left -= $popup.width();
			}

			offset.top += 10;

			// Set the popup's position.
			editor.popups.show(popupName, offset.left + $popup.width() / 2, offset.top);
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