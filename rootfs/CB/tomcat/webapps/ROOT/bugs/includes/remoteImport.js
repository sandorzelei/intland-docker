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

function showAjaxError(jqXHR, textStatus, errorThrown) {
	try {
		var exception = $.parseJSON(jqXHR.responseText);
		showFancyAlertDialog(exception.message);
	} catch(err) {
		if (jqXHR.status == 401) { // Unauthorized
			showFancyAlertDialog(i18n.message("ajax.unauthorized.message="));
		} else if (jqXHR.status == 403) { // Forbidden
			showFancyAlertDialog(i18n.message("ajax.forbidden.message"));
		} else {
			showFancyAlertDialog("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		}
	}
}

function getNamePrefixes(names) {
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

	var prefix = [];
	var trie   = {};

	if ($.isArray(names)) {
		for (var i = 0; i < names.length; ++i) {
			addToTrie(trie, names[i]);
		}
	}

	optimizeTrie(trie);
	prefixesTrie(trie, "", prefix);

	return prefix.sort();
}

function buildPrefixesMenu(menu, action, prefixes, callback) {
	if (!$.isPlainObject(menu)) {
		menu = {};
	}

    if ($.isArray(prefixes) && prefixes.length > 0) {
    	for (var i = 0; i < prefixes.length; ++i) {
    		var prefix = prefixes[i];

    		menu[action + prefix] = {
			    name : prefix + '*'
    		};
    	}
    }

	return $.isEmptyObject(menu) ? false : {
		items	 : menu,
		callback : callback
	};
}


(function($) {

	// A plugin to choose a remote data source in a popup dialog
	$.fn.chooseRemoteSource = function(trackerId, connection, selected, config, extension) {
		var settings = $.extend( {}, $.fn.chooseRemoteSource.defaults, config);

		extension = $.extend({
			showHierarchy : function(popup, connection, hierarchy, selected, settings) {
				showFancyAlertDialog("No hierarchy plugin configured");
			},

			showPreview : function(popup, connection, selected, settings) {
				showFancyAlertDialog("No preview available");
			},

			getSelected : function(popup, connection, settings) {
				return null;
			},

			getValidation : function(connection, selected, settings) {
				return null;
			},

			finished : function(connection, selected, settings) {
				showFancyAlertDialog(JSON.stringify(selected));
			}
		}, extension);

		function showHierarchy(hierarchy) {
			var popup = $('#chooseRemoteSourcePopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'chooseRemoteSourcePopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			function finished(result) {
				popup.dialog("close");
	  			popup.remove();

	  			extension.finished.call(extension, connection, result, settings);
			}

			extension.showHierarchy.call(extension, popup, connection, hierarchy, selected, settings);

			settings.buttons = [{
				text : settings.submitText,
				click: function() {
					selected = extension.getSelected.call(extension, popup, connection, settings);
					if (selected) {
						var validation = extension.getValidation.call(extension, connection, selected, settings);
						if ($.isPlainObject(validation) && validation.url) {
						    $.ajax(validation.url, {
						    	type 	 : 'GET',
						    	data 	 : validation.params,
						    	dataType : 'json',
						    	cache	 : false
						    }).done(function(tracker) {
						    	if (tracker && tracker.id != trackerId) {
						    		var message = validation.error || settings.validation.error;
						    		showFancyAlertDialog(message.replace('YYY', tracker.name).replace('ZZZ', tracker.project ? tracker.project.name : "Unknown"));
						    	} else {
						    		finished(selected);
						    	}
							}).fail(showAjaxError);
						} else {
							finished(selected);
						}
					} else {
						showFancyAlertDialog(settings.title);
					}
				}
			}, {
				text  : settings.cancelText,
			   "class": "cancelButton",
				click : function() {
					popup.dialog("close");
					popup.remove();
				}
			}];

			if ($.isPlainObject(settings.preview) && settings.preview.label) {
				settings.buttons.push({
					text  : settings.preview.label,
				   "class": "cancelButton",
					click : function() {
						selected = extension.getSelected.call(extension, popup, connection, settings);
						if (selected) {
							extension.showPreview.call(extension, popup, connection, selected, settings);
						} else {
							showFancyAlertDialog(settings.title);
						}
					}
				});
			}

		    settings.close = function() {
	  			popup.remove();
		    };

			popup.dialog(settings);
		}

		var busy = ajaxBusyIndicator.showBusyPage(settings.hierarchy.loading);

		// We must make the call for the (top-level) hierarchy here, in order to handle missing connection infos properly
	    $.ajax(settings.hierarchy.url, {
	    	type 	    : 'POST',
			contentType : 'application/json',
	    	dataType 	: 'json',
			data 		: JSON.stringify(connection),
	    	cache	 	: false
	    }).done(function(result) {
			ajaxBusyIndicator.close(busy);
			showHierarchy(result);
		}).fail(function(jqXHR, textStatus, errorThrown) {
			ajaxBusyIndicator.close(busy);
			showAjaxError(jqXHR, textStatus, errorThrown);
        });
	};


	$.fn.chooseRemoteSource.defaults = {
		label		: 'Select...',
		title		: 'Please select the remote data source to import',

		hierarchy	: {
			url		: null,
			loading	: 'Loading remote data sources, Please wait...'
		},

		validation	: {
			error 	: 'The remote data source is already associated with tracker "YYY" in project "ZZZ"'
		},

		preview		: {
			label	: 'Preview...'
		},

	    submitText	: 'OK',
	    cancelText	: 'Cancel',
		dialogClass	: 'popup',
		position	: { my: "center", at: "center", of: window, collision: 'fit' },
		modal		: true,
		draggable	: true,
		closeOnEscape : true,
		width		: 480,
		height		: 640
	};


	// A plugin that allows to map remote object attributes and enum values to target fields and choice options
	$.fn.mapRemoteAttributes = function(attributes, config) {
		var settings = $.extend(true, {}, $.fn.mapRemoteAttributes.defaults, config, {
			expand : false
		});

		// Array of mapable fields
		var fields = settings.fields;
		if (!$.isArray(fields)) {
			fields = [];
		}

		// Array of reserved fields, that cannot be mapped and whose name, label and property must not be used for new fields
		var reserved = settings.reservedFields;
		if (!$.isArray(reserved)) {
			reserved = [];
		}

		// A Map of designated target custom field definitions for predefined Remote attributes
		var designated = settings.designatedField;
		if (!$.isPlainObject(designated)) {
			designated = {};
		}

		// Map of dedicated target fields, that can only be assigned to selected Remote attributes
		// key = field id or field name, value = array of selected Remote attributes names/aliases
		var dedicated = settings.dedicatedField;
		if (!$.isPlainObject(dedicated)) {
			dedicated = {};
		}

		function getSetting(name) {
			return settings[name];
		}

		function addAttributeMapping(attrib, mapping) {
			if ($.isPlainObject(attrib)) {
				var attrId = attrib[settings.attributeId];
				var target = attrib.target;

				if (attrId && target) {
					var attribMapping;

					if ($.isPlainObject(target)) {
						attribMapping = target;
					} else {
						attribMapping = {};

						if (typeof target === "number") {
							attribMapping.id = target;
						} else if (typeof target === "string") {
							attribMapping.name = target;
						}
					}

					var options = attrib.options;
					if ($.isArray(options) && options.length > 0) {
						attribMapping.options = {};

						for (var j = 0; j < options.length; ++j) {
							var option = options[j];
							if ($.isPlainObject(option)) {
								var optId = option.id || option.name;
								if (optId && option.target) {
									attribMapping.options[optId.toString()] = option.target;
								}
							}
						}
					}

					mapping[attrId] = attribMapping;

					if ($.isPlainObject(attrib.nested)) {
						addAttributeMapping(attrib.nested, mapping);
					} else if ($.isArray(attrib.children)) {
						for (var i = 0; i < attrib.children.length; ++i) {
							addAttributeMapping(attrib.children[i], mapping);
						}
					}
				}
			}
		}

		function getAttributeMapping(attribs) {
			var result;
			if ($.isPlainObject(attribs)) {
				result = attribs;
			} else {
				result = {};

				if ($.isArray(attribs) && attribs.length > 0) {
					for (var i = 0; i < attribs.length; ++i) {
						addAttributeMapping(attribs[i], result);
					}
				}
			}

			return result;
		}

		function camelize(str) {
			if (str && str.length > 0) {
				return str.replace(/(?:^\w|[A-Z]|\b\w)/g, function(letter, index) {
				    return index == 0 ? letter.toLowerCase() : letter.toUpperCase();
				}).replace(/\s+/g, '');
			}
			return str;
		}

		function getAttributeProperty(attrib) {
			var attribId = attrib[settings.attributeId];
			return attribId.startsWith('customfield_') ? camelize(attrib.name) : attribId;
		}

		function isTargetField(target, field) {
			if ($.isPlainObject(target)) {
				return target.id ? (field.id === target.id) : (field.name === target.name);
			} else if (typeof target === "string") {
				return field.name === target;
			} else if (typeof target === "number") {
				return field.id === target;
			}

			return false;
		}

		function findTargetField(target) {
			if (target) {
				for (var i = 0; i < fields.length; ++i) {
					if (isTargetField(target, fields[i])) {
						return fields[i];
					}
				}
			}

			return null;
		}

		function isNewField(target) {
			var name = null;

			if ($.isPlainObject(target)) {
				name = (target.id ? null : target.name);
			} else if (typeof target === "string") {
				name = target;
			}

			return name && name.length > 0 && !(findFieldByName(fields, name) || findFieldByName(reserved, name));
		}

		function isInSet(check, qualifiers) {
			if ($.isArray(qualifiers)) {
				if ($.isArray(check)) {
					for (var i = 0; i < check.length; ++i) {
						if ($.inArray(check[i], qualifiers) >= 0) {
							return true;
						}
					}
				} else if ($.inArray(check, qualifiers) >= 0) {
					return true;
				}
				return false;
			} else if (qualifiers) {
				if ($.isArray(check)) {
					if ($.inArray(qualifiers, check) >= 0) {
						return true;
					}
				} else {
					return check === qualifiers;
				}
				return false;
			}
			return true;
		}

		function getFieldType(field) {
//			var cardinality = field.required ? (field.multiple ? '1..* ' : '1 ') : (field.multiple ? '0..* ' : '0..1 ');
			var typeName = '';

			if ($.isPlainObject(field.of)) {
				typeName = getFieldType(field.of);

				if (field.type == 0) {
					typeName += (' ' + (field.multiple ? settings.issueTypes["name"].plural : settings.issueTypes["name"].name));
				} else {
					typeName += ' ' + settings.typeName[field.type];
				}

			} else if (field.type == 5) {
				var memberType = field.memberType || settings.principalTypes[0].id;
				var principals = [];

				for (var i = 0; i < settings.principalTypes.length; ++i) {
					var principal = settings.principalTypes[i];
					if ((memberType & principal.id) == principal.id) {
						principals.push(field.multiple ? principal.plural : principal.name);
					}
				}

				typeName = principals.join(', ');

			} else if (field.type == 7) {
				if (field.refType == 1) {
					typeName = field.multiple ? settings.principalTypes[0].plural : settings.principalTypes[0].name;

				} else if (field.refType == 5) {
					var qualifiers = $.isArray(field.refQuali) && field.refQuali.length > 0 ? field.refQuali : ["artifact"];
					var artifacts  = [];

					for (var i = 0; i < qualifiers.length; ++i) {
						var artifactType = settings.artifactTypes[qualifiers[i]];
						if (artifactType) {
							artifacts.push(field.multiple ? artifactType.plural : artifactType.name);
						}
					}

					typeName = artifacts.join(', ');

				} else if (field.refType == 9) {
					var qualifiers = $.isArray(field.refQuali) && field.refQuali.length > 0 ? field.refQuali : ["0"];
					var issues     = [];

					for (var i = 0; i < qualifiers.length; ++i) {
						var issueType = settings.issueTypes[qualifiers[i]];
						if (issueType) {
							issues.push(field.multiple ? issueType.plural : issueType.name);
						}
					}

					typeName = issues.join(', ');
				}
			} else {
				typeName = settings.typeName[field.type];

				if (field.multiple) {
					if (field.type == 6) {
						typeName = settings.multipleLabel + ' ' + typeName;
					} else if (field.type < 5 || field.type >= 10) {
						typeName += ' ' + settings.typeName[12];
					}
				}
			}

			return typeName;
		}

		function isAssignable(attrib, field, cardinality, raw) {
			var attrType = (!raw && typeof attrib.mappedType === "number" ? attrib.mappedType : attrib.type);

			if (cardinality && attrib.multiple && !field.multiple) {
				return false;
			}

			if ($.isPlainObject(field.of)) {
				return isAssignable(attrib, field.of, false, true);
			} else if (field.type == 0 || field.type == 10) { // (wiki)text
				return attrType == 0 || attrType == 10;
			} else if (field.type == 2) { // float
				return attrType == 1 || attrType == 2;
			} else if (field.type == 5) { // principal
				return (attrType == 5 && (field.memberType & attrib.memberType) != 0) ||
				       (attrType == 7 && attrib.refType == 1 && (field.memberType & 2) == 2);
			} else if (field.type == 7) { // reference
				return attrType == 7 && field.refType == attrib.refType && isInSet(attrib.refQuali, field.refQuali);
			} else {
				return attrType == field.type;
			}
		}

		function isPossibleTarget(attrib, property, field) {
			var selected = dedicated[field.id && field.id < 100 ? field.id.toString() : field.name];
			if ($.isArray(selected)) {
				return $.inArray(property, selected) >= 0 && isAssignable(attrib, field, settings.cardinality, false);
			}
			return !designated[property] && (settings.bidirect || !field.formula) && isAssignable(attrib, field, settings.cardinality, false);
		}

		function hasName(field, name) {
			return field && (
			 	  (field.name     && (name === field.name.toUpperCase())) ||
				  (field.rest     && (name === field.rest.toUpperCase())) ||
				  (field.label    && (name === field.label.toUpperCase())) ||
				  (field.property && (name === field.property.toUpperCase())));
		}

		function findFieldByName(fields, name) {
			if ($.isArray(fields) && name) {
				name = name.toUpperCase();

				for (var i = 0; i < fields.length; ++i) {
					if (hasName(fields[i], name)) {
						return fields[i];
					}
				}
			}

			return null;
		}

		function newField(attrib, name) {
			var field = $.extend({}, attrib, {
				name  : name,
				label : name
			});

			// This is a new field for codeBeamer, it does not have a CB id yet !!!
			delete field.id;
			delete field.mapping;
			delete field.options;
			delete field.nested;
			delete field.children;

			if (typeof field.mappedType === "number") {
				if (field.type == 5) {
					field.of = {
						type 		: field.type,
						memberType 	: field.memberType || 2
					};

					delete field.memberType;

				} else if (field.type == 7) {
					field.of = {
						type 	 : field.type,
						refType	 : field.refType,
						refQuali : field.refQuali
					};

					delete field.refType;
					delete field.refQuali;
				}

				field.type = field.mappedType;
				delete field.mappedType;
			}

			if (field.type == 6) {
				field.options = [];

				var options = attrib.options;
				if ($.isArray(options) && options.length > 0) {
					for (var i = 0; i < options.length; ++i) {
						if ($.isPlainObject(options[i])) {
							var option = $.extend({}, options[i]);

							delete option.id;
							delete option.ttid;
							delete option.attrib;
							delete option.target;

							field.options.push(option);
						}
					}
				}
			}

			return field;
		}

		function proposeFieldName(attrib) {
			var name = attrib.name;

			if (attrib.mappedType === 0) {
				if (name.endsWith('/s')) {
					name = name.substring(0, name.length - 2);
				}
				name += (' ' + (attrib.multiple ? settings.issueTypes["name"].plural : settings.issueTypes["name"].name));
			}

			return name;
		}

		function createNewField(attrib, fields) {
			var fldName = $.trim(prompt(settings.fieldNameTitle, proposeFieldName(attrib)));
			if (fldName && fldName.length > 0) {
				var field = findFieldByName(reserved, fldName);
				if (field) {
					showFancyAlertDialog(settings.reservedFieldName);
				} else if (field = findFieldByName(fields, fldName)) {
					showFancyAlertDialog(settings.duplicateFieldName);
				} else {
					fields.push(field = newField(attrib, fldName));
					return field;
				}
			}

			return null;
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

			var optName = $.trim(prompt(settings.valueNameTitle, template.name || ''));
			if (optName && optName.length > 0) {
				var nameUpper = optName.toUpperCase();

				if ($.isArray(options)) {
					for (var i = 0; i < options.length; ++i) {
						if (nameUpper === options[i].name.toUpperCase() || (options[i].label && (nameUpper === options[i].label.toUpperCase()))) {
							if (optName === options[i].name || optName === options[i].label) {
//								showFancyAlertDialog(setting.duplicateValueName);
								option = options[i];
								break;
							} else if (!confirm(settings.createSimilarValue)) {
								option = options[i];
								break;
							}
						}
					}
				} else {
					options = [];
				}

				if (!option) {
					option = $.extend({}, template, {
						name  : optName,
						label : optName
					});

					delete option.id;
					delete option.ttid;
					delete option.attrib;
					delete option.target;

					options.push(option);
				}
			}

			return option;
		}

		function resetTarget() {
			var reset = $(this).data('reset');
			if ($.isFunction(reset)) {
				reset.apply(this);
			}
		}

		function isMapped(attrib) {
			return $.isPlainObject(attrib.target) && attrib.target.id != -1;
		}

		function getTargetOptions(attrib) {
			if (isMapped(attrib)) {
				var field = attrib.target;
				if (field.type === 6 && !$.isArray(field.options)) {
					field.options = [];
				}

				return field.options;
			}

			return null;
		}

		function getTargetOptionSelector(options, selectedVal) {
			var selector = $('<select>', { "class" : 'option', title : settings.selectValueTitle });

			if (!selectedVal) {
				selector.append($('<option>', {
				   "class"	 : 'option',
					value  	 : null
				}).text('-- ' + settings.selectValueLabel + ' --'));
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

			if (settings.editable) {
				result.append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.clickToEditValue
				}));
			}

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

		function isNewOption(field, options, target) {
			if ($.isPlainObject(target)) {
				return ((field && field.id == 9999) || target.id === undefined || target.id == null) && target.name && !findOptionByName(options, target.name, false);
			} else if (typeof target === "string") {
				return !findOptionByName(options, target, false);
			}

			return false;
		}

		function setOption(option, target) {
			if (target) {
				var exists = null;
				var values = getTargetOptions(option.attrib);

				if ($.isArray(values)) {
					exists = findTargetOption(values, target);
				} else {
					values = [];
				}

				if (exists) {
					target = exists;
				} else if (isNewOption(option.attrib.target, values, target)) {
					if ($.isPlainObject(target)) {
						target = $.extend({}, option, target, {
							label : target.label || target.name
						});
					} else {
						target = $.extend({}, option, {
							name  : target,
							label : target
						});
					}

					delete target.id;
					delete target.ttid;
					delete target.attrib;

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

		function setOptions(attrib, mapping) {
			var options = attrib.options;

			if (isMapped(attrib) && $.isArray(options) && options.length > 0) {
				var field = attrib.target;

				if (!$.isPlainObject(mapping)) {
					mapping = {};
				}

				for (var i = 0; i < options.length; ++i) {
					var option = options[i];
					var optKey = option.id || option.name;
					var target = (optKey ? mapping[optKey.toString()] : null) || (field.id === 9999 ? option.target : null);

					setOption(option, target);
				}
			}
		}

		function getOptions(attrib) {
			var options = attrib.options;
			var mapping = {};

			if (isMapped(attrib) && $.isArray(options) && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					var option = options[i];
					var optKey = option.id || option.name;
					var target = option.target;

					if (optKey && $.isPlainObject(target) && target.name) {
						if (typeof target.id === "number" && target.id >= 0) {
							target = target.id;
						} else {
							target = target.name;
						}

						mapping[optKey.toString()] = target;
					}
				}
			}

			return mapping;
		}

		function resetOptions(options, createIfNotExists) {
			if ($.isArray(options) && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					resetOption(options[i], createIfNotExists);
				}
			}
		}

		function saveOptions(attrib) {
			if (attrib.type == 6 && isMapped(attrib)) {
				var attribId = attrib[settings.attributeId];
				var field    = attrib.target;

				if (attribId && field.type == 6) {
					if (!$.isPlainObject(field.optionMapping)) {
						field.optionMapping = {};
					}
					field.optionMapping[attribId.toString()] = getOptions(attrib);
				}
			}
		}

		function restoreOptions(attrib) {
			if (attrib.type == 6 && isMapped(attrib)) {
				var attribId = attrib[settings.attributeId];
				var field    = attrib.target;

				if (attribId && $.isPlainObject(field.optionMapping)) {
					setOptions(attrib, field.optionMapping[attribId.toString()]);
				}
			}
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

		function setupOptionTarget(option, target) {
			var div = null;

			if (isMapped(option.attrib)) {
				div = $('<div>', { "class" : 'optTarget', style : 'margin-left: ' + ((settings.indent + 1) * 19) + 'px; width: 100%;' });
				target.append(div);

				div.append(getOptionLabel(option.target));

				if (settings.editable) {
					div.editable(setOptionTarget, {
				        type   : 'optionTarget',
				        event  : 'click',
				        onblur : 'cancel'
				    });
				}
			}

			return div;
		}

		function resetOptionTarget() {
			var optRow = $(this);
			var option = optRow.data('option');
			if (option) {
				var optTarget = optRow.find('div.optTarget');

				if (isMapped(option.attrib)) {
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

		function resetOptionTargets(attrRow, expand) {
			var attrib = attrRow.data('attrib');
			if (attrib.type == 6) {
				var attrId = attrRow.attr('data-tt-id');

				attrRow.nextUntil(':not(tr.option[data-tt-parent-id="' + attrId + '"])').each(resetOptionTarget);

				if (settings.expand && expand) {
					try {
						attrRow.closest('table').treetable(isMapped(attrib) ? "expandNode" : "collapseNode", attrId);
					} catch(e) {
						alert(e.stack);
					}
				}
			}
		}

		function assignUnmappedOptions(event) {
			var attRow = $(this).closest('tr.attrib');
			var attrId = attRow.attr('data-tt-id');

			attRow.nextUntil(':not(tr.option[data-tt-parent-id="' + attrId + '"])').each(function() {
				var optRow = $(this);
				var option = optRow.data('option');
				if (option && !option.target && setOption(option, option.name)) {
					resetOptionTarget.apply(optRow);
				}
			});

			event.preventDefault();
			return false;
		}

		function getOptionTargetNames(mapping) {
			if ($.isPlainObject(mapping)) {
				$.each(mapping, function(name, target) {
					// Ignore target id, if a target name is available
					if ($.isPlainObject(target) && typeof target.name === "string" && target.name.length > 0) {
						delete target.id;
					}
				});
			}

			return mapping;
		}

		function setupOptions(tbody, attribId, options) {
			if ($.isArray(options) && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					var option = options[i];

					var optRow = $('<tr>', { "class" : 'option odd', "data-tt-id" : option.ttid, "data-tt-parent-id" : attribId }).data('option', option).data('reset', resetOptionTarget);
					optRow.append($('<td>', { "class" : 'optName', title : option.description, style: 'vertical-align: middle; white-space: nowrap; width: 50%;' }).text((option.label || option.name).replace(/^\s+|\s+$/g, '\u23B5')));
					optRow.append($('<td>', { "class" : 'direction', style : 'width: 20px; min-width: 20px;' }));

					var optTarget = $('<td>', { "class" : 'optTarget', style : 'vertical-align: middle' });
					optRow.append(optTarget);
					tbody.append(optRow);

					setupOptionTarget(option, optTarget);

					tbody.append(optRow);
				}
			}
		}

		function getTargetFieldSelector(attrib, fields) {
			var property = getAttributeProperty(attrib);
			var selector = $('<select>', { "class" : 'field', title : settings.selectFieldTitle });

			selector.append($('<option>', {
			   "class"	 : 'field',
				value	 : "-IGNORE-",
				title 	 : settings.ignoreFieldTitle,
				selected : (attrib.target && attrib.target.id === -1)
			}).text('-- ' + settings.ignoreFieldLabel + ' --').data('field', { id : -1 }));

			for (var i = 0; i < fields.length; ++i) {
				var field = fields[i];

				if (isPossibleTarget(attrib, property, field)) {
					selector.append($('<option>', {
					  "class" 	: 'field',
					   value 	: field.id || field.name,
					   title	: field.description,
					   selected : isTargetField(attrib.target, field)
					}).text((field.label || field.name) + ' (' + getFieldType(field) + ')').data('field', field));
				}
			}

			if (!designated[property]) {
				selector.append($('<option>', { "class" : 'field', value : '-NEW-' }).text('-- ' + settings.newFieldLabel + ' --'));
			}

			return selector;
		}

		function getFieldLabel(field) {
			var result = $('<span>', { "class" : 'subtext' });

			if (field != null && field.id != -1) {
				result.css('margin-left', '6px').text('(' + getFieldType(field) + ')');

				var label = $('<label>', { title : field.description}).text(field.label || field.name);
				label.append(result);

				result = label;
			} else {
				result.css('color', 'gray').text('-- ' + settings.ignoreFieldLabel + ' --');
			}

			if (settings.editable) {
				result.append($('<img>', {
				   "class": 'inlineEdit',
					src   : contextPath + '/images/inlineEdit.png',
					title : settings.clickToEditField
				}));
			}

			return result;
		}

		function changeAttribute(attrib, field, createIfNotExists) {
			if (field != attrib.target) {
				saveOptions(attrib);

				attrib.target = field;
				resetOptions(attrib.options, createIfNotExists);

				restoreOptions(attrib);
			}

			return field;
		}

		function setAttribute(attrib, target, createIfNotExists) {
			if (target) {
				var field = null;

				if ($.isPlainObject(target) && target.id === -1) {
					field = target;
				} else {
					var exists = findTargetField(target);
					if (exists) {
						if (isPossibleTarget(attrib, getAttributeProperty(attrib), exists)) {
							field = exists;
						}
					} else if (createIfNotExists && isNewField(target)) {
						field = $.isPlainObject(target) ? newField($.extend({}, attrib, target), target.name) : newField(attrib, target);
						fields.push(field);
					}
				}

				if (field && (field.id || field.name)) {
					return changeAttribute(attrib, field, createIfNotExists);
				}
			}

			return null;
		}

		function resetAttribute(attrib, createIfNotExists) {
			if (!setAttribute(attrib, attrib.target, createIfNotExists) && isMapped(attrib)) {
				changeAttribute(attrib, null, false);
			}
		}

   	  	function setDirection(direction, value, editable) {
  	  		var oldVal = direction.data('direction');
  			var clazz = (oldVal === 'synchronize' ? 'bidirect' : oldVal);
  			if (clazz) {
   	   	  		direction.removeClass(settings.editable ? 'editable ' + clazz : clazz);
  			}

  	  		var option = (value ? settings.direction[value] : null);
   	  		if ($.isPlainObject(option) && option.value) {
   	  			direction.data('direction', value);
   	  			direction.attr('title', option.title.replace('XXX', settings.valuesLabel));

   	  			clazz = (value === 'synchronize' ? 'bidirect' : value);
   	  			direction.addClass(editable && settings.editable ? 'editable ' + clazz : clazz);
   	  		} else {
   	  			direction.removeData('direction');
   	  			direction.removeAttr('title');
   	  		}
   	  	}

		function resetDirection(row, attrib) {
			var direction = row.find('td.direction');

			if (!isMapped(attrib)) {
				setDirection(direction, null, false);
			} else if (settings.bidirect) {
				if (!attrib.editable || ($.isArray(settings.importOnly) && $.inArray(attrib[settings.attributeId], settings.importOnly) >= 0)) {
					setDirection(direction, 'import', false);
				} else if (attrib.target.formula) {
					setDirection(direction, 'export', false);
				} else if (!direction.hasClass('editable')) {
					setDirection(direction, direction.data('direction') || 'synchronize', true);
				}
			}
		}

		function setupDirection(row, attrib, target) {
			if (settings.bidirect) {
				if ($.isPlainObject(target) && target.sync) {
					row.find('td.direction').data('direction', target.sync == 3 ? 'synchronize' : (target.sync == 2 ? 'export' : 'import'));
				}

				resetDirection(row, attrib);
			}
		}

		function setAttributeTarget(value) {
	        var attRow = $(this).closest('tr.attrib');
	       	var attrib = attRow.data('attrib');
	       	var fields = attRow.data('fields');

        	if (value === '-NEW-') {
        		var newFld = createNewField(attrib, fields);
        		if (newFld) {
    				changeAttribute(attrib, newFld, false);
        		}
			}

        	resetDirection(attRow, attrib);
         	resetOptionTargets(attRow, true);

			return getFieldLabel(attrib.target)[0].outerHTML;
		}

		function setupAttributeTarget(attrib, target) {
			var div = $('<div>', { "class" : 'attrTarget', style : 'margin-left: ' + (settings.indent * 19) + 'px; width: 100%;' }).append(getFieldLabel(attrib.target));
			target.append(div);

        	if (settings.editable) {
	        	div.editable(setAttributeTarget, {
			        type   : 'attributeTarget',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}

			return div;
		}

		function resetAttributeTarget() {
			var attRow = $(this);
	       	var attrib = attRow.data('attrib');
	       	if (attrib) {
				resetDirection(attRow, attrib);

				var attTarget = attRow.find('div.attrTarget');
				if (attTarget.length == 0) {
					setupAttributeTarget(attrib, attRow.find('td.attrTarget'));
				} else {
					attTarget.empty().append(getFieldLabel(attrib.target));
				}
	       	}
		}

		function changeAttributeRow(row, attrib, field) {
			if (setAttribute(attrib, field, true)) {
				resetAttributeTarget.apply(row);
				resetOptionTargets(row, true);
			}
		}

		function setupTargetField(attrRow, attrTarget, attrib, mapping) {
			var target = mapping[attrib[settings.attributeId]];

			var dfltField = designated[getAttributeProperty(attrib)];
			if (dfltField && !findTargetField(dfltField)) {
				fields.push(dfltField);
			}

			setAttribute(attrib, target, true);
			setOptions(attrib, $.isPlainObject(target) ? target.options : null);

			setupDirection(attrRow, attrib, target);
			setupAttributeTarget(attrib, attrTarget);

			return target;
		}

		function checkTargetField(row, attrib, affected, allowed, dedicate) {
			if (isMapped(attrib)) {
				if (($.isFunction(affected) ? affected(attrib.target) : affected) && !($.isFunction(allowed) ? allowed(attrib.target, attrib) : allowed)) {
					changeAttributeRow(row, attrib, {id : -1});
				}
			} else if (dedicate) {
				var property = getAttributeProperty(attrib);

				// if attrib has a dedicated field, and that is affected and allowed, then set dedicated field
				for (var i = 0; i < fields.length; ++i) {
					var field   = fields[i];
					var targets = dedicated[field.id && field.id < 100 ? field.id.toString() : field.name];

					if ($.isArray(targets) && $.inArray(property, targets) >= 0 && isAssignable(attrib, field, settings.cardinality, false) &&
					   ($.isFunction(affected) ? affected(field) : affected) && ($.isFunction(allowed) ? allowed(field, attrib) : allowed)) {
						changeAttributeRow(row, attrib, field);
						break;
					}
				}
			}
		}

		function getAttributeType(attrib) {
//			var cardinality = attrib.required ? (attrib.multiple ? '1..* ' : '1 ') : (attrib.multiple ? '0..* ' : '0..1 ');
			var typeName = (attrib.notSupported && attrib.format) ? attrib.format : getFieldType(attrib);

			if (typeof attrib.mappedType === "number") {
				if (attrib.mappedType == -1) {
					typeName = settings.notPossible;
				} else if (attrib.mappedType == 0) {
					typeName += (' ' + (attrib.multiple ? settings.issueTypes["name"].plural : settings.issueTypes["name"].name));
				} else {
					typeName += ' ' + settings.typeName[attrib.mappedType];
				}
			}

			return '(' + typeName + ')';
		}

		function showAttributeType(attrRow, attrib) {
			$('td.attrName > span.subtext', attrRow).empty().append(getAttributeType(attrib));
		}

		function getAttributeNamePrefixes() {
			return getNamePrefixes($.map(attributes, function(attrib) {
				return attrib.name;
			}));
		}

		function getAttributeRows(container) {
			if (container.is('tr')) {
				return container.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + container.attr('data-tt-id') + '"]');
			} else if (container.is('table.attribs')) {
				return container.find('tbody > tr.attrib');
			}

			return container.find('table.attribs > tbody > tr.attrib');
		}

		function changeAttributeTargetType(attrRow, affected) {
			var attrib = attrRow.data('attrib');
			if (attrib && $.isArray(affected)) {
				for (var i = 0; i < affected.length; ++i) {
					if (affected[i].attribs(attrib)) {
						if (affected[i].fields) {
							checkTargetField(attrRow, attrib, affected[i].fields, affected[i].allowed, true);
						} else if (affected[i].allowed) {
							if (typeof attrib.mappedType === "number") {
								delete attrib.mappedType;

								showAttributeType(attrRow, attrib);
								checkTargetField(attrRow, attrib, true, true, true);
							}
						} else if (attrib.type == 5 || attrib.type == 7) {
							var mappedType = (attrib.options != null && attrib.options.length > 0 ? 6 : (typeof affected[i].disable === "number" ? affected[i].disable : 0) );
							if (mappedType != attrib.mappedType) {
								attrib.mappedType = mappedType;

								showAttributeType(attrRow, attrib);

								checkTargetField(attrRow, attrib, true, function(field, attrib) {
									return isAssignable(attrib, field, settings.cardinality, false);
								}, false);
							}
						}
					}
				}
			}
		}

		function setAttributeMapping(attrRow, mapping) {
			var attrib = attrRow.data('attrib');
			if (attrib) {
				var target = mapping[attrib[settings.attributeId]];
				if (target) {
					if ($.isPlainObject(target) && typeof target.id === "number") {
						if (target.id >= 100) {
							// Ignore the id of custom fields, use the name
							delete target.id;
						} else {
							// Ignore the name of system fields
							delete target.name;
						}
					}

					if (setAttribute(attrib, target, true)) {
						if (settings.bidirect && $.isPlainObject(target) && target.sync) {
							attrRow.find('td.direction').data('direction', target.sync == 3 ? 'synchronize' : (target.sync == 2 ? 'export' : 'import'));
						}

						resetAttributeTarget.apply(attrRow);

						setOptions(attrib, $.isPlainObject(target) ? getOptionTargetNames(target.options) : null);
						resetOptionTargets(attrRow, !isMapped(attrib));
					}
				}
			}
		}

		function setAttributesMapping(container, mapping) {
			mapping = getAttributeMapping(mapping);

			getAttributeRows(container).each(function() {
				setAttributeMapping($(this), mapping);
			});
		}

		function ignoreAttributes(container, prefix) {
			var ignore = { id : -1 };

			if (prefix.indexOf('ignore_') == 0) {
				prefix = prefix.substring(7);
			}

			getAttributeRows(container).each(function() {
				var row    = $(this);
				var attrib = row.data('attrib');

				if (attrib && isMapped(attrib) && (prefix === '-ALL-' || attrib.name.indexOf(prefix) == 0)) {
					changeAttributeRow(row, attrib, ignore);
				}
			});
		}

   	  	function assignAttributes(container, prefix) {
			getAttributeRows(container).each(function() {
				var row    = $(this);
				var attrib = row.data('attrib');

				if (attrib && !isMapped(attrib) && (prefix === '-ALL-' || attrib.name.indexOf(prefix) == 0)) {
					var property  = getAttributeProperty(attrib);
					var dfltField = designated[property];

					// if attrib has a dedicated field
					for (var i = 0; i < fields.length; ++i) {
						var field   = fields[i];
						var targets = dedicated[field.id && field.id < 100 ? field.id.toString() : field.name];

						if ($.isArray(targets) && $.inArray(property, targets) >= 0 && isAssignable(attrib, field, settings.cardinality, false)) {
							dfltField = field;
							break;
						}
					}

					changeAttributeRow(row, attrib, dfltField || attrib.name);
				}
			});
   	  	}

		function setupAttributes(tbody, parentId, nodeId, attributes, unloaded, mapping) {
			if ($.isArray(attributes) && attributes.length > 0) {
				for (var i = 0; i < attributes.length; ++i) {
					var attrib     = attributes[i];
					var attrId     = ++nodeId;
					var attrRow    = $('<tr>', { "class" : 'attrib odd', "data-tt-id" : attrId }).data('attrib', attrib).data('fields', fields).data('reset', resetAttributeTarget);
					var attrName   = $('<td>', { "class" : 'attrName', title : attrib.description, style: 'vertical-align: middle; white-space: nowrap; width: 50%;' });
					var attrDir    = $('<td>', { "class" : 'direction', style : 'width: 20px; min-width: 20px;' });
					var attrTarget = $('<td>', { "class" : 'attrTarget', style : 'vertical-align: middle;' });

					if (parentId > 0) {
						attrRow.attr("data-tt-parent-id", parentId);
					}

					var attrLabel = $('<label>').text(attrib.label || attrib.name);
					if (attrib.hidden) {
						attrLabel.css('color', 'Gray');
					}

					attrName.append(attrLabel);

					var attrType = $('<span>', { "class" : 'subtext', style : 'margin-left: 6px;' }).text(getAttributeType(attrib));
					if (attrib.notSupported) {
						attrType.css('text-decoration', 'red line-through').attr('title', settings.notSupported.title.replace('XXX', attrib.format || attrib.name));
					}

					attrName.append(attrType);

					if (attrib.required) {
						attrName.append($('<span>', { title : settings.requiredTitle, style : 'color: FireBrick; margin-left: 3px;' }).text('*'));
					}

					if (attrib.dxl) {
						attrRow.addClass('dxl');
						attrName.append($('<img>', { src : settings.dxl.image, alt : settings.dxl.label, title : settings.dxl.title, style : 'position: relative; top: +4px; margin-left: 6px;'}));
					}

					attrRow.append(attrName);
					attrRow.append(attrDir);
					attrRow.append(attrTarget);

					tbody.append(attrRow);

					if (attrib.notSupported) {
						attrTarget.append($('<span>', {
						   "class" : 'subtext',
							title  : settings.notSupported.title.replace('XXX', attrib.format)
						}).text('-- ' + settings.notSupported.label + ' --'));
					} else {
						var nested  = $.isArray(attrib.children) ? attrib.children : $.isPlainObject(attrib.nested) ? [attrib.nested] : null;
						var options = attrib.options;

						if ($.isArray(options) && options.length > 0) {
							for (var j = 0; j < options.length; ++j) {
								options[j].ttid   = ++nodeId;
								options[j].attrib = attrib;
							}

							if (settings.editable) {
								attrName.append($('<span>', {
									"class" : 'ui-icon ui-icon-circle-arrow-s',
									 style  : 'margin-left: 6px;',
									 title  : settings.assignUnmappedOptions
								}).click(assignUnmappedOptions));
							}
						}

						setupTargetField(attrRow, attrTarget, attrib, mapping);

						if ($.isArray(options) && options.length > 0) {
							if (unloaded && !nested) {
								attrRow.addClass('unloaded').attr("data-tt-branch", true);
							} else {
								setupOptions(tbody, attrId, options);
							}
						}

						nodeId = setupAttributes(tbody, attrId, nodeId, nested, unloaded, mapping);
					}
				}
			}

			return nodeId;
		}

		function init(container, attributes) {
			var nodeId = 0;
			var tbody  = null;
			// The Remote attribute (key) to target { field = {}, options = {}} mapping
			var mapping = getAttributeMapping(settings.mapping);

			if (container.is('tr')) {
				tbody  = container.closest('tbody');
				nodeId = parseInt(container.attr('data-tt-id'));
				nodeId = setupAttributes(tbody, nodeId, nodeId, attributes, false, mapping);
			} else {
				var table = $('<table>', { "class" : 'displaytag attribs', style: 'border: 1px solid silver;'});
				container.append(table);

//				var header = $('<thead>');
//				table.append(header);
	//
//				var headline = $('<tr>',  { "class" : 'head', style: 'vertical-align: middle;' });
//				headline.append($('<th>', { "class" : 'textData', style: 'padding-left: 20px !important; vertical-align: middle; width: 50%;' }).text(settings.attibuteLabel));
//				headline.append($('<th>', { "class" : 'textData' }).text(settings.mappingLabel));
	//
//				header.append(headline);

				tbody = $('<tbody>');
				table.append(tbody);

				nodeId = setupAttributes(tbody, nodeId, nodeId, attributes, true, mapping);

				table.treetable({
					expandable   : true,
					initialState : 'collapsed',

					onNodeExpand : function() {
						var node = this;
						var row  = this.row;

						if (row.is('tr.attrib.unloaded')) {
							var optRows = $('<tbody>');
							setupOptions(optRows, row.attr('data-tt-id'), row.data('attrib').options);
							table.treetable('loadBranch', node, optRows.find('tr.option'));
						}
					},

					onNodeCollapse : function() {
						var node = this;
						var row  = this.row;

						if (row.is('tr.attrib.unloaded')) {
							table.treetable("unloadBranch", node);
						}
					}
				});
			}

			container.data('mapRemoteAttributesPlugin', {
				changeAttributeTargetType : changeAttributeTargetType,
				setAttributesMapping	  : setAttributesMapping,
				ignoreAttributes		  : ignoreAttributes,
				assignAttributes		  : assignAttributes
			});

			settings.expand = true;

			return nodeId;
		}

		function setup() {
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
		     	}
		    });

			/* Define an inplace editor for attribute target fields */
		    $.editable.addInputType('attributeTarget', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var attRow   = $(self).closest('tr.attrib');
		        	var attrib   = attRow.data('attrib');
		           	var selector = getTargetFieldSelector(attrib, attRow.data('fields')).change(function() {
		           		if (this.value != '-NEW-') {
		           			changeAttribute(attrib, selector.find('option.field:selected').data('field'), false);
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
		        selector : 'tr.attrib td.direction.editable',
		        trigger  : 'left',
		        items	 : {
		        	"ignore" : {
		        		name : getSetting('direction')["ignore"].label.replace('XXX', getSetting('valuesLabel'))
		        	},

		        	"import" : {
		        		name : getSetting('direction')["import"].label.replace('XXX', getSetting('valuesLabel'))
		        	},

		        	"export" : {
		        		name : getSetting('direction')["export"].label.replace('XXX', getSetting('valuesLabel'))
		        	},

		        	"synchronize" : {
		        		name : getSetting('direction')["synchronize"].label.replace('XXX', getSetting('valuesLabel'))
		        	}
		        },
		        callback : function(key, options) {
		        	setDirection(options.$trigger, key, true);
		        	if (key === 'ignore') {
		        		var row = options.$trigger.closest('tr.attrib');
		        		changeAttributeRow(row, row.data('attrib'), {id : -1});
		        	}
		        }
		    });
		}

		if ($.fn.mapRemoteAttributes._setup) {
			$.fn.mapRemoteAttributes._setup = false;
			setup();
		}

		return init(this, attributes);
	};

	$.fn.mapRemoteAttributes._setup = true;


	$.fn.mapRemoteAttributes.defaults = {
		editable		: true,
		bidirect		: false,
		merged			: false,
		indent			: 0,
		label			: 'Attributes',
		title			: 'The importable attributes of the selected remote objects',
		none			: 'There are no importable attributes of the selected remote objects',

		typeName	  	: ["Text", "Integer", "Decimal", "Date", "Boolean", "Member", "Choice", "References", "Language", "Country", "RichText", "Duration", "Table", "Color"],

		principalTypes	: [{
			id			: 2,
			name		: 'User',
			plural		: 'Users'
		}, {
			id			: 4,
			name		: 'Group',
			plural		: 'Groups'
		}, {
			id			: 8,
			name		: 'Role',
			plural		: 'Roles'
		}],

		artifactTypes 	: {
			artifact	: {
				name	: 'Artifact',
				plural	: 'Artifacts'
			},
			attachment	: {
				name	: 'Attachment',
				plural	: 'Attachments'
			},
			comment		: {
				name	: 'Comment',
				plural	: 'Comments'
			},
			change		: {
				name	: 'Change',
				plural	: 'Changes'
			}
		},

		notSupported 	: {
			image 		: contextPath + '/images/error.gif',
			label 		: 'Unsupported field',
			title 		: 'Fields of type "XXX" are not supported!'
		},

		multipleLabel			: 'Multiple',
		attributeId				: 'id',
		attibuteLabel 			: 'Attribute',
		unmappedAttributes		: 'Attributes not mapped yet',
		mappingLabel  			: 'Mapping',
		notPossible				: 'Not possible',
		clickToEditField	    : '(Double) Click, to choose a predefined field, or to define a new field',
		selectFieldLabel		: 'Please select',
		selectFieldTitle		: 'You must either choose a predefined field, or define a New... field',
		selectAllLabel			: 'Select all',
		ignoreFieldLabel		: 'Ignore field',
		ignoreFieldTitle		: 'The field value will be ignored (not imported)!',
		ignoreAllLabel			: 'Ignore all',
		newFieldLabel			: 'New...',
		newFieldTitle			: 'New Field',
		newFieldTooltip			: 'Create a new custom target field for this attribute',
		fieldNameTitle			: 'The name of the new field (required)',
		duplicateFieldName		: 'A field with the specified name already exists !',
		reservedFieldName		: 'The specified field name is a reserved name. Please choose another name !',
		selectValueLabel		: 'Please select',
		selectValueTitle		: 'You must either choose a predefined value, or create a New... value',
		clickToEditValue	    : '(Double) Click, to choose a predefined value, or to define a new value',
		newValueLabel			: 'New...',
		newValueTitle			: 'New Value',
		newValueTooltip			: 'Create a new custom choice value for this attribute',
		valueNameTitle			: 'Please enter the name of the new value',
		duplicateValueName		: 'A value with the specified name already exists !',
		createSimilarValue	    : 'A value with a name, that only differs in case, already exists ! Create the new value anyway ?',
		assignUnmappedOptions	: 'Automatically assign all unmapped values to matching or new target values',
		fieldMappingAmbigous	: 'Attribute "XX" is mapped to the same field ("YY") as attribute "ZZ"',
		valueNotMapped			: 'Attribute "XX": The value "YY" of has not been mapped to a target value',
		valueMappingAmbigous 	: 'Attribute "XX": The value "YY" has been mapped to the same target value ("ZZ") as value "WW"',
		valuesLabel				: 'Values',
		requiredTitle			: 'This attribute is required/mandatory',
		requiredMissing			: 'Exporting new tracker items might fail, because required values for the mandatory attribute "XX" are not exported!',

		direction : {
			label		: 'Direction',
			title		: 'Whether to only import, export or synchronize XXX bi-directionally',
			classes		: ['editable', 'import', 'export', 'bidirect'],

			ignore		: {
				value	: 0,
				label	: 'Ignore XXX',
				title	: 'Ignore XXX from the remote system'
			},
			"import"	: {
				value	: 1,
				label	: 'Import XXX',
				title	: 'Only import XXX from the remote system'
			},
			"export"	: {
				value	: 2,
				label	: 'Export XXX',
				title	: 'Only export XXX to the remote system'
			},
			synchronize	: {
				value	: 3,
				label	: 'Synchronize XXX',
				title	: 'Synchronize XXX with the remote system'
			},
			unidirect 	: {
				value	: 1,
				label	: 'Only',
				title	: 'Data'
			},
			bidirect	: {
				value	: 3,
				label	: 'Bi-directionally',
				title	: 'Data'
			}
		},

		dxl	: {
			image	: contextPath + '/images/warn.gif',
			label	: 'DXL',
			title	: 'The value of this attribute is computed via DXL'
		}
	};


	// Get the mapping of remote attributes and enum values to target fields and choice options
	$.fn.getRemoteAttributeMapping = function(settings, checkExport) {
		var reverse = {};
		var merged  = (typeof settings.merged === "string");
		var result  = [];

		function checkAttribFieldUniqueName(attrib, field, domain, name) {
			var mapped = domain[name];
			if (mapped) {
				throw settings.fieldMappingAmbigous.replace('XX', attrib.label || attrib.name).replace('YY', field.label || field.name).replace('ZZ', mapped);
			} else {
				domain[name] = attrib.name;
			}
		}

		function checkAttribFieldScopeName(attrib, field, scope, name) {
			if (scope) {
				var domain = reverse[scope];
				if (!$.isPlainObject(domain)) {
					reverse[scope] = domain = {};
				}

				checkAttribFieldUniqueName(attrib, field, domain, name);
			}
		}

		function checkAttribFieldUnique(attrib, field) {
			var name = field.name.toLowerCase();

			if (merged) {
				var scope = attrib[settings.merged];
				if ($.isArray(scope) && scope.length > 0) {
					for (var i = 0; i < scope.length; ++i) {
						checkAttribFieldScopeName(attrib, field, scope[i], name);
					}
				} else {
					checkAttribFieldScopeName(attrib, field, 'all', name);
				}

				return true;
			}

			checkAttribFieldUniqueName(attrib, field, reverse, name);
		}

		function checkOptionTargetUniqueName(attrib, field, option, target, unique, name) {
			var mapped = unique[name];
			if (mapped) {
				throw settings.valueMappingAmbigous.replace('XX', attrib.label || attrib.name).replace('YY', option.name).replace('ZZ', target.label || target.name).replace('WW', mapped);
			} else {
				unique[name] = option.name;
			}
		}

		function checkOptionTargetUniqueScopeName(attrib, field, option, target, unique, scope, name) {
			if (scope) {
				var domain = unique[scope];
				if (!$.isPlainObject(domain)) {
					unique[scope] = domain = {};
				}

				checkOptionTargetUniqueName(attrib, field, option, target, domain, name);
			}
		}

		function checkOptionTargetUnique(attrib, field, option, target, unique) {
			var name = target.name.toLowerCase();

			if (merged) {
				var scope = option[settings.merged];
				if ($.isArray(scope) && scope.length > 0) {
					for (var i = 0; i < scope.length; ++i) {
						checkOptionTargetUniqueScopeName(attrib, field, option, target, unique, scope[i], name);
					}
				} else {
					checkOptionTargetUniqueScopeName(attrib, field, option, target, unique, 'all', name);
				}

				return true;
			}

			checkOptionTargetUniqueName(attrib, field, option, target, unique, name);
		}

		function addAttrib() {
			var attRow = $(this);
			var attrib = attRow.data('attrib');
			if (attrib) {
				var field = attrib.target;
				if ($.isPlainObject(field) && field.name && (!field.id || field.id > 0)) {
					checkAttribFieldUnique(attrib, field);

					attrib = $.extend({}, attrib);

					delete attrib.ttid;
					delete attrib.mapping;
					delete attrib.nested;
					delete attrib.children;

					if (typeof field.id === "number" && field.id >= 0) {
						attrib.target = {
							id	 : field.id,
							name : field.name
						};
					} else {
						attrib.target = {
							name : field.name
						};
					}

					if (settings.bidirect) {
						var direction = attRow.find('td.direction').data('direction');
						if (direction == 'import') {
							attrib.target.sync = 1;
						} else if (direction == 'export') {
							attrib.target.sync = 2;
						}
					}

					if (field.type == 6 && attrib.options && attrib.options.length > 0) {
						var options     = [];
						var uniqueCheck = {};

						for (var j = 0; j < attrib.options.length; ++j) {
							var option = attrib.options[j];
							var target = option.target;

							if ($.isPlainObject(target) && target.name) {
								checkOptionTargetUnique(attrib, field, option, target, uniqueCheck);

								option = $.extend({}, option);
								delete option.ttid;
								delete option.attrib;

								if (typeof target.id === "number" && target.id >= 0) {
									option.target = {
										id	 : target.id,
										name : target.name
									};
								} else {
									option.target = {
										name : target.name
									};
								}
							} else {
								// Not allowed, you must choose/create a unique target
								throw settings.valueNotMapped.replace('XX', attrib.label || attrib.name).replace('YY', option.name);
							}

							options.push(option);
						}

						attrib.options = options;
					} else {
						delete attrib.options;
					}

					result.push(attrib);
				}

				if (settings.bidirect && checkExport && attrib.required && !(attrib.target && (typeof attrib.target.sync === "undefined" || (attrib.target.sync & 2) == 2))) {
					throw settings.requiredMissing.replace('XX', attrib.label || attrib.name);
				}
			}
		}

		if (this.is('tr')) {
			this.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + this.attr('data-tt-id') + '"]').each(addAttrib);
		} else {
			$('table.attribs tr.attrib', this).each(addAttrib);
		}

		return result;
	};


	// Set the attribute sync mode and target mapping from a stored mapping
	$.fn.setRemoteAttributeMapping = function(mapping) {
		var mapRemoteAttributes = this.data('mapRemoteAttributesPlugin');
		if ($.isPlainObject(mapRemoteAttributes) && $.isFunction(mapRemoteAttributes.setAttributesMapping)) {
			mapRemoteAttributes.setAttributesMapping(this, mapping);
		}

		return this;
	};


	// Ignore attributes, whose name starts with the specified prefix
	$.fn.ignoreRemoteAttributes = function(prefix) {
		var mapRemoteAttributes = this.data('mapRemoteAttributesPlugin');
		if ($.isPlainObject(mapRemoteAttributes) && $.isFunction(mapRemoteAttributes.ignoreAttributes)) {
			mapRemoteAttributes.ignoreAttributes(this, prefix);
		}

		return this;
	};


	// Import attributes, whose name starts with the specified prefix
	$.fn.importRemoteAttributes = function(prefix) {
		var mapRemoteAttributes = this.data('mapRemoteAttributesPlugin');
		if ($.isPlainObject(mapRemoteAttributes) && $.isFunction(mapRemoteAttributes.assignAttributes)) {
			mapRemoteAttributes.assignAttributes(this, prefix);
		}

		return this;
	};


	// Set whether the mapping of Remote user attributes to CodeBeamer principal fields is allowed or not
	$.fn.changeRemoteAttributeMapping = function(affected) {
		var mapRemoteAttributes = this.data('mapRemoteAttributesPlugin');
		if ($.isPlainObject(mapRemoteAttributes) && $.isFunction(mapRemoteAttributes.changeAttributeTargetType) && $.isArray(affected) && affected.length > 0) {
			function setTargetSelection() {
				var attrRow = $(this);

				mapRemoteAttributes.changeAttributeTargetType.call(attrRow, attrRow, affected);
			}

			if (this.is('tr')) {
				this.nextUntil(':not(tr.attrib,tr.option)', 'tr.attrib[data-tt-parent-id="' + this.attr('data-tt-id') + '"]').each(setTargetSelection);
			} else {
				$('table.attribs tr.attrib', this).each(setTargetSelection);
			}
		}

		return this;
	};


	// A plugin that allows to map remote link types and their attributes to target CodeBeamer associations and attributes
	$.fn.mapRemoteLinks = function(linkTypes, config) {
		var settings = $.extend( {}, $.fn.mapRemoteLinks.defaults, config, {
			expand : false
		});

		// The remote link type (name) to target assoc mapping
		var mapping = getMapping(settings.mapping);

		function getSetting(name) {
			return settings[name];
		}

		function getMapping(links) {
			if ($.isPlainObject(links)) {
				return links;
			}

			var result = {};

			if ($.isArray(links) && links.length > 0) {
				for (var i = 0; i < links.length; ++i) {
					var link = links[i];
					if ($.isPlainObject(link)) {
						var linkId = link[settings.linkTypeId];
						var target = link.target;

						if (linkId && target) {
							var linkMapping;

							if ($.isPlainObject(target)) {
								linkMapping = target;
							} else {
								linkMapping = {};

								if (typeof target === "number") {
									linkMapping.id = target;
								}
							}

							var attribs = link.attributes;
							if ($.isArray(attribs) && attribs.length > 0) {
								linkMapping.attributes = attribs;
							}

							result[linkId] = linkMapping;
						}
					}
				}
			}

			return result;
		}

   	  	function setDirection(direction, value) {
	  		var oldVal = direction.data('direction');
  			var clazz = (oldVal === 'synchronize' ? 'bidirect' : oldVal);
  			if (clazz) {
   	   	  		direction.removeClass(settings.editable ? 'editable ' + clazz : clazz);
  			}

  	  		var option = (value ? settings.attributes.direction[value] : null);
   	  		if ($.isPlainObject(option) && option.value) {
   	  			direction.data('direction', value);
   	  			direction.attr('title', option.title.replace('XXX', settings.valuesLabel));

   	  			clazz = (value === 'synchronize' ? 'bidirect' : value);
   	  			direction.addClass(settings.editable ? 'editable ' + clazz : clazz);
   	  		} else {
   	  			direction.removeData('direction');
   	  			direction.removeAttr('title');
   	  		}
    	}

		function resetDirection(direction, linkType) {
			if (settings.bidirect && $.isPlainObject(linkType.target) && linkType.target.id > 0) {
				setDirection(direction, direction.data('direction') || 'synchronize');
			} else {
				setDirection(direction, null);
			}
		}

		function setupDirection(linkType, direction, target) {
			if (settings.bidirect) {
				if ($.isPlainObject(target) && target.sync) {
					direction.data('direction', target.sync == 3 ? 'synchronize' : (target.sync == 2 ? 'export' : 'import'));
				}

				resetDirection(direction, linkType);
			}
		}

		function findAssocType(assocType) {
			if ($.isPlainObject(assocType) && assocType.id > 0) {
				for (var i = 0; i < settings.assocTypes.length; ++i) {
					if (settings.assocTypes[i].id === assocType.id) {
						return settings.assocTypes[i];
					}
				}
			}

			return null;
		}

   	  	function getAssocTypeSelector(target) {
			var selector = $('<select>', { "class" : 'assocType', title : settings.selectLinkTitle });

			selector.append($('<option>', {
			   "class"   : 'assocType',
				value    : "-IGNORE-",
				title    : settings.ignoreLinkTitle,
				style    : 'font-style: italic;',
				selected : !(target && target.id != -1)
		    }).text('-- ' + settings.ignoreLinkLabel + ' --').data("assocType", {id : -1}));

			if ($.isArray(settings.assocTypes)) {
				for (var i = 0; i < settings.assocTypes.length; ++i) {
					var option = settings.assocTypes[i];

					selector.append($('<option>', {
					   "class"   : 'assocType',
						value    : option.id,
						title    : option.description,
						selected : target && target.id === option.id
					}).text(option.name).data("assocType", option));
				}
			}

			return selector;
   	  	}

		function getAssocTypeLabel(assocType) {
			var result = $('<span>');

			if (assocType && assocType.id > 0) {
				result.attr('title', assocType.description).css('font-weight', 'bold').text(assocType.label || assocType.name);
			} else {
				result.attr('class', 'subtext').css('color', 'gray').text('-- ' + settings.ignoreLinkLabel + ' --');
			}

			if (settings.editable) {
				result.append($('<img>', {
				   "class": 'inlineEdit',
					src   : contextPath + '/images/inlineEdit.png',
					title : settings.clickToEditField
				}));
			}

			return result;
		}

		function setAssocType(value) {
	        var linkRow  = $(this).closest('tr.linkType');
	       	var linkType = linkRow.data('linkType');

	       	resetDirection(linkRow.find('td.direction'), linkType);

			if (settings.expand) {
				try {
					linkRow.closest('table').treetable(linkType.target && linkType.target.id > 0 ? "expandNode" : "collapseNode", linkRow.attr('data-tt-id'));
				} catch(e) {
					showFancyAlertDialog(e.stack);
				}
			}

			return getAssocTypeLabel(linkType.target)[0].outerHTML;
		}

		function setupLinkTarget(linkType, target) {
			target.append(getAssocTypeLabel(linkType.target));

			if (settings.editable) {
				target.editable(setAssocType, {
			        type   : 'assocType',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}
		}

		function resetLinkTarget() {
	        var linkRow  = $(this);
	       	var linkType = linkRow.data('linkType');
			if (linkType) {
		       	resetDirection(linkRow.find('td.direction'), linkType);
				linkRow.find('td.linkTarget').empty().append(getAssocTypeLabel(linkType.target));
			}
		}

		function setupTargetAssoc(linkType, linkDir, linkTarget) {
			var target = mapping[linkType[settings.linkTypeId]];

			if (!$.isPlainObject(target)) {
				target = {
					id 		   : -1,
					attributes : []
				};
			}

			linkType.target = findAssocType(target);

			setupLinkTarget(linkType, linkTarget);
			setupDirection(linkType, linkDir, target);

			return target;
		}

		function ignoreLinkAttributes(key, options) {
	        options.$trigger.closest('tr.linkType').ignoreRemoteAttributes(key);
		}

		function importLinkAttributes(key, options) {
	        options.$trigger.closest('tr.linkType').importRemoteAttributes(key);
		}

		function buildLinkAttributesMenu($trigger, event) {
	        var linkRow  = $trigger.closest('tr.linkType');
	       	var linkType = linkRow.data('linkType');
			if (linkType) {
				var attributes = linkType.attributes;
				if ($.isArray(attributes) && attributes.length > 1) {
					var ignore = $trigger.hasClass('ignore');

					return buildPrefixesMenu(ignore ? {
		        		"ignore_-ALL-" : {
		    			    name : '*'
		        		}
					} : {
		        		"-ALL-" : {
		    			    name : '-- ' + settings.attributes.unmappedAttributes + ' --'
		        		}
					}, ignore ? 'ignore_' : '', getNamePrefixes($.map(attributes, function(attrib) {
						return attrib.name;
					})), ignore ? ignoreLinkAttributes : importLinkAttributes);
				}
			}

			event.preventDefault();
			return false;
		}

		function setupLinkTypes(tbody, nodeId, linkTypes) {
			if ($.isArray(linkTypes) && linkTypes.length > 0) {
				var parentId = nodeId;

				for (var i = 0; i < linkTypes.length; ++i) {
					var linkType   = linkTypes[i];
					var typeId     = ++nodeId;
					var typeRow    = $('<tr>', { "class" : 'linkType odd', "data-tt-id" : typeId }).data('linkType', linkType);
					var typeName   = $('<td>', { "class" : 'relationName', title : linkType.description, style: 'vertical-align: middle; white-space: nowrap; width: 50%;' }).text(linkType.name);
					var typeDir    = $('<td>', { "class" : 'direction',  style: 'width: 20px; min-width: 20px;' });
					var typeTarget = $('<td>', { "class" : 'linkTarget', style : 'vertical-align: middle;' });

					if (parentId > 0) {
						typeRow.attr("data-tt-parent-id", parentId);
					}

					typeRow.append(typeName);
					typeRow.append(typeDir);
					typeRow.append(typeTarget);

					tbody.append(typeRow);

					var target     = setupTargetAssoc(linkType, typeDir, typeTarget);
					var attributes = linkType.attributes;

					if ($.isArray(attributes) && attributes.length > 0) {
						if (settings.editable && attributes.length > 1) {
							typeName.append($('<span>', {
								"class" : 'ui-icon ui-icon-circle-arrow-n edit-link-attribs ignore',
								 style  : 'margin-left: 6px;',
								 title  : settings.attributes.ignoreAllLabel
							}));

							typeName.append($('<span>', {
								"class" : 'ui-icon ui-icon-circle-arrow-s edit-link-attribs import',
								 title  : settings.attributes.selectAllLabel
							}));
						}

						typeRow.mapRemoteAttributes(attributes, $.extend({}, settings.attributes, {
							fields  : settings.attributes.fields.slice(0),
							mapping : target.attributes,
							indent  : 1
						}));
					}
				}
			}

			return nodeId;
		}

   	  	function setLinkMapping(typeRow, mapping) {
			var linkType = typeRow.data('linkType');
			var typeId   = linkType[settings.linkTypeId];
			var target   = mapping[typeId];

			if (typeof target === "number") {
				target = {
					id : target
				};
			}

			linkType.target = findAssocType(target);

			if (settings.bidirect && $.isPlainObject(target) && target.sync) {
				typeRow.find('td.direction').data('direction', target.sync == 3 ? 'synchronize' : (target.sync == 2 ? 'export' : 'import'));
			}

			resetLinkTarget.apply(typeRow);

			if (settings.expand && !(linkType.target && linkType.target.id > 0)) {
				try {
					typeRow.closest('table').treetable("collapseNode", typeRow.attr('data-tt-id'));
				} catch(e) {
					showFancyAlertDialog(e.stack);
				}
			}

			if ($.isArray(linkType.attributes) && linkType.attributes.length > 0) {
				typeRow.setRemoteAttributeMapping(target.attributes);
			}
   	  	}

   	  	function setLinkTypeMapping(container, links) {
   	  		var mapping = getMapping(links);

   	 		function setLinkTarget() {
   	 			setLinkMapping($(this), mapping);
   			}

			if (container.is('tr')) {
				container.nextAll('tr.linkType[data-tt-parent-id="' + container.attr('data-tt-id') + '"]').each(setLinkTarget);
			} else {
				$('table.linkTypes tr.linkType', container).each(setLinkTarget);
			}
   	  	}

		function init(container, linkTypes) {
			var nodeId = 0;
			var tbody  = null;

			if (container.is('tr')) {
				tbody  = container.closest('tbody');
				nodeId = parseInt(container.attr('data-tt-id'));
				nodeId = setupLinkTypes(tbody, nodeId, linkTypes);
			} else {
				var table = $('<table>', { "class" : 'displaytag linkTypes', style: 'border: 1px solid silver;'});
				container.append(table);

//				var header = $('<thead>');
//				table.append(header);
//
//				var headline = $('<tr>',  { "class" : 'head', style: 'vertical-align: middle;' });
//				headline.append($('<th>', { "class" : 'textData', style: 'padding-left: 20px !important; vertical-align: middle; width: 50%;' }).text(settings.linkTypeLabel));
//				headline.append($('<th>', { "class" : 'textData' }).text(settings.mappingLabel));
//
//				header.append(headline);

				tbody = $('<tbody>');
				table.append(tbody);

				nodeId = setupLinkTypes(tbody, nodeId, linkTypes);

				table.treetable({
					expandable   : true,
					initialState : 'collapsed'
				});
			}

			container.data('mapRemoteLinksPlugin', {
				setLinkTypeMapping : setLinkTypeMapping
			});

			settings.expand = true;
		}

		function setup() {
			/* Define an inplace editor for the target assoc type of link types  */
		    $.editable.addInputType('assocType', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		        	var linkType = $(self).closest('tr.linkType').data('linkType');
		           	var selector = getAssocTypeSelector(linkType.target).change(function() {
	           			linkType.target = selector.find('option.assocType:selected').data('assocType');

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
		        selector : 'tr.linkType td.direction.editable',
		        trigger  : 'left',
		        items	 : {
		        	"ignore" : {
		        		name : getSetting('attributes').direction["ignore"].label.replace('XXX', getSetting('linksLabel'))
		        	},

		        	"import" : {
		        		name : getSetting('attributes').direction["import"].label.replace('XXX', getSetting('linksLabel'))
		        	},

		        	"export" : {
		        		name : getSetting('attributes').direction["export"].label.replace('XXX', getSetting('linksLabel'))
		        	},

		        	"synchronize" : {
		        		name : getSetting('attributes').direction["synchronize"].label.replace('XXX', getSetting('linksLabel'))
		        	}
		        },
		        callback : function(key, options) {
		        	setDirection(options.$trigger, key);

		        	if (key === 'ignore') {
		    	        var linkRow  = options.$trigger.closest('tr.linkType');
		    	       	var linkType = linkRow.data('linkType');
		    			if (linkType) {
		    				delete linkType.target;

		    				linkRow.find('td.linkTarget').empty().append(getAssocTypeLabel(linkType.target));
		    			}
		        	}
		        }
		    });

		    $.contextMenu({
				selector : '.edit-link-attribs',
				trigger  : 'left',
		   	  	position : function(opt) {
					opt.$menu.position({
						my  : "left top",
						at  : "left top",
					   "of" : $(this).parent().find('.edit-link-attribs:first')
					});
				},
				build : buildLinkAttributesMenu
			});
		}

		if ($.fn.mapRemoteLinks._setup) {
			$.fn.mapRemoteLinks._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), linkTypes);
		});
	};

	$.fn.mapRemoteLinks._setup = true;

	$.fn.mapRemoteLinks.defaults = {
		editable		: true,
		bidirect		: false,
		merged			: false,
		label			: 'Link Types',
		title			: 'The importable link types of the selected remote objects',
		none			: 'There are no importable link types of the selected remote objects',
		linkTypeId		: 'id',
		linkTypeLabel 	: 'Link Type',
		mappingLabel  	: 'Mapping',
		linksLabel		: 'Links',
		selectLinkLabel	: 'Please select',
		selectLinkTitle	: 'You must choose a predefined association type',
		ignoreLinkLabel	: 'Ignore links',
		ignoreLinkTitle	: 'Links of this type will be ignored (not imported)!',
		linkMappingAmbigous	: 'Link Type "XX" is mapped to the same association type ("YY") as link type "ZZ"'
	};


	// Get the mapping of Remote link types and their attributes to target CodeBeamer associations and attributes
	$.fn.getRemoteLinkMapping = function(settings) {
		var reverse = {};
		var merged  = (typeof settings.linkTypes.merged === "string");
		var result  = [];

		function checkLinkTypeAssocUniqueId(linkType, assocType, unique, id) {
			var mapped = unique[id];
			if (mapped) {
				throw settings.linkTypes.linkMappingAmbigous.replace('XX', linkType.name).replace('YY', assocType.label || assocType.name).replace('ZZ', mapped);
			} else {
				unique[id] = linkType.name;
			}
		}

		function checkLinkTypeAssocScopeId(linkType, assocType, scope, id) {
			if (scope) {
				var domain = reverse[scope];
				if (!$.isPlainObject(domain)) {
					reverse[scope] = domain = {};
				}

				checkLinkTypeAssocUniqueId(linkType, assocType, domain, id);
			}
		}

		function checkLinkTypeAssocUnique(linkType, assocType) {
			var assocIdStr = assocType.id.toString();

			if (merged) {
				var scope = linkType[settings.linkTypes.merged];
				if ($.isArray(scope) && scope.length > 0) {
					for (var i = 0; i < scope.length; ++i) {
						checkLinkTypeAssocScopeId(linkType, assocType, scope[i], assocIdStr);
					}
				} else {
					checkLinkTypeAssocScopeId(linkType, assocType, 'all', assocIdStr);
				}

				return true;
			}

			checkLinkTypeAssocUniqueId(linkType, assocType, reverse, assocIdStr);
		}

		function addLinkType() {
			var typeRow   = $(this);
			var linkType  = typeRow.data('linkType');
			var assocType = linkType.target;

			if (assocType && assocType.id >= 0) {
				var linkTypeId = linkType[settings.linkTypes.linkTypeId];
				if (linkTypeId != 'External') {
					checkLinkTypeAssocUnique(linkType, assocType);
				}

				linkType = $.extend({}, linkType);

				if (settings.bidirect) {
					var direction = $('td.direction', typeRow).data('direction');
					if (direction == 'import') {
						linkType.target = {
							id   : assocType.id,
							sync : 1
						};
					} else if (direction == 'export') {
						linkType.target = {
							id   : assocType.id,
							sync : 2
						};
					} else {
						linkType.target = assocType.id;
					}
				} else {
					linkType.target = assocType.id;
				}

				if (linkType.attributes && linkType.attributes.length > 0) {
					try {
						linkType.attributes = typeRow.getRemoteAttributeMapping(settings.attributes, false);
					} catch(error) {
						throw settings.linkTypes.linkTypeLabel + ' "' + linkType.name + '": ' + error;
					}
				}

				result.push(linkType);
			}
		}

		if (this.is('tr')) {
			this.nextAll('tr.linkType[data-tt-parent-id="' + this.attr('data-tt-id') + '"]').each(addLinkType);
		} else {
			$('table.linkTypes tr.linkType', this).each(addLinkType);
		}

		return result;
	};

	// Get the mapping of Remote link types and their attributes to target CodeBeamer associations and attributes
	$.fn.setRemoteLinkMapping = function(mapping) {
		var mapRemoteLinks = this.data('mapRemoteLinksPlugin');
		if ($.isPlainObject(mapRemoteLinks) && $.isFunction(mapRemoteLinks.setLinkTypeMapping)) {
			mapRemoteLinks.setLinkTypeMapping(this, mapping);
		}
		return this;
	};


	// Get the mapping of Remote link types and their attributes to target CodeBeamer associations and attributes
	$.fn.changeRemoteLinkAttributeMapping = function(affected) {

		function setLinkUserAttribs() {
			$(this).changeRemoteAttributeMapping(affected);
		}

		if ($.isArray(affected) && affected.length > 0) {
			if (this.is('tr')) {
				this.nextAll('tr.linkType[data-tt-parent-id="' + this.attr('data-tt-id') + '"]').each(setLinkUserAttribs);
			} else {
				$('table.linkTypes tr.linkType', this).each(setLinkUserAttribs);
			}
		}

		return this;
	};


	// Plugin to edit remote connections
	$.fn.editRemoteConnection = function(connection, options) {
		var settings = $.extend({}, $.fn.editRemoteConnection.defaults, options);

		function testServer() {
			var url = $.trim($(this).prev().val());
			if (url && url.length > 0) {
				var busy = ajaxBusyIndicator.showProcessingPage();

				$.ajax(settings.server.test.url, {
					type: 'POST',
					data: { url: url },
					cache : false
			    }).done(function(result) {
					ajaxBusyIndicator.close(busy);

					if (result) {
						var msg = settings.server.test.success;
						if (typeof result === 'string') {
							msg += ': ' + result;
						}
						showFancyAlertDialog(msg, 'information');
					} else {
						showFancyAlertDialog(settings.server.test.failed);
					}
				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
		        });
			}
		}

		function init(table, connection) {
			if (!$.isPlainObject(connection)) {
				connection = {};
			}

			var line = $('<tr>', { title : settings.server.title });
			table.append(line);

			var label = $('<td>', { "class" : 'labelCell optional' }).text(settings.server.label + ':');
			line.append(label);

			var content = $('<td>', { "class" : 'dataCell', colspan : 3});
			line.append(content);

			if (settings.editable) {
				content.append($('<input>', { type : 'text', name : 'server', maxlength : 255, value : connection.server }).attr("size", "80"));

				if ($.isPlainObject(settings.server.test) && settings.server.test.url) {
					content.append($('<button>', {
						title : settings.server.test.title,
						style : 'margin-left: 3px;'
					}).text(settings.server.test.label).click(testServer));
				}
			} else {
				content.text(connection.server || '--');
			}

			line = $('<tr>');
			table.append(line);

			label = $('<td>', { "class" : 'labelCell optional', title : settings.username.title }).text(settings.username.label + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell', title : settings.username.title, style : 'width: 30%;' });
			line.append(content);

			if (settings.editable) {
				content.append($('<input>', { type : 'text', name : 'username', maxlength : 80, value : connection.username }).attr("size", "20"));
			} else {
				content.text(connection.username || '--');
			}

			label = $('<td>', { "class" : 'labelCell optional', title : settings.password.title }).text(settings.password.label + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell', title : settings.password.title });
			line.append(content);

			if (settings.editable) {
				content.append($('<input>', { type : 'password', name : 'password', maxlength : 80, value : connection.password }).attr("size", "20"));
			} else {
				content.text('******');
			}

			if (!settings.editable) {
				table.data('connection', {
					server   : connection.server,
					username : connection.username,
					password : connection.password
				});
			}
		}

		return this.each(function() {
			init($(this), connection);
		});
	};


	$.fn.editRemoteConnection.defaults = {
		editable 	: true,

		server	 		: {
			label   	: 'Server',
			tooltip 	: 'The URL (web address) of the remote server/host',
			required	: 'Please enter the URL (web address) of the remote server/host',
			test		: {
				label	: 'Test',
				title	: 'Test, if there is a server of the expected type, at the entered URL (web address)',
				success : 'Server test was successful',
				failed  : 'Server test failed: Did not find a server of the expected type, at the entered URL (web address) !',
				url		: null
			}
		},

		username 		: {
			label 		: 'Username',
			title 		: 'The username to login at the remote server/host. Can be ommitted, if the remote server allows anonymous access.',
			required	: 'Please enter a username and password to authenticate at the specified server'
		},

		password		: {
			label		: 'Password',
			title		: 'The password to authenticate at the remote server/host. Can be ommitted, if the remote server allows anonymous access.'
		}
	};


	// Get the edited remote connection
	$.fn.getRemoteConnection = function() {
		var result = $(this).data('connection');

		if (!$.isPlainObject(result)) {
			result = {
				server   : $.trim($('input[name="server"]',	  this).val()),
				username : $.trim($('input[name="username"]', this).val()),
				password :        $('input[name="password"]', this).val(),
			};
		}
		return result;
	};


	// Plugin to map remote objects to tracker items including (attributes and options, attachments, comments, history, etc.) and remote links to associations
	$.fn.mapRemoteObjects = function(mapping, settings, rows) {
//		var settings = $.extend(true, {}, $.fn.mapRemoteObjects.defaults, options );
		var checkboxes = {};
		var sections   = {};

		function getSetting(name) {
			return settings[name];
		}

		function checkBoxChanged() {
			var name = $(this).attr('name');
			var option = checkboxes[name];
			if (option) {
				var checked = option.checkbox.is(':checked');

				if ($.isFunction(option.change)) {
					option.change(checked);
				}

				if ($.isFunction(option.attribs)) {
					var affects = [{
						attribs  : option.attribs,
						allowed  : checked
					}];

					// When allowing to map users, also allow to map submitted at/last modified at dates
					if (name == 'users' && $.isPlainObject(settings.dates)) {
						// BUG-1232883: Also select/deselect SubmittedAt/LastModifiedAt dates, when selecting/deselecting Users
						affects.push($.extend({}, settings.dates, {
							allowed : checked
						}));
					}

					var controls = option.controls;
					if ($.isArray(controls) && controls.length > 0) {
						for (var i = 0; i < controls.length; ++i) {
							var controlled = settings[controls[i]];
							if ($.isPlainObject(controlled) && $.isFunction(controlled.attribs)) {
								var allowed = checked;
								if (allowed && controlled.rights) {
									allowed = false;

									if ($.isArray(controlled.rights)) {
										for (var i = 0; i < controlled.rights.length; ++i) {
											if (mapping[controlled.rights[i]]) {
												allowed = true;
												break;
											}
										}
									} else if (mapping[controlled.rights]) {
										allowed = true;
									}
								}

								affects.push($.extend({}, controlled, {
									allowed : allowed
								}));
							}
						}
					}

					if ($.isPlainObject(settings.attributes) && settings.attributes.cell) {
						settings.attributes.cell.changeRemoteAttributeMapping(affects);
					}

					// Associations cannot have reference fields, only user references !!
					if (name == 'users' && $.isPlainObject(settings.linkTypes) && settings.linkTypes.cell) {
						settings.linkTypes.cell.changeRemoteLinkAttributeMapping(affects);
					}
				}

				if (option.controlled.length > 0) {
					var attrs = checked ? {
						disabled : !settings.editable
					} : {
						disabled : true,
						checked  : false
					};

					for (var i = 0; i < option.controlled.length; ++i) {
						var controlled = checkboxes[option.controlled[i]];
						if (controlled) {
							controlled.checkbox.attr(attrs);
						}
					}
				}
			} else {
				showFancyAlertDialog("No such checkbox: " + name);
			}
		}

		function createCheckBoxes(container, checkBoxes, mapping) {
			if ($.isArray(checkBoxes) && checkBoxes.length > 0) {
				for (var i = 0; i < checkBoxes.length; ++i) {
					if (typeof checkBoxes[i] === "string") {
						var name     = checkBoxes[i];
						var checkBox = settings[name];

						if ($.isPlainObject(checkBox)) {
							var checked = mapping[name];
							var enabled = settings.editable;
							if (enabled && checkBox.rights) {
								enabled = false;

								if ($.isArray(checkBox.rights)) {
									for (var i = 0; i < checkBox.rights.length; ++i) {
										if (mapping[checkBox.rights[i]]) {
											enabled = true;
											break;
										}
									}
								} else if (mapping[checkBox.rights]) {
									enabled = true;
								}
							}

							if (checkBox.depends) {
								var controller = checkboxes[checkBox.depends];
								if (controller) {
									controller.controlled.push(name);

									if (!controller.checkbox.is(':checked')) {
										checked = false;
										enabled = false;
									}
								} else {
									showFancyAlertDialog("No such checkbox: " + name + ".depends=" + checkBox.depends);
								}
							}

							var control = $('<input>', { type : 'checkbox', name : name, title : checkBox.title, value : 'true', checked : checked, disabled : !enabled });
							container.append(control);

							var label = $('<span>', { title : checkBox.title, style : 'margin-right: 2em;' }).text(checkBox.label || name);
							container.append(label);

							if (settings.editable) {
								label.click(function() {
									$(this).prev('input[type="checkbox"]').click();
								});
							}

							checkboxes[name] = $.extend({}, checkBox, {
								checkbox 	: control,
								controlled	: []
							});

							control.change(checkBoxChanged);
						}
					}
				}
			}
		}

		function getDirectionLabel(value, options) {
			var config = settings.direction;
			var option = config["import"];
			var mode   = config.unidirect;

			if ($.isArray(options)) {
				for (var i = 0; i < options.length; ++i) {
					var name = options[i];

					var check = config[name];
					if ($.isPlainObject(check) && check.value === value) {
						option = check;

						if (name === 'synchronize') {
							mode = config.bidirect;
						}
						break;
					}
				}
			}

			var label = $('<label>', { title : option.title.replace('XXX', mode.title) }).text(option.label.replace('XXX', mode.label));

			if (settings.editable) {
				label.append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.attributes.clickToEditValue
				}));
			}

			return label;
		}

		function setDirection(value) {
			var options = $(this).data('options');

			mapping.direction = parseInt(value);

			return getDirectionLabel(mapping.direction, options)[0].outerHTML;
		}

		function setupDirection(container, options) {
			container.append(getDirectionLabel(mapping.direction || 1, options));

			if (settings.editable) {
				container.data('options', options).editable(setDirection, {
			        type   : 'syncDirection',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}
		}

		function getSyncLogLabel(value) {
			var text = (value === -1 ? settings.log.all : settings.log.lastX.replace('XXX', value));
			var label = $('<label>', { title : settings.log.prefix + ' ' + text + ' ' + settings.log.suffix }).text(text);

			if (settings.editable) {
				label.append($('<img>', {
				   "class" : 'inlineEdit',
					src    : contextPath + '/images/inlineEdit.png',
					title  : settings.attributes.clickToEditValue
				}));
			}

			return label;
		}

		function setSyncLog(value) {
			return getSyncLogLabel(mapping.log = parseInt(value))[0].outerHTML;
		}

		function setupSyncLog(container, options) {
			container.append(getSyncLogLabel(mapping.log || -1));

			if (settings.editable) {
				container.data('options', options).editable(setSyncLog, {
			        type   : 'syncLog',
			        event  : 'click',
			        onblur : 'cancel'
			    });
			}
		}

		function getSelector(clazz, options, config) {
			var option;
			var value = parseInt(mapping[clazz]);
			var mode = {
				label : '',
				title : ''
			};

			var selector = $('<select>', {
			   "class"   : clazz,
				title    : config.title || ''
			});

			for (var i = 0; i < options.length; ++i) {
				if (clazz === 'log') {
					mode.label = options[i];
					option = {
						value : options[i],
						label : options[i] === -1 ? config.all : config.lastX,
					    title : ''
					};
				} else {
					option = config[options[i]];
					mode   = (options[i] == 'synchronize' ? config.bidirect : config.unidirect);
				}

				if ($.isPlainObject(option) && option.value && option.label) {
					selector.append($('<option>', {
					   "class"   : clazz,
						value    : option.value,
						title    : option.title.replace('XXX', mode.title),
						selected : (option.value === value)
					}).text(option.label.replace('XXX', mode.label)));
				}
			}

			return selector;
		}

		function mapAttributes(attributes) {
			if ($.isPlainObject(settings.attributes) && settings.attributes.mapping) {
				var labelCell = settings.attributes.cell.prev('td.labelCell');
				labelCell.find('br, span.edit-attribs').remove();
				labelCell.removeClass('attributesLabel');

				if ($.isArray(attributes) && attributes.length > 0) {
					var affects = [];

					settings.attributes.cell.mapRemoteAttributes(attributes, $.extend({}, settings.attributes, {
						editable		: settings.editable,
						direction		: settings.direction,
						mapping      	: mapping[settings.attributes.mapping],
						fields			: mapping.objectFields,
						reservedFields	: mapping.reservedFields,
						designatedField	: mapping.designatedField,
						dedicatedField	: mapping.dedicatedField
					}));

					$.each(checkboxes, function(name, checkbox) {
						if ($.isFunction(checkbox.attribs) && !checkbox.checkbox.is(':checked')) {
							affects.push({
								attribs : checkbox.attribs,
								allowed : false
							});

							var controls = checkbox.controls;
							if ($.isArray(controls) && controls.length > 0) {
								for (var i = 0; i < controls.length; ++i) {
									var controlled = settings[controls[i]];
									if ($.isPlainObject(controlled) && $.isFunction(controlled.attribs)) {
										affects.push($.extend({}, controlled, {
											allowed : false
										}));
									}
								}
							}
						}
					});

					settings.attributes.cell.changeRemoteAttributeMapping(affects);
					settings.attributes.cell.data('attributes', attributes);

					if (settings.editable && attributes.length > 1 && labelCell.length > 0) {
						labelCell.addClass('attributesLabel').append($('<br>'));

						labelCell.append($('<span>', {
							"class" : 'ui-icon ui-icon-circle-arrow-w edit-attribs ignore',
							 title  : settings.attributes.ignoreAllLabel
						}));

						labelCell.append($('<span>', {
							"class" : 'ui-icon ui-icon-circle-arrow-e edit-attribs import',
							 title  : settings.attributes.selectAllLabel
						}));
					}
				} else {
					settings.attributes.cell.removeData('attributes');
					settings.attributes.cell.append($('<div>', {"class" : 'subtext'}).text(settings.attributes.none));
				}
			}
		}

		function ignoreAttributes(key) {
			settings.attributes.cell.ignoreRemoteAttributes(key);
		}

		function importAttributes(key) {
			settings.attributes.cell.importRemoteAttributes(key);
		}

		function buildAttributesMenu($trigger, event) {
			if ($.isPlainObject(settings.attributes) && settings.attributes.cell) {
				var attributes = settings.attributes.cell.data('attributes');
				if ($.isArray(attributes) && attributes.length > 0) {
					var ignore = $trigger.hasClass('ignore');

					return buildPrefixesMenu(ignore ? {
		        		"ignore_-ALL-" : {
		    			    name : '*'
		        		}
					} : {
		        		"-ALL-" : {
		    			    name : '-- ' + settings.attributes.unmappedAttributes + ' --'
		        		}
					}, ignore ? 'ignore_' : '', getNamePrefixes($.map(attributes, function(attrib) {
						return attrib.name;
					})), ignore ? ignoreAttributes : importAttributes);
				}
			}

			event.preventDefault();
			return false;
		}

		function mapLinkTypes(linkTypes) {
			if ($.isPlainObject(settings.linkTypes) && settings.linkTypes.mapping) {
				if ($.isArray(linkTypes) && linkTypes.length > 0) {
					var users = checkboxes.users;

					settings.linkTypes.cell.mapRemoteLinks(linkTypes, $.extend({}, settings.linkTypes, {
						editable	: settings.editable,
						assocTypes	: mapping.assocTypes,
						mapping     : mapping[settings.linkTypes.mapping],

						attributes	: $.extend({}, settings.attributes, {
							editable		: settings.editable,
							direction		: settings.direction,
							fields			: mapping.linkFields,
							reservedFields	: mapping.reservedFields,
							designatedField	: mapping.designatedField,
							dedicatedField	: mapping.dedicatedField
						})
					}));

					// Associations cannot have reference fields, only user references !!
					if (users && $.isFunction(users.attribs) && !users.checkbox.is(':checked')) {
						settings.linkTypes.cell.changeRemoteLinkAttributeMapping([{
							attribs : users.attribs,
							allowed : false
						}]);
					}
				} else {
					settings.linkTypes.cell.append($('<div>', {"class" : 'subtext'}).text(settings.linkTypes.none));
				}
			}
		}

		function applyMetaData(metaData) {
			if ($.isPlainObject(metaData)) {
				mapAttributes(metaData.attributes);
				mapLinkTypes(metaData.linkTypes);

				$.each(sections, function(name, section) {
					section.show();
				});
			} else {
				$.each(sections, function(name, section) {
					section.hide();
				});
			}
		}

		function loadMetaData(request) {
			var busy = ajaxBusyIndicator.showBusyPage(request.loading || 'Loading Meta Data ...');

		    $.ajax(request.url, {
		    	type 	    : 'POST',
				contentType : 'application/json',
		    	dataType 	: 'json',
				data 		: JSON.stringify(request.params),
		    	cache	 	: false
		    }).done(function(metaData) {
				ajaxBusyIndicator.close(busy);

				if ($.isFunction(request.callback)) {
					request.callback(metaData, checkboxes);
				}

				applyMetaData(metaData);

		    }).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
				showAjaxError(jqXHR, textStatus, errorThrown);
		    });
		}

		function objectsChanged(table, metaDataRequest) {
			if ($.isPlainObject(settings.attributes) && settings.attributes.cell) {
				settings.attributes.cell.empty();
			}

			if ($.isPlainObject(settings.linkTypes) && settings.linkTypes.cell) {
				settings.linkTypes.cell.empty();
			}

			if ($.isPlainObject(metaDataRequest) && metaDataRequest.url) {
				if (table && settings.server) {
					metaDataRequest = $.extend({}, metaDataRequest, {
						params : $.extend(table.getRemoteConnection(), metaDataRequest.params)
					});
				}

				loadMetaData(metaDataRequest);
			} else {
				applyMetaData(null);
			}
		}

		function createContent(table, cell, mapping, name, config, content) {
			if ($.isFunction(content)) {
				content(table, cell, objectsChanged, mapping, settings);
			} else if ($.isArray(content)) {
				if (name === 'direction') {
					setupDirection(cell, content);
				} else if (name === 'log') {
					setupSyncLog(cell, content);
				} else {
					createCheckBoxes(cell, content, mapping);
				}
			} else if (typeof content === "string") {
				cell.text(content);
			} else {
				cell.append(content);
			}
		}

		function init(form, mapping, rows) {
			if (!$.isPlainObject(mapping)) {
				mapping = {};
			}

			form.helpLink(settings.help);

			var table = $('<table>', { "class" : 'mapping formTableWithSpacing', style : 'width: 100%;' }).data('mapping', mapping);
			form.append(table);

			if (settings.server) {
				table.editRemoteConnection(mapping, settings);
			}

			if ($.isArray(rows)) {
				for (var i = 0; i < rows.length; ++i) {
					var row = rows[i];

					if ((row === 'attributes' || row === 'linkTypes') && $.isPlainObject(settings[row]) && settings[row].mapping) {
						row = {
							name 	: row,
						   "class"  : settings[row].mapping,
						    style   : 'vertical-align: top;',
						    depends	: true
						};
					} else if (row === 'interval') {
						row = {
							name 	: row,
							content : settings.editable ? $('<input>', {
								type	  : 'text',
								name	  : 'interval',
								title 	  : settings.interval.title,
								maxlength : 20,
								value 	  : mapping.interval,
								disabled  : !settings.editable
							}).attr("size", "5") : mapping.interval || '--',

						    depends	: true,
						    second  : {
						    	name 	: 'log',
								content : settings.log.options
						    }
						};
					}

					if ($.isPlainObject(row) && row.name) {
						var name   = row.name;
						var style  = row.style || 'vertical-align: middle;';
						var config = $.isPlainObject(settings[name]) ? settings[name] : {};

						var line = $('<tr>', { style : style + (row.depends ? ' display: None;' : '' )});
						table.append(line);

						var label = $('<td>', { "class" : 'labelCell optional', title : config.title || name, style : style }).text((config.label || name) + ':');
						line.append(label);

						var cell = $('<td>', { "class" : 'dataCell ' + (row["class"] || name), style : style });

						if ($.isPlainObject(row.second)) {
							cell.css('width', '30%');
						} else {
							cell.attr('colspan', 3);
						}
						line.append(cell);

						if (row.content) {
							createContent(table, cell, mapping, name, config, row.content);
						} else {
							config.cell = cell;
						}

						if (row.depends) {
							sections[name] = line;
						}

						if ($.isPlainObject(row.second) && row.second.content) {
							if (row.second.name) {
								name   = row.second.name;
								config = $.isPlainObject(settings[name]) ? settings[name] : {};
								label  = $('<td>', { "class" : 'labelCell optional', title : config.title || name, style : style }).text((config.label || name) + ':');
							} else {
								name   = "";
								config = {};
								label  = $('<td>', { "class" : 'labelCell optional' });
							}

							line.append(label);

							cell = $('<td>', { "class" : 'dataCell ' + (row["class"] || name), style : style });
							line.append(cell);

							createContent(table, cell, mapping, name, config, row.second.content);
						}
					}
				}
			}

			table.data('checkboxes', checkboxes);
			form.data('sections', sections);
		}

		function setup() {
			// Define an inplace editor for the synchronization direction
		    $.editable.addInputType('syncDirection', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		           	var selector = getSelector('direction', $(self).data('options'), getSetting('direction')).change(function() {
		           		form.submit();
		           	});

		           	form.append(selector);

		           	return selector;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });

			// Define an inplace editor for the synchronization history/log
		    $.editable.addInputType('syncLog', {
		        element : function(settings, self) {
		        	var form 	 = $(this);
		           	var selector = getSelector('log', $(self).data('options'), getSetting('log')).change(function() {
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
				selector : '.edit-attribs',
				trigger  : 'left',
				build 	 : buildAttributesMenu
			});
		}

		if ($.fn.mapRemoteObjects._setup) {
			$.fn.mapRemoteObjects._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), mapping, rows);
		});
	};


	$.fn.mapRemoteObjects._setup = true;

	$.fn.mapRemoteObjects.defaults = $.extend({}, $.fn.editRemoteConnection.defaults, {
		enabled		: {
			label	: 'Enabled',
			title	: 'Whether the synchronization (in the specified direction) is enabled or not'
		},

		references	: {
			label	: 'References',
			title	: 'How to handle specific remote object references',
			check   : function(field, refType, qualifier) {
						  return field && field.type == 7 && field.refType == refType && $.isArray(field.refQuali) && $.inArray(qualifier, field.refQuali) >= 0;
					  }
		},

		users		: {
			label	: 'Users',
			title	: 'Whether remote users referenced by remote objects, should be imported as CodeBeamer users, or should be simply referenced by name',
			rights	: 'userAdmin',
			attribs	: function(attrib) {
					  	  return attrib && ((attrib.type == 5 && (attrib.memberType & 2) == 2) || (attrib.type == 7 && attrib.refType == 1));
					  },
			controls: ['comments', 'history', 'worklog']
		},

		groups		: {
			label	: 'Groups',
			title	: 'Whether remote groups referenced by remote objects, should be imported as CodeBeamer groups, or should be simply referenced by name',
			rights	: 'userAdmin',
			attribs	: function(attrib) { return attrib && attrib.type == 5 && (attrib.memberType & 4) == 4; }
		},

		versions	: {
			label	: 'Versions',
			title	: 'Whether remote versions referenced by remote objects, should be imported as CodeBeamer Releases, or should be simply referenced by name',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 9, '103'); }
		},

		components	: {
			label	: 'Components',
			title	: 'Whether remote components referenced by remote objects, should be imported as CodeBeamer Components, or should be simply referenced by name',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 9, '105'); }
		},

		dates		: {
			attribs : function(attrib) { return attrib && attrib.type == 3; },
			fields	: function(field)  { return field && field.type == 3 && (field.id == 4 || field.id == 74); }
		},

		attributes 	: $.extend({}, $.fn.mapRemoteAttributes.defaults, {
			mapping	: 'fields'
		}),

		linkTypes	: $.extend({}, $.fn.mapRemoteLinks.defaults, {
			mapping	: 'links'
		}),

		direction	: $.fn.mapRemoteAttributes.defaults.direction,

		interval	: {
			label	: 'every',
			title	: 'If an interval is specified, e.g. "30min" or "8h", then the configured synchronization will be automatically executed in this interval, otherwise only when invoked manually'
		},

		log	: {
			label	: 'History',
			title   : 'How many synchronizations should be kept in the synchronization history ?',
			options	: [-1, 10, 20, 50, 100, 200, 500],
			prefix	: 'keep',
			all	    : 'all',
			lastX   : 'the last XXX',
			suffix	: 'synchronizations in the history'
		},

		options		: {
			label	: 'Optional',
			title	: 'How to handle optional/additional information of the selected objects'
		},

		attachments	: {
			label	: 'Attachments',
			title	: 'Whether to import attachments of the selected objects, or not',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 5, 'attachment'); }
		},

		comments	: {
			label	: 'Comments',
			title	: 'Whether to import comments of the selected objects, or not',
			depends	: 'users',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 5, 'comment'); },
			disable : -1
		},

		history		: {
			label	: 'History',
			title	: 'Whether to also import the issue of the selected objects, or not',
			depends	: 'users',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 5, 'change'); },
			disable : -1
		},

		worklog	: {
			label	: 'Worklog',
			title	: 'Whether to import the worklogs of the selected objects, or not',
			rights	: 'hasWorkLog',
			depends	: 'users',
			attribs	: function(attrib) { return $.fn.mapRemoteObjects.defaults.references.check(attrib, 9, '8'); },
			disable : -1
		}
	});


	// Get the remote object mapping from an editor
	$.fn.getRemoteObjectMapping = function(settings, extension, checkExport) {
		var result = null;

		var table = $('table.mapping', this);
		if (table.length > 0) {
			result = $.extend({}, table.data('mapping'), settings.server ? table.getRemoteConnection() : {});

			if ($.isPlainObject(extension)) {
				$.each(extension, function(name, value) {
					if ($.isFunction(value)) {
						value = value(table);
					}
					result[name] = value;
				});
			}

			$.each(table.data('checkboxes'), function(name, checkbox) {
				result[name] = checkbox.checkbox.is(':checked');
			});

			if ($.isPlainObject(settings.attributes) && settings.attributes.mapping) {
				if (checkExport) {
					checkExport = (settings.attributes.bidirect && (result.direction & 2) == 2);
				}
				result[settings.attributes.mapping] = $('td.' + settings.attributes.mapping, table).getRemoteAttributeMapping(settings.attributes, checkExport);
			}

			if ($.isPlainObject(settings.linkTypes) && settings.linkTypes.mapping) {
				result[settings.linkTypes.mapping] = $('td.' + settings.linkTypes.mapping, table).getRemoteLinkMapping(settings);
			}

			var intervalInput = table.find('input[name="interval"]');
			if (intervalInput.length > 0) {
				result.interval = $.trim(intervalInput.val());
			}

    		delete result.userAdmin;
    		delete result.objectFields;
    		delete result.linkFields;
    		delete result.reservedFields;
    		delete result.assocTypes;
    		delete result.designatedField;
    		delete result.dedicatedField;
		}

		return result;
	};


	$.fn.setRemoteObjectMapping = function(mapping, settings, extension) {
		if ($.isPlainObject(mapping)) {
			var table = $('table.mapping', this);
			if (table.length > 0) {
				if ($.isPlainObject(extension)) {
					$.each(extension, function(name, setter) {
						if ($.isFunction(setter)) {
							setter(table, mapping[name]);
						} else if (name === 'direction' || name === 'log') {
							if (typeof mapping[name] === "number") {
								var selector = $('select.' + name, table);
								if (selector.length > 0) {
									selector.val(mapping[name]).change();
								}
							}
						} else if (name === 'interval') {
							if (typeof mapping[name] === "string") {
								var input = $('input[name="' + name + '"]', table);
								if (input.length > 0) {
									input.val(mapping[name]).change();
								}
							}
						}
					});
				}

				$.each(table.data('checkboxes'), function(name, checkbox) {
					if (typeof mapping[name] === "boolean" && mapping[name] != checkbox.checkbox.is(':checked')) {
						checkbox.checkbox.click();
					}
				});

				if ($.isPlainObject(settings.attributes) && settings.attributes.mapping && $.isArray(mapping[settings.attributes.mapping])) {
					$('td.' + settings.attributes.mapping, table).setRemoteAttributeMapping(mapping[settings.attributes.mapping], settings.attributes);
				}

				if ($.isPlainObject(settings.linkTypes) && settings.linkTypes.mapping && $.isArray(mapping[settings.linkTypes.mapping])) {
					$('td.' + settings.linkTypes.mapping, table).setRemoteLinkMapping(mapping[settings.linkTypes.mapping], settings);
				}
			}
		}
	};


	// A plugin to map remote objects to tracker items including (attributes and options, attachments, comments, history, etc.) and remote links to associations in a popup dialog
	$.fn.showRemoteObjectMappingDialog = function(context, config, dialog, extension) {
		var settings = $.extend(true, {}, $.fn.showRemoteObjectMappingDialog.defaults, dialog);

		extension = $.extend({
			// Load mapping and pass it to specified callback(mapping)
			loadMapping : function(context, settings, callback) {
				var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

			    $.ajax(settings.settingsURL, {
			    	type 	 : 'GET',
			    	data 	 : context,
			    	dataType : 'json',
			    	cache	 : false
			    }).done(function(mapping) {
					ajaxBusyIndicator.close(busy);

					callback(mapping);

				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
		        });
			},

			// Submit mapping and on success invoke the specified callback(mapping)
			submitMapping : function(context, mapping, config, settings, callback) {
			    $.ajax(settings.settingsURL + "?tracker_id=" + context.tracker_id, {
			    	type 		: 'PUT',
					contentType : 'application/json',
			    	cache		: false,
					dataType 	: 'json',
					data 		: JSON.stringify(mapping)
			    }).done(function() {
					callback(mapping);

				}).fail(showAjaxError);
			},

			// Remove current mapping and on success invoke the specified callback
			removeMapping : function(context, config, settings, callback) {
			    $.ajax(settings.settingsURL + "?tracker_id=" + context.tracker_id, {
			    	type 	 : 'DELETE',
			    	cache	 : false,
					dataType : 'json'
			    }).done(function() {
					callback();
				}).fail(showAjaxError);
			},

			// Verify the specified mapping and on success invoke the specified callback(mapping)
			saveMapping : function(popup, context, mapping, config, callback) {
				callback(mapping);
			},

			// Create mapping editor and return the import source jQuery control, because we need to invoke it's change handler
			editMapping : function(popup, context, mapping, config) {
				return popup.mapRemoteObjects(mapping, config);
			},

			getMapping : function(popup, context, config) {
				return popup.getRemoteObjectMapping(config, null, true);
			},

			setMapping : function(popup, context, mapping, config) {
				popup.setRemoteObjectMapping(mapping, config);
			},

			getMappingFile : function(popup, context, config) {
				return {
					name : 'RemoteObjectMapping',
					data : popup.getRemoteObjectMapping(config, null, false)
				};
			},

			finished : function(context, mapping, config) {
				// Nothing
			}
		}, extension);

		extension.loadMapping.call(extension, context, settings, function(mapping) {
			var popup = $('#RemoteObjectMappingPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'RemoteObjectMappingPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			var source = extension.editMapping.call(extension, popup, context, mapping, config);

		    settings.close = function() {
		    	popup.remove();
		    };

			if (context.version) {
				settings.title += ' (Version ' + context.version + ')';
			} else {
				settings.buttons = [{
					text : settings.submitText,
					click: function() {
						try {
							var mapping = extension.getMapping.call(extension, popup, context, config);
							if (mapping) {
								extension.saveMapping.call(extension, popup, context, mapping, config, function(verified) {
									extension.submitMapping.call(extension, context, verified, config, settings, function(saved) {
							  			popup.dialog("close");
							  			popup.remove();

							  			extension.finished.call(extension, context, saved, config);
									});
								});
							}
						} catch(error) {
							showFancyAlertDialog(error);
						}
					}
				}, {
					text  : settings.cancelText,
				   "class": "cancelButton",
					click : function() {
						popup.dialog("close");
						popup.remove();
					}
				}];

				if ($.isPlainObject(settings.remove)) {
					settings.buttons.push({
						text  : settings.remove.label,
					   "class": "cancelButton",
						click : function() {
							showFancyConfirmDialogWithCallbacks(settings.remove.confirm, function() {
								extension.removeMapping.call(extension, context, config, settings, function() {
						  			popup.dialog("close");
						  			popup.remove();

						  			extension.finished.call(extension, context, null, config);
								});
							});
						}
					});
				}
			}

			popup.dialog(settings);

			if (!context.version) {
				var buttonset = popup.dialog('widget').find('div.ui-dialog-buttonpane div.ui-dialog-buttonset');

				var saveAsFile = $('<a>', {
					href	 : '#',
					download : 'RemoteObjectMapping.json',
					title	 : settings.saveAs.title
				}).text(settings.saveAs.label).click(function(event) {
					try {
						var file = extension.getMappingFile.call(extension, popup, context, config);
						if (file && file.name && $.isPlainObject(file.data)) {
							delete file.data.server;
							delete file.data.username;
							delete file.data.password;
							delete file.data.hasWorklog;

							if (!file.name.endsWith('.json')) {
								file.name += '.json';
							}

							var blob = new Blob([JSON.stringify(file.data, /*getCircularReplacer()*/null, 4)], { type : 'application/json' });

							if (window.navigator.msSaveBlob) {
								window.navigator.msSaveBlob(blob, file.name);
							} else {
								event.target.download = file.name;
								event.target.href     = (window.webkitURL || window.URL).createObjectURL(blob);
							}
						}
					} catch(error) {
						showFancyAlertDialog(error);
						event.preventDefault();
						return false;
					}
				});

				var fileSelector = $('<input>', {
					type  : 'file',
					style : 'position: fixed; top: -200px'
				}).change(function(event) {
					var file = event.target.files[0];
					var reader = new FileReader();

					reader.onload = function(event) {
						var text = event.target.result;
						extension.setMapping.call(extension, popup, context, $.parseJSON(text), config);
					};

					reader.readAsText(file, "UTF-8");
					event.target.value = '';
				});

				var loadFromFile = $('<a>', {
					href  : '#',
					title : settings.loadFrom.title
				}).text(settings.loadFrom.label).click(function(event) {
					event.preventDefault();
					fileSelector.click();
					return false;
				});

				buttonset.append(fileSelector);

				var saveLoad = $('<span>', { style : 'float: right; padding : 10px;' });
				saveLoad.append(saveAsFile).append(" / ").append(loadFromFile).append("&nbsp;").append(settings.fileText);

				buttonset.append(saveLoad);

				// BUG-1570788: Only show Load/Save, if a remote source is selected
				var sections = popup.data('sections');
				if ($.isPlainObject(sections)) {
					sections.saveLoad = saveLoad;
				}
			}

			// Invoke change handler on the import source control only after the dialog is ready, in order to load source meta data
			if ($.isFunction(source)) {
				source();
			} else {
				source.change();
			}
		});

	    return this;
	};


	$.fn.showRemoteObjectMappingDialog.defaults = {
		label			: 'Settings...',
		title			: 'Remote Object Mapping',
		loading			: 'Loading settings, please wait ...',
		settingsURL		: null,
	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
	    closeText		: 'Close',
	    fileText		: 'file ...',
	    saveAs			: {
	    	label 		: 'Save as',
	    	title		: 'Save these settings as a file'
	    },
	    loadFrom		: {
	    	label		: 'Load from',
	    	title		: 'Load saved settings from a file'
	    },
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 886,
		height			: 760
	};


	// Plugin to show the remote import statistics
	$.fn.remoteImportStatistics = function(syncStatistics, options) {
		var settings = $.extend(true, {}, $.fn.remoteImportStatistics.defaults, options );

		function openLink(event) {
			event.preventDefault();
			window.open($(this).attr('href'), "_blank");
			return false;
		}

		function showUsers(category, users) {
			var popup = $('#ImportedRemoteUsersPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'ImportedRemoteUsersPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			var list = $('<ul>');
			popup.append(list);

			for (var i = 0; i < users.length; ++i) {
				list.append($('<li>').append($('<a>', {
					href : contextPath + '/userdata/' + users[i].id,
					title : users[i].realName
				}).text(users[i].name).click(openLink)));
			}

			popup.dialog($.extend({}, settings.users.dialog, {
				title : settings.users.dialog.title.replace('XXX', category),
				close : function() {
		  			popup.remove();
			    }
			}));
		}

		function addUserLink(category, users) {
			return $('<a>', {
				href  : '#',
				title : settings.users.dialog.link.replace('XXX', category)
			}).text(users.length).click(function(event) {
				event.preventDefault();
				showUsers(category, users);
				return false;
			});
		}

		function showFailure(failure) {
			var popup = $('#SynchronizationFailurePopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'SynchronizationFailurePopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			popup.append($('<span>', { style : 'font-family: "Lucida Console", Monaco, monospace; font-weight: bold;' }).text(failure.action));

			if (failure.params) {
				popup.append($('<pre>', { style : 'margin: 0px; font-family: "Lucida Console", Monaco, monospace;' }).text(failure.params));
			}

			if (failure.error) {
				popup.append($('<p>').append($('<pre>', { style : 'margin: 0px; font-family: "Lucida Console", Monaco, monospace;' }).text(failure.error)));
			}

			popup.dialog($.extend({}, settings.operation.failure.dialog, {
				title : settings.operation.failure.label,
				close : function() {
		  			popup.remove();
			    }
			}));
		}

		function addFailureLink(failure) {
			return $('<a>', {
			   "class" : 'failure',
				href   : '#',
				title  : settings.operation.failure.title,
				style  : 'color: red;'
			}).text(settings.operation.failure.label).click(function(event) {
				event.preventDefault();
				showFailure(failure);
				return false;
			});
		}

		function showItems(config, tracker, sync, operation, items) {
			var popup = $('#ImportedItemsPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'ImportedItemsPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			var table = $('<table>', { "class" : 'importedItems formTableWithSpacing', style : 'width: 100%;' });
			popup.append(table);

			var hasChanges = false;

			for (var i = 0; i < items.length; ++i) {
				var item    = items[i];
				var changes = item.changes;

				var link = $('<a>', {
					href : contextPath + '/issue/' + item.id
				}).text(item.id).click(openLink);

				var remote = null;
				if ($.isPlainObject(item.remote)) {
					remote = item.remote.id || item.remote.name;
				}

				var row = $('<tr>', { "class" : 'attrib even', "data-tt-id" : item.id, style: 'vertical-align: top;' });
				var tdi = $('<td>', { "class" : 'numberData', style : "width: 5%; vertical-align: top;" });

				if (remote) {
					tdi.css('width', '12%');

					var remoteLink = $('<a>', {
						href : settings.remoteLink ? settings.remoteLink.replace('YYY', remote) : '#'
					}).text(remote).click(openLink);

					if (sync == 'import') {
						tdi.append(remoteLink).append(' &rarr; ').append(link);
					} else {
						tdi.append(link).append(' &rarr; ').append(remoteLink);
					}
				} else {
					tdi.append(link)
				}
				row.append(tdi);

				var summary = $('<td>', { "class" : 'textData' });

				if (item.name) {
					summary.text(item.name);
				} else if (item.description) {
					summary.html(item.description)
				}

				row.append(summary);

				table.append(row);

				if ($.isArray(changes) && changes.length > 0) {
					var changeTable = $('<table>', { style: 'border: 1px solid silver;'});

					if (sync == 'import') {
						var header = $('<thead>');
						changeTable.append(header);

						var headline = $('<tr>',  { "class" : 'head', style: 'vertical-align: middle;' });
						headline.append($('<th>', { "class" : 'textData', colspan : 2 }));
						headline.append($('<th>', { "class" : 'textData' }).text(settings.newValueLabel));
						headline.append($('<th>', { "class" : 'textData' }).text(settings.oldValueLabel));

						header.append(headline);
					}

					var tbody = $('<tbody>');
					changeTable.append(tbody);

					for (var j = 0; j < changes.length; ++j) {
						var change = changes[j];
						var op     = change.op || 'Set';

						row = $('<tr>', { style: 'vertical-align: top;' });
						row.append($('<td>', { "class" : 'textData', 		   style : "width: 2em; vertical-align: top;" }).text(settings.operation[op].label));
						row.append($('<td>', { "class" : 'labelCell optional', style : "width: 6em; vertical-align: top;" }).text(change.fieldName + ": "));
						row.append($('<td>', { "class" : 'textData', 		   style : "vertical-align: top;" }).html(change.newValue));
						var last = $('<td>', { "class" : 'textData', 		   style : "vertical-align: top;" });

						if ($.isPlainObject(change.failure)) {
							last.append(addFailureLink(change.failure));
						} else if (sync == 'import' && op == 'Set') {
							last.html(change.oldValue);
						}

						row.append(last);

						tbody.append(row);
					}

					row = $('<tr>', { "class" : 'attrib odd', "data-tt-parent-id" : item.id, "data-tt-id" : "changes-" + item.id  });
					row.append($('<td>', { "class" : 'numberData', style : "width: 5%; vertical-align: top;", title : settings.items.dialog.changes }).html("&Delta;"));
					row.append($('<td>').append(changeTable));

					table.append(row);

					hasChanges = true;
				}
			}

			if (hasChanges) {
				table.treetable({
					expandable   : true,
					initialState : 'expanded'
				});
			}

			config.title = config.title.replace('XXX', operation);

			if ($.isPlainObject(tracker)) {
				config.title = config.title.replace('YYY', tracker.name);
			}

			config.close = function() {
	  			popup.remove();
		    };

			popup.dialog(config);
		}

		function addItemLink(sync, tracker, category, operation, items) {
			var dialog = $.extend({}, settings.items.dialog, category.dialog);

			return $('<a>', {
				href  : '#',
				title : dialog.link.replace('XXX', operation)
			}).text(items.length).click(function(event) {
				event.preventDefault();
				showItems(dialog, tracker, sync, operation, items);
				return false;
			});
		}

		function showNumbers(tbody, tracker, name, category, numbers) {
			if ($.isPlainObject(numbers)) {
				var row = $('<tr>', { "class" : 'result', style: 'vertical-align: middle;' });
				var imp = $('<td>', { "class" : 'numberData diff' });
				var upd = $('<td>', { "class" : 'numberData diff' });
				var del = $('<td>', { "class" : 'numberData diff' });
				var err = $('<td>', { "class" : 'numberData diff' });

				var cat = settings[category] || { label : category };
				if ($.isPlainObject(settings[name][category])) {
					cat = $.extend(true, {}, cat, settings[name][category]);
				}

				if ($.isPlainObject(tracker)) {
					row.append($('<td>', { "class" : 'textData diff' }).append($('<a>', {
						href  : contextPath + '/tracker/' + tracker.id,
						title : tracker.description
					}).text(tracker.name).click(openLink)));
				} else {
					row.append($('<td>', { "class" : 'textData diff', style : 'width: 6em;', title : cat.title }).text(cat.label ));
				}

				if (category == 'users') {
					if (numbers.imported > 0 && $.isArray(numbers.importedUsers)) {
						imp.append(addUserLink(settings.createdLabel, numbers.importedUsers));
					} else {
						imp.text(numbers.imported);
					}

					if (numbers.updated > 0 && $.isArray(numbers.updatedUsers)) {
						upd.append(addUserLink(settings.updatedLabel, numbers.updatedUsers));
					} else {
						upd.text(numbers.updated);
					}

					if (numbers.deleted > 0 && $.isArray(numbers.deletedUsers)) {
						del.append(addUserLink(settings.deletedLabel, numbers.deletedUsers));
					} else {
						del.text(numbers.deleted);
					}
					err.text(numbers.failed || 0);

				} else if (category == 'items' || category == 'objects' || category == 'issues' || category == 'versions' || category == 'sprints' || category == 'components' || category == 'teams') {
					if (numbers.imported > 0 && $.isArray(numbers.importedItems)) {
						imp.append(addItemLink(name, tracker, cat, settings.createdLabel, numbers.importedItems));
					} else {
						imp.text(numbers.imported);
					}

					if (numbers.updated > 0 && $.isArray(numbers.updatedItems)) {
						upd.append(addItemLink(name, tracker, cat, settings.updatedLabel, numbers.updatedItems));
					} else {
						upd.text(numbers.updated);
					}

					if (numbers.deleted > 0 && $.isArray(numbers.deletedItems)) {
						del.append(addItemLink(name, tracker, cat, settings.deletedLabel, numbers.deletedItems));
					} else {
						del.text(numbers.deleted);
					}

					if (numbers.failed > 0 && $.isArray(numbers.failedItems)) {
						err.append(addItemLink(name, tracker, cat, settings.failedLabel, numbers.failedItems));
					} else {
						err.text(numbers.failed || 0);
					}
				} else {
					imp.text(numbers.imported);
					upd.text(numbers.updated);
					del.text(numbers.deleted);
					err.text(numbers.failed || 0);
				}

				if (numbers.failed > 0) {
					err.css("color", "red");
				}

				row.append(imp);
				row.append(upd);
				row.append(del);
				row.append(err);

				tbody.append(row);
			}
		}

		function showStatistics(container, name, statistics) {
			var table = $('<table>', { "class" : 'statistics formTableWithSpacing' });
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>',  { "class" : 'head', style: 'vertical-align: middle;' });
			headline.append($('<th>', { "class" : 'textData', style: 'width: 6em; padding-left: 5px; font-weight: bold;', title : settings[name].title }).text(settings[name].label));
			headline.append($('<th>', { "class" : 'numberData' }).text(settings.createdLabel));
			headline.append($('<th>', { "class" : 'numberData' }).text(settings.updatedLabel));
			headline.append($('<th>', { "class" : 'numberData' }).text(settings.deletedLabel));
			headline.append($('<th>', { "class" : 'numberData' }).text(settings.failedLabel));

			header.append(headline);

			var tbody = $('<tbody>');
			table.append(tbody);

			if ($.isPlainObject(statistics)) {
				$.each(statistics, function(category, numbers) {
					showNumbers(tbody, null, name, category, numbers);
				});
			} else if ($.isArray(statistics)) {
				for (var i = 0; i < statistics.length; ++i) {
					showNumbers(tbody, statistics[i].tracker, name, 'items', statistics[i].items);
				}
			}
		}

		function init(container, syncStatistics) {
			if ($.isArray(syncStatistics)) {
				showStatistics(container, 'tracker', syncStatistics);
			} else {
				if (!$.isPlainObject(syncStatistics)) {
					syncStatistics = {};
				}

				if ($.isPlainObject(syncStatistics["import"])) {
					if ($.isPlainObject(syncStatistics["export"])) {
						var div = $('<div>', { style : 'display: inline-block;' });

						container.append(div);

						showStatistics(div, 'import', syncStatistics["import"]);

						div.append($('<br>'));

						showStatistics(div, 'export', syncStatistics["export"]);
					} else {
						showStatistics(container, 'import', syncStatistics["import"]);
					}
				} else if ($.isPlainObject(syncStatistics["export"])) {
					showStatistics(container, 'export', syncStatistics["export"]);

				} else {
					showStatistics(container, 'import', syncStatistics);
				}
			}
		}

		return this.each(function() {
			init($(this), syncStatistics);
		});
	};


	$.fn.remoteImportStatistics.defaults = {
		nothing 	  : 'The import finished successfully, but there was no new data to import',

		tracker 	  : {
			label	  : 'Tracker',
			title	  : 'A project tracker, where items were created, updated or deleted by this import',
			items	  : {
				dialog    : {
					title : 'Items, XXX in YYY'
				}
			}
		},

		"import"	  : {
			label	  : 'Import',
			title	  : 'Import from the remote system'
		},

		"export"	  : {
			label	  : 'Export',
			title	  : 'Export to the remote system',

			items	  : {
				title	  : 'The number of items, that were created, updated or deleted in the remote system by this export',
				dialog    : {
					link  : 'Show the items, that were XXX in the remote system',
					title : 'Items, XXX in the remote system'
				}
			}
		},

		synchronization	: {
			label	  : 'Synchronization',
			title	  : 'Bi-directional synchronization with the remote system'
		},

		newValueLabel : 'Value(New)',
		oldValueLabel : 'Old Value',

		createdLabel  : 'Created',
		updatedLabel  : 'Updated',
		deletedLabel  : 'Deleted',
		failedLabel   : 'Failed',

		operation	  : {
			label	  : 'Operation',
			title	  : 'The operation to perform on a field',
			"Set"	  : {
				label : 'Set',
				title : 'Set field value(s)'
			},
			"Add"	  : {
				label : 'Add',
				title : 'Add the specified value(s) to the current set of field values (if not already present)'
			},
			"Remove"  : {
				label : 'Remove',
				title : 'Remove the specified value(s) from the current field values'
			},
			failure   : {
				label : 'Failure',
				title : 'This operation failed. Click to get detailed information about the cause of the failure.',

				action : {
					label : 'Action',
					title : 'The action, that has failed'
				},
				params : {
					label : 'Parameters',
					title : 'The parameters for the failed action'
				},
				error : {
					label : 'Error',
					title : 'The error, that occured upon action execution'
				},
				dialog : {
					dialogClass		: 'popup',
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: true,
					draggable		: true,
					closeOnEscape	: true,
					width			: 1000
				}
			}
		},

		users		  : {
			label	  : 'Users',
			title	  : 'The number of users, that were imported, updated or deleted in CodeBeamer',
			dialog    : {
				link  			: 'Show the users, that were XXX in CodeBeamer',
				title 			: 'Users, that were XXX in CodeBeamer',
				dialogClass		: 'popup',
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				draggable		: true,
				closeOnEscape	: true,
				width			: 300
			}
		},

		items		  : {
			label	  : 'Items',
			title	  : 'The number of items, that were created, updated or deleted in this tracker by this import',
			dialog    : {
				link  			: 'Show the items, that were XXX in this tracker',
				title 			: 'Items, XXX in this tracker',
				changes			: 'Field changes (New value vs.	Old value)',
				dialogClass		: 'popup',
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				draggable		: true,
				closeOnEscape	: true,
				height			: 640,
				width			: 1280
			}
		}
	};


	// A plugin to show remote import statistics/history in a popup dialog
	$.fn.showRemoteImportHistoryDialog = function(context, config, dialog, settings) {
		dialog = $.extend(true, {}, $.fn.showRemoteImportHistoryDialog.defaults, dialog);

		function loadPage(page, callback) {
			var busy = ajaxBusyIndicator.showBusyPage(dialog.loading);

		    $.ajax(dialog.historyURL, {
		    	type 	 : 'GET',
		    	data 	 : page,
		    	dataType : 'json',
		    	cache	 : false
		    }).done(function(result) {
				ajaxBusyIndicator.close(busy);
				callback(result);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
				showAjaxError(jqXHR, textStatus, errorThrown);
			});
		}

		function openLink(event) {
			event.preventDefault();
			window.open($(this).attr('href'), "_blank");
			return false;
		}

		function addSynchronizations(table, page, tree) {
			var imports = page.list;
			if (!$.isArray(imports)) {
				imports = [];
			}

			for (var i = 0; i < imports.length; ++i) {
				var id  = imports[i].version;
				var row = $('<tr>', { "class" : 'import even branch', "data-tt-id": id, style: 'vertical-align: middle;' });
				var col = $('<td>', { "class" : 'textData', style : "vertical-align: middle;" });

				var sync = (imports[i].sync == 3 ? 'synchronization' :
						   (imports[i].sync == 2 ? 'export'	   :
							   		     		   'import'));

				var label = $('<label>', { title : config[sync].title, style : 'margin-left: 4px;' }).text(config[sync].label);

				col.append(imports[i].date).append(label).append(', ').append($('<a>', {
					href  : contextPath + '/userdata/' + imports[i].user.id,
					title : imports[i].user.realName
				}).text(imports[i].user.name).click(openLink));

				delete imports[i].date;
				delete imports[i].user;
				delete imports[i].version;

				if (imports[i].baseline) {
					var baseline = $.isPlainObject(imports[i].baseline) ? imports[i].baseline.id : imports[i].baseline;

					col.append( ' (' + dialog.baselineLabel + ': ' + baseline + ')' );
					delete imports[i].baseline;
				}

				row.append(col);

				if (tree) {
					table.treetable('loadBranch', null, row);
				} else {
					table.append(row);
				}

				row = $('<tr>', { "class" : 'statistics even leaf', "data-tt-id" : 'stats-' + id, "data-tt-parent-id" : id, style: 'vertical-align: middle' });
				col = $('<td>', { "class" : 'textData', style : "vertical-align: middle; padding-left: 20px;" });

				if ($.isFunction(settings)) {
					col.append($('<a>', {
						href  : '#',
						title : dialog.settings.title,
						style: 'float: right; position: relative; top: -32px; right: 24px;'
					}).text(dialog.settings.label).data('context', $.extend({}, context, {
	    				version : id
					})).click(function(event) {
						event.preventDefault();
						settings(table, $(this).data('context'));
		    			return false;
					}));
				}

				col.remoteImportStatistics(imports[i], config);

				row.append(col);

				if (tree) {
					table.treetable('loadBranch', table.treetable('node', id), row).treetable('collapseNode', id);
				} else {
					table.append(row);
				}
			}

			var remaining = page.total - (page.page * page.size);
			if (remaining > 0) {
				var row = $('<tr>', { "class" : 'import even', "data-tt-id" : 'page-' + (page.page + 1),  style: 'vertical-align: middle;' });
				var col = $('<td>', { "class" : 'textData', style : "vertical-align: middle;" });

				col.append($('<a>', {
					href  : '#',
					title : dialog.more.title.replace('XX', page.size).replace('YY', remaining)
				}).text(dialog.more.label).data('page', $.extend({}, context, {
				  	page 	 : page.page + 1,
				  	pagesize : page.size
				})).click(function(event) {
					var page = $(this).data('page');

					event.preventDefault();

					loadPage(page, function(result) {
						table.treetable('removeNode', 'page-' + page.page);
						addSynchronizations(table, result, true);
					});

	    			return false;
				}));

				row.append(col);

				if (tree) {
					table.treetable('loadBranch', null, row);
				} else {
					table.append(row);
				}
			}
		}

		function showImportHistory(page) {
			var popup = $('#RemoteImportHistoryPopup');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'RemoteImportHistoryPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
				$(document.documentElement).append(popup);
			} else {
				popup.empty();
			}

			var table = $('<table>', { "class" : 'imports displaytag', style : 'width: 98%;' });
			popup.append(table);

			addSynchronizations(table, page);

			table.treetable({
				expandable   : true,
				initialState : 'collapsed',
				indent 		 : 5
			});

			dialog.close = function() {
	  			popup.remove();
		    };

			popup.dialog(dialog);
		}

		if ($.fn.showRemoteImportHistoryDialog._setup) {
			$.fn.showRemoteImportHistoryDialog._setup = false;
		    $.contextMenu({
		        selector : '#RemoteImportHistoryPopup table.imports tr.import',
		        trigger  : 'right',
		        items	 : {
		        	"expandAll" : {
		        		name : dialog.expandAll
		        	},
		        	"collapseAll" : {
		        		name : dialog.collapseAll
		        	}
		        },
		        callback : function(key, options) {
		        	options.$trigger.closest('table.imports').treetable(key);
		        }
		    });
		}

		loadPage(context, showImportHistory);

	    return this;
	};


	$.fn.showRemoteImportHistoryDialog._setup = true;


	$.fn.showRemoteImportHistoryDialog.defaults = {
		label			: 'History ...',
		title			: 'Import History',
		loading			: 'Loading Import History ...',
		more			: {
			label		: 'More ...',
			title		: 'Load the next XX of remaining YY history entries'
		},
		historyURL 		: null,
		expandAll		: 'Expand all',
		collapseAll		: 'Collapse all',
		settings		: {
			label		: 'Settings...',
			title		: 'Show the settings, that were used for this import'
		},
		baselineLabel	: 'Baseline',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 640,
		height			: 640
	};


	// Plugin to edit remote import settings
	$.fn.importRemoteObjects = function(remoteImport, settings, rows) {

		function showLastImport(table, cell, config, callback) {
			var lastImport = remoteImport.lastImport;
			if ($.isPlainObject(lastImport)) {
				cell.append(lastImport.date + ', ');

				cell.append($('<a>', {
					href  : contextPath + '/userdata/' + lastImport.user.id,
					title : lastImport.user.realName
				}).text(lastImport.user.name).click(function(event) {
					event.preventDefault();
					window.open($(this).attr('href'), "_blank");
					return false;
				}));

				if (lastImport.baseline) {
					var baseline = $.isPlainObject(lastImport.baseline) ? lastImport.baseline.id : lastImport.baseline;

					cell.append( ' (' + settings.baseline.label + ': ' + baseline + ')' );
				}

				cell.append($('<a>', {
					href  : '#',
					title : settings.history.dialog.title,
					style : 'margin-left: 2em;'
				}).text(settings.history.dialog.label).click(function(event) {
					event.preventDefault();

					if ($.isFunction(callback)) {
						callback(table, cell, remoteImport, settings);
					}
					return false;
				}));
			} else {
				cell.text(config.never);
			}
		}

		function init(container, remoteImport, extension) {
			var table = $('<table>', { "class" : 'remoteImport formTableWithSpacing' }).data('remoteImport', remoteImport);
			container.append(table);

			if ($.isArray(rows) && rows.length > 0) {
				for (var i = 0; i < rows.length; ++i) {
					var row = rows[i];

					if ($.isPlainObject(row) && row.name && row.content) {
						var name   = row.name;
						var config = $.isPlainObject(settings[name]) ? settings[name] : {};
						var style  = config.style || 'vertical-align: middle;';

						var line = $('<tr>', { title : config.title, style : style });
						table.append(line);

						var label = $('<td>', { "class" : 'labelCell optional', style : style }).text((config.label || name) + ':');
						line.append(label);

						var cell = $('<td>', { "class" : 'dataCell', style : style });
						line.append(cell);

						if (name === 'lastSync' || name === 'lastImport' || name === 'lastExport') {
							showLastImport(table, cell, config, row.content);
						} else if ($.isFunction(row.content)) {
							row.content(table, cell, remoteImport, settings);
						} else if (typeof row.content === "string") {
							cell.text(row.content);
						} else {
							cell.append(row.content);
						}
					}
				}
			}
		}

		return this.each(function() {
			init($(this), remoteImport, rows);
		});
	};


	$.fn.importRemoteObjects.defaults = {
		lastImport	: {
			label 	: 'Last Import',
			title 	: 'Date and time of the last remote objects import',
			never	: 'Never'
		},

		history 	: {
			config	: $.fn.remoteImportStatistics.defaults,
			dialog	: $.fn.showRemoteImportHistoryDialog.defaults
		}
	};


	// Plugin to get the remote import configuration
	$.fn.getRemoteImport = function(extension) {
		var result = null;

		var table = $('table.remoteImport', this);
		if (table.length > 0) {
			result = $.extend({}, table.data('remoteImport'));

			delete result.tracker;
//			delete result.connection;
			delete result.lastImport;
			delete result.nextSync;

			if ($.isPlainObject(extension)) {
				$.each(extension, function(name, value) {
					if ($.isFunction(value)) {
						value = value(table);
					}
					result[name] = value;
				});
			}
		}

		return result;
	};


	// A plugin to configure and execute a new remote import for a specific tracker in a popup dialog
	$.fn.showRemoteImportDialog = function(context, config, dialog, extension) {
		var popup = this;

		dialog = $.extend(true, {}, $.fn.showRemoteImportDialog.defaults, dialog, {
			close : function() {
	  			popup.remove();
		    }
		});

		extension = $.extend({
			hasSettings : function(context, result) {
				return false;
			},

			showSettings : function(popup, context, settingsConfig, settingsDialog) {
				return popup.showRemoteObjectMappingDialog(context, settingsConfig, settingsDialog);
			},

			showImport : function(popup, context, remoteImport, config) {
				return popup.importRemoteObjects(remoteImport, config);
			},

			getImport : function(popup, context, config) {
				return popup.getRemoteImport();
			},

			doImport : function(popup, context, doorsImport, config) {
				return true;
			},

			getSubject : function(context, remoteImport, config, dialog) {
				return dialog.running;
			},

			hasNext : function(context, remoteImport, config) {
				return false;
			},

			getNext : function(context, remoteImport, config) {
				return null;
			},

			importFailed : function(popup, context, remoteImport, config) {
				return popup;
			},

			cancelImport : function(popup, context, config, dialog) {
				popup.dialog("close");
				popup.remove();
			},

			showResult : function(popup, context, remoteImport, statistics, config) {
				if (config.remoteLink) {
					config = $.extend({}, config, {
						remoteLink : config.remoteLink.replace('XXX', remoteImport.connection.server)
					});
				}

				return popup.remoteImportStatistics(statistics, config);
			},

			importFinished : function(context, remoteImport, config) {
				if (this.reload) {
					window.location.reload();
				}
			}
		}, extension);

		function showSettings() {
			extension.showSettings.call(extension, popup, context, dialog.settings.config, dialog.settings.dialog);
		}

		function showResult(subject, remoteImport, statistics, callback) {
			var hasNext = extension.hasNext.call(extension, context, remoteImport, config);

			popup.empty();
			extension.showResult.call(extension, popup, context, remoteImport, statistics, dialog.result);

			if ($('tr.result', popup).length > 0) {
				extension.reload = true;
			} else {
				popup.empty().text(dialog.result.nothing);
			}

			dialog.title = subject;

			dialog.close = function() {
				callback(true);
		    };

			if (hasNext) {
				dialog.buttons = [{
					text : dialog.continueLabel,
					click: function() {
						callback(false);
					}
				}, {
					text  : dialog.settings.dialog.cancelText,
				   "class": "cancelButton",
					click : function() {
						callback(true);
					}
				}];
			} else {
				dialog.buttons = [{
					text : dialog.settings.dialog.submitText,
					click: function() {
						callback(true);
					}
				}];
			}

			popup.dialog(dialog);
		}

		function doImport(remoteImport) {
			var subject = extension.getSubject.call(extension, context, remoteImport, config, dialog);
			var busy = ajaxBusyIndicator.showBusyPage(subject);

		    $.ajax(dialog.importURL + "?tracker_id=" + context.tracker_id, {
		    	type 		: 'POST',
				contentType : 'application/json',
		    	cache		: false,
				dataType 	: 'json',
				data 		: JSON.stringify(remoteImport)
		    }).done(function(statistics) {
				ajaxBusyIndicator.close(busy);

				showResult(subject, remoteImport, statistics, function(done) {
					if (done) {
						popup.dialog("close");
						popup.remove();

						extension.importFinished.call(extension, context, remoteImport, config);
					} else {
						doImport(extension.getNext.call(extension, context, remoteImport, config));
					}
				});
			}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);

	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		showFancyAlertDialog(subject.replace('...', ':\n\n') + exception.message);
	    		} catch(err) {
	    			if (jqXHR.status == 401) { // Unauthorized
	    				showFancyAlertDialog(i18n.message("ajax.unauthorized.message="));
	    			} else if (jqXHR.status == 403) { // Forbidden
	    				showFancyAlertDialog(i18n.message("ajax.forbidden.message"));
	    			} else {
			    		showFancyAlertDialog(subject.replace('...', 'failed: ') + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    			}
	    		}

	    		extension.importFailed.call(extension, popup, context, remoteImport, config);
	        });
		}

		function showImport(remoteImport) {
			var direction = remoteImport.direction || 1;
			var action    = dialog[(direction == 3 ? 'synchronize' :
								   (direction == 2 ? 'export'	   :
										   		     'import'))];

			if ($.isPlainObject(action) && action.label) {
				$.extend(dialog, action);

				if (remoteImport.enabled) {
					dialog.buttons = [{
						text  : action.label,
						click : function() {
							doImport($.extend(extension.getImport.call(extension, popup, context, config), {
								direction : direction
							}));
						}
					}];

					if (direction == 3) {
						if ($.isPlainObject(action = dialog["import"]) && action.label) {
							dialog.buttons.push({
								text  : action.label,
								click : function() {
									doImport($.extend(extension.getImport.call(extension, popup, context, config), {
										direction : 1
									}));
								}
							});
						}

						if ($.isPlainObject(action = dialog["export"]) && action.label) {
							dialog.buttons.push({
								text  : action.label,
								click : function() {
									doImport($.extend(extension.getImport.call(extension, popup, context, config), {
										direction : 2
									}));
								}
							});
						}
					}
				} else {
					dialog.buttons = [];
				}
			} else if (remoteImport.enabled) {
				dialog.buttons = [{
					text  : dialog.settings.dialog.submitText,
				   "class": 'submitButton',
					click : function() {
						var newImport = extension.getImport.call(extension, popup, context, config);
						if (extension.doImport.call(extension, popup, context, newImport, config)) {
							doImport(newImport);
						}
					}
				}];
			} else {
				dialog.buttons = [];
			}

			dialog.buttons.push({
				text  : dialog.settings.dialog.cancelText,
			   "class": "cancelButton",
				click : function() {
					extension.cancelImport.call(extension, popup, context, config, dialog);
				}
			});

			if (remoteImport.admin) {
				dialog.buttons.push({
					 text  : dialog.settings.dialog.label,
					"class": "cancelButton",
					 click : showSettings
				});
			}

	    	popup.empty();
	    	popup.helpLink(dialog.settings.config.help);

	    	extension.showImport.call(extension, popup, context, remoteImport, config);

	    	popup.dialog(dialog);
		}

		var busy = ajaxBusyIndicator.showBusyPage(dialog.loading);

	    $.ajax(dialog.importURL, {
	    	type 	 : 'GET',
	    	data 	 : context,
	    	dataType : 'json',
	    	cache	 : false
	    }).done(function(result) {
			ajaxBusyIndicator.close(busy);

			if (result.error) {
				showFancyAlertDialog(result.error.message, 'error', null, showSettings);
			} else if (extension.hasSettings.call(extension, context, result)) {
				if (result.enabled || result.admin) {
					showImport(result);
				} else {
		    		showFancyAlertDialog(dialog.disabled);
				}
	    	} else if (result.admin) {
	    		showFancyConfirmDialogWithCallbacks(dialog.settings.confirm, showSettings);
	    	} else {
	    		showFancyAlertDialog(dialog.settings.none);
	    	}
		}).fail(function(jqXHR, textStatus, errorThrown) {
			ajaxBusyIndicator.close(busy);
			showAjaxError(jqXHR, textStatus, errorThrown);
		});
	};

	$.fn.showRemoteImportDialog.defaults = {
		title			: 'Import remote objects',
		loading			: 'Loading import information ...',
		disabled		: 'Importing into this tracker has been disabled!',
		running			: 'Importing ...',
		importURL		: null,
		settings		: {
			none		: 'This tracker has not been configured for an import yet!',
			confirm		: 'This tracker has not been configured for an import yet. Do you want to configure it now ?',
			config 		: $.fn.mapRemoteObjects.defaults,
			dialog		: $.fn.showRemoteObjectMappingDialog.defaults
		},
		result			: $.fn.remoteImportStatistics.defaults,
		continueLabel	: 'Continue',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 720
	};


	// A plugin to show a list of the deployed remote/external system connnectors
	$.fn.remoteSystemConnectors = function(connectors, config) {
		var settings = $.extend({}, $.fn.remoteSystemConnectors.defaults, config);

		function init(container, connectors) {
			if ($.isArray(connectors) && connectors.length > 0) {
				var table = $('<table>', { "class" : 'displaytag connectors', style : 'width: 96%;'});
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var toggle = $('<input>', { type : 'checkbox', name : 'toggle', value : 'true', checked : true });
				headline.append($('<th>', { "class" : 'checkbox-column-minwidth', title : settings.toggleAll }).append(toggle));
				headline.append($('<th>', { "class" : 'textData', title : settings.title }).text(settings.label));

				var tbody = $('<tbody>');
				table.append(tbody);

				for (var i = 0; i < connectors.length; ++i) {
					var connector = connectors[i];

					var row = $('<tr>', { "class" : 'even connector', style : 'vertical-align: middle;' }).data('connector', connector);
					tbody.append(row);

					var cell = $('<td>', { "class" : 'selector checkbox-column-minwidth', title : settings.toggleThis });
					row.append(cell);

					cell.append($('<input>', { type : 'checkbox', name : 'selector', value : connector.id, checked : true }));

					cell = $('<td>', { "class" : 'textData', style : 'vertical-align: middle;' });
					row.append(cell);

					cell.append($('<img>', { src : contextPath + connector.icon }));
					cell.append($('<label>', { style : 'margin-left: 5px;' }).text(connector.name));
				}

				toggle.change(function() {
					var checked = toggle.is(':checked');

					$('input[type="checkbox"][name="selector"]', tbody).attr('checked', checked);
				});
			} else {
				container.text(settings.none);
			}
		}

		return this.each(function() {
			init($(this), connectors);
		});
	};


	$.fn.remoteSystemConnectors.defaults = {
		label		: 'External/Remote system',
		title		: 'A connected external/remote system',
		none		: 'There are no external/remote system connectors deployed on this codeBeamer instance!',
		toggleAll	: '(De-)Select all connected external/remote systems',
		toggleThis  : '(De-)Select this external/remote system'
	};


	// A plugin to get the selected remote/external systems from a list of all deployed connectors to external/remote systems
	$.fn.getSelectedRemoteSystems = function() {
		var result = [];

		$('table.connectors tr.connector', this).each(function() {
			var row = $(this);
			if (row.find('input[type="checkbox"][name="selector"]:checked').length > 0) {
				result.push(row.data('connector'));
			}
		});

		return result;
	};


	// A plugin to show a popup dialog, that allows to select remote/external system connnectors from a list of all deployed connectors
	$.fn.showRemoteConnectorsDialog = function(connectors, config, dialog, callback) {
		var settings = $.extend({}, $.fn.showRemoteConnectorsDialog.defaults, dialog);

		function showConnectors(connectors) {
			if ($.isArray(connectors) && connectors.length > 0) {
				var popup = $('#chooseRemoteConnectorPopup');
				if (popup.length == 0) {
					popup = $('<div>', { id : 'chooseRemoteConnectorPopup', "class" : 'editorPopup', style : 'overflow: auto; display: None;' });
					$(document.documentElement).append(popup);
				} else {
					popup.empty();
				}

				popup.remoteSystemConnectors(connectors, config);

				settings.buttons = [{
					text  : settings.submitText,
					click : function() {
						var selected = popup.getSelectedRemoteSystems();

						popup.dialog("close");
						popup.remove();

						if ($.isFunction(callback)) {
							callback(selected);
						}
					}
				}, {
					text   : settings.cancelText,
				   "class" : "cancelButton",
					click  : function() {
						window.location.href = settings.cancelUrl;
						return false;
					}
				}];

			    settings.close = function() {
		  			popup.remove();
			    };

				popup.dialog(settings);

			} else if ($.isFunction(callback)) {
				callback(connectors);
			}
		}

		function loadConnectors() {
			var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

		    $.ajax(settings.url, {
		    	type 	 : 'GET',
		    	dataType : 'json',
		    	cache	 : false
		    }).done(function(result) {
				ajaxBusyIndicator.close(busy);
				showConnectors(result);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
				showAjaxError(jqXHR, textStatus, errorThrown);
			});
		}

		if ($.isArray(connectors)) {
			showConnectors(connectors);
		} else {
			loadConnectors();
		}

		return this;
	};


	$.fn.showRemoteConnectorsDialog.defaults = {
		url				: contextPath + '/sysadmin/ajax/remoteConnectors.spr',
		label			: 'Connectors...',
		title			: 'Available remote system connectors',
		loading 		: 'Loading remote system connectors ...',
		submitText		: 'OK',
		cancelText		: 'Cancel',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 640
	};


	// A plugin to show existing connections to (selected) external/remote systems in a container
	$.fn.remoteSystemConnections = function(config) {
		var settings  = $.extend(true, {}, $.fn.remoteSystemConnections.defaults, config);
		var container = this;

		function openConnection(event) {
			event.preventDefault();
			eval($(this).data('settings'));
			return false;
		}

		function openTarget(event) {
			event.preventDefault();
			window.open($(this).attr('href'), "_blank");
			return false;
		}

		function showConnections(tbody, row, projId, trkId, connections) {
			if ($.isArray(connections) && connections.length > 0) {
				for (var i = 0; i < connections.length; ++i) {
					var connection = connections[i];
					var createdBy  = connection.createdBy;

					if (i > 0) {
						if (trkId) {
							row = $('<tr>', { "class" : 'odd tracker secondary', "data-tt-parent-id" : projId, "data-tt-id" : trkId, style : 'vertical-align: top;' });
						} else {
							row = $('<tr>', { "class" : 'even project secondary', "data-tt-id" : projId, style : 'vertical-align: top;' });
						}
						tbody.append(row);
					}

					row.append($('<td>', {
					   "class": 'column-minwidth',
					    title : connection.remote.type,
						style : 'vertical-align: middle; text-align: center;'
					}).append($('<img>', {
						src   : connection.remote.icon,
						alt   : '?'
					})));

					var cell = $('<td>', {
					   "class": 'textData',
						style : 'vertical-align: middle;'
					}).append($('<a>', {
						href  : '#'
					}).text(connection.remote.type + ' ' + connection.remote.description).data('settings', connection.remote.settings).click(openConnection));

					if ($.isPlainObject(connection.remote.error)) {
						cell.append($('<a>', {
							href  : '#',
							title : settings.remote.error.title,
							style : 'margin-left: 6px;'
						}).append($('<img>', {
							src   : settings.remote.error.icon,
							alt   : settings.remote.error.label,
							style : 'position: relative; top: +4px;'
						})).data('error', connection.remote.error).click(function(event) {
							event.preventDefault();
							showFancyAlertDialog($(this).data('error').message);
							return false;
						}));
					}

					row.append(cell);

					row.append($('<td>', { "class" : 'textData', style : 'vertical-align: middle;' }).text(connection.remote.server));

					row.append($('<td>', {
					   "class": 'textData',
					    style : 'vertical-align: middle;'
					}).append($('<a>', {
						href  : contextPath + '/userdata/' + createdBy.id,
					    title : createdBy.realName
					}).text(createdBy.name).click(openTarget)));

					row.append($('<td>', { "class" : 'dateData', style : 'vertical-align: middle;' }).text(connection.createdAt));
				}
			} else {
				row.append($('<td>', { colspan : 5 }));
			}
		}

		function showProjects(projects) {
			container.empty();
			container.helpLink(settings.help);

			var title = $('<p>');

			var parts = settings.title.split(/[\[\]]/);
			if (parts.length > 1) {
				for (var i = 0; i < parts.length; ++i) {
					if (i == 1) {
						title.append($('<a>', { href : '#' }).text(parts[i]).click(selectConnectors));
					} else {
						title.append(parts[i]);
					}
				}
			} else {
				title.text(settings.title);
			}

			container.append(title);

			if ($.isArray(projects) && projects.length > 0) {
				var table = $('<table>', { "class" : 'displaytag projects'});
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var headline = $('<tr>',  { "class" : 'head', style : 'vertical-align: middle;' });
				header.append(headline);

				var cell = $('<th>', { "class": 'textData',	title : settings.target.title });

				cell.append($('<a>', { href : '#', title : settings.collapseAll, style : 'margin-Left: 4px; text-decoration: none;' }).text('\u25C2').click(function(event) {
					event.preventDefault();
					table.treetable('collapseAll');
					return false;
				}));

				cell.append($('<label>', { style : 'margin-Left: 8px;' }).text(settings.target.project.label));

				cell.append($('<a>', { href : '#', title : settings.expandAll, style : 'margin-Left: 8px; text-decoration: none;' }).text('\u25B8').click(function(event) {
					event.preventDefault();
					table.treetable('expandAll');
					return false;
				}));

				cell.append($('<label>', { style : 'margin-Left: 8px;' }).text(settings.target.tracker.label));

				headline.append(cell);
				headline.append($('<th>', { "class" : 'textData', title : settings.remote.title, colspan : 2 }).text(settings.remote.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.remote.server.title }).text(settings.remote.server.label));
				headline.append($('<th>', { "class" : 'textData', title : settings.createdBy.title }).text(settings.createdBy.label));
				headline.append($('<th>', { "class" : 'dateData', title : settings.createdAt.title }).text(settings.createdAt.label));
				headline.append($('<th>'));

				var tbody = $('<tbody>');
				table.append(tbody);

				for (var i = 0; i < projects.length; ++i) {
					var project 	= projects[i];
					var projId  	= 'prj-' + project.id;
					var connections = project.connections;

					var row = $('<tr>', { "class" : 'even project', "data-tt-id" : projId, style : 'vertical-align: top;' });
					tbody.append(row);

					row.append($('<td>', {
					   "class"  : 'textData projName',
						style   : 'vertical-align: middle;',
						rowspan : $.isArray(connections) && connections.length > 0 ? connections.length : 1
					}).append($('<img>', {
					   "class"  : 'tableIcon',
						src		: contextPath + project.icon,
						style   : 'position: relative; top: +3px; background-color:#5f5f5f; margin-right: 6px;'
					})).append($('<a>', {
						href    : contextPath + '/project/' + project.id,
						title   : project.description
					}).text(project.name).click(openTarget)));

					showConnections(tbody, row, projId, null, connections);

					var trackers = project.trackers;
					if ($.isArray(trackers) && trackers.length > 0) {
						for (var j = 0; j < trackers.length; ++j) {
							var tracker = trackers[j];
							var trkId   = 'trk-' + tracker.id;

							row = $('<tr>', { "class" : 'odd tracker', "data-tt-parent-id" : projId, "data-tt-id" : trkId, style : 'vertical-align: top;' });
							tbody.append(row);

							connections = tracker.connections;

							row.append($('<td>', {
							   "class"  : 'textData',
								style   : 'vertical-align: middle;',
								rowspan : $.isArray(connections) && connections.length > 0 ? connections.length : 1
							}).append($('<img>', {
							   "class"  : 'tableIcon',
								src   	: contextPath + tracker.icon,
								style   : 'position: relative; top: +3px; background-color:#5f5f5f; margin-right: 6px;'
							})).append($('<a>', {
								href    : contextPath + '/tracker/' + tracker.id,
								title   : tracker.description
							}).text(tracker.name).click(openTarget)));

							showConnections(tbody, row, projId, trkId, connections);
						}
					}
				}

				table.treetable({
					column		 : 0,
					expandable   : true,
					initialState : 'collapsed'
				});

				container.append($('<div>', { "class" : 'subtext', style : 'margin-top: 2em;' }).text(settings.hint));
			} else {
				container.append($('<span>', { "class" : 'subtext' }).text(settings.none));
			}
		}

		function loadConnections(connectors) {
			if ($.isArray(connectors) && connectors.length > 0) {
				var busy = ajaxBusyIndicator.showBusyPage(settings.loading);

			    $.ajax(settings.url, {
			    	type 	 : 'GET',
			    	data 	 : {
			    		remoteTypeId : $.map(connectors, function(connector) {
			    			return connector.id;
			    		}).join(),
			    		validate : settings.validate
			    	},
			    	dataType : 'json',
			    	cache	 : false
			    }).done(function(result) {
					ajaxBusyIndicator.close(busy);
					showProjects(result);
				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					showAjaxError(jqXHR, textStatus, errorThrown);
				});
			} else {
				showProjects(null);
			}
		}

		function selectConnectors() {
			container.showRemoteConnectorsDialog(settings.connectors.list, settings.connectors.config, settings.connectors.dialog, loadConnections);
		}

		selectConnectors();

		return container;
	};


	$.fn.remoteSystemConnections.defaults = {
		title		: 'Connections to the [selected external/remote systems]:',
		url			: contextPath + '/sysadmin/ajax/remoteAssociations.spr',
		validate    : true,
		loading		: 'Loading connections to the selected external/remote systems ...',
		none		: 'There are no connections to any of the selected external/remote systems !',
		hint		: 'In order to see (or edit) details about the connected remote systems, you must be an administrator of the target project and/or tracker!',
		collapseAll : 'Collapse all',
		expandAll   : 'Expand all',

		connectors	: {
			config	: $.fn.remoteSystemConnectors.defaults,
			dialog	: $.fn.showRemoteConnectorsDialog.defaults
		},

		target		: {
			title	: 'The Projects and/or Trackers, that are connected with external/remote systems',
			project	: {
				icon	: contextPath + '/images/issuetypes/project.gif',
				label	: 'Project'
			},
			tracker	: {
				icon	: contextPath + '/images/issuetypes/issue.png',
				label	: 'Tracker'
			}
		},

		remote 		: {
			label	: 'Connected with',
			title	: 'The external/remote system, the project/tracker is associated with',

			server	: {
				label	: 'On Host',
				title	: 'The external/remote server, that hosts the external/remote system'
			},

			error	: {
				icon 	: contextPath + '/images/warn.gif',
				label	: 'Validation failed',
				title	: 'Validation of this external/remote connection failed'
			}
		},

		createdBy	: {
			label	: 'Created by',
			title	: 'The user, that created this remote association'
		},

		createdAt	: {
			label	: 'Created at',
			title	: 'Date and time, this remote association was created'
		}
	};


})( jQuery );

