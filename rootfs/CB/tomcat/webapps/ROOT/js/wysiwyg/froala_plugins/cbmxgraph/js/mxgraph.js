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


  $.FE.PLUGINS.mxgraph = function (editor) {
	    var $head, $body, modalId, instanceToEdit;

	    modalId = "mxgraph";

	    function getBody() {
	    	var url, editorId;

	    	editorId = editor.$oel.attr('id');

	    	url = contextPath + "/mxGraph/mxGraphEditor.jsp";

	    	return "<iframe class=\"full-screen\" src=\"" + url + "\" data-editor-id=\"" + editorId + "\" data-modal-id=\"" + modalId + "\"></iframe>";
	    }

	    function openModal(modalId, head, body) {
            var modalHash = editor.modals.create(modalId, head, body);

            modalHash.$modal.empty();
            modalHash.$modal.append(getBody());

            modalHash.$modal.css("display", "flex");

	        editor.modals.show(modalId);
	        editor.modals.resize(modalId);

			editor.selection.restore();
	    }

	    function showModal(target) {
        	var head, body, $pluginSource, source, id;

        	if (target) {
    			$pluginSource = $(target);
    			instanceToEdit = $(target);
				source = $pluginSource && $pluginSource.context ? $pluginSource.context.getAttribute("alt") : undefined;
        	} else {
        		instanceToEdit = $(target);
        	}

        	if (source && source.length > 0) {

        		source = atob(source.substring(source.indexOf(";") + 1));

				if (source.indexOf('artifactId') != -1) {
					id = source.substring(source.indexOf("artifactId='") + 12);
					id = id.substring(0, id.indexOf("'"));

					$.post(contextPath + "/mxGraph/artifactPermission.spr", {doc_id: id}).done(function(data) {
						if (data === "read-write") {
							openModal(modalId, head, body);
						} else {
							showFancyAlertDialog(i18n.message("mxgraph.editor.no.permission"), null, "200px");
						}
					}).fail(function(response) {
						showFancyAlertDialog(i18n.message("mxgraph.editor.no.permission"), null, "200px");
					});
				} else {
	        		openModal(modalId, head, body);
				}

        	} else {
        		openModal(modalId, head, body);
        	}

	    }

		function hideModal() {
			editor.modals.hide(modalId);
		}

		function getInstanceUnderEditing() {
			return instanceToEdit;
		}


		return {
			showModal: showModal,
			hideModal: hideModal,
			getInstanceUnderEditing: getInstanceUnderEditing
		};
  };

}));
