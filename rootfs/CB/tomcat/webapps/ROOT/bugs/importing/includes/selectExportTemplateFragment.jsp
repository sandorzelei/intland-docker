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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%--
	fragment for selecting which template is going to be used in the export
	use TemplateSelectionCommand command bean for template selection
 --%>
<style type="text/css">
	.templateSelection .float {
		float: left;
	}

	.templateSelection .align-wrapper-middle {
		display: inline-block;
		vertical-align: middle;
	}

	.templateSelection .align-wrapper-top {
		display: inline-block;
		vertical-align: text-top;
	}

	.templateSelection .template-management {
		margin-left: 10px;
	}

	.file-upload-container {
		margin-top: -20px;
		margin-left: 8px;
	}

	.file-upload-container .qq-upload-button {
		margin-right: 1em;
		-webkit-border-radius: 22px;
		-moz-border-radius: 22px;
		border-radius: 22px;
		border: dashed 3px #DDD;
	}

	.file-upload-container .qq-upload-icon {
		display: inline-block;
		vertical-align: top;
		float: none;
	}

	.file-upload-container .qq-upload-text {
		display: inline-block;
		float: none;
	}

	.file-upload-container .fileUpload_dropZone {
		width: 200px;
	}

	.file-upload-container .qq-uploader {
		white-space: nowrap;
	}

	.file-upload-container .qq-upload-list {
		padding-top: 15px;
		margin-left: 0px;
	}

	button.ui-multiselect {
		min-width: 200px !important;
		overflow: hidden;
		position: relative;
		width: 200px;
	}

	button.ui-multiselect span.ui-icon {
		background-color: white;
		position: absolute;
		right: 0;
		top: 2px;
	}

	.templateSelection div.ui-multiselect {
		vertical-align: top;
		position: relative;
		top: -2px;
		min-width: 200px !important;
		width: 200px;
	}

	/* avoid changing font-weight to avoid jumping layout */
	.templateSelection div.ui-multiselect-menu label * {
		font-weight: normal !important;
	}

	div.ui-multiselect-menu label {
		display: table;
	}
	div.ui-multiselect-menu label > input, div.ui-multiselect-menu label > span {
		display: table-cell;
		vertical-align: top;
	}

	div.ui-multiselect-menu {
		z-index: 10;
	}

	.ui-multiselect-menu.ui-widget.ui-widget-content.ui-corner-all.ui-multiselect-single {
		font-weight: normal !important;
		min-width: 200px !important;
		max-width: 400px;
		word-break: break-all;
	}

</style>

<spring:nestedPath path="templateSelection">
<div class="templateSelection">

	<div class="align-wrapper-middle">
		<div class="float">
			<spring:message code="tracker.issues.exportToWord.roundtrip.export.use.template" />
			<spring:message var="tooltip" code="tracker.issues.exportToWord.roundtrip.export.use.template.tooltip" />
			<form:select path="templateName" title="${tooltip}" cssClass="templateName" cssStyle="min-width: 200px; max-width: 200px;" >
				<form:option value="" ><spring:message code="tracker.issues.exportToWord.roundtrip.export.default.template" text="Default template" /></form:option>
				<c:if test="${! empty templateNames}">
					<spring:message var="customTemplates" code="tracker.issues.exportToWord.roundtrip.export.custom.templates" text="Custom templates" />
					<%--
					<optgroup label="${customTemplates}">
					--%>
						<c:forEach var="template" items="${templateNames}">
							<c:set var="templateName"><c:out value="${template.name}" default="" /></c:set>
							<c:set var="templateDescription"><c:out value="${templateDescriptions[template.id]}" default=""/></c:set>
							<c:set var="templateLabel">${templateName}</c:set>
							<c:set var="templateLabel" value="${templateLabel}" />
							<form:option value="${templateName}" label="${templateLabel}" title="${templateDescription}"/>
						</c:forEach>
					<%--
					</optgroup>
					--%>
				</c:if>
			</form:select>
		</div>
	</div>

	<div class="align-wrapper-middle">
		<div class="float template-management">
			<c:choose>
				<c:when test="${! empty templateManagementUrl}">
					<a href="${templateManagementUrl}"><spring:message code="tracker.issues.exportToWord.roundtrip.export.manage.custom.templates" text="Manage custom templates" /></a>
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.issues.exportToWord.roundtrip.export.default.template.download.tooltip" var="tooltip"  />
					<a href="<c:url value='${downloadDefaultRoundtripTemplateUrl}'/>" title="${tooltip}" >
						<spring:message code="tracker.issues.exportToWord.roundtrip.export.default.template.download" />
					</a>
				</c:otherwise>
			</c:choose>
		</div>
	</div>

	<div class="align-wrapper-top">
		<div class="float file-upload-container">
			<ui:fileUpload conversationFieldName="officeExportUploadConversationId"
				uploadConversationId="${command.templateSelection.uploadConversationId}"
				single="true" dndControlMessageCode="tracker.issues.exportToWord.roundtrip.export.upload.template" />
			<form:hidden path="uploadConversationId" />
		</div>
	</div>
</div>
</spring:nestedPath>

<script type="text/javascript">
$(function() {
	$("select.templateName").multiselect({
		multiple: false,
		selectedList: 1,
		// open above the select list
		position: {
			my: 'left bottom',
			at: 'left top'
		},
		open: function(event, ui) {
			// focus to the multiselect-filter when opening this
			// TODO: hm, can not get the multiselect we've opened ?
			$(".ui-multiselect-filter input").first().focus();

			var label = $(".ui-multiselect-menu > ul > li > label");
			label.prop('title', '');
			$("input", label).prop('title', '');

			$(".ui-multiselect-menu > ul > li > label > span").tooltip({
				tooltipClass : "tooltip",
				position: {my: "left+50 top", collision: "flipfit"},
				content : function(callback) {

					var value = $('input', this).val();
					var opt = $("select.templateName > option[value='" + value + "']");
					var title = opt.prop('title');
					var helperDiv = $("<div>").html(title);
					return helperDiv.text();
				},
				close: function(event, ui) {
					jquery_ui_keepTooltipOpen(ui);
				}
			});
		},
		close: function(event, ui) {
			$(".ui-multiselect-menu > ul > li > label > span").tooltip("destroy");
		},
		click: function(event, ui) {
			$(this).next().attr('title', ui.value || i18n.message('tracker.issues.exportToWord.roundtrip.export.use.template.tooltip'));
		}
	}).multiselectfilter({
		placeholder: "<spring:message code='multiselectfilter.text'/>"
	});

	$("#officeExportUploadConversationId_dropZone").bind("onUploadComplete", function(event, id, fileName, responseJSON) {
		var mimeType;

		mimeType = responseJSON.mimeType;

		if (mimeType.indexOf("excel") != -1 || mimeType.indexOf("spreadsheet") != -1) {
			$(event.target).trigger("switchToExcelTab");
		} else {
			if (mimeType.indexOf("word") != -1 ) {
				$(event.target).trigger("switchToWordTab");
			}
		}
	});
});


</script>



