
/**
 * Wait for all file-uploads are finished, and when those are done call the callback method. Shows a warning dialog
 *
 * @param callWhenFinished Callback method to call when all uploads finished
 * @param allowCancel If this dialog can be cancelled and the callback is NOT called when cancelled
 * @return If the file uploads are all complete
 */
function waitForFileUploadsFinished(callWhenFinished, allowCancel) {
	if (isFileUploadsFinished(false)) {
		callWhenFinished();
		return true;
	} else {
		// cover the whole page and call the callback when file uploads are complete
		var $busyDialog = ajaxBusyIndicator.showBusyPage(i18n.message("dndupload.uploadsareinprogress"), allowCancel);

		// wait until all uploads are sent
		window.setInterval(function() {
			if (isFileUploadsFinished(false)) {
				// check if the dialog has been cancelled? then don't call the callback
				var cancelled = ! $busyDialog.dialog("isOpen");
				if (! cancelled) {
					callWhenFinished();
				}
			}
		}, 1000);
	}
	return false;
}

/**
 * Extensions to fileuploader.js. Must be in a separate file because it needs the file-uploader initialized.
 */
function isFileUploadsFinished(showInProgressAlert) {
	try {
		var uploadsAreInProgress = false;
		try {
			var uploadSpinners = $("span.qq-upload-spinner");	// note: the span is needed !
			uploadsAreInProgress = (uploadSpinners == null || uploadSpinners.length != 0);
		} catch (e) {
			// jquery throws an exception when no spinner, why?
		}

		if (uploadsAreInProgress) {
			if (showInProgressAlert == null || showInProgressAlert) {
				alert(i18n.message("dndupload.uploadsareinprogress"));
			}
			return false;
		}
	} catch (e) {
		console.log("Exception in isFileUploadsFinished(): " + e);
	}
	return true;
}

var uploaderExtensions = {

	initFileUploader: function(elementId, conversationId, options) {
		console.log("Initializing file upload on " + elementId);
		var hasConversation = conversationId && conversationId != "";
		var conversationParams = (hasConversation ? "?conversationId=" + conversationId : "");
		var $element = $('#' + elementId);

		var defaultOptions = {
			forcesingle: false,
			action: contextPath + "/dndupload/uploadoctetstream.spr" + conversationParams,
			action_iframe: contextPath + "/dndupload/uploadmultipart.spr" + conversationParams,
			action_remove: contextPath + "/dndupload/removeFile.spr" + conversationParams,
			onSubmit: function(id, fileName) {
				var clearHighlights = function(jQueryObj) {
					// making sure that the drag and drop area is not highlighted anymore
					jQueryObj('.qq-upload-drop-area-active').each(function() {
						jQueryObj(this).removeClass('qq-upload-drop-area-active');
					});
				};
				clearHighlights($);
				if (window.parent != window) {
					clearHighlights(window.parent.$);
				}

				if (options.onSubmit && typeof options.onSubmit === 'function') {
					options.onSubmit();
				}
				var timeout = 100;
				if ($("body").hasClass('IE8')) {
					timeout = 1000;
				}
				setTimeout(function() {
					uploaderExtensions.scheduleUpdateVisuals(elementId, null, false);
					uploaderExtensions._keepSessionAlive();
					uploaderExtensions._rearrangeUploadControlsInDomIfNeeded($element);
				}, timeout); // new list item will be added just after this event handler runs, so wait a bit
			},
			onProgress: function() {
				if (!$element.hasClass("qq-autohide")) {
					$element.find(".qq-upload-size").show(); // fix for IE
					uploaderExtensions.scheduleUpdateVisuals(elementId, null, false);
				}
				uploaderExtensions._rearrangeUploadControlsInDomIfNeeded($element);
			},
			onComplete: function(id, fileName, responseJSON) {
				uploaderExtensions.scheduleUpdateVisuals(elementId);

				if (responseJSON.success) {
					// fire the onUploadComplete custom event so anybody can subscribe on this!
					$element.trigger("onUploadComplete", [id, fileName, responseJSON]);
				} else {
					// if the upload failed don't fire the event: so for example the failed image-upload won't be added to the wysiwyg editor
					console.log("Failed upload of <" + fileName +">, not firing event. " + responseJSON);

					var error = responseJSON.error;
					if (error != null && error != "") {
						var $errorElement = $element.find('li[data-id="' + id  + '"] .qq-upload-failed-text');
						$errorElement.append(": " + error);
					}
				}
				uploaderExtensions._rearrangeUploadControlsInDomIfNeeded($element);
				uploaderExtensions._keepSessionAlive();
				uploaderExtensions._addFileSizeData($element, responseJSON, fileName);
				// If single file upload switch the filename from old to the new one
				if (this.forcesingle) {
					var fileNameCont = $element.find(".qq-upload-success .qq-upload-file").first();
					fileNameCont.attr("title", fileName);
					fileNameCont.text(fileName);
				}
			},
			onCancel: function() {
				uploaderExtensions.scheduleUpdateVisuals(elementId);
				uploaderExtensions._keepSessionAlive();
			},
			flatBox: false,
			// The id of the html element for external drop-zone
			externalDropZoneId: null,
			getPreviouslyUploadedFiles: true,
			showMessage: function(message){
				alert("Upload failed: " + message);
			}
		};

		// there might be multiple upload widgets on the page, so enabling dropping outside
		qq.UploadDropZone.dropOutsideDisabled = false;

		var mergedOptions = $.extend(defaultOptions, options);
		mergedOptions.element = $element[0];
		if (! mergedOptions.dndControlMessageCode) {
			mergedOptions.dndControlMessageCode = mergedOptions.forcesingle ? 'dndupload.attachonefile' : 'dndupload.attachfiles';
		}

		var uploader = new qq.FileUploader(mergedOptions);

		// update the list when an uploaded file is removed from there
		$element.bind('onRemove',
				function(event, fileName) {
					uploaderExtensions.scheduleUpdateVisuals(elementId);
					uploaderExtensions._keepSessionAlive();
					setTimeout(function() { uploaderExtensions._hideUploadListIfEmpty(elementId); });
				});

		if (mergedOptions.flatBox) {
			$element.addClass('fileUpload-flatbox');
			$element.find(".qq-upload-icon").text(i18n.message(mergedOptions.dndControlMessageCode));
		}

		$element.show();

		if (hasConversation && mergedOptions.getPreviouslyUploadedFiles) {
			uploaderExtensions.initUploaderConversation(uploader, elementId, conversationId);
		}

		if (mergedOptions.externalDropZoneId) {
			uploaderExtensions._initExternalDropZone(uploader, "#" + mergedOptions.externalDropZoneId);
		}

		// bind the uploader to the element of it
		$element.data("UPLOADER_INSTANCE", uploader);
		$element.trigger("onUploaderIntialized");

		return uploader;
	},

	// get the uploader instance for an element
	getUploader: function(selector) {
		var $el = $(selector).first();
		if ($el.length == 0) {
			// try as id
			$el = $("#" + selector).first();
		}

		return $el.data("UPLOADER_INSTANCE");
	},

	_rearrangeUploadControlsInDomIfNeeded: function(element) {
		if ((typeof element == "string") || (typeof element == "number")) {
			element = uploaderExtensions._getUploaderHtmlElement(element);
		}
		if (!uploaderExtensions._isUsedInsideAWikiEditor(element)) {
			// Inside a wiki editor, controls (remove, cancel, ...) are floated on the right but are
			// placed first in the DOM because of a FF/IE bug. Thus, outside a wiki editor, we must
			// re-arrange the DOM a bit to make those control elements appear after file names and not
			// vice versa.
			var uploadControls = element.find(".dd-upload-control");
			uploadControls.each(function() {
				var $this = $(this);
				var parent = $this.parent();
				$this.detach().appendTo(parent);
			});
		}
	},

	_keepSessionAliveTimer: null,

	// ping the sever while the uploads are in progress so session won't expire
	_keepSessionAlive: function() {
		var freq = 20 * 60 * 1000;	// 20 mins
		if (uploaderExtensions._keepSessionAliveTimer == null) {
			uploaderExtensions._keepSessionAliveTimer = setTimeout(function() {
				uploaderExtensions._keepSessionAliveTimer = null;
				// if there are still file uploads going on then ping the server and continue pinging
				if (! isFileUploadsFinished(false)) {
					var keepSessionAliveURL = contextPath + "/images/space.gif";
					$.post(keepSessionAliveURL);
					uploaderExtensions._keepSessionAlive();
				}
			}, freq);
		}
	},

	_initExternalDropZone: function(uploader, dropZoneElement, isValidFiles) {
		var externalDropZone = $(dropZoneElement)[0];
		if (externalDropZone) {
			var highlightDropArea = true;	// TODO: not highlighting the drop-area now, because it can not be safely/nicely removed
			uploader._initDropZone(uploader, externalDropZone, highlightDropArea);

			// optional function decides if the drag-dropped file is accepted ?
			if (isValidFiles != null) {
				$(externalDropZone).on("isValidFileDrag", function(event, dragEvent) {
					try {
						var files = dragEvent.dataTransfer.files;
						if (! isValidFiles(files)) {
							dragEvent.valid = false;
						}
					} catch (ex) {
						console.log("Failed to get drop-files" + ex);
					}
				});
			}
		} else {
			console.log("External drop zone not found: " + externalDropZoneId +", drop disabled to this");
		}
	},

	// map between the upload widget's id and its conversation-id
	_uploaderWidgetIdToConversationIds: {},

	/**
	 * Downloads the info about previously uploaded files in the conversation, and
	 * displays this in the file-uploader widget
	 *
	 * @param fileUploader
	 * @param uploaderId
	 * @param conversationId
	 */
	initUploaderConversation: function(fileUploader, uploaderId, conversationId) {
		uploaderExtensions._uploaderWidgetIdToConversationIds[uploaderId] = conversationId;
		var url = contextPath + "/dndupload/getPreviouslyUploadedFiles.spr?conversationId=" + conversationId;
		$.ajax({
			  url: url,
			  async: true,
			  dataType: "json",
			  success: function(data) {
				  if (data == null || data.length == 0) {
					  uploaderExtensions._hideUploadListIfEmpty(uploaderId);
					  return;
				  } else {
					  var uploaderElement = uploaderExtensions._getUploaderHtmlElement(uploaderId);
					  var uploaderList = $(uploaderElement).find('ul.qq-upload-list')[0];
					  $(uploaderList).html(html).css('display', 'block');
				  }

				  var result = [];
				  for (var i = 0; i < data.length; i++) {
					  var fileData = data[i];
					  var formattedSize = fileUploader._formatSize(fileData.size);
					  var formattedName = fileUploader._formatFileName(fileData.fileName);
					  // almost the same as line-template
					  var li = '<li>' +
									// controls must be here because of FF and IE 'float: right' bug
									'<a class="qq-upload-remove dd-upload-control" href="#">&nbsp;&nbsp;&nbsp;</a>' +
									// other info
									'<span class="qq-upload-file" title="' + fileData.fileName +'" >' + formattedName +'</span>' +
									'<span class="qq-upload-size">' + formattedSize + '</span>' +
								'</li>';
					  result.push(li);
				  }
				  var html = result.join("\n");
				  var uploaderElement = uploaderExtensions._getUploaderHtmlElement(uploaderId);
				  var uploaderList = $(uploaderElement).find("ul.qq-upload-list")[0];
				  $(uploaderList).html(html).css('display', 'block');

				  $(uploaderElement).trigger("onChange");	// fire an change event, so listeners can update themselves

				  uploaderExtensions.scheduleUpdateVisuals(uploaderId);
			  },
			  error: function(xhr, textStatus, errorThrown) {
				  console.log("error loading previously uploaded files, conversationId=" + conversationId +", error:" + textStatus);
			  }
		  });
	},

	_getUploaderHtmlElement: function(uploaderId) {
		if (uploaderId == null) {
			uploaderId = "uploadConversationId_dropZone";
		}
		return $("#" + uploaderId);
	},

	autoToggleOnMouseOver: function(uploaderId, uploaderElement, editor) {
		if (uploaderElement) {
			$(uploaderElement).addClass("qq-autohide");
			var list = $(uploaderElement).find(".qq-upload-list");

			$(list).on("mouseenter", function() {
				$(uploaderElement).addClass("qq-mouse-hovering");
				uploaderExtensions.scheduleUpdateVisuals(uploaderId, 1);
			});

			$(list).on("mouseleave", function() {
				$(uploaderElement).removeClass("qq-mouse-hovering");
				uploaderExtensions.scheduleUpdateVisuals(uploaderId, 500);
			});
		}
	},

	// map contains the uploader-id as keys and the timer of the scheduled update function
	_scheduledUpdate: {},

	// schedule the hiding/showing the uploaded files' list
	// the hide/show is not happening immediately because it is happening when the mouse is hovering over the upload widget
	// 			and if it is done immediately it would cause too fast open/collapse flickering of the list
	scheduleUpdateVisuals: function(uploaderId, timeout, forceHideElements) {
		var mouseHovering = null;
		if (typeof forceHideElements !== "undefined") {
			mouseHovering = !forceHideElements;
		}

		var previousSchedule = uploaderExtensions._scheduledUpdate[uploaderId];
		if (previousSchedule) {
			// cancel previous schedule
			window.clearTimeout(previousSchedule);
		}
		// schedule the next execute
		timeout = timeout || 500;
		uploaderExtensions._scheduledUpdate[uploaderId] = window.setTimeout(function() {
			uploaderExtensions._updateListOnChange(uploaderId, mouseHovering, function() {
				uploaderExtensions._rearrangeUploadControlsInDomIfNeeded(uploaderId);
				uploaderExtensions._hideUploadListIfEmpty(uploaderId);
			});
		}, timeout);

		uploaderExtensions._hideUploadListIfEmpty(uploaderId);
	},

	/**
	 * function changes the css class of the fileupload list depending on
	 * if it contains uploaded files or not
	 */
	_hideUploadListIfEmpty: function(uploaderId) {
		var uploaderElement = uploaderExtensions._getUploaderHtmlElement(uploaderId);
			$uploadList = $(uploaderElement).find('.qq-upload-list');
		if ($uploadList.length) {
			var hasFiles = uploaderExtensions.hasFiles($uploadList[0]);
			$uploadList.toggleClass('qq-upload-list-has-files', hasFiles);
			$uploadList.toggle(hasFiles);
		}
	},

	/**
	 * Check if the upload widget has files
	 * @param uploadList the ".qq-upload-list" element
	 * @return If it has files
	 */
	hasFiles: function(uploadList) {
		var listElems = $(uploadList).find("li");
		var hasFiles = listElems && listElems.length > 0;
		return hasFiles;
	},

	// if the files being uploaded are hidden too?
	_hideUploadingFiles: true,

	_showNumberOfFiles: function(uploaderElement) {
		uploaderExtensions._setNumberOfFilesVisibility(uploaderElement, true);
	},

	_hideNumberOfFiles: function(uploaderElement) {
		uploaderExtensions._setNumberOfFilesVisibility(uploaderElement, false);
	},

	_setNumberOfFilesVisibility: function(uploaderElement, show) {
		try {
			$(uploaderElement).find(".qq-numFiles").remove();

			if (show) {
				// when some files are hidden show their number...
				var hiddenElements = $(uploaderElement).find(".qq-upload-list li:hidden");
				var visibleElements = $(uploaderElement).find(".qq-upload-list li:visible");
				var numHidden = hiddenElements.size();
				var numVisible = visibleElements.size();
				if (numHidden > 0) {
					var msg = (numVisible == 0) ? i18n.message("dndupload.numfiles.hidden", numHidden) :
												  i18n.message("dndupload.numfiles.more.hidden", numHidden);
					if (uploaderExtensions._hideUploadingFiles) {
						var uploadingElements =  $(uploaderElement).find(".qq-upload-list li .qq-upload-spinner");
						var numUploading = uploadingElements.size();
						if (numUploading > 0) {
							var message = numUploading == 1 ?
								i18n.message('dndupload.one.file.is.uploading.hidden') :
								i18n.message("dndupload.some.files.are.uploading.hidden", numUploading, numHidden);
							msg = "<img src='" + contextPath + "/images/loading.png' style='vertical-align:top; margin-right: 2px'></img>" + message;
						}
					}
					$(uploaderElement).find(".qq-upload-list").append("<li class='qq-numFiles'>" + msg + "</li>");
				}
			}
		} catch (e) {
			console.log("callback error in showNumberOfFiles()" + e);
		}
	},

	_updateListOnChange: function(uploaderId, mouseHovering, callback) {
		var uploaderElement = uploaderExtensions._getUploaderHtmlElement(uploaderId);
		if (typeof mouseHovering === 'undefined' || mouseHovering === null) {
			mouseHovering = $(uploaderElement).hasClass("qq-mouse-hovering");
		}
		if (uploaderElement && uploaderElement.hasClass("qq-autohide")) {
			uploaderExtensions._setNumberOfFilesVisibility(uploaderElement, mouseHovering ? false : true);
			var sel = uploaderExtensions._hideUploadingFiles ? "li" : ".qq-upload-success";
			$(uploaderElement).find(".qq-upload-list " + sel).each(function() {
				// show or hide the elements when the mouse is hovering
				if (mouseHovering) {
					$(this).show();
					uploaderExtensions._hideNumberOfFiles(uploaderElement);
					callback && callback();
				} else {
					$(this).fadeOut(function() {
						uploaderExtensions._showNumberOfFiles(uploaderElement);
						callback && callback();
					});
				}
			});
		}
		uploaderElement.find(".qq-upload-size").show(); // fix for IE
	},

	/**
	 * Cancel all ongoing uploads
	 */
	cancelAllUploads: function() {
		try {
			$(".qq-upload-cancel").each().click();
		} catch (ignored) {
		}
	},

	_isUsedInsideAWikiEditor: function(element) {
		return $(element).closest(".actionBar").length > 0;
	},

	_addFileSizeData: function($element, responseJSON, fileName) {
		$element.find('.qq-upload-file[title="' + fileName + '"]').
			closest('li').
			find('.qq-upload-size').data('size', responseJSON["size"] ? responseJSON["size"] : 0);
	}

};

// fixing IE8's overlay transparency problem on some pages
$(function() {
	if ($("body").hasClass('IE8')) {
		// when mouse enters the upload widget then show the hidden file-inputs inside to avoid transparency problems
		$(document).on("mouseenter", ".qq-upload-button", function(event) {
			// show the file upload so that "click" event will be triggered on it
			var $file = $(this).find("input[type='file']");
			$file.show();
		});
	}
});

// fixing IE10's file upload is not started on single-click only double click
// see: https://github.com/tors/jquery-fileupload-rails/issues/33
$(function() {
	if ($("body").hasClass('IE10')) {
		$(document).on("mousedown", ".qq-upload-button", function(event) {
			var $file = $(this).find("input[type='file']");
			$file.show().trigger('click');
		});
	}
});
