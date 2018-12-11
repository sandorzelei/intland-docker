<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="noReload" content="<c:out value='${param.noReload}'/>"/>
<meta name="decorator" content="popup"/>
<meta name="module" content="global_search"/>
<meta name="moduleCSSClass" content="searchModule newskin"/>
<meta name="stylesheet" content="search.css"/>

<c:set var="referrer" value="${empty param.referrer ? header.Referer : param.referrer}" />
<c:set var="from_id" value="${param.from_id}" />
<c:set var="from_type_id" value="${param.from_type_id}" />
<c:set var="to_type_id" value="history" />

<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.css" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.custom.less" />" type="text/css" media="all" />

<script src="<ui:urlversioned value='/js/jquery/jquery-selectboxit/jquery.selectBoxIt.min.js'/>"></script>

<style type="text/css">

	.assoc-border {
		border: 1px solid #d1d1d1 !important;
		border-right: 0px !important;
		height: 26px;
    	width: 6px;
	}

	.last-assoc {
		border: none;
		height: 26px;
    	width: 6px;
	}

	.this-issue {
	  	padding: 0px 3px 0px 3px;
	   	text-align: center;
	   	border-radius: 3px;
	    height: 26px;
	    line-height: 26px;
	    width: 110px;
	    font-size: 14px;
	    background: #99ebff;
	}

	.other-issue {
		padding: 0px 3px 0px 3px;
	   	text-align: center;
	   	border-radius: 3px;
	    height: 26px;
	    line-height: 26px;
	    width: 110px;
	    font-size: 14px;
	    background: #d1d1d1;
	}

	.assoc-label {
	    text-align: center;
	    height: 26px;
	    font-size: 14px;
	    line-height: 26px;
	    margin-top: -26px;
	    margin-left: 3px;
	    margin-right: 3px;
	    cursor: pointer;
	    padding: 0px 3px 0px 3px;
	}

	.association-combo {
   		border: 1px solid #cccccc;
	}

	.sel {
		z-index: 9999;
	    width: 425px;
	    background: white;
    	border: 1px solid #d1d1d1;
    	height: 25px;
    	line-height: 25px;
    	cursor: pointer;
	}

	.assoc-options {
		border: 1px solid #d1d1d1;
	    height: 30px;
	}

	.assoc-column {
		padding-top: 25px !important;
	}

	.assoc-list td{
		padding-top: 0px !important;
   		padding-bottom: 0px !important;
   		padding-left: 0px !important;
	}

	.assoc-list tbody {
		padding-top: 15px;
	}

	.inverse .selected {
	    background: #d1d1d1;
	}

	.selected {
	   	border-radius: 3px;
	    background: #99ebff;
	}

	.hide {
	    display: none;
	}

	.options {
		z-index: 999900;
		position: absolute;
	}

	.assoc-table {
		min-width: 427px;
		background-color: white;
		margin-top: -1px;
	}

	.options div {
	    transition: all 0.2s ease-out;
	}
	.options .assoc-label:hover {
	    background-color: #f5f5f5;
	}

	.select-association {
	    font-weight: bold;
	}

	.no-separator {
	 	margin-top: 10px !important;
	 	margin-bottom: 0px !important;
	}

	.association-settings tr{
		margin-top: 0px !important;
	 	margin-bottom: 0px !important;
	 	padding-top: 0px !important;
	 	padding-bottom: 0px !important;
	}
	.association-settings td{
		margin-top: 0px !important;
	 	margin-bottom: 0px !important;
	 	padding-top: 0px !important;
	 	padding-bottom: 0px !important;
	}

	.no-separator legend{
		border: none !important;
	}

	.association-arrow-container {
	    background: #d1d1d1;
	    border-left: 1px solid #ccc;
	    width: 16px;
	    float: right;
	    padding-top: 10px;
	    padding-left: 7px;
	    height: 15px;
	}

	.association-arrow {
	    margin: 0 auto;
	    width: 0;
	    height: 26px;
	    border-top: 5px solid #000000;
	    border-right: 5px solid transparent;
	    border-left: 5px solid transparent;
	}

	.checkboxContainer {
		padding-top: 10px;
	}

	.checkboxContainer input[type="checkbox"] {
		position: relative;
		top: 2px;
	}
	
	body.Mac .checkboxContainer input[type="checkbox"] {
		top: -1px;
	} 

	.inactive {
		color: #D1D1D1 !important;
	}
	
	#propagateDependenciesCheckbox {
		margin: 5px 0;
	}
</style>

<script type="text/javascript">

	function cancelAction() {
		if ("${associationForm.inline}" != "true") {
			window.close();
		} else {
			closePopupInline();
		}
	}

	jQuery(function($) {

		var $accordion = $('.accordion');
		$accordion.cbMultiAccordion();
		$accordion.cbMultiAccordion("open", 0);

		$("#propagatingSuspects").change(function() {
			var isChecked = $(this).prop('checked');
			
			['reverseSuspect', 'bidirectionalSuspect'].forEach(function(suspectType) {
				var $suspectCheckbox = $('#' + suspectType),
					$suspectLabel = $('label[for="' + suspectType + '"]');
				
				$suspectLabel[isChecked ? 'removeClass' : 'addClass']('inactive');
				$suspectCheckbox.prop('disabled', !isChecked);
				!isChecked && $suspectCheckbox.prop('checked', false);
			});
			
			if ($('#propagateDependencies').prop('checked')) {
				$('#reverseSuspect')
					.prop('disabled', true)
					.next()
					.addClass('inactive');
			}
		});
		$("#propagatingSuspects").change();
		
		$('#reverseSuspect').change(function() {
			if ($(this).prop('checked')) {
				$('#bidirectionalSuspect').prop('checked', false);
			}
		});
		
		$('#bidirectionalSuspect').change(function() {
			if ($(this).prop('checked')) {
				$('#reverseSuspect').prop('checked', false);
			}
		});

		$('#propagateDependencies').change(function() {
			var $baselineSelector = $('#addAssociationForm select[name="baselineId"]'),
				$reverseSuspect = $('#reverseSuspect'),
				isCheckboxOn = $(this).prop('checked') == true;

			$baselineSelector
				.toggleClass('inactive', isCheckboxOn)
				.prop('disabled', isCheckboxOn);
			
			$reverseSuspect
				.prop('disabled', isCheckboxOn)
				.next()
				.toggleClass('inactive', isCheckboxOn)
			
			if (!isCheckboxOn) {
				$('#propagatingSuspects').change();
			} else {
				$reverseSuspect.prop('checked', false);
			}
		});		
		
		var form = $("#addAssociationForm");

		$('input[name="ADD"]').click(function() {

			var $that = $(this);
			if ($that.data("clicked")) {
				return true;
			}

			ajaxBusyIndicator.showBusyPage();
			// Get the versions of selected tracker item IDs by the selected baseline
			var $baselineSelector = form.find('select[name="baselineId"]');
			var baselineId = $baselineSelector.val();
			if (baselineId !== "NONE") {
				baselineId = parseInt(baselineId, 10);
				var selectedTrackerItemIds = [];
				$('input[name="historyItem"]').each(function() {
					if ($(this).prop("checked")) {
							var checkboxValue = $(this).val();
							var parts = checkboxValue.split("-");
							console.log(parts);
							if (parseInt(parts[0], 10) == 9) { // Tracker item ID
								console.log($(this).closest("tr").find("a.itemUrl").attr("data-id"));
								selectedTrackerItemIds.push(parseInt($(this).closest("tr").find("a.itemUrl").attr("data-id")));
							}
					}
				});

				$.getJSON(contextPath + "/ajax/referenceSetting/getTrackerItemVersionByBaseline.spr", {
					baselineId: baselineId == "NONE" ? null : parseInt(baselineId, 10),
					trackerItemIdList: selectedTrackerItemIds.join(",")
				}).done(function(result) {
					var versionByItemId = result["versionByItemId"];
					for (var trackerItemId in versionByItemId) {
						var version = versionByItemId[trackerItemId];
						$('input[name="historyItem"]').each(function() {
							var itemId = parseInt($(this).closest("tr").find(".itemUrl").attr("data-id"))
							if (itemId == trackerItemId) {
								$(this).val($(this).val() + "/" + version);
							}
						});
					}
					$that.data("clicked", true);
					$that.click();
				});
				return false;
			} else {
// 				form.submit(function() {
// 					if (!select.prop("selection-is-valid")) {
// 						select.get(0).selectedIndex = -1; // clear selection
// 					}
// 					return true;
// 				});
				$that.data("clicked", true);
				$that.click();
				form.submit();
				return false;
			}
		});

		disableDoubleSubmit(form);

		// Struts textarea tag does not support placeholder attribute, so patch it with jQuery
		form.find("textarea[name=comment]").attr("placeholder", "<spring:message code="association.description.placeholder" text="Enter comment here..."/>");

		// update filter
		var filterValue = "<spring:escapeBody htmlEscape="true" javaScriptEscape="true">${associationForm.filterInput}</spring:escapeBody>";
		var historyTable = $("#history_item");

		// table, filter is not null, filter is not empty and not the placeholder
		if (historyTable && filterValue && filterValue != "" && filterValue != i18n.message("user.history.filter.label")){
			$("#filterInput").val(filterValue);
			$.uiTableFilter(historyTable, filterValue);
		}

		$('.sel').click(function (e) {
		    e.stopPropagation();
		    if ( $('.options').css('display') == 'none' ){
		    	$('.options').show();
		    	updateSelection();
		    }
		    else {
		    	$('.options').hide();
		    }
		});

		$('.options').click(function (e) {
			 e.stopPropagation();
			 $('.options').show();
		});

		$('body').click(function (e) {
			$('.options').hide();
		});

		$('.options').children('div').click(function (e) {
		    e.stopPropagation();
		    $('.options').hide();
		});

		$('.assoc-label').click(function (e) {
			e.stopPropagation();
			var associationId = $(this).attr("data-option-id");
			var reverseOrderChecked = $("#reverseOrder").attr('checked');
			var incomingAssociation = $(this).attr("data-option-incoming");

			selectAssociation(associationId, reverseOrderChecked, incomingAssociation);

			// update hidden field
			if (reverseOrderChecked){
				associationId = "inverse-"+associationId;
			}
			$('input[name=assocType]').val(associationId);

			$('.options').hide();
		});

		checkOrder();

		var selectedAssociation = $('input[name=assocType]').val();
		if (selectedAssociation){
			var reverseOrderChecked = false;
			if (selectedAssociation.lastIndexOf("inverse-", 0) === 0){
				selectedAssociation = selectedAssociation.substring(8);
				$('#reverseOrder').prop('checked', true);
				checkOrder();
				reverseOrderChecked = true;
			}


			var incomingAssociation = $('div[data-option-id='+selectedAssociation+']').attr("data-option-incoming");

			selectAssociation(selectedAssociation, reverseOrderChecked, incomingAssociation)
		}
	});

	function selectAssociation(associationId, reverseOrderChecked, incomingAssociation){
		var typeName, otherItem, selectLabel, item, itemPrefix;
		// update dropdown entry
		typeName = "${typeName}";

		if (!reverseOrderChecked){
			otherItem = i18n.message("association.otherItem.as.postifx");
			itemPrefix  = i18n.message("association.item.as.prefix");
			item = itemPrefix ? itemPrefix + " " + typeName : typeName;
			selectLabel = incomingAssociation.replace("\{0\}", item).replace("\{1\}", otherItem);
		}
		else {
			otherItem = i18n.message("association.otherItem.as.prefix");
			itemPrefix  = i18n.message("association.item.as.postifx");
			item = itemPrefix ? itemPrefix + " " + typeName : typeName;
			selectLabel = incomingAssociation.replace("\{0\}", otherItem).replace("\{1\}", item)
		}
		$("#selected-assoc").html(selectLabel);

		// update list selection
		$('.assoc-label').removeClass("selected");
		$('div[data-option-id='+associationId+']').addClass("selected");

	}

	function checkOrder(){
		var reverseOrderChecked = $("#reverseOrder").attr('checked');
		updateSelection();

		if (reverseOrderChecked){
			var element = $('.this-issue').detach();
			$('#right-column').append(element);

			element = $('.other-issue').detach();
			$('#left-column').append(element);

			$('#associations').addClass("inverse");
		}
		else {
			var element = $('.this-issue').detach();
			$('#left-column').append(element);

			element = $('.other-issue').detach();
			$('#right-column').append(element);

			$('#associations').removeClass("inverse");
		}
	}

	function updateSelection(){
		var selectedAssociation = $('input[name=assocType]').val();
		$('.assoc-label').removeClass("selected");
		if (selectedAssociation){
			var reverseOrderChecked = $("#reverseOrder").attr('checked');
			if (selectedAssociation.lastIndexOf("inverse-", 0) === 0 && reverseOrderChecked){
				selectedAssociation = selectedAssociation.substring(8);
				// update list selection
				$('div[data-option-id='+selectedAssociation+']').addClass("selected");
			}
			else if (selectedAssociation.lastIndexOf("inverse-", 0) === -1 && !reverseOrderChecked){
				// update list selection
				$('div[data-option-id='+selectedAssociation+']').addClass("selected");
			}
		}
	}

</script>

<c:set var="entity" value="${associationForm.entity}" />

<ui:actionMenuBar >
		<ui:pageTitle>
			<spring:message code="association.${associationForm.editing ? 'editing' : 'creation'}.title" text="${associationForm.editing ? 'Editing' : 'Adding'} Association"/>
		</ui:pageTitle>

		<spring:message code="association.of.label" text="of"/>

		<c:choose>
			<c:when test="${from_type_id eq GROUP_TRACKER_ITEM}">
				<spring:message code="tracker.type.${entity.typeName}" text="${entity.typeName}"/>

				<c:choose>
					<c:when test="${entity.closed}">
						[<span class="closedItem"><c:out value="${entity.keyAndId}"/></span>]
					</c:when>
					<c:otherwise>
						[<c:out value="${entity.keyAndId}"/>]
					</c:otherwise>
				</c:choose>
			</c:when>

			<c:when test="${from_type_id eq GROUP_OBJECT}">
				<spring:message code="document.label" text="Document"/> [# <c:out value="${entity.id}" />]
			</c:when>

			<c:otherwise>
				<c:out value="${entity.interwikiLink}"/>
			</c:otherwise>
		</c:choose>

		- <c:out value="${entity.name}"/>

		<c:if test="${associationForm.editing && !empty associationForm.targetEntity}">
			<spring:message code="association.to.label" text="to"/>
			<c:out value="${associationForm.targetEntity.interwikiLink} ${associationForm.targetEntity.shortDescription}"/>
		</c:if>
</ui:actionMenuBar>

<html:form action="/proj/addAssociationDialog" styleId="addAssociationForm">

	<html:hidden property="referrer" value="${referrer}" />
	<html:hidden property="from_type_id" value="${from_type_id}" />
	<html:hidden property="from_id" value="${from_id}" />

	<html:hidden property="assoc_id" value="${associationForm.assoc_id}" />
	<html:hidden property="assocType" value="${associationForm.assocType}" />
	<c:if test="${param.inline}">
		<html:hidden property="inline" value="true"/>
	</c:if>
	<html:hidden property="callback" value="${param.callback }"/>

	<c:if test="${!associationForm.editing}">
		<c:set var="from_type_id" value="${param.from_type_id}" />
		<c:set var="from_id" value="${param.from_id}" />
	</c:if>

	<ui:actionBar>
	  	<c:if test="${empty param.revision}">
			<c:choose>
				<c:when test="${associationForm.editing}">
					<html:submit styleClass="button" property="SAVE" styleId="Save">
						<spring:message code="button.save" text="Save"/>
					</html:submit>
				</c:when>
				<c:otherwise>
					<html:hidden property="ADD" value="Add" />
					<html:submit styleClass="button">
						<spring:message code="button.add" text="Add"/>
					</html:submit>
				</c:otherwise>
			</c:choose>

			&nbsp;&nbsp;
		</c:if>

		<html:cancel styleClass="cancelButton" onclick="cancelAction(); return false;">
			<spring:message code="button.cancel" text="Cancel"/>
		</html:cancel>
	</ui:actionBar>

	<ui:showErrors />

<c:set var="addAssocControls">

	<table class="formTableWithSpacing">
		<tr>
			<td class="fieldLabel optional"><spring:message code="reference.setting.association.type.label" text="Association Type:"/></td>
			<td>
				<div class="sel">
					<div class="assoc-selection">
						<span id="selected-assoc" class="selectboxit-text" unselectable="on" data-val="1" aria-live="polite" >--</span>
    				<span id="" class="association-arrow-container" unselectable="on">
    					<img id="" class="association-arrow" unselectable="on"></img>
    				</span>
					</div>

				</div>
				<div class="options hide">
					<table class="assoc-table">
						<tr class="association-combo">
							<td id="left-column"><div class="this-issue"><spring:message code="relations.this" arguments="${typeName}"/></div></td>
							<td class="assoc-column">
								<br>
								<table id="associations" class="assoc-list">
									<c:set var="incomingSelected" value="true" />
									<c:forEach items="${detailedAssocTypes}" var="assocType" varStatus = "status">
										<c:set var="borderClass" value="${status.last ? ' last-assoc ' : 'assoc-border'}" />
										<tr>
											<td class="${borderClass}"/>
											<td>
												<div class="assoc-label" data-option-id="${assocType.id}" data-option-name="${assocType.name}" data-option-incoming="${assocType.incoming}" data-supports-suspected="${assocType.supportsSuspected}" >${assocType.name}</div>
											</td>
										</tr>
									</c:forEach>
								</table>
							</td>
							<td id="right-column">
								<div class="other-issue"><spring:message code="association.otherItem.as.prefix"/></div>
							</td>
						</tr>
						<tr class="assoc-options">
							<td colspan="3">
								<c:set var="reverseChecked" value="${incomingSelected ? '' : ' checked'}" />
								<input id="reverseOrder" name="reverseOrder" title="" type="checkbox" onchange="checkOrder()" value="false" ${reverseChecked}}>
								<label for="reverseOrder"><spring:message code="association.reverse"/></label>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<c:if test="${from_type_id eq GROUP_TRACKER_ITEM or from_type_id eq GROUP_OBJECT}">
			<c:choose>
				<c:when test="${associationForm.editing}">
					<c:if test="${not empty associationForm.version}">
						<tr>
							<td class="fieldLabel optional"><spring:message code="version.label" text="Version"/>:</td>
							<td>
								<c:out value="${associationForm.version}"/>
							</td>
						</tr>
					</c:if>
				</c:when>
				<c:otherwise>
					<tr>
						<td class="fieldLabel optional"><spring:message code="reference.setting.baselines" text="Baselines"/>:</td>
						<td>
							<html:select property="baselineId">
								<option value="NONE"><spring:message code="reference.setting.head" text="HEAD"/></option>
								<option value="0"><spring:message code="reference.setting.current.head" text="Current HEAD"/></option>
								<c:forEach items="${baselines}" var="baseline">
									<c:if test="${baseline.id != null}">
										<option value="${baseline.id}">${baseline.name}</option>
									</c:if>
								</c:forEach>
							</html:select>
						</td>
					</tr>
				</c:otherwise>
			</c:choose>

			<tr>
				<td></td>
				<td class="checkboxContainer">
					<div class="propagation-settings">
						<div id="suspectedCheckbox" class="propagateSuspectsContainer">
							<spring:message var="propagateSuspectTitle" code="association.propagatingSuspects.tooltip" text="Should this association be marked 'Suspected' whenever the association target is modified?"/>
							<html:checkbox styleId="propagatingSuspects" property="propagatingSuspects" value="true" title="${propagateSuspectTitle}"/>
							<label for="propagatingSuspects" title="${propagateSuspectTitle}">
								<spring:message code="association.propagatingSuspects.label" text="Propagate suspects"/>
							</label>
							<span class="help">[<a target="_blank" href="https://codebeamer.com/cb/wiki/84895#section-Suspected+links"><spring:message code="cb.help.label" text="Help" /></a>]</span>
						</div>
						<div class="propagation-options" style="padding-right: 20px;">
							<div id="reverseSuspectCheckbox">
								<html:checkbox styleId="reverseSuspect" property="reverseSuspect" value="true" />
								<label for="reverseSuspect">
									<spring:message code="reference.setting.reverse.suspect" text="Reverse direction"/>
								</label>
							</div>
							<div id="bidirectionalSuspectCheckbox" class="bidirectionalSuspectContainer">
								<spring:message var="bidirectionalAssociationTitle" code="association.bidirectional.title" text="Create an association with the selected type and propagate suspects in both directions."/>
								<html:checkbox styleId="bidirectionalSuspect" property="bidirectionalSuspect" value="true" title="${bidirectionalAssociationTitle}" />
								<label for="bidirectionalSuspect">
									<spring:message code="association.bidirectional" text="Bi-directional"/>
								</label>
							</div>
						</div>
						<div class="hint" style="display: table-cell;">
							<spring:message code="association.propagatingSuspects.hint" text="Propagate suspects can be used between Work Items, Dashboards, Documents and Wiki pages."/><br>
							<spring:message code="association.propagatingSuspects.bidirectional.hint" text="Bi-directional option is only applied between Work Items."/>
						</div>	
					</div>
					<div id="propagateDependenciesCheckbox" class="propagateDependenciesContainer">
						<spring:message var="propagateDependenciesTitle" code="reference.setting.propagatingDependencies.label" text="Propagate Unresolved Dependencies"/>
						<html:checkbox styleId="propagateDependencies" property="propagatingDependencies" value="true" title="${propagateDependenciesTitle}" />
						<label for="propagateDependencies">
							<spring:message code="reference.setting.propagatingDependencies.label" text="Propagate Unresolved Dependencies"/>
						</label>
						<div class="hint" style="display: inline-block; margin-left: 10px;">
							<spring:message code="association.propagatingDependencies.hint" text="Propagate Unresolved Dependencies setting is only applied between Work Items except Test Run, Review and SCM related items."/>
						</div>
					</div>					
				</td>
			</tr>
		</c:if>
		<tr>
			<td colspan="2">
				<spring:message var="addCommentLabel" code="comment.add.label"/>
				<ui:collapsingBorder id="commentSection" label="${addCommentLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder no-separator">
					<html:textarea property="comment" rows="3" cols="80" styleClass="expandTextArea" />
				</ui:collapsingBorder>
			</td>
		</tr>
		<c:if test="${associationForm.editing && empty associationForm.targetEntity}">
			<%-- editing an association, that points to an url --%>
			<tr>
				<td class="optional">
					<spring:message code="association.url.label" text="URL"/>:
				</td>
				<td>
					<html:text property="url" size="80" />
				</td>
			</tr>
		</c:if>
	</table>

</c:set>

<c:choose>
	<c:when test="${associationForm.inline && !associationForm.editing}">
		<spring:message var="detailsLabel" code="issue.details.label" text="Details" htmlEscape="true"/>

		<div class="accordion">
			<h3 class="accordion-header"><spring:message code="reference.setting.association.setting.title" text="Association Settings"/></h3>
			<div class="accordion-content"><c:out value="${addAssocControls}" escapeXml="false" /></div>
		</div>

	</c:when>

	<c:otherwise>
		<c:out value="${addAssocControls}" escapeXml="false" />
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	var populateTree = function (n) {
		return {"project_id": "${param.proj_id}",
			"nodeId": n.attr ? n.attr("id") : "",
			"type": n.attr ? n.attr("type") : "",
			"tracker_id": "",
			"revision": "-1",
			"listViews": false
		};
	};

</script>

<c:choose>
	<c:when test="${associationForm.editing}">
		<ui:displaytagPaging defaultPageSize="${pagesize}" items="${revisions}" excludedParams="page"/>

		<br/>
		<spring:message var="historyTitle" code="document.history.title" text="History"/>
		<ui:collapsingBorder label="${historyTitle}" hideIfEmpty="false" open="true">
			<display:table name="${revisions}" id="revision" sort="external" defaultsort="1" defaultorder="descending" cellpadding="0" export="false"
						   decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">

				<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
				<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
				<display:setProperty name="paging.banner.onepage" value="" />
				<display:setProperty name="paging.banner.placement" value="${empty revisions.list ? 'none' : 'bottom'}"/>

				<spring:message var="versionLabel" code="document.version.label" text="Version"/>
				<display:column title="${versionLabel}" property="version" headerClass="numberData" class="numberData" style="width:5%"/>

				<spring:message var="versionDateLabel" code="document.createdAt.label" text="Date"/>
				<display:column title="${versionDateLabel}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" style="width:5%" />

				<spring:message var="versionCreatorLabel" code="document.lastModifiedBy.short" text="by"/>
				<display:column title="${versionCreatorLabel}" property="lastModifiedBy" headerClass="textData" class="textData columnSeparator" style="width:10%" />

				<spring:message var="versionCommentLabel" code="association.description.label" text="Comment"/>
				<display:column title="${versionCommentLabel}" property="description" headerClass="textData" class="textDataWrap columnSeparator" />

				<spring:message var="versionTypeLabel" code="association.assocType.label" text="Association Type"/>
				<display:column title="${versionTypeLabel}" headerClass="textData" class="textData columnSeparator" style="width:10%">
					<spring:message code="association.typeId.${revision.name}" text="${revision.name}"/>
				</display:column>

				<spring:message var="versionStatusLabel" code="document.status.label" text="Status"/>
				<display:column title="${versionStatusLabel}" headerClass="textData StatusHeaderClass" class="textData columnSeparator StatusClass" style="width:10%">
					<spring:message code="association.propagatingSuspects.label" text="Propagate suspects"/>:
					<c:choose>
						<c:when test="${revision.status.id eq 1 or revision.status.id eq 3}">
							<spring:message code="boolean.true.label" text="True"/>,
							<spring:message code="association.suspected.label" text="Propagate suspects"/>:
							<spring:message code="boolean.${revision.status.id eq 3 ? 'true' : 'false'}.label"/>
						</c:when>
						<c:otherwise>
							<spring:message code="boolean.false.label" text="False"/>
						</c:otherwise>
					</c:choose>
				</display:column>

			</display:table>
		</ui:collapsingBorder>
	</c:when>
	<c:otherwise>
		<ui:artifactSelector jsVariable="artifactSelector" treeUrl="${pageContext.request.contextPath}/trackers/ajax/tree.spr"
			treePopulatorFn="populateTree" exclude="${from_id}" showTreeSearchBox="true" disableTree="true" enableExternalUrls="true"
			externalUrlItems="${urlItems}" selectedHistoryValues="${selectedHistoryValues}" hideHeader="true" />
		<script type="text/javascript">
			$(function() {
				codebeamer.toolbar.handleSubmit($("#addAssociationForm"));
			});
		</script>
	</c:otherwise>
</c:choose>
</html:form>

