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

codebeamer.WikiConversion = codebeamer.WikiConversion || (function($) {
	var blockLevelElements = 'address,article,aside,blockquote,canvas,dd,div,dl,dt,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,header,hgroup,hr,li,main,nav,noscript,ol,output,p,pre,section,table,tfoot,ul,video';

	var PREVIEW_URL = contextPath + '/wysiwyg/wikipreview.spr',
		WIKI_TO_HTML_URL = contextPath + '/wysiwyg/convertWikiToHTML.spr',
		HTML_TO_WIKI_URL = contextPath + '/wysiwyg/convertHTMLToWiki.spr';

	var editorToEntityRefrences = {};

	function bindEditorToEntity(editorId, entityId) {
		editorToEntityRefrences[editorId] = entityId;
	}

	function getEditorsEntityReference(editorId) {
		return editorToEntityRefrences[editorId];
	}

	/**
	 * WIKI to HTML conversion, used for wysiwyg and preview modes
	 * @param wiki
	 * @param editorId the id of the wysiwyg editor
	 * @param isPreviewMode True if preview mode is selected
	 */
	function wikiToHtml(wiki, editorId, isPreviewMode, isSynchronous) {
		var conversationId = $('#' + editorId).data('uploadConversationId');
		// add doc_id to url so server can display the existing attachments too
		var entityRef = getEditorsEntityReference(editorId);

		var url = isPreviewMode ? PREVIEW_URL : WIKI_TO_HTML_URL;

		return convertWikiToHtml(url, wiki, {
			async: !isSynchronous
		}, entityRef, conversationId).then(function(result) {
			if (!isPreviewMode && result.content) {
				// Dirty hack for underline and strikethrough
				result.content = replaceTextDecorationSpans(result.content);
				// And an other dirty hack to replace empty paragraphs with brs
				result.content = replaceEmptyParagraphsWithBrs(result.content);
				// #1651072 Fixing anchors in table cells if the cell doesn't contain text
				result.content = wrapAnchorsWithZeroWidthSpaces(result.content);
			}
			return result;
		});
	}

	function replaceTextDecorationSpans(content) {
		var $temp = $('<div>' + content + '</div>'),
			$spans = $temp.find('span[style*="text-decoration"]');

		for (var i = $spans.length - 1; i >=0; i--) {
			var $span = $($spans.get(i)),
				tagName;

			if ($span.css('text-decoration').indexOf('underline') > -1) {
				tagName = 'u';
			}

			if ($span.css('text-decoration').indexOf('line-through') > -1) {
				tagName = 's';
			}

			if (tagName && $span[0].innerHTML.replace(/<br>/gi, '').length != 0) {
				if ($span.children().length) {
					$span.replaceWith(function() {
					    return $('<' + tagName + '/>', { html: $(this).html() });
					});
				} else {
					$span.replaceWith('<' + tagName + '>' + $span.text() + '</' + tagName + '>');
				}
			}
		}

		return $temp.html();
	}

	function wrapAnchorsWithZeroWidthSpaces(content) {
		var $temp = $('<div>' + content + '</div>');

		$temp.find('table td').each(function() {
			var $cell = $(this);
			var hasText = !!$cell.contents().filter(function() {
				//Node.TEXT_NODE === 3 and node is immediate child and the text of the node is not whitespace
				return (this.nodeType === 3 && this.parentNode === $cell[0] && !!this.textContent.trim().length);
			}).length;

			if (!hasText) {
				$cell.find('a').before('&#8203;').after('&#8203;');
			}
		});

		return $temp.html();
	}

	/**
	 * HTML to WIKI conversion
	 * @param html
	 * @param editorId the id of the wysiwyg editor
	 */
	function htmlToWiki(html, editorId, isSynchronous) {
		var conversationId = $('#' + editorId).data('uploadConversationId');
		// add doc_id to url so server can display the existing attachments too
		var entityRef = getEditorsEntityReference(editorId);

		// Dirty hack for underline and strikethrough
		html = replaceUnderlineAndStrikeThroughTags(html);

		return _convertHtmlToWiki(html, {
			async: !isSynchronous
		}, entityRef, conversationId);
	}

	function replaceUnderlineAndStrikeThroughTags(html) {
		var $temp = $('<div>' + html + '</div>'),
			$textDecorations = $temp.find('u, s'),
			mapping = {
				u: 'underline',
				s: 'line-through'
			};

		for (var i = $textDecorations.length - 1; i >=0; i--) {
			var $tag = $($textDecorations.get(i)),
				tagName;

			if ($tag.is('u')) {
				tagName = 'u';
			}

			if ($tag.is('s')) {
				tagName = 's';
			}

			if (tagName && $tag[0].innerHTML.replace(/<br>/gi, '').length != 0) {
				if ($tag.children().length) {
					$tag.replaceWith(function() {
						return $('<span/>', { html: $(this).html(), style: 'text-decoration: ' + mapping[tagName] });
					});
				} else {
					$tag.replaceWith('<span style="text-decoration: ' + mapping[tagName] + '">' + $tag.text() + '</span>');
				}
			}
		}

		return $temp.html();
	}
	/**
	 * Used for inserting raw wiki markup to the wysiwyg editor
	 *
	 * Convert a raw wiki markup to HTML so that it can be inserted to html/wywiwyg editor and won't become HTML but will be converted
	 * back to the original raw wiki by the html->wiki converter.
	 */
	function escapeWikiToHtml(wiki) {
		if (wiki == null) {
			return null;
		}

		var url = contextPath + "/wysiwyg/escapeWikiToHtml.spr";
		var result = null;
		$.ajax({
			type: "POST",
			cache: false,
			url: url,
			async: false,
			data: {
				"wiki": wiki
			},
			dataType: "json",
			success: function(data) {
				result = data;
			}
		});

		return result == null ? null : result.html;
	}

	function _convertHtmlToWiki(html, ajaxArgs, entityRef, conversationId) {
		return _convertOnServer(HTML_TO_WIKI_URL, html, ajaxArgs, entityRef, conversationId);
	}

	function convertWikiToHtml(url, wiki, ajaxArgs, entityRef, conversationId) {
		return _convertOnServer(url, wiki, ajaxArgs, entityRef, conversationId);
	}

	// shared ajax call/parameters from wiki->html or html->wiki
	function _convertOnServer(ajaxUrl, content, ajaxArgs, entityRef, conversationId) {
		try {
			var promise;

			var mergedArgs = $.extend(true /* deep merge to merge data property too */, {}, {
				type: 'POST',
				cache: false,
				url: ajaxUrl,
				data: {
					'entityRef': entityRef,
					'conversationId' : conversationId,
					'content': content
				},
				dataType: 'json'
			}, ajaxArgs);

			if ($.trim(content).length == 0) {
				console.log('Not calling server because wiki/html text is empty');
				promise = $.when({ 'content': '' });
			} else {
				promise = $.ajax(mergedArgs);
			}

			// when conversion failed keep the unconverted value, so the user has chance to recover
			// TODO: any better error handling
			return promise.fail(function(jqXHR, textStatus, errorThrown) {
				console.log('_convertOnServer(<' + ajaxUrl + '> error:' + textStatus + ', ' + errorThrown);
				showFancyAlertDialog('Conversion has failed, the original content is left in the editor, please save it outside of browser as your changes may get lost later, so you can recover from this!', 'error');
			});
		} catch (e) {
			console.log('Conversion failed: ' + e);
		}
	}

	function getCleanHTMLOnEditorSave($editor) {
		var html = $editor.froalaEditor('html.get');
		return getCleanHtml(html);
	}

	function getCleanHtml(html) {
		// clean up the chrome dirt in html
		html = htmlCleanup(html);

		// decorate the html by adding a <html>...</html> wrapper which is used on server
		// to recognize the "unconverted" html markup
		// see WikiMarkupProcessor and AutoConvertHtmlToWiki for the related conversion handling part on the server
		var UNCONVERTED_DECORATE_START = '<html>';
		var UNCONVERTED_DECORATE_END = '</html>';

		if ($.trim(html).length > 0) {
			if (html.indexOf(UNCONVERTED_DECORATE_START) == -1) {
				html = UNCONVERTED_DECORATE_START + html + UNCONVERTED_DECORATE_END;
			} else {
				console.log('HTML fragment is already decorated:<' + html + '>');
			}
		}
		return html;
	}

	function _isEmptyParagraph($element) {
		return $element.is('p') && $element[0].innerHTML.replace(/<br>/gi, '').length == 0;
	}

	function htmlCleanup(html) {
		try {
			var $cleaner = $('<div>' + html + '</div>');
			// remove the line-height and font-size from the spans right inside li elements
			$cleaner.find('li > span').each(function() {
				$(this).css({
					'line-height' : '',
					'font-size': ''
				});
			});

			// removing the 2+ empty immediate sibling paragraphs, paragraphs which contain only <br>-s are handled as empty
			$cleaner.children().each(function() {
				var $element = $(this),
					isEmptyParagraph = _isEmptyParagraph($element),
					counter = 0;

				while (isEmptyParagraph) {
					var $nextElement = $element.next();
					isEmptyParagraph = _isEmptyParagraph($nextElement);
					counter++;

					if (counter > 2) {
						$element.remove();
					}
					$element = $nextElement;
				}
			});

			// updating relative urls to absolute urls in links
			$cleaner.find('a[href^="' + contextPath + '"], a[href^="/displayDocument"]').each(function() {
				var $anchor = $(this),
					href = $anchor.attr('href');

				$anchor.attr('href', document.location.origin + href);
			});

			return $cleaner.html();
		} catch (ex) {
			console.log('Error during html cleanup of <' + html + '>');
			return html;
		}
	}

	/**
	 * Converts the editor's html to wiki, and stores it in the editor textarea
	 * @param editor The id of the editor textarea, or the textarea jquery object
	 * @param isSynchronous Optional parameter to specify whether to use sync or async http call for html to wiki conversion
	 */
	function saveEditor(editor, isSynchronous) {
		var $editor = editor.jquery ? editor : $('#' + editor);

		if ($editor.length) {
			var promise;

			if ($editor.hasClass('dirty')) {
				var html = getCleanHTMLOnEditorSave($editor);

				promise = htmlToWiki(html, $editor.attr('id'), isSynchronous);
			} else {
				promise = $.when({ 'content': $editor.data('oldMarkup') });
			}

			return promise.then(function(result) {
				var markup = result.content;

				if ($editor.data('allowTestParameters')) {
					markup = _allowTestParametersInMarkup(markup);
				}

				$editor.val(markup)
					.data('oldMarkup', markup)
					.removeClass('dirty');
			});
		}

		return $.when();
	}

	function replaceEmptyParagraphsWithBrs(content) {
		var $emptyPsToBrs = $('<div>' + content + '</div>');
		$emptyPsToBrs.find('p:empty').each(function() {
			var $element = $(this);
			if ($element.prev().is(blockLevelElements)) {
				$element.remove();
			} else {
				$element.replaceWith('<br>');
			}
		});
		return $emptyPsToBrs.html();
	}
	// Temporary solution to hack ${parameters} in test steps, test case pre|post actions and description
	function _allowTestParametersInMarkup(markup) {
		var escapedChars = "|[]\\#-!'_^{}%,"; // from WikiEscaper.java

		return markup.replace(/\$\~\{.+?\~\}/g, function(matchedParameter) {
			var parameter = matchedParameter.substring(3, matchedParameter.length - 2);

			parameter = parameter.replace(/\~./g, function(escapedCharacter) {
				if (escapedChars.indexOf(escapedCharacter.charAt(1)) > -1) {
					return escapedCharacter.charAt(1);
				}
				return escapedCharacter;
			});
			return '${' + parameter + '}';
		});
	}

	return {
		wikiToHtml: wikiToHtml,
		htmlToWiki: htmlToWiki,
		escapeWikiToHtml: escapeWikiToHtml,
		bindEditorToEntity: bindEditorToEntity,
		editorToEntityRefrences: editorToEntityRefrences,
		getEditorsEntityReference: getEditorsEntityReference,
		saveEditor: saveEditor,
		htmlCleanup: htmlCleanup,
		getCleanHTMLOnEditorSave: getCleanHTMLOnEditorSave,
		getCleanHtml: getCleanHtml,
		convertWikiToHtml: convertWikiToHtml,
		replaceEmptyParagraphsWithBrs: replaceEmptyParagraphsWithBrs,
		replaceTextDecorationSpans: replaceTextDecorationSpans,
		replaceUnderlineAndStrikeThroughTags: replaceUnderlineAndStrikeThroughTags
	}
})(jQuery);