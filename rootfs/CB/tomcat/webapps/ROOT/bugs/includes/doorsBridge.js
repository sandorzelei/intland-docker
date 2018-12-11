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

	// A plugin that shows a preview of the first x paragraphs of a formal DOORS module
	$.fn.showDoorsPreviewDialog = function(connection, module, config) {
		var settings = $.extend( {}, $.fn.showDoorsPreviewDialog.defaults, config);

		function showPreview(preview) {
			var popup = $('#DoorsPreviewPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'DoorsPreviewPopup', "class" : 'editorPopup', style : 'display: None; overflow: auto' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

	    	popup.html(preview);

		    settings.title = settings.title.replace('XXX', settings.length).replace('YYY', module.path);
		    settings.close = function() {
	  			popup.remove();
		    };

			popup.dialog(settings);
		}

		var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

		// We must make the call for the root nodes here, in order to handle missing connection infos properly
	    $.ajax(settings.previewURL, {
	    	type 	    : 'POST',
			contentType : 'application/json',
	    	dataType 	: 'html',
			data 		: JSON.stringify($.extend({}, connection, {
				module  : module.id,
				baseline: module.baseline || null,
				length  : settings.length
			})),
	    	cache	 	: false
	    }).done(function(preview) {
			ajaxBusyIndicator.close(busy);
			showPreview(preview);
		}).fail(function(jqXHR, textStatus, errorThrown) {
			ajaxBusyIndicator.close(busy);
			showAjaxError(jqXHR, textStatus, errorThrown);
        });
	};

	$.fn.showDoorsPreviewDialog.defaults = {
		previewURL		: contextPath + '/ajax/doors/preview.spr',
		label			: 'Preview...',
		tooltip			: 'Show a preview of the first 50 items in the selected DOORS module (without OLEs and pictures)',
		title			: 'Preview of first XXX items in YYY',
		loading			: 'Loading the preview can take several seconds. Please wait ...',
		length			: 50,
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 820,
		height			: 640,
	    resizable		: true
	};


	// A plugin that shows the DOORS project/folder/module hierarchy tree
	$.fn.doorsHierarchy = function(roots, connection, config) {
		var settings = $.extend(true, {}, $.fn.doorsHierarchy.defaults, config);

		function hierarchy(parent, nodes, nextLevel) {
			var result = [];

			if ($.isArray(nodes)) {
				if (nodes.length > 1) {
					nodes.sort(function(a, b) {
						var diff = (a.type === 3 ? 0 : 1) - (b.type === 3 ? 0 : 1);
						if (diff == 0) {
							diff = a.name.localeCompare(b.name);
						}
						return diff;
					});
				}

				for (var i = 0; i < nodes.length; ++i) {
					if ($.isPlainObject(nodes[i])) {
						if (!nodes[i].path) {
							nodes[i].path = (parent ? parent.path : "") + "/" + nodes[i].name;
						}

						var node = {
							id   : nodes[i].id,
							text : nodes[i].name,
							data : nodes[i],
							type : settings.hierarchy.nodeTypes[nodes[i].type],
							state : {
							    opened : (nodes[i].type == 3)
							},
							li_attr : {
								title : nodes[i].description
							}
						};

						if ($.isArray(nodes[i].children)) {
							node.children = hierarchy(nodes[i], nodes[i].children, false);
						} else if (nodes[i].type < 3) {
							node.children = nextLevel;
						}

						result.push(node);
					}
				}
			}

			return result;
		}

		function expand(node, callback) {
			var toplevel = (node.id === "#");
			if (toplevel && $.isArray(roots)) {
				callback([{
					id    : "0000000000000",
					type  : "doors",
					text  : "IBM Rational DOORS",
					state : {
					    opened : true
					},
					li_attr : {
						title : "IBM Rational DOORS via DOORS Bridge at " + connection.server
					},
					children : hierarchy(null, roots, true)
				}]);
			} else {
				var busy = ajaxBusyIndicator.showBusyPage(settings.hierarchy.loading);

	        	var query = $.extend( {}, connection, {
	        		node 		: toplevel ? null : node.id,
	        		recursively : settings.hierarchy.recursively,
	        		baselineSets: settings.hierarchy.baselineSets
	        	});

	    	    $.ajax(settings.hierarchy.url, {
	    	    	type 	    : 'POST',
	    			contentType : 'application/json',
	    	    	dataType 	: 'json',
	    			data 		: JSON.stringify(query),
	    	    	cache	 	: false
	    	    }).done(function(nodes) {
	    			ajaxBusyIndicator.close(busy);
	    	    	if (!toplevel) {
	    	    		node.data.children = nodes;
	    	    	}
	    	    	callback(hierarchy(toplevel ? null : node.data, nodes, !settings.hierarchy.recursively));
	    		}).fail(function(jqXHR, textStatus, errorThrown) {
	    			ajaxBusyIndicator.close(busy);
	    			showAjaxError(jqXHR, textStatus, errorThrown);
	            });
			}
	    }

		function showAndSelect(form, nodes, path, depth) {
			if ($.isArray(nodes) && depth < path.length) {
				var name = path[depth];
				var node = null;

				// Find the node with the current path name
				for (var i = 0; i < nodes.length; ++i) {
					if (nodes[i].name == name) {
						node = nodes[i];
						break;
					}
				}

				if (node && node.id) {
					if (depth < path.length - 1) {
						form.jstree("open_node", node.id, function(opened) {
							node = opened.data;
							showAndSelect(form, node.children, path, depth + 1);
						}, false);
					} else if (settings.hierarchy.baselineSets || node.type == 3) {
						form.jstree("select_node", node.id);
					}
				} else {
					showFancyAlertDialog("Child with name='" + name + "' not found");
				}
			}
		}

		function init(form, connection) {
			form.jstree({
				plugins : ["types", "conditionalselect"],

				core : {
				    multiple  : settings.multiple,
				    animation : 0,
				    data 	  : expand,
				    themes	  : {
				    	name : "default",
		                dots : true,
		                icons: true
		            }
				},

				types : settings.typeDefs,

				conditionalselect : function (node, event) {
					return $.isPlainObject(node.data) && (settings.hierarchy.baselineSets || node.type == "module");
				}
			}).bind('ready.jstree', function() {
				var path = connection.module || connection.folder;
				if (path && path.length > 0) {
					if (path.startsWith("/")) {
						path = path.substring(1);
					}

					showAndSelect(form, roots, path.split('/'), 0);
				}
			});
		}

		return this.each(function() {
			init($(this), connection);
		});
	};


	$.fn.doorsHierarchy.defaults = {
		multiple  : false,

		hierarchy : {
			url			: contextPath + '/ajax/doors/hierarchy.spr',
			loading     : 'Loading folder tree, Please wait...',
			nodeTypes 	: ["doors", "folder", "project", "module"],
			recursively : false,
			baselineSets: false
		},

		typeDefs : {
			doors : {
				icon : contextPath + "/images/doors/doors16.png"
			},
			folder : {
				icon : contextPath + "/images/doors/folder.png"
			},
			project : {
				icon : contextPath + "/images/doors/project.png"
			},
			module : {
				icon : contextPath + "/images/doors/module.png"
			}
		}
	};


	// Get the selected module from a module selector
	$.fn.getDoorsModule = function() {
		var selected = $(this).jstree("get_selected", true);
		if ($.isArray(selected)) {
			for (var i = 0; i < selected.length; ++i) {
				if (selected[i].type == "module") {
					return selected[i].data;
				} else {
					showFancyAlertDialog("Non module node selected: " + JSON.stringify(selected[i].data));
				}
			}
		}

		return null;
	};


	// A plugin to edit the DOORS import settings of a specific tracker in a popup dialog
	$.fn.chooseDoorsModuleDialog = function(trackerId, connection, config, callback) {
		var settings = $.extend(true, {}, $.fn.chooseDoorsModuleDialog.defaults, config);

		return this.chooseRemoteSource(trackerId, connection, connection.module, settings, {
			showHierarchy : function(popup, connection, nodes, module, settings) {
				popup.doorsHierarchy(nodes, connection, settings);
			},

			showPreview : function(popup, connection, module, settings) {
				popup.showDoorsPreviewDialog(connection, module, settings.preview);
			},

			getSelected : function(popup, connection, settings) {
				var module = popup.getDoorsModule();
				return $.isPlainObject(module) && module.id ? module : null;
			},

			getValidation : function(connection, module, settings) {
				return {
					url	   : settings.validation.url,
					params : { tracker_id : trackerId, moduleId : module.id },
					error  : settings.validation.error.replace('XXX', module.name)
				};
			},

			finished : function(connection, module, settings) {
				callback(module);
			}
		});
	};


	$.fn.chooseDoorsModuleDialog.defaults = $.extend({}, $.fn.chooseRemoteSource.defaults, {
		title		: 'Please select the DOORS module to import',

		hierarchy	: {
			url		: contextPath + '/ajax/doors/hierarchy.spr',
			loading : 'Loading folder tree, Please wait...',
		},

		validation	: {
			url		: contextPath + '/ajax/doors/mapping.spr',
			error 	: 'The DOORS module "XXX" is already associated with tracker "YYY" in project "ZZZ"',
		},

		preview 	: $.fn.showDoorsPreviewDialog.defaults
	});


	// Plugin to edit DOORS import settings. The return value is the module input, in order to invoke it's change method.
	$.fn.editDoorsSettings = function(trackerId, doorsSettings, options) {
		var settings = $.extend(true, {}, $.fn.editDoorsSettings.defaults, options );
		var result   = null;

		if (!$.isPlainObject(doorsSettings)) {
			doorsSettings = {};
		}

		if (doorsSettings.attachments === undefined) {
			doorsSettings.attachments = true;
		}

//		this.append($('<div>', { 'class': 'information' }).html(settings.informationMessage));

		this.mapRemoteObjects(doorsSettings, settings, [{
			name    : 'module',
			content : function(table, cell, callback) {
				var moduleLink = $('<a>', {
				   "class" : 'module',
					href   : '#'
				}).click(function(event) {
					event.preventDefault();
					cell.showDoorsPreviewDialog(table.getRemoteConnection(), doorsSettings.module, settings.module.selector.preview);
					return false;
				});

				function setModule(module) {
					if ($.isPlainObject(module) && module.id) {
						doorsSettings.module = module;

						moduleLink.empty().append($('<span>', {
							title : module.description
						}).text(module.path));

						callback(table, $.extend({}, settings.metaData, {
							params : {
								module : module.id
							}
						}));
					} else {
						delete doorsSettings.module;

						moduleLink.empty().append($('<span>', {
						   "class" : 'subtext',
							style  : 'color: red;'
						}).text('-- ' + settings.module.selector.title + ' --'));

						callback(table, null);
					}
				}

				cell.append(moduleLink);

				if (settings.editable) {
					cell.addClass('source').append($('<img>', {
					   "class" : 'inlineEdit',
						src    : contextPath + '/images/inlineEdit.png',
						title  : settings.module.selector.title
					}).click(function(event) {
						event.preventDefault();

						table.chooseDoorsModuleDialog(trackerId, $.extend(table.getRemoteConnection(), {
							module : $.isPlainObject(doorsSettings.module) ? doorsSettings.module.path : null
						}), settings.module.selector, setModule);

						return false;
					}));
				}

				// If the server changes, force re-selecting the module
				table.find('input[name="server"]').change(function() {
					setModule(null);
				});

				result = function() {
					setModule(doorsSettings.module);
				};
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

		return result;
	};


	$.fn.editDoorsSettings.defaults = $.extend(true, {}, $.fn.mapRemoteObjects.defaults, {
		server			: {
			title  		: 'The address (URL) of the codeBeamer DOORS Bridge server',
			test		: {
				label	: 'Test',
				title	: 'Test, if there is a DOORS Bridge Server, at the entered URL (web address)',
				success : 'Server test was successful',
				failed  : 'Server test failed: Did not find a DOORS Bridge Server, at the entered URL (web address) !',
				url		: contextPath + '/ajax/doors/bridge/test.spr'
			}
		},

		module			: {
			label		: 'Module',
			title		: 'The DOORS formal module to import',
			selector	: $.fn.chooseDoorsModuleDialog.defaults
		},

		"import"		: {
			label		: 'Import',
			title		: 'Options for the import from the selected DOORS Module'
		},

		reliable		: {
			label		: 'Reliable',
			title		: 'Whether the history of the selected DOORS module should be regarded as reliable or not'
		},

		metaData		: {
			url			: contextPath + '/ajax/doors/metaData.spr',
			loading		: 'Loading module meta data, please wait...',
		},

		users			: {
			label		: 'Users',
			title		: 'Whether DOORS users referenced by objects, should be imported as CodeBeamer users, or should be simply referenced by name'
		},

		attributes		: {
			label		: 'Attributes',
			title		: 'The importable attributes of the selected DOORS formal module',
			none		: 'There are no importable attributes of the selected DOORS formal module',
			attributeId	: 'name',
			importOnly 	: ['Created On', 'Created By', 'Last Modified On', 'Last Modified By', 'history'],
			cardinality : false
		},

		linkTypes		: {
			label		: 'Link Types',
			title		: 'The importable link types of the selected DOORS formal module',
			none		: 'There are no importable link types of the selected DOORS formal module'
		}
	});


	// Get the DOORS settings from an editor
	$.fn.getDoorsSettings = function(settings) {
		return this.getRemoteObjectMapping(settings, null, false);
	};

	// Set the DOORS settings in an editor
	$.fn.setDoorsSettings = function(mapping, settings) {
		this.setRemoteObjectMapping(mapping, settings, {
			interval  : null,
			log		  : null
		});
	};


	// A plugin to edit the DOORS import settings of a specific tracker in a popup dialog
	$.fn.showDoorsSettingsDialog = function(context, config, dialog, callback, preset) {
		return this.showRemoteObjectMappingDialog(context, config, $.extend({
			title		: 'DOORS Bridge Settings',
			settingsURL	: contextPath + '/ajax/doors/settings.spr'
		}, dialog), {

			// Create mapping editor and return the import source jQuery control, because we need to invoke it's change handler
			editMapping : function(popup, context, mapping, config) {
				if ($.isPlainObject(preset) && $.isPlainObject(preset.module) && preset.module.id) {
					mapping.server   = preset.server;
					mapping.username = preset.username;
					mapping.password = preset.password;
					mapping.module   = preset.module;
				}
		    	return popup.editDoorsSettings(context.tracker_id, mapping, config);
			},

			getMapping : function(popup, context, config) {
				var mapping = popup.getDoorsSettings(config);
				if (mapping && mapping.module && mapping.module.id) {
					return mapping;
				}

				showFancyAlertDialog(config.module.selector.title);
				return null;
			},

			setMapping : function(popup, context, mapping, config) {
				popup.setDoorsSettings(mapping, config);
			},

			getMappingFile : function(popup, context, config) {
				var mapping = popup.getDoorsSettings(config);
				if (mapping && mapping.module) {
					var path = mapping.module.path.split('/');

					delete mapping.module;

					return {
						name : 'DOORS-' + path[path.length - 1],
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


	// A plugin to show the DOORS import history of a specific tracker in a popup dialog
	$.fn.showDoorsImportHistoryDialog = function(context, config, dialog, settings) {
		return this.showRemoteImportHistoryDialog(context, config, $.extend({
			title			: 'DOORS Import History',
			loading			: 'Loading DOORS Import History ...',
			historyURL 		: contextPath + '/ajax/doors/import/history.spr',
			baselineLabel	: 'Baseline'
		}, dialog), settings ? function(popup, context) { popup.showDoorsSettingsDialog(context, settings.config, settings.dialog);	} : false);
	};


	// Plugin to edit DOORS import settings
	$.fn.doorsImport = function(doorsImport, options) {
		var settings = $.extend(true, {}, $.fn.doorsImport.defaults, options);

		var importHead = true;
		var baselines = doorsImport.module.baselines;
		if ($.isArray(baselines) && baselines.length > 0) {
			baselines.push({
				id 			: 'HEAD',
				name		: settings.baseline.head.label,
				description : settings.baseline.head.title,
				createdAt	: settings.baseline.createdAt.now,
			   "Created By"	: settings.baseline.createdBy.system
			});

			importHead = false;
		}

		return this.importRemoteObjects(doorsImport, settings, [{
			name 	: 'module',
			content : function(table, cell) {
				cell.append($('<a>', {
					href  : '#',
					title : doorsImport.module.description
				}).text(/*doorsImport.connection.server + */doorsImport.module.path).click(function(event) {
					event.preventDefault();
					cell.showDoorsPreviewDialog(doorsImport.connection, doorsImport.module, settings.module.preview);
					return false;
				}));
			}
		}, {
			name 	: 'lastModified',
			content	: doorsImport.module.lastModifiedAt + ', ' + doorsImport.module["Last Modified By"]
		}, {
			name	: 'lastImport',
			content	: function(table, cell) {
				cell.showDoorsImportHistoryDialog({ tracker_id : doorsImport.tracker.id },
												   settings.history.config, settings.history.dialog,
												   doorsImport.admin ? settings.history.settings : false);
			}
		}, {
			name	: 'nextImport',
			content	: function(table, cell) {
				var nextDate = $.isPlainObject(doorsImport.nextSync) ? doorsImport.nextSync.date : null;
				cell.text(doorsImport.enabled ? (nextDate || settings.nextImport.none) : settings.nextImport.disabled);
			}
		}, {
			name	: importHead ? 'baseline' : 'baselines',
			content	: importHead ? settings.baseline.head.label : function(table, cell) {
				var baselineTable = $('<table>', { "class" : 'displaytag baselines', style : 'margin: 0px; width: 100%; border: 1px solid silver; display: block; max-height : 480px; overflow-y : auto;' });
				cell.append(baselineTable);

				var header = $('<thead>');
				baselineTable.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var toggle = $('<input>', { type : 'checkbox', name : 'toggle', value : 'true', checked : true });
				headline.append($('<th>', { "class" : 'checkbox-column-minwidth', title : settings.baseline.toggleAll }).append(toggle));
				headline.append($('<th>', { "class" : 'textData', title : settings.baseline.title   		}).text(settings.baseline.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.baseline.createdAt.title }).text(settings.baseline.createdAt.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.baseline.createdBy.title }).text(settings.baseline.createdBy.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.baseline.status.title    }).text(settings.baseline.status.label));

				tbody = $('<tbody>');
				baselineTable.append(tbody);

				for (var i = 0; i < baselines.length; ++i) {
					var baseline = baselines[i];

					var row = $('<tr>', { "class" : 'even baseline', title : baseline.description, style : 'vertical-align: middle;' }).data('baseline', baseline);
					tbody.append(row);

					var selector = $('<input>', { type : 'checkbox', name : 'selector', value : baseline.id, checked : true });
					row.append($('<td>', { "class" : 'selector checkbox-column-minwidth', title : settings.baseline.toggleThis }).append(selector));
					row.append($('<td>', { "class" : 'textData' }).text(baseline.id));
					row.append($('<td>', { "class" : 'textData' }).text(baseline.createdAt));
					row.append($('<td>', { "class" : 'textData' }).text(baseline["Created By"]));
					row.append($('<td>', { "class" : 'status importable', title : settings.baseline.status.importable.title }));
				}

				toggle.change(function() {
					var checked = toggle.is(':checked');

					$('input[type="checkbox"][name="selector"]:enabled', tbody).attr('checked', checked);
				});
			}
		}]);
	};


	$.fn.doorsImport.defaults = $.extend(true, {}, $.fn.importRemoteObjects.defaults, {
		module		: {
			label	: 'Module',
			title	: 'The DOORS formal module to import',
			preview	: $.fn.showDoorsPreviewDialog.defaults
		},

		baselines 	: {
			multiple	: true,
			label 		: 'Baselines',
			title 		: 'The importable baselines of the selected DOORS formal module',
			toggleAll	: '(De-)Select all baselines',
			style		: 'vertical-align: top;'
		},

		baseline 	: {
			label 	: 'Baseline',
			title 	: 'A baseline of the selected DOORS formal module',

			toggleThis 	: '(De-)Select this baseline',

			createdAt	: {
				label	: 'Created at',
				title	: 'The date and time of baseline creation',
				now     : 'Now'
			},

			createdBy	: {
				label	: 'Created by',
				title	: 'The name of the DOORS user, that created this baseline',
				system  : 'System'
			},

			status		: {
				label	: 'Status',
				title	: 'The import status of this baseline',

				importable	: {
					label	: 'Importable',
					title	: 'This baseline can be imported'
				},

				imported	: {
					label	: 'Imported',
					title	: 'This baseline was already imported'
				},

				failed		: {
					label	: 'Failed',
					title	: 'Importing this baseline failed'
				},

				skipped		: {
					label	: 'Skipped',
					title	: 'This baseline was skipped'
				}
			},

			none  	: {
				label : 'None',
				title : 'Do not import a baseline, but the head revision'
			},
			last  	: {
				label : 'Last',
				title : 'Import the most recent baseline'
			},
			head    : {
				label : 'Current (head) revision',
				title : 'The current (head) revision of the module'
			},
			mirror	: {
				label : 'Mirroring',
				title : 'Also create an appropriate CodeBeamer baseline, that mirrors the imported DOORS baseline'
			}
		},
		lastModified : {
			label 	: 'Last Modification',
			title 	: 'Date, time and user, that made the last modification of the DOORS module',
		},
		lastImport	: {
			label 	: 'Last Import',
			title 	: 'Date, time and baseline of the last import from the associated DOORS module',
		},
		nextImport	: {
			label 	: 'Next Import',
			title 	: 'Date and time of the next scheduled import from the associated DOORS module',
			none	: 'Not scheduled'
		}
	});


	// Plugin to get the DOORS import configuration
	$.fn.getDoorsImport = function() {
		return this.getRemoteImport({
			baselines : function(table) {
				var baselineTable = $('table.baselines', table);
				if (baselineTable.length > 0) {
					var baselines = [];
					var skipped   = [];

					baselineTable.find('tr.baseline').has('td.status.importable, td.status.failed').each(function() {
						var row = $(this);

						var baseline = {
							selector : row.find('input[type="checkbox"][name="selector"]'),
							status	 : row.find('td.status'),
							data 	 : row.data('baseline')
						};

						if (baseline.selector.is(':checked')) {
							baseline.skipped = skipped;
							baselines.push(baseline);

							skipped = [];
						} else {
							skipped.push(baseline);
						}
					});

					return baselines;
				}

				return null;
			},

			mirroring : function(table) {
				var checkbox = $('input[name="mirroring"]', table);
				return checkbox.length == 0 || checkbox.is(':checked');
			}
		});
	};


	// A plugin to edit the DOORS import settings of a specific tracker in a popup dialog
	$.fn.showDoorsImportDialog = function(trackerId, config, dialog) {
		var settings = $.extend(true, {}, $.fn.showDoorsImportDialog.defaults, dialog);

		function showBaselineImportStatistics(module, baseline, statistics) {
			var popup = $('#BaselineImportStatisticsPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'BaselineImportStatisticsPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			popup.remoteImportStatistics(statistics, settings.statistics.config);

			popup.dialog($.extend({}, settings.statistics.dialog, {
				title : settings.statistics.dialog.title.replace('XXX', baseline.id).replace('YYY', module.path),
				close : function() {
		  			popup.remove();
			    }
			}));
		}

		function addImportStatisticsLink(module, baseline, statistics) {
			baseline.status.parent().find('td:nth-child(2)').empty().append($('<a>', {
				href  : '#',
				title : settings.statistics.hint
			}).text(baseline.data.id).click(function(event) {
				event.preventDefault();
				showBaselineImportStatistics(module, baseline.data, statistics);
				return false;
			}));
		}

		function importBaseline(extension, doorsImport, baseline, callback) {
			$.ajax(dialog.importURL + '?tracker_id=' + trackerId, {
		    	type 	 	: 'POST',
				contentType : 'application/json',
		    	data 	 	: JSON.stringify({
		    		direction : 1,
		    		baseline  : baseline.data.id === 'HEAD' ? null : baseline.data.id,
		    		mirroring : true,
		    		newerThan : doorsImport.newerThan || null
		    	}),
		    	dataType 	: 'json',
		    	cache	 	: false,
		    	beforeSend  : function() {
		    		if ($.isArray(baseline.skipped)) {
		    			for (var i = 0; i < baseline.skipped.length; ++i) {
				    		baseline.skipped[i].selector.attr('disabled', true);
				    		baseline.skipped[i].status.attr({
				    			"class" : 'status skipped',
				    			 title  : config.baseline.status.skipped.title
				    		});
		    			}
		    		}

		    		baseline.status.attr("class", 'status running');
		    	}
		    }).done(function(result) {
				baseline.status.attr({
					"class" : 'status imported',
					 title  : config.baseline.status.imported.title
				});

		    	baseline.selector.attr({
		    		checked  : false,
		    		disabled : true
		    	});

		    	addImportStatisticsLink(doorsImport.module, baseline, result);

		    	// Important: Set newerThan for next module import to the baseline date !
		    	doorsImport.newerThan = baseline.data["Created On"];

		    	extension.reload = true;

				var nextBaseline = $.isArray(doorsImport.baselines) ? doorsImport.baselines.shift() : null;
				if ($.isPlainObject(nextBaseline)) {
			    	// If the import has not been cancelled
			    	if (extension.running) {
			    		importBaseline(extension, doorsImport, nextBaseline, callback);
			    	}
				} else {
					callback(true);
				}
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		if ($.isArray(baseline.skipped)) {
	    			for (var i = 0; i < baseline.skipped.length; ++i) {
			    		baseline.skipped[i].selector.attr('disabled', false);
			    		baseline.skipped[i].status.attr({
			    			"class" : 'status importable',
			    			 title  : config.baseline.status.importable.title
			    		});
	    			}
	    		}

				baseline.status.attr({
					"class" : 'status failed',
					 title  : config.baseline.status.failed.title
				});

	    		try {
	    			baseline.exception = $.parseJSON(jqXHR.responseText);

	    			baseline.status.click(function() {
			    		showFancyAlertDialog(baseline.exception.message);
		    		}).click();
	    		} catch(err) {
	    			showAjaxError(jqXHR, textStatus, errorThrown);
	    		}

	    		callback(false);
	        });
		}

		return this.showRemoteImportDialog({tracker_id : trackerId}, config, settings, {
			hasSettings : function(context, doorsImport) {
				return doorsImport.module;
			},

			showSettings : function(popup, context, settingsConfig, settingsDialog) {
				var impDlg = this;

				return popup.showDoorsSettingsDialog(context, settingsConfig, settingsDialog, function(mapping) {
					if (mapping) {
						popup.showDoorsImportDialog(trackerId, config, dialog);
					} else {
						impDlg.cancelImport(popup, context, config, dialog);
					}
				});
			},

			showImport : function(popup, context, doorsImport, config) {
				return popup.doorsImport(doorsImport, config);
			},

			getImport : function(popup, context, config) {
				return popup.getDoorsImport();
			},

			getSubject : function(context, doorsImport, config, dialog) {
				return dialog.running.replace('XXX', config.baseline.head.label);
			},

			doImport : function(popup, context, doorsImport, config) {
				var baselines = doorsImport.baselines;
				if ($.isArray(baselines)) {
					var baseline = baselines.shift();
					if ($.isPlainObject(baseline)) {
				 		var buttons = popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button.submitButton');
				 		buttons.button("disable");

				 		var extension = this;
				 		extension.running = true;

						importBaseline(extension, doorsImport, baseline, function(done) {
							extension.running = false;
							buttons.button("enable");

							if (done) {
								showFancyAlertDialog(settings.importSuccess, 'information');
							}
						});
					} else {
						this.cancelImport(popup, context, config);
					}

					return false;
				}

				delete doorsImport.module;
				delete doorsImport.baselines;

				return true;
			},

			cancelImport : function(popup, context, config, dialog) {
				if (this.running) {
			 		var extension = this;

					showFancyConfirmDialogWithCallbacks(dialog.confirmCancel, function() {
						extension.running = false;

						popup.dialog('widget').find('.ui-dialog-buttonpane .ui-button.submitButton').button("enable");;

						// Not closing here, the user has to click Cancel or Close again
					});
				} else {
					popup.dialog("close");
					popup.remove();

					if (this.reload) {
						window.location.reload();
					}
				}
			}
		});
	};

	$.fn.showDoorsImportDialog.defaults = $.extend({}, $.fn.showRemoteImportDialog.defaults, {
		title			: 'Import from DOORS',
		loading			: 'Loading information about the DOORS Module to import ...',
		running			: 'Importing XXX from IBM Rational DOORS ...',
		importURL		: contextPath + '/ajax/doors/import.spr',
		importSuccess   : 'All selected module baselines were imported successfully. To see the import statistics of a baseline, click on that baseline.',
		confirmCancel	: 'Do you really want to cancel the running import ?',
		width			: 900,

		settings		: {
			none		: 'This tracker has not been configured for an Import from DOORS yet!',
			confirm		: 'No DOORS formal module has been associated with this tracker yet. Do you want to configure one now ?',
			config 		: $.fn.editDoorsSettings.defaults,
			dialog		: $.fn.showDoorsSettingsDialog.defaults
		},

		statistics		: {
			hint		: 'Click here, to show statistics about the import of this baseline',
			config		: $.fn.remoteImportStatistics.defaults,
			dialog		: {
				title			: 'Import of Baseline XXX of Module YYY',
				dialogClass		: 'popup',
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				draggable		: true,
				closeOnEscape	: true,
				width			: 480
			}
		}
	});

})( jQuery );

