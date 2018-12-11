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

	$.ech.multiselect.prototype._setButtonValue = function(value) {
		this.buttonlabel.html(value);
    };

    $.ech.multiselect.prototype.getAccessPerms = function() {
		var permissions = [];

		var selected = this.getChecked();
		for (var i = 0; i < selected.length; ++i) {
			var checkbox = selected[i];
			var sepIdx   = checkbox.value.indexOf('-');
			var type     = checkbox.value.substring(0, sepIdx);
			var id       = parseInt(checkbox.value.substring(sepIdx + 1));
			var label    = $(checkbox).siblings().filter(".label");
			var access   = label.siblings().filter(".access");
			var permission = {};

			permission[type]  = id;
			permission.access = access.is(':checked') ? 3 : 1;

			permissions.push(permission);
		}

		return permissions;
	};

	function isSelected(permissions, type, id) {
		for (var i = 0; i < permissions.length; ++i) {
			if (permissions[i] != null && permissions[i][type] == id) {
				return true;
			}
		}
		return false;
	}


	// A plugin to get the selected read/write access permission per field/role from a multiple selector plugin (see below)
	$.fn.getReadWriteAccessPermissions = function(defaults) {
		var selector = $('select.accessPerms', this);
		if (selector.length > 0) {
			return selector.multiselect("getAccessPerms");
		}
		return $.isArray(defaults) ? defaults : [];
	};


	// The read/write permission per field/role multiple selector plugin
	$.fn.readWriteAccessPermMultiSelect = function(permissions, edit, config, extraAction) {
		var settings = $.extend( {}, $.fn.readWriteAccessPermMultiSelect.defaults, config );

		function getSetting(name) {
			return settings[name];
		}

		function getAccess(permissions, type, id) {
			for (var i = 0; i < permissions.length; ++i) {
				if (permissions[i] != null && permissions[i][type] == id) {
					return permissions[i].access == 3 ? 'edit' : 'read';
				}
			}
			return 'read';
		}

		function toggleReadWriteAccess() {
			var access = $(this);
			if (access.is(':checked')) {
				access.attr('title', settings.readText);
			} else {
				access.attr('title', settings.editText);
			}
			return false;
		}
		
		function updateHeaderCheckbox(checkbox) {
			var $checkbox = $(checkbox),
				columnSelector = $checkbox.hasClass('readOnlyColumn') ? '.readOnlyColumn' : '.editColumn',
				$list = $checkbox.closest('ul.ui-multiselect-optgroup'),
				listItemCount = $list.children('li').length,
				isAllCheckboxSelectedInColumn = $list.find('li input' + columnSelector + ':checked').length == listItemCount;
			
			$list.find('span' + columnSelector + ' input').prop('checked', isAllCheckboxSelectedInColumn);
		}

		function init(container, permissions, edit, extraAction) {
			if (!$.isArray(permissions)) {
				permissions = [];
			}

			var editLinkMarkup = '<span class="editLink">Edit &#9660;</span>';

			if (permissions.length > 0 || settings.editable) {
				var selector = $('<select>', { "class" : 'accessPerms', multiple : true, disabled : !settings.editable });
				container.append(selector);

				var fields = settings.memberFields;
				if (typeof(fields) == 'function') {
					fields = settings.memberFields();
				}

				if ($.isArray(fields) && fields.length > 0) {
					var group = $('<optgroup>', { label : settings.memberFieldsLabel }).addClass("participants");
					selector.append(group);

					for (var i = 0; i < fields.length; ++i) {
						group.append($('<option>', { "class" : 'field', value: 'field-' + fields[i].id, selected : isSelected(permissions, 'field', fields[i].id) }).text(fields[i].displayLabel || fields[i].label || fields[i].name));
				    }
				}

				var roles = settings.roles;
				if (typeof(roles) == 'function') {
					roles = settings.roles();
				}

				if ($.isArray(roles) && roles.length > 0) {
					var group = $('<optgroup>', { label : settings.rolesLabel }).addClass("roles");
					selector.append(group);

					for (var i = 0; i < roles.length; ++i) {
						group.append($('<option>', { "class" : 'role', value: 'role-' + roles[i].id, selected : isSelected(permissions, 'role', roles[i].id) }).text(roles[i].name));
				    }
				}

				selector.multiselect({
		    		checkAllText	 : settings.checkAllText,
		    	 	uncheckAllText	 : settings.uncheckAllText,
		    	 	noneSelectedText : settings.noneText + (settings.editable ? editLinkMarkup : ''),
		    	 	autoOpen		 : false,
		    	 	multiple         : true,
		    	 	selectedList	 : 99,
		    	 	minWidth		 : settings.minWidth,
		    	 	height			 : "auto",
					position		 : {
						my: "center top",
						at: "center bottom"
					},

		    	 	create			 : function() {

											var widget = selector.multiselect("widget");
												widget.mousedown(function(e) {
												e.preventDefault();
											});
												widget.mouseover(function(e) {
												e.preventDefault();
											});

		    	 							if (extraAction && typeof(extraAction.callback) == 'function') {
		    	 								var headers = widget.find('ul').first();
		    	 								var extraItem = $('<li>');
		    	 								var actionLink = $('<a>', { title : extraAction.title, "class": "accessPermLink" }).click(extraAction.callback);


		    	 								actionLink.append($('<span>', { "class" : 'accessPermDefault'}).text(extraAction.label));

		    	 								extraItem.append(actionLink);
		    	 								headers.append(extraItem);
		    	 							}

											widget.find(":checkbox").each(function() {
												var roCheckbox = $(this);
												roCheckbox.addClass("readOnlyColumn");
												var details  = roCheckbox.next().addClass("label");
												var sepIdx   = this.value.indexOf('-');
												var type     = this.value.substring(0, sepIdx);
												var id       = parseInt(this.value.substring(sepIdx + 1));
												var mode     = getAccess(permissions, type, id);
												var access   = $('<input>', {
													"type": "checkbox",
													"class": 'editColumn access',
													checked: mode == 'edit'
												});

												if (edit) {
													details.css({
														"display": "inline-block",
														"min-width": "12em"
													});

													roCheckbox.closest("label").attr("for", ""); // this would otherwise cause event triggering issues in Firefox

													var refresh = throttleWrapper(function() {
														selector.multiselect("update");
													}, 50);

													access.mousedown(function(e) {
														e.preventDefault();
													});
													access.change(function() {
														var roCb = access.siblings().filter(".readOnlyColumn:not(:checked)");
														var thisIsChecked = $(this).is(":checked");
														var roIsChecked = roCb.is(":checked");
														if (thisIsChecked && !roIsChecked) {
															roCb.prop("checked", true);
															updateHeaderCheckbox(roCb[0]);	
														}
														toggleReadWriteAccess.apply(this);
														refresh();
														updateHeaderCheckbox(this);
													});

													roCheckbox.mousedown(function(e) {
														e.preventDefault();
													});
													roCheckbox.change(function(e) {
														var editCb = roCheckbox.siblings().filter(".editColumn:checked");
														var thisIsChecked = $(this).is(":checked");
														var editIsChecked = editCb.is(":checked");
														if (!thisIsChecked && editIsChecked) {
															editCb.prop("checked", false);
															updateHeaderCheckbox(editCb[0]);
														}
														refresh();
														updateHeaderCheckbox(this);
													});
												} else {
													access.hide();
												}

												access.insertAfter(roCheckbox);
											});

											var addTitleCheckboxes = function(sectionClassName, columnClassName, label) {
												var title = $("<span>");
												var cb = $("<input>", { type: "checkbox" }).change(function() {
													var state = $(this).is(":checked"),													
														otherCheckbox = $(this).parent().siblings('.columnHeader').children('input');
													cb.closest("ul").find(" li ." + columnClassName).each(function() {
														var otherCb = $(this);
														if (otherCb.is(":checked") != state) {
															otherCb.prop("checked", state).change();
														}
													});
													
													if ((state && otherCheckbox.parent().is('.readOnlyColumn') && !otherCheckbox.is(':checked')) ||
														(!state && otherCheckbox.parent().is('.editColumn') && otherCheckbox.is(':checked'))) {
														otherCheckbox.click();
													}
												});
												cb.mousedown(function(e) {
													e.preventDefault();
												});
												var sectionHeader = widget.find("." + sectionClassName);
												title.addClass("columnHeader " + columnClassName)
													.append(cb)
													.append(label);
												sectionHeader.prepend(title);
											};
											var addTitleCheckboxesToSection = function(sectionClassName) {
												var roLabel = getSetting("readText");
												var editLabel = getSetting("editText");

												addTitleCheckboxes(sectionClassName, "readOnlyColumn", roLabel);
												if (edit) {
													addTitleCheckboxes(sectionClassName, "editColumn", editLabel);
												}
											};

											addTitleCheckboxesToSection("participants");
											addTitleCheckboxesToSection("roles");

											selector.multiselect("update");

											$('button.ui-multiselect', container).mousedown(function(e) {
												e.preventDefault();
											});
											
											['participants', 'roles'].forEach(function(listName) {
												var $firstReadCheckbox = widget.find('ul.' + listName + ' input.readOnlyColumn').first(),
												$firstEditCheckbox = widget.find('ul.' + listName + ' input.editColumn').first();
												
												if ($firstReadCheckbox.length) {
													updateHeaderCheckbox($firstReadCheckbox[0]);
												}
												if ($firstEditCheckbox.length) {
													updateHeaderCheckbox($firstEditCheckbox[0]);
												}
											})
									   },

						selectedText : function (selectedCount, totalCount, selected) {
											var selection = [];

											for (var i = 0; i < selected.length; ++i) {
												var checkbox = $(selected[i]);
												var label    = checkbox.siblings().filter(".label");
												var access   = checkbox.siblings().filter(".access");
												var settingAsText = (getSetting(access.is(':checked') ? 'editText' : 'readText') );

												selection.push('<span class="setting"><b>' + label.text() + '</b>: ' + settingAsText + '</span>');
											}

											selection.push(editLinkMarkup);

											return selection.join("");
									   },
						checkAll: function(e) {
							var $widget = selector.multiselect('widget'),
								$checkboxes = $widget.find('.editColumn input:not(:checked)');

							$checkboxes.click();
						},
						uncheckAll: function(e) {
							var $widget = selector.multiselect('widget'),
								$checkboxes = $widget.find('input[type="checkbox"]');
							
							$checkboxes.prop('checked', false);
						}
				});
			} else {
				container.append(settings.noneText);
			}
		}

		return this.each(function() {
			init($(this), permissions, edit, extraAction);
		});
	};

	$.fn.readWriteAccessPermMultiSelect.defaults = {
		editable			: false,
		minWidth			: 640, //'auto'
		roles				: [],
		memberFields		: [],
		memberFieldsLabel	: 'Participants',
		rolesLabel			: 'Roles',
		readText			: 'Read',
		editText			: 'Edit',
		noneText  			: 'None',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all'
	};


	// The field access permission configuration plugin
	$.fn.accessPermissionConfiguration = function(mode, permissions, sameAs, edit, config) {
		var settings = $.extend( {}, $.fn.accessPermissionConfiguration.defaults, config );

		function getSetting(name) {
			return settings[name];
		}

		function getAccessModeSelector(mode) {
           	var selector = $('<select>', { "class" : 'fieldAccessMode', disabled : !settings.editable });

			var modes = settings.accessControlTypes;
          	for (var i = 0; i < modes.length; ++i) {
          		selector.append($('<option>', { value : modes[i].id, title : modes[i].title, selected : (modes[i].id == mode) }).text(modes[i].name));
           	}

          	return selector;
		}

		function getPermissionsForStatus(statusPerms, status) {
			if ($.isArray(statusPerms)) {
				for (var i = 0; i < statusPerms.length; ++i) {
					if (statusPerms[i].status == status) {
						return statusPerms[i].permissions;
					}
				}
			}
			return status != null && settings.defaultIsDefault ? [{"default" : true}] : [];
		}

		function showSinglePermissions(container, permissions, edit, defaults) {
			if (!$.isArray(permissions)) {
				permissions = [];
			}

			if (isSelected(permissions, 'default', true)) {
				if (settings.editable) {
					var selector = $('<select>');
					selector.append($('<option>', { value : 'default', title : settings.defaultTooltip, selected : true }).text(settings.defaultText));
					selector.append($('<option>', { value : 'special', title : settings.specialTooltip }).text(settings.specialText));
					container.append(selector);

					selector.change(function() {
						if (this.value == 'special') {
							container.empty();
							showSinglePermissions(container, defaults.multiselect("getAccessPerms"), edit, defaults);
							$('select.accessPerms', container).multiselect("open");
							$('button.ui-multiselect', container).draggable({
								cancel			: '',
								helper			: 'clone',
								revert			: true,
								revertDuration	: 0,
								containment		: container.closest('table'),
								cursor			: "move",
								delay			: 150,
								distance		: 5,
								scroll			: true
							});
						}
					});
				} else {
					container.append($('<label>', { title : settings.defaultTooltip }).text(settings.defaultText));
				}
			} else {
				container.readWriteAccessPermMultiSelect(permissions, edit, settings, defaults == null ? null : {
					label	 : i18n.message("tracker.field.permissions.status.reset.to.default"),
					title 	 : settings.defaultTooltip,
					callback : function() {
						container.empty();
						showSinglePermissions(container, [{"default" : true}], edit, defaults);
					}
				});
			}
		}

		function showPermissionsPerStatus(container, mode, perms, edit) {
			if (!$.isArray(perms)) {
				perms = [{ status : null, permissions : []}];
			}

			var states = [{ id : null, name : '--'}];

			var multi = (mode.val() == '2');
			if (multi) {
				var statusOptions = settings.statusOptions;
				if (typeof(statusOptions) == 'function') {
					statusOptions = settings.statusOptions();
				}

				if ($.isArray(statusOptions) && statusOptions.length > 0) {
					states.push.apply(states, statusOptions);
				}
			}

			var table = $('<table>', { "class" : 'accessPermsPerStatus formTableWithSpacing', style : 'margin-top: 0.5em; width: 100%;' });
			container.append(table);

			var defaults = null;

			for (var i = 0; i < states.length; ++i) {
				var permsPerStatus = $('<tr>', { "class" : 'status' });
				table.append(permsPerStatus);

				var statusCol = $('<td>', { "class" : 'accessPermsStatus ' + ((i == 0 || $.inArray(states[i].id, settings.workflowStates) >= 0) ? 'active' : 'unused'), style : 'width: 5%;'} );
				statusCol.append($('<input>', { type : 'hidden', name : 'status', value : states[i].id }));
				if (i == 0) {
					statusCol.append(mode);
				} else {
					statusCol.append($('<label>').text(states[i].name));
				}
				permsPerStatus.append(statusCol);

				var permsCol = $('<td>', { "class" : 'permissions textDataWrap' } );
				showSinglePermissions(permsCol, getPermissionsForStatus(perms, states[i].id), edit, defaults);
				permsPerStatus.append(permsCol);

				if (multi) {
					var selector = $('select.accessPerms', permsCol);
					if (selector.length > 0) {
						$('button.ui-multiselect', permsCol).draggable({
							cancel			: '',
							helper			: 'clone',
							revert			: true,
							revertDuration	: 0,
							containment		: table,
							cursor			: "move",
							delay			: 150,
							distance		: 5,
							scroll			: true
						});
					}

					var isFirstControl = i == 0;
					if (isFirstControl) {
						var fieldSet = $('<fieldset class="ui-multiselect-wrapper-fieldset"><legend> ' + i18n.message("cb.defaultSettings") + ' </legend></fieldset>').insertBefore(selector);
						selector.add(selector.next(".ui-multiselect")).detach().appendTo(fieldSet);
					}

					permsCol.droppable({
						accept: "button.ui-multiselect",
						drop  : function(event, ui) {
									var container = $(this);
									if (!container.is(ui.draggable.closest('td'))) {
										container.empty();
										showSinglePermissions(container, ui.draggable.prev('select.accessPerms').multiselect("getAccessPerms"), edit, defaults);

										$('button.ui-multiselect', container).draggable({
											cancel			: '',
											helper			: 'clone',
											revert			: true,
											revertDuration	: 0,
											containment		: table,
											cursor			: "move",
											delay			: 150,
											distance		: 5,
											scroll			: true
										});
									}
								}
					});

					if (i == 0) {
						defaults = selector;
					}
				}
		    }
		}

		function init(container, mode, permissions, sameAs, edit) {
			var modeSelector = getAccessModeSelector(mode);

			if (mode == 3) {
				container.append(modeSelector).append($.isFunction(sameAs) ? sameAs() : sameAs);
			} else if (mode > 0) {
				showPermissionsPerStatus(container, modeSelector, permissions, edit);
			} else {
				container.append(modeSelector);
			}

			if (settings.editable) {
				modeSelector.change(function() {
					var newMode  = parseInt(this.value);
					var newPerms = container.getAccessPermissions();

					container.empty();
					settings.defaultIsDefault = true;

					init(container, newMode, newPerms, sameAs, edit);
				});
			}
		}

		return this.each(function() {
			init($(this), mode, permissions, sameAs, edit);
		});
	};

	$.fn.accessPermissionConfiguration.defaults = $.extend( {}, $.fn.readWriteAccessPermMultiSelect.defaults, {
		defaultAccessCtrl	: 0,
		accessControlTypes	: [{ id : 0, name : 'None', title : '' }, { id : 1, name : 'Single', title : '' }, { id : 2, name : 'Per Status', title : '' }],
		statusOptions		: [],
		workflowStates		: [],
		statusLabel			: 'Status',
		permissionsLabel	: 'Permissions',
		defaultText  		: 'Default',
		defaultTooltip 		: 'Apply default permissions for this status',
		defaultIsDefault	: false,
		specialText  		: 'Special',
		specialTooltip 		: 'Apply special permissions for this status'
	});


	// A second plugin to get the configured access permissions
	$.fn.getAccessPermissions = function() {

		function getSelectedPermissions(status, container) {
			var selector = $('select.accessPerms', container);
			if (selector.length > 0) {
				return selector.multiselect("getAccessPerms");
			}
			return status != null ? [{"default" : true}] : [];
		}

		var result = [];

		$('table.accessPermsPerStatus tr.status', this).each(function() {
			var statusId = parseInt($('input[name="status"]', this).val());
			statusId = (isNaN(statusId) ? null : statusId);

			result.push({
				status 		: statusId,
				permissions : getSelectedPermissions(statusId, this)
			});
		});

		if (result.length == 0) {
			result.push({
				status 		: null,
				permissions : []
			});
		}

		return result;
	};

	// A third plugin to open a dialog with the field access permission configuration
	$.fn.showAccessPermissionsDialog = function(mode, perms, sameAs, edit, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showAccessPermissionsDialog.defaults, dialog );
		var popup    = this;

		popup.accessPermissionConfiguration(mode, perms, sameAs, edit, config);
		if (settings.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : settings.submitText,
				 click: function() {
					 		var modeId = parseInt($('select.fieldAccessMode', popup).val());
					 		var accessPerms = [];
					 		var accessSameAs = null;

					 		if (modeId == 3) {
					 			var sameAsOption = $('select.sameAccessAs > option:selected', popup);
					 			if (sameAsOption && sameAsOption.length > 0) {
					 				accessSameAs = sameAsOption.data('field');
					 			}
					 		} else {
					 			accessPerms = popup.getAccessPermissions();
					 		}

							callback(modeId, accessPerms, accessSameAs);
					  		popup.dialog("close");
						}
				},
				{ text : settings.cancelText,
				  "class": "cancelButton",
				  click: function() {
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

	$.fn.showAccessPermissionsDialog.defaults = {
		editable		: true,
		dialogClass		: 'popup',
		width			: 950,
		maxHeight		: 800,
		draggable		: true,
		submitText		: 'OK',
		cancelText		: 'Cancel'
	};

})( jQuery );

