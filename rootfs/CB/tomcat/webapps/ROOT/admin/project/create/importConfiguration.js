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
    // Helper to find circular dependencies during JSON.stringify, e,g. JSON.stringify(object, getCircularReplacer(), 4)
	function getCircularReplacer() {
		const seen = new WeakSet;

		return function(key, value) {
		    if (typeof value === "object" && value !== null) {
		    	if (seen.has(value)) {
		    		return '-CIRCLE-';
		    	}
		    	seen.add(value);
		    }
		    return value;
		};
	}

	function getOption(option) {
		var result = null;

		if ($.isPlainObject(option) && (option.id || option.name)) {
			result = $.extend({}, option);

			delete result.label;
			delete result.count;
			delete result.attrib;
			delete result.target;
		}

		return result;
	}

	function getField(field) {
		var result = null;

		if ($.isPlainObject(field) && (field.id || field.name)) {
			result = $.extend({}, field);

			delete result.rest;
			delete result.label;
			delete result.columns;
			delete result.options;
			delete result.mapable;
			delete result.merged;
			delete result.parent;
			delete result.target;
		}

		return result;
	}

	function getFields(fields) {
		var result = [];

		if ($.isArray(fields) && fields.length > 0) {
			for (var i = 0; i < fields.length; ++i) {
				var field = fields[i];
				if ($.isPlainObject(field)) {
					var attrib = $.extend({}, field, {
						target : getField(field.target)
					});

					delete attrib.id;
					delete attrib.count;
					delete attrib.parent;
					delete attrib.values;

					var options = field.options;
					if ($.isArray(options) && options.length > 0) {
						attrib.options = [];

						for (var j = 0; j < options.length; ++j) {
							var option = options[j];
							if ($.isPlainObject(option)) {
								var enumVal = $.extend({}, option, {
									target : getOption(option.target)
								});

								delete enumVal.id;
								delete enumVal.count;
								delete enumVal.attrib;

								attrib.options.push(enumVal);
							}
						}
					}

					result.push(attrib);
				}
			}
		}

		return result;
	}

	function getTracker(tracker) {
		var result = null;
		if ($.isPlainObject(tracker) && tracker.name) {
			result = $.extend({}, tracker);

			delete result.label;
			delete result.fields;
		}
		return result;
	}

	function getQualifiers(qualifiers) {
		var result = [];

		if ($.isArray(qualifiers) && qualifiers.length > 0) {
			for (var i = 0; i < qualifiers.length; ++i) {
				var qualifier = qualifiers[i];

				if ($.isPlainObject(qualifier)) {
					var field = getField(qualifier.field);
					if (field) {
						result.push({
							field : field,
							value : getOption(qualifier.value)
						});
					}
				}
			}
		}

		return result;
	}

	function getSpecType(type) {
		var result = null;

		if ($.isPlainObject(type)) {
			result = $.extend({}, type, {
				fields : getFields(type.fields)
			});

			if (result.fields.length == 0) {
				delete result.fields;
			}

			delete result.count;
			delete result.parent;
		}

		return result;
	}

	function getSpecTypes(types) {
		var result = [];

		if ($.isArray(types) && types.length > 0) {
			for (var i = 0; i < types.length; ++i) {
				var type = getSpecType(types[i]);
				if (type) {
					result.push(type);
				}
			}
		}

		return result;
	}

	function getSpecObjType(items) {
		var result = getSpecType(items);
		if (result) {
			var tracker = getTracker(items.target);
			if (tracker) {
				result.target = tracker;
			} else {
				delete result.target;
			}

			var table = getField(items.table);
			if (table) {
				result.table = table;
			} else {
				delete result.table;
			}

			var qualifiers = getQualifiers(items.qualifiers);
			if (qualifiers.length > 0) {
				result.qualifiers = qualifiers;
			} else {
				delete result.qualifiers;
			}
		}

		return result;
	}

	function getSpecObjTypes(types) {
		var result = [];

		if ($.isArray(types) && types.length > 0) {
			for (var i = 0; i < types.length; ++i) {
				var type = getSpecObjType(types[i]);
				if (type) {
					result.push(type);
				}
			}
		}

		return result;
	}

	function getSpecification(specification) {
		var result = null;

		if ($.isPlainObject(specification)) {
			result = $.extend({}, specification, {
				target : getTracker(specification.target),
				type   : getSpecType(specification.type),
				items  : getSpecObjTypes(specification.items)
			});

			delete result.count;
		}

		return result;
	}

	function getSpecifications(specs) {
		var result = [];

		if ($.isArray(specs) && specs.length > 0) {
			for (var i = 0; i < specs.length; ++i) {
				var spec = getSpecification(specs[i]);
				if (spec) {
					result.push(spec);
				}
			}
		}

		return result;
	}

	function getRefFields(refFields) {
		var result = {};

		if ($.isPlainObject(refFields)) {
			for (var typeId in refFields) {
				var field = getField(refFields[typeId]);
				if (field) {
					result[typeId] = field;
				}
			}
		}

		return result;
	}

	function getRelation(relation) {
		var result = getSpecType(relation);
		if (result) {
			var refFlds = getRefFields(relation.referenceFields);
			if ($.isEmptyObject(refFlds)) {
				delete result.referenceFields;
			} else {
				result.referenceFields = refFlds;
			}
		}

		return result;
	}

	function getRelations(relations) {
		var result = [];

		if ($.isArray(relations) && relations.length > 0) {
			for (var i = 0; i < relations.length; ++i) {
				var relation = getRelation(relations[i]);
				if (relation) {
					result.push(relation);
				}
			}
		}

		return result;
	}


	$.fn.trackerConfigForm = function(items, trackers, settings) {

		function getTypeSelector(items, trackers) {
			var types    = settings.trackerTypes;
			var selector = $('<select>', { name : 'type' });

			for (var i = 0; i < types.length; ++i) {
				var type = types[i].type;
				selector.append($('<option>', { "class" : 'type', value : type.id, title : type.description, selected : items.type && items.type.id == type.id}).text(type.name).data("tracker", types[i]));
			}

			return selector;
		}

		function init(form, items, trackers) {
			var table = $('<table>', { "class" : 'trackerConfiguration formTableWithSpacing' }).data('trackers', trackers);
			form.append(table);

			var typeRow    = $('<tr>', { title : settings.typeTooltip });
			var typeLabel  = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.typeLabel + ':');
			var typeCell   = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox' });

			var typeSelect = getTypeSelector(items, trackers);
			typeCell.append(typeSelect);

			typeRow.append(typeLabel);
			typeRow.append(typeCell);
			table.append(typeRow);

			var nameRow   = $('<tr>', 	 { title : settings.nameTooltip, style: 'vertical-align: middle;' });
			var nameLabel = $('<td>',	 { "class" : 'labelCell mandatory' }).text(settings.nameLabel + ':');
			var nameCell  = $('<td>', 	 { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
			var nameInput = $('<input>', { type : 'text', name : 'name', value : items.label || items.name, maxlength : 160, disabled : items.custom }).attr("size", "80");
			nameInput.attr('autocomplete', 'off');

			nameCell.append(nameInput);
			nameRow.append(nameLabel);
			nameRow.append(nameCell);
			table.append(nameRow);

			var keyNameRow   = $('<tr>', 	{ title : settings.keyNameTooltip, style: 'vertical-align: middle;' });
			var keyNameLabel = $('<td>',	{ "class" : 'labelCell mandatory' }).text(settings.keyNameLabel + ':');
			var keyNameCell  = $('<td>', 	{ "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
			var keyNameInput = $('<input>', { type : 'text', name : 'keyName', value : escapeHtml(items.keyName), maxlength : 10 }).attr("size", "10");
			keyNameInput.attr('autocomplete', 'off');

			keyNameCell.append(keyNameInput);
			keyNameRow.append(keyNameLabel);
			keyNameRow.append(keyNameCell);
			table.append(keyNameRow);

			var descrRow    = $('<tr>',		  { title : settings.descriptionTooltip });
			var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional', style : 'width: 5%;' }).text(settings.descriptionLabel + ':');
			var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea' });
			var description = $('<textarea>', { name : 'description', rows : 2, cols : 80 }).val(items.description);

			descrCell.append(description);
			descrRow.append(descrLabel);
			descrRow.append(descrCell);
			table.append(descrRow);
		}

		return this.each(function() {
			init($(this), items, trackers);
		});
	};

	$.fn.getTrackerConfig = function() {
		var table   = $('table.trackerConfiguration', this);
		var tracker = $('select[name="type"]', table).find('option:selected').data('tracker');

		// Must return a deep copy, so modifications to fields or choice options have no effect on the base tracker type !!
		return $.extend(true, {}, tracker, {
			name        : $.trim($('input[name="name"]', table).val()),
			keyName     : $.trim($('input[name="keyName"]', table).val()),
			description : $.trim($('textarea[name="description"]', table).val())
		});
	};

	$.fn.showTrackerConfigDialog = function(items, trackers, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showTrackerConfigDialog.defaults, dialog );
		var popup    = this;

		popup.trackerConfigForm(items, trackers, config);

		if (typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
						 	var result = callback(popup.getTrackerConfig());
						 	if (!(result == false)) {
					  			popup.dialog("close");
						 	}
						}
				},
				{ text : config.cancelText,
				  "class": "cancelButton",
				  click: function() {
				  			popup.dialog("close");
						 }
				}
			];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.showTrackerConfigDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true,
		appendTo		: "body"
	};


	// Plugin to allow the user to edit the import configuration
	$.fn.importConfiguration = function(input, target, options) {
		var settings = $.extend( {}, $.fn.importConfiguration.defaults, options );

		settings.trackerTypes    = getTrackerTypes(target.trackers);
		settings.referenceFields = getReferenceFields(target.trackers);

		function startsWith(string, prefix) {
			return string.slice(0, prefix.length) == prefix;
		}

		function getSetting(name) {
			return settings[name];
		}

		function getSourceSelector() {
			var selector = $('<select>', { "class" : 'source', title : settings.source.select.title });

			if (!target.source) {
				selector.append($('<option>', { "class" : 'option', value : null, style: 'color: gray; font-style: italic;' }).text('-- ' + settings.source.select.label + ' --'));
			}

			if ($.isArray(target.sources)) {
				for (var i = 0; i < target.sources.length; ++i) {
					var source = target.sources[i];

					var srcInfo = settings.source[source];
					if ($.isPlainObject(srcInfo)) {
						selector.append($('<option>', {
						   "class"   : 'source',
							value 	 : source,
							title	 : srcInfo.title,
							selected : source === target.source
						}).text(srcInfo.label || source));

					} else {
						selector.append($('<option>', {
						   "class"   : 'source',
							value 	 : source,
							selected : source === target.source
						}).text(source));
					}
				}
			}

			selector.append($('<option>', {
			   "class"	 : 'option',
				value  	 : '-NEW-'
			}).text('-- ' + settings.source["new"].label + ' --'));

			return selector;
		}

		function getSourceLabel(source) {
			var result;

			if (typeof(source) === 'string' && source.length > 0) {
				var srcInfo = settings.source[source];
				if ($.isPlainObject(srcInfo)) {
					result = $('<label>', { title : srcInfo.title }).text(srcInfo.label || source);
				} else {
					result = $('<label>').text(source);
				}
			} else {
				result = $('<span>', { "class" : 'subtext', style : 'color: red', title : settings.source.select.title }).text('-- ' + settings.source.select.label + ' --');
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.source.select.hint
			}));

			return result;
		}

		function createSource() {
			var source = $.trim(prompt(settings.source["new"].title, ''));
			if (source && source.length > 0) {
				if ($.isArray(target.reservedSources) && $.inArray(source, target.reservedSources) != -1) {
					alert(settings.source["new"].exists);
					return target.source;
				}

				if ($.isArray(target.sources)) {
					if ($.inArray(source, target.sources) != -1) {
						return source;
					}
				} else {
					target.sources = [];
				}

				target.sources.push(source);
			} else {
				source = target.source;
			}

			return source;
		}

		function setSource(source) {
			if (source === '-NEW-') {
				source = createSource();
			}

			if (source != target.source) {
				target.source = source;

				if (settings.source.configURL) {
					var container = $(this).closest('table').parent();

					$.ajax(settings.source.configURL, {
						type	 : 'GET',
						data	 : {
							proj_id : target.id,
							source  : source
						},
						dataType : 'json'
					}).done(function(result) {
						setMapping(container, target, result);
					}).fail(function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
				    		alert("GET " + settings.source.configURL + " failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText + ", ex=" + err);
			    		}
			        });
				}
			}

			return getSourceLabel(source)[0].outerHTML;
		}

		function getTrackerTypes(trackers) {
			var sorted = [];

			if ($.isArray(trackers) && trackers.length > 0) {
				var check = {}; // There can be multiple trackers with the same type !!

				for (var i = 0; i < trackers.length; ++i) {
					var type = trackers[i].type;

					if (!check[type.name]) {
						check[type.name] = true;

						// Must push a deep clone, so modifications to predefined trackers have no effect on new trackers build from a type !!
						sorted.push($.extend(true, {}, trackers[i]));
					}
				}

				sorted.sort(function(a, b) {
					return a.type.name.localeCompare(b.type.name);
				});
			}

			return sorted;
		}

		function getTrackerType(tracker) {
			if ($.isPlainObject(tracker)) {
				var type = tracker.type;

				if ($.isPlainObject(type)) {
					return type;
				} else if (typeof type === "number") {
					var types = settings.trackerTypes;

					for (var i = 0; i < types.length; ++i) {
						if (types[i].id === type) {
							type = types[i];
							break;
						}
					}
				}
			}
			return null;
		}

		function findAssocType(assocType) {
			if (assocType && assocType.id) {
				for (var i = 0; i < settings.assocTypes.length; ++i) {
					if (settings.assocTypes[i].id === assocType.id) {
						return settings.assocTypes[i];
					}
				}
			}

			return null;
		}

		function getAssocTypeLabel(assocType) {
			var result = $('<span>');

			if (assocType && assocType.id > 0) {
				result.attr('title', assocType.description).css('font-weight', 'bold').text(assocType.label || assocType.name);
			} else {
				result.attr('class', 'subtext').css('color', 'gray').text('-- ' + settings.noAssocTypeLabel + ' --');
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.clickToEditField
			}));

			return result;
		}

		function setupAssociations(relation, target) {
			target.append($('<span>', {
			   "class" : 'relationTargetSelector',
				title  : settings.selectAssocTypeTitle
			}).append(getAssocTypeLabel(relation.target = findAssocType(relation.target))));
		}

		function selectAssocType(key, opt) {
			var row      = opt.$trigger.closest('tr.relations');
	        var relation = row.data('relation');

			if (key === '-1') {
				delete relation.target;
				row.each(resetTarget);

			} else if (relation.target = findAssocType({id : parseInt(key)})) {
				row.find('td.relationTarget > span.relationTargetSelector').empty().append(getAssocTypeLabel(relation.target));
	        }
		}

		function buildAssocTypeMenu($trigger, event, callback) {
			var items = {};

			if (!$.isFunction(callback)) {
				callback = selectAssocType;
			}

			for (var i = 0; i < settings.assocTypes.length; ++i) {
				var option = settings.assocTypes[i];

				items[option.id.toString()] = {
					name     : option.name,
					callback : callback
				};
			}

			return {
				isHtmlName : true,
				name  : '<label title="' + settings.associationTitle + '">' + settings.associationLabel + '</label>',
				items : items
			};
		}

		function getReferenceFields(trackers) {
			var result = [];

			if ($.isArray(trackers) && trackers.length > 0) {
				var types = {}; // BUG-555209: There can be multiple trackers with the same type and they can have different reference fields !!

				for (var i = 0; i < trackers.length; ++i) {
					var type   = trackers[i].type;
					var fields = trackers[i].fields;

					if ($.isArray(fields) && fields.length > 0) {
						var group = types[type.name];

						if (!$.isPlainObject(group)) {
							group = {
								type   : type,
								fields : {}
							};
							types[type.name] = group;
						}

						var refFlds = group.fields;

						for (var j = 0; j < fields.length; ++j) {
							var field = fields[j];

							if (field && field.mapable) {
								if (field.type == 7) {
									if (field.refType == 9 && !refFlds[field.id.toString()]) {
										refFlds[field.id.toString()] = field;
									}
								} else if (field.type == 12 && $.isArray(field.columns)) {
									for (var k = 0; k < field.columns.length; ++k) {
										var column = field.columns[k];
										if (column && column.type == 7 && column.refType == 9) {
											if (!refFlds[column.id.toString()]) {
												refFlds[column.id.toString()] = $.extend({}, column, {
													label : (field.label || field.name) + ' - ' + (column.label || column.name)
												});
											}
										}
									}
								}
							}
						}
					}
				}

				$.each(types, function(name, group) {
					var refFlds = $.map(group.fields, function(field) { return field; });
					if (refFlds.length > 0) {
						refFlds.sort(function(a, b) {
							return (a.label || a.name).localeCompare(b.label || b.name);
						});

						result.push({
							type   : group.type,
							fields : refFlds
						});
					}
				});

				if (result.length > 1) {
					result.sort(function(a, b) {
						return a.type.name.localeCompare(b.type.name);
					});
				}
			}

			return result;
		}

		function findReferenceField(typeId, field) {
			if (typeId && field && field.id) {
				for (var i = 0; i < settings.referenceFields.length; ++i) {
					var group = settings.referenceFields[i];
					if (group.type.id === typeId) {
						if (field = findField(group.fields, field)) {
							return {
								type  : group.type,
								field : field
							};
						}

						break;
					}
				}
			}
			return null;
		}

		function isMapped(items) {
			return $.isPlainObject(items) && $.isPlainObject(items.target) && items.target.name != '-IGNORE-';
		}

		function getMappedTrackerTypes() {
			var result = {};

			if ($.isPlainObject(input)) {
				if ($.isArray(input.items) && input.items.length > 0) {
					for (var i = 0; i < input.items.length; ++i) {
						var items = input.items[i];
						if (isMapped(items)) {
							result[items.target.type.name] = items.target.type;
						}
					}
				}

				if ($.isArray(input.specifications) && input.specifications.length > 0) {
					for (var i = 0; i < input.specifications.length; ++i) {
						var specification = input.specifications[i];
						if (isMapped(specification)) {
							result[specification.target.type.name] = specification.target.type;
						}
					}
				}
			}

			return result;
		}

		function addReferenceField(relation, referenceFields, referenceField) {
			if (referenceField && referenceField.type && referenceField.field) {
				var refFldSpan = $('<span>', { "class" : 'referenceField' }).data('referenceField', referenceField);

				refFldSpan.append($('<label>', {
				   "class" : 'trackerType',
					title  : referenceField.type.description
				}).text((referenceField.type.label || referenceField.type.name) + ': '));

				refFldSpan.append($('<span>', {
				   "class" : 'field',
					title  : referenceField.field.description
				}).text(referenceField.field.label || referenceField.field.name).append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.clickToEditField
				})));

				refFldSpan.append($('<a>', {
				   "class" : "removeQualifierLink",
					title  : settings.removeLabel
				}).click(function() {
					var fldSpan = $(this).closest('span.referenceField');
					var refFld  = fldSpan.data('referenceField');

					fldSpan.remove();

					if ($.isPlainObject(relation.referenceFields)) {
						delete relation.referenceFields[refFld.type.id];

						if ($.isEmptyObject(relation.referenceFields)) {
							delete relation.referenceFields;

							referenceFields.closest('tr.relations').each(resetTarget);
						}
					}
 				}).append($('<span>', {
					"class" : "ui-icon ui-icon-circle-close"
				})));

				refFldSpan.append($('<span>', { "class" : 'separator' }).text(', '));

				referenceFields.append(refFldSpan);
			}
		}

		function selectReferenceField(key, opt) {
			var target   = opt.$trigger.closest('td.relationTarget');
	        var relation = target.parent().data('relation');

			if (key != '-1') {
				var parts = key.split('-');

				var referenceField = findReferenceField(parseInt(parts[0]), { id : parseInt(parts[1]) });
				if (referenceField) {
					if (!$.isPlainObject(relation.referenceFields)) {
						relation.referenceFields = {};
					}

					relation.referenceFields[referenceField.type.id] = getField(referenceField.field);

					addReferenceField(relation, target.find('span.referenceFields'), referenceField);
				}
			}
		}

		function setupReferenceFields(relation, target) {
			var refFields = $('<span>', { "class" : 'referenceFields' });
			var selector  = $('<span>', { "class" : 'relationTargetSelector ui-icon ui-icon-circle-plus', title : settings.moreReferenceFieldsLabel });

			target.append(refFields).append(selector);

			if ($.isPlainObject(relation.referenceFields)) {
				for (var typeId in relation.referenceFields) {
					addReferenceField(relation, refFields, findReferenceField(parseInt(typeId), relation.referenceFields[typeId]));
				}
			}

			return selector;
		}

		function buildReferenceFieldMenu($trigger, event, group, prefix, callback) {
			var items = {};

			if (!$.isPlainObject(group)) {
		       	var refField = $trigger.closest('span.referenceField').data('referenceField');
				var type     = refField.type;

				for (var i = 0; i < settings.referenceFields.length; ++i) {
					if (settings.referenceFields[i].type.id === type.id) {
						group = settings.referenceFields[i];
						break;
					}
				}

				prefix = '';

				callback = function(key, opt) {
					var field = findField(group.fields, { id : parseInt(key) });
			       	if (field) {
			       		refField.field = field;

				       	opt.$trigger.closest('tr.relations').data('relation').referenceFields[type.id] = getField(field);

				       	opt.$trigger.attr('title', field.description).text(field.label || field.name).append($('<img>', {
						   "class" : 'inlineEdit',
							src    : contextPath + '/images/inlineEdit.png',
							title  : settings.clickToEditField
						}));
			       	}
				};
			}

			for (var i = 0; i < group.fields.length; ++i) {
				var field = group.fields[i];

				items[prefix + field.id] = {
					name     : field.label || field.name,
					callback : callback
				};
			}

			return $.isEmptyObject(items) ? false : {
				name  : group.type.name,
				items : items
			};
		}

		function buildReferenceFieldsMenu($trigger, event, callback) {
        	var mappedTypes = getMappedTrackerTypes();
        	var relation    = $trigger.closest('tr.relations').data('relation');
        	var refFields   = relation.referenceFields;
			var items		= {};

			if (!$.isPlainObject(refFields)) {
				refFields = {};
			}

			if (!$.isFunction(callback)) {
				callback = selectReferenceField;
			}

			for (var i = 0; i < settings.referenceFields.length; ++i) {
				var group = settings.referenceFields[i];

				if (mappedTypes[group.type.name] && !refFields[group.type.id]) {
					items[group.type.id.toString()] = buildReferenceFieldMenu($trigger, event, group, group.type.id + '-', callback);
				}
			}

			return $.isEmptyObject(items) ? false : {
				isHtmlName : true,
				name  : '<label title="' + settings.referenceTitle + '">' + settings.referenceLabel + '</label>',
				items : items
			};
		}

		function setupRelationTarget(relation, target) {
			if (relation.target && relation.target.id > 0) {
				setupAssociations(relation, target);
			} else if ($.isPlainObject(relation.referenceFields) && !$.isEmptyObject(relation.referenceFields)) {
				setupReferenceFields(relation, target);
			} else {
				target.append($('<span>', {
				   "class" : 'relationTargetSelector subtext',
					title  : settings.selectRelationTitle,
					style  : 'color: gray;'
				}).text('-- ' + settings.ignoreRelationLabel + ' --').append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.clickToEditField
				})));
			}
		}

		function resetRelationTarget() {
			var row      = $(this).closest('tr.relations');
	        var relation = row.data('relation');

	        setupRelationTarget(relation, row.find('td.relationTarget').empty());
		}

		function buildRelationTargetMenu($trigger, event) {
			var target   = $trigger.closest('td.relationTarget');
	        var relation = target.parent().data('relation');
	        var items 	 = {
				ignore : {
					name  		: '<label title="' + settings.ignoreRelationTitle + '">-- ' + settings.ignoreRelationLabel + ' --</label>',
					isHtmlName	: true,
		            callback 	: function(key, opt) {
		            	delete relation.target;
		            	delete relation.referenceFields;

		            	setupRelationTarget(relation, target.empty());
		            }
				},

				association : buildAssocTypeMenu($trigger, event, function(key, opt) {
			        delete relation.referenceFields;

			        setupAssociations(relation, target.empty());
			        selectAssocType(key, {$trigger : target});
				}),

				reference : buildReferenceFieldsMenu($trigger, event, function(key, opt) {
			        delete relation.target;

			        setupReferenceFields(relation, target.empty());
			        selectReferenceField(key, {$trigger : target});
				})
			};

	        if (!items.reference) {
	        	delete items.reference;
	        }

			return {
				items : items
			};
		}

		function trackerExists(trackers, tracker) {
			if ($.isArray(trackers) && trackers.length > 0 && $.isPlainObject(tracker) && tracker.name) {
				var nameUpper = tracker.name.toUpperCase();

				for (var i = 0; i < trackers.length; ++i) {
					if ((trackers[i].name && (trackers[i].name.toUpperCase() === nameUpper)) ||
					    (trackers[i].label && (trackers[i].label.toUpperCase() === nameUpper))) {
	 					return trackers[i];
					}
				}
			}
			return null;
		}

		function addTracker(trackers, tracker) {
			var added = false;

			tracker.custom = true;
			if (!tracker.label) {
				tracker.label = tracker.name;
			}

			for (var i = 0; i < trackers.length; ++i) {
				if (tracker.label.localeCompare(trackers[i].label) <= 0) {
					trackers.splice(i, 0, tracker);
					added = true;
					break;
				}
			}

			if (!added) {
 				trackers.push(tracker);
			}
		}

		function createTrackerIfNotExists(trackers, tracker) {
			if ($.isArray(trackers) && tracker && tracker.name) {
				if (tracker.name != '-IGNORE-') {
					var exists = trackerExists(trackers, tracker);
					if (exists) {
						tracker = exists;
					} else {
						if (!tracker.label) {
							tracker.label = tracker.name;
						}

						if (!$.isPlainObject(tracker.type)) {
							tracker.type = {
								id   : typeof tracker.type === 'number' ? tracker.type : 5,
								name : 'Requirement'
							};
						}

						// We must derive the new tracker from the appropriate type !!!
						var types = settings.trackerTypes;
						for (var i = 0; i < types.length; ++i) {
							if (types[i].type.id == tracker.type.id) {
								// Must derive as a deep copy, so later modifications of tracker fields/choice options have no impact on base type
								tracker = $.extend(true, {}, types[i], tracker, { type : types[i].type });
								break;
							}
						}

						addTracker(trackers, tracker);
					}
				}
			}

			return tracker;
		}

		function createNewTracker(items, target, callback) {
			var trackers = target.data('trackers');
			var popup = $('#trackerConfigPopup');
 			popup.empty();

  			popup.showTrackerConfigDialog(items, trackers, settings, {
				title			: settings.newTrackerTitle,
				position		: { my: "left top", at: "left top", of: target, collision: 'fit' },
				modal			: true,
				closeOnEscape	: true

  			}, function(tracker) {
 				if (!tracker.name || tracker.name.length == 0) {
 					alert(getSetting('nameMissing'));
 					return false;
 				}

 				if (!tracker.keyName || tracker.keyName.length == 0) {
 					alert(getSetting('keyNameMissing'));
 					return false;
 				}

				if (trackerExists(trackers, tracker)) {
					alert(getSetting('nameExisting'));
 					return false;
 				}

				tracker.label = tracker.name;

				if (items.description && !tracker.description) {
 	 				tracker.description = items.description;
				}

 				addTracker(trackers, tracker);

  			    return callback(tracker);
  			});
		}

		function showTracker(items, target) {
			var tracker = items.target;
			var popup = $('#trackerConfigPopup');

 			popup.empty();

  			popup.showTrackerConfigDialog(tracker, target.data('trackers'), settings, {
				title			: settings.showTrackerTitle,
				position		: { my: "left top", at: "left top", of: target, collision: 'fit' },
				modal			: true,
				closeOnEscape	: true

  			}, tracker.custom ? function(edited) {
 				tracker.keyName     = edited.keyName;
  				tracker.description = edited.description;

  				if (tracker.type.id != edited.type.id) {
  	  				tracker.type   = edited.type;
  	  				tracker.fields = edited.fields;

  					target.find('span.targetTracker').html(setTargetTracker.apply(target, [tracker.name]));
 				}

  			} : false);
		}

		function showAttrValues() {
			var link = $(this);
			var attrib = link.closest('tr.attrib').data('attrib');
			var values = $(this).data('values');
			var popup = $('#trackerConfigPopup');

			popup.empty();

 			var list = $('<ol>');

 			if ($.isArray(values) && values.length > 0) {
 				for (var i = 0; i < values.length; ++i) {
 					list.append($('<li>').text(values[i]));
 				}
 			}

 			popup.append(list);

 			popup.dialog({
 				dialogClass		: 'popup',
 				width			: 800,
 				draggable		: true,
 				modal			: true,
 				closeOnEscape	: true,
 				title			: attrib.name + ': ' + settings.valuesLabel,
 				position		: { my: "left top", at: "right top", of: link, collision: 'fit' }
 			});
		}

		function mergeChoiceFieldOptions(attrib, field) {
			if (attrib.type == 6 && field.id == null) {
				if (!$.isPlainObject(field.merged)) {
					field.merged = {};
				}

				if (!field.merged[attrib.id]) {
					var options = attrib.options;
					if ($.isArray(options) && options.length > 0) {
						var existing = null;

						if ($.isArray(field.options)) {
							existing = $.map(field.options, function(option) {
								return option.name;
							});
						} else {
							field.options = [];
						}

						// Add missing choice options
						for (var i = 0; i < options.length; ++i) {
							if (existing == null || existing.length == 0 || $.inArray(options[i].name, existing) == -1) {
								var option = getOption(options[i]);
								if (option) {
									delete option.id; // Remove the (row) id of the option

									field.options.push(option);
								}
							}
						}
					}

					field.merged[attrib.id] = true;
				}
			}
		}

		function resetTarget() {
			var reset = $(this).data('reset');
			if ($.isFunction(reset)) {
				reset.apply(this);
			}
		}

		function findOptionByName(options, name, ignoreCase) {
			if ($.isArray(options) && options.length > 0 && name && name.length > 0) {
				if (ignoreCase) {
					name = name.toUpperCase();
				}

				for (var i = 0; i < options.length; ++i) {
					var option = options[i];

					if (option && option.name && (ignoreCase ? option.name.toUpperCase() : option.name) === name) {
						return option;
					}
				}

				if (ignoreCase) {
					for (var i = 0; i < options.length; ++i) {
						var option = options[i];

						if (option && option.label && option.label.toUpperCase() === name) {
							return option;
						}
					}
				}
			}

			return null;
		}

		function createNewOption(options, template) {
			var option = null;

			var optName = $.trim(prompt(getSetting('valueNameTitle'), template.name || ''));
			if (optName && optName.length > 0) {
				var nameUpper = optName.toUpperCase();

				if ($.isArray(options)) {
					for (var i = 0; i < options.length; ++i) {
						if (nameUpper === options[i].name.toUpperCase() || (options[i].label && (nameUpper === options[i].label.toUpperCase()))) {
							if (optName === options[i].name || optName === options[i].label) {
//								alert(getSetting('duplicateValueName'));
								option = options[i];
								break;
							} else if (!confirm(getSetting('createSimilarValue'))) {
								option = options[i];
								break;
							}
						}
					}
				} else {
					options = [];
				}

				if (!option) {
					option = $.extend(getOption(template), {
						name  : optName,
						label : optName
					});

					delete option.id;

					options.push(option);
				}
			}

			return option;
		}

		function getTargetOptions(attrib) {
			var field = attrib.target;
			if (field && field.id != -1 && field.type === 6) {
				if (!$.isArray(field.options)) {
					field.options = [];
				}

				return field.options;
			}

			return null;
		}

		function getTargetOptionSelector(options, selectedVal) {
			var selector = $('<select>', { "class" : 'option', title : settings.selectValueTitle });

			if (!selectedVal) {
				selector.append($('<option>', { "class" : 'option', value : null, style: 'color: gray; font-style: italic;' }).text('-- ' + settings.selectValueLabel + ' --'));
			}

			if ($.isArray(options)) {
				for (var i = 0; i < options.length; ++i) {
					var option = options[i];

					selector.append($('<option>', {
					   "class"   : 'option',
						value 	 : option.name,
						title 	 : option.description,
						selected : (option.name === selectedVal)
					}).text(option.label || option.name).data('option', option));
				}
			}

			selector.append($('<option>', {
			   "class"	 : 'option',
				value  	 : '-NEW-'
			}).text('-- ' + settings.newValueLabel + ' --'));

			return selector;
		}

		function getOptionLabel(option) {
			var result = $('<label>', { "class" : 'inputTarget', style : 'font-style: italic' });

			if (option != null) {
				result.attr('title', option.description).text(option.label || option.name);
			} else {
				result.css('color', 'red').text('-- ' + settings.selectValueLabel + ' --');
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.clickToEditValue
			}));

			return result;
		}

		function isTargetOption(option, target) {
			if ($.isPlainObject(target)) {
				if (target.id === undefined || target.id == null) {
					return option.name === target.name;
				}
				return option.id === target.id;
			} else if (typeof target === "string") {
				return option.name === target;
			} else if (typeof target === "number") {
				return option.id === target;
			}

			return false;
		}

		function findTargetOption(options, target) {
			if ($.isArray(options) && options.length > 0 && target) {
				for (var i = 0; i < options.length; ++i) {
					if (isTargetOption(options[i], target)) {
						return options[i];
					}
				}
			}

			return null;
		}

		function isNewOption(options, target) {
			if ($.isPlainObject(target)) {
				return (target.id === undefined || target.id == null) && target.name && !findOptionByName(options, target.name, false);
			} else if (typeof target === "string") {
				return !findOptionByName(options, target, false);
			}

			return false;
		}

		function setOption(option, target) {
			if (target) {
				var values = getTargetOptions(option.attrib);
				var exists = null;

				if ($.isArray(values)) {
					exists = findTargetOption(values, target);
				} else {
					values = [];
				}

				if (exists) {
					target = exists;
				} else if (isNewOption(values, target)) {
					if ($.isPlainObject(target)) {
						target = $.extend(getOption(option), target, {
							label : target.label || target.name
						});
					} else {
						target = $.extend(getOption(option), {
							name  : target,
							label : target
						});
					}

					delete target.id;

					values.push(target);
				} else {
					target = null;
				}

				if (target) {
					option.target = target;
				}
			}

			return target;
		}

		function resetOption(option, createIfNotExists) {
			var name    = (option.target && option.target.name ? option.target.name : option.name);
			var options = getTargetOptions(option.attrib);

			option.target = findTargetOption(options, option.target) || findOptionByName(options, name, false) || findOptionByName(options, name, true);

			if (option.target == null && createIfNotExists) {
				setOption(option, name);
			}
		}

		function setOptions(options, targets) {
			if ($.isArray(options) && options.length > 0 && $.isPlainObject(targets)) {
				for (var i = 0; i < options.length; ++i) {
					var option = options[i];

					var target = targets[option.name];
					if (target) {
						setOption(option, target.target);
					}
				}
			}
		}

		function resetOptions(options, createIfNotExists) {
			if ($.isArray(options) && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					resetOption(options[i], createIfNotExists);
				}
			}
		}

		function setupOptionTarget(option, target) {
			var div = null;

			if (option.attrib.target && option.attrib.target.id != -1) {
				div = $('<div>', { "class" : 'optTarget', style : 'width: 100%;' });
				target.append(div);

				div.append(getOptionLabel(option.target));

				div.editable(setOptionTarget, {
			        type   : 'optionTarget',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}

			return div;
		}

		function setOptionTarget(value) {
	       	var option = $(this).closest('tr.option').data('option');

			if (value === '-NEW-') {
				var newOption = createNewOption(getTargetOptions(option.attrib), option);
				if (newOption) {
					option.target = newOption;
				}
			}

			return getOptionLabel(option.target)[0].outerHTML;
		}

		function resetOptionTarget() {
			var optRow = $(this);
			var option = optRow.data('option');
			if (option) {
				var optTarget = optRow.find('div.optTarget');

				if (option.attrib.target && option.attrib.target.id != -1) {
					if (optTarget.length == 0) {
						setupOptionTarget(option, optRow.find('td.optTarget'));
					} else {
						optTarget.empty().append(getOptionLabel(option.target));
					}
				} else {
					optTarget.remove();
				}
			}
		}

		function resetOptionTargets(attrRow) {
			var attrib = attrRow.data('attrib');
			if (attrib.type == 6) {
				var attrId = attrRow.attr('data-tt-id');

				attrRow.nextUntil(':not(tr.option[data-tt-parent-id="' + attrId + '"])').each(resetOptionTarget);

				if (settings.expand) {
					try {
						attrRow.closest('table').treetable(attrib.target && attrib.target.id != -1 ? "expandNode" : "collapseNode", attrId);
					} catch(e) {
						alert(e.stack);
					}
				}
			}
		}

		function assignUnmappedOptions() {
			var attRow = $(this).closest('tr.attrib');
			var attrId = attRow.attr('data-tt-id');

			attRow.nextUntil(':not(tr.option[data-tt-parent-id="' + attrId + '"])').each(function() {
				var optRow = $(this);
				var option = optRow.data('option');
				if (option && !option.target && setOption(option, option.name)) {
					resetOptionTarget.apply(optRow);
				}
			});
		}

		function setupOptionMapping(node, row, type) {
			var attrib  = row.data('attrib');
			var options = attrib.options;

			if ($.isArray(options) && options.length > 0) {
				var attribId    = row.attr('data-tt-id');
				var optionInset = row.attr('data-option-inset');
				var optRows 	= $('<tbody>');

				for (var i = 0; i < options.length; ++i) {
					var option = options[i];
					var optRow = $('<tr>', { "class" : 'option even', "data-tt-id" : option.id, "data-tt-parent-id" : attribId }).data('option', option).data('reset', resetOptionTarget);
					optRow.append($('<td>', { "class" : 'optName', title : option.description, style: 'vertical-align: middle; width: 40%;' }).text(option.name));
					optRow.append($('<td>', { "class" : 'numberData', style : 'width: 2em;' }).text(option.count));

					var optTarget = $('<td>', { "class" : 'optTarget', style : 'vertical-align: middle; padding-left: ' + optionInset });
					optRow.append(optTarget);

					setupOptionTarget(option, optTarget);

					optRows.append(optRow);
				}

				row.closest('table').treetable('loadBranch', node, optRows.find('tr.option'));
			}
		}

		function findField(fields, field) {
			if ($.isArray(fields) && fields.length > 0 && field && (field.id || field.name)) {
				if (field.id === -1) {
					return null;
				} else {
					if (field.id) {
						for (var i = 0; i < fields.length; ++i) {
							if (field.id === fields[i].id) {
								return fields[i];
							}
						}

						if (field.id < 100) {
							return null;
						}
					}

					if (field.name) {
						var fldKey = field.name.toUpperCase();

						for (var i = 0; i < fields.length; ++i) {
							if (fldKey === fields[i].name.toUpperCase()) {
								return fields[i];
							}
						}
					}
				}
			}

			return null;
		}

		function isAssignable(attrib, field) {
			return field.mapable && (field.type == attrib.type || (field.type == 10 && attrib.type == 0) || (field.type == 0 && attrib.type == 10));
		}

		function createNewField(attrib, fldName, auto) {
			var field = null;

			if (!(fldName && fldName.length > 0)) {
				fldName = attrib.name;
			}

			// Remove any 'ReqIF.' prefix (ReqIF implementation rule R4)
			if (fldName && fldName.indexOf('ReqIF.') == 0) {
				fldName = fldName.substring(6);
			}

			if (auto) {
				if (fldName === 'Name') {
					fldName = 'summary';
				} else if (fldName === 'Text') {
					fldName = 'description';
				}
			} else {
				fldName = $.trim(prompt(getSetting('fieldNameTitle'), fldName));
			}

			if (fldName && fldName.length > 0) {
				var nameUpper = fldName.toUpperCase();

				var fields = getTargetFields(attrib.parent);
				if ($.isArray(fields)) {
					for (var i = 0; i < fields.length; ++i) {
						if (nameUpper === fields[i].name.toUpperCase() ||
							(fields[i].rest  && (nameUpper === fields[i].rest.toUpperCase())) ||
							(fields[i].label && (nameUpper === fields[i].label.toUpperCase()))) {
							field = fields[i];
							break;
						}
					}
				} else {
					fields = [];
				}

				if (field == null) {
					field = {
						name 		: fldName,
						label 		: fldName,
						description : attrib.description,
						type 		: attrib.type,
						mapable 	: true
					};

					fields.push(field);
				} else if (!isAssignable(attrib, field)) {
					if (!auto) {
						alert(getSetting(field.mapable ? 'duplicateFieldName' : 'reservedFieldName'));
					}
					return null;
				}

				mergeChoiceFieldOptions(attrib, field);
			}

			return field;
		}

		function getTargetFields(items) {
			return isMapped(items) ? ($.isPlainObject(items.table) ? items.table.columns : items.target.fields) : null;
		}

		function getTargetFieldSelector(attrib, fields, selectedFld) {
			var selector = $('<select>', { "class" : 'field', title : settings.selectFieldTitle });

			if (!selectedFld) {
				selector.append($('<option>', { "class" : 'field', value : null, style: 'color: gray; font-style: italic;' }).text('-- ' + settings.selectFieldLabel + ' --'));
			}

			selector.append($('<option>', {
			   "class"	 : 'field',
				value	 : "-IGNORE-",
				title 	 : settings.ignoreFieldTitle,
				selected : (selectedFld && selectedFld.id === -1)
			}).text('-- ' + settings.ignoreFieldLabel + ' --').data('field', { id : -1 }));

			if ($.isArray(fields)) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];

					if (isAssignable(attrib, field)) {
						selector.append($('<option>', {
						  "class" 	: 'field',
						   value 	: field.id || field.name,
						   title	: field.description,
						   selected : selectedFld && (selectedFld.id ? field.id === selectedFld.id : field.name === selectedFld.name)
						}).text((field.label || field.name) + ' (' + settings.typeName[field.type] + ')').data('field', field));
					}
				}
			}

			selector.append($('<option>', { "class" : 'field', value : '-NEW-' }).text('-- ' + settings.newFieldLabel + ' --'));

			return selector;
		}

		function getFieldLabel(field) {
			var result = $('<span>', { "class" : 'subtext' });

			if (field != null) {
				if (field.id < 0) {
					result.css('color', 'gray').text('-- ' + settings.ignoreFieldLabel + ' --');
				} else {
					result.css('margin-left', '6px').text('(' + settings.typeName[field.type] + ')');

					var label = $('<label>', { title : field.description}).text(field.label || field.name);
					label.append(result);

					result = label;
				}
			} else {
				result.css('color', 'red').text('-- ' + settings.selectFieldLabel + ' --');
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.clickToEditField
			}));

			return result;
		}

		function findAttribField(attrib, field) {
			if (!($.isPlainObject(field) && (field.id || field.name))) {
				var dflt = settings.defaultAttributeMapping[attrib.name];
				if (dflt) {
					field = {
						id : dflt
					};
				} else {
					field = {
						name : attrib.name
					};
				}
			}

			return findField(getTargetFields(attrib.parent), field);
		}

		function setAttribute(attrib, field, createIfNotExists) {
			if (attrib.table) {
				// Make sure, that the implicit table field mapping is not corrupted
				if (!attrib.target) {
					attrib.target = {
						id : settings.tableMapping[attrib.name] || -1
					};
				}
				return attrib.target;
			}

			var exists = findAttribField(attrib, field);
			if (exists) {
				if (isAssignable(attrib, exists)) {
					field = exists;
					mergeChoiceFieldOptions(attrib, field);
				} else {
					return null;
				}
			} else if (field && field.name && !(field.id === -1)) {
				if (createIfNotExists) {
					field = createNewField(attrib, field.name, true);
				} else {
					return null;
				}
			}

			if (field && (field.id || field.name)) {
				if (field != attrib.target) {
					attrib.target = field;
					resetOptions(attrib.options, createIfNotExists);
				}

				return field;
			}
			return null;
		}

		function resetAttribute(attrib, createIfNotExists) {
			if (!setAttribute(attrib, attrib.target || {}, createIfNotExists) && attrib.target) {
				attrib.target = null;
				resetOptions(attrib.options, false);
			}
		}

		function setAttributes(specType, target) {
			var attribs = specType.fields;
			if ($.isArray(attribs) && attribs.length > 0 && $.isPlainObject(target)) {
				for (var i = 0; i < attribs.length; ++i) {
					var attrib = attribs[i];

					var targetAttr = target[attrib.name];
					if (targetAttr) {
						setAttribute(attrib, targetAttr.target, true);
						setOptions(attrib.options, targetAttr.optionsPerName);
					}
				}
			}
		}

		function resetAttributes(specType, createIfNotExists) {
			var attribs = specType.fields;

			if ($.isArray(attribs) && attribs.length > 0) {
				for (var i = 0; i < attribs.length; ++i) {
					resetAttribute(attribs[i], createIfNotExists);
				}
			}
		}

		function setupAttributeTarget(attrib, target) {
			var div = null;

			if (isMapped(attrib.parent)) {
				div = $('<div>', { "class" : 'attrTarget', style : 'width: 100%;' });
				target.append(div);

	        	div.append(getFieldLabel(attrib.target));

	        	div.editable(setAttributeTarget, {
			        type   : 'attributeTarget',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}

			return div;
		}

		function setAttributeTarget(value) {
	        var attRow = $(this).closest('tr.attrib');
	       	var attrib = attRow.data('attrib');

        	if (value === '-NEW-') {
        		var newFld = createNewField(attrib, null, false);
				if (newFld) {
					attrib.target = newFld;
				}
			}

        	resetOptions(attrib.options, false);
         	resetOptionTargets(attRow);

			return getFieldLabel(attrib.target)[0].outerHTML;
		}

		function resetAttributeTarget() {
			var attRow = $(this);
	       	var attrib = attRow.data('attrib');
	       	if (attrib) {
				var attTarget = attRow.find('div.attrTarget');

				if (isMapped(attrib.parent)) {
					if (attTarget.length == 0) {
						setupAttributeTarget(attrib, attRow.find('td.attrTarget'));
					} else {
						attTarget.empty().append(getFieldLabel(attrib.target));
					}
				} else {
					attTarget.remove();
				}
	       	}
		}

		function changeAttribute(row, attrib, field) {
			if (isMapped(attrib.parent)) {
				setAttribute(attrib, field, true);
				resetAttributeTarget.apply(row);
				resetOptionTargets(row);
			}
		}

		function resetItemAttributeTargets(itemsRow) {
			var items = itemsRow.data('item');
			if (items) {
				itemsRow.nextUntil(':not(tr.attrib,tr.option)').each(resetTarget);

				if (settings.expand) {
					try {
						itemsRow.closest('table').treetable(isMapped(items) ? "expandNode" : "collapseNode", itemsRow.attr('data-tt-id'));
					} catch(e) {
						alert(e.stack);
					}
				}
			}
		}

		function showHideEmptyItemAttributes(parent, showEmpty, showIgnored) {
			var parentId = parent.attr('data-tt-id');

			parent.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + parentId + '"]').each(function() {
				var attRow = $(this);
				var attrib = attRow.data('attrib');

				if ((showEmpty || attrib.count > 0) /*&& (showIgnored || (!attrib.target || attrib.target.id != -1))*/) {
					attRow.show();
				} else {
					attRow.hide();
				}
			});
		}

		function addToTrie(trie, name) {
			if (name && name.length > 0) {
				var letters = name.split("");
				var node    = trie;

				for (var i = 0; i < letters.length; ++i) {
					var letter = letters[i];
					var next = node[letter];

					if (next == null) {
						next = node[letter] = (i === letters.length - 1 ? 0 : {});
					} else if (next === 0) {
						next = node[letter] = { '$' : 0 };
					}

					node = next;
				}
			}
		}

		function optimizeTrie(trie) {
			var num = 0, last = null;

			for (var node in trie) {
				if (typeof trie[node] === "object" ) {
					var ret = optimizeTrie(trie[node]);
					if (ret) {
						delete trie[node];
						node = node + ret.name;
						trie[node] = ret.value;
					}
				}

				last = node;
				num++;
			}

			if (num === 1) {
				return { name: last, value: trie[last] };
			}
		}

		function prefixesTrie(trie, prefix, result) {
			var num = 0;

			for (var node in trie) {
				if (typeof trie[node] === "object" ) {
					var path  = prefix + node;
					var leafs = prefixesTrie(trie[node], path, result);

					if (leafs > 1 && node.length >= 2) {
						result.push(path);
					}

					num += leafs;
				} else {
					num++;
				}
			}

			return num;
		}

		function buildPrefixesMenu(menu, action, prefixes, callback) {
			if (!$.isPlainObject(menu)) {
				menu = {};
			}

	        if ($.isArray(prefixes) && prefixes.length > 0) {
	        	for (var i = 0; i < prefixes.length; ++i) {
	        		var prefix = prefixes[i];

	        		menu[action + prefix] = {
	    			    name	 : prefix + '*'
	        		};
	        	}
	        }

			return $.isEmptyObject(menu) ? false : {
				items	 : menu,
				callback : callback
			};
		}

		function getAttributeNamePrefixes(parent) {
			var parentId = parent.attr('data-tt-id');
			var prefix   = [];
			var trie     = {};

			// Build a Trie structure
			parent.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + parentId + '"]').each(function() {
				addToTrie(trie, $(this).data('attrib').name);
			});

			optimizeTrie(trie);
			prefixesTrie(trie, "", prefix);

			return prefix.sort();
		}

		function ignoreAttributes(key, options) {
			var parent   = options.$trigger.closest('tr');
			var parentId = parent.attr('data-tt-id');
			var ignore   = { id : -1 };

			if (key.indexOf('ignore_') == 0) {
				key = key.substring(7);
			}

			parent.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + parentId + '"]').each(function() {
				var row    = $(this);
				var attrib = row.data('attrib');

				if (key === 'Rest_') {
					var field = attrib.target;
					if (!field) {
						changeAttribute(row, attrib, ignore);
					}
				} else if (attrib.name.indexOf(key) == 0) {
					changeAttribute(row, attrib, ignore);
				}
			});
		}

		function getIgnoreAttributesMenu(parent) {
        	return buildPrefixesMenu({
				ignore_Rest_ : {
					name : getSetting("unmappedAttributes")
				}
        	}, 'ignore_', getAttributeNamePrefixes(parent), ignoreAttributes);
		}

   	  	function assignAttributes(key, options) {
			var parent   = options.$trigger.closest('tr');
			var parentId = parent.attr('data-tt-id');

			parent.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + parentId + '"]').each(function() {
				var row    = $(this);
				var attrib = row.data('attrib');
				var field  = attrib.target;

				if (key === 'autoMapRest') {
					if (!field) {
						changeAttribute(row, attrib, { name : attrib.name });
					}
				} else if (attrib.name.indexOf(key) == 0) {
					if (!field || field.id === -1) {
						changeAttribute(row, attrib, { name : attrib.name });
					}
				}
			});
   	  	}

   	  	function getAssignAttributesMenu(parent) {
        	return buildPrefixesMenu({
	    		autoMapRest : {
					name : getSetting("unmappedAttributes")
	    		}
        	}, '', getAttributeNamePrefixes(parent), assignAttributes);
		}

   	  	function createAssignIgnoreAllControls(clazz) {
			var controls = $('<span>', { "class" : clazz || 'controls' });
			controls.append($('<a>', { "class" : 'edit-link ignore-all', style : 'font-size: smaller !important;' }).text(settings.ignoreAttrLabel));
			controls.append($('<a>', { "class" : 'edit-link assign-all', style : 'font-size: smaller !important;' }).text(settings.autoMapAttrLabel));

			return controls;
   	  	}

		function setupAttribMapping(node, row, type) {
			var item    = row.data(type);
			var attribs = item.fields;

			if ($.isArray(attribs) && attribs.length > 0) {
				var itemId      = row.attr('data-tt-id');
				var attribInset = row.attr('data-attrib-inset');
				var optionInset = row.attr('data-option-inset');
				var attrRows 	= $('<tbody>');
				var rowCount    = 0;

				for (var i = 0; i < attribs.length; ++i) {
					var attrib = attribs[i];

					if (!attrib.table) {
						var attrRow    = $('<tr>', { "class" : 'attrib odd', "data-tt-id" : attrib.id, "data-tt-parent-id" : itemId }).data('attrib', attrib).data('reset', resetAttributeTarget);
						var attrName   = $('<td>', { "class" : 'attrName', title : attrib.description, style: 'vertical-align: middle; width: 40%;' });
						var attrVals   = $('<td>', { "class" : 'numberData', style : 'width: 2em;' });
						var attrTarget = $('<td>', { "class" : 'attrTarget', style : 'vertical-align: middle; padding-left: ' + attribInset });

						attrName.append($('<label>').text(attrib.name));
						attrName.append($('<span>', { "class" : 'subtext', style : 'margin-left: 6px;' }).text('(' + settings.typeName[attrib.type] + ')'));

						if (attrib.count > 0 && $.isArray(attrib.values) && attrib.values.length > 0) {
							attrVals.append($('<a>').text(attrib.count).data('values', attrib.values).click(showAttrValues));
						} else {
							attrVals.text(attrib.count);
						}

						attrRow.append(attrName);
						attrRow.append(attrVals);
						attrRow.append(attrTarget);

						setupAttributeTarget(attrib, attrTarget);

						attrRows.append(attrRow);

						var options = attrib.options;
						if ($.isArray(options) && options.length > 0) {
							attrRow.addClass('unloaded').attr({
								"data-tt-branch"    : true,
								"data-option-inset" : optionInset
							});

							attrName.append($("<a>", {
							   "class" : "edit-link",
								style  : 'font-size: smaller !important;',
								title  : settings.assignUnmappedOptions
							}).text(settings.autoMapAttrLabel).click(assignUnmappedOptions));
						}

						rowCount++;
					}
				}

				// add the ignoreAll link that is used as the context menu trigger
				if (rowCount > 1) {
					var itemName = row.find('td.' + type + 'Name');

					var controls = itemName.find('span.attribControls');
					if (controls.length == 0) {
						itemName.append(createAssignIgnoreAllControls('attribControls'));
					}
				}

				row.closest('table').treetable('loadBranch', node, attrRows.find('tr.attrib'));
			}
		}

		function getQualifierFields(fields) {
			var result = [];

			if ($.isArray(fields) && fields.length > 0) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];
					if (field.id > 0 && field.type == 6) {
						result.push(field);
					}
				}
			}

			return result;
		}

		function findQualifierField(fields, qualifier) {
			if ($.isArray(fields) && fields.length > 0 && qualifier && qualifier.field) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];
					if (field.id === qualifier.field.id) {
						return field.type == 6 ? field : null;
					}
				}
			}
			return null;
		}

		function selectQualifierValue(key, opt) {
			var qualiSpan = opt.$trigger.closest('span.qualifier');
			var qualifier = qualiSpan.data('qualifier');
			var newValue  = null;

			if (key === '-NEW-') {
				newValue = createNewOption(qualifier.field.options, { name : '' });
			} else  {
				newValue = findOptionByName(qualifier.field.options, key, false);
			}

			if (newValue) {
				qualifier.value = newValue;

				qualiSpan.find('span.qualiValue').empty().append(getOptionLabel(qualifier.value));
			}
		}

		function buildQualifierValueMenu($trigger, event, qualifier, prefix, callback) {
			if (!$.isPlainObject(qualifier)) {
				qualifier = $trigger.closest('span.qualifier').data('qualifier');
			}

			var options   = qualifier.field.options;
        	var selected  = qualifier.value ? qualifier.value.name : null;
        	var items     = {};

        	prefix = prefix || '';

        	if (!$.isFunction(callback)) {
        		callback = selectQualifierValue;
        	}

			if ($.isArray(options) && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					var option = options[i];
					if (option && option.name && (selected == null || option.name != selected)) {
						if (option.description && option.description.length > 0) {
							items[prefix + option.name] = {
								name  		: '<label title="' + option.description + '">' + (option.label || option.name) + '</label>',
								isHtmlName	: true,
								callback    : callback
							};
						} else {
							items[prefix + option.name] = {
								name 	 : option.label || option.name,
								callback : callback
							};
						}
					}
				}
			}

			items[prefix + '-NEW-'] = {
				name : '-- ' + settings.newValueLabel + ' --'
			};

			return {
				name  		: '<label title="' + settings.selectValueTitle + '">' + settings.selectValueLabel + '</label>',
				isHtmlName	: true,
				items 		: items,
				callback	: callback
			};
		}

		function setQualifiers(items, qualifiers) {
			items.qualifiers = [];

			if ($.isArray(qualifiers) && qualifiers.length > 0) {
				var qualiFields = getQualifierFields(getTargetFields(items));
				if (qualiFields.length > 0) {
					for (var i = 0; i < qualifiers.length; ++i) {
						var qualifier = qualifiers[i];

						var field = findQualifierField(qualiFields, qualifier);
						if (field && qualifier.value && qualifier.value.name) {
							var value = null;

							if ($.isArray(field.options)) {
								value = findOptionByName(field.options, qualifier.value.name, false);
							} else {
								field.options = [];
							}

							if (value == null) {
								field.options.push(value = qualifier.value);
							}

							items.qualifiers.push({
								field : field,
								value : value
							});
						}
					}
				}
			}
		}

		function resetQualifiers(items) {
			setQualifiers(items, items.qualifiers);
		}

		function getQualifierSelectorLabel(qualifiers) {
			var result;

			if ($.isArray(qualifiers) && qualifiers.length > 0) {
				result = $('<span>', {
				   "class" : "ui-icon ui-icon-circle-plus",
					title  : settings.moreQualifiersLabel
				});
			} else {
				result = $('<span>', {
				   "class" : 'subtext',
				    style  : 'color: gray; margin-left: 4px;'
				}).text('-- ' + settings.noQualifiersLabel + ' --').append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.clickToEditField
				}));
			}

			return result;
		}

		function addQualifier(items, selector, qualifiers, qualifier) {
			if (qualifier && qualifier.field && qualifier.field.id) {
				var qualiSpan = $('<span>', { "class" : 'qualifier', title : qualifier.field.description }).data('qualifier', qualifier);
				var valueSpan = $('<span>', { "class" : 'qualiValue' }).append(getOptionLabel(qualifier.value));

				qualiSpan.append((qualifier.field.label || qualifier.field.name) + ": ").append(valueSpan).append($('<a>', {
				   "class" : "removeQualifierLink",
					title  : settings.removeQualifierTitle
				}).click(function() {
					var qspan = $(this).closest('span.qualifier');
					var quali = qspan.data('qualifier');

					qspan.remove();

  					if ($.isArray(items.qualifiers) && items.qualifiers.length > 0) {
  						for (var i = 0; i < items.qualifiers.length; ++i) {
  							var check = items.qualifiers[i];
  							if (check && check.field && check.field.id === quali.field.id) {
  	 							items.qualifiers.splice(i, 1);
  	  							break;
  							}
  						}

  						if (items.qualifiers.length == 0) {
  							selector.empty().append(getQualifierSelectorLabel(items.qualifiers));
  						}
  					}
 				}).append($('<span>', {
					"class" : "ui-icon ui-icon-circle-close"
				})));

				qualifiers.append(qualiSpan);

				return valueSpan;
			}

			return null;
		}

		function setupTargetQualifiers(items, target) {
			target.hide().empty();

			var qualiFields = getQualifierFields(getTargetFields(items));
			if (qualiFields.length > 0) {
				var qualifiers = $('<span>', { "class" : 'qualifiers' });
				var selector   = $('<span>', { "class" : 'qualiSelect', title : settings.qualifiersTitle }).append(getQualifierSelectorLabel(items.qualifiers));

				if ($.isArray(items.qualifiers) && items.qualifiers.length > 0) {
					for (var i = 0; i < items.qualifiers.length; ++i) {
						addQualifier(items, selector, qualifiers, items.qualifiers[i]);
					}
				}

				target.append(qualifiers).append(selector).show();
			}
		}

		function selectQualifier(key, opt) {
        	var target = opt.$trigger.closest('span.itemQualifiers');
			var select = target.find('span.qualiSelect');
			var items  = target.closest('tr.items').data('item');

			if (key === '0') {
				delete items.qualifiers;

				target.find('span.qualifiers').empty();
				select.empty().append(getQualifierSelectorLabel(items.qualifiers));
			} else {
				var parts = key.split('-');
				var qualifier = {
					field : {
						id : parseInt(parts.splice(0, 1)[0])
					},
					value : null
				};

				if (qualifier.field = findQualifierField(getTargetFields(items), qualifier)) {
					key = parts.join('-');

					if (key === '-NEW-') {
						qualifier.value = createNewOption(qualifier.field.options, { name : '' });
					} else  {
						qualifier.value = findOptionByName(qualifier.field.options, key, false);
					}

					if (qualifier.value) {
						if (!$.isArray(items.qualifiers)) {
							items.qualifiers = [];
						}

						items.qualifiers.push(qualifier);
						addQualifier(items, select, target.find('span.qualifiers'), qualifier);

						if (items.qualifiers.length == 1) {
							select.empty().append(getQualifierSelectorLabel(items.qualifiers));
						}
					}
				}
			}
		}

		function buildQualifierMenu($trigger, event) {
        	var objType    = $trigger.closest('tr.items').data('item');
        	var fields     = getTargetFields(objType);
        	var qualifiers = objType.qualifiers;
        	var items      = {};

 			if (!$.isArray(qualifiers)) {
				qualifiers = [];
			}

 			items['0'] = {
 				name : '-- ' + settings.noQualifiersLabel  + ' --'
 			};

			if ($.isArray(fields) && fields.length > 0) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];
					if (field.id > 7 && field.type == 6) {
						var used = false;

						for (var j = 0; j < qualifiers.length; ++j) {
							var qualifier = qualifiers[j];
							if (qualifier && qualifier.field && qualifier.field.id === field.id) {
								used = true;
								break;
							}
						}

						if (!used) {
				 			items[field.id.toString()] = $.extend(buildQualifierValueMenu($trigger, event, { field : field }, field.id + '-', selectQualifier), {
			 	 				name : field.label || field.name
				 	 		});
						}
					}
				}
			}

			// New qualifier field would not have an id !!
			// selector.append($('<option>', { "class" : 'qualifier', value : '-NEW-' }).text('-- ' + settings.newFieldLabel + ' --'));

			return $.isEmptyObject(items) ? false : {
				name  		: '<label title="' + settings.qualifiersTitle + '">' + settings.qualifiersLabel + '</label>',
				isHtmlName	: true,
				items 		: items,
				callback	: selectQualifier
			};
		}

		function getTableFields(fields) {
			var result = [];

			if ($.isArray(fields) && fields.length > 0) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];
					if (field.id >= 1000000 && field.type == 12) {
						result.push(field);
					}
				}
			}

			return result;
		}

		function findTableField(fields, table) {
			if ($.isArray(fields) && fields.length > 0 && table && table.id >= 1000000) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];
					if (field.id === table.id) {
						return field.type == 12 ? field : null;
					}
				}
			}
			return null;
		}

		function setTable(items, table) {
			if (isMapped(items)) {
				table = findTableField(items.target.fields, table);
			} else {
				table = null;
			}

			if (items.table != table) {
				items.table = table;
				resetQualifiers(items);
				resetAttributes(items);
			}

			return table;
		}

		function resetTable(items) {
			setTable(items, items.table);
		}

		function getTableLabel(items) {
			var table  = items.table;
			var result = $('<label>', { "class" : 'inputTarget', style : 'font-weight: bold;' });

			if (table && table.id >= 1000000) {
				result.attr('title', table.description).text(table.label || table.name);
			} else {
				result.attr('title', settings.tableTitle).css('color', 'gray').text(items.target.type.name || settings.tableNone);
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.clickToEditField
			}));

			return result;
		}

		function setupTargetTable(items, target) {
			var tableSpan = null;

			target.hide().empty();

			if (isMapped(items)) {
				var tables = getTableFields(items.target.fields);
				if (tables.length > 0) {
					target.append($('<span>', { "class" : 'targetTable' }).append(getTableLabel(items))).show();
				}
			}

			return tableSpan;
		}

		function setTargetTable(key, opt) {
			var row   = opt.$trigger.closest('tr.items');
	        var items = row.data('item');

	        if (key === 'none') {
	        	delete items.table;
	        } else {
	        	items.table = findTableField(items.target.fields, { id : parseInt(key) });
	        }

			row.find('td.itemTarget > span.itemSubTable > span.targetTable').empty().append(getTableLabel(items));

			resetQualifiers(items);
			setupTargetQualifiers(items, row.find('td.itemTarget > span.itemQualifiers'));

			resetAttributes(items);
			resetItemAttributeTargets(row);
		}

		function buildTableMenu($trigger, event) {
        	var objType = $trigger.closest('tr.items').data('item');
			var table   = objType.table;
        	var fields  = getTableFields(objType.target.fields);
        	var tables  = {};

        	if (table && table.id >= 1000000) {
        		tables.none = {
            		name : objType.target.type.name || settings.tableNone
        		};
        	}

 			if ($.isArray(fields) && fields.length > 0) {
				for (var i = 0; i < fields.length; ++i) {
					var field = fields[i];

					if (field.id >= 1000000 && field.type == 12 && !(table && table.id === field.id)) {
						if (field.description && field.description.length > 0) {
							tables[field.id.toString()] = {
								name  		: '<label title="' + field.description + '">' + (field.label || field.name) + '</label>',
								isHtmlName	: true
							};
						} else {
							tables[field.id.toString()] = {
								name : field.label || field.name
							};
						}
					}
				}
			}

			return $.isEmptyObject(tables) ? false : {
				items    : tables,
				callback : setTargetTable
			};
		}

		function getTrackerSelector(trackers, selectedTracker) {
			var selector = $('<select>', { "class" : 'tracker', title : settings.selectTrackerTitle });

			if (!selectedTracker) {
				selector.append($('<option>', { "class" : 'tracker', value : null, style: 'color: gray; font-style: italic;' }).text(settings.selectTrackerLabel));
			}

			selector.append($('<option>', {
			   "class"	 : 'tracker',
				value	 : '-IGNORE-',
				title	 : settings.ignoreTrackerTitle,
				selected : selectedTracker && selectedTracker.name === '-IGNORE-'
			}).text("-- " + settings.ignoreTrackerLabel + " --").data("tracker", { name : '-IGNORE-' }));

			if ($.isArray(trackers)) {
				for (var i = 0; i < trackers.length; ++i) {
					var tracker = trackers[i];
					if (tracker && tracker.name) {
						selector.append($('<option>', {
						   "class"	 : 'tracker',
							value	 : tracker.name,
							title	 : tracker.description,
							selected : selectedTracker && selectedTracker.name === tracker.name
						}).text((tracker.label || tracker.name) + ' (' + tracker.type.name + ')').data("tracker", tracker));
					}
				}
			}

			selector.append($('<option>', { "class" : 'tracker', value : '-NEW-' }).text("-- " + settings.newTrackerLabel + " --"));

			return selector;
		}

		function getTrackerLabel(tracker) {
			var result = $('<span>', { "class" : 'subtext' });

			if (tracker != null) {
				if (tracker.name === '-IGNORE-') {
					result.css('color', 'gray').text('-- ' + settings.ignoreTrackerLabel + ' --');
				} else {
					result.css('margin-left', '6px').text('(' + tracker.type.name + ')');
					result = $('<label>', { "class" : 'trackerName', title : tracker.description }).text(tracker.label || tracker.name).append(result);
				}
			} else {
				result.css('color', 'red').text(settings.selectTrackerLabel);
			}

			result.append($('<img>', {
			   "class": 'inlineEdit',
				src   : contextPath + '/images/inlineEdit.png',
				title : settings.clickToEditTracker
			}));

			return result;
		}

		function getTargetTrackerLink() {
			return $("<a>", {
			   "class" : "trackerInfoLink",
				title  : settings.showTrackerTitle
			}).click(function() {
				var target = $(this).closest("td");
				var row    = target.closest('tr');
				var type   = row.hasClass('items') ? row.data('item') : row.data('specification');

				showTracker(type, target);
			}).append($('<span>', {
				"class" : "ui-icon ui-icon-info"
			}));
		}

		function setItemsTracker(items, tracker) {
			if ($.isArray(items) && items.length > 0) {
				for (var i = 0; i < items.length; ++i) {
					var item = items[i];

					if (item.target != tracker) {
						item.target = tracker;

						if (item.table && item.table.id > 0) {
							resetTable(item);
						} else {
							resetQualifiers(item);
							resetAttributes(item);
						}
					}
				}
			}
		}

		function setTracker(items, trackers, tracker) {
			if ($.isArray(trackers) && tracker && tracker.name) {
				tracker = createTrackerIfNotExists(trackers, tracker);

				if (items.target != tracker) {
					items.target = tracker;

					if (items.table && items.table.id > 0) {
						resetTable(items);
					} else {
						resetQualifiers(items);
						resetAttributes(items);
						setItemsTracker(items.items, tracker);
					}
				}
			}

			return tracker;
		}

		function changeTargetTracker(row, items, target, tracker) {
			resetTable(items);
			setupTargetTable(items, target.find('span.itemSubTable'));

			resetQualifiers(items);
			setupTargetQualifiers(items, target.find('span.itemQualifiers'));

			resetAttributes(items);
			resetItemAttributeTargets(row);
		}

		function resetTargetTracker() {
			var row    = $(this);
			var type   = row.hasClass('items') ? row.data('item') : row.data('specification');
			var target = row.find('span.trackerSection');

			if (type && target.length > 0) {
				target.find('span.targetTracker').empty().append(getTrackerLabel(type.target));

				var trackerLink = target.find('a.trackerInfoLink');
				if (!type.target || type.target.name === '-IGNORE-') {
					trackerLink.remove();
				} else if (trackerLink.length == 0) {
					target.append(getTargetTrackerLink());
				}
			}
		}

		function setTargetTracker(value) {
			var $this  = $(this);
			var target = $this.closest('td');
	        var row    = target.parent();
			var type   = row.hasClass('items') ? row.data('item') : row.data('specification');

			if (value === '-NEW-') {
				createNewTracker(type, target, function(tracker) {
					type.target = tracker;

					$this.html(setTargetTracker.apply($this, [tracker.name]));
				});
			} else {
				var rowId   = row.attr('data-tt-id');
				var tracker = type.target;

				if (row.hasClass('items')) {
					changeTargetTracker(row, type, target, tracker);
				} else {
					var start = row;
					var specType = row.next('tr.specTypes');
					if (specType.length > 0) {
						start = specType;
					}

					start.nextUntil(':not(tr.items,tr.attrib,tr.option)', 'tr.items[data-tt-parent-id="' + rowId + '"]').each(function() {
						var itemRow = $(this);
						var rowItems = itemRow.data('item');

						rowItems.target = tracker;

						changeTargetTracker(itemRow, rowItems, itemRow.find('td.itemTarget'), tracker);
					});
				}

				var trackerLink = $this.next('a.trackerInfoLink');
				if (!tracker || tracker.name === '-IGNORE-') {
					trackerLink.remove();
				} else if (trackerLink.length == 0) {
					getTargetTrackerLink().insertAfter($this);
				}

				if (settings.expand) {
					try {
						row.closest('table').treetable(tracker && tracker.name != '-IGNORE-' ? "expandNode" : "collapseNode", rowId);
					} catch(e) {
						alert(e.stack);
					}
				}
			}

			return getTrackerLabel(type.target)[0].outerHTML;
		}

		function setupTrackerTarget(items, target, trackers) {
			var trackerSpan = null;

			if (items.parent == null) {
				var tracker   = items.target;
				var targetDiv = $('<span>', { "class" : 'targetTracker' });
				trackerSpan   = $('<span>', { "class" : 'trackerSection' }).append(targetDiv);

				target.data('trackers', trackers);
				target.append(trackerSpan);

				targetDiv.append(getTrackerLabel(tracker));

				targetDiv.editable(setTargetTracker, {
			        type   : 'targetTracker',
			        event  : 'click',
			        onblur : 'cancel'
			    });

				if (tracker && tracker.name != '-IGNORE-') {
					trackerSpan.append(getTargetTrackerLink());
				}
			}

			return trackerSpan;
		}

		function setupItemTarget(items, target, trackers) {
			setupTrackerTarget(items, target, trackers);

			var subTable = $('<span>', { "class" : 'itemSubTable', style: 'margin-left: 6px; display: None;' });
			target.append(subTable);

			var qualifierSpan = $('<span>', { "class" : 'itemQualifiers', style: 'margin-left: 6px; display: None;' });
			target.append(qualifierSpan);

			setupTargetTable(items, subTable);
			setupTargetQualifiers(items, qualifierSpan);

			return target;
		}

		function resetItemTarget() {
			var row   = $(this);
			var items = row.data('item');

			if (items) {
				resetTargetTracker.apply(this);
				setupTargetTable(items, row.find('td.itemTarget > span.itemSubTable'));
				setupTargetQualifiers(items, row.find('td.itemTarget > span.itemQualifiers'));
			}
		}

		function changeItemsTracker(row, items, tracker) {
			items.target = createTrackerIfNotExists(target.trackers, tracker);

			var targetTracker = row.find('td.itemTarget > span.trackerSection > span.targetTracker');
			if (targetTracker.length > 0) {
				targetTracker.html(setTargetTracker.apply(targetTracker[0], [tracker.name]));
			}
		}

		function ignoreItems(key, options) {
  	  		var parent = options.$trigger.closest('tr');
  	  	 	var ignore = { name : '-IGNORE-' };

			if (key.indexOf('ignore_') == 0) {
				key = key.substring(7);
			}

   	  		parent.closest('tbody').find('tr.items[data-tt-parent-id="' + parent.attr('data-tt-id') + '"]').each(function() {
				var row   = $(this);
				var items = row.data('item');

				if (key === 'Rest_') {
					if (!items.target) {
						changeItemsTracker(row, items, ignore);
					}
				} else if (items.name.indexOf(key) == 0) {
					changeItemsTracker(row, items, ignore);
				}
			});
		}

   	  	function assignItems(key, options) {
   	  		var parent = options.$trigger.closest('tr');

   	  		parent.closest('tbody').find('tr.items[data-tt-parent-id="' + parent.attr('data-tt-id') + '"]').each(function() {
				var row    	= $(this);
				var items   = row.data('item');
				var tracker = items.target;

				if (key === 'autoMapRest') {
					if (!tracker) {
						changeItemsTracker(row, items, { name : items.name });
					}
				} else if (key === '-ALL-' || items.name.indexOf(key) == 0) {
					if (!tracker || tracker.name === '-IGNORE-') {
						changeItemsTracker(row, items, { name : items.name });
					}
				}
			});
   	  	}

		function getNamePrefixes(objects) {
			var prefix = [];

			if ($.isArray(objects) && objects.length > 1) {
				var trie = {};

				for (var i = 0; i < objects.length; ++i) {
					addToTrie(trie, objects[i].name);
				}

				optimizeTrie(trie);
				prefixesTrie(trie, "", prefix);
			}

			return prefix.sort();
		}

   	  	function getAssignItemsMenu(items) {
        	return buildPrefixesMenu({
	    		autoMapRest : {
					name : settings.unmappedItems
	    		}
        	}, '', getNamePrefixes(items), assignItems);
		}

		function getIgnoreItemsMenu(items) {
        	return buildPrefixesMenu({
				ignore_Rest_ : {
					name : settings.unmappedItems
				}
        	}, 'ignore_', getNamePrefixes(items), ignoreItems);
		}

		function changeSpecificationTracker(row, specification, tracker) {
			specification.target = createTrackerIfNotExists(target.trackers, tracker);

			var targetTracker = row.find('td.specificationTarget > span.trackerSection > span.targetTracker');
			if (targetTracker.length > 0) {
				targetTracker.html(setTargetTracker.apply(targetTracker[0], [tracker.name]));
			}
		}

		function ignoreSpecifications(key, options) {
			var ignore = { name : '-IGNORE-' };

			if (key.indexOf('ignore_') == 0) {
				key = key.substring(7);
			}

			options.$trigger.closest('tbody').find('tr.specifications').each(function() {
				var row           = $(this);
				var specification = row.data('specification');

				if (key === 'Rest_') {
					if (!specification.target) {
						changeSpecificationTracker(row, specification, ignore);
					}
				} else if (specification.name.indexOf(key) == 0) {
					changeSpecificationTracker(row, specification, ignore);
				}
			});
		}

		function getIgnoreSpecificationsMenu(specifications) {
        	return buildPrefixesMenu({
				ignore_Rest_ : {
					name : settings.unmappedSpecifications
				}
        	}, 'ignore_', getNamePrefixes(specifications), ignoreSpecifications);
		}

   	  	function assignSpecifications(key, options) {
			options.$trigger.closest('tbody').find('tr.specifications').each(function() {
				var row    		  = $(this);
				var specification = row.data('specification');
				var tracker  	  = specification.target;

				if (key === 'autoMapRest') {
					if (!tracker) {
						changeSpecificationTracker(row, specification, { name : specification.name });
					}
				} else if (key === '-ALL-' || specification.name.indexOf(key) == 0) {
					if (!tracker || tracker.name === '-IGNORE-') {
						changeSpecificationTracker(row, specification, { name : specification.name });
					}
				}
			});
   	  	}

   	  	function getAssignSpecificationsMenu(specifications) {
        	return buildPrefixesMenu({
	    		autoMapRest : {
					name : settings.unmappedSpecifications
	    		}
        	}, '', getNamePrefixes(specifications), assignSpecifications);
		}

   	  	function getIgnoreAllMenu($trigger) {
   	  		var row = $trigger.closest('tr');

   	  		if (row.hasClass('itemCategory')) {
   	   	  		return getIgnoreItemsMenu(row.data('items'));
   	  		} else if (row.hasClass('specificationCategory')) {
   	   	  		return getIgnoreSpecificationsMenu(row.data('specifications'));
   	  		}

   	  		return getIgnoreAttributesMenu(row);
   	  	}

   	  	function getAssignAllMenu($trigger) {
   	  		var row = $trigger.closest('tr');

   	  		if (row.hasClass('itemCategory')) {
	   	  		return getAssignItemsMenu(row.data('items'));
	  		} else if (row.hasClass('specificationCategory')) {
   	   	  		return getAssignSpecificationsMenu(row.data('specifications'));
   	  		}

   	  		return getAssignAttributesMenu(row);
   	  	}

   	  	function positionMenu(opt) {
			opt.$menu.position({
				my  : "left top",
				at  : "left top+2",
			   "of" :  $(this).closest('span')
			});
		}

		function setup() {
			/* Define an inplace editor for the ReqIF data source */
		    $.editable.addInputType('source', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		           	var selector = getSourceSelector().change(function() {
		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });

			/* Define an inplace editor for choice field option targets  */
		    $.editable.addInputType('optionTarget', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var option   = $(self).closest('tr.option').data('option');
		           	var selector = getTargetOptionSelector(getTargetOptions(option.attrib), option.target ? option.target.name : null).change(function() {
		           		if (this.value != '-NEW-') {
		           			option.target = selector.find('option:selected').data('option');
		           		}

		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	},

		     	plugin : function(settings, original) {
		     		var form     = $(this);
	     			var selector = form.find('select.option');

	     			// Try to open the select dropdown list automatically
//		     		setTimeout(function() {
//		     			if (selector.length > 0) {
//			     			var event = document.createEvent('MouseEvents');
//			     			event.initMouseEvent('mousedown', true, true, window);
//
//			     			selector.get(0).dispatchEvent(event);
//		     			} else {
//		     				alert('Cannot click on selector');
//		     			}
//		     		}, 200);
		     	}
		    });

			/* Define an inplace editor for attribute target fields */
		    $.editable.addInputType('attributeTarget', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var attrib   = $(self).closest('tr.attrib').data('attrib');
		           	var selector = getTargetFieldSelector(attrib, getTargetFields(attrib.parent), attrib.target).change(function() {
		           		if (this.value != '-NEW-') {
		           			attrib.target = selector.find('option.field:selected').data('field');
		           		}

		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });


			/* Define an inplace editor for specification/item target trackers */
		    $.editable.addInputType('targetTracker', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var target   = $(self).closest('td');
		        	var trackers = target.data('trackers');
		        	var row      = target.parent();
					var type     = row.hasClass('items') ? row.data('item') : row.data('specification');
		           	var selector = getTrackerSelector(trackers, type.target).change(function() {
		           		if (this.value != '-NEW-') {
		           			type.target = selector.find('option.tracker:selected').data('tracker');
		           		}

		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });

		    $.contextMenu({
				selector : "span.targetTable",
				trigger  : "left",
				position : positionMenu,
				build    : buildTableMenu
			});

		    $.contextMenu({
				selector : "span.qualiValue",
				trigger  : "left",
				position : positionMenu,
				build    : buildQualifierValueMenu
			});

		    $.contextMenu({
				selector : "span.qualiSelect",
				trigger  : "left",
				position : positionMenu,
				build    : buildQualifierMenu
			});

		    $.contextMenu({
				selector : "span.referenceField > span.field",
				trigger  : "left",
				position : positionMenu,
				build    : buildReferenceFieldMenu
			});

		    $.contextMenu({
				selector : "span.relationTargetSelector",
				trigger  : "left",
				position : positionMenu,
				build    : buildRelationTargetMenu
			});

		    $.contextMenu({
				selector : ".ignore-all",
				trigger  : "left",
				position : positionMenu,
				build    : getIgnoreAllMenu
			});

		    $.contextMenu({
				selector : ".assign-all",
				trigger  : "left",
				position : positionMenu,
				build    : getAssignAllMenu
			});
		}

		function buildAttrMap(item) {
			item.attrsPerName = {};

			if ($.isArray(item.fields)) {
				for (var j = 0; j < item.fields.length; ++j) {
					var attrib = item.fields[j];
					if (attrib && attrib.name) {
						item.attrsPerName[attrib.name] = attrib;

						attrib.optionsPerName = {};

						if ($.isArray(attrib.options)) {
							for (var k = 0; k < attrib.options.length; ++k) {
								var option = attrib.options[k];
								if (option && option.name) {
									attrib.optionsPerName[option.name] = option;
								}
							}
						}
					}
				}
			}
		}

		function clearAttrMap(item) {
			delete item.attrsPerName;

			if ($.isArray(item.fields)) {
				for (var j = 0; j < item.fields.length; ++j) {
					var attrib = item.fields[j];
					if (attrib && attrib.name) {
						delete attrib.optionsPerName;
					}
				}
			}
		}

		function buildLookupMap(items) {
			var result = {};

			for (var i = 0; i < items.length; ++i) {
				var item = items[i];
				if (item && item.name) {
					result[item.name] = item;

					buildAttrMap(item);
				}
			}

			return result;
		}

		function clearLookupMap(items) {
			for (var i = 0; i < items.length; ++i) {
				var item = items[i];
				if (item && item.name) {
					clearAttrMap(item);
				}
			}
		}

		function setupAttributes(parent, type, nodeId, target) {
			var attribs = parent.fields;

			if ($.isArray(attribs) && attribs.length > 0) {
				if (type == 'relation') {
					parent = target.specRelationTracker;
				} else if (type == 'specType' || type == 'specification') {
					parent = target.specTypeTracker;
				}

				for (var i = 0; i < attribs.length; ++i) {
					var attrib  = attribs[i];
					var options = attrib.options;

					attrib.id     = ++nodeId;
					attrib.parent = (attrib.table ? target.doorsTables : parent);

					if ($.isArray(options) && options.length > 0) {
						for (var j = 0; j < options.length; ++j) {
							var option = options[j];

							option.id = ++nodeId;
							option.attrib = attrib;
						}
					}

					if (isMapped(attrib.parent)) {
						resetAttribute(attrib, true);
					}
				}
			}

			return nodeId;
		}

		function setupSpecObjType(tbody, typeId, items, nodeId, target) {
			if (items.target = createTrackerIfNotExists(target.trackers, items.target)) {
				items.table = findTableField(items.target.fields, items.table);
			} else {
				items.table = null;
			}

		    resetQualifiers(items);

		    return setupAttributes(items, "item", nodeId, target);
		}

		function setupSpecification(tbody, specId, specification, nodeId, target) {
			specification.target = createTrackerIfNotExists(target.trackers, specification.target);

			if (specification.type) {
				nodeId = setupMapping(tbody, [specification.type], "specType", settings.specTypesLabel, nodeId, target, false, specId);
			}

			if ($.isArray(specification.items) && specification.items.length > 0) {
				for (var i = 0; i < specification.items.length; ++i) {
					specification.items[i].parent = specification;
					specification.items[i].target = specification.target;
				}

				nodeId = setupMapping(tbody, specification.items, "item", settings.itemsLabel, nodeId, target, false, specId);
			}

			return nodeId;
		}

		function setupMapping(tbody, items, type, title, nodeId, target, showCategory, parentId) {
			if ($.isArray(items) && items.length > 0) {
				var categoryId  = parentId;
				var categoryRow = null;
				var categoryEmpty = true;

				if (showCategory) {
					categoryId  = ++nodeId;
					categoryRow = $('<tr>', { "class" : type + 'Category even', "data-tt-id" : categoryId }).data(type + 's', items);

					var categoryName = $('<td>', { "class" : 'categoryName', style: 'width: 30%;' }).text(title);

					categoryRow.append(categoryName);
					categoryRow.append($('<td>', { "class" : 'numberData', style : 'width: 2em;' }).text(items.length));
					categoryRow.append($('<td>', { "class" : 'textData' }));
					tbody.append(categoryRow);

					if (parentId) {
						categoryRow.attr("data-tt-parent-id", parentId);
					}

					if ((type == 'item' || type == 'specification') && items.length > 1) {
						categoryName.append(createAssignIgnoreAllControls(type + 'Controls'));
					}
				}

				for (var i = 0; i < items.length; ++i) {
					var item = items[i];
					var itemId = ++nodeId;
					var itemRow = $('<tr>', { "class" : type + 's even', "data-tt-id" : itemId, "data-tt-parent-id" : categoryId }).data(type, item);
					var itemName = $('<td>', { "class" : type + 'Name', title : item.description, style: 'width: 30%;' }).text(item.label || item.name)
					var itemCount = $('<td>', { "class" : 'numberData', style : 'width: 2em;' }).text(item.count);
					var itemTarget = $('<td>', { "class" : type + 'Target' });

					var attribs = item.fields;
					if ($.isArray(attribs) && attribs.length > 0) {
						var attribInset  = '2em;';
						var optionInset  = '4em;';

						if (type == 'specType' && showCategory) {
							attribInset = '4px;';
							optionInset = '2em;';
						}

						itemRow.addClass('unloaded').attr({
							"data-tt-branch"    : true,
							"data-attrib-inset" : attribInset,
							"data-option-inset" : optionInset
						});
					}


					if (item.count > 0) {
						categoryEmpty = false;
					} else {
						itemRow.addClass('empty');
					}

					itemRow.append(itemName);
					itemRow.append(itemCount);
					itemRow.append(itemTarget);

					tbody.append(itemRow);

					if (type == 'specification') {
						itemRow.data('reset', resetTargetTracker);
						nodeId = setupSpecification(tbody, itemId, item, nodeId, target);
						setupTrackerTarget(item, itemTarget, target.trackers);

					} else if (type == 'specType') {
						nodeId = setupAttributes(item, type, nodeId, target);

					} else if (type == 'item') {
						itemRow.data('reset', resetItemTarget);
						nodeId = setupSpecObjType(tbody, itemId, item, nodeId, target);
						setupItemTarget(item, itemTarget, target.trackers);

					} else if (type == 'relation') {
						itemRow.data('reset', resetRelationTarget);
						nodeId = setupAttributes(item, type, nodeId, target);
						setupRelationTarget(item, itemTarget);
					}
				}

				if (showCategory && categoryEmpty) {
					categoryRow.addClass('empty');
				}
			}

			return nodeId;
		}

		function setTrackerItems(items, mapping) {
			if ($.isPlainObject(mapping)) {
				setTable(items, mapping.table);
				setQualifiers(items, mapping.qualifiers);
				setAttributes(items, mapping.attrsPerName);
			}
		}

		function setItem(item, trackers, mapping) {
			if ($.isPlainObject(mapping)) {
				setTracker(item, trackers, mapping.target);
				setTrackerItems(item, mapping);
			}
		}

		function setItems(items, trackers, mapping) {
			if ($.isArray(items) && items.length > 0 && $.isArray(mapping) && mapping.length > 0) {
				var itemsPerName = buildLookupMap(mapping);

				for (var i = 0; i < items.length; ++i) {
					var item = items[i];

					setItem(item, trackers, itemsPerName[item.name]);
				}

				clearLookupMap(mapping);
			}
		}

		function setRelation(relation, mapping) {
			if ($.isPlainObject(mapping)) {
				if (relation.target = findAssocType(mapping.target)) {
					delete relation.referenceFields;
				} else if ($.isPlainObject(mapping.referenceFields)) {
					relation.referenceFields = {};

					for (var typeId in mapping.referenceFields) {
						var field = mapping.referenceFields[typeId];
						var refFld = findReferenceField(parseInt(typeId), field);
						if (refFld) {
							relation.referenceFields[typeId] = refFld.field;
						}
					}
				} else {
					delete relation.referenceFields;
				}

				setAttributes(relation, mapping.attrsPerName);
			}
		}

		function setRelations(relations , mapping) {
			if ($.isArray(relations) && relations.length > 0 && $.isArray(mapping) && mapping.length > 0) {
				var relPerName = buildLookupMap(mapping);

				for (var i = 0; i < relations.length; ++i) {
					var relation = relations[i];

					setRelation(relation, relPerName[relation.name]);
				}

				clearLookupMap(mapping);
			}
		}

		function setSpecType(specType, mapping) {
			if ($.isPlainObject(mapping)) {
				setAttributes(specType, mapping.attrsPerName);
			}
		}

		function setSpecTypes(specTypes, mapping) {
			if ($.isArray(specTypes) && specTypes.length > 0 && $.isArray(mapping) && mapping.length > 0) {
				var typePerName = buildLookupMap(mapping);

				for (var i = 0; i < specTypes.length; ++i) {
					var specType = specTypes[i];

					setSpecType(specType, typePerName[specType.name]);
				}

				clearLookupMap(mapping);
			}
		}

		function setSpecification(specification, trackers, mapping) {
			if ($.isPlainObject(mapping)) {
				var tracker = setTracker(specification, trackers, mapping.target);

				if (specification.type && $.isPlainObject(mapping.type)) {
					buildAttrMap(mapping.type);
					setSpecType(specification.type, mapping.type);
					clearAttrMap(mapping.type);
				}

				setItems(specification.items, trackers, mapping.items);
			}
		}

		function setSpecifications(specifications, trackers, mapping) {
			if ($.isArray(specifications) && specifications.length > 0 && $.isArray(mapping) && mapping.length > 0) {
				var specsPerName = buildLookupMap(mapping);

				for (var i = 0; i < specifications.length; ++i) {
					var specification = specifications[i];

					setSpecification(specification, trackers, specsPerName[specification.name]);
				}

				clearLookupMap(mapping);
			}
		}

		function setMapping(container, target, mapping) {
			if ($.isPlainObject(mapping)) {
				var table = $('table.importConfiguration', container);
				var input = table.data('input');

				setItems(input.items, target.trackers, mapping.items);
				setRelations(input.relations, mapping.relations);
				setSpecTypes(input.specificationTypes, mapping.specificationTypes);
				setSpecifications(input.specifications, target.trackers, mapping.specifications);

				table.find('tbody > tr').each(resetTarget);
			}
		}

		function isEmptyArray(array) {
			if ($.isArray(array) && array.length > 0) {
				for (var i = 0; i < array.length; ++i) {
					var item = array[i];

					if ($.isPlainObject(item) && item.count > 0) {
						return false;
					}
				}
			}

			return true;
		}

		function isEmpty(input) {
			if ($.isPlainObject(input)) {
				return isEmptyArray(input.items) && isEmptyArray(input.specifications);
				// without tracker items, there are also no valid associations
			}

			return true;
		}

		function saveAsFile(link, container, fileName) {
			var data = container.getImportConfiguration();
			var blob = new Blob([JSON.stringify(data, undefined, 4)], { type : 'application/json' });

			if (window.navigator.msSaveBlob) {
				window.navigator.msSaveBlob(blob, fileName);
			} else if (window.webkitURL != null) {
				link.href = window.webkitURL.createObjectURL(blob);
			} else {
				link.href = window.URL.createObjectURL(blob);
			}
		}

		function showHideEmptyAttribs(tbody, showEmpty, showIgnored) {
			tbody.find('tr.attrib').each(function() {
				var attRow = $(this);
				var attrib = attRow.data('attrib');

				if ((showEmpty || attrib.count > 0) /*&& (showIgnored || !attrib.target || attrib.target.id != -1)*/) {
					attRow.show();
				} else {
					if (attRow.hasClass('expanded')) {
						tbody.parent().treetable("collapseNode", attRow.attr('data-tt-id'));
					}
					attRow.hide();
				}
			});
		}

		function showHideEmptyRows(table, tbody, rows, showEmpty, children) {
			tbody.find(rows).each(function() {
				var row  = $(this);
				var ttid = row.attr('data-tt-id');

				if (row.hasClass('empty')) {
					if (showEmpty) {
						row.show();

						if (children) {
							table.treetable("expandNode", ttid);
						}
					} else {
						if (row.hasClass('expanded')) {
							table.treetable("collapseNode", ttid);
						}
						row.hide();
					}
				} else if (children && row.hasClass('expanded')) {
					if (row.hasClass('specificationCategory')) {
						showHideEmptyRows(table, tbody, 'tr.specifications.empty[data-tt-parent-id="' + ttid + '"]', showEmpty, false);

					} else if (row.hasClass('itemCategory')) {
						showHideEmptyRows(table, tbody, 'tr.items.empty[data-tt-parent-id="' + ttid + '"]', showEmpty, false);

					} else if (row.hasClass('specTypeCategory')) {
						showHideEmptyRows(table, tbody, 'tr.specTypes.empty[data-tt-parent-id="' + ttid + '"]', showEmpty, false);

					} else if (row.hasClass('relationCategory')) {
						showHideEmptyRows(table, tbody, 'tr.relations.empty[data-tt-parent-id="' + ttid + '"]', showEmpty, false);
					}
				}
			});
		}

		function init(container, input, target) {
			container.helpLink(settings.help);

			if ($("body").hasClass("IE8") || $("body").hasClass("IE9") || $("body").hasClass("IE10")) {
				container.append($('<h4>').append(settings.noSupport));
			} else {
				var fileSelector = $('<input>', { type : 'file', style : 'position: fixed; top: -300px;' }).change(function(event) {
					var file = event.target.files[0];
					var reader = new FileReader();

					reader.onload = function(event) {
						var text = event.target.result;
						setMapping(container, target, $.parseJSON(text));
					};

					reader.readAsText(file, "UTF-8");
				});

				container.append(fileSelector);

				var fileName = input.name + '.json';
				var save = $('<a>', { href : '#', download : fileName }).text(settings.saveLabel).click(function(event) {
					saveAsFile(event.target, container, fileName);
				});

				var load = $('<a>', { href : '#' }).text(settings.loadLabel).click(function() {
					fileSelector.click();
					return false;
				});

				var parts = settings.intro.split(/<\w*>/);
				container.append($('<h4>').append(parts[0]).append(save).append(parts[1]).append(load).append(parts[2]));
			}

			if ($.isPlainObject(settings.source)) {
				var sourceTable = $('<table>', { "class" : 'reqIFSource formTableWithSpacing', style : 'margin-bottom: 1em;' });
				var sourceRow   = $('<tr>', { style: 'vertical-align: middle;'});
				var sourceLabel = $('<td>', { "class" : 'labelCell mandatory', title : settings.source.title, style : 'padding-left: 34px !important;' }).text(settings.source.label + ':');
				var sourceCell  = $('<td>', { "class" : 'reqIFSource dataCell dataCellContainsSelectbox' });

				sourceCell.append(getSourceLabel(target.source));
				sourceCell.editable(setSource, {
			        type   : 'source',
			        event  : 'click',
			        onblur : 'cancel'
			    });

				sourceRow.append(sourceLabel);
				sourceRow.append(sourceCell);
				sourceTable.append(sourceRow);
				container.append(sourceTable);
			}

			var table = $('<table>', { id : 'importConfigTable', "class" : 'displaytag importConfiguration', style : 'width: 98%' }).data('input', input).data('target', target);
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var emptyToggle = $('<input>', { name : 'emptyInputToggle', id : 'emptyInputToggle', type : 'checkbox', title : settings.toggleTitle });
			var emptyLabel = $('<label>', { "for" : 'emptyInputToggle', title : settings.toggleTitle }).text(settings.toggleLabel);

			var headline = $('<tr>',  { "class" : 'head', style: 'vertical-align: middle;' });
			headline.append($('<th>', { "class" : 'textData', style: 'padding-left: 20px !important; vertical-align: middle; width: 40%;' }).append("  ").append(settings.inputLabel).append("&nbsp;&nbsp; (").append(emptyToggle).append(emptyLabel).append(")"));
			headline.append($('<th>', { "class" : 'numberData', style : 'width: 2em;' }).text(settings.countLabel));
			headline.append($('<th>', { "class" : 'textData' }).text(settings.targetLabel));

			header.append(headline);

			var tbody = $('<tbody>');
			table.append(tbody);

			if ($.isArray(target.trackers)) {
				target.trackers.sort(function(a, b) {
					var name1 = a.label || a.name || 'zzz';
					var name2 = b.label || b.name || 'zzz';

					return name1.localeCompare(name2);
				});
			}

			target.doorsTables = {
				target : {
					name   : "DOORS Tables",
					fields : settings.tableFields
				}
			};

			target.specTypeTracker = {
				target : {
					fields : settings.specificationFields
				}
			};

			target.specRelationTracker = {
				target : {
					fields : settings.relationFields
				}
			};


			var nodeId = 0;
			nodeId = setupMapping(tbody, input.specifications, 		"specification", settings.specificationsLabel, nodeId, target, true);
			nodeId = setupMapping(tbody, input.items, 				"item", 		 settings.itemsLabel, 		   nodeId, target, true);
			nodeId = setupMapping(tbody, input.relations, 			"relation", 	 settings.relationsLabel, 	   nodeId, target, true);
			nodeId = setupMapping(tbody, input.specificationTypes,  "specType", 	 settings.specTypesLabel, 	   nodeId, target, true);

			table.treetable({
				expandable   : true,
				initialState : 'collapsed',

				onNodeExpand : function() {
					var node = this;
					var row  = this.row;

					if (row.hasClass('unloaded')) {
						row.removeClass('unloaded');

						if (row.hasClass('attrib')) {
							setupOptionMapping(node, row, 'attrib');
						} else if (row.hasClass('specTypes')) {
							setupAttribMapping(node, row, 'specType');
						} else if (row.hasClass('items')) {
							setupAttribMapping(node, row, 'item');
						} else if (row.hasClass('relations')) {
							setupAttribMapping(node, row, 'relation');
						}
					}

					if (!emptyToggle.is(':checked')) {
						var filter = null;

						if (row.hasClass('items') || row.hasClass('specTypes') || row.hasClass('relations')) {
							filter = function() {
								showHideEmptyItemAttributes(row, false);
							};
						} else if (row.hasClass('specificationCategory')) {
							filter = function() {
								showHideEmptyRows(table, tbody, 'tr.specifications.empty[data-tt-parent-id="' + node.id + '"]', false, false);
							};
						} else if (row.hasClass('itemCategory')) {
							filter = function() {
								showHideEmptyRows(table, tbody, 'tr.items.empty[data-tt-parent-id="' + node.id + '"]', false, false);
							};
						} else if (row.hasClass('specTypeCategory')) {
							filter = function() {
								showHideEmptyRows(table, tbody, 'tr.specTypes.empty[data-tt-parent-id="' + node.id + '"]', false, false);
							};
						} else if (row.hasClass('relationCategory')) {
							filter = function() {
								showHideEmptyRows(table, tbody, 'tr.relations.empty[data-tt-parent-id="' + node.id + '"]', false, false);
							};
						}

						if (filter) {
							setTimeout(filter, 10);
						}
					}
				},

				onNodeCollapse : function() {
					var node = this;
					var row  = this.row;

					if (row.hasClass('attrib') || row.hasClass('specTypes') || row.hasClass('items') || row.hasClass('relations')) {
						table.treetable("unloadBranch", node);
						row.addClass('unloaded');
					}
				}
			});

//			showHideEmptyAttribs(tbody, false, false);

			emptyToggle.click(function() {
				var showEmpty = emptyToggle.is(':checked');
				showHideEmptyAttribs(tbody, showEmpty);
				showHideEmptyRows(table, tbody, 'tr.itemCategory, tr.relationCategory, tr.specTypeCategory, tr.specificationCategory', showEmpty, true);
			});

			setTimeout(function() {
				tbody.find('tr.itemCategory, tr.relationCategory, tr.specTypeCategory, tr.specificationCategory').each(function() {
					var row = $(this);
					if (row.hasClass('empty')) {
						row.hide();
					} else {
						table.treetable("expandNode", row.attr('data-tt-id'));
					}
				});
			}, 100);

			settings.expand = true;

			if (isEmpty(input)) {
				showFancyConfirmDialogWithCallbacks(settings.emptyConfirm, function() {
					emptyToggle.click();
					assignSpecifications('-ALL-', { $trigger : tbody });

					var itemCategory = tbody.find('tr.itemCategory');
					if (itemCategory.length > 0) {
						assignItems('-ALL-', { $trigger : itemCategory });
					}
				});
			}

			popup = $('<div>', { id : "trackerConfigPopup", style: 'display: None;' });
			container.append(popup);
		}

		if ($.fn.importConfiguration._setup) {
			$.fn.importConfiguration._setup = false;
			setup();
		}

		return this.each(function() {
			$(this).empty();
			init($(this), input, target);
		});
	};

	$.fn.importConfiguration._setup = true;

	$.fn.importConfiguration.defaults = {
		help		: {
			title	: '"Requirements Interchange Format (ReqIF)" in the codeBeamer Knowledge Base',
			URL		: 'https://codebeamer.com/cb/wiki/639415'
		},
		typeName			   : ["Text", "Integer", "Decimal", "Date", "Boolean", "Member", "Choice", "References", "Language", "Country", "RichText", "Duration", "Table", "Color"],
		assocTypes			   : [{id : 1, name : 'depends'}, {id : 2, name : 'parent'}, {id : 3, name : 'child'}, {id : 4, name : 'related'}, {id : 5, name : 'derived'}, {id : 6, name : 'violates'}, {id : 7, name : 'excludes'}, {id : 8, name : 'invalidates'}, {id : 9, name : 'copy of'} ],
		relationFields		   : [{name : 'description', label : 'Description', type : 10}, {name : 'propagatingSuspects', label : 'Propagate suspects', type : 4}, {name : 'suspected', label : 'Suspected', type : 4}],
		specificationFields	   : [{name : 'name', label : 'Name', type : 0}, {name : 'description', label : 'Description', type : 10}, {name : 'keyName', label : 'Prefix', type : 0}],
		defaultAttributeMapping : {
			"ReqIF.Name"	   		: 3,
			"ReqIF.ChapterName"		: 3,
			"ReqIF.Text"	   		: 80,
			"ReqIF.Description"		: 80,
			"ReqIF.ForeignDeleted"	: 85
		},
		tableMapping		   : {
			TableType		   : 9888,
			TableTopBorder	   : 9881,
			TableBottomBorder  : 9882,
			TableLeftBorder	   : 9883,
			TableRightBorder   : 9884,
			TableCellAlign     : 9889,
			TableCellWidth     : 13009
		},
		intro				   : 'Please specify the mapping of input data to target project trackers, fields and choice options. You can also <Save> your final mapping or <Load> a previously saved mapping.',
		saveLabel			   : 'Save...',
		loadLabel			   : 'Load...',
		inputLabel			   : 'Input',
		toggleLabel			   : 'including empty',
		toggleTitle			   : 'Whether to show or hide empty input specifications, item types, relations and attributes',
		emptyConfirm		   : 'The ReqIF archive to import does not contain Specifications and Item Types or they are empty ! Do you want to import empty Specifications and Item Types ?',
		targetLabel			   : 'Target',
		countLabel			   : 'Count',
		valuesLabel			   : 'First 10 distinct values',
		itemsLabel			   : 'Item Types',
		unmappedItems		   : 'Item Types not mapped yet',
		relationsLabel		   : 'Relation Types',
		specTypesLabel	   	   : 'Specification Types',
		specificationsLabel	   : 'Specifications',
		unmappedSpecifications : 'Specifications not mapped yet',
		selectTrackerLabel	   : 'Please select',
		selectTrackerTitle	   : 'You must either choose a predefined target tracker, or right click, to define a new tracker',
		clickToEditTracker	   : '(Double) Click, to choose a predefined tracker, or to define a new tracker',
		ignoreTrackerLabel	   : 'Ignore',
		ignoreTrackerTitle	   : 'Ignore this type of items',
		newTrackerLabel		   : 'New Tracker',
		newTrackerTitle		   : 'Create a new target Tracker',
		showTrackerLabel	   : 'Properties',
		showTrackerTitle	   : 'Target Tracker Properties',
		typeLabel			   : 'Type',
		typeTooltip			   : 'The type of the new tracker',
		nameLabel			   : 'Name',
		nameTooltip			   : 'The name of the new tracker (required)',
		nameMissing			   : 'The tracker name is missing',
		nameExisting		   : 'There is already a tracker with the specified name',
		keyNameLabel		   : 'Key Name',
		keyNameTooltip		   : 'Key (short name)',
		keyNameMissing		   : 'The tracker key/short name is missing',
		descriptionLabel	   : 'Description',
		descriptionTooltip	   : 'Optional tracker description',
		tableLabel			   : 'Table',
		tableTitle			   : 'Optional: Choose an embedded table of the target tracker, in order to map input items to embedded table rows instead of main tracker items',
		tableNone			   : 'Items',
		qualifiersLabel		   : 'Qualifiers',
		qualifiersTitle		   : 'Optional qualifiers, to identify a subset of items in the (embedded table of the) target tracker',
		noQualifiersLabel	   : 'No qualifiers',
		moreQualifiersLabel	   : 'More qualifiers',
		removeQualifierTitle   : 'Remove this qualifier',
		selectFieldLabel	   : 'Please select',
		selectFieldTitle	   : 'You must either choose a predefined field, or define a new field',
		clickToEditField	   : '(Double) Click, to choose a predefined field, or to define a new field',
		unmappedAttributes	   : 'Attributes not mapped yet',
		ignoreFieldLabel	   : 'Ignore field',
		ignoreFieldTitle	   : 'The field value will be ignored (not imported)!',
		ignoreAttrLabel		   : 'Ignore all',
		showIgnoredLabel	   : 'including ignored',
		showIgnoredTitle	   : 'Whether to show or hide ignored attributes',
		autoMapAttrLabel	   : 'Assign all',
		newFieldLabel		   : 'New Field',
		fieldNameTitle		   : 'The name of the new field (required)',
		duplicateFieldName	   : 'A field with the specified name already exists !',
		reservedFieldName	   : 'The specified field name is a reserved name. Please choose another name !',
		selectValueLabel	   : 'Please select',
		selectValueTitle	   : 'You must either choose a predefined value, or define a new value',
		clickToEditValue	   : '(Double) Click, to choose a predefined value, or to define a new value',
		newValueLabel	   	   : 'New Value',
		valueNameTitle 		   : 'Please enter the name of the new value',
		duplicateValueName	   : 'A value with the specified name already exists !',
		createSimilarValue	   : 'A value with a name, that only differs in case, already exists ! Create the new value anyway ?',
		assignUnmappedOptions  : 'Automatically assign all unmapped values to matching or new target values',
		removeLabel			   : 'Remove',
		selectRelationTitle	   : 'Please choose, whether this type of relations should be ignored, mapped to a predefined association type, or mapped to predefined reference fields',
		ignoreRelationLabel	   : 'Ignore',
		ignoreRelationTitle	   : 'This type of relations should be ignored',
		associationLabel	   : 'Associations',
		associationTitle	   : 'This type of relations should be mapped to a predefined type of associations',
		referenceLabel	   	   : 'References',
		referenceTitle		   : 'This type of relations should be mapped to predefined reference fields',
		selectAssocTypeTitle   : 'Please choose, whether this type of relations should be mapped to a predefined association type, or not',
		noAssocTypeLabel	   : 'No Association',
		noAssocTypeTitle   	   : 'This type of relation will not be mapped to an association type',
		inlineEditHint		   : 'Double click, to change prefix and/or suffix',
		referenceFieldsLabel   : 'and/or',
		referenceFieldsTitle   : 'You can choose one or more reference fields, to bind this type of relations to',
		noReferenceFieldsLabel : 'No references',
		moreReferenceFieldsLabel : 'More references...',
		copyFromLabel	   	   : 'Copy from',
		submitText			   : 'OK',
		cancelText			   : 'Cancel'
	};


	// Plugin to retrieve the import configurations
	$.fn.getImportConfiguration = function() {
		var result = null;
		var table = $('table.importConfiguration', this);
		var input = table.data('input');

		if ($.isPlainObject(input)) {
			result = $.extend({}, input, {
				specificationTypes : getSpecTypes(input.specificationTypes),
				specifications     : getSpecifications(input.specifications),
				items              : getSpecObjTypes(input.items),
				relations          : getRelations(input.relations)
			});
		}

		return result;
	};


	// A third plugin to create an import configuration editor in a dialog
	$.fn.showImportConfigurationDialog = function(config, dialog, options, extension) {
		var popup    = this;
		var settings = $.extend({}, $.fn.showImportConfigurationDialog.defaults, dialog);
		var target   = $.extend(config.targetConfig, {
			source  		: config.source,
			sources 		: config.sources,
			reservedSources	: config.reservedSources
		});

		popup.empty();
		popup.importConfiguration(config.importConfig, target, $.extend(options, {
			assocTypes			: config.assocTypes,
			tableFields			: config.tableFields,
			relationFields		: config.assocFields,
			specificationFields : config.specFields,
			uploadId			: config.uploadId
		}));

		settings.buttons = [{
			text  : options.submitText,
			click : function() {
				var source = target.source;
				if (typeof source === 'string' && source.length > 0) {
				    var body = $('body');
				    var button = this;
					var busy = ajaxBusyIndicator.showBusyPage();

					button.disabled = true;
				    body.css('cursor', 'progress');

				    var url = extension.importURL.replace('{projectId}', target.id).replace('{uploadId}', config.uploadId).replace('{source}', source);

					$.ajax(url, {
						type		: 'POST',
						async		: true,
						data 		: JSON.stringify(popup.getImportConfiguration()),
						contentType : 'application/json',
						dataType 	: 'json'
					}).done(function(result) {
						ajaxBusyIndicator.close(busy);
						body.css('cursor', 'auto');

			  			popup.dialog('destroy');

			  			if (extension.resultURL) {
			  				setTimeout(function() {
			 	  				document.location.href = extension.resultURL.replace('{projectId}', config.targetConfig.id).replace('{baselineId}', result.id);
			  				}, 50);
			  			} else if ($.isFunction(extension.done)) {
			  				extension.done(result);
			  			}
					}).fail(function(jqXHR, textStatus, errorThrown) {
						ajaxBusyIndicator.close(busy);
						body.css('cursor', 'auto');
						button.disabled = false;

			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
				    		alert("POST " + url + " failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText + ", ex=" + err);
			    		}
			        });
				} else {
					alert(options.source.select.title);
				}
			 }
		}, {
			text  : options.cancelText,
		   "class": "cancelButton",
		    click : function() {
		    	popup.dialog("close");
			}
		}];

		// Make sure to remove the uploaded file upon Cancel/Close
		settings.close = function() {
	    	popup.dialog("destroy");

			var url = extension.importURL.replace('{projectId}', config.targetConfig.id).replace('{uploadId}', config.uploadId);

			$.ajax(url, {
				type		: 'DELETE',
				async		: true,
				contentType : 'application/json',
				dataType 	: 'json'
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("DELETE " + url + " failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText + ", ex=" + err);
	    		}
	        });
		};

		popup.dialog(settings);
	};


	$.fn.showImportConfigurationDialog.defaults = {
		title			: 'Import a file/archive',
		dialogClass		: 'popup',
		width			: 1400,
		height			: 800,
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: false
	};


})( jQuery );
