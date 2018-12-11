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

codebeamer.EditorLanguages = codebeamer.EditorLanguages || (function($) {

	function init() {
		// We can customize the translation by using the message keys of Froala here. The message keys can be found in the language files.
		var en = $.FE.LANGUAGE['en_gb'].translation,
			de = $.FE.LANGUAGE['de'].translation;

		// translation for english
		en['Clear Formatting'] = i18n.message('wysiwyg.toolbar.clear.formatting.title');


		// translation for german
		de['Normal'] = i18n.message('wysiwyg.toolbar.normal.title');
		de['Heading 5'] = i18n.message('wysiwyg.toolbar.heading.5.title');
		de['Preformatted'] = i18n.message('wysiwyg.preformatted');
		de['Blockquote'] = i18n.message('wysiwyg.toolbar.blockquote.title');
		de['HEX Color'] = i18n.message('wysiwyg.toolbar.colors.hex.color.title');
	}

	return {
		init: init
	}
})(jQuery);