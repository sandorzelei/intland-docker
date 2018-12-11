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
 * $Revision$ $Date$
--%>
<%@page import="com.intland.codebeamer.controller.scm.ScmRepositoryModel"%>
<%@page import="com.intland.codebeamer.controller.scm.ScmRepositoryManagerController.ScmRepositoryModelBuilder"%>
<%@page import="com.intland.codebeamer.controller.scm.ScmRepositoryManagerController"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%--
	JSP fragment renders a tree of repositories, with an expandable box of the sub-repositories/forks of it.

	inputs:
		requestScope.repositoryModelBuilder 	The ScmRepositoryModelBuilder contains all ScmRepositoryModel/Dto hierarchy prepared for rendering
		param.parentId		The id of the parent repository whose children will be rendered
 --%>
<c:set var="repositories" value="${repositoryModelBuilder.topLevelRepositories}"/>
<c:if test="${! empty param.parentId}">
	<%
		ScmRepositoryModelBuilder modelBuilder = (ScmRepositoryManagerController.ScmRepositoryModelBuilder) request.getAttribute("repositoryModelBuilder");
		ScmRepositoryModel parent = modelBuilder.getModel(Integer.valueOf(request.getParameter("parentId")));
		pageContext.setAttribute("parent", parent);
	%>
	<c:set var="repositories" value="${parent.forks}" />
</c:if>

<c:set var="compactRepositoryCard" value="true" scope="request" />
<c:forEach var="repository" items="${repositories}">
		<c:set var="repositoryModel" scope="request" value="${repository}" />
		<jsp:include page="repository-card.jsp" flush="false"/>
</c:forEach>
