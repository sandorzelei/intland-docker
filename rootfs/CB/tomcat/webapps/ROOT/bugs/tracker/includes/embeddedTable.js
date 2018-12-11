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

	var tableRowId = 0;

	// Plugin to show a form to edit the values of the specified fields
	$.fn.fieldEditorForm = function(fields, values, options) {
		var editorOptions = {
			height: 200,
			toolbarSticky: false
		};
		var additionalEditorOptions = {
		    uploadConversationId: $('input[name="uploadConversationId"]').val(),
		    insertNonImageAttachments: true,
		    hideOverlayEditor: true,
		    disableFormattingOptionsOpening: true
		};

		var settings = $.extend( {}, $.fn.fieldEditorForm.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function isValueSelected(value, selected) {
			if ($.isArray(selected)) {
				for (var i = 0; i < selected.length; ++i) {
					if (selected[i].value == value) {
						return true;
					}
				}
			}
			return false;
		}

		function getOptionsSelector(field, selected) {
			var selector = $('<select>', { name : 'value', multiple : field.multiple, disabled : !settings.editable });

			if (!(field.required || field.multiple)) {
				selector.append($('<option>', { value : '' }).text('--'));
			}

			if ($.isArray(field.options) && field.options.length > 0) {
				for (var i = 0; i < field.options.length; ++i) {
					selector.append($('<option>', { value : field.options[i].value, title : field.options[i].title, selected : isValueSelected(field.options[i].value, selected) }).text(field.options[i].label));
				}
			}

			return selector;
		}

		function makeMultiselect(form, field, editor) {
			if (editor.is('select[multiple="multiple"]')) {
				var changed = function(event, ui) {
					editor.data('changed', true);
				};

				var finished = function(event, ui) {
					if (editor.data('changed') && field.dependencies) {
						checkDependendOptions(form, field.dependencies);
					}
					editor.removeData('changed');
				};

				var multiselect = editor.multiselect({
		    		checkAllText	 : settings.checkAllText,
		    	 	uncheckAllText	 : settings.uncheckAllText,
		    	 	noneSelectedText : '--',
		    	 	autoOpen		 : false,
		    	 	multiple         : true,
		    	 	selectedList	 : 99,
		    	 	minWidth		 : 640, //'auto'
		    	 	click			 : changed,
		    	 	checkAll		 : changed,
		    	 	uncheckAll		 : changed,
		    	 	optgrouptoggle   : changed,
		    	 	close			 : finished
// This would fix the problem, that the filter is not editable, but breaks the popup positioning. Let's wait for a bugfix in multiselect widget
//		    	 	appendTo		 : editor.parent()
		    	});

				if ($('option', editor).length > 25) {
					multiselect.multiselectfilter({
						label		: settings.filterText + ':',
						placeholder : field.name
					});
				}

			} else if (field.dependencies) {
				editor.change(function() {
					checkDependendOptions(form, field.dependencies);
				});
			}
		}

		function getFieldEditor(field, value) {
			var editor = null;

			if (field.type == 0) { // text
				var width  = parseInt(field.width);
				if ($.isPlainObject(value)) {
					value = value.value;
				}
				editor = $('<input>', { type : 'text', name : 'value', size : width, value : value, disabled : !settings.editable});
			} else if (field.type == 10) { // wikitext
				var width  = parseInt(field.width);
				var height = parseInt(field.height);

				// wikitext value is an object { value : markup, html : rendered}
				if ($.isPlainObject(value)) {
					value = value.value;
				}

				editor = $('<textarea>', {
					id: 'wikitext-table-field-' + field.id,
					'class': 'wiki-editor',
					name : 'value',
					rows : height || 6,
					cols : width || 60,
					disabled : !settings.editable
				});

				if (value != null && value.length > 0) {
					editor.val(value);
				}
			} else if (field.type == 1 || field.type == 2) { //integer/float
				var width = parseInt(field.width);
				if (!(width && !isNaN(width))) {
					width = (field.type == 1 ? 10 : 15);
				}
				editor = $('<input>', { type : 'text', name : 'value', size : width,  maxlength : (field.maxValue ? field.maxValue.length : 20), value : value, disabled : !settings.editable});

				if (!isNaN(parseFloat(field.minValue))) {
					editor.attr('min', field.minValue);
				}
				if (!isNaN(parseFloat(field.maxValue))) {
					editor.attr('max', field.maxValue);
				}
			} else if (field.type == 3) { // date
				var uniqueId = Math.round(new Date().getTime() + (Math.random() * 100));
				editor = $('<input>', { id: "tableDateField_" + uniqueId, type : 'text', name : 'value', style: "width: 50%", disabled : !settings.editable });
				editor.val(value);
			} else if (field.type == 11) { // duration
				editor = $('<input>', { type : 'text', name : 'value', size : 20, maxlength : 20, value : value});

			} else if (field.type == 4) { // boolean
				if (field.required) {
					var checked = value && value.length > 0 && value[0].value === "true";
					editor = $('<input>', { type: 'checkbox', name : 'value', title : field.description, checked : checked });
				} else {
					editor = getOptionsSelector(field, value);
				}
			} else if (field.type == 8) { // language
				editor = getOptionsSelector(field, value);

			} else if (field.type == 9) { // country
				editor = getOptionsSelector(field, value);

			} else if (field.type == 5) { // member/principal
			} else if (field.type == 6 || // custom choice
					   field.type == 7) { // reference
				var refType = parseInt(field.refType);
				if (isNaN(refType) || refType == 0) {  // fix choice
					editor = getOptionsSelector(field, value);
				}
			} else if (field.type == 13) {
				if (value == null) {
					value = "";
				}
				editor = $('<input id="' + field.id + '" name="value" style="width: 6em;" readonly="readonly" type="text" value="' + value + '"><a class="colorPicker yui-skin-sam" id="' + field.id + '-colorPicker-icon" onclick="colorPicker.showPalette(this, ' + field.id + ', true); return false;"> <img src="' + contextPath + '/images/color_swatch.png" /></a>');
			}

			return editor;
		}

		function getCSVString(value) {
			var result = '';

			if ($.isArray(value)) {
				var values = [];
				for (var v = 0; v < value.length; ++v) {
					values.push(value[v].value);
				}
				result = values.join(',');
			} else if ($.isPlainObject(value)) {
				result = value.value;
			} else if (value) {
				result = value.toString();
			}

			return result;
		}

		function getContext(form, dependsOn) {
			var context = [];

			if ($.isArray(dependsOn) && dependsOn.length > 0) {
				for (var i = 0; i < dependsOn.length; ++i) {
					if (dependsOn[i].column) {
						var value = form.fieldEditorFormField(dependsOn[i].column).getFieldEditorFormFieldValue();

						context.push(dependsOn[i].column.toString() + '=' + getCSVString(value));
					} else {
						context.push(dependsOn[i].field.toString() + '=' + $('#dynamicChoice_references_' + dependsOn[i].field).val());
					}
				}
			}

			return context.join(';');
		}

		function checkContext(form, formField) {
			var field = formField.data('field');
			if (field.dependsOn) {
				var content    = $('td.dataCell', formField);
				var references = content.data('references');
				var selected   = formField.getFieldEditorFormFieldValue();

				$.ajax((references ? settings.checkValuesUrl : settings.choiceOptionsUrl), {
					type	: 'GET',
					data 	: { field_id : field.id,
						        context  : getContext(form, field.dependsOn),
						        values   : getCSVString(selected)
						      },
					dataType: 'json'
				}).done(function(result) {
					if ($.isArray(result)) {
						if (references) {
							// data is an array of values that should be removed !!
							try {
								var boxes = $('input[type="hidden"][name="value"]', content);
								if (boxes.length > 0) {
									//ajaxReferenceFieldAutoComplete.removeValueBoxes(boxes.get(0), result);
								}
							} catch(e) {
								alert(e);
							}
						} else {
							var editor = $('select[name="value"]', content);
							if (editor.length > 0) {
								editor.empty();

								if (!(field.required || field.multiple)) {
									editor.append($('<option>', { value : '' }).text('--'));
								}

								for (var i = 0; i < result.length; ++i) {
									editor.append($('<option>', { value : result[i].value, title : result[i].title, selected : isValueSelected(result[i].value, selected) }).text(result[i].label));
								}

								if (editor.is('select[multiple="multiple"]')) {
									editor.multiselect('refresh');
								}
							}
						}
					}
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

		function checkDependendOptions(form, dependencies) {
			if ($.isArray(dependencies) && dependencies.length > 0) {
				for (var i = 0; i < dependencies.length; ++i) {
					checkContext(form, form.fieldEditorFormField(dependencies[i]));
				}
			}
		}

		function init(form, fields, values) {
			if (!$.isArray(fields)) {
				fields = [];
			}

			if (!$.isArray(values)) {
				values = [];
			}

			if (fields.length > 0) {
				var dependendSelects = [];

				var table = $('<table>', { "class" : 'fieldEditorForm formTableWithSpacing' }).data('fields', fields);
				form.append(table);

				for (var i = 0; i < fields.length; ++i) {
					var field = $.extend({}, fields[i], {
						htmlId   :  null,
						htmlName : 'value',
						showUnset: !fields[i].required
					});

					var value = values.length > i ? values[i] : null;

					var line = $('<tr>', { "class" : 'fieldEditorFormField'} ).data('field', field).data('content', value);
					table.append(line);

					var label = $('<td>', { "class" : 'labelCell' + (field.required ? ' mandatory' : ' optional'), title : field.description }).text(field.name + ':');
					line.append(label);

					var content = $('<td>', { "class" : 'dataCell', "id" : "table-field-" + field.id });
					line.append(content);

					if (field.editable) {
						var editor = getFieldEditor(field, value);
						if (editor != null) {
							content.append(editor);

							if (field.type == 3) {
								jQueryDatepickerHelper.initCalendar(editor.attr("id"), "", field.name, true);
							}

							if (editor.is('select')) {
								makeMultiselect(table, field, editor);

								if (field.dependsOn) {
									dependendSelects.push(line);
								}
							}

							if (editor.hasClass('wiki-editor')) {
								var editorId = editor.attr('id');
								editor.wrap('<div class="editor-wrapper"></div>');
								codebeamer.WikiConversion.bindEditorToEntity(editorId, '[ISSUE:' + fields[0].taskId + ']');
								codebeamer.WYSIWYG.initEditor(editorId, editorOptions, additionalEditorOptions, true);
							}
						} else {
							content.data('references', true);

							if (field.dependsOn) {
								field.context = function() {
									return getContext(table, field.dependsOn);
								};
							}

							if (field.dependencies) {
								field.callback = function() {
									checkDependendOptions(table, field.dependencies);
								};
							}

							if (field.type == 5) {
								field = $.extend( {}, field, { htmlId: field.id + "_" + tableRowId.toString() });
								content.membersField(value, field);
								tableRowId++;
							} else {
								field = $.extend( {}, field, { htmlId: field.id + "_" + tableRowId.toString() });
								content.referenceField(value, field);
								tableRowId++;
							}
						}
					} else {
		    			if ($.isArray(value)) {
		    				for (var v = 0; v < value.length; ++v) {
		    					if (v > 0) {
		    						content.append(', ');
		    					}
		    					content.append($('<label>', { title : value[v].tooltip }).text(value[v].label));
		    				}
		    			} else if (value) {
		    				// Wikitext is an object { value : markup, html : rendered}
		    				if (field.type == 10 && $.isPlainObject(value)) {
		    					content.html(value.html);
		    				} else {
			    				content.text(value);
		    				}
		    			} else {
		    				content.text(settings.emptyText);
		    			}
					}
				}

				// Second pass to setup context dependent choice lists
				for (var i = 0; i < dependendSelects.length; ++i) {
					checkContext(table, dependendSelects[i]);
				}
			}
		}

		return this.each(function() {
			init($(this), fields, values);
		});
	};

	$.fn.fieldEditorForm.dateFieldIndex = 0;

	$.fn.fieldEditorForm.defaults = {
		editable			: true,
		emptyText			: '--',
		anyText  			: 'Any',
		noneText  			: 'None',
		filterText			: 'Filter',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all',
		submitText			: 'OK',
		cancelText			: 'Cancel',
		choiceOptionsUrl	: null,
		checkValuesUrl      : null
	};


	// Find an editor form field by id
	$.fn.fieldEditorFormField = function(fieldId) {
		var result = null;

		$('tr.fieldEditorFormField', this).each(function(index, formField) {
			var field = $(formField).data('field');
			if (field.id == fieldId) {
				result = $(formField);
				return false;
			}
			return true;
		});

		return result;
	};

	// Get the current value of an editor form field
	$.fn.getFieldEditorFormFieldValue =	function() {
		var field = this.data('field');
		var value = this.data('content');

		if (field.editable) {
			var content = $('td.dataCell', this);
			if (content.data('references')) {
				value = content.getReferences();
			} else {
				var editor = $('[name="value"]', content);
				if (editor.length > 0) {
					if (editor.is('select[multiple="multiple"]')) {
						value = [];

						var selected = editor.multiselect('getChecked');
						if (selected) {
							for (var i = 0; i < selected.length; ++i) {
								var option = $(selected[i]);
								value.push({
									value   : option.val(),
									label   : option.text(),
									tooltip : option.attr('title')
								});
							}
						}

						if (value.length == 0) {
							value = null;
						}
					} else if (editor.is('select')) {
						var option = $('option:selected', editor);
						if (option.length == 1 && option.val() && option.val().length > 0) {
							value = [{
								value   : option.val(),
								label   : option.text(),
								tooltip : option.attr('title')
							}];
						} else {
							value = null;
						}
					} else if (field.type === 4) { // boolean, checkbox
						var option = field.options[editor.is(':checked') ? 0 : 1];
						if (option) {
							value = [{
								value   : option.value,
								label   : option.label,
								tooltip : option.title
							}];
						} else {
							value = null;
						}
					} else {
						if (field.type == 10 && codebeamer.WYSIWYG.getEditorMode(editor) == 'wysiwyg') {
							codebeamer.WikiConversion.saveEditor(editor.attr('id'), true);
						}

						value = editor.val();

						if (value && (value = value.trim()).length > 0) {
							if (field.type == 1) { // integer
								value = parseInt(value);
								if (isNaN(value)) {
									value = null;
								}
							} else if (field.type == 2) { // float
								value = parseFloat(value);
								if (isNaN(value)) {
									value = null;
								}
							} else if (field.type == 4) { // boolean
								value = (value === 'true');
							}
						} else {
							value = null;
						}
					}
				}
			}
		}
		return value;
	};


	// Retrieve the edited field values from a fieldEditorForm
	$.fn.getEditedFieldValues = function() {

		var form  = $('table.fieldEditorForm', this);
		var values = [];

		$('tr.fieldEditorFormField', form).each(function(index, formField) {
			// remove validation data if exists
			$(formField).find(".invalidfield").remove();
			values.push($(formField).getFieldEditorFormFieldValue());
		});

		return values;
	};


	// A plugin to create a new/edit an table row  in a popup dialog
	$.fn.showFieldEditorDialog = function(fields, values, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showFieldEditorDialog.defaults, dialog );
		var popup    = this;

		popup.fieldEditorForm(fields, values, config);

		if (typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
						 	var result = callback(popup.getEditedFieldValues());
						 	if (!(result == false)) {
					  			popup.dialog("close");
					  			popup.remove();
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

		try {
			$.each(fields, function() {
				if (this.type == 10) { // fields contain wikitext field
					settings.height = $(window).height() * 0.8;
					settings.width = '80%';
					settings.draggable = false;
					return false;
				}
			});
			popup.dialog(settings);
		} finally {
			var busyDialog = ajaxBusyIndicator.showBusyPage();
			setTimeout(function() {
				popup.referenceFieldAutoComplete();
				ajaxBusyIndicator.close(busyDialog);
			}, 400);
		}
	};

	$.fn.showFieldEditorDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		height	 		: 500,
		draggable		: true,
		open			: function() {
			$(this).scrollTop(0);
		}
	};

	// Plugin renders and optionally allows editing an embedded table.
	$.fn.embeddedTable = function(rows, options) {
		var settings = $.extend( {}, $.fn.embeddedTable.defaults, options );

		var versionAbbr = i18n.message("reference.setting.version.abbr");
		var reverseSuspectImg = '<span class="reverseSuspectImg" />';
		var reverseSuspectLabel = i18n.message("reference.setting.reverse.suspect");
		var versionLabel = i18n.message("reference.setting.version");
		var propagateSuspectsLabel = i18n.message("association.propagatingSuspects.label");
		var suspectedLabel = i18n.message("tracker.view.layout.document.reference.suspected");

		function getSetting(name) {
			return settings[name];
		}

		function update(body) {
			var table = body.closest('table.embeddedFieldTable');
			var rows  = [];

			$('tr.embeddedTableRow', body).each(function(index, row) {
				if (settings.showRowNumber) {
					$('td.embeddedTableCell:first', row).text(index + 1);
				}

				rows.push($(row).data('content'));
			});

			var tableField = table.prev('input[name="' + settings.table + '"][type="hidden"]');
			if (tableField.length == 0) {
				tableField = $('<input>', { type : 'hidden', name : settings.table, value : JSON.stringify(rows) });
				tableField.insertBefore(table);
			} else {
				tableField.val(JSON.stringify(rows));
			}
		}

		function setCell(cell, column, value) {
			if ($.isArray(value)) {
				cell.empty();

				for (var v = 0; v < value.length; ++v) {
					if (v > 0) {
						cell.append(', ');
					}
					cell.append($('<label>', { title : value[v].tooltip }).html(value[v].label));
					if (column.refType == 9) {
						var version = value[v].version,
							propagateSuspects = value[v].propagateSuspects == "true",
							suspected = value[v].suspected == "true",
							reverseSuspect = value[v].reverseSuspect == "true",
							bidirectionalSuspect = value[v].bidirectionalSuspect == 'true',
							isOutgoingSuspected = value[v].isOutgoingSuspected == 'true',
							isIncomingSuspected = value[v].isIncomingSuspected == 'true';
						
						if (propagateSuspects) {
							var htmlForBidirectional = '';
							if (bidirectionalSuspect) {
								htmlForBidirectional = '<span class="arrow arrow-up' + (isOutgoingSuspected ? ' active' : '') + '"></span>' + 
													   '<span class="arrow arrow-down' + (isIncomingSuspected ? ' active' : '') + '"></span>';
							}							
							cell.append($("<span class='referenceSettingBadge psSettingBadge" + (suspected ? " active" : "")  +
								"' title='" + propagateSuspectsLabel + (reverseSuspect ? " (" + reverseSuspectLabel + ")" : "") + "'>" +
								suspectedLabel + (reverseSuspect ? reverseSuspectImg : "") + "</span>" + htmlForBidirectional));
						}
						if (version != 0 && version != "null") {
							cell.append($("<span class='referenceSettingBadge versionSettingBadge' title='" + versionLabel + "'>" + versionAbbr + " " + version + "</span>"));
						}
					}
				}
			} else if (value) {
				// (Wiki)Text is an object { value : markup, html : rendered}
				if ((column.type == 0 || column.type == 10) && $.isPlainObject(value)) {
					cell.html(value.html);
				} else {
					cell.html(value);
				}
			} else {
				cell.text(settings.emptyText);
			}
		}

		function addRow(body, values, position) {
			var row = $('<tr>', { "class" : 'embeddedTableRow even' }).data('content', values);

			if (position) {
				row.insertBefore(position);
			} else {
				body.append(row);
			}

			if (settings.showRowNumber) {
				row.append($('<td>', { "class" : 'numberData embeddedTableCell columnSeparator', style : 'width: 2%;' }).text(row.index() + 1));
			}

    		for (var i = 0; i < settings.columns.length; ++i) {
    			var column = settings.columns[i];
    			var value  = (values && values.length > i ? values[i] : null);
    			var clazz  = column.styleClass + ' embeddedTableCell';

    			if (i < settings.columns.length - 1) {
    				clazz += ' columnSeparator';
    			}

    			var cell = $('<td>', { "class" : clazz }).data('column', column);
    			row.append(cell);

    			setCell(cell, column, value);
    		}

    		if (settings.editable) {
    			row.click(function(event) {
    				return $(event.target).hasClass('menuArrowDown');
    			});

        		row.dblclick(function(event) {
        			event.stopPropagation();

    				editRow(body, row, function(newValues) {
    				   return insUpdRow(body, row, newValues, null);
    				});
        		});

    		}

    		if (settings.editable) {
        		appendMenuBox(row.find("td:last"));
    		}
    		return row;
		}

		function appendMenuBox(toWhat) {
			var menuBox = $('<span>', { 'class': "yuimenubaritemlabel yuimenubaritemlabel-hassubmenu"}),
				menuCssClasses = 'menuArrowDown' + (codebeamer.userPreferences.alwaysDisplayContextMenuIcons ? ' always-display-context-menu' : ''),
				menuArrow = $('<img>', { 'src': contextPath + "/images/space.gif", 'class': menuCssClasses });
			
			menuBox.append(menuArrow);
			toWhat.append(menuBox);
		}

		function updateRow(row, values) {
			row.data('content', values);

			$('td.embeddedTableCell', row).each(function(index, cell) {
				if (settings.showRowNumber) {
					if (index == 0) {
						// This is the pseudo row number
						return true;
					} else {
						--index;
					}
				}

				cell = $(cell);
				setCell(cell, cell.data('column'), values && values.length > index ? values[index] : null);
			});
			if (settings.editable) {
				appendMenuBox(row.find("td:last"));
			}
		}

		function insUpdRow(body, row, values, position) {
			var conflict = false;

			var trackerItemColumn = false;
    		for (var i = 0; i < settings.columns.length; ++i) {
    			var column = settings.columns[i];
				if (column.refType == 9) {
					trackerItemColumn = true;
				}
    			var value  = (values && values.length > i ? values[i] : null);

    			if (!value && column.required) {
    				// add validation message before the field
					var validationMessage = $('<span>', {
					   "class" : 'invalidfield',
					   "text" : i18n.message("tracker.table.row.mandatory.column.missing.message",
					         column.name)
					});
					var newLine = $('<br>');
					validationMessage.append(newLine);
					$("#table-field-" + column.id).prepend(validationMessage);

					conflict = true;
    			}
    		}

    		// Todo verify values at server (incl. rendering wiki markup)
    		if (!trackerItemColumn && settings.rowValidationURL && !conflict) {
    			var params = {
    				fields : $.map(settings.columns, function(column, index) { return column.id; }),
    				values : values
    			};

    			var url = settings.rowValidationURL,
    				conversationId = $('input[name="uploadConversationId"]').val();

				if (conversationId && conversationId.length) {
					var appendChar = settings.rowValidationURL.indexOf('?') > -1 ? '&' : '?';

					url += appendChar + 'conversationId=' + conversationId;
				}

				$.ajax(url, {
					type		: 'POST',
					async		: false,
					data 		: JSON.stringify(params),
					contentType : 'application/json',
					dataType 	: 'json'
				}).done(function(result) {
		    		values = result;

		    		body.trigger("codebeamer.tableFieldUpdated");
				}).fail(function(jqXHR, textStatus, errorThrown) {
		    		conflict = true;

		    		try {
			    		var exception = eval('(' + jqXHR.responseText + ')');
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        });
    		}

			if (conflict) {
				return false;
			}

			if (row == null) {
				row = addRow(body, values, position);
			} else {
				updateRow(row, values);
			}

			var busyDialog = ajaxBusyIndicator.showBusyPage();
			setTimeout(function() {
				update(body);
				ajaxBusyIndicator.close(busyDialog);
			}, 400);

			return true;
		}

		function editRow(body, row, callback) {
			var values = (row ? row.data('content') : []);

			var popup = $('#embeddedTableRowEditor');
  			if (popup.length == 0) {
  				popup = $('<div>', { id : 'embeddedTableRowEditor', "class" : 'editorPopup', style : 'display: None;'} );

  				body.closest('table.embeddedFieldTable').parent().append(popup);
 			} else {
  				popup.empty();
  			}

			// if we are adding or inserting a row, set default values for inputs
			if (!row) {
				for (var i = 0; i < settings.columns.length; ++i) {
					values[i] = settings.columns[i].defaultValue;
				}
			}

  			var anchor = (row ? row : body.closest('table.embeddedFieldTable').parent());

  			popup.showFieldEditorDialog(settings.columns, values, settings.fieldEditor, {
				title			: settings.name + ': ' + (row ? (row.index() + 1) + '. ' + settings.editRowLabel : settings.addRowLabel),
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false

  			}, callback);
		}


		function setupMenus(tableId) {
			if (settings.mutableRows) {
		    	/** Add a context menu to embedded table rows */
                var embeddTableRowMenu = new ContextMenuManager({
                    selector: "#" + tableId + " tbody.embeddedTable > tr.embeddedTableRow .yuimenubaritemlabel",
                    trigger: "left",
                    items: {	editRow : {
                        name    : settings.editRowLabel,
                        disabled: !settings.editable,
                        callback: function(key, options) {
                            var row  = options.$trigger.closest("tr");
                            var list = row.closest('tbody.embeddedTable');

                            editRow(list, row, function(values) {
                                return insUpdRow(list, row, values, null);
                            });
                        }
                    },
                        insertRow : {
                            name    : settings.insertRowLabel,
                            callback: function(key, options) {
                                var row  = options.$trigger.closest("tr");
                                var list = row.closest('tbody.embeddedTable');

                                editRow(list, null, function(values) {
                                    return insUpdRow(list, null, values, row);
                                });
                            }
                        },
                        addRow : {
                            name    : settings.addRowLabel,
                            callback: function(key, options) {
                                var list = options.$trigger.closest('tbody.embeddedTable');

                                editRow(list, null, function(values) {
                                    return insUpdRow(list, null, values, null);
                                });
                            }
                        },
                        removeRow: {
                            name    : settings.removeRowLabel,
                            callback: function(key, options) {
                                if (confirm(getSetting('removeRowConfirm'))) {
                                    var row  = options.$trigger.closest("tr");
                                    var list = row.closest('tbody.embeddedTable');

                                    row.remove();
                                    update(list);

                                    if ($('tr.embeddedTableRow', list).length == 0) {
                                        var table = list.closest('table.embeddedFieldTable');
                                        table.hide();
                                        table.next('label.emptyEmbeddedTable').show();
                                    }
                                }
                            }
                        }
                    },
                    zIndex  : 20
                });
		        embeddTableRowMenu.render();

		    	/** Add a context menu to empty embedded table rows */
                var emptyEmbeddTableRowMenu = new ContextMenuManager({
                    selector: "#empty-" + tableId + ".emptyEmbeddedTable .yuimenubaritemlabel",
                    trigger: "left",
                    items: {	addRow : {
                        name    : settings.addRowLabel,
                        callback: function(key, options) {
                            var table = options.$trigger.closest("label").prev('table.embeddedFieldTable');
                            var list  = $('tbody.embeddedTable', table);

                            editRow(list, null, function(values) {
                                var success = insUpdRow(list, null, values, null);
                                if (success) {
                                    options.$trigger.hide();
                                    table.show();
                                }
                                return success;
                            });
                        }
                    }
                    },
                    zIndex  : 20
                });
		        emptyEmbeddTableRowMenu.render();

			}
		}

		function init(container, rows) {
			if (!$.isArray(rows)) {
				rows = [];
			}

			if (rows.length > 0 || settings.mutableRows) {
				var table = $('<table>', { "class" : 'embeddedFieldTable', width : '100%' });
				container.append(table);
				table.uniqueId();

				if (rows.length == 0) {
					table.hide();
				}

				if (settings.header) {
					var header = $('<thead>');
					table.append(header);

					var headline = $('<tr>', { "class" : 'embeddedTableHeader head' });
					header.append(headline);

					if (settings.showRowNumber) {
						headline.append($('<th>', { "class" : 'numberData embeddedTableHeader columnSeparator', style : 'width: 2%;' }).text(settings.rowNumberLabel));
					}

		    		for (var i = 0; i < settings.columns.length; ++i) {
		    			var column = settings.columns[i];
		    			var clazz  = column.headerClass + ' embeddedTableHeader';

		    			if (i < settings.columns.length - 1) {
		    				clazz += ' columnSeparator';
		    			}

						headline.append($('<th>', { "class" : clazz, title : column.description }).text(column.title ? column.title : column.name));
		    		}
				}

				var body = $('<tbody>', { "class" : 'embeddedTable' });
				table.append(body);

	    		for (var i = 0; i < rows.length; ++i) {
	    			addRow(body, rows[i]);
	    		}

				if (settings.mutableRows) {
					/** Make the rows sortable */
				    body.sortable({
				    	items   : "> tr.embeddedTableRow",
				    	axis    : "y",
				    	cursor  : "move",
				    	delay   : 150,
				    	distance: 5,
//				    	refreshPositions: true,
						update	: function(event, ui) {
									  update(body);
								  }
				    });
				}
			}

			var tableId = table.attr("id");
			var emptyHint = $('<label>', { "class" : 'emptyEmbeddedTable', "id": "empty-" + tableId }).text(settings.noneText);
			var addRowLink = $("<a>", {"class": "addRowLink", "title": settings.addRowLabel}).html(settings.addRowLabel);
			addRowLink.click(function () {
				var $this = $(this);
		    	var table = $this.closest("label").prev('table.embeddedFieldTable');
		    	var list  = $('tbody.embeddedTable', table);

	  			 editRow(list, null, function(values) {
	  				  var success = insUpdRow(list, null, values, null);
	  					  if (success) {
	  						 $this.closest("label").hide();
  			    			  table.show();
	  					  }
						  return success;
					  });
			});
			container.append(emptyHint);
			emptyHint.append(addRowLink);
			if (rows.length > 0) {
				emptyHint.hide();
			}

			setupMenus(tableId);
			update(body); // force update body (fixes bug that reloading an invalid form looses changes)
		}

		return this.each(function() {
			init($(this), rows);
		});
	};

	$.fn.embeddedTable.defaults = {
		table				: 'table[0]',
		name				: 'table',
		header				: true,
		columns				: [],
		editable			: false,
		mutableRows			: false,
		showRowNumber		: false,
		rowValidationURL	: null,
		rowNumberLabel		: 'No.',
		addRowLabel			: 'Add new row...',
		addRowTooltip		: 'Add a new row to this table',
		insertRowLabel		: 'Insert row here...',
		insertRowTooltip	: 'Insert a new row before the selected row',
		editRowLabel		: 'Edit the row...',
		editRowTooltip		: 'Edit the selected row',
		removeRowLabel		: 'Remove row...',
		removeRowTooltip	: 'Remove the selected row from the table',
		removeRowConfirm	: 'Do you really want to remove the selected row from the table?',
		emptyText			: '--',
		fieldEditor			: $.fn.fieldEditorForm.defaults
	};


})( jQuery );
