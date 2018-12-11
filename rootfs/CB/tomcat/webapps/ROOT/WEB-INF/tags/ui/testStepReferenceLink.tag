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
<%@tag language="java" pageEncoding="UTF-8" %>

<%--
   Tag renders the link to a referenced TestStep
 --%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag"%>

<%@ attribute name="testStepReference" required="true" description="The TestStepReference instance to render link for"
	type="com.intland.codebeamer.manager.testmanagement.TestStepReference" %>
<%@ attribute name="source" type="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"
	description="The source TrackerItemDto which contains these TestSteps" %>

<c:if test="${! empty testStepReference.referencedItem}">

<c:set var="refItem" value="${testStepReference.referencedItem}" />
<spring:message code="testcase.editor.reference.step.open.title" var="title" />
<c:url var="openReferencedURL" value="${testStepReference.openURL}" />
<a class="testStepReference" href="${openReferencedURL}" target="_blank" title="${title}"><tag:joinLines newLinePrefix="">
	<c:choose>
		<c:when test="${empty refItem && empty refItem.name}">Test</c:when>
		<c:otherwise>
			<%-- if this is from a different project show the project's name too --%>
			<c:set var="projectRef" value="" />
			<c:catch>
				<c:if test="${(! empty source) && (source.project.id != refItem.project.id)}">
					<c:set var="projectRef"><c:out value="${refItem.project.name}" />&nbsp;&rarr;&nbsp;</c:set>
				</c:if>
			</c:catch>
			${projectRef}<c:out value="${refItem.name}" /></c:otherwise>
	</c:choose>
</tag:joinLines></a>
<spring:message code="testcase.editor.reference.step.edit.title" var="title" />
<c:url var="editReferencedURL" value="${testStepReference.editURL}" />
<a target="_blank" title="${title}" href="${editReferencedURL}"><img src="<c:url value='/images/newskin/action/edit-blue-m.png'/>" /></a>
<%--
	<pre>
		source: ${source}
		source.project.id: ${source.project.id}
		refItem: ${refItem.project.id}
	</pre>
--%>
</c:if>
