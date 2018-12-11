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

	// Tracker Field Allowed/Default values per status definition.
	$.fn.editFieldDefaultValues = function(field, statusSpecific, options) {
		var settings = $.extend( {}, $.fn.editFieldDefaultValues.defaults, options );
		var hoverClass = 'highlight-on-hover-w-pencil';

		function getSetting(name) {
			return settings[name];
		}

		function getValuesForStatus(statusSpecific, status) {
			if ($.isArray(statusSpecific)) {
				for (var i = 0; i < statusSpecific.length; ++i) {
					if (statusSpecific[i].status == status) {
						return statusSpecific[i];
					}
				}
			}
			return { status : status, defaultValue : null, filter : null, flags : null };
		}

		function makeMultiselect(field, editor, emptyText) {
			if (editor.is('select[multiple="multiple"]')) {
				var multiselect = editor.multiselect({
		    		checkAllText	 : settings.checkAllText,
		    	 	uncheckAllText	 : emptyText,
		    	 	noneSelectedText : emptyText,
		    	 	autoOpen		 : false,
		    	 	multiple         : true,
		    	 	selectedList	 : 99,
		    	 	minWidth		 : 300 //'auto'
		    	});

				if ($('option', editor).length > 25) {
					multiselect.multiselectfilter({
						label		: settings.filterText + ':',
						placeholder : field.name
					});
				}
			}
		}

		function showFilters(filters, twoMan) {
			if (twoMan) {
				if (filters.length > 0) {
					return filters + ' <span class="subtext" title="' + settings.twoManRuleTitle + '">(' + settings.twoManRuleLabel + ')</span>';
				}

				return '<span class="subtext" title="' + settings.twoManRuleTitle + '">(' + settings.twoManRuleLabel + ')</span>';
			}

			return filters;
		}

		function setReferences(container, references, emptyText) {
			var labels = [];

			if ($.isArray(references)) {
				for (var i = 0; i < references.length; ++i) {
					labels.push(references[i].label);
				}
			}

			container.data('references', references);

			return labels.length > 0 ? labels.join(', ') : emptyText;
		}

		function setFilterValue() {
			var container = $(this);
			var filters = setReferences(container, container.getReferences(), settings.anyText) ;
			var twoMan  = ($('input[type="checkbox"][name="twoManRule"]:checked', this).length > 0);

			container.prev('input[type="hidden"][name="flags"]').val(twoMan ? 3 : 0);

			return showFilters(filters, twoMan);
		}

		function setDefaultValue() {
			var container = $(this);
			return setReferences(container, container.getReferences(), '--');
		}

		function setup() {
			/* Define an inplace editor for filters of type members/references */
		    $.editable.addInputType('fieldFilterValue', {
		        element : function(settings, self) {
					var form   = $(this);
					var editor = $(self);
					var field  = $.extend({}, editor.data('field'), {
						htmlName : 'filterRefs',
						showUnset: true
					});

					var references = editor.data('references');

					if (field.type == 5) {
						// Member field filters always allow all enclosing member types of the field member type
						form.membersField(references, $.extend({}, field, {
							memberType : field.memberType | ((field.memberType & 2) == 2 ? 12 :
														    ((field.memberType & 4) == 4 ?  8 : 0))
						}));

						// Two-Men-Rule is only applicable for member fields that allow users
						if ((field.memberType & 2) == 2) {
							var flags  = parseInt(editor.prev('input[type="hidden"][name="flags"]').val());
							var twoMan = $('<input>', { type : 'checkbox', name : 'twoManRule', value : 3, checked : (isNaN(flags) ? false : (flags & 1) == 1) });
							var label  = $('<label>', { title : getSetting('twoManRuleTitle') });
							label.append(twoMan);
							label.append(getSetting('twoManRuleLabel'));

							form.append(label);
				 	        form.append($('<br>'));
		    			}
					} else {
						form.referenceField(references, field);
					}

		           	return this;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	},

		        plugin : function(settings, self) {
		          	$(this).referenceFieldAutoComplete();
		        }
		    });

		    /* Define an inplace editor for default values of type members/references */
		    $.editable.addInputType('fieldDefaultValue', {
		        element : function(settings, self) {
					var form   = $(this);
					var editor = $(self);
					var field  = $.extend({}, editor.data('field'), {
						htmlName : 'defaultValueRefs',
						showUnset: true,
						showCurrentUser : true
					});

					var references = editor.data('references');

					if (field.type == 5) {
						form.membersField(references, field);
					} else {
						form.referenceField(references, field);
					}

		           	return this;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	},

		        plugin : function(settings, self) {
		          	$(this).referenceFieldAutoComplete();
		        }
		    });
		}

		function init(container, field, statusSpecific) {
			if (!$.isArray(statusSpecific)) {
				statusSpecific = [];
			}

			var states = [{ id : null, name : '--'}];

			var statusOptions = settings.statusOptions;
			if (typeof(statusOptions) == 'function') {
				statusOptions = settings.statusOptions();
			}

			if ($.isArray(statusOptions) && statusOptions.length > 0) {
				states.push.apply(states, statusOptions);
			}

			var restrictable = (field.id != 7 && (field.type >= 5 && field.type <= 9));
			var fieldFilter = $.extend( {}, field, {
				multiple    : 'true',
				emptyLabel  : settings.anyText,
				defaultLabel: settings.anyText
			});

			var table = $('<table>', { "class" : 'defaultValuesPerStatus displaytag', style : 'margin-top: 0.5em;' });
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>');
			header.append(headline);

			headline.append($('<th>', { "class" : 'textData', style : 'text-align: right; padding-right: 1em !important; width: 5%;' }).text(settings.statusLabel));
			if (restrictable) {
				headline.append($('<th>', { "class" : 'textData' }).text(settings.allowedValuesLabel));
			}
			headline.append($('<th>', { "class" : 'textData' }).text(settings.defaultValueLabel));

			var body = $('<tbody>');
			table.append(body);

			for (var i = 0; i < states.length; ++i) {
				var values = getValuesForStatus(statusSpecific, states[i].id);

				var status = $('<tr>', { "class" : ('status ' + (i % 2 == 0 ? 'even' : 'odd')), style : 'width: 5%;' });
				body.append(status);

				var statusName = $('<td>', { "class" : 'accessPermsStatus ' + ((i == 0 || $.inArray(states[i].id, settings.workflowStates) >= 0) ? 'active' : 'unused'), style : 'vertical-align: top !important; width: 5%;' });
				statusName.append($('<input>', { type : 'hidden', name : 'status', value : states[i].id }));
				statusName.append($('<label>').text(states[i].name)).append(' : ');
				status.append(statusName);

				if (restrictable) {
					var allowedValues = $('<td>', { "class" : 'allowedValues textDataWrap' } );
					allowedValues.append($('<input>', { type : 'hidden', name : 'flags', value : values.flags }));

					var filterEditor = settings.fieldValueEditor('filter', fieldFilter, [{value: 'NULL',  label: '--'}], values.filter);
					if (filterEditor != null) {
						allowedValues.append(filterEditor);
						makeMultiselect(fieldFilter, filterEditor, settings.anyText);
					} else {
						filterEditor = $('<span>', { "class" : 'filter ' + hoverClass });
						filterEditor.data('field', fieldFilter);
						filterEditor.html(showFilters(setReferences(filterEditor, values.filter, settings.anyText), (values.flags && (values.flags & 1) == 1)));

						allowedValues.append(filterEditor);

						if (settings.editable) {
							filterEditor.editable(setFilterValue, {
						        type      : 'fieldFilterValue',
						        event     : 'click',
						        onblur    : 'cancel',
						        submit    : settings.submitText,
						        cancel    : settings.cancelText,
						        tooltip   : settings.editTooltip,
						        onedit    : function() {
						        	$(this).removeClass(hoverClass);
						        },
						        onreset   : function() {
						        	$(this).closest('span').addClass(hoverClass);
						        },
						        onsubmit  : function() {
						        	$(this).closest('span').addClass(hoverClass);
						        }
							});
						}
					}

					status.append(allowedValues);
				}

				var defaultValue  = $('<td>', { "class" : 'defaultValue textDataWrap', style : 'width : 30%;' } );
				var defaultEditor = settings.fieldValueEditor('defaultValue', field, [{value: '',  label: '--'}], values.defaultValue);
				if (defaultEditor != null) {
					defaultValue.append(defaultEditor);
					makeMultiselect(field, defaultEditor, settings.noneText);
				} else {
					defaultEditor = $('<span>', { "class" : 'defaultValue ' + hoverClass });
					defaultEditor.data('field', field);
					defaultEditor.text(setReferences(defaultEditor, values.defaultValue, '--'));

					defaultValue.append(defaultEditor);

					if (settings.editable) {
						defaultEditor.editable(setDefaultValue, {
					        type      : 'fieldDefaultValue',
					        event     : 'click',
					        onblur    : 'cancel',
					        submit    : settings.submitText,
					        cancel    : settings.cancelText,
					        tooltip   : settings.editTooltip,
					        onedit    : function() {
					        	$(this).removeClass(hoverClass);
					        },
					        onreset   : function() {
					        	$(this).closest('span').addClass(hoverClass);
					        },
					        onsubmit  : function() {
					        	$(this).closest('span').addClass(hoverClass);
					        }
						});
					}
				}
				status.append(defaultValue);

/* Does not work well with single select elements, the draggable consumes the clicks, so selection popup not working any longer !!
				defaultValue.draggable({
					cancel			: '',
					helper			: 'clone',
					revert			: true,
					revertDuration	: 0,
					containment		: body,
					cursor			: "move",
					delay			: 150,
					distance		: 5,
					scroll			: true
				});

				defaultValue.droppable({
					accept: 'td.defaultValue',
					drop  : function(event, ui) {
								var container = $(this);
								if (!container.is(ui.draggable)) {
									var value = $('[name="defaultValue"]', ui.draggable);
									if (value.is('select[multiple="multiple"]')) {
										var dfltVals = [];
										var selected = value.multiselect('getChecked');
										if (selected) {
											for (var i = 0; i < selected.length; ++i) {
												dfltVals.push(selected[i].value);
											}
										}
										value = dfltVals.join(',');
									} else {
										value = value.val();
									}

									var editor = settings.fieldValueEditor('defaultValue', field, [{value: '',  label: '--'}], value);
									if (editor != null) {
										container.empty().append(editor);
										makeMultiselect(field, editor);
									}
								}
							}
				});
*/
			}
		}

		if ($.fn.editFieldDefaultValues._setup) {
			$.fn.editFieldDefaultValues._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), field, statusSpecific);
		});
	};

	$.fn.editFieldDefaultValues._setup = true;

	$.fn.editFieldDefaultValues.defaults = {
		editable			: false,
		statusOptions		: [],
		workflowStates		: [],
		fieldValueEditor	: function(name, fieldId, fieldType, special, value) { return null; },
		linkLabel			: 'Allowed/Default values',
		linkTitle			: 'The allowed/default field values per status',
		twoManRuleLabel		: 'Two-man rule',
		twoManRuleTitle		: 'Separation of duty, by enforcing that a different person is assigned to this task in this status than before',
		statusLabel			: 'Status',
		allowedValuesLabel  : 'Allowed values',
		defaultValueLabel	: 'Default value',
		anyText  			: 'Any',
		noneText  			: 'None',
		filterText			: 'Filter',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all',
		submitText			: 'OK',
		cancelText			: 'Cancel'
	};


	// Get the defined Tracker Field Allowed/Default values per status
	$.fn.getFieldDefaultValues = function() {

		function getValue(row, name) {
			var result = null;

			var editor = $('[name="' + name + '"]', row);
			if (editor.length > 0) {
				if (editor.is('select[multiple="multiple"]')) {
					var values = [];
					var selected = editor.multiselect('getChecked');
					if (selected) {
						for (var i = 0; i < selected.length; ++i) {
							values.push(selected[i].value);
						}
					}
					result = values.join(',');
				} else {
					result = editor.val();
				}
			} else if ((editor = $('span.' + name, row)).length > 0) {
				result = editor.data('references');
			}
			return result;
		}

		var result = [];

		$('table.defaultValuesPerStatus tr.status', this).each(function() {
			var status = parseInt($('input[name="status"]', this).val());
			var flags  = parseInt($('input[name="flags"]',  this).val());
			var filter = getValue(this, 'filter');
			var defaultValue = getValue(this, 'defaultValue');

			if (isNaN(status)) {
				status = null;
			}

			if (isNaN(flags) || flags == 0) {
				flags = null;
			}

			if ((filter && filter.length > 0) || (flags && flags > 0) || (defaultValue && defaultValue.length > 0)) {
				result.push({
					status 		 : (isNaN(status) ? null : status),
					defaultValue : defaultValue,
					filter 		 : filter,
					flags 		 : flags
				});
			}
		});

		return result;
	};


	// A third plugin to show the field allowed/default values per status in a dialog
	$.fn.showFieldDefaultValuesDialog = function(field, statusSpecific, options, dialog, callback) {
		var settings = $.extend( {}, $.fn.showFieldDefaultValuesDialog.defaults, dialog );

		var popup = this;
		popup.editFieldDefaultValues(field, statusSpecific, options);

		if (options.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : options.submitText,
				 click: function() {
							var defaultValues = popup.getFieldDefaultValues();
						 	callback(defaultValues);

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

	$.fn.showFieldDefaultValuesDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true
	};


})( jQuery );
