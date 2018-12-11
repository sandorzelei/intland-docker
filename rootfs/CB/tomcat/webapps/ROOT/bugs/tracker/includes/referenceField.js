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

	// A JQuery plugin version of the chooseReferencesUI.tag
	$.fn.referenceField = function(references, field) {
		var settings = $.extend( {}, $.fn.referenceField.defaults, field );

		if (!$.isArray(references)) {
			references = [];
		}

		function encodeSpecialValues(special) {
			if ($.isArray(special)) {
				var result = [];
				for (var i = 0; i < special.length; ++i) {
					var value = special[i];
					if (value && value.value && value.label) {
						result.push(value.value);
						result.push(value.label);
					}
				}

				return result.join('|');

			} else if (typeof(special) == 'object') {
				var result = [];
				for (var value in special) {
					var label = special[value];
					if (label) {
						result.push(value);
						result.push(label);
					}
				}

				return result.join('|');
			}

			return special;
		}

		function init(container, references) {
			var htmlId = settings.htmlId ? settings.htmlId : $.fn.referenceField.nextId++;
			var values = [];
			var params = {};

			for (var setting in settings.ajaxParams) {
				var value = settings[setting];
				// The server default is allowUserSelection=true and we must be able to disable it !!
				if (value || (setting == 'allowUserSelection' && typeof value === 'boolean')) {
					if (setting == 'specialValues') {
						value = encodeSpecialValues(value);
					}

					params[settings.ajaxParams[setting]] = value;
				}
			}

			var table = $('<table>', {
				border 		: 0,
				cellspacing : 0,
				cellpadding : 0,
				"class" 	: 'chooseReferences fullExpandTable' + (settings.editable ? '' : ' chooseReferencesDisabled'),
				title 		: settings.title
			});
			container.append(table);

			var row = $('<tr>');
			table.append(row);

			var col1 = $('<td>', { style: "white-space:normal;" });
			row.append(col1);

			var existingJSON = [];
			for (var i=0; i < references.length; i++) {
				var reference = references[i];
				values.push(reference.value);
				existingJSON.push(reference);
			}

			var refs = $('<div>', {
				 id 						: 'referencesForLabel_' + htmlId,
				"class" 					: 'yui-multibox reference-box',
				"data-htmlId"				: htmlId,
				"data-workItemMode"			: settings.workItemMode,
				"data-workItemTrackerIds"	: settings.workItemTrackerIds,
				"data-reportMode"			: settings.reportMode,
				"data-userSelectorMode" 	: (settings.type == 5),
				"data-multiSelect" 			: settings.multiple,
				"data-emptyId"				: settings.emptyValue,
				"data-removeDoNotModifyBox"	: true,
				"data-ajaxURLParameters" 	: $.param(params, true),
				"data-referencesJSON"		: JSON.stringify(existingJSON)
			});

			if ($.isFunction(settings.context)) {
				refs.data('context', settings.context);
			}

			if ($.isFunction(settings.callback)) {
				refs.data('callback', settings.callback);
			}

			if ($.isFunction(settings.onChangeCallback)) {
				refs.data('onChangeCallback', settings.onChangeCallback);
			}

			col1.append(refs);

			var csvs = $('<input>', { type : 'hidden', id : 'dynamicChoice_references_' + htmlId, name : settings.htmlName, value : values.join(',') });
			refs.append(csvs);

			if (settings.editable) {
				var editor = $('<input>', { id : 'dynamicChoice_references_autocomplete_editor_' + htmlId, type : 'text', value : '', "class" : 'yui-ac-input' });
				refs.append(editor);
				refs.click(function() {
					editor.focus();
				});

				// Append dialog
				refs.append(ajaxReferenceFieldAutoComplete.renderReferenceSettingDialog(htmlId));

				refs.append($('<div>', { "class" : 'yui-ac-container', id : 'dynamicChoice_references_autocomplete_container_' + htmlId }));
				refs.append($('<div>', { "class" : 'yui-multibox-clear' }));

				var col2 = $('<td>', { style : "vertical-align: top; width:1%;" });
				row.append(col2);

				var popup = $('<span>', { title : settings.title });
				popup.append($('<a>', { "class" : 'popupButton' }).text(' '));
				col2.append(popup);

				params["htmlId"]    = htmlId;
				params["fieldName"] = settings.htmlName;
				params["opener_htmlId"]    = htmlId;
				params["opener_fieldName"] = encodeURIComponent(settings.htmlName);

				popup.click(function() {
					if (settings.type == 5) {
						chooseReferences.showUserSelectorPopup(htmlId, $.param(params, true), null);
					} else {
						chooseReferences.selectReferences(htmlId, $.param(params, true), null, settings.reportMode);
					}
					return false;
				});
			}
		}

		return this.each(function() {
			init($(this), references);
		});
	};

	$.fn.referenceField.defaults = {
		htmlId			: null,
		htmlName		: null,
		editable		: true,
		multiple		: false,
		showUnset		: false,
		name			: '',
		title			: '',
		emptyValue 		: '',
		emptyLabel 		: '--',
		defaultValue	: '',
		defaultLabel	: '',
		context			: null,
		callback		: null,
		onChangeCallback: null,
		workItemMode	: false,
		workItemTrackerIds : '',
		reportMode		: false,
		ajaxParams			: {
			trackerId			: 'tracker_id',
			id					: 'labelId',
			taskId				: 'task_id',
			statusId			: 'status_id',
			transitionId		: 'transition_id',
			multiple			: 'forceMultiSelect',
			showUnset 			: 'show_unset',
			defaultValue		: 'defaultValue',
			defaultLabel		: 'setToDefaultLabel',
			workItemMode		: 'workItemMode',
			workItemTrackerIds	: 'workItemTrackerIds',
			reportMode			: 'reportMode',
			specialValues		: 'labelMap',
			specialValueResolver: 'specialValueResolver'
		}
	};

	$.fn.referenceField.nextId = 0;


	$.fn.referenceFieldAutoComplete = function() {
		return this.each(function() {
    		ajaxReferenceFieldAutoComplete.bindAfterLoading.apply(this, [this]);
		});
	};


	// A JQuery plugin version of the userSelector.tag
	$.fn.membersField = function(members, field) {

		var settings = $.extend( {}, $.fn.membersField.defaults, field );

		if (field.multiple) {
			settings.singleSelect = false;

			if (!(typeof(field.allowRoleSelection) === 'boolean')) {
				settings.allowRoleSelection = true;
			}
		}

		if (field.trackerId) {
//			settings.searchOnTracker = true;
		} else {
			settings.searchOnTracker  = false;
			settings.searchOnAllUsers = true;
		}

		settings.specialValueResolver = 'com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorSpecialValues';

		return this.referenceField(members, settings);
	};


	$.fn.membersField.defaults = {
		type				: 5,
		name				: '',
		title				: '',
		emptyValue 			: '',
		emptyLabel 			: '--',
		defaultValue		: '',
		defaultLabel		: '',
		showUnset			: false,
		showCurrentUser		: false,
		showSystemUser		: false,
		searchOnAllUsers	: false,
		includeDisabledUsers: false,
		searchOnTracker		: true,
		singleSelect		: false,
		allowUserSelection 	: true,
		allowRoleSelection	: false,
		allowGroupSelection : false,
		allowMemberFields	: false,
		ajaxParams			: {
			trackerId			: 'tracker_id',
			id					: 'labelId',
			taskId				: 'task_id',
			statusId			: 'status_id',
			transitionId		: 'transition_id',
			showUnset 			: 'show_unset',
			showCurrentUser		: 'show_current_user',
			showSystemUser		: 'showSystemUser',
			searchOnAllUsers	: 'searchOnAllUsers',
			includeDisabledUsers: 'includeDisabledUsers',
			searchOnTracker 	: 'onlyUsersAndRolesWithPermissionsOnTracker',
			projectList			: 'project_list',
			requiredRoles		: 'required_roles',
			memberType			: 'memberType',
			allowUserSelection 	: 'allowUserSelection',
			allowGroupSelection : 'allowGroupSelection',
			allowRoleSelection 	: 'allowRoleSelection',
			allowMemberFields  	: 'allowMemberFields',
			singleSelect		: 'singleSelect',
			defaultValue		: 'defaultValue',
			defaultLabel		: 'setToDefaultLabel',
			specialValues		: 'labelMap',
			specialValueResolver: 'specialValueResolver'
		}
	};

	$.fn.getReferences = function() {

		var result = [];
		var refIds = $('input[type="hidden"]', this).val().split(',');
		var labels = [];
		$("ul > li > p", this).each(function() {
			labels.push($(this).text());
		});
		var tokenSettings = [];
		$(".tokenSetting", this).each(function() {
			var setting = $(this);
			tokenSettings.push({
				propagateSuspects: setting.attr("data-propagate-suspects"),
				reverseSuspect: setting.attr("data-reverse-suspect"),
				bidirectionalSuspect: setting.attr("data-bidirectional-suspect"),
				suspected: setting.attr("data-suspected"),
				propagateDependencies: setting.attr("data-propagate-dependencies"),
				version: setting.attr("data-version"),
				associationId: setting.attr("data-association-id"),
				trackerItemId: setting.attr("data-tracker-item-id")
			});
		});

		for (var i = 0; i < refIds.length; i++) {
			if (refIds[i] && refIds[i].length > 0) {
				var resultObj = {
					id: refIds[i],
					value : refIds[i],
					label : labels[i],
					tooltip : '',
					shortHTML : labels[i]
				};
				if (tokenSettings.length > 0) {
					try {
						resultObj["propagateSuspects"] = tokenSettings[i].propagateSuspects;
						resultObj["reverseSuspect"] = tokenSettings[i].reverseSuspect;
						resultObj["bidirectionalSuspect"] = tokenSettings[i].bidirectionalSuspect;
						resultObj["suspected"] = tokenSettings[i].suspected;
						resultObj["propagateDependencies"] = tokenSettings[i].propagateDependencies;
						resultObj["unresolvedDependencies"] = tokenSettings[i].unresolvedDependencies;
						resultObj["version"] = tokenSettings[i].version;
						resultObj["associationId"] = tokenSettings[i].associationId;
						resultObj["trackerItemId"] = tokenSettings[i].trackerItemId;
					} catch (ex) {
						//
					}
				}
				result.push(resultObj);
			}
		}

		return result;
	};


})( jQuery );
