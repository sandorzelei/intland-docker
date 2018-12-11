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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="project.creation.title" text="Create New Project"/>
		<spring:message code="project.creation.component.breadcrumb" arguments="${templateProject.name}" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}" >

<ui:actionBar>
	<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_submit" value="${nextButton}" />

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<style type="text/css" >
 tr.explanationRow > td {
 	padding-top: 0 !important;
 	padding-bottom: 0 !important;
 	margin-top: 0 !important;
 	margin-bottom: 0 !important;
 }
 p.explanation {
 	white-space: normal;
 	margin-top: 0;
 }

 table.displaytag tr, table.displaytag td {
 	vertical-align: top;
 }

 table.displaytag tr.subcomponent {
 	border: none !important;
 }

 tr.firstRow {
 	border-top: none !important;
 }

 table.displaytag * {
 	vertical-align: text-bottom;
 }

 span.noInherit {
 	margin-left: 15px;
 }
</style>

<div class="contentWithMargins">
<form:errors cssClass="error"/>

<spring:message var="linkTitle" code="project.creation.component.link.tooltip" text="Link settings" htmlEscape="true"/>

<spring:nestedPath path="componentsToCopySelection">
<table class="displaytag" style="width:50em;" >
	<c:forEach var="component" items="${components}" varStatus="status" >
		<tr class="odd ${status.first ?'firstRow' : ''}">
			<spring:message var="tooltip" code="project.creation.component.${component.key.name}.tooltip" />

			<td class="checkbox-column-minwidth">
				<form:hidden path="components" value="${component.key.id}"/>

				<form:checkbox path="copyFromTemplate" id="components_${component.key.id}" value="${component.key.id}" />
			</td>
			<td class="checkbox-column-minwidth">
				<label for="components_${component.key.id}">
					<spring:message code="project.creation.component.${component.key.name}.label" text="${component.key.name}"/>
				</label>
			</td>
			<td>
				<c:if test="${component.key.canInherit}">
					<span id="components_${component.key.id}_inherit" class="${empty component.key.checked ? 'invisible' : ''}" style="margin-left: 1em;">
						<form:checkbox id="defaultInherit_${component.key.id}" path="defaultInherit"
								value="${component.key.id}" title="${linkTitle}"/>
						<label for="defaultInherit_${component.key.id}" title="${linkTitle}">
							<spring:message code="project.creation.component.link.label" text="Inherit"/>
						</label>
					</span>
				</c:if>
			</td>
		</tr>
		<tr class="explanationRow">
			<td/>
			<td colspan="2"><p class="explanation">${tooltip}</p></td>
		</tr>

		<c:if test="${!empty component.value}">
			<c:forEach var="option" items="${component.value}">
				<tr id="row_${component.key.id}_${option.id}" class="even subcomponent ${empty component.key.checked ? 'invisible' : ''}" >
					<td class="checkbox-column-minwidth" >
						<form:hidden path="componentItems[${component.key.id}]" value="${option.id}" />
					</td>

					<td class="checkbox-column-minwidth" >
						<form:checkbox id="component_${component.key.id}_${option.id}" path="itemsToCopy[${component.key.id}]" value="${option.id}" />
						<label for="component_${component.key.id}_${option.id}">

							<c:set var="dto" value="${option}"/>

							<ui:coloredEntityIcon subject="${dto}" iconBgColorVar="bgColor" iconUrlVar="iconUrl"/>
							<c:url var="iconLink" value="${iconUrl}"/>
							<img src="${iconLink}" style="background-color:${bgColor}" class="issueIcon"/>

							<c:out value="${option.name}"/>

							<c:remove var="dto"/>
						</label>
					</td>

					<td>
						<c:set var="canInherit" value="${component.key.canInherit}"/>

						<c:if test="${canInherit}">
							<span id="component_${component.key.id}_${option.id}_inherit" style="margin-left: 1em;">
								<form:checkbox id="option_${component.key.id}_${option.id}_inherit" path="itemsToInherit[${component.key.id}]" value="${option.id}" title="${linkTitle}"/>

								<label for="option_${component.key.id}_${option.id}_inherit" title="${linkTitle}">
									<spring:message code="project.creation.component.link.label" text="Inherit"/>
								</label>
							</span>
						</c:if>

						<c:if test="${!canInherit}">
							<span class="noInherit"><spring:message code="project.creation.component.no.inherit.label" text="Copy template configuration"/></span>
						</c:if>

						<c:remove var="canInherit"/>
					</td>
				</tr>
			</c:forEach>
		</c:if>
	</c:forEach>
</table>
</spring:nestedPath>
</div>

</form:form>

<script type="text/javascript">
function setFolderStructureState() {
	var workItemsChecked = $('input[type="checkbox"][id="components_3"]').is(':checked');
	var configItemsChecked = $('input[type="checkbox"][id="components_50"]').is(':checked');

	var copyFolderStructure = $('input[type="checkbox"][id="components_-1"]');
	if (workItemsChecked || configItemsChecked){
		copyFolderStructure.prop('disabled', false);
	} else {
		copyFolderStructure.prop('checked', false);
		copyFolderStructure.prop('disabled', true);
	}
}
function setupComponentsChangeEvents() {
	$('input[type="checkbox"][name="componentsToCopySelection.defaultInherit"]').change(function() {
		var groupId = $(this).val();
		var checked = $(this).is(':checked');
		$('input[type="checkbox"][name="componentsToCopySelection.itemsToInherit[' + groupId + ']"]').attr('checked', checked);
	});

	$('input[type="checkbox"][name^="componentsToCopySelection.itemsToCopy"]').change(function() {
		var optId = $(this).attr('id');
		var checked = $(this).is(':checked');
		var $opt= $('#' + optId + '_inherit');
		if (checked) {
			$opt.removeClass('invisible');
		} else {
			$opt.addClass('invisible');
		}
	});

	$('input[type="checkbox"][name="componentsToCopySelection.copyFromTemplate"]').change(function() {
		var groupId = $(this).val();
		var checked = $(this).is(':checked');
		var $inherit = $('#components_' + groupId + '_inherit');
		var $row = $('tr[id^="row_' + groupId + '_"]');
		if (checked) {
			$inherit.removeClass('invisible');
			$row.removeClass('invisible');
		} else {
			$inherit.addClass('invisible');
			$row.addClass('invisible');
		}
	});


	$('input[type="checkbox"][id="components_3"]').change(function() {
		setFolderStructureState();
	});

	$('input[type="checkbox"][id="components_50"]').change(function() {
		setFolderStructureState();
	});

	// reinitialize all checkboxes after page load by triggering their change events
	$('input[type="checkbox"]').trigger("change");
}

$(setupComponentsChangeEvents);
</script>