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
<%@tag import="org.apache.commons.lang.StringUtils"%>
<%@tag import="com.intland.codebeamer.persistence.dto.ScmRepositoryDto"%>
<%@tag import="com.intland.codebeamer.manager.ScmRepositoryManager"%>
<%@tag import="com.intland.codebeamer.scm.ScmDirEntry"%>
<%@tag import="com.intland.codebeamer.servlet.Utils"%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders a breadcrumb by splitting a request parameter, and for each part will add a breadcrumb-like link.
	For example if the "dirname" parameter looks like dirname="/a/b/c/" then it will generate a breadcrumb with 3 elements:
	"a", "b", "c" and each will have be a link with url of dirname="/a" and dirname="/a/b" and dirname="/a/b/c/" parameters
 --%>
<%@ attribute name="requestParameterName" type="java.lang.String" required="true" description="The name of the request parameter" %>
<%@ attribute name="path" required="false" description="The path to show, optional" %>
<%@ attribute name="baseURL" type="java.lang.String" required="false" description="The base url without context-path. By default then the current requestURI will be used." %>
<%@ attribute name="separator" type="java.lang.String" description="The separator between each piece in the parameter when splitting it. Defaults to / character." %>
<%@ attribute name="rootName" type="java.lang.String" description="The string to show as root. If empty then root element is not shown" %>

<tag:joinLines newLinePrefix="">
	<c:if test="${empty baseURL}">
		<%-- the base url defaults to the current request uri minus the specific parameter name --%>
		<%
			baseURL = Utils.getFilteredRequestURI(request, new String[]{requestParameterName}, true);
		%>
	</c:if>
	<%
		// remove context-path if already there
		if (baseURL.startsWith(request.getContextPath())) {
			baseURL = baseURL.substring(request.getContextPath().length());
			jspContext.setAttribute("baseURL", baseURL);
			jspContext.setAttribute("branch", StringUtils.substringAfterLast(baseURL, "/"));
		}

		if (path == null) {
			String paramValue = request.getParameter(requestParameterName);
			if (paramValue != null) {
				paramValue = StringUtils.substringAfter(paramValue, "/");
			}
			path = paramValue;
			jspContext.setAttribute("path", paramValue);
		}
	%>
	<c:if test="${empty separator}">
		<c:set var="separator" value="/"/>
	</c:if>

	<c:set var="currentPath" value="" />
	<c:set var="elementsSeparator"><span class='breadcrumbs-separator'>&raquo;</span></c:set>
	<span class="breadcrumbs">
		<c:if test="${not empty rootName}">
			<a href="<c:url value='${baseURL}'/>"><c:out value="${rootName}"/></a>
			<c:if test="${not empty path}">${elementsSeparator}</c:if>
		</c:if>

		<c:forTokens items="${path}" delims="${separator}" var="piece" varStatus="status">
			<c:set var="currentPath" value="${currentPath}${piece}" />
			<c:set var="isDir" value="${not status.last}"/>
			<%
				String repositoryId = request.getParameter("repositoryId");
				Integer repoId = Integer.valueOf(repositoryId);

				String cp = (String) jspContext.getAttribute("currentPath");
				String pathUrl = ScmDirEntry.getOpenUrlLink(cp, true, (String) jspContext.getAttribute("branch"),  repoId);
				jspContext.setAttribute("pathUrl", pathUrl);
			%>
			<c:set var="currentPath" value="${currentPath}${separator}" />
			<c:url var="url" value="${pathUrl}"/>
			<a href="${url}"><c:out value="${piece}"/></a>
			<c:if test="${not status.last}">${elementsSeparator}</c:if>
		</c:forTokens>
	</span>
</tag:joinLines>

