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

	// Tracker Escalation Rules configuration Plugin definition.
	$.fn.trackerEscalationRules = function(tracker, escalations, options) {
		var settings = $.extend( {}, $.fn.trackerEscalationRules.defaults, options );
		settings.filterConfiguration.nameLabel = settings.filterNameLabel;

		function getSetting(name) {
			return settings[name];
		}

		function showItemFilter(selector, tracker, filterId, callback) {
			var view = {
  				tracker_id      : tracker.id,
  				viewTypeId      : 1,
  				viewLayoutId    : 0,
  				forcePublicView : true
  	  		};

			if (filterId != null) {
				view.view_id = filterId;
			}

			var popup = selector.next('div.filterPopup');
  			if (popup.length == 0) {
  				popup = $('<div>', { "class" : 'filterPopup', style : 'display: None;'} );
  				popup.insertAfter(selector);
  			}

  			popup.showTrackerViewConfigurationDialog(view, settings.filterConfiguration, {
				title			: filterId != null ? settings.filterEditTitle : settings.filterNewTitle,
				position		: { my: "center", at: "center", of: window, collision: 'fit' },
				modal			: true,
				closeOnEscape	: false,
				editable		: true,
  				viewUrl			: settings.trackerViewUrl,
  				submitText		: settings.submitText,
  				cancelText		: settings.cancelText

  			}, callback);
		}

		function createItemsLink(escalation, tracker, items) {
			if (items && items.id) {
				var itemCont = $('<span class="itemCont"></span>');
				var removeButton = $('<span class="removeButton" title="Remove this item"></span>');
				removeButton.click(function() {
					if (confirm(getSetting('itemsRemoveConfirm'))) {
						removeItem(escalation);
					}
				});
				if (settings.editable) {
					itemCont.append(removeButton);
				}
				itemCont.append($('<b>' + settings.rulesOfLabel + ' </b>'));
				itemCont.append($('<a>', { title : items.description }).text(items.name).click(function() {

					var link = $(this);

					showItemFilter(escalation, tracker, items.id, function(result) {
	      				if (result && result.name != null) {
	      					items.name = result.name;
	      					items.description = result.description;
	      					link.text(result.name).attr('title', result.description);
	      				}
	      			});

		  			return false;
				}));
				escalation.append(itemCont);
			}
		}

		function getAnchorLabel(anchor) {
			for (var i = 0; i < settings.anchors.length; ++i) {
				if (settings.anchors[i].value == anchor) {
					return settings.anchors[i].label;
				}
			}
			return settings.rulesLastLabel;
		}

		function getUnitLabel(unit) {
			for (var i = 0; i < settings.units.length; ++i) {
				if (settings.units[i].id == unit) {
					return settings.units[i].name;
				}
			}
			return 'Undefined';
		}

		function getRule(item) {
			var rule = $.extend({}, item.data('rule'));

			rule.offset = $('input[type="text"][name="offset"]', item).val();
			rule.unit   = parseInt($('select[name="unit"]', item).val());

			if (rule.anchor != 'AFTER_LAST_ESCALATION') {
				rule.anchor = $('select[name="anchor"]', item).val();

				var field = $('select[name="field"] > option:selected', item);
				rule.field = {
					id   : parseInt(field.val()),
					name : field.text()
				};
			}

			var status = $('select[name="status"] > option:selected', item);
			var statusId = parseInt(status.val());
			if (isNaN(statusId)) {
				rule.status = null;
			} else {
				rule.status = {
					id   : statusId,
					name : status.text()
				};
			}

			rule.notify = $('td.notify', item).getReferences();
			return rule;
		}

		function setRule(item) {
			item.data('rule', getRule(item));
			return '';
		}

		function addAddRuleHandler(button, table) {
			button.click(function() {
				var rules = $('tr.escalationRule', table);
				var lastRule = rules.last();

				var newEmptyRuleRow = newRuleRow({
					offset : '8',
					unit   : 5, //hours
					anchor : settings.anchors[1].value,
					field  : null,
					status : null,
					notify : []
				});

				var lastRuleData = lastRule.data('rule');
				lastRuleData.anchor == 'AFTER_LAST_ESCALATION' ?
					newEmptyRuleRow.insertBefore(lastRule) :
					newEmptyRuleRow.insertAfter(lastRule);

				iterateLevels(table);
			});
		}

		function addAddLastRuleHandler(button, table) {
			button.click(function() {
				button.remove();
				var lastItem = $('tr.escalationRule', table).last();
				newRuleRow({
					offset : '8',
					unit   : 5, //hours
					anchor : 'AFTER_LAST_ESCALATION',
					field  : null,
					status : null,
					notify : []
				}).insertAfter(lastItem);
				iterateLevels(table);
			});
		}

		function removeItem(list) {
			var filter = list.data().escalation.items;
			var selector = $('select.escalationItemsSelector');
			selector.closest('.selector').show();
			selector.append($('<option>', { value : filter.id, title : filter.description }).text(filter.name));
			list.remove();
		}

		function removeRule(row) {
			if (confirm(getSetting('rulesRemoveConfirm'))) {
				var list     = row.closest('li.escalation');
				var table    = list.find('table');
				var rule     = row.data('rule');

				row.remove();

				iterateLevels(table);

				var items = $('tr.escalationRule', list);

				if (rule.anchor == 'AFTER_LAST_ESCALATION') {
					// if the "After last escalation" rule was removed and other rules still exist
					if (items.length > 0) {
						// Add the "After last escalation" option to the selector
						var addLastRuleButton = $('<a>' + i18n.message('tracker.escalation.rule.last.add') + '</a>');
						addAddLastRuleHandler(addLastRuleButton, table);
						$('.moreRules', list).append(addLastRuleButton);
					}
				} else if (items.length == 1 && items.data('rule').anchor == 'AFTER_LAST_ESCALATION') {
					removeItem(list);
				}

				if (items.length == 0) {
					removeItem(list);
				}
			}
		}

		function addEscalationTable(item) {
			var table = $('<table>', { "class": 'expandTable displaytag'});
			var headerTr = $('<tr></tr>');
			headerTr.append(
				$('<th style="width: 2%"></th>'),
				$('<th class="numberData" style="width: 2%">' + i18n.message('tracker.escalation.level.label') + '</th>'),
				$('<th class="numberData">' + i18n.message('tracker.escalation.offset.label') + '</th>'),
				$('<th class="textData">' + i18n.message('tracker.escalation.unit.label') + '</th>'),
				$('<th class="textData">' + i18n.message('tracker.escalation.anchor.label') + '</th>'),
				$('<th class="textData">' + i18n.message('tracker.escalation.field.label') + '</th>'),
				$('<th class="textData">' + i18n.message('tracker.escalation.update_status.label') + '</th>'),
				$('<th style="width: 10%" class="textData">' + i18n.message('tracker.escalation.send_notif.label') + '</th>')
			);
			table.append(headerTr);
			item.append(table);
			return table;
		}

		function iterateLevels(table) {
			table.find('td.level').each(function(index, element) {
				$(this).text(index + 1);
			});
		};

		function newRuleRow(rule) {

			var row = $('<tr>', { "class" : (rule.anchor == 'AFTER_LAST_ESCALATION' ? 'escalationRule' : 'escalationRule sortable') }).data('rule', rule);

			function getRemoveButtonTd() {
				var removeButton = $('<span class="removeButton" title="Remove this rule" style="top: -1px"></span>');
				removeButton.click(function() {
					removeRule(row);
				});
				var td = $('<td class="textData" style="width: 2%"></td>');
				if (settings.editable) {
					td.append(removeButton);
				}
				return td;
			}

			function getLevelTd() {
				return $('<td class="numberData level" style="width: 2%"></td>');
			}

			function getOffsetTd() {
				var input = $('<input>', { type : 'text', name : 'offset', value : rule.offset, size : 10, maxlength : 255, title : getSetting('offsetTitle'), style : 'text-align: right;' });
				input.change(function() {
					setRule(row);
				});
				return $('<td class="numberData">').append(input);
			}

			function getUnitTd() {
				var unitSelector = $('<select>', { name : 'unit' });
				var units = getSetting('units');
				for (var i = 0; i < units.length; ++i) {
					unitSelector.append($('<option>', { value : units[i].id, selected : (rule.unit == units[i].id) }).text(units[i].name));
				}
				unitSelector.change(function() {
					setRule(row);
				});
				return $('<td class="textData"></td>').append(unitSelector);
			}

			function getAnchorAndFieldTd() {
				var anchorTd = $('<td class="textData"></td>');
				var fieldTd = $('<td class="textData"></td>');
				if (rule.anchor == 'AFTER_LAST_ESCALATION') {
					anchorTd.text(getSetting('rulesLastLabel'));
				} else {
					var anchorSelector = $('<select>', { name : 'anchor' });
					anchorTd.append(anchorSelector);

					var anchors = getSetting('anchors');
					for (var i = 0; i < anchors.length; ++i) {
						anchorSelector.append($('<option>', { value : anchors[i].value, selected : (rule.anchor == anchors[i].value) }).text(anchors[i].label));
					}

					var fieldSelector =  $('<select>', { name : 'field', style : 'width: 200px' });
					fieldTd.append(fieldSelector);

					anchorSelector.change(function() {
						$.get(getSetting('anchorFieldsUrl'), { anchor : this.value }).done(function(fields) {
							fieldSelector.empty();
							for (var i = 0; i < fields.length; ++i) {
								fieldSelector.append($('<option>', { value : fields[i].id, selected : (rule.field && rule.field.id == fields[i].id) }).text(fields[i].name));
							}
							setRule(row);
						}).fail(function(jqXHR, textStatus, errorThrown) {
							console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
						});
					});
					anchorSelector.change();
					fieldSelector.change(function() {
						setRule(row);
					});
				}
				return {
					'anchor' : anchorTd,
					'field' : fieldTd
				};
			}

			function getStatusTd() {
				var statusTd = $('<td class="textData"></td>');
				var statusSelector = $('<select>', { name : 'status' });
				statusTd.append(statusSelector);

				statusSelector.append($('<option>', { value : '' }).text('--'));

				var status = getSetting('statuses');
				for (var i = 0; i < status.length; ++i) {
					statusSelector.append($('<option>', { value : status[i].id, selected : (rule.status && rule.status.id == status[i].id) }).text(status[i].name));
				}

				statusSelector.change(function() {
					setRule(row);
				});

				return statusTd;
			}

			function getNotifyTd() {
				var notifyTd = $('<td style="width: 10%" class="notify textDataWrap"></td>');
				notifyTd.membersField(rule.notify, {
					htmlName	: 'notify',
					editable	: settings.editable,
					trackerId	: tracker.id,
					title		: getSetting('sendEmailLabel'),
					memberType	: 26, // Users, Roles and Member fields, but no Groups
					multiple	: true
				});

				// Wait a bit until membersField will be initialized
				setTimeout(function() {
					notifyTd.referenceFieldAutoComplete()
				}, 100);

				return notifyTd;
			}

			var anchorAndFieldTd = getAnchorAndFieldTd();
			row.append(
				getRemoveButtonTd(),
				getLevelTd(),
				getOffsetTd(),
				getUnitTd(),
				anchorAndFieldTd.anchor,
				anchorAndFieldTd.field,
				getStatusTd(),
				getNotifyTd()
			);

			setRule(row);

			return row;
		}

		function addEscalation(list, tracker, escalation) {
			if (!$.isPlainObject(escalation)) {
				escalation = { items : null, rules : [] };
			} else if (!$.isArray(escalation.rules)) {
				escalation.rules = [];
			}

			var item = $('<li>', { "class" : 'escalation'}).data('escalation', escalation);
			list.append(item);

			createItemsLink(item, tracker, escalation.items);

			if (escalation.rules.length > 0 || settings.editable) {

                var table = addEscalationTable(item);

				var afterLastRule = null;
				var moreRulesDiv = null;

				for (var i = 0; i < escalation.rules.length; ++i) {
					if (escalation.rules[i].anchor == 'AFTER_LAST_ESCALATION') {
						afterLastRule = escalation.rules[i];
					} else {
						var row = newRuleRow(escalation.rules[i]);
						table.append(row);
						setRule(row);
					}
				}

				if (afterLastRule != null) {
					var row = newRuleRow(afterLastRule);
					table.append(row);
					setRule(row);
				}

				iterateLevels(table);

				if (settings.editable) {

					if (escalation.rules.length == 0) {
						newRuleRow({
							offset : '8',
							unit   : 5, //hours
							anchor : settings.anchors[1].value,
							field  : null,
							status : null,
							notify : []
						}).insertAfter($('tr:first', table));
					}

					moreRulesDiv = $('<div class="moreRules"></div>');
					var addRuleButton = $('<a>' + i18n.message('tracker.escalation.rule.add') + '</a>');
					var addLastRuleButton = $('<a>' + i18n.message('tracker.escalation.rule.last.add') + '</a>');

					moreRulesDiv.append(addRuleButton);
					if (afterLastRule == null) {
						moreRulesDiv.append(addLastRuleButton);
					}

					var $deleteViewButton = $("<a>" + i18n.message("tracker.escalation.config.delete.escalation.view") + "</a>");
					$deleteViewButton.click(function() {
						showFancyConfirmDialogWithCallbacks(i18n.message("tracker.escalation.config.confirm.delete.escalation.view"), function() {
							$.ajax(contextPath + "/trackers/ajax/view.spr?tracker_id=" + tracker.id + "&view_id=" + escalation.items.id, {
								method: "DELETE"
							}).success(function() {
								window.location.reload();
							});
						});
					});
					moreRulesDiv.append($deleteViewButton);

					table.after(moreRulesDiv);

					addAddRuleHandler(addRuleButton, table);
					addAddLastRuleHandler(addLastRuleButton, table);

					/** Make the escalation rules/levels sortable */
			        table.find('tbody').sortable({
						items		: "> tr.escalationRule.sortable",
						containment	: item,
						axis		: "y",
						cursor		: "move",
						delay		: 150,
						distance	: 5,
						update		: function() {
							iterateLevels(table);
						}
					});
				}
			} else {
				item.append($('<div>', { "class" : 'hint' }).text(settings.rulesNoneLabel));
			}
		}

		function addSelectorDiv(container, tracker, escalations, list) {

			var selector = $('<select>', { "class" : 'escalationItemsSelector' }).data('tracker', tracker);
			var selectorDiv = $('<div class="selector"></div>');

			$.get(settings.itemFiltersUrl, {tracker_id : tracker.id}).done(function(filters) {
				if (filters.length == 0) {
					var warning = $("<div>", {"class": "warning"});
					warning.html(i18n.message("tracker.escalation.no.view.message"));
					$("div.escalations").before(warning);
				}
				for (var i = 0; i < filters.length; ++i) {
					var present = false;
					for (var j = 0; j < escalations.length; ++j) {
						if (escalations[j].items.id == filters[i].id) {
							present = true;
							break;
						}
					}
					if (!present) {
						selector.append($('<option>', { value : filters[i].id, title : filters[i].description }).text(filters[i].name));
					}
				}
				if ($('option', selector).length == 0) {
					selectorDiv.hide();
				}
			}).fail(function(jqXHR, textStatus, errorThrown) {
				console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			});

			var addButton = $('<a>' + i18n.message('button.add') + '</a>');
			selectorDiv.append(
				i18n.message('tracker.escalation.item.add') + ' ',
				selector,
				addButton
			);
			container.append(selectorDiv);

			addButton.click(function() {

				var option = $('option:selected', selector);
				var value = selector.val();
				if (value !== null) {
					addEscalation(list, tracker, {
						items: {
							id: parseInt(value),
							name: option.text(),
							description: option.attr('title')
						},
						rules: []
					});
				}

				option.remove();

				if ($('option', selector).length == 0) {
					selectorDiv.hide();
				}

			});
		}

		function init(container, tracker, escalations) {

			$(".newEscalationViewLink").click(function() {
				var referrer = encodeURIComponent("window.opener:" + "/proj/tracker/configuration.spr?tracker_id=" + tracker.id + "&orgDitchnetTabPaneId=tracker-customize-escalation");
				showPopupInline(contextPath + "/proj/tracker/view.spr?tracker_id=" + tracker.id + "&view_id=-1&referrer=" + referrer, { geometry: "large"});
			});

			if (!$.isArray(escalations)) {
				escalations = [];
			}

			if (escalations.length > 0 || settings.editable) {
				var list = $('<ul>', { "class" : "escalations" }).data('tracker', tracker);
				container.append(list);

				for (var i = 0; i < escalations.length; ++i) {
					addEscalation(list, tracker, escalations[i]);
				}

				if (settings.editable) {
					addSelectorDiv(container, tracker, escalations, list);
				}

			} else {
				container.append($('<div>', { "class" : 'hint' }).text(settings.itemsNoneLabel));
			}
		}

		if ($.fn.trackerEscalationRules._setup) {
			$.fn.trackerEscalationRules._setup = false;
		}

		return this.each(function() {
			init($(this), tracker, escalations);
		});
	};

	$.fn.trackerEscalationRules.defaults = {
		editable			: false,
		anchors				: [{ value : 'BEFORE',                  label : 'before' },
		       				   { value : 'AFTER',                   label : 'after' },
		       				   { value : 'AFTER_LAST_MODIFICATION', label : 'after last modification of' }],
		units				: [],
		statuses			: [],
		itemFiltersUrl		: '',
		trackerViewUrl		: '',
		anchorFieldsUrl		: '',
		ruleValidationURL	: '',
		trackerCreateViewURL: '',
		rulesOfLabel		: 'Escalation rules of',
		itemsLabel			: 'For such items',
		itemsNoneLabel		: 'No items with escalation',
		itemsMoreLabel		: 'More...',
		itemsRemoveLabel	: 'Remove',
		itemsRemoveConfirm	: 'Do you really want to remove the escalation rules for these items?',
		filterNewLabel		: 'New',
		filterNewTitle		: 'Create a new item filter',
		filterEditLabel		: 'Edit',
		filterEditTitle		: 'Edit the selected item filter',
		filterNameLabel		: 'Name',
		filterConfiguration : {	hide : ['visibility', 'layout', 'fields', 'orderBy', 'charts'] },
		ruleLabel			: 'Escalation rule',
		rulesLabel			: 'Escalation rules',
		rulesNoneLabel		: 'None',
		rulesMoreLabel		: 'More...',
		rulesEditHint		: 'Double click to edit this rule',
		rulesRemoveLabel	: 'Remove',
		rulesRemoveConfirm	: 'Do you really want to remove this escalation rule?',
		rulesLastLabel		: 'after last escalation',
		levelLabel			: 'Level',
		anchorLabel			: 'Anchor',
		offsetLabel			: 'Offset',
		offsetTitle			: 'Offset (of working time) relative to anchor (field)',
		updateStatusText	: 'Update item status to XXX',
		updateStatusLabel   : 'Update status to',
		updateStatusTitle	: 'At this escalation level, update the item status to this value',
		sendEmailText		: 'Alert XXX by email',
		sendEmailLabel		: 'Send email to',
		submitText			: 'OK',
		cancelText			: 'Cancel',
		infobox				: $.fn.objectInfoBox.defaults
	};

	$.fn.trackerEscalationRules._setup = true;


	// Tracker Escalation Rules configuration Plugin definition.
	$.fn.getEscalationRules = function(validationUrl) {

		var result = [];

		$('ul.escalations > li.escalation', this).each(function() {
			var escalation = $(this);

			var rules = [];
			$('tr.escalationRule', escalation).each(function(index, element) {
				var rule = $(this).data('rule');

				var validationResult = false;
				rules.push(rule);
				rules[index].notify = $('td.notify', $(this)).getReferences();

				$.ajax(validationUrl, {
					type		: 'POST',
					async		: false,
					data 		: JSON.stringify(rule),
					contentType : 'application/json',
					dataType 	: 'json'
				}).done(function(result) {
					validationResult = true;
				}).fail(function(jqXHR, textStatus, errorThrown) {
					validationResult = false;
				});

			});

			result.push({
				items : escalation.data('escalation').items,
				rules : rules
			});
		});

		return result;
	};


})( jQuery );

