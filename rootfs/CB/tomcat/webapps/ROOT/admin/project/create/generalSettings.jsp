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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<c:if test="${!empty reqIF}">
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.css'/>" />
</c:if>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="project.creation.title" text="Create New Project"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}">

<ui:actionBar>
	<input type="submit" class="hidden" name="_eventId_finish" value="Finish" style="display:none;"/>

	<c:choose>
	<c:when test="${licenseCode.enabled.scm && createProjectForm.kindOfNewProject != 'demo'}">
		<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
		&nbsp;&nbsp;<input type="submit" id="nextButton" class="button" name="_eventId_submit" value="${nextButton}" />
	</c:when>
	<c:otherwise>
		<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
		&nbsp;&nbsp;<input type="submit" id="finishButton" class="button" name="_eventId_finish" value="${finishButton}" />
	</c:otherwise>
	</c:choose>

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<form:errors cssClass="error"/>

<style type="text/css">
	.expandWikiTextArea {
		width: 100%;
		border-top: none !important;
	}
	.newskin .optional, .newskin .mandatory {
		vertical-align: top;
	}

	label.targetType.undefined {
		color: FireBrick;
	}

	tr.items td, tr.relations td, tr.specifications td {
		padding-bottom: 4px !important;
	}

	span.attribControls, span.specificationControls, span.itemControls, tr.attrib > td.attrName > a.edit-link {
	 	margin-left: 2em;
	 	font-weight: normal !important;
	 	display: none;
	}

	tr.specificationCategory.expanded:hover td.categoryName span.specificationControls, tr.itemCategory.expanded:hover td.categoryName span.itemControls, tr.attrib.expanded > td.attrName:hover > a.edit-link {
		display: inline;
	}

	tr.items.expanded:hover td.itemName span.attribControls, tr.specTypes.expanded:hover td.specTypeName span.attribControls, tr.relations.expanded:hover td.relationName span.attribControls {
		display: inline;
	}

	tr.attrib td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	tr.option td {
		padding-top: 2px !important;
		padding-bottom: 2px !important;
	}

	td.itemName, td.relationName, td.specTypeName, td.specificationName, td.categoryName, label.trackerName {
		font-weight: bold !important;
	}

	td.specificationTarget form, td.itemTarget form, td.relationTarget form {
		display: inline;
	}

	td.optName {
		font-style: italic;
	}

	img.inlineEdit {
		margin-left: 6px;
		position: relative;
        top: 2px;
		display: none;
	}

	span.itemQualifiers span.ui-icon, td.relationTarget span.ui-icon {
		display: none;
	}

	span.itemQualifiers:hover span.ui-icon, td.relationTarget:hover span.ui-icon {
		display: inline-block;
	}

	span.qualifier {
		margin-left: 4px;
		margin-right: 4px;
		font-weight: bold;
	}

	span.referenceField {
		margin-right: 5px;
	}

	span.referenceField label {
		font-weight: bold !important;
	}

	span.referenceField:last-child span.separator {
		display: none;
	}

	span.trackerSection:hover img.inlineEdit, span.targetTable:hover img.inlineEdit, span.itemQualifiers:hover img.inlineEdit,
	div.attrTarget:hover img.inlineEdit, div.optTarget:hover img.inlineEdit, td.relationTarget:hover img.inlineEdit {
		display: inline;
	}

	a.trackerInfoLink {
	 	display: none;
	}

	span.trackerSection:hover a.trackerInfoLink {
		display: inline;
	}

	select.field {
		min-width: 12em;
		margin-right: 6px;
	}

	label.summaryLabel {
		font-weight: bold;
	}

	span.component {
		border-style: solid;
	    border-width: 1px;
	    border-color: lightGray;
		background-color: #F5F5F5;
		padding: 1px;
	}

	span.loading {
		display: block;
		font-size: 14px;
		font-weight: bold;
		padding: 1em;
		margin-top: 1em;
	}
</style>

<div class="contentWithMargins">

<c:if test="${!empty createProjectForm.generalSettingsTemplateName}">
	<div class="strongText">
		<h3>
			<spring:message code="import.project.selected.template.label" text="Project Template"/>:
			${createProjectForm.generalSettingsTemplateName}
		</h3>
	</div>
</c:if>

<table border="0" cellpadding="1" class="formTableWithSpacing">
<tr>
	<td class="mandatory labelcell"><spring:message code="project.name.label" text="Name"/>:</td>
	<td>
		<form:input path="name" size="50" maxlength="200" />
		<br/>
		<form:errors path="name" cssClass="invalidfield"/>
	</td>
</tr>

<tr>
	<td class="optional labelcell" style="vertical-align:top;"><spring:message code="project.keyName.label" text="Key (short name)"/>:</td>
	<td nowrap>
		<form:input path="keyName" size="50" maxlength="20" />
		<br/>
		<form:errors path="keyName" cssClass="invalidfield"/>

		<p class="explanation"><spring:message code="project.keyname.description"/></p>
	</td>
</tr>

<tr>
	<td class="optional labelcell"><spring:message code="project.category.label" text="Category"/>:</td>
	<td>
		<form:input size="27" maxlength="100" path="categoryOther"/>
	</td>
</tr>

<c:if test="${createProjectForm.showImportAllAssets}">
	<tr>
		<td style="padding-left: 10px" colspan="2">
			<spring:message var="importAllAssetsTooltip" code="import.project.all.assets.tooltip" text="During the project creation process all assets are going to be created automatically based on the selected template"/>
			<form:checkbox path="importAllAssets" title="${importAllAssetsTooltip}"/>
			<spring:message code="import.project.all.assets.label" text="Include all Work Items and Documents"/>
		</td>
		<td>
			<div class="hint">
				<spring:message code="import.project.all.assets.hint" text="We Recommend to opt-in the Include All assets and Wiki pages check boxes for Evaluation purposes.<br/>If you want to use this template in Production we recommend not to include Template assets."/>
			</div>
		</td>
	</tr>

	<tr>
		<td style="padding-left: 10px" colspan="2">
			<form:checkbox path="generateWikiPages" title="${generateWikiPagesTooltip}"/>
			<spring:message code="import.project.generate.wiki.label" text="Include Wiki pages"/>
		</td>
		<td>
			<div class="hint">
				<spring:message code="import.project.generate.wiki.hint" text="We Recommend to opt-in the Include All assets and Wiki pages check boxes for Evaluation purposes.<br/>If you want to use this template in Production we recommend not to include Template assets."/>
			</div>
		</td>
	</tr>
</c:if>

</table>

<%-- If this is a ReqIF import --%>
<c:if test="${!empty reqIF}">
	<div id="importConfiguration">
		<span class="loading"><spring:message code="ajax.loading" text="Loading..."/></span>
	</div>

	<input type="hidden" id="importConfigJSON" name="importConfigJSON" value=""/>

	<c:url var="validateUrl" value="/ajax/project/validateImportConfiguration.spr"/>

	<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.ui.position.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/admin/project/create/importConfiguration.js'/>"></script>
	<script type="text/javascript">
		$('#importConfiguration').importConfiguration(${reqIF.importConfig}, ${reqIF.targetConfig}, {
			assocTypes			   : ${reqIF.assocTypes},
			tableFields			   : ${reqIF.tableFields},
			relationFields		   : ${reqIF.assocFields},
			specificationFields    : ${reqIF.specFields},
			intro				   : '<spring:message code="import.config.intro" text="Please specify the mapping of input data to target project trackers, fields and choice options. You can also <Save> your final mapping or <Load> a previously saved mapping." javaScriptEscape="true"/>',
			noSupport			   : '<spring:message code="import.config.noSupport" text="Please specify the mapping of input data to target project trackers, fields and choice options. Please note that due to technical limitations, saving/loading mapping configuration is not yet supported in Internet Explorer." javaScriptEscape="true"/>',
			saveLabel			   : '<spring:message code="import.config.save.label" text="Save..." javaScriptEscape="true"/>',
			loadLabel			   : '<spring:message code="import.config.load.label" text="Load..." javaScriptEscape="true"/>',
			inputLabel			   : '<spring:message code="import.config.input.label" text="Input" javaScriptEscape="true"/>',
			toggleLabel			   : '<spring:message code="import.config.input.empty.label" text="including empty" javaScriptEscape="true"/>',
			toggleTitle			   : '<spring:message code="import.config.input.empty.tooltip" text="Whether to show or hide empty input specifications, item types, relations and attributes" javaScriptEscape="true"/>',
			emptyConfirm		   : '<spring:message code="import.config.input.empty.confirm" text="The ReqIF archive to import does not contain Specifications and Item Types or they are empty ! Do you want to import empty Specifications and Item Types ?" javaScriptEscape="true"/>',
			countLabel			   : '<spring:message code="import.config.count.label" text="Count" javaScriptEscape="true"/>',
			valuesLabel			   : '<spring:message code="import.config.values.label" text="First 10 distinct values" javaScriptEscape="true"/>',
			targetLabel			   : '<spring:message code="import.config.target.label" text="Target" javaScriptEscape="true"/>',
			itemsLabel			   : '<spring:message code="import.config.items.label" text="Item Types" javaScriptEscape="true"/>',
			unmappedItems		   : '<spring:message code="import.config.items.umapped" text="Item Types not mapped yet" javaScriptEscape="true"/>',
			relationsLabel		   : '<spring:message code="import.config.relations.label" text="Relation Types" javaScriptEscape="true"/>',
			specTypesLabel	   	   : '<spring:message code="import.config.specTypes.label" text="Specification Types" javaScriptEscape="true"/>',
			specificationsLabel	   : '<spring:message code="import.config.specifications.label" text="Specifications" javaScriptEscape="true"/>',
			unmappedSpecifications : '<spring:message code="import.config.specifications.unmapped" text="Specifications not mapped yet" javaScriptEscape="true"/>',
			selectTrackerLabel	   : '<spring:message code="import.config.select.tracker.label" text="Please select" javaScriptEscape="true"/>',
			selectTrackerTitle	   : '<spring:message code="import.config.select.tracker.tooltip" text="You must either choose a predefined target tracker, or right click, to define a new tracker" javaScriptEscape="true"/>',
			clickToEditTracker	   : '<spring:message code="import.config.edit.tracker.tooltip" text="(Double) Click, to choose a predefined tracker, or to define a new tracker" javaScriptEscape="true"/>',
			ignoreTrackerLabel	   : '<spring:message code="import.config.ignore.tracker.label" text="Ignore" javaScriptEscape="true"/>',
			ignoreTrackerTitle	   : '<spring:message code="import.config.ignore.tracker.tooltip" text="Ignore this type of items" javaScriptEscape="true"/>',
			showTrackerLabel	   : '<spring:message code="import.config.target.tracker.label" text="Properties..." javaScriptEscape="true"/>',
			showTrackerTitle	   : '<spring:message code="import.config.target.tracker.title" text="Target Tracker Properties" javaScriptEscape="true"/>',
			newTrackerLabel		   : '<spring:message code="import.config.new.tracker.label" text="New Tracker..." javaScriptEscape="true"/>',
			newTrackerTitle		   : '<spring:message code="import.config.new.tracker.title" text="Create a new target Tracker" javaScriptEscape="true"/>',
			typeLabel			   : '<spring:message code="import.config.new.tracker.type.label" text="Type" javaScriptEscape="true"/>',
			typeTooltip			   : '<spring:message code="import.config.new.tracker.type.tooltip" text="The type of the new tracker" javaScriptEscape="true"/>',
			nameLabel			   : '<spring:message code="import.config.new.tracker.name.label" text="Name" javaScriptEscape="true"/>',
			nameTooltip			   : '<spring:message code="import.config.new.tracker.name.tooltip" text="The name of the new tracker (required)" javaScriptEscape="true"/>',
			nameMissing			   : '<spring:message code="import.config.new.tracker.name.missing" text="The tracker name is missing" javaScriptEscape="true"/>',
			nameExisting		   : '<spring:message code="import.config.new.tracker.name.existing" text="There is already a tracker with the specified name" javaScriptEscape="true"/>',
			keyNameLabel		   : '<spring:message code="tracker.key.label" text="Key" javaScriptEscape="true"/>',
			keyNameTooltip		   : '<spring:message code="tracker.keyName.label" text="Key (short name)" javaScriptEscape="true"/>',
			keyNameMissing		   : '<spring:message code="import.config.new.tracker.key.missing" text="The tracker key is missing" javaScriptEscape="true"/>',
			descriptionLabel	   : '<spring:message code="tracker.description.label" text="Description" javaScriptEscape="true"/>',
			descriptionTooltip	   : '<spring:message code="tracker.description.tooltip" text="Optional tracker description" javaScriptEscape="true"/>',
			tableLabel			   : '<spring:message code="import.config.table.label" text="Table" javaScriptEscape="true"/>',
			tableTitle			   : '<spring:message code="import.config.table.tooltip" text="Optional: Choose an embedded table of the target tracker, in order to map input items to embedded table rows instead of main tracker items" javaScriptEscape="true"/>',
			tableNone			   : '<spring:message code="tracker.type.Item.plural" text="Items" javaScriptEscape="true"/>',
			qualifiersLabel		   : '<spring:message code="import.config.qualifiers.label" text="Qualifiers" javaScriptEscape="true"/>',
			qualifiersTitle		   : '<spring:message code="import.config.qualifiers.tooltip" text="Optional qualifiers, to identify a subset of items in the (embedded table of the) target tracker" javaScriptEscape="true"/>',
			noQualifiersLabel	   : '<spring:message code="import.config.qualifiers.none" text="No qualifiers" javaScriptEscape="true"/>',
			moreQualifiersLabel	   : '<spring:message code="import.config.qualifiers.more" text="More qualifiers..." javaScriptEscape="true"/>',
			selectFieldLabel	   : '<spring:message code="import.config.select.field.label" text="Please select" javaScriptEscape="true"/>',
			selectFieldTitle	   : '<spring:message code="import.config.select.field.tooltip" text="You must either choose a predefined field, or define a new field" javaScriptEscape="true"/>',
			clickToEditField	   : '<spring:message code="import.config.edit.field.tooltip" text="(Double) Click, to choose a predefined field, or to define a new field" javaScriptEscape="true"/>',
			ignoreFieldLabel	   : '<spring:message code="import.config.ignore.field.label" text="Ignore field" javaScriptEscape="true"/>',
			ignoreFieldTitle	   : '<spring:message code="import.config.ignore.field.tooltip" text="The field value will be ignored (not imported)!" javaScriptEscape="true"/>',
			ignoreAttrLabel		   : '<spring:message code="import.config.ignore.all.label" text="Ignore all" javaScriptEscape="true"/>',
			autoMapAttrLabel	   : '<spring:message code="import.config.assign.all.label" text="Assign all" javaScriptEscape="true"/>',
			unmappedAttributes	   : '<spring:message code="import.config.not.assigned.attributes.label" text="Attributes not mapped yet" javaScriptEscape="true"/>',
			newFieldLabel		   : '<spring:message code="import.config.new.field.label" text="New Field..." javaScriptEscape="true"/>',
			fieldNameTitle		   : '<spring:message code="import.config.new.field.title" text="The name of the new field (required)" javaScriptEscape="true"/>',
			duplicateFieldName	   : '<spring:message code="import.config.new.field.duplicate" text="A field with the specified name already exists !" javaScriptEscape="true"/>',
			reservedFieldName	   : '<spring:message code="import.config.new.field.reserved" text="The specified name is a reserved field name. Please choose another name !" javaScriptEscape="true"/>',
			selectValueLabel	   : '<spring:message code="import.config.select.value.label" text="Please select" javaScriptEscape="true"/>',
			selectValueTitle	   : '<spring:message code="import.config.select.value.tooltip" text="You must either choose a predefined value, or define a new value" javaScriptEscape="true"/>',
			clickToEditValue	   : '<spring:message code="import.config.edit.value.tooltip" text="(Double) Click, to choose a predefined value, or to define a new value" javaScriptEscape="true"/>',
			newValueLabel	   	   : '<spring:message code="import.config.new.value.label" text="New Value..." javaScriptEscape="true"/>',
			valueNameTitle 		   : '<spring:message code="import.config.new.value.title" text="Please enter the name of the new value" javaScriptEscape="true"/>',
			duplicateValueName	   : '<spring:message code="import.config.new.value.duplicate" text="A value with the specified name already exists !" javaScriptEscape="true"/>',
			createSimilarValue	   : '<spring:message code="import.config.new.value.similar" text="A value with a name, that only differs in case, already exists ! Create the new value anyway ?" javaScriptEscape="true"/>',
			assignUnmappedOptions  : '<spring:message code="import.config.new.value.assign" text="Automatically assign all unmapped values to matching or new target values" javaScriptEscape="true"/>',
			removeLabel			   : '<spring:message code="import.config.qualifier.remove.label" text="Remove" javaScriptEscape="true"/>',
			selectRelationTitle	   : '<spring:message code="import.config.relation.select.tooltip" text="Please choose, whether this type of relations should be ignored, mapped to a predefined association type, or mapped to predefined reference fields" javaScriptEscape="true"/>',
			ignoreRelationLabel	   : '<spring:message code="import.config.relation.ignore.label" text="Ignore" javaScriptEscape="true"/>',
			ignoreRelationTitle	   : '<spring:message code="import.config.relation.ignore.tooltip" text="This type of relations should be ignored" javaScriptEscape="true"/>',
			associationLabel	   : '<spring:message code="import.config.relation.association.label" text="Associations" javaScriptEscape="true"/>',
			associationTitle	   : '<spring:message code="import.config.relation.association.tooltip" text="This type of relations should be mapped to a predefined type of associations" javaScriptEscape="true"/>',
			referenceLabel	   	   : '<spring:message code="import.config.relation.reference.label" text="References" javaScriptEscape="true"/>',
			referenceTitle		   : '<spring:message code="import.config.relation.reference.tooltip" text="This type of relations should be mapped to predefined reference fields" javaScriptEscape="true"/>',
			selectAssocTypeLabel   : '<spring:message code="import.config.select.assoc.type.label" text="Please select" javaScriptEscape="true"/>',
			selectAssocTypeTitle   : '<spring:message code="import.config.select.assoc.type.tooltip" text="Please choose, whether this type of relations should be mapped to a predefined association type" javaScriptEscape="true"/>',
			noAssocTypeLabel	   : '<spring:message code="import.config.select.assoc.type.none.label" text="No Association" javaScriptEscape="true"/>',
			noAssocTypeTitle   	   : '<spring:message code="import.config.select.assoc.type.none.tooltip" text="This type of relation will not be mapped to an association type" javaScriptEscape="true"/>',
			referenceFieldsLabel   : '<spring:message code="import.config.ref.fields.label" text="and/or" javaScriptEscape="true"/>',
			referenceFieldsTitle   : '<spring:message code="import.config.ref.fields.tooltip" text="You can choose reference fields, to create references in conjunction with/instead of associations." javaScriptEscape="true"/>',
			noReferenceFieldsLabel : '<spring:message code="import.config.ref.fields.none" text="No references" javaScriptEscape="true"/>',
			moreReferenceFieldsLabel: '<spring:message code="import.config.ref.fields.more" text="More references..." javaScriptEscape="true"/>',
			copyFromLabel	   	   : '<spring:message code="import.config.copy.from.label" text="Copy from" javaScriptEscape="true"/>',
			submitText			   : '<spring:message code="button.ok"     text="OK" javaScriptEscape="true"/>',
			cancelText			   : '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>'
		});

		$('#nextButton, #finishButton').click(function() {
			var config  = $('#importConfiguration').getImportConfiguration();
			var jsonStr = JSON.stringify(config);
			var valid   = false;

			$.ajax("${validateUrl}", {
				type		: 'POST',
				async		: false,
				data 		: jsonStr,
				contentType : 'application/json',
				dataType 	: 'json'
			}).done(function() {
				valid = true;
				$('#importConfigJSON').val(jsonStr);

			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = eval('(' + jqXHR.responseText + ')');
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });

			return valid;
		});
	</script>
</c:if>

</div>

</form:form>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />
