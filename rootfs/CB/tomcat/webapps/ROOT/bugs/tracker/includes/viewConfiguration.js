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

	function getNodeConfig(treeNodeDom) {
		var tree = $.jstree.reference(treeNodeDom);
		var node = tree.get_node(treeNodeDom);
		var config = node.original.metadata.config;

		return config;
	}

	function getFilterStats(criteria) {
		function addStats(filters, stats) {
			if ($.isArray(filters) && filters.length > 0) {
				for (var i = 0; i < filters.length; ++i) {
					if (filters[i] != null) {
						if (filters[i].hasOwnProperty('field')) {
							if (filters[i].op && filters[i].op.value == 'd') {
								stats.updates++;
							} else {
								stats.filters++;
							}
						} else if (filters[i].hasOwnProperty('block')) {
							stats.blocks++;

							addStats(filters[i].filters, stats);
						}
					}
				}
			}
		}

		var stats = {
			blocks  : 0,
			filters : 0,
			updates : 0
		};

		addStats(criteria, stats);

		return stats;
	}

	// Tracker View Configuration Plugin definition.
	$.fn.viewLayoutConfiguration = function(columns, options) {
		var settings = $.extend( {}, $.fn.viewLayoutConfiguration.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function setup() {
			$(document).on('click', '.visibleField .removeButton', function () {
				var field  = $(this).closest('.visibleField');
                var table    = field.closest('table');
                var selector = table.next('select.fieldSelector');
                var value    = $('input[name="visibleField"]', field).val();
                var label    = $('label', field);
                var name     = label.text();
                var option   = $('<option>', { value : value, title : label.attr('title') }).text(name);

                $('option', selector).each(function(index, elem) {
                        var current = $(this);
                        if (index > 0 && option != null && name.localeCompare(current.text()) <= 0) {
                                option.insertBefore(current);
                                option = null;
                                return false;
                        }
                });

                if (option != null) {
                        selector.append(option);
                }

                field.remove();
                selector.show();

                if ($('th.visibleField', table).length == 0) {
                        $('option:first', selector).text(getSetting('defaultLabel'));
                        $(getSetting('labelColumn')).addClass('empty');
                }
			});
		}

		function init(container, columns) {
			if (!$.isArray(columns)) {
				columns = [];
			}

			if (columns.length > 0 || settings.editable) {
				var hideAllLink = $('<a>', {title: settings.hideAllLabel, 'class': 'edit-link'}).html(settings.hideAllLabel);
				hideAllLink.click(function () {
					var table    = $(this).siblings('table');
					var selector = table.next('select.fieldSelector');

					$('th.visibleField', table).each(function() {
  						var field  = $(this);
   	  					var value  = $('input[name="visibleField"]', field).val();
   	  					var label  = $('label', field);
   	  					var name   = label.text();
   	  					var option = $('<option>', { value : value, title : label.attr('title') }).text(name);

   	  					$('option', selector).each(function(index, elem) {
   	  						var current = $(this);
   	  						if (index > 0 && option != null && name.localeCompare(current.text()) <= 0) {
   	  							option.insertBefore(current);
   	  							option = null;
   	  							return false;
   	  						}
   	  					});

   	  					if (option != null) {
   	  						selector.append(option);
   	  					}

   	  					field.remove();
					});

  					selector.show();

   	  				if ($('th.visibleField', table).length == 0) {
   	  					$('option:first', selector).text(getSetting('defaultLabel'));
   	  					$(getSetting('labelColumn')).addClass('empty');
  					}
				});
				container.append(hideAllLink);
				var table  = $('<table>', { "class" : 'columns' });
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var fields = $('<tr>', { "class" : 'visibleFields' });
				header.append(fields);

				for (var i = 0; i < columns.length; ++i) {
					var field = $('<th>', { "class" : settings.editable ? 'visibleField' : 'readOnly', nowrap : 'nowrap' });
					field.append($('<input>', { type : 'hidden', name : 'visibleField', value : columns[i].value }));
					field.append($('<label>', { title : columns[i].title }).text(columns[i].label));

					field.append($('<span>', {'class': 'removeButton', 'title': settings.removeLabel, 'style': 'margin-left: 5px;'}));
					fields.append(field);
				}

				if (settings.editable) {
					if (!$.isArray(settings.fields)) {
						settings.fields = [];
					}

					var selector = $('<select>', { "class" : 'fieldSelector' });
					container.append(selector);

					selector.append($('<option>', {value: '-1', style: 'color: gray; font-style: italic;'}).text(columns.length == 0 ? settings.defaultLabel : settings.moreLabel));

					for (var i = 0; i < settings.fields.length; ++i) {
						selector.append($('<option>', { value : settings.fields[i].value, title : settings.fields[i].title }).text(settings.fields[i].label));
				    }

					selector.change(function() {
						var value = this.value;
						if (value != '-1') {
							var option = $('option:selected', this);
							var label = option.text();
							var field = $('<th>', { "class" : 'visibleField', nowrap : 'nowrap' });
							field.append($('<input>', { type: 'hidden', name: 'visibleField', value: value}));
							field.append($('<label>', { title : option.attr('title') }).text(label));
							field.append($('<span>', {'class': 'removeButton', 'title': settings.removeLabel}));

							fields.append(field);

							// Remove the field from the selector
							var options = this.options;
							for (var j = 0; j < options.length; ++j) {
								if (options[j].value == value) {
									this.remove(j);
									break;
								}
							}

							// Hide selector if all fields updates were chosen
							if (options.length > 1) {
								options[0].text = getSetting('moreLabel');
								options[0].selected = true;
							} else {
								$(this).hide();
							}

							$(getSetting('labelColumn')).removeClass('empty');
						}
					});

					if (settings.fields.length == 0) {
						selector.hide();
					}

					/** Make the visible fields/columns sortable */
					fields.sortable({
						items		: "> th",
						containment	: table,
						axis		: "x",
						cursor		: "move",
						delay		: 150,
						distance	: 5
					});
				}
			} else {
				container.append(settings.defaultLabel);
			}
		}

		if ($.fn.viewLayoutConfiguration._setup) {
			$.fn.viewLayoutConfiguration._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), columns);
		});
	};

	$.fn.viewLayoutConfiguration.defaults = {
		editable	 : false,
		fields		 : [],
		defaultLabel : 'Default',
		moreLabel	 : 'More ...',
		hideLabel	 : 'Hide',
		hideAllLabel : 'Hide all'
	};

	$.fn.viewLayoutConfiguration._setup = true;


	// Complimentary plugin to viewLayoutConfiguration to get the current visible fields/columns configuration back
	$.fn.getViewFields = function() {
		var fields = [];

		$('tr.visibleFields > th', this).each(function(index, field) {
			var label = $('label', field);

			fields.push({
				value : $('input', field).val(),
				label : label.text(),
				title : label.attr('title')
			});
		});

		return fields;
	};


	// Tracker View Configuration Plugin definition.
	$.fn.viewOrderByConfiguration = function(orderedBy, options) {
		var settings = $.extend( {}, $.fn.viewOrderByConfiguration.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function toggleSortOrder() {
			var toggle = $(this);
			var descending = $('input', toggle);

			if (descending.val() == 'true') {
				descending.val('false');
				toggle.removeClass('descending');
				toggle.addClass('ascending');
			} else {
				descending.val('true');
				toggle.removeClass('ascending');
				toggle.addClass('descending');
			}
			return false;
		}

		function setup() {
			$(document).on('click', '.sortFields .removeButton', function () {
				var orderBy  = $(this).closest('.sortField');
				var table    = orderBy.closest('table');
				var selector = table.next('select.sortFieldSelector');
				var value    = $('input[name="orderBy"]', orderBy).val();
				var label    = $('label:first', orderBy);
				var name     = label.text();
				var option   = $('<option>', { value : value, title : label.attr('title') }).text(name);

				$('option', selector).each(function(index, elem) {
					var current = $(this);
					if (index > 0 && option != null && name.localeCompare(current.text()) <= 0) {
						option.insertBefore(current);
						option = null;
						return false;
					}
				});

				if (option != null) {
					selector.append(option);
				}

				orderBy.remove();
				selector.show();

  				if ($('th.sortField', table).length == 0) {
  					$('option:first', selector).text(getSetting('defaultLabel'));
  					$(getSetting('labelColumn')).addClass('empty');
				}
			});
		}

		function init(container, orderedBy) {
			if (!$.isArray(orderedBy)) {
				orderedBy = [];
			}

			if (orderedBy.length > 0 || settings.editable) {
				var table  = $('<table>', { "class" : 'columns' });
				container.append(table);

				var header = $('<thead>');
				table.append(header);

				var orderBy = $('<tr>', { "class" : 'sortFields' });
				header.append(orderBy);

				for (var i = 0; i < orderedBy.length; ++i) {
					var sortOrder = $('<span>', { "class" : orderedBy[i].descending ? 'sort descending' : 'sort ascending' });
					sortOrder.append($('<input>', { type : 'hidden', name : 'descending', value : orderedBy[i].descending }));

					var field = $('<th>', { "class" : settings.editable ? 'sortField' : 'readOnly', nowrap : 'nowrap' });
					field.append($('<input>', { type : 'hidden', name : 'orderBy', value : orderedBy[i].value }));
					field.append($('<label>', { title : orderedBy[i].title }).text(orderedBy[i].label));

					field.append(sortOrder);

					field.append($('<a>', {'class': 'removeButton', title: settings.removeLabel}));

					orderBy.append(field);
				}

				if (settings.editable) {
					if (!$.isArray(settings.sortableBy)) {
						settings.sortableBy = [];
					}

					var selector = $('<select>', { "class" : 'sortFieldSelector' });
					container.append(selector);

					selector.append($('<option>', {value: '-1', style: 'color: gray; font-style: italic;'}).text(orderedBy.length == 0 ? settings.defaultLabel : settings.moreLabel));

					for (var i = 0; i < settings.sortableBy.length; ++i) {
						selector.append($('<option>', { value : settings.sortableBy[i].value, title : settings.sortableBy[i].title }).text(settings.sortableBy[i].label));
				    }

					selector.change(function() {
						var value = this.value;
						if (value != '-1') {
							var option = $('option:selected', this);
							var label  = option.text();

							var sortOrder = $('<span>', { "class": 'sort descending' });
							sortOrder.append($('<input>', { type: 'hidden', name: 'descending', value: true }));
							sortOrder.click(toggleSortOrder);

							var field = $('<th>', { "class" : 'sortField', nowrap : 'nowrap' });
							field.append($('<input>', { type : 'hidden', name : 'orderBy', value : value}));
							field.append($('<label>', { title : option.attr('title') }).text(label));
							field.append(sortOrder);

							field.append($('<a>', {'class': 'removeButton', title: settings.removeLabel}));

							orderBy.append(field);

							// Remove the field from the selector
							var options = this.options;
							for (var j = 0; j < options.length; ++j) {
								if (options[j].value == value) {
									this.remove(j);
									break;
								}
							}

							// Hide selector if all fields updates were chosen
							if (options.length > 1) {
								options[0].text = getSetting('moreLabel');
								options[0].selected = true;
							} else {
								$(this).hide();
							}

							$(getSetting('labelColumn')).removeClass('empty');
						}
					});

					if (settings.sortableBy.length == 0) {
						selector.hide();
					}

					/** Make the order by fields/columns sortable */
					orderBy.sortable({
						items		: "> th",
						containment	: table,
						axis		: "x",
						cursor		: "move",
						delay		: 150,
						distance	: 5
					});

					$('span.sort', orderBy).click(toggleSortOrder);
				}

				if (orderedBy.length > 0) {
					$(getSetting('labelColumn')).removeClass('empty');
				}
			} else {
				container.append(settings.defaultLabel);
			}
		}

		if ($.fn.viewOrderByConfiguration._setup) {
			$.fn.viewOrderByConfiguration._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), orderedBy);
		});
	};

	$.fn.viewOrderByConfiguration.defaults = {
		editable	 : false,
		sortableBy   : [],
		labelColumn  : '#sortingLabel',
		defaultLabel : 'Default',
		moreLabel	 : 'More ...',
		removeLabel	 : 'Remove'
	};

	$.fn.viewOrderByConfiguration._setup = true;


	// Complimentary plugin to viewOrderByConfiguration to get the current order By configuration back
	$.fn.getViewOrderBy = function() {
		var orderBy = [];

		$('tr.sortFields > th', this).each(function(index, field) {
			var label = $('label', field);

			orderBy.push({
				value      : $('input[name="orderBy"]', field).val(),
				label      : label.text(),
				title	   : label.attr('title'),
				descending : $('input[name="descending"]', field).val() == 'true'
			});
		});

		return orderBy;
	};


	// Tracker View Configuration Plugin definition.
	$.fn.trackerFilterConfiguration = function(type, filters, options) {
		var settings = $.extend( {}, $.fn.trackerFilterConfiguration.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function getBlockText(op) {
			var result = op;
			switch(op) {
			case 'NOT':
				result = settings.notLabel;
				break;
			case 'OR':
				result = settings.orLabel;
				break;
			default:
				result = settings.andLabel;
				break;
			}

			return result;
		}

		function createValueEditor(editor, criteria, params) {
        	// Get an editor form for the field filter criteria
 	        $.ajax(settings.filterUrl, {
 	        	type  : 'GET',
	        	async : params.async || false,
 	        	cache : false,
 	        	data  : {
 	        		"var"	: criteria["var"] || '',
 	        		field 	: criteria.field.id,
 	        		"not" 	: criteria["not"] || false,
 	        		 op 	: criteria.op ? criteria.op.value : 'i',
 	        		value 	: criteria.value || '',
 	        		htmlId 	: params.htmlId || '',
 	        	  showField : !params.async
 	        	}
 	        }).done(function(html) {
 	        	editor.append($(html));
 	        	setTimeout(function() {
 	        		editor.referenceFieldAutoComplete();
 	        	}, 200);
        	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
         	});
		}

		function setValueFilter(editor, config, callback) {
   			var data = {
   				"var" : config["var"],
   				field : config.field.id
   			};

   			editor.find('[name^="filter."]').each(function(index, field) {
				var name = field.name.substring(7);
				data[name] = (name == 'not' ? (field.checked ? 'true' : 'false') : field.value);
			});

		    $.post(settings.filterUrl, data, function(result) {
			 	callback($.extend(config, result));

			}).fail(function(jqXHR, textStatus, errorThrown) {
				alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		 	});
    	}

		function createChangeFilterEditor(form, data) {
			var table = $('<table>', { "class" : 'changeFilterEditor' }).data('field', data.field);
			form.append(table);

			var fieldRow   = $('<tr>', { style : 'vertical-align: middle;' });
			var fieldLabel = $('<td>', { "class" : 'labelCell optional', title : data.field.title, style : 'vertical-align: middle;' }).text(data.field.name + ': ');
			var fieldMode  = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox fieldMode' });
			var fieldValue = $('<td>', { "class" : 'dataCell fieldValue' });

			var mode = (data.op && data.op.value == 'd' ? 'changed' : (data["var"] == 'before' ? 'before' : 'after'));

			var modeSelector = $('<select>', { name : 'variable' });
			modeSelector.append($('<option>', { value : 'changed', selected : mode == 'changed', title : settings.changedTitle }).text(settings.changedLabel));
			modeSelector.append($('<option>', { value : 'before',  selected : mode == 'before',  title : settings.beforeTitle  }).text(settings.beforeLabel));
			modeSelector.append($('<option>', { value : 'after',   selected : mode == 'after',   title : settings.afterTitle   }).text(settings.afterLabel));

			modeSelector.change(function() {
				var mode = this.value;
				if (mode == 'changed') {
					fieldValue.hide();
				} else {
					data["var"] = mode;

					if (data.op && data.op.value == 'd') {
						data.op.value = 'i';
						data.op.label = 'in';
					}

					if (fieldValue.is(':empty')) {
						createValueEditor(fieldValue, data, {
							async  : true,
							htmlId : 'fieldValue'
						});
					}

					fieldValue.show();
				}
			}).change();

			fieldMode.append(modeSelector);
			fieldRow.append(fieldLabel);
			fieldRow.append(fieldMode);
			fieldRow.append(fieldValue);
			table.append(fieldRow);
		}

		function setChangeFilter(editor, config, callback) {
			var mode = $('select[name="variable"]', editor).val();
			if (mode == 'changed') {
				delete config["var"];
				delete config["not"];
				delete config.value;

				config.op = { value : 'd', label : mode };

				callback(config);

			} else {
				config["var"] = mode;

				setValueFilter($('td.fieldValue', editor), config, callback);
			}
		}

		function createReferenceFilterEditor(form, data) {
			var notSelector = $('<select>', { name : 'has' });
			notSelector.append($('<option>', { value : 'false', selected : data["not"] == false }).text(settings.hasRefsLabel));
			notSelector.append($('<option>', { value : 'true',  selected : data["not"] == true  }).text(settings.hasNoRefsLabel));
			form.append(notSelector);

			form.append(' ');
			form.append($('<label>', { style : 'font-weight: bold;' }).text(data.type.label));

			form.append($('<br>'));
			form.append(settings.withStatusLabel + ' ');
			var flagsSelector = $('<select>', { name : 'flags' });
			for (var i = 0; i < settings.referenceFlags.length; ++i) {
				flagsSelector.append($('<option>', { value : settings.referenceFlags[i].id, selected : data.flags.id == settings.referenceFlags[i].id }).text(settings.referenceFlags[i].name));
			}
			form.append(flagsSelector);

			form.append($('<br>'));
			form.append(settings.andDueLabel + ' ');
			var filterSelector = $('<select>', { name : 'filter' });
			for (var i = 0; i < settings.referenceFilters.length; ++i) {
				filterSelector.append($('<option>', { value : settings.referenceFilters[i].id, selected : data.filter.id == settings.referenceFilters[i].id }).text(settings.referenceFilters[i].name));
			}
			form.append(filterSelector);
		}

		function setReferenceFilter(editor, config) {
			var has    = $('select[name="has"] > option:selected', editor);
			var flags  = $('select[name="flags"] > option:selected', editor);
			var filter = $('select[name="filter"] > option:selected', editor);

    		config['not'] = (has.val() == 'true');
    		config.flags  = { id : parseInt(flags.val()),  name : flags.text() };
    		config.filter = { id : parseInt(filter.val()), name : filter.text() };
		}

		function editFilter(popup, anchor, config, callback) {
			popup.empty();

			if (config.hasOwnProperty('field')) {
	        	if (config.field.id == 86) {
	        		createReferenceFilterEditor(popup, config);
	        	} else if (type == 4) {
	        		createChangeFilterEditor(popup, config);
	        	} else {
					createValueEditor(popup, config, {
						async  : false,
						htmlId : 'filter'
					});
	        	}

				popup.dialog({
					dialogClass	  : 'popup inline',
					position	  : { my: "left top", at: "left top", of: anchor, collision: 'fit' },
					width		  : type == 4 ? 700 : 600,
					height		  : 160,
					modal		  : true,
					draggable	  : true,
					closeOnEscape : false,
					buttons       : [
					     			   { text : settings.submitText,
					     				 click: function() {
							     		        	if (config.field.id == 86) {
						     					 		setReferenceFilter(popup, config);
						     						 	callback(config);
							     		        	} else if (type == 4) {
							     		        		setChangeFilter(popup, config, callback);
							     		        	} else {
							     		        		setValueFilter(popup, config, callback);
							     		        	}

					     					 		popup.dialog("close");
					     						}
					     				},
					     				{ text : settings.cancelText,
										  "class": "cancelButton",
					     				  click: function() {
					     					  		popup.dialog("close");
					     						 }
					     				}
				     			    ]
				});
			} else if (config.hasOwnProperty('block')) {
	    		var selector = $('<select>');

	    		selector.append($('<option>', { value : 'AND', selected : config.block == 'AND' }).text(getSetting('andLabel')));
	    		selector.append($('<option>', { value : 'OR' , selected : config.block == 'OR'  }).text(getSetting('orLabel' )));
	    		selector.append($('<option>', { value : 'NOT', selected : config.block == 'NOT' }).text(getSetting('notLabel')));

	    		selector.change(function() {
	    			config.block = this.value;
				 	popup.dialog("close");
				 	callback(config);
	           	});

	    		popup.append(selector);

				popup.dialog({
					title		  : settings.blocksLabel,
					dialogClass	  : 'popup overlay',
					position	  : { my: "left center", at: "left center", of: anchor, collision: 'fit' },
					minWidth	  : 64,
					width		  : popup.width() + 10,
					height		  : 100,
					modal		  : true,
					draggable	  : false,
					closeOnEscape : true,
					buttons       : []
				});
			}
		}

		function renderCriteria(container, config) {
			if (config['var']) {
				container.append(' ' + getSetting(config['var'] + 'Label'));
			}
			if (config['not']) {
				container.append(' ' + settings.notLabel);
			}
			if (config.op) {
				container.append(' ' + config.op.label);
			}
			if (config.rendered) {
				container.append(' "' + config.rendered + '"');
			}
		}

		function renderFilter(container, config) {
			if (config.field.id == 86) {
				container.append((config['not'] ? settings.hasNoRefsLabel : settings.hasRefsLabel) + ' ');
				container.append($('<label>').text(config.type.label));

				if (config.flags.id > 0) {
					container.append(' ' + settings.withStatusLabel + ' "' + config.flags.name + '"');
				}

				if (config.filter.id > 0) {
					container.append(' ' + settings.andDueLabel + ' "' + config.filter.name + '"');
				}
			} else {
				container.append($('<label>', { title : config.field.title, style : 'font-weight: bold;' }).text(config.field.name));

				if (config.op && config.op.value == 'd') {
					container.append($('<label>', { title : settings.changedTitle, style : 'margin-left: 4px;' }).text(settings.changedLabel));
				} else {
					renderCriteria(container, config);
				}
			}
		}

		/**
		 * returns the config stored in the metadata attribute for a dom node from the tree.
		 */
		function getFilterText(config) {
			var span = $('<span>');
			renderFilter (span, config);
			return span.html();
		}

		function newFilterNode(config) {
			return {
				type	: "filter",
				text 	: getFilterText(config),
				metadata: {
					config: config
				}
			};
		}

		function newBlockNode(config) {
			return {
				type 	 : "block",
				text 	 : getBlockText(config.block),
				children : [],
				state 	 : {
					opened : true
				},
				metadata : {
					config: config
				}
			};
		}

		function addFilters(nodes, filters) {
			if ($.isArray(filters)) {
				for (var i = 0; i < filters.length; ++i) {
					if (filters[i] != null) {
						if (filters[i].hasOwnProperty('field')) {
							nodes.push(newFilterNode(filters[i]));
						} else if (filters[i].hasOwnProperty('block')) {
							var node = newBlockNode(filters[i]);

							addFilters(node.children, filters[i].filters);

							nodes.push(node);
						}
					}
				}
			}
		}

		function setup() {
			/* Disable the jstree rollback feature: We don't need it and it makes things slooooooooow */
//			$.jstree._fn.get_rollback = function() {
//				this.__callback();
//				return false;
//			};
		}

		function init(container, filters) {
			if (!$.isArray(filters)) {
				filters = [];
			}

			if (filters.length > 0 || settings.editable) {
				var rootLabel = $('<label>', { "class" : 'treeRoot', style : "display: None;" }).text(settings.andLabel);
				container.append(rootLabel);

				var criteria = $('<div>', { "class" : 'criteria', style : "display: None;" });
				container.append(criteria);

				var popup = $('<div>', { "class" : 'popup overlay', style : "display: None;" });
				container.append(popup);

				var nodes = [];
				addFilters(nodes, filters);

				var addIconsForAnchor = function($anchor) {
					// if the icons have been already added then skip this node
					if ($anchor.find(".removeButton").size()) {
						return;
					}

					var $removeButton = $("<span>", {"class": "removeButton"});
					$anchor.append($removeButton);

					var $editButton = $("<span>", {"class": "editButton"});
					$anchor.append($editButton);
				};

				var addIcons = function() {
					criteria.find(".jstree-anchor").each(function () {
						var $anchor = $(this);

						addIconsForAnchor($anchor);
					});
				};

				criteria.jstree({
					// the `plugins` array allows you to configure the active plugins on this instance
					plugins : [ "types", "dnd" ],

					core : {
						data		: nodes,
						html_titles : true,
						animation	: 0,
						themes 		: {
							url 	: contextPath + "/js/jquery/jquery-jstree/themes/default/style.css",
							icons 	: false
						},
						check_callback : function(operation, node, parent, position, more) {
		                    // operation can be 'create_node', 'rename_node', 'delete_node', 'move_node' or 'copy_node'
		                    // in case of 'rename_node' node_position is filled with the new node name
		                    if (operation === 'move_node' || operation === 'copy_node') {
		                        return parent.id === '#' || parent.original.type === "block"; //only allow dropping inside root node or nodes of type 'block'
		                    }
		                    return true;  //allow all other operations
		                }
		            },

					types : {
					    block : {
							li_attr : {
								"class" : "block"
							},

					    	valid_children : ["block", "filter"]
					    },

					    filter : {
							li_attr : {
								"class" : "filter"
							},
					    	max_children   : 0,
					    	valid_children : []
					    }
					},

					dnd : {
		                check_while_dragging: true,
						large_drop_target : true,
						large_drag_target : true
					}

				}).bind("dblclick.jstree", function (event) {
					var node = $(event.target).closest("li");
					var config = getNodeConfig(node);
					editFilter(popup, node, config, function(result) {
						var text = null;
						if (result.hasOwnProperty('field')) {
							text = getFilterText(result);
						} else if (result.hasOwnProperty('block')) {
							text = getBlockText(result.block);
						}
						if (text != null) {
							criteria.jstree("set_text", node, text);
						}

						addIcons();
					});
				}).bind("click.jstree", function (event) {
					var $eventTarget = $(event.target),
						node = $eventTarget.closest("li");

					// if the tree node is opened we need to add the remove/edit icons
					if ($eventTarget.hasClass('jstree-icon') && node.hasClass('jstree-open')) {
						addIcons();
					}
				});;

				if (settings.editable) {
					criteria.bind("loaded.jstree create_node.jstree refresh.jstree", function (event, data) {
						// add the edit and delete buttons to the tree nodes
						addIcons();
					});

					// handle the edit and remove events
					criteria.on("click", ".removeButton", function (event) {
   	  					if (confirm(getSetting('removeConfirm'))) {
   	  						var node = $(this).closest("li");
   	  						var tree = $.jstree.reference(node);
   	  						var treeNode = tree.get_node(node);
   	  						var root = tree.get_container_ul();

   	  						tree.delete_node(treeNode ? treeNode : node);

	   	  					if ($('> li', root).length == 0) {
	   	  						rootLabel.hide();
	   	  						criteria.hide();
	   	  						var selector = popup.next('select.filterSelector');
	   	  					$('option:first', selector).text(getSetting('noneLabel'));
	   	  						$(getSetting('labelColumn')).addClass('empty');
	   	  					}

	   	  					addIcons();
	   	  				}
					}).on("click", ".editButton", function (event) {
						var node = $(this).closest("li");
						var config = getNodeConfig(node);
						editFilter(popup, node, config, function(result) {
							var text = null;
							if (result.hasOwnProperty('field')) {
								text = getFilterText(result);
							} else if (result.hasOwnProperty('block')) {
								text = getBlockText(result.block);
							}

							if (text != null) {
								var tree = $.jstree.reference(node);
								var treeNode = tree.get_node(node);

								tree.set_text(treeNode ? treeNode : node, text);
							}

							addIcons();
						});
					});
				}

				if (settings.editable) {
					var selector = $('<select>', { "class" : 'filterSelector' });
					container.append(selector);

					selector.append($('<option>', {value: '-1', style: 'color: gray; font-style: italic;'}).text(filters.length == 0 ? settings.noneLabel : settings.moreLabel));

					var blocks = $('<optgroup>', { label : settings.blocksLabel });
					blocks.append($('<option>', { value : 'AND' }).text(settings.andLabel));
					blocks.append($('<option>', { value : 'OR'  }).text(settings.orLabel));
					blocks.append($('<option>', { value : 'NOT' }).text(settings.notLabel));
					selector.append(blocks);

					if (settings.filterFields.length > 0) {
						var fields = $('<optgroup>', { label : settings.fieldsLabel });
						for (var i = 0; i < settings.filterFields.length; ++i) {
							fields.append($('<option>', { value : settings.filterFields[i].id, title : settings.filterFields[i].description }).text(settings.filterFields[i].name));
					    }

						selector.append(fields);
					}

					if (settings.referenceTypes.length > 0) {
						var referenceTypes = $('<optgroup>', { label : settings.referencesLabel });
						for (var i = 0; i < settings.referenceTypes.length; ++i) {
							referenceTypes.append($('<option>', { value : settings.referenceTypes[i].value }).text(settings.referenceTypes[i].label));
					    }

						selector.append(referenceTypes);
					}

					if (settings.otherFilters.length > 0) {
						var referenceTypes = $('<optgroup>', { label : settings.otherLabel });
						for (var i = 0; i < settings.otherFilters.length; ++i) {
							referenceTypes.append($('<option>', { value : settings.otherFilters[i].id }).text(settings.otherFilters[i].name));
					    }

						selector.append(referenceTypes);
					}

					selector.change(function() {
						var value = this.value;
						if (value != '-1') {
							var more   = this.options[0];
							var option = $('option:selected', this);
							var label  = option.text();
							var target = "#";

							var selected = criteria.jstree("get_selected");
							if (selected && selected.length > 0) {
								for (var node = selected[0]; node && node != '#'; node = criteria.jstree("get_parent", node)) {
									if (criteria.jstree("get_type", node) == "block") {
										target = node;
										break;
									}
								}
							}

							if (value == 'AND' || value == 'OR' || value == 'NOT') {
								rootLabel.show();
								criteria.show();

								var nodeId = criteria.jstree("create_node", target, newBlockNode({
									block   : value,
									filters : []
								}), "last");

								criteria.jstree("deselect_all");
								criteria.jstree("select_node", nodeId);

								more.text = getSetting('moreLabel');
								$(getSetting('labelColumn')).removeClass('empty');
							} else {
								var config = null;

								if (value.indexOf('|') > 0) {
									config = {
										field  : { id : 86, label : '' },
										"not"  : false,
										type   : { value : value, label : label },
										flags  : { id : 0, name : '' },
										filter : { id : 0, name : '' }
									};
								} else if (type == 4) {
									config = {
										field  : { id : parseInt(value), name : label, title : option.attr('title') },
										 op	   : { value : 'd', label : 'changed' }
									};
								} else {
									config = {
										field  : { id : parseInt(value), name : label, title : option.attr('title') },
										"not"  : false,
										 op	   : { value : 'i', label : ':' },
										value  : '',
									   rendered: '--'
									};
								}

								// Todo show filter editor dialog first, and only on OK add the new filter !!
								editFilter(popup, selector, config, function(result) {
									rootLabel.show();
									criteria.show();
									criteria.jstree("create_node", target, newFilterNode(result), "last");

									more.text = getSetting('moreLabel');
									$(getSetting('labelColumn')).removeClass('empty');
								});
							}

							more.selected = true;
						}
					});
				} else {
					criteria.jstree("lock");
				}

				if (filters.length > 0) {
					rootLabel.show();
					criteria.show();
					$(settings.labelColumn).removeClass('empty');
				}
			} else {
				container.append(settings.noneLabel);
			}
		}

		if ($.fn.trackerFilterConfiguration._setup) {
			$.fn.trackerFilterConfiguration._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), filters);
		});
	};

	$.fn.trackerFilterConfiguration.defaults = {
		editable		: false,
		filterUrl		: null,
		filterFields	: [],
		referenceTypes	: [],
		referenceFlags  : [],
		referenceFilters: [],
		labelColumn		: '#filteringLabel',
		editLabel		: 'Edit',
		editTooltip		: 'Double click to edit the condition',
		noneLabel		: 'None',
		moreLabel		: 'More...',
		blocksLabel		: 'Grouping',
		notLabel		: 'not',
		andLabel		: 'and',
		orLabel			: 'or',
		fieldsLabel		: 'Fields',
	   	changedLabel	: 'changed',
	    changedTitle	: 'Criteria, that yields true if the field value has changed',
	    beforeLabel 	: 'was',
	    beforeTitle		: 'Criteria for the old field value before the update',
	    afterLabel 		: 'is',
		afterTitle		: 'Criteria for the new field value after the update',
		hasRefsLabel	: 'Has',
		hasNoRefsLabel	: 'Has no',
		referencesLabel : 'References',
		withStatusLabel : 'with status',
	    andDueLabel		: 'and due',
	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
	    removeLabel		: 'Remove',
	    removeConfirm	: 'Do you really want to remove this condition?'
	};

	$.fn.trackerFilterConfiguration._setup = true;


	// Complimentary plugin to trackerFilterConfiguration to get the current filters back from the configuration editor
	$.fn.getTrackerFilters = function() {
		function getFilters(list) {
			var filters = [];

			$('> ul > li', list).each(function(index, filter) {
				var config = getNodeConfig(filter);

				if (config.hasOwnProperty('block')) {
					config.filters = getFilters.apply(filter, [filter]);
	        	}

	        	filters.push(config);
			});

			return filters;
		}

		var result = getFilters($('div.criteria', this));
		return result;
	};


	// Tracker View Layout Selector plugin
	$.fn.trackerViewLayoutSelector = function(type, layout, options) {
		var settings = $.extend( {}, $.fn.trackerViewLayoutSelector.defaults, options );

		function showLayoutComponents(type, layoutId) {
			var fields  = $(settings.fields);
			var orderBy = $(settings.orderBy);
			var filters = $(settings.filters);

			switch(layoutId) {
			case 1: // document layout
				fields.show();
				orderBy.hide();
				filters.show();
				break;
			case 2: // dashboard layout
				fields.hide();
				orderBy.hide();
				filters.hide();
				break;
			case 3: // review layout
				fields.hide();
				orderBy.hide();
				filters.show();
				break;
			case 4: // cardboard layout
				fields.hide();
				orderBy.hide();
				filters.hide();
				break;
			default: // table layout
				fields.show();
				orderBy.show();
				if (type == 3) { // referring issues view
					filters.hide();
				} else {
					filters.show();
				}
				break;
			}

			$(settings.label).text(settings.displays[layoutId] + ':');
		}

		showLayoutComponents(type, layout.id);

		if ($.isArray(settings.layouts) && settings.layouts.length > 0) {
			var selector = $('<select>', { name : 'layoutId' });
			this.append(selector);

			for (var i = 0; i < settings.layouts.length; ++i) {
				selector.append($('<option>', { value : settings.layouts[i].id, selected : (settings.layouts[i].id == layout.id) }).text(settings.layouts[i].name));
			}

			selector.change(function() {
				showLayoutComponents(type, parseInt(this.value));
			});
		} else {
			this.append($('<input>', { type: 'hidden', name : 'layoutId', value : layout.id }));
			this.append($('<label>').text(layout.name));
		}

		return this;
	};

	$.fn.trackerViewLayoutSelector.defaults = {
		layouts  : [],
		displays : [],
		label	 : '#displayLabel',
		fields	 : '#viewDisplay',
		orderBy  : '#viewSorting',
		filters  : '#viewFiltering'
	};

	// A complementary plugin to trackerViewLayoutSelector to get the selected view layout
	$.fn.getViewLayout = function() {
		var selector = $('select[name="layoutId"]', this);
		if (selector.length > 0) {
			var layout = $('option:selected', selector);

			return {
				id   : parseInt(selector.val()),
				name : layout.text()
			};
		}

		return {
			id   : parseInt($('input[name="layoutId"]', this).val()),
			name : $('label', this).text()
		};
	};


	// A third plugin to create a new/edit an existing tracker filter
	$.fn.trackerViewConfiguration = function(view, options) {
		var settings = $.extend( {}, $.fn.trackerViewConfiguration.defaults, view.viewConfiguration, options );

		function init(container, view) {
			if (!(typeof(view) == 'object')) {
				view = { id : null, type : 0, name : '', "public" : settings.forcePublic, "publicRights" : settings.publicRights, fields : [], orderBy : [], filters : [] };
			}

			container.append($('<input>', { type : 'hidden', name : 'id',   value : view.id   }));
			container.append($('<input>', { type : 'hidden', name : 'type', value : view.type }));

			container.helpLink(settings.help);
			container.objectInfoBox(view, settings);

			var table = $('<table>', { "class" : 'formTableWithSpacing', style : 'width: 100%;' });
			container.append(table);

			// View name plus public
			var viewName = $('<tr>');
			var label    = $('<td>', { "class" : 'mandatory', style : 'width: 5%;' }).text(settings.nameLabel + ":");
			var value    = $('<td>');

			value.append($('<input>', { type : 'text', name : 'name', value : view.name, size : 40, maxlength : 80, disabled : !settings.editable }));

			if (settings.publicRights) {
				var visibility = $('<label>', { title : settings.publicTooltip, style : 'margin-left: 1em; vertical-align: middle;' });
				visibility.append($('<input>', { type : 'checkbox', name : 'public', value : 'true', checked : view['public'] || settings.forcePublic, disabled: !settings.publicRights || settings.forcePublic }));
				visibility.append(' ' + settings.publicLabel);
				value.append(visibility);
			}
			else {
				value.append($('<span />')
						.addClass("helpLinkButton withContextHelp")
						.attr('style', 'margin-left: 10px;')
						.attr('title', 'tracker.public.view.permission.denied'));
			}

			var creationTypeInput   = $('<input>', { type : 'hidden', name : 'creationType', value : settings.creationType});
			value.append(creationTypeInput);

			viewName.append(label);
			viewName.append(value);
			table.append(viewName);

			var descrRow = $("tr.description-row");
			if (descrRow.length == 0) {
				descrRow        = $('<tr>',		  { title : settings.descriptionTooltip });
				var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional', style : 'width: 5%;' }).text(settings.descriptionLabel + ':');
				var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea' });
				var description = $('<textarea>', { name : 'description', rows : 2, cols : 80, disabled : !settings.editable }).val(view.description);

				descrCell.append(description);
				descrRow.append(descrLabel);
				descrRow.append(descrCell);
			}

			table.append(descrRow);

			// View layout
			var viewType    = $('<tr>', { title : settings.layoutTooltip, style : 'vertical-align: middle;' });
			var layoutLabel = $('<td>', { "class" : 'optional', style : 'width: 5%;' }).text(settings.layoutLabel + ":");
			var viewLayout  = $('<td>', { "class" : 'layout' });

			viewType.append(layoutLabel).append(viewLayout);
			table.append(viewType);

			// View fields/columns display
			var viewDisplay  = $('<tr>', { style : 'padding-top: 4px; padding-bottom: 4px' });
			var displayLabel = $('<td>', { "class" : 'optional', style : 'vertical-align: top; padding-top: 8px; width: 5%;' }).text(settings.displayLabel + ":");
			var viewFields   = $('<td>', { "class" : 'fields',   style : 'vertical-align: middle; white-space: nowrap;' });

			viewDisplay.append(displayLabel).append(viewFields);
			table.append(viewDisplay);

			// View sorting
			var viewSorting  = $('<tr>', { style : 'padding-top: 4px; padding-bottom: 4px' });
			var sortingLabel = $('<td>', { "class" : 'optional empty', style : 'vertical-align: top; width: 5%;' }).text(settings.sortingLabel + ":");
			var viewOrderBy  = $('<td>', { "class" : 'orderBy',        style : 'vertical-align: middle; white-space: nowrap;' });

			viewSorting.append(sortingLabel).append(viewOrderBy);
			table.append(viewSorting);

			// View filters
			var viewFiltering  = $('<tr>');
			var filteringLabel = $('<td>', { "class" : 'optional empty', style : 'vertical-align: top; width: 5%;', title : settings.filteringTooltip }).text(settings.filteringLabel + ":");
			var viewFilters    = $('<td>', { "class" : 'filters' });

			viewFiltering.append(filteringLabel).append(viewFilters);
			table.append(viewFiltering);

			var viewComponents = {
				name     	: viewName,
				visibility	: visibility,
				description : descrRow,
				label	 	: displayLabel,
				layout	 	: viewType,
				fields	 	: viewDisplay,
				orderBy  	: viewSorting,
				filters  	: viewFiltering
			};

			viewLayout.trackerViewLayoutSelector(view.type, view.layout, $.extend(settings.layoutConfiguration, viewComponents));

			viewFields.viewLayoutConfiguration(view.fields, $.extend(settings.displayConfiguration, {
				labelColumn : displayLabel
			}));

			viewOrderBy.viewOrderByConfiguration(view.orderBy, $.extend(settings.orderByConfiguration, {
				labelColumn : sortingLabel
			}));

			viewFilters.trackerFilterConfiguration(view.type, view.filters, $.extend(settings.filterConfiguration, {
				labelColumn	: filteringLabel
			}));

			if ($.isArray(settings.hide)) {
				for (var i = 0; i < settings.hide.length; ++i) {
					if (viewComponents.hasOwnProperty(settings.hide[i])) {
						viewComponents[settings.hide[i]].hide();
					}
				}
			}
		}

		return this.each(function() {
			init($(this), view);
		});
	};

	$.fn.trackerViewConfiguration.defaults = {
		viewUrl				: null,
		editable			: true,
		forcePublic			: false,
		publicRights		: false,
		nameLabel			: 'Name',
		descriptionLabel	: 'Description',
		descriptionTooltip	: 'An optional description of this view/filter',
		infoLabel			: 'Administrative information',
		infoTitle			: 'Additional/administrative information about this view/filter',
		idLabel				: 'Id',
		versionLabel		: 'Version',
		createdByLabel		: 'Created by',
		lastModifiedLabel	: 'Last modified by',
		commentLabel		: 'Comment',
		publicLabel         : 'Public',
		publicTooltip		: 'Make this view public; usable by everybody',
		layoutLabel			: 'Layout',
		layoutTooltip		: '',
		displayLabel		: 'Display',
		sortingLabel		: 'Sorting',
		filteringLabel		: 'Filtering',
		help				: {
			title			: 'Tracker Views in CodeBeamer Knowledge Base',
			URL				: 'https://codebeamer.com/cb/wiki/815542'
		},
		layoutConfiguration : {},
		displayConfiguration: {},
		orderByConfiguration: {},
		filterConfiguration : {}
	};


	// A complementary plugin for the tracker view editor, to read the view configuration back
	$.fn.getTrackerView = function() {
		return {
			id      		: parseInt($('input[name="id"]',   this).val()),
			type    		: parseInt($('input[name="type"]', this).val()),
			name    		: $('input[name="name"]',   this).val(),
			description 	: $('textarea[name="description"]', this).val(),
		   "public" 		: $('input[name="public"]', this).is(':checked'),
		    layout  		: $('td.layout',  this).getViewLayout(),
		    fields  		: $('td.fields',  this).getViewFields(),
		    orderBy 		: $('td.orderBy', this).getViewOrderBy(),
		    filters 		: $('td.filters', this).getTrackerFilters(),
		    creationType  	: $('input[name="creationType"]',   this).val()
		};
	};


	// A fourth plugin to create a new/edit an existing tracker filter (view but only the filters are relevant) in a dialog
	$.fn.showTrackerViewConfigurationDialog = function(view, config, dialog, callback) {
		var popup    = this;
		var settings = $.extend( {}, $.fn.showTrackerViewConfigurationDialog.defaults, dialog );

		$.getJSON(settings.viewUrl, view).done(function(configuration) {
			settings.viewUrl = configuration.viewConfiguration.viewUrl;
			popup.trackerViewConfiguration(configuration, config);
    	}).fail(function(jqXHR, textStatus, errorThrown) {
    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
        });

		if (settings.editable && typeof(callback) == 'function') {
			settings.buttons = [{
				text  : settings.submitText,
				click : function() {
					var edited = popup.getTrackerView();
					var valid  = true;

					if ($.isFunction(settings.validator)) {
						try {
							valid = (settings.validator(edited, getFilterStats(edited.filters)) != false);
						} catch(ex) {
							valid = false;
							alert(ex);
						}
					}

					if (valid) {
						$.ajax(settings.viewUrl, {type: 'POST', data : JSON.stringify(edited), contentType : 'application/json', dataType : 'json' }).done(function(result) {
						 	callback(result);
							popup.dialog("close");
							popup.remove();
						}).fail(function(jqXHR, textStatus, errorThrown) {
							try {
								var exception = eval('(' + jqXHR.responseText + ')');
								alert(exception.message);
							} catch(err) {
								alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
							}
					    });
					}
				}
			}, {
				text   : settings.cancelText,
			   "class" : "cancelButton",
				click  : function() {
		  			popup.dialog("close");
		  			popup.remove();
				}
			}];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.showTrackerViewConfigurationDialog.defaults = {
		editable		: true,
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true,
		viewUrl			: null,
		submitText		: 'OK',
		cancelText		: 'Cancel',
		validator		: null // function(view, stats) {}
	};


})( jQuery );
