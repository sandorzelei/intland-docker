/*
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */

/**
* defines and maps the global hotkeys
* note that this mapping depends on the configuration/license. if for example a tab is visible
* because of the licensing then the hotkey for showing this toolbar tag is also disabled.
*/
var codebeamer = codebeamer || {};

/**
 *
ALT+P - Projects
ALT+T - Trackers
ALT+I - WIKI
ALT+D - Documents
ALT+K - Baselines
ALT+M - My Start
ALT+A - Admin
ALT+R - Reports
ALT+U - Members
ALT+F - add focus to the main search text box
 */

/**
 * singleton for storing the hotkeys and their documentation
 */
codebeamer.HotkeyRegistry = codebeamer.HotkeyRegistry || (function($) {
	var registeredHotkeys = [];

	var getRegisteredHotkeys = function () {
		return registeredHotkeys;
	};

	var registerHotkey = function (key, documentation) {
		registeredHotkeys.push({key: key, documentation: documentation});
	};

	var registerHotkeys = function (hotkeys) {
		registeredHotkeys =  registeredHotkeys.concat(hotkeys);
	};

	var clearHotkeys = function() {
		registeredHotkeys = [];
	};

	return {
		"getRegisteredHotkeys": getRegisteredHotkeys,
		"registerHotkey": registerHotkey,
		"registerHotkeys": registerHotkeys,
		"clearHotkeys": clearHotkeys
	}
}(jQuery));

codebeamer.HotkeyFormatter = codebeamer.HotkeyFormatter || (function($) {
	var isMac = navigator.platform.toLowerCase().indexOf("mac") == 0;

	function getKeyCombination(keyCombo) {
		var result, i;

		result = '';

		for (i = 0; i < keyCombo.length; i++) {
			result = result ? result + '+' : result;

			if (keyCombo[i].toLowerCase() === 'ctrl') {
				if (isMac) {
					result = result + 'META';
				} else {
					result = result + 'CTRL';
				}
			} else {
				result = result + keyCombo[i].toUpperCase();
			}

		}

		return result;
	}

	function getLabel(keyCombo) {
		var result, i, parts;

		parts = keyCombo.split('+');

		result = '';

		for (i = 0; i < parts.length; i++) {
			result = result ? result + ' + ' : result;

			if (parts[i].toLowerCase() === 'alt') {
				if (isMac) {
					result = result + '\u2325';
				} else {
					result = result + 'Alt';
				}
			} else {
				if (parts[i].toLowerCase() === 'ctrl' || parts[i].toLowerCase() === 'meta') {
					if (isMac) {
						result = result + '\u2318';
					} else {
						result = result + 'Ctrl';
					}
				} else {
					if (parts[i].toLowerCase() === 'enter') {
						if (isMac) {
							result = result + '\u21a9';
						} else {
							result = result + 'Enter';
						}
					} else {
						if (parts[i].toLowerCase() === 'shift') {
							if (isMac) {
								result = result + '\u21e7';
							} else {
								result = result + 'Shift';
							}
						} else {
							if (parts[i].length === 1) {
								result = result + parts[i].toUpperCase();
							} else {
								result = result + parts[i].substr(0, 1).toUpperCase() + parts[i].substr(1).toLowerCase();
							}
						}
					}
				}
			}
		}

		return result;
	}

	return {
		getKeyCombination: getKeyCombination,
		getLabel: getLabel,
		isMac: isMac
	}
}(jQuery));

codebeamer.Hotkeys = codebeamer.Hotkeys || function (config) {
	this.init(config);
}

$.extend(codebeamer.Hotkeys.prototype, {
	defaults: {
		disabledModules: []
	},

	modules: ['admin', 'independent'],

	openUrl: function (url) {
		location.href = url;
	},

	openOverlay: function (url) {
		inlinePopup.show(url, {'geometry': 'large'});
		return false;
	},

	createOpenUrlAction: function (urlPattern, popup) {
		return function () {
			if (this.subjectId) {
				var url = contextPath + urlPattern.format(this.subjectId);
				if (popup) {
					this.openOverlay(url);
				} else {
					this.openUrl(url);
				}
			}
			return false;
		}.bind(this)
	},

	showOverlay: function(urlPattern) {
		return function () {
			if (this.subjectId) {
				var url = contextPath + urlPattern.format(this.subjectId);
				inlinePopup.show(url, {'geometry': 'large'});
			}
			return false;
		}.bind(this)
	},

	_isMac: function () {
		return codebeamer.HotkeyFormatter.isMac;
	},

	_isIe: function () {
		return $("body").is(".IE");
	},

	_modifier: codebeamer.HotkeyFormatter.isMac ? 'ALT+SHIFT+' : 'ALT+CTRL+', // modifiers must be in alphabetical order

	getModuleHotkeyDependency: function (){
		return {
			"independent": [
				 	{key: this._modifier + 'P' ,
				 		action: function() { this.openUrl(contextPath + '/projects/browse.spr'); return false;}.bind(this),
				 		documentation: 'hotkey.open.projects.tab.description'
				 	},
				 	{key: this._modifier + 'R' ,
				 		action: function() { this.openUrl(contextPath + '/query'); return false;}.bind(this),
				 		documentation: 'hotkey.open.queries.tab.description'
				 	},
				 	{key: this._modifier + 'M' , action: function() { this.openUrl(contextPath + '/user'); return false;}.bind(this),
				 		documentation: 'hotkey.open.mystart.tab.description'},
				 	{key: this._modifier + 'T' , action: this.createOpenUrlAction('/project/{0}/tracker'),
				 			documentation: 'hotkey.open.trackers.tab.description'},
				 	{key: this._modifier + 'I' , action: this.createOpenUrlAction('/project/{0}'),
				 		documentation: 'hotkey.open.wiki.tab.description'},
				 	{key: this._modifier + 'D' , action: this.createOpenUrlAction('/proj/doc.do?trashMode=false&proj_id={0}'),
				 			documentation: 'hotkey.open.documents.tab.description'},
				 	{key: this._modifier + 'H' , action: this.createOpenUrlAction('/proj/baselines.spr?proj_id={0}'),
				 			documentation: 'hotkey.open.baselines.tab.description'},
				 	{key: this._modifier + 'U' , action: this.createOpenUrlAction('/proj/members.spr?proj_id={0}'),
				 			documentation: 'hotkey.open.members.tab.description'},
				 	{key: this._modifier + 'S' , action: function(a, e) {
				 		// if the toggle searchfield is visible use that, otherwise use the input box from the top search form
					 		var $searchField = $(".searchField:visible");
					 		if ($searchField.size() > 0) {
					 			$searchField.find(".toggleButton").click();
					 			$searchField.find("input").focus();
					 		} else {
					 			$("#searchFilter").focus();
					 		}
					 		return false;
					 	},
					 	documentation: 'hotkey.focus.filter.box.description'
				 	}
			],
			"admin": [
			    {key: this._modifier + 'A' , action: this.createOpenUrlAction('/proj/admin.spr?proj_id={0}'),
			    	documentation: 'hotkey.open.admin.tab.description'}
			]
		}
	},

	init: function(config) {
		var bindHotkeys = function() {
			var moduleHotkeyDependency = this.getModuleHotkeyDependency(config);
			for (var i = 0; i < this.modules.length; i++) {
				var key = this.modules[i];
				if (this.disabledModules.indexOf(key) < 0) {
					codebeamer.HotkeyRegistry.registerHotkeys(moduleHotkeyDependency[key]);
					mapHotKeys(moduleHotkeyDependency[key]);
				}
			}
		}.bind(this);

		$.extend(this, this.defaults, config);
		bindHotkeys();
	}
});


/* create the class for handling the tracker page hotkeys
 * these hotkeys are:
 * alt + e: edit item
 * alt+h: open history tab
 * alt+c: add comment
 * alt+l: add association
 */
codebeamer.TrackerItemHotkeys = codebeamer.TrackerItemHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.TrackerItemHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['independent', 'edit', 'comment', 'create'],

	_modifier: function () {
		var result = "ALT+";

		if (this._isIe()) {
			result = 'CTRL+SHIFT+';
		} else {
			if (this._isMac()) {
				result = 'ALT+';
			}
		}
		return result;
	},

	getModuleHotkeyDependency: function (config) {
		var comment = [];
		comment.push({
			key: this._modifier() + 'C' ,
			action: this.createOpenUrlAction('/proj/tracker/addAttachment.spr?task_id={0}', true),
			documentation: 'hotkey.item.add.comment.description'
		});
		if (config.hasOwnProperty("canCreateAssociation") && config.canCreateAssociation) {
			comment.push({
				key: this._modifier() + 'L' ,
				action: this.showOverlay("/proj/tracker/addAssociation.do?inline=true&from_type_id=9&from_id={0}"),
				documentation: 'hotkey.item.add.association.description'
			});
		}
		return {
			"independent": [
				 	{key: this._modifier() + 'H' , action:
				 		function() {
				 			org.ditchnet.jsp.TabUtils.switchTab(document.getElementById("task-details-history-tab"));

				 			// scroll to the history tab
				 			$("body").animate({"scrollTop": $("#task-details-history-tab").offset().top}, 0);
				 			return false;
				 		}.bind(this),
				 		documentation: 'hotkey.item.show.history.description'}
			],
			"comment": comment,
			"edit": [
			    {key: this._modifier() + 'E' , action: this.createOpenUrlAction('/issue/{0}/edit'),
			    	documentation: 'hotkey.item.edit.description'}
			    ],
			"create": [
			    {
			 		key: codebeamer.HotkeyFormatter.isMac ? codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'i']) : codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'insert']),
			 		action: this.createOpenUrlAction('/tracker/' + this.trackerId + '/create?parent_id={0}'),
			 		documentation: 'hotkey.item.create.child.description'
			 	}
			]
		}
	}
});

/**
 * hotkeys for document view
 * ALT+L - Add Association (Link)
 * ALT+C - Add comment
 * ALT+UP - Select the previous work item as default if any
 * ALT+DOWN - Select the next work item as default if any
 * additionally please scroll there and highlight the work item
 * ALT+E - Change description for the default work item
 * using CTRL+S the description saved
 */
codebeamer.DocumentViewHotkeys = codebeamer.DocumentViewHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.DocumentViewHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['independent', 'create'],

	_getTree: function () {
		var tree = $.jstree.reference("#treePane");
		return tree;
	},

	_getSelectedNode: function () {
		var tree = this._getTree();
		var selectedId = tree.get_selected();

		if (selectedId) {
			return tree.get_node(selectedId);
		}

		return null;
	},

	_selectNode: function (node) {
 		if (node) {
 			var tree = this._getTree();
 			tree.deselect_all();
 			tree.open_node(node);
 			tree.select_node(node);
 		}
	},

	getModuleHotkeyDependency: function () {
		return {
			"independent": [
				 	{
				 		key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', 'up']),
				 		action: function() {
				 			var tree = this._getTree();
					 		var node = this._getSelectedNode();
					 		var $domNode = $("#treePane li#" + node.id);
					 		var prev = $domNode.prev();

					 		if (prev.size() == 0) {
						 		var nodes = $("#treePane li");
						 		var index = nodes.index($domNode) - 1;
						 		if (index >= 0 && index <  nodes.length) {
						 			prev = nodes.get(index);
						 		}
					 		} else {
						 		var lis = $(prev).find("li").not($domNode);
						 		if (lis.size() != 0) {
						 			prev = lis.last();
						 		}
					 		}

					 		if (prev && $(prev).size() != 0) {
					 			this._selectNode(prev);
					 		}

					 		return false;
					 	}.bind(this),
					 	documentation: 'hotkey.docview.previous.item.description'
				 	},
				 	{
				 		key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', 'down']),
				 		action: function() {
				 			var tree = this._getTree();
					 		var node = this._getSelectedNode();
					 		var $domNode = $("#treePane li#" + node.id);
					 		var lis = $domNode.find("li");
					 		var next = lis.size() == 0 ? tree.get_next_dom(node) : $(lis.get(0));

					 		if (next.size() == 0) {
						 		var nodes = $("#treePane li");
						 		var index = nodes.index($domNode) + 1;
						 		if (index >= 0 && index <  nodes.length) {
						 			next = nodes.get(index);
						 		}
					 		}

					 		if (next && $(next).size() != 0) {
					 			this._selectNode(next);
					 		}

					 		return false;
					 	}.bind(this),
					 	documentation: 'hotkey.docview.next.item.description'
				 	},
				 	{
				 		key: this._isIe() ? codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'shift', 'e']) : codebeamer.HotkeyFormatter.getKeyCombination(['alt', 'e']),
				 		action: function () {
					 		var node = this._getSelectedNode();
					 		if (node) {
					 			var id = node.li_attr["id"];
					 			$(".requirementTr#" + id + " .edit-description").click();
					 		}
					 	}.bind(this),
					 	documentation: 'hotkey.docview.edit.description'
					 },
				 	{
						key: this._isIe() ? codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'shift', 'l']) : codebeamer.HotkeyFormatter.getKeyCombination(['alt', 'l']),
				 		action: function () {
				 			if (!trackerObject.config.revision) {
					 			var node = this._getSelectedNode();
					 			if (node) {
					 				trackerObject.addAssociationForNode(node);
					 			}
				 			}
				 			return false;
				 		}.bind(this),
				 		documentation: 'hotkey.docview.add.association.description'
				 	},
				 	{
				 		key: this._isIe() ? codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'shift', 'c']) : codebeamer.HotkeyFormatter.getKeyCombination(['alt', 'c']),
				 		action: function () {
				 			var node = this._getSelectedNode();
				 			if (node) {
				 				var id = node.li_attr["id"];
				 				$(".requirementTr#" + id + " .comment-bubble").click();
				 			}
				 		}.bind(this),
				 		documentation: 'hotkey.docview.add.comment.description'
				 	}
			],
			"create": [
				 	{
				 		key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'return']),
				 		action: function () {
				 			var node = this._getSelectedNode();
					 		if (node) {
					 			trackerObject.addRequirementAfter(node);
						 		return false;
					 		}

					 		return false;
				 		}.bind(this),
				 		documentation: 'hotkey.docview.create.item.after.description'
				 	},
				 	{
				 		key: codebeamer.HotkeyFormatter.isMac ? codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'i']) : codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'insert']),
				 		action: function () {
				 			var node = this._getSelectedNode();
				 			if (node) {
				 				trackerObject.addChildRequirement(node);
				 				return false;
				 			}

				 			return true;
				 		}.bind(this),
				 		documentation: 'hotkey.docview.new.child.description'
				 	}
			]
		}
	}
});

/**
 * hotkeys for table view
 *
 *
 */
codebeamer.TableViewHotkeys = codebeamer.TableViewHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.TableViewHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['create'],
	getModuleHotkeyDependency: function () {
		return {
			'create': [
				 {
			 		key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'return']),
					action: this.createOpenUrlAction('/tracker/{0}/create'),
					documentation: 'hotkey.table.new.item.description'
				 }
			 ]
		}
	}

});

/**
 * hotkeys for planner
 *
 */
codebeamer.PlannerHotkeys = codebeamer.PlannerHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.PlannerHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['independent'],
	getModuleHotkeyDependency: function () {
		return {
			'independent': [
		           {
   			 		   key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'return']),
		        	   action: function () {
		        		   $(".add-new-item-link").click();
		        	   },
		        	   documentation: 'hotkey.table.new.item.description'
		           }
		    ]
		}
	}

});

/**
 * hotkeys for release view
 *
 */
codebeamer.ReleaseHotkeys = codebeamer.ReleaseHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.ReleaseHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['create'],
	getModuleHotkeyDependency: function (config) {
		return {
			'create': [
		           {
        			   key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 'return']),
		        	   action: function () {
		        		   var actionLinkSelector = config.isReleaseTracker ? '.add-new-release' : '.add-new-sprint';
		        		   var $link = $(actionLinkSelector);

		        		   if ($link.size()) {
		        			   $link[0].click();
		        		   }
		        	   },
		        	   documentation: config.isReleaseTracker ? 'hotkey.release.new.item.description' : 'hotkey.release.new.release.description'
		           }
		    ]
		}
	}

});

codebeamer.FormHotkeys = codebeamer.FormHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.FormHotkeys.prototype, {
	init: function (config) {
		$.extend(this, config);

		var editorHotkeyHandler = function (event) {
			var $focused = $(document.activeElement);
			var keyCode = 83;
			var $document = $(document);
			var $target = $(event.target);
			var ctrlKey = codebeamer.HotkeyFormatter.isMac ? event.metaKey : event.ctrlKey;
			var isExtendedDocumentView = typeof trackerObject != "undefined" && trackerObject.config.extended;
			var isTestRunner = !!$('form.test-runner-form').length;
			
			if (!$focused && this.isPopup) {
				keyCode = 91;
			}
			if ( (codebeamer.HotkeyFormatter.isMac && event.metaKey || !codebeamer.HotkeyFormatter.isMac && event.ctrlKey) && event.which == keyCode) { // cmd or ctrl+s
				if ($focused || this.isPopup) {
					// check if we are on docview
					var $issuePropertiesPanel = $focused.parents("#issuePropertiesPane");

					if (isExtendedDocumentView) {
						event.preventDefault();
						codebeamer.trackers.extended.save();
						return true;
					}

					if ($issuePropertiesPanel.size() > 0) {
						// the event was started on doc view property panel
						saveIssueProperties();
						event.preventDefault();
						$('.token-input-dropdown-facebook').remove();
					} else {
						var $testStepWrapperUnderMouseCursor = $(".teststepwrapper.mouseOver");

						// Check if the test step section is under the cursor, but none of the fields are focused.
						if ($testStepWrapperUnderMouseCursor.size() > 0) {
							$testStepWrapperUnderMouseCursor.find("input[data-purpose=save]").first().click();
							event.preventDefault();
						} else {
							// trigger blur on contenteditable elements to force content to be saved
							var $target = $(event.target);
							if ($target.attr("contenteditable")) {
								$target.blur();
							}
							// find the closest form and submit it
							var $form = this.isPopup ? $("form:first") : $focused.parents("form").not("#browseTrackerForm");
							if ($form.size() != 0) {
								var $saveBtn = $form.find('input[type=submit].button');

								if ($saveBtn.length) {
									$($saveBtn.get(0)).click();
								}

								event.preventDefault();
							}
						}
					}
				}
			}

			if (event.which == 27 && !ctrlKey && !event.shiftKey && !event.altKey && !isTestRunner &&
					(isExtendedDocumentView || !$.FE || !$.FE.INSTANCES.length)) { // handle ESC keydown including the doc edit view except when there is Froala editor on the page
				var $cancelBtn = $('.cancelButton').first(),
					isPopup = this.isPopup;
				
				if (($cancelBtn.length && $cancelBtn.is(':visible')) || isPopup) {
					showFancyConfirmDialogWithCallbacks(
						i18n.message('close.editing.confirmation.label'),
						function() {
							if (isPopup) {
								var success = inlinePopup.close();
								if (!success) {
									window.close();
								}
							} else {
								if (isExtendedDocumentView) {
									$('.dirty').removeClass('dirty');
								}
								$($cancelBtn.get(0)).click();
							}
						},
						$document.on.bind($document, 'keydown', editorHotkeyHandler),
						'warning', 
						function() {
							if (isExtendedDocumentView) {
								$(this).closest('.ui-dialog').find('.ui-dialog-buttonpane button').first().focus(); 
							}
							$document.off('keydown', editorHotkeyHandler);
						},
						function() {
							setTimeout(function() { $document.on('keydown', editorHotkeyHandler); });
						}
					);
				}
			}

			return true;
		}.bind(this);

		// event handler for the editor
		$(document).on('keydown', null, editorHotkeyHandler);
		$(document).ready(function() {
			var $saveButton, keyCombo, $cancelButton;

			$saveButton = $(document).find('input[type=submit].button:not(.cancelButton),input[data-role=save]').first();
			keyCombo = codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 's']);
			$saveButton.attr('title', $saveButton.val() + " (" + codebeamer.HotkeyFormatter.getLabel(keyCombo) + ")");
			
			$cancelButton = $('.cancelButton').first();
			keyCombo = codebeamer.HotkeyFormatter.getKeyCombination(['esc']);
			$cancelButton.attr('title', $cancelButton.val() + " (" + codebeamer.HotkeyFormatter.getLabel(keyCombo) + ")");
		});

		codebeamer.HotkeyRegistry.registerHotkeys([
				 {key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', '1']), documentation: 'hotkey.editor.activate.wysiwyg.tab.description'},
				 {key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', '2']), documentation: 'hotkey.editor.activate.markup.tab.description'},
				 {key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', '3']), documentation: 'hotkey.editor.activate.preview.tab.description'},
				 {key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 's']), documentation: 'hotkey.form.save.description'},
				 {key: codebeamer.HotkeyFormatter.getKeyCombination(['esc']), documentation: 'hotkey.form.cancel.description'}
		 ]);

		// on textareas disable the ctrl+alt+ combinations
		$(document).on('keyup', 'textarea', function(event) {
			if (event.ctrlKey && event.altKey) {
				event.stopPropagation();
			}
		});

		// prevent alt+2 from writing anything to the textareas
		var disableTrademarkSign = function(event) {
			if ((event.altKey && event.which == 50) || event.which == 8482) {
				event.preventDefault();
			}
		};

		$(document).on('keypress', 'textarea', disableTrademarkSign);
		$(document).on('keyup', 'textarea', disableTrademarkSign);
	}
});


codebeamer.WidgetEditorHotkeys = codebeamer.WidgetEditorHotkeys || function(config) {
	this.init(config);
}

$.extend(codebeamer.WidgetEditorHotkeys.prototype, codebeamer.Hotkeys.prototype, {
	modules: ['edit'],
	getModuleHotkeyDependency: function () {
		return {
			'edit': [
		           {
        			   key: codebeamer.HotkeyFormatter.getKeyCombination(['ctrl', 's']),
		        	   action: function () {
		        		   $('#editorForm').submit();
		        	   },
		        	   documentation: 'hotkey.table.widget.editor.save'
		           },
		           {
		        	   key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', '1']),
		        	   action: function () {
		        		   var event, previewTab;

		        		   event = {
		        	           _selectedIndex: 0
		        		   };

		        		   previewTab = document.getElementById("preview-tab-tab");

		        		   if (previewTab) {
			        		   org.ditchnet.jsp.TabUtils.switchTab(document.getElementById("editor-tab-tab"));
			        		   tabChanged(event);
		        		   }
		        	   },
		        	   documentation: 'hotkey.table.widget.editor.editorTab'
		           },
		           {
		        	   key: codebeamer.HotkeyFormatter.getKeyCombination(['alt', '2']),
		        	   action: function () {
		        		   var event, previewTab;

		        		   event = {
		        	           _selectedIndex: 1
		        		   };

		        		   previewTab = document.getElementById("preview-tab-tab");

		        		   if (previewTab) {
			        		   org.ditchnet.jsp.TabUtils.switchTab(previewTab);
			        		   tabChanged(event);
		        		   }
		        	   },
		        	   documentation: 'hotkey.table.widget.editor.editor.previewTab'
		           }
		    ]
		}
	}

});
