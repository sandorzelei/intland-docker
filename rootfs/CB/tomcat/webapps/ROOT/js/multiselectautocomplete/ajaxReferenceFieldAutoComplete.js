/**
 * Javascript for setting up ajax reference field's autocomplete.
 * $Id$
 */

var ajaxReferenceFieldAutoComplete = {
	/**
	 * Initialize the ajax controls for reference field auto-completion.
	 *
	 * @param contextPath
	 * @param inputFieldId
	 *            The id of the input field for the auto-complete
	 * @param containerId
	 *            The id of the container for the auto-complete's popup
	 * @param ajaxURLParameters
	 *            The url parameters passed in the ajax request
	 * @param updatingElement
	 *            The update callback function is attached to this html element
	 * @param referenceInputElementId
	 *            The id hidden element contains values for selected reference
	 *            fields. Note: it is important that we use id, because the html
	 *            element is replaced from the popup
	 * @param multiSelect If the multi-select is enabled (multiple boxes can be selected by the widget).
	 * @param userSelectorMode True for user selector-mode, False for reference selector mode
	 *
	 * @param emptyId The reference-id when the box is considered empty. This is used when adding the "empty" box as id
	 * @param emptyHTML The text when no boxes are shown at all.
	 *
	 * @param onChangeCallback An optional javascript function will be called back when a new box added or removed (the scope is automatically set to the multiboxPanel)
	 * @param contextCallback An optional javascript function will be called back before sending a request to the server to add additional context information
	 * @param afterUpdateCallback An optional javascript function will be called back after the shadow references field has been updated
	 *
	 */
	init: function(contextPath, inputfieldId, containerId, ajaxURLParameters, updatingElement, referenceInputElementId, multiSelect,
				   userSelectorMode, acceptEmail, workItemMode, workItemTrackerIds, reportMode, emptyId, emptyHTML, onChangeCallback, contextCallback, afterUpdateCallback, existingJson) {
		// Copy value into id if work item mode (tokenInput accepts only id property)
		if (workItemMode) {
			for (var i = 0; i < existingJson.length; i++) {
				existingJson[i]["id"] = existingJson[i]["value"];
			}
		}

		// initializing data source
		var url;
		// using a different ajax-url for user selector
		if (userSelectorMode) {
			url = "/ajax/getUserFieldSuggestions.spr";
		} else {
			url = "/ajax/getReferenceFieldSuggestions.spr";
		}

		var input = $('#' + inputfieldId);
		var referenceInputElement = $('#' + referenceInputElementId);

		// Firefox caches the input field values after refreshing the page (F5) and this causes problems regarding
		// ajaxReferenceFieldAutoComplete fields. I find only this solution.
		// This is a hidden input field, and the suggested "autocomplete=off" is not applicable for hidden inputs.
		// That is why we need to set "autocomplete=off" for the entire form, but because of this, the built-in
		// autocomplete functionality will not work neither on text input fields.
		//
		// To be unified, switch off the built-in browser autocomplete in all browser.
		referenceInputElement.closest("form").attr("autocomplete", "off");

		// Avoid multiple initialization
		if (!input.data("initedTokenInput")) {
			input.tokenInput(function() {
				var queryParameters = ajaxURLParameters;
				if (contextCallback != null) {
					queryParameters += "&context=" + encodeURIComponent(contextCallback());
				}
				return contextPath + url + '?' + queryParameters + "&selectedItems=" + referenceInputElement.val();
			}, {
				queryParam: "autoCompleteFilter",
				theme: "facebook",
				minChars: 2, // number of characters required before starting ajax call
				resultsLimit: 15, // same as: AjaxServiceImpl.MAX_REFERENCE_SUGGESTION_RESULTS
				propertyToSearch: "shortHTML",
				jsonContainer: "resultset",
				tokenLimit: multiSelect ? null : 1,
				preventDuplicates: false,
				hintText: null,
				searchingText: null,
				noResultsText: "",
				searchDelay: 500,
				resultsFormatter: function(item) {
					if (item.detailedHTML) {
						return '<li>' + item.detailedHTML + '</li>';
					}
					return '<li>' + item.shortHTML + '</li>';
				},
				tokenFormatter: function(item) {
					var id = item.id;
					var html = "<li><p class='name" + (item.disabled && item.disabled !== "false" ? " disabled" : "") + "'>" + item.shortHTML + "</p>";
					// If reference is a tracker item reference
					if (!workItemMode && item.hasOwnProperty("trackerItemId") && item.trackerItemId !== null && item.trackerItemId != "null") {
						var uniqueId = Math.random().toString(36).substr(2, 9); // build a unique ID for tokenSetting

						var branchName = (item.hasOwnProperty("branchName") && item.branchName != null && item.branchName != "null") ? item.branchName : "";
						var version = (item.hasOwnProperty("version") && item.version != null && item.version != "null") ? item.version : 0;
						var associationId = item.hasOwnProperty("associationId") ? item.associationId : 0;
						var propagateSuspects = item.hasOwnProperty("propagateSuspects") ? item.propagateSuspects : false;
						var suspected = item.hasOwnProperty("suspected") ? item.suspected : false;
						var reverseSuspect = item.hasOwnProperty("reverseSuspect") ? item.reverseSuspect : false;
						var bidirectionalSuspect = item.hasOwnProperty('bidirectionalSuspect') ? item.bidirectionalSuspect : false;
						var isOutgoingSuspected = item.hasOwnProperty('isOutgoingSuspected') ? item.isOutgoingSuspected : false;
						var isIncomingSuspected = item.hasOwnProperty('isIncomingSuspected') ? item.isIncomingSuspected : false;
						var isDependencyCheckingSupported = item.hasOwnProperty('isDependencyCheckingSupported') ? item.isDependencyCheckingSupported : false;
						var propagateDependencies = item.hasOwnProperty('propagateDependencies') ? item.propagateDependencies : false;
						var hasUnresolvedDependencies = item.hasOwnProperty('unresolvedDependencies') ? item.unresolvedDependencies : false;
						
						html += "<span class='tokenSetting' title='" + i18n.message("reference.setting.title") + "' " +
							"data-initialized='false' " +
							"data-id='" + uniqueId + "' " +
							"data-tracker-item-id='" + item.trackerItemId + "' " +
							"data-branch-name='" + branchName + "' " +
							"data-version='" + version + "'" +
							"data-original-version='" + version + "'" +
							"data-association-id='" + associationId + "' " +
							"data-propagate-suspects='" + propagateSuspects + "' " +
							"data-suspected='" + suspected + "'" +
							"data-reverse-suspect='" + reverseSuspect + "'" +
							"data-bidirectional-suspect='" + bidirectionalSuspect + "'" +
							"data-is-outgoing-suspected='" + isOutgoingSuspected + "'" +
							"data-is-incoming-suspected='" + isIncomingSuspected + "'" +
							"data-is-dependency-checking-supported='" + isDependencyCheckingSupported + "'" +
							"data-propagate-dependencies='" + propagateDependencies + "'" + 
							"data-unresolved-dependencies='" + hasUnresolvedDependencies + "'></span>";
					}
					html += "</li>";
					return html;
				},
				prePopulate: existingJson,
				onReady: function() {
					$('#token-input-' + inputfieldId).css('width', '30px');
					input.data("initedTokenInput", true);
					ajaxReferenceFieldAutoComplete.initReferenceSettings(input);

					$(input).trigger('codebeamer:referenceFieldInitialized');
				},
				onAdd: function(item) {
					var $referenceInputElement = $("#" + referenceInputElementId);
					$referenceInputElement.closest(".reference-box").find('.tokenSetting[data-initialized="false"]').each(function() {
						ajaxReferenceFieldAutoComplete.addReferenceSettingBadges($(this));
					});
					//fix for #857669 and #942515
					$referenceInputElement
						.next('ul.token-input-list-facebook')
						.find('li.token-input-input-token-facebook input')
						.css({ width: '30px'});

					ajaxReferenceFieldAutoComplete.onTokenInputChange("onAdd", item, inputfieldId, referenceInputElementId, onChangeCallback, afterUpdateCallback);
				},
				onDelete: function(item) {
					ajaxReferenceFieldAutoComplete.onTokenInputChange("onDelete", item, inputfieldId, referenceInputElementId, onChangeCallback, afterUpdateCallback);
				},
				onResult: function(results) {
					// in Planner in some cases the result should be interrupted (meanwhile ESC or Enter pressed)
					if (codebeamer.planner && codebeamer.planner.interruptSuggestionsRendering()) {
						return {"resultset": []};
					}
					return results;
				}
			});

			updatingElement.reinitAjaxReferenceControl = function(referencesRendered) {
				input.tokenInput("clear");
				if (referencesRendered.length > 0) {
					for (var i = 0; i < referencesRendered.length; i++) {
						input.tokenInput("add", referencesRendered[i]);
					}
				}
				input.closest(".reference-box").find(".tokenSetting").each(function() {
					ajaxReferenceFieldAutoComplete.addReferenceSettingBadges($(this));
				});
			};

		}

		return input;

	},

	onTokenInputChange : function(type, item, inputfieldId, referenceInputElementId, onChangeCallback, afterUpdateCallback) {
		ajaxReferenceFieldAutoComplete.updateReferenceValues(inputfieldId, referenceInputElementId);
		if (onChangeCallback != null && typeof onChangeCallback != "undefined") {
			onChangeCallback.apply($(this), [type, item, inputfieldId]);
		}
		if (afterUpdateCallback != null) {
			afterUpdateCallback();
		}
		$('#' + referenceInputElementId).closest('form').trigger('checkform.areYouSure');
	},

	versionCache : {},
	baselineCache: {},

	initReferenceSettings : function($input) {

		var $referenceBox = $input.closest(".reference-box");
		var $dialog = $referenceBox.find(".referenceSettingDialog");
		// Check if dialog already appended to body
		var $existingDialog = $("body").children("#" + $dialog.attr("id"));
		if ($existingDialog.length > 0) {
			$existingDialog.remove();
		}
		// Append dialog to body to be visible pages using layout
		$dialog.detach().appendTo($("body"));

		var versionAbbr = i18n.message("reference.setting.version.abbr");
		var reverseSuspectImg = '<span class="reverseSuspectImg" />';
		var reverseSuspectLabel = i18n.message("reference.setting.reverse.suspect");

		var openReferenceSettingDialog = function($el, itemName, $dialog) {
			// Hide others
			$(".referenceSettingDialog").hide();

			$dialog.find(".referenceSettingTitle").text(i18n.message("reference.setting.of.title") + " " + itemName);
			$dialog.data("id", $el.attr("data-id"));
			
			var isDependencyCheckingSupported = $el.attr('data-is-dependency-checking-supported') == 'true'; 
			$dialog.find('div.propagateDependencies').toggle(isDependencyCheckingSupported);

			var trackerItemId = $el.attr("data-tracker-item-id");
			var version = $el.attr("data-version");
			var propagateSuspects = $el.attr("data-propagate-suspects") == "true";
			var suspected = $el.attr("data-suspected") == "true";
			var reverseSuspect = $el.attr("data-reverse-suspect") == "true";
			var bidirectionalSuspect = $el.attr('data-bidirectional-suspect') == 'true';
			var propagateDependencies =  $el.attr('data-propagate-dependencies') == 'true';
			var unresolvedDependencies = $el.attr('data-unresolved-dependencies') == 'true';
			
			var $versionContainer = $dialog.find(".referenceSettingVersionContainer");
			var $baselineSelector = $dialog.find(".referenceDialogBaselineSelector");
			var $versionSelector = $dialog.find(".referenceDialogVersionSelector");
			var $propagateSuspectsCheckbox = $dialog.find(".referenceDialogPropagateSuspects");
			var $reverseSuspectCheckbox = $dialog.find(".referenceDialogReverseSuspect");
			var $bidirectionalSuspectCheckbox = $dialog.find('.referenceDialogBidirectionalSuspect');
			var $propagateDependenciesCheckbox = $dialog.find('.referenceDialogPropagateDependencies');
			
			var $versionAjaxLoading = $dialog.find(".versionAjaxLoading");
			$versionSelector.empty();
			$baselineSelector.empty();

			var renderVersions = function(baselinesByRevision, baselinesMap) {
				$versionAjaxLoading.hide();

				$versionSelector.empty();
				$baselineSelector.empty();

				for (var revision in baselinesByRevision) {
					var baselines = baselinesByRevision[revision];
					var baselineList = [];
					for (var i = 0; i < baselines.length; i++) {
						baselineList.push(baselines[i].name);
					}
					var text = versionAbbr + " " + revision + " " + (baselineList.length > 0 ? "(" + baselineList.join(", ") + ")" : "");
					$versionSelector.prepend($("<option>", { value: revision }).text(text));
				}
				$versionSelector.prepend($("<option>", { value: 0}).text(i18n.message("reference.setting.head")));

				for (var baseline in baselinesMap) {
					var baselineVersion = baselinesMap[baseline];
					$baselineSelector.append($("<option>", { value: baselineVersion }).text(baseline));
				}

				var baselineVersions = [];
				$baselineSelector.find("option").each(function() {
					baselineVersions.push(parseInt($(this).attr("value"), 10));
				});
				if (version == "HEAD") {
					version = Math.max.apply(null, baselineVersion);
				}
				$baselineSelector.val(version);
				$versionSelector.val(version);
				if (version == 0) {
					$baselineSelector.closest(".referenceSettingSelectorContainer").find('input[type="radio"]').prop("checked", true).change();
				} else {
					$versionSelector.closest(".referenceSettingSelectorContainer").find('input[type="radio"]').prop("checked", true).change();
				}

				$versionContainer.show();
				
				if ($propagateDependenciesCheckbox.prop('checked')) {
					$baselineSelector.prop('disabled', true);
					$versionSelector.prop('disabled', true);
				}
			};

			$propagateSuspectsCheckbox.prop("checked", propagateSuspects);
			$reverseSuspectCheckbox.prop("checked", reverseSuspect);
			$bidirectionalSuspectCheckbox.prop('checked', bidirectionalSuspect);
			$propagateSuspectsCheckbox.change();
			$propagateDependenciesCheckbox.prop('checked', propagateDependencies);
			$propagateDependenciesCheckbox.change();
			
			$versionAjaxLoading.show();
			$versionContainer.hide();
			if (typeof ajaxReferenceFieldAutoComplete.versionCache[trackerItemId] === 'undefined') {
				$.getJSON(contextPath + "/ajax/referenceSetting/getTrackerItemVersions.spr", {
					trackerItemId: trackerItemId
				}).done(function(result) {
					var baselinesByRevision = result["baselinesByRevision"];
					var baselines = result["baselines"];
					ajaxReferenceFieldAutoComplete.versionCache[trackerItemId] = baselinesByRevision;
					ajaxReferenceFieldAutoComplete.baselineCache[trackerItemId] = baselines;
					renderVersions(baselinesByRevision, baselines);
				});
			} else {
				renderVersions(ajaxReferenceFieldAutoComplete.versionCache[trackerItemId], ajaxReferenceFieldAutoComplete.baselineCache[trackerItemId]);
			}

			$dialog.show();
			$dialog.position({
				at: "left bottom",
				my: "left top",
				collision: "flipfit",
				of: $el.closest("li")
			});
		};

		$referenceBox.on("click", ".tokenSetting", function(e) {
			e.stopPropagation();
			var itemName = $(this).closest("li").find(".name").text();
			openReferenceSettingDialog($(this), itemName, $dialog);
		});

		$referenceBox.on("click", ".referenceSettingBadge,.udBadge", function(e) {
			e.stopPropagation();
			$(this).closest("li").find(".tokenSetting").click();
		});

		$referenceBox.find(".tokenSetting").each(function() {
			ajaxReferenceFieldAutoComplete.addReferenceSettingBadges($(this));
		});

		$dialog.find(".cancelButton").click(function(e) {
			e.preventDefault();
			$dialog.hide();
		});

		$dialog.find(".okButton").click(function(e) {
			e.preventDefault();
			var id = $dialog.data("id");
			var $tokenSetting = $referenceBox.find('.tokenSetting[data-id="' + id + '"]');
			ajaxReferenceFieldAutoComplete.addReferenceSettingBadges($tokenSetting, $dialog);
		});

		$dialog.find(".referenceDialogPropagateSuspects").change(function(){
			var $suspectContainers = $dialog.find(".reverseSuspectContainer, .bidirectionalSuspectContainer");
			if ($(this).prop("checked") == true) {
				$suspectContainers.removeClass("inactive");
				$suspectContainers.find("input").prop("disabled", false);
				
				if ($dialog.find('.referenceDialogPropagateDependencies').prop('checked')) {
					$dialog.find('.reverseSuspectContainer')
						.addClass('inactive')
						.find('input').prop('disabled', true);
				}
			} else {
				$suspectContainers.addClass("inactive");
				$suspectContainers.find("input").prop("disabled", true);
				$suspectContainers.find("input").prop("checked", false);
			}
		});

		$dialog.find('.referenceDialogReverseSuspect').change(function() {
			if ($(this).prop('checked') == true) {
				$dialog.find('.referenceDialogBidirectionalSuspect').prop('checked', false);
			}
		});
		
		$dialog.find('.referenceDialogBidirectionalSuspect').change(function() {
			if ($(this).prop('checked') == true) {
				$dialog.find('.referenceDialogReverseSuspect').prop('checked', false);
			}
		});
		
		$dialog.find('.referenceDialogPropagateDependencies').change(function() {
			var $versionContainer = $dialog.find('.referenceSettingVersionContainer'),
				$reverseSuspectContainer = $dialog.find('.reverseSuspectContainer'),
				isCheckboxOn = $(this).prop('checked') == true;

			if (isCheckboxOn) {
				$versionContainer
					.toggleClass('inactive', isCheckboxOn)
					.find('input, select').prop('disabled', isCheckboxOn);
			} else {
				$versionContainer.removeClass('inactive');
				$versionContainer.find('input:checked')
					.closest('.referenceSettingSelectorContainer')
					.find('select').prop('disabled', false);
				$versionContainer.find('input').prop('disabled', false);
			}
			$reverseSuspectContainer
				.toggleClass('inactive', isCheckboxOn)
				.find('input').prop('disabled', isCheckboxOn);
			
			if (!isCheckboxOn) {
				$dialog.find('.referenceDialogPropagateSuspects').change();
			} else {
				$reverseSuspectContainer.find('input').prop('checked', false);
			}
		});

		$dialog.find('input[name="versionCheckbox"]').change(function() {
			if ($(this).prop("checked") == true) {
				if ($(this).val() == "version") {
					$dialog.find(".referenceDialogBaselineSelector").prop("disabled", true);
					$dialog.find(".referenceDialogVersionSelector").prop("disabled", false);
				}
				if ($(this).val() == "baseline") {
					$dialog.find(".referenceDialogVersionSelector").prop("disabled", true);
					$dialog.find(".referenceDialogBaselineSelector").prop("disabled", false);
				}
			}
		});

	},
	
	addReferenceSettingBadges : function($el, $dialog) {
		var versionAbbr = i18n.message("reference.setting.version.abbr");
		var reverseSuspectImg = '<span class="reverseSuspectImg" />';
		var reverseSuspectLabel = i18n.message("reference.setting.reverse.suspect");

		if ($dialog) {
			var versionFromDialog = 0,
				$versionContainer = $dialog.find('.referenceSettingVersionContainer');
			
			if ($versionContainer.is(':visible') && !$versionContainer.hasClass('inactive')) {
				var baselineSelected = $dialog.find('.baselineSelectorCheckbox').prop("checked") == true;
				versionFromDialog = baselineSelected ? $dialog.find(".referenceDialogBaselineSelector").val() : $dialog.find(".referenceDialogVersionSelector").val();
				if (typeof versionFromDialog === 'undefined') {
					versionFromDialog = 0;
				}
			}
			$el.attr("data-version", versionFromDialog);
			$el.attr("data-propagate-suspects", $dialog.find(".referenceDialogPropagateSuspects").prop("checked"));
			$el.attr("data-reverse-suspect", $dialog.find(".referenceDialogReverseSuspect").prop("checked"));
			
			var originalBidirectSetting = $el.attr('data-bidirectional-suspect') == 'true',
				newBidirectSetting = $dialog.find('.referenceDialogBidirectionalSuspect').prop('checked');
			$el.attr('data-bidirectional-suspect', newBidirectSetting);
			
			if (originalBidirectSetting != newBidirectSetting) {
				$el.attr('data-suspected', false);
				$el.attr('data-is-outgoing-suspected', false);
				$el.attr('data-is-incoming-suspected', false);
			}
			
			$el.attr('data-propagate-dependencies', $dialog.find('.referenceDialogPropagateDependencies').prop('checked'));
			
			$dialog.hide();
		}

		var trackerItemId = $el.attr("data-tracker-item-id");
		var branchName = $el.attr("data-branch-name");
		var associationId = $el.attr("data-association-id");
		var version = $el.attr("data-version");
		var propagateSuspects = $el.attr("data-propagate-suspects") == "true";
		var suspected = $el.attr("data-suspected") == "true";
		var reverseSuspect = $el.attr("data-reverse-suspect") == "true";
		var bidirectionalSuspect = $el.attr('data-bidirectional-suspect') == 'true';
		var isOutgoingSuspected = $el.attr('data-is-outgoing-suspected') == 'true';
		var isIncomingSuspected = $el.attr('data-is-incoming-suspected') == 'true';
		var propagateDependencies = $el.attr('data-propagate-dependencies') == 'true';
		var unresolvedDependencies = $el.attr('data-unresolved-dependencies') == 'true';
		
		var versionLabel = i18n.message("reference.setting.version");
		var propagateSuspectsLabel = i18n.message("association.propagatingSuspects.label");
		var suspectedLabel = i18n.message("tracker.view.layout.document.reference.suspected");

		var $li = $el.closest("li");
		var htmlId = $li.closest(".reference-box").attr("data-htmlId");
		var $liNamePart = $li.find(".name");
		$li.find(".branchBadge").remove();
		if (branchName != null && branchName.length > 0) {
			var isMasterBranch = branchName == i18n.message("tracker.branching.master.label");
			$liNamePart.after($("<span class='referenceSettingBadge branchBadge" + (isMasterBranch ? " masterBranchBadge" : "") + "' title='" + branchName + "'>" + branchName + "</span>"));
		}
		$li.find(".versionSettingBadge").remove();
		if (version != 0 && version != "null") {
			$liNamePart.after($("<span class='referenceSettingBadge versionSettingBadge' title='" + versionLabel + "'>" + versionAbbr + " " + version + "</span>"));
		}
		$li.find(".psSettingBadge").remove();
		$li.find('span.arrow').remove();
		$li.find('span.udBadge').remove();
		if (propagateSuspects) {
			var htmlForBidirectional = '';
			if (bidirectionalSuspect) {
				htmlForBidirectional = '<span class="arrow arrow-up' + (isOutgoingSuspected ? ' active' : '') + '"></span>' + 
									   '<span class="arrow arrow-down' + (isIncomingSuspected ? ' active' : '') + '"></span>';
			} 
			$liNamePart.after($("<span class='referenceSettingBadge psSettingBadge" + (suspected ? " active" : "")  +
				"' title='" + propagateSuspectsLabel + (reverseSuspect ? " (" + reverseSuspectLabel + ")" : "") + "'>" +
				suspectedLabel + (reverseSuspect ? reverseSuspectImg : "") + "</span>" + htmlForBidirectional));
		}

		if (propagateDependencies) {
			$el.before('<span title="' + i18n.message('association.unresolved.dependencies.label') + '" class="udBadge' + (unresolvedDependencies ? ' active' : '') + '"><i class="fa fa-exclamation"></i>' + i18n.message('association.unresolved.dependencies.compact.label') + '</span>');
		}

		ajaxReferenceFieldAutoComplete.updateReferenceValues("dynamicChoice_references_autocomplete_editor_" + htmlId, "dynamicChoice_references_" + htmlId);
        $el.attr("data-initialized", "true");
    },

	renderReferenceSettingDialog : function(htmlId) {
		var $dialog = $("<div>", { id: "dynamicChoice_references_" + htmlId + "_setting_dialog", "class": "referenceSettingDialog"});
		$dialog.append($("<h4>", { "class" : "referenceSettingTitle" }));
		$dialog.append($("<span>", { "class" : "versionAjaxLoading"}));

		var $container = $("<div>", { "class" : "referenceSettingVersionContainer"});
		$container.append($("<span>", { "class" : "referenceSettingVersionLabel"}).text(i18n.message("reference.setting.select.baseline.version")));

		var $selectorContainer1 = $("<div>", { "class": "referenceSettingSelectorContainer"});
		var $selectorLabel1 = $("<span>", { "class": "referenceSettingSelectorLabel baseline"});
		$selectorLabel1.append($("<input>", { "type": "radio", name: "versionCheckbox", value: "baseline", "class": "baselineSelectorCheckbox", id: "dialog_baseline_" + htmlId}));
		$selectorLabel1.append($("<label>", { "for": "dialog_baseline_" + htmlId}).text(i18n.message("reference.setting.baselines")));
		$selectorContainer1.append($selectorLabel1);
		var $selectorSpan1 = $("<span>");
		$selectorSpan1.append($("<select>", { id: "dialog_baselineSelector_" + htmlId, "class": "referenceDialogBaselineSelector"}));
		$selectorContainer1.append($selectorSpan1);
		$container.append($selectorContainer1);

		var $selectorContainer2 = $("<div>", { "class": "referenceSettingSelectorContainer"});
		var $selectorLabel2 = $("<span>", { "class": "referenceSettingSelectorLabel version"});
		$selectorLabel2.append($("<input>", { "type": "radio", name: "versionCheckbox", value: "version", "class": "versionSelectorCheckbox", id: "dialog_version_" + htmlId}));
		$selectorLabel2.append($("<label>", { "for": "dialog_version_" + htmlId}).text(i18n.message("reference.setting.versions")));
		$selectorLabel2.find(".versionSelectorCheckbox").prop("checked", true);
		$selectorContainer2.append($selectorLabel2);
		var $selectorSpan2 = $("<span>");
		$selectorSpan2.append($("<select>", { id: "dialog_versionSelector_" + htmlId, "class": "referenceDialogVersionSelector"}));
		$selectorContainer2.append($selectorSpan2);
		$container.append($selectorContainer2);

		$dialog.append($container);

		var $checkboxContainer = $("<div>", {'class': 'propagation-settings', "title": i18n.message("reference.setting.propagate.suspects.tooltip")});

		var $checkbox1 = $("<span>", { "class": "propagateSuspectsContainer"});
		var $checkboxSpan1_1 = $("<span>");
		$checkboxSpan1_1.append($("<input>", { "type": "checkbox", "class": "referenceDialogPropagateSuspects", id: "dialog_propagetSuspects_" + htmlId } ));
		var $checkboxSpan1_2 = $("<span>");
		$checkboxSpan1_2.append($("<label>", { "for": "dialog_propagetSuspects_" + htmlId }).text(i18n.message("association.propagatingSuspects.label")));
		$checkbox1.append($checkboxSpan1_1);
		$checkbox1.append($checkboxSpan1_2);
		$checkboxContainer.append($checkbox1);

		var $propagationOptions = $("<span>", {'class': 'propagation-options'});
		$checkboxContainer.append($propagationOptions);
		
		var $checkbox2 = $("<span>", { "class": "reverseSuspectContainer"});
		var $checkboxSpan2_1 = $("<span>");
		$checkboxSpan2_1.append($("<input>", { "type": "checkbox", "class": "referenceDialogReverseSuspect", id: "dialog_reverseSuspect_" + htmlId } ));
		var $checkboxSpan2_2 = $("<span>");
		$checkboxSpan2_2.append($("<label>", { "for": "dialog_reverseSuspect_" + htmlId }).text(i18n.message("reference.setting.reverse.suspect")));
		$checkbox2.append($checkboxSpan2_1);
		$checkbox2.append($checkboxSpan2_2);
		$propagationOptions.append($checkbox2);
		$propagationOptions.append('<br>');
		
		var $checkbox3 = $("<span>", { "class": "bidirectionalSuspectContainer"});
		var $checkboxSpan3_1 = $("<span>");
		$checkboxSpan3_1.append($("<input>", { "type": "checkbox", "class": "referenceDialogBidirectionalSuspect", id: "dialog_bidirectionalSuspect_" + htmlId } ));
		var $checkboxSpan3_2 = $("<span>");
		$checkboxSpan3_2.append($("<label>", { "for": "dialog_bidirectionalSuspect_" + htmlId }).text(i18n.message("reference.setting.bidirectional.suspect")));
		$checkbox3.append($checkboxSpan3_1);
		$checkbox3.append($checkboxSpan3_2);
		$propagationOptions.append($checkbox3);
		
		$dialog.append($checkboxContainer);

		var $buttonContainer = $("<div>", { "class": "referenceDialogButtonContainer"});
		$buttonContainer.append($("<button>", { "class": "button okButton"}).text(i18n.message("button.ok")));
		$buttonContainer.append($("<button>", { "class": "button cancelButton"}).text(i18n.message("button.cancel")));
		$dialog.append($buttonContainer);

		return $dialog;
	},

	updateReferenceValues: function(inputFieldId, referenceInputElementId) {
		var tokenSettings = [];
		var input = $("#" + inputFieldId);
		input.closest("div.reference-box").find(".tokenSetting").each(function() {
			var associationId = $(this).attr("data-association-id");
			var trackerItemId = $(this).attr("data-tracker-item-id");
			var propagateSuspects = $(this).attr("data-propagate-suspects") == "true";
			var isSuspected = $(this).attr("data-suspected") == "true";
			var reverseSuspect = $(this).attr("data-reverse-suspect") == "true";
			var bidirectionalSuspect = $(this).attr('data-bidirectional-suspect') == 'true';
			var propagateDependencies = $(this).attr('data-propagate-dependencies') == 'true';
			var hasUnresolvedDependencies = $(this).attr('data-unresolved-dependencies') == 'true';
			var version = $(this).attr("data-version");
			var originalVersion = $(this).attr("data-original-version");
			tokenSettings.push("9-" + trackerItemId + "/" + version + "#" + (version == originalVersion ? associationId : "0") + "#" + propagateSuspects + "#" + isSuspected + "#" + reverseSuspect + '#' + bidirectionalSuspect + '#' + propagateDependencies + '#' + hasUnresolvedDependencies);
		});

		var refvalue = "";
		if (tokenSettings.length > 0) {
			refvalue = tokenSettings.join(",");
		} else {
			var boxes = input.tokenInput("get");
			var refIds = new Array();
			for (var i=0; i<boxes.length; i++) {
				var box = boxes[i];
				var refId = box["id"];
				if (refId != null) {
					refIds[refIds.length] = refId;
				}
			}
			refvalue = refIds.join(",");
		}

		// find the current referenceInputElement by its id, the previous
		// element may be replaced by changing the innerHTML before
		var referenceInputElement = document.getElementById(referenceInputElementId);
		if (referenceInputElement == null) {
			alert("Can not find input field contains selected items, should have id='" + referenceInputElementId +"'");
			return null;
		}
		referenceInputElement.value = refvalue;

		// when the reference settings are updated we need to trigger the checkform event
		var $el = $(referenceInputElement);
		var $uninitialized = $el.closest('.reference-box').find('.tokenSetting[data-initialized=false]');
		if ($uninitialized.size() == 0) {  // only for form fields that are already fully initialized
            $el.closest('form').trigger('checkform.areYouSure');
        }
	},

	/**
	 * callback function for handling the "Do not modify" special value, to be passed to the
	 * init() function as the onChangeCallback.
	 */
	removeDoNotModifyBox: function() {
		var boxes = $(this).tokenInput("get");

		var DO_NOT_MODIFY_VALUE = "___DONT_MODIFIY_VALUE__"; // same as MassUpdateTaskForm.DONT_MODIFY_VALUE constant //$NON-NLS-1$
		// only remove the "Do not modify" if there are more than 1 selected-boxes shown
		if (boxes && boxes.length <= 1) {
			return;
		}
		for (var i=0; i<boxes.length; i++) {
			var box = boxes[i];
			var refId = box["id"];
			if (refId && refId == DO_NOT_MODIFY_VALUE) {
				$(this).tokenInput("remove", { id: refId });
			}
		}
	},

	/**
	 * Remove the specified value boxes
	 * @param fieldId
	 * @param values is an array of value ids whose boxes to remove
	 */
	removeValueBoxes: function(fieldId, values) {
		var tokenInputField = $("#dynamicChoice_references_autocomplete_editor_" + fieldId);
		var boxes = tokenInputField.tokenInput("get");
		if (boxes && boxes.length == 0) {
			return;
		}
		for (var i=0; i < boxes.length; i++) {
			var box = boxes[i];
			var refId = box["id"];
			for (var j=0; j < values.length; j++) {
				if (refId && refId == values[j]) {
					tokenInputField.tokenInput("remove", { id: refId });
				}
			}
		}

	},

	/**
	 * Initialize the Ajax autocomplete for all <div id="referencesForLabel_<htmlId>" class="yui-multibox" child elements of the specified section element,
	 * after the element body has been dynamically loaded via Ajax (JQuery.load)
	 * This functions relies on custom data- attributes, added by the chooseReferencesUI.tag !
	 * @param section
	 */
	bindAfterLoading : function(section) {
		$('div.yui-multibox[id^="referencesForLabel_"]', section).each(function(index, references) {
			var $references 	  =  $(references);
			var htmlId 			  =  $references.attr('id').substring(19);
			var userSelectorMode  = ($references.attr('data-userSelectorMode') == 'true');
			var acceptEmail		  = ($references.attr('data-acceptEmail') == 'true');
			var workItemMode 	  = ($references.attr('data-workItemMode') == 'true');
			var workItemTrackerIds=  $references.attr("data-workItemTrackerIds");
			var reportMode 		  = ($references.attr("data-reportMode") == "true");
			var multiSelect       = ($references.attr('data-multiSelect') == 'true');
			var removeDoNotModify = ($references.attr('data-removeDoNotModifyBox') == 'true');
			var emptyId           =  $references.attr('data-emptyId');
			var ajaxURLParameters =  $references.attr('data-ajaxURLParameters');
			var referencesJSON    =  $.parseJSON($references.attr('data-referencesJSON'));
			var contextCallback   =  $references.data('context');
			var onUpdateCallback  =  $references.data('callback');
			var onChangeCallback  =  $references.data('onChangeCallback');

			if (removeDoNotModify) {
				// This causes a Javascript error when removeDoNotModifyBox() gets called
				// onChangeCallback = ajaxReferenceFieldAutoComplete.removeDoNotModifyBox();
			}

			ajaxReferenceFieldAutoComplete.init.apply($references, [contextPath, "dynamicChoice_references_autocomplete_editor_" + htmlId, "dynamicChoice_references_autocomplete_container_" + htmlId,
				ajaxURLParameters, references, "dynamicChoice_references_" + htmlId, multiSelect, userSelectorMode, acceptEmail, workItemMode, workItemTrackerIds, reportMode, emptyId, null,
				$.isFunction(onChangeCallback) ? onChangeCallback : null,
				$.isFunction(contextCallback) ? contextCallback : null,
				$.isFunction(onUpdateCallback) ? onUpdateCallback : null, referencesJSON]);
		});
	}


};

