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


  $.FE.PLUGINS.imageAttachment = function (editor) {
	    var $head, $body, modalId;

	    modalId = "imageAttachment";

	    function getBody() {
	    	var  editorId, itemKey;

	    	editorId = editor.$oel.attr('id');
	    	itemKey = encodeURIComponent(codebeamer.WikiConversion.getEditorsEntityReference(editorId));

	    	return "<iframe class=\"normal\" src=\"" + contextPath + "/wysiwyg/getImageAttachments.spr?entityRef=" + itemKey
	    				+ "\" data-editor-id=\"" + editorId + "\" data-modal-id=\"" + modalId + "\"></iframe>";
	    }

	    function showModal() {
        	var head, body, modalHash;

            modalHash = editor.modals.create(modalId, head, body);

            modalHash.$modal.empty();
            modalHash.$modal.append(getBody());

            modalHash.$modal.css("display", "flex");

            editor.events.$on($(editor.o_win), 'resize', function () {
              var instance = $modal.data('instance') || editor;

              instance.modals.resize(modalId);
            });

	        editor.modals.show(modalId);
	        editor.modals.resize(modalId);

			editor.selection.restore();

	    }

		function hideModal() {
			editor.modals.hide(modalId);
		}

		return {
			showModal : showModal,
			hideModal : hideModal
		};
  };

}));
