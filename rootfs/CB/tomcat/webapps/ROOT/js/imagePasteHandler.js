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

codebeamer.imagePasteHandler = codebeamer.imagePasteHandler || {

	hasOnlyImages: function(items) {
		var i, imageCounter = 0;

		for (i = 0; i < items.length; i++) {
			if (/^image\/(jpeg|png|gif|bmp)$/.test(items[i].type)) {
				imageCounter++;
			}
		}

		return items.length > 0 ? imageCounter === items.length : false;
	},

	hasTextItem: function(items) {
		var result = false;

		for (i = 0; i < items.length; i++) {
			if (/text\/plain/.test(items[i].type)) {
				result = true;
				break;
			}
		}

		return result;
	},

	enrichImage: function(image) {
		var type, extension, randomName;

		// Pasted data has no file name, we have to generate one
		type = image.type.split("/");
		extension = type.length  > 0 ? type[1] : null;
		randomName = "pasted-" + Math.random().toString(36).substring(2);

		blob = image.slice();
		blob.type = image.type;
		if (extension && randomName) {
			blob.name = randomName + "." + extension;
		} else {
			blob = null;
		}

		return blob;
	},

	uploadImagesFromDataTransfer: function(uploaderInstance, items) {
		for (var i = 0; i < items.length; i++) {
			// The object does not have the "size" property by default, but accessing it as a file will return a Blob, which has the proper "size" property
			var image = this.enrichImage(items[i].getAsFile());
			uploaderInstance._uploadFile(image);
		}
	},

	handlePasteEvent: function(event, uploaderInstance, dataTransfer, items) {
		var textContent;

		if (this.hasOnlyImages(items)) {
			this.uploadImagesFromDataTransfer(uploaderInstance, items);
			event.preventDefault();
		} else {
			// Paste the text content manually, prohibit anything else (like html)
			var $target = $(event.target);
			var container = $target.closest("td");
			if (this.hasTextItem(items)) {
				textContent = dataTransfer.getData("text/plain");
				this.pasteHtmlAtCaret(container, textContent);
			}
			event.preventDefault();
		}
	},

	uploadImagesFromBlobs: function(uploaderInstance, blobs) {
		if (blobs.length == 0) {
			return;
		}

		for (var i = 0; i < blobs.length; i++) {
			var image = this.enrichImage(blobs[i]);
			uploaderInstance._uploadFile(image);
		}
	},

	dataURItoBlob: function(dataURI) {
		var byteString, mimeString, ab, ia, bb, i;
	    // convert base64 to raw binary data held in a string
	    // doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
	    byteString = atob(dataURI.split(',')[1]);

	    // separate out the mime component
	    mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

	    // write the bytes of the string to an ArrayBuffer
	    ab = new ArrayBuffer(byteString.length);
	    ia = new Uint8Array(ab);
	    for (i = 0; i < byteString.length; i++) {
	        ia[i] = byteString.charCodeAt(i);
	    }

	    // write the ArrayBuffer to a blob, and you're done
	    bb = new Blob([ia], {type: mimeString});
	    return bb;
	},

	getLineBreakNodeName: function() {
		var lineBreakNodeName;

		lineBreakNodeName = "BR"; // Use <br> as a default

	    if ($("body").hasClass("Chrome")) {
	        lineBreakNodeName = "DIV";
	    } else {
	    	if ($("body").hasClass("IE11")) {
		        lineBreakNodeName = "P";
		    } else {
		    	if ($("body").hasClass("FF")) {
			        lineBreakNodeName = "BR";
			    }
		    }
	    }

	    return lineBreakNodeName;
	},

	extractTextWithWhitespace: function(elems) {
		var extractedText, lineBreakNodeName;

		lineBreakNodeName = this.getLineBreakNodeName();
	    extractedText = this.extractTextWithWhitespaceWorker(elems, lineBreakNodeName);

	    return extractedText;
	},

	extractTextWithWhitespaceWorker: function(elems, lineBreakNodeName) {
		var ret, elem, i;

	    ret = "";
	    elem;

	    for (i = 0; elems[i]; i++)
	    {
	        elem = elems[i];

	        if (elem.nodeType === 3     // text node
	            || elem.nodeType === 4) // CDATA node
	        {
	            ret += elem.nodeValue;
	        }

	        if (elem.nodeName === lineBreakNodeName)
	        {
	            ret += "\n";
	        }

	        if (elem.nodeType !== 8) // comment node
	        {
	            ret += this.extractTextWithWhitespaceWorker(elem.childNodes, lineBreakNodeName);
	        }
	    }

	    return ret;
	},

	converTextToHtml: function(text) {
		var lines, html, lineBreakNodeName, i;

		lines = text.split('\n');
		lineBreakNodeName = this.getLineBreakNodeName();
		html = "";

		for (i = 0; i < lines.length; i++) {
			if (lineBreakNodeName === 'BR') {
				html = html + lines[i] + '<br/>';
			} else {
				html = html + '<' + lineBreakNodeName + '>' + lines[i] + '</' + lineBreakNodeName + '>'
			}
		}

		return html;
	},

	pasteHtmlAtCaret: function(container, html) {
	    var sel, range, isInvisible, restored;

	    isInvisible = false;
	    // When the container is not visible, then it is not possible to focus the element and restore that selection.
	    // Solution is to reveal the element, but make it invisible to the user.
	    if ($(container).find(".imagePasteAwareEditor").is(":hidden")) {
	    	isInvisible = true;
	    	$(container).find(".imagePasteAwareEditor").css("opacity", 0).css("display", "block").css("position", "absolute");
	    }

	    this.focusEditor(container);
	    restored = this.restoreSelectionForContainer(container);

	    if (restored) {
		    if (window.getSelection) {
		        // IE9 and non-IE
		        sel = window.getSelection();
		        if (sel.getRangeAt && sel.rangeCount) {
		            range = sel.getRangeAt(0);
		            range.deleteContents();

		            // Range.createContextualFragment() would be useful here but is
		            // non-standard and not supported in all browsers (IE9, for one)
		            var el = document.createElement("div");
		            el.innerHTML = html;
		            var frag = document.createDocumentFragment(), node, lastNode;
		            while ( (node = el.firstChild) ) {
		                lastNode = frag.appendChild(node);
		            }
		            range.insertNode(frag);

		            // Preserve the selection
		            if (lastNode) {
		                range = range.cloneRange();
		                range.setStartAfter(lastNode);
		                range.collapse(true);
		                sel.removeAllRanges();
		                sel.addRange(range);
		            }
		        }
		    } else {
		    	if (document.selection && document.selection.type != "Control") {
			        // IE < 9
			        document.selection.createRange().pasteHTML(html);
			    }
		    }
	    } else {
	    	// There was no selection to restore, append it to the container
	    	$(container).find(".imagePasteAwareEditor").append(html);
	    }

	    if (isInvisible) {
	    	$(container).find(".imagePasteAwareEditor").css("opacity", 100).css("display", "none").css("position", "inherit");
	    	this.refreshTextAreaInContainer(container);
	    	$(container).trigger("invisibleContainerUpdated");
	    }

	},

	isCurrentBrowserSupported: function() {
		var result = false;

		if ($("body").hasClass("IE11") || $("body").hasClass("FF") || $("body").hasClass("Chrome")) {
			result = true;
		}

		return result;
	},

	isEditorEmpty: function(container) {
		var editor, textarea, text, result;

		result = false;

		if (this.isCurrentBrowserSupported()) {
			editor = $(container).find(".imagePasteAwareEditor");

			text = this.extractTextWithWhitespace(editor);
			text = text !== null || text !== undefined ? text.trim() : "";

			result = (text === "");
		}

		return result;
	},

	refreshTextAreaInContainer: function(container) {
		var editor, textarea, text;

		if (this.isCurrentBrowserSupported()) {
			editor = $(container).find(".imagePasteAwareEditor");
			textarea = $(container).find('textarea');

			text = this.extractTextWithWhitespace(editor);
			textarea.val(text);
		}
	},

	refreshEditorInContainer: function(container) {
		var editor, textarea, html;

		if (this.isCurrentBrowserSupported()) {
			editor = $(container).find(".imagePasteAwareEditor");
			textarea = $(container).find('textarea');
			var val = textarea.val();
			html = this.converTextToHtml(val);

			editor.empty().append(html);
		}
	},

	toggleReadOnlyMode: function(container) {
		var editor;

		if (this.isCurrentBrowserSupported()) {
			this.selection = null;
			editor = $(container).find(".imagePasteAwareEditor");

			if (editor.attr("contenteditable") === "true") {
				editor.attr("contenteditable", "false");
				editor.attr("title", "");
			} else {
				editor.attr("contenteditable", "true");
				editor.attr("title", i18n.message("editor.paste.notification"));
			}
		}
	},

	hideEditorInContainer: function(container) {
		if (this.isCurrentBrowserSupported()) {
			$(container).find(".imagePasteAwareEditor").hide();
			this.selection = null;
		}
	},

	showEditorInContainer: function(container) {
		if (this.isCurrentBrowserSupported()) {
			$(container).find(".imagePasteAwareEditor").show();
		}
	},

	focusEditor: function(container) {
		if (this.isCurrentBrowserSupported()) {
			var editor = $(container).find(".imagePasteAwareEditor");
			editor.focus();
			moveCursorToEndOfContentEditable(editor.get(0));
		}
	},

	restoreSelectionForContainer: function(container) {
		var dropZoneId, selection, $container, sel, restored;

		$container = $(container);
		$dropZone = $container.find(".fileUpload_dropZone");
		dropZoneId = $container.data("dropZoneId");
		selection = $container.data("selection");

	    if (dropZoneId != null && $dropZone[0].id === dropZoneId && selection) {
	        this.restoreSelection(selection);
	    } else {
	    	this.clearSelection();
	    }

	    return this.getSelection() !== null;
	},

	clearSelection: function() {
		var sel;

        if (window.getSelection) {
            sel = window.getSelection();
            sel.removeAllRanges();
        } else {
        	if (document.selection) {
        		document.selection.empty();
        	}
        }
	},

	restoreSelection: function(selection) {
		var sel;

        if (window.getSelection) {
            sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(selection);
        } else {
        	if (document.selection && selection.select) {
        		document.selection.empty();
        		selection.select();
        	}
        }
	},

	getSelection: function() {
		var sel, result;

		result = null;

		if (window.getSelection) {
	        sel = window.getSelection();
	        if (sel.getRangeAt && sel.rangeCount) {
	        	result = sel.getRangeAt(0);
	        }
	    } else {
	    	if (document.selection && document.selection.createRange) {
	    		result = document.selection.createRange();
	    	}
	    }

		return result;
	},

	attachHandler: function(element) {
		var $element, $imagePasteAwareEditor;

		function saveSelection(element) {
			var $dropZone, dropZoneId, selection;

			$dropZone = $element.find(".fileUpload_dropZone");
			dropZoneId = $element.data("dropZoneId");
			selection = $element.data("selection");
			// Take into account only the selection for the same editor
			if (dropZoneId != null) {
				if ($dropZone[0].id !== this.dropZoneId) {
					$element.data("selection", null);
					$element.data("dropZoneId", $dropZone[0].id);
				}
			} else {
				$element.data("dropZoneId", $dropZone[0].id);
			}

			selection = this.getSelection();
			if (selection) {
				$element.data("selection", selection);
			} else {
				$element.data("selection", null);
			}
		}

		$element = $(element);
		$imagePasteAwareEditor = $element.find(".imagePasteAwareEditor")

		$imagePasteAwareEditor.on("keydown", $.proxy(saveSelection, this));
		$imagePasteAwareEditor.on("click", $.proxy(saveSelection, this));

		$element.on("paste", $.proxy(function(e) {
			var uploaderInstance, dataTransfer, textContent;

			uploaderInstance = uploaderExtensions.getUploader($element.find(".fileUpload_dropZone")[0]);
			dataTransfer = e.originalEvent.clipboardData || e.originalEvent.dataTransfer;

			if (dataTransfer && dataTransfer.items && dataTransfer.items.length > 0) {
				this.handlePasteEvent(e, uploaderInstance, dataTransfer, dataTransfer.items);
			} else {
				if (dataTransfer && dataTransfer.files && dataTransfer.files.length > 0) {
	                this.handlePasteEvent(e, uploaderInstance, dataTransfer, dataTransfer.files);
				} else {
					dataTransfer = e.originalEvent.clipboardData || e.originalEvent.dataTransfer || window.clipboardData;
					textContent = dataTransfer.getData("text");
 					// Paste the text content manually, prohibit anything else (like html)
					if (textContent) {
						var $target = $(e.target);
						var container = $target.closest("td");
						this.pasteHtmlAtCaret(container, textContent);
						e.preventDefault();
					} else {
						// Wait for IE11 and Firefox to paste the image, then copy at as blob and upload
						setTimeout($.proxy(function() {
							var blobs, that;

							blobs = [];
							that = this;

							$(e.currentTarget).find('.imagePasteAwareEditor img').each(function(index, element) {
								var imageAsDataUri, blob;

								imageAsDataUri = element.src;

								blobs.push(that.dataURItoBlob(imageAsDataUri));
							});

							that.uploadImagesFromBlobs(uploaderInstance, blobs);

							$(e.currentTarget).find('img').remove();
						}, this), 150);
					}
				}
			}

		    e.stopPropagation();
		}, this));
	},

	init: function(container, cssClass) {
		var editor, textarea;

		if (this.isCurrentBrowserSupported()) {
			editor = "<div title='" +  i18n.message("editor.paste.notification") + "' contentEditable='true' tabindex='0' class='imagePasteAwareEditor ";
			editor +=  cssClass != null && cssClass != undefined ? cssClass : "";
			editor += "'></div>";
			textarea = $(container).find('textarea');
			textarea.after(editor);
			textarea.hide();

			this.attachHandler(container);

			$(container).trigger("image:paste:intialized");
		}
	},

	/**
	 * Bind the event so when file uploaded the uploaded image will be pasted to the textarea/editor cotnainer
	 * @param container The container for textarea
	 * @param textarea The textarea to add the uploaded image as thumbnail
	 * @param fileName The uploaded file's name
	 * @param responseJson The JSON response form file uploader widget contains the image url and more data
	 */
	pasteUploadedImageAsThumbnail: function(container, textarea, fileName, responseJson) {
		var mimeType = responseJson.mimeType;
		// if the uploaded file is an image then add the wiki reference to the textarea
		if (mimeType && mimeType.indexOf("image/") == 0) {

			var url = responseJson.url;

			fetchImageSize(url, function(width, height) {
				var imgMarkup = "[!" + fileName + "!]";
				// insert a special css markup using .thumbnailImages which will shink very large images and show them in a lightbox viewer if necessary
				if (width == null || height == null || width > 200 || height > 200) {
					imgMarkup = "%%thumbnailImages " + imgMarkup +" %!";
				}
				if (codebeamer.imagePasteHandler.isCurrentBrowserSupported()) {
					codebeamer.imagePasteHandler.pasteHtmlAtCaret(container, imgMarkup);
				} else {
					textarea.replaceSelectedText(imgMarkup);
					fixTextArea(textarea, "");
					$(container).trigger("invisibleContainerUpdated");
				}
			});

		}
	},

	/**
	 * Fixes IE looses caret position when text-area looses the focus
	 * @param textArea The text-area to fix
	 * @param display The optional display css attribute for the textarea. Defaults to "block". Sometimes an empty is better ?
	 */
	fixTextArea: function(textArea, display) {
		if ($('body').hasClass('IE')) {
			var $element = $(textArea);
			var IE_PREVIOUS_SELECTION = "IEpreviousSelection";
			$element.bind("beforedeactivate", function() {
				try {
					var sel = $element.getSelection();
					$element.data(IE_PREVIOUS_SELECTION, sel);
				} catch (e) {
					console.log("fixIECaretLostForTextArea() error:" + e);
				}
			});
			$element.bind("focus", function() {
				var lastSelection = $element.data(IE_PREVIOUS_SELECTION);
				if (lastSelection) {
					$element.setSelection(lastSelection.start, lastSelection.end);
					$element.data(IE_PREVIOUS_SELECTION, null);
				}
			});
			$element.css("display", display == null ? "block" : display);
		}
	}
};