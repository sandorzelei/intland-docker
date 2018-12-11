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

	function isChoiceField(fieldId) {
		return (fieldId >= 13 && fieldId <= 17) || (fieldId >= 30 && fieldId <= 31) || (fieldId >= 1000 && fieldId < 10000);
	}

	function isUserDefined(fieldId) {
		return fieldId >= 10000 && fieldId < 20000;
	}

	function isTableColumn(fieldId) {
		var rowCol = fieldId % 1000000;
		return fieldId >= 1000000 && rowCol > 0 && rowCol < 100;
	}

	function getTableId(fieldId) {
		return fieldId >= 1000000 ? Math.floor(fieldId / 1000000) - 1 : -1;
	}

	function getColumnIndex(columnId) {
		return columnId >= 1000000 ? (columnId % 100) - 1 : -1;
	}

	function setTypeOfField(field, type) {
		if (field && field.id && typeof type === 'number') {
			field.type            = type;
			field.multiValue      = false;
			field.choosable       = false;
			field.referenceConfig = false;
			field.computable      = false;
			field.combinable      = false;
			field.resizeable      = false;
			field.multiLine       = false;
			field.limitable       = false;
			field.formatable      = false;
			field.omitSuspectedChange = false;
			field.omitMerge			= false;
			if (isUserDefined(field.id) || isTableColumn(field.id)) {
				field.computable  = true;

				if (isNaN(type) || type == 0 || type == 10) {  //(Wiki)Text
					field.resizeable = true;
					field.multiLine  = true;
					field.limitable  = true; // min/max is the minimum/maximum length of the text ?

				} else if (type == 1 || type == 2 || type == 11) { //Integer, Decimal, Duration
					field.resizeable = true;
					field.limitable  = true;
					field.formatable = (type != 11);

				} else if (type >= 5 && type <= 9) { //Principal, Choice, Reference, Country, Language
					if (type == 6 || type == 7) { // Choice, Reference
						field.choosable       = true;
						field.referenceConfig = true;
					}
					field.multiValue = true;
					field.combinable = (type > 5);

				} else if (type == 4) { // Boolean
					field.combinable = true;
				}
			} else if (isChoiceField(field.id)) {
				if (type == 6 || type == 7) { // Choice, Reference
					field.choosable       = true;
					field.referenceConfig = true;
				}
				field.multiValue = true;
				field.combinable = (type > 5);
			}

			return true;
		}

		return false;
	}

	function appendMenuBox(toWhat) {
		var menuBox = $('<span>', { 'class': "yuimenubaritemlabel yuimenubaritemlabel-hassubmenu"});
		var menuArrow = $('<img>', { 'src': contextPath + "/images/space.gif", 'class': 'menuArrowDown' + (codebeamer.userPreferences.alwaysDisplayContextMenuIcons ? ' always-display-context-menu' : '')});
		menuBox.append(menuArrow);
		toWhat.append(menuBox);
	}

	var allowedFieldTypeChanges = {
		'0': 10,
		'10': 0,
		'1': 2
	};

	// Single field configuration form plugin
	$.fn.fieldConfigurationForm = function(field, settings, newField) {

		function getTypeSelector(typeClass, type) {
			var types    = settings.typeClasses[typeClass];
			var selector = $('<select>', { name : 'type', disabled : !settings.editable, style: 'margin-right: 5px;' });

			for (var i = 0; i < types.length; ++i) {
			     selector.append($('<option>', {value: types[i], selected: (type == types[i])}).text(settings.typeName[types[i]]));
			};

			return selector;
		}

		function getRefTypeSelector(refType) {
			var selector = $('<select>', { name : 'refType', style : 'margin-right: 8px;' });

			for (var i = 0; i < settings.refTypes.length; ++i) {
			     selector.append($('<option>', {value: settings.refTypes[i], selected: (refType == settings.refTypes[i])}).text(settings.refTypeName[settings.refTypes[i]]));
			}

			return selector;
		}

		function getMemberTypeSelector(memberMask) {
			var selector = $('<select>', { name : 'memberType', multiple : true, style : 'margin-right: 8px;', disabled : !settings.editable });

			if (!(typeof memberMask === 'number')) {
				memberMask = 0;
			}

			for (var i = 0; i < settings.memberTypes.length; ++i) {
				var memberType = settings.memberTypes[i];
			    selector.append($('<option>', { value: memberType.id, title : memberType.title, selected : (memberMask & memberType.id) == memberType.id }).text(memberType.name));
			}

			return selector;
		}

		function truncateText(text, numberOfChars) {
			numberOfChars = numberOfChars || DEFAULT_TRUNCATE_CHARS;
			if (text.length > numberOfChars) {
				return (text.substring(0, numberOfChars) + "...");
			}
			return text;
		};

		function initMultiSelect($selector, noneSelectedText, onePerGroup) {

			$selector.multiselect({
				classes: "queryConditionSelector",
				minWidth: 100,
				height: 230,
				checkAllText : "",
				uncheckAllText: "",
				beforeoptgrouptoggle: function(event, ui) {
					return !onePerGroup;
				},
				selectedText: function(numChecked, numTotal, checkedItems) {
					var value = [];
					var $checkedItems = $(checkedItems);
					$checkedItems.each(function(){
						var valueString = $(this).next().html();
						value.push(valueString);
					});
					var joinedText = value.join(", ");
					return "<span class=\"labelValueText\">" + truncateText(joinedText) + "</span>";
				},
				noneSelectedText: function() {
					return noneSelectedText;
				},
				create: function(event, ui) {
					// remove check/uncheck all/close buttons
					$(".queryConditionSelector .ui-multiselect-all").closest("ul").remove();
					setTimeout(function() {
						$selector.multiselect("widget").find(".ui-multiselect-filter").find("input").focusin(function(e) {
							return false;
						});
					}, 100);
				},
				open: function() {
					var $widget = $(this).multiselect("widget");
					setTimeout(function() {
						$widget.find(".ui-multiselect-filter input").focus();
					}, 100);
				},
				click: function(event, ui) {
					var $menu = $(this).multiselect("widget");
					if (ui.value != "on") {
						var selected = $(this).multiselect("getChecked").filter(":not(.additionalCheckbox)");

						// only one option allowed per optionGroup
						// (radio group cannot be used because it applies to all the groups)
						if( onePerGroup ) {
							if( !ui.checked ) {
								// at this point, nothing is checked, so check the default
								var values = ui.value.split(" ");
								$menu.find("[value='0 " + values[1] + "']").attr("checked", true);
							}

							// get all the selected option's optgroup!
							checkboxesOfOptGroup = {};
							optGroupNames = [];
							$.each(selected, function(i, checkbox) {
								var value = checkbox.value;
								var optGroupName = $("option[value='" + value + "']", $selector).parent().attr('label');

								if( checkboxesOfOptGroup[optGroupName] == null ) {
									checkboxesOfOptGroup[optGroupName] = [];
									optGroupNames.push(optGroupName);
								}
								checkboxesOfOptGroup[optGroupName].push(checkbox);
							});

							// if a click occurs, deselect every other option
							// which is different from the clicked option
							$.each(optGroupNames, function(i, groupName) {
								if( checkboxesOfOptGroup[groupName].length > 1 ) {
									$.each(checkboxesOfOptGroup[groupName], function(i, checkbox) {
										if( checkbox.value != ui.value ) {
											$menu.find("[value='" + checkbox.value + "']").attr("checked", false);
										}
									});
								}
							});
						}
					}
				}
			}).multiselectfilter({
				label: "",
				placeholder: i18n.message("Filter")
			});
		};

		function getStatusSelector(statusSelector, projectWithTrackerInfos, options) {
			statusSelector.empty();

			if( projectWithTrackerInfos != null && $.isArray(projectWithTrackerInfos) && projectWithTrackerInfos.length > 0 ){
				$.each(projectWithTrackerInfos, function(i, info) {

					var optGroup = $('<optgroup>', {'label': info.projectName + " - " + info.trackerName});
					$.each(options.trackerItemFilters, function(j, status) {
						var elemSettings = { value: status.id + ' ' + info.trackerId };
						if( status.id == '0' ) {
							elemSettings.selected = true;
						}

						optGroup.append($('<option>', elemSettings).text(status.name));
					});

					$.get(options.trackerFiltersUrl, { tracker_id : info.trackerId, options : 'IgnoreDeletedFlag' }).done(function(filters) {
						addStatusOptions(optGroup, filters);
						statusSelector.append(optGroup);
						statusSelector.multiselect("refresh");

			    	}).fail(function(jqXHR, textStatus, errorThrown) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			        });
				});

			} else {
				statusSelector.multiselect("refresh");
			}

			return statusSelector;
		}

		function addStatusOptions(selector, data) {
			$.each(data, function(i, filter) {
				selector.append($('<option>', { value : filter.id }).text(filter.name));
			});
		}

		function getTrackerSelector(trackerSelector, selectedProjectInfos, options) {

			trackerSelector.empty();

			if( selectedProjectInfos != null && $.isArray(selectedProjectInfos) && selectedProjectInfos.length > 0 ) {
				$.each(selectedProjectInfos, function(i, selectedProjectInfo) {
					$.get(options.projectTrackersUrl, { "proj_id" : selectedProjectInfo.projectId, typeId : 9}, function(trackers) {
						// Result is the "explicitly" array

						if( $.fn.fieldConfigurationForm.currentTrackers == null ) {
							$.fn.fieldConfigurationForm.currentTrackers = {};
						}
						$.fn.fieldConfigurationForm.currentTrackers[selectedProjectInfo.projectId] = trackers;

						addTrackerOptions(trackerSelector, trackers, selectedProjectInfo.projectName);
						trackerSelector.multiselect("refresh");

		        	}).fail(function(jqXHR, textStatus, errorThrown) {
		        		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					});
				});
			} else {
				$.fn.fieldConfigurationForm.currentTrackers == null
				trackerSelector.multiselect("refresh");
			}

			return trackerSelector;
		}

		function addTrackerOptions(selector, trackers, projectName) {

			if( trackers != null && $.isArray(trackers) ) {
				for( var i = 0; i < trackers.length; i++ ) {
					var item = trackers[i];
					if( item.trackers != null && $.isArray(item.trackers) ) {
						var optGroup = $('<optgroup>', {'label': projectName});

						$.each(item.trackers, function(j, tracker) {
							var option = $('<option>', {'value': tracker.id, 'project': projectName}).text(tracker.name);
							optGroup.append(option);

							if (tracker.branchList && tracker.branchList.length) {
								for (var k = 0; k < tracker.branchList.length; k++) {
									var branch = tracker.branchList[k];

									var name = branch.name;

									var classes = ' branchTracker';
									if (tracker.branchList[k].level) {
										classes += ' level-' + tracker.branchList[k].level;
									}

									var $branchOption = $('<option>', {
										"class" : classes,
										value: branch.id,
										title : branch.title
									}).text(name).data('tracker', branch);

									optGroup.append($branchOption);
								}
							}
						});
						selector.append(optGroup);
					}
				}
			}
		}

		function getProjectSelector(options) {
			var selector = $('<select>', { "class" : 'projectSelector', 'multiple': 'multiple' });

			var request = $.get(options.projectsUrl).done( function(projects) {
				// projects: list of {id, name}
				addProjectOptions(selector, projects);
				initMultiSelect(selector, options.projectSelectorDefault);

	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	        });

			$.fn.fieldConfigurationForm.getProjectsRequest = request;

			return selector;
		}

		function addProjectOptions(selector, projects) {
			$.each(projects, function(i, project) {
				var option = $('<option>', {'value': project.id}).text(project.name);
				selector.append(option);
			});
		}

		function getQuickAddReferringTracker(options) {

			var wrapperDiv = $('<div>', {'style': 'white-space: normal;'});

			var projectSelectorLabel = $('<label>', {'class': 'labelCell optional'}).text(options.projectLabel);
			var projectSelector = getProjectSelector(options);

			var trackerSelectorLabel = $('<label>', {'class': 'labelCell optional'}).text(options.trackerLabel);
			var trackerSelector = $('<select>', { "class" : 'trackerSelector', 'multiple': 'multiple'});

			var statusSelectorLabel = $('<label>', {'class': 'labelCell optional'}).text(options.statusLabel);
			var statusSelector = $('<select>', { 'class': 'statusSelector', 'multiple' : 'multiple' });

			$.fn.fieldConfigurationForm.getProjectsRequest.done( function() {
				initMultiSelect(trackerSelector, options.trackerSelectorDefault);
				initMultiSelect(statusSelector, options.statusSelectorDefault, true);
			});

			projectSelector.on("multiselectclick", function(event, ui) {
				var projectId = this.value;

				var checkedProjects = projectSelector.multiselect("getChecked");

				var projectInfos = [];
				$.each(checkedProjects, function(i, projectCheckbox) {
					var name = $(projectCheckbox).next().html();
					var id = projectCheckbox.value;
					projectInfos.push({projectId: id, projectName: name});
				});

				trackerSelector = getTrackerSelector(trackerSelector, projectInfos, options);
				statusSelector = getStatusSelector(statusSelector, [], options);

				trackerSelector.off("multiselectclick");
				trackerSelector.on("multiselectclick", function(event, ui) {
					var trackerId = this.value;

					var checkedTrackers = trackerSelector.multiselect("getChecked");

					var trackerInfos = [];
					$.each(checkedTrackers, function(i, trackerCheckbox) {
						var name = $(trackerCheckbox).next().html();
						var id = trackerCheckbox.value;
						var projectName = $('option[value="' + id + '"]', trackerSelector).parent().attr('label');
						trackerInfos.push({projectName: projectName, trackerId: id, trackerName: name});
					});

					statusSelector = getStatusSelector(statusSelector, trackerInfos, options);
				});
			});

			var projectSelectorWrapper = $('<div>', {'class': 'labelAndSelectorWrapper'});
			projectSelectorWrapper.append(projectSelectorLabel);
			projectSelectorWrapper.append(projectSelector);
			wrapperDiv.append(projectSelectorWrapper);

			var trackerSelectorWrapper = $('<div>', {'class': 'labelAndSelectorWrapper'});
			trackerSelectorWrapper.append(trackerSelectorLabel);
			trackerSelectorWrapper.append(trackerSelector);
			wrapperDiv.append(trackerSelectorWrapper);

			var statusSelectorWrapper = $('<div>', {'class': 'labelAndSelectorWrapper'});
			statusSelectorWrapper.append(statusSelectorLabel);
			statusSelectorWrapper.append(statusSelector);
			wrapperDiv.append(statusSelectorWrapper);

			return wrapperDiv;
		}

		function init(form, field) {
			if ($.isPlainObject(field)) {
				field = $.extend({}, field);
			} else {
				field = {};
			}

			form.objectInfoBox(field.info, settings);

			var table = $('<table>', { "class" : 'fieldConfiguration formTableWithSpacing' }).data('field', field);
			form.append(table);
/*
			var propRow   = $('<tr>');
			var propLabel = $('<td>', { "class" : 'labelCell optional' }).text(settings.propertyLabel + ':');
			var propCell  = $('<td>', { "class" : 'dataCell' }).text(field.property);

			propRow.append(propLabel);
			propRow.append(propCell);
			table.append(propRow);
*/

			function toggleRefTypeWarning(show, select) {
				var warningDiv = form.find('.refTypeWarning');
				if (select) {
					var selectedOption = select.find(":selected");
					warningDiv.text(i18n.message("tracker.field.refTypeWarning.label", selectedOption.text()));
				}
				show ? warningDiv.show() : warningDiv.hide();
			}

			var addTextWithHint = function(element, text, hint) {
				if (hint.length > 0) {
					var img = $('<img>', { "class": 'labelHintImg', src: "../../images/newskin/action/information-s.png", title: hint});
					img.tooltip({
						tooltipClass: 'tooltip',
						position: {my: "left top+5", collision: "flipfit"}
					});
					element.append(img);
				}
				if (text.length > 0) {
					element.append($('<span></span>').text(text));
				}
			};

			var isChoiceType = field.typeClass == 'choiceTypes';

			var nameRow   = $('<tr>', 	 { title : settings.nameTooltip, style: 'vertical-align: middle;' });
			var nameLabel = $('<td>',	 { "class" : 'labelCell mandatory' }).text(settings.nameLabel + ':');
			var nameCell  = $('<td>', 	 { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
			var name	  = $('<input>', { type : 'text', name : 'label', value : field.label, size : 40, maxlength : 160, disabled : !settings.editable });
			name.attr('autocomplete', 'off');

			if (field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName) {
				name.prop("disabled", true);
			}

			var hideLabel = $('<label>', { title : settings.hiddenTooltip, style: 'margin-left: 2em; vertical-align: middle; white-space: nowrap;' });
			var hidden    = $('<input>', { type : 'checkbox', name : 'hidden', value : 'true', checked : field.hidden });

			hideLabel.append(hidden).append(settings.hiddenLabel);

			nameCell.append(name).append(hideLabel);
			nameRow.append(nameLabel);
			nameRow.append(nameCell);
			table.append(nameRow);

			var typeRow    = $('<tr>', { title : settings.typeTooltip });
			var typeLabel  = $('<td>', { "class" : 'labelCell optional' }).text(settings.typeLabel + ':');
			var typeCell   = $('<td>', { "class" : 'dataCell dataCellContainsSelectbox' });

			var typeSelect = null;
			if (field.typeClass == 'fixedType') {
				typeCell.text(field.typeName);
			} else {
	          	typeSelect = getTypeSelector(field.typeClass, field.type);
				typeCell.append(typeSelect);
			}

			typeRow.append(typeLabel);
			typeRow.append(typeCell);
			table.append(typeRow);

           	if (field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName) {
           		typeRow.find("select").prop("disabled", true);
           	}

			if (!field.neverListable) {
				var titleRow   = $('<tr>', 	  { title : settings.titleTooltip });
				var titleLabel = $('<td>',	  { "class" : 'labelCell optional', style: 'vertical-align: middle; white-space: nowrap;' });
				var titleCell  = $('<td>', 	  { "class" : 'dataCell' });
				var title	   = $('<input>', { type : 'text', name : 'title', value : field.title, size : 40, maxlength : 80, disabled : !settings.editable});
				title.attr('autocomplete', 'off');

				if (field['class'] == 'tableColumn') {
					titleLabel.text(settings.titleLabel + ':');
				} else {
					var listLabel  = $('<label>', { title : settings.listableTooltip, style: 'vertical-align: middle; white-space: nowrap;' }).text(settings.listableLabel);
					var listable   = $('<input>', { type : 'checkbox', name : 'listable', value : 'true', checked : field.listable, style : 'margin: 4px 8px 0px 4px;' });
					listLabel.append(listable);

					titleLabel.append(listLabel).append(settings.titleLabel + ':');
				}

				titleCell.append(title);
				titleRow.append(titleLabel);
				titleRow.append(titleCell);
				table.append(titleRow);
			}

			var descrRow    = $('<tr>',		  { title : settings.descriptionTooltip });
			var descrLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(settings.descriptionLabel + ':');
			var descrCell   = $('<td>', 	  { "class" : 'dataCell expandTextArea' });
			var description = $('<textarea>', { name : 'description', rows : 2, cols : 80, disabled : !settings.editable }).val(field.description || '');

			descrCell.append(description);
			descrRow.append(descrLabel);
			descrRow.append(descrCell);
			table.append(descrRow);

			if (field['class'] == 'table') {
				var requiredRow    = $('<tr>', { style : 'vertical-align: middle !important;' + (field.demandable ? '' : ' display: None;') });
				var requiredLabel  = $('<td>', { "class" : 'labelCell optional', style: 'vertical-align: middle !important; white-space: nowrap;' });
				var requiredCell   = $('<td>', { "class" : 'requiredIn dataCell', style: 'vertical-align: middle; white-space: nowrap;' });

				requiredLabel.text(settings.mandatorySettings.mandatoryLabel + ' ' + settings.mandatorySettings.inStatusLabel + ':');

				var allExcept = $('<span>', { title : settings.mandatorySettings.allExceptTitle, style : 'vertical-align: middle;' });

				var required = $('<input>', { type: 'checkbox', name: 'required', checked: field.required, disabled : !settings.editable });
				required.uniqueId();

				var disableNameEditing = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;
				if (disableNameEditing) {
					required.prop("disabled", true);
				}

				var label = $('<label>', { "for" : required.attr('id'), style : 'color: ' + (field.required ? 'black' : 'lightGray') });
				label.append('<b>' + settings.mandatorySettings.allText + '</b>, ' + settings.mandatorySettings.exceptLabel + ': ');

				if (settings.editable) {
					required.click(function() {
						label.css('color', $(this).is(':checked') ? 'black' : 'lightGray');
					});
				}

				if (settings.editable) {
					required.click(function() {
						label.css('color', $(this).is(':checked') ? 'black' : 'lightGray');
					});
				}

				allExcept.append(required);
				allExcept.append(label);
				requiredCell.append(allExcept);


				var disableMandatoryList = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

	    		requiredCell.fieldMandatoryControl(field.requiredIn, $.extend({}, settings.mandatorySettings, {
	    			editable : settings.editable,
	    			minWidth : 500,
	    			disabled: disableMandatoryList
	    		}));

	       	 	requiredRow.append(requiredLabel);
				requiredRow.append(requiredCell);
				table.append(requiredRow);

				var optionsRow   = $('<tr>');
				var optionsLabel = $('<td>');
				var optionsCell  = $('<td>', { "class" : 'dataCell expandTextArea' });
				var options = $('<table>');

				var numberedRow   = $('<tr>', { title : settings.numberedTitle });
				var numberedLabel = $('<td>', { style : 'vertical-align: middle !important;' }).text(settings.numberedLabel);
				var numberedCell  = $('<td>', { style : "width: 20px;" });
				var numbered      = $('<input>', { type: 'checkbox', name: 'numbered', checked: field.multiple });

				numberedCell.append(numbered);
				numberedRow.append(numberedCell);
				numberedRow.append(numberedLabel);
				options.append(numberedRow);

				var colPermsRow   = $('<tr>', { title : settings.colPermsTitle });
				var colPermsLabel = $('<td>', { style : 'vertical-align: middle !important;' }).text(settings.colPermsLabel);
				var colPermsCell  = $('<td>', { style : "width: 20px;" });
				var colPerms      = $('<input>', { type: 'checkbox', name: 'colPerms', checked: field.width > 1 });

				colPermsCell.append(colPerms);
				colPermsRow.append(colPermsCell);
				colPermsRow.append(colPermsLabel);
				options.append(colPermsRow);

				optionsCell.append(options);
				optionsRow.append(optionsLabel);
				optionsRow.append(optionsCell);
				table.append(optionsRow);

			} else {
				var contentRow    = $('<tr>', { style : (field.formatable || field.multiValue || field.referenceConfig || (field.id != 7 && field.combinable) || field.limitable || field.resizeable /*|| field.demandable*/ ? '' : 'display: None;') });
				var contentLabel  = $('<td>', { "class" : 'labelCell optional', style : 'vertical-align: top; padding-top: 10px;' });
				addTextWithHint(contentLabel, (isChoiceType ? settings.datasourceLabel : settings.layoutLabel) + ':', isChoiceType ? settings.datasourceTooltip : "");
				contentLabel.append('<label style="display: block; margin-top: 12px;" class="suspected-settings-label">' + i18n.message('reference.suspected.setting.title')  + ':</label>');
				var contentCell   = $('<td>', { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
				var contentTableLayout  = $('<table>', { "style" : 'border-collapse: separate;' });
				var makeContentTableLayoutRow = function(){
					var contentRow    = $('<tr>');
					var contentColumn = $('<td>', { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap; padding-left: 0px;' });
					contentRow.append(contentColumn);
					contentTableLayout.append(contentRow);
					return contentColumn;
				};

				var lastRow = makeContentTableLayoutRow();

				var formatted = $('<label>', { title : settings.formattedTitle, style : 'padding-right: 5px;' + (field.formatable ? '' : ' display: None;') });
				formatted.append($('<input>', { type: 'checkbox', name: 'formatted', value: 'true', checked: field.multiple, style: 'margin-right: 5px;' }));
				formatted.append(settings.formattedLabel + ' ');
				lastRow.append(formatted);

				var multiple = $('<label>', { title : settings.multipleTitle, style : 'padding-right: 5px;' + (field.multiValue ? '' : ' display: None;') });
				multiple.append($('<input>', { type: 'checkbox', name: 'multiple', value: 'true', checked: field.multiple, style: 'margin-right: 5px;' }));
				multiple.append(settings.multipleLabel);
				lastRow.append(multiple);

				var showHideAdditionalReferenceField = {
					showHide : function(refValue){

						if (refValue == 9 && field.type == 6 && propagateSuspected != undefined){
                            var $table = propagateSuspected.closest('table.fieldConfiguration');

                            $table.find('label.suspected-settings-label').show();
							propagateSuspected.parent().parent().css('display', 'table-row');
							if (newField === true) {
								quickAddReferringTracker.parent().parent().css('display', 'table-row');
							}
							defaultReferenceVersionType.parent().parent().css('display', 'table-row');
							reversedSuspect.parent().parent().css('display', 'table-row');
							bidirectionalSuspect.parent().parent().css('display', 'table-row');
							propagateDependencies.parent().parent().css('display', 'table-row');
						} else if (propagateSuspected != undefined){
                            var $table = propagateSuspected.closest('table.fieldConfiguration');

                            $table.find('label.suspected-settings-label').hide();
							propagateSuspected.parent().parent().css('display', 'none');
							if (newField === true) {
								quickAddReferringTracker.parent().parent().css('display', 'none');
							}
							defaultReferenceVersionType.parent().parent().css('display', 'none');
							reversedSuspect.parent().parent().css('display', 'none');
							bidirectionalSuspect.parent().parent().css('display', 'none');
							propagateDependencies.parent().parent().css('display', 'none');
						}
					}
				};

				var referenceType = getRefTypeSelector(field.refType);
				var referenceFieldInit;
				if (newField === true) {
					referenceType.change(function() {
						toggleRefTypeWarning($(this).val() != 0, $(this));
						showHideAdditionalReferenceField.showHide($(this).val());
						if ($(this).val() == 9 && field.multiValue){
							$('input[type="checkbox"][name="multiple"]',  table).prop('checked', true);
						}
					});
					referenceFieldInit = function(){
						toggleRefTypeWarning(referenceType.val() != 0, referenceType);
						showHideAdditionalReferenceField.showHide(referenceType.val());
					};
				} else {
					referenceType.change(function() {
						showHideAdditionalReferenceField.showHide($(this).val());
						if ($(this).val() == 9 && field.multiValue){
							$('input[type="checkbox"][name="multiple"]',  table).prop('checked', true);
						}
					});
					referenceFieldInit = function(){
						showHideAdditionalReferenceField.showHide(referenceType.val());
					};
				}
				lastRow.append(referenceType);

				if (!field.referenceConfig) {
					referenceType.hide();
					showHideAdditionalReferenceField.showHide(referenceType.val());
				}

				var memberTypeSpan = null;
				if (field.id == 5 || field.id == 32 || typeSelect != null) {
					memberTypeSpan = $('<span>', { style: 'margin-right: 5px; display: None;' });
					lastRow.append(memberTypeSpan);

					var memberType = getMemberTypeSelector(field.memberType);
					memberTypeSpan.append(memberType);

					memberType.multiselect({
//			    		checkAllText	 : settings.checkAllText,
//			    	 	uncheckAllText	 : settings.unsetLabel,
			    	 	noneSelectedText : settings.membersLabel,
			    	 	autoOpen		 : false,
			    	 	multiple         : true,
			    	 	selectedList	 : 4
			    	});

					if (field.type == 5) {
						memberTypeSpan.show();
					}
				}

				var dependsOn = null;
				if (field.id != 7 && field.id != 88) {
					var unionHint = i18n.message('tracker.field.dependsOn.union.tooltip');
					var matchAny  = $('<input>', {
						type     : 'checkbox',
						name     : 'matchAny',
						checked  : field.matchAny === true,
						disabled : !settings.editable,
						title    : unionHint,
						style    : 'margin-left: 5px;'
					});
					matchAny.uniqueId();

					dependsOn = $('<label>', { style : 'padding-right: 5px;' + (field.combinable ? '' : ' display: None;') }).text(settings.dependsOnLabel);
					dependsOn.append(settings.dependsOnSelector(field));
					dependsOn.append(matchAny);
					dependsOn.append($('<label>', {
						"for" : matchAny.attr('id'),
						title : unionHint
					}).text(i18n.message('tracker.field.dependsOn.union.label')));
					addTextWithHint(dependsOn, "", settings.dependsOnTitle + ' ' + i18n.message('tracker.field.dependsOn.hint'));
					lastRow.append(dependsOn);
				}

				lastRow.parent().css('display', 'none');
				lastRow.children().each(
					function() {
						if ($( this ).css('display') != 'none'){
							lastRow.parent().css('display', 'table-row');
						}
					}
				);

				lastRow = makeContentTableLayoutRow();

				var propagateSettings = $('<div>', { 'class': 'propagation-settings', style: 'margin: 5px 0;' });
				lastRow.append(propagateSettings);
				
				var propagateSuspected = $('<label>', { title : settings.propagateSuspectedTitle, 'class': 'propagateSuspectsContainer' });
				var propagateSuspectedInput = $('<input>', { type: 'checkbox', name: 'propagateSuspected', value: 'true', checked: field.propagateSuspected, style: 'margin-right: 5px;' });
				propagateSuspected.append(propagateSuspectedInput);
				propagateSuspected.append(settings.propagateSuspectedLabel);
				propagateSettings.append(propagateSuspected);

				var propagateOptions = $('<div>', { 'class': 'propagation-options' + (field.propagateSuspected ? '' : ' inactive') });
				propagateSettings.append(propagateOptions);
				
				var reversedSuspect = $('<label>', { title : settings.reversedSuspectTitle, style : 'padding-right: 5px;', 'class' : 'reverseSuspectContainer' });
				var reversedSuspectInput = $('<input>', { type: 'checkbox', name: 'reversedSuspect', value: 'true', checked: field.reversedSuspect, style: 'margin-right: 5px;', disabled: !field.propagateSuspected });
				var bidirectionalSuspect = $('<label>', { title : settings.bidirectionalSuspectTitle, style : 'padding-right: 5px;', 'class': 'bidirectionalSuspectContainer' });
				var bidirectionalSuspectInput = $('<input>', { type: 'checkbox', name: 'bidirectionalSuspect', value: 'true', checked: field.bidirectionalSuspect, style: 'margin-right: 5px;', disabled: !field.propagateSuspected });
				var propagateDependencies = $('<label>', { title : settings.propagateDependenciesTitle, style : 'display: inline-block; padding-right: 5px;' });
				var propagateDependenciesInput = $('<input>', { type: 'checkbox', name: 'propagateDependencies', value: 'true', checked: field.propagateDependencies, style: 'margin-right: 5px;' });
				
				propagateSuspectedInput.click(function(){
					var isChecked = $(this).is(':checked');
					
					if (!isChecked) {
						reversedSuspectInput.prop('checked', false);
						bidirectionalSuspectInput.prop('checked', false);
					}
					reversedSuspectInput.prop('disabled', !isChecked);
					bidirectionalSuspectInput.prop('disabled', !isChecked);
					propagateOptions.toggleClass('inactive', !isChecked);
				});
				reversedSuspectInput.click(function(){
					var $this = $(this);
					if ($this.is(':checked')) {
						bidirectionalSuspectInput.prop('checked', false);
					}
				});
				bidirectionalSuspectInput.click(function(){
					var $this = $(this);
					if ($this.is(':checked')) {
						reversedSuspectInput.prop('checked', false);
					}
				});

				reversedSuspect.append(reversedSuspectInput);
				reversedSuspect.append(settings.reversedSuspectLabel);
				propagateOptions.append(reversedSuspect);
				propagateOptions.append('<br>');
				
				bidirectionalSuspect.append(bidirectionalSuspectInput);
				bidirectionalSuspect.append(settings.bidirectionalSuspectLabel);
				propagateOptions.append(bidirectionalSuspect);
				
				if (!codebeamer.hidePropagateDependenciesOnTrackerLevel) {
					lastRow = makeContentTableLayoutRow();
	
					propagateDependencies.append(propagateDependenciesInput);
					propagateDependencies.append(settings.propagateDependenciesLabel);
					lastRow.append(propagateDependencies);
				}
				
				var quickAddReferringTracker;

				if (newField === true) {
					lastRow = makeContentTableLayoutRow();
					quickAddReferringTracker = getQuickAddReferringTracker(settings.referenceConfigurationSettings);
					lastRow.append(quickAddReferringTracker);
				}

				var getDefaultReferenceVersionTypeSelector = function(field, settings){
					var selector = ($('<select>', { name: 'defaultReferenceVersionType', title: settings.defaultReferenceVersionTypeTitle, style : 'margin-left: 5px; margin-right: 5px;' }));
					selector.append($('<option>', { value: 'NONE', selected: ('NONE' == field.defaultReferenceVersionType) }).text(settings.defaultReferenceVersionTypeNone));
					selector.append($('<option>', { value: 'HEAD', selected: ('HEAD' == field.defaultReferenceVersionType) }).text(settings.defaultReferenceVersionTypeHead));

					return selector;
				};

				lastRow = makeContentTableLayoutRow();

				var defaultReferenceVersionType = $('<label>', { title : settings.defaultReferenceVersionTypeTitle, style : 'padding-right: 5px;' });
				defaultReferenceVersionType.append(settings.defaultReferenceVersionTypeLabel);
				defaultReferenceVersionType.append(getDefaultReferenceVersionTypeSelector(field, settings));
				lastRow.append(defaultReferenceVersionType);

				showHideAdditionalReferenceField.propagateSuspected = propagateSuspected;
				if (newField === true) {
					showHideAdditionalReferenceField.quickAddReferringTracker = quickAddReferringTracker;
				}
				showHideAdditionalReferenceField.defaultReferenceVersionType = defaultReferenceVersionType;
				showHideAdditionalReferenceField.reversedSuspect = reversedSuspect;
				showHideAdditionalReferenceField.bidirectionalSuspect = bidirectionalSuspect;
				showHideAdditionalReferenceField.propagateDependencies = propagateDependencies;

				lastRow = makeContentTableLayoutRow();

				if (!field.limitable && !field.resizeable) {
					lastRow.parent().css('display', 'none');
				}

				var minMax = $('<span>', { style : 'padding-right: 5px;' + (field.limitable ? '' : 'display: None;') });

				minMax.append($('<label>', {title: settings.minValueTitle }).text(settings.minValueLabel + ' '));
				minMax.append($('<input>', {"class" : "numberInputField", type : 'text', name: 'minValue', value: field.minValue, size: 10, maxlength: 255, title: settings.minValueTitle }));
				minMax.append($('<label>', {title: settings.maxValueTitle }).text('  ' + settings.maxValueLabel + ' '));
				minMax.append($('<input>', {"class" : "numberInputField", type : 'text', name: 'maxValue', value: field.maxValue, size: 10, maxlength: 255, title: settings.maxValueTitle }));
				lastRow.append(minMax);

				var size = $('<span>', { style : 'padding-right: 5px;' + (field.resizeable && field.multiLine ? '' : 'display: None;') });
				size.append($('<label>', {title: settings.widthTitle }).text(settings.widthLabel + ' '));
				size.append($('<input>', {"class" : "numberInputField", type: 'number', name: 'width', value: (field.width || field.cols), size: 2, maxlength: 2, title: settings.widthTitle }));
				size.append($('<label>', {title: settings.heightTitle }).text('  ' + settings.heightLabel + ' '));
				size.append($('<input>', {"class" : "numberInputField", type: 'number', name: 'height', value: (field.height || field.rows), size: 2, maxlength: 2, title: settings.heightTitle }));
				lastRow.append(size);

				var length = $('<span>', { style : 'padding-right: 5px;' + (field.resizeable && !field.multiLine ? '' : 'display: None;') });
				length.append($('<label>', {title: settings.lengthTitle }).text(settings.lengthLabel + ' '));
				length.append($('<input>', {"class" : "numberInputField", type: 'number', name: 'length', value: field.width, size: 2, maxlength: 2, title: settings.lengthTitle }));
				lastRow.append(length);

				if (newField === true && field.referenceConfig) {
					lastRow = makeContentTableLayoutRow();
					var warningSpan = $('<span class="refTypeWarning warning"></span>');
					lastRow.append(warningSpan);
				}
				contentCell.append(contentTableLayout);
				contentRow.append(contentLabel);
				contentRow.append(contentCell);
				table.append(contentRow);

				referenceFieldInit();

				var omitSuspectedChangeRow    = $('<tr>',		  { title : settings.omitSuspectedChangeTitle });
				var omitSuspectedChangeLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(settings.omitSuspectedChangeLabel + ':');
				var omitSuspectedChangeCell   = $('<td>', 	  { "class" : 'dataCell' });
				var omitSuspectedChange = $('<input>', { id: 'omitSuspectedChangeCheckbox', type: 'checkbox', name: 'omitSuspectedChange', value: 'true', checked: field.omitSuspectedChange, style: 'margin-right: 5px;' });
				var omitSuspectedChangeAfterLabel   = $('<label>', { 'for': 'omitSuspectedChangeCheckbox' }).text(settings.omitSuspectedChangeAfterLabel);
				omitSuspectedChangeCell.append(omitSuspectedChange);
				omitSuspectedChangeCell.append(omitSuspectedChangeAfterLabel);
				omitSuspectedChangeRow.append(omitSuspectedChangeLabel);
				omitSuspectedChangeRow.append(omitSuspectedChangeCell);

				table.append(omitSuspectedChangeRow);

				var omitMergeRow    = $('<tr>',		  { title : i18n.message('tracker.field.omitMerge.tooltip') });
				var omitMergeLabel  = $('<td>', 	  { "class" : 'labelCell optional' }).text(i18n.message('tracker.field.omitMerge.label') + ':');
				var omitMergeCell   = $('<td>', 	  { "class" : 'dataCell' });
				var omitMerge = $('<input>', { id: 'omitMergeCheckbox', type: 'checkbox', name: 'omitMerge', value: 'true', checked: field.omitMerge, style: 'margin-right: 5px;' });
				var omitMergeAfterLabel   = $('<label>', { 'for': 'omitMergeCheckbox' }).text(settings.omitSuspectedChangeAfterLabel);

				omitMergeCell.append(omitMerge);
				omitMergeCell.append(omitMergeAfterLabel);
				omitMergeRow.append(omitMergeLabel);
				omitMergeRow.append(omitMergeCell);

				table.append(omitMergeRow);

				var formulaRow    = $('<tr>', { title : settings.formulaTitle, style : field.computable ? '' : 'display: None;' });
				var formulaLabel  = $('<td>', { "class" : 'labelCell optional' }).text(settings.formulaLabel + ':');
				var formulaCell   = $('<td>', { "class" : 'formula dataCell expandTextArea' });
				var formula       = $('<textarea>', { name : 'formula', width : 500, height : 100, rows : 3, cols : 100, disabled : !settings.editable }).val(field.formula || '');

				formulaCell.append(formula);
				formulaRow.append(formulaLabel);
				formulaRow.append(formulaCell);
				table.append(formulaRow);

				formula.resizable({
					handles: "se"
			    });

				var disableNameEditing = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;
				// Disable Layout and Content / Datasource if field is a built in reference field
				if (disableNameEditing) {
					contentRow.find("input, select").prop("disabled", "disabled");
					contentRow.find("label").css("color", "lightGray");
					formulaRow.find("textarea").prop("disabled", "disabled");
				}

				var requiredRow    = $('<tr>', { style : 'vertical-align: middle !important;' + (field.demandable ? '' : ' display: None;') });
				var requiredLabel  = $('<td>', { "class" : 'labelCell optional', style: 'vertical-align: middle !important; white-space: nowrap;' });
				var requiredCell   = $('<td>', { "class" : 'requiredIn dataCell', style: 'vertical-align: middle; white-space: nowrap;' });

				requiredLabel.text(settings.mandatorySettings.mandatoryLabel + ' ' + settings.mandatorySettings.inStatusLabel + ':');

				var allExcept = $('<span>', { title : settings.mandatorySettings.allExceptTitle });

				var required = $('<input>', { type: 'checkbox', name: 'required', checked: field.required, disabled : !settings.editable });
				required.uniqueId();

				if (disableNameEditing) {
					required.prop("disabled", true);
				}

				var label = $('<label>', { "for" : required.attr('id'), style : 'color: ' + (field.required ? 'black' : 'lightGray') });
				label.append('<b>' + settings.mandatorySettings.allText + '</b>, ' + settings.mandatorySettings.exceptLabel + ': ');

				if (settings.editable) {
					required.click(function() {
						label.css('color', $(this).is(':checked') ? 'black' : 'lightGray');
					});
				}

				allExcept.append(required);
				allExcept.append(label);
				requiredCell.append(allExcept);

				var disableMandatoryList = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

	    		requiredCell.fieldMandatoryControl(field.requiredIn, $.extend({}, settings.mandatorySettings, {
	    			editable : settings.editable,
	    			minWidth : 500,
	    			disabled: disableMandatoryList
	    		}));

	       	 	requiredRow.append(requiredLabel);
				requiredRow.append(requiredCell);
				table.append(requiredRow);
			
				if (settings.editable && typeSelect != null) {
					var origType = typeSelect.val();
					var changeType = function(type) {
	    	        	setTypeOfField(field, type);

		           		if (field.computable) {
		           			formulaRow.show();
		           		} else {
		           			formulaRow.hide();
		           		}

		           		if (field.formatable || field.multiValue || field.referenceConfig || (field.id != 7 && field.combinable) || field.limitable || field.resizeable /*|| field.demandable*/) {
			          		contentRow.show();

			           		if (field.formatable) {
			           			formatted.show();
			           			multiple.hide();
			           		} else if (field.multiValue) {
			           			formatted.hide();
			           			multiple.show();
			           		} else {
			           			formatted.hide();
			          			multiple.hide();
			            	}

			    			if (field.referenceConfig) {
			    				referenceType.show();
								referenceFieldInit();
			    			} else {
								toggleRefTypeWarning(false);
			    				referenceType.hide();
			    			}

			    			if (memberTypeSpan) {
								if (field.type == 5) {
									memberTypeSpan.show();
									showHideAdditionalReferenceField.showHide(referenceType.val());
								} else {
									memberTypeSpan.hide();
								}
			    			}

			    			if (dependsOn) {
			               		if (field.combinable) {
			               			dependsOn.show();
			               		} else {
			               			dependsOn.hide();
			               		}
			    			}

			    			if (field.resizeable) {
			    				if (field.multiLine) {
			    					size.show();
			    					length.hide();
			    				} else {
			    					size.hide();
			    					length.show();
			    				}
			    			} else {
		    					size.hide();
		    					length.hide();
			    			}

			    			if (field.limitable) {
			    				minMax.show();
			    			} else {
			    				minMax.hide();
			    			}

	//		    			if (field.demandable) {
	//		    				initial.show();
	//		    			} else {
	//		    				initial.hide();
	//		    			}
			          	} else {
			          		contentRow.hide();
			          	}

		    			if (field.demandable) {
		    				requiredRow.show();
		    			} else {
		    				requiredRow.hide();
		    			}
					};

		          	typeSelect.change(function() {
		          		var type = parseInt(this.value);

		          		if (field.label) {
	    	        		var allowedFieldType = allowedFieldTypeChanges[field.type];

	    					// TASK-922296: Allow restricted field type changes
	    					if (allowedFieldType == type) {
	    						showFancyAlertDialog(i18n.message('tracker.field.valueType.change.warning'));
	    						changeType(type);
	    					} else {
	    						var infoMessage = '';

	    						if (typeof allowedFieldType !== 'undefined') {
	    							infoMessage = '<br/><br/>' + i18n.message('tracker.field.valueType.immutable.info', settings.typeName[allowedFieldType]);
	    						}

	    						showFancyAlertDialog(settings.typeImmutable + infoMessage);
	    						typeSelect.val(origType);
	    					}
		          		} else {
		          			changeType(type);
		          		}
		           	});
				} else if (field.id == 88) {
	          		contentRow.hide();
				}
			}

			if (settings.serviceDeskEnabled) {
				var deskLabelRow    = $('<tr>',		  { title : i18n.message("tracker.serviceDesk.field.config.label.tooltip"), "class": "service-desk-row" });
				var deskLabelLabel  = $('<td>', { "class" : 'labelCell optional', style: 'vertical-align: middle !important; white-space: nowrap;' });
				deskLabelLabel.text(i18n.message("tracker.serviceDesk.field.config.label.label") + ":");
				var deskLabelCell   = $('<td>', { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
				var deskLabel	  = $('<input>', { type : 'text', name : 'serviceDeskLabel', value : field.label, size : 40, maxlength : 160, disabled : !settings.editable }).val(field.serviceDeskLabel || '');
				deskLabel.attr('autocomplete', 'off');

				deskLabelCell.append(deskLabel);
				deskLabelRow.append(deskLabelLabel);
				deskLabelRow.append(deskLabelCell);
				table.append(deskLabelRow);

				var deskDescriptionRow = $('<tr>',		  { title : i18n.message("tracker.serviceDesk.field.config.description.tooltip"), "class": "service-desk-row" });
				var deskDescriptionLabel = $('<td>', { "class" : 'labelCell optional', style: 'vertical-align: middle !important; white-space: normal;' });
				deskDescriptionLabel.text(i18n.message("tracker.serviceDesk.field.config.description.label") + ":");
				var deskDescriptionCell = $('<td>', { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;' });
				var deskDescription = $('<textarea>', { name : 'serviceDeskDescription', rows : 2, cols : 80, disabled : !settings.editable }).val(field.serviceDeskDescription || '');
				deskDescriptionCell.append(deskDescription);
				deskDescriptionRow.append(deskDescriptionLabel);
				deskDescriptionRow.append(deskDescriptionCell);
				table.append(deskDescriptionRow);
			}
		}

		return this.each(function() {
			init($(this), field);
		});

		var DEFAULT_TRUNCATE_CHARS = 60;
	};

	function getSelectedTrackerReference(context, options) {

		var result = null;

		var projectSelector = $('select.projectSelector', context);
		var trackerSelector = $('select.trackerSelector', context);
		var statusSelector = $('select.statusSelector', context);

	//	var warningMessage = projectId == '0' ? options.selectAProjectWarning : trackerId == '0' ? options.selectATrackerWarning : null;
	//	if( warningMessage != null ) {
	//	showFancyAlertDialog(warningMessage/*i18n.message("")*/);
	//	return null;
	//	}

		var selectedProjects = projectSelector.multiselect("getChecked");

		var trackerIds = [];
		var selectedTrackers = trackerSelector.multiselect("getChecked");
		$.each(selectedTrackers, function(i, trackerCheckbox) {
			trackerIds.push(trackerCheckbox.value);
		});

		var statusIdsWithNames = [];
		var selectedStatuses = statusSelector.multiselect("getChecked");
		$.each(selectedStatuses, function(i, statusCheckbox) {
			var valueComponents = statusCheckbox.value.split(" ");
			var statusName = $(statusCheckbox).next().html();
			statusIdsWithNames.push({statusId: valueComponents[0], trackerId: valueComponents[1], name: statusName});
		});

		if( selectedProjects != null && selectedProjects.length > 0 ) {
			result = [];

			$.each(selectedProjects, function(i, projectCheckbox) {
				var projectId = projectCheckbox.value;
				var projectName = $(projectCheckbox).next().html();

				// the explicitly selectable trackers
				var explicitly = $.fn.fieldConfigurationForm.currentTrackers[projectId];

				// add the branches to the explicitly selectable tracker list so that after the validation the selected branches are kept
				if (explicitly) {
					explicitly = [].concat(explicitly);

					for (var i = 0; i < explicitly.length; i++) {
						var withbranches = [];
						for (var j = 0; j < explicitly[i].trackers.length; j++) {
							var tracker = explicitly[i].trackers[j];

							withbranches.push(tracker);

							if (tracker['branchList']) {
								withbranches = withbranches.concat(tracker.branchList);
							}
						}

						explicitly[i].trackers = withbranches;
					}
				}

				var project = {
					id: projectId,
					name: projectName,
					types: [],
					permissions: [],
					flags: null,
					explicitly: explicitly
				}


				for(var it = 0; it < trackerIds.length; it++ ) {
					var trackerId = trackerIds[it];
					// find the tracker and set as selected with the given status
					$.each(project.explicitly, function(i, selectedItems) {
						$.each(selectedItems.trackers, function(j, tracker) {
							if( tracker.id == trackerId ) {
								tracker.selected = true;
								// get the selected status
								var statusId, statusName;
								$.each(statusIdsWithNames, function(k, statusIdWName) {
									if( statusIdWName.trackerId == tracker.id ) {
										statusId = statusIdWName.statusId;
										statusName = statusIdWName.name;
									}
								});
								tracker.filter = {
									id: statusId,
									name: statusName
								};
							}
						});
					});
				}

				result.push(project);
			});
		}

		return result;
	}

	// Get the field configuration from a configuration form
	$.fn.getFieldConfiguration = function(options, newField) {
		var table  = $('table.fieldConfiguration', this);
		var field  = table.data('field');
		var result = $.extend( {}, field, {
			label       : $.trim($('input[name="label"]',   table).val()),
			description : $.trim($('textarea[name="description"]', table).val()),
			listable    : field['class'] == 'tableColumn' ? true : (field.neverListable ? false : $('input[type="checkbox"][name="listable"]', table).is(':checked')),
			title       : field.neverListable ? null : $.trim($('input[name="title"]', table).val()),
			hidden      : $('input[type="checkbox"][name="hidden"]', table).is(':checked')
		});

		if (field.typeClass != 'fixedType') {
			result.type = parseInt($('select[name="type"]', table).val());
		}

		if (field['class'] == 'table') {
			result.multiple   = $('input[type="checkbox"][name="numbered"]', table).is(':checked');
			result.width      = $('input[type="checkbox"][name="colPerms"]', table).is(':checked') ? 2 : 0;
			result.required   = $('input[type="checkbox"][name="required"]', table).is(':checked');
			result.requiredIn = $('td.requiredIn', table).getFieldRequiredIn();

		} else if (field.id != 88) {
			result.formula 	  = field.computable ? $.trim($('textarea[name="formula"]', table).val()) : null;

			result.multiple   = field.formatable ? $('input[type="checkbox"][name="formatted"]', table).is(':checked') :
						        field.multiValue ? $('input[type="checkbox"][name="multiple"]',  table).is(':checked') : null;

			result.refType    = field.referenceConfig ? parseInt($('select[name="refType"]', table).val()) : 0;

			result.dependsOn  = field.id != 7 && field.combinable ? parseInt($('select[name="dependsOn"]', table).val()) : -1;
			result.matchAny   = result.dependsOn > 0 && $('input[type="checkbox"][name="matchAny"]', table).is(':checked');

			result.propagateSuspected  = result.refType == 9 ? $('input[type="checkbox"][name="propagateSuspected"]',  table).is(':checked') : null;

			if( newField === true ) {
				result.referenceFilters = getSelectedTrackerReference(table, options);
			}

			result.reversedSuspect  = result.refType == 9 ? $('input[type="checkbox"][name="reversedSuspect"]',  table).is(':checked') : null;
			result.bidirectionalSuspect  = result.refType == 9 ? $('input[type="checkbox"][name="bidirectionalSuspect"]',  table).is(':checked') : null;
			result.propagateDependencies  = result.refType == 9 ? $('input[type="checkbox"][name="propagateDependencies"]',  table).is(':checked') : null;
			result.defaultReferenceVersionType  = result.refType == 9 ? $('select[name="defaultReferenceVersionType"]',  table).val() : null;

            result.omitSuspectedChange = $('input[type="checkbox"][name="omitSuspectedChange"]',  table).is(':checked');

            result.omitMerge = $('input[type="checkbox"][name="omitMerge"]',  table).is(':checked');
            
			result.minValue   = field.limitable ? $.trim($('input[name="minValue"]', table).val()) : null;
			result.maxValue   = field.limitable ? $.trim($('input[name="maxValue"]', table).val()) : null;

			result.width      = field.resizeable ? parseInt($('input[type="number"][name="' + (field.multiLine ? 'width' : 'length') +'"]', table).val()) : null;
			result.height	  = field.resizeable && field.multiLine ? parseInt($('input[type="number"][name="height"]', table).val()) : null;

			result.required   = field.demandable ? $('input[type="checkbox"][name="required"]', table).is(':checked') : null;
			result.requiredIn = field.demandable ? $('td.requiredIn', table).getFieldRequiredIn() : null;

			if (result.type == 5) {
				var memberTypeSelector = $('select[name="memberType"]', table);
				if (memberTypeSelector.length > 0) {
					var selectedTypes = memberTypeSelector.multiselect("getChecked");
					if (selectedTypes && selectedTypes.length > 0) {
						var memberType = 0;
						for (var i = 0; i < selectedTypes.length; ++i) {
							memberType += parseInt(selectedTypes[i].value);
						}
						result.memberType = memberType;
					} else {
						delete result.memberType;
					}
				}
			}

//		    result.statusSpecific = field.demandable ? field.statusSpecific : null;
		}
		if ($('input[name="serviceDeskLabel"]').size() > 0) {
			result.serviceDeskLabel = $('input[name="serviceDeskLabel"]').val();
			result.serviceDeskDescription = $('textarea[name="serviceDeskDescription"]').val();
		}

		return result;
	};


	// Another plugin to edit the configuration of a field in a popup dialog
	$.fn.showFieldConfigurationDialog = function(field, config, newField, dialog, callback) {
		var settings = $.extend( {}, $.fn.showFieldConfigurationDialog.defaults, dialog );
		var popup    = this;

		popup.fieldConfigurationForm(field, config, newField);

		if (config.editable && typeof(callback) == 'function') {
			settings.buttons = [
			   { text : config.submitText,
				 click: function() {
						 	var result = callback(popup.getFieldConfiguration(settings.referenceConfigurationSettings, newField));
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

		// Add info link if choice field
		if (field.typeClass == "choiceTypes") {
			settings.open = function(event, ui) {
				if (config.infoLinkUrl !== null) {
					var buttonCont = $(this).parent().find(".ui-dialog-buttonset");
					var infoLink = $('<span>', { "class" : "infoLink"});
					infoLink.append($('<a href="' + config.infoLinkUrl + '" target="_blank">' + i18n.message('tracker.field.customize.infoLink.label') + '</a>'));
					buttonCont.append(infoLink);
				}
			};
		}

		popup.dialog(settings);
	};

	$.fn.showFieldConfigurationDialog.defaults = {
		dialogClass		: 'popup',
		width			: 940,
		draggable		: true,
		appendTo		: "body"
	};


	// Tracker Field Configuration Plugin definition.
	$.fn.trackerFieldsConfiguration = function(fields, options) {
		var settings = $.extend( {}, $.fn.trackerFieldsConfiguration.defaults, options );


		function getSetting(name) {
			return settings[name];
		}

		function setSetting(name, value) {
			settings[name] = value;
		}

		function getTypeSelector(typeClass, type) {
			var types    = settings.typeClasses[typeClass];
			var selector = $('<select>');

			for (var i = 0; i < types.length; ++i) {
			     selector.append($('<option>', {value: types[i], selected: (type == types[i])}).text(settings.typeName[types[i]]));
			};

			return selector;
		}

		function findField(predicate) {
			var result = null;

			$('> tbody', settings.fields).each(function() {
				var fldtr = $('tr:first', this);
				var field = fldtr.data('field');

				if (predicate.apply(fldtr, [field])) {
					result = field;
					return false;
				}

				$('tr.tableColumn', this).each(function() {
					var colrow = $(this);
					var column = colrow.data('field');

					if (predicate.apply(colrow, [column])) {
						result = column;
						return false;
					}
				});

				return (result == null);
			});

			return result;
		}

		function findFieldById(id) {
			if (id != null) {
				if (!(typeof id === 'number')) {
					id = parseInt($.trim(id.toString()));
				}

				return findField(function(field) {
					return field.id == id;
				});
			}
			return null;
		}

		function getMemberFields() {
			var memberFields = [];

			findField(function(field) {
				if (field.type == 5 && field.id != 75 && field.id != 83) {
					memberFields.push(field);
				}
			});

			return memberFields;
		}

		function doInDependendFields(fieldId, action) {
			findField(function(field) {
				if (field.dependsOn == fieldId) {
					action.apply(this, field);

					doInDependendFields(field.id, action);
				}
			});
		}

		function isValueSelected(value, selected) {
			if ($.isArray(selected)) {
				for (var i = 0; i < selected.length; ++i) {
					if (value == selected[i]) {
						return true;
					}
				}
			}
			return false;
		}

		function showChoiceOptions(link, field, cell, withAutoSave) {
			var popup = $('#field_' + field.id + '_optionDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_optionDialog', style : 'display: none;' });
				cell.append(popup);
			}
			settings.choiceOptionSettings["withAutoSave"] = !!withAutoSave;
			popup.showChoiceOptionsDialog(field.id, settings.choiceOptionSettings, {
				title			: (field.displayLabel || field.label) + ' ' + $(link).text(),
				appendTo		: "body",
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: settings.editable,
				closeOnEscape	: !settings.editable

			}, function(options) {
				field.options = options;

				// Destroy all combinationDialogs of other fields depending on this field, in order to force rebuilding option selectors
				doInDependendFields(field.id, function(dependendField) {
					if (dependendField){
						$('#field_' + dependendField.id + '_combinationsDialog').remove();
					}
				});
			});
			return false;
		}

		function getOptions(fieldId) {
			var field = findFieldById(fieldId);
			if (field) {
				if (!field.options) {
		        	// Get field options from server
		 	        $.ajax(settings.fieldOptionsUrl, {type: 'GET', data: {fieldId: fieldId}, dataType: 'json', async: false, cache: false}).done(function(options) {
		 	        	field.options = options;
		 	    	}).fail(function(jqXHR, textStatus, errorThrown) {
		 	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		 	    	});
				}

				return field.options;
			}

			return [];
		}

		function getStatusOptions() {
			return getOptions(7);
		}

		function getOptionsSelector(name, special, options, selected, multiple, disabled) {
			var stringcmp = false;
			if (typeof selected === 'string') {
				selected = selected.split(',');
				stringcmp = true;
			}

			var selector = $('<select>', { name : name, multiple : multiple, disabled : disabled });
			if (special != null && special.length > 0) {
				for (var i = 0; i < special.length; ++i) {
					selector.append($('<option>', { value : special[i].value, selected : isValueSelected(special[i].value, selected) }).text(special[i].label));
				}
			}

			if (options != null && options.length > 0) {
				for (var i = 0; i < options.length; ++i) {
					selector.append($('<option>', { value : options[i].id, title : options[i].description, selected : isValueSelected(stringcmp ? options[i].id.toString() : options[i].id, selected) }).text(options[i].name));
				}
			}

			return selector;
		}

		function showReferenceConfig(link, field, cell) {
			var popup = $('#field_' + field.id + '_refConfigDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_refConfigDialog', "data-type" : field.refType, style : 'display: None;' });
				cell.append(popup);

				popup.showReferenceFieldConfiguationDialog(field.id, field.refType, field.referenceFilters, settings.referenceConfigurationSettings, {
					title			: (field.displayLabel || field.label) + ' ' + $(link).text(),
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: settings.editable,
					closeOnEscape	: !settings.editable
				}, function(configuration) {
					field.referenceFilters = configuration;
					// update external project badge counter
					var externalProjectCountBadge = $("div.externalProjectCountBadge", cell);
					var externalProjectCount = $('label', externalProjectCountBadge);
					fillExternalProjectCountBadge(field, externalProjectCountBadge, externalProjectCount);
				});
			} else {
				popup.dialog("open");
			}

			return false;
		}

		function showConfigDialog(withAutoSave) {
			var link  = this;
			var cell  = $(link).closest('td');
			var field = cell.closest('tr').data('field');

			if (field.refType && field.refType > 0) {
				return showReferenceConfig(link, field, cell);
			}

			return showChoiceOptions(link, field, cell, withAutoSave);
		}

		function showMandatoryControl() {
			var link  = this;
			var cell  = $(link).closest('td');
			var field = cell.closest('tr').data('field');

			var popup = $('#field_' + field.id + '_mandatoryDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_mandatoryDialog', "class" : 'mandatoryDialog', style : 'display: None;' });
				cell.append(popup);

				var disablePermissionEditing = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

				popup.showFieldMandatoryDialog(field.required, field.requiredIn, $.extend(settings.mandatorySettings, {disabled: disablePermissionEditing}), {
					title			: (field.displayLabel || field.label) + ' - ' + settings.mandatorySettings.mandatoryLabel + ' ' + settings.mandatorySettings.inStatusLabel,
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: settings.editable,
					closeOnEscape	: !settings.editable

				}, function(required, inStatus) {
					field.required   = required;
					field.requiredIn = inStatus;

					showLayoutAndContent(cell, field);
				});

			} else {
				popup.dialog("open");
			}
			return false;
		}

		function showStatusSpecificValues() {
			var link  = this;
			var cell  = $(link).closest('td');
			var field = cell.closest('tr').data('field');

			var popup = $('#field_' + field.id + '_defaultValuesDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_defaultValuesDialog', "class" : 'defaultValuesDialog', style : 'display: None;' });
				cell.append(popup);

				var restrictable = (field.id != 7 && (field.type >= 5 && field.type <= 9));

				popup.showFieldDefaultValuesDialog($.extend({}, field, { trackerId : settings.trackerId, editable : settings.editable }), field.statusSpecific, settings.defaultValueSettings, {
					title			: (field.displayLabel || field.label) + ' - ' + (restrictable ? settings.defaultValueSettings.linkLabel : settings.defaultValueSettings.defaultValueLabel),
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: settings.editable,
					closeOnEscape	: !settings.editable

				}, function(result) {
					field.statusSpecific = result;
					showLayoutAndContent(cell, field);
				});
			} else {
				popup.dialog("open");
			}
			return false;
		}

		function getFieldEditor(editorName, field, special, value) {
			var editor = null;

			if (field.type == 0 || field.type == 10) { // (wiki)text
				var width  = field.width || (field.id == 80 ? 80 : 20);
				var height = field.height > 1 ? field.height : (field.id == 80 || field.type == 10 ? 2 : 1);

				if (height > 1) {
					editor = $('<textarea>', { name : editorName, rows : height, cols : width, disabled : (field.editable == false) });
					if (value != null && value.length > 0) {
						editor.val(value);
					}
				} else {
					editor = $('<input>', { type : 'text', name : editorName, size : width, value : value, disabled : (field.editable == false)});
				}
			} else if (field.type == 1 || field.type == 2) { //integer/float
				var width = parseInt(field.width);
				if (!(width && !isNaN(width))) {
					width = (field.type == 1 ? 10 : 15);
				}
				editor = $('<input>', { type : 'text', name : editorName, size : width,  maxlength : (field.maxValue ? field.maxValue.length : 20), value : value, disabled : (field.editable == false)});

				if (!isNaN(parseFloat(field.minValue))) {
					editor.attr('min', field.minValue);
				}
				if (!isNaN(parseFloat(field.maxValue))) {
					editor.attr('max', field.maxValue);
				}
			} else if (field.type == 3) { // date
				if (!$.isArray(special)) {
					special = [];
				}
				special.push.apply(special, settings.dateOptions);

				editor = getOptionsSelector(editorName, special, null, value, false, field.editable == false);

			} else if (field.type == 11) { // duration
				editor = $('<input>', { type : 'text', name : editorName, size : 20, maxlength : 20, value : value});
			} else if (field.type == 4) { // boolean
				if (!$.isArray(special)) {
					special = [];
				}
				special.push({value: 'true',  label: settings.trueValueText  });
				special.push({value: 'false', label: settings.falseValueText });

				editor = getOptionsSelector(editorName, special, null, value, field.multiple, field.editable == false);

			} else if (field.type == 8) { // language
				if (!$.isArray(special)) {
					special = [];
				}
				special.push.apply(special, settings.languageOptions);

				editor = getOptionsSelector(editorName, special, null, value, field.multiple, field.editable == false);

			} else if (field.type == 9) { // country
				if (!$.isArray(special)) {
					special = [];
				}
				special.push.apply(special, settings.countryOptions);

				editor = getOptionsSelector(editorName, special, null, value, field.multiple, field.editable == false);

			} else if (field.type == 5) { // member/principal
			} else if (field.type == 6 || // custom choice
					   field.type == 7) { // reference
				var refType = field.refType;
				if (!refType || isNaN(refType) || refType == 0) { // fix choice
					editor = getOptionsSelector(editorName, special, getOptions(field.id), value, field.multiple, field.editable == false);
				}
			}

			return editor;
		}

		function getDependsOnSelector(field) {
			var table = getTableId(field.id);

			var selector = ($('<select>', { name: 'dependsOn', title: settings.dependsOnTitle, style : 'margin-left: 5px;' }));
		    selector.append($('<option>', { value: -1 }).text('--'));

		    findField(function(other) {
				var tid = getTableId(other.id);

		    	if (other.id != field.id && other.combinable && (tid == -1 || tid == table)) {
		    		var stack  = [field.id];
					var cyclic = false;

					for (var check = other; check && check.dependsOn; check = findFieldById(check.dependsOn)) {
						if ($.inArray(check.dependsOn, stack) == -1) {
							stack.push(check.dependsOn);
						} else {
							cyclic = true;
							break;
						}
					}

					if (!cyclic) {
					    selector.append($('<option>', { value: other.id, selected: (other.id == field.dependsOn) }).text(other.displayLabel || other.label));
					}
		    	}
		    });

			return selector;
		}

		function getCombined(field) {
			var stack  = [];
			var result = [];

			for (var combined = field; combined && combined.id && $.inArray(combined.id, stack) == -1; combined = findFieldById(combined.dependsOn)) {
				stack.push(combined.id);
				result.push(combined);
			}
			return result.reverse();
		}

		function showValueCombinations() {
			var link     = this;
			var cell     = $(link).closest('td');
			var row      = cell.closest('tr');
			var field    = row.data('field');
			var combined = getCombined(field);

			var popup = $('#field_' + field.id + '_combinationsDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_combinationsDialog', "class" : 'combinationsDialog', style : 'display: None;' });
				cell.append(popup);

				popup.showFieldValueCombinationsDialog(combined, field.combinations, settings.combinationSettings, {
					title			: $.map(combined, function(fld) { return fld.displayLabel || fld.label; }).join(' / ') + ' ' + getSetting('combinationsTitle'),
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: settings.editable,
					closeOnEscape	: !settings.editable

				}, function(result) {
					field.combinations = result;
				});
			} else {
				popup.dialog("open");
			}
			return false;
		}

		function showCommentVisibility() {
			var link     = this;
			var cell     = $(link).closest('td');
			var row      = cell.closest('tr');
			var field    = row.data('field');
			var combined = [{
				id         : 6, // SubmittedBy = Role of comment submitter
				label      : getSetting('roleLabel'),
				type       : 5,
				memberType : 8,
				multiple   : true
			}, {
				id         : 5, // Assigned to = Allowed visibility
				label      : getSetting('defaultValueSettings').allowedValuesLabel,
				type       : 5,
				memberType : 24,
				multiple   : true
			}, {
				id         : field.id, // Comments/Attachments default visibility
				label      : getSetting('defaultValueSettings').defaultValueLabel,
				type       : 5,
				memberType : 24,
				multiple   : false
			}];

			var popup = $('#field_' + field.id + '_combinationsDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_combinationsDialog', "class" : 'combinationsDialog', style : 'display: None;' });
				cell.append(popup);
				var commentVisibilitySettings = $.extend({}, settings.combinationSettings, {
					addText: i18n.message('comment.visibility.default.more'),
					moreTooltip: i18n.message('comment.visibility.default.tooltip'),
					removeConfirm: i18n.message('comment.visibility.remove.confirm'),
					isCommentVisibility: true
				});
				
				popup.showFieldValueCombinationsDialog(combined, field.combinations, $.extend({}, commentVisibilitySettings, {
					noneText  		: getSetting('visibilityNone'),
					moreText		: getSetting('visibilityMore')
				}), {
					title			: getSetting('visibilityTitle'),
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: settings.editable,
					closeOnEscape	: !settings.editable

				}, function(result) {
					field.combinations = result;
				});
			} else {
				popup.dialog("open");
			}

			return false;
		}

		function getSameAccessAsSelector(field) {
			var selector = ($('<select>', { "class" : 'sameAccessAs', title: settings.accessPermissionSettings.accessControlTypes[3].title, style : 'margin-left: 5px;' }));

		    findField(function(other) {
		    	if (other.id != field.id && other.id != 88) {
					var stack  = [field.id];
					var cyclic = false;

					for (var check = other; check && check.accessSameAs && check.accessSameAs.id >= 0; check = findFieldById(check.accessSameAs.id)) {
						if ($.inArray(check.accessSameAs.id, stack) == -1) {
							stack.push(check.accessSameAs.id);
						} else {
							cyclic = true;
							break;
						}
					}

					if (!cyclic) {
					    selector.append($('<option>', { value: other.id, selected: (field.accessSameAs && other.id == field.accessSameAs.id) }).text(other.displayLabel || other.label).data('field', other));
					}
		    	}
		    });

		    if (!settings.editable) {
		    	selector.prop("disabled", true);
		    }

			return selector;
		}

		function showAccessPermissions() {
			var link  = this;
			var cell  = $(link).closest('td');
			var row   = cell.closest('tr');
			var field = row.data('field');

			var popup = $('#field_' + field.id + '_accessPermissionsDialog');
			if (popup.length == 0) {
				popup = $('<div>', { id : 'field_' + field.id + '_accessPermissionsDialog', "class" : 'accessPermissionsDialog', style : 'display: None;' });
				cell.append(popup);

				var sameAsSelector = function() {
					return getSameAccessAsSelector(field);
				};

				var disablePermissionEditing = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

				var permissionEditable = field.editableAtAll && !disablePermissionEditing;

				var accessPermSettings = $.extend(settings.accessPermissionSettings, {
					editable: settings.accessPermissionSettings.editable && !disablePermissionEditing
				});

				var editable = settings.editable || settings.branchDisabledAdminRights;
				popup.showAccessPermissionsDialog(field.accessCtrl, field.accessPerms, sameAsSelector, permissionEditable, accessPermSettings, {
					title			: (field.displayLabel || field.label) + ' - ' + settings.permissionsTitle,
					appendTo		: "body",
					position		: { my: "center", at: "center", of: window, collision: 'fit' },
					modal			: editable,
					editable		: editable && !disablePermissionEditing,
					closeOnEscape	: !settings.editable,
					submitText		: settings.submitText,
					cancelText		: settings.cancelText

				}, function(accessMode, accessPerms, accessSameAs) {
					field.accessCtrl  = accessMode;
					field.accessPerms = accessPerms;
					field.accessSameAs = accessSameAs;

					showAccessControl(cell, field);
				});
			} else {
				popup.dialog("open");
			}
			return false;
		}

		function editFieldConfiguration(anchor, title, field, callback, newField) {
			var popup = $('#field_' + field.id + '_editorDialog');
  			if (popup.length == 0) {
  				popup = $('<div>', { id : 'field_' + field.id + '_editorDialog', "class" : 'editorPopup', style : 'display: None;'} );
  				popup.insertAfter(settings.fields);
  			} else {
  				popup.empty();
  			}

  			popup.showFieldConfigurationDialog(field, settings, newField, {
				title			: title,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false

  			}, function(edited) {
  				var valid = true;

  				$.ajax(settings.fieldValidationUrl, {
  					type		: 'POST',
  					async		: false,
  					data 		: JSON.stringify(edited),
  					contentType : 'application/json',
  					dataType 	: 'json'

  				}).done(function(result) {
   					edited.name         = result.name;
  					edited.label 		= result.label;
  					edited.title 		= result.title;
  					edited.displayLabel = result.displayLabel;
  					edited.displayTitle = result.displayTitle;
					edited.minValue     = result.minValue;
  					edited.maxValue     = result.maxValue;

  				}).fail(function(jqXHR, textStatus, errorThrown) {
  		    		valid = false;

  		    		try {
  			    		var exception = eval('(' + jqXHR.responseText + ')');
  			    		alert(exception.message);
  		    		} catch(err) {
  			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
  		    		}
  		        });

  				if (valid && !(edited.name && edited.name.length > 0 && edited.label && edited.label.length > 0)) {
  					valid = false;
  					alert(settings.nameRequired);
  				}

  				if (valid) {
  					valid = callback(edited);
  				}

  			    return valid;
  			});
		}

		function setFieldType(value) {
			var row   = $(this).closest('tr');
			var type  = parseInt(value);
			var field = $.extend({}, row.data('field'));
			var isFieldTypeChangeAllowed = true;
			var allowedFieldType = allowedFieldTypeChanges[field.type];

			// TASK-922296: Allow restricted field type changes
			if (allowedFieldType == type) {
				showFancyAlertDialog(i18n.message('tracker.field.valueType.change.warning'));
			} else {
				var infoMessage = '';

				if (typeof allowedFieldType !== 'undefined') {
					infoMessage = '<br/><br/>' + i18n.message('tracker.field.valueType.immutable.info', settings.typeName[allowedFieldType]);
				}

				showFancyAlertDialog(settings.typeImmutable + infoMessage);
				type = field.type;
				isFieldTypeChangeAllowed = false;
			}

			if (isFieldTypeChangeAllowed) {
				setTypeOfField(field, type);
				updateField(field, row, true);
			}

			return settings.typeName[type];
		}

		function setFieldOffset(value) {
			var field  = $(this).closest('tr').data('field');
			var offset = value;

			if (!(typeof value === 'number')) {
				value  = $.trim(value.toString());
				offset = parseInt(value);
			}

			if (offset === 0){
				field.offset = 0;
			}
			else if (offset && !isNaN(offset)) {
				field.offset = offset;
			} else {
				offset = field.offset;
			}
			return offset;
		}

		function setFieldListable() {
			var checkbox = $(this);
			var field = checkbox.closest('tr').data('field');
    		field.listable = checkbox.is(':checked');
		}

		function setFieldNewline() {
			var checkbox = $(this);
			var field = checkbox.closest('tr').data('field');
    		field.newline = checkbox.is(':checked');
		}

		function setFieldColspan(value) {
			var field   = $(this).closest('tr').data('field');
			var colspan = value;

			if (!(typeof value === 'number')) {
				value   = $.trim(value.toString());
				colspan = parseInt(value);
			}

			if (colspan && !isNaN(colspan)) {
				field.colspan = colspan;
			} else {
				colspan = field.offset;
			}
			return colspan;
		}

		function getRuleSelector(rules, rule) {
			var selector = $('<select>');
		    selector.append($('<option>', {value: ''}).text('--'));

			for (var i = 0; i < rules.length; ++i) {
				var ruleDef = settings.ruleName[rules[i]];
			    selector.append($('<option>', {value: rules[i], title: ruleDef.tooltip, selected: (rule == rules[i])}).text(ruleDef.label));
			};

			return selector;
		}

		function setHierarchyRule(value) {
			var rule   = settings.ruleName[value];
   		    var type   = $(this).data("type");
			var field  = $(this).closest('tr').data('field');
   		    var config = field[type];

   		    if (config) {
				config.id      = (rule ? parseInt(value) : null);
				config.name    = (rule ? rule.label      : '--');
				config.tooltip = (rule ? rule.tooltip    : null);
			}

			return rule ? rule.label : '--';
		}

		function setExternalProjectBadgeColor(badge, count) {
			badge.removeClass();
			badge.addClass("externalProjectCountBadge");
			if( count <= 1 ){
				badge.addClass("externalProjectCountBadgeGreen");
			} else if( count >= 2 && count <= 4 ) {
				badge.addClass("externalProjectCountBadgeYellow");
			} else if( count > 4 ) {
				badge.addClass("externalProjectCountBadgeRed");
			}
		}

		function showLayoutAndContent(cell, field, getFieldById) {
			var first = true;
			cell.empty();

			appendMenuBox(cell);

			if (field['class'] == 'table') {
				if (field.required || (field.requiredIn && field.requiredIn.length > 0)) {
					cell.append($('<a>', {title: settings.mandatorySettings.mandatoryTitle }).text(settings.mandatorySettings.mandatoryLabel).click(showMandatoryControl));
					first = false;
				}

				if (field.multiple) {
					cell.append($('<label>', {title: settings.numberedTitle }).text((first ? '' : ', ') + settings.numberedLabel));
					first = false;
				}

				if (field.width >= 1) {
					cell.append($('<label>', {title: settings.colPermsTitle }).text((first ? '' : ', ') + settings.colPermsLabel));
					first = false;
				}
			} else {
				if (field.computable) {
					if (field.formula != null && field.formula.length > 0) {
						cell.append($('<label>', {title: settings.computedTitle }).text(settings.computedLabel));
						first = false;
					}
				}

				if (field.formatable) {
					if (field.multiple) {
						cell.append($('<label>', {title: settings.formattedTitle }).text((first ? '' : ', ') + settings.formattedLabel));
						first = false;
					}
				} else if (field.multiValue) {
					if (field.multiple) {
						cell.append($('<label>', {title: settings.multipleTitle }).text((first ? '' : ', ') + settings.multipleLabel));
						first = false;
					}
				}

				if (field.choosable) {
					var refName = settings.refTypeName[field.refType ? field.refType.toString() : '0'];
					if (!refName) {
						refName = settings.refTypeName['0'];
					}
					cell.append($('<label>').text(' '));

					var $refSelectLink = $('<a>').text(refName);

					var externalProjectCountBadge = null;

					if( field.refType != null && field.refType == 9 ) {
						// A blank title should be set for the tooltip to appear
						$refSelectLink.attr("title", "");

						externalProjectCountBadge = $('<div>', {'class': 'externalProjectCountBadge', 'title' : i18n.message('tracker.field.externalProjecCountBadge.tooltip')});

						var helperSpan = $('<span>', {'class': 'externalProjectIconWrapper'});
						var externalProjectIcon = $('<img>', {'src': contextPath + '/images/newskin/external_project_count_icon.png'});
						helperSpan.append(externalProjectIcon);

						var externalProjectCount = $("<label>");

						externalProjectCountBadge.append(helperSpan);
						externalProjectCountBadge.append(externalProjectCount);

						if( $.fn.trackerFieldsConfiguration.currentProjectId == null ) {
							$.get(settings.referenceConfigurationSettings.projectOfTrackerUrl).done( function(projectId) {
								$.fn.trackerFieldsConfiguration.currentProjectId = projectId;

								getExternalProjectCountData(field, externalProjectCountBadge, externalProjectCount);
							});
						} else {
							getExternalProjectCountData(field, externalProjectCountBadge, externalProjectCount);
						}

						var referringFieldTooltipOption = {
								position: {my: "left+50 top", collision: "flipfit"},
								tooltipClass : "tooltip",
								content : function(callback) {
									var cell  = $(this).closest('td');
									var field = cell.closest('tr').data('field');
									var editLinkWrapper = $('<div>', {'class' : 'contentArea tooltipHeader'});

									var editFromTooltipLink = $('<a>')
									.text(i18n.message('project.administration.tracker.config.referencingfield.tooltip.editlink'));

									editLinkWrapper.prepend(editFromTooltipLink);

									editFromTooltipLink.click( function() {
										$refSelectLink.click();
									});

									if( field.referenceFilters == null ) {
										getFieldConfigData(field).done( function(config){
											field.referenceFilters = config;
											var tooltipContent = createReferringInfoTooltipContent(field.referenceFilters);
											tooltipContent.prepend(editLinkWrapper);
											callback(tooltipContent);
										});
									} else {
										var tooltipContent = createReferringInfoTooltipContent(field.referenceFilters);
										tooltipContent.prepend(editLinkWrapper);
										return tooltipContent;
									}

								},
								close: function(event, ui) {
									jquery_ui_keepTooltipOpen(ui);
								}
							};

						$refSelectLink.tooltip(referringFieldTooltipOption);
					}

					$refSelectLink.click(function() {
						if( field.refType != null && field.refType == 9 ) {
							$refSelectLink.tooltip("destroy");
							$refSelectLink.tooltip(referringFieldTooltipOption);
						}
						showConfigDialog.call(this);
					}).on("clickWithAutoSave", function() {
						showConfigDialog.call(this, true);
					});

					cell.append($refSelectLink);

					if( externalProjectCountBadge != null ){
						cell.append(' ').append(externalProjectCountBadge);
					}

					first = false;

				} else if (field.type == 5 && field.id != 88) {
					var memberTypes = [];

					var memberMask = (typeof field.memberType === 'number' ? field.memberType : 0);
					if (memberMask > 0) {
						for (var i = 0; i < settings.memberTypes.length; ++i) {
							var memberType = settings.memberTypes[i];
							if ((memberMask & memberType.id) == memberType.id) {
								memberTypes.push(memberType.name);
							}
						}
					} else {
						memberTypes.push(settings.membersLabel);
					}
					cell.append($('<label>', { style : 'margin-left: 4px;' }).text(memberTypes.join(', ')));
					first = false;
				}

				if (field.demandable) {
					if (field.required || (field.requiredIn && field.requiredIn.length > 0)) {
						if (!first) {
							cell.append(', ');
						}
						cell.append($('<a>', {title: settings.mandatorySettings.mandatoryTitle }).text(settings.mandatorySettings.mandatoryLabel).click(showMandatoryControl));
						first = false;
					}

// This popup looks weird in field configuration popup, sow we always show the link here
//					if (field.statusSpecific && field.statusSpecific.length > 2) {
						if (!first) {
							cell.append(', ');
						}
						cell.append($('<a>', { "class" : field.statusSpecific && field.statusSpecific.length > 0 ? 'hasAccessPerms' : 'noAccessPerms', title: settings.defaultValueSettings.linkTitle }).text(field.type >= 5 && field.type <= 9 ? settings.defaultValueSettings.linkLabel : settings.defaultValueSettings.defaultValueLabel).click(showStatusSpecificValues));
	    				first = false;
//					}
				}

				if (field.id == 88) {
					cell.append($('<a>', {title: settings.visibilityTitle }).text(settings.visibilityLabel).click(showCommentVisibility));
    				first = false;

				} else if (field.combinable) {
					var dependsOn = field.dependsOn && !isNaN(field.dependsOn) ? (getFieldById || findFieldById)(field.dependsOn) : null;
					if (dependsOn) {
						cell.append($('<label>', {title: settings.dependsOnTitle }).text((first ? '' : ', ') + settings.dependsOnLabel + ' '));
						cell.append($('<a>', {title: settings.dependsOnTitle }).text(dependsOn.displayLabel || dependsOn.label).click(showValueCombinations));
	    				first = false;
					}
				}

				if (field.resizeable) {
					var width = field.width;
					if (width && !isNaN(width)) {
						if (field.multiLine) {
							var height = field.height;
							if (height && !isNaN(height) && height > 1) {
								cell.append($('<label>', {title: settings.sizeTitle }).text((first ? '' : ', ') + settings.sizeLabel + ': ' + width + ' x ' + height));
							} else {
								cell.append($('<label>', {title: settings.widthTitle }).text((first ? '' : ', ') + settings.widthLabel + ': ' + width));
							}
						} else {
							cell.append($('<label>', {title: settings.lengthTitle }).text((first ? '' : ', ') + settings.lengthLabel + ': ' + width));
						}
						first = false;
					}
				}

				if (field.limitable) {
					if (field.minValue && field.minValue.length > 0) {
						cell.append($('<label>', {title: settings.minValueTitle }).text((first ? '' : ', ') + settings.minValueLabel + ': ' + field.minValue));
						first = false;
					}

					if (field.maxValue && field.maxValue.length > 0) {
						cell.append($('<label>', {title: settings.maxValueTitle }).text((first ? '' : ', ') + settings.maxValueLabel + ': ' + field.maxValue));
						first = false;
					}
				}
			}
		}

		function getExternalProjectCountData(field, externalProjectCountBadge, externalProjectCount) {
			if( field.referenceFilters == null ) {
				getFieldConfigData(field).done( function(config) {
					field.referenceFilters = config;

					fillExternalProjectCountBadge(field, externalProjectCountBadge, externalProjectCount);
				});
			} else {
				fillExternalProjectCountBadge(field, externalProjectCountBadge, externalProjectCount);
			}
		}

		function fillExternalProjectCountBadge(field, externalProjectCountBadge, externalProjectCount) {
			var count = countExternalProjects(field.referenceFilters, $.fn.trackerFieldsConfiguration.currentProjectId);
			setExternalProjectBadgeColor(externalProjectCountBadge, count);
			externalProjectCount.text(count);
		}

		function countExternalProjects(referenceFilters, currentProjectId) {
			var count = 0;
			if( referenceFilters != null && $.isArray(referenceFilters) && referenceFilters.length > 0 ) {
				$.each(referenceFilters, function(i, project) {
					if( project.id != currentProjectId ) {
						count++;
					}
				});
			}
			return count;
		}

		function getFieldConfigData(field) {
			var refConfUrl = settings.referenceConfigurationSettings.refConfUrl;

			return $.get(refConfUrl, {fieldId : field.id}).done(function(config) {
				return config;
			}).fail(function(jqXHR, textStatus, errorThrown) {
				alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	        });
		}

		function createReferringInfoTooltipContent(configData) {
			var refConfSettings = settings.referenceConfigurationSettings;

			var contentWrapper = $("<div>");
			var trackerConfig = $('<ul>', { "class" : 'projects', 'style' : 'padding-left: 20px; padding-right: 15px;' });

			contentWrapper.append(trackerConfig);

			if (configData.length > 0) {
				for (var i = 0; i < configData.length; ++i) {
					var project = $('<li>', { "class" : 'project' });
					project.append(refConfSettings.inProjectLabel + ' ');
					project.append($('<label>').text(configData[i].name));

					// showProjectTrackerConfig
					var projConfig = $('<ul>', { "class" : 'components'});

					if( configData[i].flags != null ) {

						// showAllProjectTrackerItems
						var allConfig = $('<ul>', { "class" : 'allTrackerItems' });

					    var allItems = $('<li>', { "class" : 'component allItems' });
					    allItems.append($('<label>', {title : refConfSettings.allItemsTitle }).text(refConfSettings.allItemsLabel));
					    allItems.append(' ' + refConfSettings.withStatusLabel + ": ").append(configData[i].flags.name);

					    allItems.append(allConfig);
					    // showAllProjectTrackerItems end

						// showProjectTrackerTypes
						if( configData[i].types != null && configData[i].types.length > 0 ) {

							if( !$("ul.allTrackerItems", projConfig).length ) {
								projConfig.prepend(allItems);
							}

							var typeList = $('<ul>', { "class" : 'trackerTypes' });

							var typeConfig = $('<li>', { "class" : 'component allOfType' });

							typeConfig.append($('<label>', {title : refConfSettings.itemOfTypeTitle }).text(refConfSettings.itemOfTypeLabel));
							typeConfig.append(typeList);
							allConfig.prepend(typeConfig);

							for (var j = 0; j < configData[i].types.length; ++j) {
								var type = $('<li>', { "class" : 'trackerType' });
								type.append($('<label>').text(configData[i].types[j].name));
								typeList.append(type);
							}
						}
						// showProjectTrackerTypes end

						// showProjectTrackerPermissions
						if( configData[i].permissions != null && configData[i].permissions.length > 0 ) {

							if( !$("ul.allTrackerItems", projConfig).length ) {
								projConfig.prepend(allItems);
							}

							var permissionList = $('<ul>', { "class" : 'permissions' });
							var permsConfig = $('<li>', { "class" : 'component allWithPermission', style : 'margin-top: 10px;' });

							permsConfig.append($('<label>', {title : refConfSettings.itemPermsTitle }).text(refConfSettings.prjPermsLabel + ':'));
							permsConfig.append(permissionList);
							allConfig.append(permsConfig);

							for (var j = 0; j < configData[i].permissions.length; ++j) {
								var permission = $('<li>', { "class" : 'permission' });
								permission.append($('<label>', { title : configData[i].permissions[j].title }).text(configData[i].permissions[j].name));
								permissionList.append(permission);
							}
						}
						// showProjectTrackerPermissions end
					}

					// showProjectTrackers
					if( configData[i].explicitly != null && configData[i].explicitly.length > 0 ) {
						var folderList = $('<ul>', { "class" : 'folders' });

						var explicitlyConfig = $('<li>', { "class" : 'component explicitly', style : 'margin-top: 10px;' });

						explicitlyConfig.append($('<label>', {title : refConfSettings.itemsExplctTitle }).text(refConfSettings.itemsExplctLabel));
					    explicitlyConfig.append(folderList);

						projConfig.append(explicitlyConfig);


						for (var j = 0; j < configData[i].explicitly.length; ++j) {
							var trackers = configData[i].explicitly[j].trackers;
							if ($.isArray(trackers) && trackers.length > 0) {
								var trackerList = $('<ul>', { "class" : 'trackers' });
								var selectedTrackersInFolder = 0;

								for (var k = 0; k < trackers.length; ++k) {
									if (trackers[k].selected) {
										var tracker = $('<li>', { "class" : 'tracker' });
										tracker.append($('<label>', { title : trackers[k].title }).text(trackers[k].name));

										if (trackers[k].filter != null) {
											tracker.append(': ' + trackers[k].filter.name);
										}

										trackerList.append(tracker);
										selectedTrackersInFolder++;
									}
								}

								if (selectedTrackersInFolder > 0) {
									var folder = $('<li>', { "class" : 'folder' });
									folder.append(refConfSettings.inFolderLabel + ' ');
									folder.append($('<label>').text(configData[i].explicitly[j].path));
									folder.append(trackerList);
									folderList.append(folder);
								}
							}
						}
					}
					//showProjectTrackers end

					project.append(projConfig);
					trackerConfig.append(project);
				}
			} else {
				trackerConfig.append($('<li>').text(refConfSettings.projectsNone));
			}

			return contentWrapper;
		}

		function showAccessControl(cell, field) {
			if (field.id == 88) { // No access control for comments/attachments
				return;
			}

			var aclModes = settings.accessPermissionSettings.accessControlTypes;
			var aclMode  = aclModes[settings.accessPermissionSettings.defaultAccessCtrl];

			if (field.accessCtrl >= 0 && field.accessCtrl < aclModes.length) {
				aclMode = aclModes[field.accessCtrl];
			}
			var aclClass = 'accessControl hasAccessPerms';
			var aclTitle = aclMode.title;
			var aclLabel = aclMode.name;

			if (field.accessSameAs && field.accessSameAs.id >= 0) {
				aclLabel += ': ' + (field.accessSameAs.displayLabel || field.accessSameAs.label || field.accessSameAs.name);

				if (field.accessSameAs.broken) {
					aclClass += ' brokenLink';
					aclTitle += ' (broken)';
				} else if (field.accessSameAs.cyclic) {
					aclClass += ' cyclicLink';
					aclTitle += ' (cyclic)';
				}
			} else if (aclMode.id > 0) {
				var permissions = 0;

				if ($.isArray(field.accessPerms)) {
					for (var i = 0; i < field.accessPerms.length; ++i) {
						if (field.accessPerms[i] && $.isArray(field.accessPerms[i].permissions)) {
							permissions += field.accessPerms[i].permissions.length;
						}
					}
				}

				aclClass = 'accessControl ' + (permissions > 0 ? 'hasAccessPerms' : 'noAccessPermsWarn');
				aclTitle = aclMode.title + ', ' + permissions + ' ' + settings.permissionsLabel;
			}

			cell.empty();
			cell.append($('<a>', { "class" : aclClass, title : aclTitle }).text(aclLabel).click(showAccessPermissions));
		}

		function createField(spec, parent, getFieldById) {
			var field = $('<tr>', { "data-tt-id" : spec.id, "class" : spec['class'] + (spec.removable ? ' removable ' : ' ') + (spec.offset % 2 == 0 ? 'even' : 'odd') });
			if (parent && parent.id) {
				field.attr('data-tt-parent-id', parent.id);
			}

			field.data('field', spec);

			if (settings.editable) {
				// add the issue handle fr drag and drop
				var handlerColumn = $('<td>', {"class": "issueHandle", "title": i18n.message("cmdb.version.stats.drag.drop.hint")});
				field.append(handlerColumn);
			}

			var showPosition = $(settings.formSelector).data("showPosition");
			var offsetColumn = $('<td>', { "class" : 'numberData', style: 'min-width: 4em; width: 1%;' + (showPosition ? '' : ' display: None;')});
			var fieldOffset  = $('<span>', { "class" : 'fieldOffset' }).text(spec.offset);
			offsetColumn.append(fieldOffset);
			field.append(offsetColumn);

			var showProperty = $(settings.formSelector).data("showProperty");
			var fieldProperty = $('<td>', { "class" : 'property', style: 'width: 1%; padding-right: 10px !important;' + (showProperty ? '' : ' display: None;')});
			fieldProperty.append(spec.property);
			field.append(fieldProperty);

			var typeColumn = $('<td>', { "class" : 'textData', style: 'width: 1%;' });
			var hoverClass = '';
			if (settings.editable) {
				hoverClass = 'highlight-on-hover-w-pencil';
			}
			var fieldType  = $('<span>', { "class" : 'fieldType ' + spec.typeClass}).text(spec.typeName && spec.typeName.length > 0 ? spec.typeName : settings.typeName[spec.type]);
			typeColumn.append(fieldType);
			field.append(typeColumn);

			var labelColumn = $('<td>', { "class" : 'textData', style: 'width: 1%;' });

			var indenter = $('<span>', { "class" : 'indenter' });
			if (spec['class'] == 'table') {
				indenter.click(expandCollapseTable);
			}

//			var fieldLabel = $('<span>', { "class" : 'fieldLabel ' + (spec.hidden ? 'hidden ' : '') + hoverClass, "title" : settings.inlineEditTooltip}).html(spec.displayLabel || spec.label);
			var fieldLabel = $('<span>', { "class" : 'fieldLabel ' + (spec.hidden ? 'hidden ' : ''), "title" : settings.inlineEditTooltip}).html(spec.displayLabel || spec.label);
			labelColumn.append(indenter).append(' ').append(fieldLabel);
			field.append(labelColumn);

			if (settings.editable) {
				fieldLabel.click(function(event) {
					var config = field.data('field');
					var title = settings.editMenuLabel + ': ';
					if (parent != null) {
						var editableField = getFieldById(parent.id);
						if (editableField){
							title += (editableField.displayLabel || editableField.label) + " - ";
						}
					}
					title += (config.displayLabel || config.label) + ' (' + config.property + ')';

					event.stopPropagation();

					editFieldConfiguration(field, title, config, function(result) {
						if (validateField(result, field)) {
							var dependsOnField = result.dependsOn ? getFieldById(result.dependsOn) : null;

							if (result.combinable && dependsOnField && result.type == 6 && dependsOnField.type == 6) {
								try {
								    $.ajax(settings.combinationSettings.combiValuesUrl,	{
								    	type: 'GET',
										data: {
											fieldId : dependsOnField.id + ',' + result.id,
											fieldType : '6,6'
										},
										dataType: 'json',
										cache: false
									}).done(function(result) {
										if (result && !result.combinations.length && result.references.length == 1) {
											var fieldData = field.data('field');
											fieldData.combinations = [[
												[result.references[0]],
												result.references[0].references[0].value
											]];
										}
									}).fail(function(jqXHR, textStatus, errorThrown) {
										console.warn('failed: ' + textStatus + ', errorThrown=' + errorThrown + ', response=' + jqXHR.responseText);
										var exception = $.parseJSON(jqXHR.responseText);
										alert(exception.message);
								    });
								} catch(err) {
									console.warn('Failed to automatically set reference dependency', err);
								}
							}
							return updateField(result, field);
						}
						return false;
					});
				});
			}

			var fieldListable = $('<td>', { "class" : 'checkbox-column-minwidth', style: 'width: 1%;' });
			var listable = $('<input>', { type : 'checkbox', "class" : 'listable', title : settings.listableTooltip, checked : spec.listable, disabled : (!settings.editable || spec.neverListable || spec['class'] == 'tableColumn') });
			fieldListable.append(listable);
			field.append(fieldListable);

			var titleColumn = $('<td>', { "class" : 'textData', style: 'width: 1%;' });
			var fieldTitle  = $('<span>',  { "class" : 'fieldTitle' }).html(spec.displayTitle || spec.title);
			titleColumn.append(fieldTitle);
			field.append(titleColumn);

			var layoutAndContent = $('<td>', { "class" : 'layoutAndContent textData' });
			field.append(layoutAndContent);

			spec.width = spec.width || spec.cols;
			spec.height = spec.height || spec.rows;

			showLayoutAndContent(layoutAndContent, spec, getFieldById);

			var permissionsColumn = $('<td>', { "class" : 'permissions textData', style: 'width: 1%;' });
			field.append(permissionsColumn);

			if (!parent || parent.width >= 1) {
				showAccessControl(permissionsColumn, spec);
			}

			var distributeColumn = $('<td>', { "class" : 'textData', style: 'width: 1%;' });
			field.append(distributeColumn);

			var fieldDistribute = null;
			if (spec.distribute && spec['class'] != 'tableColumn') {
				fieldDistribute = $('<span>', { "class" : 'distribute ' + hoverClass }).text(spec.distribute.name);
				fieldDistribute.data("type", "distribute");
				distributeColumn.append(fieldDistribute);
			}

			var aggregateColumn = $('<td>', { "class" : 'textData', style: 'width: 1%;' });
			field.append(aggregateColumn);

			var fieldAggregate = null;
			if (spec.aggregate && spec['class'] != 'tableColumn') {
				fieldAggregate = $('<span>', { "class" : 'aggregate ' + hoverClass }).text(spec.aggregate.name);
				fieldAggregate.data("type", "aggregate");
				aggregateColumn.append(fieldAggregate);
			}

			var colspanColumn = $('<td>', { "class" : 'checkbox-column-minwidth', style: 'text-align: center;' });
			field.append(colspanColumn);

			var fieldColspan = null;
			if (spec.multiColumn) {
				fieldColspan = $('<span>', { "class" : 'multiColumn ' + hoverClass }).text(spec.colspan ? spec.colspan : 1);
				colspanColumn.append(fieldColspan);
			}

			var newlineColumn = $('<td>', { "class" : 'checkbox-column-minwidth', style: 'text-align: center;' });
			field.append(newlineColumn);

			var fieldNewline = null;
			if (spec['class'] != 'tableColumn') {
				fieldNewline = $('<input>', { type : 'checkbox', "class" : 'newline', title : settings.breakRowTooltip, checked : spec.newline, disabled : !settings.editable });
				newlineColumn.append(fieldNewline);
			}

			if (settings.editable) {
				/** Make the field offsets editable */
			    fieldOffset.editable(setFieldOffset, {
			        type      : 'fieldOffset',
			        event     : 'click',
			        onblur    : 'cancel'
			    });

			 // Type column elements no longer needed to be editable
//			    if (spec.typeClass != 'fixedType') {
//					/** Make the field type editable */
//				    fieldType.editable(setFieldType, {
//				        type      : 'fieldType',
//				        event     : 'click',
//				        onblur    : 'cancel',
//					    tooltip   : settings.inlineEditTooltip
//				    });
//			    }

			   	listable.click(setFieldListable);

				if (fieldDistribute != null) {
					/** Make the distribution rule editable */
				    fieldDistribute.editable(setHierarchyRule, {
				        type       : 'hierarchyRule',
						placeholder: '--',
				        event      : 'click',
				        onblur     : 'cancel',
					    tooltip    : settings.inlineEditTooltip,
					    onedit     : function() {
					    	$(this).removeClass(hoverClass);
					    },
					    onreset    : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    },
					    onsubmit   : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    }
				    });
				}

				if (fieldAggregate != null) {
					/** Make the aggregation rule editable */
				    fieldAggregate.editable(setHierarchyRule, {
				        type       : 'hierarchyRule',
						placeholder: '--',
				        event      : 'click',
				        onblur     : 'cancel',
					    tooltip    : settings.inlineEditTooltip,
					    onedit     : function() {
					    	$(this).removeClass(hoverClass);
					    },
					    onreset    : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    },
					    onsubmit   : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    }
				    });
				}

				if (fieldColspan != null) {
					/** Make the field colspan editable */
				    fieldColspan.editable(setFieldColspan, {
				        type       : 'colspan',
						placeholder: '1',
				        event      : 'click',
				        onblur     : 'cancel',
					    tooltip    : settings.inlineEditTooltip,
					    onedit     : function() {
					    	$(this).removeClass(hoverClass);
					    },
					    onreset    : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    },
					    onsubmit   : function() {
					    	$(this).closest('span').addClass(hoverClass);
					    }
				    });
				}

				if (fieldNewline != null) {
					fieldNewline.click(setFieldNewline);
				}
			}

			return field;
		}

		function updateField(field, row, onlyType) {
			var prev = row.data('field');
			row.data('field', field);

			if (!onlyType) {
			    if (field.typeClass != 'fixedType') {
			    	$('span.fieldType', row).text(settings.typeName[field.type]);
			    }

			    var label = $('span.fieldLabel', row);
			    label.attr('title', field.description).text(field.displayLabel || field.label);
				if (field.hidden) {
					label.addClass("hidden");
				} else {
					label.removeClass("hidden");
				}
				$('span.fieldTitle', row).html(field.displayTitle || field.title);
				$('input.listable',  row).attr('checked', field.listable);
			}

			if (field['class'] == 'table') {
				var enable = field.width >= 1; // Do columns have own access control ?

				row.nextAll('tr.tableColumn').each(function() {
					var cell = $('td.permissions', this);
					var acl = $('a.accessControl', cell);

					if (acl.length > 0) {
						if (!enable) {
							acl.remove();
						}
					} else if (enable) {
						showAccessControl(cell, $(this).data('field'));
					}
				});

			} else if (field.typeClass != 'fixedType' &&
					  (field.type != prev.type ||
					  (typeof field.refType != 'undefined' && field.refType ? field.refType : 0) != (typeof prev.refType != 'undefined' && prev.refType ? prev.refType : 0))) {

				// If default values exist, they are most likely obsolete, due to the field type change
				if ($.isArray(field.statusSpecific) && field.statusSpecific.length > 0) {
		  			// Ask the user whether to keep the default values or to remove them
		  			if (confirm(settings.removeDfltsConfirm)) {
		  				field.statusSpecific = [];

		  				$('#field_' + field.id + '_defaultValuesDialog').remove();
		  			}
		  		}

				// If value combinations exist, they are most likely obsolete, due to the field type change
				if ($.isArray(field.combinations) && field.combinations.length > 0) {
		  			// Ask the user whether to keep the value combinations or to remove them
		  			if (confirm(settings.removeCombisConfirm)) {
		  				field.combinations = [];
						$('#field_' + field.id + '_combinationsDialog').remove();

	   				 	// Also destroy combinations recursively
						doInDependendFields(field.id, function(dependendField) {
							dependendField.combinations = [];
							$('#field_' + dependendField.id + '_combinationsDialog').remove();
						});
		  			}
				}

				// Remove obsolete reference configuration dialog
				$('#field_' + field.id + '_refConfigDialog').remove();

				if (field.refType && field.refType > 0) {
					if (field.refType == 1) {
						field.referenceFilters = { groups: [], permissions: [], projects: [] };
					} else if (field.refType == 2) {
						field.referenceFilters = { qualifiers: [], permissions: [], projects: [] };
					} else {
						field.referenceFilters = [];
					}
				}
			}

			var layoutAndContent = $('td.layoutAndContent', row);
			if (layoutAndContent.length > 0) {
				showLayoutAndContent(layoutAndContent, field);
			}

			if (field['class'] != 'tableColumn') {
				var tbody = row.closest('tbody');

				if (field.hidden && !$(settings.formSelector).data("showHidden")) {
					tbody.hide();
				} else {
					tbody.show();
				}
			}

			return true;
		}

		function validateField(field, row) {
			var table = (field['class'] == 'tableColumn' ? getTableId(field.id) : -1);

			var duplicate = findField(function(existing) {
				var tid = (existing['class'] == 'tableColumn' ? getTableId(existing.id) : -1);
				return tid == table && (existing.name == field.name || existing.label == field.label || existing.displayLabel == field.displayLabel) && !(row && row.is(this));
			});

			if (duplicate) {
				alert(settings.nameDuplicate);
				return false;
			}

			return true;
		}

		function addField(title, spec, parent, before, newField) {
			var fieldId = 0;
			var offset  = 0;
			var minId   = 0;
			var idIncr  = 1;
			var propName;
			var fields;
			var tbody;
			var currentFieldType;

			if (spec['class'] == 'table') {
				fields = $('tbody tr.table', settings.fields);
				minId  = 1000000;
				idIncr = 1000000;
				propName = function(id) { return 'table[' + getTableId(id) + ']'; };
                currentFieldType = 'customTable';
			} else if (spec.typeClass == 'choiceTypes') {
				minId  = 1000;
				fields = $('tbody tr.trackerField:has(span.choiceTypes)', settings.fields);
				propName = function(id) { return 'choiceList[' + (id - 1000) + ']'; };
                currentFieldType = 'choiceList';
			} else { // simpleTypes
				minId = 10000;
				fields = $('tbody tr.trackerField:has(span.simpleTypes)', settings.fields);
				propName = function(id) { return 'customField[' + (id - 10000) + ']'; };
                currentFieldType = 'customField';
			}

			fields.each(function() {
				var existing = $(this);
				var fldOff = parseInt($('span.fieldOffset:first', existing).text());
				var fldId  = existing.attr('data-tt-id');

				offset  = Math.max(offset, fldOff);
				fieldId = Math.max(fieldId, fldId);
			});

			var lastField = $("#trackerFields > tbody:last");
			if (before != null) {
				var prevOff = parseInt($('span.fieldOffset:first', before.prevAll("tbody:first")).text());
				var nextOff = parseInt($('span.fieldOffset:first', before).text());

				if (typeof prevOff === 'undefined' || isNaN(prevOff)) {
					prevOff = 0;
				}
				var remainder = (prevOff + nextOff) % 2;
				offset = (prevOff + nextOff - remainder) / 2;
			} else {
				offset = lastField.find("tr:first").data("field").offset + 16;
			}

            $.ajax(settings.nextCustomFieldIdUrl, {
                type	: 'GET',
                data	: { type : currentFieldType},
                dataType: 'json',
                async   : false,
                cache	: false
            }).done(function(response) {
                minId = response;
            }).fail(function(jqXHR, textStatus, errorThrown) {
                alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
            });

			spec.id = (fieldId < minId ? minId : fieldId + idIncr);
			spec.property = propName(spec.id);
			spec.offset = offset + 1;

			editFieldConfiguration(null, title, spec, function(field) {
				if (validateField(field)) {
					if (field['class'] == 'table') {
						tbody = $('<tbody>', { id : 'table_' + field.id, "class" : 'table' });
					} else {
						tbody = $('<tbody>', { id : 'field_' + field.id, "class" : 'field' });
					}

					tbody.append(createField(field));
					if (before != null) {
						tbody.insertBefore(before);
					} else {
						tbody.insertAfter(lastField);
					}

					if (field['class'] == 'table') {
						sortable(tbody, 'tr.tableColumn');
					}

					flashChanged(tbody.find("tr"));

					return true;
				}

				return false;
			}, newField);
		}

		function checkFieldValues(field, callback) {
			var result = null;

 	        $.ajax(settings.checkFieldValuesUrl, {
 	        	type	: 'GET',
 	        	data	: { fieldId : field.id },
 	        	dataType: 'json',
 	        	async   : $.isFunction(callback),
 	        	cache	: false
 	    	}).done(callback || function(response) {
 	    		result = response;
 	        }).fail(function(jqXHR, textStatus, errorThrown) {
 	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
 	    	});

 	        return result;
		}

		function createDefaultPermissionToNewField(settings){
			settings.accessPermissionSettings.roles;
			var newPerms = [];
			var newPerm = {status: null, permissions: []};
			for (idx in settings.accessPermissionSettings.roles) {
				var currentRole = settings.accessPermissionSettings.roles[idx];
				newPerm.permissions.push({access : 3, role : currentRole.id});
			}
			newPerms.push(newPerm);
			return newPerms;
		}

		function addChoiceField(before, newField) {
			addField(settings.newChoiceFieldText, {
						"class"  	 : 'trackerField',
						type   		 : 6,
						typeClass	 : 'choiceTypes',
						label		 : null,
						title        : null,
						description  : null,
						listable 	 : false,
						hidden		 : false,
						multiValue   : true,
						choosable    : true,
						referenceConfig : true,
						demandable   : true,
						combinable   : true,
						distribute 	 : { "class" : 'choice', id : null, name : '--' },
						aggregate 	 : { "class" : 'choice', id : null, name : '--' },
						multiColumn  : true,
						removable    : true,
   						editableAtAll: true,
   						accessCtrl   : 1,
						accessPerms  : createDefaultPermissionToNewField(settings)
					 }, null, before, newField);
		}

		function addCustomField(before, newField) {
			addField(settings.newCustomFieldText, {
						"class"  	 : 'trackerField',
						type   	 	 : 0,
						typeClass	 : 'simpleTypes',
						label		 : null,
						title        : null,
						description  : null,
						listable 	 : false,
						hidden		 : false,
						computable   : true,
						demandable   : true,
						resizeable   : true,
						multiLine    : true,
						limitable    : true,
						distribute 	 : { "class" : 'type', id : null, name : '--' },
						aggregate 	 : { "class" : 'type', id : null, name : '--' },
						multiColumn  : true,
						removable    : true,
						editableAtAll: true,
						accessCtrl   : 1,
						accessPerms  : createDefaultPermissionToNewField(settings)
					 }, null, before, newField);
		}

		function addTable(before, newField) {
			addField(settings.newTableText, {
						"class"  	 : 'table',
						type   	 	 : 12,
						typeClass	 : 'fixedType',
						typeName	 : settings.typeName[12],
						label		 : null,
						title        : null,
						description  : null,
						listable 	 : false,
						hidden		 : false,
						multiColumn  : true,
						removable    : true,
   						editableAtAll: true,
						accessCtrl   : 1,
						accessPerms  : createDefaultPermissionToNewField(settings)
					 }, null, before, newField);
		}

		function removeField(field) {
			// Destroy combinations recursively
			doInDependendFields(field.id, function(dependendField) {
				dependendField.combinations = [];
				$('#field_' + dependendField.id + '_combinationsDialog').remove();

				// Only clear dependency in other fields directly depending on this
				if (dependendField.dependsOn == field.id) {
					dependendField.dependsOn = -1;

					var layoutAndContent = $('td.layoutAndContent', this);
					if (layoutAndContent.length > 0) {
						showLayoutAndContent(layoutAndContent, dependendField);
					}
				}
			});

			// Unlink fields whose permission was set to same as removed field
			findField(function(linked) {
				if (linked.accessSameAs && linked.accessSameAs.id == field.id) {
					delete linked.accessSameAs;
					linked.accessCtrl = 1;

					showAccessControl($('td.permissions', this), linked);
				}
			});
		}

		function getMoreFieldsSelector() {
			var selector = $('<select>', { style : 'margin-top: 1em;' }).change(function() {
				var desc = $('#field_80');
				var type = this.value;

				switch(type) {
				case 'choiceField':
					addChoiceField(null, true);
					break;
				case 'customField':
					addCustomField(null, true);
					break;
				case 'table':
					addTable(null, true);
					break;
				}

				this.options[0].selected = true;

				$('#toggleBoxes').trigger('cbClearFieldFilters');
			});

			selector.append($('<option>', { value : '', style : 'color: gray; font-style: italic;'} ).text(settings.moreFieldsLabel));
			selector.append($('<option>', { value : 'choiceField' } ).text(settings.newChoiceFieldText));
			selector.append($('<option>', { value : 'customField' } ).text(settings.newCustomFieldText));
			selector.append($('<option>', { value : 'table' 	  } ).text(settings.newTableText));

			return selector;
		}

		function expandCollapseTable() {
			var indenter = $(this);
			var table = indenter.closest('tbody');

			if (indenter.hasClass('collapsed')) {
				$('tr.tableColumn', table).show();
				indenter.removeClass('collapsed');
			} else {
				$('tr.tableColumn', table).hide();
				indenter.addClass('collapsed');
			}
		}

		function setup() {
			if (settings.editable) {
               /** Add a context menu to tracker fields */
                var trackerFieldMenu = new ContextMenuManager({
                    selector: "table.fieldsConfiguration tbody tr.trackerField .yuimenubaritemlabel",
                    trigger : "left",
                    build : function($trigger) {
                    	var fldtr = $trigger.closest("tr");
                    	var field = fldtr.data('field');

        				var fieldNameEditingDisabled = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;
             			var items = {
                    		addHereNew : {
                                name: settings.addHereMenuLabel,
                                items: {
                                    addChoiceField: {
                                        name: settings.newChoiceFieldText,
                                        callback: function (key, options) {
                                            addChoiceField(options.$trigger.closest('tbody'));
                                        }
                                    },
                                    addCustomField: {
                                        name: settings.newCustomFieldText,
                                        callback: function (key, options) {
                                            addCustomField(options.$trigger.closest('tbody'));
                                        }
                                    },
                                    addTable: {
                                        name: settings.newTableText,
                                        callback: function (key, options) {
                                            addTable(options.$trigger.closest('tbody'));
                                        }
                                    }
                                }
                            },
                            edit: {
                                name: settings.editMenuLabel,
                                callback: function (key, options) {
                                    var fldtr = options.$trigger.closest("tr");
                                    var field = fldtr.data('field');
                                    var title = settings.editMenuLabel + ': ' + field.label + ' (' + field.property + ')';

                                    editFieldConfiguration(fldtr, title, field, function (result) {
                                        if (validateField(result, fldtr)) {
                                            return updateField(result, fldtr);
                                        }
                                        return false;
                                    });
                                }
                            },
                            hideOrUnveil : {
                                name: field.hidden ? settings.unveilFieldLabel : settings.hideFieldLabel,
                                callback: function (key, options) {
                                    var fldtr = options.$trigger.closest("tr");
                                    var field = fldtr.data('field');

                                	field.hidden = !field.hidden;
                                	updateField(field, fldtr);
                                }
                            }
                    	};

            			if (field.removable && !fieldNameEditingDisabled) {
            				items.remove = {
                                name: settings.removeFieldLabel,
                                callback: function (key, options) {
                                    var fldtr = options.$trigger.closest("tr");
                                    var field = fldtr.data('field');

                                    if (field.removable) {
                						showFancyConfirmDialogWithCallbacks(getSetting('removeFieldConfirm'), function() {
                							// TASK-778983: Do not allow to remove non-empty fields, only allow to hide them
                							checkFieldValues(field, function(result) {
                								// If there are already existing field values
                								if (result.items) {
                									var linksHeading = '',
                										itemLinks = '';
                									if (result.itemLinks) {
                										linksHeading = '<p>' + i18n.message('tracker.field.remove.affected.items.label') + '</p>';
                										itemLinks = '<ul>';
                										var linkCounter = 0;
                										Object.keys(result.itemLinks).forEach(function(itemId) {
                											var link = result.itemLinks[itemId];
                											if (link.length) {
                												itemLinks += '<li>' + link + '</li>';
                												linkCounter++;
                											}
                										});
                										itemLinks += '</ul>';
                										var noPermissionCounter = result.items - linkCounter;
                										if (noPermissionCounter) {
                											itemLinks += '<p style="font-weight:bold;">' + i18n.message('tracker.field.remove.item.permission.label', noPermissionCounter) + '</p>';
                										}
                									}
                									showFancyConfirmDialogWithCallbacks(getSetting('hideFieldConfirm').replace('XX', result.items).replace('YY', result.trackers) + linksHeading + itemLinks, function() {
                										// Ask if the user wants to hide the field instead
                										field.hidden = true;
                										field.required = false;
                										field.requiredIn = null;

                										updateField(field, fldtr);
                									});
                								} else {
                									fldtr.closest('tbody').remove();
                									removeField(field);
                								}
                							});
                						});
                                    }
                                }
            				};
            			}

            			return { items : items };
            		}
                });
                trackerFieldMenu.render();

				/** Add a context menu to table fields */
                var tableFieldMenu = new ContextMenuManager({
                    selector: "table.fieldsConfiguration tbody tr.table .yuimenubaritemlabel",
                    trigger: "left",
                    build : function($trigger) {
                    	var fieldRow = $trigger.closest("tr");
        				var field = fieldRow.data('field');
        				var fieldNameEditingDisabled = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

             			var items = {
             				addColumn : {
		                        name 	: settings.newColumnText,
		                        callback: function(key, options) {
		                            var table  = options.$trigger.closest('tbody');
		                            var field  = options.$trigger.parents('tr').data('field');
		                            var offset = 0;
		                            var colId  = field.id;

		                            $('tr.tableColumn', table).each(function() {
		                                var existing = $(this);
		                                var exColOff = parseInt($('span.fieldOffset:first', existing).text());
		                                var exColId  = existing.attr('data-tt-id');

		                                offset = Math.max(offset, exColOff);
		                                colId  = Math.max(colId,  exColId);
		                            });

		                            offset += 10;
		                            colId++;

		                            editFieldConfiguration(table, settings.newColumnText, {
		                                "class"  	  : 'tableColumn',
		                                id 		 	  : colId,
		                                offset   	  : offset,
		                                property 	  : 'tableColumn[' + getTableId(field.id) + ',' + getColumnIndex(colId) + ']',
		                                type   		  : 0,
		                                typeClass	  : 'allTypes',
		                                listable 	  : true,
		                                computable    : true,
		                                demandable    : true,
		                                resizeable    : true,
		                                multiLine     : true,
		                                limitable     : true,
		                                multiColumn   : false,
		                                editableAtAll : true,
		                                accessCtrl    : 0,
		                                removable	  : true

		                            }, function(result) {
		                                if (validateField(result)) {
		                                    var column = createField(result, field, getFieldById);
		                                    table.append(column);
		                                    return true;
		                                }
		                                return false;
		                            });
		                        }
		                    },
	                        edit : {
	                            name    : settings.editMenuLabel,
	                            callback: function(key, options) {
	                                var fldtr = options.$trigger.closest("tr");
	                                var field = fldtr.data('field');
	                                var title = settings.editMenuLabel + ': ' + field.label + ' (' + field.property + ')';

	                                editFieldConfiguration(fldtr, title, field, function(result) {
	                                    if (validateField(result, fldtr)) {
	                                        return updateField(result, fldtr);
	                                    }
	                                    return false;
	                                });
	                            }
	                        }
             			};

            			if ($trigger.closest("tr").hasClass('removable') && !fieldNameEditingDisabled) {
	                        items.remove = {
	                            name 	: settings.removeTableLabel,
	                            callback: function(key, options) {
	                                var field = options.$trigger.closest("tr");
	                                if (field.hasClass('removable') && confirm(getSetting('removeTableConfirm'))) {
	                                    field.closest('tbody').remove();
	                                }
	                            }
	                        };
                        }

            			return { items : items };
                    }
                });
				tableFieldMenu.render();

				/** Add a context menu to table columns */
                var tableColumnMenu = new ContextMenuManager({
                    selector: "table.fieldsConfiguration tbody tr.tableColumn .yuimenubaritemlabel",
                    trigger: "left",
                    build : function($trigger) {
                    	var fldtr = $trigger.closest("tr");
                    	var field = fldtr.data('field');

        				var fieldNameEditingDisabled = field.hasOwnProperty("disableEditingFieldName") && field.disableEditingFieldName;

             			var items = {
             				edit : {
		                        name    : settings.editMenuLabel,
		                        callback: function(key, options) {
		                            var colrow = options.$trigger.closest("tr");
		                            var column = colrow.data('field');
		                            var parent = colrow.closest('tbody').find('tr.table:first').data('field');
		                            var title  = settings.editMenuLabel + ': ';
		                            if (parent) {
		                                title += parent.label + " - ";
		                            }
		                            title += column.label + ' (' + column.property + ')';

		                            editFieldConfiguration(colrow, title, column, function(result) {
		                                if (validateField(result, colrow)) {
		                                    return updateField(result, colrow);
		                                }
		                                return false;
		                            });
		                        }
		                    }
             			};

            			if ($trigger.closest("tr").hasClass('removable') && !fieldNameEditingDisabled) {
	                        items.remove = {
	                        	name 	: settings.removeColumnLabel,
	                            callback: function(key, options) {
	                                var colrow = options.$trigger.closest("tr");
	                                var column = colrow.data('field');

	                                if (column.removable && confirm(getSetting('removeColumnConfirm'))) {
	                                	// TASK-778983: Do not allow to remove non-empty columns
	                                	checkFieldValues(column, function(result) {
	                                		if (result.items) {
	                                    		// Since we cannot hide table columns, we can only deny removing the column
	                                    		alert(getSetting('existColumnValues').replace('XX', result.items).replace('YY', result.trackers));
	                                		} else {
	     	                                   $(colrow).remove();
	    	                                   removeField(column);
	                                		}
		                                });
	                                }
	                            }
	                        };
	                    }

            			return { items : items };
                    }
                });
				tableColumnMenu.render();

				/* Define an inplace editor for field offsets */
			    $.editable.addInputType('fieldOffset', {
			        element : function(settings, self) {
			           	var input = $('<input>', { type: 'number', size: '4', maxlength: '10', style: 'text-align: right;'});
			           	input.attr('autocomplete', 'off');
			           	$(this).append(input);
			           	return input;
			        }
			    });

				/* Define an inplace editor for field types */
			    $.editable.addInputType('fieldType', {
			        element : function(settings, self) {
			        	var form 	   = $(this);
			        	var field      = $(self).closest('tr').data('field');
			           	var typeSelect = getTypeSelector(field.typeClass, field.type);

			           	typeSelect.change(function() {
			           		form.submit();
			           	});

			           	form.append(typeSelect);
			           	return typeSelect;
			        },

			    	content : function(string, settings, self) {
			    		// Nothing
			     	}
			    });

				/* Define an inplace editor for field aggregation/distribution rules */
			    $.editable.addInputType('hierarchyRule', {
			        element : function(settings, self) {
			        	var form 	  = $(this);
			        	var field     = $(self).closest('tr').data('field');
			    		var type      = $(self).data("type");
			    		var rule      = field[type];
			    		var category  = getSetting(type == 'aggregate' ? 'aggrClasses' : 'distClasses');
			    		var ruleClass = rule['class'];

			    		if (ruleClass == 'type') {
			    			ruleClass = (field.type ? field.type.toString() : '0');
							if (typeof category[ruleClass] === 'undefined') {
			    				ruleClass = 'choice';
			    			}
			    		}

			           	var ruleSelect = getRuleSelector(category[ruleClass], rule.id);
			           	ruleSelect.change(function() {
			           		form.submit();
			           	});
			           	form.append(ruleSelect);

			           	return ruleSelect;
			        },

			    	content : function(string, settings, self) {
			    		// Nothing
			     	}
			    });

				/* Define an inplace editor for the field colSpan */
			    $.editable.addInputType('colspan', {
			        element : function(settings, self) {
			        	var form   = $(this);
			        	var field  = $(self).closest('tr').data('field');
			           	var select = $('<select>');
			           	for (var i = 1; i <= 3; ++i) {
			           		select.append($('<option>', {value: i, selected: (field.colspan == i)}).text(i));
			           	}

			           	select.change(function() {
			           		form.submit();
			           	});
			           	form.append(select);
			           	return select;
			        },

			    	content : function(string, settings, self) {
			    		// Nothing
			     	}
			    });
			}
		}

		/** Make the table items sortable */
		function sortable(table, items, options) {
			if (settings.editable) {
				table.sortable( $.extend( {}, options, {
					items	: "> " + items,
					axis 	: "y",
					cursor	: "move",
					delay	: 150,
					distance: 5,

					update	: function(event, ui) {
						var item    = $(ui.item);
						var offSpan = $('span.fieldOffset:first', item);
						var offset  = parseInt(offSpan.text());
						var prevOff = parseInt($('span.fieldOffset:first', item.prevAll(items + ":first")).text());
						var nextOff = parseInt($('span.fieldOffset:first', item.nextAll(items + ":first")).text());

						if (typeof prevOff === 'undefined' || isNaN(prevOff)) {
							var remainder = nextOff % 2;
							offset = (nextOff - remainder) / 2;
						} else if (typeof nextOff === 'undefined' || isNaN(nextOff)) {
							offset = prevOff + 10;
						} else {
							var remainder = (prevOff + nextOff) % 2;
							offset = (prevOff + nextOff - remainder) / 2;
						}

						if (offset === 0 || offset === prevOff || offset === nextOff){
							// invalid offset
							event.preventDefault();

							var msg = (offset === 0) ?
									i18n.message("tracker.field.resort.warning.null") :
									i18n.message("tracker.field.resort.warning.exists", offset);

							var dialogButtons = [
							   {
							   	text : i18n.message("button.ok"),
									click : function(){
										if(!$("#showPosition").is(':checked')){
											$('#showPosition').click();
										}
										$(this).dialog("destroy");
									}
								}
							];

							showModalDialog("warning", msg, dialogButtons, 30);

						}
						else {

							offSpan.text(setFieldOffset.apply(offSpan, [offset]));

							var showPosition = $(settings.formSelector).data("showposition");
							if (showPosition) {
								offSpan.dblclick();
							}
						}
					}
				}));
			}
		}

		function getFieldById(fieldId) {
			for (var i = 0; i < fields.length; ++i) {
				var field = fields[i];
				if (field.id == fieldId) {
					return field;
				}

				var columns = field.columns;
				if ($.isArray(columns)) {
					for (var j = 0; j < columns.length; ++j) {
						if (columns[j].id == fieldId) {
							return columns[j];
						}
					}
				}
			}
			return null;
		}

		function init(container, fields) {
			if (!$.isArray(fields)) {
				fields = [];
			}

			var table = $('<table>', { id : 'trackerFields', "class" : 'displaytag fieldsConfiguration' });
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>',  { "class" : 'head' });
			if (settings.editable) {
				headline.append($('<th>')); // for the issue handle column
			}
			headline.append($('<th>', { "class" : 'numberData positionHeader', style : 'min-width: 4em; width: 1%;' + (settings.showPosition ? '' : ' display: None;') }).text(settings.offsetLabel));
			headline.append($('<th>', { "class" : 'textData propertyNameHeader', style : 'width: 1%;' + (settings.showProperty ? '' : ' display: None;') }).text(settings.propertyLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'width: 1%;' }).text(settings.typeLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'padding-left: 31px !important; width: 1%;'  }).text(settings.nameLabel));
			headline.append($('<th>', { "class" : 'checkbox-column-minwidth', style : 'text-align: center;' }).text(settings.listableLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'width: 1%;'  }).text(settings.titleLabel));
			headline.append($('<th>', { "class" : 'textData'  }).text(settings.layoutLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'width: 1%;'  }).text(settings.permissionsLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'width: 1%; padding-left: 8px;'  }).text(settings.distributeLabel));
			headline.append($('<th>', { "class" : 'textData', style : 'width: 1%; padding-left: 8px;'  }).text(settings.aggregateLabel));
			headline.append($('<th>', { "class" : 'checkbox-column-minwidth', style : 'text-align: center;', title : settings.colspanTitle }).text(settings.widthLabel));
			headline.append($('<th>', { "class" : 'checkbox-column-minwidth', style : 'text-align: center;' }).text(settings.newlineLabel));
			header.append(headline);

			for (var i = 0; i < fields.length; ++i) {
				var field = fields[i];
				var tbody = $('<tbody>', { id : 'field_' + field.id, "class" : field['class'] == 'table' ? 'table' : 'field' });
				table.append(tbody);

				tbody.append(createField(field, null, getFieldById));

				if (field['class'] == 'table') {
					var columns = field.columns;
					if ($.isArray(columns)) {
						for (var j = 0; j < columns.length; ++j) {
							tbody.append(createField(columns[j], field, getFieldById));
						}
					}

					sortable(tbody, 'tr.tableColumn');
				}

				if (field.hidden) {
					tbody.hide();
				}
			}

			if (settings.editable) {
				/** Make the field list sortable */
				sortable(table, 'tbody', {
					helper  			: "clone",
					placeholder			: 'group_move_placeholder',
					forcePlaceholderSize: true,
				    refreshPositions	: true
				});

				getMoreFieldsSelector().insertAfter(table);
			}

			settings.fields = table;
		}

		if ($.fn.trackerFieldsConfiguration._setup) {
			$.fn.trackerFieldsConfiguration._setup = false;
			setup();
		}

		settings.dependsOnSelector = getDependsOnSelector;
		settings.showStatusSpecificValues = showStatusSpecificValues;
		settings.combinationSettings.trackerId = settings.trackerId;
		settings.combinationSettings.combiValueEditor = getFieldEditor;
		settings.mandatorySettings.statusOptions = getStatusOptions;
		settings.defaultValueSettings.statusOptions = getStatusOptions;
		settings.defaultValueSettings.fieldValueEditor = getFieldEditor;
		settings.defaultValueSettings.editTooltip = settings.inlineEditTooltip;
		settings.accessPermissionSettings.statusOptions = getStatusOptions;
		settings.accessPermissionSettings.memberFields = getMemberFields;

		return this.each(function() {
			init($(this), fields);
		});
	};

	$.fn.trackerFieldsConfiguration.defaults = {
		trackerId			: null,
		editable			: false,
		showPosition		: false,
		showProperty		: false,
		typeClasses			: { "allTypes" : [], "simpleTypes" : [], "choiceTypes" : [] },
		typeName			: [],
		memberTypes			: [{ id : 2, name : "Users"  },
		           			   { id : 4, name : "Groups" },
		           			   { id : 8, name : "Roles"  }],
		refTypes			: [],
		refTypeName			: {},
		aggrClasses			: {},
		distClasses			: {},
		ruleName			: {},
		fieldValidationUrl  : null,
		fieldOptionsUrl		: null,
		checkFieldValuesUrl : null,
        nextCustomFieldIdUrl: null,
		infoLinkUrl			: null,
		dateOptions			: [],
		countryOptions		: [],
		languageOptions		: [],
		inlineEditTooltip	: 'Click to edit',
		moreFieldsLabel		: 'More fields...',
		addHereMenuLabel	: 'Insert here a',
		newChoiceFieldText	: 'New choice field...',
		newCustomFieldText	: 'New custom field...',
		newTableText		: 'New table...',
		newColumnText		: 'Add new column...',
		editMenuLabel		: 'Edit',
		hideFieldLabel		: 'Hide',
	    hideFieldConfirm	: 'The field cannot be removed, because there are XX items in YY trackers, that have values for this field. Do you want to hide the field instead ?',
	    unveilFieldLabel	: 'Unveil',
		removeFieldLabel	: 'Remove',
	    removeFieldConfirm	: 'Really remove this field definition?',
	    removeTableLabel	: 'Remove table...',
	    removeTableConfirm	: 'Really remove this whole table?',
	    removeTableValues	: 'There are XX items in YY trackers, that have values for this table. Really remove them ?',
	    removeColumnLabel	: 'Remove column...',
	    removeColumnConfirm	: 'Really remove this table column?',
	    existColumnValues	: 'This column cannot be removed, because there are XX items in YY trackers, that have values for this table column!',
	    removeDfltsConfirm  : 'There exist default values and/or field filters that are most likely incompatible with the new field type. Should these be removed ?',
	    removeCombisConfirm : 'There exist field value combinations that are most likely incompatible with the new field type. Should these be removed ?',
		editLabelText		: 'Label',
		editTitleText		: 'Title',
		editTooltipText		: 'Description',
		editLayoutText		: 'Layout and Content',
		offsetLabel			: 'Pos.',
		propertyLabel		: 'Property',
		typeLabel			: 'Type',
		typeTooltip			: 'The field value type/class',
	    typeImmutable		: 'The type of this field cannot be changed!',
		nameLabel			: 'Label',
		nameTooltip			: 'The name/label of the field can contain simple HTML text markup (b, em, i, u, strong, small, sub, sup, font, br)',
	    nameRequired		: 'The name/label of the field must not be empty',
	    nameDuplicate		: 'There is already another field with the same name/label',
		titleLabel			: 'Title',
		titleTooltip		: 'The alternative title for table columns representing this field can also contain simple HTML text markup (b, em, i, u, strong, small, sub, sup, font, br)',
		descriptionLabel	: 'Description',
		descriptionTooltip	: 'Optional tooltip/description of this field (plain text only)',
		permissionsTitle	: 'Field Access',
		permissionsLabel	: 'Permissions',
		distributeLabel		: 'Distribution rule',
		aggregateLabel		: 'Aggregation rule',
		listableLabel		: 'List',
		listableTooltip		: 'Is this field appearing in the tracker-lists?',
		hiddenLabel			: 'Hidden',
		hiddenTooltip		: 'If activated, this field will not be shown on the GUI.',
		breakRowTooltip		: 'Start a new line with this field?',
		contentLabel		: 'Content',
		membersLabel		: 'Members',
		formatLabel			: 'Layout',
		computedLabel		: 'computed',
		computedTitle		: 'The read-only field value is computed from other field values',
		formulaLabel		: 'Computed as',
		formulaTitle		: 'The Unified Expression Language script to compute the field value',
		formattedLabel		: 'formatted',
		formattedTitle		: 'Show formatted number with decimal grouping ?',
		multipleLabel		: 'multiple',
		multipleTitle		: 'Can the field have multiple values?',
		dependsOnLabel		: 'depends on',
		dependsOnTitle		: 'The other choice field, the current field values depends on',
		visibilityLabel		: 'Visibility',
		visibilityTitle		: 'The default visibility of comments/attachments created by members in specific roles',
		visibilityNone		: 'No restrictions, Everybody by default',
		visibilityMore		: 'Add restrictions per role ...',
		roleLabel			: 'Role',
		combinationsTitle	: 'Field value combinations',
		layoutLabel			: 'Layout and Content',
		datasourceLabel		: 'Datasource',
		datasourceTooltip	: 'Please select datasource of the choice field from the dropdown list.',
		sizeLabel			: 'Size',
		sizeTitle			: 'The size of the input field (width in number of characters x height in number of lines)',
		lengthLabel			: 'Length',
		lengthTitle			: 'Length of the field in number of characters',
		widthLabel			: 'Width',
		widthTitle			: 'Width of the field in number of characters',
		heightLabel			: 'Height',
		heightTitle			: 'Height of the field in number of lines/rows',
		minValueLabel		: 'min.',
		minValueTitle		: 'Smallest allowed field value',
		maxValueLabel		: 'max.',
		maxValueTitle		: 'Largest allowed field value',
		numberedLabel		: 'Row numbers',
		numberedTitle		: 'Show an extra column with the table row numbers ?',
		colPermsLabel		: 'Column permissions',
		colPermsTitle		: 'Should each column of this table have individual access permissions ?',
		colspanTitle		: 'How many columns of the 3-column editor mask should this field span',
		newlineLabel		: 'Newline',
		noText				: 'No',
	    submitText    		: 'OK',
	    cancelText   		: 'Cancel',
	    trueValueText		: 'true',
		falseValueText		: 'false',
		propagateSuspectedLabel		: 'Propagate suspects',
		propagateSuspectedTitle		: 'Should this association be marked \'Suspected\' whenever the association target is modified?',
		reversedSuspectLabel		: 'Reverse direction',
		reversedSuspectTitle		: 'Original, source work item should be suspected.',
		bidirectionalSuspectLabel	: 'Bidirectional suspect',
		bidirectionalSuspectTitle	: 'Both source and target work item should be suspected',
		defaultReferenceVersionTypeLabel		: 'Default version',
		defaultReferenceVersionTypeTitle		: 'Default version of referred item.',
		defaultReferenceVersionTypeHead		: 'HEAD',
		omitSuspectedChangeLabel : 'Omit Suspected when changing',
        omitSuspectedChangeTitle : 'When this ticked on the suspected feature will not mark the item as Suspected when this field was changed',
        omitSuspectedChangeAfterLabel : 'omit'
	};

	$.fn.trackerFieldsConfiguration._setup = true;
	$.fn.trackerFieldsConfiguration.currentProjectId = null;

	$.fn.fieldConfigurationForm.currentTrackers = null;
	$.fn.fieldConfigurationForm.getProjectsRequest = null;

	// Final plugin to retrieve the field configurations
	$.fn.getTrackerFieldsConfiguration = function() {
		var fields = [];

		$('table.fieldsConfiguration > tbody', this).each(function() {
			var field = $('tr:first', this).data('field');

			if (field['class'] == 'table') {
				field.columns = [];

				$('tr.tableColumn', this).each(function() {
					field.columns.push($(this).data('field'));
				});
			}

			fields.push(field);
		});

		return fields;
	};

})( jQuery );
