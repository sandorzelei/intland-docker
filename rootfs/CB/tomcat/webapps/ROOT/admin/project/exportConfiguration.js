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

	// ExportConfiguration Editor Plugin
	$.fn.exportConfiguration = function(project, trackers, options) {
		var settings = $.extend( {}, $.fn.exportConfiguration.defaults, options );
		var container = $(this);

		function getSetting(name) {
			return settings[name];
		}

		function getAssociationSelector(assocTypes, selected) {
			var selector = $('<select>', { "class" : 'assocType', multiple : true, title : settings.associationsTooltip });

			if ($.isArray(assocTypes) && assocTypes.length > 0) {
				if (!$.isArray(selected)) {
					selected = [];
				}
			    for (var i = 0; i < assocTypes.length; ++i) {
			    	selector.append($('<option>', { "class" : 'assocType', value : assocTypes[i].id, selected : isSelected(assocTypes[i], selected) }).text(assocTypes[i].name).data('assocType', assocTypes[i]));
			    }
			}

			return selector;
		}

		function showAssocTypes(tracker, selected) {
			var assocTypes = settings.assocTypes;
			if ($.isArray(assocTypes) && assocTypes.length > 0) {
				var trackerAssocs = $('<li>', { "class": 'category assocTypes' });
				tracker.append(trackerAssocs);

				trackerAssocs.append($('<label>', { title : settings.associationsTooltip }).text(settings.associationsLabel + ' :'));

				var assocList = $('<ul>', { "class" : 'assocTypes' });
				trackerAssocs.append(assocList);

				var moreAssocs = $('<li>', { "class": 'moreAssocs' });
				assocList.append(moreAssocs);

				var selector = getAssociationSelector(assocTypes, selected);
				moreAssocs.append(selector);

				selector.multiselect({
		    		checkAllText	 : settings.associationsAll,
		    	 	uncheckAllText	 : settings.associationsNone,
		    	 	noneSelectedText : settings.associationsNone,
		    	 	autoOpen		 : false,
		    	 	multiple         : true,
		    	 	selectedList	 : assocTypes.length,
		    	 	height			 : 'auto',
		    	 	minWidth		 : 600, //'auto',
		    	 	appendTo		 : moreAssocs,
					position		: { my: "left top", at: "left top", of: moreAssocs, collision: 'none' }
		    	});
			}
		}

		function loadDestinations() {
			if (!$.isArray($.fn.exportConfiguration.defaults.destinations)) {
				$.get(settings.extension.destinationsUrl).done(function(destinations) {
					$.fn.exportConfiguration.defaults.destinations = destinations;
				}).fail(function(jqXHR, textStatus, errorThrown) {
					alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		        });
			}
		}

		function getDestinationSelector(destination) {
			var selector = $('<select>', { "class" : 'destination', title : settings.destinationTooltip });

			var destinations = $.fn.exportConfiguration.defaults.destinations;
			if ($.isArray(destinations) && destinations.length > 0) {
				for (var i = 0; i < destinations.length; ++i) {
					selector.append($('<option>', {
					   "class"   : 'destination',
						value    : destinations[i],
						selected : destinations[i] === destination
					}).text(destinations[i]));
				}
			}

			selector.append($('<option>', {
			   "class"   : 'destination',
				value    : '',
				selected : !(typeof(destination) === 'string' && destination.length > 0)
			}).text(settings.destinationOther));

			return selector;
		}

		function getDestinationLabel(destination) {
			var result = $('<label>').text(typeof(destination) === 'string' && destination.length > 0 ? destination : settings.destinationOther).append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.destinationTooltip
			}));

			return result;
		}

		function setDestination(destination) {
			var container = $(this).closest('div').parent();
			var project   = container.data('project');

			if (!(project.destination === destination)) {
				project.destination = typeof(destination) === 'string' && destination.length > 0 ? destination : null;

				$.get(settings.extension.exportConfigUrl, { proj_id : project.id, destination : project.destination }).done(function(exportConfig) {
					setExportConfiguration(container, exportConfig);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		        });
			}

			return getDestinationLabel(destination)[0].outerHTML;
		}

		function getReferenceSelector(references) {
			var selector = $('<select>', { "class" : 'reference', title : settings.referencesTooltip });
			selector.append($('<option>', { "class" : 'reference', value : '', style : 'color: gray; font-style: italic;' }).text(settings.referencesNone));

			if ($.isArray(references) && references.length > 0) {
			    for (var i = 0; i < references.length; ++i) {
			    	var refType = references[i].type;
			    	references[i].offset = i;

			    	selector.append($('<option>', { "class" : 'reference', value : refType.value, title : refType.title }).text(refType.label).data('reference', references[i]));
			    }
			}

			return selector;
		}

		function removeReference() {
			var item       = $(this);
			var reference  = item.data('reference');
			var references = item.closest('ul.references');
			var moreRefs   = $('li.moreRefs:last', references);
			var selector   = $('select.reference', moreRefs);
			var option     = $('<option>', { "class" : 'reference', value : reference.type.value, title : reference.type.title }).text(reference.type.label).data("reference", reference);

			$('option', selector).each(function(index, elem) {
				var current = $(this);
				if (index > 0 && option != null && reference.offset < current.data('reference').offset) {
					option.insertBefore(current);
					option = null;
					return false;
				}
			});

			if (option != null) {
				selector.append(option);
			}

			item.remove();

			if ($('li.reference', references).length == 0) {
				$('option:first', selector).text(getSetting('referencesNone'));
			}

			moreFlds.show();
		}

		function selectReference() {
			var value = this.value;
			if (value && value != '') {
				var selector   = $(this);
				var reference  = $('option:selected', selector).data('reference');
				var moreRefs   = selector.closest('li.moreRefs');
				var references = moreRefs.closest('ul.references');
				var item       = $('<li>', { "class" : 'reference' }).data('reference', reference);

				item.append($('<label>', { title : reference.type.title }).text(reference.type.label)).append($('<span>', {
				   "class" : "ui-icon ui-icon-circle-close",
					title  :  settings.fieldRemoveLabel
				}).click(function() {
					removeReference.call($(this).parent());
				}));

   				$('li.reference', references).each(function() {
	   				var current = $(this);

   					if (item != null && reference.offset < current.data('reference').offset) {
   						item.insertBefore(current);
   						item = null;
   						return false;
   					}
   				});

   				if (item != null) {
   					item.insertBefore(moreRefs);
   				}

				// Remove the reference from the selector
				var options = this.options;
				for (var j = 0; j < options.length; ++j) {
					if (options[j].value == value) {
						this.remove(j);
						break;
					}
				}

				options[0].text = settings.referencesMore;

				// Hide selector if all references were chosen
				if (options.length > 1) {
					options[0].selected = true;
				} else {
					moreRefs.hide();
				}

				var restored = selector.data('restored');
				if (!restored) {
					// Automatically include the referencing trackers and the appropriate reference fields
					selectReferencingTrackers(selector.closest('ul.trackers'), reference);
				}
				selector.removeData('restored');
			}
		}

		function showTrackerReferences(container, tracker, references, selected) {
			if ($.isArray(references) && references.length > 0) {
				var trackerReferences = $('<li>', { "class": 'category references' });
				container.append(trackerReferences);

				trackerReferences.append($('<label>', { title : settings.referencesTooltip }).text(settings.referencesLabel + ' :'));

				var referenceList = $('<ul>', { "class" : 'references' });
				trackerReferences.append(referenceList);

				var moreReferences = $('<li>', { "class": 'moreRefs' });
				referenceList.append(moreReferences);

				var referenceSelector = getReferenceSelector(references);
				referenceSelector.change(selectReference);
				moreReferences.append(referenceSelector);

				if ($.isArray(selected) && selected.length > 0) {
				    for (var i = 0; i < selected.length; ++i) {
				    	referenceSelector.val(selected[i].value).data('restored', true).change();
				    }
				    referenceSelector.removeData('restored');
				}
			}
		}

		function isSelected(option, selected) {
			if (option) {
			    for (var i = 0; i < selected.length; ++i) {
					if (option.id === selected[i].id) {
						return true;
					}
				}
			}
			return false;
		}

		function getFieldSelector(fields, type, selected) {
			var selector = $('<select>', { "class" : type, multiple : (type == 'column'), title : settings.fieldsTooltip });
			if (type == 'field') {
				selector.append($('<option>', { "class" : 'field', value : '-1', style : 'color: gray; font-style: italic;' }).text(settings.fieldsNone));
			}

			if ($.isArray(fields) && fields.length > 0) {
			    for (var i = 0; i < fields.length; ++i) {
			    	fields[i].offset = i;

			    	selector.append($('<option>', { "class" : type, value : fields[i].id, title : fields[i].description, selected : (type == 'column' && (!$.isArray(selected) || isSelected(fields[i], selected))) }).text(fields[i].label || fields[i].name).data('field', fields[i]));
			    }
			}

			return selector;
		}

		function removeField() {
			var item     = $(this);
			var field    = item.data('field');
			var fields   = item.closest('ul.fields');
			var moreFlds = $('li.moreFields:last', fields);
			var selector = $('select.field', moreFlds);
			var option   = $('<option>', { "class" : 'field', value : field.id, title : field.description }).text(field.label || field.name).data("field", field);

			$('option', selector).each(function(index, elem) {
				var current = $(this);
				if (index > 0 && option != null && field.offset < current.data('field').offset) {
					option.insertBefore(current);
					option = null;
					return false;
				}
			});

			if (option != null) {
				selector.append(option);
			}

			item.remove();

			if ($('li.field', fields).length == 0) {
				$('option:first', selector).text(getSetting('fieldsNone'));
			}

			moreFlds.show();
		}

		function selectField() {
			var value = this.value;
			if (value != '-1') {
				var selector = $(this);
				var field    = $('option:selected', selector).data('field');
				var moreFlds = selector.closest('li.moreFields');
				var fields   = moreFlds.closest('ul.fields');
				var item     = $('<li>', { "class" : 'field' }).data('field', field);
				var fieldLabel = $('<label>', { title : field.description }).text(field.label || field.name);

				item.append(fieldLabel).append($('<span>', {
					"class" : "ui-icon ui-icon-circle-close",
					title   :  settings.fieldRemoveLabel
				}).click(function() {
					removeField.call($(this).parent());
				}));

				// If the field is a table: append a multiple column selector
				if (field.type == 12 && $.isArray(field.columns) && field.columns.length > 0) {
					var columnSelector = getFieldSelector(field.columns, 'column', selector.data('columns'));

					item.append(': ').append(columnSelector);

					columnSelector.multiselect({
			    		checkAllText	 : settings.associationsAll,
			    	 	uncheckAllText	 : settings.associationsNone,
			    	 	noneSelectedText : settings.associationsNone,
			    	 	autoOpen		 : false,
			    	 	multiple         : true,
			    	 	selectedList	 : field.columns.length,
			    	 	height			 : 'auto',
			    	 	minWidth		 : 480, //'auto'
			    	 	appendTo		 : item,
						position		: { my: "left top", at: "right+6 top", of: fieldLabel, collision: 'none' }
			    	});
				}

				selector.removeData('columns');

   				$('li.field', fields).each(function() {
	   				var current = $(this);

   					if (item != null && field.offset < current.data('field').offset) {
   						item.insertBefore(current);
   						item = null;
   						return false;
   					}
   				});

   				if (item != null) {
   					item.insertBefore(moreFlds);
   				}

				// Remove the field from the selector
				var options = this.options;
				for (var j = 0; j < options.length; ++j) {
					if (options[j].value == value) {
						this.remove(j);
						break;
					}
				}

				options[0].text = settings.fieldsMore;

				// Hide selector if all fields were chosen
				if (options.length > 1) {
					options[0].selected = true;
				} else {
					moreFlds.hide();
				}
			}
		}

		function selectReferenceField(tracker, refField) {
			var fieldSelector = $('ul.trackerConfig > li.fields > ul.fields > li.moreFields > select.field', tracker);

			$('option.field', fieldSelector).each(function(index, elem) {
				var field = $(this).data('field');
				if (index > 0 && field.name == refField) {
					fieldSelector.val(field.id).change();
   					return false;
   				}
	   		});
		}

		function showTrackerFields(container, tracker, fields, selected) {
			if ($.isArray(fields) && fields.length > 0) {
				var trackerFields = $('<li>', { "class": 'category fields' });
				container.append(trackerFields);

				trackerFields.append($('<label>', { title : settings.fieldsTooltip }).text(settings.fieldsLabel + ' :'));

				trackerFields.append($('<a>', {
					"class" : 'edit-link',
					"title" : settings.fieldsSelectAll,
					"style" : 'margin-left: 10px;'
				}).text(settings.fieldsSelectAll).click(function() {
					var selector = $(this).closest('li.fields').find('ul.fields select.field');
		            for (var fields = selector[0].options; fields.length > 1; fields = selector[0].options) {
 						selector.val(fields[1].value).change();
		            }
				}));

				trackerFields.append($('<a>', {
					"class" : 'edit-link',
					"title" : settings.fieldsRemoveAll,
					"style" : 'margin-left: 10px;'
				}).text(settings.fieldsRemoveAll).click(function() {
					$(this).closest('li.fields').find('ul.fields > li.field').each(function() {
		   	  		    removeField.call($(this));
		   			});
				}));

				var fieldList = $('<ul>', { "class" : 'fields' });
				trackerFields.append(fieldList);

				var moreFields = $('<li>', { "class": 'moreFields' });
				fieldList.append(moreFields);

				var fieldSelector = getFieldSelector(fields, 'field');
				fieldSelector.change(selectField);
				moreFields.append(fieldSelector);

				if ($.isArray(selected)) {
				    for (var i = 0; i < selected.length; ++i) {
				    	fieldSelector.val(selected[i].id).data('columns', selected[i].columns).change();
				    }
					fieldSelector.removeData('columns');

				} else if (settings.extension && $.isFunction(settings.extension.defaultField)) {
				    for (var i = 0; i < fields.length; ++i) {
				    	if (settings.extension.defaultField(tracker, fields[i])) {
				    		fieldSelector.val(fields[i].id).change();
				    	}
				    }
				}
			}
		}

		function showTrackerFilter(selector, viewId, callback) {
			var tracker = selector.data('tracker');
			var view = {
  				tracker_id      : tracker.id,
  				viewTypeId      : 1,
  				viewLayoutId    : 0,
  				forcePublicView : true
  	  		};

			if (viewId != null) {
				view.view_id = viewId;
			}

			var popup = selector.next('div.filterPopup');
  			if (popup.length == 0) {
  				popup = $('<div>', { "class" : 'filterPopup', style : 'display: None;'} );
  				popup.insertAfter(selector);
  			}

  			popup.showTrackerViewConfigurationDialog(view, settings.filterConfiguration, {
				title			: settings.itemsLabel + ' ' + settings.inFolderLabel + ' ' + tracker.name,
				position		: { my: "left top", at: "left top", of: selector, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				editable		: true,
  				viewUrl			: settings.trackerViewUrl,
  				submitText		: settings.submitText,
  				cancelText		: settings.cancelText

  			}, callback);
		}

		function getItemsSelector(tracker, views, value) {
			var selector = $('<select>', { name : 'items', "class" : 'items', title : settings.itemFilterTitle }).data('tracker', tracker);

			for (var i = 0; i < settings.trackerItemFilters.length; ++i) {
			    selector.append($('<option>', { "class" : 'items', value : settings.trackerItemFilters[i].id, selected : settings.trackerItemFilters[i].id == value }).text(settings.trackerItemFilters[i].name).data('items', settings.trackerItemFilters[i]));
			}

			if ($.isArray(views) && views.length > 0) {
	    		for (var i = 0; i < views.length; ++i) {
					selector.append($('<option>', { "class" : 'items', value : views[i].id, title : views[i].description, selected : views[i].id == value }).text(views[i].name).data('items', views[i]));
	    		}
			}

		    selector.append($('<option>', { "class" : 'items', value : '-NEW-' }).text('-- ' + i18n.message("tracker.view.create.label") + ' --'));

			return selector;
		}

		function showTrackerConfig(container, tracker, value) {
			$.get(settings.extension.trackerConfigUrl || settings.trackerConfigUrl, { tracker_id : tracker.id }).done(function(config) {
				var itemSelector = getItemsSelector(tracker, config.views, value && value.items ? value.items.id : null);

				var editViewLink = $("<a>", {"class": "edit-link"}).append($('<img>', {
					src   : contextPath + '/images/Editor.gif',
					alt   : settings.editViewLabel,
					title : settings.editViewLabel
				})).click(function() {
					var filter = parseInt(itemSelector.val());
                    if (!isNaN(filter) && filter > 0) {
                        showTrackerFilter(itemSelector, filter, function(view) {
                            if (view && view.name != null) {
                                $('option:selected', itemSelector).text(view.name).attr('title', view.description);
                            }
                        });
                    }
				});

				container.append(': ').append(itemSelector).append(editViewLink);

				itemSelector.change(function() {
					var selected = itemSelector.val();
					if (selected === '-NEW-') {
						itemSelector.prop("selectedIndex", 0);
						editViewLink.hide();

						showTrackerFilter(itemSelector, null, function(view) {
	                        if (view && view.id > 0) {
	                        	var option = $('<option>', { "class" : 'items',  value : view.id, title : view.description, selected : true }).text(view.name);

	                        	var newView = itemSelector.find('option.items[value="-NEW-"]');
	                        	if (newView.length > 0) {
	                        		option.insertBefore(newView);
	                        	} else {
		                        	itemSelector.append(option);
	                        	}

	                        	itemSelector.change();
	                        }
	                    });
					} else {
						var filter = parseInt(selected);
						var editable = !isNaN(filter) && filter > 0;

						editViewLink.toggle(editable);
					}
				}).change();

				var trackerConfig = $('<ul>', { "class" : 'trackerConfig'});
				container.append(trackerConfig);

				showTrackerFields(trackerConfig, tracker, config.fields, value ? value.fields : null);
				showTrackerReferences(trackerConfig, tracker, config.references, value ? value.references : null);
				showAssocTypes(trackerConfig, value ? value.associations : null);


	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	        });
		}

		function getTrackerSelector(trackers) {
			var selector = $('<select>', { "class" : 'tracker', title : settings.trackersTitle });
		    selector.append($('<option>', { "class" : 'tracker', value : 0, style: 'color: gray; font-style: italic;'}).text(settings.trackersNone));

			if ($.isArray(trackers) && trackers.length > 0) {
				trackers.sort(function(a, b) {
					return a.name.localeCompare(b.name);
				});

				for (var i = 0; i < trackers.length; ++i) {
					var tracker = trackers[i];
					selector.append($('<option>', { "class" : 'tracker', value : tracker.id, title : tracker.description }).text(tracker.name).data('tracker', tracker));
				}
			}

			return selector;
		}

		function removeTracker() {
			var item     = $(this);
			var tracker  = item.data('tracker');
			var trackers = item.closest('ul.trackers');
			var lastItem = $('li.moreTrackers:last', trackers);
			var selector = $('select.tracker', lastItem);
			var option   = $('<option>', { "class" : 'tracker', value : tracker.id, title : tracker.description }).text(tracker.name).data("tracker", tracker);

			$('option', selector).each(function(index, elem) {
				var current = $(this);
				if (index > 0 && option != null && option.text().localeCompare(current.text()) <= 0) {
					option.insertBefore(current);
					option = null;
					return false;
				}
			});

			if (option != null) {
				selector.append(option);
			}

			item.remove();

			if ($('li.tracker', trackers).length == 0) {
				$('option:first', selector).text(getSetting('trackersNone'));
			}

			lastItem.show();
		}

		function selectTracker() {
			var value = this.value;
			if (value != '0') {
				var selector = $(this);
				var config   = selector.data('config');
				var lastItem = selector.closest('li.moreTrackers');
				var trackers = lastItem.closest('ul.trackers');
				var tracker  = $('option:selected', selector).data('tracker');
				var item     = $('<li>', { "class" : 'tracker' }).data('tracker', tracker);

				var trackerLabel = $('<label>', { title : tracker.description }).text(tracker.name).append($('<span>', {
					"class" : "ui-icon ui-icon-circle-close",
					title   :  settings.trackerRemoveLabel
				}).click(function() {
					removeTracker.call($(this).closest('li.tracker'));
				}));

				item.append(trackerLabel);

				selector.removeData('config');
				showTrackerConfig(item, tracker, config);

  				$('li.tracker', trackers).each(function() {
	   				var current = $(this);

   					if (item != null && tracker.name.localeCompare(current.data('tracker').name) <= 0) {
   						item.insertBefore(current);
   						item = null;
   						return false;
   					}
   				});

   				if (item != null) {
   					item.insertBefore(lastItem);
   				}

				// Remove the tracker from the selector
				var options = this.options;
				for (var j = 0; j < options.length; ++j) {
					if (options[j].value == value) {
						this.remove(j);
						break;
					}
				}

				options[0].text = settings.trackersMore;

				// Hide selector if all trackers were chosen
				if (options.length > 1) {
					options[0].selected = true;
				} else {
					lastItem.hide();
				}
			}
		}

		function selectReferencingTrackers(trackerList, reference) {
			var refField = reference.type.value.substr(0, reference.type.value.indexOf('|'));
			var trackers = reference.trackers;

			if ($.isArray(trackers) && trackers.length > 0) {
				var trackerSelector = $('li.moreTrackers > select.tracker', trackerList);

				for (var i = 0; i < trackers.length; ++i) {
					trackerSelector.val(trackers[i].id).change();
				}

				// Because tracker configuration may be loaded asynchronously, we must wait before trying to also select the reference field
				setTimeout(function() {
					$('li.tracker', trackerList).each(function() {
						var tracker = $(this);

						if (isSelected(tracker.data('tracker'), trackers)) {
							selectReferenceField(tracker, refField);
						}
					});
				}, 500);
			}
		}

		function setExportConfiguration(container, config) {
			// First collapse current configuration (if any)
			$('ul.trackers > li.tracker', container).each(function() {
				removeTracker.call($(this));
			});

			var trackers = config.trackers;
			if ($.isArray(trackers) && trackers.length > 0) {
				var trackerSelector = $('ul.trackers > li.moreTrackers > select.tracker', container);

				for (var i = 0; i < trackers.length; ++i) {
					var trackerConf = trackers[i];

					if (trackerConf.tracker) {
						for (var property in trackerConf.tracker) {
							trackerConf[property] = trackerConf.tracker[property];
						}
						delete trackerConf.tracker;
					}

					$('option', trackerSelector).each(function(index, elem) {
						var tracker = $(this).data('tracker');
						if (index > 0 && tracker.name == trackerConf.name) {
							trackerSelector.val(tracker.id).data('config', trackerConf).change();
		   					return false;
		   				}
			   		});
				}
			}
		}

		function saveAsFile(link, container, fileName) {
			var data = container.getExportConfiguration();
			var blob = new Blob([JSON.stringify(data, undefined, 4)], { type : 'application/json' });

			if (window.navigator.msSaveBlob) {
				window.navigator.msSaveBlob(blob, fileName);
			} else if (window.webkitURL != null) {
				link.href = window.webkitURL.createObjectURL(blob);
			} else {
				link.href = window.URL.createObjectURL(blob);
			}
		}

		function init(container, project, trackers) {
			container.empty();
			container.data('project', project);

			container.helpLink(settings.help);

			var destDiv = $('<div>');
			container.append(destDiv);

			var destination = $('<span>', { "class" : 'destination' });

			destDiv.append($('<b>').text(settings.destinationLabel + ": "))
			destDiv.append(destination);

			var trackerConfig = $('<ul>', { "class" : 'trackers' });
			container.append(trackerConfig);

			var moreTrackers = $('<li>', { "class": 'moreTrackers' });
			trackerConfig.append(moreTrackers);

			var trackerSelector = getTrackerSelector(trackers);
			trackerSelector.change(selectTracker);
			moreTrackers.append(trackerSelector);

			if (project.destination) {
				destination.text(project.destination === 'Origin' ? settings.destinationOrigin : project.destination);

				if (!project.destination.endsWith('.json')) {
					project.destination += '.json';
				}
			} else {
				destination.append(getDestinationLabel(project.destination));
				destination.editable(setDestination, {
			        type   : 'destination',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}

			$.get(settings.extension.exportConfigUrl, { proj_id : project.id, destination : project.destination }).done(function(exportConfig) {
				setExportConfiguration(container, exportConfig);

			}).fail(function(jqXHR, textStatus, errorThrown) {
				alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	        });

			var loadSave = $('<div>', {"class": 'explanation', style: 'margin-left: 2em;'});
			container.append(loadSave);

			if ($("body").hasClass("IE8") || $("body").hasClass("IE9") || $("body").hasClass("IE10")) {
				loadSave.append(settings.notSupportedHint);
			} else {
				var fileSelector;
				var addFileSelector = function() {
					fileSelector = $('<input>', {
						type: 'file',
						style: 'position: fixed; top: -200px'
					}).change(function(event) {
						var file = event.target.files[0];
						var reader = new FileReader();

						reader.onload = function(event) {
							var text = event.target.result;
							setExportConfiguration(container, $.parseJSON(text));
						};

						reader.readAsText(file, "UTF-8");

						// now re-add the file selector so loading the same file again will trigger a change event again
						fileSelector.remove();
						addFileSelector();
					});
				};

				addFileSelector();
				loadSave.append(fileSelector);

				var fileName = project.name + '-' + (settings.extension ? settings.extension.type || '' : '') + 'Export.json';
				var save = $('<a>', {
					href: '#',
					download: fileName
				}).text(settings.saveText).click(function(event) {
					saveAsFile(event.target, container, fileName);
				});

				var load = $('<a>', {href: '#'}).text(settings.loadText).click(function() {
					fileSelector.click();
					return false;
				});

				var parts = settings.loadSaveHint.split(/<\w*>/);
				loadSave.append(parts[0]).append(load).append(parts[1]).append(save).append(parts[2]);
			}
		}

		function setup() {
			loadDestinations();

			/* Define an inplace editor for the ReqIF export destination */
		    $.editable.addInputType('destination', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var project  = $(self).closest('div').parent().data('project');
		           	var selector = getDestinationSelector(project.destination).change(function() {
		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });
		}

		if ($.fn.exportConfiguration._setup) {
			$.fn.exportConfiguration._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), project, trackers);
		});
	};

	$.fn.exportConfiguration._setup = true;

	$.fn.exportConfiguration.defaults = {
		help		: {
			title	: '"Requirements Interchange Format (ReqIF)" in the codeBeamer Knowledge Base',
			URL		: 'https://codebeamer.com/cb/wiki/639415'
		},
		assocTypes			: [{id : 1, name : 'depends'}, {id : 2, name : 'parent'}, {id : 3, name : 'child'}, {id : 4, name : 'related'}, {id : 5, name : 'derived'}, {id : 6, name : 'violates'}, {id : 7, name : 'excludes'}, {id : 8, name : 'invalidates'}, {id : 9, name : 'copy of'} ],
		trackerItemFilters	: [{ id: -1, name: 'Open'}],
		trackerViewUrl		: contextPath + '/trackers/ajax/view.spr',
		trackerConfigUrl	: contextPath + '/trackers/ajax/ReqIFExportTrackerConfig.spr',
	    submitText    		: 'OK',
	    cancelText   		: 'Cancel',
		saveText			: 'Save...',
		loadText			: 'Load...',
		loadSaveHint		: 'You can also <Load> a previously saved configuration, or <Save> this configuration for later re-use',
		destinationLabel	: 'Destination',
		destinationTooltip	: 'Please select the type of the destination/target system for the export',
		destinationOrigin	: 'Origin',
		destinationOther	: 'Other',
	    trackersTitle		: 'Please select trackers, whose items should be exported',
	    trackersNone		: 'Please select',
	    trackersMore		: 'More Trackers ...',
	    trackersRequired	: 'You must at least select one tracker to be exported',
	    trackerRemoveLabel  : 'Remove',
	    trackerRemoveTooltip: 'Remove this tracker from export',
	    itemsLabel			: 'Items/Issues',
	    inFolderLabel		: 'in',
		itemFilterLabel		: 'Filter',
		itemFilterTitle		: 'A filter to selected a subset of items in this tracker/category',
		createViewLabel		: 'New',
		editViewLabel		: 'Edit',
  		fieldsLabel			: 'Fields',
  		fieldsTooltip		: 'These fields/attributes can be exported',
	    fieldsNone			: 'Please select',
	    fieldsMore			: 'More Fields ...',
  		fieldsSelectAll		: 'Select all',
  		fieldsRemoveAll		: 'Deselect all',
  		fieldRemoveLabel	: 'Remove',
  		referencesLabel		: 'References',
  		referencesTooltip	: 'Also export these referencing items/issues',
  		referencesNone		: 'None',
  		referencesMore		: 'More...',
  		associationsLabel	: 'Associations',
  		associationsTooltip	: 'Also export item/issue associations of this type',
  		associationsNone	: 'None',
  		associationsAll		: 'All',
		filterConfiguration : {
			nameLabel	: 'Name',
			hide		: ['visibility', 'layout', 'fields', 'orderBy', 'charts']
  		}
	};


	// The complimentary plugin to get the export configuration back from an editor
	$.fn.getExportConfiguration = function() {
		function getColumns(field) {
			var columns = [];

			if (field.data('field').type == 12) {
				$('select.column > option.column:selected', field).each(function() {
					columns.push($(this).data('field'));
				});
			}

			return columns;
		}

		function getFields(tracker) {
			var fields = [];

			$('ul.fields > li.field', tracker).each(function() {
				var field = $(this);

				fields.push($.extend({}, field.data('field'), {
					columns : getColumns(field)
				}));
			});

			return fields;
		}

		function getReferences(tracker) {
			var references = [];

			$('ul.references > li.reference', tracker).each(function() {
				references.push($(this).data('reference').type);
			});

			return references;
		}

		function getAssociations(tracker) {
			var associations = [];

			$('select.assocType > option.assocType:selected', tracker).each(function() {
				associations.push($(this).data('assocType'));
			});

			return associations;
		}

		function getTrackers(project) {
			var trackers = [];

			$('ul.trackers > li.tracker', project).each(function() {
				var tracker = $(this);

				trackers.push($.extend({}, tracker.data('tracker'), {
					items        : $('select.items > option:selected', tracker).data('items'),
					fields       : getFields(tracker),
					references   : getReferences(tracker),
					associations : getAssociations(tracker)
				}));
			});

			return trackers;
		}

		return $.extend({}, this.data('project'), {
			trackers : getTrackers(this)
		});
	};


	// A third plugin to create an export configuration editor in a dialog
	$.fn.showExportConfigurationDialog = function(project, dialog, options, extension) {
		var popup    = this;
		var settings = $.extend( {}, $.fn.showExportConfigurationDialog.defaults, dialog );
		var callback = extension.executeExport;

		popup.empty().text(settings.waitText);

		$.get(extension.trackersUrl || settings.trackersUrl, { proj_id : project.id }).done(function(trackers) {
			popup.exportConfiguration(project, trackers, options);

			var position = popup.dialog("option", "position");
			popup.dialog("option", "position", position);

    	}).fail(function(jqXHR, textStatus, errorThrown) {
    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
        });

		if (typeof(callback) == 'function') {
			settings.buttons = [{
				text  : options.submitText,
				click : function() {
			 		var exportConfig = popup.getExportConfiguration();
			 		if ($.isArray(exportConfig.trackers) && exportConfig.trackers.length > 0) {
					 	var downloadUrl = callback(exportConfig);
					 	if (downloadUrl) {
				  			popup.dialog("close");

							if (exportConfig.destination) {
								downloadUrl += ('&destination=' + exportConfig.destination);
							}

					 		document.location.href = downloadUrl;
					 	}
			 		} else {
			 			alert(options.trackersRequired);
			 		}
				}
			}, {
				text   : options.cancelText,
			   "class" : "cancelButton",
				click : function() {
					popup.dialog("close");
				}
			}];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};


	$.fn.showExportConfigurationDialog.defaults = {
		trackersUrl	  	: contextPath + '/proj/ajax/ReqIFExportTrackers.spr',
		title			: 'Select project contents to be exported',
		waitText		: 'Please wait...',
		dialogClass		: 'popup',
		width			: 800,
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true
	};


	// A third plugin to create an export configuration editor in a dialog
	$.fn.initExportMenu = function(project, callback, extension) {
		var settings = $.extend({}, $.fn.initExportMenu.defaults, extension.menu);

		function positionMenu(opt) {
			opt.$menu.position({
				my  : "left top",
				at  : "right top",
			   "of" :  this
			});
		}

		function returnReqIF(key, opt) {
			callback($.extend({}, project, {
				destination : key
			}), extension);
		}

		function exportReqIF(key, opt) {
			callback(project, extension);
		}

		function buildBackToMenu($trigger, event) {
			var items = {};

			$.ajax(settings.sources.url, {
				type	 : 'GET',
				data     : { proj_id : project.id },
				dataType : 'json',
				async    : false
			}).done(function(result) {
				if ($.isArray(result) && result.length > 0) {
					for (var i = 0; i < result.length; ++i) {
						var source = result[i];
						var srcDef = settings.sources[source];

						if ($.isPlainObject(srcDef)) {
							items[source] = {
								name  		: '<label title="' + srcDef.title + '">' + srcDef.label + '</label>',
								isHtmlName	: true,
								callback	: returnReqIF
							};
						} else {
							items[source] = {
								name 	 : source + ' ...',
								callback : returnReqIF
							};
						}
					}
				}
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("GET " + settings.sources.url + " failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText + ", ex=" + err);
	    		}
	        });

			return $.isEmptyObject(items) ? false : {
				name  		: '<label title="' + settings.sources.backTo.title + '">' + settings.sources.backTo.label + '</label>',
				isHtmlName	: true,
				items 		: items
			};
		}

		function buildReqIFExportMenu($trigger, event) {
	        var items = {
	        	forward : {
    				name  		: '<label title="' + settings.forward.title + '">' + settings.forward.label + '</label>',
    				isHtmlName	: true,
    				callback 	: exportReqIF
    			},
    			backTo  : buildBackToMenu($trigger, event)
	        };

	        if (!items.backTo) {
	        	delete items.backTo;
	        }

			return {
				name  		: '<label title="' + settings.title + '">' + settings.label + '</label>',
				isHtmlName	: true,
				items 		: items
			};
		}

		if ($.fn.initExportMenu.init) {
			$.fn.initExportMenu.init = false;

		    $.contextMenu({
				selector : settings.selector,
				trigger  : settings.trigger,
				position : positionMenu,
				build    : buildReqIFExportMenu,
				autoHide : true
			});
		}

		return this;
	};

	$.fn.initExportMenu.init = true;

	$.fn.initExportMenu.defaults = {
		label   : 'As ReqIF archive',
		title   : 'Export selected contents of this project as a ReqIF archive',
		selector: 'li.ui-menu-item > a.exportAsReqIF',
		trigger : 'hover',

		sources : {
			url	   : contextPath + '/ajax/project/getReqIFImportConfigs.spr',
			backTo : {
				label : 'Back to',
				title : 'Export a ReqIF update response for a ReqIF data source, where data was previously imported from'
			},
			Origin : {
				label : 'Origin',
				title : 'Export a ReqIF update response back to the origin of this project'
			}
		},

		forward : {
			label : 'Forward ...',
			title : 'Forward selected contents of this project as a ReqIF archive'
		}

	};


})( jQuery );
