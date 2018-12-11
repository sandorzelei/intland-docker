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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<meta name="decorator" 		content="${popup ? 'popup' : 'main' }"/>
<meta name="module" 		content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />

<style type="text/css">
	.newskinPageContent {
		margin: 10px !important;
	}
	.newskinPageContent .mandatory {
		padding-right: 5px;
	}
	.newskinPageContent .mainTitle {
		padding-top: 30px;
		padding-bottom: 12px;
		padding-left: 5px;
		padding-right: 15px;
		font-size: 16px;
		font-weight: bold;
	}
	.actionBar input {
		margin-right: 0px !important;
	}
	.actionBar .cancelButton {
		margin-left: 0px !important;
		padding-left: 0px !important;
	}
	.newskinPageContent .ditch-tab-container {
		margin-left: 5px;
	}
	#tracker-view-choice-fields {
		margin-left: 10px !important;
	}
	.newskinPageContent .chooseReferences {
		margin: 0px !important;
	}
	.newskinPageContent .chooseReferences td {
		padding-top: 0px;
		padding-bottom: 0px;
	}
	.newskinPageContent .chooseReferences .popupButton {
		margin-top: 0px;
	}

	li.filter label {
		font-weight: bold;
	}

	.editor-wrapper:not(.fr-fake-popup-editor) {
	    margin-bottom: 10px;
	}

</style>

<wysiwyg:froalaConfig />

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.js'/>"></script>

<script type="text/javascript">

function deleteView(form) {
	return confirm('<spring:message code="tracker.view.delete.confirm" />');
}

</script>

<c:url var="editViewUrl" value="/proj/tracker/view.spr">
	<c:param name="tracker_id" value="${tracker.id}"/>
</c:url>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false">
			<spring:message code="tracker.view.${empty view.id ? 'create' : 'edit'}.label" text="${empty view.id ? 'New' : 'Edit'} View"/>
		</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<form id="trackerViewForm" action="${editViewUrl}" method="post">
	<input type="hidden" name="forcePublicView" value="<c:out value='${forcePublicView}'/>" />
	<input type="hidden" name="configuration"   value="" />
	<input type="hidden" name="referrer"   		value="<c:out value='${referrer}'/>" />

	<ui:actionBar>
		<input type="hidden" value="${saveAs}" name="save_as" />

		<spring:message var="saveButton" code="button.save" text="Save"/>
		<input type="submit" class="button" name="SAVE" value="${saveButton}" />

		<c:if test="${canDelete and not saveAs}">
			<spring:message var="deleteButton" code="button.delete" text="Delete"/>
			<input type="submit" class="button" name="DELETE" value="${deleteButton}" onclick="return deleteView(this.form);"/>
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" style="margin-left:20px !important;" onclick="inlinePopup.close(); return false;"/>
	</ui:actionBar>

	<div id="trackerViewConfiguration" class="newskinPageContent">
		<table class="formTableWithSpacing" style="display: None; width: 100%;">
			<tr class="description-row">
				<td class="labelCell optional" style="width: 5%;">
					<spring:message code="tracker.view.description.label" text="Description"/>:
				</td>
				<td>
					<wysiwyg:editor editorId="editor" useAutoResize="false" height="120" overlayHeaderKey="wysiwyg.tracker.description.editor.overlay.header">
					    <textarea id="editor" rows="5" name="description">${view.description}</textarea>
					</wysiwyg:editor>
				</td>
			</tr>
		</table>
		<ui:showErrors />
	</div>
</form>


<script type="text/javascript">
	$('#trackerViewConfiguration').trackerViewConfiguration(${configuration});

	$('#trackerViewForm').submit(function() {
		$('#trackerViewForm > input[type="hidden"][name="configuration"]').val(JSON.stringify($('#trackerViewConfiguration').getTrackerView()));

		function startsWith(string, prefix) {
			return string.slice(0, prefix.length) == prefix;
		}

	});
</script>
