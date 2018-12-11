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

	// A plugin that allows to select a project/folder with baseline sets in a popup dialog
	$.fn.chooseDoorsFolderDialog = function(projectId, connection, config, callback) {
		var settings = $.extend(true, {}, $.fn.chooseDoorsFolderDialog.defaults, config);

		return this.chooseRemoteSource(projectId, connection, connection.folder, settings, {
			showHierarchy : function(popup, connection, nodes, selected, settings) {
				popup.doorsHierarchy(nodes, connection, settings);
			},

			getSelected : function(popup, connection, settings) {
				var selected = popup.jstree("get_selected", true);
				if ($.isArray(selected)) {
					for (var i = 0; i < selected.length; ++i) {
						var folder = selected[i].data;

						if ($.isPlainObject(folder) && folder.id) {
							return folder;
						}
					}
				}

				return null;
			},

			getValidation : function(connection, folder, settings) {
				return {
					url	   : settings.validation.url,
					params : { proj_id : projectId, folderId : folder.id },
					error  : settings.validation.error.replace('XXX', folder.name)
				};
			},

			finished : function(connection, selected, settings) {
				callback(selected);
			}
		});
	};


	$.fn.chooseDoorsFolderDialog.defaults = $.extend({}, $.fn.chooseRemoteSource.defaults, {
		title		: 'Please select the DOORS project/folder, whose baseline sets to import',

		hierarchy	: {
			url		: contextPath + '/ajax/doors/hierarchy.spr',
			loading : 'Loading folder tree, Please wait...',
			baselineSets: true
		},

		validation	: {
			url		: contextPath + '/ajax/doors/projectMapping.spr',
			error 	: 'The DOORS project/folder "XXX" is already associated with project "YYY"'
		},

		preview 	: null
	});


	// Plugin to edit DOORS import settings for the merged meta data (attributes, link types) of multiple modules
	// context: { server, username, password, project, folder, modules, template }
	// Must return the modules control in order to invoke it's change handler if the enclosing dialog is ready
	$.fn.editMergedDoorsSettings = function(context, template, options) {
		var settings = $.extend(true, {}, $.fn.editMergedDoorsSettings.defaults, options );

		if (!$.isPlainObject(template)) {
			template = {};
		}

		if (template.attachments === undefined) {
			template.attachments = true;
		}

		var modules = $('<input>', {
			type 	  : 'text',
			name 	  : 'modules',
			maxlength : 120,
			value 	  : settings.modules.replace('XXX', context.modules.length),
			disabled  : true
		}).attr("size", "80");

		this.mapRemoteObjects(template, settings, [{
			name    : 'module',
			content : function(table, cell, callback) {
				cell.append(modules);

				modules.change(function() {
					callback(table, $.extend({}, settings.metaData, {
						params : context
					}));
				});
			}
		}, {
			name 	: 'import',
			content	: ['reliable'],
			depends : true,
			second  : {
				content : ['enabled']
			}
		}, {
			name 	: 'references',
			content	: ['users'],
			depends : true
		}, "attributes", "linkTypes", "interval"]);

		return modules;
	};

	$.fn.editMergedDoorsSettings.defaults = $.extend(true, $.fn.editDoorsSettings.defaults, {
		server		: false,

		modules 	: 'These are cummulative settings for the import of XXX modules',

		metaData	: {
			url		: contextPath + '/ajax/doors/metaData.spr'
		},

		attributes	: {
			merged 	: 'modules'
		},

		linkTypes	: {
			merged 	: 'modules'
		}
	});


	// Plugin to edit DOORS import settings for the merged meta data (attributes, link types) of multiple modules in a popup dialog
	// context: { server, username, password, project, folder, modules, template }
	$.fn.showMergedDoorsSettingsDialog = function(context, config, dialog, callback) {
		return this.showRemoteObjectMappingDialog(context, config, $.extend({
			title		: 'DOORS Bridge Settings',
			settingsURL	: contextPath + '/ajax/doors/trackerTemplate.spr',
			trackers	: {
				url 	: contextPath + '/ajax/doors/createTrackers.spr',
				creating: 'Creating Trackers for XXX DOORS Modules in Project YYY ...'
			}
		}, dialog), {

			// Load mapping and pass it to specified callback(mapping)
			loadMapping : function(context, settings, callback) {
				var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

			    $.ajax(settings.settingsURL + "?proj_id=" + context.project.id, {
			    	type 	 	: 'POST',
					contentType : 'application/json',
			    	data 	 	: JSON.stringify(context.template),
			    	dataType 	: 'json',
			    	cache	 	: false
			    }).done(function(mapping) {
					ajaxBusyIndicator.close(busy);

					callback(mapping);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
		        });
			},

			// Submit mapping and on success invoke the specified callback(mapping)
			submitMapping : function(context, mapping, config, settings, callback) {
				var busy = ajaxBusyIndicator.showBusyPage(settings.trackers.creating.replace('XXX', context.modules.length).replace('YYY', context.project.name));

				// Create the target trackers for the modules and
			    $.ajax(settings.trackers.url + "?proj_id=" + context.project.id, {
			    	type 		: 'POST',
					contentType : 'application/json',
			    	cache		: false,
					dataType 	: 'json',
					data 		: JSON.stringify($.extend({}, mapping, context))
			    }).done(function(trackers) {
					ajaxBusyIndicator.close(busy);

					callback(trackers);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
		        });
			},

			// Create mapping editor and return the import source jQuery control, because we need to invoke it's change handler
			editMapping : function(popup, context, mapping, config) {
		    	return popup.editMergedDoorsSettings(context, mapping, config);
			},

			getMapping : function(popup, context, config) {
				var mapping = popup.getDoorsSettings(config);

				delete mapping.module;
				return mapping;
			},

			setMapping : function(popup, context, mapping, config) {
				popup.setDoorsSettings(mapping, config);
			},

			getMappingFile : function(popup, context, config) {
				var mapping = popup.getDoorsSettings(config);
				if (mapping) {
					delete mapping.module;

					return {
						name : 'DOORS-' + context.folder.name,
						data : mapping
					};
				}

				showFancyAlertDialog(config.module.selector.title);
				return null;
			},

			finished : function(context, mapping, config) {
	  			if ($.isFunction(callback)) {
	  				callback(mapping);
	  			}
			}
		});
	};


	// A plugin that shows a popup dialog to select the target tracker template/type for the modules to import
	// context: { server, username, password, project, folder }
	$.fn.showImportDoorsModulesDialog = function(context, modules, config, callback) {
		var settings = $.extend({}, $.fn.showImportDoorsModulesDialog.defaults, config);

		function getTypeName(typeId, types) {
			if (typeId && $.isArray(types)) {
				for (var i = 0; i < types.length; ++i) {
					if (types[i].id === typeId) {
						return types[i].name;
					}
				}
			}

			return 'Unknown';
		}

		function getTypeSelector(types) {
			var selector = $('<select>', { "class" : 'trackerType',	title : settings.type.select });

			if ($.isArray(types)) {
				for (var i = 0; i < types.length; ++i) {
					var type = types[i];

					selector.append($('<option>', {
						"class"   : 'trackerType',
						 value    : type.id,
						 selected : type.id == 5
					}).text(type.name).data('type', type));
				}
			}

			return selector;
		}

		function getSelectedType(container) {
			var selected = container.find('select.trackerType > option.trackerType:selected');
			if (selected.length > 0) {
				return selected.data('type');
			}

			return null;
		}

		function getInheritance(container) {
			var checkbox = container.find('input[type="checkbox"][name="inherit"]');
			return checkbox.is(':checked');
		}

		function getTemplateSelector(templates) {
			var selector = $('<select>', { "class" : 'template', title : settings.template.select });

			selector.append($('<option>', {
				"class" : 'template',
				 value  :  null,
				 style  : 'color: gray; font-style: italic;'
			}).text(settings.template.none));

			if ($.isArray(templates)) {
				for (var i = 0; i < templates.length; ++i) {
					var template = templates[i];

					selector.append($('<option>', {
						"class"   : 'template',
						 value    : template.id,
						 title	  : template.title || template.description
					}).text(template.project.name + '/' + template.name).data('template', template));
				}
			}

			return selector;
		}

		function getSelectedTemplate(container, types) {
			var selected = container.find('select.template > option.template:selected');
			if (selected.length > 0) {
				var template = selected.data('template');
				if (template && template.id) {
					return $.extend({}, template, {
						type    : {
							id	  : template.type,
							name  : getTypeName(template.type, types)
						},
						inherit : getInheritance(container)
					});
				}
			}

			return null;
		}

		function showTemplate(container, template) {
			if (!$.isPlainObject(template)) {
				template = {};
			}

			container.append($('<p>', { style : 'margin-top: 4px; margin-bottom: 8px;'}).text(settings.hint));

			var table = $('<table>', { "class" : 'template formTableWithSpacing', style : 'width: 100%;' });
			container.append(table);

			var row = $('<tr>', { style : 'vertical-align: middle;' });
			table.append(row);

			var label = $('<td>', { "class" : 'labelCell optional', title : settings.template.title }).text(settings.template.label + ':');
			row.append(label);

			var cell = $('<td>', { "class" : 'dataCell' });

			cell.append(getTemplateSelector(template.templates));

			cell.append($('<input>', {
				type	: 'checkbox',
				id		: 'inheritTemplateConfigCheckbox',
				name	: 'inherit',
				title	: settings.template.inherit.title,
				value	: 'true',
				checked : true,
				style 	: 'margin-left: 2em;'
			}));

			cell.append($('<label>', {
				"for" : 'inheritTemplateConfigCheckbox',
				title : settings.template.inherit.title
			}).text(settings.template.inherit.label));

			row.append(cell);

			row = $('<tr>', { style : 'vertical-align: middle;' });
			table.append(row);

			label = $('<td>', { "class" : 'labelCell optional', title : settings.type.title }).text(settings.type.label + ':');
			row.append(label);

			cell = $('<td>', { "class" : 'dataCell' }).append(getTypeSelector(template.types));
			row.append(cell);
		}

		function showDialog(template) {
			var popup = $('#importDoorsModulesPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'importDoorsModulesPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			function close() {
				popup.dialog("close");
				popup.remove();
			}

			function showSettings(tracker) {
				popup.showMergedDoorsSettingsDialog($.extend({}, context, {
					modules  : modules,
					template : tracker
				}), settings.settings.config, settings.settings.dialog, function(result) {
					close();

		  			if ($.isFunction(callback)) {
		  				callback(result);
		  			}
				});
			}

			showTemplate(popup, template);

			settings.title = settings.title.replace('XXX', modules.length).replace('YYY', context.project.name);

			settings.buttons = [{
				text : settings.submitText,
				click: function() {
					try {
						var tracker = getSelectedTemplate(popup, template.types);
						if (tracker && tracker.id && tracker.type) {
							if (tracker.type.id != 5) {
								showFancyConfirmDialogWithCallbacks(settings.template.confirm.replace('XXX', modules.length).replace('YYY', tracker.type.name), function() {
									showSettings(tracker);
								});
							} else {
								showSettings(tracker);
							}
						} else {
							var type = getSelectedType(popup);

							showFancyConfirmDialogWithCallbacks(settings.type.confirm.replace('XXX', modules.length).replace('YYY', type.name), function() {
								showSettings({
									type : type
								});
							});
						}
					} catch(error) {
						showFancyAlertDialog(error);
					}
				}
			}, {
				text  : settings.cancelText,
			   "class": "cancelButton",
				click : close
			}];

		    settings.close = function() {
	  			popup.remove();
		    };

			popup.dialog(settings);
		}

		var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

	    $.ajax(settings.templateURL, {
	    	type 	 : 'GET',
	    	data 	 : { proj_id : context.project.id },
	    	dataType : 'json',
	    	cache	 : false
	    }).done(function(template) {
			ajaxBusyIndicator.close(busy);

			showDialog(template);

		}).fail(function(jqXHR, textStatus, errorThrown) {
			ajaxBusyIndicator.close(busy);
			showAjaxError(jqXHR, textStatus, errorThrown);
        });

	    return this;
	};


	$.fn.showImportDoorsModulesDialog.defaults = {
		label		: 'Create Trackers ...',
		title		: 'Create Trackers for XXX DOORS Modules in Project YYY',
		loading		: 'Loading settings, please wait ...',
		templateURL	: contextPath + '/ajax/doors/trackerTemplate.spr',

		hint		: 'Please select the template (preferred) or the type of the new target trackers.',

		template	: {
			label	: 'Template',
			title	: 'The template of the new trackers',
			select	: 'Please select the template of the new trackers',
			none	: 'None',
			confirm	: 'Do you really want to create XXX new trackers, based on the selected template of type YYY ?',

			inherit : {
				label : 'Inherit template configuration',
				title : 'Should the template configuration be inherited or copied?'
			}
		},

		type		: {
			label	: 'Type',
			title	: 'The type of the new trackers',
			select	: 'Please select the type of the new trackers',
			confirm	: 'Do you really want to create XXX new trackers of type YYY without a template ?'
		},

		settings	: {
			config	: $.fn.editMergedDoorsSettings.defaults
		},

	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 680,
		height			: 200
	};



	// A plugin that lists the modules in a baseline set and allows to create new target trackers
	// context: { server, username, password, project, trackers, folder }
	$.fn.doorsModulesList = function(context, modules, config, callback) {
		var settings = $.extend({}, $.fn.doorsModulesList.defaults, config);

		function getModulePath(rootPath, module) {
			var modPath = module.path;

			if (modPath.startsWith(rootPath)) {
				modPath = modPath.substring(rootPath.length);
			}

			return modPath;
		}

		function showModule(rootPath, module, cell) {
			if (module.deleted) {
				cell.append($('<label>', { title : module.description, style : 'text-decoration: red line-through'}).text(getModulePath(rootPath, module)));

				if (!settings.editable) {
					cell.append($('<img>', {
						src   : settings.module.deleted.icon,
						alt   : settings.module.deleted.label,
						title : settings.module.deleted.title,
						style : 'position: relative; top: +4px; margin-left: 6px;'
					}));
				}
			} else {
				cell.append($('<a>', {
					href  : '#',
					title : module.description
				}).text(getModulePath(rootPath, module)).click(function(event) {
					event.preventDefault();
					cell.showDoorsPreviewDialog(context, module, settings.module.preview);
					return false;
				}));
			}
		}

		function getTrackerSelector(row, cell) {
			var selector = $('<select>', { "class"  : 'tracker' });

			selector.append($('<option>').text('--'));

			if ($.isArray(context.trackers) && context.trackers.length > 0) {
				for (var i = 0; i < context.trackers.length; ++i) {
					var tracker = context.trackers[i];

					selector.append($('<option>', {
						"class" : 'tracker',
						 value  :  tracker.id,
						 title  :  tracker.description
					}).text(tracker.name).data('tracker', tracker));
				}
			}

			selector.change(function() {
				var tracker = selector.find('option.tracker:selected').data('tracker');
				if (tracker && tracker.id) {
					var module = row.data('module');

					selector.prop("selectedIndex", 0);

					selector.showDoorsSettingsDialog({
						tracker_id : tracker.id
					}, settings.tracker.settings.config, settings.tracker.settings.dialog, function(mapping) {
						if (mapping && mapping.module && mapping.module.id === module.id) {
							module.tracker = tracker;         // module is an extended module plus baseline
							module.module.tracker = tracker;  // module.module is the module definition

							showTracker(row, context.project, tracker, cell.empty());

							// Remove tracker from available trackers
							context.trackers.splice($.inArray(tracker, context.trackers), 1);

							if (settings.editable) {
								row.find('td.selector').empty();

								// Remove tracker from all other tracker selectors
								row.closest('tbody').find('tr.module > td.tracker > select.tracker > option.tracker[value="' + tracker.id + '"]').remove();
							}

							if ($.isFunction(callback)) {
								callback(true);
							}
						}
					}, {
						server   : context.server,
						username : context.username,
						password : context.password,
						module   : row.data('module')
					});
				}
			});

			return selector;
		}

		function showTracker(row, project, tracker, cell) {
			if ($.isPlainObject(tracker)) {
				var trackerPath = (tracker.project && tracker.project.id != project.id ? tracker.project.name + '/' + tracker.name : tracker.name);

				cell.append($('<a>', {
					href  : settings.tracker.link.replace('XXX', tracker.id),
					title : tracker.title || tracker.description
				}).text(trackerPath).click(function(event) {
					event.preventDefault();
					window.open($(this).attr('href'), "_blank");
					return false;
				}));

				cell.append($('<a>', {
					href  : '#',
					title : settings.tracker.settings.hint,
					style : 'margin-left: 6px;'
				}).append($('<img>', {
					src   : settings.tracker.settings.image,
					alt   : settings.tracker.settings.label,
					style : 'position: relative; top: +4px;'
				})).click(function(event) {
					event.preventDefault();

					cell.showDoorsSettingsDialog({
						tracker_id : tracker.id
					}, settings.tracker.settings.config, settings.tracker.settings.dialog, function(mapping) {
						if (!mapping) {
							var module = row.data('module');

							delete module.tracker;         // module is an extended module plus baseline
							delete module.module.tracker;  // module.module is the module definition

							// Add tracker to available trackers
							if ($.isArray(context.trackers)) {
								var added = false;

								for (var i = 0; i < context.trackers.length; ++i) {
									if (tracker.name.localeCompare(context.trackers[i].name) <= 0) {
										context.trackers.splice(i, 0, tracker);
										added = true;
										break;
									}
								}

								if (!added) {
									context.trackers.push(tracker);
								}
							}

							if (settings.editable) {
								row.find('td.selector').empty().append($('<input>', { type : 'checkbox', name : 'selector', value : module.id }));

								// Add tracker to other selectors
								row.closest('tbody').find('tr.module > td.tracker > select.tracker').each(function() {
									var selector = $(this);
									var option   = $('<option>', {
										"class" : 'tracker',
										 value  :  tracker.id,
										 title  :  tracker.description
									}).text(tracker.name).data('tracker', tracker);

									selector.find('option.tracker').each(function() {
			 	  						var current = $(this);
			 	  						if (option != null && tracker.name.localeCompare(current.text()) <= 0) {
			 	  							option.insertBefore(current);
			 	  							option = null;
			 	  							return false;
			 	  						}
			 	  					});

			 	  					if (option != null) {
			 	  						selector.append(option);
			 	  					}
								});
							}

							showTracker(row, project, null, cell.empty());
							showLastImport(null, null, cell.next('td').empty());

							if ($.isFunction(callback)) {
								callback(true);
							}
						}
					});

					return false;
				}));
			} else if (settings.editable) {
				cell.append(getTrackerSelector(row, cell));
			} else {
				cell.text('--');
			}
		}

		function showLastImport(tracker, lastImport, cell) {
			if ($.isPlainObject(lastImport)) {
				cell.append(lastImport.date);

				if ($.isPlainObject(lastImport.user)) {
					cell.append(', ').append($('<a>', {
						href  : contextPath + '/userdata/' + lastImport.user.id,
						title : lastImport.user.realName
					}).text(lastImport.user.name).click(function(event) {
						event.preventDefault();
						window.open($(this).attr('href'), "_blank");
						return false;
					}));
				}

				if (lastImport.baseline) {
					var baseline = $.isPlainObject(lastImport.baseline) ? lastImport.baseline.id : lastImport.baseline;

					cell.append( ' (' + settings.baseline.label + ': ' + baseline + ')' );
				}

				cell.append($('<a>', {
					href  : '#',
					title : settings.lastImport.history.dialog.title,
					style : 'margin-left: 1em;'
				}).text(settings.lastImport.history.dialog.label).click(function(event) {
					event.preventDefault();

					cell.showDoorsImportHistoryDialog({ tracker_id : tracker.id },
													  settings.lastImport.history.config,
													  settings.lastImport.history.dialog,
													  settings.lastImport.history.settings);

					return false;
				}));
			} else {
				cell.text(settings.lastImport.never);
			}
		}

		function setNewModuleTrackers(trackers) {
			if ($.isPlainObject(trackers)) {
				$('table.modules tr.module', this).each(function() {
					var row    = $(this);
					var module = row.data('module');

					if ($.isPlainObject(module)) {
						var tracker = trackers[module.id];

						if ($.isPlainObject(tracker)) {
							var cell = row.find('td.tracker');

							cell.empty();

							if (tracker.id) {
								module.tracker = tracker;

								row.find('input[type="checkbox"][name="selector"]').remove();
								showTracker(row, context.project, tracker, cell);

							} else if (tracker.exception) {
								cell.append($('<a>', {
									href  : '#',
									title : 'Click here to show exception message',
									style : 'color: red;'
								}).text(tracker.exception).data('message', tracker.message).click(function(event) {
									event.preventDefault();
									showFancyAlertDialog($(this).data('message'));
									return false;
								}));
							} else {
								cell.text('--');
							}
						}
					}
				});
			}
		}

		function init(container, modules) {
			if ($.isArray(modules) && modules.length > 0) {
				var project  = context.project;
				var rootPath = context.folder.path + "/";

				var table = $('<table>', { "class" : 'displaytag modules', style : 'width: 96%;'}).data('setNewModuleTrackers', setNewModuleTrackers);
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var toggle = null;
				if (settings.editable) {
					toggle = $('<input>', { type : 'checkbox', name : 'toggle', value : 'true' });
					headline.append($('<th>', { "class" : 'checkbox-column-minwidth', title : settings.toggleAll }).append(toggle));
				}

				headline.append($('<th>', { "class" : 'textData', title : settings.module.title   	}).text(settings.module.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.baseline.title 	}).text(settings.baseline.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.tracker.title  	}).text(settings.tracker.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.lastImport.title }).text(settings.lastImport.label));

				var tbody = $('<tbody>');
				table.append(tbody);

				modules.sort(function(a, b) {
					return getModulePath(rootPath, a).localeCompare(getModulePath(rootPath, b));
				});

				var cell = null;

				for (var i = 0; i < modules.length; ++i) {
					var module  = modules[i];
					var tracker = module.tracker;

					var row = $('<tr>', { "class" : 'even module', style : 'vertical-align: middle;' }).data('module', module);
					tbody.append(row);

					if (settings.editable) {
						row.append(cell = $('<td>', { "class" : 'selector checkbox-column-minwidth', title : settings.toggleThis, style : 'text-align: center;' }));

						if (module.deleted) {
							cell.append($('<img>', { src : settings.module.deleted.icon, alt : settings.module.deleted.label, title : settings.module.deleted.title }));
						} else if (!$.isPlainObject(tracker)) {
							cell.append($('<input>', { type : 'checkbox', name : 'selector', value : module.id }));
						}
					}

					row.append(cell = $('<td>', { "class" : 'textData', title : module.description }));
					showModule(rootPath, module, cell);

					row.append(cell = $('<td>', { "class" : 'textData' }).text(module.baseline || 'HEAD'));

					row.append(cell = $('<td>', { "class" : 'textData tracker' }));
					showTracker(row, project, tracker, cell);

					row.append(cell = $('<td>', { "class" : 'textData' }));
					showLastImport(tracker, module.lastImport, cell);
				}

				if (settings.editable) {
					toggle.change(function() {
						var checked = toggle.is(':checked');

						$('input[type="checkbox"][name="selector"]', tbody).attr('checked', checked);
					});
				}
			} else {
				container.text(settings.none)
			}
		}

		return this.each(function() {
			init($(this), modules);
		});
	}


	$.fn.doorsModulesList.defaults = {
		label 		: 'Modules',
		none 		: 'There are no modules to display',
		editable	: true,
		toggleAll	: '(De-)Select all modules',
		toggleThis 	: '(De-)Select this module',

		module 		: {
			label	: 'Module',
			title	: 'The DOORS Module',
			preview : $.fn.showDoorsPreviewDialog.defaults,
			deleted : {
				icon  : contextPath + '/images/brokenlink.gif',
				label : 'Deleted',
				title : 'This module was deleted'
			}
		},

		baseline	: {
			label	: 'Baseline',
			title	: 'The Module baseline'
		},

		tracker		: {
			label	: 'Tracker',
			title	: 'The target tracker associated with this module',
			link    : contextPath + '/tracker/XXX',

			settings   : {
				image  : contextPath + '/images/cog.png',
				label  : 'Settings...',
				hint   : 'Click here, to show/edit the DOORS import settings for this tracker',
				config : $.fn.editDoorsSettings.defaults,
				dialog : null
			}
		},

		lastImport	: {
			label	: 'Last import',
			title	: 'Date, time and baseline of the last import',
			never   : 'Never'
		}

	};

	// A plugin to get the selected modules in the modules list
	$.fn.getSelectedDoorsModules = function() {
		var result = [];

		$('table.modules tr.module', this).each(function() {
			var row      = $(this);
			var module   = row.data('module');
			var selector = row.find('input[type="checkbox"][name="selector"]:checked');

			if ($.isPlainObject(module) && selector.length > 0) {
				result.push(module);
			}
		});

		return result;
	};


	// A plugin that shows the modules in a baseline set in a popup dialog
	// context: { server, username, password, project, trackers, folder }
	$.fn.showBaselineSetModulesDialog = function(context, baselineSet, modules, config, dialog, callback) {
		var settings = $.extend({}, $.fn.showBaselineSetModulesDialog.defaults, dialog);

		var popup = $('#baselineSetModulesPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'baselineSetModulesPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
			$(document.documentElement).append(popup);
		} else {
			popup.empty();
		}

		function showModulesList() {
			var modulesList = [];

			var moduleVersions = baselineSet[settings.modules];
			if ($.isPlainObject(moduleVersions)) {
				// For already imported baseline sets, we must use the saved module to tracker mapping that was used at the time of the import
				var mapping = baselineSet.mapping;
				if (!$.isPlainObject(mapping)) {
					mapping = null;
				}

				$.each(moduleVersions, function(moduleId, baselineId) {
					var module = modules[moduleId];
					if ($.isPlainObject(module)) {
						var tracker = (mapping ? mapping[moduleId] : module.tracker);

						modulesList.push($.extend({}, module, {
							module   : module,
							baseline : baselineId,
							tracker  : tracker
						}));
					}
				});
			}

			popup.doorsModulesList(context, modulesList, $.extend({}, config, {
				editable : baselineSet.status != 'imported'
			}), callback);
		}

		function setNewModuleTrackers(trackers) {
			if ($.isPlainObject(trackers)) {
				var moduleTableSetNewModuleTrackers = popup.find('table.modules').data('setNewModuleTrackers');
				var created = 0;
				var failed  = 0;

				$.each(trackers, function(moduleId, tracker) {
					var module = modules[moduleId];

					if ($.isPlainObject(module) && $.isPlainObject(tracker)) {
						if (tracker.id) {
							module.tracker = tracker;
							created++;

						} else if (tracker.exception) {
							failed++;
						}
					}
				});

				if (failed > 0) {
					showFancyAlertDialog(settings.importWithErrors.replace('XXX', created).replace('YYY', context.project.name).replace('ZZZ', failed));
				} else if (created > 0) {
					showFancyAlertDialog(settings.importSuccess.replace('XXX', created).replace('YYY', context.project.name), 'information');
				}

				if ($.isFunction(moduleTableSetNewModuleTrackers)) {
					moduleTableSetNewModuleTrackers.call(popup, trackers);
				}

				if (created > 0 && $.isFunction(callback)) {
					callback(true);
				}
			}
		}

		function createNewTrackers() {
			try {
				modulesList = popup.getSelectedDoorsModules();

				if ($.isArray(modulesList) && modulesList.length > 0) {
					popup.showImportDoorsModulesDialog(context, modulesList, settings.importDialog, setNewModuleTrackers);
				}
			} catch(error) {
				showFancyAlertDialog(error);
			}
		}

		function close() {
			popup.dialog("close");
			popup.remove();
		}

		settings.title = settings.title.replace('XXX', context.folder.path + '/' + baselineSet.definition.name + '/' + baselineSet.id);

		settings.buttons = [{
			text  : settings.closeText,
			click : close
		}];

		if (baselineSet.status != 'imported') {
			settings.buttons.push({
				text  : settings.importDialog.label,
			   "class": "cancelButton",
				click : createNewTrackers
			});
		}

	    settings.close = function() {
  			popup.remove();
	    };

	    showModulesList();

		popup.dialog(settings);

		return this;
	};


	$.fn.showBaselineSetModulesDialog.defaults = {
		title			: 'Modules in Baseline Set XXX',
		modules 		: 'baselines',
		importDialog 	: $.fn.showImportDoorsModulesDialog.defaults,
		importSuccess   : 'Successfully created and configured XXX new Trackers for the selected DOORS Modules in Project YYY',
		importWithErrors: 'Could only create and configure XXX new Trackers for the selected DOORS Modules in Project YYY.\n Creating Trackers for ZZZ Modules failed.\n Please see list for details.',
	    closeText    	: 'Close',
	    cancelText   	: 'Cancel',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 1200,
		height			: 800
	};



	// A plugin to edit the DOORS import settings of a specific tracker in a popup dialog
	// context: { server, username, password, project, folder,  baselineSets }
	$.fn.importDoorsBaselineSetsDialog = function(context, config, callback) {
		var settings = $.extend(true, {}, $.fn.importDoorsBaselineSetsDialog.defaults, config);

		function getModulePath(rootPath, module) {
			var modPath = module.path;

			if (modPath.startsWith(rootPath)) {
				modPath = modPath.substring(rootPath.length);
			}

			return modPath;
		}

		function getTrackerLink(project, tracker) {
			var trackerPath = (tracker.project && tracker.project.id != project.id ? tracker.project.name + '/' + tracker.name : tracker.name);

			return $('<a>', {
				href  : settings.tracker.url.replace('XXX', tracker.id),
				title : tracker.title || tracker.description
			}).text(trackerPath).click(function(event) {
				event.preventDefault();
				window.open($(this).attr('href'), "_blank");
				return false;
			});
		}

		function showStepsTable(container, baselineSets) {
			if ($.isArray(baselineSets) && baselineSets.length > 0) {
				var progressBar = $('<div>', { "class" : 'progressBar', style : 'display: None;' });
				container.append(progressBar);

				var table = $('<table>', { "class" : 'displaytag baselineSets', style : 'width: 96%;'});
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var toggle = $('<input>', { type : 'checkbox', name : 'toggle', value : 'true', title : settings.baselines.toggleAll, checked : true, style : 'margin-left: 4px;' });

				headline.append($('<th>', { "class" : 'textData' }).append($('<a>', {
					href  : '#',
					title : settings.collapseAll
				}).text('\u25C2').click(function(event) {
					event.preventDefault();
					table.treetable('collapseAll');
					return false;
				})).append($('<a>', {
					href  : '#',
					title : settings.expandAll,
					style : 'margin-Left: 2px;'
				}).text('\u25B8').click(function(event) {
					event.preventDefault();
					table.treetable('expandAll');
					return false;
				})).append($('<label>', {
					style : 'margin-Left: 3px;'
				}).text(settings.baselineSet.label + ' \u25B8 ' + settings.module.label + ' \u25B8 ' + settings.baseline.label)).append(toggle));

				headline.append($('<th>', { "class" : 'textCenterData', style : 'width: 20px;', title : settings.baseline.status.title }).text(settings.baseline.status.label));
				headline.append($('<th>', { "class" : 'textData' }).text(settings.tracker.label));

				var tbody = $('<tbody>');
				table.append(tbody);

				var rootPath = context.folder.path + '/';
				var project  = context.project;
				var rowId = 0;

				for (var i = 0; i < baselineSets.length; ++i) {
					var baselineSet = baselineSets[i];
					var blSetId     = ++rowId;

					var row = $('<tr>', { "class" : 'odd baselineSet', "data-tt-id" : blSetId, style : 'vertical-align: middle;', title : baselineSet.description }).data('baselineSet', baselineSet);
					tbody.append(row);

					row.append($('<td>', { "class" : 'textData' }).text(baselineSet.definition.name + " - " + baselineSet.id));
					row.append($('<td>', { "class" : 'status'   }));
					row.append($('<td>', { "class" : 'textData' }).text(baselineSet.createdAt + ", " + baselineSet["Created By"]));

					var modules = baselineSet.modules;
					if ($.isArray(modules) && modules.length > 0) {
						modules.sort(function(a, b) {
							return getModulePath(rootPath, a).localeCompare(getModulePath(rootPath, b));
						});

						for (var j = 0; j < modules.length; ++j) {
							var module  = modules[j];
							var tracker = module.tracker;
							var modId   = ++rowId;

							row = $('<tr>', { "class" : 'even module', "data-tt-parent-id" : blSetId, "data-tt-id" : modId, style : 'vertical-align: middle;' }).data('module', module);
							tbody.append(row);

							row.append($('<td>', { "class" : 'textData', title : module.description }).text(getModulePath(rootPath, module)));
							row.append($('<td>', { "class" : 'status' }));
							row.append($('<td>', { "class" : 'textData' 							}).append(getTrackerLink(project, tracker)));

							var baselines = module.baselines;
							if ($.isArray(baselines) && baselines.length > 0) {
								for (var k = 0; k < baselines.length; ++k) {
									var baseline = baselines[k];
									var blId     = ++rowId;

									row = $('<tr>', { "class" : 'odd baseline', "data-tt-parent-id" : modId, "data-tt-id" : blId, title : baseline.description, style : 'vertical-align: middle;' }).data('baseline', baseline);
									tbody.append(row);

									row.append($('<td>', {
									   "class"   : 'textData',
										style 	 : 'vertical-align: middle;'
									}).append($('<input>', {
										type  	 : 'checkbox',
										name  	 : 'selector',
										value 	 : 'true',
										title 	 : settings.baseline.toggleThis,
										checked  : true,
										disabled : module.head ? false : (k == baselines.length - 1),
										style 	 : 'margin-right: 4px;'
									})).append($('<label>').text(baseline.id).click(function(event) {
										event.preventDefault();
										$(this).prev().click();
										return false;
									})));
									row.append($('<td>', { "class" : 'status'   }));
									row.append($('<td>', { "class" : 'textData' }).text(baseline.createdAt + ", " + baseline["Created By"]));
								}
							}
						}
					}

					delete baselineSet.modules;
				}

				toggle.change(function() {
					var checked = toggle.is(':checked');

					$('input[type="checkbox"][name="selector"]:enabled', tbody).attr('checked', checked);
				});

				table.treetable({
					column		 : 0,
					expandable   : true,
					initialState : 'expanded'
				});
			} else {
				container.text(settings.baselineSets.none);
			}
		}

		function getImportSteps(container) {
			var baselineSets = [];
			var steps  		 = 0;

			container.find('table.baselineSets tr.baselineSet').each(function() {
				var row    = $(this);
				var status = row.find('td.status');

				if (!status.hasClass('imported')) {
					var baselineSet = {
						rowId	: row.attr('data-tt-id'),
						data 	: row.data('baselineSet'),
						status	: status,
						modules : []
					};

					status.attr("class", 'status pending');

					row.nextAll('tr.module[data-tt-parent-id="' + baselineSet.rowId + '"]').each(function() {
						row    = $(this);
						status = row.find('td.status');

						if (!status.hasClass('imported')) {
							var module = {
								rowId	  : row.attr('data-tt-id'),
								data      : row.data('module'),
								status    : status,
								baselines : [],
								skipped   : []
							};

							status.attr("class", 'status pending');

							row.nextAll('tr.baseline[data-tt-parent-id="' + module.rowId + '"]').each(function() {
								row      = $(this);
								status   = row.find('td.status');
								selector = row.find('input[type="checkbox"][name="selector"]');

								if (!(status.hasClass('imported') || status.hasClass('skipped'))) {
									var baseline = {
										rowId    : row.attr('data-tt-id'),
										data     : row.data('baseline'),
										selector : selector,
										status   : status
									};

									status.attr("class", 'status pending');

									if (selector.is(':checked')) {
										baseline.skipped = module.skipped;
										module.baselines.push(baseline);

										module.skipped = [];
										steps++;

									} else {
										module.skipped.push(baseline);
									}
								}
							});

							baselineSet.modules.push(module);

							if (module.data.head) {
								steps++;
							}
						}
					});

					baselineSets.push(baselineSet);
					steps++;
				}
			});

			return {
				baselineSets : baselineSets,
				steps	 	 : steps
			};
		}

		function showModuleBaselineImportStatistics(module, baseline, statistics) {
			var popup = $('#ModuleImportStatisticsPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'ModuleImportStatisticsPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			popup.remoteImportStatistics(statistics, settings.baseline.statistics.config);

			popup.dialog($.extend({}, settings.baseline.statistics.dialog, {
				title : settings.baseline.statistics.dialog.title.replace('XXX', baseline.id).replace('YYY', module.path),
				close : function() {
		  			popup.remove();
			    }
			}));
		}

		function addImportStatisticsLink(module, baseline, statistics) {
			var nameColumn;

			if ($.isPlainObject(baseline)) {
				nameColumn = baseline.status.prev();
				nameColumn.find('label').remove();
			} else {
				nameColumn = module.status.prev();
				baseline = {
					data : {
						id : '#HEAD'
					}
				};
			}

			nameColumn.append($('<a>', {
				href  : '#',
				title : settings.baseline.statistics.hint
			}).text(baseline.data.id).click(function(event) {
				event.preventDefault();
				showModuleBaselineImportStatistics(module.data, baseline.data, statistics);
				return false;
			}));
		}

		function incrementProgressBar(progressBar) {
	    	if (settings["import"].running) {
				var progress = progressBar.progressbar("value");
				progressBar.progressbar("value", progress + 1);
	    	}
		}

		function importModuleBaseline(table, progressBar, module, baseline, callback) {
			$.ajax(settings.baseline.url + '?tracker_id=' + module.data.tracker.id, {
		    	type 	 	: 'POST',
				contentType : 'application/json',
		    	data 	 	: JSON.stringify({
		    		direction : 1,
		    		baseline  : baseline ? baseline.data.id : null,
		    		mirroring : true,
		    		newerThan : module.data.newerThan || null
		    	}),
		    	dataType 	: 'json',
		    	cache	 	: false,
		    	beforeSend  : function() {
		    		var skipped;

		    		if ($.isPlainObject(baseline)) {
			    		baseline.status.attr("class", 'status running');
						table.treetable('expandNode', module.rowId);

						skipped = baseline.skipped;
		    		} else {
			    		module.status.attr("class", 'status running');
			    		skipped = module.skipped;
		    		}

		    		if ($.isArray(skipped) && skipped.length > 0) {
		    			for (var i = 0; i < skipped.length; ++i) {
				    		skipped[i].selector.attr("disabled", true);
				    		skipped[i].status.attr({
				    			"class" : 'status skipped',
				    			 title  : settings.baseline.status.skipped.title
				    		});
		    			}
		    		}
		    	}
		    }).done(function(result) {
		    	if ($.isPlainObject(baseline)) {
			    	baseline.selector.attr('disabled', true);
					baseline.status.attr({
					   "class" : 'status imported',
						title  : settings.baseline.status.imported.title
					});
//			    	baseline.data.result = result;

			    	addImportStatisticsLink(module, baseline, result);

			    	// Important: Set newerThan for next module import to the baseline date !
			    	module.data.newerThan = baseline.data["Created On"];

					var nextBaseline = $.isArray(module.baselines) ? module.baselines.shift() : null;
					if ($.isPlainObject(nextBaseline) || module.data.head) {
				    	// If the import has not been cancelled
				    	if (settings["import"].running) {
				    		module.status.attr("class", 'status pending');

							importModuleBaseline(table, progressBar, module, nextBaseline, callback);
				    	}
					} else {
						callback(true);
					}
		    	} else {
//			    	module.data.result = result;
		    		addImportStatisticsLink(module, null, result);

			    	delete module.data.newerThan;

		    		callback(true);
		    	}
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		var skipped;

				if ($.isPlainObject(baseline)) {
					baseline.status.attr({
					   "class" : 'status failed',
						title  : settings.baseline.status.failed.title
					});
					skipped = baseline.skipped;
				} else {
					skipped = module.skipped;
				}

	    		if ($.isArray(skipped) && skipped.length > 0) {
	    			for (var i = 0; i < skipped.length; ++i) {
			    		skipped[i].selector.attr("disabled", false);
			    		skipped[i].status.attr({
			    			"class" : 'status importable',
			    			 title  : settings.baseline.status.importable.title
			    		});
	    			}
	    		}

	    		try {
	    			module.exception = $.parseJSON(jqXHR.responseText);

	    			module.status.click(function() {
			    		showFancyAlertDialog(module.exception.message);
		    		}).click();

	    			if ($.isPlainObject(baseline)) {
	    				baseline.exception = module.exception;

	    				baseline.status.click(function() {
	    					module.status.click();
			    		});
	    			}
	    		} catch(err) {
	    			showAjaxError(jqXHR, textStatus, errorThrown);
	    		}

	    		callback(false);
	        }).always(function() {
	        	incrementProgressBar(progressBar);
	        });
		}

		function importBaselineSetModule(table, progressBar, baselineSet, module, callback) {
			var baseline = $.isArray(module.baselines) ? module.baselines.shift() : null;
			if ($.isPlainObject(baseline) || module.data.head) {
				importModuleBaseline(table, progressBar, module, baseline, function(done) {
					if (done) {
						module.status.attr("class", 'status imported');
						table.treetable('collapseNode', module.rowId);
					} else {
						module.status.attr("class", 'status failed');
					}
					callback(done);
				});
			} else {
				module.status.attr("class", 'status imported');
				callback(true);
			}
		}

		function submitBaselineSet(table, progressBar, baselineSet, callback) {
			$.ajax(settings.baselineSet.url + '?proj_id=' + context.project.id, {
		    	type 	 	: 'POST',
				contentType : 'application/json',
		    	data 	 	: JSON.stringify(baselineSet.data),
		    	dataType 	: 'json',
		    	cache	 	: false,
		    	beforeSend  : function() {
					baselineSet.status.attr("class", 'status running');
		    	}
		    }).done(function(result) {
		    	baselineSet.status.attr("class", 'status imported');
		    	baselineSet.result = result;

		    	callback(true);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				baselineSet.status.attr("class", 'status failed');

	    		try {
	    			baselineSet.exception = $.parseJSON(jqXHR.responseText);

	    			baselineSet.status.click(function() {
			    		showFancyAlertDialog(baselineSet.exception.message);
		    		}).click();
	    		} catch(err) {
	    			showAjaxError(jqXHR, textStatus, errorThrown);
	    		}

	    		callback(false);
	        }).always(function() {
	        	incrementProgressBar(progressBar);
	        });
		}

		function importBaselineSet(table, progressBar, baselineSet, callback) {
			if ((baselineSet.toDo = baselineSet.modules.length) > 0) {
				baselineSet.failed = 0;

				function moduleFinished(done) {
			    	baselineSet.toDo--;

					if (!done) {
						baselineSet.failed++;
					}

			    	if (baselineSet.toDo > 0) {
				    	// If the import has not been cancelled
				    	if (settings["import"].running) {
				    		importNextModule();
				    	}
			    	} else if (baselineSet.failed == 0) {
						table.treetable('collapseNode', baselineSet.rowId);

						if (baselineSet.data.id !== 'HEAD') {
							submitBaselineSet(table, progressBar, baselineSet, callback);
						} else {
					    	baselineSet.status.attr("class", 'status imported');
					    	incrementProgressBar(progressBar);
							callback(true);
						}
		    		} else {
						baselineSet.status.attr("class", 'status failed');

		    			callback(false);
		    		}
				}

				function importNextModule() {
					var module = baselineSet.modules.shift();
			    	if (module) {
			    		importBaselineSetModule(table, progressBar, baselineSet, module, moduleFinished);
			    	}

			    	return module;
				}

				table.treetable('expandNode', baselineSet.rowId);

				for (var threads = 0; threads < 4;) {
			    	if (importNextModule()) {
			    		threads++;
			    	} else {
			    		break;
			    	}
				}
			} else if (baselineSet.data.id !== 'HEAD') {
				submitBaselineSet(table, progressBar, baselineSet, callback);
			} else {
		    	baselineSet.status.attr("class", 'status imported');
		    	incrementProgressBar(progressBar);
				callback(true);
			}
		}

		function importBaselineSetList(table, progressBar, baselineSets, callback) {
			var baselineSet = baselineSets.shift();
			if (baselineSet) {
				function baselineSetFinished(done) {
					if (done) {
						var nextBaselineSet = baselineSets.shift();
						if (nextBaselineSet) {
					    	// If the import has not been cancelled
					    	if (settings["import"].running) {
								importBaselineSet(table, progressBar, nextBaselineSet, baselineSetFinished);
					    	}
						} else {
							callback(true);
						}
					} else {
						callback(false);
					}
				}

				importBaselineSet(table, progressBar, baselineSet, baselineSetFinished);
			} else {
				callback(true);
			}
		}

		function importBaselineSets(container, callback) {
			var toImport = getImportSteps(container);
			if (toImport.steps > 0) {
				var stepsTable  = $('table.baselineSets', container);
				var progressBar = $('div.progressBar',    container);

				stepsTable.treetable("collapseAll");

				progressBar.show().progressbar({
					value 	: 0,
					max		: toImport.steps
				});

				importBaselineSetList(stepsTable, progressBar, toImport.baselineSets, function(done) {
					progressBar.hide().progressbar("destroy");

					if (done) {
						showFancyAlertDialog(settings["import"].success, 'information');
					} else {
						stepsTable.find('td.status.pending').removeClass('pending');
					}

					callback(done);
				});
			} else {
				callback(true);
			}
		}

		function getImportedBaselineSets(container) {
			var result = [];

			container.find('table.baselineSets tr.baselineSet').has('td.status.imported').each(function() {
				var srow 		= $(this);
				var baselineSet = $.extend({}, srow.data('baselineSet'), {
					modules		: []
				});

				delete baselineSet.createdAt;
				delete baselineSet.status;

				srow.nextAll('tr.module[data-tt-parent-id="' + srow.attr('data-tt-id') + '"]').has('td.status.imported').each(function() {
					var mrow      = $(this);
					var module    = $.extend({}, mrow.data('module'), {
						baselines : []
					});

					delete module.tracker;
					delete module.lastImport;
					delete module.newerThan;

					mrow.nextAll('tr.baseline[data-tt-parent-id="' + mrow.attr('data-tt-id') + '"]').has('td.status.imported').each(function() {
						var baseline = $.extend({}, $(this).data('baseline'));

						delete baseline.createdAt;

						module.baselines.push(baseline);
					});

					baselineSet.modules.push(module);
				});

				result.push(baselineSet);
			});

			return result;
		}

		function showImportSteps(baselineSets) {
			var popup = $('#importBaselineSetsPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'importBaselineSetsPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			showStepsTable(popup, baselineSets);

			function notify(done) {
				if ($.isFunction(callback)) {
					callback(done, getImportedBaselineSets(popup));
				}
			}

			function close(done) {
				popup.dialog("close");
				notify(done);
				popup.remove();
			}

			settings.buttons = [{
				text 	: settings.submitText,
			   "class"	: "submitButton",
				click	: function() {
			 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button.submitButton');
			 		buttons.button("disable");

			 		settings["import"].running = true;

					try {
						importBaselineSets(popup, function(done) {
							settings["import"].running = false;

							if (done) {
								close(true);
							} else {
								buttons.button("enable");
							}
						});
					} catch(error) {
						showFancyAlertDialog(error);
						buttons.button("enable");
						settings["import"].running = false;
					}
				}
			}, {
				text	: settings["import"].cancel.label,
			   "class"	: "cancelButton",
				click 	: function() {
					if (settings["import"].running) {
						showFancyConfirmDialogWithCallbacks(settings["import"].cancel.confirm, function() {
							settings["import"].running = false;

							popup.find('div.progressBar').hide().progressbar("destroy");
							popup.find('table.baselineSets td.status.pending').removeClass('pending');
							popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button.submitButton').button("enable");;

							// Not closing here, the user has to click Cancel or Close again
						});
					} else {
						close(false);
					}
				}
			}];

		    settings.close = function() {
				if (settings["import"].running) {
					showFancyAlertDialog(settings["import"].cancel.required);
				} else {
					notify(false);
		  			popup.remove();
				}
		    };

			popup.dialog(settings);
		}

		function loadImportSteps() {
			var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

			$.ajax(settings.stepsURL, {
		    	type 	 	: 'POST',
				contentType : 'application/json',
		    	data 	 	: JSON.stringify(context),
		    	dataType 	: 'json',
		    	cache	 	: false
		    }).done(function(baselineSets) {
				ajaxBusyIndicator.close(busy);

				showImportSteps(baselineSets);

			}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
				showAjaxError(jqXHR, textStatus, errorThrown);
	        });
		}

		loadImportSteps();
		return this;
	};


	$.fn.importDoorsBaselineSetsDialog.defaults = $.extend(true, {}, $.fn.doorsImport.defaults, {
		title			: 'Import DOORS Baseline Sets',
		loading 		: 'Loading necessary steps, to import the selected baseline sets ...',
		stepsURL		: contextPath + '/ajax/doors/baselineSetImportSteps.spr',
		expandAll		: 'Expand all tree nodes',
		collapseAll		: 'Collapse all tree nodes',

		baselineSet		: {
			label		: 'Baseline Set',
			url			: contextPath + '/ajax/doors/importBaselineSet.spr'
		},

		baseline		: {
			url			: contextPath + '/ajax/doors/import.spr',

			statistics	: {
				hint	: 'Click here, to show statistics about the import of this baseline',
				config	: $.fn.remoteImportStatistics.defaults,
				dialog	: {
					title			: 'Import of Baseline XXX of Module YYY',
					dialogClass		: 'popup',
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: true,
					draggable		: true,
					closeOnEscape	: true,
					width			: 480
				}
			}
		},

		tracker			: {
			label		: 'Tracker',
			url			: contextPath + '/tracker/XXX'
		},

		"import"		: {
			full		: {
				label	: 'full',
				title	: 'A full import of all data in this module/baseline'
			},

			incremental	: {
				label	: 'incremental',
				title	: 'An incremental import of modified data in this module/baseline'
			},

			success		: 'The DOORS Baseline Sets were imported successfully',

			cancel		: {
				label	: 'Cancel',
				required: 'You cannot close this dialog, because an import is running. You have to Cancel the import first!',
				confirm : 'Do you really want to cancel the running import ?'
			}
		},

		submitText    	: 'OK',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 900,
		height			: 800
	});


	// A plugin to display a list of importable baseline sets from a selected DOORS project/folder
	$.fn.importableBaselineSets = function(projectId, source, config) {
		var settings = $.extend(true, {}, $.fn.importableBaselineSets.defaults, config);

		function getCoverage(baselineSet, modules) {
			var result = [0, 0];

			if ($.isPlainObject(baselineSet.baselines)) {
				// For already imported baseline sets, we must use the saved module to tracker mapping that was used at the time of the import
				var mapping = baselineSet.mapping;
				if (!$.isPlainObject(mapping)) {
					mapping = null;
				}

				$.each(baselineSet.baselines, function(moduleId, baseline) {
					var module = modules[moduleId];
					if ($.isPlainObject(module)) {
						var tracker = (mapping ? mapping[moduleId] : module.tracker);
						if ($.isPlainObject(tracker)) {
							++result[0];
						}

						++result[1];
					}
				});
			}

			return result;
		}

		function getCvrgClass(coverage) {
			return coverage[0] == 0 ? 'none' : coverage[0] == coverage[1] ? 'full' : 'part';
		}

		function refreshCoverage(table) {
			var modules = table.data('modules');

			table.find('tr.baselineSet:not(:has(td.status.imported))').each(function() {
				var row 		= $(this);
				var baselineSet = row.data('baselineSet');
				var status 		= baselineSet.status || 'importable';
				var coverage    = getCoverage(baselineSet, modules);

				if (status == 'importable') {
					row.find('input[type="checkbox"][name="selector"]').attr(coverage[0] > 0 ? {
						disabled : false
					} : {
						disabled : true,
						checked  : false
					});
				}

				var coverageCell = row.find('td.coverage');

				coverageCell.attr("class", 'textCenterData coverage ' + getCvrgClass(coverage));
				coverageCell.find('a').text(coverage[0] + " / " + coverage[1]);
			});
		}

		function showBaselineSets(login, folder, project) {
			if (!$.isPlainObject(project)) {
				project = {};
			}

			var baselineSets = project.baselineSets;

			if ($.isArray(baselineSets) && baselineSets.length > 0) {
				var modules = project.modules;

				var table = $('<table>', { "class" : 'displaytag baselineSets', style : 'margin-left: 0px; border: 1px solid silver; width: 96%;'});
				settings.baselineSets.cell.append(table);

				table.data('project', project.project);
				table.data('folder',  folder);
				table.data('modules', modules);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var cell = $('<th>', { "class" : 'checkbox-column-minwidth', title : settings.baselineSets.toggleAll });
				headline.append(cell);

				var toggle = $('<input>', { type : 'checkbox', name : 'toggle', value : 'true' });
				cell.append(toggle);

				headline.append($('<th>', { "class" : 'textData', 		title : settings.baselineSets.definition.title }).text(settings.baselineSets.definition.label));
				headline.append($('<th>', { "class" : 'textData', 		title : settings.baselineSets.version.title    }).text(settings.baselineSets.version.label));
				headline.append($('<th>', { "class" : 'dateData', 		title : settings.baselineSets.createdAt.title  }).text(settings.baselineSets.createdAt.label));
				headline.append($('<th>', { "class" : 'textData', 		title : settings.baselineSets.createdBy.title  }).text(settings.baselineSets.createdBy.label));
				headline.append($('<th>', { "class" : 'textCenterData', title : settings.baselineSets.status.title     }).text(settings.baselineSets.status.label));
				headline.append($('<th>', { "class" : 'textCenterData', title : settings.baselineSets.coverage.title   }).text(settings.baselineSets.coverage.label));

				var tbody = $('<tbody>');
				table.append(tbody);

				for (var i = 0; i < baselineSets.length; ++i) {
					var baselineSet    = baselineSets[i];
					var blSetStatus    = baselineSet.status || 'importable';
					var statusSettings = settings.baselineSets.status[blSetStatus] || settings.baselineSets.status.importable;
					var coverage       = getCoverage(baselineSet, modules);

					var row = $('<tr>', { "class" : 'even baselineSet', style : 'vertical-align: middle;' }).data('baselineSet', baselineSet);
					tbody.append(row);

					cell = $('<td>', { "class" : 'selector checkbox-column-minwidth', title : settings.baselineSets.selectSet });
					row.append(cell);

					var selector = $('<input>', { type : 'checkbox', name : 'selector', value : 'true', disabled : (blSetStatus != 'importable' || coverage[0] == 0) });
					cell.append(selector);

					row.append($('<td>', { "class" : 'textData', title : baselineSet.definition.description }).text(baselineSet.definition.name));
					row.append($('<td>', { "class" : 'textData', title : baselineSet.description 			}).text(baselineSet.id));
					row.append($('<td>', { "class" : 'dateData' 											}).text(baselineSet.createdAt));
					row.append($('<td>', { "class" : 'textData' 											}).text(baselineSet["Created By"]));

					cell = $('<td>', { "class" : 'status ' + blSetStatus, title : statusSettings.title });
					row.append(cell);

					if (blSetStatus == 'imported' && $.isPlainObject(baselineSet.imported)) {
						cell.attr('title', statusSettings.title + ': ' + baselineSet.imported.date + ', ' + baselineSet.imported.user.name + ' (' + baselineSet.imported.user.realName + ')');
					} else if (blSetStatus == 'blocked' && $.isPlainObject(baselineSet.blockers)) {
						cell.click(function(event) {
							var blset = $(this).closest('tr.baselineSet').data('baselineSet');

							event.preventDefault();

							table.showBaselineSetModulesDialog($.extend(login.getRemoteConnection(), {
								project : project.project,
								trackers: project.trackers,
								folder  : folder
							}), blset, modules, settings.baselineSets.status.blocked.config, settings.baselineSets.status.blocked.dialog);

							return false;
						});
					}

					cell = $('<td>', { "class" : 'textCenterData coverage ' + getCvrgClass(coverage), style : 'width: 6em;' });
					row.append(cell);

					cell.append($('<a>', {
						href  : '#',
						title : settings.baselineSets.coverage.hint
					}).text(coverage[0] + " / " + coverage[1]).click(function(event) {
						var blset = $(this).closest('tr.baselineSet').data('baselineSet');

						event.preventDefault();

						table.showBaselineSetModulesDialog($.extend(login.getRemoteConnection(), {
							project : project.project,
							trackers: project.trackers,
							folder  : folder
						}), blset, modules, settings.baselineSets.coverage.config, settings.baselineSets.coverage.dialog, function(refresh) {
							if (refresh) {
								refreshCoverage(table);
							}
						});

						return false;
					}));
				}

				toggle.change(function() {
					var checked = toggle.is(':checked');

					$('input[type="checkbox"][name="selector"]:enabled', tbody).attr('checked', checked);
				});

			} else {
				settings.baselineSets.cell.text(settings.baselineSets.none);
			}
		}

		function folderChanged(table, folder, callback) {
			settings.baselineSets.cell.empty();

			if ($.isPlainObject(folder) && folder.id) {
				var busy = ajaxBusyIndicator.showBusyPage(settings.baselineSets.loading);

			    $.ajax(settings.baselineSets.url + projectId, {
			    	type 	    : 'POST',
					contentType : 'application/json',
			    	dataType 	: 'json',
					data 		: JSON.stringify($.extend(table.getRemoteConnection(), {
						folder  : folder.id
					})),
			    	cache	 	: false
			    }).done(function(result) {
					ajaxBusyIndicator.close(busy);

					showBaselineSets(table, folder, result);
					callback();

					settings.baselineSets.row.show();

			    }).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
			    });
			} else {
				settings.baselineSets.row.hide();
			}
		}

		function init(form, source) {
			if ($.isPlainObject(source)) {
				delete source.baselineSets;
			} else {
				source = {};
			}

			var folder = source.module;
			if (!$.isPlainObject(folder)) {
				folder = {};
			}

			form.helpLink(settings.help);

			var table = $('<table>', { "class" : 'mapping formTableWithSpacing', style : 'width: 100%;' }).data('source', source);
			form.append(table);

			table.editRemoteConnection(source, settings);

			var row = $('<tr>');
			table.append(row);

			var label = $('<td>', { "class" : 'labelCell optional', title : settings.folder.title }).text(settings.folder.label + ':');
			row.append(label);

			var cell = $('<td>', { "class" : 'dataCell', colspan : 3 });
			row.append(cell);

			var folderPath = $('<input>', { type : 'text', name : 'folder', maxlength : 120, placeholder: settings.folder.selector.title, title : folder.description, value : folder.path, disabled : true }).attr("size", "80").data('folder', folder);
			cell.append(folderPath);

			cell.append($('<a>', {
				href  : '#',
				title : settings.folder.selector.title,
				style : 'margin-left: 1em;'
			}).text(settings.folder.selector.label).click(function(event) {
				event.preventDefault();

				table.chooseDoorsFolderDialog(projectId, $.extend(table.getRemoteConnection(), {
					folder : folderPath.val()
				}), settings.folder.selector, function(selected) {
					folderPath.data('folder', selected);
					folderPath.val(selected.path).attr('title',  selected.description).change();
				});

				return false;
			}));


			var onlyImportable = $('<input>', {	type : 'checkbox', id : 'onlyImportableBaselineSetsCheckbox', name: 'onlyImportable', checked : true });

			settings.baselineSets.row = $('<tr>', { style : 'display: None;'});
			table.append(settings.baselineSets.row);

			label = $('<td>', { "class" : 'labelCell optional', title : settings.baselineSets.title, style : 'vertical-align:top;' });

			label.append($('<div>', {
				title : settings.baselineSets.importable.title
			}).append(onlyImportable).append($('<label>', {
				"for" : 'onlyImportableBaselineSetsCheckbox'
			}).text(settings.baselineSets.importable.label)));

			label.append($('<label>').text(settings.baselineSets.label + ':'));

			settings.baselineSets.row.append(label);

			settings.baselineSets.cell = $('<td>', { "class" : 'dataCell baselineSets', colspan : 3 });
			settings.baselineSets.row.append(settings.baselineSets.cell);


			onlyImportable.change(function() {
				var checked = onlyImportable.is(':checked');

				settings.baselineSets.cell.find('table.baselineSets tr.baselineSet:not(:has(td.status.importable))').each(function() {
					var row = $(this);
					if (checked) {
						row.hide();
					} else {
						row.show();
					}
				});
			})

			folderPath.change(function() {
				folderChanged(table, folderPath.data('folder'), function() {
					onlyImportable.change();
				});
			});

			// If the server changes, force re-selecting the folder
			$('input[name="server"]', table).change(function() {
				folderPath.removeData('folder');
				folderPath.val('').attr('title', '').change();
			});


			return folderPath;
		}

		return init(this, source);
	};


	$.fn.importableBaselineSets.defaults = $.extend({}, $.fn.editRemoteConnection.defaults, {
		folder			: {
			label		: 'Project/Folder',
			title		: 'The DOORS project/folder, whose defined baseline sets to import',
			selector	: $.fn.chooseDoorsFolderDialog.defaults
		},

		baselineSets	: {
			label		: 'Baseline Sets',
			title		: 'The defined baseline sets of the selected DOORS project/folder',
			url			: contextPath + '/ajax/doors/importableBaselineSets.spr?proj_id=',
			loading		: 'Loading the defined baseline sets of the selected DOORS project/folder ...',
			none		: 'There are no defined baseline sets in the selected DOORS project/folder',

			toggleAll	: '(De-)Select all importable baseline sets',
			selectSet   : '(De-)Select this baseline set for import',

			importable	: {
				label 	: 'Importable',
				title 	: 'Whether to only show the importable baseline sets, or also those, that are already imported or cannot be imported'
			},

			definition	: {
				label	: 'Definition',
				title	: 'The name of the baseline set definition'
			},

			version		: {
				label	: 'Version',
				title	: 'The version (major, minor and optional suffix) of the baseline set'
			},

			createdAt	: {
				label	: 'Created at',
				title	: 'The date and time of baseline set creation'
			},

			createdBy	: {
				label	: 'Created by',
				title	: 'The name of the DOORS user, that created this baseline set'
			},

			status		: {
				label	: 'Status',
				title	: 'The status of this baseline set',

				importable	: {
					label	: 'Importable',
					title	: 'This baseline set can be imported'
				},

				imported	: {
					label	: 'Imported',
					title	: 'This baseline set was already imported'
				},

				blocked		: {
					label	: 'Blocked',
					title	: 'This baseline set cannot be imported, because at least one of the included modules has already been imported beyond the module version in this set',
					config  : $.fn.doorsModulesList.defaults,
					dialog  : $.extend({}, $.fn.showBaselineSetModulesDialog.defaults, {
						title 	: 'The imports of these Modules block the import of Baseline Set XXX',
						modules : 'blockers'
					})
				}
			},

			coverage	: {
				label	: 'Coverage',
				title	: 'The ratio of modules in this baseline set, that are associated with trackers',
				hint    : 'Click here, to view modules in this set and their associated target tracker',
				config  : $.fn.doorsModulesList.defaults,
				dialog  : $.fn.showBaselineSetModulesDialog.defaults
			}
		}
	});


	// A plugin to get the selected baseline sets in the baseline set list
	$.fn.getSelectedBaselineSets = function() {
		var login   	 = $('table.mapping', this);
		var baselineSets = $('table.baselineSets', this);
//		var importable   = [];
		var selected 	 = [];
		var completely	 = false;

		baselineSets.find('tr.baselineSet:has(td.status.importable)').each(function() {
			var row         = $(this);
			var baselineSet = row.data('baselineSet');

			if ($.isPlainObject(baselineSet)) {
//				importable.push(baselineSet);

				if (row.find('input[type="checkbox"][name="selector"]:checked').length > 0) {
					selected.push(baselineSet);

					if (row.is(':last-child')) {
						completely = true;
					}
				}
			}
		});

		return $.extend(login.getRemoteConnection(), {
			project		 : baselineSets.data('project'),
			folder  	 : baselineSets.data('folder' ),
			modules		 : baselineSets.data('modules'),
//			importable 	 : importable,
			baselineSets : selected,
			completely	 : completely
		});
	};


	// A plugin to edit the DOORS import settings of a specific tracker in a popup dialog
	$.fn.showDoorsBaselineSetDialog = function(projectId, config, dialog) {
		var popup    = this;
		var settings = $.extend({}, $.fn.showDoorsBaselineSetDialog.defaults, dialog);

		function showBaselineSets(mapping) {
			var folderPath = popup.importableBaselineSets(projectId, mapping, config);

		    settings.close = function() {
		    	popup.remove();
		    };

		    function close() {
				popup.dialog("close");
				popup.remove();
		    }

		    function finished(mapping, callback) {
				var folder = mapping.folder;

				if ($.isPlainObject(folder)) {
					delete mapping.project;
					delete mapping.folder;
					delete mapping.modules;

					mapping.module = folder;

					var busy = ajaxBusyIndicator.showBusyPage(settings.saving);

					$.ajax(settings.folderURL + '?proj_id=' + projectId, {
				    	type 	    : 'PUT',
						contentType : 'application/json',
				    	dataType 	: 'json',
						data 		: JSON.stringify(mapping),
				    	cache	 	: false
				    }).done(function() {
						ajaxBusyIndicator.close(busy);

						if ($.isFunction(callback)) {
							callback();
						}
				    }).fail(function(jqXHR, textStatus, errorThrown) {
						ajaxBusyIndicator.close(busy);
						showAjaxError(jqXHR, textStatus, errorThrown);
				    });
		    	}
		    }

		    function saveMapping(importedSets, baselineSets, modules) {
		    	function getBaselines(imported) {
			    	for (var i = 0; i < baselineSets.length; ++i) {
			    		var baselineSet = baselineSets[i];

			    		if (baselineSet.definition.name === imported.definition.name && baselineSet.id === imported.id) {
			    			return baselineSet.baselines;
			    		}
			    	}

			    	return null;
		    	}

		    	function getMapping(baselines) {
		    		var mapping = {};

					$.each(baselines, function(moduleId, baseline) {
						var module = modules[moduleId];

						if ($.isPlainObject(module) && $.isPlainObject(module.tracker)) {
							mapping[module.id] = module.tracker.id;
						}
					});

					return mapping;
		    	}

		    	for (var i = 0; i < importedSets.length; ++i) {
		    		var imported = importedSets[i];
		    		if ($.isPlainObject(imported)) {
		    			var baselines = getBaselines(imported);
		    			if ($.isPlainObject(baselines)) {
				    		imported.baselines = baselines;
					    	imported.mapping = getMapping(baselines, modules);
		    			}
		    		}
		    	}

		    	return importedSets;
		    }

			settings.buttons = [{
				text : settings.submitText,
				click: function() {
					try {
						var context = popup.getSelectedBaselineSets();
						if ($.isPlainObject(context)) {
							var modules      = context.modules;
							var baselineSets = context.baselineSets;

							delete context.modules;

							if ($.isArray(baselineSets) && baselineSets.length > 0) {
								popup.importDoorsBaselineSetsDialog(context, settings.importDialog, function(done, imported) {
									// If at least one baseline set was imported
									if ($.isArray(imported) && imported.length > 0) {
										finished($.extend({}, context, {
											baselineSets : saveMapping(imported, baselineSets, modules)
										}), done && context.completely ? close : function() {
											// Reload the baselines list to reflect their new status
											folderPath.change();
										});
									}
								});
							} else {
								finished(context, close);
							}
						}
					} catch(error) {
						showFancyAlertDialog(error);
					}
				}
			}, {
				text  : settings.cancelText,
			   "class": "cancelButton",
				click : close
			}];

			popup.dialog(settings);

			folderPath.change();
		}

		var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

	    $.ajax(settings.folderURL, {
	    	type 	 : 'GET',
	    	data 	 : { proj_id : projectId },
	    	dataType : 'json',
	    	cache	 : false
	    }).done(function(source) {
			ajaxBusyIndicator.close(busy);

			showBaselineSets(source);

		}).fail(function(jqXHR, textStatus, errorThrown) {
			ajaxBusyIndicator.close(busy);
			showAjaxError(jqXHR, textStatus, errorThrown);
        });

	    return this;
	};

	$.fn.showDoorsBaselineSetDialog.defaults = {
		title			: 'DOORS Baseline Sets',
		loading			: 'Loading settings, please wait ...',
		saving			: 'Associating project with selected DOORS Project/Folder ...',
		folderURL		: contextPath + '/ajax/doors/projectFolder.spr',
		importDialog	: $.fn.importDoorsBaselineSetsDialog.defaults,
	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 900,
		height			: 800
	};


})( jQuery );