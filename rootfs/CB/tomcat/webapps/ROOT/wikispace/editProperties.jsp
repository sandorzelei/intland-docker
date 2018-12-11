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
<meta name="decorator" content="main"/>
<meta name="module" content="wikispace"/>
<meta name="moduleCSSClass" content="wikiModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<wysiwyg:froalaConfig />

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle><spring:message code="wiki.properties.title" text="Edit Properties"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="saveButton" code="button.save" text="Save"/>
<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

<c:set var="controlButtons">
	&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
	&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
</c:set>

<form:form commandName="propertiesForm">

<form:hidden path="forward_doc_id" />

<div class="actionBar">
	<c:out value="${controlButtons}" escapeXml="false" />
</div>

<div class="contentWithMargins" >
<TABLE WIDTH="95%" BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

<TR>
	<TD class="mandatory"><spring:message code="document.name.label" text="Name"/>:</TD>

	<TD NOWRAP WIDTH="90%">
		<form:input path="artifact.name" cssClass="expandText" size="90" maxlength="255" /><br/><form:errors path="artifact.name" cssClass="invalidfield"/>
	</TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="document.owner.label" text="Owner"/>:</TD>

	<TD NOWRAP WIDTH="90%">
		<%-- for personal wiki pages the owner is not editable --%>
		<c:choose>
			<c:when test="${artifact.userPage}">
				<tag:userLink user_id="${artifact.owner.id}" />
			</c:when>
			<c:otherwise>
				<form:select path="artifact.owner.id">
					<form:options items="${ownerOptions}" itemLabel="name" itemValue="id" />
				</form:select>
			</c:otherwise>
		</c:choose>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="document.status.label" text="Status"/>:</TD>

	<TD NOWRAP WIDTH="90%">
		<form:select path="artifact.status.id">
			<c:forEach items="${statusOptions}" var="statusOption">
				<form:option value="${statusOption.id}">
					<spring:message code="document.status.${statusOption.name}" text="${statusOption.name}" htmlEscape="true"/>
				</form:option>
			</c:forEach>
		</form:select>
	</TD>
</TR>

<TR VALIGN="top">
	<TD class="optional"><spring:message code="document.description.label" text="Description"/>:</TD>

	<TD CLASS="expandTextArea">
		<wysiwyg:editor editorId="editor" useAutoResize="true" heightMin="200" formatSelectorSpringPath="artifact.descriptionFormat" overlayDefaultHeaderKey="wysiwyg.default.properties.overlay.header">
		    <form:textarea id="editor" path="artifact.description" rows="12" cols="95" autocomplete="off" />
		</wysiwyg:editor>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="document.lock.label" text="Locked"/>:</TD>

	<td>
		<form:checkbox path="locked" />
	</td>
</TR>

<TR>
	<TD class="optional" ><spring:message code="document.keptHistoryEntries.label" text="Keep Versions"/>:</TD>

	<td>
		<form:select path="artifact.additionalInfo.keptHistoryEntries">
			<form:option value="-1"><spring:message code="document.keptHistoryEntries.all" text="All"/></form:option>
			<form:option value="0"><spring:message code="document.keptHistoryEntries.none" text="None"/></form:option>
			<form:option value="1"><spring:message code="document.keptHistoryEntries.prev" text="Previous"/></form:option>
			<form:option value="2"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="2"/></form:option>
			<form:option value="3"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="3"/></form:option>
			<form:option value="5"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="5"/></form:option>
			<form:option value="10"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="10"/></form:option>
			<form:option value="50"><spring:message code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="50"/></form:option>
		</form:select>
	</td>
</TR>

<c:forEach items="${attributes}" var="attribute">
	<tr>
		<td class="optional" title="<c:out value="${attribute.key.title}" />"><c:out value="${attribute.key.label}"/>:</TD>
		<td>
			<c:choose>
				<c:when test="${attribute.key.inputType eq 3}">
					<%-- dateTime --%>
					<input id="attribute_${attribute.key.id}" type="text" size="30" maxlength="30" name="<c:out value="attributes[${attribute.key.title}]"/>" value="<c:out value="${attribute.value}"/>"/>&nbsp;
					<ui:calendarPopup textFieldId="attribute_${attribute.key.id}"/>
				</c:when>
				<c:otherwise>
					<%-- string --%>
					<input type="text" class="expandText" size="90" maxlength="254" name="<c:out value="attributes[${attribute.key.title}]"/>" value="<c:out value="${attribute.value}"/>"/>
				</c:otherwise>
			</c:choose>
		</td>
	</tr>
</c:forEach>

</TABLE>
</div>
</form:form>
