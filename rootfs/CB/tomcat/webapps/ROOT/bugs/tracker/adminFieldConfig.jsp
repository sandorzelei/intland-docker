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

<ui:urlversioned var="tableColumnImageUrl"   value="/images/down_right_corner.gif" />
<ui:urlversioned var="tableExpandImageUrl"   value="/js/jquery/jquery-treetable/images/expand.png" />
<ui:urlversioned var="tableCollapseImageUrl" value="/js/jquery/jquery-treetable/images/collapse.png" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />

<head>
	<style type="text/css">
		.group_move_placeholder {
		  	display: table-row;
		}

		tbody.table {
			background-color: #FCFCFC !important;
		}

		span.indenter {
		  display: inline-block;
		  margin: 0;
		  padding: 0;
		  text-align: right;
		  user-select: none;
		  -khtml-user-select: none;
		  -moz-user-select: none;
		  -o-user-select: none;
		  -webkit-user-select: none;
		  width: 19px;
		}

		tr.table span.indenter {
			background-image: url("${tableCollapseImageUrl}");
			background-position: center center !important;
			background-repeat: no-repeat !important;
			height: 12px !important;
		}

		tr.table span.indenter.collapsed {
			background-image: url("${tableExpandImageUrl}");
		}

		tr.tableColumn span.indenter {
			background-image: url("${tableColumnImageUrl}");
			background-position: right center !important;
			background-repeat: no-repeat !important;
		 	width:	38px;
			height: 12px !important;
		}

		span.fixedType {
			color: #777;
		}

		span.choiceTypes {
 			color: #777;
		}

		ul.projectRoles li.projectRole, ul.projectRoles li.moreProjectRoles {
			list-style-type: circle;
		}

		li.projectQualifier > label {
			font-weight: bold;
		}

		li.permission > label {
			font-weight: bold;
		}

		li.trackerType, li.moreTrackerTypes {
			list-style-type: circle;
		}

		li.trackerType > label {
			font-weight: bold;
		}

		li.tracker {
			list-style-type: circle;
		}

		li.tracker > label {
			font-weight: bold;
		}

		li.folder {
			margin-top: 4px;
		}

		li.folder > label {
			font-weight: bold;
		}

		li.project, li.moreProjects {
			margin-top: 6px;
		}

		li.project > label {
			font-weight: bold;
		}

		select.componentSelector optGroup {
			font-weight: normal;
		}

		div.combinationsDialog {
			padding: 1em !important;
		}
		div.combinationsDialog .ui-multiselect-header {
			padding: 3px;
		}
		div.combinationsDialog .combination .removeButton {
			top: 0;
		}

		div.mandatoryDialog {
			padding: 1em !important;
		}

		div.requiredIn {
			padding: 4px 0px 4px 0px !important;
		}

		div.defaultValuesDialog {
			padding: 1em !important;
		}

		#trackerFields {
			border: 1px solid #ddd;
			margin-top: 15px !important;
		}

		#trackerFields tr:hover {
			background-color: #f4f4f4;
		}

		#trackerFields .yuimenubaritemlabel {
			float: right;
		}

		#trackerFields td .fieldType {
			padding: 1px 5px;
		}

		#trackerFields td:hover .fieldType.highlight-on-hover {
			padding: 0px 4px;
		}

		#trackerFields tr {
			line-height: 24px;
		}

		#trackerFields td span.highlight-on-hover form {
			display: inline;
			margin-left: -5px;
			margin-right: -5px;
		}

		#trackerFields td span.fieldLabel.hidden {
			color: gray;
		}

		span.removeButton {
			width: 16px;
			height: 16px;
			background-image: url("../../images/newskin/action/delete-grey-16x16.png");
			display: inline-block;
			margin: 0 3px 0 0;
			top: 3px;
			position: relative;
			cursor: pointer;
		}

		span.removeButton:hover {
			background-image: url("../../images/newskin/action/delete-grey-16x16_on.png");
		}

		span.editButton {
			background-image: url("../../images/newskin/action/edit-s.png");
		    margin-right: 5px;
		    margin-top: 4px;
			width: 12px;
		    height: 12px;
		    display: inline-block;
		    opacity: 0.4;
		    cursor: pointer;
		}

		span.editButton:hover {
			opacity: 0.7;
		}
		#toggleBoxes {
			margin-top: 15px;
		}

		#toggleBoxes .subtext {
			font-size: 13px;
			margin-right: 20px;
			position: relative;
			top: -2px;
		}

		#toggleBoxes .search-field-input {
			margin-right: 15px;
			position: relative;
			top: -2px;
		}

		#toggleBoxes .search-type-selector {
			position: relative;
			top: -1px;
		}

		#tracker-customize td.matrixCell, #tracker-customize th.permOwner {
			width: 7%;
		}

		#tracker-customize th.permOwner {
			padding-left: 10px;
			padding-right: 10px;
		}

		.newskin td.issueHandle {
			background-image: url("../../images/newskin/action/dragbar-dark.png");
			background-position: 3px center;
			background-color: #d1d1d1;
		}

		.ui-resizable-se {
	   		right: 0px !important;
	    	bottom: 10px !important;
	  	}

	  	.tooltipHeader {
	  		border-bottom: 1px solid lightgray;
	  		padding-bottom: 4px;
	  	}

	  	div.labelAndSelectorWrapper {
	  		padding: 5px;
	  		display: inline-block;
	  	}

	  	div.externalProjectCountBadge {
	  		width: 35px;
	  		height: 15px;
	  		display: inline-block;
	  		text-align: left;
	  		vertical-align: middle;
	  	}

	  	div.externalProjectCountBadge img {
	  		padding-left: 3px;
	  		vertical-align: middle;
	  	}

	  	div.externalProjectCountBadge label {
	  		color: white;
	  		padding-right: 5px;
	  		font-weight: bold;
	  		line-height: normal;
	  	}

	  	div.externalProjectCountBadge span {
	  		color: white;
	  		font-weight: bold;
	  	}

	  	div.externalProjectCountBadgeGreen {
	  		background: #03BC0E;
	  	}

	  	div.externalProjectCountBadgeYellow {
	  		background: #FFCD17;
	  	}

	  	div.externalProjectCountBadgeRed {
	  		background: #C40000;
	  	}

	  	span.externalProjectIconWrapper {
	  		display: inline-block;
	  		height: 100%;
	  		vertical-align: middle;
	  	}

		.ui-multiselect-menu.ui-widget-content .ui-widget-header {
			display: block !important;
		}

		.trackerSelector option.branchTracker {
			color: #187a6d;
		}

		tr.combination.reference:not(:hover) {
			background-color: #eee !important;
		}
	</style>

	<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/inlineEdit.css" />" type="text/css" media="all" />
</head>

<c:set var="canEditFieldPermissions" value="${canAdminTracker || branchDisabledAdminRights}"/>


<form id="trackerLayoutForm" action="${configurationUrl}" method="post">
	<div class="actionBar">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.fieldProps.tooltip" />
		</div>
	</div>

	<div id="toggleBoxes">
        <spring:message var="searchPlaceholder" code="search.field.tooltip.placeholder" text="Search..." />
        <spring:message var="fieldsByTypeLabel" code="tracker.field.fields.by.type.label" text="Show fields by type" />

        <input class="search-field-input" type="text" onkeypress="return event.keyCode != 13;" oninput="updateFieldVisibility()" placeholder="${searchPlaceholder}" />
		<input type="checkbox" onchange="toggleColumn(this, 'positionHeader', 'showPosition');" id="showPosition"><label class="subtext" for="showPosition"><spring:message code="tracker.field.offset.show" text="Show field position"/></label>
		<input type="checkbox" onchange="toggleColumn(this, 'propertyNameHeader', 'showProperty');" id="showPropertyName"><label class="subtext" for="showPropertyName"><spring:message code="tracker.field.property.show" text="Show property name"/></label>
		<input type="checkbox" onchange="updateFieldVisibility()" id="showHidden"><label class="subtext" for="showHidden"><spring:message code="tracker.field.showHidden.label" text="Show hidden fields"/></label>
        <select class="search-type-selector" onchange="updateFieldVisibility()">
            <option value="-1">${fieldsByTypeLabel}</option>
        </select>
	</div>
</form>

<script type="text/javascript">
	function toggleColumn(box, headerClass, dataName) {
		var show = box.checked;
		var index = $("." + headerClass).index() + 1;
		var selector = '#trackerFields th:nth-child(' + index + '),#trackerFields td:nth-child(' + index + ')';
		if (show) {
			$(selector).show();
		} else {
			$(selector).hide();
		}

		$("#trackerLayoutForm").data(dataName, show);
	}

	function updateFieldVisibility() {
		var isShowHiddenFields = $('#showHidden')[0].checked,
			searchTerm = $('#toggleBoxes .search-field-input').val(),
			filterType = $('#toggleBoxes .search-type-selector').val(),
			$fieldsTable = $('#trackerLayoutForm > table.fieldsConfiguration'),
			hasVisibleRow = false;

		$fieldsTable.find('> tbody').each(function() {
			var field = $('tr:first', this).data('field'),
			    isSearchMatching = true,
			    isFilterMatching = true,
			    isShowField = true;

			if (searchTerm.length) {
			    isSearchMatching = field.label.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1;
			}

			if (filterType > -1) {
			    isFilterMatching = field.type == filterType;
			}

			if (field.hidden) {
			    isShowField = isShowHiddenFields;
			}

			if (isSearchMatching && isFilterMatching && isShowField) {
			    $(this).show();
			    hasVisibleRow = true;
			} else {
			    $(this).hide();
			}
		});

		if (!hasVisibleRow) {
			$fieldsTable.hide();
		} else {
			$fieldsTable.show();
		}
	}

	$('#trackerLayoutForm').trackerFieldsConfiguration( ${fieldsJSON}, {
		formSelector		: '#trackerLayoutForm',
		editable			: ${canAdminTracker},
		branchDisabledAdminRights : ${branchDisabledAdminRights},
		serviceDeskEnabled	: ${serviceDeskEnabled},
		trackerId			: ${tracker.id},
		typeName			: [<c:forEach items="${fieldTypeNames}" var="typeName" varStatus="loop">"${typeName}"<c:if test="${!loop.last}">, </c:if></c:forEach>],
		typeClasses			: {
			 "allTypes" 	: [<c:forEach items="${allTypes}" var="type" varStatus="loop">${type}<c:if test="${!loop.last}">, </c:if></c:forEach>],
			 "simpleTypes"  : [<c:forEach items="${simpleTypes}" var="type" varStatus="loop">${type}<c:if test="${!loop.last}">, </c:if></c:forEach>],
			 "choiceTypes"  : [<c:forEach items="${choiceTypes}" var="type" varStatus="loop">${type}<c:if test="${!loop.last}">, </c:if></c:forEach>]
		},
		refTypes			: [<c:forEach items="${referenceTypes}" var="type" varStatus="loop">'${type.id}'<c:if test="${!loop.last}">, </c:if></c:forEach>],
		refTypeName			: {<c:forEach items="${referenceTypes}" var="type" varStatus="loop">"${type.id}" : '<spring:message code="${type.name}" text="${type.name}" javaScriptEscape="true"/>'<c:if test="${!loop.last}">, </c:if></c:forEach>},
		ruleName			: {<c:forEach items="${hierarchyRules}" var="rule" varStatus="loop">
			"${rule.id}" : { label : '<spring:message code="tracker.rule.${rule.id}.label" text="${rule.name}" javaScriptEscape="true"/>', tooltip : '<spring:message code="tracker.rule.${rule.id}.tooltip" text="${rule.description}" javaScriptEscape="true"/>'}<c:if test="${!loop.last}">, </c:if>
		</c:forEach>},
		aggrClasses			: {<c:forEach items="${aggregationClasses}" var="ruleClass" varStatus="loop">
			"${ruleClass.key}" : [<c:forEach items="${ruleClass.value}" var="rule" varStatus="rloop">'${rule.id}'<c:if test="${!rloop.last}">, </c:if></c:forEach>]<c:if test="${!loop.last}">, </c:if>
		</c:forEach>},
		distClasses			: {<c:forEach items="${distributionClasses}" var="ruleClass" varStatus="loop">
			"${ruleClass.key}" : [<c:forEach items="${ruleClass.value}" var="rule" varStatus="rloop">'${rule.id}'<c:if test="${!rloop.last}">, </c:if></c:forEach>]<c:if test="${!loop.last}">, </c:if>
		</c:forEach>},
		memberTypes			: [{ id : 2, name : '<spring:message code="project.newMember.users.label"	text="Users"  javaScriptEscape="true"/>' },
		           			   { id : 4, name : '<spring:message code="project.newMember.groups.label"	text="Groups" javaScriptEscape="true"/>' },
		           			   { id : 8, name : '<spring:message code="project.roles.label"				text="Roles"  javaScriptEscape="true"/>' }],
		dateOptions			: ${dateOptions},
		countryOptions		: ${countryOptions},
		languageOptions		: ${languageOptions},
		fieldOptionsUrl		: '${trackerFieldOptionsUrl}',
		fieldValidationUrl  : '${fieldValidationUrl}',
		checkFieldValuesUrl : '${checkFieldValuesUrl}',
        nextCustomFieldIdUrl: '${nextCustomFieldIdUrl}',
		infoLinkUrl			: '${infoLinkUrl}',
		inlineEditTooltip	: '<spring:message code="tracker.field.layout.inline.edit.hint"		text="Click to edit" javaScriptEscape="true"/>',
		addHereMenuLabel	: '<spring:message code="tracker.field.insert" 						text="Insert here a" javaScriptEscape="true"/>',
		moreFieldsLabel		: '<spring:message code="tracker.fieldProps.more" 					text="More fields..." javaScriptEscape="true"/>',
		newChoiceFieldText	: '<spring:message code="tracker.field.insert.choice" 				text="New choice field..." javaScriptEscape="true"/>',
		newCustomFieldText	: '<spring:message code="tracker.field.insert.custom" 				text="New custom field..." javaScriptEscape="true"/>',
		newTableText		: '<spring:message code="tracker.table.insert" 						text="New table..." javaScriptEscape="true"/>',
		newColumnText		: '<spring:message code="tracker.table.column.add" 					text="Add new column..." javaScriptEscape="true"/>',
		editMenuLabel		: '<spring:message code="tracker.field.edit" 						text="Edit" javaScriptEscape="true"/>',
		infoLabel			: '<spring:message code="tracker.field.info.label" 					text="Administrative Information" javaScriptEscape="true" />',
		infoTitle			: '<spring:message code="tracker.field.info.tooltip" 				text="Additional/administrative information about this field" javaScriptEscape="true" />',
		versionLabel		: '<spring:message code="document.version.label" 					text="Version" javaScriptEscape="true" />',
		createdByLabel		: '<spring:message code="document.createdBy.label" 					text="Created by" javaScriptEscape="true" />',
		lastModifiedLabel	: '<spring:message code="document.lastModifiedBy.tooltip" 			text="Last modified by" javaScriptEscape="true" />',
		commentLabel		: '<spring:message code="document.comment.label" 					text="Comment" javaScriptEscape="true" />',
		hideFieldLabel		: '<spring:message code="tracker.field.hide.label" 					text="Hide" javaScriptEscape="true" />',
	    hideFieldConfirm	: '<spring:message code="tracker.field.hide.instead.remove"			text="There are {0} items in {1} trackers, that have values for this field. Really remove them ?" arguments="XX,YY" javaScriptEscape="true"/>',
		unveilFieldLabel	: '<spring:message code="tracker.field.unveil.label" 				text="Unveil" javaScriptEscape="true" />',
		removeFieldLabel	: '<spring:message code="tracker.field.remove" 						text="Remove" javaScriptEscape="true"/>',
	    removeFieldConfirm	: '<spring:message code="tracker.field.remove.confirm" 				text="Really remove this field definition?" javaScriptEscape="true"/>',
	   	removeTableLabel	: '<spring:message code="tracker.table.remove" 						text="Remove table..." javaScriptEscape="true"/>',
	    removeTableConfirm	: '<spring:message code="tracker.table.remove.confirm" 				text="Really remove this whole table?" javaScriptEscape="true"/>',
	    removeTableValues	: '<spring:message code="tracker.table.remove.values" 				text="There are {0} items in {1} trackers, that have values for this table. Really remove them ?" arguments="XX,YY" javaScriptEscape="true"/>',
	    removeColumnLabel	: '<spring:message code="tracker.table.column.remove" 				text="Remove column..." javaScriptEscape="true"/>',
	    removeColumnConfirm	: '<spring:message code="tracker.table.column.remove.confirm" 		text="Really remove this table column?" javaScriptEscape="true"/>',
	    existColumnValues	: '<spring:message code="tracker.table.column.remove.values" 		text="This column cannot be removed, because there are {0} items in {1} trackers, that have values for this table column!" arguments="XX,YY" javaScriptEscape="true"/>',
	    removeDfltsConfirm  : '<spring:message code="tracker.field.defaults.remove.confirm" 	text="There exist default values and/or field filters that are most likely incompatible with the new field type. Should these be removed ?" javaScriptEscape="true"/>',
	    removeCombisConfirm : '<spring:message code="tracker.field.combis.remove.confirm" 		text="There exist field value combinations that are most likely incompatible with the new field type. Should these be removed ?" javaScriptEscape="true"/>',
		editLabelText		: '<spring:message code="tracker.field.label.label"  				text="Label" javaScriptEscape="true"/>',
		editTitleText		: '<spring:message code="tracker.field.title.label"  				text="Title" javaScriptEscape="true"/>',
		editTooltipText		: '<spring:message code="tracker.field.description.label"  			text="Description" javaScriptEscape="true"/>',
		editLayoutText		: '<spring:message code="tracker.field.layout.label" 				text="Layout and Content" javaScriptEscape="true"/>',
		editDatasourceText	: '<spring:message code="tracker.field.datasource.label" 			text="Datasource" javaScriptEscape="true"/>',
		offsetLabel			: '<spring:message code="tracker.field.offset.label" 				text="Pos." javaScriptEscape="true"/>',
		propertyLabel		: '<spring:message code="tracker.field.property.label" 				text="Property" javaScriptEscape="true"/>',
		typeLabel			: '<spring:message code="tracker.field.valueType.label" 			text="Type" javaScriptEscape="true"/>',
		typeTooltip			: '<spring:message code="tracker.field.valueType.tooltip"			text="The field value type/class" javaScriptEscape="true"/>',
	    typeImmutable		: '<spring:message code="tracker.field.valueType.immutable"			text="The type of this field cannot be changed!" javaScriptEscape="true"/>',
		nameLabel			: '<spring:message code="tracker.field.label.label" 				text="Label" javaScriptEscape="true"/>',
		nameTooltip			: '<spring:message code="tracker.field.label.tooltip" 				text="The name/label of the field can contain simple HTML text markup (b, em, i, u, strong, small, sub, sup, font, br)" javaScriptEscape="true"/>',
	    nameRequired		: '<spring:message code="tracker.field.label.required" 				text="The name/label of the field must not be empty" javaScriptEscape="true"/>',
	    nameDuplicate		: '<spring:message code="tracker.field.label.duplicate" 			text="There is already another field with the same name/label" javaScriptEscape="true"/>',
		titleLabel			: '<spring:message code="tracker.field.title.label"  				text="Title" javaScriptEscape="true"/>',
		titleTooltip		: '<spring:message code="tracker.field.title.tooltip"  				text="The optional/alternative title for table columns representing this field can also contain simple HTML text markup (b, em, i, u, strong, small, sub, sup, font, br)" javaScriptEscape="true"/>',
		descriptionLabel	: '<spring:message code="tracker.field.description.label"  			text="Description" javaScriptEscape="true"/>',
		descriptionTooltip	: '<spring:message code="tracker.field.description.tooltip"  		text="Optional tooltip/description of this field (plain text only)" javaScriptEscape="true"/>',
		permissionsTitle	: '<spring:message code="tracker.fieldAccess.title"					text="Field Access" javaScriptEscape="true"/>',
		permissionsLabel	: '<spring:message code="tracker.field.permissions.label" 			text="Permissions" 	javaScriptEscape="true"/>',
		distributeLabel		: '<spring:message code="tracker.field.distributionRule.label" 		text="Distribution rule" javaScriptEscape="true"/>',
		aggregateLabel		: '<spring:message code="tracker.field.aggregationRule.label" 		text="Aggregation rule" javaScriptEscape="true"/>',
		listableLabel		: '<spring:message code="tracker.field.listable.label" 			    text="List" javaScriptEscape="true"/>',
		listableTooltip		: '<spring:message code="tracker.field.listable.tooltip" 			text="Is this field appearing in the tracker-lists?" javaScriptEscape="true"/>',
		hiddenLabel			: '<spring:message code="tracker.field.hidden.label" 			    text="Hidden" javaScriptEscape="true"/>',
		hiddenTooltip		: '<spring:message code="tracker.field.hidden.tooltip" 				text="Hidden fields will not be visible at the GUI." javaScriptEscape="true"/>',
		breakRowTooltip		: '<spring:message code="tracker.field.breakRow.tooltip" 			text="Start a new line with this field?" javaScriptEscape="true"/>',
		computedLabel		: '<spring:message code="tracker.field.computed.label"   			text="computed" javaScriptEscape="true" />',
		computedTitle		: '<spring:message code="tracker.field.computed.tooltip" 			text="The read-only field value is computed from other field values" javaScriptEscape="true"/>',
		formulaLabel		: '<spring:message code="tracker.field.formula.label" 				text="Computed as" javaScriptEscape="true"/>',
		formulaTitle		: '<spring:message code="tracker.field.formula.tooltip" 			text="The Unified Expression Language script to compute the field value" javaScriptEscape="true"/>',
		contentLabel		: '<spring:message code="tracker.field.content.label" 				text="Content" javaScriptEscape="true"/>',
		membersLabel		: '<spring:message code="members.label"								text="Members" javaScriptEscape="true"/>',
		formatLabel			: '<spring:message code="tracker.view.layout.label" 				text="Layout" javaScriptEscape="true"/>',
		formattedLabel		: '<spring:message code="tracker.field.formatted.label"				text="formatted" javaScriptEscape="true"/>',
		formattedTitle		: '<spring:message code="tracker.field.formatted.tooltip"			text="Show formatted number with decimal grouping ?" javaScriptEscape="true"/>',
		multipleLabel		: '<spring:message code="tracker.field.multipleSelection.label"		text="multiple" javaScriptEscape="true"/>',
		multipleTitle		: '<spring:message code="tracker.field.multipleSelection.tooltip"	text="Can the field have multiple values?" javaScriptEscape="true"/>',
		dependsOnLabel		: '<spring:message code="tracker.field.dependsOn.label"   			text="depends on" javaScriptEscape="true"/>',
		dependsOnTitle		: '<spring:message code="tracker.field.dependsOn.tooltip" 			text="The other choice field, the current field values depends on" javaScriptEscape="true"/>',
		visibilityLabel		: '<spring:message code="comment.visibility.label"   				text="Visibility" javaScriptEscape="true"/>',
		visibilityTitle		: '<spring:message code="comment.visibility.default"   				text="The default visibility of comments/attachments created by members in specific roles" javaScriptEscape="true"/>',
		visibilityNone		: '<spring:message code="comment.visibility.default.none"  			text="No restrictions" javaScriptEscape="true"/>',
		visibilityMore		: '<spring:message code="comment.visibility.default.more"  			text="Add restrictions per role ..." javaScriptEscape="true"/>',
		roleLabel			: '<spring:message code="role.label"  								text="Role" javaScriptEscape="true"/>',
		combinationsTitle	: '<spring:message code="tracker.field.combinations.label" 			text="Field value combinations" javaScriptEscape="true"/>',
		layoutLabel			: '<spring:message code="tracker.field.layout.label" 				text="Layout and Content" javaScriptEscape="true"/>',
		datasourceLabel		: '<spring:message code="tracker.field.datasource.label" 			text="Datasource" javaScriptEscape="true"/>',
		datasourceTooltip	: '<spring:message code="tracker.field.datasource.tooltip" 			text="Please select datasource of the choice field from the dropdown list." javaScriptEscape="true"/>',
		sizeLabel			: '<spring:message code="tracker.field.size.label" 					text="Size" javaScriptEscape="true"/>',
		sizeTitle			: '<spring:message code="tracker.field.size.tooltip" 				text="The size of the input field (width in number of characters x height in number of lines)" javaScriptEscape="true"/>',
		lengthLabel			: '<spring:message code="tracker.field.length.label" 				text="Length" javaScriptEscape="true"/>',
		lengthTitle			: '<spring:message code="tracker.field.length.tooltip" 				text="Length of the field in number of characters" javaScriptEscape="true"/>',
		widthLabel			: '<spring:message code="tracker.field.cols.label" 					text="Width" javaScriptEscape="true"/>',
		widthTitle			: '<spring:message code="tracker.field.cols.tooltip" 				text="Width of the field in number of characters" javaScriptEscape="true"/>',
		heightLabel			: '<spring:message code="tracker.field.rows.label" 					text="Height" javaScriptEscape="true"/>',
		heightTitle			: '<spring:message code="tracker.field.rows.tooltip" 				text="Height of the field in number of lines/rows" javaScriptEscape="true"/>',
		minValueLabel		: '<spring:message code="tracker.field.minValue.label" 				text="min." javaScriptEscape="true"/>',
		minValueTitle		: '<spring:message code="tracker.field.minValue.tooltip" 			text="Smallest allowed field value" javaScriptEscape="true"/>',
		maxValueLabel		: '<spring:message code="tracker.field.maxValue.label" 				text="max." javaScriptEscape="true"/>',
		maxValueTitle		: '<spring:message code="tracker.field.maxValue.tooltip" 			text="Largest allowed field value" javaScriptEscape="true"/>',
		numberedLabel		: '<spring:message code="tracker.table.numbered.label" 				text="Row numbers" javaScriptEscape="true"/>',
		numberedTitle		: '<spring:message code="tracker.table.numbered.tooltip" 			text="Show an extra column with the table row numbers ?" javaScriptEscape="true"/>',
		colPermsLabel		: '<spring:message code="tracker.table.column.permissions.label" 	text="Column permissions" javaScriptEscape="true"/>',
		colPermsTitle		: '<spring:message code="tracker.table.column.permissions.tooltip"	text="Should each column of this table have individual access permissions ?" javaScriptEscape="true"/>',
		colspanTitle		: '<spring:message code="tracker.field.colspan.tooltip"  			text="How many columns of the 3-column editor mask should this field span" javaScriptEscape="true"/>',
		newlineLabel		: '<spring:message code="tracker.field.breakRow.label" 				text="Newline" javaScriptEscape="true"/>',
		noText    			: '<spring:message code="button.no" 								text="No" javaScriptEscape="true"/>',
	    submitText    		: '<spring:message code="button.ok" 								text="OK" javaScriptEscape="true"/>',
	    cancelText   		: '<spring:message code="button.cancel" 							text="Cancel" javaScriptEscape="true"/>',
	    trueValueText		: '<spring:message code="boolean.true.label" 						text="true" javaScriptEscape="true"/>',
		falseValueText		: '<spring:message code="boolean.false.label" 						text="false" javaScriptEscape="true"/>',
		propagateSuspectedLabel		            : '<spring:message code="tracker.field.propagatingSuspects.label"   			text="Propagate suspects" javaScriptEscape="true"/>',
		propagateSuspectedTitle		            : '<spring:message code="tracker.field.propagatingSuspects.tooltip" 			text="Should this association be marked 'Suspected' whenever the association target is modified?" javaScriptEscape="true"/>',
		reversedSuspectLabel		            : '<spring:message code="tracker.field.reversedSuspect.label"   				text="Reverse direction" javaScriptEscape="true"/>',
		reversedSuspectTitle		            : '<spring:message code="tracker.field.reversedSuspect.tooltip" 				text="Original, source work item should be suspected." javaScriptEscape="true"/>',
		bidirectionalSuspectLabel		        : '<spring:message code="tracker.field.bidirectionalSuspect.label"   			text="Bidirectional suspect" javaScriptEscape="true"/>',
		bidirectionalSuspectTitle		        : '<spring:message code="tracker.field.bidirectionalSuspect.tooltip" 			text="Both source and target work item should be suspected." javaScriptEscape="true"/>',
		propagateDependenciesLabel		        : '<spring:message code="tracker.field.propagatingDependencies.label"  			text="Propagate unresolved dependencies" javaScriptEscape="true"/>',
		propagateSuspectedTitle		            : '<spring:message code="tracker.field.propagatingDependencies.tooltip"			text="Should this association be marked 'Suspected' whenever the association target is unresolved?" javaScriptEscape="true"/>',		
		defaultReferenceVersionTypeLabel		: '<spring:message code="tracker.field.defaultReferenceVersionType.label"   	text="Default version" javaScriptEscape="true"/>',
		defaultReferenceVersionTypeTitle		: '<spring:message code="tracker.field.defaultReferenceVersionType.tooltip" 	text="Default version of referred item." javaScriptEscape="true"/>',
		defaultReferenceVersionTypeHead		    : '<spring:message code="tracker.field.defaultReferenceVersionType.HEAD.label" 	text="HEAD" javaScriptEscape="true"/>',
		defaultReferenceVersionTypeNone		    : '<spring:message code="tracker.field.defaultReferenceVersionType.NONE.label" 	text="HEAD" javaScriptEscape="true"/>',
        omitSuspectedChangeLabel		: '<spring:message code="tracker.field.omitSuspectedChange.label"		text="Omit Suspected when changing" javaScriptEscape="true"/>',
        omitSuspectedChangeTitle		: '<spring:message code="tracker.field.omitSuspectedChange.tooltip"	text="When this ticked on the suspected feature will not mark the item as Suspected when this field was changed" javaScriptEscape="true"/>',
        omitSuspectedChangeAfterLabel	: '<spring:message code="tracker.field.omitSuspectedChange.after.label"	text=" omit" javaScriptEscape="true"/>',

		choiceOptionSettings : {
			editable			: ${canAdminTracker},
			optionsUrl			: '${optionsUrl}',
			optionUrl			: '${optionUrl}',
			flagName    		: {<c:forEach items="${optionFlags}" var="flag" varStatus="loop">"${flag.id}" : "${flag.name}"<c:if test="${!loop.last}">, </c:if></c:forEach>},
			idLabel				: '<spring:message code="tracker.choice.id.label" 				text="Id" javaScriptEscape="true"/>',
			idRequired			: '<spring:message code="tracker.choice.id.required" 			text="A (unique) option Id is required" javaScriptEscape="true"/>',
			idDuplicate			: '<spring:message code="tracker.choice.id.duplicate" 			text="There is already another choice option with the same Id" javaScriptEscape="true"/>',
			nameLabel			: '<spring:message code="tracker.choice.name.label" 			text="Name" javaScriptEscape="true"/>',
			nameRequired		: '<spring:message code="tracker.choice.name.required" 			text="A (unique) option name is required" javaScriptEscape="true"/>',
			nameDuplicate		: '<spring:message code="tracker.choice.name.duplicate" 		text="There is already another choice option with the same name" javaScriptEscape="true"/>',
			descrLabel			: '<spring:message code="tracker.choice.description.label"		text="Description" javaScriptEscape="true"/>',
			flagsLabel			: '<spring:message code="tracker.choice.flags.label" 			text="Flags" javaScriptEscape="true"/>',
			infoLabel			: '<spring:message code="tracker.choice.info.label" 			text="Administrative Information" javaScriptEscape="true" />',
			infoTitle			: '<spring:message code="tracker.choice.info.tooltip" 			text="Additional/administrative information about this choice option" javaScriptEscape="true" />',
			versionLabel		: '<spring:message code="document.version.label" 				text="Version" javaScriptEscape="true" />',
			createdByLabel		: '<spring:message code="document.createdBy.label" 				text="Created by" javaScriptEscape="true" />',
			lastModifiedLabel	: '<spring:message code="document.lastModifiedBy.tooltip" 		text="Last modified by" javaScriptEscape="true" />',
			commentLabel		: '<spring:message code="document.comment.label" 				text="Comment" javaScriptEscape="true" />',
			submitText    		: '<spring:message code="button.ok" 							text="OK" javaScriptEscape="true"/>',
		    cancelText   		: '<spring:message code="button.cancel" 						text="Cancel" javaScriptEscape="true"/>',
		    addOptionText		: '<spring:message code="tracker.choiceList.addOption.here" 	text="Add Option here" javaScriptEscape="true"/>',
		    addOptionLink		: '<spring:message code="tracker.choiceList.addOption.label" 	text="Add Option" javaScriptEscape="true"/>',
		    addOptionTooltip    : '<spring:message code="tracker.choiceList.addOption.tooltip" 	text="Add a new option to the end of the options list. You can drag the new option to the intended position later." javaScriptEscape="true"/>',
		    editOptionText		: '<spring:message code="tracker.choice.option.edit" 			text="Edit Option" javaScriptEscape="true"/>',
		    editOptionTooltip	: '<spring:message code="tracker.choiceList.dblclick.hint" 		text="Double click to edit the choice option" javaScriptEscape="true"/>',
		    editIdText   		: '<spring:message code="tracker.choice.id.edit" 				text="Change Id" javaScriptEscape="true"/>',
		    editNameText 		: '<spring:message code="tracker.choice.name.edit" 				text="Change Name" javaScriptEscape="true"/>',
		    editDescrText 		: '<spring:message code="tracker.choice.description.edit" 		text="Change Description" javaScriptEscape="true"/>',
		    editFlagsText		: '<spring:message code="tracker.choice.flags.edit" 			text="Change Flags" javaScriptEscape="true"/>',
		    colorPickerText		: '<spring:message code="colorpicker.title" 					text="Pick a color!" javaScriptEscape="true" />',
			colorPickerIcon		: '<ui:urlversioned value="/images/color_swatch.png"/>',
		    removeOptionText	: '<spring:message code="tracker.choice.option.remove" 			text="Remove Option" javaScriptEscape="true"/>',
		    removeOptionConfirm : '<spring:message code="tracker.choice.option.remove.confirm" 	text="Really remove this choice option ?" javaScriptEscape="true"/>'
		},

		combinationSettings : {
			editable			: ${canAdminTracker},
			combiValuesUrl		: '${combisUrl}',
			combiReferencesUrl	: '${itemRefFldRefsUrl}',
		    submitText    		: '<spring:message code="button.ok" 								text="OK" javaScriptEscape="true"/>',
		    cancelText   		: '<spring:message code="button.cancel" 							text="Cancel" javaScriptEscape="true"/>',
			noneText  			: '<spring:message code="tracker.field.combinations.none" 			text="No field value combinations" javaScriptEscape="true"/>',
			addText  			: '<spring:message code="tracker.field.combinations.add" 			text="Add static combination" javaScriptEscape="true"/>',
			moreTooltip			: '<spring:message code="tracker.field.combinations.more.tooltip"	text="Click here to add more combinations" javaScriptEscape="true"/>',
			referencesAdd		: '<spring:message code="tracker.field.combinations.dynamic.add"    text="Add dynamic combination" javaScriptEscape="true"/>',
			referencesTooltip   : '<spring:message code="tracker.field.combinations.dynamic.tooltip" text="Click here to define dynamic combinations via references between the source trackers" javaScriptEscape="true"/>',
			filterText			: '<spring:message code="tracker.field.value.filter.label"			text="Filter" javaScriptEscape="true"/>',
			checkAllText		: '<spring:message code="tracker.field.value.choose.all" 			text="Check all" javaScriptEscape="true"/>',
			uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" 			text="Uncheck all" javaScriptEscape="true"/>',
			noValueText			: '<spring:message code="tracker.field.value.none" 					text="None" javaScriptEscape="true"/>',
			anyValueText		: '<spring:message code="tracker.filter.Any.label" 					text="Any"  javaScriptEscape="true"/>',
	        editTooltip   		: '<spring:message code="tracker.field.combinations.click" 			text="Click to edit the values" javaScriptEscape="true"/>',
		    removeText			: '<spring:message code="tracker.field.combinations.remove" 		text="Remove" javaScriptEscape="true"/>',
		   	removeConfirm		: '<spring:message code="tracker.field.combinations.remove.confirm" text="Do you really want to remove this field value combination?" javaScriptEscape="true"/>'
		},

		referenceConfigurationSettings : {
			editable			: ${canAdminTracker},
			refConfUrl			: '${refConfUrl}',
			projectsUrl			: '${projectsUrl}',
			projectRolesUrl		: '${projectRolesUrl}',
			projectTrackersUrl	: '${projectTrackersUrl}',
			projectCategories   : [<c:forEach items="${projectCategories}" var="qualifier" varStatus="loop">{ value: "${qualifier.value}", label: "${qualifier.label}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			projectPermissions  : [<c:forEach items="${projectPermissions}" var="permission" varStatus="loop">{ id: ${permission.id}, name: "${permission.name}", title: "${permission.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			trackerTypes		: [<c:forEach items="${trackerTypes}" var="type" varStatus="loop">{ id: ${type.id}, name: "${type.name}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			trackerPermissions	: [<c:forEach items="${trackerPermissions}" var="permission" varStatus="loop">{ id: ${permission.id}, name: "${permission.name}", title: "${permission.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			trackerFiltersUrl	: '${trackerFiltersUrl}',
			trackerItemFilters	: [<c:forEach items="${trackerItemFilters}" var="filter" varStatus="loop">{ id: -${filter.id}, name: '<spring:message code="issue.flags.${filter.name}.label" text="${filter.name}" javaScriptEscape="true"/>' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			repositoryTypes		: [<c:forEach items="${repositoryTypes}" var="type" varStatus="loop">{ id: ${type.id}, name: "${type.name}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			repositoryPermissions:[<c:forEach items="${repositoryPermissions}" var="permission" varStatus="loop">{ id: ${permission.id}, name: "${permission.name}", title: "${permission.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			basicRepositoryPermissions:[<c:forEach items="${basicRepositoryPermissions}" var="permission" varStatus="loop">{ id: ${permission.id}, name: "${permission.name}", title: "${permission.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			userGroups  		: [<c:forEach items="${userGroups}" var="group" varStatus="loop">{ id: ${group.id}, name: "<spring:escapeBody javaScriptEscape='true'>${group.name}</spring:escapeBody>", title: "<spring:escapeBody javaScriptEscape='true'>${group.description}</spring:escapeBody>" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			userPermissions  	: [<c:forEach items="${userPermissions}" var="permission" varStatus="loop">{ id: ${permission.id}, name: "${permission.name}", title: "${permission.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		    submitText    		: '<spring:message code="button.ok" 											text="OK" javaScriptEscape="true"/>',
		    cancelText   		: '<spring:message code="button.cancel" 										text="Cancel" javaScriptEscape="true"/>',
		    userGroupsLabel		: '<spring:message code="tracker.reference.choose.users.groups.label"			text="in Group" javaScriptEscape="true"/>',
			userGroupsTitle		: '<spring:message code="tracker.reference.choose.users.groups.tooltip"			text="If groups are selected, only members of these groups are included" javaScriptEscape="true"/>',
			userGroupsAny		: '<spring:message code="tracker.reference.choose.users.groups.any"  			text="Any"		javaScriptEscape="true"/>',
			userGroupsMore		: '<spring:message code="tracker.reference.choose.users.groups.more" 			text="More..."	javaScriptEscape="true"/>',
			userGroupsRemove	: '<spring:message code="tracker.reference.choose.users.groups.remove"   		text="Remove" javaScriptEscape="true"/>',
		    userPermsLabel		: '<spring:message code="tracker.reference.choose.users.permissions.label"		text="with Permission" javaScriptEscape="true"/>',
		    userPermsTitle		: '<spring:message code="tracker.reference.choose.users.permissions.tooltip"	text="If permissions are selected, only users are included where the user has at least one of the specified permissions" javaScriptEscape="true"/>',
		    userPermsAny		: '<spring:message code="tracker.reference.choose.users.permissions.any" 		text="Any" 		javaScriptEscape="true"/>',
		    userPermsMore		: '<spring:message code="tracker.reference.choose.users.permissions.more" 		text="More..."	javaScriptEscape="true"/>',
		    userPermsRemove		: '<spring:message code="tracker.reference.choose.users.permissions.remove"  	text="Remove" javaScriptEscape="true"/>',
		    projectMembersLabel : '<spring:message code="tracker.reference.choose.users.members.label"  		text="member of" javaScriptEscape="true"/>',
			projectMembersTitle : '<spring:message code="tracker.reference.choose.users.members.tooltip"  		text="If projects members are selected, those are included whether or not they are member of the specified groups" javaScriptEscape="true"/>',
			projectMembersNone  : '<spring:message code="tracker.reference.choose.users.members.none"  			text="None" javaScriptEscape="true"/>',
			memberRolesLabel	: '<spring:message code="tracker.reference.choose.members.roles.label"  		text="in Role" javaScriptEscape="true"/>',
			memberRolesTitle	: '<spring:message code="tracker.reference.choose.members.roles.tooltip"  		text="If roles are selected, only members in these roles are included" javaScriptEscape="true"/>',
			memberPermsLabel	: '<spring:message code="tracker.reference.choose.members.permissions.label"	text="with Permission" javaScriptEscape="true"/>',
			memberPermsTitle	: '<spring:message code="tracker.reference.choose.members.permissions.tooltip"	text="If permissions are selected, all members with any of these permissions are selected, independent of the role" javaScriptEscape="true"/>',
		    prjQlfrsLabel		: '<spring:message code="tracker.reference.choose.projects.qualifiers.label"	text="of Category" javaScriptEscape="true"/>',
		    prjQlfrsTitle		: '<spring:message code="tracker.reference.choose.projects.qualifiers.tooltip"	text="If categories are selected, only projects with these categories are included" javaScriptEscape="true"/>',
		    prjQlfrsAny			: '<spring:message code="tracker.reference.choose.projects.qualifiers.any"  	text="Any"		javaScriptEscape="true"/>',
		    prjQlfrsMore		: '<spring:message code="tracker.reference.choose.projects.qualifiers.more" 	text="More..."	javaScriptEscape="true"/>',
		    prjQlfrsRemove		: '<spring:message code="tracker.reference.choose.projects.qualifiers.remove"   text="Remove" javaScriptEscape="true"/>',
		    prjPermsLabel		: '<spring:message code="tracker.reference.choose.projects.permissions.label"	text="with Permission" javaScriptEscape="true"/>',
		    prjPermsTitle		: '<spring:message code="tracker.reference.choose.projects.permissions.tooltip"	text="If permissions are selected, only projects are included where the user has at least one of the specified permissions" javaScriptEscape="true"/>',
		    prjPermsAny			: '<spring:message code="tracker.reference.choose.projects.permissions.any" 	text="Any" 		javaScriptEscape="true"/>',
		    prjPermsMore		: '<spring:message code="tracker.reference.choose.projects.permissions.more" 	text="More..."	javaScriptEscape="true"/>',
		    prjPermsRemove		: '<spring:message code="tracker.reference.choose.projects.permissions.remove"  text="Remove" javaScriptEscape="true"/>',
		    projectsLabel		: '<spring:message code="tracker.reference.choose.projects.individual.label" 	text="and explicitly" javaScriptEscape="true"/>',
		    projectsTitle		: '<spring:message code="tracker.reference.choose.projects.individual.tooltip" 	text="If individual projects are selected, those are included, whether or not the category or permission matches." javaScriptEscape="true"/>',
		    projectsNone		: '<spring:message code="tracker.reference.choose.projects.individual.none" 	text="None" 	javaScriptEscape="true"/>',
		    projectsMore		: '<spring:message code="tracker.reference.choose.projects.individual.more" 	text="More..."	javaScriptEscape="true"/>',
		    projectsRemove		: '<spring:message code="tracker.reference.choose.projects.individual.remove" 	text="Remove" javaScriptEscape="true"/>',
		    inProjectLabel		: '<spring:message code="tracker.reference.choose.trackers.projects.label" 		text="in Project"	javaScriptEscape="true"/>',
			inFolderLabel		: '<spring:message code="issue.references.in.label" 							text="in" javaScriptEscape="true"/>',
		    moreTrackerProj 	: '<spring:message code="tracker.reference.choose.trackers.projects.more" 		text="More projects..."	javaScriptEscape="true"/>',
		    noTrackersLabel 	: '<spring:message code="tracker.reference.choose.trackers.none"				text="No Trackers/CMDB Categories" javaScriptEscape="true"/>',
		    allTrackersLabel	: '<spring:message code="tracker.reference.choose.trackers.allOf.label"			text="all Trackers/CMDB Categories" javaScriptEscape="true"/>',
		    allTrackersTitle	: '<spring:message code="tracker.reference.choose.trackers.allOf.title"			text="If at least one type and/or permission is selected, all Trackers/CMDB Categories in this project with any of these types/permissions are included." javaScriptEscape="true"/>',
		    trkrOfTypeLabel 	: '<spring:message code="tracker.reference.choose.trackers.types.label"			text="of type" javaScriptEscape="true"/>',
		    trkrOfTypeTitle 	: '<spring:message code="tracker.reference.choose.trackers.types.tooltip"		text="If types are selected, all Trackers/CMDB Categories in this project with any of these types are included" javaScriptEscape="true"/>',
		    trkrPermsTitle		: '<spring:message code="tracker.reference.choose.trackers.permissions.tooltip"	text="If permissions are selected, all CMDB/Trackers in this project are included, where the user has at least one of the specified permissions" 	javaScriptEscape="true"/>',
		    trkrsExplctLabel	: '<spring:message code="tracker.reference.choose.trackers.explicitly.label"	text="and explicitly" javaScriptEscape="true"/>',
		    trkrsExplctTitle	: '<spring:message code="tracker.reference.choose.trackers.explicitly.tooltip"	text="If individual Trackers/CMDB Categories are selected, those are included, whether or not the type or permission matches." javaScriptEscape="true"/>',
		    trkrsExplctNone		: '<spring:message code="tracker.reference.choose.trackers.explicitly.none"		text="No Trackers/CMDB Categories" javaScriptEscape="true"/>',
		    trkrsExplctMore		: '<spring:message code="tracker.reference.choose.trackers.explicitly.more"		text="More Trackers/CMDB Categories..." javaScriptEscape="true"/>',
		    itemsLabel			: '<spring:message code="tracker.reference.choose.items"						text="Items/Issues" javaScriptEscape="true"/>',
		    noItemsLabel		: '<spring:message code="tracker.reference.choose.items.none"					text="No Tracker/CMDB items" javaScriptEscape="true"/>',
		    allItemsLabel		: '<spring:message code="tracker.reference.choose.items.allOf.label"			text="all Tracker/CMDB items" javaScriptEscape="true"/>',
		    allItemsTitle		: '<spring:message code="tracker.reference.choose.items.allOf.title"			text="If at least one type and/or permission is selected, all Tracker/CMDB items in this project with any of these types/permissions are included." javaScriptEscape="true"/>',
			withStatusLabel		: '<spring:message code="issue.references.status.label"							text="with status" javaScriptEscape="true"/>',
		    itemOfTypeLabel		: '<spring:message code="tracker.reference.choose.items.types.label"			text="of type" javaScriptEscape="true"/>',
		    itemOfTypeTitle		: '<spring:message code="tracker.reference.choose.items.types.tooltip"			text="If types are selected, all Tracker/CMDB items of this type in this project are included." javaScriptEscape="true"/>',
		    noneOfTypeLabel		: '<spring:message code="tracker.reference.choose.items.types.none"				text="None" 	javaScriptEscape="true"/>',
		    moreOfTypeLabel		: '<spring:message code="tracker.reference.choose.items.types.more"				text="More..." 	javaScriptEscape="true"/>',
		    itemPermsTitle		: '<spring:message code="tracker.reference.choose.items.permissions.tooltip"	text="If permission are selected, all Tracker/CMDB items with any of these permissions are included." 	javaScriptEscape="true"/>',
		    itemsExplctLabel	: '<spring:message code="tracker.reference.choose.items.explicitly.label"		text="and explicitly" javaScriptEscape="true"/>',
		    itemsExplctTitle	: '<spring:message code="tracker.reference.choose.items.explicitly.tooltip"		text="If individual Trackers/CMDB Categories are selected, all items from these Trackers/CMDB Categories matching the specified filter/criteria are included" javaScriptEscape="true"/>',
			itemFilterLabel		: '<spring:message code="tracker.reference.choose.items.filter.label"			text="Filter" javaScriptEscape="true"/>',
			itemFilterTitle		: '<spring:message code="tracker.reference.choose.items.filter.tooltip"			text="A filter to selected a subset of items in this tracker/category" javaScriptEscape="true"/>',
		    noReposLabel		: '<spring:message code="tracker.reference.choose.repositories.none"			text="No SCM repositories" javaScriptEscape="true"/>',
		    allReposLabel		: '<spring:message code="tracker.reference.choose.repositories.allOf.label"		text="all Repositories" javaScriptEscape="true"/>',
		    allReposTitle		: '<spring:message code="tracker.reference.choose.repositories.allOf.title"		text="If at least one type and/or permission is selected, all repositories in this project with any of these types/permissions are included." javaScriptEscape="true"/>',
		    repoOfTypeLabel		: '<spring:message code="tracker.reference.choose.repositories.types.label"		text="of type" javaScriptEscape="true"/>',
		    repoOfTypeTitle 	: '<spring:message code="tracker.reference.choose.repositories.types.tooltip"	text="If types are selected, all repositories of these types in this project are included." javaScriptEscape="true"/>',
		    repoPermsTitle		: '<spring:message code="tracker.reference.choose.repositories.permissions.tooltip"	text="If permissions are selected, all SCM repositories in this project are included, where the user has at least one of the specified permissions." 	javaScriptEscape="true"/>',
		    reposExplctLabel	: '<spring:message code="tracker.reference.choose.repositories.explicitly.label" text="and explicitly" javaScriptEscape="true"/>',
		    reposExplctTitle	: '<spring:message code="tracker.reference.choose.repositories.explicitly.tooltip" text="If individual SCM repositories are selected, those are included, whether or not the type or permission matches." javaScriptEscape="true"/>',
		    reposExplctNone		: '<spring:message code="tracker.reference.choose.repositories.explicitly.none" text="No SCM Repositories" javaScriptEscape="true"/>',
		    reposExplctMore		: '<spring:message code="tracker.reference.choose.repositories.explicitly.more" text="More SCM Repositories..." javaScriptEscape="true"/>',
			createViewLabel		: '<spring:message code="tracker.notification.changeFilter.create.label" 		text="New" javaScriptEscape="true"/>',
			editViewLabel		: '<spring:message code="tracker.notification.changeFilter.edit.label" 			text="Edit" javaScriptEscape="true"/>',
			trackerViewUrl		: '${trackerViewUrl}',
			// Quick add reference during field creation
			trackerSelectorDefault: '<spring:message code="tracker.field.create.addReference.trackerSelectorDefault" text="Select a tracker" javaScriptEscape="true"/>',
			projectSelectorDefault: '<spring:message code="tracker.field.create.addReference.projectSelectorDefault" text="Select a project" javaScriptEscape="true"/>',
			statusSelectorDefault: '<spring:message code="tracker.field.create.addReference.statusSelectorDefault" text="Select a status" javaScriptEscape="true"/>',
			projectLabel		: '<spring:message code="tracker.field.create.addReference.projectLabel" text="Project:" javaScriptEscape="true"/>',
			trackerLabel		: '<spring:message code="tracker.field.create.addReference.trackerLabel" text="Tracker:" javaScriptEscape="true"/>',
			statusLabel			: '<spring:message code="tracker.field.create.addReference.statusLabel" text="Status:" javaScriptEscape="true"/>',
			projectOfTrackerUrl : '${projectOfTrackerUrl}'
		},

		mandatorySettings : {
			editable			: ${canAdminTracker},
			mandatoryLabel		: '<spring:message code="tracker.field.mandatory.label"					text="Mandatory" 	javaScriptEscape="true"/>',
			mandatoryTitle		: '<spring:message code="tracker.field.mandatory.tooltip"				text="Please click here, to define in which states this field must have a value." javaScriptEscape="true"/>',
			inStatusLabel		: '<spring:message code="tracker.field.mandatory.inStatus.label"		text="in Status" 	javaScriptEscape="true"/>',
			allText  			: '<spring:message code="tracker.field.mandatory.inStatus.all"			text="All" 			javaScriptEscape="true"/>',
			noneText  			: '<spring:message code="tracker.field.mandatory.inStatus.none"			text="None" 		javaScriptEscape="true"/>',
			exceptLabel			: '<spring:message code="tracker.field.mandatory.inStatus.except.label"	text="except" 		javaScriptEscape="true"/>',
			exceptTitle			: '<spring:message code="tracker.field.mandatory.inStatus.except.title"	text="Basically the field is mandatory in all states, except the specified ones (if any)" javaScriptEscape="true"/>',
			checkAllText		: '<spring:message code="tracker.field.value.choose.all" 				text="Check all" 	javaScriptEscape="true"/>',
			uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" 				text="Uncheck all" 	javaScriptEscape="true"/>',
		    submitText    		: '<spring:message code="button.ok" 									text="OK" 			javaScriptEscape="true"/>',
		    cancelText   		: '<spring:message code="button.cancel" 								text="Cancel" 		javaScriptEscape="true"/>'
		},

		defaultValueSettings : {
			editable			: ${canAdminTracker},
			workflowStates		: [<c:forEach items="${workflowStates}" var="state" varStatus="loop">${state}<c:if test="${!loop.last}">, </c:if></c:forEach>],
			linkTitle			: '<spring:message code="tracker.field.statusSpecific.tooltip"		text="The allowed/default field values per status" 			javaScriptEscape="true"/>',
			linkLabel			: '<spring:message code="tracker.field.statusSpecific.label"		text="Allowed/Default values" javaScriptEscape="true"/>',
			statusLabel			: '<spring:message code="issue.status.label"						text="Status" 			javaScriptEscape="true"/>',
			allowedValuesLabel  : '<spring:message code="tracker.field.filter.label" 				text="Allowed Values" 	javaScriptEscape="true"/>',
			twoManRuleLabel		: '<spring:message code="tracker.field.flags.two-men-rule.label"	text="Two-man rule" 	javaScriptEscape="true"/>',
			twoManRuleTitle		: '<spring:message code="tracker.field.flags.two-men-rule.tooltip"	text="Separation of duty, by enforcing that a different person is assigned to this task in this status than before" javaScriptEscape="true"/>',
			defaultValueLabel	: '<spring:message code="tracker.field.defaultValue.label" 			text="Default Value" 	javaScriptEscape="true"/>',
			anyText  			: '<spring:message code="tracker.field.value.any" 					text="Any" 				javaScriptEscape="true"/>',
			noneText  			: '<spring:message code="tracker.field.value.none" 					text="None" 			javaScriptEscape="true"/>',
			filterText			: '<spring:message code="tracker.field.value.filter.label"			text="Filter" 			javaScriptEscape="true"/>',
			checkAllText		: '<spring:message code="tracker.field.value.choose.all" 			text="Check all" 	javaScriptEscape="true"/>',
			uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" 			text="Uncheck all" 	javaScriptEscape="true"/>',
		    submitText    		: '<spring:message code="button.ok" 								text="OK" 			javaScriptEscape="true"/>',
		    cancelText   		: '<spring:message code="button.cancel" 							text="Cancel" 		javaScriptEscape="true"/>'
		},

	    accessPermissionSettings : {
			editable			: ${canEditFieldPermissions},
			defaultAccessCtrl	: ${defaultAccessCtrl},
			accessControlTypes	: [<c:forEach items="${accessControlTypes}" var="aclType" varStatus="loop">{ id: ${aclType.id}, name: "${aclType.name}", title: "${aclType.description}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			workflowStates		: [<c:forEach items="${workflowStates}" var="state" varStatus="loop">${state}<c:if test="${!loop.last}">, </c:if></c:forEach>],
			roles				: ${projectRoles},
			memberFieldsLabel	: '<spring:message code="tracker.fieldAccess.memberFields.label" 			text="Participants" javaScriptEscape="true"/>',
			rolesLabel		 	: '<spring:message code="tracker.fieldAccess.roles.label" 					text="Roles"		javaScriptEscape="true"/>',
			permissionsLabel	: '<spring:message code="tracker.field.permissions.label" 					text="Permissions" 	javaScriptEscape="true"/>',
			readText			: '<spring:message code="tracker.fieldAccess.read.label" 					text="Read" 		javaScriptEscape="true"/>',
			editText			: '<spring:message code="tracker.fieldAccess.edit.label" 					text="Edit" 		javaScriptEscape="true"/>',
			noneText  			: '<spring:message code="tracker.field.permissions.none.label"				text="None" 		javaScriptEscape="true"/>',
			checkAllText		: '<spring:message code="tracker.field.value.choose.all" 					text="Check all" 	javaScriptEscape="true"/>',
			uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" 					text="Uncheck all" 	javaScriptEscape="true"/>',
			statusLabel			: '<spring:message code="tracker.field.permissions.status.label" 			text="Status"		javaScriptEscape="true"/>',
			defaultText  		: '<spring:message code="tracker.field.permissions.status.default.label"	text="Default" 		javaScriptEscape="true"/>',
			defaultTooltip 		: '<spring:message code="tracker.field.permissions.status.default.tooltip"	text="Apply default permissions for this status" javaScriptEscape="true"/>',
			specialText  		: '<spring:message code="tracker.field.permissions.status.special.label"	text="Special" 		javaScriptEscape="true"/>',
			specialTooltip 		: '<spring:message code="tracker.field.permissions.status.special.tooltip"	text="Apply special permissions for this status" javaScriptEscape="true"/>'
		}
	});

	$(function() {
		var $typeSelector = $('#toggleBoxes .search-type-selector'),
		    types = [];

		$('#trackerLayoutForm > table.fieldsConfiguration > tbody').each(function() {
			var field = $('tr:first', this).data('field');
			if ($.inArray(field.type, types) == -1) {
				$typeSelector.append($('<option>', { value : field.type }).text(field.typeName));
				types.push(field.type);
			}
		});

		$('#toggleBoxes').on('cbClearFieldFilters', function() {
			var $searchFieldInput =  $(this).find('.search-field-input');

			$(this).find('.search-type-selector').val(-1);

			$searchFieldInput.val('');
			$searchFieldInput.trigger('input');
		});
	});
<c:if test="${canAdminTracker || canEditFieldPermissions}">

	$('#trackerLayoutForm > div.actionBar').ajaxSubmitButton({
		id          : 'saveTrackerFieldsSubmitButton',
	    submitText  : '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${layoutUrl}',
	    submitData	: function() {
							return $('#trackerLayoutForm').getTrackerFieldsConfiguration();
					  },
		onSuccess	: function(result) {
							showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));

							// Reload the resulting tracker configuration
							$('#trackerLayoutForm').submit();
					  }
	});

</c:if>
</script>
