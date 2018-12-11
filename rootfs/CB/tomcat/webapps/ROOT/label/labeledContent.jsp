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
<%@page import="com.intland.codebeamer.manager.EntityLabelManager"%>
<%@page import="com.intland.codebeamer.persistence.dto.LabelDto"%>

<meta name="decorator" content="main"/>
<meta name="module" content="labels"/>
<meta name="moduleCSSClass" content="newskin labelsModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:set var="STARRED_LABEL" value='<%=LabelDto.PRIVATE_LABEL_PREFIX + EntityLabelManager.STARRED_LABEL%>' />
<c:set var="isStarredLabel" value="${label.displayName == STARRED_LABEL}" />
<c:set var="title">
<c:choose>
	<c:when test='${isStarredLabel}' >
		<spring:message code="tags.starred.title" text="My Starred Items"/>
	</c:when>
	<c:otherwise>
		<spring:message code="tag.entities.title" text="Content Tagged with {0} ({1})" arguments="${fn:escapeXml(label.displayName)},${fn:length(labeledEntities)}"/>
	</c:otherwise>
</c:choose>
</c:set>

<jsp:include page="./includes/actionBar.jsp">
	<jsp:param name="title" value="${title}" />
	<jsp:param name="showGlobalMessages" value="false" />
</jsp:include>

<ui:actionBar>
	<ui:actionLink builder="labelsPageActionMenuBuilder" />
</ui:actionBar>

<div class="contentWithMargins" style="margin-top: 0">
	<display:table name="${labeledEntities}" id="labeledEntity" requestURI="displayLabeledContent.do" class="expandTable displaytag" cellpadding="0" defaultsort="1" export="true">
		<display:column sortable="false" media="html">
			<c:choose>
				<c:when test="${isStarredLabel}">
					<ui:ajaxTagging entityTypeId="${labeledEntity.entityTypeId}" entityId="${labeledEntity.dto.id}" on="true" favourite="true" />
				</c:when>
				<c:otherwise>
					<c:set var="ajaxTaggingEnabled" value="false"/>

					<% try { %>
					<c:set var="ajaxTaggingEnabled" value="${labeledEntity.dto.writable}" />
					<% } catch (Throwable th) {
						// if the dto is not a WriteControlledDto, then we allow tagging... see 'writeable' attribute in entityLabelList.jsp
						pageContext.setAttribute("ajaxTaggingEnabled", Boolean.TRUE);
					}%>
					<ui:ajaxTagging entityTypeId="${labeledEntity.entityTypeId}" entityId="${labeledEntity.dto.id}" on="true" tagName="${label.displayName}"
									enabled="${ajaxTaggingEnabled}" cssStyle="margin:1px;"
							/>
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="objectShortDescription" code="user.history.shortDescription.label" text="Artifact"/>
		<display:column title="${objectShortDescription}" headerClass="textData" class="textDataWrap" media="html">
			<ui:wikiLink item="${labeledEntity.dto}" hideBadges="${true}" useKeyInLabel="true"/>
		</display:column>

		<display:column title="${objectShortDescription}" media="csv xml excel pdf">
			<c:out value="${labeledEntity.dto.shortDescription}" />
		</display:column>


		<c:set var="trackerProperty" value="" />
		<c:set var="trackerProperty">
        	<c:catch var="exception">${labeledEntity.dto.tracker}</c:catch>
    	</c:set>

		<c:set var="projectProperty" value="" />
		<c:set var="projectProperty">
			<c:catch var="exception">${labeledEntity.dto.project}</c:catch>
		</c:set>

		<spring:message var="projectLabel" code="document.project.label" text="Project"/>
		<display:column title="${projectLabel}" headerClass="textData" media="html">
			<c:if test="${not empty trackerProperty}">
				<ui:wikiLink item="${labeledEntity.dto.tracker.project}" hideBadges="${true}" useKeyInLabel="true" />
			</c:if>
			<c:if test="${empty trackerProperty and not empty projectProperty}">
				<ui:wikiLink item="${labeledEntity.dto.project}" hideBadges="${true}" useKeyInLabel="true" />
			</c:if>
		</display:column>

		<display:column title="${projectLabel}" media="csv xml excel pdf">
			<c:if test="${not empty trackerProperty}">
				<c:out value="${labeledEntity.dto.tracker.project.name}" />
			</c:if>
			<c:if test="${empty trackerProperty and not empty projectProperty}">
				<c:out value="${labeledEntity.dto.project.name}" />
			</c:if>
		</display:column>

		<spring:message var="created" code="tag.since.label" text="Since"/>
		<display:column title="${created}" sortProperty="createdAt" sortable="true" headerClass="dateData" class="dateData" style="width:10%;" media="html">
			<tag:formatDate value="${labeledEntity.createdAt}" />
		</display:column>
	</display:table>
</div>
