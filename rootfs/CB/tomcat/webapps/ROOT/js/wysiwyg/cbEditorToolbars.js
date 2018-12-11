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

codebeamer.EditorToolbars = codebeamer.EditorToolbars || (function($) {
	var mainToolbarButtons = ['cbFormattingOptions', 'cbAdvancedOptions', 'cbLinkOptions', 'insertFile', 'cbEmoticons', 'cbWysiwygOptions', 'cbWysiwyg', 'cbMarkup', 'cbPreview', 'cbMakeDefault', 'cbWikiHelp', 'cbEditorFormat', 'cbOverlayEditor'];

	// buttons for different editor modes
	var buttonsForModes = {
		wysiwyg: ['cbFormattingOptions', 'cbAdvancedOptions', 'cbLinkOptions', 'insertFile', 'cbEmoticons', 'cbWysiwygOptions', 'cbEditorFormat', 'cbOverlayEditor'],
		markup: ['insertFile', 'cbWysiwyg', 'cbMarkup', 'cbPreview', 'cbMakeDefault', 'cbOverlayEditor', 'cbEditorFormat', 'cbWikiHelp'],
		preview: ['cbWysiwyg', 'cbMarkup', 'cbPreview', 'cbOverlayEditor', 'cbWikiHelp']
	}

	var buttonsForNonWikiFormats = ['insertFile', 'cbMarkup', 'cbOverlayEditor', 'cbEditorFormat', 'cbWikiHelp'];

	// buttons for subtoolbars
	var buttonsForToolbars = {
		cbFormattingOptions: ['bold', 'italic', 'underline', 'strikeThrough', 'cbMonospace', 'paragraphFormat', 'cbColorBackground', 'cbColorText', 'formatUL', 'formatOL', 'outdent', 'indent', 'cbPasteAsText', 'clearFormatting', 'undo', 'redo'],
		cbAdvancedOptions: ['insertTable', 'cbCreateRelatedIssue', 'cbWikiMarkup', 'cbMxGraph'],
		cbLinkOptions: ['cbInsertLink', 'cbWikiLink', 'cbRemoveLink'],
		cbWysiwygOptions: ['cbWysiwyg', 'cbMarkup', 'cbPreview', 'cbMakeDefault', 'cbWikiHelp']
	}

	var exludedButtons = ['cbCancel', 'cbSave'];

	var iconsWithTexts = {
		cbInsertLinkIcon: { ICON: 'link', NAME: i18n.message('wysiwyg.link') },
		cbRemoveLinkIcon: { ICON: 'unlink', NAME: i18n.message('wysiwyg.unlink') },
		cbIconHistoryLinkIcon: { ICON: 'history', NAME: i18n.message('wysiwyg.history.link.plugin.wikiLink') },

		cbWysiwygIcon: { ICON: 'file-text', NAME: i18n.message('wysiwyg.compact.layout.wysiwyg.tooltip') },
		cbMarkupIcon: { ICON: 'code', NAME: i18n.message('wysiwyg.compact.layout.markup.tooltip') },
		cbPreviewIcon: { ICON: 'eye', NAME: i18n.message('wysiwyg.compact.layout.preview.tooltip') }
	};

	var icons = {
		cbLinkOptionsIcon: { NAME: 'link' },
		cbEditorFormatIcon: { NAME: 'list-alt' },
		cbEmoticonsIcon: { NAME: 'smile-o' },
		cbFormattingOptionsIcon: { NAME: 'font' },
		cbAdvancedOptionsIcon: { NAME: 'pencil-square-o' },
		cbWysiwygOptionsIcon: { NAME: 'desktop' },
		insertFile: { NAME: 'upload' },
		cbMonospaceIcon: { NAME: 'text-width' },
		cbCreateRelatedIssueIcon: { NAME: 'plus' },
		cbWikiMarkupIcon: { NAME: 'file-code-o' },
		cbWikiMarkupPreformattedIcon: { NAME: 'file-code-o' },
		cbMxGraphIcon: { NAME: 'code-fork' },
		cbWikiMarkupInformationIcon: { NAME: 'info-circle' },
		cbWikiMarkupWarningIcon: { NAME: 'warning' },
		cbWikiMarkupErrorIcon: { NAME: 'exclamation' },
		cbHorizontalLineIcon: { NAME: 'minus' },
		cbImageAttachmentIcon: { NAME: 'file-image-o' },
		cbTableOfContentsIcon: { NAME: 'file-text-o' },
		cbMxGraphNewIcon: { NAME: 'plus' },
		cbMxGraphDocumentIcon: { NAME: 'code-fork'},
		cbPasteAsText: { NAME: 'paste' },
		cbWikiHelpIcon: { NAME: 'question-circle' }
	}

	var formatMapping = {
		W: 'wiki',
		'': 'plain',
		H: 'html'
	};

	var imagePath = contextPath + '/images/newskin/wysiwyg/';

	var inited = false;

	function initToolbarsAndButtons() {
		if (!inited) {
			// init mode switcher buttons
			_createWysiwygButton();
			_createMarkupButton();
			_createPreviewButton();
			_createMakeDefaultButton();
			_createWikiHelpButton();

			_createWikiMarkupButton();
			_createRelatedIssueButton();
			_createMxGraphButton();

			_createLinkButton();
			_createRemoveLinkButton();
			_createWikiLinkButton();

			_createEditorFormatButton();
			_createEmoticonsButton();
			_createPasteAsTextButton();
			_createMonospaceButton();

			_createOverlayButton();

			_initIcons();

			_initSubToolbars();

			codebeamer.WysiwygShortcuts.registerIndent();
			codebeamer.WysiwygShortcuts.registerOutdent();
			codebeamer.WysiwygShortcuts.registerListShortCuts();
			
			inited = true;
		}
	}

	function _defineIcons(icons, template) {
		$.each(icons, function(icon, config) {
			if (template) {
				config.template = template;
			}

			if (config.hasOwnProperty('SRC')) {
				config.SRC = imagePath + config.SRC;
			}
			$.FroalaEditor.DefineIcon(icon, config);
		});
	};

	function _initIcons() {
		$.FroalaEditor.DefineIconTemplate('cbIconWithText', '<i class="fa fa-[ICON]"></i><span class="cb-editor-button-name">[NAME]</span>');

		// redefine image template to support ALT text with multiple words
		$.FroalaEditor.DefineIconTemplate('image', '<img src=[SRC] alt="[ALT]" />');

		_defineIcons(icons)
		_defineIcons(iconsWithTexts, 'cbIconWithText');

		$.FroalaEditor.DefineIcon('cbMakeDefaultIcon', { NAME: i18n.message('wiki.wysiwyg.set.default.mode.label'), template: 'text' });
	}

	function switchMode(editor, mode) {
		var useFormatSelector = editor.$oel.data('useFormatSelector');

		mode = mode || 'wysiwyg';

		// update main toolbar
		editor.$tb.children('button').each(function() {
			var $button = $(this),
				toggleFn = buttonsForModes[mode].indexOf($button.data('cmd')) == -1 ? 'hide' : 'show';

			if (exludedButtons.indexOf($button.data('cmd')) == -1) {
				$button[toggleFn]();
			}

			if (!useFormatSelector && $button.data('cmd') == 'cbEditorFormat') {
				$button.hide();
			}
		});

		var isOverlayActive = $.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor),
			$textarea = editor.$oel.detach();

		if (mode == 'markup' && !isOverlayActive) {
			var height = editor.$wp.height() + 2;

			if ($textarea.data('useAutoSize')) {
				$textarea.css('min-height', height);
			} else {
				$textarea.css('height', height);
			}
		}

		if (mode == 'markup') {
			editor.$box.prepend($textarea);
		} else {
			$textarea.insertAfter(editor.$box);
		}

		if (isOverlayActive) {
			editor.$box.find('.overlay-header').detach().prependTo(editor.$box);
		}

		editor.$box.closest('.editor-wrapper')
			.removeClass('wysiwyg markup preview')
			.addClass(mode)
			.data('editorMode', mode);

		if ($textarea.data('resizeEditorToFillParent')) {
			codebeamer.WYSIWYG.resizeEditorToFillParent(editor);
		}

		if (mode == 'markup' && $textarea.data('useAutoSize')) {
			$textarea.trigger('autosize.resizeIncludeStyle');
		}

		hideOpenPopups(editor);

		_updateWysiwygOptionsButtons(editor, mode);

		editor.position.refresh();
	}

	function _updateMakeDefaultButton(editor) {
		var editorMode = codebeamer.WYSIWYG.getEditorMode(editor.$oel),
			defaultEditorMode = codebeamer.WYSIWYG.getDefaultEditorMode(editor.$oel),
			makeDefaultButton = editor.button.getButtons('button.fr-btn-text[data-cmd="cbMakeDefault"]');

		makeDefaultButton[editorMode == defaultEditorMode ? 'addClass' : 'removeClass']('fr-disabled');
	}

	function _updateWysiwygOptionsButtons(editor, mode) {
		var	$buttons = editor.button.getButtons('button.fr-btn-cbIconWithText');

		$buttons.removeClass('cb-button-active');

		$buttons.filter(function(index, button) {
			return ($(button).data('cmd') || '').toLowerCase().indexOf(mode) != -1
		}).addClass('cb-button-active');

		_updateMakeDefaultButton(editor);
	}

	function _initHtmlAndPlainMode(editor, extraButtons) {
		var buttonsToShow = buttonsForNonWikiFormats;
		if (extraButtons && Array.isArray(extraButtons)) {
            buttonsToShow = extraButtons.concat(buttonsForNonWikiFormats);
		}

        var useFormatSelector = editor.$oel.data('useFormatSelector');
		if (!useFormatSelector) {
			buttonsToShow.remove('cbEditorFormat');
		}

		editor.$tb.children('button').each(function() {
			var $button = $(this),
				toggleFn = buttonsToShow.indexOf($button.data('cmd')) == -1 ? 'hide' : 'show';

			$button[toggleFn]();
		});
	}

	function getButtonsForMode(mode) {
		return buttonsForModes[mode];
	}

	function getMainToolbarButtons() {
		return mainToolbarButtons.slice();
	}

	function _createOverlayButton() {
		var editorHeight, toolbarBottom;

		$.FroalaEditor.RegisterCommand('cbOverlayEditor', {
			title: i18n.message('wysiwyg.wiki.overlay.edit.title'),
			icon: 'fullscreen',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				// Also contains some code from fullscreen.js, the original Froala plugin for fullscreen mode
				var $wrapper, $parentNode, oldScroll, self;

				$wrapper = this.$oel.closest('.editor-wrapper');
			    $parentNode = this.$box.parent();
			    self = this;

				if ($wrapper.hasClass('fr-modal')) {
					$wrapper.find(".overlay-header").remove();
					// Remove additional calsses
					$wrapper.removeClass('fr-modal').removeClass('fr-active').removeClass('fr-fake-popup-editor');

					// Restore editor height
					if (editorHeight) {
						this.opts.height = editorHeight;
					} else {
						this.opts.height = null;
					}

					// Restore autoresize on markup field
				    if (this.$oel.data('useAutoSize')) {
						this.$oel.autosize();
				    }

				    // Restore the toolbar position
				    this.opts.toolbarBottom = toolbarBottom;

				    // Refresh editor
				    this.size.refresh();

				    $(this.o_win).scrollTop(oldScroll)

				    // Restore original z-index and overflow for all parents
				    while (!$parentNode.is('body:first')) {

				    	if ($parentNode.data('z-index')) {
				    		$parentNode.css('z-index', '');

				    		if ($parentNode.css('z-index') != $parentNode.data('z-index')) {
				    				$parentNode.css('z-index', $parentNode.data('z-index'));
				    		}

				    		$parentNode.removeData('z-index');
				    	}


				        if ($parentNode.data('overflow')) {
				        	$parentNode.css('overflow', '');

				        	if ($parentNode.css('overflow') != $parentNode.data('overflow')) {
				        		$parentNode.css('overflow', $parentNode.data('overflow'));
				        	}

				        	$parentNode.removeData('overflow');
				        } else {
				        	$parentNode.css('overflow', '');
				        	$parentNode.removeData('overflow');
				        }

				    	$parentNode = $parentNode.parent();
				    }

      				this.$win.trigger('scroll');

				    // Document view fix
				    $wrapper.find(".nested-summary").show();
				} else {
					this.$box.prepend('<div class="actionMenuBar overlay-header"><div class="actionMenuBarIcon" />' + this.opts.overlayHeader + '<a class="container-close"></a></div>');
					this.$box.find('.overlay-header').mouseenter(throttleWrapper(function() {
						self.selection.save();
					}, 200));
					this.$box.find('.container-close').click(function() {
						self.button.click(self.$box.find('button[data-cmd=cbOverlayEditor]'));
						self.selection.restore();
						self.$box.find('.overlay-header').off().remove();
					});

					// Add classes, so the editor looks like an editor popup
					$wrapper.addClass('fr-modal').addClass('fr-active').addClass('fr-fake-popup-editor');

					// Set the height like the fullscreen plugin
					editorHeight = this.opts.height;
				    this.opts.height = (this.o_win.innerHeight * 0.9) - 50 - (this.opts.toolbarInline ? 0 : this.$tb.outerHeight());

				    // Disable autosize on the markup field
				    if (this.$oel.data('useAutoSize')) {
						this.$oel.trigger('autosize.destroy');
				    }

				    // Move toolbar to the bottom
				    toolbarBottom = this.opts.toolbarBottom;
				    this.opts.toolbarBottom = true;

				    // Refresh the editor to render changes
				    this.size.refresh();

				    oldScroll = this.helpers.scrollTop();

				    // Fix for z-index, like in fullscreen
				    while (!$parentNode.is('body:first')) {

				    	if (!$parentNode.hasClass("editor-wrapper")) {
					        $parentNode
					          .data('z-index', $parentNode.css('z-index'))
					          .data('overflow', $parentNode.css('overflow'))
					          .css('z-index', '10000')
					          .css('overflow', 'visible');
				    	}

				        $parentNode = $parentNode.parent();
				      }

				    // Document view fix
				    $wrapper.find(".nested-summary").hide();

      				this.$win.trigger('scroll');
				}
			},
			isActive: function(editor) {
				return editor && editor.$oel && editor.$oel.closest('.editor-wrapper').hasClass('fr-modal');
			}
		});
	}

	function _createWikiMarkupButton() {
		$.FroalaEditor.RegisterCommand('cbWikiMarkup', {
			title: i18n.message('wysiwyg.wiki.markup.plugin.title'),
			type: "dropdown",
			icon: 'cbWikiMarkupIcon',
			undo: false,
			refreshAfterCallback: false,
			options: {
				"cbWikiMarkup": i18n.message('wysiwyg.wiki.markup.plugin.title'),
				"cbWikiMarkupInformation" : i18n.message('wysiwyg.wiki.markup.plugin.style.insert') + ' ' + i18n.message('wysiwyg.wiki.markup.plugin.style.Information'),
				"cbWikiMarkupWarning": i18n.message('wysiwyg.wiki.markup.plugin.style.insert') + ' ' + i18n.message('wysiwyg.wiki.markup.plugin.style.Warning'),
				"cbWikiMarkupError": i18n.message('wysiwyg.wiki.markup.plugin.style.insert') + ' ' + i18n.message('wysiwyg.wiki.markup.plugin.style.Error'),
				"cbWikiMarkupPreformatted": i18n.message('wysiwyg.wiki.markup.plugin.style.insert') + ' ' + i18n.message('wysiwyg.wiki.markup.plugin.style.Preformatted'),
				"cbHorizontalLine": i18n.message('wysiwyg.wiki.markup.plugin.horizontal.line.title'),
				"cbImageAttachment": i18n.message('wysiwyg.image.link.plugin.title'),
				"cbTableOfContents": i18n.message('wysiwyg.table.of.contents')
			},
		    html: function () {
		        var c = '<ul class="fr-dropdown-list" role="presentation">';
		        var options =  $.FE.COMMANDS.cbWikiMarkup.options;

		        for (var val in options) {
		          if (options.hasOwnProperty(val)) {
		            c += '<li role="presentation"><a class="fr-command fr-title icon-with-text" style="display: flex;" tabIndex="-1" role="option" data-cmd="cbWikiMarkup" data-param1="' + val + '" title="' + options[val] + '">' + this.icon.create(val + "Icon") + '<span>' + options[val] + '</span></a></li>';
		          }
		        }
		        c += '</ul>';

		        return c;
		    },
		    refreshOnShow: function($btn, $dropdown) {
		    	if ($btn.hasClass("toc-not-allowed")) {
		    		$dropdown.find("[data-param1=cbTableOfContents]").hide();
		    	} else {
		    		$dropdown.find("[data-param1=cbTableOfContents]").show();
		    	}

		    	this.popups.hide('table.insert');
		    },
			callback: function(cmd, val) {

				switch (val) {
					case "cbWikiMarkup": this.wikiMarkup.showModal();
					                     break;
					case "cbWikiMarkupInformation": this.wikiMarkup.showModal("Information");
					                                break;
					case "cbWikiMarkupWarning": this.wikiMarkup.showModal("Warning");
					                            break;
					case "cbWikiMarkupError": this.wikiMarkup.showModal("Error");
					                          break;
					case "cbWikiMarkupPreformatted": this.wikiMarkup.showModal("Preformatted");
                                                     break;
					case "cbHorizontalLine": this.commands.insertHR();
					                         break;
					case "cbImageAttachment": this.imageAttachment.showModal();
					                          break;
					case "cbTableOfContents": this.tableOfContents.insert();
					                          break;
				}

			}
		});
	}

	function _createRelatedIssueButton() {
		$.FroalaEditor.RegisterCommand('cbCreateRelatedIssue', {
			title: i18n.message('wysiwyg.create.related.issue.plugin.label'),
			icon: 'cbCreateRelatedIssueIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				this.cbCreateRelatedIssue.showModal();
			}
		});
	}

	function _createMxGraphButton() {
		$.FroalaEditor.RegisterCommand('cbMxGraph', {
			title: i18n.message('wysiwyg.mxgraph.editor.title'),
			type: "dropdown",
			icon: 'cbMxGraphIcon',
			undo: false,
			refreshAfterCallback: false,
			options: {
				"cbMxGraphNew": i18n.message('wysiwyg.mxgraph.editor.title'),
				"cbMxGraphDocument": i18n.message('wysiwyg.mxgraph.artifact.title')
			},
		    html: function () {
		        var c = '<ul class="fr-dropdown-list" role="presentation">';
		        var options =  $.FE.COMMANDS.cbMxGraph.options;

		        for (var val in options) {
		          if (options.hasOwnProperty(val)) {
		            c += '<li role="presentation"><a class="fr-command fr-title icon-with-text" style="display: flex;" tabIndex="-1" role="option" data-cmd="cbMxGraph" data-param1="' + val + '" title="' + options[val] + '">' + this.icon.create(val + "Icon") + '<span>' + options[val] + '</span></a></li>';
		          }
		        }
		        c += '</ul>';

		        return c;
		    },
		    refreshOnShow: function() {
		    	this.popups.hide('table.insert');
		    },
			callback: function(cmd, val) {

				switch (val) {
					case "cbMxGraphNew": this.mxgraph.showModal();
					                     break;
					case "cbMxGraphDocument": this.artifact.showModal();
					                          break;
				}

			}
		});
	}

	function _createLinkButton() {
		$.FE.RegisterShortcut($.FE.KEYCODE.J, 'cbInsertLink', null, 'J', false, false);
		$.FroalaEditor.RegisterCommand('cbInsertLink', {
			title: i18n.message('wysiwyg.link'),
			icon: 'cbInsertLinkIcon',
			undo: false,
			refreshAfterCallback: false,
			popup: true,
			focus: true,
			callback: function() {
				var editor = this instanceof $.FroalaEditor ? this : codebeamer.WysiwygShortcuts.getActualEditor();

				editor.selection.save();
				editor.commands.exec('insertLink');
			}
		});
	}

	function _createRemoveLinkButton() {
		$.FroalaEditor.RegisterCommand('cbRemoveLink', {
			title: i18n.message('wysiwyg.unlink'),
			icon: 'cbRemoveLinkIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				this.commands.exec('linkRemove');
			}
		});
	}

	function _createWikiLinkButton() {
		$.FroalaEditor.RegisterCommand('cbWikiLink', {
			title: i18n.message('wysiwyg.history.link.plugin.wikiLink'),
			icon: 'cbIconHistoryLinkIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				this.wikiLink.showModal();
			}
		});
	}

	function _createEditorFormatButton() {
		$.FroalaEditor.RegisterCommand('cbEditorFormat', {
			title: i18n.message('text.format.selector.tooltip'),
			type: 'dropdown',
			icon: 'cbEditorFormatIcon',
			undo: false,
			refreshAfterCallback: false,
			options: {
				wiki: i18n.message('text.format.wiki'),
				plain: i18n.message('text.format.flat'),
				html: i18n.message('text.format.html')
			},
			refreshOnShow: function($btn, $dropdown) {
				var selectedFormat = this.$oel.closest('.editor-wrapper').find('input[type=hidden]').val();

				hideOpenPopups(this);

				$dropdown.find('a[data-param1="' + formatMapping[selectedFormat] + '"]').addClass('fr-active');
			},
			callback: function(cmd, val) {
				updateToolbarForEditorFormat(this, val);
			}
		});
	}

	function _createEmoticonsButton() {
		$.FroalaEditor.RegisterCommand('cbEmoticons', {
			title: 'Emoticons',
			icon: 'cbEmoticonsIcon',
			undo: true,
			refreshAfterCallback: false,
			callback: function() {
				var $btn = this.$tb.find('.fr-command[data-cmd="cbEmoticons"]');

				if ($btn.hasClass('cb-button-active')) {
					this.cbEmoticons.hidePopup();
					$btn.removeClass('cb-button-active');
				} else {
					this.cbEmoticons.showPopup();
					$btn.addClass('cb-button-active');
				}
			}
		});
	}

	function _updatePasteAsTextButton($btn, isEnabled) {
		if (isEnabled) {
			$btn.find('i').css('color', '#5eceeb');
		} else {
			$btn.find('i').removeAttr('style');
		}

	}

	function _createPasteAsTextButton() {
		$.FroalaEditor.RegisterCommand('cbPasteAsText', {
			title: i18n.message('wysiwyg.pasteAsText.plugin.tooltip'),
			icon: 'cbPasteAsText',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				this.opts.pastePlain = !this.opts.pastePlain;

				_updatePasteAsTextButton(this.button.getButtons('button[data-cmd="cbPasteAsText"]'), this.opts.pastePlain);

				userSettings.save('WYSIWYG_PASTE_AS_TEXT', this.opts.pastePlain);

				codebeamer.WYSIWYG.updateInlineOptions({ pasteplain: this.opts.pastePlain });
			}
		});
	}

	function _createMonospaceButton() {
		$.FroalaEditor.RegisterCommand('cbMonospace', {
			title: 'Monospace',
			icon: 'cbMonospaceIcon',
			undo: true,
			toggle: true,
			refresh: function ($btn) {
				var format = this.format.is('tt');
				$btn.toggleClass('fr-active', format).attr('aria-pressed', format);
			},
			callback: function() {
				var text = this.selection.text() || '&#65279',
					$marker = $(this.markers.insert()),
					isNesting = $marker.closest('tt').length;

				if (!isNesting) {
					this.html.insert('<tt>' + text + '</tt>');
					$marker.remove();
				} else {
					$marker.unwrap().remove();
				}
			}
		});
	}

	// 'this' refers to the editor instance in command callback functions
	function _createWysiwygButton() {
		$.FroalaEditor.RegisterCommand('cbWysiwyg', {
			title: i18n.message('wysiwyg.compact.layout.wysiwyg.tooltip'),
			icon: 'cbWysiwygIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				var editorId = this.$oel.attr('id'),
					self = this;
				codebeamer.WYSIWYG.toggleConversionInProgress(this.$oel, true);

				var markupText = $.trim(self.$oel.val());
				self.$oel.data('oldMarkup', markupText);

				codebeamer.WikiConversion.wikiToHtml(markupText, editorId).then(function(result) {
					var html = result.content;
					self.html.set(html);

					codebeamer.WYSIWYG.toggleEditing(self.$el, true);

					switchMode(self, 'wysiwyg');
					self.$oel.removeClass('dirty');
					self.events.focus();
				}).always(function() {
					codebeamer.WYSIWYG.toggleConversionInProgress(self.$oel, false);
				});
			}
		});
	}

	function _createMarkupButton() {
		$.FroalaEditor.RegisterCommand('cbMarkup', {
			title: i18n.message('wysiwyg.compact.layout.markup.tooltip'),
			icon: 'cbMarkupIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				var editorId = this.$oel.attr('id'),
					self = this,
					promise = codebeamer.WYSIWYG.getEditorMode(this.$oel) == 'wysiwyg' ? codebeamer.WikiConversion.saveEditor(editorId) : $.when();

				codebeamer.WYSIWYG.toggleConversionInProgress(this.$oel, true);

				promise.then(function() {
					codebeamer.WYSIWYG.toggleEditing(self.$el, true);
					switchMode(self, 'markup');

					self.$oel.focus();
					self.$oel[0].setSelectionRange(0, 0);
					self.$oel.removeClass('dirty');
				}).always(function() {
					codebeamer.WYSIWYG.toggleConversionInProgress(self.$oel, false);
				});
			}
		});
	}

	function _createPreviewButton() {
		$.FroalaEditor.RegisterCommand('cbPreview', {
			title: i18n.message('wysiwyg.compact.layout.preview.tooltip'),
			icon: 'cbPreviewIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				var editorId = this.$oel.attr('id'),
					self = this,
					promise = codebeamer.WYSIWYG.getEditorMode(this.$oel) == 'wysiwyg' ? codebeamer.WikiConversion.saveEditor(editorId) : $.when();

				codebeamer.WYSIWYG.toggleConversionInProgress(this.$oel, true);

				promise.then(function() {
					codebeamer.WikiConversion.wikiToHtml(self.$oel.val(), editorId, true).then(function(result) {
						var previewHtml = result.content;
						self.$el.html(previewHtml);

						codebeamer.WYSIWYG.toggleEditing(self.$el, false);

						switchMode(self, 'preview');
        				self.$el.blur();
					}).always(function() {
						codebeamer.WYSIWYG.toggleConversionInProgress(self.$oel, false);
						initializeJSPWikiScripts();
					});
				});
			}
		});
	}

	function _createMakeDefaultButton() {
		$.FroalaEditor.RegisterCommand('cbMakeDefault', {
			title: i18n.message('wiki.wysiwyg.set.default.mode.label'),
			icon: 'cbMakeDefaultIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				var self = this;

				codebeamer.WYSIWYG.setDefaultEditorMode(self.$oel, function() {
					self.button.getButtons('button.fr-btn-text[data-cmd="cbMakeDefault"]').addClass('fr-disabled');

					codebeamer.WYSIWYG.updateInlineOptions({ mode: codebeamer.WYSIWYG.getEditorMode(self.$oel) });
					hideOpenPopups(self);
				});
			}
		});
	}

	function _createWikiHelpButton() {
		$.FroalaEditor.RegisterCommand('cbWikiHelp', {
			title: i18n.message('cb.wiki.help.title'),
			icon: 'cbWikiHelpIcon',
			undo: false,
			refreshAfterCallback: false,
			callback: function() {
				launch_url(contextPath + '/help/wiki.do', null);
			}
		});
	}

	function hideOpenPopups(editor, except) {
		var $popups = Object.keys(buttonsForToolbars).map(function(command) {
			return editor.popups.get(command + 'Toolbar.popup');
		});

		if (except != 'cbEmoticons.popup') {
			$popups.push(editor.popups.get('cbEmoticons.popup'));
		}

		if (except != 'file.insert') {
			$popups.push(editor.popups.get('file.insert'));
		}

		$.each($popups, function(index, $popup) {
			if ($popup) {
				$popup.removeClass('fr-active');

				if (editor.$tb) {
					var $btn = editor.$tb.find('.fr-command[data-cmd="' + $popup.data('command') + '"]');
					$btn.removeClass('cb-button-active');
				}
			}
		});
		if (except && !editor.$oel.data('disableFormattingOptionsOpening')) {
			window.localStorage.wysiwygFormattingOptionsVisible = false;
		}

		editor.position.refresh();
	}

	function _initSubToolbars() {
		$.each(buttonsForToolbars, function(command, buttonList) {
			var toolbarName = command + 'Toolbar',
				popupName = toolbarName + '.popup';

			// Define popup template
			$.FroalaEditor.POPUP_TEMPLATES[popupName] = '[_BUTTONS_]';

			// The custom popup is defined inside a plugin
			$.FroalaEditor.PLUGINS[toolbarName] = function(editor) {
				// do not let the toolbar to be closed
				editor.popups.onHide(popupName, function() {
					this.popups.get(popupName).addClass('fr-active' + (editor.opts.toolbarBottom ? ' fr-above' : ''));
				});

				function _updateAdvancedOptionsButtons() {
					var $relatedIssueBtn = editor.button.getButtons('button[data-cmd="cbCreateRelatedIssue"]'),
						$wikiMarkupBtn = editor.button.getButtons('button[data-cmd="cbWikiMarkup"]'),
						hasSelection = !!editor.selection.text().length,
						selection = editor.selection.get(),
						$node;

					$relatedIssueBtn[hasSelection ? 'removeClass' : 'addClass']('fr-disabled');
					$wikiMarkupBtn[hasSelection ? 'addClass' : 'removeClass']('fr-disabled');

					$node = $(selection.focusNode);

					if ($node.is("h1,h2,h3,h4,h5,a") || $node.parents().is("h1,h2,h3,h4,h5,a")) {
						$wikiMarkupBtn.addClass("toc-not-allowed");
					} else {
						$wikiMarkupBtn.removeClass("toc-not-allowed");
					}

				}

				// Create custom popup
				function initPopup() {
					// Popup buttons.
					var popup_buttons = '';

					if (command == 'cbWysiwygOptions' && editor.$oel.data('disablePreview')) {
						var index = buttonList.indexOf('cbPreview');
						if (index != -1) {
							buttonList.splice(index, 1);
						}
					}

					// Create the list of buttons
					popup_buttons += '<div class="fr-buttons">';
					popup_buttons += editor.button.buildList(buttonList);
					popup_buttons += '</div>';

					// Load popup template
					var template = {
						buttons: popup_buttons
					};

					// Create popup
					var $popup = editor.popups.create(popupName, template);
					$popup
						.attr('data-command', command)
						.addClass('cb-custom-popup');

					if (command == 'cbWysiwygOptions') {
						editor.button.getButtons('button[data-cmd="cbWysiwyg"]').addClass('cb-button-active');
						_updateMakeDefaultButton(editor);
					}

					// enable or disable the 'create related issue' and 'insert wiki markup' buttons based on selection changes in the editor
					if (command == 'cbAdvancedOptions') {
						editor.$oel.on('froalaEditor.keyup froalaEditor.mouseup', throttleWrapper(_updateAdvancedOptionsButtons, 300));
					}

					// init the paste as text button
					if (command == 'cbFormattingOptions') {
						_updatePasteAsTextButton(editor.button.getButtons('button[data-cmd="cbPasteAsText"]'), editor.opts.pastePlain);
					}

					return $popup;
				}

				// Show the popup
				function showPopup() {
					var $btn = editor.$tb.find('.fr-command[data-cmd="' + command + '"]'),
						$popup = editor.popups.get(popupName);

					// toggle the toolbar visibility when the command button clicked
					if (editor.popups.isVisible(popupName)) {
						$popup.removeClass('fr-active');
						$btn.removeClass('cb-button-active');

						if (command == 'cbFormattingOptions' && !editor.$oel.data('disableFormattingOptionsOpening')) {
							window.localStorage.wysiwygFormattingOptionsVisible = false;
						}
						return;
					}

					hideOpenPopups(editor, popupName);


					if (!$popup) {
						$popup = initPopup();
					}

					$btn.addClass('cb-button-active');

					editor.popups.setContainer(popupName, editor.$tb);

					if (command == 'cbFormattingOptions' && editor.$oel.data('hideUndoRedo')) {
						var toggleFn = $.FroalaEditor.COMMANDS.cbOverlayEditor.isActive(editor) ? 'show' : 'hide';
						editor.button.getButtons('button[data-cmd="undo"], button[data-cmd="redo"]')[toggleFn]();
					}

					if (codebeamer.WYSIWYG.isIE() && editor.opts.toolbarSticky) {
						editor.popups.show(popupName);
						$popup.css('top', -18);
					} else {
						var left = 0,
							top = $btn.offset().top	+ (editor.opts.toolbarBottom ? 10 : $btn.outerHeight() - 10);

						editor.popups.show(popupName, left, top, $btn.outerHeight());
					}

					if (command == 'cbAdvancedOptions') {
						_updateAdvancedOptionsButtons();
					}

					if (command == 'cbFormattingOptions' && !editor.$oel.data('disableFormattingOptionsOpening')) {
						window.localStorage.wysiwygFormattingOptionsVisible = true;
					}
				}

				// Hide the custom popup.
				function hidePopup() {
					editor.popups.hide(popupName);
				}
				
				// #1804445 - formatting options command shortcuts are not working before the subtoolbar is first displayed, 
				// so hacking this subtoolbar into the DOM before it is first shown
				if (toolbarName == 'cbFormattingOptionsToolbar') {
					var $popup = initPopup();
					
					$popup
						.data('container', editor.$tb)
						.data('instance', editor);
					
					editor.$tb.append($popup);
				}

				// Methods visible outside the plugin.
				return {
					showPopup : showPopup,
					hidePopup : hidePopup
				}
			}

			$.FroalaEditor.RegisterCommand(command, {
				title: i18n.message('wysiwyg.compact.layout.' + command + '.tooltip'),
				icon: command + 'Icon',
				undo: false,
				focus: true, // setting focus to true to fix the problem with sticky toolbar positions and popups on editor.focus
				plugin: toolbarName,
				callback: function() {
					this[toolbarName].showPopup();
				}
			});
		});
	}

	function initHidingEditorPopups(editor) {
		editor.popups.onShow('cbEmoticons.popup', function() {
			hideOpenPopups(editor, 'cbEmoticons.popup');
		});
		editor.popups.onShow('file.insert', function() {
			hideOpenPopups(editor, 'file.insert');
			editor.$tb.find('.fr-popup.fr-active').css({
				left: 10
			});
		});
		editor.popups.onShow('image.insert', function() {
			if (codebeamer.WYSIWYG.getEditorMode(editor.$oel) == 'markup') {
				$('.fr-popup.fr-active').css({
					top: editor.$oel.closest('.editor-wrapper').offset().top
				});
			}
		});
		editor.popups.onShow('link.insert', function() {
			hideOpenPopups(editor);
			editor.$tb.find('.fr-popup.fr-active').css({
				left: 10,
				top: editor.opts.toolbarBottom ? -134 : 18
			});
		});
		editor.popups.onShow('table.edit', function() {
			var $popup = editor.popups.get('table.edit'),
				offset = editor.$tb.find('.cb-custom-popup.fr-active').length ? 28 : 0; // using offset if any subtoolbar is displayed

			if ($popup[0].getBoundingClientRect().bottom > editor.$tb[0].getBoundingClientRect().top - offset) { // the popup overlaps the toolbar
				var selectedCells = editor.table.selectedCells(),
					topOffset = selectedCells.length ? $(selectedCells[0]).outerHeight() + $popup.outerHeight() : $popup.outerHeight();

				$popup
					.addClass('fr-above') // open the popup with 'above' style
					.css('top', parseInt($popup.css('top'), 10) - topOffset); // adjust the 'top' value
			}
		});
		editor.popups.onHide('cbEmoticons.popup', function() {
			var $btn = editor.$tb.find('.fr-command[data-cmd="cbEmoticons"]');
			$btn.removeClass('cb-button-active');
		});
	}

	function updateToolbarForEditorFormat(editor, format, extraButtons) {
		$.each(formatMapping, function(key, value) {
			if (value == format) {
				editor.$oel.closest('.editor-wrapper').find('input[type=hidden]').val(key);
			}
		});

		if (format != 'wiki') {
			editor.$oel.on('cbConversionEnd', function() {
				_initHtmlAndPlainMode(editor, extraButtons);
				editor.$oel.off('cbConversionEnd');
			});
			editor.commands.exec('cbMarkup');
		} else {
			editor.commands.exec('cbWysiwyg');
		}
	}

	return {
		initToolbarsAndButtons: initToolbarsAndButtons,
		getMainToolbarButtons: getMainToolbarButtons,
		getButtonsForMode: getButtonsForMode,
		switchMode: switchMode,
		initHidingEditorPopups: initHidingEditorPopups,
		updateToolbarForEditorFormat: updateToolbarForEditorFormat,
		formatMapping: formatMapping,
		hideOpenPopups: hideOpenPopups
	}
})(jQuery);
