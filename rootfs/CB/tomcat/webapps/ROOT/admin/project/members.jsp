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
<meta name="module" content="${isProjectAdmin ? 'admin' : 'members'}"/>
<meta name="moduleCSSClass" content="newskin membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<link rel="stylesheet" href="<ui:urlversioned value='/admin/project/members.less' />" type="text/css" media="all" />

<c:url var="requestURI" value="/proj/members.spr"/>
<c:url var="userGroupIcon" value="/images/persons.gif" scope="request"/>

<ui:actionMenuBar verticalMiddleAlign="true">
	<jsp:attribute name="rightAligned">
		<ui:combinedActionMenu builder="memberViewsActionMenuBuilder" keys="settings,table,vcard" buttonKeys="settings,table,vcard" subject="${project}"
							   activeButtonKey="${memberLayout eq 'list' ? 'table' : memberLayout}" cssClass="large" />
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="true">
				<spring:message code="project.members.title" text="Members"/>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<ui:globalMessages/>
				
<c:choose>
	<c:when test="${memberLayout eq 'list'}">
		<jsp:include page="membersTable.jsp"/>
	</c:when>
	<c:when test="${memberLayout eq 'vcard'}">
		<jsp:include page="membersVcard.jsp"/>
	</c:when>
	<c:otherwise>
		<jsp:include page="membersSettings.jsp"/>
	</c:otherwise>
</c:choose>

<spring:message var="filterHint" code="filter.input.box.hint" text="Filter..."/>

<script type="text/javascript">
	jQuery(function($) {
		applyHintInputBox("#memberFilter", "${filterHint}");
	});
</script>
