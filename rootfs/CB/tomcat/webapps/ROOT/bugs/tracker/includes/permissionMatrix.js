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

	function hashCheckbox(owner, permission) {
		return owner + "---" + permission;
	}

	var checkboxCache = {};
	var rowCbCache = {};

	// A JQuery plugin to show/edit object access permissions in a matrix (per field/role)
	$.fn.permissionMatrix = function(accessPerms, options) {
		var settings = $.extend({}, $.fn.permissionMatrix.defaults, options);
		// removing add attachment permission in order to not display it on the UI
		settings.permissions = settings.permissions.filter(function(permission) {
			return permission.name != 'issue_attachment_add';
		});

		function grantRevokeAllPermissions(owner, grant) {
			var checkboxes = null;

			var role = owner.data('role');
			if (role) {
				checkboxes = 'input[type="checkbox"][data-owner="role-' + role.id + '"]';
			} else {
				var field = owner.data('field');
				if (field) {
					checkboxes = 'input[type="checkbox"][data-owner="field-' + field.id + '"]';
				}
			}

			if (checkboxes) {
				var table = owner.closest('table.permissionMatrix');
				$(checkboxes, table).filter(':not(.alwaysChecked)').attr('checked', grant);
			}
		}

		function grantRevokeToAll(permission, grant) {
			var row = permission.closest('tr');
			var tds = row.find('td');
			var filteredTds = tds.filter(':not(.grantRevokeAll)').filter(':not(.alwaysChecked)');
			var checkBoxes = filteredTds.find('input[type="checkbox"]:enabled');
			if ($.fn.permissionMatrix._initialized) {
				checkBoxes.prop('checked', grant);
			}
			checkBoxes.change();
		}

		function setup() {
			if (settings.editable) {

				/** Add a context menu to permission owners, to allow granting/revoking all permissions to/from this owner */
				var ownerPermissionMenu = new ContextMenuManager({
					selector: "table.permissionMatrix th.permOwner",
					items: {    grantAll: { name: settings.grantAllText,
						callback: function(key, options) {
							grantRevokeAllPermissions(options.$trigger, true);
						}
					},
						revokeAll: { name: settings.revokeAllText,
							callback: function(key, options) {
								grantRevokeAllPermissions(options.$trigger, false);
							}
						}
					}
				});
				ownerPermissionMenu.render();
			}
			$.fn.permissionMatrix._initialized = true;
		}

		function isSelected(accessPerms, type, id, perm) {
			for (var i = 0; i < accessPerms.length; ++i) {
				if (accessPerms[i] != null && accessPerms[i][type] == id) {
					return (accessPerms[i].access & perm) == perm;
				}
			}
			return false;
		}

		function isAlwaysChecked(role, perm, settings, projAdminRoleId) {
			// the role is admin
			if (role === projAdminRoleId) {
				// admin
				if (perm === 8388608) {
					return true;
				}
				// browse
				if (perm === 1) {
					return true;
				}
				// update own changesets
				if (perm === 16) {
					return true;
				}
				// update changeset
				if (perm === 2) {
					return true;
				}

				// check default admin permissions
				if (settings.adminPermissions){
					return (perm & settings.adminPermissions) != 0;
				}

			}
			return false;
		}

		function init(container, accessPerms) {
			var projAdminRoleId = settings.projAdminRoleId;
			var table = $('<table>', { "class": 'permissionMatrix displaytag' });
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>', { "class": 'head' });
			header.append(headline);

			headline.append($('<th>', { "class": 'textData columnSeparator', style: 'width: 5%; white-space: normal;' }).text(settings.permissionLabel));

			if (settings.editable) {
				headline.append($('<th>', { "class": 'textData textCenterDataWrap columnSeparator', style: 'white-space: normal;' }).text(settings.grantRevokeAllLabel + "*"));
			}

			var fields = ($.isArray(settings.fields) ? settings.fields : []);
			for (var i = 0; i < fields.length; ++i) {
				headline.append($('<th>', { "class": 'permOwner textCenterDataWrap columnSeparator', style: 'white-space: normal;', title: fields[i].title }).text(fields[i].name).data("field", fields[i]));
			}

			var roles = ($.isArray(settings.roles) ? settings.roles : []);
			for (var i = 0; i < roles.length; ++i) {
				var columnTitle = roles[i].description;
				if (roles[i].id == projAdminRoleId){
					columnTitle += "**";
				}
				headline.append($('<th>', { "class": 'permOwner textCenterDataWrap columnSeparator', style: 'white-space: normal;', title: columnTitle }).text(roles[i].name).data("role", roles[i]));
			}

			headline.append($('<th>'));

			var body = $('<tbody>');
			table.append(body);

			var permissions = ($.isArray(settings.permissions) ? settings.permissions : []);

			for (var i = 0; i < permissions.length; ++i) {
				var row = $('<tr>', { "class": (i % 2 == 0 ? 'permission even' : 'permission odd'), style: 'vertical-align: middle;' }).data("permission", permissions[i]);
				body.append(row);

				var permCol = $('<td>', { "class": 'permission textData', style: 'vertical-align: middle; width: 5%;', title: (settings.showDescriptions ? null : permissions[i].title) }).text(permissions[i].name);
				if (settings.showDescriptions && permissions[i].title != permissions[i].title.length > 0) {
					var helpImg = $('<img>', { 'src': settings.contextPath + "/images/newskin/action/help.png" });
					var helpAnchor = $('<a>', { "title": permissions[i].title, href: '#', "onclick": 'return false;', "style": 'margin-left: 10px; vertical-align: sub;' });
					helpAnchor.append(helpImg);
					permCol.append(helpAnchor);
				}
				row.append(permCol);

				if (settings.editable) {
					var grantRevokeCol = $('<td>', {"class": 'matrixCell columnSeparator grantRevokeAll', "title": settings.grantRevokeAllLabel, style: "background-color: #f5f5f5;" });
					var permValue = permissions[i].id;
					var hash = hashCheckbox("", permValue);
					var cb = $('<input>', { type: "checkbox", id: hash });
					grantRevokeCol.append(cb);
					checkboxCache[hash] = cb.get(0);
					row.append(grantRevokeCol);
				}

				for (var j = 0; j < fields.length; ++j) {
					var cell = $('<td>', { "class": 'matrixCell columnSeparator', title: (fields[j].name + ': ' + permissions[i].name) }).data('field', fields[j]);
					row.append(cell);

					var ownerValue = 'field-' + fields[j].id;
					var permValue = permissions[i].id;
					var hash = hashCheckbox(ownerValue, permValue);
					var cb = $('<input>', { type: 'checkbox', id: hash, "data-owner": ownerValue, "data-permId": permValue, checked: isSelected(accessPerms, 'field', fields[j].id, permissions[i].id), disabled: !settings.editable });
					cell.append(cb);
					checkboxCache[hash] = cb.get(0);
				}

				for (var j = 0; j < roles.length; ++j) {

					var isAlwaysCheckedValue = isAlwaysChecked(roles[j].id, permissions[i].id, settings, projAdminRoleId);
					var cell = $('<td>', { "class": 'matrixCell columnSeparator' + (isAlwaysCheckedValue ? 'alwaysChecked' : ''), title: (roles[j].name + ': ' + permissions[i].name) }).data('role', roles[j]);
					row.append(cell);

					var isSelectedValue = isAlwaysCheckedValue ? true : isSelected(accessPerms, 'role', roles[j].id, permissions[i].id);
					var isDisabledVAlue = isAlwaysCheckedValue ? true : !settings.editable;

					var ownerValue = 'role-' + roles[j].id;
					var permValue = permissions[i].id;
					var hash = hashCheckbox(ownerValue, permValue);
					var cb = $('<input>', { type: 'checkbox', id: hash, "data-owner": ownerValue, "class": (isAlwaysCheckedValue ? 'alwaysChecked' : ''), "data-permId": permValue, checked: isSelectedValue, disabled: isDisabledVAlue });
					cell.append(cb);
					checkboxCache[hash] = cb.get(0);
				}

				row.append($('<td>'));
			}

			var hint = $('<span>').text("*" + settings.grantToAllHint).css({
				"margin": "1em 0 0 1em",
				"display": "block",
				"font-size": "0.9em"
			});
			hint.insertAfter(container);

			var defaultAdminPermissionList = "";
			for (var i = 0; i < permissions.length; ++i) {
				if ((permissions[i].id & settings.adminPermissions) != 0){
					if (defaultAdminPermissionList !== ""){
						defaultAdminPermissionList += ", ";
					}
					defaultAdminPermissionList += permissions[i].name
				}
			}

			if (settings.adminPermissionHint){
				var hint2 = $('<span>').text("** " + settings.adminPermissionHint + ": " + defaultAdminPermissionList).css({
					"margin": "1em 0 0 1em",
					"display": "block",
					"font-size": "0.9em"
				});
				hint2.insertAfter(hint);
			}

			if (settings.editable) {
				table.find("td.grantRevokeAll").each(function() {
					var grantRevokeCheckBox = $(this).find('input[type="checkbox"]');
					var row = $(this).closest("tr");
					grantRevokeCheckBox.change(function() {
						grantRevokeToAll(row, this.checked);
					});
				});
				checkGrantRevokeCheckBoxes(table);
			}

			if (settings.editable) {
				table.find('td').filter(':not(.grantRevokeAll)').filter(':not(.alwaysChecked)').find('input[type="checkbox"]').change(function() {
					checkGrantRevokeCheckBoxes(table);
				});
			}
		}

		if ($.fn.permissionMatrix._setup) {
			$.fn.permissionMatrix._setup = false;
			setup();
		}

		var result = this.each(function() {
			init($(this), accessPerms);
		});

		return result;
	};


	$.fn.permissionMatrix.defaults = {
		editable: true,
		permissions: [],
		fields: [],
		roles: [],
		permissionLabel: 'Permission',
		showDescriptions: false,
		fieldsLabel: 'Participants',
		rolesLabel: 'Roles',
		grantAllText: 'Grant all permissions',
		revokeAllText: 'Revoke all permissions',
		grantToAllText: 'Grant to all',
		revokeFromAllText: 'Revoke from all',
		grantRevokeAllLabel: 'Grant/revoke to/from all'
	};

	$.fn.permissionMatrix._setup = true;
	$.fn.permissionMatrix._initialized = false;


	// Another JQuery plugin to get the object access permissions (per field/role) from a matrix
	$.fn.getPermissions = function() {
		var table = $('table.permissionMatrix', this);
		var permissions = [];

		$('th.permOwner', table).each(function() {
			var owner = $(this);
			var checkboxes = null;
			var permission = { access: 0 };

			var role = owner.data('role');
			if (role) {
				permission.role = role.id;
				checkboxes = 'input[type="checkbox"][data-owner="role-' + role.id + '"]:checked';
			} else {
				var field = owner.data('field');
				if (field) {
					permission.field = field.id;
					checkboxes = 'input[type="checkbox"][data-owner="field-' + field.id + '"]:checked';
				}
			}

			if (checkboxes) {
				$(checkboxes, table).each(function() {
					var granted = $(this).closest('tr').data('permission');
					permission.access |= granted.id;
				});
			}

			if ((permission.access > 0 && permission.field != null) || permission.role != null) {
				permissions.push(permission);
			}
		});

		return permissions;
	};

	/**
	 * Returns a native(!) DOM element according to the specified arguments.
	 * @param table
	 * @param owner
	 * @param permission
	 * @returns {*}
	 */
	function getCheckbox(table, owner, permission) {
		// Complex selector below is very slow in IE8, need some cache speed up.
		// checkboxCache property is already built and set upon initialization.
		var key = hashCheckbox(owner || "", permission);
		if (!(key in checkboxCache)) {
			checkboxCache[key] = $(document.getElementById(key)).not('.alwaysChecked').get(0);
		}
		return checkboxCache[key];
	}

	var enable = function(cb) {
		if (cb != null) {
			cb.disabled = false;
		}
	};

	var uncheckAndDisable = function(cb) {
		if (cb != null) {
			cb.checked = false;
			cb.disabled = true;
		}
	};

	var isChecked = function(cb) {
		return !!(cb && cb.checked);
	};

	function checkEditDependencies(table, checkbox, other) {
		var owner = checkbox.attr('data-owner');
		var enabled = isChecked(checkbox.get(0));

		if (enabled) {
			enable(getCheckbox(table, owner, 32)); // issue_mass_edit
			enable(getCheckbox(table, owner, 64)); // issue_close
			enable(getCheckbox(table, owner, 128)); // issue_delete
		} else if (!isChecked(getCheckbox(table, owner, other))) {
			uncheckAndDisable(getCheckbox(table, owner, 32)); // issue_mass_edit
			uncheckAndDisable(getCheckbox(table, owner, 64)); // issue_close
			uncheckAndDisable(getCheckbox(table, owner, 128)); // issue_delete
		}

		checkGrantRevokeCheckBoxes(table);
	}

	function updatePublicView(table, checkbox){
		var owner = checkbox.attr('data-owner');
		var enabled = isChecked(checkbox.get(0));

		if (enabled) {
			enable(getCheckbox(table, owner, 1048576));
		}
		else {
			uncheckAndDisable(getCheckbox(table, owner, 1048576));
		}
	}

	function checkAttachmentDependencies(table, checkbox) {
		var owner = checkbox.attr('data-owner');
		var enabled = isChecked(checkbox.get(0));

		if (enabled) {
			enable(getCheckbox(table, owner, 2048)); // issue_comment_add
			enable(getCheckbox(table, owner, 4096)); // issue_attachment_add
			enable(getCheckbox(table, owner, 8192)); // issue_attachment_edit
			enable(getCheckbox(table, owner, 16384)); // issue_attachment_edit_own
		} else {
			uncheckAndDisable(getCheckbox(table, owner, 2048)); // issue_comment_add
			uncheckAndDisable(getCheckbox(table, owner, 4096)); // issue_attachment_add
			uncheckAndDisable(getCheckbox(table, owner, 8192)); // issue_attachment_edit
			uncheckAndDisable(getCheckbox(table, owner, 16384)); // issue_attachment_edit_own
		}
		
		checkGrantRevokeCheckBoxes(table);
	}

	function checkGrantRevokeCheckBoxes(table) {
		table.find("td.grantRevokeAll").each(function() {
			var grantRevokeCheckBox = this.firstChild;
			var row = $(this.parentNode);
			var key = row.index();
			if (!(key in rowCbCache) || !$.contains(document.documentElement, rowCbCache[key][0])) { // first element is detached
				rowCbCache[key] = row.children(':not(.grantRevokeAll,.alwaysChecked)').children('input[type="checkbox"]');
			}
			var allEnabledCheckBoxes = rowCbCache[key].filter(":enabled");
			if (allEnabledCheckBoxes.length === 0) {
				uncheckAndDisable(grantRevokeCheckBox);
			} else {
				grantRevokeCheckBox.checked = allEnabledCheckBoxes.filter(':not(:checked)').length === 0;
				grantRevokeCheckBox.disabled = false;
			}
		});
		checkAdminCheckoutCloneChecked(table);
	}

	function checkAdminCheckoutCloneChecked(table) {
		var checkbox = getCheckbox(table, "role-1", 1048576);
		if (checkbox) {
			var checked = isChecked(checkbox);

			// scm_repository_push
			var adminCommitCheckbox = getCheckbox(table, "role-1", 8);
			if (adminCommitCheckbox) {
				adminCommitCheckbox.disabled = true;
				adminCommitCheckbox.checked = checked;
			}

			// SCM Repository - Update Own Changesets
			var adminUpdateOwnChangesetCheckbox = getCheckbox(table, "role-1", 16);
			if (adminUpdateOwnChangesetCheckbox) {
				adminUpdateOwnChangesetCheckbox.disabled = true;
				adminUpdateOwnChangesetCheckbox.checked = checked;
			}
		}
	}

	// A third plugin to enforce dependencies between tracker permissions
	$.fn.trackerPermissionDependencies = function(extension) {

		function includeIssueViewIfOwner(table, checkbox){
			includePermission(table, checkbox, 1, 4);
		}

		function includeIssueEditIfOwner(table, checkbox){
			includePermission(table, checkbox, 2, 16);
		}

		function includePermission(table, checkbox, sourcePerm, targetPerm){
			var owner = checkbox.attr('data-owner');
			var otherbox = $(getCheckbox(table, owner, targetPerm));
			var checkboxTitle = otherbox.parent().prop("title");
			var permissionName = $("#---"+sourcePerm).closest(".permission").text();
			var tooltipPostfix = " - " + i18n.message("permission.matrix.need.uncheck", permissionName);

			if (checkbox.is(':checked')){
				otherbox.prop('checked', true);
				otherbox.prop("disabled", true);

				// append the tooltip if it is not appended yet
				if (!(checkboxTitle.slice(-tooltipPostfix.length) === tooltipPostfix)){
					checkboxTitle += tooltipPostfix;
				}
				otherbox.parent().prop("title", checkboxTitle);

				checkGrantRevokeCheckBoxes(table);
				checkAdminCheckoutCloneChecked(table);
			}
			else {
				otherbox.prop("disabled", false);
				checkboxTitle = checkboxTitle.replace(tooltipPostfix, "");
				otherbox.parent().prop("title", checkboxTitle);
			}
		}

		function processDependentCheckboxState(table, checkbox, other){
			var owner = checkbox.attr('data-owner');
			var otherbox = $(getCheckbox(table, owner, other));

			if (checkbox.is(':checked')){
				otherbox.prop("disabled", false);
			}
			else {
				otherbox.prop("disabled", true);
				otherbox.prop('checked', false);
			}
		}

		function checkDependentCheckboxState(table, checkbox, other){
			var owner = checkbox.attr('data-owner');
			var otherbox = $(getCheckbox(table, owner, other));

			if (otherbox.is(':checked')){
				checkbox.prop("disabled", false);
			}
			else {
				checkbox.prop("disabled", true);
				checkbox.prop('checked', false);
			}
		}

		function checkViewDependencies(table, checkbox, other) {
			var owner = checkbox.attr('data-owner');
			var otherbox = $(getCheckbox(table, owner, other));

			if (checkbox.is(':checked')) {
				$('input[type="checkbox"][data-owner="' + owner + '"]:disabled', table).filter(':not(.alwaysChecked)').each(function() {
					var dependent = $(this);
					if (!(dependent.is(checkbox) || dependent.is(otherbox))) {
						dependent.attr('disabled', false);
					}
				});

				// Issue-Edit-Not-Own only if Issue-View-Not-Own !!
				if (other == 1 && !otherbox.is(':checked')) {
					uncheckAndDisable(getCheckbox(table, owner, 2));
				}

				includePermission(table, $(getCheckbox(table, owner, 1)), 1, 4);
				includePermission(table, $(getCheckbox(table, owner, 2)), 2, 16);

				checkEditDependencies(table, $(getCheckbox(table, owner, 16), 2)); // issue_edit[_not_own]
				checkAttachmentDependencies(table, $(getCheckbox(table, owner, 1024))); // issue_attachment_view

				processDependentCheckboxState(table, $(getCheckbox(table, owner, 16384)), 8192);
				processDependentCheckboxState(table, $(getCheckbox(table, owner, 32768)), 65536);
				processDependentCheckboxState(table, $(getCheckbox(table, owner, 131072)), 262144);

				checkDependentCheckboxState(table, $(getCheckbox(table, owner, 8192)), 16384);
				checkDependentCheckboxState(table, $(getCheckbox(table, owner, 65536)), 32768);
				checkDependentCheckboxState(table, $(getCheckbox(table, owner, 262144)), 131072);

				checkAdminCheckoutCloneChecked(table);
			} else if (!otherbox.is(':checked')) {
				$('input[type="checkbox"][data-owner="' + owner + '"]:enabled', table).filter(':not(.alwaysChecked)').each(function() {
					var dependent = $(this);
					if (!(dependent.is(checkbox) || dependent.is(otherbox))) {
						dependent.attr('checked', false).attr('disabled', true);
					}
				});
			} else if (other == 4) { //'issue_view'
				uncheckAndDisable(getCheckbox(table, owner, 2));
			}

			checkGrantRevokeCheckBoxes(table);
			checkAdminCheckoutCloneChecked(table);

		}

		var table = $('table.permissionMatrix', this);

		$('tr.permission', table).each(function() {
			$.fn.permissionMatrix._initialized = false;

			var row = $(this);
			var permission = row.data('permission');

			$('input[type="checkbox"]', row).filter(':not(.alwaysChecked)').each(function() {
				var checkbox = $(this);
				var processed = false;

				if (extension != null) {
					processed = extension(table, permission, checkbox);
				}

				if (!processed) {
					switch (permission.id) {
						case 1: //issue_view_not_own
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && checkViewDependencies(table, checkbox, 4);
								$.fn.permissionMatrix._initialized && includeIssueViewIfOwner(table, checkbox);
								$.fn.permissionMatrix._initialized && updatePublicView(table, checkbox);
								$.fn.permissionMatrix._initialized && includeIssueEditIfOwner(table, $(getCheckbox(table, checkbox.attr('data-owner'), 2)));
							});
							updatePublicView(table, checkbox);
							break;
						case 2: // issue_edit_not_own
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && checkEditDependencies(table, checkbox, 16);
								$.fn.permissionMatrix._initialized && includeIssueEditIfOwner(table, checkbox);
							});
							break;
						case 4: //issue_view
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && checkViewDependencies(table, checkbox, 1);
							});
							checkViewDependencies(table, checkbox, 1);
							break;
						case 8: // issue_add
							checkbox.change(function() {
								// update the brahc_merge checkbox state
								$.fn.permissionMatrix._initialized && processDependentCheckboxState(table, checkbox, 16777216);
							});
							break;
						case 16: // issue_edit
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && checkEditDependencies(table, checkbox, 2);
							});
							checkEditDependencies(table, checkbox, 2);
							break;
						case 1024: // issue_attachment_view
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && checkAttachmentDependencies(table, checkbox);
								$.fn.permissionMatrix._initialized && processDependentCheckboxState(table, $(getCheckbox(table, checkbox.attr('data-owner'), 16384)), 8192);
							});
							checkAttachmentDependencies(table, checkbox);
							break;
						case 8192:
							checkDependentCheckboxState(table, checkbox, 16384);
							break;
						case 16384: // edit_comment_if_own
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && processDependentCheckboxState(table, checkbox, 8192);
							});
							break;
						case 32768: // issue_subscribe
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && processDependentCheckboxState(table, checkbox, 65536);
							});
							break;
						case 65536:
							checkDependentCheckboxState(table, checkbox, 32768);
							break;
						case 131072: // tracker_subscribe
							checkbox.change(function() {
								$.fn.permissionMatrix._initialized && processDependentCheckboxState(table, checkbox, 262144);
							});
							break;
						case 262144:
							checkDependentCheckboxState(table, checkbox, 131072);
							break;
						case 16777216: // branch_merge
							checkDependentCheckboxState(table, checkbox, 8);
							break;
					}
				}

			});
		});

		checkGrantRevokeCheckBoxes(table);
		$.fn.permissionMatrix._initialized = true;
	};


	// A fourth plugin to enforce dependencies between repository permissions
	$.fn.repositoryPermissionDependencies = function(extension) {

		function checkBrowseDependencies(table, checkbox, admin) {
			var owner = checkbox.attr('data-owner');
			var adminbox = $(getCheckbox(table, owner, admin));

			if (checkbox.is(':checked')) {
				$('input[type="checkbox"][data-owner="' + owner + '"]:disabled', table).filter(':not(.alwaysChecked)').each(function() {
					var dependent = $(this);
					if (!(dependent.is(checkbox) || dependent.is(adminbox))) {
						dependent.attr('disabled', false);
					}
				});

				checkCloneDependencies(table, $(getCheckbox(table, owner, 1048576)));
				checkEditDependencies(table, $(getCheckbox(table, owner, 16)), 2); // issue_edit[_not_own]
				checkAttachmentDependencies(table, $(getCheckbox(table, owner, 1024))); // issue_attachment_view

			} else {
				$('input[type="checkbox"][data-owner="' + owner + '"]:enabled', table).filter(':not(.alwaysChecked)').each(function() {
					var dependent = $(this);
					if (!(dependent.is(checkbox) || dependent.is(adminbox))) {
						dependent.attr('checked', false).attr('disabled', true);
					}
				});
			}

			checkGrantRevokeCheckBoxes(table);
		}

		function checkCloneDependencies(table, checkbox) {
			var owner = checkbox.attr('data-owner');
			var enabled = checkbox.is(':checked');

			if (enabled) {
				enable(getCheckbox(table, owner, 8)); // scm_repository_push
				enable(getCheckbox(table, owner, 2097152)); // scm_repository_fork
			} else {
				uncheckAndDisable(getCheckbox(table, owner, 8));  // scm_repository_push
				uncheckAndDisable(getCheckbox(table, owner, 2097152));  // scm_repository_fork
			}

			checkPushDependencies(table, $(getCheckbox(table, owner, 8)));
		}

		function checkPushDependencies(table, checkbox) {
			var owner = checkbox.attr('data-owner');
			var enabled = checkbox.is(':checked');

			if (enabled) {
				enable(getCheckbox(table, owner, 16)); // scm_repository_update_changeset_own
				enable(getCheckbox(table, owner, 4194304)); // scm_repository_create_remote_branch
			} else {
				uncheckAndDisable(getCheckbox(table, owner, 16)); // scm_repository_update_changeset_own
				uncheckAndDisable(getCheckbox(table, owner, 4194304)); // scm_repository_create_remote_branch
			}

			checkGrantRevokeCheckBoxes(table);
		}

		/*function checkViewDependencies(table, checkbox, other) {
		 var owner = checkbox.attr('data-owner');
		 var otherbox = $(getCheckbox(table, owner, other));

		 if (checkbox.is(':checked')) {
		 $('input[type="checkbox"][data-owner="' + owner + '"]:disabled', table).filter(':not(.alwaysChecked)').each(function() {
		 var dependent = $(this);
		 if (!(dependent.is(checkbox) || dependent.is(otherbox))) {
		 dependent.attr('disabled', false);
		 }
		 });

		 // Issue-Edit-Not-Own only if Issue-View-Not-Own !!
		 if (other == 1 && !otherbox.is(':checked')) {
		 uncheckAndDisable(getCheckbox(table, owner, 2));
		 }

		 checkEditDependencies(table, $(getCheckbox(table, owner, 16)), 2); // issue_edit[_not_own]
		 checkAttachmentDependencies(table, $(getCheckbox(table, owner, 1024))); // issue_attachment_view
		 checkAdminCheckoutCloneChecked(table);
		 } else if (!otherbox.is(':checked')) {
		 $('input[type="checkbox"][data-owner="' + owner + '"]:enabled', table).filter(':not(.alwaysChecked)').each(function() {
		 var dependent = $(this);
		 if (!(dependent.is(checkbox) || dependent.is(otherbox))) {
		 dependent.attr('checked', false).attr('disabled', true);
		 }
		 });
		 } else if (other == 4) { //'issue_view'
		 uncheckAndDisable(getCheckbox(table, owner, 2));
		 }

		 checkGrantRevokeCheckBoxes(table);
		 checkAdminCheckoutCloneChecked(table);

		 }*/

		this.trackerPermissionDependencies(function(table, permission, checkbox) {
			var processed = false;

			if (extension != null) {
				processed = extension(table, permission, checkbox);
			}

			if (!processed) {
				switch (permission.id) {
					case 1: //scm_repository_browse
						checkbox.change(function() {
							checkBrowseDependencies(table, checkbox, 8388608);
						});
						checkbox.change();
						processed = true;
						break;
					case 4: //scm_repository_view_changeset
						checkbox.change(function() {
							checkBrowseDependencies(table, checkbox, 8388608);
						});
						processed = true;
						break;
					case 8: //scm_repository_push
						checkbox.change(function() {
							checkPushDependencies(table, checkbox);
						});
						processed = true;
						break;
					case 1048576: // scm_repository_clone
						checkbox.change(function() {
							checkCloneDependencies(table, checkbox);
						});
						checkbox.change();
						processed = true;
						break;
					case 8388608: //scm_repository_admin
						checkbox.change(function() {
							// checkViewDependencies(table, checkbox, 4);
						});
						processed = true;
						break;
				}
			}

			checkGrantRevokeCheckBoxes(table);
			return processed;
		});

	};


})(jQuery);