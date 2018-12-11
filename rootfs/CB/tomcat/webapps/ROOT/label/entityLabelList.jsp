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
 *
 * $Revision: 23955:cdecf078ce1f $ $Date: 2009-11-27 19:54 +0100 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="acltaglib" prefix="acl" %>

<%@page import="com.intland.codebeamer.persistence.dto.base.ProjectAwareDto"%>
<%@page import="com.intland.codebeamer.security.ProjectRequestWrapper"%>
<%@page import="com.intland.codebeamer.persistence.dto.base.WriteControlledDto"%>

<c:if test="${licenseCode.enabled.labels}">
	<acl:isAnonymousUser var="isAnonymousUser" />
	<%
		// note: this scriptlet is rather ugly, but this is only way to do it simply and use as an includable component-like JSP fragment without passing in a bunch of parameters
		ProjectAwareDto projectAware = (request instanceof ProjectRequestWrapper) ? ((ProjectRequestWrapper)request).getCurrentProjectAware() : null;
		boolean writeable = (!(projectAware instanceof WriteControlledDto) || ((WriteControlledDto)projectAware).isWritable());

		request.setAttribute("writable", Boolean.valueOf(writeable));
	%>

	<div class="labellist">

		<%-- view all tags link --%>
        <%-- <c:url var="showLabelsUrl" value="/proj/label/showLabels.do"/>

		<c:if test="${empty param.editable or param.editable ne 'false'}">
			<spring:message var="tagAdmin" code="tag.admin.title" text="Tag Administration"/>
			<div style="float:right; margin-left:1em;">
				<span class="noPrint">
					<a href="${showLabelsUrl}" title="${tagAdmin}">
						<spring:message code="tag.admin.label" text="View all tags"/>
					</a>
				</span>
			</div>
		</c:if> --%>

		<c:url var="openEntityLabelPopup" value="/proj/label/openEntityLabelPopup.do">
			<c:param name="entityTypeId" value="${param.entityTypeId}" />
			<c:param name="entityId" value="${param.entityId}" />
			<c:param name="forwardUrl" value="${param.forwardUrl}" />
			<c:if test="${not empty param.branchId}"><c:param name="branchId" value="${param.branchId}" /></c:if>
		</c:url>

		<c:set var="openPopupEditorJs">addItemIdsAndShowPopupInline('${openEntityLabelPopup}'); return false;</c:set>

		<%-- title / add link --%>
		<spring:message var="tagsTitle" code="tags.tooltip" text="Add Tags to this..."/>
		<c:choose>
			<c:when test="${isAnonymousUser || !writable || param.editable eq 'false'}">
				<span class="tags-head tag"><spring:message code="tags.label" text="Tags"/>:&nbsp;</span>
			</c:when>
			<c:otherwise>
				<a class="tags-head tag" href="#" onclick="${openPopupEditorJs}" title="${tagsTitle}"><spring:message code="tags.label" text="Tags"/>:</a>&nbsp;
			</c:otherwise>
		</c:choose>

		<%-- label listing --%>
		<c:set var="hasTags" value="false" />
		<c:forEach items="${entityLabels}" var="entityLabel" varStatus="status">
			<c:if test="${!entityLabel.label.hidden}">
				<c:set var="hasTags" value="true" />
				<c:url var="displayLabeledContentUrl" value="/proj/label/displayLabeledContent.do">
					<c:param name="labelId" value="${entityLabel.label.id}" />
				</c:url>
				<a class="tag-label tag" href="${displayLabeledContentUrl}"><c:out value="${entityLabel.label.displayName}" /></a>
			</c:if>
		</c:forEach>
		<c:if test="${!hasTags && param.editable}">
			<a class="tags-none tag" href="#" onclick="${openPopupEditorJs}"><spring:message code="tags.none" text="not added yet"/></a>
		</c:if>
		<c:if test="${!hasTags && param.editable eq 'false'}">
			<span class="tags-none tag"><spring:message code="tags.none" text="not added yet"/></span>
		</c:if>
	</div>
</c:if>