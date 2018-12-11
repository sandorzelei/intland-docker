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

	$.fn.showTraceabilityBrowser = function(result, exportUrl, exportColumnLimit, assocUrls, refTypeUrls, revisionId, levelReferenceTypes) {


		function highlightCells(table) {

			var countColumns = function(tr) {
				var count = 0;
				$(tr.children(':not(.referencingTrackers)')).each(function () {
					if ($(this).attr('colspan')) {
						count += +$(this).attr('colspan');
					} else {
						count++;
					}
				});
				return count;
			};

			var hoverTds = function(tr, n) {
				var maxColumn = countColumns(tr.closest('table:not(.referencingTrackers)').find('tr:first'));
				tr.find('td[rowspan]:not(.referencingTrackers)').slice(0,n).addClass("hover");
				if (countColumns(tr) < maxColumn) {
					hoverTds(tr.prevAll('tr:has(td[rowspan]:not(.referencingTrackers)):first'), maxColumn - countColumns(tr));
				}
			};

			var getHoverTds = function(td) {
				return td.siblings(':not(.referencingTrackers)').addBack();
			};

			var getHoverNextTds = function(td) {
				var tr = td.parent();
				var tdRowspan = td.attr('rowspan');
				var nextTds = $();
				if (typeof tdRowspan !== "undefined") {
					var nextTrs = tr.nextAll('tr').slice(0, tdRowspan - 1);
					nextTds = nextTrs.find('td:not(.referencingTrackers)');
				}
				return nextTds;
			};

			table.on('mouseenter', 'td:not(.referencingTrackers)', function() {
				getHoverTds($(this)).addClass('hover');
				getHoverNextTds($(this)).addClass('hover');
				var td = $(this);
				var maxColumn = countColumns(td.closest('table:not(.referencingTrackers)').find('tr:first'));
				if (countColumns(td.parent()) < maxColumn ) {
					hoverTds(td.parent().prevAll('tr:has(td[rowspan]:not(.referencingTrackers)):first'), maxColumn - countColumns(td.parent()));
				}
			});

			table.on('mouseleave', 'td:not(.referencingTrackers)', function() {
				getHoverTds($(this)).removeClass('hover');
				getHoverNextTds($(this)).removeClass('hover');
				$(this).parent().prevAll('tr:has(td[rowspan]:not(.referencingTrackers))').find('td[rowspan]:not(.referencingTrackers)').removeClass("hover");
			});

		}

		function filterColumn($sign, assocIn, assocOut, refIn, refOut) {

			var hideItem = function($el) {
				$el.html("--");
				$el.prev("td").html("");
			};

			var showItem = function($el) {
				$el.html($el.data("oldData"));
				$el.prev("td").html($el.prev("td").data("oldData"));
			};

			var index = $sign.attr("data-index");
			$("#traceabilityResultTable").find('td.name').each(function() {
				if (($(this).cellPos().left + 1) / 2 - 1 == index) {
					var reference = $(this).attr("data-is-relation") == "true";
					var association = $(this).attr("data-is-association") == "true";
					var outgoing = $(this).attr("data-is-outgoing") == "true";
					var incomingReference = reference && !outgoing;
					var outgoingReference = reference && outgoing;
					var incomingAssociation = association && !outgoing;
					var outgoingAssociation = association && outgoing;
					if (!assocIn && incomingAssociation) {
						hideItem($(this));
					} else if (!assocOut && outgoingAssociation) {
						hideItem($(this));
					} else if (!refIn && incomingReference) {
						hideItem($(this));
					} else if (!refOut && outgoingReference) {
						hideItem($(this));
					} else {
						showItem($(this));
					}
				}
			});
		}

		function initReferenceTypeSelectors(container) {

			container.find("td").each(function() {
				$(this).data("oldData", $(this).html());
			});

			container.find(".levelReferenceSetting").each(function() {
				filterColumn($(this), $(this).attr("data-assocIn") == "true", $(this).attr("data-assocOut") == "true", $(this).attr("data-refIn") == "true", $(this).attr("data-refOut") == "true");
			});

			container.on("click", ".levelReferenceSetting", function() {
				$(".levelSettingContainer").remove(); // remove others from the screen
				var $levelSettingSign = $(this);

				var $settingCont = $("<div>", { "class" : "levelSettingContainer"});

				var $assoc = $("<div>", { "class": "levelSettingTitle"}).text(i18n.message("tracker.traceability.browser.show.associations"));
				$assoc.append($("<br>"));
				$assoc.append($("<input>", { type: "checkbox", id: "levelSetting_assoc_incoming", checked: $levelSettingSign.attr("data-assocIn") == "true"}));
				$assoc.append($("<label>", { "for": "levelSetting_assoc_incoming"}).text(i18n.message("tracker.traceability.browser.incoming")));
				$assoc.append($("<br>"));
				$assoc.append($("<input>", { type: "checkbox", id: "levelSetting_assoc_outgoing", checked: $levelSettingSign.attr("data-assocOut") == "true"}));
				$assoc.append($("<label>", { "for": "levelSetting_assoc_outgoing"}).text(i18n.message("tracker.traceability.browser.outgoing")));
				$settingCont.append($assoc);

				var $ref = $("<div>", { "class": "levelSettingTitle"}).text(i18n.message("tracker.traceability.browser.show.relations"));
				$ref.append($("<br>"));
				$ref.append($("<input>", { type: "checkbox", id: "levelSetting_ref_incoming", checked: $levelSettingSign.attr("data-refIn") == "true"}));
				$ref.append($("<label>", { "for": "levelSetting_ref_incoming"}).text(i18n.message("tracker.traceability.browser.incoming")));
				$ref.append($("<br>"));
				$ref.append($("<input>", { type: "checkbox", id: "levelSetting_ref_outgoing", checked: $levelSettingSign.attr("data-refOut") == "true"}));
				$ref.append($("<label>", { "for": "levelSetting_ref_outgoing"}).text(i18n.message("tracker.traceability.browser.outgoing")));
				$settingCont.append($ref);

				var $okButton = $("<button>",{ "class": "button"}).text(i18n.message("button.ok"));
				$okButton.click(function() {
					var $cont = $(this).closest(".levelSettingContainer");
					var assocIn = $cont.find("#levelSetting_assoc_incoming").prop("checked") == true;
					var assocOut = $cont.find("#levelSetting_assoc_outgoing").prop("checked") == true;
					var refIn = $cont.find("#levelSetting_ref_incoming").prop("checked") == true;
					var refOut = $cont.find("#levelSetting_ref_outgoing").prop("checked") == true;
					filterColumn($levelSettingSign, assocIn, assocOut, refIn, refOut);
					$levelSettingSign.attr("data-assocIn", assocIn ? "true" : "false");
					$levelSettingSign.attr("data-assocOut", assocOut ? "true" : "false");
					$levelSettingSign.attr("data-refIn", refIn ? "true" : "false");
					$levelSettingSign.attr("data-refOut", refOut ? "true" : "false");
					$(this).closest(".levelSettingContainer").remove();
				});
				$settingCont.append($okButton);

				var $cancelButton = $("<button>", { "class": "button cancelButton"}).text(i18n.message("button.cancel"));
				$cancelButton.click(function() {
					$(this).closest(".levelSettingContainer").remove();
				});
				$settingCont.append($cancelButton);

				$("body").append($settingCont);
				$settingCont.position({
					of: $levelSettingSign,
					my: "left top",
					at: "left bottom",
					collision: "flipfit"
				});

				return false;
			});
		}

		function parseExistingLevelSetting(levelSetting, index) {
			if (typeof levelSetting === "undefined" || levelSetting == null || levelSetting.length == 0) {
				return [true, true, true, true];
			}
			var levels = levelSetting.split(",");
			for (var i = 0; i < levels.length; i++) {
				var parts = levels[i].split("-");
				var levelIndex = parts[0];
				if (levelIndex == index) {
					var settings = parts[1];
					return [settings[0] == 1, settings[1] == 1, settings[2] == 1, settings[3] == 1];
				}
			}
			return [true, true, true, true];
		}

		function init(container, result) {

			var jsonResult = $.parseJSON(result);
			var rows = jsonResult["rows"];
			var trackerParams = jsonResult["trackers"];
			var originalParameters = jsonResult["originalParameters"];
			var ignoredList = jsonResult["ignoredList"];
			var showSuggestions = jsonResult["showSuggestions"];
			if (showSuggestions) {
				var referencingTrackersAndTypes = jsonResult["referencingTrackersAndTypes"];
				if (referencingTrackersAndTypes) {
					var preferred = referencingTrackersAndTypes["preferred"];
					var other = referencingTrackersAndTypes["other"];
				}
			}
			var trackers = [];

			var selectedTrackers = $("#selectedTrackers");
			selectedTrackers.find("li[data-tracker-id]").remove();
			trackers.push($("table.selectedTrackers tr.currentTracker").clone());

			var hasIgnoredLevel = false;
			$(".controlContainer").find(".levelContainer.droppable").each(function(index, el) {
				var numberOfItems = ignoredList[index+1];
				if (typeof numberOfItems !== "undefined") {
					var $numberOfItemsSpan = $(this).find(".numberOfItems");
					if (numberOfItems == 0) {
						hasIgnoredLevel = true;
						$numberOfItemsSpan.find(".ignore").show();
						$(this).closest("tr").addClass("ignoredLevel");
					} else {
						$numberOfItemsSpan.find(".ignore").hide();
						$(this).closest("tr").removeClass("ignoredLevel");
					}
					$numberOfItemsSpan.find(".resultNumber").text(numberOfItems);
					$numberOfItemsSpan.show();
				}
			});

			container.empty();

			if (hasIgnoredLevel) {
				var ignoredInfo = $('<div class="information">' + i18n.message('tracker.traceability.browser.ignored.info') + '</div>');
				container.append(ignoredInfo);
			}

			var table = $('<table id="traceabilityResultTable" class="tb">');

			var tHead = $('<thead>');
			var headTr = $('<tr>');
			for (var i = 0; i < trackerParams.length; i++) {
				var levels = trackerParams[i];
				var $levelReferenceSetting = $('<a title="' + i18n.message("tracker.traceability.browser.filter.level") + '" href="#" class="levelReferenceSetting" data-index="' + i + '">&#10095;</a>');
				var levelSettings = parseExistingLevelSetting(levelReferenceTypes, i);
				$levelReferenceSetting.attr("data-assocIn", levelSettings[0] ? "true" : "false");
				$levelReferenceSetting.attr("data-assocOut", levelSettings[1] ? "true" : "false");
				$levelReferenceSetting.attr("data-refIn", levelSettings[2] ? "true" : "false");
				$levelReferenceSetting.attr("data-refOut", levelSettings[3] ? "true" : "false");
				var typeTh = $('<th class="referenceType"></th>');
				if (i != 0) {
					typeTh.append($levelReferenceSetting);
				}
				var th = $('<th></th>');
				var levelHeaderText = i == 0 ? i18n.message("tracker.traceability.browser.initial.trackers") : i18n.message("tracker.traceability.browser.level") + ' ' + i;
				th.append('<span class="levelHeader">' + levelHeaderText + '</span>');
				for (var j = 0; j < levels.length; j++) {
					var parameter = levels[j];
					var iconUrl = parameter.numericId != 0 ? contextPath + parameter.iconUrl : contextPath + '/images/issuetypes/issue.png';
					th.append('<img src="' + iconUrl + '" style="background-color: #5f5f5f">');
					th.append('<span class="trackerName">' + parameter.label + '</span>');
				}
				headTr.append(typeTh);
			 	headTr.append(th);
			}
			tHead.append(headTr);
			table.append(tHead);

			var appendRefTr = function(table, item, preferred) {
				var refTr = $('<tr></tr>');
				if (!item.trackerType) {
					refTr.append($('<td class="referencingTrackers"></td>'));
				}
				refTr.append($('<td class="referencingTrackers refCode"><img style="background-color: ' + item.iconBgColor + '" src="' + contextPath + item.iconUrl + '"></td>'));
				var refTdName = $('<td class="referencingTrackers" colspan="' + (item.trackerType ? 2 : 1) + '">' + (preferred ? '<b>' : '') + '<a class="referenceTracker" href="#" data-id="' + item.id + '" data-tracker-type-id="' + (item.trackerType ? item.id : item.trackerTypeId) + '">' + item.name + '</a>' + (preferred ? '</b>' : '') + '</td>');
				if (item.relation) {
					refTdName.append($('<img class="refType" src="' + refTypeUrls.relation + '">'));
				}
				refTr.append(refTdName);
				table.append(refTr);
			};

			var tBody = $('<tbody>');
			for (var i = 0; i < rows.length; i++) {
				var row = rows[i];
				var tr = $('<tr>');
				for (var j = 0; j < row.cells.length; j++) {
					var cell = row.cells[j];
					var name = (cell.title == null || cell.title.length == 0) ? '<span class="empty">--</span>' : cell.title;
					var code = (cell.code == null || cell.code.length == 0) ?  '--' : '[' + cell.code + ']';
					var tooltipContainerAttributes = cell.wikiLink ? ' data-hover-tooltip="true" data-wikilink="' + cell.wikiLink + '" ' : '';
					var tooltipTargetAttributes = cell.wikiLink  ? ' data-hover-tooltip-target ' : '';
					var isRelation = cell.referenceType == "RELATION" || cell.referenceType == "COMBINED" || cell.referenceType == "COMMIT" ? "true" : "false";
					var isAssociation = cell.referenceType == "ASSOCIATION" || cell.referenceType == "COMBINED" ? "true" : "false";
					var dataInfo = ' data-index="' + j + '" data-is-relation="' +  isRelation + '" data-is-association="' + isAssociation + '" data-is-outgoing="' + (cell.outgoing ? 'true' : 'false') + '"';
					var icon = '';
					if (cell.iconUrl && cell.iconBgColor) {
						icon = '<img src="' + cell.iconUrl + '" class="tableIcon" style="background-color:' +
							cell.iconBgColor + ';"' + tooltipTargetAttributes + '/>';
					}
					var nameTdText = "--";
					if (code != '--') {
						nameTdText = icon + '<a href="' + cell.url + '" target="_blank" class="itemLink">' + code + ' ' + name + '</a>';
					}
					var nameTd = $('<td class="name"' + dataInfo + tooltipContainerAttributes + '>' + nameTdText + '</td>');
					if (cell.associationType.length > 0) {
						var assoc = $('<span class="assocType"></span>');
						var tooltipString = "";
						var assocImgUrl = "";
						if (cell.associationType == "copy of") {
							assocImgUrl = assocUrls.copy;
							tooltipString = i18n.message('association.typeId.copy of');
						} else if (cell.associationType == "depends") {
							assocImgUrl = assocUrls.depends;
							tooltipString = i18n.message('association.typeId.depends');
						}
						if (assocImgUrl.length > 0) {
							assoc.append($('<img title="' + tooltipString + '" src="' + assocImgUrl + '">'));
							nameTd.append(assoc);
						}
					}

					if (cell.propagateSuspect) {
						var suspectedTitle = i18n.message("association.propagatingSuspects.label") + (cell.reverseSuspect ? " (" + i18n.message("tracker.field.reversedSuspect.label") + ")" : "");
						var $suspectedBadge = $('<span title="' + suspectedTitle + '" class="referenceSettingBadge psSettingBadge' + (cell.suspected ? ' active' : '') + '">' + i18n.message("tracker.view.layout.document.reference.suspected") + '</span>');
						if (cell.reverseSuspect) {
							$suspectedBadge.append($('<span class="reverseSuspectImg"></span>'));
						}
						var badgeSpan = $("<span>", { "style" : "white-space: nowrap"});
						badgeSpan.append($("<span>", { "style" : "visibility: hidden"}).text("|"));
						badgeSpan.append($suspectedBadge);
						nameTd.append(badgeSpan);
					}

					var referenceTypeUrl = "";
					var referenceToolTip = "";
					if (cell.referenceType == "ASSOCIATION") {
						referenceTypeUrl = refTypeUrls.association;
						referenceToolTip = i18n.message("association.label");
					} else if (cell.referenceType == "RELATION") {
						referenceTypeUrl = refTypeUrls.relation;
						referenceToolTip = i18n.message("tracker.traceability.browser.relation");
					}
					var referenceTypeImg = "";
					if (cell.referenceType == "COMBINED") {
						referenceTypeImg = (cell.title == null || cell.title.length == 0 || cell.referenceType.length == 0) ? '' :
							'<img title="' + i18n.message("association.label") + '" src="' + refTypeUrls.association + '"><img title="' + i18n.message("tracker.traceability.browser.relation") + '" src="' + refTypeUrls.relation + '">';
					} else if (cell.referenceType != "COMMIT") {
						referenceTypeImg = (cell.title == null || cell.title.length == 0 || cell.referenceType.length == 0) ? '' : '<img title="' + referenceToolTip + '" src="' + referenceTypeUrl + '">';
					}
					var referenceTypeTd = $('<td class="referenceType">' + referenceTypeImg + '</td>');
					if (cell.testRunResult != null && cell.testRunResult.length > 0) {
						nameTd.append($('<span class="' + cell.testRunResultCssClass + '">' + cell.testRunResult + '</span>'));
					}
					if (cell.rowSpan > 1) {
						referenceTypeTd.attr('rowspan', cell.rowSpan);
						nameTd.attr('rowspan', cell.rowSpan);
			 		}
					tr.append(referenceTypeTd);
			 		tr.append(nameTd);
			 	}
			 	tBody.append(tr);
			}

			table.append(tBody);

			if (showSuggestions && referencingTrackersAndTypes && (preferred.length > 0 || other.length > 0)) {
				var refTrackersDiv = $('<div class="refTrackers"></div>');
				var refTable = $('<table id="traceabilitySuggestedTable" class="referencingTrackers"></table>');
				var refHeader = $('<tr><th colspan="3" class="referencingTrackers">&#10095; ' + i18n.message("tracker.traceability.browser.info.refTypes.title") + '</th></tr>');
				refTable.append(refHeader);
				if (preferred.length > 0) {
					for (var k = 0; k < preferred.length; k++) {
						appendRefTr(refTable, preferred[k], true);
					}
				}
				if (other.length > 0) {
					for (var k = 0; k < other.length; k++) {
						appendRefTr(refTable, other[k], false);
					}
				}
				refTrackersDiv.append(refTable);
				refTable.find("a").click(function() {
					codebeamer.Traceability.addEntityFromSuggestedArea($(this));
				});
			}

			if (rows.length > 0) {
				var tableCont = $('<table class="tableContainer"></table>');
				var tableContRow = $('<tr></tr>');
				var traceabilityTable = $('<td class="traceabilityTable"></td>');
				traceabilityTable.append(table);
				var references = $('<td class="traceabilityTable"></td>');
				references.append(refTrackersDiv);
				tableContRow.append(traceabilityTable);
				tableContRow.append(references);
				tableCont.append(tableContRow);
				codebeamer.Traceability.highlightCells(table);
				container.append(tableCont);
				setStickyHeader();
				initReferenceTypeSelectors(container);
			} else {
				var noItem = $('<p style="margin: 0.5em">' + i18n.message('tracker.reference.choose.items.none') + '.</p>');
				container.append(noItem);
			}

		}

		return this.each(function() {
			init($(this), result, exportUrl);
		});
	};

	function scanTable( $table ) {
		var m = [];
		$table.children( "tr" ).each( function( y, row ) {
			$( row ).children( "td, th" ).each( function( x, cell ) {
				var $cell = $( cell ),
					cspan = $cell.attr( "colspan" ) | 0,
					rspan = $cell.attr( "rowspan" ) | 0,
					tx, ty;
				cspan = cspan ? cspan : 1;
				rspan = rspan ? rspan : 1;
				for( ; m[y] && m[y][x]; ++x );
				for( tx = x; tx < x + cspan; ++tx ) {
					for( ty = y; ty < y + rspan; ++ty ) {
						if( !m[ty] ) {
							m[ty] = [];
						}
						m[ty][tx] = true;
					}
				}
				var pos = { top: y, left: x };
				$cell.data( "cellPos", pos );
			} );
		} );
	}

	$.fn.cellPos = function( rescan ) {
		var $cell = this.first(),
			pos = $cell.data( "cellPos" );
		if( !pos || rescan ) {
			var $table = $cell.closest( "table, thead, tbody, tfoot" );
			scanTable( $table );
		}
		pos = $cell.data( "cellPos" );
		return pos;
	}

})( jQuery );

