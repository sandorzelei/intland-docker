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
	function disableTransitionEditigForTestRunTracker(settings) {
		if (settings.typeId == 9) { // disable editing for test run trackers
			settings.editable = false;
		}
	}

	// State transition permissions plugin
	$.fn.transitionPermissions = function(permissions, options, isNewTransition) {
		var settings = $.extend( {}, $.fn.transitionPermissions.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function isSelected(permissions, type, id) {
			for (var i = 0; i < permissions.length; ++i) {
				if (permissions[i] != null && permissions[i][type] == id) {
					return true;
				}
			}
			return false;
		}

		function init(container, permissions) {
			if (!$.isArray(permissions)) {
				permissions = [];
			}

			if (permissions.length > 0 || settings.editable) {
				var selector = $('<select>', { "class" : 'accessPerms', multiple : true, disabled : !settings.editable });
				container.append(selector);

				var fields = settings.memberFields;
				if ($.isArray(fields) && fields.length > 0) {
					var group = $('<optgroup>', { label : settings.memberFieldsLabel });
					selector.append(group);

					for (var i = 0; i < fields.length; ++i) {
						var selected = isNewTransition || isSelected(permissions, 'field', fields[i].id);
						group.append($('<option>', { "class" : 'field', value: 'field-' + fields[i].id, selected : selected }).text(fields[i].name));
				    }
				}

				var roles = settings.roles;
				if ($.isArray(roles) && roles.length > 0) {
					var group = $('<optgroup>', { label : settings.rolesLabel });
					selector.append(group);

					for (var i = 0; i < roles.length; ++i) {
						var selected = isNewTransition || isSelected(permissions, 'role', roles[i].id);
						group.append($('<option>', { "class" : 'role', value: 'role-' + roles[i].id, title : roles[i].description, selected : selected }).text(roles[i].name));
				    }
				}

				selector.multiselect({
                    header           : true,
		    		checkAllText	 : settings.checkAllText,
		    	 	uncheckAllText	 : settings.permissionsNone,
		    	 	noneSelectedText : settings.permissionsNone,
		    	 	autoOpen		 : settings.autoOpen,
		    	 	multiple         : true,
		    	 	selectedList	 : 99,
		    	 	minWidth		 : 600, //'auto'
		    	 	height			 : 360,
		    	 	classes			 : "transition-permission",
		    	 	open: function (e, d) {
		    	 		// move the cancel/ok buttons to the
		    			var $widget = $(this).multiselect("widget");
		    			var $form = $(this).parents(".transition-permission-form");

		    			if ($form.size() != 0 && $widget.find("[type=submit]").size() == 0) {
		    				var $cancelButton = $form.find('button:not(.ui-multiselect)').eq(1);
			    			var $submitButton = $form.find('button:not(.ui-multiselect)').eq(0);

			    			var $cancelButtonClone = $("<button>", {type: 'cancel'}).html(i18n.message("button.cancel"));
			    			var $submitButtonClone = $("<button>", {type: 'submit'}).html(i18n.message("button.ok"));

			    			$cancelButtonClone.click(function() {
			    				$cancelButton.click();
			    			});

			    			$submitButtonClone.click(function() {
			    				$submitButton.click();
			    			});

			    			$widget.find(".ui-multiselect-header").append($submitButtonClone).append($cancelButtonClone);
		    			}
		    	 	}
				});
			} else {
				container.append(settings.noneText);
			}
		}

		return this.each(function() {
			init($(this), permissions);
		});
	};

	$.fn.transitionPermissions.defaults = {
		editable			: false,
		autoOpen			: false,
		memberFields		: [],
		roles				: [],
		permissionsLabel	: 'Permitted',
		permissionsTooltip	: 'Who is allowed to execute this state transition?',
		permissionsNone		: 'No one',
		memberFieldsLabel	: 'Participants',
		rolesLabel		 	: 'Roles',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all'
	};


	$.fn.getTransitionPermissions = function() {
		var permissions = [];

		var selected = $('select.accessPerms', this).multiselect('getChecked');
		for (var i = 0; i < selected.length; ++i) {
			var checkbox = selected[i];
			var sepIdx   = checkbox.value.indexOf('-');
			var type     = checkbox.value.substring(0, sepIdx);
			var id       = parseInt(checkbox.value.substring(sepIdx + 1));
			var permission = {};

			permission[type]  = id;
			permission.access = 1;

			permissions.push(permission);
		}

		return permissions;
	};

	// A helper function to get a status from a status selector
	function getStatus(which, form) {
		var status = {};

		var selector = $('select[name="' + which + 'Id"]', form);
		if (selector.length > 0) {
			status.id   = parseInt(selector.val());
			status.name = $('option:selected', selector).text();
		} else {
			status.id   = parseInt($('input[name="' + which + 'Id"]', form).val()),
			status.name = $('td[class="' + which + '"] > label', form).text();
		}

		return isNaN(status.id) ? null : status;
	}


	// State transition Editor Plugin definition.
	$.fn.stateTransitionEditor = function(tracker, transition, options) {
		var settings = $.extend( {}, $.fn.stateTransitionEditor.defaults, options );
		settings.guard = $.extend( {}, $.fn.stateTransitionEditor.defaults.guard, options.guard );
		settings.guard.nameLabel = settings.nameLabel;
		settings.changes = $.extend( {}, $.fn.stateTransitionEditor.defaults.changes, options.changes );
		settings.changes.nameLabel = settings.nameLabel;

		function getSetting(name) {
			return settings[name];
		}
		disableTransitionEditigForTestRunTracker(settings);

		function getGuardSelector(tracker, filter, config) {
			var selector = $('<select>', { name : 'guardId', "class" : 'guardSelector' }).data("tracker", tracker).data("config", config);

			selector.append($('<option>', { value : '' }).text(config.none));

	        $.get(settings.trackerFiltersUrl, {tracker_id : tracker.id, viewTypeId : config.viewTypeId, creationType : config.creationType}).done(function(filters) {
	        	for (var i = 0; i < filters.length; ++i) {
	        		// BUG-873381: If guard/view is overloaded or replaced by materialized view, the id changes, so we must base selected on the name, not the id
					selector.append($('<option>', { value : filters[i].id, title : filters[i].description, selected : (filter && filter.name == filters[i].name) }).text(filters[i].name)
							.data("creationType", filters[i].descFormat)
							.data("creationTypeLong", config.creationType));
	    		}
				selector.trigger("change");
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

		function showTrackerFilter(selector, viewId, callback) {
			var tracker = selector.data('tracker');
			var config  = selector.data('config');
			var view = {
				tracker_id      : tracker.id,
				viewTypeId      : config.viewTypeId,
				viewLayoutId    : 0,
				creationType    : config.creationType,
				forcePublicView : true
	  		};

			if (viewId) {
				view.view_id = viewId;
			}

			var popup = selector.next('div.filterPopup');
			if (popup.length == 0) {
				popup = $('<div>', { "class" : 'filterPopup', style : 'display: None;'} );
				popup.insertAfter(selector);
			}

			popup.showTrackerViewConfigurationDialog(view, config, {
				title			: viewId ? config.editLabel : config.newLabel,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				editable		: true,
				viewUrl			: settings.trackerViewUrl,
				submitText		: settings.submitText,
				cancelText		: settings.cancelText,
				validator		: function(view, stats) {
					try {
						return config.validator(view, stats);
					} catch(ex) {
						alert(config[ex] || ex);
					}
					return false;
				}

			}, callback);
		}

		function validateGuardDeletion(guardId, transitionId) {
			var transitions = $('#adminTransitionPermissionForm').getStateTransitions(),
				valid = true;

			if ($.isArray(transitions)) {
				transitions.forEach(function(transition) {
					// check if guard is used in other transitions
					if (transition.guard && transition.id != transitionId && transition.guard.id == guardId) {
						valid = false;
					}

					if ($.isArray(transition.actions)) {
						transition.actions.forEach(function(action) {
							if (action.condition && action.condition.id == guardId) {
								valid = false;
							}
						});
					}
				});
			}

			return valid;
		}

		function deleteGuard(selector, guardId, transitionId, callback) {
			var message = selector.data('config').deleteConfirm,
				warningMessage = '';

			if (!validateGuardDeletion(guardId, transitionId)) {
				warningMessage = i18n.message('tracker.transition.guard.delete.invalid');
			}

			showFancyConfirmDialogWithCallbacks(warningMessage + message,
				function() {
						$.ajax(settings.trackerViewUrl + "?tracker_id=" + tracker.id + "&view_id=" + guardId, {
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

		function getFieldsReadableInTransition(fromId, toId) {
			var transAk = fromId + '-' + toId;

			var fields = settings.fieldsPerTransitionAk[transAk];
			if (!$.isArray(fields)) {
				var params = {
					tracker_id : tracker.id,
					toStatusId : toId
				};

				if (fromId && fromId.length > 0) {
					params.fromStatusId = fromId;
				}

	 	        $.ajax(settings.transitionFieldsUrl, {type: 'GET', data: params, dataType: 'json', async: false, cache: false}).done(function(result) {
	 	        	settings.fieldsPerTransitionAk[transAk] = result;
	 	        	fields = result;
	 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	 	        	settings.fieldsPerTransitionAk[transAk] = [];
	 	    		try {
	 		    		var exception = $.parseJSON(jqXHR.responseText);
	 		    		alert(exception.message);
	 	    		} catch(err) {
	 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	 	    		}
	 	    	});
			}

			return fields;
		}

		function setup() {

		}

		function addGuardLinks(guardCell, guard, transitionId) {
			if (settings.editable && settings.typeId != 9) { // disable the add/edit guard functions for test run trackers
				// the add guard link
				var addLabel = i18n.message("button.add");
				var addGuardLink = $("<a>", {"title": addLabel, "class": "edit-link"}).html(addLabel);
				addGuardLink.click(function () {
					var selector = guard;
					showTrackerFilter(selector, null, function(view) {
					  if (view && view.id > 0) {
						  var config = selector.data('config');
						  selector.append( $('<option>', { value : view.id, title : view.description, selected : true }).text(view.name)
								  .data("creationType", config.creationType).data("creationTypeLong", config.creationType));
						  selector.trigger("change");
					  }
					});
				});

				guardCell.append(addGuardLink);

				// the edit guard link
				var editLabel = i18n.message("button.edit");
				var editGuardLink = $("<a>", {"title": editLabel, "class": "edit-link"}).html(editLabel);

				editGuardLink.click(function () {
				   var selector = guard;
      			   var filter = parseInt(selector.val());
      			   if (filter > 0) {
      				   showTrackerFilter(selector, filter, function(view) {
      					   if (view && view.name != null) {
      						   $('option:selected', selector).text(view.name).attr('title', view.description);
      					   }
      				   });
      			   }
				});

				guardCell.append(editGuardLink);

				// the delete guard link
				var deleteLabel = i18n.message("button.delete");
				var deleteGuardLink = $("<a>", {"title": deleteLabel, "class": "edit-link"}).html(deleteLabel);

				deleteGuardLink.click(function () {
					var selector = guard;

					var filter = parseInt(selector.val());
					if (filter > 0) {
						var selected = $('option:selected', selector);
      					var config = selector.data('config');

						if (selected.data("creationTypeLong") == config.creationType) {
							deleteGuard(selector, filter, transitionId, function() {
								selected.remove();
								guard.trigger("change");
					        });
						}
					}
				});

				guardCell.append(deleteGuardLink);


				var toggleLinks = function (selected) {
					if (!selected.attr("value")) {
						editGuardLink.hide();
						deleteGuardLink.hide();
					} else {
						editGuardLink.show();
						deleteGuardLink.show();
					}
				};

				guard.change(function () {
					var selected = $(this).find(":selected");
					toggleLinks(selected);
				});

				// trigger the change event immediately to get the guard edit link visbilities updated
				guard.trigger("change");

			}
		}

		function init(form, tracker, transition) {
			if (!$.isPlainObject(transition)) {
				transition = {
					eventId : 0
				};
			}

			form.helpLink(settings.help);
			form.objectInfoBox(transition, settings);

			var table = $('<table>', { "class" : 'transitionEditor formTableWithSpacing' }).data('transition', transition);

			var fromStatus = null;
			var toStatus   = null;

			// If the transition is a workflow event handler and not a State Transition
			if (transition.eventId) {
				var event  = settings.events[transition.eventId];
				var status = (event.name == 'StateExit' ? transition.fromStatus : transition.toStatus);

				var statusRow   = $('<tr>');
				var statusLabel = $('<td>', { "class" : 'labelCell mandatory', title : settings.state.tooltip }).text(settings.state.label + ':');
				var statusCell  = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox fromStatus', colspan : 4 });

				fromStatus = $('<input>', { type : 'hidden', name : 'fromStatusId', value : -1 });

				if (settings.editable) {
					toStatus = $('<select>', { name : 'toStatusId' });

					var showObsolete = true;
					if ($("#showObsolete").length && !$("#showObsolete").is(':checked')) {
						showObsolete = false;
					}
					for (var i = 0; i < settings.statusOptions.length; ++i) {
						var obsolete = false;
						var text = settings.statusOptions[i].name;
						if (settings.obsolete) {
							for (var j = 0; j < settings.obsolete.length; ++j) {
								if (text == settings.obsolete[j]) {
									text = text + ' (' + i18n.message("issue.flag.Obsolete.label") + ')';
									obsolete = true;
								}
							}
						}
						if (!obsolete || showObsolete) {
							toStatus.append($('<option>', { value : settings.statusOptions[i].id, selected : (status && status.id == settings.statusOptions[i].id) }).text(text));
						}
					}

					if (event.name == 'FieldUpdate') {
						toStatus.append($('<option>', { value : '-1', selected : (status && status.id == -1) }).text(settings.anyStatusLabel));
					}
				} else {
					toStatus = $('<input>', { type : 'hidden', name : 'toStatusId', value : (status ? status.id : '') });
					statusCell.append($('<label>').text(status ? status.name : '--'));
				}

				statusCell.append(fromStatus);
				statusCell.append(toStatus);
				statusRow.append(statusLabel);
				statusRow.append(statusCell);
				table.append(statusRow);

				if (transition.eventId == 3) {
					var guardRow    = $('<tr>',	{ title : settings.changes.tooltip, valign : 'middle' });
					var guardLabel  = $('<td>', { "class" : 'labelCell optional' }).text(settings.changes.label + ':');
					var guardCell   = $('<td>', { "class" : ' guard dataCell dataCellContainsSelectbox', colspan : 4 });
					var guard;

					if (settings.editable) {
						guard = getGuardSelector(tracker, transition.guard, settings.changes);
					} else {
						guard = $('<input>', { type : 'hidden', name : 'guardId', value : (transition.guard ? transition.guard.id : '') });
						guardCell.append(transition.guard ? transition.guard.name : settings.changes.none);
					}

					guardCell.append(guard);
					guardRow.append(guardLabel);
					guardRow.append(guardCell);

					addGuardLinks(guardCell, guard, transition.id);

					table.append(guardRow);
				}
			} else { // State Transition
				var fromToRow = $('<tr>');
				var fromLabel = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.fromLabel + ':');
				var fromCell  = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox fromStatus', style : 'width: 5%' });

				if (settings.editable) {
					fromStatus = $('<select>', { name : 'fromStatusId' });
					fromStatus.append($('<option>', { value : '' }).text('--'));

					var showObsolete = true;
					if ($("#showObsolete").length && !$("#showObsolete").is(':checked')) {
						showObsolete = false;
					}
					for (var i = 0; i < settings.statusOptions.length; ++i) {
						var obsolete = false;
						var text = settings.statusOptions[i].name;
						if (settings.obsolete) {
							for (var j = 0; j < settings.obsolete.length; ++j) {
								if (text == settings.obsolete[j]) {
									text = text + ' (' + i18n.message("issue.flag.Obsolete.label") + ')';
									obsolete = true;
								}
							}
						}
						if (!obsolete || showObsolete) {
							fromStatus.append($('<option>', { value : settings.statusOptions[i].id, selected : (transition.fromStatus && transition.fromStatus.id == settings.statusOptions[i].id) }).text(text));
						}
					}

					fromStatus.append($('<option>', { value : '-1', selected : (transition.fromStatus && transition.fromStatus.id == -1) }).text(settings.anyStatusLabel));
				} else {
					fromStatus = $('<input>', { type : 'hidden', name : 'fromStatusId', value : (transition.fromStatus ? transition.fromStatus.id : '') });
					fromCell.append($('<label>').text(transition.fromStatus ? transition.fromStatus.name : '--'));
				}

				fromCell.append(fromStatus);
				fromToRow.append(fromLabel);
				fromToRow.append(fromCell);

				var toLabel = $('<td>', { "class" : 'labelCell mandatory', style : 'width: 5%; padding-left: 2em;' }).text(settings.toLabel + ':');
				var toCell  = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox toStatus' });

				if (settings.editable) {
					toStatus = $('<select>', { name : 'toStatusId' });

					var showObsolete = true;
					if ($("#showObsolete").length && !$("#showObsolete").is(':checked')) {
						showObsolete = false;
					}
					for (var i = 0; i < settings.statusOptions.length; ++i) {
						var obsolete = false;
						var text = settings.statusOptions[i].name;
						if (settings.obsolete) {
							for (var j = 0; j < settings.obsolete.length; ++j) {
								if (text == settings.obsolete[j]) {
									text = text + ' (' + i18n.message("issue.flag.Obsolete.label") + ')';
									obsolete = true;
								}
							}
						}
						if (!obsolete || showObsolete) {
							toStatus.append($('<option>', { value : settings.statusOptions[i].id, selected : (transition.toStatus && transition.toStatus.id == settings.statusOptions[i].id) }).text(text));
						}
					}
				} else {
					toStatus = $('<input>', { type : 'hidden', name : 'toStatusId', value : (transition.toStatus ? transition.toStatus.id : '') });
					toCell.append($('<label>').text(transition.toStatus ? transition.toStatus.name : '--'));
				}

				toCell.append(toStatus);
				fromToRow.append(toLabel);
				fromToRow.append(toCell);
				fromToRow.append($('<td>'));
				table.append(fromToRow);

				var nameRow   = $('<tr>');
				var nameLabel = $('<td>',	 { "class" : 'labelCell mandatory' }).text(settings.nameLabel + ':');
				var nameCell  = $('<td>', 	 { "class" : 'dataCell', colspan : 4 });
				var name	  = $('<input>', { type : 'text', name : 'name', value : transition.name, maxlength : 80, disabled : !settings.editable });

				var hideLabel = $('<label>', { title : settings.hiddenTooltip, style: 'margin-left: 2em; vertical-align: middle; white-space: nowrap;' });
				var hidden    = $('<input>', { type : 'checkbox', name : 'hidden', value : 'true', checked : transition.hidden, disabled : !settings.editable });

				hideLabel.append(hidden).append(settings.hiddenLabel);

				nameCell.append(name).append(hideLabel);
				nameRow.append(nameLabel);
				nameRow.append(nameCell);
				table.append(nameRow);

				var descrRow    = $('<tr>',		  { title : settings.descriptionTooltip });
				var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(settings.descriptionLabel + ':');
				var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea', colspan : 4 });
				var description = $('<textarea>', { name : 'description', rows : 2, cols : 80, disabled : !settings.editable }).val(transition.description);

				descrCell.append(description);
				descrRow.append(descrLabel);
				descrRow.append(descrCell);
				table.append(descrRow);

				var permsRow    = $('<tr>', { title : settings.permissions.permissionsTooltip, valign : 'middle' });
				var permsLabel  = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.permissions.permissionsLabel + ':');
				var permsCell   = $('<td>', { "class" : 'permissions', colspan : 4 });

				var isNewTransition = !transition.permissions;
				permsCell.transitionPermissions(transition.permissions, settings.permissions, isNewTransition);

				permsRow.append(permsLabel);
				permsRow.append(permsCell);
				table.append(permsRow);

				if (settings.predicates.length > 0) {
					var predicateRow   = $('<tr>', { title : settings.predicate.tooltip, valign : 'top' });
					var predicateLabel = $('<td>', { "class" : 'labelCell optional', style : 'vertical-align:top;' }).text(settings.predicate.label + ':');
					var predicateCell  = $('<td>', { "class" : 'predicate dataCell dataCellContainsSelectbox', colspan : 4 });
					var predicate;

					if (settings.editable) {
						predicate = $('<select>', { name : 'predicate' });
						predicateCell.append(predicate);

						for (var i = 0; i < settings.predicates.length; ++i) {
							predicate.append($('<option>', { value : settings.predicates[i].name, selected : transition.predicate == settings.predicates[i].name, title : settings.predicates[i].title }).text(settings.predicates[i].label));
						}

						var predicateDiv = $('<div>', {"class" : 'predicateExpression', style : 'display: None;'});
						predicateCell.append(predicateDiv);

						var predicateExpr = $('<textarea>', { "class" : 'predicateExpression', rows : 1, cols: 80, placeholder : settings.predicate.expression }).val(transition.predicateExpression);
						predicateDiv.append(predicateExpr);

						predicate.change(function() {
							if (this.value == 'predicateExpression') {
								predicateDiv.show();
							} else {
								predicateDiv.hide();
							}
						});

						predicate.change();
					} else {
						predicateCell.append($('<input>', { type : 'hidden', name : 'predicate', value : transition.predicate }));

						var predicateName = '--';

						if (transition.predicate) {
							for (var i = 0; i < settings.predicates.length; ++i) {
								if (transition.predicate == settings.predicates[i].value) {
									predicateName = settings.predicates[i].label;
									break;
								}
							}
						};

						predicateCell.append(predicateName);

						if (predicateName == 'predicateExpression') {
							var predicateDiv = $('<div>', {"class" : 'predicateExpression'});
							predicateCell.append(predicateDiv);

							var predicateExpr = $('<textarea>', { "class" : 'predicateExpression', rows : 1, cols: 80, placeholder : settings.predicate.expression, disabled: true }).val(transition.predicateExpression);
							predicateDiv.append(predicateExpr);
						}
					}

					predicateRow.append(predicateLabel);
					predicateRow.append(predicateCell);
					table.append(predicateRow);
				}

				var guardRow    = $('<tr>',	{ title : settings.guard.tooltip, valign : 'middle' });
				var guardLabel  = $('<td>', { "class" : 'labelCell optional' }).text(settings.guard.label + ':');
				var guardCell   = $('<td>', { "class" : ' guard dataCell dataCellContainsSelectbox', colspan : 4 });
				var guard;

				if (settings.editable) {
					guard = getGuardSelector(tracker, transition.guard, settings.guard);
				} else {
					guard = $('<input>', { type : 'hidden', name : 'guardId', value : (transition.guard ? transition.guard.id : '') });
					guardCell.append(transition.guard ? transition.guard.name : settings.guard.none);
				}

				guardCell.append(guard);

				addGuardLinks(guardCell, guard, transition.id);

				guardRow.append(guardLabel);
				guardRow.append(guardCell);
				table.append(guardRow);
			}

			var actionsRow    = $('<tr>', { valign : 'middle' });
			var actionsLabel  = $('<td>', { "class" : 'labelCell ' + (transition.eventId ? 'mandatory' : 'optional'), style : 'vertical-align: top;', title : settings.actions.actionsTooltip }).text(settings.actions.actionsLabel + ':');
			var actionsCell   = $('<td>', { "class" : 'actions dataCell', colspan : 4 });

			var context = $.extend({}, transition, {
				tracker 	  : tracker,
				status  	  : function() { return getStatus('toStatus', form); },
				fields  	  : function() { return getFieldsReadableInTransition(fromStatus.val(), toStatus.val()); },
				allowNewChild : function() { return fromStatus.val() != ''; }
			});

			actionsCell.workflowActionList(context, transition.actions, $.extend({}, settings.actions, {
				condition : $.extend({}, settings.actions.condition, {
					viewTypeId : transition.eventId ? [1, 4] : 1
				})
			}));

			actionsRow.append(actionsLabel);
			actionsRow.append(actionsCell);
			table.append(actionsRow);

			form.append(table);
		}

		if ($.fn.stateTransitionEditor._setup) {
			$.fn.stateTransitionEditor._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), tracker, transition);
		});
	};

	$.fn.stateTransitionEditor.defaults = {
		editable			: false,
		validationUrl		: null,
		trackerFiltersUrl	: null,
		trackerViewUrl		: null,
		transitionFieldsUrl : contextPath + '/trackers/ajax/transition/readableFields.spr',
		statusOptions		: [],
		events				: [{
			id 				: 0,
			name 			: 'StateTransition',
			label			: 'State Transition',
			tooltip			: 'A state transition from an old status to a new status',
			phase			: 'On Execution'
		}, {
			id 				: 1,
			name 			: 'StateEntry',
			label			: 'State Entry',
			tooltip			: 'Actions to execute upon entering a status from another status',
			phase			: 'On Entry'
		}, {
			id 				: 2,
			name 			: 'StateExit',
			label			: 'State Exit',
			tooltip			: 'Actions to execute upon exiting a status to another status',
			phase			: 'On Exit'
		}, {
			id 				: 3,
			name 			: 'FieldUpdate',
			label			: 'Change Handler',
			tooltip			: 'Actions to execute upon changing field values while in a status',
			phase			: 'On Update'
		}],
		predicates			: [],
		anyStatusLabel		: '***',
		infoLabel			: 'Administrative Information',
		infoTitle			: 'Show additional/administrative information about this transition',
		idLabel				: 'Id',
		versionLabel		: 'Version',
		nameLabel			: 'Name',
		nameRequired		: 'A transition name is required',
		descriptionLabel	: 'Description',
		descriptionTooltip	: 'The first line of the description will be also used as transition menu item tooltip and must not contain any Wiki or HTML markup.',
		createdByLabel		: 'Created by',
		lastModifiedLabel	: 'Last modified by',
		commentLabel		: 'Comment',
		fromLabel			: 'From',
		toLabel				: 'To',
		fromToSame			: 'From and To status must be different!',
		hiddenLabel			: 'Hidden',
		hiddenTooltip		: 'A hidden state transition cannot be invoked interactively via the GUI.',
		help				: {
			URL				: 'https://codebeamer.com/cb/wiki/11108',
			title			: 'State Transitions in the CodeBeamer Knowledge Base'
		},
		state				: {
			label			: 'State',
			tooltip			: 'A defined tracker workflow state'
		},
		event				: {
			label			: 'Event',
			tooltip			: 'The workflow event to define or to handle',
			none			: 'None',
			moreLabel		: 'More...',
			moreTitle		: 'Add a new workflow event',
			deleteLabel		: 'Delete',
			deleteConfirm	: 'Do you really want to delete this XXX?"',
		 	duplicateText   : 'There is already a XXX for this status!'
		},
		predicate			: {
			label			: 'Condition',
			tooltip			: 'The transition condition determines, whether the transition is applicable for a specific subject item (in addition to user permissions and source and target status), or not.',
			expression 		: 'A boolean expression/formula, that must yield true or false',
			validationUrl	: contextPath + '/trackers/ajax/transition/validatePredicateExpression.spr?tracker_id='
		},
		guard				: {
			label			: 'Guard',
			tooltip			: 'Only execute this state transition, if this guard condition is true',
			none			: 'None',
			newLabel		: 'New',
			editLabel		: 'Edit',
			deleteLabel     : 'Delete',
			deleteConfirm   : 'Do you really want to delete this guard?',
			nameLabel		: 'Name',
			viewTypeId		: 1,
			creationType	: 'guard',
			hide			: ['visibility', 'layout', 'fields', 'orderBy', 'charts'],
			filterRequired	: 'The guard condition must contain at least one filter criteria',
			validator		: function(view, stats) {
				if (stats.filters == 0) {
					throw "filterRequired";
				}
				return true;
			}
		},
		changes				: {
			label			: 'Changes',
			tooltip			: 'Only execute the defined actions, if these attributes of the subject item changed',
			none			: 'Any',
			newLabel		: 'New',
			editLabel		: 'Edit',
			deleteLabel     : 'Delete',
			deleteConfirm   : 'Do you really want to delete this change filter?',
			nameLabel		: 'Name',
			viewTypeId		: 4,
			creationType	: 'changes',
			hide			: ['visibility', 'layout', 'fields', 'orderBy', 'charts'],
			filterRequired	: 'The change filter condition must contain at least one field updated criteria',
			validator		: function(view, stats) {
				if (stats.updates == 0) {
					throw "filterRequired";
				}
				return true;
			}
		},
		actions				: $.fn.workflowActionEditor.defaults,
		permissions			: $.fn.transitionPermissions.defaults,
		submitText    		: 'OK',
		cancelText   		: 'Cancel',
		addStatus			: 'Add Status...',
		editText			: 'Edit',
		editTitle			: 'Edit Transition',
		duplicateText		: 'A transition with the same From/To already exists!',

		// A cache for the readable fields per transition alternate key "fromId-toId"
		fieldsPerTransitionAk : {}
	};

	$.fn.stateTransitionEditor._setup = true;


	// A plugin to get the transition settings back from an editor
	$.fn.getStateTransition = function(settings) {
		var result = {};

		var editor = $('table.transitionEditor', this);
		if (editor.length > 0) {
			var transition = editor.data('transition');
			if (transition.eventId) {
				var any = {
					id   : -1,
					name : settings.anyStatusLabel
				};

				var event  = settings.events[transition.eventId];
				var status = getStatus('toStatus', editor);

				result = $.extend(result, transition, {
					name    	: event.name + '-' + status.id,
					fromStatus  : event.name == 'StateEntry' ? any : status,
					toStatus    : event.name == 'StateExit'  ? any : status,
					actions 	: $('td.actions', editor).getWorkflowActions()
				});

				if (transition.eventId == 3) {
					result.guard = getStatus('guard', editor);

					if (result.guard && result.guard.name) {
						result.name = result.name + '-' + result.guard.name;
					}
				}
			} else {
				result = $.extend(result, transition, {
					name    		: $.trim($('input[name="name"]', editor).val()),
					description 	: $('textarea[name="description"]', editor).val(),
					fromStatus  	: getStatus('fromStatus', editor),
					toStatus    	: getStatus('toStatus', editor),
					permissions		: $('td.permissions', editor).getTransitionPermissions(),
					predicate 		: $('[name="predicate"]', editor).val(),
					guard			: getStatus('guard', editor),
					hidden      	: $('input[type="checkbox"][name="hidden"]', editor).is(':checked'),
					actions 		: $('td.actions', editor).getWorkflowActions()
				});

				if (result.predicate == 'predicateExpression') {
					result.predicateExpression = $.trim($('textarea.predicateExpression', editor).val());

					$.ajax(settings.predicate.validationUrl, {
						type		: 'POST',
						async		: false,
						data 		: JSON.stringify(result.predicateExpression),
						contentType : 'application/json',
						dataType 	: 'json'
					}).fail(function(jqXHR, textStatus, errorThrown) {
						var exception = $.parseJSON(jqXHR.responseText);
				    	throw exception.message;
			        });
				} else {
					delete result.predicateExpression;
				}
			}
		}

		return result;
	};


	// Another plugin to create a new/edit an existing state transition in a popup dialog
	$.fn.showStateTransitionDialog = function(tracker, transition, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showStateTransitionDialog.defaults, dialog );
		var popup    = this;

		popup.stateTransitionEditor(tracker, transition, config);

		function handleSubmit() {
			var result;
			try {
			 	result = callback(popup.getStateTransition(config));
			 	if (!(result == false)) {
		  			popup.dialog("close");
		  			popup.remove();
			 	}
			} catch(ex) {
				alert(ex);
			}
			return result;
		}

		if (config.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
							if (settings["withAutoSave"]) {
								if (handleSubmit()) {
									$("#saveStateTransitionsSubmitButton").trigger('click');
								};
							} else {
								handleSubmit();
								showOverlayMessage(i18n.message('tracker.state.transition.save.notification'), null, false, true);
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

	$.fn.showStateTransitionDialog.defaults = {
		dialogClass		: 'popup state-transition-dialog',
		width			: 1100,
		draggable		: true
	};


	// State transition list Plugin definition.
	$.fn.stateTransitionList = function(tracker, transitions, options, trackerLayoutLabelStatusId) {
		var settings = $.extend( {}, $.fn.stateTransitionEditor.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function getFieldsReadableInTransition(transition) {
			var fromId  = transition.fromStatus ? transition.fromStatus.id.toString() : '';
			var toId    = transition.toStatus   ? transition.toStatus.id   : null;
			var transAk = fromId + '-' + toId;

			var fields = settings.fieldsPerTransitionAk[transAk];
			if (!$.isArray(fields)) {
				var params = {
					tracker_id : tracker.id,
					toStatusId : toId
				};

				if (fromId && fromId.length > 0) {
					params.fromStatusId = fromId;
				}

	 	        $.ajax(settings.transitionFieldsUrl, {type: 'GET', data: params, dataType: 'json', async: false, cache: false}).done(function(result) {
	 	        	settings.fieldsPerTransitionAk[transAk] = result;
	 	        	fields = result;
	 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	 	        	settings.fieldsPerTransitionAk[transAk] = [];
	 	    		try {
	 		    		var exception = $.parseJSON(jqXHR.responseText);
	 		    		alert(exception.message);
	 	    		} catch(err) {
	 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	 	    		}
	 	    	});
			}

			return fields;
		}

		function getActionContext(transition) {
			return $.extend({}, transition, {
				tracker : tracker,
				status  : transition.toStatus,
				fields  : function() { return getFieldsReadableInTransition(transition); }
			});
		}

		function getStatusIdx(status) {
			if (status && status.id) {
				if (status.id < 0) {
					return settings.statusOptions.length;
				}

				for (var i = 0; i < settings.statusOptions.length; ++i) {
					if (settings.statusOptions[i].id == status.id) {
						return i;
					}
				}
			}
			return -2;
		}

		function getStatusName(status) {
			if (status && status.id) {
				if (status.id < 0) {
					return settings.anyStatusLabel;
				}

				for (var i = 0; i < settings.statusOptions.length; ++i) {
					if (settings.statusOptions[i].id == status.id) {
						return settings.statusOptions[i].name;
					}
				}
			}
			return '--';
		}

		function isSelected(permissions, type, id) {
			for (var i = 0; i < permissions.length; ++i) {
				if (permissions[i] != null && permissions[i][type] == id) {
					return true;
				}
			}
			return false;
		}

		function getGranted(permissions) {
			if (!$.isArray(permissions)) {
				permissions = [];
			}

			if (permissions.length > 0) {
				var granted = [];

				var fields = settings.permissions.memberFields;
				if ($.isArray(fields) && fields.length > 0) {
					for (var i = 0; i < fields.length; ++i) {
						if (isSelected(permissions, 'field', fields[i].id)) {
							granted.push(fields[i].name);
						}
				    }
				}

				var roles = settings.permissions.roles;
				if ($.isArray(roles) && roles.length > 0) {
					for (var i = 0; i < roles.length; ++i) {
						if (isSelected(permissions, 'role', roles[i].id)) {
							granted.push(roles[i].name);
						}
					}
				}

				if (granted.length > 0) {
					return granted.join(', ');
				}
			}

			return settings.permissions.noneText;
		}

		function editTransition(table, row, eventId, callback) {
			var tracker    = table.data('tracker');
			var transition = row ? row.data('transition') : { eventId : eventId };
			var event      = settings.events[transition.eventId];

			var popup = $('#stateTransitionEditor');
  			if (popup.length == 0) {
  				popup = $('<div>', { id : 'stateTransitionEditor', "class" : 'editorPopup', style : 'display: None;'} );
  				popup.insertAfter(table);
  			} else {
  				popup.empty();
  			}

  			popup.showStateTransitionDialog(tracker, transition, options, {
				title			: event.label || event.name,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				withAutoSave	: false

  			}, callback);
		}

		function setTransition(row, transition) {
			row.data('transition', transition);

			$('td.fromStatus', row).text(getStatusName(transition.fromStatus));
			$('td.toStatus',   row).text(getStatusName(transition.toStatus));
			$('td.action',     row).workflowActionIcons(getActionContext(transition), transition.actions, settings.actions);

			// The name and description of event handlers cannot be changed and they also do not have permissions
			if (!transition.eventId) {
				var link = $('td.name a.transitionLink', row);
				link.text(transition.name).attr('title', transition.description);

				if (transition.hidden) {
					link.addClass('hidden');
				} else {
					link.removeClass('hidden');
				}

				$('td.permissions', row).text(getGranted(transition.permissions));
			} else if (transition.eventId == 3) {
				var event = settings.events[3];
				var label = (event.phase || event.label || event.name) + ': ' + (transition.guard ? transition.guard.label || transition.guard.name || '--' : settings.changes.none);

				$('td.name > a.transitionLink', row).text(label);
			}
		}

		function setTransitionPermissions() {
			var container  = $(this);
			var transition = container.closest('tr').data('transition');

			transition.permissions = container.getTransitionPermissions();

			return getGranted(transition.permissions);
		}

		function addTransition(table, transition) {
			if (!$.isPlainObject(transition)) {
				transition = {};
			}

			var row = $('<tr>', { "class" : 'stateTransition even' }).data('transition', transition);

			var fromStatusText = getStatusName(transition.fromStatus);
			var toStatusText = getStatusName(transition.toStatus);

			if (obsoleteStates !== 'undefined') {
				for (var j = 0; j < obsoleteStates.length; ++j) {
					if (fromStatusText !== 'undefined' && fromStatusText != null && fromStatusText == obsoleteStates[j]) {0
						fromStatusText = fromStatusText + ' (' + i18n.message("issue.flag.Obsolete.label") + ')';
					}
					if (toStatusText !== 'undefined' && toStatusText != null && toStatusText == obsoleteStates[j]) {
						toStatusText = toStatusText + ' (' + i18n.message("issue.flag.Obsolete.label") + ')';
					}
				}
			}

			row.append($('<td>', { "class" : 'fromStatus textData columnSeparator' }).text(fromStatusText));
			row.append($('<td>', { "class" : 'toStatus textData columnSeparator' }).text(toStatusText));

			var link = $('<a>', { "class" : 'transitionLink' + (transition.eventId ? ' event' : transition.hidden ? ' hidden' : '') });

			if (transition.eventId) {
				var event = settings.events[transition.eventId];
				var label = event.phase || event.label || event.name;

				if (transition.eventId == 3) {
					label = label + ': ' + (transition.guard ? transition.guard.label || transition.guard.name || '--' : settings.changes.none);
				}

				link.text(label).attr('title', event.tooltip);
			} else {
				link.text(transition.name).attr('title', transition.description);
			}

			link.click(function() {
				editTransition(table, row, null, function(transition) {
					return insUpdTransition(table, row, transition);
				});
	  			return false;
			});

			var nameCell = $('<td>', { "class" : 'name textData columnSeparator' });
			nameCell.append($('<span>', { "class": 'transitionLinkContainer'}).append(link));
			row.append(nameCell);

			var menuBox = $('<span>', { 'class': "yuimenubaritemlabel yuimenubaritemlabel-hassubmenu"});
			var menuArrow = $('<img>', { 'src': contextPath + "/images/space.gif", 'class': 'menuArrowDown' + (codebeamer.userPreferences.alwaysDisplayContextMenuIcons ? ' always-display-context-menu' : '')});
			menuBox.append(menuArrow);
			nameCell.append(menuBox);

			row.append($('<td>', { "class" : 'action action-column-minwidth columnSeparator' }).workflowActionIcons(getActionContext(transition), transition.actions, settings.actions));

			var permissonsCell = $('<td>', { "class" : 'permissions textData' });
			row.append(permissonsCell);

			if (!transition.eventId) {
				permissonsCell.append($('<span>', {"class": settings.editable ? 'highlight-on-hover' : ''}).text(getGranted(transition.permissions)));

				if (settings.editable) {
					permissonsCell.editable(setTransitionPermissions, {
				        type      : 'transitionPermissions',
				        event     : 'click',
				        onblur    : 'cancel',
				        submit    : settings.submitText,
				        cancel    : settings.cancelText,
				        tooltip   : i18n.message("tracker.field.layout.inline.edit.hint"),
				        cssclass  : "transition-permission-form"
					});
				}
			}
			return row;
		}

		function insUpdTransition(table, row, transition) {
			var eventId  = transition.eventId || 0;
			var eventGrd = (eventId == 3 ? (transition.guard ? transition.guard.name || '--' : settings.changes.none) : '');
			var fromId   = getStatusIdx(transition.fromStatus);
			var toId     = getStatusIdx(transition.toStatus);
			var position = null;
			var conflict = false;

			if (!(transition.name && transition.name.length > 0)) {
				alert(settings.nameRequired);
				return false;
			}

			if (eventId == 0 && !(transition.permissions && transition.permissions.length > 0)) {
				alert(i18n.message("tracker.transition.permissions.required.message"));
				return false;
			}

			if (fromId == toId && eventId < 3) {
				alert(settings.fromToSame);
				return false;
			}

			if (eventId && !($.isArray(transition.actions) && transition.actions.length > 0)) {
				alert(i18n.message("tracker.workflow.event.actions.required"));
				return false;
			}

			$('tr.stateTransition', table).each(function() {
				var current = $(this);
				var check = current.data('transition');
				if (check) {
					var checkEvent = check.eventId || 0;
					var checkGuard = (checkEvent == 3 ? (check.guard ? check.guard.name || '--' : settings.changes.none) : '');
					var checkFrom  = getStatusIdx(check.fromStatus);
					var checkTo    = getStatusIdx(check.toStatus);

					if (fromId < checkFrom) {
						position = current;
						return false;
					} else if (fromId == checkFrom) {
						if (toId < checkTo) {
							position = current;
							return false;
						} else if (toId == checkTo) {
							if (eventId < checkEvent) {
								position = current;
								return false;
							} else if (eventId == checkEvent) {
								var guardDiff = eventGrd.localeCompare(checkGuard);
								if (guardDiff < 0) {
									position = current;
									return false;
								} else if (guardDiff == 0) {
									position = current;
									if (row == null || !current.is(row)) {
										// Error duplicate from/to
										conflict = true;
									}
									return false;
								}
							}
						}
					}
				}
			});

			if (conflict) {
				if (eventId) {
					var event = settings.events[eventId];
					alert(settings.event.duplicateText.replace('XXX', (event.label || event.name) + (eventId == 3 ? (': ' + eventGrd) : '')));
				} else {
					alert(settings.duplicateText);
				}
				return false;
			}

			if (row == null) {
				row = addTransition(table, transition);
			} else {
				setTransition(row, transition);

				if (row.is(position)) {
					return true;
				} else {
					row.detach();
				}
			}

			if (position == null) {
				$('tbody:first', table).append(row);
			} else {
				row.insertBefore(position);
			}

			return true;
		}

		function editStatus(table, status) {
			var tracker = table.data('tracker');
			var state = $.extend({}, status, {
				entryActions   : [],
				exitActions    : [],
				changeHandlers : {}
			});

			$('tr.stateTransition', table).each(function() {
				var row = $(this);
				var transition = row.data('transition');

				if (transition.eventId == 1 && transition.toStatus.id == status.id) {
					state.entryRow = row;
					state.entryActions = transition.actions;
				} else if (transition.eventId == 2 && transition.fromStatus.id == status.id) {
					state.exitRow = row;
					state.exitActions = transition.actions;
				} else if (transition.eventId == 3 && transition.fromStatus.id == status.id) {
					var change = (transition.guard ? transition.guard.name || '--' : settings.changes.none);
					state.changeHandlers[change] = {
						row     : row,
						guard   : transition.guard,
						actions : transition.actions
					};
				}
			});

			var popup = $('#stateTransitionEditor');
  			if (popup.length == 0) {
  				popup = $('<div>', { id : 'stateTransitionEditor', "class" : 'editorPopup', style : 'display: None;'} );
  				popup.insertAfter(table);
  			} else {
  				popup.empty();
  			}

  			popup.showStateActionsDialog(tracker, state, options, {
				title			: settings.state.label + ": " + (status.label || status.name),
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false

  			}, function(result) {
   				if ($.isArray(result.entryActions) && result.entryActions.length > 0) {
  					if (state.entryRow) {
  	  					insUpdTransition(table, state.entryRow, $.extend({}, state.entryRow.data('transition'), {
  	  						actions : result.entryActions
  	  					}));
  					} else {
  	  					insUpdTransition(table, null, {
  	  						tracker    : tracker,
  	  						eventId    : 1,
  	  						name       : settings.events[1].name + "-" + status.id,
  	  						fromStatus : {
	  	  	  					id     : -1,
	  	    					name   : settings.anyStatusLabel
	  	    				},
	  	  					toStatus   : status,
  	  						actions    : result.entryActions
  	  					});
  					}
  				} else if (state.entryRow) {
  					state.entryRow.remove();
  				}

  				if ($.isArray(result.exitActions) && result.exitActions.length > 0) {
  					if (state.exitRow) {
  	  					insUpdTransition(table, state.exitRow, $.extend({}, state.exitRow.data('transition'), {
  	  						actions : result.exitActions
  	  					}));
  					} else {
  	  					insUpdTransition(table, null, {
  	  						tracker    : tracker,
  	  						eventId    : 2,
  	  						name       : settings.events[2].name + "-" + status.id,
  	  						fromStatus : status,
  	  						toStatus   : {
	  	  	  					id     : -1,
	  	    					name   : settings.anyStatusLabel
	  	    				},
  	  						actions    : result.exitActions
  	  					});
  					}
  				} else if (state.exitRow) {
  					state.exitRow.remove();
  				}

  				if ($.isPlainObject(result.changeHandlers)) {
  					$.each(result.changeHandlers, function(change, handler) {
  						if ($.isPlainObject(handler) && $.isArray(handler.actions) && handler.actions.length > 0) {
  	  						var existing = state.changeHandlers[change];
  	  						if (existing && existing.row) {
	  	   	  					insUpdTransition(table, existing.row, $.extend({}, existing.row.data('transition'), {
	  	   	  						guard   : handler.guard,
	  	  	  						actions : handler.actions
	  	  	  					}));
	  	  					} else {
	  	  	  					insUpdTransition(table, null, {
	  	  	  						tracker    : tracker,
	  	  	  						eventId    : 3,
	  	  	  						name       : settings.events[3].name + "-" + status.id + (handler.guard && handler.guard.name ? '-' + handler.guard.name : ''),
	  	  	  						fromStatus : status,
	  	  	  						toStatus   : status,
	  	  	  						guard      : handler.guard,
	  	  	  						actions    : handler.actions
	  	  	  					});
	  	  					}

  							delete state.changeHandlers[change];
 						}
					});
  				}

				$.each(state.changeHandlers, function(change, handler) {
					handler.row.remove();
				});
  			});
		}

		function setup() {
			/** Add a context menu to state transitions */
            var stateTransitionsMenu = new ContextMenuManager({
                selector: "table.stateTransitions tr.stateTransition .yuimenubaritemlabel",
                trigger: "left",
                items: {
                	edit: {
	                    name: settings.editText,
	                    callback: function(key, options) {
	                        var table = options.$trigger.closest('table');
	                        var $trigger = options.$trigger.parents('tr');
	                        editTransition(table, $trigger, null, function(transition) {
	                            return insUpdTransition(table, $trigger, transition);
	                        });
	                    },
	                    disabled: function(key, options) {
	                        return !getSetting('editable');
	                    }
	                },
                    remove: {
                        name: settings.event.deleteLabel,
                        callback: function(key, options) {
                        	var msg = null;

                        	var transition = options.$trigger.parents("tr").data('transition');
                        	if (!transition.fromStatus){
                        		 msg = i18n.message("tracker.transition.delete.basic.confirm") + "<br/>" + msg;
                        	} else {
                            	var event = getSetting("events")[transition.eventId];
                            	msg = getSetting("event").deleteConfirm.replace('XXX', event.label || event.name);
                        	}

                        	showFancyConfirmDialogWithCallbacks(msg, function() {
                                options.$trigger.parents('tr').remove();
                                $("#saveStateTransitionsSubmitButton").click();
                            });
                        },
                        disabled: function(key, options) {
                            var tracker = options.$trigger.closest('table').data('tracker');
                            var transition = options.$trigger.parents("tr").data('transition');

                            return !getSetting('editable') || !transition.tracker || transition.tracker.id != tracker.id;
                        }
                    },
                    applyToAll: {
                    	name: i18n.message("tracker.transition.apply.permissions.label"),
                        disabled: function(key, options) {
                            var transition = options.$trigger.parents("tr").data('transition');
                            return !getSetting('editable') || !transition || transition.eventId;
                        },
                    	callback: function (key, options) {
                    		var transition = options.$trigger.parents("tr").data('transition');
                    		var permissions = transition.permissions;
                    		showFancyConfirmDialogWithCallbacks(i18n.message("tracker.transition.apply.permissions.confirm.message"), function () {
                        		$("tr.stateTransition").each(function () {
                        			var $row = $(this);
                        			var targetTransition = $row.data('transition');
                        			if (targetTransition && !targetTransition.eventId) {
                        				targetTransition.permissions = permissions;
                        				$('td.permissions', $row).text(getGranted(targetTransition.permissions));
                        			}
                        		});
                    		});
                    	}
                    }
                }
            });
			stateTransitionsMenu.render();

			/* Define an inplace editor for transition permissions */
			$.editable.addInputType('transitionPermissions', {
				element: function(settings, self) {
					var form = $(this);
					var transition = $(self).closest('tr').data('transition');

					form.transitionPermissions(transition.permissions, getSetting('permissions'));

					return this;
				},

				content: function(string, settings, self) {
					// Nothing
				},

				plugin: function(settings, self) {
					$('select.accessPerms', this).multiselect("open");
				}
			});
		}

		function init(container, tracker, transitions) {
			if (!$.isArray(transitions)) {
				transitions = [];
			}

			var table = $('<table>', { "class" : 'displaytag stateTransitions' }).data('tracker', tracker);
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>');
			headline.append($('<th>', { "class" : 'columnSeparator', style : 'width: 10%;' }).text(settings.fromLabel));
			headline.append($('<th>', { "class" : 'columnSeparator', style : 'width: 10%;' }).text(settings.toLabel));
			headline.append($('<th>', { "class" : 'columnSeparator', style : 'width: 10%;' }).text(settings.nameLabel));
			headline.append($('<th>', { "class" : 'columnSeparator', style : 'width: 5%;'  }).text(settings.actions.actionsLabel));
			headline.append($('<th>', { "class" : 'columnSeparator' }).text(settings.permissions.permissionsLabel));
			header.append(headline);

			var body = $('<tbody>');
			table.append(body);

			for (var i = 0; i < transitions.length; ++i) {
				body.append(addTransition(table, transitions[i]));
			}

			if (settings.editable) {
				var moreTransitions = $('<div>', { "class" : 'moreStateTransitions' });
				container.append(moreTransitions);

				var eventSelector = $('<select>', { "class" : 'eventSelector', title : settings.event.moreTitle, style: 'margin-left: 4px; margin-right: 4px;' });
				eventSelector.append($('<option>', { value : '-1', style : 'color: gray; font-style: italic;' }).text(transitions.length > 0 ? settings.event.moreLabel : settings.event.none));

				for (var i = 0; i < settings.events.length; ++i) {
					eventSelector.append($('<option>', { value : i, title : settings.events[i].tooltip, style : i == 0 ? 'color: black;' : 'font-style: italic; color: green;' }).text(settings.events[i].label || settings.events[i].name));
				};

				moreTransitions.append(eventSelector);

				eventSelector.change(function() {
					var value = parseInt(this.value);
					if (value >= 0) {
						editTransition(table, null, value, function(transition) {
							transition.tracker = table.data('tracker');

							if (insUpdTransition(table, null, transition)) {
								$('option:first', eventSelector).text(getSetting('event').moreLabel);
								return true;
							}
							return false;
						});

						this.options[0].selected = true;
					}
				});

				if (trackerLayoutLabelStatusId) {
					moreTransitions.append($('<a>', { "class": 'addStatus', "style": 'margin-left: 20px;' }).text(settings.addStatus).click(function() {
						$("#field_" + trackerLayoutLabelStatusId).find("> tr > td.layoutAndContent.textData > a").trigger("clickWithAutoSave");
					}));
				}

				var statesList = $('<ul>', { "class" : 'states', style: 'display: None;' });
				for (var i = 0; i < settings.statusOptions.length; ++i) {
					var status = settings.statusOptions[i];

					statesList.append($('<li>', { "class" : 'state' }).text(status.name).data('status', status).click(function() {
						editStatus(table, $(this).data('status'));
					}));
				}

				container.append(statesList);
			}
		}

		if ($.fn.stateTransitionList._setup) {
			$.fn.stateTransitionList._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), tracker, transitions);
		});
	};

	$.fn.stateTransitionList._setup = true;


	// A plugin to get all transitions in a transition list/table
	$.fn.getStateTransitions = function() {
		var transitions = [];

		$('table.stateTransitions tr.stateTransition', this).each(function() {
			var row = $(this);
			var transition = row.data('transition');
			if (transition) {
				// Because we have invoked workflowActionIcons() on the transition
				row.cleanupWorkflowAction(transition.actions);

				transitions.push(transition);
			}
		});

		return transitions;
	};

	// A plugin to show the editor for a specific state transition
	$.fn.showStateTransitionEditor = function(transitionId) {
		$('table.stateTransitions tr.stateTransition', this).each(function() {
			var row = $(this);
			var transition = row.data('transition');
			if (transition && transition.id == transitionId) {
				$('td.name a.transitionLink', row).click();
				return false;
			}
		});
	};

	// State transition Editor Plugin definition.
	$.fn.stateActionsEditor = function(tracker, state, options) {
		var settings = $.extend( {}, $.fn.stateTransitionEditor.defaults, options );
		settings.changes = $.extend( {}, $.fn.stateTransitionEditor.defaults.changes, options.changes );
		settings.changes.nameLabel = settings.nameLabel;

		settings.actions = $.extend( {}, $.fn.stateTransitionEditor.defaults.actions, options.actions );
		settings.actions.condition = $.extend({}, settings.actions.condition, {
				viewTypeId : [1, 4]
		});
		disableTransitionEditigForTestRunTracker(settings);

		function getSetting(name) {
			return settings[name];
		}

		function getFields() {
			var fields = settings.fieldsVisibleInState;
			if (!$.isArray(fields)) {
				var params = {
					tracker_id : tracker.id,
					toStatusId : state.id
				};

	 	        $.ajax(settings.transitionFieldsUrl, {type: 'GET', data: params, dataType: 'json', async: false, cache: false}).done(function(result) {
	 	        	settings.fieldsVisibleInState = result;
	 	        	fields = result;
	 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	 	    		settings.fields = [];
	 	    		try {
	 		    		var exception = $.parseJSON(jqXHR.responseText);
	 		    		alert(exception.message);
	 	    		} catch(err) {
	 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	 	    		}
	 	    	});
			}

			return fields;
		}

		function showChangeFilter(selector, viewId, callback) {
			var tracker = selector.data('tracker');
			var config  = selector.data('config');
			var view = {
				tracker_id      : tracker.id,
				viewTypeId      : config.viewTypeId,
				viewLayoutId    : 0,
				creationType    : config.creationType,
				forcePublicView : true
	  		};

			if (viewId) {
				view.view_id = viewId;
			}

			var popup = selector.next('div.filterPopup');
			if (popup.length == 0) {
				popup = $('<div>', { "class" : 'filterPopup', style : 'display: None;'} );
				popup.insertAfter(selector);
			}

			popup.showTrackerViewConfigurationDialog(view, config, {
				title			: viewId ? config.editLabel : config.newLabel,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				editable		: true,
				viewUrl			: settings.trackerViewUrl,
				submitText		: settings.submitText,
				cancelText		: settings.cancelText,
				validator		: function(view, stats) {
					try {
						return config.validator(view, stats);
					} catch(ex) {
						alert(config[ex] || ex);
					}
					return false;
				}
			}, callback);
		}

		function addChangeHandler(context, handler) {
			var handlerRow     = $('<tr>', { "class" : 'changeHandler' }).data('guard', handler.guard);
			var handlerLabel   = $('<td>', { "class" : 'labelCell optional', style : 'padding-left: 0px; vertical-align: top;', title : handler.guard ? handler.guard.description : '' }).text((handler.guard ? handler.guard.name || '--' : settings.changes.none) + ':');
			var handlerActions = $('<td>', { "class" : 'updateActions dataCell' });

			handlerActions.workflowActionList(context, handler.actions, settings.actions);

			handlerRow.append(handlerLabel);
			handlerRow.append(handlerActions);

			return handlerRow;
		}

		function init(form, tracker, state) {
			var context = {
				tracker 	  : tracker,
				status  	  : state,
				fields  	  : getFields,
				allowNewChild : true
			};

			if (!$.isPlainObject(state)) {
				state = {
					entryActions   : [],
					exitActions    : [],
					changeHandlers : {}

				};
			}

			form.helpLink(settings.help);

			var table = $('<table>', { "class" : 'stateEditor formTableWithSpacing' }).data('state', state);

			var phase = settings.events[1]; // Entry

			var entryRow   = $('<tr>', { valign : 'middle' });
			var entryLabel = $('<td>', { "class" : 'labelCell optional', style : 'vertical-align: top;', title : phase.tooltip }).text((phase.phase || phase.label) + ':');
			var entryCell  = $('<td>', { "class" : 'entryActions dataCell' });

			entryCell.workflowActionList(context, state.entryActions, settings.actions);

			entryRow.append(entryLabel);
			entryRow.append(entryCell);
			table.append(entryRow);

			phase = settings.events[3]; // Update

			var updateRow   = $('<tr>', { valign : 'middle' });
			var updateLabel = $('<td>', { "class" : 'labelCell optional', style : 'padding-top: 10px; vertical-align: top;', title : phase.tooltip }).text((phase.phase || phase.label) + ':');
			var updateCell  = $('<td>', { "class" : 'changeHandlers dataCell' });

			var handlerTable = $('<table>', { "class" : 'changeHandlers' });
			var handlerCount = 0;

			if ($.isPlainObject(state.changeHandlers)) {
				$.each(state.changeHandlers, function(change, handler) {
					handlerTable.append(addChangeHandler(context, handler));
					handlerCount++;
				});
			}

			if (settings.editable) {
				var moreHandlersRow = $('<tr>', { "class" : 'moreChangeHandlers' });
				var moreHandlerCell = $('<td>', { "class" : 'moreChangeHandlers', colspan : 2, style : 'padding-left: 0px;' });
				var changeFilterSelector = $('<select>', { "class" : 'changeFilters' }).data('tracker', tracker).data('config', settings.changes);

				changeFilterSelector.append($('<option>', { "class" : 'changeFilter', value : '-1', style : 'color: gray; font-style: italic;' }).text(handlerCount > 0 ? settings.event.moreLabel : settings.event.none));

    			var changeFilter = $('<option>', { "class" : 'changeFilter', value : 0 }).text(settings.changes.none).data("guard", null);
    			if (state.changeHandlers.hasOwnProperty(settings.changes.none)) {
    				changeFilter.attr('style', 'display: None;');
    			}
    			changeFilterSelector.append(changeFilter);

		        $.get(settings.trackerFiltersUrl, {tracker_id : tracker.id, viewTypeId : settings.changes.viewTypeId, creationType : settings.changes.creationType}).done(function(filters) {
		        	for (var i = 0; i < filters.length; ++i) {
		    			changeFilter = $('<option>', { "class" : 'changeFilter', value : filters[i].id, title : filters[i].description }).text(filters[i].name).data("guard", filters[i]);
		    			if (state.changeHandlers.hasOwnProperty(filters[i].name)) {
		    				changeFilter.attr('style', 'display: None;');
		    			}
		    			changeFilterSelector.append(changeFilter);
		    		}
		    	}).fail(function(jqXHR, textStatus, errorThrown) {
		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        });

				moreHandlerCell.append(changeFilterSelector);
				moreHandlersRow.append(moreHandlerCell);
				handlerTable.append(moreHandlersRow);

				changeFilterSelector.change(function() {
					var value = parseInt(this.value);
					if (value >= 0) {
						var selectedFilter = $('option.changeFilter:selected', changeFilterSelector);

						addChangeHandler(context, {
							guard   : selectedFilter.data('guard'),
							actions : []

						}).insertBefore(moreHandlersRow);

						$('option.changeFilter:first', changeFilterSelector).text(getSetting('event').moreLabel);

						this.options[0].selected = true;
						selectedFilter.hide();
					}
				});
			}

			updateCell.append(handlerTable);
			updateRow.append(updateLabel);
			updateRow.append(updateCell);
			table.append(updateRow);

			phase = settings.events[2]; // Exit

			var exitRow   = $('<tr>', { valign : 'middle' });
			var exitLabel = $('<td>', { "class" : 'labelCell optional', style : 'vertical-align: top;', title : phase.tooltip }).text((phase.phase || phase.label) + ':');
			var exitCell  = $('<td>', { "class" : 'exitActions dataCell' });

			exitCell.workflowActionList(context, state.exitActions, settings.actions);

			exitRow.append(exitLabel);
			exitRow.append(exitCell);
			table.append(exitRow);

			form.append(table);
		}

		function setup() {
			// Add a context menu to transition guard selectors
			$.contextMenu({
				selector : "tr.changeHandler > td.labelCell",
				items    : {
					editFilter : {
						name     : settings.guard.editLabel,
						callback : function(key, options) {
							var changeHandler = options.$trigger.closest('tr.changeHandler');
							var filter = changeHandler.data('guard');
							if (filter && filter.id) {
			      				var selector = changeHandler.closest('table.changeHandlers').find('select.changeFilters');

								showChangeFilter(selector, filter.id, function(view) {
									if (view && view.name != null) {
										var option = $('option.changeFilter[value="' + filter.id + '"]', selector);
										option.text(view.name).attr('title', view.description).data('guard', view);

										options.$trigger.text(view.name + ':').attr('title', view.description).data('guard', view);
									}
								});
							}
						},
						disabled : function(key, options) {
							var filter = options.$trigger.closest('tr.changeHandler').data('guard');
							return !(filter && filter.id);
						}
					},

	              remove : {
            		  name     : settings.changes.deleteLabel,
		      		  callback : function(key, options) {
		      			  var changeHandler = options.$trigger.closest('tr.changeHandler');
		      			  if (confirm(getSetting('changes').deleteConfirm)) {
		      				  var guard    = changeHandler.data('guard');
		      				  var table    = changeHandler.closest('table.changeHandlers');
		      				  var selector = table.find('select.changeFilters');

		      				  changeHandler.remove();

		      				  $('option.changeFilter[value="' + (guard ? guard.id : 0) + '"]', selector).show();

		      				  if ($('tr.changeHandler', table).length == 0) {
		      					  $('option.changeFilter:first', selector).text(getSetting('event').none);
		      				  }
		      			  }
		      		  }
            	   }
				},
   	           	autoHide: true
		    });

			// Add a context menu to transition guard selectors
			$.contextMenu({
				selector : "select.changeFilters",
				items    : {
            	   addFilter : {
            		  name     : settings.guard.newLabel,
		      		  callback : function(key, options) {
		      			  var selector = options.$trigger;
		      			  showChangeFilter(selector, null, function(view) {
		      				  if (view && view.id > 0) {
		      					  selector.append( $('<option>', { "class" : 'changeFilter', value : view.id, title : view.description, selected : true }).text(view.name).data("guard", view)).change();
		      				  }
		      			  });
		      		  }
 					}
				},
	           	autoHide: true
	    	});
		}

		if ($.fn.stateActionsEditor._setup) {
			$.fn.stateActionsEditor._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), tracker, state);
		});
	};

	$.fn.stateActionsEditor._setup = true;



	// A plugin to get the transition settings back from an editor
	$.fn.getStateActions = function(settings) {
		var result = {};

		var editor = $('table.stateEditor', this);
		if (editor.length > 0) {
			result = $.extend(result, editor.data('state'), {
				entryActions   : $('td.entryActions', editor).getWorkflowActions(),
				exitActions    : $('td.exitActions',  editor).getWorkflowActions(),
				changeHandlers : {}
			});

			$('table.changeHandlers tr.changeHandler', editor).each(function() {
				var row   = $(this);
				var guard = row.data('guard');

				if (guard && guard.name) {
					result.changeHandlers[guard.name] = {
						guard   : guard,
						actions : $('td.updateActions', row).getWorkflowActions(),
					};

				} else {
					result.changeHandlers[settings.changes.none] = {
						actions : $('td.updateActions', row).getWorkflowActions(),
					};
				}
			});
		}

		return result;
	};

	$.fn.showStateActionsDialog = function(tracker, state, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showStateTransitionDialog.defaults, dialog );
		disableTransitionEditigForTestRunTracker(settings);

		var popup    = this;

		popup.stateActionsEditor(tracker, state, config);

		if (config.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
					 		try {
							 	var result = callback(popup.getStateActions(config));
							 	if (!(result == false)) {
						  			popup.dialog("close");
						  			popup.remove();
							 	}
							} catch(ex) {
								alert(ex);
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


	// A plugin to show the editor for a specific state node
	$.fn.showStateNodeEditor = function(statusId) {
		$('ul.states > li.state', this).each(function() {
			var item = $(this);
			var status = item.data('status');
			if (status && status.id == statusId) {
				item.click();
				return false;
			}
		});
	};


})( jQuery );

