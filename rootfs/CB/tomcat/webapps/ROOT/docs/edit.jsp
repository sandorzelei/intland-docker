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
<%@page import="com.intland.codebeamer.Config"%>
<meta name="decorator" content="main"/>
<meta name="module" content="docs"/>
<meta name="moduleCSSClass" content="documentsModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<wysiwyg:froalaConfig />

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function enableCharSetSelection() {
	var frm = document.getElementById('DocumentAttributesForm');
	var state = frm.extract.checked;
	frm.charsetName.disabled=!state;
}

function submitForm(form) {
	var $editor = $('#editor');

	if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
        codebeamer.WikiConversion.saveEditor($editor, true);
    }

	var button = form.SAVE;
	button.disabled=true;
}
// -->
</SCRIPT>

<html:form action="/proj/doc/editAttributes" onsubmit="submitForm(this)" enctype="multipart/form-data" styleId="DocumentAttributesForm">

<c:if test="${!empty param.doc_id}">
	<c:set var="doc_id" value="${param.doc_id}" />
</c:if>

<c:set var="proj_id" value="${PROJECT_DTO.id}" />

<c:set var="form" value="${documentAttributesForm}" />

<c:if var="uploadNewVersion" test="${upload or param.upload}" />
<html:hidden property="uploadNewVersion" value="${uploadNewVersion}" />

<spring:message var="saveLabel" code="button.${uploadNewVersion or empty doc_id ? 'upload' : 'save'}"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
		<span class="breadcrumbs-separator">&raquo;</span>
		<ui:pageTitle><spring:message code="document.${uploadNewVersion ? 'update' : (empty doc_id ? 'upload' : 'propedit')}.title" /></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:showErrors />

<input type="hidden" name="projId" value="${proj_id}" />

<c:set var="controlButtons">
	&nbsp;&nbsp;<html:submit styleClass="button" property="SAVE" value="${saveLabel}" />

	&nbsp;&nbsp;
	<html:cancel styleClass="cancelButton">
		<spring:message code="button.cancel" text="Cancel"/>
	</html:cancel>
</c:set>

<ui:actionBar>
	<c:out value="${controlButtons}" escapeXml="false" />
</ui:actionBar>

<div class="contentWithMargins" >


<html:hidden property="dir_id" />

<c:if test="${!empty doc_id}">
	<html:hidden property="doc_id" />
</c:if>
<html:hidden property="revision"/>

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

<c:choose>
	<c:when test="${!empty doc_id}">
		<c:if test="${uploadNewVersion}">
			<TR>
				<TD class="mandatory">
					<spring:message code="document.upload.filetoupload" text="File to upload"/>:
				</TD>

				<TD CLASS="expandTextArea" COLSPAN="5" id="uploadCell" >
					<ui:fileUpload single="true" dndControlMessageCode="document.upload.chooseafile"/>
				</TD>
			</TR>
		</c:if>

		<TR>
			<TD class="mandatory"><spring:message code="document.name.label" text="Name"/>:</TD>

			<TD CLASS="expandText">
				<html:text styleClass="expandText" property="newName" size="90"/>
			</TD>
		</TR>

		<TR>
			<TD class="optional"><spring:message code="document.owner.label" text="Owner"/>:</TD>

			<TD>
				<html:select property="selectedOwnerId">
					<html:optionsCollection property="users" label="name" value="id"/>
				</html:select>
			</TD>
		</TR>
	</c:when>

	<c:otherwise>
		<TR>
			<TD class="optional">
				<spring:message code="document.upload.filestoupload" text="Files to upload"/>:
			</TD>

			<TD CLASS="expandTextArea" COLSPAN="5" id="uploadCell" >
				<ui:fileUpload dndControlMessageCode="document.upload.choosefiles"/>
			</TD>
		</TR>

		<acl:isUserInRole value="document_unpack">
			<TR>
				<TD class="optional"><spring:message code="document.extract.label" text="Mode"/>:</TD>

				<TD NOWRAP>
					<html:checkbox property="extract" onclick="enableCharSetSelection();" styleId="extract"/>
					<label for="extract">
						<spring:message code="document.extract.tooltip" text="Unpack archive files with .zip, .tar, .tar.gz or .tgz extension"/>,&nbsp;
					</label>
					<spring:message code="document.charset.label" text="Character set"/>:
					<html:select property="charsetName" disabled="true">
						<html:optionsCollection property="availableCharsetNames" />
					</html:select>
				</TD>
			</TR>
		</acl:isUserInRole>

	</c:otherwise>
</c:choose>

	<TR>
		<TD class="optional">
		<acl:isUserInRole var="isProjectAdmin" value="project_admin"/>
		<c:choose>
			<c:when test="${isProjectAdmin}">
				<c:url var="editStatusURL" value="/proj/doc/editStatus.spr">
					<c:if test="${!empty doc_id}">
						<c:param name="doc_id" value="${doc_id}" />
					</c:if>
					<c:if test="${!empty param.dir_id}">
						<c:param name="dir_id" value="${param.dir_id}" />
					</c:if>
				</c:url>
				<spring:message var="tooltip" code="document.status.label.link.tooltip" />
				<a href="#" onclick="inlinePopup.show('${editStatusURL}'); return false;" title="${tooltip}"
						><spring:message code="document.status.label" text="Status"/></a>:
			</c:when>
			<c:otherwise>
				<spring:message code="document.status.label" text="Status"/>:
			</c:otherwise>
		</c:choose>
		</TD>

		<TD>
			<html:select property="statusId">
				<c:forEach items="${form.statusOptions}" var="statusOption">
					<html:option value="${statusOption.id}">
						<spring:message code="document.status.${statusOption.name}" text="${statusOption.name}"/>
					</html:option>
				</c:forEach>
			</html:select>
		</TD>
	</TR>

<c:if test="${!form.directory}">
	<TR>
		<TD class="optional"><spring:message code="document.keptHistoryEntries.label" text="Keep Versions"/>:</TD>

		<TD>
			<c:set var="documentMaxHistory" value="<%=Config.getDocumentMaxHistory()%>" />
			<html:select property="keptHistoryEntries">
				<c:choose>
					<c:when test="${empty documentMaxHistory}">
						<html:option value="-1"><spring:message code="document.keptHistoryEntries.all" text="All"/></html:option>
					</c:when>
					<c:otherwise>
						<html:option value="-1"><spring:message code="document.keptHistoryEntries.default" text="Default {0}" arguments="${documentMaxHistory}"/></html:option>
						<html:option value="<%=String.valueOf(Integer.MAX_VALUE)%>"><spring:message code="document.keptHistoryEntries.all" text="All"/></html:option>
					</c:otherwise>
				</c:choose>
				<html:option value="0"><spring:message code="document.keptHistoryEntries.none" text="None"/></html:option>
				<html:option value="1"><spring:message code="document.keptHistoryEntries.prev" text="Previous"/></html:option>
				<html:option value="2"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="2"/></html:option>
				<html:option value="3"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="3"/></html:option>
				<html:option value="5"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="5"/></html:option>
				<html:option value="10"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="10"/></html:option>
				<html:option value="50"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="50"/></html:option>
			</html:select>
		</TD>
	</TR>
</c:if>

<TR VALIGN="top" >
	<TD class="optional">
		&nbsp;<spring:message code="document.description.label" text="Description"/>:&nbsp;
	</TD>

	<TD CLASS="expandTextArea">
		<wysiwyg:editor editorId="editor" useAutoResize="false" resizeEditorToFillParent="true" focus="${empty doc_id}" formatSelectorStrutsProperty="descriptionFormat" overlayDefaultHeaderKey="wysiwyg.default.properties.overlay.header">
		    <html:textarea property="description" styleId="editor" rows="11" cols="95" />
		</wysiwyg:editor>
	</TD>
</TR>
<c:if test="${!form.directory}">
	<c:if test="${!uploadNewVersion}">
		<c:forEach items="${attributes}" var="attribute">
			<tr>
				<td class="optional"  title="<c:out value="${attribute.key.title}" />"><c:out value="${attribute.key.label}"/>:</td>
				<td class="expandText">
					<c:choose>
						<c:when test="${attribute.key.inputType eq 3}">
							<%-- dateTime --%>
							<input id="attribute_${attribute.key.id}" type="text" size="30" maxlength="30" name="<c:out value="attribute(${attribute.key.title})"/>" value="<c:out value="${attribute.value}"/>"/>&nbsp;
							<ui:calendarPopup textFieldId="attribute_${attribute.key.id}"/>
						</c:when>
						<c:otherwise>
							<%-- string --%>
							<input type="text" class="expandText" size="90" maxlength="254" name="<c:out value="attribute(${attribute.key.title})"/>" value="<c:out value="${attribute.value}"/>"/>
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
		</c:forEach>
	</c:if>
</c:if>

<c:set var="unvisible" value="style=&quot;display:none&quot;" />

<c:if test="${uploadNewVersion}">
	<TR VALIGN="TOP">
		<TD class="optional"><spring:message code="document.update.comment.label" text="Modification Comment"/>:</TD>
		
		<TD><html:textarea style="width: calc(100% - 5px);" property="comment" rows="4" /></TD>
	</TR>
</c:if>

</TABLE>

</div>
</html:form>

<c:if test="${not empty doc_id}">
	<script type="text/javascript">
		setTimeout(function() {
            $('#DocumentAttributesForm input[name="newName"]').focus();
        }, window.parent != window ? 800 : 1);
	</script>
</c:if>
