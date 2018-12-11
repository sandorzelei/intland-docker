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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ tag import="com.intland.codebeamer.controller.usersettings.UserSetting"%>
<%@ tag import="java.util.Collections"%>
<%@ tag import="com.intland.codebeamer.manager.support.EntityReferenceResolver"%>
<%@ tag import="com.intland.codebeamer.Config"%>

<%@ attribute name="editorId" required="true" description="The HTML id of textarea control."  %>
<%@ attribute name="entity" required="false" type="com.intland.codebeamer.persistence.dto.base.ReferableDto"
		description="The entity (wikipage for example) being edited here. It matters because the attachments are searched on this entity"  %>
<%@ attribute name="entityRef" required="false" description="The entity reference (wiki page or issue) being edited here."  %>
<%@ attribute name="height" required="false" description="If set, the editor height should be forced (in px)" %>
<%@ attribute name="heightMin" required="false" description="Specifies the minimum height for the editor (in px)" %>
<%@ attribute name="heightMax" required="false" description="Specifies the maximum height for the editor (in px)" %>
<%@ attribute name="footerHeight" required="false" description="Specifies an offset to use when calculating the size in resizeEditorToFillParent mode (in px)" %>
<%@ attribute name="uploadConversationId" required="false" description="Specifies the conversation id for file upload" %>
<%@ attribute name="insertNonImageAttachments" required="false" type="java.lang.Boolean" description="Should the editor insert wiki link of non image attachments?" %>
<%@ attribute name="formatSelectorSpringPath" required="false" description="When not empty then the selector between 'wiki/html/plain' format will appear in the editor toolbar. Use when on a spring form and put the spring's path of the bean-property which contains the format!" %>
<%@ attribute name="formatSelectorStrutsProperty" required="false" description="When not empty then the selector between 'wiki/html/plain' format will appear in the editor toolbar. Use when on a struts form and put the struts's property name which constains the format!" %>
<%@ attribute name="formatSelectorDisabled" required="false" type="java.lang.Boolean" description="If the format selector is disabled (read-only)?" %>
<%@ attribute name="formatSelectorName" required="false" description="When not empty then the selector between 'wiki/html/plain' format will appear in the editor toolbar. Specify the property name which constains the format!" %>
<%@ attribute name="formatSelectorValue" required="false" description="When not empty then the selector between 'wiki/html/plain' format will appear in the editor toolbar. Can be used for the default(saved) value." %>
<%@ attribute name="mode" required="false" description="The current editor mode. Possible values: wysiwyg, markup, preview. Default value configured by com.intland.codebeamer.Config."  %>
<%@ attribute name="useAutoResize" required="false" description="Defines if the editor should be use autoresized. Default is false"  %>
<%@ attribute name="showSaveCancel" required="false" type="java.lang.Boolean" description="If true, the editor will contain save and cancel buttons" %>
<%@ attribute name="resizeEditorToFillParent" required="false" type="java.lang.Boolean" description="If true, the editor will fill the screen or overlay/popup." %>
<%@ attribute name="hideQuickInsert" required="false" type="java.lang.Boolean" description="If true, the quick insert button won't be displayed." %>
<%@ attribute name="getMarkup" required="false" description="Javascript function name. If it is set, then the editor will load the markup from there instead of the textarea field." %>
<%@ attribute name="toolbarSticky" required="false" type="java.lang.Boolean" description="If true, the editor toolbar is sticky." %>
<%@ attribute name="focus" required="false" description="The flag to focus the editor after page loading." %>
<%@ attribute name="overlayHeaderKey" required="false" description="Label key for the header component of the overlay mode. This tag can inject the name and id of the currently used dto, specify a placeholder in the label ( {0}, {1} ) to use this feature." %>
<%@ attribute name="overlayDefaultHeaderKey" required="false" description="Label key for the header component of the overlay mode. Chnages the default 'Edit' text the given key." %>
<%@ attribute name="disablePreview" required="false" type="java.lang.Boolean" description="If it is true then the Preview mode is disabled. Default is false." %>
<%@ attribute name="readonly" required="false" type="java.lang.Boolean" description="If it is true then the editing is disabled. Only the save and cancel buttons are displayed in the toolbar if they are specified. Default is false." %>
<%@ attribute name="disableFormattingOptionsOpening" required="false" type="java.lang.Boolean" description="If it is true then the formatting options is not opened by default if it was open last time when the user used the editor. Default is true." %>
<%@ attribute name="hideUndoRedo" required="false" type="java.lang.Boolean" description="If it is true then 'hide' and 'redo' buttons are not displayed on formatting options toolbar. Default is false." %>
<%@ attribute name="hideOverlayEditor" required="false" type="java.lang.Boolean" description="If it is true then the editing can not be done in the overlay. Default is false." %>
<%@ attribute name="ignorePreviouslyUploadedFiles" required="false" type="java.lang.Boolean" description="If it is true then the previously uploaded files in the conversation are not loaded. Default is false." %>
<%@ attribute name="allowTestParameters" required="false" type="java.lang.Boolean" description="If it is true then test parameters with $ { } syntax will be not escaped. Default is false." %>


<c:if test="${not empty entity}">
    <%
        entityRef = EntityReferenceResolver.getInstance().encodeReferences(Collections.singleton(entity));
        jspContext.setAttribute("entityRef", entityRef);
    %>
</c:if>

<c:if test="${empty insertNonImageAttachments}">
    <c:set var="insertNonImageAttachments" value="false" />
</c:if>

<c:if test="${empty disableFormattingOptionsOpening}">
    <c:set var="disableFormattingOptionsOpening" value="true" />
</c:if>

<%
jspContext.setAttribute("defaultMode", com.intland.codebeamer.Config.getWikiStyleConfig().getDefaultMode());
%>

<c:choose>
	<c:when test="${requestScope.PROJECT_AWARE_DTO != null}">
		<c:set var="currentDto" value="${requestScope.PROJECT_AWARE_DTO}" />

		<c:set var="currentItem">
			<ui:itemLink item="${currentDto}" useVersionedUrl="${false}" showKeyAndId="${false}"
				showVersionBadge="${false}" showItemName="${true}"
				excludeLink="${true}" showItemDescription="${false}" />
		</c:set>

		<c:choose>
			<c:when test="${empty overlayHeaderKey}">
				<c:set var="overlayHeaderLabel">
					<span class="editor-overlay-item-name">${ui:replaceNewLine(currentItem, '')}</span> <span class="breadcrumbs-separator">&raquo;</span> <spring:message code="${not empty overlayDefaultHeaderKey ? overlayDefaultHeaderKey : 'wysiwyg.default.item.overlay.header'}" /> <span class="editor-overlay-item-id">#${currentDto.id}</span>
				</c:set>
			</c:when>
			<c:otherwise>
				<spring:message code="${overlayHeaderKey}" var="overlayHeaderLabel" arguments="${ui:replaceNewLine(currentItem, '')},${currentDto.id}" />
			</c:otherwise>
		</c:choose>

	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${empty overlayHeaderKey}">
				<spring:message code="wysiwyg.default.overlay.header" var="overlayHeaderLabel" />
			</c:when>
			<c:otherwise>
				<spring:message code="${overlayHeaderKey}" var="overlayHeaderLabel" />
			</c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>

<c:if test="${mode != 'wysiwyg' && mode != 'markup' && mode != 'preview'}">
    <ui:UserSetting setting="PREFERRED_EDITOR_MODE" var="mode" />
</c:if>

<c:if test="${mode != 'wysiwyg' && mode != 'markup' && mode != 'preview'}">
    <c:set var="mode" value="${defaultMode}" />
</c:if>

<ui:UserSetting setting="WYSIWYG_PASTE_AS_TEXT" var="pasteAsText" />

<div class="editor-wrapper">
	<c:if test="${not empty entityRef}">
		<script type="text/javascript">
	    	codebeamer.WikiConversion.bindEditorToEntity('${editorId}', '${entityRef}');
		</script>
	</c:if>

	<jsp:doBody />

    <c:if test="${not empty formatSelectorSpringPath}">
        <form:hidden path="${formatSelectorSpringPath}" />
    </c:if>
    <c:if test="${not empty formatSelectorStrutsProperty}">
        <html:hidden property="${formatSelectorStrutsProperty}" />
    </c:if>

    <c:if test="${not empty formatSelectorName}">
        <input id="${formatSelectorName}" name="${formatSelectorName}" type="hidden" value="${formatSelectorValue}">
    </c:if>

	<script type="text/javascript">
	(function() {
		var options = {
			<c:if test="${not empty height}">
	        height: ${height},
	        </c:if>
	        <c:if test="${not empty heightMin}">
	        heightMin: ${heightMin},
	        </c:if>
	        <c:if test="${not empty heightMax}">
	        heightMax: ${heightMax},
	        </c:if>
	        pastePlain: '${pasteAsText}' == 'true',
	        toolbarSticky: '${toolbarSticky}' == 'true'
		};

		codebeamer.WYSIWYG.initEditor('${editorId}', options, {
			saveOnFormSubmit: true,
			uploadConversationId: '${ui:escapeJavaScript(uploadConversationId)}',
			insertNonImageAttachments: ${insertNonImageAttachments},
			useFormatSelector: !!('${formatSelectorSpringPath}' + '${formatSelectorStrutsProperty}' + '${formatSelectorName}').length && '${formatSelectorDisabled}' != 'true',
			mode: '${mode}',
			useAutoResize: '${useAutoResize}' == 'true' && '${resizeEditorToFillParent}' != 'true',
			showSaveCancel: '${showSaveCancel}' == 'true',
			resizeEditorToFillParent: '${resizeEditorToFillParent}' == 'true',
	        <c:if test="${not empty footerHeight}">
	        footerHeight: ${footerHeight},
	        </c:if>
	        <c:if test="${not empty getMarkup}">
	        getMarkup: ${getMarkup},
	        </c:if>
	        overlayHeader: '${overlayHeaderLabel}',
			hideQuickInsert: '${hideQuickInsert}' == 'true',
			focus: '${focus}' == 'true',
			disablePreview: '${disablePreview}' == 'true',
			readonly: '${readonly}' == 'true',
			disableFormattingOptionsOpening: '${disableFormattingOptionsOpening}' == 'true',
			hideUndoRedo: '${hideUndoRedo}' == 'true',
			hideOverlayEditor: '${hideOverlayEditor}' == 'true',
			ignorePreviouslyUploadedFiles: '${ignorePreviouslyUploadedFiles}' == 'true',
			allowTestParameters: '${allowTestParameters}' == 'true'
		});
	})();
	</script>
</div>