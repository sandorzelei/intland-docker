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
 *
 * $Revision$ $Date$
 */

(function($) {

	// A plugin to show a a form where to map source fields to target fields
	$.fn.trackerItemFieldMappingForm = function(mapping, config) {
		var settings = $.extend( {}, $.fn.trackerItemFieldMappingForm.defaults, config );

		function init(container, mapping) {
			if (!$.isPlainObject(mapping)) {
				mapping = {
					possible : [],
					lost 	 : []
				};
			}

			if ($.isArray(mapping.possible) && mapping.possible.length > 0) {
				var fieldSet = $('<fieldset>').append($('<legend>').text(settings.mappingLabel));
				container.append(fieldSet);

				var fields = $('<table>', { "class" : 'fieldMapping formTableWithSpacing' });
				fieldSet.append(fields);

				for (var i = 0; i < mapping.possible.length; ++i) {
					var field = mapping.possible[i].field;
					var fieldMapping = $('<tr>', { "class" : "fieldMapping" }).data('field', field);
					fieldMapping.append($('<td>', { "class" : 'optional', title : field.description }).append(field.name));

					var targetsCell    = $('<td>');
					var targetSelector = $('<select>', { name : 'targetField' });

					targetSelector.append($('<option>', { "class" : 'field', value : -1 }).text(settings.targetFieldNone));

					var targets = mapping.possible[i].targets;
					if ($.isArray(targets) && targets.length > 0) {
						for (var j = 0; j < targets.length; ++j) {
							targetSelector.append($('<option>', { "class" : 'field', value : targets[j].id, title : targets[j].description }).append(targets[j].name));
						}
					}

					targetsCell.append(targetSelector);
					fieldMapping.append(targetsCell);
					fields.append(fieldMapping);
				}
			}

			if ($.isArray(mapping.lost) && mapping.lost.length > 0) {
				var div = $('<div>', {"class" : 'warning' });
				container.append(div);
				div.append(settings.lostLabel);

				var lost = $('<ul>');
				div.append(lost);

				if (mapping.lost.length > 1) {
					mapping.lost.sort(function(a,b) {
						return a.name.localeCompare(b.name);
					});
				}

				for (var i = 0; i < mapping.lost.length; ++i) {
					lost.append($('<li>', { title : mapping.lost[i].description }).append(mapping.lost[i].name));
				}
			}
		}

		return this.each(function() {
			init($(this), mapping);
		});
	};

	$.fn.trackerItemFieldMappingForm.defaults = {
		mappingLabel	 : 'Please map the following source and target fields manually:',
		sourceFieldLabel : 'Source Field',
		targetFieldLabel : 'Target Field',
		targetFieldNone  : '--not available--',
		lostLabel		 : 'The content of following source fields will not be transferred and will get lost!'
	};


	// Get the resulting field mapping from a mapping form
	$.fn.getTrackerItemFieldMapping = function() {
		var result = {};

		$('table.fieldMapping > tbody > tr.fieldMapping', this).each(function() {
			var fieldMapping = $(this);
			var field  = fieldMapping.data('field');
			var target = $('select[name="targetField"] > option.field:selected', fieldMapping);
			if (field && target.length == 1) {
				var targetId = parseInt(target.attr('value'));
				if (!isNaN(targetId) && targetId > 0) {
					result[field.id.toString()] = {
						id   : targetId,
						name : target.text()
					};
				}
			}
		});

		return result;
	};


	// Show a dialog where the user can configure the mapping of source fields to target fields
	$.fn.showTrackerItemMappingDialog = function(mapping, config, dialog, callback) {
		var settings = dialog; //$.extend( {}, $.fn.showTrackerItemMappingDialog.defaults, dialog );

		var popup = $('#issueCopyMovePopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: none;' });
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		popup.trackerItemFieldMappingForm(mapping, config);

		settings.buttons = [
		   { text : settings.submitText,
			 click: function(event) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
				 		buttons.button("disable");
						popup.css('cursor', 'progress');

					 	callback(popup.getTrackerItemFieldMapping(), function(done) {
						 	if (done) {
					  			popup.dialog("close");
					  			popup.remove();
						 	} else {
					    		buttons.button("enable");
								popup.css('cursor', 'auto');
						 	}
					 	});
					}
			},
			{ text : settings.cancelText,
			  "class": "cancelButton",
			  click: function() {
			  			popup.dialog("close");
			  			popup.remove();
			  			callback(false);
					 }
			}
		];

		settings.close = function() {
  			popup.remove();
  			callback(false);
		};

		popup.dialog(settings);
	};


	// Plugin shows a form to select the destination project/tracker where to move items to
	$.fn.destinationProjectAndTrackerSelector = function(tracker, settings) {

		function init(container, tracker) {
			if (!$.isPlainObject(tracker)) {
				tracker = {
					id   : null,
					type : 0,
					name : settings.itemsLabel
				};
			}

			if (!$.isPlainObject(tracker.project)) {
				tracker.project = {
					id  : 0,
					name: settings.projectLabel
				};
			}

			var projectSelector = $('<select>', { name : 'project', "class": "issueCopyMoveProjectSelector", title : settings.projectTitle.replace('ABC', settings.action) });
			container.append(projectSelector);

			projectSelector.append($('<option>', { "class" : (tracker.project.id == 0 ? 'placeholder' : 'project'), value : tracker.project.id, selected : true, disabled : (tracker.project.id == 0) }).text(tracker.project.name));

			$.get(settings.projectsUrl).done(function(projects) {
				for (var i = 0; i < projects.length; ++i) {
					if (projects[i].id != tracker.project.id) {
						projectSelector.append($('<option>', { "class" : 'project', value: projects[i].id }).text(projects[i].name));
					}
				}
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
	    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });

			container.append('&nbsp;&nbsp;&raquo;&nbsp;&nbsp;');

			var trackerSelector = $('<select>', { name : 'tracker', "class": "issueCopyMoveTrackerSelector", title : settings.trackerTitle.replace('ABC', settings.action) });
			container.append(trackerSelector);

			trackerSelector.append($('<option>', { "class" : 'placeholder', value : null, selected : true, disabled : true }).text(settings.trackerLabel));

			projectSelector.change(function() {
				var value = this.value;

				$('optGroup', 		trackerSelector).remove();
				$('option.tracker', trackerSelector).remove();

				if (value != '0') {
					$.ajax(settings.trackersUrl, {type: 'GET', data : { proj_id : value, type_id : tracker.type }, dataType : 'json' }).done(function(trackersPerPath) {
						if (trackersPerPath.length > 1) {
							for (var i = 0; i < trackersPerPath.length; ++i) {
								var trackers = trackersPerPath[i].trackers;

								if ($.isArray(trackers) && trackers.length > 0) {
									var trackerGroup = $('<optGroup>', { label : trackersPerPath[i].path });

									for (var j = 0; j < trackers.length; ++j) {
										if (settings.copy || trackers[j].id != tracker.id) {
											var $trackerOption = $('<option>', {
												"class" : 'tracker',
												value : trackers[j].id,
												title : trackers[j].title
											}).text(trackers[j].name).data('tracker', trackers[j]);

											if (trackers[j].isBranch) {
												$trackerOption.addClass('branch');
											}

											if (!trackers[j].visible) {
												$trackerOption.addClass('hidden');
											}

											trackerGroup.append($trackerOption);
										}
									}

									trackerSelector.append(trackerGroup);
								}
							}

						} else if (trackersPerPath.length == 1) {
							var trackers = trackersPerPath[0].trackers;
							if ($.isArray(trackers) && trackers.length > 0) {
								for (var i = 0; i < trackers.length; ++i) {
									if (settings.copy || trackers[i].id != tracker.id) {
										var $trackerOption = $('<option>', {
											"class" : 'tracker',
											value: trackers[i].id,
											title : trackers[i].title
										}).text(trackers[i].name).data('tracker', trackers[i]);

										if (!trackers[i].visible) {
											$trackerOption.addClass('hidden');
										}
										trackerSelector.append($trackerOption);

										if (trackers[i].branchList && trackers[i].branchList.length) {
											for (var k = 0; k < trackers[i].branchList.length; k++) {
												var branch = trackers[i].branchList[k];
												var classes = 'tracker branchTracker';
												if (branch.level) {
													classes += ' level-' + branch.level;
												}

												var $branchOption = $('<option>', {
													"class" : classes,
													value: branch.id,
													title : branch.title
												}).text(branch.name).data('tracker', branch);

												trackerSelector.append($branchOption);
											}
										}
									}
								}
							}
						}

						// make the list a multiselect. this is necessary to be able to stlye (color, padding) the options
						$('.issueCopyMoveTrackerSelector').multiselect({
							multiple: false,
							'classes' : 'trackerSelector',
							height: 300,
							'selectedText': function(numChecked, numTotal, checked) {
								var value = [];
								$(checked).each(function(){
									value.push($(this).next().html());
								});
								return value.join(", ");
							}
						});
			    	}).fail(function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
			    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			    		}
			        });
				}
			});

			if (tracker.project.id > 0) {
				projectSelector.change();
			}

			if (settings.copy) {
				container.associationBetweenCopiedItems(null, settings.association);
			}

			var div = $('<div>', { style : 'margin-top: 8px; margin-bottom: 8px;' });
			container.append(div);

			var label = $('<label>', { title : settings.switchToTitle.replace('ABC', settings.action) });
			label.append($('<input>', { type : 'checkbox', name : 'switchTo', checked : false, style : 'margin-right: 4px;' }));
			label.append(settings.switchToLabel);

			div.append(label);
		}

		return this.each(function() {
			init($(this), tracker);
		});
	};


	// Plugin to get the destination project and tracker from a destinationProjectAndTrackerSelector form
	$.fn.getDestinationProjectAndTracker = function() {
		return {
			tracker : $('select[name="tracker"] > option.tracker:selected', this).data('tracker'),
			follow  : $('input[type="checkbox"][name="switchTo"]', this).is(':checked')
		};
	};


	// Transfer the specified tracker items to the specified destination (optionally setup the specified type of associations between copied items and original items )
	$.fn.copyMoveTrackerItems = function(tracker, items, destination, association, config, callback) {
		var settings = $.extend( {}, $.fn.showTrackerItemsCopyMoveToDialog.defaults, config );
		var popup    = settings.popup;
		var context  = this;

		setAssociationSettingsDefaults(settings);

		callback = callback || function() {};

		/**
		 * checks if there are no two fields mapped to the same target field. returns true if the mapping passes the validation
		 */
		var validateMapping = function (mapping) {
			if (!mapping) {
				return false;
			}

			var targetIds = $.map(mapping, function (item) {return item.id;})
			var unique = $.unique(targetIds.slice()); // slice is important because it copies the id array

			// reutrn true if there are no duplications
			return targetIds.length == unique.length;
		};

		if (tracker && tracker.id && $.isArray(items) && items.length > 0) {
			if (popup) {
				popup.css('cursor', 'progress');
			}

			$.ajax(settings.submitUrl + tracker.id, {type: 'POST',
				data : JSON.stringify({ items : items, baseline : tracker.baseline, destination : destination, association : association, ignoreEmptyFields: settings.ignoreEmptyFields }),
				contentType : 'application/json', dataType : 'json' }).done(function(result) {
				if (popup) {
					popup.dialog("close");
		  			popup.remove();
	  			}

	  			if (result.mapping) {
 					var target = ' ' + result.destination.tracker.name;

 					if (result.destination.tracker.id != result.origin.id) {
	  					if (result.destination.tracker.project.id != result.origin.project.id) {
	  						target = ' ' + result.destination.tracker.project.name + ' \u00bb ' + result.destination.tracker.path + ' \u00bb ' + result.destination.tracker.name;
	  					} else if (result.destination.tracker.path != result.origin.path) {
	  						target = ' ' + result.destination.tracker.path + ' \u00bb ' + result.destination.tracker.name;
	  					}
	  				}

	  				settings.position = { my: "center", at: "center", of: window, collision: 'fit' };
	  				settings.title    = settings.title.replace('XX', items.length).replace('YY', tracker.name).replace('...', target);

	  				context.showTrackerItemMappingDialog(result.mapping, settings.mapping, settings, function(mapping, mappingDone) {
	  					if (mapping) {
	  						if (!validateMapping(mapping)) {
	  							showFancyAlertDialog(i18n.message("issue.paste.assign.duplicate.fields"));
	  							mappingDone(false);
	  							return;
	  						}
		  					$.ajax(settings.submitUrl + tracker.id, {type: 'POST', data : JSON.stringify({ items : items, baseline : tracker.baseline, destination : destination, association : association, mapping : mapping }), contentType : 'application/json', dataType : 'json' }).done(function(result) {
		  						mappingDone(true);
		  						callback(result);

					    	}).fail(function(jqXHR, textStatus, errorThrown) {
					    		try {
						    		var exception = $.parseJSON(jqXHR.responseText);
						    		alert(exception.message);
					    		} catch(err) {
					    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					    		}
					    		mappingDone(false);
					        });
	  					} else {
	  						callback(false);
	  					}
	  				});
	  			} else {
	  				callback(result);
	  			}
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	  			try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
			    	console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}

	  			if (popup) {
					popup.css('cursor', 'auto');
			 		popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button').button("enable");
	  			}

	  			callback(false);
	        });
		}
	};


	// A plugin to show a dialog where to select the destination project/tracker where to copy/move items to
	$.fn.showTrackerItemsCopyMoveToDialog = function(tracker, items, config, callback) {
		var settings = $.extend( {}, $.fn.showTrackerItemsCopyMoveToDialog.defaults, config );
		var context  = this;

		setAssociationSettingsDefaults(settings);

		callback = callback || function() {};

		if ($.isArray(items) && items.length > 0) {
			var popup = $('#issueCopyMovePopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: None;' });
				this.closest('form').append(popup);
			} else {
				popup.empty();
			}

			if (!$.isPlainObject(tracker)) {
				tracker = {
					id   : null,
					type : 0,
					name : settings.itemsLabel
				};
			}

			popup.destinationProjectAndTrackerSelector(tracker, settings);

			settings.popup    = popup;
			settings.title    = settings.title.replace('XX', items.length).replace('YY', tracker.name);
			settings.position = { my: "center", at: "center", of: window, collision: 'fit' };

			settings.buttons = [
			   { text : settings.submitText,
				 click: function(event) {
					 var destination = popup.getDestinationProjectAndTracker();
					        if (destination && destination.tracker && destination.tracker.id) {
						 		var association = (settings.copy ? popup.getAssociationBetweenCopiedItems() : null);

						 		popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button').button("disable");

						 		settings = $.extend(settings, {ignoreEmptyFields: true});
						 		context.copyMoveTrackerItems(tracker, items, destination, association, settings, function(result) {
						 			if (result) {
						 				if (destination.follow) {
						 	  				document.location.href = settings.followUrl + destination.tracker.id;
						 	  			} else if (!settings.copy) {
						 	  				document.location.reload();
						 	  			} else {
						 	  				showOverlayMessage(i18n.message("issue.copyMove.successful.message"));
						 	  			}
						 			}
						 			callback(result);
						 		});
					        } else {
					        	alert(settings.noDestination);
					        }
						}
				},
				{ text : settings.cancelText,
				  "class": "cancelButton",
				  click: function() {
				  			popup.dialog("close");
				  			popup.remove();
				 			callback(false);
						 }
				}
			];

			settings.close = function() {
	  			popup.remove();
	 			callback(false);
			};

			popup.dialog(settings);

		} else {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			showFancyAlertDialog(settings.noItemsWarning);
			return;
		}
	};

	$.fn.showTrackerItemsCopyMoveToDialog.defaults = {
		dialogClass		: 'popup',
		width			: 640,
		draggable		: true,
		modal			: true,
		closeOnEscape	: false,
		copy			: true,
		action			: 'Copy',
		title			: 'Copy XX YY to ...',
	    itemsLabel   	: 'Items',
	    noItemsWarning  : 'No items to be copied/moved',
	    projectLabel    : 'Destination project',
		projectTitle    : 'Select the destination project for the ABC operation',
	    trackerLabel    : 'Destination tracker',
		trackerTitle    : 'Selected the destination tracker for the ABC operation',
	    noDestination   : 'Please select the destination project and tracker',
		switchToLabel   : 'Switch to destination',
		switchToTitle   : 'Should the browser view switch to the destination tracker after the ABC operation ?',
		submitText		: 'OK',
		cancelText		: 'Cancel',
		projectsUrl     : contextPath + '/proj/ajax/projects.spr',
		trackersUrl     : contextPath + '/trackers/ajax/compatibleProjectTrackers.spr',
		submitUrl		: contextPath + '/trackers/ajax/copyTrackerItems.spr?tracker_id=',
		followUrl		: contextPath + '/tracker/',
		association		: $.fn.associationBetweenCopiedItems.defaults,
		mapping			: $.fn.trackerItemFieldMappingForm.defaults,
		appendTo		: "body"
	};


	// A  plugin to cut/copy tracker items to the clipboard (via Ajax)
	$.fn.cutCopyTrackerItemsToClipboard = function(tracker, items, config, callback) {
		var settings = $.extend( {}, $.fn.showTrackerItemsCopyMoveToDialog.defaults, config );

		callback = callback || function(result) {
			if (result) {
				showOverlayMessage(i18n.message("issue.copy.successful.message"));
			}
		};

		if (tracker && tracker.id && $.isArray(items) && items.length > 0) {
			$.ajax(settings.submitUrl + tracker.id, {type: 'POST', data : JSON.stringify({ items : items, baseline : tracker.baseline, destination : { clipboard : true }}), contentType : 'application/json', dataType : 'json' }).done(function(result) {
				callback(result);

			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
	    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	    		callback(false);
	        });
		} else {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			showFancyAlertDialog(settings.noItemsWarning);
			return;
		}
	};


	// Show a dialog where the user can configure the mapping of source fields to target fields
	$.fn.showPasteMappingAndAssociationDialog = function(pasting, settings, callback) {
		var transfer = $.extend({}, pasting, {
			association : null,
			mapping     : {}
		});

		var popup = $('#issueCopyMovePopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: None;' });
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		if (pasting.copy) {
			popup.associationBetweenCopiedItems(null, settings.association);
		}

		if (pasting.mapping) {
			popup.trackerItemFieldMappingForm(pasting.mapping, settings.mapping);
		}

 		settings.buttons = [
		   { text : settings.submitText,
			 click: function(event) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
				 		buttons.button("disable");
				 		popup.css('cursor', 'progress');

				 		if (transfer.copy) {
					 		transfer.association = popup.getAssociationBetweenCopiedItems();
				 		}

						if (pasting.mapping) {
							transfer.mapping = popup.getTrackerItemFieldMapping();
						}

					 	callback(transfer, function(done) {
						 	if (done) {
					  			popup.dialog("close");
					  			popup.remove();
						 	} else {
						 		popup.css('cursor', 'auto');
					    		buttons.button("enable");
						 	}
					 	});
					}
			},
			{ text : settings.cancelText,
			  "class": "cancelButton",
			  click: function() {
			  			popup.dialog("close");
			  			popup.remove();

			  			callback(false);
					 }
			}
		];

		settings.close = function() {
  			popup.remove();
  			callback(false);
		};

		popup.dialog(settings);
	};


	var setAssociationSettingsDefaults = function (settings) {
		var associationSettings = settings.association;

		// the copy of type association is selected by default
		for (var i = 0; i < associationSettings.assocTypes.length; ++i) {
			if (associationSettings.assocTypes[i].id == 9) {
				associationSettings.assocTypes[i].selected = true;

				// propagate suspected is checked by default
				associationSettings.propagateSuspectedByDefault = true;
				break;
			}
		}
	};

	// A plugin to paste tracker items from the clipboard to a destination (item/tracker) (via Ajax)
	$.fn.pasteTrackerItemsFromClipboard = function(destination, config, callback) {
		var settings = $.extend( {}, $.fn.showTrackerItemsCopyMoveToDialog.defaults, config );
		var context  = this;

		setAssociationSettingsDefaults(settings);

		callback = callback || function(result) {
			if (result) {
				document.location.reload();
			}
		};

		if (destination && destination.tracker && destination.tracker.id) {
			var body = $('body');
			body.css('cursor', 'progress');

			$.ajax(settings.pasteUrl + destination.tracker.id, {type: 'POST', data : JSON.stringify(destination), contentType : 'application/json', dataType : 'json' }).done(function(pasting) {
				body.css('cursor', 'auto');

				if (pasting.copy || pasting.mapping) {
					var origin = pasting.origin.name;

  					if (pasting.origin.project.id != pasting.destination.tracker.project.id) {
  						origin = pasting.origin.project.name + ' \u00bb ' + pasting.origin.path + ' \u00bb ' + pasting.origin.name;
  					} else if (pasting.origin.path != pasting.destination.tracker.path) {
  						origin = pasting.origin.path + ' \u00bb ' + pasting.origin.name;
  					}

	  				if (pasting.baseline) {
	  					origin += ' (' + pasting.baseline.name + ')';
	  				}

	  				settings.title     = (pasting.copy ? settings.copyTitle  : settings.moveTitle ).replace('XX', pasting.items.length).replace('YY', origin);
	  				settings.action    = (pasting.copy ? settings.copyAction : settings.moveAction);
	  				settings.submitUrl = (pasting.copy ? settings.copyUrl    : settings.moveUrl   );
	  				settings.position  = { my: "center", at: "center", of: window, collision: 'fit' };

 	  				if (pasting.copy) {
	  					settings.width = settings.copyWidth;
	  				}

	  				context.showPasteMappingAndAssociationDialog(pasting, settings, function(transfer, pasteDone) {
	  					if (transfer) {
		  					transfer.destination = destination;
		  					transfer.clearClipboard = true;

							$.ajax(settings.submitUrl + pasting.origin.id, {type: 'POST', data : JSON.stringify(transfer), contentType : 'application/json', dataType : 'json' }).done(function(result) {
								pasteDone(true);
								callback(transfer);

					    	}).fail(function(jqXHR, textStatus, errorThrown) {
					    		try {
						    		var exception = $.parseJSON(jqXHR.responseText);
						    		alert(exception.message);
					    		} catch(err) {
					    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					    		}
					    		pasteDone(false);
					        });
	  					} else {
	  						callback(false);
	  					}
	  				});
	  			} else {
					callback(true);
	  			}
			}).fail(function(jqXHR, textStatus, errorThrown) {
				body.css('cursor', 'auto');

				try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
	    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}

	    		callback(false);
	        });
		}
	};


	// A  plugin to remove tracker items (via Ajax)
	$.fn.removeTrackerItems = function(tracker, items, settings, callback) {
		if (tracker && tracker.id && $.isArray(items) && items.length > 0) {
			callback = callback || function(result) {
				if (result) {
					document.location.reload();
				}
			};

			if (confirm(settings.confirmMsg.replace('XX', items.length))) {
				var body = $('body');
				body.css('cursor', 'progress');

				$.ajax(settings.submitUrl + tracker.id, {type: 'POST', data : JSON.stringify(items), contentType : 'application/json', dataType : 'json' }).done(function(result) {
					body.css('cursor', 'auto');
					callback(true);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					body.css('cursor', 'auto');

		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
		    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}

		    		callback(false);
		        });
			} else {
				callback(false);
			}
		} else {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			showFancyAlertDialog(settings.noItemsWarning);
			return;
		}
	};


	// Show a dialog where the user can mass edit the selected items
	$.fn.showMassEditDialog = function(context, items, config, settings, callback) {

		function isBaselineFormValid() {
			var result = false;

			if ($("input[name=baselineName]").val()) {
				result = true;
			}

			return result;
		}

		var popup = $('#issueCopyMovePopup');

		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: None;' });
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		var $updateContainer = $("<div class='update-container visible-container'></div>");
		$updateContainer.appendTo(popup);

		var baselineHintMessage = createInfoMessageBox(settings.baselineHint, "information");
		baselineHintMessage.addClass("baseline-hint-message hidden-container");
		$updateContainer.prepend(baselineHintMessage);

		$updateContainer.append($('<a>', { href: settings.help.URL, title : settings.help.title, style : 'float: Right;' }).append(
			$('<img>', { "class" : 'labelHintImg', src : contextPath + "/images/newskin/action/information-s.png", style: 'margin-top: 1px;' })
		).click(function() {
			window.open(settings.help.URL, "_blank");
			return false;
		}));

		$updateContainer.append($('<p>').text(settings.header.replace('XX', context.tracker.name).replace('YY', items.length) + ": "));

		$updateContainer.trackerFieldUpdates(context, [], $.extend({}, config, {items: items}));

		if (context.removed && context.removed.length > 0) {
			$updateContainer.append($('<p>').text(settings.removedInfo.replace('XX', context.removed)));
		}

		popup.append(
			"<div class='baseline-container hidden-container'>" +
			"<table class='baselineDetails formTableWithSpacing'>" +
			"<tr>" +
			"<td class='labelCell mandatory'>" + settings.baselineName + "</td>" +
			"<td class='dataCell'>" +
			"<div class='mandatoryNotice'>" +
			"<span class='invalid'>" + settings.baselineFieldMandatory + "</span>" +
			"</div>" +
			"<input type='text' name='baselineName' maxlength='80' autocomplete='off'></input>" +
			"</td>" +
			"</tr>" +
			"<tr>" +
			"<td class='labelCell optional'>" + settings.baselineDescription + "</td>" +
			"<td class='dataCell'><textarea type='text' name='baselineDescription' maxlength='100' cols='80' rows='2'></textarea></td>" +
			"</tr>" +
			"<tr>" +
			"<td class='labelCell optional'>" + settings.baselineSignature + "</td>" +
			"<td class='dataCell'>" +
			"<input type='text' name='baselineSignature' maxlength='80'></input>" +
			"</td>" +
			"</tr>" +
			"<tr>" +
			"<td class='labelCell'></td>" +
			"<td class='dataCell'>" +
			"<input type='checkbox' id='baselineMode' name='baselineMode' checked></input>" +
			"<label for='baselineMode'>" + settings.baselineMode + "</label>" +
			"</td>" +
			"</tr>" +
			"</table>" +
			"</div>"
		);

		var baselineInfoMessage = createInfoMessageBox(settings.baselineHeader, "information");
		popup.find(".baseline-container").prepend(baselineInfoMessage);

		codebeamer.prefill.prevent(popup.find("input[name=baselineSignature]"), getBrowserType());

		settings.title = settings.title.replace('XX', context.tracker.name).replace('YY', items.length);

		settings.buttons = [{
			text: settings.prevText,
			"class": "second-step-control hidden-button",
			click: function(event) {
				$(".update-container").removeClass("hidden-container").addClass("visible-container");
				$(".baseline-container").removeClass("visible-container").addClass("hidden-container");
				$(".first-step-control").removeClass("hidden-button");
				$(".second-step-control").addClass("hidden-button");
				// Hide Save button in the first step, if user is baseline admin AND baseline is mandatory
				if (isBaselineMandatory && config.isBaselineAdmin) {
					$(".submit-control").addClass("hidden-button");
					$(".baseline-hint-message").removeClass("hidden-container");
				}
				event.preventDefault();
				event.stopPropagation();
			}
		},
		{
			text  : settings.submitText,
			"class": "submit-control",
			click : function(event) {
				function isBaselineAdmin() {
					return config.isBaselineAdmin;
				}

				function isBaselineAdminSkippinghBaseline() {
					return config.isBaselineAdmin && !isBaselineMandatory && $(".update-container").hasClass("visible-container");
				}

				function isBaselineAdminCreatingBaselineWhenMandatory() {
					return isBaselineMandatory && config.isBaselineAdmin && isBaselineFormValid();
				}

				function isBaselineAdminCreatingBaselineWhenNotMandatory() {
					return !isBaselineMandatory && config.isBaselineAdmin && isBaselineFormValid();
				}

		 		try {
		 			var data = {
			 			items 	: items,
					 	updates : popup.getTrackerFieldUpdates(config.mandatoryValue),
					 	baseline: {
					 		name: $("input[name=baselineName]").val(),
					 		description: $("textarea[name=baselineDescription]").val(),
					 		signature: $("input[name=baselineSignature]").val(),
					 		isTrackerMode: $("input[name=baselineMode]").is(":checked")
					 	}
			 		};

			 		// Allow submit, if:
			 		// - The user is not a baseline admin
			 		// - The user is baseline admin, but baseline is not mandatory and pressed the Save button on the first page of the wizard
			 		// - The user is baseline admin, baseline is mandatory and form is properly filled, and pressed the Save button on the second page of the wizard
			 		// - The user is baseline admmin, baseline is not mandatory and form is proplery filled, and pressed the Save button on the second page of the wizard
		 			if (!$.isEmptyObject(data.updates) && (!isBaselineAdmin()
		 					|| isBaselineAdminSkippinghBaseline()
		 					|| isBaselineAdminCreatingBaselineWhenMandatory()
		 					|| isBaselineAdminCreatingBaselineWhenNotMandatory())) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
				 		buttons.button("disable");
				 		popup.css('cursor', 'progress');

						$.ajax(settings.submitUrl + context.tracker.id, {type: 'POST', data : JSON.stringify(data), contentType : 'application/json', dataType : 'json' }).done(function(result) {
							popup.css('cursor', 'auto');
							callback(result);

				  			popup.dialog("close");
				  			popup.remove();

				    	}).fail(function(jqXHR, textStatus, errorThrown) {
					 		buttons.button("enable");
				    		popup.css('cursor', 'auto');

				    		try {
					    		var exception = $.parseJSON(jqXHR.responseText);
					    		alert(exception.message);
				    		} catch(err) {
					    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
				    		}
				        });
		 			} else {
		 				if (!$.isEmptyObject(data.updates) && config.isBaselineAdmin) {
		 					if (!$(".mandatoryNotice").hasClass("visible")) {
			 					$(".mandatoryNotice").addClass("visible");
		 					}
		 				} else {
		 					if ($.isEmptyObject(data.updates)) {
		 						showFancyAlertDialog(settings.submitWarning);
		 					}
		 				}
		 			}

	 			} catch(ex) {
	 				alert(ex);
	 			}
			}
		},
		{
			text  : settings.cancelText,
			"class": "cancelButton",
			click : function() {
				popup.dialog("close");
				popup.remove();
				callback(false);
			 }
		}];

		if (config.isBaselineAdmin) {
			settings.buttons.splice(2, 0, {
				text: settings.nextText,
				"class": "first-step-control",
				click: function(event) {
					$(".update-container").removeClass("visible-container").addClass("hidden-container");
					$(".baseline-container").removeClass("hidden-container").addClass("visible-container");
					$(".second-step-control").removeClass("hidden-button");
					$(".first-step-control").addClass("hidden-button");
					$(".submit-control").removeClass("hidden-button");
					$(".mandatoryNotice").removeClass("visible");
					event.preventDefault();
					event.stopPropagation();
				 }
			});
		}

		settings.close = function() {
  			popup.remove();
  			callback(false);
		};

		var isBaselineMandatory = false;

		$("body").on("baseline:mandatory", function() {
			// Hide Save button in the first step, if user is baseline admin AND baseline is mandatory
			if (!$("first-step-control").hasClass("hidden-button") && config.isBaselineAdmin) {
				$(".submit-control").addClass("hidden-button");
				$(".baseline-hint-message").removeClass("hidden-container");
			}

			isBaselineMandatory = true;
		});

		$("body").on("baseline:optional", function() {
			$(".mandatoryNotice").removeClass("visible");
			$(".submit-control").removeClass("hidden-button");
			$(".baseline-hint-message").addClass("hidden-container");

			isBaselineMandatory = false;
		});

		popup.dialog(settings);
	};


	// A  plugin to remove tracker items (via Ajax)
	$.fn.massEditTrackerItems = function(tracker, items, settings, callback) {
		var selectbox = $(this);

		callback = callback || function(result) {
			if (result) {
				document.location.reload();
			}
		};

		if (tracker && tracker.id && $.isArray(items) && items.length > 0) {
			$.ajax(settings.initUrl + tracker.id, {type: 'POST', data : JSON.stringify(items), contentType : 'application/json', dataType : 'json' }).done(function(result) {
				selectbox.showMassEditDialog({
					tracker	: tracker,
					fields 	: result.fields,
					removed : result.removed
				}, items, $.extend({}, settings, result.config), $.extend({}, {
					dialogClass		: 'popup',
					width			: 640,
					draggable		: true,
					modal			: true,
					closeOnEscape	: false
				}, settings), callback);
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
	    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });
		} else {
			var $reportSelector = $(".reportSelectorTag");
			if ($reportSelector.length == 1) {
				var reportSelectorId = $reportSelector.attr("id");
				if (codebeamer.ReportSupport.intelligentTableViewIsEnabled(reportSelectorId)) {
					showFancyAlertDialog(i18n.message("intelligent.table.view.not.supported.action"));
					return;
				}
			}
			showFancyAlertDialog(settings.noItemsWarning);
			return;
		}
	};


	// Show a dialog where the user can submit rating for the specified item
	$.fn.showReviewDialog = function(review, options, callback) {
		var settings = $.extend({}, $.fn.showReviewDialog.defaults, options);

		var popup = $('#issueCopyMovePopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: None;' });
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		popup.append($('<a>', { href: settings.help.URL, title : settings.help.title, style : 'float: Right;' }).append(
			$('<img>', { "class" : 'labelHintImg', src : contextPath + "/images/newskin/action/information-s.png", style: 'margin-top: 1px;' })
		).click(function() {
			window.open(settings.help.URL, "_blank");
			return false;
		}));

		var config = review.config;
		if (!$.isPlainObject(config)) {
			config = {
				range     : 1,
				signature : 0
			};
		}

		var type = (config.range > 1 ? settings.rating : settings.approval);

		popup.append($('<p>').text(type.header.replace('XX', review.reviewer.name).replace('YY', review.item.name)));

		if (config.range > 1 || config.signature) {
			var fields = $('<table>', { "class" : 'formTableWithSpacing' });
			popup.append(fields);

			if (config.range > 1) {
				var ratingRow   = $('<tr>',  { title : settings.rating.tooltip, style: 'vertical-align: middle;' });
				var ratingLabel = $('<td>',	 { "class" : 'labelCell mandatory' }).text(settings.rating.label + ':');
				var ratingCell  = $('<td>',  { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
				var ratingEcho  = $('<label>', { style : 'float: Right; margin-left: 1em; margin-top: 5px;' });
				var ratingInput = $('<input>', { type: 'range', name : 'rating', min : 0, max : config.range, value : config.range/2, style : 'border: 0;' }).change(function() {
					ratingEcho.text($(this).val() + ' ' + settings.rating.ofLabel + ' ' + config.range);
				}).change();

				ratingCell.append(ratingEcho);
				ratingCell.append(ratingInput);
				ratingRow.append(ratingLabel);
				ratingRow.append(ratingCell);
				fields.append(ratingRow);
			}

			if (config.signature) {
				if (config.signature > 1) {
					var usernameRow   = $('<tr>',  { title : settings.signature.username.tooltip, style: 'vertical-align: middle;' });
					var usernameLabel = $('<td>',  { "class" : 'labelCell mandatory' }).text(settings.signature.username.label + ':');
					var usernameCell  = $('<td>',  { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
					var usernameInput = $('<input>', { type: 'text', name : 'username', "size" : 25, maxlength : 160 });

					usernameCell.append(usernameInput);
					usernameRow.append(usernameLabel);
					usernameRow.append(usernameCell);
					fields.append(usernameRow);
				}

				var passwordRow   = $('<tr>',  { title : settings.signature.password.tooltip, style: 'vertical-align: middle;' });
				var passwordLabel = $('<td>',  { "class" : 'labelCell mandatory' }).text(settings.signature.password.label + ':');
				var passwordCell  = $('<td>',  { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
				var passwordInput = $('<input>', { type: 'password', name : 'password', "size" : 25, maxlength : 160 });

				passwordCell.append(passwordInput);
				passwordRow.append(passwordLabel);
				passwordRow.append(passwordCell);
				fields.append(passwordRow);
			}
		}

		callback = callback || function(result) {
			if (result) {
				if (result.url /*&& confirm(result.label)*/) { // According to Janos and Peter: Only one click, so no confirmation
					document.location.href = result.url;
				} else {
					document.location.reload();
				}
			}
		};

		var submit = function(rating) {
	 		try {
	 			var data = $.extend( {}, review.item, {
	 				reviewer : review.reviewer,
		 			rating   : rating
		 		});

				if (config.signature) {
					data.reviewer = $.extend( {}, review.reviewer, {
						password : $.trim($('input[name="password"]', popup).val())
					});

					if (config.signature > 1) {
						data.reviewer.name = $.trim($('input[name="username"]', popup).val());
						if (!data.reviewer.name || data.reviewer.name.length == 0) {
							alert(settings.signature.username.required);
							return false;
						}
					}

					if (!data.reviewer.password || data.reviewer.password.length == 0) {
						alert(settings.signature.password.required);
						return false;
					}
				}

		 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button');
		 		buttons.button("disable");
		 		popup.css('cursor', 'progress');

				$.ajax(settings.submitUrl + review.item.id, {type: 'POST', data : JSON.stringify(data), contentType : 'application/json', dataType : 'json' }).done(function(result) {
					popup.css('cursor', 'auto');
					callback(result);

		  			popup.dialog("close");
		  			popup.remove();

		    	}).fail(function(jqXHR, textStatus, errorThrown) {
			 		buttons.button("enable");
		    		popup.css('cursor', 'auto');

		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        });
 			} catch(ex) {
 				alert(ex);
 			}
		};

		settings.title = type.title.replace('XX', review.reviewer.name).replace('YY', review.item.name);

		if (config.range > 1) {
			settings.buttons = [{
				text  : settings.submitText,
				click : function(event) {
					var rating = parseInt($('input[name="rating"]', popup).val());
					if (rating == NaN) {
						alert(type.required);
					} else {
						submit(rating);
					}
				}
			}];
		} else { // approval
			settings.buttons = [
			   $.extend({}, type.approve, {
				  click : function(event) {
					 submit(1);
				  }
			   }),
			   $.extend({}, type.decline, {
				  click : function(event) {
					 submit(0);
				  }
			  })
			];
		}

		settings.buttons.push({
			text  : settings.cancelText,
		   "class": "cancelButton",
			click : function() {
	  			popup.dialog("close");
	  			popup.remove();

	  			callback(null);
			 }
		});

		settings.close = function() {
  			popup.remove();
  			callback(null);
		};

		popup.dialog(settings);
	};


	$.fn.showReviewDialog.defaults = {
		dialogClass		: 'popup',
		width			: 640,
		draggable		: true,
		modal			: true,
		closeOnEscape	: false,
		submitUrl		: contextPath + '/trackers/ajax/trackerItemReview.spr?task_id=',
		submitText    	: 'OK',
		cancelText   	: 'Cancel',
		help : {
			URL			: 'https://codebeamer.com/cb/wiki/825406',
			title		: 'Work Item Review in the CodeBeamer Knowledge Base'
		},
		rating : {
			title		: 'Rating for YY',
			header		: 'XX, please enter your rating for YY:',
			label		: 'Rating',
		    tooltip	 	: 'Your rating for the specified (work) item',
		    ofLabel    	: 'of',
		    required	: 'Please specify your rating'
		},
		approval : {
			title		: 'Approval of YY',
			header		: 'XX, please Approve or Decline YY',
			approve : {
				text 	: 'Approve'
			},
			decline : {
				text 	: 'Decline'
			}
		},
		signature : {
			username : {
				label 	: 'Username',
				tooltip : 'Please enter your login username, to verify your identity',
				required: 'In order to verify your identity, please enter your account/login username'
			},
			password : {
				label 	: 'Password',
				tooltip : 'Please enter your password, to verify your identity',
				required: 'In order to verify your identity, please enter your account/login password'
			}
		}
	};


})( jQuery );
