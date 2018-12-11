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

	// FieldValueCombinationsEditor Plugin definition.
	$.fn.fieldValueCombinationsEditor = function(fields, references, combinations, options) {
		var contextId = this.attr('id') || '';
		
		var settings = $.extend( {}, $.fn.fieldValueCombinationsEditor.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function makeCombiValMultiSelect(content, editor) {
			var multiselect = editor.multiselect({
	    		checkAllText	 : settings.checkAllText,
	    	 	uncheckAllText	 : settings.uncheckAllText,
	    	 	noneSelectedText : settings.noValueText,
	    	 	autoOpen		 : false,
	    	 	multiple         : true,
	    	 	selectedList	 : 99,
	    	 	minWidth		 : 300, //'auto'
	    	 	appendTo		 : contextId ? '#' + contextId : '' 
	    	}).bind('multiselectclose', function(event, ui) {
	    		var selector = $(this);
	    		var selected = selector.multiselect("widget").find(":checkbox:checked");
	    		var isAny    = false;

	    		selected.each(function() {
	    			if (this.value == '*') {
	    				isAny = true;
	    				return false;
	    			}
	    		});

	    		if (isAny) {
	        		selected.each(function() {
	        			if (this.value != '*') {
	 	        			this.click();
	        			}
	        		});
	    		}
			});

			if ($('option', editor).length > 25) {
				multiselect.multiselectfilter({
					label		: settings.filterText + ':',
					placeholder : i18n.message('multiselectfilter.text')
				});
			}
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

		function setCombiVal() {
			var container = $(this);
			return setReferences(container, container.getReferences(), '--');
		}

		function isSelected(selected, value) {
			if (typeof selected === 'string') {
				selected = selected.split(',');
			}

			if ($.isArray(selected)) {
				for (var i = 0; i < selected.length; ++i) {
					var selectedValue = selected[i];
					if ($.isPlainObject(selectedValue)) {
						selectedValue = selectedValue.value;
					}

					if (value === selectedValue) {
						return true;
					}
				}
				return false;

			} else if ($.isPlainObject(selected)) {
				selected = selected.value;
			}

			return value === selected;
		}

		function getRefSelector(field, references, selected) {
			var selector = $('<select>', { name : 'combiVal', multiple : true });

			if ($.isArray(references) && references.length > 0) {
				for (var i = 0; i < references.length; ++i) {
					selector.append($('<option>', { value : references[i].value, selected : (references.length == 1 || isSelected(selected, references[i].value)) }).html(references[i].title));
				}
			}

			return selector;
		}

		function setup() {
			/* Define an inplace editor for choice field values */
		    $.editable.addInputType('combinedFieldValues', {
		        element : function(settings, self) {
					var form   = $(this);
					var editor = $(self);
					var field  = editor.data('field');
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

		function createCombination(fields, refMap, combination) {
			var refValue = combination[fields.length - 2];

			if ($.isArray(refValue) && refValue.length > 0) {
				refValue = refValue[0];
			}

			if ($.isPlainObject(refValue)) {
				refValue = refValue.value;
			}

			var combi = $('<tr>', { "class" : 'combination even' });

			var reference = (refMap && refValue ? refMap[refValue] : null);
			if (reference) {
				delete refMap[reference.value];

				combi.addClass('reference');
				combi.data('reference', reference);
				combi.attr('title', i18n.message('tracker.field.combinations.dynamic.hint'));
			} else {
				combi.attr('title', settings.isCommentVisibility ? i18n.message('comment.visibility.restriction.hint') : i18n.message('tracker.field.combinations.static.hint'));
			}

			for (var j = 0; j < fields.length; ++j) {
				var special = [
	               { value: 'NULL', label: '--' },
	               { value: '*',    label: settings.anyValueText }
				];

				var field = $.extend({}, fields[j], {
					editable		: settings.editable,
					trackerId		: settings.trackerId,
					htmlName		: 'combiValRefs',
					multiple 		: true,
					showUnset		: true,
					emptyValue 		: 'NULL',
					emptyLabel 		: '--',
					defaultValue	: '*',
					defaultLabel	: settings.anyValueText,
					specialValues 	: special
				});

				var combiValColumn = $('<td>', { "class" : 'combiVal' });

				var combiValEditor = (reference ? (j == fields.length - 1 ? getRefSelector(field, reference.references, combination[j]) : null) : settings.combiValueEditor('combiVal', field, special, combination[j]));
				if (combiValEditor != null) {
					combiValColumn.append(combiValEditor);
					makeCombiValMultiSelect(fields[j], combiValEditor);
				} else {
					combiValEditor = $('<span>', { "class" : 'combiVal highlight-on-hover' });
					combiValColumn.append(combiValEditor);

					combiValEditor.data('field', field);
					combiValEditor.html(setReferences(combiValEditor, combination[j], '--'));

					if (reference) {

					} else if (settings.editable) {
						combiValEditor.editable(setCombiVal, {
					        type      : 'combinedFieldValues',
					        event     : 'click',
					        onblur    : 'cancel',
					        submit    : settings.submitText,
					        cancel    : settings.cancelText,
					        tooltip   : settings.editTooltip
					    });
					}
				}
				combi.append(combiValColumn);
			}

			if (settings.editable) {
				// add the remove button
				var buttonColumn = $('<td>', { "class" : 'buttons', 'style': 'width: 30px' });
				buttonColumn.append($('<span>', { title: settings.removeText, "class" : "removeButton"}));
				combi.append(buttonColumn);

				buttonColumn.on('click', '.removeButton', function () {
					var self = this;
					showFancyConfirmDialogWithCallbacks(settings.removeConfirm, function() {
		        	  var $row = $(self).closest('tr'),
	        	  		  $table = $row.closest('table.combinations');
		        	  
			          if ($row.hasClass('reference')) {
			  			var reference = $row.data('reference');
			  			var selector  = $('select.reference', $row.closest('table.combinations').parent());

			  			selector.append($('<option>', { "class" : 'reference', value : reference.value, title : reference.title }).html(reference.label).data("reference", reference));

			  			$row.remove();

			  			if ($('tr.reference', $row.parent()).length == 0) {
			  				$('option:first', selector).text(getSetting('referencesAdd'));
			  			}

			  			selector.show();
			          } else {
			              $row.remove();
			          }

			          if (!$table.find('tbody tr').length) {
			        	  $table.siblings('div.none-text').show();
			          }
					});
				});
			}
			
			if (reference && fields.length > 2) {
				combi.find('td').each(function(index, element) {
					if (index < fields.length - 2) {
						$(element).html('');
					}
				});
			}

			return combi;
		}

		function init(popup, fields, references, combinations) {
			if (!$.isArray(fields)) {
				fields = [];
			}

			var table  = $('<table>', { "class" : 'combinations displaytag' });
			var thead  = $('<thead>');
			var header = $('<tr>');

			for (var i = 0; i < fields.length; ++i) {
				header.append($('<th>', { style: 'text-align: left;' }).text(fields[i].displayLabel || fields[i].label));
			}
			header.append($('<th>', { style: 'text-align: left;' }));
			
			var tbody = $('<tbody>');

			thead.append(header);
			table.append(thead);
			table.append(tbody);
			popup.append(table);

			var hasRefs = false;
			var refMap  = {};

			if ($.isArray(references) && references.length > 0) {
				hasRefs = true;

				for (var i = 0; i < references.length; ++i) {
					var referenceArray = references[i].references;
					if (referenceArray && referenceArray.length) {
						references[i].references = referenceArray.filter(function(reference) {
							return reference.title && reference.title.length; 
						});
					}
					refMap[references[i].value] = references[i];
				}
			}

			popup.append($('<div>', {style: 'margin-top: 1em;', 'class':'none-text' }).text(settings.noneText));
			
			if ($.isArray(combinations) && combinations.length > 0) {
				for (var i = 0; i < combinations.length; ++i) {
					tbody.append(createCombination(fields, refMap, combinations[i]));
				}
				popup.find('div.none-text').hide();
			} else {
				popup.find('div.none-text').show();
			}

			if (settings.editable) {
				var moreDiv = $('<div>', {style: 'margin: 2em 0 1em 4px;' });

				if (hasRefs) {
					var hasMore  = false;
					var selected = false;
					var selector = $('<select>', { "class" : 'reference', title : settings.referencesTooltip, style : 'margin-right: 20px;' });

					selector.append($('<option>', { "class" : 'reference', value : '', style : 'color: gray; font-style: italic;' }).text(settings.referencesAdd));

					for (var i = 0; i < references.length; ++i) {
						if (refMap[references[i].value]) {
					    	selector.append($('<option>', { "class" : 'reference', value : references[i].value, title : references[i].title }).html(references[i].label).data('reference', references[i]));

							hasMore = true;
						} else {
							selected = true;
						}
					}

					if (selected) {
						$('option:first', selector).text(settings.referencesAdd);
					}

					if (!hasMore) {
						selector.hide();
					}

					selector.change(function() {
						var value = this.value;
						if (value && value != '') {
							var reference = $('option:selected', selector).data('reference');

							var fieldRefMap = {};
							fieldRefMap[reference.value] = reference;

							var combination = [];
							for (var j = 0; j < fields.length; ++j) {
								combination.push({value: '*', label: settings.anyValueText });
							}

							combination[fields.length - 2] = [reference];
							combination[fields.length - 1] = null;

							tbody.append(createCombination(fields, fieldRefMap, combination));

							// Remove the reference from the selector
							var options = this.options;
							for (var j = 0; j < options.length; ++j) {
								if (options[j].value == value) {
									this.remove(j);
									break;
								}
							}

							options[0].text = settings.referencesAdd;

							// Hide selector if all references were chosen
							if (options.length > 1) {
								options[0].selected = true;
							} else {
								selector.hide();
							}
							popup.find('div.none-text').hide();
						}

					});

					moreDiv.append(selector);
				}

				var moreCombis = $('<a>', { title: settings.moreTooltip }).text(settings.addText);

				moreCombis.click(function() {
					var combination = [];
					for (var j = 0; j < fields.length; ++j) {
						combination.push({value: '', label: settings.noValueText });
					}

					tbody.append(createCombination(fields, {}, combination));
					popup.find('div.none-text').hide();
				});

				moreDiv.append(moreCombis);
				
				popup.append(moreDiv);
				
				if (!settings.isCommentVisibility) {
					var $infoDiv = $('<div class="information" style="margin-top: 20px;"></div>');
					
					if (fields.length >= 2) {
						var currentFieldLabel = fields[fields.length - 1].displayLabel || fields[fields.length - 1].label;
						
						$infoDiv.append(i18n.message('tracker.field.combinations.more.hint1.label', currentFieldLabel));
					}
					$infoDiv.append(' ' + i18n.message('tracker.field.combinations.more.hint2.label'));
					$infoDiv.append('<br><br>');
					$infoDiv.append('<a target="_blank" href="https://codebeamer.com/cb/wiki/23940#section-Static+field+value+dependencies">' + i18n.message('tracker.field.combinations.static.wiki.label') + '</a>');				
					$infoDiv.append('<br>');
					$infoDiv.append('<a target="_blank" href="https://codebeamer.com/cb/wiki/23940#section-Reference+field+value+dependencies+between+work_2Fconfiguration+items">' + i18n.message('tracker.field.combinations.dynamic.wiki.label') + '</a>');
					
					popup.append($infoDiv);
				}
			}
		}

		if ($.fn.fieldValueCombinationsEditor._setup) {
			$.fn.fieldValueCombinationsEditor._setup = false;
			setup();
		}

		var plugin = this;

		return this.each(function() {
			var popup = $(this);
			init.apply(plugin, [popup, fields, references, combinations]);
		});
	};

	// Plugin to get field value combinations from an definition.
	$.fn.getFieldValueCombinations = function(fields) {
		var combinations = [];

		$('tr.combination', this).each(function() {
			var combination = [];

			$('td.combiVal', this).each(function() {
				var value  = null;
				var editor = $('[name="combiVal"]', this);
				if (editor.length > 0) {
					if (editor.is('select[multiple="multiple"]')) {
						var values = [];
						var selected = editor.multiselect('getChecked');
						if (selected) {
							for (var i = 0; i < selected.length; ++i) {
								values.push(selected[i].value);
							}
						}
						value = values.join(',');
					} else {
						value = editor.val();
					}
				} else if ((editor = $('span.combiVal', this)).length > 0) {
					value = editor.data('references');
				}
				combination.push(value);
			});

			combinations.push(combination);
		});

		return combinations;
	};

	// A third plugin to create a field value combinations editor in a dialog
	$.fn.showFieldValueCombinationsDialog = function(fields, combinations, options, dialog, callback) {
		var popup      = this;
		var settings   = $.extend( {}, $.fn.showFieldValueCombinationsDialog.defaults, dialog );
		var fieldIds   = $.map(fields, function(fld) { return fld.id;   }).join(',');
		var fieldTypes = $.map(fields, function(fld) { return fld.type; }).join(',');

		if ($.isArray(combinations)) {
 	        $.ajax(options.combiReferencesUrl, {type: 'GET', data: { fieldId : fieldIds, fieldType : fieldTypes }, dataType: 'json', cache: false }).done(function(references) {
				popup.fieldValueCombinationsEditor(fields, references, combinations, options);
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });
		} else {
 	        $.ajax(options.combiValuesUrl, {type: 'GET', data: { fieldId : fieldIds, fieldType : fieldTypes }, dataType: 'json', cache: false }).done(function(result) {
				popup.fieldValueCombinationsEditor(fields, result.references, result.combinations, options);
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });
		}

		if (options.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : options.submitText,
				 click: function() {
							var combis = popup.getFieldValueCombinations(fields);
						 	callback(combis);

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


	$.fn.fieldValueCombinationsEditor.defaults = {
		trackerId			:  null,
		editable			:  false,
		combiValuesUrl		:  null,
		combiReferencesUrl	:  null,
		combiValueEditor	:  function(editorName, field, special, value) {return null; },
	    submitText    		: 'OK',
	    cancelText   		: 'Cancel',
		noneText  			: 'No value combinations',
		moreTooltip			: 'Click here to add more value combinations',
		referencesAdd		: 'Add dynamic combination',
		referencesTooltip   : 'Click here to define dynamic combinations via references between the source trackers',
		filterText			: 'Filter',
		checkAllText		: 'Check all',
		uncheckAllText		: 'Uncheck all',
		noValueText			: 'None',
		anyValueText		: 'Any',
		trueValueText		: 'true',
		falseValueText		: 'false',
        editTooltip   		: 'Click to edit',
	    removeText			: 'Remove',
	   	removeConfirm		: 'Do you really want to remove this field value combination?'
	};

	$.fn.fieldValueCombinationsEditor._setup = true;

	$.fn.showFieldValueCombinationsDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true
	};


})( jQuery );

