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
<%@ taglib uri="taglib"   prefix="tag"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="callTag" prefix="ct" %>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />

<style type="text/css">
	.actionBar .rightAlignedDescription {
		padding: 4px;
	}
	.formTableWithSpacing {
		margin-top: 15px;
	}
	.ditch-tab-pane-wrap {
		margin-right: 0px;
	}
	.msTD {
		padding-top: 5px !important;
		padding-bottom: 5px !important;
	}
	#startDate {
		margin-top: 5px !important;
		margin-bottom: 5px !important;
	}
	.ditch-tab-pane {
		margin-bottom: 10px !important;
	}
	.descLTD {
		vertical-align: bottom !important;
		padding-bottom: 15px !important;
	}
	<%-- TODO: should be applied everywhere ? --%>
	.newskin input[type="checkbox"], .newskin input[type="radio"] {
		vertical-align: text-bottom;
		position: relative;
		top: -1px;
	}

	.status-color-box {
		display: block;
		height: 13px;
		width: 13px;
	}

	table.statustable {
		margin-right: 2em;
	}

	table.statustable td {
		padding: 0.5em;
		border-bottom: 1px solid #d1d1d1;
	}

	table.statustable td.last {
		border-bottom: none !important;
	}

	table.statustable td.status {
		padding-right: 2em;
	}

	li.tracker, li.moreTrackers {
		margin-top: 6px;
	}

	li.tracker > label {
		font-weight: bold;
	}

	li.filter label {
		font-weight: bold;
	}

	ul.trackerData li.category {
		list-style-type: square;
	}

	li.category {
		margin-top: 3px;
	}

	ul.fields li.field, ul.fields li.moreFields {
		list-style-type: circle;
	}

	li.field > label {
		font-weight: bold;
	}

	ul.references li.reference, ul.references li.moreRefs {
		list-style-type: circle;
	}

	li.reference > label {
		font-weight: bold;
	}

	ul.assocTypes li.moreAssocs {
		list-style-type: circle;
	}

	li.tracker > label > span.ui-icon, li.field > span.ui-icon, li.reference > span.ui-icon {
		display: none;
	}

	li.tracker > label:hover > span.ui-icon, li.field:hover > span.ui-icon, li.reference:hover > span.ui-icon {
		display: inline-block;
	}

	li.fields > a.edit-link {
		display: none;
	}

	li.fields:hover > a.edit-link {
		display: inline-block;
	}

	div.destination {
		margin-left: 2em;
		margin-top: 6px;
		margin-bottom: 6px;
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

	td.specificationTarget form, td.itemTarget form, td.relationTarget form, span.destination form {
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
	div.attrTarget:hover img.inlineEdit, div.optTarget:hover img.inlineEdit, td.relationTarget:hover img.inlineEdit,
	td.reqIFSource:hover img.inlineEdit, span.destination:hover img.inlineEdit {
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

	tr.join-row {
		background-color: #f5f5f5;
	}

	#icon-file-upload {
		margin-left: 5px;
		float: left;
		width: 70%;
	}

	#predefined-icon-list {
		float: left;
	}

	span.invalidfield {
		display: inline-block;
	}

	.project-icon.selected {
		border: 1px solid #ffab46;
	}

	span.removeButton {
		top: 3px;
		margin: 0 3px 0 0;
		height: 16px;
	}

	.explanation {
        margin: 10px 0;
	}

	.projectSettingsTable {
		width: 100%;
		margin: 10px 0;
	}

	.projectSettingsTable td {
		padding: 3px;
	}

	.projectSettingsTable .labelcell {
		width: 15%;
	}
</style>

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.ui.position.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-fileupload/jquery.iframe-transport.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-fileupload/jquery.fileupload.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/admin/project/exportConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/admin/project/create/importConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/selectorUtils.js'/>"></script>

<jsp:include page="/bugs/includes/remoteImport.jsp" />
<jsp:include page="/bugs/includes/doorsBridge.jsp" />
<jsp:include page="/bugs/includes/doorsProject.jsp" />


<script type="text/javascript">
function confirmDelete(button) {
	var msg = '<spring:message javaScriptEscape="true" code="proj.admin.delete.project.confirm" />';
	return showFancyConfirmDialog(button, msg);
}

var exportAsTemplate = {
	title 		: '<spring:message code="project.template.export.title" text="Exporting project {0} as a template" arguments="XXX" javaScriptEscape="true"/>',
	including	: '<spring:message code="project.template.export.including.label" text="Including" javaScriptEscape="true"/>',
	toggleAll   : '<spring:message code="project.template.export.including.tooltip" text="Additional project components to include in the template. Click here to toggle the current selection" javaScriptEscape="true"/>',
	wikiPages   : '<spring:message code="project.creation.component.Wiki Pages.label" text="Wiki Pages" javaScriptEscape="true"/>',
	documents   : '<spring:message code="Documents" text="Documents" javaScriptEscape="true"/>',
	trackerItems: '<spring:message code="Issues" text="Work Items" javaScriptEscape="true"/>',
	associations: '<spring:message code="project.export.associations.label" text="Associations" javaScriptEscape="true"/>',
	queries     : '<spring:message code="Queries" text="Queries" javaScriptEscape="true"/>',
	branches    : '<spring:message code="Branches" text="Branches" javaScriptEscape="true"/>',
	trackers    : '<spring:message code="Trackers" text="Trackers" javaScriptEscape="true"/>',
	trackersHint    : '<spring:message code="project.template.export.tracker.hint" text="It is possible to choose trackers to export if the checkbox is disabled." javaScriptEscape="true"/>',
	submitText	: '<spring:message code="button.ok"     text="OK" javaScriptEscape="true"/>',
	cancelText	: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
	exportUrl	: '<c:url value="/proj/admin/exportAsTemplate.spr?proj_id="/>',
	dialogClass	: 'popup',
	position	: { my: "center", at: "center", of: window, collision: 'fit' },
	modal		: true,
	width		: 360,
	hasBranchingLicense: ${hasBranchingLicense}
};

function showTemplateExport(project, config) {
	var settings = $.extend({}, config, exportAsTemplate);
	var popup    = $('#exportDialogPopup');

	popup.empty();
	popup.append($('<p>', { title : settings.toggleAll, style : 'font-weight: bold;' }).text(settings.including + ':'));

	var exportDocs    = $('<input>', { type : 'checkbox', id : 'expTmplDocsCB',    checked : true });
	var exportWiki    = $('<input>', { type : 'checkbox', id : 'expTmplWikiCB',    checked : true });
	var exportItems   = $('<input>', { type : 'checkbox', id : 'expTmplItemsCB',   checked : true });
	var exportQueries = $('<input>', { type : 'checkbox', id : 'expTmplQueriesCB', checked : true });

	var exportBranchOptions = { type : 'checkbox', id : 'expTmplBranchesCB', checked : settings.hasBranchingLicense };
	if (!settings.hasBranchingLicense) {
		exportBranchOptions["disabled"] = "disabled";
	}

	var exportBranches = $('<input>', exportBranchOptions);
	var exportTrackerBox = $('<input>', { type : 'checkbox', id : 'expTmplTrackerBoxCB', checked : true });
	var exportTrackers = $('<select>', { "class" : 'selector trackerSelectorTag', id : 'expTmplTrackersCB', multiple : 'multiple', style :'display: none' });
	var exportForm = $('<form>', { style : 'display: hidden', action : settings.exportUrl + project.id, method : 'POST', id: 'exportForm' });

	popup.append(exportDocs   ).append($('<label>', { 'for' : 'expTmplDocsCB'    }).text(settings.documents)).append($('<br>'));
	popup.append(exportWiki   ).append($('<label>', { 'for' : 'expTmplWikiCB'    }).text(settings.wikiPages)).append($('<br>'));
	popup.append(exportItems  ).append($('<label>', { 'for' : 'expTmplItemsCB'   }).text(settings.trackerItems)).append($('<br>'));
	popup.append(exportQueries).append($('<label>', { 'for' : 'expTmplQueriesCB' }).text(settings.queries)).append($('<br>'));
	popup.append(exportBranches).append($('<label>', { 'for' : 'expTmplBranchesCB' }).text(settings.branches)).append($('<br>'));
	popup.append(exportTrackerBox).append($('<label>', { 'for' : 'expTmplTrackerBoxCB' }).text(settings.trackers));
	popup.append($('<div>', { "class" : 'hint', style : 'display: inline-block; margin-left: 5px;'}).text(settings.trackersHint));
	popup.append($('<br>'));
	popup.append(exportTrackers);

	var trackerSelectorConf = {
		"projectId" : ${project.id},
		"multiple" : 'true',
		"showBranches" : 'false',
		"showHiddenTrackers" : 'true',
		"notAllowedTypes" : [7,9,901,902,903,904,905,906,10000]
  	};
	codebeamer.SelectorUtils.initTrackerSelector($("#expTmplTrackersCB"), trackerSelectorConf);

	var selectorButton = $("[type=button][class*='trackerSelectorTag']");
	exportTrackerBox.change(function() {

		if(this.checked) {
			selectorButton.hide();
		} else {
			selectorButton.show();
		}
	});

	selectorButton.hide();

	settings.title = settings.title.replace('XXX', project.name);
	settings.width = 'auto';
	settings.buttons = [{
		text : settings.submitText,
		click: function() {
			var options = {
				skipDocuments    : !exportDocs.is(':checked'),
				skipWikiPages    : !exportWiki.is(':checked'),
				skipTrackerItems : !exportItems.is(':checked'),
				skipQueries 	 : !exportQueries.is(':checked'),
				skipBranches 	 : !exportBranches.is(':checked'),
				skipTrackers 	 : !exportTrackerBox.is(':checked')
			};

			popup.dialog("close");
			popup.append(exportForm);
			exportForm.append($('<input>', { 'type' : 'hidden', 'name' : 'options', 'value':JSON.stringify(options)}));
			var $sel = $("[name=multiselect_expTmplTrackersCB]:checked");
            var selectedTrackers = $.map($sel, function (elem) {
                return $(elem).val();
            }).join();
			exportForm.append($('<input>', { 'type' : 'hidden', 'name' : 'selectedTrackers', 'value':selectedTrackers}));
			exportForm.submit();
		}
	}, {
		text  : settings.cancelText,
	   "class": "cancelButton",
		click : function() {
			popup.dialog("close");
		}
	}];

	popup.dialog(settings);

	return false;
}

var exportAsReqIF = {
	type			 : 'ReqIF',
	title 			 : '<spring:message code="project.reqIF.export.title" text="Select project contents to be exported as ReqIF" javaScriptEscape="true"/>',
	destinationsUrl  : '<c:url value="/proj/ajax/ReqIFDestinations.spr"/>',
	exportConfigUrl  : '<c:url value="/proj/ajax/ReqIFExportConfig.spr"/>',
	trackersUrl	     : '<c:url value="/proj/ajax/ReqIFExportTrackers.spr"/>',
	trackerConfigUrl : '<c:url value="/trackers/ajax/ReqIFExportTrackerConfig.spr"/>',

	menu			 : {
		label   	 : '<spring:message code="project.reqIF.export.label"   text="As ReqIF archive" javaScriptEscape="true"/>',
		title   	 : '<spring:message code="project.reqIF.export.tooltip" text="Export selected contents of this project as a ReqIF archive" javaScriptEscape="true"/>',
		selector	 : 'li.ui-menu-item > a.exportAsReqIF',
		trigger		 : 'hover',

		sources 	 : {
			url		 : '<c:url value="/ajax/project/getReqIFImportConfigs.spr"/>',
			backTo	 : {
				label: '<spring:message code="project.reqIF.export.backTo.label"   text="Back to" javaScriptEscape="true"/>',
				title: '<spring:message code="project.reqIF.export.backTo.tooltip" text="Export a ReqIF update response for a ReqIF data source, where data was previously imported from" javaScriptEscape="true"/>'
			},
			Origin	 : {
				label: '<spring:message code="project.reqIF.export.backTo.origin.label"   text="Origin ..." javaScriptEscape="true"/>',
				title: '<spring:message code="project.reqIF.export.backTo.origin.tooltip" text="Export a ReqIF update response back to the origin of this project" javaScriptEscape="true"/>'
			}
		},

		forward 	 : {
			label	 : '<spring:message code="project.reqIF.export.forward.label"   text="Forward ..." javaScriptEscape="true"/>',
			title	 : '<spring:message code="project.reqIF.export.forward.tooltip" text="Forward selected contents of this project as a ReqIF archive" javaScriptEscape="true"/>'
		}
	},

	initialFields : {
		"102" 	  : [0, 3, 7, 13, 14, 80, 10000, 10001, 1000000],
		"108" 	  : [0, 3, 7, 13, 80, 10000, 1000000],
		"109" 	  : [0, 3, 7, 13, 80],
		"default" : [0, 2, 3, 7, 13, 14, 15, 80]
	},

	defaultField  : function(tracker, field) {
		var type = tracker.type.id.toString();

		if (!$.isArray(exportAsReqIF.initialFields[type])) {
			type = 'default';
		}

		return field && $.inArray(field.id, exportAsReqIF.initialFields[type]) != -1;
	},

	executeExport : function(config) {
		var result = null;

		$.ajax('<c:url value="/proj/ajax/setReqIFExportConfig.spr"/>', {
			type		: 'POST',
			async		: false,
			data 		: JSON.stringify(config),
			contentType : 'application/json',
			dataType 	: 'json'
		}).done(function() {
			result = '<c:url value="/proj/exportAsReqIF.spr?proj_id="/>' + config.id;
		}).fail(function(jqXHR, textStatus, errorThrown) {
    		try {
	    		var exception = $.parseJSON(jqXHR.responseText);
	    		alert(exception.message);
    		} catch(err) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
    		}
		});

		return result;
	}
};

var importReqIF = {
	type		: 'ReqIF',
	title 		: '<spring:message code="project.reqIF.import.title" text="Import a ReqIF file/archive" javaScriptEscape="true"/>',
	uploadURL	: '<c:url value="/ajax/project/{projectId}/uploadReqIF.spr"/>',
	importURL	: '<c:url value="/ajax/project/{projectId}/upload/{uploadId}/importReqIF.spr?source={source}"/>',

	done : function(result) {
		if ($.isArray(result) && result.length > 0) {
			$('#importDialogPopup').empty().remoteImportStatistics(result, remoteImportStatisticsConfig).dialog($.extend({}, $.fn.showRemoteImportHistoryDialog.defaults, {
				title : '<spring:message code="project.reqIF.import.title" text="Import a ReqIF file/archive" javaScriptEscape="true"/>'
			}));
		} else {
			showFancyAlertDialog('<spring:message code="project.reqIF.import.finished" text="The ReqIF import finished successfully, but there were no new tracker items to import, update or delete" javaScriptEscape="true"/>');
		}
	}
};

function showExportDialog(project, extension) {
	$('#exportDialogPopup').showExportConfigurationDialog(project, {
		title				: extension.title,
		waitText			: '<spring:message code="ajax.please.wait" text="Please wait..." javaScriptEscape="true"/>'
	}, {
		assocTypes			: ${assocTypes},
		trackerViewUrl		: '<c:url value="/trackers/ajax/view.spr"/>',
		trackerItemFilters	: [<c:forEach items="${trackerItemFilters}" var="filter" varStatus="loop">{ id: -${filter.id}, name: '<spring:message code="issue.flags.${filter.name}.label" text="${filter.name}" javaScriptEscape="true"/>' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		submitText			: '<spring:message code="button.ok"     text="OK" javaScriptEscape="true"/>',
		cancelText			: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
		saveText			: '<spring:message code="import.config.save.label" text="Save..." javaScriptEscape="true"/>',
		loadText			: '<spring:message code="import.config.load.label" text="Load..." javaScriptEscape="true"/>',
		loadSaveHint		: '<spring:message code="project.export.hint" text="You can also <Load> a previously saved configuration, or <Save> this configuration for later re-use" javaScriptEscape="true"/>',
		notSupportedHint	: '<spring:message code="project.export.notSupported.hint" text="Please note that due to technical limitations, saving/loading mapping configuration is not yet supported in Internet Explorer." javaScriptEscape="true"/>',
		destinationLabel	: '<spring:message code="project.export.destination.label" text="Destination" javaScriptEscape="true"/>',
		destinationTooltip	: '<spring:message code="project.export.destination.tooltip" text="Please select the type of the destination/target system for the export" javaScriptEscape="true"/>',
		destinationOrigin	: '<spring:message code="project.export.destination.origin" text="Origin" javaScriptEscape="true"/>',
		destinationOther	: '<spring:message code="project.export.destination.other" text="Other" javaScriptEscape="true"/>',
		trackersTitle		: '<spring:message code="project.export.trackers.title" text="Please select trackers/categories, whose items should be exported" javaScriptEscape="true"/>',
	    trackersNone		: '<spring:message code="project.export.trackers.none" text="Please select" javaScriptEscape="true"/>',
	    trackersMore		: '<spring:message code="project.export.trackers.more" text="More Trackers ..." javaScriptEscape="true"/>',
	    trackersRequired	: '<spring:message code="project.export.trackers.missing" text="You must at least select one tracker to be exported" javaScriptEscape="true"/>',
	    trackerRemoveLabel  : '<spring:message code="project.export.trackers.remove.label" text="Remove" javaScriptEscape="true"/>',
	    trackerRemoveTooltip: '<spring:message code="project.export.trackers.remove.tooltip" text="Remove this tracker from export" javaScriptEscape="true"/>',
	    itemsLabel			: '<spring:message code="tracker.reference.choose.items" text="Items/Issues" javaScriptEscape="true"/>',
		inFolderLabel		: '<spring:message code="issue.references.in.label" text="in" javaScriptEscape="true"/>',
		itemFilterLabel		: '<spring:message code="project.export.items.label" text="Items" javaScriptEscape="true"/>',
		itemFilterTitle		: '<spring:message code="project.export.items.tooltip" text="Which items in this tracker/category should be exported" javaScriptEscape="true"/>',
		createViewLabel		: '<spring:message code="tracker.notification.changeFilter.create.label" text="New" javaScriptEscape="true"/>',
		editViewLabel		: '<spring:message code="tracker.notification.changeFilter.edit.label" 	text="Edit" javaScriptEscape="true"/>',
 		fieldsLabel			: '<spring:message code="project.export.fields.label" text="Fields" javaScriptEscape="true"/>',
  		fieldsTooltip		: '<spring:message code="project.export.fields.tooltip" text="These fields/attributes can be exported" javaScriptEscape="true"/>',
	    fieldsNone			: '<spring:message code="project.export.fields.none" text="Please select" javaScriptEscape="true"/>',
	    fieldsMore			: '<spring:message code="project.export.fields.more" text="More Fields ..." javaScriptEscape="true"/>',
  		fieldsSelectAll		: '<spring:message code="project.export.fields.select.all" text="Select all" javaScriptEscape="true"/>',
  		fieldsRemoveAll		: '<spring:message code="project.export.fields.remove.all" text="Deselect all" javaScriptEscape="true"/>',
  		fieldRemoveLabel	: '<spring:message code="project.export.fields.remove.label" text="Remove" javaScriptEscape="true"/>',
  		referencesLabel		: '<spring:message code="project.export.references.label" text="References" javaScriptEscape="true"/>',
  		referencesTooltip	: '<spring:message code="project.export.references.tooltip" text="Also export these referencing items/issues" javaScriptEscape="true"/>',
  		referencesNone		: '<spring:message code="project.export.references.none" text="None" javaScriptEscape="true"/>',
  		referencesMore		: '<spring:message code="project.export.references.more" text="More..." javaScriptEscape="true"/>',
  		associationsLabel	: '<spring:message code="project.export.associations.label" text="Associations" javaScriptEscape="true"/>',
  		associationsTooltip	: '<spring:message code="project.export.associations.tooltip" text="Also export item/issue associations of this type" javaScriptEscape="true"/>',
  		associationsNone	: '<spring:message code="project.export.associations.none" text="None" javaScriptEscape="true"/>',
  		associationsAll		: '<spring:message code="project.export.associations.all" text="All" javaScriptEscape="true"/>',
  		extension			: extension

	}, extension);

	return false;
}

function showImportDialog(config, extension) {
	$('#importDialogPopup').showImportConfigurationDialog(config, {
		title				   : extension.title
	}, {
		intro				   : '<spring:message code="import.config.intro" text="Please specify the mapping of input data to target project trackers, fields and choice options. You can also <Save> your final mapping or <Load> a previously saved mapping." javaScriptEscape="true"/>',
		noSupport			   : '<spring:message code="import.config.noSupport" text="Please specify the mapping of input data to target project trackers, fields and choice options. Please note that due to technical limitations, saving/loading mapping configuration is not yet supported in Internet Explorer." javaScriptEscape="true"/>',
		saveLabel			   : '<spring:message code="import.config.save.label" text="Save..." javaScriptEscape="true"/>',
		loadLabel			   : '<spring:message code="import.config.load.label" text="Load..." javaScriptEscape="true"/>',
		inputLabel			   : '<spring:message code="import.config.input.label" text="Input" javaScriptEscape="true"/>',
		source				   : {
			label			   : '<spring:message code="import.config.source.label"   text="Source" javaScriptEscape="true"/>',
			title			   : '<spring:message code="import.config.source.tooltip" text="The source of the ReqIF file/archive to import" javaScriptEscape="true"/>',
			select			   : {
				label		   : '<spring:message code="import.config.source.select.label"   text="Please select" javaScriptEscape="true"/>',
				title		   : '<spring:message code="import.config.source.select.tooltip" text="Please select the source of the ReqIF file/archive to import" javaScriptEscape="true"/>',
				hint 		   : '<spring:message code="import.config.source.select.hint"    text="(Double) Click, to choose a predefined ReqIF source, or to define a new ReqIF source" javaScriptEscape="true"/>'
			},
			"new"			   : {
				label		   : '<spring:message code="import.config.source.new.label"  text="New Source" javaScriptEscape="true"/>',
				title		   : '<spring:message code="import.config.source.new.name"   text="The name of the new ReqIF source (required)" javaScriptEscape="true"/>',
				exists 		   : '<spring:message code="import.config.source.new.exists" text="A ReqIF source with the specified name already exists !" javaScriptEscape="true"/>'
			},
			Origin			   : {
				label		   : '<spring:message code="import.config.source.origin.label"   text="Origin" javaScriptEscape="true"/>',
				title		   : '<spring:message code="import.config.source.origin.tooltip" text="The source of the ReqIF file/archive, that was uses to create this project" javaScriptEscape="true"/>'
			},
			configURL		   : '<c:url value="/proj/ajax/ReqIFImportConfig.spr"/>'
		},
		targetLabel			   : '<spring:message code="import.config.target.label" text="Target" javaScriptEscape="true"/>',
		toggleLabel			   : '<spring:message code="import.config.input.empty.label" text="including empty" javaScriptEscape="true"/>',
		toggleTitle			   : '<spring:message code="import.config.input.empty.tooltip" text="Whether to show or hide empty input specifications, item types, relations and attributes" javaScriptEscape="true"/>',
		emptyConfirm		   : '<spring:message code="import.config.input.empty.confirm" text="The ReqIF archive to import does not contain Specifications and Item Types or they are empty ! Do you want to import empty Specifications and Item Types ?" javaScriptEscape="true"/>',
		countLabel			   : '<spring:message code="import.config.count.label" text="Count" javaScriptEscape="true"/>',
		valuesLabel			   : '<spring:message code="import.config.values.label" text="First 10 distinct values" javaScriptEscape="true"/>',
		itemsLabel			   : '<spring:message code="import.config.items.label" text="Item Types" javaScriptEscape="true"/>',
		unmappedItems		   : '<spring:message code="import.config.items.umapped" text="Item Types not mapped yet" javaScriptEscape="true"/>',
		relationsLabel		   : '<spring:message code="import.config.relations.label" text="Relation Types" javaScriptEscape="true"/>',
		specTypesLabel	   	   : '<spring:message code="import.config.specTypes.label" text="Specification Types" javaScriptEscape="true"/>',
		specificationsLabel	   : '<spring:message code="import.config.specifications.label" text="Specifications" javaScriptEscape="true"/>',
		unmappedSpecifications : '<spring:message code="import.config.specifications.unmapped" text="Specifications not mapped yet" javaScriptEscape="true"/>',
		selectTrackerLabel	   : '<spring:message code="import.config.select.tracker.label" text="Please select" javaScriptEscape="true"/>',
		selectTrackerTitle	   : '<spring:message code="import.config.select.tracker.tooltip" text="You must either choose a predefined target tracker, or right click, to define a new tracker" javaScriptEscape="true"/>',
		clickToEditTracker	   : '<spring:message code="import.config.edit.tracker.tooltip" text="(Double) Click, to choose a predefined tracker, or to define a new tracker" javaScriptEscape="true"/>',
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
		selectFieldTitle	   : '<spring:message code="import.config.select.field.tooltip" text="You must either choose a predefined field, or right click, to define a new field" javaScriptEscape="true"/>',
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
		selectValueTitle	   : '<spring:message code="import.config.select.value.tooltip" text="You must either choose a predefined value, or right click, to define a new value" javaScriptEscape="true"/>',
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
		selectAssocTypeTitle   : '<spring:message code="import.config.select.assoc.type.tooltip" text="You must choose a predefined association type" javaScriptEscape="true"/>',
		referenceFieldsLabel   : '<spring:message code="import.config.ref.fields.label" text="and/or" javaScriptEscape="true"/>',
		referenceFieldsTitle   : '<spring:message code="import.config.ref.fields.tooltip" text="You can choose reference fields, to create references in conjunction with/instead of associations." javaScriptEscape="true"/>',
		noReferenceFieldsLabel : '<spring:message code="import.config.ref.fields.none" text="No references" javaScriptEscape="true"/>',
		moreReferenceFieldsLabel: '<spring:message code="import.config.ref.fields.more" text="More references..." javaScriptEscape="true"/>',
		copyFromLabel	   	   : '<spring:message code="import.config.copy.from.label" text="Copy from" javaScriptEscape="true"/>',
		submitText			   : '<spring:message code="button.ok"     text="OK" javaScriptEscape="true"/>',
		cancelText			   : '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>'

	}, extension);

	return false;
}

/**
 * Show a file selector and let the user select a single file.
 * Send this file (in a multi-part POST request) to extension.uploadURL (replace {projectId} in the URL with the current project.id)
 * On success, the file POST request returns JSON data that must be passed on to showImportDialog()
 */
function startFileImport(project, extension) {
	$('#importFileSelector').val(''); // clean previously added file
    $('#importFileSelector').fileupload({
		url     		  : extension.uploadURL.replace('{projectId}', project.id),
		type    		  : 'POST',
        dataType		  : 'json',
        dropZone          : null,
        autoUpload 		  : true,
        replaceFileInput  : false,
        singleFileUploads : true,

        add	: function(e, data) {
			var busy = ajaxBusyIndicator.showBusyPage();
	       	data.submit().success(function(result) {
				ajaxBusyIndicator.close(busy);
	       		showImportDialog(result, extension);
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
				ajaxBusyIndicator.close(busy);
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });
        }
    });
	$("#importFileSelector").click();

	return false;
}

</script>


<ui:showErrors />

<%-- hidden form to submit project-delete --%>
<form id="deleteProjectForm" action="<c:url value='/proj/deleteProject.spr?projectId=${project.id}'/>" method="post" style="display:none;"></form>

<form id="projectSettingsForm" action="<c:url value="/proj/admin/settings.spr?proj_id=${project.id}"/>" method="post">

	<input type="hidden" name="proj_id" value="<c:out value='${project.id}'/>"/>
	<input type="hidden" name="version" value="<c:out value='${project.version}'/>"/>
	<input type="hidden" name="deleted" value="<c:out value='${project.deleted}'/>"/>
	<input type="hidden" name="options" value="<c:out value='${options}'/>"/>
	<input type="hidden" name="scheduledJobs" value="" id="projectScheduledJobs"/>

	<div class="actionBar">
		&nbsp;&nbsp;
		<spring:message var="saveButton" code="button.save" text="Save"/>
		<input id="saveButton" type="submit" class="button" name="SAVE" value="${saveButton}" />

		&nbsp;&nbsp;
		<c:choose>
			<c:when test="${project.deleted}">
				<spring:message var="restoreButton"  code="project.restore.button.label" text="Restore Project..."/>
				<spring:message var="restoreTitle"   code="project.restore.button.tooltip" text="Restore the removed project and its contents"/>
				<spring:message var="restoreConfirm" code="proj.admin.restore.project.confirm" javaScriptEscape="true" />
				<input type="submit" class="button" name="RESTORE" value="${restoreButton}" title="${restoreTitle}" onclick="return showFancyConfirmDialog(this, '${restoreConfirm}');"/>

				<c:if test="${empty derivedTrackers}">
					&nbsp;&nbsp;

					<spring:message var="deleteButton"  code="project.delete.button.label" text="Delete Project..."/>
					<spring:message var="deleteTitle"   code="project.delete.button.tooltip" text="Irreversibly delete the project and its contents"/>
					<spring:message var="deleteConfirm" code="proj.admin.delete.project.confirm" javaScriptEscape="true" />
					<input type="button" class="button" value="${deleteButton}" title="${deleteTitle}"
							onclick="if (showFancyConfirmDialog(this, '${deleteConfirm}')) { document.getElementById('deleteProjectForm').submit(); }; return false;"
							/>
				</c:if>
			</c:when>
			<c:otherwise>
				<spring:message var="removeButton"  code="project.remove.button.label" text="Remove Project..."/>
				<spring:message var="removeTitle"   code="project.remove.button.tooltip" text="Reversibly remove the project and its contents"/>
				<spring:message var="removeConfirm" code="proj.admin.remove.project.confirm" javaScriptEscape="true" />
				<input type="submit" class="button" name="REMOVE" value="${removeButton}" title="${removeTitle}" onclick="return showFancyConfirmDialog(this, '${removeConfirm}');"/>
			</c:otherwise>
		</c:choose>

		&nbsp;&nbsp;
		<ui:actionMenu builder="projectExportActionMenuBuilder" subject="${project}" inline="true" cssClass="actionLink">
			<spring:message code="project.export.menu.label" text="Export..."/>
		</ui:actionMenu>

		<ui:actionMenu builder="projectImportActionMenuBuilder" subject="${project}" inline="true" cssClass="actionLink">
			<spring:message code="project.import.menu.label" text="Import..."/>
		</ui:actionMenu>

		&nbsp;&nbsp;
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<span class="rightAlignedDescription">
			<spring:message code="project.administration.general.tooltip" text="You can edit the Name, Description, Category, Home Page, Access properties of the project or you can Delete this project."/>
		</span>
	</div>

	<c:if test="${project.deleted and not empty derivedTrackers}">
		<div class="warning">
			<spring:message code="project.derived.trackers.hint" text="You can't delete this project permanently because some of its trackers are used as templates by the following trackers"/>:
			<c:forEach items="${derivedTrackers}" var="tracker" varStatus="loopStatus">
				<c:url value="${tracker.urlLink }" var="trackerUrl"/>

				<a href="${trackerUrl}" title="${tracker.name}">${tracker.project.name } - ${tracker.name}</a>
				<c:if test="${not loopStatus.last }">, </c:if>
			</c:forEach>
		</div>
	</c:if>

	<c:if test="${deletedProjectCancelled}">
		<div class="warning">
			<spring:message code="project.deleted.cancelled.hint" text="You have cancelled the modifications of the project settings."/>
		</div>
	</c:if>

	<table class="projectSettingsTable">
		<tr>
			<td class="mandatory labelcell" style="vertical-align: middle;"><spring:message code="project.name.label" text="Name"/>:</td>
			<td class="expandText">
				<form:input id="name" path="project.name" size="80" maxlength="200"/>
				<c:if test="${!empty fieldErrors['name']}"><br><span class="invalidfield"><c:out value="${fieldErrors['name']}" /></span></c:if>
			</td>
		</tr>
		<tr>
			<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.keyName.label" text="Key (short name)"/>:</td>
			<td class="expandtext" nowrap>
				<form:input id="keyName" path="project.keyName" size="10" maxlength="10"/>
				&nbsp;&nbsp;
				<spring:message var="templateTitle" code="project.template.tooltip" text="Whether this project can be used as template when creating new projects?" htmlEscape="true"/>
				<input type="checkbox" name="template" value="true" id="templateCheckbox" class="templateCheckbox" style="vertical-align:middle;" title="${templateTitle}" <c:if test="${project.template}">checked="checked"</c:if>/>
				<label title="${templateTitle}" for="templateCheckbox"><strong><spring:message code="project.template.enabled" text="Available as template"/></strong></label>
				<c:if test="${!empty fieldErrors['keyName']}"><br><span class="invalidfield"><c:out value="${fieldErrors['keyName']}" /></span></c:if>
			</td>
		</tr>
		<tr>
			<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.category.label" text="Category"/>:</td>
			<td class="expandText">
				<input type="text" size="80" maxlength="100" name="category" value="<spring:message code="project.category.${project.category}.label" text="${project.category}" htmlEscape="true"/>"/>
			</td>
		</tr>

		<tr>
			<td class="optional labelCell"><spring:message code="project.image.label" text="Image"/>:</td>
			<td class="expandText">
				<div class="warning" style="display: none; margin-left: 0px;" id="upload-warning">
					<spring:message code="project.image.selected.warning" text="Save the project peoperties to set the new icon"></spring:message>
				</div>
				<spring:message code="project.image.change.hint" text="Click here to change the icon of the project" var="changeIconHint"/>
				<div class="predefined-icon-list" id="predefined-icon-list">
					<ct:call object="${predefinedIcons}" method="contains" return="contains" param1="${selectedIcon}"/>
					<c:if test="${contains }">
						<c:url var="iconUrl" value="/images/newskin/action/projectbrowser/icons/${selectedIcon}.png"/>
						<label for="${icon}" class="project-icon" id="currentIcon" title="${changeIconHint}">
							<img src="${iconUrl}"/>
						</label>
					</c:if>
					<c:if test="${!contains }">
						<ct:call object="${uploadedIconIds}" method="contains" return="contains" param1="${selectedIcon}"/>
						<c:if test="${contains }">
							<c:url var="iconUrl" value="/displayDocument?doc_id=${selectedIcon}"/>
							<label for="${icon}" class="project-icon" id="currentIcon" title="${changeIconHint}">
								<img src="${iconUrl}"/>
							</label>
						</c:if>
					</c:if>
				</div>
				<div id="icon-file-upload">
					<ui:fileUpload uploadConversationId="${uploadConversationId}" conversationFieldName="uploadConversationId" single="true"
						cssClass="inlineFileUpload" onCompleteCallback="clearPreviousError"/>
					<c:if test="${!empty fieldErrors['uploadConversationId']}"><span class="invalidfield"><c:out value="${fieldErrors['uploadConversationId']}" /></span><br><br></c:if>
				</div>
				<div style="display:none;" id="predefinedIconRadios">
					<c:forEach items="${predefinedIcons}" var="icon">
						<input type="radio" name="predefinedIcon" id="${icon}" value="${icon}" <c:if test="${selectedIcon == icon}">checked="checked"</c:if>/>
					</c:forEach>
					<c:forEach items="${uploadedIconIds}" var="iconId">
						<input type="radio" name="predefinedIcon" id="${iconId}" value="${iconId}" <c:if test="${selectedIcon == iconId}">checked="checked"</c:if>/>
					</c:forEach>
				</div>
				<div id="predefinedIcon" class="project-icon-list" style="display:none">
					<c:forEach items="${predefinedIcons}" var="icon">
						<c:url var="iconUrl" value="/images/newskin/action/projectbrowser/icons/${icon}.png"/>
						<label for="${icon}" class="project-icon">
							<img src="${iconUrl}"/>
						</label>
					</c:forEach>
					<c:forEach items="${uploadedIconIds}" var="iconId">
						<c:url var="iconUrl" value="/displayDocument?doc_id=${iconId}"/>
						<label for="${iconId}" class="project-icon">
							<img src="${iconUrl}"/>
						</label>
					</c:forEach>
				</div>
			</td>
		</tr>
		<tr style="vertical-align: middle;">
			<td class="optional labelcell" style="vertical-align: top;"><spring:message code="project.menuItems.label" text="Menu Items"/>:</td>

			<td nowrap>
				<c:forEach items="${menuItems}" var="menuItem" varStatus="menuStatus">
					<c:if test="${menuItem.id != 'forum'}">
						<label for="menuItems_${menuItem.id}">
							<input id="menuItems_${menuItem.id}" type="checkbox" name="menuItems" value="${menuItem.id}" <c:if test="${selectedItems[menuItem.id]}">checked="checked"</c:if>/> <c:out value="${menuItem.label}"/>
						</label>
						<c:if test="${!menuStatus.last}">
							&nbsp;&nbsp;
						</c:if>
					</c:if>
				</c:forEach>
				<br>
				<span class="subtext"><spring:message code="project.menuItems.tip" text="If checked then the navigation bar will be displayed on the right hand side of the project Wiki pages."/></span>
			</td>
		</tr>
		<tr style="vertical-align: middle;">
			<td class="optional labelcell" style="vertical-align: top;"><spring:message code="project.wiki.navigation.bar.visible.label" text="Navigation bar on Wiki pages"/>:</td>
			<td>
				<label for="wikiNavigationBarVisible">
					<input id="wikiNavigationBarVisible" type="checkbox" name="wikiNavigationBarVisible" ${wikiNavigationBarVisible ? 'checked="checked"' : ''} /><spring:message code="cmdb.category.visible.label" text="Visible" />
				</label>
				<br>
				<span class="subtext"><spring:message code="project.wiki.navigation.bar.hint.label"/></span>
			</td>
		</tr>
	</table>

	<spring:message var="projectMetaDescriptionLabel" code="project.meta.description.label" text="Project Meta Description"/>
	<ui:collapsingBorder label="${projectMetaDescriptionLabel}" open="false">
		<table class="projectSettingsTable">
			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.status.color.label" text="Status"/>:</td>
				<td>
					<table>
						<tr>
							<td>
								<table class="statustable">
									<tr>
										<td><input id="status-ok" type="radio" name="projectStatus" value="ok"<c:if test="${projectStatus == 'ok' || !projectStatus}"> checked</c:if>></td>
										<td class="status"><label for="status-ok"><spring:message code="project.status.ok.label" text="On Track"/></label></td>
										<td><a class="status-color-box project-status ok"></a></td>
									</tr>
									<tr>
										<td><input id="status-warning" type="radio" name="projectStatus" value="warning"<c:if test="${projectStatus == 'warning'}"> checked</c:if>></td>
										<td class="status"><label for="status-warning"><spring:message code="project.status.warning.label" text="Needs Attention"/></label></td>
										<td><a class="status-color-box project-status warning"></a></td>
									</tr>
									<tr>
										<td><input id="status-alert" type="radio" name="projectStatus" value="alert"<c:if test="${projectStatus == 'alert'}"> checked</c:if>></td>
										<td class="status"><label for="status-alert"><spring:message code="project.status.alert.label" text="Off Track"/></label></td>
										<td><a class="status-color-box project-status alert"></a></td>
									</tr>
									<tr>
										<td class="last">
											<spring:message var="closedTitle" code="project.${project.closed ? 'reopen' : 'close'}.tooltip" htmlEscape="true"/>
											<input id="closedCheckbox" type="checkbox" name="closed" value="true" title="${closedTitle}" <c:if test="${project.closed}">checked="checked"</c:if>/>
										</td>
										<td colspan="2" class="last">
											<label title="${closedTitle}" for="closedCheckbox"><spring:message code="project.closed.label" text="Closed"/></label>
										</td>
									</tr>
								</table>
							</td>
							<td style="vertical-align: top;">
								<b><spring:message code="project.description.label" text="Status"/>:</b>&nbsp;
								<form:input id="status" path="project.status" size="40" maxlength="80" />
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.startEnd.label" text="Start / End"/>:</td>
				<td>
					<input id="startDate" type="text" name="startDate" size="20" maxlength="30" value="<tag:formatDate value="${project.startDate}" type="date"/>" />&nbsp;
					<ui:calendarPopup textFieldId="startDate" otherFieldId="endDate"/>
					&nbsp;/&nbsp;
					<input id="endDate" type="text" name="endDate" size="20" maxlength="30" value="<tag:formatDate value="${project.endDate}" type="date"/>"/>&nbsp;
					<ui:calendarPopup textFieldId="endDate" otherFieldId="startDate" />
					<c:if test="${!empty fieldErrors['startDate']}"><br><span class="invalidfield"><c:out value="${fieldErrors['startDate']}" /></span></c:if>
				</td>
			</tr>

			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.estimatedBudget.label" text="Estimated Budget"/>:</td>
				<td><input type="number" size="20" name="estimatedBudget" value="<c:out value='${estimatedBudget}'/>" /></td>
			</tr>

			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.spentBudget.label" text="Spent Budget"/>:</td>
				<td><input type="number" size="20" name="spentBudget" value="<c:out value='${spentBudget}'/>" /></td>
			</tr>
				<%--<tr>
					<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.estimatedCost.label" text="Estimated Cost"/>:</td>
					<td><input type="text" size="40" name="estimatedCost" value="<c:out value='${estimatedCost}'/>" /></td>
				</tr>--%>
			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.estimatedTime.label" text="Estimated Time"/>:</td>
				<td><input type="number" size="20" name="estimatedTime" value="<c:out value='${estimatedTime}'/>" /> (<spring:message code="project.time.additional.label" text="calculated value in man days"/>)</td>
			</tr>

			<tr>
				<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.spentTime.label" text="Spent Time"/>:</td>
				<td><input type="number" size="20" name="spentTime" value="<c:out value='${spentTime}'/>" /> (<spring:message code="project.time.additional.label" text="calculated value in man days"/>)</td>
			</tr>
		</table>
	</ui:collapsingBorder>

	<table class="projectSettingsTable">
		<tr style="vertical-align: middle;" class="join-row">
			<td class="optional labelcell" style="vertical-align: top;"><spring:message code="project.membershipPolicy.label" text="Membership"/>:</td>

			<td nowrap>
				<input id="membershipPolicy_only_admin" type="radio" name="propagation" value="" <c:if test="${empty project.propagation}">checked="checked"</c:if>/>
				<label for="membershipPolicy_only_admin"><spring:message code="project.membershipPolicy.onlyAdmin" /></label>
				<br/>

				<input id="membershipPolicy_with_approval" type="radio" name="propagation" value="${ANYBODY_CAN_JOIN_WITH_APPROVAL}" <c:if test="${project.propagation eq ANYBODY_CAN_JOIN_WITH_APPROVAL}">checked="checked"</c:if>/>
				<label for="membershipPolicy_with_approval"><spring:message code="project.membershipPolicy.withApproval" /></label>
				<br/>

				<input id="membershipPolicy_everybody" type="radio" name="propagation" value="${ANYBODY_CAN_JOIN_WITHOUT_APPROVAL}" <c:if test="${project.propagation eq ANYBODY_CAN_JOIN_WITHOUT_APPROVAL}">checked="checked"</c:if>/>
				<label for="membershipPolicy_everybody"><spring:message code="project.membershipPolicy.everybody" /></label>
			</td>
		</tr>
		<c:if test="${not empty groups }">
			<tr class="join-row">
				<td class="optional labelcell" style="vertical-align: middle;">
					<spring:message code="project.membershipConstraints.label" text="Membership constraints"/>:
				</td>
				<td style="padding: 5px 0px;">
					<select id="membership_group_constraint" multiple="multiple">
						<c:forEach items="${groups}" var="group">
							<c:set var="selected" value=""/>
							<c:if test="${groupConstraintLookup[group.id] != null }">
								<c:set value="selected='selected'" var="selected"/>
							</c:if>

							<option value="${group.id }" ${selected}><spring:message code="group.${group.name}.label" text="${group.name}"/></option>
						</c:forEach>
					</select>
					<input type="hidden" id="membersipGroupConstraintsField" name="membersipGroupConstraints"/>
					<label for="membership_group_constraint">
						<span class="subtext">
							<spring:message code="project.membersipConstraints.hint" text="If not empty, only the users in the selected groups can join to the public project"/>
						</span>
					</label>
				</td>
			</tr>
		</c:if>

		<tr class="join-row" id="defaultMemberRoleId">
			<td nowrap class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.assignNewMembersToRole.label" text="Assign new members to Role"/>:</td>
			<td>
				<select name="defaultMemberRoleId">
					<option value="">--</option>
					<c:forEach items="${roles}" var="role">
						<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true"/>
						<option value="${role.id}" title="${roleTitle}" <c:if test="${project.defaultMemberRoleId eq role.id}">selected="selected"</c:if>>
							<spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/>
						</option>
					</c:forEach>
				</select>
			</td>
		</tr>

		<tr style="vertical-align: middle;" class="join-row" id="participationConditions">
			<td class="optional labelcell" style="vertical-align: middle;"><spring:message code="project.participationConditions.label" text="Participation Conditions"/>:</td>

			<td nowrap>
				<wysiwyg:froalaConfig />
				<wysiwyg:editor editorId="editor" entity="${project}" useAutoResize="false" height="200" uploadConversationId="" overlayHeaderKey="wysiwyg.participation.conditions.overlay.header">
				    <form:textarea path="project.description" id="editor" rows="12" cols="80" autocomplete="off" />
				</wysiwyg:editor>

				<div class="explanation">
					<span class="subtext"><spring:message code="project.participationConditions.hint"
						text="In this field you can define the prerequisites for a user to be able to join the project and you can introduce the project in a few words. This description is used on the project browser."></spring:message></span>
				</div>
			</td>
		</tr>
	</table>
</form>

<div id="exportDialogPopup" style="display:None;">
</div>

<input id="importFileSelector" type="file" name="file" style="position: fixed; top: -300px;"/>

<div id="importDialogPopup" style="display:None;">
</div>


<script type="text/javascript">
	var focusControl = document.forms["projectSettingsForm"].elements["name"];
	$(focusControl).focus();

	$(document).ready(function () {
		var form = $('#projectSettingsForm');

		form.initExportMenu({
			id   : ${project.id},
			name : '<spring:escapeBody javaScriptEscape="true">${project.name}</spring:escapeBody>',
		}, showExportDialog, exportAsReqIF);

		$('#currentIcon,#changeIcon').click(function () {
			$('#predefinedIcon').dialog({
				'width': 600,
				'dialogClass': 'popup',
				'modal': true,
				'maxHeight': $(window).height() - 100,
				'title': i18n.message('project.image.change.popup.title')
			});
		});

		$("#predefinedIcon label.project-icon").click(function(){
			var $this = $(this);
			$('.project-icon.selected').removeClass('selected');
			$this.addClass('selected');
			$('#upload-warning').show();

			var labelForId = $this.prop('for');
			if (typeof labelForId !== 'undefined' && labelForId.length > 0) {
				$("#" + labelForId).click();
				var $current = $('#currentIcon');
				$current.addClass('selected');
				$current.empty().append($(this).find('img').clone());
				$('#predefinedIcon').dialog("close");
			}
		});

		function validatePage() {

			function isEmptyOrInteger(str) {
				if (str.length == 0) return true;
				return /^\+?(0|[1-9]\d*)$/.test(str);
			}

			var description = $.trim(form.find('input[name="status"]').val());
			var estimatedTime = $.trim(form.find('input[name="estimatedTime"]').val());
			var spentTime = $.trim(form.find('input[name="spentTime"]').val());
			var estimatedBudget = $.trim(form.find('input[name="estimatedBudget"]').val());
			var spentBudget = $.trim(form.find('input[name="spentBudget"]').val());

			if (form.find("input#status-alert").is(':checked') && description.length == 0) {
				alert(i18n.message("project.admin.validation.description"));
				return false;
			}

			if (!isEmptyOrInteger(estimatedTime) || !isEmptyOrInteger(spentTime) || !isEmptyOrInteger(estimatedBudget) || !isEmptyOrInteger(spentBudget)) {
				alert(i18n.message("project.admin.validation.times"));
				return false;
			}

			return true;
		};

		//$("#predefinedIcon").buttonset();
		$('#saveButton').click(function() {
			if (validatePage()) {
				return true;
			} else {
				return false;
			}
		});

		$("[name=propagation]").on("change", highlightMandatory);
		highlightMandatory();

		$('#membership_group_constraint').multiselect({
			"header": "Apply",
			"position": {"my": "left top", "at": "left bottom", "collision": "none none"},
			"selectedText": function(numChecked, numTotal, checked) {
				return $.map(checked, function(a) {
					return $(a).next('span').html();
				}).join(", ");
			},
			"click": function () {
				var $checked = $('#membership_group_constraint').multiselect("getChecked");
				var values = [];
				$checked.each(function () {
					values.push($(this).val());
				});

				if (values) {
					$('#membersipGroupConstraintsField').val(values.join(','));
				} else {
					$('#membersipGroupConstraintsField').val("");
				}
			}
		});
	});

	function highlightMandatory() {
		var privateProject = $("#membershipPolicy_only_admin").is(":checked");

		var rows = $('#defaultMemberRoleId,#participationConditions');
		var labels =  rows.find('td:first');
		if (privateProject) {
			rows.removeClass('highlighted-row');
		} else {
			rows.addClass('highlighted-row');
		}
	}

	function clearPreviousError() {
		$("#icon-file-upload .invalidfield").remove();
		$('#upload-warning').show();
	}
</script>