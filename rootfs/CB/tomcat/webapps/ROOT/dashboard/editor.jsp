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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/dashboard/editor.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.filter.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/dashboard/dashboard-editor.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/dashboard/chartSelector.js'/>"></script>

<script type="text/javascript">
    // Disable hotkeys from  codebeamer.FormHotkeys, which is by default included in the popup decorator.
	$(document).off("keydown");
	$(document).off("keypress");
	$(document).off("keyup");

	// Clear hotkeys from codebeamer.FormHotkey, so hotkey popup will not show them.
	codebeamer.HotkeyRegistry.clearHotkeys();
</script>

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${isAddingWidget }">
			<spring:message code="dashboard.add.widget.label" text="Adding" arguments="${widgetTitle}"/>
		</c:when>
		<c:otherwise>
			<spring:message code="dashboard.edit.widget.label" text="Editing" arguments="${widgetTitle}"/>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<c:url value="/dashboard/updateWidget.spr" var="actionUrl"></c:url>
<c:if test="${isAddingWidget }">
	<c:url value="/dashboard/addWidget.spr" var="actionUrl"></c:url>
</c:if>
<form action="${actionUrl}" method="post" id="editorForm">
	<ui:actionBar>
		<spring:message var="saveTitle" code="button.save" text="Save"/>
		<input type="submit" class="button" value="${saveTitle}"></input>

		<c:url var="backUrl" value="/dashboard/widgetPicker.spr">
			<c:param name="dashboardId" value="${dashboardId }"/>
			<c:if test="${columnNumber > 0}">
				<c:param name="columnNumber" value="${columnNumber }"/>
			</c:if>
			<c:if test="${rowNumber > 0}">
				<c:param name="rowNumber" value="${rowNumber }"/>
			</c:if>
		</c:url>

		<c:if test="${isAddingWidget }">
			<a class="cancel" href="${backUrl }"><spring:message code="button.back" text="Back"/></a>
		</c:if>

		<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
		<input type="submit" class="cancelButton editor-cancel" onclick="closePopupInline(); return false;" value="${cancelTitle}" />

		<spring:message code="testrunner.hotkeys.hint" var="hotkeysTitle" text="Show keyboard hotkeys"/>
		<a onclick="toggleHotkeys({align: 'right'});" title="${hotkeysTitle }" id="hotkey-toggle">
			<c:url value="/images/newskin/hotkeys.png" var="imgUrl"/>
			<img src="${imgUrl }"/>
			<spring:message code="testrunner.hotkeys.title" text="Hotkeys"/>
		</a>
		<spring:message code="testrunner.hotkeys.hint" var="hotkeysHintText" text="Show keyboard hotkeys"/>
		<div id="hotkeysHint" class="hint" title="${hotkeysHintText}" style="display:none;">
			<table>

			</table>
		</div>
	</ui:actionBar>
	<tab:tabContainer id="editor-tabs" skin="cb-box" jsTabListener="tabChanged" selectedTabPaneId="editor-tab">
		<tab:tabPane id="editor-tab" tabTitle="Editor">
			<div class="contentWithMargins <c:if test="${isLivePreviewWidget}">editorForm</c:if>">

				<input type="hidden" name="dashboardId" value="${dashboardId}"></input>
				<input type="hidden" name="widgetType" value="${widgetType}"></input>
				<input type="hidden" name="projectId" value="${projectId}"></input>
				<input type="hidden" name="columnNumber" value="${columnNumber}"></input>
				<input type="hidden" name="rowNumber" value="${rowNumber}"></input>

				<c:if test="${not isAddingWidget }">
					<input type="hidden" name="widgetId" value="${widgetId}"></input>
				</c:if>

				<div class="form-field">
					<label for="title" class="mandatory"><spring:message code="dashboard.widget.title.label" text="Title"/>:</label>
					<input type="text" name="title" value="${ui:escapeHtml(widget.title)}"><br/>
					<label></label>
						<a class="copy-report-name" onclick="codebeamer.dashboard.chartSelector.copySelectedQueryNameToTitle();">
							<spring:message code="dashboard.add.widget.copy.report.name.label" text="Copy report name"/>
						</a>
				</div>
				<div class="form-field">
					<c:set var="checked" value="${widget.headerHidden ? 'checked' : '' }"/>
					<input type="checkbox" id="headerHidden" class="checkboxInput" name="headerHidden" ${checked }>
					<label for="headerHidden" class="checkboxLabel"><spring:message code="dashboard.widget.headerHidden.label" text="Hide header"/></label>
				</div>

				<div class="form-field" id="colorField" <c:if test="${widget.headerHidden}">style="display:none;"</c:if>>
					<label for="title" class="optional"><spring:message code="dashboard.widget.header.color.label" text="Header color"/>:</label>
					<input type="text" name="color" id="color" value="${widget.color }" readonly="readonly" style="width: 6em;"/>
					<ui:colorPicker fieldId="color" ></ui:colorPicker>
				</div>
				<c:if test="${widget.pinned}">
					<div class="form-field">
						<label for="pinnedLayout"><spring:message code="dashboard.widget.justify.label" text="Justify"/>:</label>
						<select name="pinnedLayout">
							<option value="stretch" <c:if test="${widget.pinnedLayout == 'stretch' || widget.pinnedLayout == ''}">selected</c:if>><spring:message code="dashboard.widget.justify.stretch.label" text="Stretch"/></option>
							<option value="right" <c:if test="${widget.pinnedLayout == 'right'}">selected</c:if>><spring:message code="dashboard.widget.justify.right.label" text="Right"/></option>
							<option value="center" <c:if test="${widget.pinnedLayout == 'center'}">selected</c:if>><spring:message code="dashboard.widget.justify.center.label" text="Center"/></option>
							<option value="left" <c:if test="${widget.pinnedLayout == 'left'}">selected</c:if>><spring:message code="dashboard.widget.justify.left.label" text="Left"/></option>
						</select>
					</div>
				</c:if>
				${editorForm}
			</div>
			<c:if test="${isLivePreviewWidget}">
				<div class="contentWithMargins livePreview">
					${widgetPreview}
				</div>
			</c:if>
		</tab:tabPane>

		<c:if test="${!isLivePreviewWidget}">
			<spring:message code="button.preview" text="Preview" var="previewTitle"></spring:message>
			<tab:tabPane id="preview-tab" tabTitle="${previewTitle}">
				<div id="preview-container">

				</div>
			</tab:tabPane>
		</c:if>

	</tab:tabContainer>
</form>

<c:if test="${newWidget }">
	<script type="text/javascript">
		codebeamer.dashboard.chartSelector.newWidget = true;
	</script>
</c:if>

<script type="text/javascript">
	function tabChanged(event) {
		var $previewContainer = $("#preview-container"),
		    $editor = $('#editor');

		if ($editor.length && codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
			codebeamer.WikiConversion.saveEditor($editor, true);
		}

		// Some editors only close when detecting a click, trigger it directly.
		$previewContainer.click();

		if (event._selectedIndex == 1) { // the user activated the preview tab
			var formData = $("#editorForm").serialize();
			var bs = ajaxBusyIndicator.showBusyPage();

			$.post(contextPath + '/dashboard/preview.spr', formData).done(function (response) {
				$previewContainer.html(response);
				initializeMinimalJSPWikiScripts($previewContainer);
			}).fail(function () {
				var $error = $("<div>", {"class": "error"}).html("Couldn't render the preview");
				$previewContainer.html($error);
			}).always(function () {
				bs.remove();
			});
		}
	}

	function submitForm() {
		var $editor = $('#editor');
		if ($editor.length && codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
		    codebeamer.WikiConversion.saveEditor($editor, true);
		}

		return true;
	}

	$(document).ready(function () {
		var hotkeys, modules;

		alignLabels();

		if(self==top) {
			$(location).attr('href', '${dashboardUrl}');
		}

		$("#editorForm").submit(function() {
			submitForm();
		});

		hotkeys = new codebeamer.WidgetEditorHotkeys({});
		modules = hotkeys.getModuleHotkeyDependency();
		// Add hotkeys to input and textarea fields as well
		$(document).find("textarea,input").mapHotKeys(modules.edit);

		codebeamer.dashboard.editor.init();
	});

</script>
<script type="text/javascript">

	if ($("#query,#queryId").length > 0) {
		$(document).ready(function () {
			var title = $("input[name=title]");
			title.on("paste keydown keyup keypress change", function () {
				var $input = $(this);
				var previousValue = ($input.data("currentValue") || "").trim();
				if (previousValue != $input.val().trim()) {
					$input.data("modified", true);
				} else {
					$input.data("modified", false);
				}
			});

			if (!codebeamer.dashboard.chartSelector.newWidget ) {
				var selectedQueryName = codebeamer.dashboard.chartSelector.getSelectedQueryName();
				title.data("currentValue", title.val());

				if (title.val().trim() != selectedQueryName) {
					title.data("modified", true);
				}
			}

			codebeamer.dashboard.chartSelector.initializeDefaultNameProvider();
		});
	} else {
		$(".copy-report-name").hide();
	}

	$("#editorForm").on("submit", function() {
		var $submitButton = $("input[type=submit]");
		$submitButton.attr("disabled", "disabled");

		var $title = $("input[name=title]");

		var $querySelector = $(".storedQuery select");
		var queryId = $querySelector.val();

		if (queryId) {
			codebeamer.dashboard.chartSelector.copyQueryNameToTitle(queryId);
		}
	});
</script>
