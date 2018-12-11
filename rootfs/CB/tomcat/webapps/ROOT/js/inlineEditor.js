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
 */
var codebeamer = codebeamer || {};

(function () {
	"use strict";

	// TODO: this inlineEditor is not used anywhere, but eventually should be ????

	/**
	 * Inline editor which will make any element "editable" on the ui, by:
	 *
	 * * when the user double clicks on the element then the element is replaced with an iframe
	 * * the iframe must contain a page with "popup" sitemesh decoration
	 * * the iframe will have
	 *
	 * @param element The element which is going to be edited
	 * @param config The configuration argument
	 * @returns {codebeamer.inlineEditor}
	 */
	codebeamer.inlineEditor = function (element, config) {
		this.init(element, config);
	};

	codebeamer.inlineEditor.prototype =  {
		init: function(element, config) {
			var self = this;
			var defaults = {
					showOKCancelButtons: true
				};
			this.config = $.extend(defaults, config);
			this.element = element;
			element.inlineEditor = this;	// the inline-editor is accessible on the element being edited

			// mark the element (visually also) as editable
			$(this.element).addClass("editable");

			// double click starts editing
			$(this.element).dblclick(function(e) {
				var $editable = $(this).closest(".editable");
				if($editable.hasClass("edited")) {
					// already being edited
					return;
				}

				self.startEditing();
			});
		},

		// called when starting the editing
		startEditing: function() {
			var $editable = $(this.element);
			// mark as it is being edited
			$editable.addClass("edited");
			// save the old html
			this.oldHtml = $editable.html();

			this.initEditor();
		},

		// build the html for editor, this html will be used when the element is being edited
		// @return The html fragment will be used as editor
		getEditorHtml: function() {
			return "Editing...<input type='text'>blahblah</input>";
		},

		// replaces element being edited with an editor
		initEditor: function() {
			var self = this;
			var $editable = $(this.element);
			var editorHtml = this.getEditorHtml();
			if (this.config.showOKCancelButtons) {
				var okCancelHtml = '<div class="okcancel"><button type="button" class="button">'
					+i18n.message('button.save') + '</button> <a onclick="return false;" href="#">' + i18n.message('button.cancel') + '</a></div>';
				editorHtml += okCancelHtml;
			}
			$editable.html(editorHtml);

			if (this.config.showOKCancelButtons) {
				$editable.find(".okcancel button").click(function(e) {
					self.onOKPressed(this);
				});
				$editable.find(".okcancel a").click(function(e) {
					self.onCancelPressed(this);
				});
			}
		},

		onOKPressed: function() {
			var resultHtml = this.saveChanges();
			this.stopEditing(resultHtml);
		},

		onCancelPressed: function() {
			this.cancelEditing();
		},

		/**
		 * Callback to save changes
		 * @returns {String} The html to be shown in the edited are as the result of the save. If null returned then the original content is restored.
		 */
		saveChanges:function() {
			return "alma";
		},

		// stops editing the element and if cancelled restores the original content
		// @param newHtmlContent The new html content. Use null for "cancelling" edit when original html content is restored.
		stopEditing: function(newHtmlContent) {
			var $editable = $(this.element);
			$editable.html(newHtmlContent ? newHtmlContent : this.oldHtml);
			$editable.removeClass("edited");
			if (newHtmlContent != null) {
				// there is some new content, flash it so user can spot that this has changed
				flashChanged($editable);
			}
		},

		cancelEditing: function() {
			this.stopEditing(null);
		}

	};

}());

(function () {
	"use strict";

	codebeamer.wikiSectionEditor = function(element, wikiPageId, sectionTitle, sectionNo) {
		this.element = element;
		this.wikiPageId = wikiPageId;
		this.sectionTitle = sectionTitle;
		this.sectionNo = sectionNo;
		this.lockActive = false;

		var self = this;

		$(window).on("beforeunload", function(e){
			self._releaseLock();
		});
	};

	codebeamer.wikiSectionEditor.prototype = {

			_releaseLock : function(){
				var self = this;

				var openedEditorCount = $(".sectionEditable .edited").size();

				if (this.lockActive && openedEditorCount == 1) {
					$.ajax({
					    url: contextPath + '/ajax/wiki/releaseLock.spr?wikiId=' + self.wikiPageId,
					    type: 'GET',
					    dataType: "jsonp",
					    async: false,
					    success: function() {
					   	 	self.lockActive = false;
					    }
					});
				}
			},

			_isSectionStartElement: function (element) {
				var id = $(element).attr("id");
				if (id && id.indexOf("section-") == 0) {
					return true;
				}
				return false;
			},

			/**
			 * Extract the level of the section, i.e. it should be "4" for a H4 tag
			 * @param element
			 * @returns an integer level extracted from the tag name
			 */
			_extractSectionLevel: function(element) {
				try {
					var sectionTagName = $(element).prop("tagName");
					if (! sectionTagName) {
						return 0;
					}
					var extractLevel = new RegExp("\\d+");	// extract digits from tag name like "H2"
					var level = extractLevel.exec(sectionTagName);
					return parseInt(level[0]);
				} catch (e) {
					console.log("_extractSectionLevel error:" + e);
				}
				return 0;
			},

			_collectUntilNextSection: function(element, sectionLevel, sectionElements, goDeeper) {
				var self = this;
				if (this._isSectionStartElement(element)) {
					// if the start element is a <H3/> tag then the section only ends if there is an other H3 or H2 ... tag coming
					var level = this._extractSectionLevel(element);
					if (level <= sectionLevel) {
						return true;	// found next section, stop iteration
					}
				}
				if (goDeeper) {
					// because JSPWiki does not generate perfect html: the next-section can be somewhere BELOW! (in the child) dom tree.
					// must walk the children too !
					var stop = false;
					$(element).find('*').each(function() {
						stop = self._collectUntilNextSection(this, sectionLevel, sectionElements, false);
						if (stop) {
							return false;
						}
					});
					if (stop) {
						return true;
					}
				}

				sectionElements.push(element);
				return false;
			},

			/**
			 * Find the section elements.
			 * @param element One of the DOM elements of the section
			 * @return An array for the elements found, in the order they are in the DOM. The first elemenent is the section's start element
			 */
			_findSectionElements: function(element, recursive) {
				var self = this;
				var sectionElements = new Array();

				var sectionStartElem;
				if (this._isSectionStartElement(element)) {
					sectionStartElem = element;
				} else {
					sectionStartElem = $(element).closest('[id^="section-"]');	// find the closest parent element 'id="secton-"..., this is the start of the section
				}
				if (sectionStartElem == null) {
					console.log("Can not find section start in DOM tree for " + element);
					return sectionElements;
				}
				// collect the elements of the section: which is everything on the same level (siblings) on the DOM
				// after the start element and until the start of the next section
				var sectionLevel = this._extractSectionLevel(sectionStartElem);
				var sectionStartElemUnwrapped = $(sectionStartElem).get(0); // unwrap element if this is a jquery wrapped element
				sectionElements.push(sectionStartElemUnwrapped);

				var foundFirstElement = false;
				$(sectionStartElem).parent().contents().each(function() {
					var el = this;
					if (el == sectionStartElemUnwrapped) {
						foundFirstElement = true;
					} else {
						if (foundFirstElement) {
							// if this is a text-node then wrap it to a <span> so we can hide it by adding a CSS class to that. The text-nodes can not have CSS classes
							if (el.nodeType == 3) {
								$(el).wrap('<span></span>');
								el = $(el).parent();
							} else {
								// check if this is the start of the next section, and stop if so
								if (self._collectUntilNextSection(el, sectionLevel, sectionElements, recursive)) {
									return false;
								};
							}
							sectionElements.push(el);
						};
					}
				});
				return sectionElements;
			},

			/**
			 * Add new wysiwyg editor for editing section
			 * @param $sectionHeader
			 * @param sectionElements The (hidden) elements of the section being edited
			 * @param wikiContent
			 * @returns The id of the wywiwyg editor
			 */
			_addWikiSectionEditor: function($sectionHeader, sectionElements, wikiContent) {
				this.editorContainer = document.createElement('div');

				var $editorContainer = $(this.editorContainer),
					$inlineEditor = codebeamer.WYSIWYG.createInlineEditorTextarea(wikiContent),
					newEditorId = $inlineEditor.attr('id'),
					self = this;

				$sectionHeader.before($editorContainer);
				$editorContainer.append($inlineEditor);
				$editorContainer
					.attr('id', 'containerId' + newEditorId.replace('editorTA-', ''))
					.addClass('wikiSectionEditor edited editor-wrapper');

				$inlineEditor.on('saveChanges', function() {
					var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);
					editor.toolbar.disable();
					self._saveEditing(newEditorId, sectionElements);
				});

				$inlineEditor.on('cancelEditing', function() {
					var editor = codebeamer.WYSIWYG.getEditorInstance(newEditorId);

					editor.toolbar.disable();
					codebeamer.EditorFileList.removeAllFiles(editor.$oel).then(function() {
						editor.destroy();
						self._cancelEditing(newEditorId, sectionElements);
						autoAdjustPanesHeight();
					});
				});

				var options = {
					heightMin: 200,
					toolbarBottom: false,
					toolbarContainer: '#toolbarContainer',
					toolbarSticky: false
				};

				var additionalOptions = {
					save: function() {
						this.$oel.trigger('saveChanges');
					},
					cancel: function() {
						this.$oel.trigger('cancelEditing');
					},
				    uploadConversationId: this._getUploadConversationId(),
				    insertNonImageAttachments: true,
				    useAutoResize: true,
				    focus: true,
				    overlayHeader: i18n.message('wysiwyg.wiki.section.overlay.header'),
				    ignorePreviouslyUploadedFiles: true
				}

				codebeamer.WikiConversion.bindEditorToEntity(newEditorId, '[WIKIPAGE:' + this.wikiPageId + ']');
				codebeamer.WYSIWYG.initEditor(newEditorId, options, additionalOptions, true);

				return newEditorId;
			},

			_getUploadConversationId: function() {
				return "upload-for-section-" + this.wikiPageId +"-" + this.sectionTitle + "-" + this.sectionNo;
			},

			_buildAjaxRequestData: function(data) {
				var def = {
					"doc_id"  : this.wikiPageId,
					"section" : this.sectionTitle,
					"sectionNo" : this.sectionNo
				};
				var result = $.extend(def, data);
				return result;
			},

			_saveEditing: function(editorId, sectionElements) {
				var self = this,
					$textarea = $('#' + editorId),
					editorInstance = codebeamer.WYSIWYG.getEditorInstance(editorId),
					promise = codebeamer.WYSIWYG.getEditorMode($textarea) == 'wysiwyg' ? codebeamer.WikiConversion.saveEditor(editorId) : $.when();

				promise.then(function() {
					var modifiedWiki = $textarea.val();

					$.ajax({
						type: "POST",
						url: contextPath + "/ajax/wiki/updateWikiContent.spr",
						data: self._buildAjaxRequestData({
							pageContent: modifiedWiki,
							uploadConversationId: self._getUploadConversationId()
						}),
						dataType: "json",
						success: function(data) {
							// restore view
							editorInstance.destroy();

							var updatedContent = data.content;
							// console.log("updating wiki section content:" + data.content);

							var newContentElement = self._finishEditingAndUpdate(sectionElements, updatedContent);
							if (newContentElement) {
								codebeamer.initializeInlineSectionEditing(self.wikiPageId, true, newContentElement);
							}
							autoAdjustPanesHeight();
						},
						error: function(jqXHR, textStatus, errorThrown, a, b, c, d, e, f) {
							// TODO: better handling of errors ?
							if (jqXHR.status != 401) {	// the "unauthorized response will automatically redirect to the login page, so don't show that error
								alert(i18n.message("wiki.section.edit.error", errorThrown));
							}
						}
					});
				});

			},

			// get the section structure below in the section elements
			// @return the array of ["h3","h4"] which flattens the tree structure of the sections
			_getSectionLevelStructure: function(sectionElements) {
				var self = this;
				var sections = [];
				$(sectionElements).each(function(){
						try {
							var tn = $(this).prop("tagName").toLowerCase();
							if (tn.indexOf("h") == 0) {
								sections.push(tn);
							}
						} catch (ignored) {
						}

						// go deeper recursively to find the next h5/h4/h3/h2/h1
						var sub = self._getSectionLevelStructure($(this).children());
						for (var i=0; i<sub.length; i++) {
							sections.push(sub[i]);
						}
				});
				return sections;
			},

			/**
			 * compute if the old and new section structure is different so pare reload is necessary?
			 * @param oldStructure Array of section elements like [h3,h4] in the old structure
			 * @param newStructure
			 */
			_isSectionStructureDifferent: function(oldStructure, newStructure) {
				console.log("Comparing old section structure and new:" + oldStructure.join(",") + " -> " + newStructure.join(","));
				var oldElem = null;
				for (var i=0; i< newStructure.length; i++) {
					var newElem = newStructure[i];
					if (i < oldStructure.length) {
						oldElem = oldStructure[i];
					}

					if (newElem != oldElem) {
						// structure changed.
						// also checks If the new-structure contains new elements which are on the same level as the last of the old structure, that is fine!
						return true;
					}
				}
				return false;
			},

			/**
			 * When the wiki section structure becomes "corrupted" and page reload needed then mark the structure as dirty,
			 * and then reload when the last editing is complete
			 *
			 * @return if the page is reloaded
			 */
			_markSectionStructureDirty:function(dirty) {
				$("#rightPane").toggleClass("sectionStructureDirty", dirty);
				return codebeamer.wikiSectionEditor.prototype._reloadWikiPageDisplayedIfStructureDirty();
			},

			_isSectionStructureDirty:function() {
				var dirty = $("#rightPane").hasClass("sectionStructureDirty");
				return dirty;
			},

			// @return if the page is reloaded
			_reloadWikiPageDisplayedIfStructureDirty:function() {
				if (codebeamer.wikiSectionEditor.prototype._isSectionStructureDirty()) {
					// if there is still an other section is being edited then don't reload
					if ($(".edited").length > 0) {
						console.log("An other section is being edited, can not reload!");
					} else {
						console.log("Reloading wiki content, because section structure is dirty");
						reloadWikiPageDisplayed();
						return true;
					}
				}
				return false;
			},

			_finishEditingAndUpdate: function(sectionElements, newContent) {
				// replace the editor with the new content
				var $unwrappedNewContent = $(newContent).children().unwrap(),  // removing wrapping 'wikiContent' span from newContent
					$wrapper = $('<div></div>');

				$wrapper.append($unwrappedNewContent);
				$(this.editorContainer).parent().replaceWith($wrapper);
				// can not $.chain!
				flashChanged($wrapper, undefined, function() {
					$wrapper.children().unwrap();
				});

				var sectionStructureDirty = false;
				try {
					// check if the section's strcuture has been changed for example from h3->h4, which makes the current DOM structure invalid, and requires reload
					var newSectionStructure = this._getSectionLevelStructure($wrapper);
					var oldSectionStructure = this._getSectionLevelStructure(sectionElements);
					sectionStructureDirty = this._isSectionStructureDifferent(oldSectionStructure, newSectionStructure);
				} catch (ex) {
					console.log("Change detection failed:" + ex);
					this._markSectionStructureDirty(true);
				}

				this._finished();

				//remove the previous wiki section content from the DOM
				$(sectionElements).each(function() { // not using chain, because it's not removing all elements then
					$(this).empty().remove(); // faster than just removing, according to the jquery docs
				});

				if (sectionStructureDirty) {
					// must be after the sectionElements are removed otherwise this will think that there is an other section being edited, and can not reload
					var pageReloaded = this._markSectionStructureDirty(sectionStructureDirty);
					if (pageReloaded) {
						return null; // no need to do anything because the page will be reloaded
					}
				}

				codebeamer.renderSectionNumberHierarchy();

				return $wrapper;
			},

			_cancelEditing: function(editorId, sectionElements) {
				// show the edited elements
				this._setSectionElementsVisible(sectionElements, true);

				this._finished();
			},

			_correctViewPortIfRequired: function(containerId) {
				// contruct a selector for the newly opened section editor
				var sectionEditorSelector = "#containerId" + containerId.replace("editorTA-","");
				var editorElement = $(sectionEditorSelector)[0];

				if (!this._isElementInViewport(editorElement)){
					// if it is not in the window
					editorElement.scrollIntoView(true);
				}
			},

			_isElementInViewport: function(el) {
			    var rect = el.getBoundingClientRect();
			    var scrollingViewPort = $("#rightPane")[0].getBoundingClientRect();

			   	return !(scrollingViewPort.left > rect.right ||
			    		scrollingViewPort.right < rect.left ||
			    		scrollingViewPort.top > rect.bottom ||
			    		scrollingViewPort.bottom < rect.top);
			},

			_finished: function() {
				var $editableSection = $(this.element).closest('.sectionEditable');

				$editableSection.removeClass("edited highlighted");

				// release lock
				this._releaseLock();

				// remove the editor
				$(this.editorContainer).remove();

				// reload if necessary
				codebeamer.wikiSectionEditor.prototype._reloadWikiPageDisplayedIfStructureDirty();
			},

			_setSectionElementsVisible: function(sectionElements, visible) {
				// hide section elements for editing
				$(sectionElements).toggleClass("hiddenForEditing", !visible);
			},

			/**
			 * Edit a wiki page's section
			 * @param element The (sub)-element of the wiki section being edited
			 */
			editWikiSection: function() {
				var self = this;

				if (codebeamer.wikiSectionEditor.prototype._isSectionStructureDirty()) {
					alert(i18n.message("wiki.section.edit.dirty"));
					return false;
				}

				try {
					var sectionElements = this._findSectionElements(this.element, true);

					// create a clone of the section-header and display while editing
					var $sectionHeader = $(sectionElements[0]);

					$.ajax({
						url: contextPath + "/ajax/wiki/getWikiContent.spr",
						data: self._buildAjaxRequestData({}),
						success: function(data) {
							try {

								// check server side permission or locking error
								if (data.error){

									// remove edited class from the editable section
									// otherwise the current section cannot be edited anymore
									var $editableSection = $sectionHeader.parent();
									if ($editableSection && $editableSection.hasClass("edited")){
										$editableSection.removeClass("edited");
									}

									// warn the user and return - not start the editing
									alert(data.error);
									return;
								}

								self.lockActive = true;

								var wikiContent = data.content;
								if (wikiContent == null) {
									self._onWikiSectionNotFound();
									return;
								}

								var componentId = self._addWikiSectionEditor($sectionHeader, sectionElements, wikiContent);

								// hide section elements for editing
								// note: only hidden after the editor is shown to avoid page jumps
								self._setSectionElementsVisible(sectionElements, false);

								// correct viewport if it is required
								self._correctViewPortIfRequired(componentId);

								$(self.element).closest('.editsection').data('editor', self);
							} catch (ex) {
								console.log("error adding wiki editor" + ex);
							}
						},
						error: function (jqXHR, textStatus, errorThrown) {
							if (jqXHR.status == 404) {
								self._onWikiSectionNotFound();
							} else {
								if (jqXHR.status != 401) {	// the "unauthorized response will automatically redirect to the login page, so don't show that error
									alert(i18n.message("wiki.section.edit.error", errorThrown));
								}
							}
						}
					});
				} catch (ex) {
					console.log("error finding section " + ex);
				}
			},

			_onWikiSectionNotFound: function() {
				alert(i18n.message("wiki.section.edit.not.found"));
			}
	};

}());

/**
 * Functions for editing a wiki page or a section of it
 */
var wikiEditor = (function() {	// TODO: should become a proper js class and extends the inlineEditor above

	/**
	 * Function opens the editor for a wiki page or a section of it
	 * @param wikiPageId The id of the wiki page
	 * @param params Additional url parameters for editor like when editing a certain page revision
	 */
	var editWikiPage = function(wikiPageId, params) {
		var editUrl = contextPath + "/proj/wiki/editWikiPage.spr?doc_id=" + wikiPageId + "&overlay=true";
		if (params != null) {
			editUrl += "&" + params;
		}
		showPopupInline(editUrl, { geometry: 'large', isEditWikiInOverlay: true });
	};

	/**
	 * Edit a wiki page's section
	 * @param element The (sub)-element of the wiki section being edited
	 */
	var editWikiSection = function(element, wikiPageId, sectionTitle, sectionNo) {
		try {
			var editor = new codebeamer.wikiSectionEditor(element, wikiPageId, sectionTitle, sectionNo);
			editor.editWikiSection();
		} catch (ex) {
			console.log("error finding section " + ex);
		}
	};

	return {
		"editWikiPage": editWikiPage,
		"editWikiSection": editWikiSection
	};
})();

codebeamer.initializeInlineSectionEditing = function (wikiId, editable, rootElement) {
	$("#rightPane").unbind("wikiContentChanged").bind("wikiContentChanged", function() {
		// clear the dirty flag when a new wiki page is loaded to the right
		codebeamer.wikiSectionEditor.prototype._markSectionStructureDirty(false);
		codebeamer.renderSectionNumberHierarchy();
	});
	if (editable) {
		$("body").removeClass("sectionEditingInitialized");

		try {
			$(".editsection").each(function (i) {
				var t = $(this);
				var el = $($(this).children()[0]);
				var text = t.parent().text();
				text = text.slice(text.indexOf("]") + 1);
				var editor = new codebeamer.wikiSectionEditor(el, wikiId, text, i);
				$(editor._findSectionElements($(el)), false); // this will change the simple-text nodes as side effect
			});
		} catch (e) {}
		var domWalkTime = (new Date()).getTime();

		codebeamer.wrapAllSections(rootElement);
		var wrapAllSectionTime = (new Date()).getTime();

		codebeamer.initializeInlineSectionEditingEvents();
		var eventInittime = (new Date()).getTime();

		$("body").addClass("sectionEditingInitialized")
				 .trigger("sectionEditingInitialized"); // also fire an event when section editing is initialized

		// also add/remove a special css class when the page contains sections to adjust margins
		var containsSections = $("body .sectionEditable").length > 0;
		$("body").toggleClass("containsSections", containsSections);

		// the section may contain HTML -like tabs- which needs some js to work/look properly
		setTimeout(initializeJSPWikiScripts, 300);
	}

	codebeamer.renderSectionNumberHierarchy();
};

codebeamer.domWalk = function(node, levelNumbers){

	if (node && node.nodeType == 1) {

		var nodeName = node.nodeName.toLowerCase();

		if (node.id.indexOf("section-") === 0){
			for (i = 0; i < levelNumbers.length - 1; i++) {
				if (nodeName == ("h" + (i + 1))) {
					levelNumbers[i] += 1;
					for (j = i + 1; j < levelNumbers.length; j++){
						// reset sub levels
						levelNumbers[j] = 0;
					}
					codebeamer.updateLabelNumbering(node, i, levelNumbers);
				}
			}
		}
	}

	if (node) {
		node = node.firstChild;
		while (node) {
			codebeamer.domWalk(node, levelNumbers);
			node = node.nextSibling;
		}
	}
}

codebeamer.updateLabelNumbering = function(node, level, levelNumbers){

	var numbering = "";
	for (i = 0; i < level + 1; i++) {
		if (numbering) {
			numbering += ".";
		}
		if (levelNumbers[i] == 0){
			levelNumbers[i] = 1;
		}
		numbering += "" + levelNumbers[i];
	}


	var span = $(node).find("span.numbering").first();
	if (span.length == 0) {
		$(node).prepend("<span class='numbering'>" + numbering + "</span>");
	} else {
		span.text(numbering);
	}
}

codebeamer.sectionNumberHierarchyEnabled = false;

codebeamer.renderSectionNumberHierarchy = function() {
	if (codebeamer.sectionNumberHierarchyEnabled){
		codebeamer.domWalk($("#pagecontent")[0],  [0, 0, 0, 0, 0, 0]);
	}
};

codebeamer.initializeInlineSectionEditingEvents = function() {
	var cssSectionEditable="sectionEditable";
	var $pageContent = $("#pagecontent");
	// bind handlers if not yet bound
	if ($pageContent.data("eventsBound") == null) {
		$pageContent.data("eventsBound", true);

		// using event propagation to bind the click handler only once!
		var startEditingHandler = function(evt) {
			var $clickedOn = $(evt.target);
			// check if the click was happening inside a section which is being edited ?
			var closestEditor = $clickedOn.closest(".wikiSectionEditor");
			if (closestEditor.length > 0) {
				// console.log("do nothing when double clicked inside the editor:" + $clickedOn);
				return;
			}

			var $sectionClicked = $clickedOn.closest("." + cssSectionEditable);
			if ($sectionClicked.length > 0) {
				// check if already editing a sub-section?
				var editorInside = $sectionClicked.find(".wikiSectionEditor");
				if (editorInside.length > 0) {
					console.log("already editing an inside section, editing is cancelled");
					return;
				}

				var startEditing = function() {
					if ($sectionClicked.is(".edited")) {
						console.log("section editing already initiated");
						return;
					}

					var $parentEdited = $sectionClicked.closest(".edited");
					if ($parentEdited.length > 0) {
						console.log("Parent of clicked is already being edited, skipping edit");
						return;
					}

					$sectionClicked.addClass("edited");
					console.log("Init editor for:" + $sectionClicked);

					var editsectionlink = $sectionClicked.find(".editsection").first().find(">a");
					editsectionlink.click();

					$sectionClicked.find('img.inplaceEditableIcon').remove();
					clearSelection();
				}
				// throttle double click so if quickly clicking won't cause problems
				throttle(startEditing);
			}
		};
		
		$pageContent.on('click', '.inplaceEditableIcon', startEditingHandler);
		if (codebeamer.userPreferences.doubleClickEditOnWikiSection) {
			$pageContent.on('dblclick', startEditingHandler);
		}

		var makeEditIconSticky = function() {
			var $highlightedSection = $('#wikiPageContent .sectionEditable.highlighted');

			if ($highlightedSection.length) {
				var $inplaceEditableIcon = $highlightedSection.find('.inplaceEditableIcon'),
					top = $highlightedSection.offset().top,
					HEADER_HEIGHT_OFFSET = 183,
					newTopValue = Math.abs(HEADER_HEIGHT_OFFSET - top);

				if (!$highlightedSection.hasClass('edited') && top < HEADER_HEIGHT_OFFSET && newTopValue < $highlightedSection.outerHeight()) {
					$inplaceEditableIcon.css({ top: newTopValue + 'px' });
				} else {
					$inplaceEditableIcon.css({ top: 0 });
				}
			}
		}

		$('#rightPane').on('scroll', function() {
			throttle(makeEditIconSticky, null, null, 50);
		});

		var throttleCounter = 0;
		var execCounter = 0;
		var CSS_HIGHLIGHTED = codebeamer.highlightForInplaceEditabilityCSSClass;
		var mouseOver = function() {
			execCounter++;
			var $elementOver = $(this.target);
			var $sectionOver = $elementOver.closest("." + cssSectionEditable);
			// console.log("executing mouse over:" + $sectionOver +", throttled " + execCounter + " of " + throttleCounter);

			var editedChildren = $sectionOver.children(".hiddenForEditing");
			// remove all other highlighted sections
			$("." + CSS_HIGHLIGHTED).not($sectionOver).each(function(){
				$(this).removeClass(CSS_HIGHLIGHTED);
				codebeamer.highlightWithInplaceEditableIcon(this, false);
			});

			if (!$sectionOver.hasClass(CSS_HIGHLIGHTED)) {
				$sectionOver.addClass(CSS_HIGHLIGHTED);
				if (!$sectionOver.hasClass('edited')) {
					codebeamer.highlightWithInplaceEditableIcon($sectionOver, true);
				} else {
					// if edited in overlay then remove 'highlighted' class
					if ($sectionOver.children('.editor-wrapper.fr-fake-popup-editor').length) {
						$sectionOver.removeClass(CSS_HIGHLIGHTED);
					}
				}
			}
			makeEditIconSticky();
		};
		var mouseLeave = function() {
			var $elementOver = $(this.target);
			var $sectionOver = $elementOver.closest("." + cssSectionEditable);
			$sectionOver.removeClass(CSS_HIGHLIGHTED);
			codebeamer.highlightWithInplaceEditableIcon($sectionOver, false);
		};

		var enableThrottling = true; // the mouse-over and leave events are fired very frequently, to avoid slow down executing them throttled
		var throttleTime = 50;  /* using a very short time to be reponsive*/
		//console.log("throttling mouse over:" + enableThrottling +":" + throttleTime +"ms");

		// use event propagation and throttling for mouse over events
		$pageContent.mouseover(function(event){
			throttleCounter ++;
			if (enableThrottling) {
				throttle(mouseOver, event, mouseOver, throttleTime);
			} else {
				mouseOver.call(event);
			}
		}).mouseleave(function(event){
			if (enableThrottling) {
				throttle(mouseLeave, event, mouseLeave, throttleTime);
			} else {
				mouseLeave.call(event);
			}
		});
	}

};

/**
 * This function wraps the content between two equal level header tag to a div and makes them highlighted on hover.
 */
codebeamer.wrapAllSections = function(rootElement) {
	rootElement = rootElement || '#pagecontent';

	var elementSelector = rootElement != '#pagecontent' ? '' : '>.wikiContent';

	var tagNames = ["h5", "h4", "h3", "h2", "h1"]; // ordering is important!

	var wrapper = "<div class='sectionEditable' />";

	var isTagHigherLevel = function(tag, tagToCompareTo) {
		var tagIndex = tagNames.indexOf(tag);
		var tagToCompareToIndex = tagNames.indexOf(tagToCompareTo);
		return (tagIndex >= 0) && (tagIndex > tagToCompareToIndex);
	};

	var wrapAllTags = function(tagNameToWrap) {
		var open = false;
		var elems = [];
		var childrenIncludingTextNodes = elementSelector.length ? $(rootElement).find(elementSelector).contents() : $(rootElement).contents();
		childrenIncludingTextNodes.each(function(index, el) {
			var isTextNode = !("tagName" in el);
			if (!isTextNode) {
				var tagName = el.tagName.toLowerCase();
				if (tagName === tagNameToWrap) {
					if (open) {
						$(elems).wrapAll(wrapper);
						elems = [];
					} else {
						open = true;
					}
					elems.push(el);
				} else if (isTagHigherLevel(tagName, tagNameToWrap)) {
					open = false;
					$(elems).wrapAll(wrapper);
					elems = [];
				} else {
					if (open) {
						elems.push(el);
					}
				}
			} else {
				if (open) {
					elems.push(el);
				}
			}
		});
		$(elems).wrapAll(wrapper);
	};

	$(tagNames).each(function(index, tagName) {
		wrapAllTags(tagName);
	});
};

$.extend(codebeamer, {
	highlightForInplaceEditabilityCSSClass: "highlighted" ,

	// see addHighlightWithInplaceEditableIcon below for parameters
	highlightWithInplaceEditableIcon: function(element, highlight, inplaceEditableIconPlaceHolderSelector) {
		var debug = false;
		var $element = $(element);

		// check if there is a placeholder for the inplaceEditableIcon, then add it there
		var $placeHolder = $element;
		if (inplaceEditableIconPlaceHolderSelector) {
			$placeHolder = $element.find(inplaceEditableIconPlaceHolderSelector).first();

			if ($placeHolder.length == 0) {
				$placeHolder = $element; // insert the icon directly to the highlighted element
			}
		}
		var $inplaceEditableIcon = $placeHolder.find(".inplaceEditableIcon");

		if (highlight) {
			// check if already highlighted?
			if ($inplaceEditableIcon.length > 0) {
				if (debug) {
					console.log("already highlighted!");
				}
				return;
			};

			if (debug) {
				console.log("highlighting " + element);
			}

			$placeHolder.prepend("<img class='inplaceEditableIcon' title='" + i18n.message('inline.editor.click.to.start.hint') + "' style='display:none;' src='" + contextPath +"/images/space.gif' />");
			$inplaceEditableIcon = $element.find(".inplaceEditableIcon");

			// check the width of the element, and make space for the icon if necessary by adding a special class to that
			$element.addClass("inplaceEditableIconContainer");

			$inplaceEditableIcon.fadeIn('slow');
		} else {
			if (debug) {
				console.log("removing highlight " + element);
			}

			$inplaceEditableIcon.remove(); // only remove the immediate children!
			$element.removeClass("inplaceEditableIconContainer");
		}
	},

	/**
	 * Add code to the page which will automatically show the "pen" icon for the "highlighted" elements when the mouse moves over
	 * @param highlightSelector
	 * @param inplaceEditableIconPlaceHolderSelector Optional css-selector for choosing the sub-element of the "highlighted" element where the pencil-icon will be added to
	 */
	addHighlightWithInplaceEditableIcon: function(highlightSelector, inplaceEditableIconPlaceHolderSelector) {
		if (!highlightSelector) {
			highlightSelector = "." + codebeamer.highlightForInplaceEditabilityCSSClass;
		}

		$(document).on("mouseenter", highlightSelector, null, function() {
			codebeamer.highlightWithInplaceEditableIcon(this, true, inplaceEditableIconPlaceHolderSelector);
		 })
		 .on("mouseleave", highlightSelector, null, function() {
			codebeamer.highlightWithInplaceEditableIcon(this, false, inplaceEditableIconPlaceHolderSelector);
		});
	}

});

$.extend(codebeamer, {
	highlightForInplaceOfficeEditabilityCSSClass: "officeEditHighlighted" ,

	// see addHighlightWithInplaceEditableIcon below for parameters
	highlightWithInplaceOfficeEditableIcon: function(element, highlight, inplaceEditableIconPlaceHolderSelector) {
		if (!isOfficeEditEnabled){
			// office edit is disabled
			return;
		}

		var debug = false;
		var $element = $(element);

		// check if there is a placeholder for the inplaceEditableIcon, then add it there
		var $placeHolder = $element;
		if (inplaceEditableIconPlaceHolderSelector) {
			$placeHolder = $element.find(inplaceEditableIconPlaceHolderSelector).first();

			if ($placeHolder.length == 0) {
				$placeHolder = $element; // insert the icon directly to the highlighted element
			}
		}
		var $inplaceEditableIcon = $placeHolder.find(".inplaceOfficeEditableIcon");

		if (highlight) {
			// check if already highlighted?
			if ($inplaceEditableIcon.length > 0) {
				if (debug) {
					console.log("already highlighted!");
				}
				return;
			};

			if (debug) {
				console.log("highlighting " + element);
			}

			$placeHolder.prepend("<img class='inplaceOfficeEditableIcon' title='Click to start office editing' style='display:none;' src='" + contextPath +"/images/space.gif' />");
			$inplaceEditableIcon = $element.find(".inplaceOfficeEditableIcon");
			// check the width of the element, and make space for the icon if necessary by adding a special class to that
			$element.addClass("inplaceOfficeEditableIconContainer");

			// don't animate on IE, because that looks strange
			if ($("body").hasClass("IE")) {
				$inplaceEditableIcon.show();
			} else {
				$inplaceEditableIcon.fadeIn('slow');
			}
			$inplaceEditableIcon.click(function() {
				if ($(this).is(":visible")) {
					var id = $(this).closest("tr").first().attr('id');
					OfficeEdit.doEditing(id, contextPath, function(){
						IssueDescriptionPoller.addIssue(id, new Date().getTime(), "tr#" + id + " > td.requirementTd > div.description > div.editable");
						IssueDescriptionPoller.startPolling(contextPath + "/checkissuechanged.spr", function(updated){
							refreshProperties(updated.id);
						});
					});

				} else {
					console.log("not doing anything, already hidden...");
				}
			});
		} else {
			if (debug) {
				console.log("removing highlight " + element);
			}

			$inplaceEditableIcon.remove(); // only remove the immediate children!
			$element.removeClass("inplaceOfficeEditableIconContainer");
		}
	},

	/**
	 * Add code to the page which will automatically show the "pen" icon for the "highlighted" elements when the mouse moves over
	 * @param highlightSelector
	 * @param inplaceEditableIconPlaceHolderSelector Optional css-selector for choosing the sub-element of the "highlighted" element where the pencil-icon will be added to
	 */
	addHighlightWithInplaceOfficeEditableIcon: function(highlightSelector, inplaceEditableIconPlaceHolderSelector) {
		if (!highlightSelector) {
			highlightSelector = "." + codebeamer.highlightForInplaceOfficeEditabilityCSSClass;
		}

		$(document)
			.on("mouseenter", highlightSelector, null, function() {
				codebeamer.highlightWithInplaceOfficeEditableIcon(this, true, inplaceEditableIconPlaceHolderSelector);
			 })
			.on("mouseleave", highlightSelector, null, function() {
				codebeamer.highlightWithInplaceOfficeEditableIcon(this, false, inplaceEditableIconPlaceHolderSelector);
			});
	}
});