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

	// A plugin that shows the JIRA project and issue types tree
	$.fn.chooseJiraIssues = function(trackerId, projects, connection, selected, config) {
		var settings = $.extend(true, {}, $.fn.chooseJiraIssues.defaults, config);

		function children(parent, nodes) {
			var result = [];

			if ($.isArray(nodes)) {
				for (var i = 0; i < nodes.length; ++i) {
					if ($.isPlainObject(nodes[i])) {
						if (parent) {
							nodes[i].project = parent;
							nodes[i].path    = parent.name + " - " + nodes[i].name;
						}

						var node = {
							id   : (parent && parent.id ? parent.id + "-" + nodes[i].id : nodes[i].id),
							text : nodes[i].name,
							data : nodes[i],
							type : (parent == null ? 'project' : nodes[i].type || 'issues'),
							state : {
							    opened : (parent != null)
							},
							li_attr : {
								title : nodes[i].description
							}
						};

						if (nodes[i].iconUrl) {
							node.icon = nodes[i].iconUrl;
						} else if (nodes[i].avatarUrls && nodes[i].avatarUrls["16x16"]) {
							//node.icon = nodes[i].avatarUrls["16x16"];
						}

						if (parent == null) {
							node.children = true;
						}

						result.push(node);
					}
				}
			}

			return result;
		}

		function expand(node, callback) {
			if (node.id === "#") {
				callback([{
					id    : "0",
					type  : "jira",
					text  : "Atlassian JIRA",
					state : {
					    opened : true
					},
					li_attr : {
						title : "Atlassian JIRA at " + connection.server
					},
					children : children(null, projects)
				}]);
			} else {
				var busy = ajaxBusyIndicator.showBusyPage(settings.issueTypes.loading);

	    	    $.ajax(config.issueTypes.url.replace('XXX', node.data.id), {
	    	    	type 	    : 'POST',
	    			contentType : 'application/json',
	    	    	dataType 	: 'json',
	    			data 		: JSON.stringify($.extend({}, connection, { tracker_id : trackerId })),
	    	    	cache	 	: false
	    	    }).done(function(issueTypes) {
	    			ajaxBusyIndicator.close(busy);
	    	    	callback(children(node.data, issueTypes));
	    		}).fail(function(jqXHR, textStatus, errorThrown) {
	    			ajaxBusyIndicator.close(busy);
	    			showAjaxError(jqXHR, textStatus, errorThrown);
	            });
			}
	    }

		function init(form) {
			form.jstree({
				plugins : ["types", "conditionalselect"],

				core : {
				    multiple  : false,
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
					return node.type == "issues" || node.type == "components" || node.type == "versions";
				}
			}).bind('ready.jstree', function() {
				if (selected && selected.id && selected.project && selected.project.id) {
					form.jstree("open_node", selected.project.id, function(opened) {
						form.jstree("select_node", selected.project.id + "-" + selected.id);
					}, false);
				}
			});
		}

		return this.each(function() {
			init($(this));
		});
	};


	$.fn.chooseJiraIssues.defaults = {
		issueTypes	: {
			url 	: contextPath + '/ajax/jira/project/XXX/issueTypes.spr',
			loading : 'Loading issue types, Please wait...'
		},
		typeDefs	: {
			jira : {
				icon : contextPath + "/images/jira/jira16.png"
			},
			project : {
				icon : contextPath + "/images/jira/project.png"
			},
			components : {
				icon : contextPath + "/images/jira/component.png"
			},
			versions : {
				icon : contextPath + "/images/jira/version.png"
			},
			issues : {
				icon : contextPath + "/images/jira/issue.png"
			}
		}
	};


	// Get the selected project and issue type from a JIRA issues selector
	$.fn.getJiraIssues = function() {
		var selected = $(this).jstree("get_selected", true);
		if ($.isArray(selected)) {
			for (var i = 0; i < selected.length; ++i) {
				if (selected[i].type == "issues" || selected[i].type == "components" || selected[i].type == "versions") {
					return selected[i].data;
				} else {
					showFancyAlertDialog("No JIRA issue type selected: " + JSON.stringify(selected[i].data));
				}
			}
		}

		return null;
	};


	// Show the selected JIRA project and issue type in a new browser tab
	$.fn.showJiraIssues = function(connection, issues, config) {
		if (issues && issues.project && issues.project.key && issues.id) {
			var settings = $.extend({}, $.fn.showJiraIssues.defaults, config);
			var url;

			if (issues.name == 'Versions') {
				url = settings.jiraVersionsURL;
			} else if (issues.name == 'Components') {
				url = settings.jiraComponentsURL;
			} else {
				url = settings.jiraIssuesURL;
			}

			window.open(connection.server + url.replace('XXX', issues.project.key).replace('YYY', issues.id), "_blank");
		}
	};


	$.fn.showJiraIssues.defaults = {
		jiraIssuesURL		: '/secure/IssueNavigator.jspa?reset=true&jqlQuery=project=XXX AND issuetype=YYY AND resolution=Unresolved&mode=hide',
		jiraVersionsURL		: '/browse/XXX/?selectedTab=com.atlassian.jira.jira-projects-plugin:versions-panel',
		jiraComponentsURL	: '/browse/XXX/?selectedTab=com.atlassian.jira.jira-projects-plugin:components-panel'
	};


	// A plugin to choose the JIRA issues to import into a specific tracker in a popup dialog
	$.fn.chooseJiraIssuesDialog = function(trackerId, connection, selected, config, callback) {
		var settings = $.extend(true, {}, $.fn.chooseJiraIssuesDialog.defaults, config);

		return this.chooseRemoteSource(trackerId, connection, selected, settings, {
			showHierarchy : function(popup, connection, projects, issues, settings) {
				popup.chooseJiraIssues(trackerId, projects, connection, issues, settings);
			},

			showPreview : function(popup, connection, issues, settings) {
				popup.showJiraIssues(connection, issues);
			},

			getSelected : function(popup, connection, settings) {
				var issues = popup.getJiraIssues();
				return $.isPlainObject(issues) && $.isPlainObject(issues.project) && issues.project.id && issues.id ? issues : null;
			},

			getValidation : function(connection, issues, settings) {
				return {
					url	   : settings.validation.url.replace('XXX', issues.project.id).replace('YYY', issues.id),
					params : { tracker_id : trackerId },
					error  : settings.validation.error.replace('XXX', issues.path)
				};
			},

			finished : function(connection, issues, settings) {
				callback(issues);
			}
		});
	};


	$.fn.chooseJiraIssuesDialog.defaults = $.extend({}, $.fn.chooseRemoteSource.defaults, {
		title		: 'Please select the JIRA project and issue type to import',

		hierarchy	: {
			url		: contextPath + '/ajax/jira/projectList.spr',
			loading	: 'Loading JIRA projects, Please wait...'
		},

		validation	: {
			url		: contextPath + '/ajax/jira/project/XXX/issueType/YYY/tracker.spr',
			error 	: 'The JIRA project and issue type "XXX" is already associated with tracker "YYY" in project "ZZZ"'
		}
	});


	// Plugin to edit JIRA import settings. The return value is the issues path input, in order to invoke it's change method.
	$.fn.editJiraSettings = function(trackerId, jiraSettings, options) {
		var settings = $.extend(true, {}, $.fn.editJiraSettings.defaults, options);
		var result   = null;

		if (!$.isPlainObject(jiraSettings)) {
			jiraSettings = {};
		}

		this.mapRemoteObjects(jiraSettings, settings, [{
			name    : 'issues',
			content : function(table, cell, callback) {
				var issuesLink = $('<a>', {
				   "class" : 'issues',
					href   : '#'
				}).click(function(event) {
					event.preventDefault();
					cell.showJiraIssues(table.getRemoteConnection(), jiraSettings.issues);
					return false;
				});

				function setIssues(issues) {
					if ($.isPlainObject(issues) && $.isPlainObject(issues.project) && issues.id) {
						jiraSettings.issues = issues;

						issuesLink.empty().append($('<img>', {
							src   : issues.iconUrl,
							style : 'margin-right: 4px;'
						})).append($('<span>', {
							title : issues.description
						}).text(issues.path));

						callback(table, $.extend({}, settings.schema, {
							url 	 : settings.schema.url.replace('XXX', issues.project.id).replace('YYY', issues.id).replace('ZZZ', issues.project.key),
							callback : function(metaData, checkboxes) {
								if ($.isPlainObject(metaData)) {
									issues.workflow = metaData.workflow;

									settings.teamLink = metaData.teamKey && (!jiraSettings.teamsKey || metaData.teamKey === jiraSettings.teamsKey);

									if ($.isPlainObject(checkboxes)) {
										var teams = checkboxes["teams"];
										if ($.isPlainObject(teams)) {
											if (settings.teamLink) {
												teams.checkbox.attr('disabled', false);
											} else {
												teams.checkbox.attr({
													title    : metaData.teamKey ? settings.teams.mismatch : settings.teams.none,
													disabled : true,
													checked  : false
												});
											}
										}
									}
								}
							}
						}));
					} else {
						delete jiraSettings.issues;

						issuesLink.empty().append($('<span>', {
						   "class" : 'subtext',
							style  : 'color: red;'
						}).text('-- ' + settings.issues.selector.title + ' --'));

						callback(table, null);
					}
				}

				cell.append(issuesLink);

				if (settings.editable) {
					cell.addClass('source').append($('<img>', {
					   "class" : 'inlineEdit',
						src    : contextPath + '/images/inlineEdit.png',
						title  : settings.issues.selector.title
					}).click(function(event) {
						event.preventDefault();

						table.chooseJiraIssuesDialog(trackerId, table.getRemoteConnection(), jiraSettings.issues, settings.issues.selector, setIssues);

						return false;
					}));
				}

				// If the server changes, force re-selecting the issues
				table.find('input[name="server"]').change(function() {
					setIssues(null);
				});

				result = function() {
					setIssues(jiraSettings.issues);
				};
			}
		}, {
			name 	: 'direction',
			content : ['import', 'export', 'synchronize'],
			depends : true,
			second  : {
				content : ['enabled']
			}
		}, {
			name 	: 'references',
			content	: ['users', 'groups', 'versions', 'components', 'teams', 'epics'],
			depends : true

		}, "attributes", "linkTypes", "interval"]);

		return result;
	};


	$.fn.editJiraSettings.defaults = $.extend(true, {}, $.fn.mapRemoteObjects.defaults, {
		issues			: {
			label		: 'Issues',
			title		: 'The JIRA project and issue type to import',
			selector	: $.fn.chooseJiraIssuesDialog.defaults,
		},

		schema			: {
			url			: contextPath + '/ajax/jira/project/XXX/issueType/YYY/schema.spr?key=ZZZ',
			loading		: 'Loading schema of the selected JIRA issue type, please wait...'
		},

		references		: {
			title		: 'How to handle specific JIRA issue references'
		},

		users			: {
			title		: 'Whether JIRA users referenced by issues, should be imported as CodeBeamer users, or should be simply referenced by name',
		},

		groups			: {
			title		: 'Whether JIRA groups referenced by issues, should be imported as CodeBeamer groups, or should be simply referenced by name',
		},

		versions		: {
			title		: 'Whether JIRA versions referenced by issues, should be imported as CodeBeamer Releases, or should be simply referenced by name',
		},

		components		: {
			title		: 'Whether JIRA components referenced by issues, should be imported as CodeBeamer Components, or should be simply referenced by name',
		},

		teams			: {
			label		: 'Teams',
			title		: 'Whether JIRA teams referenced by issues, should be imported as CodeBeamer Teams, or should be simply referenced by name',
			none		: 'There is no recognized JIRA Team field in this issue type',
			mismatch    : 'The values of the Team field of this JIRA issue type are not compatible with the Teams already imported into this project',
			attribs		: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 9, '150'); },
			rights		: 'teamLink'
		},

		epics			: {
			label		: 'Epics',
			title		: 'Whether Epic links should be imported as references to also imported Epics, or should be imported as simple JIRA Epic Keys',
			attribs		: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 9, '12'); },
			rights		: 'epicLink'
		},

		attributes		: $.extend({}, $.fn.mapRemoteAttributes.defaults, {
			label		: 'Fields',
			title		: 'The importable fields of the selected JIRA issue type',
			none		: 'Theres are no importable fields of the selected JIRA issue type',
			attributeId	: 'key',
			importOnly 	: ['created', 'creator', 'updated', 'updater', 'changelog'],
			cardinality : true,
			bidirect    : true
		}),

		linkTypes		: $.extend({}, $.fn.mapRemoteLinks.defaults, {
			label		: 'Links',
			title		: 'The importable links of the selected JIRA issue type',
			bidirect    : true
		}),

		options			: {
			title		: 'How to handle optional JIRA issue information'
		},

		worklog			: {
			label		: 'Worklog',
			title		: 'Whether to also import the issue worklog, or not',
			depends		: 'users'
		}
	});


	// Get the JIRA settings from an editor
	$.fn.getJiraSettings = function(settings, checkExport) {
		var result = this.getRemoteObjectMapping(settings, null, checkExport);

		delete result.epicLink;
		delete result.teamsKey;

		return result;
	};

	// Set the JIRA settings in an editor
	$.fn.setJiraSettings = function(mapping, settings) {
		this.setRemoteObjectMapping(mapping, settings, {
			direction : null,
			interval  : null,
			log		  : null
		});
	};

	// A plugin that shows a dialog where the user can enter an administrator login in order to access the JIRA workflow
	$.fn.syncJiraWorkflowAsAdmin = function(server, issues, config, callback) {
		var settings = $.extend(true, {}, $.fn.syncJiraWorkflowAsAdmin.defaults, config);

		var popup = $('#syncJiraWorkflowAdminPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'syncJiraWorkflowAdminPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
			$(document.documentElement).append(popup);
		} else {
			popup.empty();
		}

		var table = $('<table>', { "class" : 'formTableWithSpacing', style : 'width: 100%;' });
		popup.append(table);

		table.editRemoteConnection({server : server}, config);

		settings.buttons = [{
			text  : settings.submitText,
			click : function() {
				var login = popup.getRemoteConnection();
				var busy  = ajaxBusyIndicator.showBusyPage();

				$.ajax(settings.url.replace('XXX', issues.project.key).replace('YYY', issues.id), {
					type  		: 'POST',
					contentType : 'application/json',
			    	dataType 	: 'json',
					data  		: JSON.stringify(login),
					cache 		: false
			    }).done(function(result) {
					ajaxBusyIndicator.close(busy);

					popup.dialog("close");
					popup.remove();

					callback(login, result);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
		        });
			}
		}, {
			text  : settings.cancelText,
		   "class": "cancelButton",
			click : function() {
				popup.dialog("close");
				popup.remove();
			}
		}];

	    settings.close = function() {
  			popup.remove();
	    };

		popup.dialog(settings);
	};


	$.fn.syncJiraWorkflowAsAdmin.defaults = {
		label		: 'Sync as admin',
		title   	: 'Synchronize the workflow with a one-time administrator login',
		url			: contextPath + '/ajax/jira/project/XXX/issueType/YYY/workflow.spr',
	    submitText  : 'OK',
	    cancelText  : 'Cancel',
		dialogClass	: 'popup',
		position	: { my: "center", at: "center", of: window, collision: 'fit' },
		modal		: true,
		draggable	: true,
		closeOnEscape : true,
		width		: 720,
		height		: 200
	};


	// A plugin that shows a dialog where the user can manually upload a JIRA workflow file
	$.fn.syncJiraWorkflow = function(mapping, config, callback) {
		var settings = $.extend(true, {}, $.fn.syncJiraWorkflow.defaults, config);

		var popup = $('#syncJiraWorkflowPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'syncJiraWorkflowPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
			$(document.documentElement).append(popup);
		} else {
			popup.empty();
		}

		function done() {
			popup.dialog("close");
			popup.remove();
			callback(mapping);
		}

		function submitFile(event, file) {
			var busy = ajaxBusyIndicator.showBusyPage();

			file.submit().success(function(result) {
				ajaxBusyIndicator.close(busy);

				mapping.workflow = result;
				done();

	    	}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
				showAjaxError(jqXHR, textStatus, errorThrown);
	        });
		}

		var fileSelector = $('<input>', { type : 'file', name : 'file', style : 'position: fixed; top: -300px;' });
		popup.append(fileSelector);

		popup.append(settings.message.replace('XXX', mapping.username));

		var options = $('<ul>');
		options.append($('<li>').text(settings.changeUser.title).append('<br/><br/>'));
		options.append($('<li>').text(settings.syncAsAdmin.title).append('<br/><br/>'));
		options.append($('<li>').html(settings.syncFromFile.title.replace('XXX', settings.syncFromFile.page.replace('XXX', mapping.server).replace('YYY', mapping.issues.project.key)).replace('YYY', mapping.issues.name)).append('<br/>'));
		options.append($('<li>').html(settings.dontSync.title));
		popup.append(options);

		settings.buttons = [{
			text  : settings.changeUser.label,
			click : function() {
				popup.syncJiraWorkflowAsAdmin(mapping.server, mapping.issues, settings.syncAsAdmin, function(admin, workflow) {
					mapping.username = admin.username;
					mapping.password = admin.password;
					mapping.workflow = workflow;
					done();
				});
			}
		}, {
			text  : settings.syncAsAdmin.label,
			click : function() {
				popup.syncJiraWorkflowAsAdmin(mapping.server, mapping.issues, settings.syncAsAdmin, function(admin, workflow) {
					// Do not use the admin login for synchronization !
					mapping.workflow = workflow;
					done();
				});
			}
		}, {
			text  : settings.syncFromFile.label,
			click : function() {
				fileSelector.fileupload({
					url     		  : settings.syncFromFile.url,
					type    		  : 'POST',
			        dataType		  : 'json',
			        dropZone          : null,
			        autoUpload 		  : true,
			        replaceFileInput  : false,
			        singleFileUploads : true,
			        add				  : submitFile
			    });

				fileSelector.val('').click();
			}
		}, {
			text  : settings.dontSync.label,
			click : done
		}, {
			text  : settings.syncAsAdmin.cancelText,
		   "class": "cancelButton",
			click : function() {
				popup.dialog("close");
				popup.remove();
			}
		}];

	    settings.close = function() {
  			popup.remove();
	    };

		popup.dialog(settings);
	};


	$.fn.syncJiraWorkflow.defaults = {
		title		: 'JIRA workflow synchronization',
		message		: 'You have mapped the JIRA issue status to the CodeBeamer item status.<br/>This requires to also synchronize the issue workflow, ' +
			          'but the user XXX does not have JIRA administrator permission, that is required, in order to access the JIRA workflow definition.<br/><br/>' +
			          'Your available options are:',

		resolution	: {
			required: 'JIRA requires a "Resolution", if the "Status" is changed to resolved.\nSo you must also configure an appropriate "Resolution" export mapping'
		},

		changeUser	: {
			label	: 'Change the user',
			title   : 'Change the user for the JIRA synchronization to a JIRA administrator'
		},

		syncFromFile: {
			label	: 'Sync from file',
			title   : 'Synchronize the workflow based on an XML workflow definition file',
			url		: contextPath + '/ajax/jira/workflow.spr',
			page	: 'XXX/plugins/servlet/project-config/YYY/issuetypes'
		},

		syncAsAdmin	: $.fn.syncJiraWorkflowAsAdmin.defaults,

		dontSync	: {
			label	: 'Don\'t sync',
			title   : 'Do not synchronize the workflow'
		},

		dialogClass	: 'popup',
		position	: { my: "center", at: "center", of: window, collision: 'fit' },
		modal		: true,
		draggable	: true,
		closeOnEscape : true,
		width		: 960,
		height		: 420
	};


	// A plugin to edit the JIRA import settings of a specific tracker in a popup dialog
	$.fn.showJiraSettingsDialog = function(context, config, dialog, callback) {
		return this.showRemoteObjectMappingDialog(context, config, $.extend({
			title		: 'JIRA Settings',
			settingsURL	: contextPath + '/ajax/jira/settings.spr'
		}, dialog), {
			editMapping : function(popup, context, mapping, config) {
		    	return popup.editJiraSettings(context.tracker_id, mapping, config);
			},

			getMapping : function(popup, context, config) {
				var mapping = popup.getJiraSettings(config, true);
				if (mapping && mapping.issues) {
					if (mapping.issues.workflow) {
						mapping.workflow = mapping.issues.workflow;
					}
					return mapping;
				}

				showFancyAlertDialog(config.issues.selector.title);
				return null;
			},

			setMapping : function(popup, context, mapping, config) {
				popup.setJiraSettings(mapping, config);
			},

			getMappingFile : function(popup, context, config) {
				var mapping = popup.getJiraSettings(config, false);
				if (mapping && mapping.issues) {
					var path = mapping.issues.path.replace(' - ', '-');

					delete mapping.issues;
					delete mapping.workflow;

					return {
						name : 'Jira-' + path,
						data : mapping
					};
				}

				showFancyAlertDialog(config.issues.selector.title);
				return null;
			},

			saveMapping : function(popup, context, mapping, config, store) {
				var syncWorkflow = false;

				// If field values should (also) be exported
				if ($.isArray(mapping.fields) && (mapping.direction & 2) == 2) {
					function isExported(name) {
						for (var i = 0; i < mapping.fields.length; ++i) {
							var field = mapping.fields[i];
							if (field.key == name) {
								if ($.isPlainObject(field.target) && typeof field.target.sync === "number" ? (field.target.sync & 2) == 2 : field.target) {
									return field;
								}
								break;
							}
						}
						return null;
					}

					// If the JIRA status field (key=='status') is mapped bi-directionally
					var status = isExported('status');
					if (status) {
						// Then resolution must also be mapped bi-directionally
						var resolution = isExported('resolution');
						if (resolution) {
							// And if the JIRA status is mapped to the CodeBeamer Status (id==7), then the workflow (state transitions) must be synchronized as well
							syncWorkflow = ($.isPlainObject(status.target) ? status.target.id === 7 : status.target === 7);
						} else {
							showFancyAlertDialog(dialog.workflow.resolution.required);
							return;
						}
					}
				}

				if (syncWorkflow && !mapping.workflow) {
					popup.syncJiraWorkflow(mapping, dialog.workflow, store);
				} else {
					store(mapping);
				}
			},

			finished : function(context, mapping, config) {
	  			if ($.isFunction(callback)) {
	  				callback(mapping);
	  			}
			}
		});
	};


	// A plugin to show the JIRA import history of a specific tracker in a popup dialog
	$.fn.showJiraImportHistoryDialog = function(context, config, dialog, settings) {
		return this.showRemoteImportHistoryDialog(context, config, $.extend({
			title		: 'JIRA Import History',
			loading		: 'Loading JIRA Import History ...',
			historyURL	: contextPath + '/ajax/jira/synchronization/history.spr'
		}, dialog), settings ? function(popup, context) { popup.showJiraSettingsDialog(context, settings.config, settings.dialog); } : false);
	};


	// Plugin to edit JIRA import settings
	$.fn.importJiraIssues = function(jiraImport, options) {
		var settings = $.extend(true, {}, $.fn.importJiraIssues.defaults, options);

		var lastSync = 'lastSync';
		var lastDate = null;

		if ($.isPlainObject(jiraImport.lastImport)) {
			lastDate = jiraImport.lastImport.date;

			if (jiraImport.lastImport.direction == 2) {
				nextSync = 'lastExport';
			} else if (jiraImport.lastImport.direction == 1) {
				nextSync = 'lastImport';
			}
		}

		var nextSync = 'nextSync';
		var nextDate = null;

		if ($.isPlainObject(jiraImport.nextSync)) {
			nextDate = jiraImport.nextSync.date;

			if (jiraImport.nextSync.direction == 2) {
				nextSync = 'nextExport';
			} else if (jiraImport.nextSync.direction == 1) {
				nextSync = 'nextImport';
			}
		}

		return this.importRemoteObjects(jiraImport, settings, [{
			name 	: 'issues',
			content : function(table, cell) {
				cell.append($('<img>', {
					src   : jiraImport.issues.iconUrl,
					style : 'margin-right: 4px;'
				})).append($('<a>', {
					href  : '#',
					title : jiraImport.issues.description
				}).text(/*jiraImport.connection.server + */jiraImport.issues.path).click(function(event) {
					event.preventDefault();
					cell.showJiraIssues(jiraImport.connection, jiraImport.issues);
					return false;
				}));
			}
		}, {
			name 	: lastSync,
			content	: function(table, cell) {
				var histCfg = settings.history.config;
				if (histCfg.remoteLink) {
					histCfg = $.extend({}, histCfg, {
						remoteLink : histCfg.remoteLink.replace('XXX', jiraImport.connection.server)
					});
				}

				cell.showJiraImportHistoryDialog({tracker_id : jiraImport.tracker.id},
												 histCfg, settings.history.dialog,
												 jiraImport.admin ? settings.history.settings : false);
			}
		}, {
			name 	: nextSync,
			content	: function(table, cell) {
				cell.text(jiraImport.enabled ? (nextDate || settings[nextSync].none) : settings.nextSync.disabled);
			}
		}]);
	};


	$.fn.importJiraIssues.defaults = {
		issues		: {
			label	: 'Issues',
			title	: 'The JIRA project and issue type to import'
		},
		lastImport	: {
			label 	: 'Last Import',
			title 	: 'Date and time of the last import from JIRA'
		},
		nextImport	: {
			label	: 'Next Import',
			title	: 'Date and time of the next scheduled import from JIRA',
			none	: 'Not scheduled'
		},
		nextExport	: {
			label	: 'Next Export',
			title	: 'Date and time of the next scheduled export to JIRA',
			none	: 'Not scheduled'
		},
		nextSync	: {
			label 	: 'Next Synchronization',
			title 	: 'Date and time of the next scheduled synchronization with JIRA',
			none	: 'Not scheduled'
		}
	};


	// Plugin to get the JIRA import configuration
	$.fn.getJiraImport = function() {
		var result = this.getRemoteImport();
		delete result.issues;
		return result;
	};


	// A plugin to configure and execute a new import from JIRA for a specific tracker in a popup dialog
	$.fn.showJiraSyncDialog = function(trackerId, config, dialog) {
		return this.showRemoteImportDialog({tracker_id : trackerId}, config, $.extend(true, {}, $.fn.showJiraSyncDialog.defaults, dialog), {
			hasSettings : function(context, jiraImport) {
				return jiraImport.issues;
			},

			showSettings : function(popup, context, settingsConfig, settingsDialog) {
				var impDlg = this;

				return popup.showJiraSettingsDialog(context, settingsConfig, settingsDialog, function(mapping) {
					if (mapping) {
						popup.showJiraSyncDialog(trackerId, config, dialog);
					} else {
						impDlg.cancelImport(popup, context, config, dialog);
					}
				});
			},

			showImport : function(popup, context, jiraImport, config) {
				return popup.importJiraIssues(jiraImport, config);
			},

			getImport : function(popup, context, config) {
				return popup.getJiraImport();
			}
		});
	};

	$.fn.showJiraSyncDialog.defaults = $.extend({}, $.fn.showRemoteImportDialog.defaults, {
		importURL	: contextPath + '/ajax/jira/synchronization.spr',
		loading		: 'Loading synchronization information ...',
		synchronize : {
			title	: 'Synchronize with JIRA',
			running	: 'Synchronizing with Atlassian JIRA ...'
		},
		"import"	: {
			title	: 'Import from JIRA',
			running	: 'Importing from from Atlassian JIRA ...'
		},
		"export"	: {
			title	: 'Export to JIRA',
			running	: 'Exporting to Atlassian JIRA ...'
		},
		settings	: {
			none	: 'This tracker has not been configured for an Import from JIRA yet!',
			confirm	: 'No JIRA project and issue type have been associated with this tracker yet. Do you want to configure one now ?',
			config 	: $.fn.editJiraSettings.defaults,
			dialog	: $.fn.showJiraSettingsDialog.defaults
		}
	});


})( jQuery );

