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

	// ReferenceFieldConfiguation Editor Plugin
	$.fn.editReferenceFieldConfiguation = function(refType, configuration, options) {
		var settings = $.extend( {}, $.fn.editReferenceFieldConfiguation.defaults, options );
		settings.filterConfiguration.nameLabel = settings.itemFilterLabel;
		// TASK-1490314
		var firstTrackerItemFilterLabel = i18n.message("issue.flags.Any status.label");
		if (settings.trackerItemFilters && settings.trackerItemFilters.length > 0 && settings.trackerItemFilters[0].name === firstTrackerItemFilterLabel) {
			settings.trackerItemFilters[0].name = i18n.message("issue.references.all.label");
		}

		function getSetting(name) {
			return settings[name];
		}

		function addPermission(permissionList, morePermissions, value, label, title) {
			var permission = $('<li>', {"class": 'permission'});
			permission.append($('<input>', {type: 'hidden', name: 'permission', value: value }));
			permission.append($('<label>', {title: title}).text(label));

			$('li.permission', permissionList).each(function() {
				var existing = $(this);
				if (permission != null && label.localeCompare($('label', existing).text()) <= 0) {
					permission.insertBefore(existing);
					addRemoverButtons("ul.permissions > li.permission", removePermission);
					permission = null;
					return false;
				}
			});

			if (permission != null) {
				permission.insertBefore(morePermissions);
				addRemoverButtons("ul.permissions > li.permission", removePermission);
			}
		}

		function getPermissionSelector(permissionList, morePermissions, permissions, selected) {
			var selector = $('<select>', { "class" : 'permissionSelector' });

			selector.append($('<option>', { value : '0', style : 'color: gray; font-style: italic;' }).text(selected != null && selected.length > 0 ? settings.prjPermsMore : settings.prjPermsAny));

			for (var i = 0; i < permissions.length; ++i) {
				var isSelected = false;
				if (selected != null && selected.length > 0) {
					for (var j = 0; j < selected.length; ++j) {
						if (selected[j].id == permissions[i].id) {
							isSelected = true;
							break;
						}
					}
				}

				if (!isSelected) {
					selector.append($('<option>', { value : permissions[i].id, title : permissions[i].title }).text(permissions[i].name));
				}
			}

			selector.change(function() {
				var value = this.value;
				if (value != '0') {
					var option = $('option:selected', this);
					addPermission(permissionList, morePermissions, value, option.text(), option.attr('title'));

					// Remove the permission from the selector
					var options = this.options;
					for (var j = 0; j < options.length; ++j) {
						if (options[j].value == value) {
							this.remove(j);
							break;
						}
					}

					options[0].text = getSetting('prjPermsMore');
					options[0].selected = true;
				}
			});

			return selector;
		}

		function addProjects(selector, selected, section) {
			var projects = $.fn.editReferenceFieldConfiguation.projects;
			var count = 0;
		    for (var i = 0; i < projects.length; ++i) {
		    	var show = true;

		    	if (selected != null) {
		    		for (var j = 0; j < selected.length; ++j) {
		    			if (selected[j].id == projects[i].id) {
		    				show = false;
		    				break;
		    			}
		    		}
		    	}

		    	if (show) {
				     selector.append($('<option>', {value: projects[i].id}).text(projects[i].name));
				     count++;
		    	}
		    }

		    if (section != null && count == 0) {
		    	section.hide();
		    }
		}

		function getProjectSelector(selected, section, moreLabel) {
			var selector = $('<select>', { "class" : 'projectSelector' });
		    selector.append($('<option>', {value: '0', style: 'color: gray; font-style: italic;'}).text(typeof(selected) === 'undefined' || selected.length == 0 ? settings.projectsNone : moreLabel));

		    if ($.fn.editReferenceFieldConfiguation.projects == null) {
		        $.get(getSetting("projectsUrl")).done(function(data) {
		        	$.fn.editReferenceFieldConfiguation.projects = data;
		        	addProjects(selector, selected, section);
		    	}).fail(function(jqXHR, textStatus, errorThrown) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		        });
			} else {
	        	addProjects(selector, selected, section);
			}
			return selector;
		}

		function getFilterSelector(tracker, filter) {
			var selector = $('<select>', { name : 'filter', "class" : tracker == null ? 'flagsSelector' : 'filterSelector', title : settings.itemFilterTitle });

			for (var i = 0; i < settings.trackerItemFilters.length; ++i) {
			    selector.append($('<option>', {value: settings.trackerItemFilters[i].id, selected : (settings.trackerItemFilters[i].id == filter) }).text(settings.trackerItemFilters[i].name));
			}

			if (tracker != null) {
				selector.data("tracker", tracker);

		        $.get(getSetting("trackerFiltersUrl"), {
		        	tracker_id : tracker.id,
		        	options    : 'IgnoreDeletedFlag'
		        }).done(function(filters) {
		    		for (var i = 0; i < filters.length; ++i) {
						selector.append($('<option>', { value : filters[i].id, title : filters[i].description, selected : (filters[i].id == filter) }).text(filters[i].name));
		    		}
		    		selector.change();
		    	}).fail(function(jqXHR, textStatus, errorThrown) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		        });

		        selector.change(function() {
		        	var id = $(this).val();
					var $manageFilterContainer = $(this).next(".manageFilterContainer");
					if ($manageFilterContainer.length > 0) {
						if (id > 0) {
							$manageFilterContainer.find(".edit").show().attr("data-id", id);
							$manageFilterContainer.find(".delete").show().attr("data-id", id);
						} else {
							$manageFilterContainer.find(".edit").hide();
							$manageFilterContainer.find(".delete").hide();
						}
					}
				});

			}

			return selector;
		}

		function getManageFilterContainer($selector, trackerId) {
			var $cont = $("<span>", { "class" : "manageFilterContainer"});
			var $new = $("<a>", { "href" : "#", "class" : "new", "title" : i18n.message("tracker.reference.filter.add.tooltip")}).text(i18n.message("button.add"));
			var $edit = $("<a>", { "href" : "#", "class" : "edit", "title" : i18n.message("tracker.reference.filter.edit.tooltip")}).text(i18n.message("button.edit"));
			var $delete = $("<a>", { "href" : "#", "class" : "delete", "title" : i18n.message("tracker.reference.filter.delete.tooltip")}).text(i18n.message("button.delete"));
			$cont.append($new).append($edit).append($delete);
			var referrer = encodeURIComponent("window.opener:" + "/proj/tracker/configuration.spr?tracker_id=" + UrlUtils.getParameter("tracker_id") + "&orgDitchnetTabPaneId=tracker-customize-field-properties");
			$new.click(function() {
                showTrackerFilter($selector, null, function(view) {
                    if (view && view.id > 0) {
                        $selector.append( $('<option>', { value : view.id, title : view.description, selected : true }).text(view.name));
                    }
                    $selector.change();
                });
                return false;
			});
			$edit.click(function() {
                var filter = parseInt($selector.val());
                if (filter > 0) {
                    showTrackerFilter($selector, filter, function(view) {
                        if (view && view.name != null) {
                            $('option:selected', $selector).text(view.name).attr('title', view.description);
                        }
                        $selector.change();
                    });
                }
                return false;
			});
			$delete.click(function() {
				var id = $(this).attr("data-id");
				showFancyConfirmDialogWithCallbacks(i18n.message("tracker.reference.filter.confirm.delete"), function() {
					$.ajax(contextPath + "/trackers/ajax/view.spr?tracker_id=" + trackerId + "&view_id=" + id, {
						method: "DELETE"
					}).success(function() {
						$selector.find('option[value="' + id + '"]').remove();
						$selector.val(0);
						$selector.change();
					}).fail(function(jqXHR) {
						if (jqXHR && jqXHR.hasOwnProperty("responseJSON") && jqXHR.responseJSON.hasOwnProperty("message")) {
							showFancyAlertDialog(jqXHR.responseJSON.message);
						} else {
							showFancyAlertDialog(i18n.message("tracker.reference.filter.delete.error"));
						}
					});
				});
				return false;
			});
			return $cont;
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

		function showProjectMembersConfig(project, config) {
			if (typeof config === 'undefined' || config == null) {
				config = { roles: [], permissions: [] };
			}
			var members = $('<ul>');

			var roles = $('<li>');
			roles.append($('<label>', { title : settings.memberRolesTitle }).text(settings.memberRolesLabel + ':'));

			var roleList = $('<ul>', { "class" : 'projectQualifiers projectRoles' });
			roles.append(roleList);

			var hasRoles = false;
			if (config.hasOwnProperty('roles') && config.roles.length > 0) {
				for (var i = 0; i < config.roles.length; ++i) {
					if (config.roles[i].hasOwnProperty('selected') && config.roles[i].selected) {
						var role = $('<li>', { "class" : 'projectQualifier projectRole' });
						role.append($('<input>', { type : 'hidden', name : 'qualifier', value : config.roles[i].id }));
						role.append($('<label>', { title : config.roles[i].description }).text(config.roles[i].name));
						roleList.append(role);
						hasRoles = true;
					}
				}
			}

			if (settings.editable) {
				var moreRoles = $('<li>' , { "class" : 'moreProjectRoles' });
				roleList.append(moreRoles);

				var roleSelector = $('<select>', { "class" : 'projectQualifierSelector projectRoleSelector' });
				moreRoles.append(roleSelector);

				roleSelector.append($('<option>', { value : '0', style : 'color: gray; font-style: italic;' }).text(hasRoles ? settings.userGroupsMore : settings.userGroupsAny));

				if (config.hasOwnProperty('roles') && config.roles.length > 0) {
					for (var i = 0; i < config.roles.length; ++i) {
						if (!(config.roles[i].hasOwnProperty('selected') && config.roles[i].selected)) {
							roleSelector.append($('<option>', { value : config.roles[i].id.toString(), title : config.roles[i].description }).text(config.roles[i].name));
						}
					}

					roleSelector.change(function() {
						var value = this.value;
						if (value != '0') {
							var options = this.options;
							var option  = $('option:selected', this);
							var role    = $('<li>', { "class": 'projectQualifier projectRole' });

							role.append($('<input>', { type: 'hidden', name: 'qualifier', value: value }));
							role.append($('<label>', { title : option.attr('title') }).text(option.text()));

							// Remove the role from the selector
							for (var j = 0; j < options.length; ++j) {
								if (options[j].value == value) {
									this.remove(j);
									break;
								}
							}

							role.insertBefore(moreRoles);
							addRemoverButtons("ul.projectQualifiers > li.projectQualifier", removeProjectQualifier);

							options[0].text = getSetting('userGroupsMore');
							options[0].selected = true;
						}
					});
				}
			} else if (!hasRoles) {
				roleList.append($('<li>').text(settings.userGroupsAny));
			}

			var permissions = $('<li>', { style : 'margin-top: 10px;' });
			permissions.append($('<label>', {title : settings.memberPermsTitle }).text(settings.memberPermsLabel + ':'));

			var permissionList = $('<ul>', { "class" : 'permissions' });
			permissions.append(permissionList);

			if (config.hasOwnProperty('permissions') && config.permissions.length > 0) {
				for (var i = 0; i < config.permissions.length; ++i) {
					var permission = $('<li>', { "class" : 'permission' });
					permission.append($('<input>', { type : 'hidden', name : 'permission', value : config.permissions[i].id }));
					permission.append($('<label>', { title : config.permissions[i].title }).text(config.permissions[i].name));
					permissionList.append(permission);
				}
			} else if (!settings.editable) {
				permissionList.append($('<li>').text(settings.userPermsAny));
			}

			if (settings.editable) {
				var morePermissions = $('<li>');
				permissionList.append(morePermissions);

				var permissionSelector = getPermissionSelector(permissionList, morePermissions, settings.projectPermissions, config.permissions);
				morePermissions.append(permissionSelector);
			}

			members.append(roles);
			members.append(permissions);
			project.append(members);
		}

		function showUserReferenceConfig(popup, config) {
			if (typeof config === 'undefined' || config == null) {
				config = { groups: [], permissions: [], projects: [] };
			}

			var userConfig = $('<ul>');

			var groups = $('<li>');
			groups.append($('<label>', { title : settings.userGroupsTitle }).text(settings.userGroupsLabel + ':'));

			var groupList = $('<ul>', { "class" : 'projectQualifiers userGroups' });
			groups.append(groupList);

			var hasGroups = false;
			if (config.hasOwnProperty('groups') && config.groups.length > 0) {
				hasGroups = true;

				for (var i = 0; i < config.groups.length; ++i) {
					var group = $('<li>', { "class" : 'projectQualifier userGroup' });
					group.append($('<input>', { type : 'hidden', name : 'qualifier', value : config.groups[i].id }));
					group.append($('<label>', { title : config.groups[i].title }).text(config.groups[i].name));
					groupList.append(group);
				}
			} else if (!settings.editable) {
				groupList.append($('<li>').text(settings.userGroupsAny));
			}

			if (settings.editable) {
				var moreGroups = $('<li>');
				groupList.append(moreGroups);

				var groupSelector = $('<select>', { "class" : 'projectQualifierSelector userGroupSelector' });
				moreGroups.append(groupSelector);

				groupSelector.append($('<option>', { value : '0', style : 'color: gray; font-style: italic;' }).text(hasGroups ? settings.userGroupsMore : settings.userGroupsAny));

				for (var i = 0; i < settings.userGroups.length; ++i) {
					var selected = false;
					if (config.hasOwnProperty('groups') && config.groups.length > 0) {
						for (var j = 0; j < config.groups.length; ++j) {
							if (config.groups[j].id == settings.userGroups[i].id) {
								selected = true;
								break;
							}
						}
					}

					if (!selected) {
						groupSelector.append($('<option>', { value : settings.userGroups[i].id.toString(), title : settings.userGroups[i].title }).text(settings.userGroups[i].name));
					}
				}

				groupSelector.change(function() {
					var value = this.value;
					if (value != '0') {
						var options = this.options;
						var option  = $('option:selected', this);
						var group   = $('<li>', { "class": 'projectQualifier userGroup' });

						group.append($('<input>', { type: 'hidden', name: 'qualifier', value: value }));
						group.append($('<label>', { title: option.attr('title') } ).text(option.text()));

						// Remove the group from the selector
						for (var j = 0; j < options.length; ++j) {
							if (options[j].value == value) {
								this.remove(j);
								break;
							}
						}

						group.insertBefore(moreGroups);
						addRemoverButtons("ul.projectQualifiers > li.projectQualifier", removeProjectQualifier);

						options[0].text = getSetting('userGroupsMore');
						options[0].selected = true;
					}
				});
			}

			var permissions = $('<li>', { style : 'margin-top: 10px;' });
			permissions.append($('<label>', {title : settings.userPermsTitle }).text(settings.userPermsLabel + ':'));

			var permissionList = $('<ul>', { "class" : 'permissions' });
			permissions.append(permissionList);

			if (config.hasOwnProperty('permissions') && config.permissions.length > 0) {
				for (var i = 0; i < config.permissions.length; ++i) {
					var permission = $('<li>', { "class" : 'permission' });
					permission.append($('<input>', { type : 'hidden', name : 'permission', value : config.permissions[i].id }));
					permission.append($('<label>', { title : config.permissions[i].title }).text(config.permissions[i].name));
					permissionList.append(permission);
				}
			} else if (!settings.editable) {
				permissionList.append($('<li>').text(settings.userPermsAny));
			}

			if (settings.editable) {
				var morePermissions = $('<li>');
				permissionList.append(morePermissions);

				var permissionSelector = getPermissionSelector(permissionList, morePermissions, settings.userPermissions, config.permissions);
				morePermissions.append(permissionSelector);
			}

			var projects = $('<li>', { style : 'margin-top: 10px;' });
			projects.append($('<label>', {title : settings.projectMembersTitle }).text(settings.projectMembersLabel + ':'));

			var projectList = $('<ul>', { "class" : 'projects' });
			projects.append(projectList);

			if (config.hasOwnProperty('projects') && config.projects.length > 0) {
				for (var i = 0; i < config.projects.length; ++i) {
					var project = $('<li>', { "class" : 'project' });
					project.append($('<input>', { type : 'hidden', name : 'project', value : config.projects[i].id }));
					project.append(settings.inProjectLabel + ' ');
					project.append($('<label>').text(config.projects[i].name));

					showProjectMembersConfig(project, config.projects[i]);

					projectList.append(project);
				}
			} else if (!settings.editable) {
				projectList.append($('<li>').text(settings.projectMembersNone));
			}

			if (settings.editable) {
				var moreProjects = $('<li>', { "class": 'moreProjects' });
				projectList.append(moreProjects);

				var projectSelector = getProjectSelector(config.projects, moreProjects, settings.moreTrackerProj);
				moreProjects.append(projectSelector);

				projectSelector.change(function() {
					var value = this.value;
					if (value != '0') {
						var text     = $('option:selected', this).text();
						var project = $('<li>', {"class": 'project'});
						project.append($('<input>', {type: 'hidden', name: 'project', value: value }));
						project.append(settings.inProjectLabel + ' ');
						project.append($('<label>').text(text));
						project.insertBefore(moreProjects);
						addRemoverButtons("ul.projects > li.project", removeProject);

						$.get(getSetting('projectRolesUrl'), { "proj_id" : value }, function(roles) {
							showProjectMembersConfig(project, { roles : roles, permissions: [] });
			        	}).fail(function(jqXHR, textStatus, errorThrown) {
			        		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
						});

						// Remove the project from the selector
						var options = this.options;
						for (var j = 0; j < options.length; ++j) {
							if (options[j].value == value) {
								this.remove(j);
								break;
							}
						}

						options[0].text = getSetting('moreTrackerProj');

						// Hide selector if all projects were chosen
						if (options.length > 1) {
							options[0].selected = true;
						} else {
							moreProjects.hide();
						}
					}
				});
			}


			userConfig.append(groups);
			userConfig.append(permissions);
			userConfig.append(projects);
			popup.append(userConfig);
		}

		function showProjectReferenceConfig(popup, config) {
			if (typeof config === 'undefined' || config == null) {
				config = { qualifiers: [], permissions: [], projects: [] };
			}

			var projConfig = $('<ul>');

			var qualifiers = $('<li>');
			qualifiers.append($('<label>', { title : settings.prjQlfrsTitle }).text(settings.prjQlfrsLabel + ':'));

			var qualifierList = $('<ul>', { "class" : 'projectQualifiers' });
			qualifiers.append(qualifierList);

			var hasQualifiers = false;
			if (config.hasOwnProperty('qualifiers') && config.qualifiers.length > 0) {
				hasQualifiers = true;

				for (var i = 0; i < config.qualifiers.length; ++i) {
					var qualifier = $('<li>', { "class" : 'projectQualifier' });
					qualifier.append($('<input>', { type : 'hidden', name : 'qualifier', value : config.qualifiers[i].value }));
					qualifier.append($('<label>').text(config.qualifiers[i].label));
					qualifierList.append(qualifier);
				}
			} else if (!settings.editable) {
				qualifierList.append($('<li>').text(settings.prjQlfrsAny));
			}

			if (settings.editable) {
				var moreQualifiers = $('<li>');
				qualifierList.append(moreQualifiers);

				var qualifierSelector = $('<select>', { "class" : 'projectQualifierSelector' });
				moreQualifiers.append(qualifierSelector);

				qualifierSelector.append($('<option>', { value : '', style : 'color: gray; font-style: italic;' }).text(hasQualifiers ? settings.prjQlfrsMore : settings.prjQlfrsAny));
				for (var i = 0; i < settings.projectCategories.length; ++i) {
					var selected = false;
					if (config.hasOwnProperty('qualifiers') && config.qualifiers.length > 0) {
						for (var j = 0; j < config.qualifiers.length; ++j) {
							if (config.qualifiers[j].value == settings.projectCategories[i].value) {
								selected = true;
								break;
							}
						}
					}

					if (!selected) {
						qualifierSelector.append($('<option>', { value : settings.projectCategories[i].value }).text(settings.projectCategories[i].label));
					}
				}

				qualifierSelector.change(function() {
					var value = this.value;
					if (value != '') {
						var options  = this.options;
						var text     = $('option:selected', this).text();
						var category = $('<li>', {"class": 'projectQualifier'});

						if (value == 'Other') {
							category.append($('<input>', {type: 'text', name: 'qualifier', size: '20', maxlength: '80'}));
						} else {
							category.append($('<input>', {type: 'hidden', name: 'qualifier', value: value }));
							category.append($('<label>').text(text));

							// Remove the category from the selector
							for (var j = 0; j < options.length; ++j) {
								if (options[j].value == value) {
									this.remove(j);
									break;
								}
							}
						}

						category.insertBefore(moreQualifiers);
						addRemoverButtons("ul.projectQualifiers > li.projectQualifier", removeProjectQualifier);

						options[0].text = getSetting('prjQlfrsMore');
						options[0].selected = true;
					}
				});
			}

			var permissions = $('<li>', { style : 'margin-top: 10px;' });
			permissions.append($('<label>', {title : settings.prjPermsTitle }).text(settings.prjPermsLabel + ':'));

			var permissionList = $('<ul>', { "class" : 'permissions' });
			permissions.append(permissionList);

			if (config.hasOwnProperty('permissions') && config.permissions.length > 0) {
				for (var i = 0; i < config.permissions.length; ++i) {
					var permission = $('<li>', { "class" : 'permission' });
					permission.append($('<input>', { type : 'hidden', name : 'permission', value : config.permissions[i].id }));
					permission.append($('<label>', { title : config.permissions[i].title }).text(config.permissions[i].name));
					permissionList.append(permission);
				}
			} else if (!settings.editable) {
				permissionList.append($('<li>').text(settings.prjPermsAny));
			}

			if (settings.editable) {
				var morePermissions = $('<li>');
				permissionList.append(morePermissions);

				var permissionSelector = getPermissionSelector(permissionList, morePermissions, settings.projectPermissions, config.permissions);
				morePermissions.append(permissionSelector);
			}

			var projects = $('<li>', { style : 'margin-top: 10px;' });
			projects.append($('<label>', {title : settings.projectsTitle }).text(settings.projectsLabel + ':'));

			var projectList = $('<ul>', { "class" : 'projects' });
			projects.append(projectList);

			if (config.hasOwnProperty('projects') && config.projects.length > 0) {
				for (var i = 0; i < config.projects.length; ++i) {
					var project = $('<li>', { "class" : 'project' });
					project.append($('<input>', { type : 'hidden', name : 'project', value : config.projects[i].id }));
					project.append($('<label>').text(config.projects[i].name));
					projectList.append(project);
				}
			} else if (!settings.editable) {
				projectList.append($('<li>').text(settings.projectsNone));
			}

			if (settings.editable) {
				var moreProjects = $('<li>');
				projectList.append(moreProjects);

				var projectSelector = getProjectSelector(config.projects, moreProjects, settings.projectsMore);
				moreProjects.append(projectSelector);

				projectSelector.change(function() {
					var value = this.value;
					if (value != '0') {
						var text     = $('option:selected', this).text();
						var project = $('<li>', {"class": 'project'});
						project.append($('<input>', {type: 'hidden', name: 'project', value: value }));
						project.append($('<label>').text(text));

						// Remove the project from the selector
						var options = this.options;
						for (var j = 0; j < options.length; ++j) {
							if (options[j].value == value) {
								this.remove(j);
								break;
							}
						}

						project.insertBefore(moreProjects);
						addRemoverButtons("ul.projects > li.project", removeProject);

						options[0].text = getSetting('projectsMore');

						// Hide selector if all projects were chosen
						if (options.length > 1) {
							options[0].selected = true;
						} else {
							moreProjects.hide();
						}
					}
				});
			}

			projConfig.append(qualifiers);
			projConfig.append(permissions);
			projConfig.append(projects);
			popup.append(projConfig);
		}

		function showAllProjectTrackerItems(projConfig, optType, filter) {
			var allConfig = $('ul.allTrackerItems', projConfig);
			if (allConfig.length == 0) {
			    allConfig = $('<ul>', { "class" : 'allTrackerItems' });

			    var allLabel = (optType == 18 ? settings.allReposLabel : (optType == 9 ? settings.allItemsLabel : settings.allTrackersLabel));
			    var allTitle = (optType == 18 ? settings.allReposTitle : (optType == 9 ? settings.allItemsTitle : settings.allTrackersTitle));
			    var allItems = $('<li>', { "class" : 'component allItems' });
			    allItems.append($('<label>', {title : allTitle }).text(allLabel));

			    if (optType == 9) {
			    	var filterSelector = getFilterSelector(null, filter);

			    	if (settings.editable) {
			    		allItems.append(' ' + settings.withStatusLabel + ": ").append(filterSelector);
			    	} else {
			    		var selected = filterSelector.find("option[value=" + filter + "]").html();
			    		allItems.append(' ' + settings.withStatusLabel + ": ").append(selected);
			    	}
			    }

			    allItems.append(allConfig);
			    projConfig.prepend(allItems);
			}
			return allConfig;
		}

		function addProjectTrackerType(typeList, moreTypes, value, label) {
			var type = $('<li>', {"class": 'trackerType'});
			type.append($('<input>', {type: 'hidden', name: 'type', value: value }));
			type.append($('<label>').text(label));

			$('li.trackerType', typeList).each(function() {
				var existing = $(this);
				if (type != null && label.localeCompare($('label', existing).text()) <= 0) {
					type.insertBefore(existing);
					type = null;
					return false;
				}
			});

			if (type != null) {
				type.insertBefore(moreTypes);
			}

			addRemoverButtons("ul.trackerTypes > li.trackerType", removeTrackerType);
		}

		function showProjectTrackerTypes(projConfig, optType, filter, types, evenIfEmpty) {
			var typeList = $('ul.allTrackerItems ul.trackerTypes', projConfig);

			if ($.isArray(types) && (types.length > 0 || evenIfEmpty)) {
				if (typeList.length == 0) {
					typeList = $('<ul>', { "class" : 'trackerTypes' });

					var allConfig  = showAllProjectTrackerItems(projConfig, optType, filter);
					var typesLabel = (optType == 18 ? settings.repoOfTypeLabel : (optType == 9 ? settings.itemOfTypeLabel : settings.trkrOfTypeLabel));
				    var typesTitle = (optType == 18 ? settings.repoOfTypeTitle : (optType == 9 ? settings.itemOfTypeTitle : settings.trkrOfTypeTitle));
					var typeConfig = $('<li>', { "class" : 'component allOfType' });

					typeConfig.append($('<label>', {title : typesTitle }).text(typesLabel));
					typeConfig.append(typeList);
					allConfig.prepend(typeConfig);

					for (var i = 0; i < types.length; ++i) {
						var type = $('<li>', { "class" : 'trackerType' });
						type.append($('<input>', { type : 'hidden', name : 'type', value : types[i].id }));
						type.append($('<label>').text(types[i].name));
						typeList.append(type);
					}

					if (settings.editable) {
						var typeDefs  = (optType == 18 ? settings.repositoryTypes : settings.trackerTypes);
						var moreTypes = $('<li>', { "class" : 'moreTrackerTypes' });
						typeList.append(moreTypes);

						var typeSelector = $('<select>', { "class" : 'trackerTypeSelector' });
						moreTypes.append(typeSelector);

						typeSelector.append($('<option>', { value : '0', style : 'color: gray; font-style: italic;' }).text(types.length > 0 ? settings.moreOfTypeLabel : settings.noneOfTypeLabel));

						for (var i = 0; i < typeDefs.length; ++i) {
							var selected = false;
							for (var j = 0; j < types.length; ++j) {
								if (types[j].id == typeDefs[i].id) {
									selected = true;
									break;
								}
							}

							if (!selected) {
								typeSelector.append($('<option>', { value : typeDefs[i].id }).text(typeDefs[i].name));
							}
						}

						typeSelector.change(function() {
							var value = this.value;
							if (value != '0') {
								addProjectTrackerType(typeList, moreTypes, value, $('option:selected', this).text());

								// Remove the type from the selector
								var options = this.options;
								for (var j = 0; j < options.length; ++j) {
									if (options[j].value == value) {
										this.remove(j);
										break;
									}
								}

								options[0].text = settings.moreOfTypeLabel;
								options[0].selected = true;
							}
						});

					}
				} else if (types.length > 0 && settings.editable) {
					var moreTypes = $('li.moreTrackerTypes', typeList);

					for (var i = 0; i < types.length; ++i) {
						addProjectTrackerType(typeList, moreTypes, types[i].id, types[i].name);
					}
				}
			}

			return typeList.length > 0 ?  typeList[0] : null;
		}

		function showProjectTrackerPermissions(projConfig, optType, filter, permissions, evenIfEmpty) {
			var permissionList = $('ul.allTrackerItems ul.permissions', projConfig);

			if ($.isArray(permissions) && (permissions.length > 0 || evenIfEmpty)) {
				if (permissionList.length == 0) {
					permissionList = $('<ul>', { "class" : 'permissions' });

					var allConfig   = showAllProjectTrackerItems(projConfig, optType, filter);
				    var permsTitle  = (optType == 18 ? settings.repoPermsTitle : (optType == 9 ? settings.itemPermsTitle : settings.trkrPermsTitle));
					var permsConfig = $('<li>', { "class" : 'component allWithPermission', style : 'margin-top: 10px;' });

					permsConfig.append($('<label>', {title : permsTitle }).text(settings.prjPermsLabel + ':'));
					permsConfig.append(permissionList);
					allConfig.append(permsConfig);

					for (var i = 0; i < permissions.length; ++i) {
						var permission = $('<li>', { "class" : 'permission' });
						permission.append($('<input>', { type : 'hidden', name : 'permission', value : permissions[i].id }));
						permission.append($('<label>', { title : permissions[i].title }).text(permissions[i].name));
						permissionList.append(permission);
					}

					if (settings.editable) {
						var morePermissions = $('<li>', { "class" : 'morePermissions'});
						permissionList.append(morePermissions);

						var permissionSelector = getPermissionSelector(permissionList, morePermissions, optType == 18 ? settings.basicRepositoryPermissions : settings.trackerPermissions, permissions);
						morePermissions.append(permissionSelector);
					}
				} else if (permissions.length > 0 && settings.editable) {
					var morePermissions = $('li.morePermissions', permissionList);

					for (var i = 0; i < permissions.length; ++i) {
						addPermission(permissionList, morePermissions, permissions[i].id, permissions[i].name, permissions[i].title);
					}
				}
			}

			return permissionList.length > 0 ?  permissionList[0] : null;
		}

		function addProjectTracker(folderList, moreTrackers, folderName, value, label, title, optType) {
			var folder   = null;
			var before   = moreTrackers;
			var trackers = null;
			label = $.trim(label);

			$('li.folder', folderList).each(function() {
				var existing = $(this);
				var offset = folderName.localeCompare($('label:first', existing).text());
				if (folder == null && offset <= 0) {
					if (offset == 0) {
						folder = existing;
					} else {
						before = existing;
					}
					return false;
				}
			});

			if (folder == null) {
				folder = $('<li>', { "class" : 'folder' });
				folder.append(settings.inFolderLabel + ' ');
				folder.append($('<label>').text(folderName));
				folder.insertBefore(before);
				addRemoverButtons("ul.folders > li.folder", removeFolder);

				trackers = $('<ul>', { "class" : 'trackers' });
				folder.append(trackers);
			} else {
				trackers = $('ul.trackers', folder);
			}

			var tracker = $('<li>', { "class" : 'tracker' });
			tracker.append($('<input>', { type : 'hidden', name : 'tracker', value : value }));
			tracker.append($('<label>', { title : title }).text(label));

			if (optType == 9) {
				var filterSelector = getFilterSelector({ id : value, name : label, title : title}, 0);

				if (settings.editable) {
					tracker.append(': ').append(filterSelector);
					tracker.append(getManageFilterContainer(filterSelector, value));
					filterSelector.change();
				} else {
					var selected = filterSelector.find("option[value=0]").html();
					tracker.append(': ').append(selected);
				}
			}

			$('li.tracker', trackers).each(function() {
				var existing = $(this);
				if (tracker != null && label.localeCompare($('label', existing).text()) <= 0) {
					tracker.insertBefore(existing);
					addRemoverButtons("ul.trackers > li.tracker", removeTracker);
					tracker = null;
					return false;
				}
			});

			if (tracker != null) {
				trackers.append(tracker);
				addRemoverButtons("ul.trackers > li.tracker", removeTracker);
			}
		}

		function showProjectTrackers(projConfig, moreComponents, optType, folders, evenIfEmpty) {
			var folderList = $('ul.folders', projConfig);

			if ($.isArray(folders) && (folders.length > 0 || evenIfEmpty)) {
				if (folderList.length == 0) {
					folderList = $('<ul>', { "class" : 'folders' });

					var explicitlyLabel  = (optType == 18 ? settings.reposExplctLabel : (optType == 9 ? settings.itemsExplctLabel : settings.trkrsExplctLabel));
				    var explicitlyTitle  = (optType == 18 ? settings.reposExplctTitle : (optType == 9 ? settings.itemsExplctTitle : settings.trkrsExplctTitle));
					var explicitlyConfig = $('<li>', { "class" : 'component explicitly', style : 'margin-top: 10px;' });

					explicitlyConfig.append($('<label>', {title : explicitlyTitle }).text(explicitlyLabel));
				    explicitlyConfig.append(folderList);

				    if (moreComponents != null) {
				    	explicitlyConfig.insertBefore(moreComponents);
				    } else {
					    projConfig.append(explicitlyConfig);
				    }

					var selectedTrackers = 0;

					for (var i = 0; i < folders.length; ++i) {
						var trackers = folders[i].trackers;
						if ($.isArray(trackers) && trackers.length > 0) {
							var trackerList = $('<ul>', { "class" : 'trackers' });
							var selectedTrackersInFolder = 0;

							for (var j = 0; j < trackers.length; ++j) {
								if (trackers[j].selected) {
									var tracker = $('<li>', { "class" : 'tracker' });
									tracker.append($('<input>', { type : 'hidden', name : 'tracker', value : trackers[j].id }));
									tracker.append($('<label>', { title : trackers[j].title }).text(trackers[j].name));

									if (optType == 9) {
										if (settings.editable) {
											var filterSelector = getFilterSelector(trackers[j], trackers[j].filter.id);
											tracker.append(': ').append(filterSelector);
											tracker.append(getManageFilterContainer(filterSelector, trackers[j].id));
											filterSelector.change();
										} else if (trackers[j].filter != null) {
											tracker.append(': ' + trackers[j].filter.name);
										}
									}

									trackerList.append(tracker);
									selectedTrackersInFolder++;
								}
							}

							if (selectedTrackersInFolder > 0) {
								var folder = $('<li>', { "class" : 'folder' });
								folder.append(settings.inFolderLabel + ' ');
								folder.append($('<label>').text(folders[i].path));
								folder.append(trackerList);
								folderList.append(folder);

								selectedTrackers += selectedTrackersInFolder;
							}
						}
					}

					if (settings.editable) {
					    var noneTrackersLabel = (optType == 18 ? settings.reposExplctNone : settings.trkrsExplctNone);
					    var moreTrackersLabel = (optType == 18 ? settings.reposExplctMore : settings.trkrsExplctMore);

						var moreTrackers = $('<li>', { "class" : 'moreTrackers', style : 'margin-top: 10px;' });
						folderList.append(moreTrackers);

						var trackerSelector = $('<select>', { "class" : 'trackerSelector', "data-none" : noneTrackersLabel });
						moreTrackers.append(trackerSelector);

						trackerSelector.append($('<option>', { value : '0', style : 'color: gray; font-style: italic;' }).text(selectedTrackers > 0 ? moreTrackersLabel : noneTrackersLabel));

						var findTracker = function(trackerList, id) {
							for (var i = 0; i < trackerList.length; i++) {
								if (trackerList[i].id == id) {
									return trackerList[i];
								}
							}
							return null;
						};

						for (var i = 0; i < folders.length; ++i) {
							var trackers = folders[i].trackers;
							if ($.isArray(trackers) && trackers.length > 0) {
								var trackerGroup = $('<optGroup>', { label : folders[i].path });

								for (var j = 0; j < trackers.length; ++j) {
									var tracker = trackers[j];
									if (tracker.hasOwnProperty("isBranch") && tracker.isBranch) {
										continue;
									}
									var $option = $('<option>', { value : tracker.id, title : tracker.title }).text(tracker.name);
									trackerGroup.append($option);
									if (tracker.selected) {
										$option.prop("disabled", true);
									}
									if (tracker.hasOwnProperty("branchList")) {
										for (var k = 0; k < tracker.branchList.length; k++) {
											var branchTracker = findTracker(trackers, tracker.branchList[k].id);
											if (branchTracker != null) {
												var $option = $('<option>', { value : branchTracker.id, title : branchTracker.title, "class": "branchTracker" });
												var name = "";
												for (var n = 0; n < (tracker.branchList[k].level * 5); n++) {
													name += "&nbsp;";
												}
												name += branchTracker.name;
												trackerGroup.append($option.html(name));
												if (branchTracker.selected) {
													$option.prop("disabled", true);
												}
											}
										}
									}
								}

								trackerSelector.append(trackerGroup);
							}
						}

						trackerSelector.change(function() {
							var value = this.value;
							if (value != '0') {
								var option = $('option:selected', this);
								var folder = option.closest('optGroup');

								addProjectTracker(folderList, moreTrackers, folder.attr('label'), value, option.text(), option.attr('title'), optType);
								option.prop("disabled", true);

								if ($('option', folder).length == 0) {
									folder.hide();
								}

								if ($('option', trackerSelector).length == 0) {
									moreTrackers.hide();
								}

								this.options[0].text = moreTrackersLabel;
								this.options[0].selected = true;
							}
						});
					}
				} else if (folders.length > 0 && settings.editable) {
					var moreTrackers = $('li.moreTrackers', folderList);

					for (var i = 0; i < folders.length; ++i) {
						var trackers = folders[i].trackers;
						if ($.isArray(trackers) && trackers.length > 0) {
							for (var j = 0; j < trackers.length; ++j) {
								if (trackers[j].selected) {
									addProjectTracker(folderList, moreTrackers, folders[i].path, trackers[j].id, trackers[j].name, trackers[j].title, optType);
								}
							}
						}
					}
				}
			}

			return folderList.length > 0 ?  folderList[0] : null;
		}

		function showProjectTrackerConfig(project, optType, config) {
			if (config == null || typeof config === 'undefined') {
				config = { flags: null, types: [], permissions: [], explicitly : [] };
			}

			var filter = 0;
			if (config.flags) {
				filter = config.flags.id;
			}

			var projConfig = $('<ul>', { "class" : 'components'});

			var allOfType          = showProjectTrackerTypes(projConfig, optType, filter, config.types, false);
			var allWithPermission  = showProjectTrackerPermissions(projConfig, optType, filter, config.permissions, false);
			var trackersExplicitly = showProjectTrackers(projConfig, null, optType, config.explicitly, false);

			if (settings.editable) {
				var components     = $('li.component', projConfig);
				var noComponents   = (optType == 18 ? settings.noReposLabel : (optType == 9 ? settings.noItemsLabel : settings.noTrackersLabel));
				var moreComponents = $('<li>', { "class" : 'moreComponents', style : 'margin-top: 10px;' });
				projConfig.append(moreComponents);

				var componentSelector = $('<select>', { "class" : 'componentSelector' });
				moreComponents.append(componentSelector);

				componentSelector.append($('<option>', { value : '', style : 'color: gray; font-style: italic;' }).text(components.length > 0 ? settings.moreOfTypeLabel : noComponents));

			    var allLabel = (optType == 18 ? settings.allReposLabel : (optType == 9 ? settings.allItemsLabel : settings.allTrackersLabel));
			    var allTitle = (optType == 18 ? settings.allReposTitle : (optType == 9 ? settings.allItemsTitle : settings.allTrackersTitle));
			    var allItems = $('<optgroup>', { label : allLabel, title : allTitle });
			    componentSelector.append(allItems);

				var allOfTypeLabel  = (optType == 18 ? settings.repoOfTypeLabel : (optType == 9 ? settings.itemOfTypeLabel : settings.trkrOfTypeLabel));
			    var allOfTypeTitle  = (optType == 18 ? settings.repoOfTypeTitle : (optType == 9 ? settings.itemOfTypeTitle : settings.trkrOfTypeTitle));
				var allOfTypeOption = $('<option>', { value : 'allOfType', title : allOfTypeTitle }).text(allOfTypeLabel);
			    allItems.append(allOfTypeOption);

			    var allWithPermissionTitle  = (optType == 18 ? settings.repoPermsTitle : (optType == 9 ? settings.itemPermsTitle : settings.trkrPermsTitle));
				var allWithPermissionOption = $('<option>', { value : 'allWithPermission',  title : allWithPermissionTitle }).text(settings.prjPermsLabel);
			    allItems.append(allWithPermissionOption);

				var explicitlyLabel  = (optType == 18 ? settings.reposExplctLabel : (optType == 9 ? settings.itemsExplctLabel : settings.trkrsExplctLabel));
			    var explicitlyTitle  = (optType == 18 ? settings.reposExplctTitle : (optType == 9 ? settings.itemsExplctTitle : settings.trkrsExplctTitle));
			    var explicitlyOption = $('<option>', { value : 'explicitly', title : explicitlyTitle }).text(explicitlyLabel);
			    componentSelector.append(explicitlyOption);

			    var componentSelection = { allOfType : true, allWithPermission : true, explicitly : true };

				if (allOfType != null) {
					allOfTypeOption.hide();
					componentSelection.allOfType = false;
				}

			    if (allWithPermission != null) {
			    	allWithPermissionOption.hide();
					componentSelection.allWithPermission = false;
			    }

				if (trackersExplicitly != null) {
					explicitlyOption.hide();
					componentSelection.explicitly = false;
				}

				if (allOfType != null && allWithPermission != null) {
					allItems.hide();
					if (trackersExplicitly != null) {
						moreComponents.hide();
					}
				}

				var selector = componentSelector[0];
				selector.allItems = allItems;
				selector.allOfType = allOfTypeOption;
				selector.allWithPermission = allWithPermissionOption;
				selector.explicitly = explicitlyOption;
				selector.componentSelection = componentSelection;
				selector.noComponents = noComponents;

				componentSelector.change(function() {
					var value = this.value;
					var that = this;

					var addRemovers = function() {
						addRemoverButtons($(that).closest("ul.components").find("li.component"), removeComponent);
					};

					if (value != '') {
						switch (value) {
						case 'allOfType':
							showProjectTrackerTypes(projConfig, optType, filter, [], true);
							allOfTypeOption.hide();
							componentSelection.allOfType = false;
							break;
						case 'allWithPermission':
							showProjectTrackerPermissions(projConfig, optType, filter, [], true);
					    	allWithPermissionOption.hide();
							componentSelection.allWithPermission = false;
							break;
						case 'explicitly':
							// Get the trackers of the selected project, grouped by path
							var projectId = $('input[name="project"]', project).val();

							$.get(getSetting('projectTrackersUrl'), { "proj_id" : projectId, typeId : optType, "branches" : "true"}, function(trackers) {
								showProjectTrackers(projConfig, moreComponents, optType, trackers, true);
								addRemovers();
				        	}).fail(function(jqXHR, textStatus, errorThrown) {
				        		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
							});
							explicitlyOption.hide();
							componentSelection.explicitly = false;
							break;
						}

						if (!(componentSelection.allOfType || componentSelection.allWithPermission)) {
							allItems.hide();
							if (!componentSelection.explicitly) {
								moreComponents.hide();
							}
						}

						var options = this.options;
						options[0].text = settings.moreOfTypeLabel;
						options[0].selected = true;

						addRemovers();
					}
				});
			}

			project.append(projConfig);
		}

		function showTrackerReferenceConfig(popup, optType, projects) {
			if (!$.isArray(projects)) {
				projects = [];
			}

			var wrapperDiv = $("<div>", {"id": "referenceConfigWrapper"});
			var trackerConfig = $('<ul>', { "class" : 'projects' });

			wrapperDiv.append(trackerConfig);

			if (projects.length > 0) {
				for (var i = 0; i < projects.length; ++i) {
					var project = $('<li>', { "class" : 'project' });
					project.append($('<input>', { type : 'hidden', name : 'project', value : projects[i].id }));
					project.append(settings.inProjectLabel + ' ');
					project.append($('<label>').text(projects[i].name));

					showProjectTrackerConfig(project, optType, projects[i]);

					trackerConfig.append(project);
				}
			} else if (!settings.editable) {
				trackerConfig.append($('<li>').text(settings.projectsNone));
			}

			if (settings.editable) {
				var moreProjects = $('<li>', { "class": 'moreProjects' });
				trackerConfig.append(moreProjects);

				var projectSelector = getProjectSelector(projects, moreProjects, settings.moreTrackerProj);
				moreProjects.append(projectSelector);

				projectSelector.change(function() {
					var value = this.value;
					if (value != '0') {
						var text     = $('option:selected', this).text();
						var project = $('<li>', {"class": 'project'});
						project.append($('<input>', {type: 'hidden', name: 'project', value: value }));
						project.append(settings.inProjectLabel + ' ');
						project.append($('<label>').text(text));

						showProjectTrackerConfig(project, optType, null);
						project.insertBefore(moreProjects);
						addRemoverButtons("ul.projects > li.project", removeProject);

						// Remove the project from the selector
						var options = this.options;
						for (var j = 0; j < options.length; ++j) {
							if (options[j].value == value) {
								this.remove(j);
								break;
							}
						}

						options[0].text = getSetting('moreTrackerProj');

						// Hide selector if all projects were chosen
						if (options.length > 1) {
							options[0].selected = true;
						} else {
							moreProjects.hide();
						}
					}
				});
			}

			popup.append(wrapperDiv);
		}

		function removeTrackerType(type) {
			var types    = type.closest('ul');
			var selector = $('select.trackerTypeSelector', types)[0];
			var value    = $('input[name="type"]', type).val();
			var label    = $('label', type).text();
			var option   = $('<option>', { value : value }).text(label);

			$('option', selector).each(function(index, elem) {
				var current = $(this);
				if (index > 0 && option != null && label.localeCompare(current.text()) <= 0) {
					option.insertBefore(current);
					option = null;
					return false;
				}
			});

			if (option != null) {
				$(selector).append(option);
			}

			type.remove();

				if ($('li.trackerType', types).length == 0) {
					selector.options[0].text = getSetting('noneOfTypeLabel');
			}
		};

		function removeTracker(tracker) {
			var trackers = tracker.closest('ul');
			var folder   = trackers.closest('li');
			var folders  = folder.closest('ul');
			var selector = $('select.trackerSelector', folders)[0];
			var path     = $('label:first', folder).text();
			var value    = $('input[name="tracker"]', tracker).val();

			$('optGroup', selector).each(function(index, elem) {
				var group = $(this);
				if (path.localeCompare(group.attr('label')) == 0) {
					group.find('option[value="' + value + '"]').prop("disabled", false);
					group.show();
					$(selector).parent().show();
					return false;
				}
			});

			tracker.remove();
			if ($('li.tracker', trackers).length == 0) {
				folder.remove();

				if ($('li.folder', folders).length == 0) {
					selector.options[0].text = $(selector).attr('data-none');
				}
			}
		}

		function removeFolder(folder) {
			var folders  = folder.closest('ul');
			var path     = $('label:first', folder).text();
			var selector = $('select.trackerSelector', folders)[0];

			$('optGroup', selector).each(function(index, elem) {
				var group = $(this);
				if (path.localeCompare(group.attr('label')) == 0) {
					$('li.tracker', folder).each(function(index, tracker) {
						var value  = $('input[name="tracker"]', tracker).val();
						group.find('option[value="' + value + '"]').prop("disabled", false);
					});
					group.show();
					$(selector).parent().show();
					return false;
				}
			});

			folder.remove();

			if ($('li.folder', folders).length == 0) {
				selector.options[0].text = $(selector).attr('data-none');
			}
		}

		function removeProject(project) {
			var projects = project.closest('ul');
			var selector = $('select.projectSelector', projects)[0];
					var value    = $('input[name="project"]', project).val();
					var label    = $('label:first', project).text();
			var option   = $('<option>', { value : value }).text(label);

			$('option', selector).each(function(index, elem) {
				var current = $(this);
				if (index > 0 && option != null && label.localeCompare(current.text()) <= 0) {
					option.insertBefore(current);
					option = null;
					return false;
				}
			});

			if (option != null) {
				$(selector).append(option);
			}

			project.remove();

			if ($('li.project', projects).length == 0) {
				selector.options[0].text = getSetting('projectsNone');
			}

			$(selector).parent().show();
		}

		function removeComponent(component) {
			var components = component.closest('ul.components');
    		var compType   = component.attr('class').split(' ')[1];
			var selector   = $('select.componentSelector', components)[0];
			var selection  = selector.componentSelection;

					component.remove();

			switch(compType) {
			case 'allItems':
				selection.allOfType = true;
				selection.allWithPermission = true;

				selector.allItems.show();
				selector.allOfType.show();
				selector.allWithPermission.show();
				break;

			case 'allOfType':
				selection.allOfType = true;
				if (selection.allWithPermission) {
					$('li.allItems', components).remove();
				}
				selector.allItems.show();
				selector.allOfType.show();
				break;

			case 'allWithPermission':
				selection.allWithPermission = true;
				if (selection.allOfType) {
					$('li.allItems', components).remove();
				}
				selector.allItems.show();
				selector.allWithPermission.show();
				break;

			case 'explicitly':
				selection.explicitly = true;
				selector.explicitly.show();
				break;
			}

			if (selection.allOfType && selection.allWithPermission && selection.explicitly) {
				selector.options[0].text = selector.noComponents;
			}

			$(selector).parent().show();
		}

		function removePermission(permission) {
			var permissions = permission.closest('ul');
			var selector    = $('select.permissionSelector', permissions)[0];
			var value       = $('input[name="permission"]', permission).val();
			var label       = $('label', permission);
			var text        = label.text();
					var option      = $('<option>', { value : value, title : label.attr('title') }).text(text);

					$('option', selector).each(function(index, elem) {
						var current = $(this);
						if (index > 0 && option != null && text.localeCompare(current.text()) <= 0) {
							option.insertBefore(current);
							option = null;
							return false;
						}
					});

					if (option != null) {
						$(selector).append(option);
					}

			permission.remove();

			if ($('li.permission', permissions).length == 0) {
				selector.options[0].text = getSetting('prjPermsAny');
			}
		}

		function removeProjectQualifier(qualifier) {
			var qualifiers = qualifier.closest('ul');
			var selector   = $('select.projectQualifierSelector', qualifiers)[0];
			var value      = $('input[name="qualifier"]', qualifier).val();
			var label      = $('label:first', qualifier);

			if (label.length == 1) {
				var text   = label.text();
				var option = $('<option>', { value : value, title : label.attr('title') }).text(text);

				$('option', selector).each(function(index, elem) {
					var current = $(this);
					if (index > 0 && option != null && text.localeCompare(current.text()) <= 0) {
						option.insertBefore(current);
						option = null;
						return false;
					}
				});

				if (option != null) {
					$(selector).append(option);
				}
			}

			qualifier.remove();

			if ($('li.projectQualifier', qualifiers).length == 0) {
				selector.options[0].text = getSetting('prjQlfrsAny');
			}
		}

		function init(popup, refType, config) {
			if (refType == 1) {
				showUserReferenceConfig(popup, config);
			} else if (refType == 2) {
				showProjectReferenceConfig(popup, config);
			} else {
				showTrackerReferenceConfig(popup, refType, config);
			}
		}

		function addRemoverButtons(selector, callback) {
			if (settings.editable) {
				var title = i18n.message("tracker.reference.choose.users.groups.remove");
				var context = $("#referenceConfigWrapper");
				$(selector, context).each(function () {
					var $li = $(this);
					if ($li.find("> .removeButton").size() == 0) {
						var removeButton = $("<span>", {"class": "removeButton", "title": title});
						$li.prepend(removeButton);
						removeButton.click(function () {
							callback($li);
						});
					}
				});
			}
		}

		return this.each(function(index, elem) {
			init($(elem), refType, configuration);
			addRemoverButtons("ul.trackerTypes > li.trackerType", removeTrackerType);
			addRemoverButtons("ul.trackers > li.tracker", removeTracker);
			addRemoverButtons("ul.folders > li.folder", removeFolder);
			addRemoverButtons("ul.projects > li.project", removeProject);
			addRemoverButtons("ul.components li.component", removeComponent);
			addRemoverButtons("ul.permissions > li.permission", removePermission);
			addRemoverButtons("ul.projectQualifiers > li.projectQualifier", removeProjectQualifier);
		});
	};

	// The complimentary plugin to get the reference field configuration back from an editor
	$.fn.getReferenceFieldConfiguration = function(refType) {

		function saveProjectRoles(project) {
			var roles = [];

			$('ul.projectRoles > li.projectRole', project).each(function() {
				var label = $('label:first', this);
				roles.push({
					id		 	: $('input[name="qualifier"]', this).val(),
					name	 	: label.text(),
					description : label.attr('title'),
					selected 	: true
				});
			});

			// If roles are selected, we must also add the information about the not selected roles
			if (roles.length > 0) {
				$('select.projectRoleSelector > option', project).each(function() {
  					var option = $(this);
  					var roleId = option.attr('value');
  					if (roleId != '0') {
  	 					roles.push({
	  						id      	: roleId,
							name    	: option.text(),
							description	: option.attr('title'),
							selected	: false
	  					});
	  				}
 				});
			}

			return roles;
		}

		function saveUserReferenceConfig(popup) {
			var config = { groups: [], permissions: [], projects: [] };

			$('ul.userGroups > li.userGroup', popup).each(function() {
				var label = $('label', this);
				config.groups.push({
					id    : $('input[name="qualifier"]', this).val(),
					name  : label.text(),
					title : label.attr('title')
				});
			});

			$('ul.permissions > li.permission', popup).each(function() {
				var label = $('label', this);
				config.permissions.push({
					id    : $('input[name="permission"]', this).val(),
					name  : label.text(),
					title : label.attr('title')
				});
			});

			$('ul.projects > li.project', popup).each(function() {
				var project = $(this);
				var value   = $('input[name="project"]', project).val();
				var label   = $('label:first', project).text();

				config.projects.push({
					id 			: value,
					name 		: label,
					roles		: saveProjectRoles(project),
					permissions : saveProjectTrackerPermissions(project)
				});
			});

			return config;
		}

		function saveProjectReferenceConfig(popup) {
			var config = { qualifiers: [], permissions: [], projects: [] };

			$('ul.projectQualifiers > li.projectQualifier', popup).each(function() {
				var value = $('input[name="qualifier"]', this).val();
				var label = $('label', this).text();
				if (typeof(label) === "undefined") {
					label = value;
				}
				config.qualifiers.push({
					value : value,
					label : label
				});
			});

			$('ul.permissions > li.permission', popup).each(function() {
				var label = $('label', this);
				config.permissions.push({
					id    : $('input[name="permission"]', this).val(),
					name  : label.text(),
					title : label.attr('title')
				});
			});

			$('ul.projects > li.project', popup).each(function() {
				config.projects.push({
					id   : $('input[name="project"]', this).val(),
					name : $('label', this).text()
				});
			});

			return config;
		}

		function saveProjectTrackerTypes(project) {
			var types = [];

			$('ul.trackerTypes > li.trackerType', project).each(function() {
				types.push({
					id   : $('input[name="type"]', this).val(),
					name : $('label', this).text()
				});
			});

			return types;
		}

		function saveProjectTrackerPermissions(project) {
			var permissions = [];

			$('ul.permissions > li.permission', project).each(function() {
				var label = $('label', this);
				permissions.push({
					id 	  : $('input[name="permission"]', this).val(),
					name  : label.text(),
					title : label.attr('title')
				});
			});

			return permissions;
		}

		function saveProjectTrackers(project, optType) {
			var defaultFilter = $.fn.editReferenceFieldConfiguation.defaults.trackerItemFilters[0];
			var folders = [];

			$('ul.folders > li.folder', project).each(function() {
				var folder   = $(this);
				var path     = $('label:first', folder).text();
				var trackers = [];

				$('ul.trackers > li.tracker', folder).each(function() {
					var tracker = $(this);
					var value   = $('input[name="tracker"]', tracker).val();
					var label   = $('label:first', tracker);
					var filter  = { id: defaultFilter.id, name : defaultFilter.name };

					if (optType == 9) {
						var selected = $('select.filterSelector > option:selected', tracker);
						filter.id   = selected.attr('value');
						filter.name = selected.text();
					}

					trackers.push({
						id		 : value,
						path	 : path,
						name	 : label.text(),
						title 	 : label.attr('title'),
						filter   : filter,
						selected : true
					});
				});

				if (trackers.length > 0) {
					folders.push({
						path 	 : path,
						trackers : trackers
					});
				}
			});

			// If trackers are selected, we must also add the information about the not selected trackers
			if (folders.length > 0) {

				$('select.trackerSelector > optGroup', project).each(function() {
					var group    = $(this);
					var path     = group.attr('label');
					var trackers = [];

	  				$('option', group).each(function() {
	  					var option = $(this);
	  					trackers.push({
	  						id      : option.attr('value'),
							path    : path,
							name    : option.text(),
							title   : option.attr('title'),
							filter  : { id: defaultFilter.id, name : defaultFilter.name },
							selected: false
	  					});
	   				});

					if (trackers.length > 0) {
						var folder = null;

						for (var i = 0; i < folders.length; ++i) {
		   	  				if (path.localeCompare(folders[i].path) == 0) {
		   	  					folder = folders[i];
		   	  					break;
		   	  				}
						}

						if (folder == null) {
							folders.push({
								path     : path,
								trackers : trackers
							});
						} else {
							folder.trackers.push.apply(folder.trackers, trackers);
						}
					}
				});
			}

			return folders;
		}

		function saveProjectItemsFilter(project, optType) {
			var defaultFilter = $.fn.editReferenceFieldConfiguation.defaults.trackerItemFilters[0];
			var filter  = { id: defaultFilter.id, name : defaultFilter.name };

			if (optType == 9) {
				var selected = $('li.allItems > select.flagsSelector > option:selected', project);
				filter.id   = selected.attr('value');
				filter.name = selected.text();
			}

			return filter;
		}

		function saveTrackerReferenceConfig(popup, optType) {
			var config = [];

			$('ul.projects > li.project', popup).each(function() {
				var project = $(this);
				var value   = $('input[name="project"]', project).val();
				var label   = $('label:first', project).text();

				config.push({
					id 			: value,
					name 		: label,
					flags		: saveProjectItemsFilter(project, optType),
					types 		: saveProjectTrackerTypes(project),
					permissions	: saveProjectTrackerPermissions(project),
					explicitly	: saveProjectTrackers(project, optType)
				});
			});

			return config;
		}


		if (refType == 1) {
			refConfig = saveUserReferenceConfig(this);
		} else if (refType == 2) {
			refConfig = saveProjectReferenceConfig(this);
		} else {
			refConfig = saveTrackerReferenceConfig(this, refType);
		}

		return refConfig;
	};

	// A third plugin to create a reference field configuration editor in a dialog and
	$.fn.showReferenceFieldConfiguationDialog = function(fieldId, refType, configuration, options, dialog, callback) {
		var popup    = this;
		var settings = $.extend( {}, $.fn.showReferenceFieldConfiguationDialog.defaults, dialog );

		if (configuration === undefined || configuration == null) {
			$.get(options.refConfUrl, {fieldId : fieldId }).done(function(config) {
				popup.editReferenceFieldConfiguation(refType, config, options);
				var position = popup.dialog("option", "position");
				popup.dialog("option", "position", position);
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	        });
		} else {
			popup.editReferenceFieldConfiguation(refType, configuration, options);
		}

		if (options.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : options.submitText,
				 click: function() {
							var refConfig = popup.getReferenceFieldConfiguration(refType);
						 	callback(refConfig);

							$(this).dialog("close");
						}
				},
				{ text : options.cancelText,
				  "class": "cancelButton",
				  click: function() {
				  			var popup = $(this);
				  			popup.dialog("close");
				  			popup.remove();
						 }
				}
			];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.editReferenceFieldConfiguation.defaults = {
		editable			: false,
		refConfUrl			: null,
		projectsUrl			: null,
		projectRolesUrl		: null,
		projectTrackersUrl  : null,
		projectCategories   : [],
		projectPermissions  : [],
		trackerTypes		: [],
		trackerPermissions	: [],
		trackerFiltersUrl	: null,
		trackerItemFilters	: [{ id: 0, name: 'Any status'}],
		repositoryTypes		: [],
		repositoryPermissions:[],
		basicRepositoryPermissions: [],
		userGroups  		: [],
		userPermissions  	: [],
	    submitText    		: 'OK',
	    cancelText   		: 'Cancel',
	    userGroupsLabel		: 'in Group',
		userGroupsTitle		: 'If groups are selected, only members of these groups are included',
		userGroupsAny		: 'Any',
		userGroupsMore		: 'More..',
		userGroupsRemove	: 'Remove',
	    userPermsLabel		: 'with Permission',
	    userPermsTitle		: 'If permissions are selected, only users are included where the user has at least one of the specified permissions',
	    userPermsAny		: 'Any',
	    userPermsMore		: 'More...',
	    userPermsRemove		: 'Remove',
	    projectMembersLabel : 'member of',
		projectMembersTitle : 'If projects members are selected, those are included whether or not they are member of the specified groups',
		projectMembersNone  : 'None',
		memberRolesLabel	: 'in Role',
		memberRolesTitle	: 'If roles are selected, only members in these roles are included',
		memberPermsLabel	: 'with Permission',
		memberPermsTitle	: 'If permissions are selected, all members with any of these permissions are selected, independent of the role',
	    prjQlfrsLabel		: 'of Category',
	    prjQlfrsTitle		: 'If categories are selected, only projects with these categories are included',
	    prjQlfrsAny			: 'Any',
	    prjQlfrsMore		: 'More...',
	    prjQlfrsRemove		: 'Remove',
	    prjPermsLabel		: 'with Permission',
	    prjPermsTitle		: 'If permissions are selected, only projects are included where the user has at least one of the specified permissions',
	    prjPermsAny			: 'Any',
	    prjPermsMore		: 'More...',
	    prjPermsRemove		: 'Remove',
	    projectsLabel		: 'and explicitly',
	    projectsTitle		: 'If individual projects are selected, those are included, whether or not the category or permission matches.',
	    projectsNone		: 'None',
	    projectsMore		: 'More...',
	    projectsRemove		: 'Remove',
	    inProjectLabel		: 'in Project',
	    moreTrackerProj 	: 'More projects...',
	    inFolderLabel		: 'in',
	    noTrackersLabel 	: 'No Trackers/CMDB Categories',
	    allTrackersLabel	: 'all Trackers/CMDB Categories',
	    allTrackersTitle	: 'If at least one type and/or permission is selected, all Trackers/CMDB Categories in this project with any of these types/permissions are included.',
	    trkrOfTypeLabel 	: 'of type',
	    trkrOfTypeTitle 	: 'If types are selected, all Trackers/CMDB Categories in this project with any of these types are included',
	    noneOfTypeLabel		: 'None',
	    moreOfTypeLabel		: 'More...',
	    trkrPermsTitle		: 'If permissions are selected, all CMDB/Trackers in this project are included, where the user has at least one of the specified permissions',
	    trkrsExplctLabel	: 'and explicitly',
	    trkrsExplctTitle	: 'If individual Trackers/CMDB Categories are selected, those are included, whether or not the type or permission matches.',
	    trkrsExplctNone		: 'No Trackers/CMDB Categories',
	    trkrsExplctMore		: 'More Trackers/CMDB Categories...',
	    itemsLabel			: 'Items/Issues',
	    noItemsLabel		: 'No Tracker/CMDB items',
	    allItemsLabel		: 'all Tracker/CMDB items',
	    allItemsTitle		: 'If at least one type and/or permission is selected, all Tracker/CMDB items in this project with any of these types/permissions are included.',
		withStatusLabel		: 'with status',
	    itemOfTypeLabel		: 'of type',
	    itemOfTypeTitle		: 'If types are selected, all Tracker/CMDB items of this type in this project are included.',
	    itemPermsTitle		: 'If permission are selected, all Tracker/CMDB items with any of these permissions are included.',
	    itemsExplctLabel	: 'and explicitly',
	    itemsExplctTitle	: 'If individual Trackers/CMDB Categories are selected, all items from these Trackers/CMDB Categories matching the specified filter/criteria are included',
		itemFilterLabel		: 'Filter',
		itemFilterTitle		: 'A filter to selected a subset of items in this tracker/category',
	    noReposLabel		: 'No SCM repositories',
	    allReposLabel		: 'all Repositories',
	    allReposTitle		: 'If at least one type and/or permission is selected, all repositories in this project with any of these types/permissions are included.',
	    repoOfTypeLabel		: 'of type',
	    repoOfTypeTitle 	: 'If types are selected, all repositories of these types in this project are included.',
	    repoPermsTitle		: 'If permissions are selected, all SCM repositories in this project are included, where the user has at least one of the specified permissions.',
	    reposExplctLabel	: 'and explicitly',
	    reposExplctTitle	: 'If individual SCM repositories are selected, those are included, whether or not the type or permission matches.',
	    reposExplctNone		: 'No SCM Repositories',
	    reposExplctMore		: 'More SCM Repositories...',
		trackerViewUrl		: null,
		createViewLabel		: 'New',
		editViewLabel		: 'Edit',
		filterConfiguration : {
				nameLabel	: 'Name',
 				hide		: ['visibility', 'layout', 'fields', 'orderBy', 'charts'],
				creationType: 'user'
  		}
	};

	$.fn.showReferenceFieldConfiguationDialog.defaults = {
		dialogClass		: 'popup',
		width			: 640,
		draggable		: true
	};

	$.fn.editReferenceFieldConfiguation.projects = null;

})( jQuery );
