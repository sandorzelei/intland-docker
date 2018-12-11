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
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:actionGenerator builder="projectListPageActionMenuBuilder" actionListName="projectActions" allowedKeys="newWorkingSet, listProjects" >
	<ui:actionMenuBar>
		<ui:breadcrumbs strongBody="true"><ui:pageTitle><spring:message code="Working Sets" text="Working Sets"/></ui:pageTitle></ui:breadcrumbs>
	</ui:actionMenuBar>

	<ui:actionBar>
		<ui:rightAlign>
			<jsp:body>
				<ui:actionLink actions="${projectActions}" />
			</jsp:body>
		</ui:rightAlign>
	</ui:actionBar>
</ui:actionGenerator>

<display:table requestURI="/viewWorkingSets.spr" name="${workingSets}" id="workingset" cellpadding="0" export="false" defaultsort="1">

	<spring:message var="workingSetName" code="workingset.name.label" text="Name"/>
	<display:column title="${workingSetName}" sortProperty="name" sortable="true" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator"
		headerClass="textData" class="textData columnSeparator">

			<c:url var="editURL" value="/editWorkingSet.spr">
				<c:param name="workingSetId" value="${workingset.id}" />
			</c:url>
			<spring:message var="workingSetEdit" code="workingset.customize.tooltip" text="Edit Working Set"/>
			<a title="${workingSetEdit}" href="${editURL}"><c:out value="${workingset.name}"/></a>
			<br/>
			<table border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td nowrap width="20"></td>

					<td><span class="subtext"><tag:transformText value="${workingset.description}" format="${workingset.descriptionFormat}" /></span></td>

					<td nowrap width="4"></td>
				</tr>
			</table>
	</display:column>

	<spring:message var="workingSetProjects" code="workingset.projects.label" text="Projects"/>
	<display:column title="${workingSetProjects}" sortable="false"
		headerClass="textDataWrap expand" class="textDataWrap">
		<c:set var="items" value="${workingSetItems[workingset.id]}" />
		<c:forEach items="${items}" var="item" varStatus="loopStatus">
			<a class="${item.styleClass}" href="<c:url value="${item.urlLink}"/>"><c:out value="${item.name}" /></a><c:if test="${!loopStatus.last}">, </c:if>
		</c:forEach>
	</display:column>

</display:table>

