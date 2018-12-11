/**
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
var codebeamer = codebeamer || {};
codebeamer.dashboard = codebeamer.dashboard || {};
codebeamer.dashboard.userEditor = codebeamer.dashboard.userEditor || (function($) {

	function renderUsers(result, $selector, checked) {
		$selector.empty();

		if (result.hasOwnProperty("users")) {
			var $usersOptGroup = $("<optgroup>", { "label" : i18n.message("tracker.field.Users.label")});
			for (var i = 0; i < result.users.length; i++) {
				var user = result.users[i];

				var $option = $("<option>", { value : "user_" + user.id }).text(user.aliasName + " (" + user.realName + (user.emailDomain.length > 0 ? ", " + user.emailDomain : "") + ")")

				if (checked.indexOf("user_" + user.id) >= 0) {
					$option.attr("selected", "selected");
				}

				$usersOptGroup.append($option);
			}
			$selector.append($usersOptGroup);
		}

		if (result.hasOwnProperty("roles")) {
			var $roleOptGroup = $("<optgroup>", { "label" : i18n.message("tracker.fieldAccess.roles.label")});
			for (var i = 0; i < result.roles.length; i++) {
				var role = result.roles[i];

				var $option = $("<option>", { value : "role_" + role.roleId, "class": "roleOption" }).text(role.roleLabel);

				if (checked.indexOf("role_" + role.roleId) >= 0) {
					$option.attr("selected", "selected");
				}

				$roleOptGroup.append($option);
			}
			$selector.append($roleOptGroup);
		}
	};

	function getUserChoicesJSON(projectIds, userQueryUrl, $selector) {
		$.getJSON(userQueryUrl, { project_id_list : projectIds.join(",")}).done(function(result) {
			var checked = [];

			$selector.multiselect("getChecked").each(function() {
				checked.push(this.value);
			});

			renderUsers(result, $selector, checked);

			$selector.multiselect("refresh");
		});
	};

	function getUsersAndRoles(projectIds, userQueryUrl, selectorId) {
		getUserChoicesJSON(projectIds, userQueryUrl, $("#" + selectorId));
	};

	return {
		"getUsersAndRoles": getUsersAndRoles
	};

})(jQuery);