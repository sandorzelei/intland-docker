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

	// Create a choice option object from a tr.choiceOption
	$.fn.getChoiceOption = function() {
		var option = {};

		$('input', this).each(function(index, field) {
			var name  = field.name;
			var value = field.value;

			option[name] = (name == 'id' || name == 'flags' ? parseInt(value) : value);
		});

		return option;
	};

	// The plugin to get the choice options back from an editor
	$.fn.getChoiceOptions = function() {
		var options = [];

		$('tr.choiceOption', this).each(function() {
			options.push($(this).getChoiceOption());
		});

		return options;
	};


	// A plugin to show a form to edit attributes of a choice option
	$.fn.choiceOptionForm = function(option, fieldFlags, settings) {

		function init(form, option) {
			if (!$.isPlainObject(option)) {
				option = {};
			}

			form.objectInfoBox(option.info, settings);

			var table   = $('<table>', { "class" : 'choiceOptionForm formTableWithSpacing' }).data('option', option);
			var idRow   = $('<tr>');
			var idLabel = $('<td>',	   { "class" : 'labelCell mandatory' }).text(settings.idLabel + ':');
			var idCell  = $('<td>',    { "class" : 'dataCell' });
          	var idEdit	= $('<input>', { type : 'number', name : 'id', value : option.id, size : '5', maxlength : '10', disabled : !settings.editable });
          	idEdit.attr('autocomplete', 'off');

          	idCell.append(idEdit);
          	idRow.append(idLabel);
          	idRow.append(idCell);
			table.append(idRow);

			var nameRow   = $('<tr>');
			var nameLabel = $('<td>',	 { "class" : 'labelCell mandatory' }).text(settings.nameLabel + ':');
			var nameCell  = $('<td>', 	 { "class" : 'dataCell' });
			var name	  = $('<input>', { type : 'text', name : 'name', value : option.name, maxlength : 80, disabled : !settings.editable });
       		var style	  = $('<input>', { type : 'hidden', name : 'style', value : option.style, id : 'style_editor' });

			nameCell.append(name);
			nameCell.append(style);

			// If this is a status option
           	if (settings.editable && option.fieldId == 7) {
           		nameCell.append($('<a>', { href : '#', "class" : 'colorPicker yui-skin-sam', title : settings.colorPickerText }).append($('<img>', { src : settings.colorPickerIcon })).click(function() {
           			colorPicker.showPalette(this, 'style_editor');
           			return false;
           		}));
           	}

			nameRow.append(nameLabel);
			nameRow.append(nameCell);
			table.append(nameRow);

			var descrRow    = $('<tr>');
			var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(settings.descrLabel + ':');
			var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea' });
			var description = $('<textarea>', { name : 'description', rows : 2, cols : 80, disabled : !settings.editable }).val(option.description);

			descrCell.append(description);
			descrRow.append(descrLabel);
			descrRow.append(descrCell);
			table.append(descrRow);

    		if (fieldFlags && fieldFlags.length > 0) {
				var flagsRow   = $('<tr>');
				var flagsLabel = $('<td>', { "class" : 'labelCell optional' }).text(settings.flagsLabel + ':');
				var flagsCell  = $('<td>', { "class" : 'flags' });

	    		for (var i = 0; i < fieldFlags.length; ++i) {
	        		var flag     = parseInt(fieldFlags[i]);
	        		var name     = settings.flagName[fieldFlags[i]];
		           	var checkbox = $('<input>', { type : 'checkbox', name : name, value : flag, checked : ((option.flags & flag) == flag), disabled : !settings.editable });
	        		var label    = $('<label>', { style : 'vertical-align: middle; margin-right: 8px;' });

	        		label.append(checkbox);
		           	label.append(name);
		           	flagsCell.append(label);

		           	if (flag == 32 || flag == 128) {
		           		// don't allow the Information and the Folder flags to be selected simultaneously
		           		checkbox.on("change", function () {
		           			var otherFlag = $(this).val() == 128 ? 32 : 128;
		           			if ($(this).is(":checked")) {
		           				flagsRow.find("input[value=" + otherFlag + "]").attr("checked", null);
		           			}
		           		});
		           	}
	        	}

				flagsRow.append(flagsLabel);
				flagsRow.append(flagsCell);
				table.append(flagsRow);
    		}

			form.append(table);
		}

		return this.each(function() {
			init($(this), option);
		});
	};


	// Retrieve the edited choice option from a choiceOptionForm
	$.fn.getChoiceOptionFromForm = function() {
		var form  = $('table.choiceOptionForm', this);
		var flags = 0;
		var names = [];

		$('td.flags input[type="checkbox"]:checked', form).each(function(index, checkbox) {
			flags |= parseInt(checkbox.value);
			if (checkbox.value >= 1) {
				names.push(checkbox.name);
			}
		});

		var option = $.extend({}, form.data('option'), {
			id   		: parseInt($('input[name="id"]', form).val()),
			name    	: $.trim($('input[name="name"]', form).val()),
			style		: $.trim($('input[name="style"]', form).val()),
			description : $.trim($('textarea[name="description"]', form).val()),
			meaning	    : names.length > 0 ? names.join(', ') : '--',
			flags		: flags
		});

		return option;
	};


	// A plugin to create a new/edit an existing choice option in a popup dialog
	$.fn.showChoiceOptionDialog = function(option, fieldFlags, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showChoiceOptionDialog.defaults, dialog );
		var popup    = this;

		popup.choiceOptionForm(option, fieldFlags, config);

		if (config.editable && $.isFunction(callback)) {
			settings.buttons = [
			   { text : config.submitText,
				 id: "field" + option.fieldId + "_add_choice_option_button_ok",
				 click: function() {
						 	var result = callback(popup.getChoiceOptionFromForm());
						 	if (!(result == false)) {
					  			popup.dialog("close");
					  			popup.remove();
						 	}
						}
				},
				{ text : config.cancelText,
				  "class": "cancelButton",
				  id : "field" + option.fieldId + "_add_choice_option_button_cancel",
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

	$.fn.showChoiceOptionDialog.defaults = {
		dialogClass		: 'popup',
		width			: 800,
		draggable		: true,
		close			: function( event, ui ) {
							var possibleAnchors = $("a.colorPicker:not([id])");
							console.log(possibleAnchors);
							if( possibleAnchors && possibleAnchors.length > 0) {
								var colorpickerOpenerAnchor = possibleAnchors[0];
								colorPicker.hidePalette(colorpickerOpenerAnchor);
							}
						}
	};


	// ChoiceOptionEditor Plugin definition.
	$.fn.choiceOptionEditor = function(options) {
		var settings = $.extend( {}, $.fn.choiceOptionEditor.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function setup() {
			/* Define an inplace editor for choice option ids */
		    $.editable.addInputType('choiceOptionId', {
		        element : function(settings, self) {
		           	var input = $('<input>', { type : 'number', size : '5', maxlength : '10', style : 'text-align:right;' });
		           	input.attr('autocomplete', 'off');
		           	$(this).append(input);
		           	$(this).attr('title', '');
		           	return input;
		        }
		    });

			/* Define an inplace editor for choice option flags */
		    $.editable.addInputType('choiceOptionFlags', {
		        element : function(settings, self) {
		    		var flags = parseInt($(self).prev('input[type="hidden"]').val());

		    		var fieldFlags = $(self).closest('tbody.choiceOptions').attr('data-flags').split(',');
		        	for (var i = 0; i < fieldFlags.length; ++i) {
		        		var flag     = parseInt(fieldFlags[i]);
		        		var name     = getFlagName(fieldFlags[i]);
			           	var checkbox = $('<input>', { type : 'checkbox', name : name, value : flag, checked : ((flags & flag) == flag) });
		        		var label    = $('<label>', { style : 'vertical-align: middle; margin-right: 8px;' });

		        		label.append(checkbox);
			           	label.append(name);
			            $(this).append(label);
		        	}
		           	$(this).append($('<br>'));
		           	$(this).attr('title', '');

		           	return this;
		        },

		    	content : function(string, settings, self) {
		    		// Nothing
		     	}
		    });

		}

		function editOptionId(option) {
			$('span.choiceOptionId', option).dblclick();
		}

		function setOptionId(id) {
			// Store the new item filter id in the appropriate hidden field
			$(this).prev('input[type="hidden"]').val(id);
			return id;
		}

		function getFlagName(flag) {
			return settings.flagName[flag];
		}

		function editOptionFlags(option) {
			$('span.choiceOptionFlags', option).dblclick();
		}

		function setOptionFlags() {
			var flags = 0;
			var flagNames = [];

			$('input[type="checkbox"]:checked', this).each(function(index, checkbox) {
				flags |= parseInt(checkbox.value);
				if (checkbox.value > 1) {
					flagNames.push(checkbox.name);
				}
			});

			var flagsFld = $(this).prev('input[type="hidden"]');
			var oldFlags = parseInt(flagsFld.val());
			flagsFld.val(flags);

			if (flags != oldFlags) {
				var optRow  = flagsFld.closest('tr.choiceOption');
				var options = optRow.closest('tbody.choiceOptions');
				var option  = optRow.getChoiceOption();

				option.fieldId = parseInt(options.attr('data-fieldId'));

	        	// Load the option flags editor html
				$.get(settings.optionUrl, option, function(html) {
					$('span.choiceOptionName', optRow).html(html);
				});
			}

			return flagNames.length > 0 ? flagNames.join(', ') : '--';
		}

		function setOption(row, option) {
			$('input[type="hidden"]', row).each(function(index, field) {
				$(field).val(option[field.name]);
			});

			$('span.choiceOptionId',    row).text(option.id);
			$('span.choiceOptionName',  row).text(option.name).attr('title', option.description);
			$('span.choiceOptionFlags', row).text(option.meaning);
		}

		function addOption(options, option, position) {
			var optionIndex = parseInt(options.attr('data-nextOptionIndex'));
			options.attr('data-nextOptionIndex', optionIndex + 1);

			var optRow = $('<tr>', { "class" : 'choiceOption', "data-index" : optionIndex });

			if (settings.editable) {
				var issueHandle = $("<td>", {"class": "issueHandle", "title": i18n.message("cmdb.version.stats.drag.drop.hint")});
				optRow.append(issueHandle);
			}

			var optIdCol  = $('<td>',    { "class" : 'numberData', style: 'width: 4em;"' });
			var optIdFld  = $('<input>', { type : 'hidden', name : 'id', value : option.id });
			var optIdSpan = $('<span>',  { "class" : 'choiceOptionId' }).text(option.id);

			optIdCol.append(optIdFld);
			optIdCol.append(optIdSpan);

			var extraClass = '';
			if (settings.editable) {
				extraClass = "highlight-on-hover";
			}
			var optNameCol  = $('<td>',    { "class" : 'textData', style : 'min-width: 10em; width:10%'} );
			var optNameFld  = $('<input>', { type : 'hidden', name : 'name', value : option.name });
			var optNameSpan = $('<span>',  { "class" : 'choiceOptionName ' + extraClass, title : option.description }).text(option.name);
			var optStyleFld = $('<input>', { type : 'hidden', name : 'style', value : option.style, id : 'style_' + optionIndex });
			var optDescrFld = $('<input>', { type : 'hidden', name : 'description', value : option.description });

			optNameCol.append(optNameFld);
			optNameCol.append(optNameSpan);
			optNameCol.append(optStyleFld);
			optNameCol.append(optDescrFld);

			var optFlagsCol  = $('<td>',    { "class" : 'textData' });
			var optFlagsFld  = $('<input>', { type : 'hidden', name : 'flags', value : option.flags });
			var optFlagsSpan = $('<span>',  { "class" : 'choiceOptionFlags' }).text(option.meaning);

			optFlagsCol.append(optFlagsFld);
			optFlagsCol.append(optFlagsSpan);

            /** Add remove button */
            var removeBtn = $('<span>', { "class" : 'removeButton', "title" : settings.removeOptionText });
            var removeBtnCol = $('<td>', { "class" : 'removeButtonData'});
            removeBtn.click(function() {
                removeChoiceOption(optRow);
            });

            removeBtnCol.append(removeBtn);

			optRow.append(optIdCol);
			optRow.append(optNameCol);
			optRow.append(optFlagsCol);
            optRow.append(removeBtnCol);

			if (position) {
				optRow.insertBefore(position);
			} else {
				options.append(optRow);
			}

			/** Make the choice option name and style editable */
		    optNameSpan.click(function(event) {
		    	event.stopPropagation();
		    	editOption(options, optRow, function(option) {
				   return insUpdOption(options, optRow, option, null);
		    	});
		    });

			// Immediately active inline editing of the newly added option
			//optNameSpan.dblclick();

			return optRow;
		}

		function insUpdOption(options, row, option, position) {
			var conflict = false;

			if (!(option.id && option.id > 0)) {
				alert(settings.idRequired);
				return false;
			}

			if (!(option.name && option.name.length > 0)) {
				alert(settings.nameRequired);
				return false;
			}

			$('tr.choiceOption', options).each(function() {
				var current = $(this);
				if (row == null || !current.is(row)) {
					var check = current.getChoiceOption();

					if (check.id == option.id) {
						alert(settings.idDuplicate);
						conflict = true;
						return false;
					} else if (check.name == option.name) {
						alert(settings.nameDuplicate);
						conflict = true;
						return false;
					}
				}
			});

			if (conflict) {
				return false;
			}

			if (row == null) {
				row = addOption(options, option, position);
			} else {
				setOption(row, option);
			}

			$.get(settings.optionUrl, option, function(html) {
				var choiceOptionSpan = $('span.choiceOptionName', row);
				choiceOptionSpan.html(html);
				// Write back the option name
				var nameSpan = choiceOptionSpan.find('span');
				if (nameSpan.length > 0) {
					nameSpan.text(option.name);
				} else {
					choiceOptionSpan.text(option.name);
				}
			});

			return true;
		}

		function removeChoiceOption(option) {
//			if (confirm(settings.removeOptionConfirm)) {
				option.remove();
//			}
		}

		function editOption(options, row, callback) {
			var option;

			if (row) {
				option = row.getChoiceOption();

				var info = row.attr('data-info');
				if (info) {
					option.info = eval('(' + info + ')');
				}
			} else {
				option = {
					id 			: parseInt(options.attr('data-nextOptionId')),
					name	    : '',
					style		: '',
					description : '',
					flags 		: 0
				};

				options.attr('data-nextOptionId', option.id + 1);
			}

			option.fieldId = parseInt(options.attr('data-fieldId'));
    		var fieldFlags = options.attr('data-flags').split(',');

			var popup = $('#choiceOptionEditor');
  			if (popup.length == 0) {
  				popup = $('<div>', { id : 'choiceOptionEditor', "class" : 'editorPopup', style : 'display: None;'} );
  				popup.insertAfter(options.closest('table'));
  			} else {
  				popup.empty();
  			}

  			popup.showChoiceOptionDialog(option, fieldFlags, settings, {
				title			: row ? settings.editOptionText : settings.addOptionLink,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false

  			}, callback);
		}

		function init() {
			var options = $('tbody.choiceOptions', this);

			if (settings.editable) {

				/** Make the choice options sortable */
				// #1788661 UI sortable has performance issues when the item count is several thousands especially on initialization
				// Only those elements are initialized which are visible on the screen when the browser window is scrolled or the mouse enters the choice options table
				options.sortable({ items: "> tr.sorting", axis: "y", cursor: "move", delay: 150, distance: 5 });
				
				var refreshSortableOptions = throttleWrapper(function() {
					if (options.is(':visible')) {
						var $trs = options.find('> tr').filter(function(index, element) {
							return isElementOnScreen(element);
						});
						
						var isRefreshNeeded = false;
						
						$trs.each(function() {
							if (!$(this).hasClass('sorting')) {
								$(this).addClass('sorting');
								isRefreshNeeded = true;
							}
							
						});
						
						isRefreshNeeded && options.sortable('refresh');
					}
				}, 200);

				options.closest('.choice-options-dialog').on('scroll', refreshSortableOptions);
				options.on('mouseenter', refreshSortableOptions);

                var thead = options.siblings("thead");
			    thead.find("th:first-child", options).before($("<th>"));
                thead.find("th:last-child", options).after($("<th>"));
			    $("tr.choiceOption td:first-child", options).before($("<td>", {"class": "issueHandle", "title": i18n.message("cmdb.version.stats.drag.drop.hint")}));
				/** Make the choice option name and style editable */
			    $('span.choiceOptionName', options).click(function(event) {
			    	var optRow = $(this).closest('tr.choiceOption');

			    	event.stopPropagation();

			    	editOption(options, optRow, function(option) {
					   return insUpdOption(options, optRow, option, null);
			    	});
			    }).addClass("highlight-on-hover");

                /** Add remove button */
				$("tr.choiceOption", options).each(function() {
					var optRow = $(this);
                var removeBtn = $('<span>', { "class" : 'removeButton', "title" : settings.removeOptionText });
                var removeBtnCol =$('<td>', { "class" : 'removeButtonData' });
					optRow.append(removeBtnCol.append(removeBtn));
					removeBtn.click(function() {
						removeChoiceOption(optRow);
                });
				});

			    var moreOptionsDiv  = $('<div>', { style : 'margin-left: 75px; margin-top: 1em;'});
				var moreOptionsLink = $('<a>', { title : settings.addOptionTooltip }).text(settings.addOptionLink).click(function() {
					editOption(options, null, function(option) {
						return insUpdOption(options, null, option, null);
					});
					return false;
				});

				moreOptionsDiv.append(moreOptionsLink);
				$(this).append(moreOptionsDiv);
			}
		}

		if ($.fn.choiceOptionEditor._setup) {
			$.fn.choiceOptionEditor._setup = false;
			setup();
		}

		return this.each(init);
	};

	var renderChoiceOptions = function(data) {

		var table = $("<table>", { "class": "displaytag"});

		var inlineEditHint = i18n.message("tracker.field.layout.inline.edit.hint");

		var head = function() {
			var idTh = $("<th>", {
				"class": "numberData",
				"style": "width: 4em;"
			}).html(i18n.message("tracker.choice.id.label"));

			var nameTh = $("<th>", {
				"class": "textData",
				"style": "width:50%"
			}).html(i18n.message("tracker.choice.name.label"));

			var flagsTh = $("<th>", {
				"class": "textData"
			}).html(i18n.message("tracker.choice.flags.label"));

			var headRow = $("<tr>").append(idTh).append(nameTh).append(flagsTh);
			return $("<thead>").append(headRow);
		};

		var body = function() {
			var tbody = $("<tbody>", {
				"id": "field_" + data.fieldId + "_options",
				"class": "choiceOptions",
				"data-fieldid": data.fieldId,
				"data-nextoptionid": data.nextOptionId,
				"data-nextoptionindex": data.nextOptionIndex,
				"data-flags": data.fieldFlags
			});
			$(data.options).each(function(index, option) {

				var tr = $("<tr>", {
					"class": "choiceOption",
					"data-index": index,
					"data-info": JSON.stringify(option.info)
				});

				var idTd = $("<td>", {
					"class": "numberData" + (!!option.overrides.id ? " overriddenFieldValue" : ""),
					"style": "width: 4em;"
				}).append($("<input>", {
					"type": "hidden",
					"name": "id",
					"value": option.id
				})).append($("<span>", {
					"class": "choiceOptionId"
				}).text(option.id));

				var nameTd = $("<td>", {
					"class": "textData" + (!!option.overrides.name ? " overriddenFieldValue" : ""),
					"style": "50%"
				}).append($("<input>", {
					"type": "hidden",
					"name": "name"
				}).val(option.name))
					.append($("<span>", {
						"class": "choiceOptionName",
						"title": inlineEditHint
					}).html(option.label))
					.append($("<input>", {
						"type": "hidden",
						"name": "style",
						"id": "style_" + index
					}).val(option.style))
					.append($("<input>", {
						"type": "hidden",
						"name": "description"
					}).val(option.description));

				var flagsTd = $("<td>", {
					"class": "textData" + (!!option.overrides.flags ? " overriddenFieldValue" : "")
				}).append($("<input>", {
					"type": "hidden",
					"name": "flags"
				}).val(option.flags))
					.append($("<span>", {
						"class": "choiceOptionFlags"
					}).text(option.meaning));

				tr.append(idTd).append(nameTd).append(flagsTd);
				tbody.append(tr);
			});

			return tbody;
		};

		table.append(head()).append(body());

		return table;
	};

	// A third plugin to show/edit choice options in a dialog
	$.fn.showChoiceOptionsDialog = function(fieldId, options, dialog, callback) {
		var popup    = this;
		var popupId  = popup.attr("id");
		var settings = $.extend( {}, $.fn.showChoiceOptionsDialog.defaults, dialog );

		var initWithContent = function(jsonResponseObject) {
			var renderedHtml = renderChoiceOptions(jsonResponseObject);
			popup.html(renderedHtml);
			if (options.editable) {
				popup.choiceOptionEditor(options);
			}
			var position = popup.dialog("option", "position");
			popup.dialog("option", "position", position);

			saveState();
		};

		var getState = function() {
			var popup = $("#" + popupId);
			var tbody = popup.find("tbody");
			var result = {
				"fieldId": tbody.data("fieldid"),
				"nextOptionId": tbody.data("nextoptionid"),
				"nextOptionIndex": tbody.data("nextoptionindex"),
				"fieldFlags": tbody.data("flags")
			};
			var options = [];
			$(tbody.find("tr")).each(function(index, tr) {
				tr = $(tr);
				options.push({
					"id": tr.find("input[name=id]").val(),
					"flags": tr.find("input[name=flags]").val(),
					"overrides": {
						"id": tr.find("input[name=id]").closest("td").hasClass("overriddenFieldValue"),
						"name": tr.find("input[name=name]").closest("td").hasClass("overriddenFieldValue"),
						"flags": tr.find("input[name=flags]").closest("td").hasClass("overriddenFieldValue")
					},
					"style": tr.find("input[name=style]").val(),
					"description": tr.find("input[name=description]").val(),
					"name": tr.find(".choiceOptionName").text(),
					"label": tr.find(".choiceOptionName").html(),
					"meaning": tr.find(".choiceOptionFlags").text(),
					"offset": index + 1,
					"info": JSON.stringify(tr.data("info"))
				});
			});
			result["options"] = options;

			return result;
		};

		var saveState = function() {
			popup.prop("lastState", getState());
		};

		var restoreLastState = function() {
			initWithContent(popup.prop("lastState"));
		};

		var errorHandler = function(errorMsg) {
			popup.dialog("close").remove();
			if (!errorMsg) {
				errorMsg = i18n.message("ajax.genericError");
			}
			alert(errorMsg);
		};

		var firstInvocation = !popup.prop("lastState");
		if (firstInvocation) {
			popup.html('<div class="options-loading" style="height: 100px;"></div>');
			$.ajax({
				url: options.optionsUrl + '&fieldId=' + fieldId,
				cache: false,
				success: function(jsonResponseObject) {
					if (!jsonResponseObject) {
						errorHandler();
					}
					else {
						initWithContent(jsonResponseObject);
					}
				},
				error: function(jqXHR) {
					var errorMsg = i18n.message("ajax.genericError");
					if (jqXHR.hasOwnProperty("responseText") && jqXHR.responseText.indexOf("Field is not created yet") > -1) {
						errorMsg = i18n.message("tracker.choice.save.warning");
					}
					errorHandler(errorMsg);
				}
			});
		} else {
			var html = popup.html();
			popup.empty();
			popup.html('<div class="options-loading" style="height: 100px;"></div>');
			setTimeout(function() {
				popup.html(html);
				
				var position = popup.dialog('option', 'position');
				popup.dialog('option', 'position', position);
			}, 500);
		}

		if (options.editable && $.isFunction(callback)) {
			settings.buttons = [
				{ text: options.submitText,
					id: "field" + fieldId + "_choice_option_editor_button_ok",
					click: function() {

						var that = $(this);
						var saveChoiceOptions = function() {
							var choiceOptions = popup.getChoiceOptions();
							callback(choiceOptions);
							saveState();
							that.dialog("close");
						};

						if (options["withAutoSave"]) {
							showFancyConfirmDialogWithCallbacks(i18n.message("tracker.choice.option.autosave.warning"), function() {
								saveChoiceOptions();
								// trigger a global layout save event
								$("#saveTrackerFieldsSubmitButton").click();
							});
						} else {
							saveChoiceOptions();
						}

					}
				},
				{ text: options.cancelText,
					"class": "cancelButton",
					id: "field" + fieldId + "_choice_option_editor_button_cancel",
					click: function() {
						var popup = $(this);
						restoreLastState();
						popup.dialog("close");
					}
				}
			];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.choiceOptionEditor.defaults = {
		editable			: false,
		optionsUrl			: null,
		optionUrl			: null,
		flagName    		: { "1" : 'Obsolete', "4" : 'Resolved', "8" : 'Successful', "16" : 'Closed', "32" : 'Folder', "64" : 'In progress' },
		idLabel				: 'Id',
		idRequired			: 'A (unique) option Id is required',
		idDuplicate			: 'There is already another choice option with the same Id',
		nameLabel			: 'Name',
		nameRequired		: 'A (unique) option name is required',
		nameDuplicate		: 'There is already another choice option with the same name',
		descrLabel			: 'Description',
		flagsLabel			: 'Flags',
		infoLabel			: 'Administrative Information',
		infoTitle			: 'Additional/administrative information about this choice option',
		versionLabel		: 'Version',
		createdByLabel		: 'Created by',
		lastModifiedLabel	: 'Last modified by',
		commentLabel		: 'Comment',
	    submitText    		: 'OK',
	    cancelText   		: 'Cancel',
	    addOptionText		: 'Add Option here',
	    addOptionLink		: 'Add Option',
	    addOptionTooltip    : 'Add a new option to the end of the options list. You can drag the new option to the intended position later.',
	    editOptionText		: 'Edit Option',
	    editOptionTooltip	: 'Double click to edit the choice option',
	    editIdText   		: 'Change Id',
	    editNameText 		: 'Change Name',
	    editDescrText 		: 'Change Description',
	    editFlagsText		: 'Change Flags',
	    colorPickerText		: 'Pick a color!',
	    colorPickerIcon		: contextPath + '/images/color_swatch.png',
	    removeOptionText	: 'Remove Option',
	    removeOptionConfirm : 'Really remove this choice option ?'
	};

	$.fn.choiceOptionEditor._setup = true;

	$.fn.showChoiceOptionsDialog.defaults = {
		dialogClass		: 'popup choice-options-dialog',
		minWidth		: 630,
		draggable		: true
	};

})( jQuery );

