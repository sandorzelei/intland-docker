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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%--
  Request parameters:
    - actionList
--%>

<script type="text/javascript">

	// create and submit a filter query
	function handleFilterEvent() {
		var filterPattern = $("#documentSearchPattern").val();
		var mimeTypeFilter = $("#mimeTypeFilter").val();

		var form = $('<form action="' + contextPath + '/proj/doc/listDocuments.do" method="POST">'
		    	+ '<input type="hidden" name="doc_id" value="${listDocumentForm.doc_id}">'
		        + '</form>');
		    $('<input type="text" name="searchPattern">').val(filterPattern).appendTo(form);
		    $('<input type="text" name="mimeTypeFilter">').val(mimeTypeFilter).appendTo(form);
		    form.hide().appendTo("body").submit();
	}

	function download() {
		// obtain selected artifact ids
		var values = new Array();
		$.each($("input[name='selectedArtifactIds']:checked"), function() {
		  values.push('artifactIds=' + $(this).val());
		});
		if (values.length > 0) {
			var params = values.join('&');
			window.open(contextPath + '/artifacts/zip.spr?' + params,'_blank');
			//window.location.href = ;
		} else {
			showFancyAlertDialog(i18n.message("documents.download.zip.not.selected"));
		}
	}
	
	// HTML does not allow nested <form> elements, so we will assemble it dynamically
	jQuery(function($) {
   		applyHintInputBox("#documentSearchPattern", "${searchHint}");

		var pattern = $("#documentSearchPattern");

		pattern.keypress(function(e) {
			if (e.which == 13) {
				handleFilterEvent();
			    return false
		     }
		     return true;
	    });
   });
</script>

<style>
	.noRightMargin {
		margin-right: 0px !important;
	}

	#middleHeaderDiv {
		min-height: 22px;
	}
</style>

<c:set var="actionBarContents">
	<ui:rightAlign>
		<jsp:attribute name="filler">
			<c:if test="${not param.isBaselined}">
				<ui:actionMenu inline="true" title="more" actions="${actionList}" keys="Properties, newBaseline, ---, cut, copy, paste, delete, permissions, notification, ---, trash, Delete..., ---, Favourite" />
			</c:if>
		</jsp:attribute>
		<jsp:attribute name="fillerCSSStyle2">
			width: 100%;
		</jsp:attribute>
		<jsp:attribute name="rightAligned">
			<c:if test="${not param.isBaselined}">
				<spring:message var="searchHint" code="search.hint" text="Search..."/>
				<spring:message var="searchTitle" code="documents.search.tooltip" text="Use wildcards to search files or directories by name..."/>
				<!-- search by-name field -->
				<input type="text" id="documentSearchPattern" size="20" title="${searchTitle}" class="searchFilterBox" value="<c:out value="${listDocumentForm.searchPattern}" />">

				<!-- search by file type -->
				<select id="mimeTypeFilter" name="mimeTypeFilter" onchange="handleFilterEvent();" class="actionComboBox noRightMargin">
					<spring:message var="defaultLabel" code="document.filter.mimetype.label" text="Filter by file type" />
					<c:if test="${!empty listDocumentForm.mimeTypeFilter}">
						<spring:message var="defaultLabel" code="document.filter.mimetype.all" text="All files" />
					</c:if>
					<option value="" class="actionComboBoxOption">${defaultLabel}</option>

					<c:forEach items="${listDocumentForm.mimeTypeFilterValues}"	var="fileType">
						<spring:message var="optionLabel" code="document.filter.mimetype.${fileType}" text="${fileType}" htmlEscape="true" />
						<c:set var="selected" value="${fileType == listDocumentForm.mimeTypeFilter ? ' selected ' : ''}" />
						<option value="${fileType}" class="actionComboBoxOption" ${selected}> ${optionLabel} </option>
					</c:forEach>
				</select>
			</c:if>
		</jsp:attribute>
		<jsp:body>
			<c:if test="${not param.isBaselined}">
				<c:if test="${param.displayNew}">
					<ui:actionMenu inline="true" title="new" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon-add-blue.png" actions="${actionList}" keys="new*"
								   cssStyle="margin-left: 10px;"
							/>
					<div style="position: relative;top: 2px;display: inline-block;left: -6px;cursor: pointer;">
						<spring:message code="documents.download.label" text="Download" var="downloadTitle"/>
						<img class="action" title="${downloadTitle}" src="<ui:urlversioned value="/images/newskin/actionIcons/icon-download.png"/>" onclick="javascript:download();">
					</div>
					
				</c:if>

				<script type="text/javascript">
					// submit the form if at least one checkbox of 'selectedArtifactIds' is selected
					// @param for The form to submit
					// @param params The parameters to add to the submit
					function submitOnComboSelection(form, params) {
						var cansubmit = submitIfSelected(form, 'selectedArtifactIds');
						if (cansubmit) {
							// Important: this is NOT the action-url of the form, but the hidden action field!
							form.action.value = params;
							form.submit();
						}
					}

					// callback when the selection changes
					function onSelectionChange(selectbox) {
						var action = selectbox.options[selectbox.selectedIndex].value;
						var form = selectbox.form;
						var success = false;

						switch (action) {
							case "cut":
								success = submitOnComboSelection(form, 'cut');
								break;
							case "copy":
								success =  submitOnComboSelection(form, 'copy');
								break;
							case "paste":
								success = disableButtonsAndSubmit(form, 'paste');
								break;
							case "delete":
								success = confirmDelete(form);
								break;
							case "permissions":
								success = submitOnComboSelection(form, 'permissions');
								break;
							case "notification":
								success = submitOnComboSelection(form, 'notification');
								break;
						}

						if (!success) {
							// can not submit because no checkbox was checked,
							// reset the selectbox to the 1st selection so "More Actions..." will be selected
							selectbox.selectedIndex = 0;
						}
					}

					// Click handler for context menu
					function documentExtraActionsClickHandler(element) {
						var action = $(element).attr("href");
						var $actionSelector = $("#actionCombo");
						$actionSelector.val(action);
						$actionSelector.change();
					}
				</script>
				<span style="display: none">
					<ui:actionComboBox keys="cut, copy, paste, delete, permissions, notification" actions="${actionList}"
									   onchange="javascript:onSelectionChange(this);" id="actionCombo"
					/>
				</span>
			</c:if>
		</jsp:body>
	</ui:rightAlign>
</c:set>

<c:choose>
	<c:when test="${param.unwrapContents}">${actionBarContents}</c:when>
	<c:otherwise><ui:actionBar id="middleHeaderDiv">${actionBarContents}</ui:actionBar></c:otherwise>
</c:choose>
