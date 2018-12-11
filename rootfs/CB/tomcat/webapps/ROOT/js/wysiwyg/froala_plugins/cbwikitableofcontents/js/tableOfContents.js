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


  $.FE.PLUGINS.tableOfContents = function (editor) {

	  	var tocWikiMarkup, tocHmlMarkup;

	  	tocWikiMarkup = "[{TableOfContents}]";
	  	tocHmlMarkup="<p><pre class=\"pluginSource\">" + tocWikiMarkup +"</pre></p>";

		function insert() {
			var html, placeholder, existingTocPlugins;

			$html = editor.$el;

			existingTocPlugins = $html.find(".pluginSource:contains('" + tocWikiMarkup + "')")

			if(existingTocPlugins.length > 0) {

				if(confirm(i18n.message("wiki.wysiwyg.TOC.already.exists"))) {

					placeholder = "toc-placeholder-class";

					editor.$oel.froalaEditor("html.insert", "<span class=" + placeholder + ">\uFEFF</span>", true);

					existingTocPlugins.remove();

					$html.find("." + placeholder).replaceWith(tocHmlMarkup);
					editor.$oel.addClass('dirty');

				}

			} else {
				editor.$oel.froalaEditor("html.insert", tocHmlMarkup, true);
				editor.$oel.addClass('dirty');
			}

		}

		return {
			insert: insert
		};
  };

}));
