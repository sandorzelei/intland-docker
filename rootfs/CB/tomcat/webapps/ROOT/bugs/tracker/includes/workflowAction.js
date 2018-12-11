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

	function getActionClass(clazzes, name) {
		if (name) {
			for (var i = 0; i < clazzes.length; ++i) {
				if (clazzes[i].name == name) {
					return clazzes[i];
				}
			}
		}

		return null;
	}

	function getActionClazz(action, settings) {
		if (!$.isPlainObject(action.clazz)) {
			action.clazz = getActionClass(settings.actionClasses, action.name);
		}
		return action.clazz;
	}

	function getReferenceType(types, value) {
		if (types && value) {
			for (var i = 0; i < types.length; ++i) {
				if (types[i].value == value) {
					return types[i];
				}
			}
		}

		return null;
	}

	function getRefTypeTracker(type, trackerId) {
		if (type && type.trackers && trackerId) {
			for (var i = 0; i < type.trackers.length; ++i) {
				if (type.trackers[i].id == trackerId) {
					return type.trackers[i];
				}
			}
		}

		return null;
	}

	function getTrackerStatus(tracker, statusId) {
		if (tracker && tracker.statusOptions && statusId) {
			for (var i = 0; i < tracker.statusOptions.length; ++i) {
				if (tracker.statusOptions[i].id == statusId) {
					return tracker.statusOptions[i];
				}
			}
		}

		return null;
	}

	function getReference(action, settings) {
		var result = action.reference;
		if (result && result.refType) {
			if (typeof result.refType === 'string') {
				result.refType = getReferenceType(settings.referenceTypes, result.refType);
				result.tracker = getRefTypeTracker(result.refType, result.tracker);
				result.status  = getTrackerStatus(result.tracker, result.status);
			}
		} else {
			result = null;
		}

		return result;
	}

	function getFullActionName(action, settings) {
		var clazz = getActionClazz(action, settings);
		var result;

		if (action.condition && action.condition.name) {
			result = '[' + action.condition.name + '] ';
		} else {
			result = '';
		}

		var reference =	getReference(action, settings);
		if (reference && reference.tracker && settings.refActionPatterns[clazz.name]) {
			result += settings.refActionPatterns[clazz.name].replace('<refType>', reference.refType.label)
															.replace('<tracker>', reference.tracker.project.name + ' \u00BB ' +
																				  reference.tracker.scopeName + ' \u00BB ' +
																				  reference.tracker.name);
			if (result.indexOf('<status>') >= 0) {
				result = result.replace('<status>', reference.status ? reference.status.name : 'Undefined' );
			}
		} else {
			result += clazz.label;
		}

		return result;
	}

	function handleActionEditDialogOpen() {
		var $tagInput = $(this).find('.tag-input');
		initEntityLabelAutocomplete($tagInput, { ignorePrivateLabels: true });
		if ($tagInput.length) {
			$tagInput.autocomplete('option', 'appendTo', '.popup.edit-action-dialog')
		}
	}
	
	/**
	 * Workflow action Editor Plugin definition.
	 * - context must be an object, with at least
	 *    + tracker : an object with at least id, name and project (id and name)
	 *    + status  : either an object with at least id and name or a function, that returns a status object
	 *    + fields  : either an array of the accessible tracker fields (in the specified status) or a function, that  returns such a field array
	 */
	$.fn.workflowActionEditor = function(context, action, options) {
		var settings         = $.extend({}, $.fn.workflowActionEditor.defaults, options);
		settings.executeAs   = $.extend({}, $.fn.workflowActionEditor.defaults.executeAs,	options.executeAs);
		settings.association = $.extend({}, $.fn.workflowActionEditor.defaults.association,	options.association);
		settings.condition   = $.extend({}, $.fn.workflowActionEditor.defaults.condition,	options.condition);
		settings.condition.nameLabel = settings.nameLabel;


		function getSetting(name) {
			return settings[name];
		}

		function getConditionSelector(condition) {
			var selector = $('<select>', { name : 'conditionId', "class" : 'conditionSelector' });

			selector.append($('<option>', { value : '' }).text(settings.condition.none));

			$.get(settings.trackerFiltersUrl, {
	        	tracker_id : context.tracker.id,
	        	viewTypeId : $.isArray(settings.condition.viewTypeId) ? settings.condition.viewTypeId.join(',') : settings.condition.viewTypeId
	        }).done(function(filters) {
        		// BUG-873381: If filter/view is overloaded or replaced by materialized view, the id changes, so we must base selected on the name, not the id
	    		for (var i = 0; i < filters.length; ++i) {
					selector.append($('<option>', { value : filters[i].id, title : filters[i].description, selected : (condition && condition.name == filters[i].name) }).text(filters[i].name).data("creationType", filters[i].descFormat));
	    		}
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });

			return selector;
		}

		function showConditionEditor(selector, condition, callback) {
			var view = {
				tracker_id      : context.tracker.id,
				viewTypeId      : $.isArray(settings.condition.viewTypeId) ? settings.condition.viewTypeId[settings.condition.viewTypeId.length - 1] : settings.condition.viewTypeId,
				viewLayoutId    : 0,
				forcePublicView : true
	  		};

			if (condition && condition.id) {
				view.view_id = condition.id;
			}

			var popup = selector.next('div.conditionEditorPopup');
			if (popup.length == 0) {
				popup = $('<div>', { "class" : 'conditionEditorPopup', style : 'display: None;'} );
				popup.insertAfter(selector);
			}

			popup.showTrackerViewConfigurationDialog(view, settings.condition, {
				title			: condition && condition.id ? settings.condition.editLabel + ": " +  condition.name : settings.condition.newTitle,
				position		: { my: "left top", at: "left top", of: selector, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				editable		: true,
				viewUrl			: settings.trackerViewUrl,
				submitText		: settings.submitText,
				cancelText		: settings.cancelText,
				validator		: function(view, stats) {
					try {
						return settings.condition.validator(view, stats);
					} catch(ex) {
						alert(settings.condition[ex] || ex);
					}
					return false;
				}

			}, callback);
		}

		function validateConditionDeletion(conditionId, originalId) {
			var transitions = $('#adminTransitionPermissionForm').getStateTransitions(),
				editedTransition = $('#stateTransitionEditor:visible').getStateTransition(),
				transitionIds = [], // id of the state transitions which are using the deleted action condition
				counter = 0,
				valid = false;

			if ($.isArray(transitions)) {
				transitions.forEach(function(transition) {
					if (transition.guard && transition.guard.id == conditionId) {
						transitionIds.push(transition.id);
					}

					if ($.isArray(transition.actions)) {
						transition.actions.forEach(function(action) {
							if (action.condition && action.condition.id == conditionId) {
								transitionIds.push(transition.id);
							}
						});
					}
				});
			}

			if (editedTransition.actions) {
				editedTransition.actions.forEach(function(action) {
					if (action.condition && action.condition.id == conditionId) {
						counter++;
					}
				});
			}

			if (counter == 1 && conditionId == originalId) {
				transitionIds = transitionIds.filter(function(id) {
					return editedTransition.id != id;
				});
			}

			valid = transitionIds.length == 0;

			if (transitionIds.length == 1 && conditionId == originalId) {
				valid = editedTransition.id ? editedTransition.id == transitionIds[0] : true;
			}

			return valid;
		}

		function deleteCondition(conditionId, originalId, callback) {
			var message = settings.condition.deleteConfirm,
				warningMessage = '';

			if (!validateConditionDeletion(conditionId, originalId)) {
				warningMessage = i18n.message('tracker.action.condition.delete.invalid');
			}

			showFancyConfirmDialogWithCallbacks(warningMessage + message,
				function() {
					$.ajax(settings.trackerViewUrl + "?tracker_id=" + context.tracker.id + "&view_id=" + conditionId, {
						type : 'DELETE'
					}).done(callback).fail(function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
				    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			    		}
			        });
				});
		}

		function isValueSelected(value, selected) {
			if ($.isArray(selected)) {
				for (var i = 0; i < selected.length; ++i) {
					if (value == selected[i]) {
						return true;
					}
				}
			} else if (selected != null && value == selected) {
				return true;
			}
			return false;
		}

		function getOptionsSelector(special, options, selected, multiple, disabled) {
			var stringcmp = false;
			if (typeof selected === 'string') {
				selected = selected.split(',');
				stringcmp = true;
			}

			var selector = $('<select>', { name : 'value', multiple : multiple, disabled : disabled });
			if (special != null && special.length > 0) {
				for (var i = 0; i < special.length; ++i) {
					selector.append($('<option>', { value : special[i].value, title : special[i].title || special[i].description, selected : isValueSelected(special[i].value, selected) }).text(special[i].label || special[i].name));
				}
			}

			if (options != null && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					selector.append($('<option>', { value : options[i].id, title : options[i].title || options[i].description, selected : isValueSelected(stringcmp ? options[i].id.toString() : options[i].id, selected) }).text(options[i].label || options[i].name));
				}
			}

			return selector;
		}

		function getParamEditor(param, value, special) {
			var editor = null;

			if (param.type == 6 && !param.refType) { // choice
				editor = getOptionsSelector(special, param.options, value, param.multiple, !settings.editable);

			} else if (param.type == 92) { // field
				var options = [];

				var fields = $.isFunction(context.fields) ? context.fields() : context.fields;
				if ($.isArray(fields) && fields.length > 0) {
			    	var fldTypes = null;
			    	var refTypes = null;
			    	var multiple = false;

			    	if ($.isPlainObject(param.field)) {
			    		fldTypes = $.isArray(param.field.type)    ? param.field.type    : typeof param.field.type    === 'number' ? [param.field.type]    : null;
				    	refTypes = $.isArray(param.field.refType) ? param.field.refType : typeof param.field.refType === 'number' ? [param.field.refType] : null;
				    	multiple = param.field.multiple;
			    	}

					for (var i = 0; i < fields.length; ++i) {
						if ((fldTypes == null || isValueSelected(fields[i].type, fldTypes)) &&
							(refTypes == null || fields[i].type != 7 || isValueSelected(fields[i].refType, refTypes)) &&
							(!multiple || fields[i].multiple)) {
							options.push(fields[i]);
						}
					}
				}

 	        	editor = getOptionsSelector(special, options, value, param.multiple, !settings.editable);
			}

			return editor;
		}

		function getParameterHint(hint) {
			var $hintRow = $('<tr>', { 'class': 'hint-row' }),
				$hintCell = $('<td>', {'class': 'hint-cell' }),
				$hint = $('<div>', { 'class': 'subtext' }).html(hint);
			
			$hintCell.append($hint);
			$hintRow.append($('<td>'));
			$hintRow.append($hintCell);
			return $hintRow;
		}
		
		function showParameters(table, action) {
			var paramContext = $.extend( {}, context, {
				source 			: context,
				updateMandatory : true
			});

			if (!$.isPlainObject(action.parameters)) {
				action.parameters = {};
			}

			for (var i = 0; i < action.clazz.params.length; ++i) {
				var param 		= action.clazz.params[i];
				var paramValue  = action.parameters[param.name];

				var paramRow    = $('<tr>', { "class" : 'actionParam', title : param.title }).data('param', param);
				var paramLabel  = $('<td>', { "class" : 'labelCell ' + (param.required ? 'mandatory' : 'optional'), style : 'vertical-align: top;' }).text(param.label + ':');
				var paramCell   = $('<td>', { "class" : 'paramValue dataCell' });

				paramRow.append(paramLabel);
				paramRow.append(paramCell);
				table.append(paramRow);
				
				if (param.hint) {
					table.append(getParameterHint(param.hint));
				}
				
				if (param.type == 93) { // association
					paramCell.associationBetweenCopiedItems((paramValue ? paramValue.value : null) || param['default'], settings.association);

				} else if (param.type == 94) { // review
					paramCell.reviewConfiguration(context, (paramValue ? paramValue.value : null) || param['default'], settings.review);
				} else {
					var paramEditor = getParamEditor(param, (paramValue ? paramValue.value : null) || param['default'], param.required || param.multiple ? [] : [{value: '',  label: '--'}]);
					if (paramEditor != null) {
						paramCell.append(paramEditor);
						paramEditor.makeMultiSelect(param, settings.fieldUpdates);
					} else {
						paramCell.addClass('fieldUpdate');

						var noValue = !$.isPlainObject(paramValue);
						if (noValue) {
							paramValue = {
								op : 1
							};

							if (param['default']) {
								paramValue.value = param['default'];
								noValue = false;
							} else if (param.computeAs) {
								paramValue.computeAs = param.computeAs;
								noValue = false;
							}
						}

						paramCell.trackerFieldUpdate(paramContext, $.extend({}, param, {actionParam : true}), paramValue, settings.fieldUpdates);

						if (param.required && noValue) {
							paramCell.dblclick();
						}
					}
				}
			}
		}

		function showFieldUpdates(container, action) {
			var tracker = context.tracker;
			var status  = context.status;

			var reference =	getReference(action, settings);
			if (reference && reference.tracker) {
				tracker = reference.tracker;
				status  = reference.status;
			}

			var params = {
				tracker_id 	  : tracker.id,
				excludeStatus : (action.name == 'selfUpdates' || action.name == 'referringItemCreator')
			};

			if ($.isFunction(status)) {
				status = status();
			}
			if (status && status.id != null) {
				params.statusId = status.id;
			}

			if (action.name == 'referringItemCreator' && reference) {
				var sepIdx = reference.refType.value.indexOf('|');
				if (sepIdx > 0) {
					params.excludeField = reference.refType.value.substring(0, sepIdx);
				}
			}

			$.get(action.name == 'referringItemCreator' ? settings.newItemFieldsUrl : settings.trackerFieldsUrl, params).done(function(fields) {
				container.trackerFieldUpdates($.extend( {}, context, {
					tracker			: tracker,
					status 			: status,
					fields 			: fields,
					source			: context,
					allowClearAll	: action.name == 'selfUpdates',
					updateMandatory : action.name == 'referringItemCreator'
				}), action.fieldUpdates, settings.fieldUpdates);

	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });

			container.data('checkMandatory', action.name != 'selfUpdates');
		}

		function setup() {

		}

		function init(form, action) {
			if (!$.isPlainObject(action)) {
				action = {};
			}

			if (!$.isPlainObject(action.clazz)) {
				action.clazz = getActionClass(settings.actionClasses, action.name);
			}

			if (action.clazz) {
				action.name = action.clazz.name;

				var table = $('<table>', { "class" : 'actionParamEditor formTableWithSpacing' }).data('action', action);
				form.append(table);

				var conditionRow   = $('<tr>', { "class" : 'actionCondition', title : settings.condition.tooltip });
				var conditionLabel = $('<td>', { "class" : 'labelCell optional' }).text(settings.condition.label + ':');
				var conditionCell  = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox' });

				if (settings.editable) {
					conditionCell.append(getConditionSelector(action.condition));

					// add the crud links
					var newConditionLink = $("<a>", {"class": "edit-link", "title": settings.condition.newLabel}).html(settings.condition.newLabel);
					newConditionLink.click(function () {
						var selector = $(this).siblings("select");
						showConditionEditor(selector, null, function(view) {
							if (view && view.id > 0) {
								selector.append($('<option>', { value: view.id, title: view.description, selected: true }).text(view.name).data("creationType", "G"));
								selector.change();
							}
						});
					});


					var editConditionLink = $("<a>", {"class": "edit-link", "title": settings.condition.editLabel}).html(settings.condition.editLabel);
					editConditionLink.click(function () {
						var selector = $(this).siblings("select");;

						var conditionId = parseInt(selector.val());
						if (conditionId > 0) {
							var selected = $('option:selected', selector);

							showConditionEditor(selector, { id : conditionId, name : selected.text() }, function(view) {
								if (view && view.id > 0 && view.name != null) {
									selector.find('option[value="' + view.id + '"]').text(view.name).attr('title', view.description);
								}
							});
						}
					});

					var deleteConditionLink = $("<a>", {"class": "edit-link", "title": settings.condition.deleteLabel}).html(settings.condition.deleteLabel);
					deleteConditionLink.click(function () {
						var selector = $(this).siblings("select");

						var conditionId = parseInt(selector.val());
						if (conditionId > 0) {
							var selected = $('option:selected', selector);
							if (selected.data("creationType") == 'G') {
								deleteCondition(conditionId, action.condition ? action.condition.id : null, function() {
									var selector = selected.parent();
									selected.remove();
									selector.change();
						        });
							}
						}
					});

					conditionCell.append(newConditionLink);
					conditionCell.append(editConditionLink);
					conditionCell.append(deleteConditionLink);

					conditionCell.on("change", "select", function () {
						var conditionId = parseInt($(this).val());
						var editable = !isNaN(conditionId) && conditionId > 0;

						editConditionLink.toggle(editable);
						deleteConditionLink.toggle(editable);
					});

					var showActionLinks = !!action.condition;
					editConditionLink.toggle(showActionLinks);
					deleteConditionLink.toggle(showActionLinks);
				} else {
					conditionCell.text(action.condition && action.condition.name ? action.condition.name : settings.condition.none);
				}

				conditionRow.append(conditionLabel);
				conditionRow.append(conditionCell);
				table.append(conditionRow);

				if (action.clazz.helpUrl) {
					conditionCell.helpLink({
						URL   : action.clazz.helpUrl,
						title : action.clazz.title || action.clazz.label
					});
				}

				conditionCell.objectInfoBox(action, settings);

				var reference =	getReference(action, settings);
				if (reference && reference.tracker && reference.tracker.usingWorkflow) {
					var stateChartLink = $('<a>', {
											title : settings.stateChartTitle,
											style : 'float: right;',
											onclick : 'launch_url("' + settings.stateChartUrl + '?tracker_id=' + reference.tracker.id + '"); return false;'
										 });
					stateChartLink.append($('<img>', { src : settings.stateChartImageUrl, alt : settings.stateChartTitle }));
					conditionCell.append(stateChartLink);
				}

				var hasParameters = ($.isArray(action.clazz.params) && action.clazz.params.length > 0);
				if (hasParameters) {
					showParameters(table, action);
				}

				if (action.clazz.name == 'selfUpdates' || action.clazz.name == 'referringItemUpdater' || action.clazz.name == 'referringItemCreator') {
					var updatesRow   = $('<tr>');
					var updatesLabel = $('<td>', {
											"class" : 'labelCell mandatory',
											 title  :  action.clazz.name == 'referringItemCreator' ? settings.fieldValuesTooltip : settings.fieldUpdates.updatesTooltip,
											 style  : 'margin-top: 6px; vertical-align: top;'
									   }).text(
											(action.clazz.name == 'referringItemCreator' ? settings.fieldValuesLabel : settings.fieldUpdates.updatesLabel) + ':'
									   );
					var updatesCell  = $('<td>', { "class" : 'fieldUpdates'});

					showFieldUpdates(updatesCell, action);

					updatesRow.append(updatesLabel);
					updatesRow.append(updatesCell);
					table.append(updatesRow);
				}

				if (action.clazz.name == 'referringItemCreator') {

					var existingPropagateSuspects = action.referenceSettings ? action.referenceSettings.propagateSuspects : false;
					var existingReverseSuspect = action.referenceSettings ? action.referenceSettings.reverseSuspect : false;
					var existingBidirectionalSuspect = action.referenceSettings ? action.referenceSettings.bidirectionalSuspect : false;
					var existingPropagateDependencies = action.referenceSettings ? action.referenceSettings.propagateDependencies : false;
					var existingVersion = action.referenceSettings ? action.referenceSettings.version : "NONE";

					var referenceSettingRow = $('<tr>',	{ title : settings.referenceSettingTooltip });
					var referenceSettingLabel = $('<td>', { "class" : 'labelCell optional', "style" : "vertical-align: top" }).text(i18n.message('reference.suspected.setting.title') + ':');
					var referenceSettingCell   = $('<td>', { "class" : 'dataCell expandTextArea' });

					var propagateSettings = $('<div>', { style : 'padding: 0 5px 10px 0px', 'class': 'propagation-settings' });

					var propagateSuspectsCheckbox = $('<input>', { name: "propagateSuspects", type: "checkbox", disabled : !settings.editable, checked: existingPropagateSuspects});
					var propagateSuspectsLabel = $('<label>').text(settings.referenceSettingPropagateSuspects);

					var propagateSuspectsContainer = $('<div>', { 'class': 'propagateSuspectsContainer'});
					propagateSuspectsContainer.append(propagateSuspectsCheckbox).append(propagateSuspectsLabel);
					propagateSettings.append(propagateSuspectsContainer);

					var propagateOptions = $('<div>', { 'class': 'propagation-options' });
					propagateSettings.append(propagateOptions);

					var reverseSuspectCheckbox = $('<input>', { name: "reverseSuspect", type: "checkbox", disabled : !settings.editable, checked: existingReverseSuspect});
					var reverseSuspectLabel = $('<label>').text(settings.referenceSettingReverseSuspect);
					var reverseSuspectContainer = $('<span>', { 'class': 'reverseSuspectContainer' }).append(reverseSuspectCheckbox).append(reverseSuspectLabel);
					
					var bidirectionalSuspectCheckbox = $('<input>', { name: "bidirectionalSuspect", type: "checkbox", disabled : !settings.editable, checked: existingBidirectionalSuspect});
					var bidirectionalSuspectLabel = $('<label>').text(settings.referenceSettingBidirectionalSuspect);
					var bidirectionalSuspectContainer = $('<span>', { 'class': 'bidirectionalSuspectContainer' }).append(bidirectionalSuspectCheckbox).append(bidirectionalSuspectLabel);

					propagateOptions.append(reverseSuspectContainer);
					propagateOptions.append('<br>');
					propagateOptions.append(bidirectionalSuspectContainer);

					var propagateDependenciesCheckbox = $('<input>', { name: "propagateDependencies", type: "checkbox", disabled : !settings.editable, checked: existingPropagateDependencies});
					var propagateDependenciesLabel = $('<label>').text(settings.referenceSettingPropagateDependencies);
					var propagateDependenciesContainer = $('<div>', { "style" : "padding: 0 5px 8px 0"}).append(propagateDependenciesCheckbox).append(propagateDependenciesLabel);
					
					referenceSettingCell.on('click', 'label', function() {
						$(this).prev().click();
					});

					propagateSuspectsCheckbox.change(function() {
						var isChecked = $(this).is(':checked');
						reverseSuspectLabel.css('color', isChecked ? 'black' : 'lightgray');
						reverseSuspectCheckbox.prop('disabled', !isChecked);
						bidirectionalSuspectLabel.css('color', isChecked ? 'black' : 'lightgray');
						bidirectionalSuspectCheckbox.prop('disabled', !isChecked);
						if (!isChecked) {
							reverseSuspectCheckbox.prop('checked', false);
							bidirectionalSuspectCheckbox.prop('checked', false);
						}
					});
					propagateSuspectsCheckbox.change();

					reverseSuspectCheckbox.change(function() {
						if ($(this).is(':checked')) {
							bidirectionalSuspectCheckbox.prop('checked', false);
						}
					});
					bidirectionalSuspectCheckbox.change(function() {
						if ($(this).is(':checked')) {
							reverseSuspectCheckbox.prop('checked', false);
						}
					});

					var baselineSelector = $('<select>', { name: "version"});
					var baselineSelectorLabel = $('<label>').text(settings.referenceSettingBaseline);
					baselineSelector.append($('<option>', { value: "NONE"}).text(settings.referenceSettingNonLabel));
					baselineSelector.append($('<option>', { value: "HEAD"}).text(settings.referenceSettingHeadLabel));
					baselineSelector.val(existingVersion);
					var baselineContainer = $('<div>', { "style" : "padding: 0 5px 5px 0px"}).append(baselineSelectorLabel).append(baselineSelector);

					referenceSettingCell.append(propagateSettings);
					if (!codebeamer.hidePropagateDependenciesOnTrackerLevel) {
						referenceSettingCell.append(propagateDependenciesContainer);
					}
					referenceSettingCell.append(baselineContainer);
					referenceSettingRow.append(referenceSettingLabel);
					referenceSettingRow.append(referenceSettingCell);
					table.append(referenceSettingRow);
				}

				if (action.clazz.name == 'referringItemUpdater' || action.clazz.name == 'referringItemCreator' || 
					(hasParameters && action.clazz.name != 'addTagsAction' && action.clazz.name != 'removeTagsAction')) {
					var descrRow    = $('<tr>',	{ title : settings.descriptionTooltip });
					var descrLabel  = $('<td>', { "class" : 'labelCell optional' }).text(settings.descriptionLabel + ':');
					var descrCell   = $('<td>', { "class" : 'dataCell expandTextArea' });
					var description = $('<textarea>', { name : 'description', rows : 1, cols : 80, disabled : !settings.editable }).val(action.description);

					descrCell.append(description);
					descrRow.append(descrLabel);
					descrRow.append(descrCell);
					table.append(descrRow);
				}

				// ExecuteAs is enabled or already has a saved value
				if ((settings.executeAsEnabled || action.executeAs) &&
						(action.clazz.name == 'referringItemUpdater' || action.clazz.name == 'referringItemCreator')) {
					var execAsRow   = $('<tr>', { title : settings.executeAs.title });
					var execAsLabel = $('<td>', { "class" : 'labelCell optional' }).text(settings.executeAs.name + ':');
					var execAsCell  = $('<td>', { "class" : 'dataCell executeAs' });

					execAsCell.membersField(action.executeAs, $.extend({}, settings.executeAs, {
						trackerId : context.tracker.id,
						editable  : settings.editable
					}));

					execAsRow.append(execAsLabel);
					execAsRow.append(execAsCell);
					table.append(execAsRow);

					execAsCell.referenceFieldAutoComplete();
				}

				if (action.clazz.name == 'addTagsAction') {
					var statusOptions = $('#statusOptions').val().split(',');
					var $row = $('<tr>',	{ title : i18n.message('tracker.action.addTagsAction.newStatusForTaggedSprints.tooltip') }),
						$labelCell = $('<td>', { 'class' : 'labelCell optional', style: 'vertical-align: top' }).text(i18n.message('tracker.action.addTagsAction.newStatusForTaggedSprints.label') + ':'),
						$inputCell = $('<td>', { 'class' : 'dataCell expandText' }),
						$select = $('<select>', { 'class' : 'status-selector'});
					
					$select.append($('<option>').html('--'));
					$.each(statusOptions, function(index, item) {
						var option = item.trim();
						$select.append($('<option' + (action.statusForTaggedSprints == option ? ' selected' : '') + '/>').html(option));
					});
					
					$inputCell.append($select);
					$row.append($labelCell);
					$row.append($inputCell);
					table.append($row);

					table.append(getParameterHint(i18n.message('tracker.action.addTagsAction.newStatusForTaggedSprints.hint')));
				}
				
				if (action.clazz.name == 'addTagsAction' || action.clazz.name == 'removeTagsAction') {
					var $row = $('<tr>',	{ title : '' }),
						$labelCell = $('<td>', { 'class' : 'labelCell mandatory', style: 'vertical-align: top' }).text(i18n.message('tags.label') + ':'),
						$inputCell = $('<td>', { 'class' : 'dataCell expandText' }),
						$input = $('<input>', { type: 'text', 'class' : 'tag-input' }),
						$hint = $('<div>', { 'class': 'subtext', style: 'margin-top: 10px;' }).html(i18n.message('tag.release.edit.hint')),
						tags = action.tags;
					
					if (tags) {
						$input.val($.trim(tags).match(/.*;$/) ? tags : tags + '; ');
					}

					initEntityLabelAutocomplete($input, { ignorePrivateLabels: true });
					$input.attr('size', 80);
					$inputCell.append($input);
					$inputCell.append($hint);
					$row.append($labelCell);
					$row.append($inputCell);
					table.append($row);
				}
			}
		}

		if ($.fn.workflowActionEditor._setup) {
			$.fn.workflowActionEditor._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), action);
		});
	};


	$.fn.workflowActionEditor.defaults = {
		editable			: false,
		roles				: [],
		trackerFieldsUrl	: contextPath + '/trackers/ajax/transition/updatableFields.spr',
		newItemFieldsUrl	: contextPath + '/trackers/ajax/transition/initialFields.spr',
		trackerFiltersUrl	: null,
		trackerViewUrl		: null,
		actionClasses		: [],
		actionsLabel		: 'Actions',
		actionsTooltip		: 'Custom actions to execute upon a state transition',
		actionsNone		    : 'None',
		actionsMore		    : 'More...',
		infoLabel			: 'Administrative Information',
		infoTitle			: 'Show additional/administrative information about this action',
		idLabel				: 'Id',
		nameLabel			: 'Name',
		nameRequired		: 'An action name is required',
		descriptionLabel	: 'Description',
		descriptionTooltip	: 'An optional action description',
		versionLabel		: 'Version',
		createdByLabel		: 'Created by',
		lastModifiedLabel	: 'Last modified by',
		commentLabel		: 'Comment',
		condition			: {
			label			: 'Condition',
			tooltip			: 'An optional condition, to only execute this action, if the condition yields true',
			none			: 'None',
			newLabel		: 'New',
			newTitle		: 'New condition',
			editLabel		: 'Edit',
			deleteLabel     : 'Delete',
			deleteConfirm   : 'Do you really want to delete this condition?',
			nameLabel		: 'Name',
			viewTypeId		:  1,
			creationType	: 'guard',
			hide			: ['visibility', 'layout', 'fields', 'orderBy', 'charts'],
			filterRequired	: i18n.message('tracker.action.condition.filter.required'),
			validator		: function(view, stats) {
				if (stats.filters == 0) {
					throw "filterRequired";
				}
				return true;
			}
		},
		executeAs  			: {
			name			: 'Execute as',
			title			: 'The special user, the action should be executed as (with that user\'s privileges)',
			emptyValue 		: '',
			emptyLabel 		: '--',
			showCurrentUser	: true,
			showSystemUser	: true,
			searchOnTracker	: true,
			singleSelect	: true
		},
		association			: $.extend({}, $.fn.associationBetweenCopiedItems.defaults, {
			compactLayout	: true
		}),
		fieldUpdates		: $.fn.trackerFieldUpdates.defaults,
        fieldValuesLabel	: 'Field values',
        fieldValuesTooltip	: 'Item field values to set',
		submitText    		: 'OK',
		cancelText   		: 'Cancel',
		newText				: 'New...',
		newTitle			: 'New action',
		editText			: 'Edit',
		editTitle			: 'Edit action',
		editHint			: 'Double click to edit this action, or right-click to get edit context menu.',
		deleteText			: 'Delete',
		deleteConfirm		: 'Do you really want to delete this action?',
		parametersMissing	: 'The following mandatory parameters are missing',
		distributionMissing : 'For each distribution field, there must also be a field update, that copies this field value to a target field',
		stateChartTitle		: 'Workflow Graph',
		stateChartUrl		: contextPath + '/proj/tracker/workflowGraph.spr',
		stateChartImageUrl	: contextPath + '/images/state_diagram.gif',
		refActionPatterns	: {
			referringItemCreator : 'Create new <refType> in "<tracker>"',
			referringItemUpdater : 'Update <refType> in "<tracker>" with status "<status>"'
		},
		referenceSettingLabel				: 'Suspected Settings',
		referenceSettingTooltip				: 'Set Propagate suspects (Reverse direction) and/or Baseline',
		referenceSettingPropagateSuspects	: 'Propagate suspects',
		referenceSettingReverseSuspect		: 'Reverse direction',
		referenceSettingBaseline			: 'Default version',
		referenceSettingHeadLabel			: 'Current HEAD',
		referenceSettingNonLabel			: '--'
	};

	$.fn.workflowActionEditor._setup = true;


	// A helper plugin to cleanup unnecessary editing information from a list of workflow actions
	$.fn.cleanupWorkflowAction = function(action) {
		function cleanup(action) {
			if ($.isPlainObject(action) && $.isPlainObject(action.reference)) {
				var ref = action.reference;

				if ($.isPlainObject(ref.refType)) {
					ref.refType = ref.refType.value;
				}

				if ($.isPlainObject(ref.tracker)) {
					ref.tracker = ref.tracker.id;
				}

				if ($.isPlainObject(ref.status)) {
					ref.status = ref.status.id;
				}
			}
		}

		if ($.isArray(action) && action.length > 0) {
			for (var i = 0; i < action.length; ++i) {
				cleanup(action[i]);
			}
		} else {
			cleanup(action);
		}
	};

	// A plugin to get the configured workflow action from an editor
	$.fn.getWorkflowAction = function(settings) {

		function getDescription(form) {
			var description = null;
			var editor = $('textarea[name="description"]', form);
			if (editor && editor.length > 0) {
				description = editor.val();
			}
			return description;
		}

		function getCondition(form, condition) {
			var selector = $('select.conditionSelector', form);
			if (selector.length > 0) {
				condition = {
					id   : parseInt(selector.val()),
				 	name : $('option:selected', selector).text()
				};
			}

			return condition && condition.id && !isNaN(condition.id) ? condition : null;
		}

		function isEmpty(value) {
			if ($.isPlainObject(value) &&
				((typeof value.value === 'string' && value.value.trim().length > 0) ||
				 ($.isArray(value.value) && value.value.length > 0) ||
				 (typeof value.copyFrom === 'number' && value.copyFrom > 0) ||
				 (typeof value.computeAs === 'string' && value.computeAs.trim().length > 0))) {
				return false;
			}
			return true;
		}

		function hasEmptyValue(update) {
			if ($.isPlainObject(update) && $.isArray(update.values)) {
				if (update.values.length > 0) {
					for (var i = 0; i < update.values.length; ++i) {
						if (isEmpty(update.values[i])) {
							return true;
						}
					}
					return false;
				}

				return true;
			}

			return isEmpty(update);
		}

		function getParameters(form, action) {
			var params = {};
			var errors = [];

			$('tr.actionParam', form).each(function() {
				var row   = $(this);
				var param = row.data('param');
				var value = null;

				if (param.type == 93) { // association
					value = $('td.paramValue', row).getAssociationBetweenCopiedItems();
					if (value) {
						params[param.name] = { value : value };
					}
				} else if (param.type == 94) { // rating
					value = $('td.paramValue', row).getReviewConfiguration(settings.review);
					if (value) {
						params[param.name] = { value : value };
					}

				} else {
					var editor = $('td.fieldUpdate', row);
					if (editor.length > 0) {
						value = editor.getTrackerFieldUpdate();
					} else {
						editor = $('[name="value"]', row);
						if (editor.length > 0) {
							if (editor.is('select[multiple="multiple"]')) {
								var values = [];
								var selected = editor.multiselect('getChecked');
								if (selected) {
									for (var i = 0; i < selected.length; ++i) {
										values.push(selected[i].value);
									}
								}
								value = { value : values.join(',') };
							} else {
								value = { value : editor.val() };
							}
						}
					}

					if (!hasEmptyValue(value)) {
						var dfltValue  = param['default'];
						var paramValue = ($.isArray(value.values) && value.values.length == 1 ? value.values[0] : value);

						if (!(dfltValue && paramValue.value && paramValue.value == dfltValue)) {
							params[param.name] = value;
						}
					} else if (param.required) {
						errors.push(param.label || param.name);
					}
				}
			});

			if (errors.length > 0) {
				throw (settings && settings.parametersMissing ? settings.parametersMissing : 'The following mandatory parameters are missing') + ":\n" + errors.join(', ');
			}

			return params;
		}

		function getFieldUpdates(form) {
			var updates = {};
			var editor = $('td.fieldUpdates', form);
			if (editor && editor.length > 0) {
				var checkMandatory = editor.data('checkMandatory');
				if (checkMandatory) {
					checkMandatory = (settings && settings.fieldUpdates ? settings.fieldUpdates.mandatoryValue : null) || 'Mandatory XX value is missing';
				}

				try {
					updates = editor.getTrackerFieldUpdates(checkMandatory);
				} catch(ex) {
					throw (settings && settings.parametersMissing ? settings.parametersMissing : 'The following mandatory parameters are missing') + ":\n" + editor.prev('td.labelCell').text() + " " + ex;
				}

				if ($.isEmptyObject(updates)) {
					throw (settings && settings.parametersMissing ? settings.parametersMissing : 'The following mandatory parameters are missing') + ":\n" + editor.prev('td.labelCell').text();
				}
			}
			return updates;
		}

		function getExecuteAs(form) {
			var executeAs = null;
			var editor = $('td.executeAs', form);
			if (editor && editor.length > 0) {
				executeAs = editor.getReferences();
			}
			return executeAs;
		}

		function getReferenceSettings(form) {
			return {
				"propagateSuspects" : $('input[name="propagateSuspects"]', form).is(":checked"),
				"reverseSuspect" : $('input[name="reverseSuspect"]', form).is(":checked"),
				"bidirectionalSuspect" : $('input[name="bidirectionalSuspect"]', form).is(":checked"),
				"propagateDependencies" : $('input[name="propagateDependencies"]', form).is(":checked"),
				"version" : $('select[name="version"]', form).val()
			}
		}
		
		function getTags(form) {
			var tags = $('input.tag-input', form).val();
				
			if (tags === '') {
				throw (settings && settings.parametersMissing ? settings.parametersMissing : 'The following mandatory parameters are missing') + ':\n' + i18n.message('tags.label');
			} else if (tags) {
				var tagsArray = tags.split(';').map(function(tag) {
					return $.trim(tag);
				});
				var privateTags = [];
				
				$.each(tagsArray, function(index, tag) {
					if (tag && tag.startsWith('#')) {
						privateTags.push(tag);
						tagsArray[index] = tag.substring(1);
					}
				});
				
				if (privateTags.length) {
					showFancyAlertDialog(i18n.message('tag.release.private.tag.warning', privateTags.join(', ')));
				}
				tags = tagsArray.join('; ');
			}
			return tags;
		}
		
		function getStatusForTaggedSprints(form) {
			return $('select.status-selector', form).val();
		}

		function consistencyCheck(action) {
			if (action.name == 'referringItemCreator') {
				var distribution = action.parameters['distribution'];
				if ($.isPlainObject(distribution)) {
					distribution = distribution.value;
				}
				if (distribution && distribution.length > 0) {
					distribution = distribution.split(',');

					for (var i = 0; i < distribution.length; ++i) {
						var fieldId = parseInt(distribution[i]);
						var found = false;

						$.each(action.fieldUpdates, function(key, value) {
							if ($.isArray(value.values)) {
								for (var j = 0; j < value.values.length; ++j) {
									if (value.values[j].copyFrom && value.values[j].copyFrom == fieldId) {
										found = true;
										return false;
									}
								}
							} else if (value.copyFrom && value.copyFrom == fieldId) {
								found = true;
								return false;
							}
						});

						if (!found) {
							throw settings.distributionMissing;
						}
					}
				}
			}
		}

		var result = {};

		var form = $('table.actionParamEditor', this);
		if (form.length > 0) {
			var action = form.data('action');

			form.cleanupWorkflowAction(action);

			result = $.extend(result, action, {
				description  : getDescription(form),
				condition  	 : getCondition(form, action.condition),
				parameters 	 : getParameters(form, action),
				fieldUpdates : getFieldUpdates(form),
				executeAs    : getExecuteAs(form),
				referenceSettings : getReferenceSettings(form),
				tags: getTags(form),
				statusForTaggedSprints: getStatusForTaggedSprints(form) || ''
			});

			consistencyCheck(result);
		}

		return result;
	};


	// Another plugin to create a new/edit an existing workflow action in a popup dialog
	$.fn.workflowActionDialog = function(context, action, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.workflowActionDialog.defaults, dialog );
		var popup    = this;

		if (action && action.clazz) {
			settings.title = settings.title + ": " + getFullActionName(action, config);
		}

		popup.workflowActionEditor(context, action, config);

		if (config.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
					 var storeAction = function () {
					 		try {
							 	var result = callback(popup.getWorkflowAction(config));
							 	if (!(result == false)) {
						  			popup.dialog("close");
						  			popup.remove();
							 	}
							} catch(ex) {
								alert(ex);
							}
				 	 };

				 	 // if the action is customEmailSender then check if the velocity template file exists
				 	if (action.clazz.name == 'customEmailSender') {
				 		var result = popup.getWorkflowAction(config);
				 		var subjectTemplate = result.parameters.subject.values[0].value;
				 		var bodyTemplate = result.parameters.content.values[0].value;

				 		if (bodyTemplate || subjectTemplate) { // validate the template files only if there is at least one template file selected
					 		var templates = [subjectTemplate, bodyTemplate];
					 		$.get(contextPath + "/trackers/ajax/validateEmailTemplates.spr", {
					 			"templates": templates
					 		}).done(function (data) {
					 			if (data && data.length) {
					 				showFancyAlertDialog(i18n.message("tracker.action.customEmailSender.template.invalid"));
					 			} else {
					 				storeAction();
					 			}
					 		});
				 		} else {
				 			storeAction();
				 		}
				 	} else {
				 		storeAction();
				 	}
				 }
				},
				{ text : config.cancelText,
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

	$.fn.workflowActionDialog.defaults = {
		dialogClass		: 'popup',
		width			: 900,
		draggable		: true
	};



	// Workflow action list Plugin definition.
	$.fn.workflowActionList = function(context, actions, options) {
		var settings = $.extend( {}, $.fn.workflowActionEditor.defaults, options );

		function getSettings() {
			return settings;
		}

		function getSetting(name) {
			return settings[name];
		}

		function getRefTypeItems(forInsert) {
		    var refTypeItems = {};

			for (var i = 0; i < settings.referenceTypes.length; ++i) {
				var referenceType = settings.referenceTypes[i];
				var projectItems = {};
				var projectCount = 0;
				var trackerItems;
				var pathItems;

				// Cannot create item parent or template
				if (forInsert && (referenceType.value.indexOf('76|') == 0 ||   // Parent
						          referenceType.value.indexOf('82|') == 0)) { // Children
					continue;
				}

				for (var j = 0; j < referenceType.trackers.length; ++j) {
					var tracker	= referenceType.trackers[j];
					if (!forInsert || tracker.canAddItems) {
						var projectItem = projectItems[tracker.project.id.toString()];
						if (projectItem) {
							pathItems = projectItem.items;
						} else {
							pathItems = {};
							projectItem = {
								name  : tracker.project.name,
								items : pathItems,
								paths : 0
							};

							projectItems[tracker.project.id.toString()] = projectItem;
							projectCount++;
						}

						var pathItem = pathItems[tracker.scopeName];
						if (pathItem) {
							trackerItems = pathItem.items;
						} else {
							trackerItems = {};
							pathItem = {
								name  : tracker.scopeName,
								items : trackerItems
							};

							pathItems[tracker.scopeName] = pathItem;
							projectItem.paths++;
						}

						if (forInsert) {
							trackerItems[i.toString() + '.' + j] = {
								name : tracker.name
							};
						} else {
							var statusItems = {};

							for (var k = 0; k < tracker.statusOptions.length; ++k) {
								var statusOption = tracker.statusOptions[k];

								statusItems[i.toString() + '.' + j + '.' + k] = {
									name : statusOption.name
								};
							}

							trackerItems[tracker.id.toString()] = {
								name  : tracker.name,
								items : statusItems
							};
						}
					}
				}

				$.each(projectItems, function(key, projectItem) {
					if (projectItem.paths == 1) {
						$.each(projectItem.items, function(key, pathItem) {
							projectItem.items = pathItem.items;
						});
					}
				});

				if (projectCount == 1 && context.tracker.project) {
					var thisProjectItems = projectItems[context.tracker.project.id.toString()];
					if (thisProjectItems) {
						projectItems = thisProjectItems.items;
					}
				}

				refTypeItems[referenceType.value] = {
					name : referenceType.label,
					items: projectItems
				};
			}

			if ($.isEmptyObject(refTypeItems)) {
				refTypeItems.dummy = {
                    name     : settings.actionsNone,
                    disabled : true
				};
			}

			return refTypeItems;
		}

		function getNextActionIndex(actionList, action) {
			var maxIndex = -1;

			$('> li.workflowAction', actionList).each(function() {
				var current = $(this).data('action');
				if (current.name == action && current.index > maxIndex) {
					maxIndex = current.index;
				}
			});

			return maxIndex + 1;
		}

		function editAction(actionList, action, title, callback) {
			var container = actionList.parent();

			var popup = $('div.workflowActionPopup', container);
			if (popup.length == 0) {
				popup = $('<div>', { "class" : 'workflowActionPopup', style : 'display: None;'} );
				container.append(popup);
			} else {
				popup.empty();
			}

			popup.workflowActionDialog(actionList.data('context'), action, options, {
				title			: title,
				position		: { my: "center", at: "center", of: container, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				dialogClass		: 'popup edit-action-dialog',
				open			: handleActionEditDialogOpen
			}, callback);
		}

		function setActionItem() {
			var $actionItem = $(this);
			var action = $actionItem.data('action');
			var span = $('<span>').append($('<label>', { "class" : 'workflowActionLabel' + (settings.editable ? ' highlight-on-hover' : '') }).text(getFullActionName(action, settings)));
			// using setTimeout to let jeditable plugin to finish its task and add links only after that
			setTimeout(function() {
				addWorkflowActionLinks($actionItem);
			});
			return span.html();
		}

		function handleCancelEdit() {
			var $actionItem = $(this).parent();
			// using setTimeout to let jeditable plugin to finish its task and then attach event handlers to action links
			setTimeout(function() {
				var actionLinks = $actionItem.find('a');
				if (actionLinks.length == 2) {
					attachActionLinkEventHandlers(actionLinks.eq(0), actionLinks.eq(1));
				}
			});
		};

		function initTagInput() {
			var $actionItem = $(this);
			if ($actionItem.data('action').clazz.name == 'addTagsAction' ||
				$actionItem.data('action').clazz.name == 'removeTagsAction') { 
				setTimeout(function() {
					var $input = $actionItem.find('input.tag-input');
					if ($input.length) {
						$input.autocomplete('option', 'appendTo', '.popup.state-transition-dialog');
					}
				});
			}
		}
		function makeEditable(actionItem) {
			actionItem.editable(setActionItem, {
		        type      : 'workflowAction',
		        event     : 'click',
		        onblur    : 'cancel',
		        submit    : settings.submitText,
		        cancel    : settings.cancelText,
		        onreset   : handleCancelEdit,
		        onedit : initTagInput
//		        tooltip   : settings.updatesDblClick
			});
		}

		function newAction(actionList, clazz, reference) {
 			editAction(actionList, {
				clazz     : clazz,
				name      : clazz.name,
				index     : getNextActionIndex(actionList, clazz.name),
				reference : reference,
				condition : null,
				parameters: {}

			}, settings.newTitle, function(action) {
	            var moreActions = $('li.moreActions', actionList);
				var actionItem  = $('<li>', { "class" : 'workflowAction' }).data('action', action).append($('<label>', { "class" : 'workflowActionLabel'  + (settings.editable ? ' highlight-on-hover' : '')}).text(getFullActionName(action, settings)));

				addWorkflowActionLinks(actionItem);
				makeEditable(actionItem);

				actionItem.insertBefore(moreActions);

	            var actionSelector = $('select.actionSelector', moreActions);
				$('option:first', actionSelector).text(getSetting('actionsMore'));
			});
		}

		function attachActionLinkEventHandlers($editLink, $removeLink) {
			$editLink.on('click', function(event) {
				event.stopPropagation();
				var item = $(this).closest('li');
				var action = item.data('action');
				var actionList = item.closest('ul.workflowActions');

				editAction(actionList, action, settings.editTitle, function(result) {
					item.data('action', result).find('.workflowActionLabel').text(getFullActionName(result, settings));
				});
			});

			$removeLink.on('click', function(event) {
				event.stopPropagation();
				if (confirm(getSetting("deleteConfirm"))) {
					var action = $(this).closest('li');
					var actionList = action.closest('ul.workflowActions');
					var selector = $('select.actionSelector', actionList);

					action.remove();

					var remaining = $('> li.workflowAction', actionList);
					if (remaining.length == 0) {
						$('option:first', selector).text(getSetting('actionsNone'));
					}
				}
			});
		}

		function addWorkflowActionLinks(context) {
			if (settings.editable) {
				var editLink = $('<a>', {'class': 'edit-link'}).html(i18n.message('button.edit'));
				context.append(editLink);
				var removeLink = $('<a>', {'class': 'edit-link'}).html(settings.deleteText);
				context.append(removeLink);

				attachActionLinkEventHandlers(editLink, removeLink);
			}
		}

		/**
		 * the following two are not real context menus. these are opened automatically when a specific item is selected in the list
		 * (trigger: none)
		 */
		function setup() {
		    // Add a context menu to workflow actions
		    $.contextMenu({
		        selector : 'select.actionSelector > option[value="referringItemUpdater"]',
		        trigger  : 'none',
		        items    : getRefTypeItems(false),

		        position : function(options, x, y) {
		        	options.$menu.position({
	        	        my: 'left top',
	        	        at: 'left bottom',
	        	        of: options.$trigger.parent()
		            });
		        },

		        callback : function(key, options) {
		        	var parts 	   = key.split('.', 3);
		        	var refTypeIdx = parseInt(parts[0]);
		        	var trackerIdx = parseInt(parts[1]);
		        	var statusIdx  = parseInt(parts[2]);

		        	var referenceType = settings.referenceTypes[refTypeIdx];
		        	var tracker = referenceType.trackers[trackerIdx];
		        	var status  = tracker.statusOptions[statusIdx];

		        	newAction(options.$trigger.closest('ul.workflowActions'), getActionClass(settings.actionClasses, 'referringItemUpdater'), {
		        		refType : referenceType,
		        		tracker : tracker,
		        		status  : status
		        	});
				},

		        autoHide : false
		    });

		    // Add a context menu to workflow actions
		    $.contextMenu({
		        selector : 'select.actionSelector > option[value="referringItemCreator"]',
		        trigger  : 'none',
		        items    : getRefTypeItems(true),

		        position : function(options, x, y) {
		        	options.$menu.position({
	        	        my: 'left top',
	        	        at: 'left bottom',
	        	        of: options.$trigger.parent()
		            });
		        },

		        callback : function(key, options) {
		        	var parts 	   = key.split('.', 2);
		        	var refTypeIdx = parseInt(parts[0]);
		        	var trackerIdx = parseInt(parts[1]);

		        	var referenceType = settings.referenceTypes[refTypeIdx];
		        	var tracker = referenceType.trackers[trackerIdx];

		        	newAction(options.$trigger.closest('ul.workflowActions'), getActionClass(settings.actionClasses, 'referringItemCreator'), {
		        		refType : referenceType,
		        		tracker : tracker
		        	});
				},

		        autoHide : false
		    });

		    $.editable.addInputType('workflowAction', {
		    	element : function(settings, self) {
					var form       = $(this);
					var editor     = $(self);
                    var action     = editor.data('action');
                    var actionList = editor.closest('ul.workflowActions');

	    			form.append($('<label>', { "class" : 'actionTitle' }).text(getFullActionName(action, getSettings())));

	    			var div = $('<div>', { "class" : 'inlineActionEditor' });
	    			form.append(div);

	    			div.workflowActionEditor(actionList.data('context'), action, getSettings());

	    			return this;
		    	},

		    	content : function(string, settings, self) {
		    		// Nothing
		     	},

		        plugin : function(settings, self) {
		          	$(this).referenceFieldAutoComplete();
		        },

		        submit : function(settings, self) {
		        	var form = $(this);
					var item = $(self);
					var result = true;

			 		try {
					 	var action = $('div.inlineActionEditor', form).getWorkflowAction(getSettings());
			 			item.data('action', action);
					} catch(ex) {
						result = false;
						alert(ex);
					}
					return result;
		        }
		    });
		}

		function init(container, actions) {
			var actionList = $('<ul>', { "class" : 'workflowActions' }).data('context', context);
			container.append(actionList);

			if ($.isArray(actions) && actions.length > 0) {
				for (var i = 0; i < actions.length; ++i) {
					var action = actions[i];
					if (action && action.name) {
						if (!$.isPlainObject(action.clazz)) {
							action.clazz = getActionClass(settings.actionClasses, action.name);
						}

						if (action.clazz) {
							actionItem = $('<li>', { "class" : 'workflowAction' }).data('action', action).append($('<label>', { "class" : 'workflowActionLabel'  + (settings.editable ? ' highlight-on-hover' : '') }).text(getFullActionName(action, settings)));
							makeEditable(actionItem);
							actionList.append(actionItem);
							addWorkflowActionLinks(actionItem);
						}
					}
				}
			}

			if (settings.editable) {
				var moreActions = $('<li>', { "class": 'moreActions' });
				actionList.append(moreActions);

				var actionSelector = $('<select>', { "class" : 'actionSelector' });
				moreActions.append(actionSelector);

				actionSelector.append($('<option>', { value : '', style : 'color: gray; font-style: italic;' }).text($('> li.workflowAction', actionList).length > 0 ? settings.actionsMore : settings.actionsNone));

				for (var i = 0; i < settings.actionClasses.length; ++i) {
					actionSelector.append($('<option>', { value : settings.actionClasses[i].name }).text(settings.actionClasses[i].label).data("clazz", settings.actionClasses[i]));
				}

				actionSelector.change(function() {
					var value = this.value;
					if (value != '') {
						var option = $('option:selected', actionSelector);

						if (value == 'referringItemCreator' || value == 'referringItemUpdater') {
							option.contextMenu();
						} else {
							newAction(actionList, option.data('clazz'), null);
						}

						this.options[0].selected = true;
					}
				});

				actionList.sortable({
					items		: 'li.workflowAction',
					containment	: container,
					axis 		: "y",
					cursor		: "move",
					delay		: 150,
					distance	: 5
				});
			}
		}

		if ($.fn.workflowActionList._setup) {
			$.fn.workflowActionList._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), actions);
		});
	};

	$.fn.workflowActionList._setup = true;


	// Workflow action icons Plugin definition.
	$.fn.workflowActionIcons = function(context, actions, options) {
		function showWorkflowAction(container, action, callback) {
			var popup = $('div.workflowActionPopup', container);
			if (popup.length == 0) {
				popup = $('<div>', { "class" : 'workflowActionPopup', style : 'display: None;'} );
				container.append(popup);
			} else {
				popup.empty();
			}

			popup.workflowActionDialog(context, action, options, {
				title			: options.editTitle,
				position		: { my: "left top", at: "left bottom", of: container, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				dialogClass		: 'popup edit-action-dialog',
				open			: handleActionEditDialogOpen
			}, callback);
		}

		function init(container, actions) {
			container.empty();
			if ($.isArray(actions) && actions.length > 0) {
				for (var i = 0; i < actions.length; ++i) {
					var action = actions[i];
					if (action && action.name) {
						if (!$.isPlainObject(action.clazz)) {
							action.clazz = getActionClass(options.actionClasses, action.name);
						}

						if (action.clazz && action.clazz.icon) {
							var actionLink = $('<a>', { "class" : 'workflowActionLink', title : getFullActionName(action, options), style : 'margin-Right: 2px;' }).data('index', i).click(function() {
								var item = $(this);
								var index = item.data('index');

								showWorkflowAction(container, actions[index], function(result) {
									item.attr('title', getFullActionName(result, options));
									actions[index] = result;
								});
							});

							actionLink.append($('<img>', { src : action.clazz.icon}));

							container.append(actionLink);
						}
					}
				}
			}
		}

		return this.each(function() {
			init($(this), actions);
		});
	};


	// A plugin to get the configured workflow actions
	$.fn.getWorkflowActions = function() {
		var actions = [];

		$('ul.workflowActions > li.workflowAction', this).each(function() {
			var item = $(this);
			var action = item.data('action');
			if (action) {
				item.cleanupWorkflowAction(action);
				actions.push(action);
			}
		});

		return actions;
	};


})( jQuery );

