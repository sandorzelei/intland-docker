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

	/**
	 * Check if the specified field update value is empty
	 */
	function isEmpty(value) {
		if ($.isPlainObject(value) &&
			((typeof value.value === 'string' && value.value.trim().length > 0) ||
			 ($.isArray(value.value) && value.value.length > 0) ||
			 (typeof value.copyFrom === 'number' && value.copyFrom > 0) ||
			 ($.isPlainObject(value.copyFrom) && value.copyFrom.id) ||
			 (typeof value.computeAs === 'string' && value.computeAs.trim().length > 0))) {
			return false;
		}
		return true;
	}


	/**
	 * A small helper plugin to convert a <select> into a multi-select widget
	 */
	$.fn.makeMultiSelect = function(field, settings) {
		return this.each(function() {
			var editor = $(this);

			if (editor.is('select[multiple="multiple"]')) {
				var multiselect = editor.multiselect({
					appendTo 		 : $("body"),
		    		checkAllText	 : settings.checkAllText,
		    	 	uncheckAllText	 : settings.unsetLabel,
		    	 	noneSelectedText : '--',
		    	 	autoOpen		 : false,
		    	 	multiple         : true,
		    	 	selectedList	 : 99,
		    	 	minWidth		 : 300 //'auto'
		    	});

				if ($('option', editor).length > 25) {
					multiselect.multiselectfilter({
						label		: settings.filterText + ':',
						placeholder : field.label || field.name
					});
				}
			}
		});
	};


	/**
	 * Tracker field updates plugin.
	 * - context must be an object, with at least
	 *    + tracker : an object with at least id, name and project (id and name)
	 *    + status  : either an object with at least id and name or a function, that returns a status object
	 *    + fields  : either an array of the (editable) fields to update (in the specified status) or a function, that returns such a field array
	 *    * source  : optional (an underlying context where field values can be copied from) or null
	 */
	$.fn.trackerFieldUpdate = function(context, field, update, options, settings) {
		if (!$.isPlainObject(settings)) {
			settings = $.extend( {}, $.fn.trackerFieldUpdates.defaults, options);
		}

		function getSetting(name) {
			return settings[name];
		}

		function getSourceFields(context) {
			var sourceFields = (context.source ? context.source.fields : null);
			if ($.isFunction(sourceFields)) {
				sourceFields = sourceFields();
			}
			return $.isArray(sourceFields) ? sourceFields : [];
		}

		function getOp(context, field, update) {
			if (typeof update.op == 'undefined' || update.op == null) {
				update.op = (field.id == 88 && !context.updateMandatory ? 6 : 1);
			}

			if (typeof update.op == 'number') {
				for (var i = 0; i < settings.fieldUpdateOps.length; ++i) {
					if (settings.fieldUpdateOps[i].id == update.op) {
						update.op = settings.fieldUpdateOps[i];
						break;
					}
				}
			}

			return update.op;
		}

		function isApplicable(context, field, first, op) {
			if (first && context.updateMandatory) { // For new issues
				return op.id == 1;
			} else if (field.id == 88) { // Comments/Attachments
				return op.id == 6;  // BUG-772472: Only allow adding new comments/attachments
			} else if ((op.id > 0 || (!field.required || context.allowClearAll)) && (!$.isArray(op.fieldTypes) || isValueSelected(field.type, op.fieldTypes)))  {
				switch(op.id) {
				case 0: // Clear
				case 1: // Set
					return first;
				case 6: // Add
				case 7: // Remove:
				case 8: // Retain
					if (!field.multiple) {
						return false;
					}
				}

				return true;
			}
			return false;
		}

		function getValueType(update) {
			var type = settings.valueTypes[0];  // None

			if ($.isPlainObject(update)) {
				if (update.hasOwnProperty('value')) {
					type = settings.valueTypes[1];  // Value
				} else if (update.hasOwnProperty('copyFrom')) {
					type = settings.valueTypes[2];  // ValueOf
				} else if (update.hasOwnProperty('computeAs')) {
					type = settings.valueTypes[3];  // ResultOf
				}
			}

			return type;
		}

		function getCopyFrom(context, update) {
			if ($.isPlainObject(update.copyFrom) && update.copyFrom.id) {
				return update.copyFrom;
			} else if (typeof update.copyFrom == 'number') {
				var sourceFields = getSourceFields(context);
				for (var i = 0; i < sourceFields.length; ++i) {
					if (sourceFields[i].id == update.copyFrom) {
						update.copyFrom = sourceFields[i];
						return update.copyFrom;
					}
				}
			}

			delete update.copyFrom;
			return null;
		}

		function isAssignable(context, field, value) {
			if (!(context.allowClearAll && field.id == value.id)) {
				if (field.id == 88) { // Comments/Attachments
					return value.id == 88 || value.type == 0 || value.type == 10;
				} else if (field.type == 0 || field.type == 10) {  // (wiki)text
					return value.type == 0 || value.type == 10;
				} else if (field.type == 2) { // float
					return value.type == 1 || value.type == 2;
				} else if (field.type == 5) { // principal
					return (value.type == 5 && (field.memberType & value.memberType) != 0) ||
					       (value.type == 7 && value.refType == 1 && (field.memberType & 2) == 2);
				} else if (field.type == 7) { // reference
					return value.type == 7 && field.refType == value.refType;
				} else {
					return value.type == field.type;
				}
			}
			return false;
		}

		function getAssignableFields(context, field) {
			var result = [];

			var sourceFields = getSourceFields(context);
			for (var i = 0; i < sourceFields.length; ++i) {
				if (isAssignable(context, field, sourceFields[i])) {
					result.push(sourceFields[i]);
				}
			}

			return result;
		}

		function isValueSelected(value, selected) {
			if ($.isArray(selected)) {
				for (var i = 0; i < selected.length; ++i) {
					if ($.isPlainObject(selected[i])) {
						if (value == selected[i].value) {
							return true;
						}
					} else if (value == selected[i]) {
						return true;
					}
				}
			} else if (selected != null && value == selected) {
				return true;
			}
			return false;
		}

		function getProjects(context, field, project) {
			if (!$.isArray(field.options)) {
				var categories = $.isArray(project.category) ? project.category : (typeof project.category === 'string' ? [project.category] : []);

				field.options = [];

				$.ajax(settings.projectsUrl, {
					type		: 'POST',
					async		: false,
					data 		: JSON.stringify(categories),
					contentType : 'application/json',
					dataType 	: 'json'
				}).done(function(projects) {
					if ($.isArray(projects) && projects.length > 0) {
						for (var i = 0; i < projects.length; ++i) {
							field.options.push($.extend({}, projects[i], {
								value : '2-' + projects[i].id
							}));
						}
					}
				}).fail(function(jqXHR, textStatus, errorThrown) {
		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        });
			}

			return field.options;
		}

		function getTrackers(context, field, tracker) {
			if (!$.isArray(field.options)) {
				var trkTypes  = $.isArray(tracker.type)    ? tracker.type    : (typeof tracker.type    === 'number' ? [tracker.type]    : null);
				var refTypes  = $.isArray(tracker.refType) ? tracker.refType : (typeof tracker.refType === 'string' ? [tracker.refType] : null);

		    	field.options = [];

				if (tracker.referring) {
					// Get trackers referring to current tracker
		 	        $.ajax(settings.referringTrackersUrl, {
		 	        	type	: 'GET',
		 	        	data	: {
		 	        		tracker_id : context.tracker.id,
		 	        		forInsert  : tracker.forInsert || false
		 	        	},
		 	        	dataType : 'json',
		 	        	async	 : false,
		 	        	cache	 : false
		 	        }).done(function(references) {
						$.each(references, function(refType, trackers) {
							if (refTypes == null || isValueSelected(refType, refTypes)) {
								for (var i = 0; i < trackers.length; ++i) {
									if (trkTypes == null || isValueSelected(trackers[i].type, trkTypes)) {
										field.options.push($.extend({}, trackers[i], {
											value : '3-' + trackers[i].id,
											label : trackers[i].project.name + ' \u00BB ' + trackers[i].name
										}));
									}
								}
							}
						});
		 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
		 	    		try {
		 		    		var exception = $.parseJSON(jqXHR.responseText);
		 		    		alert(exception.message);
		 	    		} catch(err) {
		 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		 	    		}
		 	    	});
				} else if (context.tracker.project) { // Get project trackers
		 	        $.ajax(settings.projectTrackersUrl, {
		 	        	type	: 'GET',
		 	        	data	: {
							proj_id : context.tracker.project.id,
							typeId  : 3 //Tracker, not Repository
						},
		 	        	dataType: 'json',
		 	        	async	: false,
		 	        	cache	: false
		 	        }).done(function(trackersPerPath) {
						for (var j = 0; j < trackersPerPath.length; ++j) {
	//						var path     = trackersPerPath[j].path;
							var trackers = trackersPerPath[j].trackers;

							for (var i = 0; i < trackers.length; ++i) {
								if (trkTypes == null || isValueSelected(trackers[i].type, trkTypes)) {
									field.options.push($.extend({}, trackers[i], {
										value : '3-' + trackers[i].id
									}));
								}
							}
						}
		 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
		 	    		try {
		 		    		var exception = $.parseJSON(jqXHR.responseText);
		 		    		alert(exception.message);
		 	    		} catch(err) {
		 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		 	    		}
		 	    	});
				}
			}

			return field.options;
		}

		function getFieldOptions(context, field) {
			if (!$.isArray(field.options)) {
				var params = {
					tracker_id : context.tracker.id,
					fieldId	   : field.id
				};

				var status = context.status;
				if ($.isFunction(status)) {
					status = status();
				}

				if (status && status.id != null) {
					params.statusId = status.id;
				}

	        	// Get field options from server
	 	        $.ajax(settings.fieldOptionsUrl, {
	 	        	type	: 'GET',
	 	        	data	: params,
	 	        	dataType: 'json',
	 	        	async	: false,
	 	        	cache	: false
	 	        }).done(function(result) {
					field.options = result;
	 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	 	    		field.options = [];

	 	    		try {
	 		    		var exception = $.parseJSON(jqXHR.responseText);
	 		    		alert(exception.message);
	 	    		} catch(err) {
	 		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	 	    		}
	 	    	});
			}

			return field.options;
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
					selector.append($('<option>', { value : special[i].value, selected : isValueSelected(special[i].value, selected) }).text(special[i].label));
				}
			}

			if (options != null && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					var value = (options[i].hasOwnProperty('value') ? options[i].value : options[i].id);
					selector.append($('<option>', { value : value, title : options[i].title || options[i].description, selected : isValueSelected(stringcmp ? value.toString() : value, selected) }).text(options[i].label || options[i].name));
				}
			}

			return selector;
		}

		function getFieldEditor(context, field, special, value) {
			var editor = null;

			if (field.id == 88) { // Comments/Attachments
				editor = $('<textarea>', { name : 'value', rows : 4, cols : 80, disabled : !settings.editable, placeholder : settings.commentText });
				if (value != null && value.length > 0) {
					editor.val(value);
				}
			} else if (field.type == 0 || field.type == 10) { // (wiki)text
				var width  = parseInt(field.width);
				if (!(width && !isNaN(width))) {
					width = (field.type == 10 ? 60 : 20);
				}

				var height = parseInt(field.height);
				if (!(height && !isNaN(height))) {
					height = (field.type == 10 ? 4 : 1);
				}

				if (height > 1) {
					editor = $('<textarea>', { name : 'value', rows : height, cols : width, disabled : !settings.editable });
					if (value != null && value.length > 0) {
						editor.val(value);
					}
				} else {
					editor = $('<input>', { type : 'text', name : 'value', size : width, value : value, disabled : !settings.editable}).attr("size", width);
				}
			} else if (field.type == 1 || field.type == 2) { //integer/float
				var width = parseInt(field.width);
				if (!(width && !isNaN(width))) {
					width = (field.type == 1 ? 10 : 15);
				}
				editor = $('<input>', { type : 'text', name : 'value', size : width,  maxlength : (field.maxValue ? field.maxValue.length : 20), value : value, disabled : !settings.editable});

				editor.attr("size", width);

				if (!isNaN(parseFloat(field.minValue))) {
					editor.attr('min', field.minValue);
				}
				if (!isNaN(parseFloat(field.maxValue))) {
					editor.attr('max', field.maxValue);
				}
			} else if (field.type == 11) { // duration
				editor = $('<input>', { type : 'text', name : 'value', size : 20, maxlength : 20, value : value}).attr("size", 20);

			} else if (field.type == 3) { // date
				editor = getOptionsSelector(special, settings.dateOptions, value, false, !settings.editable);

			} else if (field.type == 4) { // boolean
				editor = getOptionsSelector(special, [{ value: 'true',  label: settings.trueValueText  },
				                                      { value: 'false', label: settings.falseValueText }], value, field.multiple, !settings.editable);

			} else if (field.type == 8) { // language
				editor = getOptionsSelector(special, settings.languageOptions, value, field.multiple, !settings.editable);

			} else if (field.type == 9) { // country
				editor = getOptionsSelector(special, settings.countryOptions, value, field.multiple, !settings.editable);

			} else if (field.type == 5) { // member/principal
				// Special handling !

			} else if (field.type == 13) { // color
				editor = $(
					'<div class="colorPickerContainer">' +
					'<div id=' + field.id + '_color_field_indicator class="colorField" style="display: none;"><\/div>' +
					'<input id=' + field.id + '_color_field type="text" class="colorInput" name="value" readonly="readonly"><\/input>' +
					'<a id=' + field.id + '-colorPicker-icon href="#" title="' + i18n.message('colorpicker.title') +  '" class="colorPicker yui-skin-sam"'+
						'onClick="colorPicker.showPalette(this, \'' + (field.id + '_color_field') + '\', \'' + (field.id + '_color_field_indicator') + '\', true); return false;">' +
					'<img src="' + (contextPath + '/images/color_swatch.png').replace(/\//, '\/') + '"><\/img>' +
					'<\/a>' +
					'<\/div>'
				);

			} else if (field.type == 6 || // custom choice
					   field.type == 7) { // reference
				var refType = parseInt(field.refType);
				if (isNaN(refType) || refType == 0) {  // fix choice
					editor = getOptionsSelector(special, getFieldOptions(context, field), value, field.multiple, !settings.editable);
				} else if (refType == 2 && $.isPlainObject(field.project)) {
					editor = getOptionsSelector(special, getProjects(context, field, field.project), value, field.multiple, !settings.editable);
				} else if (refType == 3 && $.isPlainObject(field.tracker)) {
					editor = getOptionsSelector(special, getTrackers(context, field, field.tracker), value, field.multiple, !settings.editable);
				}
			}

			return editor;
		}

		function renderReferences(container, value) {
			if ($.isArray(value)) {
				var first = true;
				for (var i = 0; i < value.length; ++i) {
					if (first) {
						first = false;
					} else {
						container.append(', ');
					}
					container.append($('<label>', { "class" : 'fieldUpdateValue', title : value[i].title }).text(value[i].label));
				}
				if (first) {
					container.append('--');
				}
			} else if ($.isPlainObject(value)) {
				container.append($('<label>', { "class" : 'fieldUpdateValue', title : value.title }).text(value.label || value.value));
			} else {
				container.append('--');
			}
		}

		function renderOptions(container, special, options, selected) {
			var stringcmp = false;
			if (typeof selected === 'string') {
				selected = selected.split(',');
				stringcmp = true;
			}

			var first = true;

			if (special != null && special.length > 0) {
				for (var i = 0; i < special.length; ++i) {
					if (isValueSelected(special[i].value, selected)) {
						if (first) {
							first = false;
						} else {
							container.append(', ');
						}
						container.append($('<label>', { "class" : 'fieldUpdateValue', title : special[i].title }).text(special[i].label));
					}
				}
			}

			if (options != null && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {

					var value = stringcmp ? "" : null;
					if (options[i] != null && options[i] != undefined) {
						if (options[i].hasOwnProperty("value")) {
							value = options[i].value;
						} else {
							if (options[i].hasOwnProperty("id")) {
								value = options[i].id;
							}
						}
					}

					if (isValueSelected(stringcmp ? value.toString() : value, selected)) {
						if (first) {
							first = false;
						} else {
							container.append(', ');
						}
						container.append($('<label>', { "class" : 'fieldUpdateValue', title : options[i].title || options[i].description }).text(options[i].label || options[i].name));
					}
				}
			}

			if (first) {
				container.append('--');
			}
		}

		function renderFieldValue(container, context, field, special, value) {
			if (field.id == 88) { // Comments/Attachments
				container.append($('<span>', { "class" : 'fieldUpdateValue' }).text(value || '--'));

			} else if (field.type == 3) { //date
				renderOptions(container, special, settings.dateOptions, value);

			} else if (field.type == 4) { // boolean
				renderOptions(container, special, [{ value: 'true',  label: settings.trueValueText  },
				                                   { value: 'false', label: settings.falseValueText }], value);

			} else if (field.type == 8) { // language
				renderOptions(container, special, settings.languageOptions, value);

			} else if (field.type == 9) { // country
				renderOptions(container, special, settings.countryOptions, value);

			} else if (field.type == 5) { // member/principal
				renderReferences(container, value);

			} else if (field.type == 13) { // color
				container.append($('<span class="color-preview" style="background-color:' + value + ';"/><span class="colorName">' + value + '<\/span>'));
			} else if (field.type == 6 || field.type == 7) { // fix choice or reference
				var refType = parseInt(field.refType);
				if (isNaN(refType) || refType == 0) {
					renderOptions(container, special, getFieldOptions(context, field), value);
				} else if (refType == 2 && $.isPlainObject(field.project)) {
					renderOptions(container, special, getProjects(context, field, field.project), value);
				} else if (refType == 3 && $.isPlainObject(field.tracker)) {
					renderOptions(container, special, getTrackers(context, field, field.tracker), value);
				} else {
					renderReferences(container, value);
				}
			} else {
				container.append($('<span>', { "class" : 'fieldUpdateValue' }).text(value || '--'));
			}
		}

		function renderFieldUpdate(container, context, field, update) {
			var op = getOp(context, field, update);
			if (op.id != 1) {
				container.append($('<label>', { title : op.description, style : 'margin-right: 4px;' }).text(op.id > 0 ? op.name + ':' : op.name));
			}

			if (op.id > 0) {
				// Append has an additional separator in front of the value to append
				if (op.id == 3 && update.separator && update.separator.length > 0) {
					var separator = $('<label>', { "class" : 'separator', title : settings.separatorTooltip, style : 'margin-right: 4px;' }).text(update.separator);
					container.append(separator);
				}

				var type = getValueType(update);
				if (type && type.id) {
					switch(type.id) {
					case 1: // Value as specified/chosen
						renderFieldValue(container, context, field, [{value: 'NULL',  label: '--'}], update.value);
						break;

					case 2: // Copy of of selected source field
						var copyFrom = getCopyFrom(context, update);
						if (copyFrom) {
							container.append($('<label>', { title : type.option.title, style : 'margin-right: 4px' }).text(type.name));
							container.append($('<label>', { "class" : 'fieldValueOf' + (settings.editable ? 'highlight-on-hover' : ''), title : copyFrom.title }).text(copyFrom.name));
						}
						break;

					case 3: // Result of computation/expression
						container.append($('<pre>', { "class" : 'fieldUpdateExpression', title : type.option.title }).text(update.computeAs || '--'));
						break;
					}
				}

				// Prepend has an additional separator after the value to append
				if (op.id == 2 && update.separator && update.separator.length > 0) {
					var separator = $('<label>', { "class" : 'separator', title : settings.separatorTooltip, style : 'margin-left: 3px;' }).text(update.separator);
					container.append(separator);
				}

				if (settings.isMassEdit && field.id == 7 && update.value && settings.items) { //Status
					var payload, trackerItemId;

					payload = {
						"7": {
							"values": [update]
						}
					}

					trackerItemId = typeof settings.items[0] === "object" ? settings.items[0].id : settings.items[0];

					$.ajax(getSetting("baselineWorkflowActionCheckingUrl") + "?tracker_id=" + context.tracker.id + "&tracker_item_id=" + trackerItemId, {
						type: "POST",
						data: JSON.stringify(payload),
						contentType: "application/json",
						dataType: "json"
					}).done(function(result) {
						if (result === true) {
							$("body").trigger("baseline:mandatory");
						} else {
							$("body").trigger("baseline:optional");
						}
					}).fail(function(jqXHR, textStatus, errorThrown) {
						var exception, valid;
						valid = false;

						try {
							exception = $.parseJSON(jqXHR.responseText);
							$("body").trigger("baseline:optional");
							alert(exception.message);
						} catch(err) {
							alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
						}
					});

				}

			}
		}

		function renderFieldUpdates(container, context, field, values) {
			for (var i = 0; i < values.length; ++i) {
				if (i > 0) {
					container.append($('<br>'));
				}
				renderFieldUpdate(container, context, field, values[i]);

				/*
				 * multipleFieldList is true only if this field is the part of a group.
				 */
				var fields = context.fields;
				var multipleFieldList = false;
				if ($.isArray(fields) && fields.length > 0) {
					multipleFieldList = true;
				}

				if (settings.editable && multipleFieldList && !(field.required && context.updateMandatory)) {
					container.append($('<span>', { title: i18n.message("project.export.fields.remove.label"), "class" : "removeButton", style: 'margin-left: 10px;'}));
				}

				var editLink = $('<a>', {'class': 'edit-link', 'title': i18n.message('button.edit')}).html(i18n.message('button.edit'));
				if (settings.editable) {
					container.append(editLink);
				}
				container.on('click', '.removeButton', function () {
					var update   = $(this).closest('tr.fieldUpdate');
					var updates  = update.closest('table.fieldUpdates');
					var field    = update.data('field');
					var selector = $('select.fieldUpdateSelector', updates);
					var option   = $('option[value="' + field.id + '"]', selector);

					selector.closest('tr.moreFieldUpdates').show();
					option.show();
					update.remove();

	  				if ($('tr.fieldUpdate', updates).length == 0) {
	  					$('option:first', selector).text(getSetting('updatesNone'));
					}
				}).on('click', '.edit-link', function () {
					$(this).closest('.fieldUpdate').click();
				});

				if ((field.required && context.updateMandatory)) {
					container.click();
				}
			}
		}

		function setFieldUpdate() {
			var self = $(this);
			var span = $('<span>');

			renderFieldUpdates(span, self.data('context'), self.data('field'), self.data('update').values);

			return span.html();
		}

		function submitFieldUpdate(context, field, item) {
        	var valid  = true;
			var update = $.extend({}, item.data('update'), {
				op : $('select.updateOpSelector', item).find('option:selected').data('op')
			});

			delete update.value;
			delete update.copyFrom;
			delete update.computeAs;
			delete update.separator;

			if (update.op.id) {
				// Prepend and Append ops have an additional separator
				if (update.op.id == 2 || update.op.id == 3) {
					update.separator = $('input[name="separator"]', item).val();
				}

				var type = $('select.valueTypeSelector', item).find('option:selected').data('type');
				if (type && type.id) {
					switch(type.id) {
					case 1: // Value as specified/chosen
						var valueEditor = $('span.valueEditor', item);
						if (valueEditor.data('referenceField')) {
							update.value = valueEditor.getReferences();
						} else {
							var editor = $('[name="value"]', valueEditor);
							if (editor.length > 0) {
								if (editor.is('select[multiple="multiple"]')) {
									var values = [];
									var selected = editor.multiselect('getChecked');
									if (selected) {
										for (var i = 0; i < selected.length; ++i) {
											values.push(selected[i].value);
										}
									}
									update.value = values.join(',');
								} else {
									update.value = editor.val();
								}
							} else {
								update.value = null;
							}
						}
						break;

					case 2: // Copy of of selected source field
						update.copyFrom = parseInt($('select[name="value"]', item).val());
						break;

					case 3: // Result of computation/expression
			        	var data = $.extend( {}, field, {
        					label   : field.value,
				  			formula :  $('textarea.fieldUpdateExpression', item).val()
			        	});

						$.ajax(getSetting('exprValidationUrl'), {
							type		: 'POST',
							async		: false,
							data 		: JSON.stringify(data),
							contentType : 'application/json',
							dataType 	: 'json'
						}).done(function(result) {
				        	update.computeAs = data.formula;
						}).fail(function(jqXHR, textStatus, errorThrown) {
							valid = false;

				    		try {
					    		var exception = $.parseJSON(jqXHR.responseText);
					    		alert(exception.message);
				    		} catch(err) {
					    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
				    		}
				        });
						break;
					}
				}
			}

			if (valid && field.required) {
				if (isEmpty(update) && !context.allowClearAll) {
					valid = false;
					alert(getSetting('mandatoryValue').replace('XX', field.label || field.name));
				}
			}

        	if (valid) {
            	item.data('update', update);
        	}

        	return valid;
		}

		function submitFieldUpdates(settings, self) {
        	var form   = $(this);
			var item   = $(self);
			var context = item.data('context');
			var field  = item.data('field');
			var values = [];
			var valid  = true;

			$('table.fieldUpdateValues tr.fieldUpdateValue', form).each(function() {
				var update = $(this);

				if (submitFieldUpdate(context, field, update)) {
					var value = update.data('update');
					if ($.isPlainObject(value)) {
						values.push(value);
					}
				} else {
					valid = false;
				}
			});

        	if (valid) {
        		item.data('update', $.extend({}, item.data('update'), {
        			values : values
        		}));
        	}

        	return valid;
		}

		function addValueEditor(container, context, field, value) {
			var valueEditor = getFieldEditor(context, field, (field.required && !context.allowClearAll) || field.multiple ? [] : [{value: '',  label: '--'}], value);
			if (valueEditor != null) {
				container.append(valueEditor);
				valueEditor.makeMultiSelect(field, settings);
			} else {
				var status = context.status;
				if ($.isFunction(status)) {
					status = status();
				}

				var refField = $.extend({}, field, {
					trackerId	 : context.tracker.id,
					htmlName 	 : 'value',
//					showUnset	 : false,
					singleSelect : !field.multiple
				});

				if (status && status.id != null) {
					refField.statusId = status.id;
				}

				if (field.type == 5) {
					if (refField.allowUserSelection || (refField.memberType & 2) == 2) {
						refField.showCurrentUser = true;
					}

					container.membersField(value, refField);
				} else {
					container.referenceField(value, refField);
				}

				container.referenceFieldAutoComplete();
				container.data('referenceField', true);
			}

			return valueEditor;
		}

		function addValueType(container, context, field, update, first) {
			var selected = getValueType(update);
			if (selected && selected.id) {
				var selector = $('<select>', { name : 'valueType', "class" : 'valueTypeSelector', disabled : !settings.editable });

				for (var i = 1; i < settings.valueTypes.length; ++i) {
					var type = settings.valueTypes[i];
					if (type.id == 2) {
						var assignableFields = getAssignableFields(context, field);
						if ($.isArray(assignableFields) && assignableFields.length > 0) {
							selector.data('assignableFields', assignableFields);
						} else {
							continue;
						}
					}

					selector.append($('<option>', { value : type.id, title : (first && context.updateMandatory && type.option ? type.option : type).title, selected : type.id == selected.id }).text((first && context.updateMandatory && type.option ? type.option : type).name).data('type', type));

					if (field.rtexprvalue === false) {
						selector.hide();
						break;
					}
				}

				container.append(selector);

				var valueEditor = $('<span>', { "class" : 'valueEditor' });
				container.append(valueEditor);

				selector.change(function() {
					var type = settings.valueTypes[parseInt(this.value)];

					valueEditor.empty();

					switch(type.id) {
					case 1: // Choose/Enter value
						addValueEditor(valueEditor, context, field, update.value == 'NULL' ? null : update.value || field.initialValue || '');
						break;

					case 2: // Selected source field to copy value from
						var fields = selector.data('assignableFields');
						var source = getCopyFrom(context, update);
						if (!source) {
							source = field;

							// Try to map custom fields by name
							if (field.id >= 100) {
								for (var i = 0; i < fields.length; ++i) {
									if ((field.label || field.name).localeCompare(fields[i].label || fields[i].name) == 0) {
										source = fields[i];
										break;
									}
								}
							}
						}

						valueEditor.append(getOptionsSelector(null, fields, source ? source.id : null, false, !settings.editable));
						break;

					case 3: // Enter formula/expression to compute the value
						valueEditor.append($('<textarea>', { name : 'computeAs', "class" : 'fieldUpdateExpression', rows : 2, cols : 80, placeholder : (context.updateMandatory && type.option ? type.option : type).title }).val(update.computeAs));
						break;
					}
				});

				selector.change();
			}
		}

		function addUpdateOp(table, context, field, update, first) {
			var row = $('<tr>', { "class" : first ? 'fieldUpdateValue first' : 'fieldUpdateValue additional' }).data('update', update);
			table.append(row);

			var container = $('<td>', { "class": 'fieldUpdateValue'});
			row.append(container);

//			var removeButton = $("<span>", {"class": "removeButton"});
//			removeButton.click(function (event) {
//				event.stopPropagation();
//				$(this).closest(".additional").remove();
//			});
//			container.append(removeButton);

			var selected = getOp(context, field, update);
			var selector = $('<select>', { name : 'op', "class" : 'updateOpSelector', disabled : !settings.editable });

			for (var i = 0; i < settings.fieldUpdateOps.length; ++i) {
				var op = settings.fieldUpdateOps[i];
				if (isApplicable(context, field, first, op)) {
					selector.append($('<option>', { value : op.id, title : op.description, selected : op.id == selected.id }).text(op.name).data('op', op));
				}
			}

			if ($('option', selector).length == 1) {
				selector.hide();
			}

			var valueTypeAndEditor = $('<span>', { "class" : 'valueTypeAndEditor' });
			valueTypeAndEditor.append(selector);
			container.append(valueTypeAndEditor);

			var moreValues = null;

			if (first && settings.editable && field.multiple) {
				moreValues = $('<button>', { "class" : 'moreFieldUpdateValues', title : settings.moreValuesTitle }).text(settings.updatesMore).click(function() {
					addUpdateOp(table, context, field, {
						op    	 : 6,
						value 	 : null,
						required : true
					}, false);

					return false;
				});

				moreValues.insertAfter(table);
			}

			selector.change(function() {
				var op = this.value;
				if (op == '0') { // Clear
					valueTypeAndEditor.children(":not(.updateOpSelector)").remove();
					$('tr.fieldUpdateValue.additional', table).remove();
					if (moreValues) {
						moreValues.hide();
					}
				} else {
					var separator = $('input[name="separator"]', valueTypeAndEditor);
					if (separator.length == 0) {
						if (op == '2' || op == '3') {  // Prepend or Append
							separator = $('<input>', {
								type 		: 'text',
								name 		: 'separator',
								size 		: 10,
								value		: update.separator,
								disabled 	: !settings.editable,
								placeholder : settings.separatorLabel,
								title 		: settings.separatorTooltip
							});

							valueTypeAndEditor.find(".updateOpSelector").after(separator);
						}
					} else if (op != '2' && op != '3') {  // Other than Prepend or Append
						separator.remove();
					}

					var valueType = $('select.valueTypeSelector', valueTypeAndEditor);
					if (valueType.length == 0) {
						var selected = getValueType(update);
						if (!(selected && selected.id)) {
							update.value = null;
						}

						addValueType(valueTypeAndEditor, context, field, update, first);
					}

					if (moreValues) {
						moreValues.show();
					}
				}
			});

			selector.change();
		}

		function setup() {
		    $.editable.addInputType('fieldUpdate', {
		    	element : function(settings, self) {
		    		var form = $(this);
					var cell = $(self);
					var ctxt = cell.data('context');

					if (ctxt) {
						var fld  = cell.data('field');
						var vals = cell.data('update').values;
						var table  = $('<table>', { "class" : 'fieldUpdateValues' });

						form.append(table);

						for (var i = 0; i < vals.length; ++i) {
			    			addUpdateOp(table, ctxt, fld, vals[i], i == 0);
						}

						table.sortable({
							items		: 'tr.fieldUpdateValue.additional',
							containment	: table,
							axis 		: "y",
							cursor		: "move",
							delay		: 150,
							distance	: 5
						});
					} else {
						if (settings.field.id === 7) {
							$("body").trigger("baseline:optional");
						}
					}

	    			return this;
		    	},

		    	content : function(string, settings, self) {
		    		// Nothing
		     	},

		        plugin : function(settings, self) {
		          	$(this).referenceFieldAutoComplete();
		        },

		        submit : submitFieldUpdates
		    });
		}

		function init(container, context, field, update) {
			if (!$.isPlainObject(update)) {
				update = {
					values : null
				};
			}

			if (!$.isArray(update.values)) {
				if (isEmpty(update)) {
					update.values = [{
						value 	 : null,
						required : true,
						op : update.op
					}];
				} else {
					update = {
						values : [update]
					};
				}
			}

			container.data('context', context).data('field', field).data('update', update);

			renderFieldUpdates(container, context, field, update.values);

			if (settings.editable) {
				container.editable(setFieldUpdate, {
			        type     	: 'fieldUpdate',
			        placeholder	: '--',
			        event		: 'click',
			        onblur		: 'cancel',
			        submit		: settings.submitText,
			        cancel		: settings.cancelText,
			        tooltip		: settings.updatesDblClick,
			        field		: field
				});
				openEditorOnInit(container);
			}
		}

		function openEditorOnInit(container) {
			setTimeout(function () {container.click();}, 200);
		}

		if ($.fn.trackerFieldUpdate._setup) {
			$.fn.trackerFieldUpdate._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), context, field, update);
		});
	};

	$.fn.trackerFieldUpdate._setup = true;


	// A plugin to get a tracker field update from an editor
	$.fn.getTrackerFieldUpdate = function() {
		var result = $(this).data('update');

		if ($.isPlainObject(result) && $.isArray(result.values)) {
			for (var i = 0; i < result.values.length; ++i) {
				var update = result.values[i];

				if ($.isPlainObject(update) && (update.hasOwnProperty('op') ||
												update.hasOwnProperty('value') ||
												update.hasOwnProperty('copyFrom') ||
												update.hasOwnProperty('computeAs'))) {
					if ($.isPlainObject(update.op)) {
						update.op = update.op.id;
					}

					if ($.isPlainObject(update.copyFrom)) {
						update.copyFrom = update.copyFrom.id;
					}
				}
			}
		}

		return result;
	};


	/**
	 * Tracker field updates plugin.
	 * - context must be an object, with at least
	 *    + tracker : an object with at least id, name and project (id and name)
	 *    + status  : either an object with at least id and name or a function, that returns a status object
	 *    + fields  : either an array of the (editable) fields to update (in the specified status) or a function, that returns such a field array
	 *    * source  : optional (an underlying context where field values can be copied from) or null
	 */
	$.fn.trackerFieldUpdates = function(context, fieldUpdates, options) {
		var settings = $.extend( {}, $.fn.trackerFieldUpdates.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function getRoles(context, field) {
			if (!$.isArray(field.options)) {
				field.options = [];

				$.ajax(settings.projectRolesUrl, {
					type		: 'GET',
					async		: false,
					data 		: { proj_id : context.tracker.project.id },
					dataType 	: 'json'
				}).done(function(roles) {
					field.options = roles;
				}).fail(function(jqXHR, textStatus, errorThrown) {
		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        });
			}

			return field.options;
		}

		function addFieldUpdate(context, field, index, update) {
			var row   = $('<tr>', { "class" : 'fieldUpdate'}).data('field', field).data('index', index);
			var label = $('<td>', { "class" : 'labelCell ' + (field.required ? 'mandatory' : 'optional'), title : field.title }).text(field.name + ':');
			var value = $('<td>', { "class" : 'fieldUpdate dataCell' + (settings.editable ? ' highlight-on-hover-nested' : '')  });

			row.append(label);
			row.append(value);

			value.trackerFieldUpdate(context, field, update, options, settings);

			return row;
		}

		function setup() {

		}

		function init(container, context, fieldUpdates) {
			var updatesList = $('<table>', { "class" : 'fieldUpdates' }).data('context', context);
			container.append(updatesList);

			var fields = context.fields;
			if ($.isFunction(fields)) {
				fields = fields();
			}

			if ($.isArray(fields) && fields.length > 0) {
				if (!$.isPlainObject(fieldUpdates)) {
					fieldUpdates = {};
				}

				if (!$.isEmptyObject(fieldUpdates) || context.updateMandatory) {
					for (var i = 0; i < fields.length; ++i) {
						var field = fields[i];

						if (field.id == 83) { // Staff
							var roles = getRoles(context, field);
							for (var j = 0; j < roles.length; ++j) {
								var role    = roles[j];
								var staffId = (900000 + role.id);

								var update = fieldUpdates[staffId.toString()];
								if (update) {
									var updateItem = addFieldUpdate(context, $.extend({}, field, {
										id		 			: staffId,
										name 	 			: field.name + " - " + role.name,
										multiple 			: true,
										memberType 			: 6,
										projectList 		: context.tracker.project.id,
										requiredRoles 		: role.id,
										searchOnTracker		: false

									}), (i * 1000) + j, update);

									updateItem.data('role', role);
									updatesList.append(updateItem);
								}
							}
						} else {
							var update = fieldUpdates[field.id.toString()];
							if (update || (field.required && settings.editable && context.updateMandatory)) {
								var updateItem = addFieldUpdate(context, field, i * 1000, update);
								updatesList.append(updateItem);

								if (!update) {
									$('td.fieldUpdate', updateItem).dblclick();
								}
							}
						}
					}
				}

				if (settings.editable) {
					var moreFieldUpdates = $('<tr>', { "class" : 'moreFieldUpdates' });
					updatesList.append(moreFieldUpdates);

					var selectorCell = $('<td>', { colspan : 2 });
					moreFieldUpdates.append(selectorCell);

					var fieldUpdateSelector = $('<select>', { "class" : 'fieldUpdateSelector' });
					selectorCell.append(fieldUpdateSelector);

					fieldUpdateSelector.append($('<option>', { value : '-1', style : 'color: gray; font-style: italic;' }).text($('tr.fieldUpdate', updatesList).length > 0 ? settings.updatesMore : settings.updatesNone));

					var hiddenOptions = 0;
					for (var i = 0; i < fields.length; ++i) {
						var field = fields[i];

						if (field.id == 83) { // Staff
							var group = $('<optgroup>', { label : field.name, title : field.title || field.tooltip }).data('field', field);
							var roles = getRoles(context, field);

							for (var j = 0; j < roles.length; ++j) {
								var role    = roles[j];
								var staffId = (900000 + role.id);

								var option = $('<option>', { value : staffId }).text(role.name).data('field', $.extend({}, field, {
									id       			: staffId,
									name     			: field.name + " - " + role.name,
									multiple 			: true,
									memberType 			: 6,
									projectList 		: context.tracker.project.id,
									requiredRoles 		: role.id,
									searchOnTracker		: false

								})).data('role', role).data('index', (i * 1000) + j);

								var update = fieldUpdates[staffId.toString()];
								if (update) {
									option.hide();
									hiddenOptions++;
								}

								group.append(option);
							}

							fieldUpdateSelector.append(group);

						} else {
							var option = $('<option>', { value : field.id }).text(field.name).data('field', field).data('index', i * 1000);

							var update = fieldUpdates[field.id.toString()];
							if (update || (context.updateMandatory && field.required)) {
								option.hide();
								hiddenOptions++;
							}

							fieldUpdateSelector.append(option);
						}
					}

					// Hide selector if all fields were chosen
					if (hiddenOptions >= fields.length) {
						moreFieldUpdates.hide();
					}

					fieldUpdateSelector.change(function() {
						var value = this.value;
						if (value != '-1') {
							var option = $('option:selected', fieldUpdateSelector);
							var field  = option.data('field');
							var role   = option.data('role' );
							var index  = option.data('index');
							option.hide();

							var updateItem = addFieldUpdate(context, field, index, null);

							if (role) {
								updateItem.data('role', role);
							}

							$('tr.fieldUpdate', updatesList).each(function() {
	   	  						var current = $(this);
	   	  						if (updateItem != null && index <= current.data('index')) {
	   	  							updateItem.insertBefore(current);
	   	  							$('td.fieldUpdate', updateItem).dblclick();
	   	  							updateItem = null;
	   	  							return false;
	   	  						}
							});

							if (updateItem != null) {
								updateItem.insertBefore(moreFieldUpdates);
   	  							$('td.dataCell', updateItem).dblclick();
							}

							this.options[0].text = getSetting('updatesMore');
							this.options[0].selected = true;

							// Hide selector if all fields were chosen
// On Crome this is always true
//							if ($('option:visible', fieldUpdateSelector).length <= 1) {
//								moreFieldUpdates.hide();
//							}
						}
					});
				}
			}
		}

		if ($.fn.trackerFieldUpdates._setup) {
			$.fn.trackerFieldUpdates._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), context, fieldUpdates);
		});
	};


	$.fn.trackerFieldUpdates.defaults = {
		editable			: false,
		exprValidationUrl	: contextPath + '/trackers/ajax/validateFieldConfiguration.spr',
		projectsUrl			: contextPath + '/proj/ajax/projectsWithCategory.spr',
		fieldOptionsUrl		: null,
		projectRolesUrl		: contextPath + '/proj/ajax/definedRoles.spr',
		projectTrackersUrl  : null,
		referringTrackersUrl: null,
		dateOptions			: [],
		countryOptions		: [],
		languageOptions		: [],
		valueTypes     		: [{ id : 0, name : 'None'  },
		                       { id : 1, name : 'Value' },
        					   { id : 2, name : 'Value of',  title : 'The value of the selected source field' },
        					   { id : 3, name : 'Result of', title : 'The result of the specified computation/expression'}
        					  ],
		updatesLabel		: 'Field Updates',
		updatesTooltip		: 'Field values to update upon transition',
		updatesNone			: 'None',
		updatesMore			: 'More...',
		updatesEdit			: 'Edit',
		updatesRemove		: 'Remove',
		updatesDblClick		: 'Double click to edit the fields to update',
		unsetLabel			: 'Clear field value',
		checkAllText		: 'Check all',
		filterText			: 'Filter',
	    trueValueText		: 'true',
		falseValueText		: 'false',
		submitText    		: 'OK',
		cancelText   		: 'Cancel',
		commentText			: 'Comment',
		separatorLabel		: 'Separator',
		separatorTooltip	: 'The optional separator between the existing text and the additional text to prepend/append',
		moreValuesTitle		: 'Add more values to add, remove or retain',
		mandatoryValue		: 'Mandatory XX value is missing'
	};

	$.fn.trackerFieldUpdates._setup = true;


	// A plugin to get the tracker field updates from an editor
	$.fn.getTrackerFieldUpdates = function(mandatoryCheck) {
		var result = {};

		function hasEmptyValue(update) {
			if ($.isPlainObject(update) && $.isArray(update.values) && update.values.length > 0) {
				for (var i = 0; i < update.values.length; ++i) {
					if (isEmpty(update.values[i])) {
						return true;
					}
				}
				return false;
			}

			return true;
		}

		$('table.fieldUpdates tr.fieldUpdate', this).each(function() {
			var row   = $(this);
			var field = row.data('field');
			var role  = row.data('role');
			var value = $('td.fieldUpdate', row).getTrackerFieldUpdate();

			if (field && value) {
				if (mandatoryCheck && field.required && hasEmptyValue(value)) {
					throw mandatoryCheck.replace('XX', field.label || field.name);
				}

				if (role) {
					value.role = role;
				} else {
					delete value.role;
				}

				result[field.id.toString()] = value;
			}
		});

		return result;
	};


})( jQuery );

