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
<%@tag import="com.intland.codebeamer.Config"%>
<%@tag import="com.intland.codebeamer.persistence.dto.base.ReferableDto"%>
<%@ tag import="java.util.Collections"%>
<%@ tag import="com.intland.codebeamer.manager.support.EntityReferenceResolver"%>
<%@tag import="com.intland.codebeamer.remoting.GroupTypeClassUtils"%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%--
	Renders a wiki text to the page , and on double click edit it in an overlay editor.
	The jsp body should contain the textarea which contains the edited content.
 --%>
<%@ attribute name="id" required="false" type="java.lang.String" description="Id of the textarea, required by the WYSWYG inline editor."  %>
<%@ attribute name="wiki" required="false" type="java.lang.String" description="The wiki text being edited, will be rendered"  %>
<%@ attribute name="owner" required="false" type="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"
		description="The entity (wikipage for example) being edited here. It matters because the attachments are searched on this entity"  %>
<%@ attribute name="uploadConversationId" required="false" type="java.lang.String" %>
<%@ attribute name="title" required="false" description="The HTML title (=tooltip) for the elements" %>
<%@ attribute name="disabled" required="false" description="Disabled editing field" type="java.lang.Boolean" %>
<%@ attribute name="forceOverlayEdit" required="false" description="If true then the wiki field is edited in overlay" type="java.lang.Boolean" %>
<%@ attribute name="allowTestParameters" required="false" description="If true then the wiki field allows $ { } style parameters. Used for test cases." type="java.lang.Boolean" %>

<c:set var="enabled" value="<%=Config.getWikiConfig().isEditWikiFieldsInOverlay()%>" />

<c:if test="${forceOverlayEdit}">
    <c:set var="enabled" value="true" />
</c:if>

<c:choose>
<c:when test="${enabled and not disabled}">
	<%-- Note: data attributes will be converted to lowercase! --%>
	<c:set var="data" >uploadConversationId="<c:out value='${uploadConversationId}'/>"</c:set>
	<c:if test="${! empty owner}">
		<c:set var="projectId" value="${owner.project.id}" />
		<c:set var="entityTypeId" value="<%=GroupTypeClassUtils.objectToGroupType(owner)%>" />
		<c:set var="entityId" value="${owner.id}" />
		<%
			String entityRef = EntityReferenceResolver.getInstance().encodeReferences(Collections.singleton((ReferableDto)owner));
			jspContext.setAttribute("entityRef", entityRef);
		%>
		<c:set var="data">${data} projectId="${projectId}" entityTypeId="${entityTypeId}" entityId="${entityId}" entityRef="${entityRef}"</c:set>
	</c:if>

	<div class="editWikiInOverlayContainer" title="${title}" ${data} >
		<div class="editWikiInOverlayEditableIcon"></div>
		<div class="editWikiInOverlayHTML"><tag:transformText value="${wiki}" format="W" owner="${owner}" uploadConversationId="${uploadConversationId}" default="--" /></div>
		<div class="editWikiInOverlayBody"><jsp:doBody/></div>
	</div>

	<ui:delayedScript avoidDuplicatesOnly="true">
	<script type="text/javascript">
		$(wikiEditorOverlay.init);
	</script>
	</ui:delayedScript>
</c:when>
<c:otherwise>
	<wysiwyg:editor editorId="${id}" entity="${addUpdateTaskForm.trackerItem}" height="100" uploadConversationId="${addUpdateTaskForm.uploadConversationId}"
        disableFormattingOptionsOpening="true" hideUndoRedo="true" insertNonImageAttachments="true" useAutoResize="false" allowTestParameters="${allowTestParameters}"
        ignorePreviouslyUploadedFiles="${empty errors}">
			<jsp:doBody/>
	</wysiwyg:editor>
</c:otherwise>
</c:choose>
