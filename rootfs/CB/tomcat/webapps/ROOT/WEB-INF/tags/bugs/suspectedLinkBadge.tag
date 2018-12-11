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
--%>
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ tag import="com.intland.codebeamer.persistence.dto.AssociationDto" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.AssociationTypeDto" %>
<%@ tag import="com.intland.codebeamer.persistence.dao.impl.EntityCache" %>

<%@ attribute name="from" required="true" type="java.lang.Integer" rtexprvalue="true" description="Item ID of the starting point of the link"  %>
<%@ attribute name="to" required="true" type="java.lang.Integer" rtexprvalue="true" description="Item ID of the endpoint of the link"  %>
<%@ attribute name="clearable" required="true" type="java.lang.Boolean" rtexprvalue="true" description="True if badge is clearable" %>
<%@ attribute name="association" required="false" type="com.intland.codebeamer.persistence.dto.AssociationDto" rtexprvalue="true" description="Association DTO object" %>
<%@ attribute name="revision" required="false" type="java.lang.Integer" rtexprvalue="true" description="The browsed baseline"  %>

<spring:message var="suspectedTitle" code="association.suspected.hint" text="The association target been modified since creating/resetting this association!" htmlEscape="true" />
<spring:message var="suspectedLabel" code="association.suspected.label" text="Suspected" />
<spring:message var="clearTitle" code="tracker.view.layout.document.reference.clear.suspected" text="Clear" htmlEscape="true"/>

<c:if test="${!empty association}">
	<%
		AssociationDto dto = (AssociationDto) jspContext.getAttribute("association");
		jspContext.setAttribute("associationId", dto.getId());
		jspContext.setAttribute("reverseSuspect", Boolean.valueOf(dto.isReverse()));
		//jspContext.setAttribute("showDiff", Boolean.valueOf(dto.getTypeId().equals(AssociationTypeDto.COPY_OF)));

		// always show the diff
		jspContext.setAttribute("showDiff",Boolean.TRUE);
		jspContext.setAttribute("copy", Boolean.valueOf(dto.getTypeId().equals(AssociationTypeDto.COPY_OF)));
		if (dto.getFrom() != null && dto.getFrom().getTypeId() != null && dto.getTo() != null && dto.getTo().getTypeId() != null) {
			jspContext.setAttribute("artifactSuspectedLink", Boolean.valueOf((dto.getFrom().getTypeId().intValue() == EntityCache.ARTIFACT_TYPE.intValue() || dto.getTo().getTypeId().intValue() == EntityCache.ARTIFACT_TYPE.intValue())));
		} else {
			jspContext.setAttribute("artifactSuspectedLink", Boolean.FALSE);
		}
	%>
</c:if>

<c:set var="extraClass" value="depends-on-icon"/>
<c:if test="${copy}">
	<c:set var="extraClass" value="copy-icon"/>
</c:if>

<span class="suspectedLinkBadgeContainer">
	<span class="${extraClass} assoc-type-icon"></span>

	<span class="suspectedLinkBadge suspect<c:if test="${clearable}"> clearable</c:if><c:if test="${showDiff}"> showDiff</c:if><c:if test="${artifactSuspectedLink}"> artifactSuspectLink</c:if>"
		  data-association-id="${associationId}" data-name="suspect-${from}-${to}" data-revision="${revision}"
		  title="${suspectedTitle}">
		${suspectedLabel} <span class="aggregatedCounter" style="display: none;">(<span class="value"></span>)</span>
		<c:if test="${reverseSuspect}">
			<span class="reverseSuspectImg"></span>
		</c:if>
		<c:if test="${clearable}">
			<span class="clearIcon"> <img title="${clearTitle}" src="<c:url value="/images/tablet-remove.png"/>"></span>
		</c:if>
	</span>
	<c:if test="${association.biDirectReferenceSupported && association.biDirectReference}">
		<span class="arrow arrow-up${association.biDirectOutgoingSuspected ? ' active' : ''}"></span> 
		<span class="arrow arrow-down${association.biDirectIncomingSuspected ? ' active' : ''}"></span>
	</c:if>	
</span>

<ui:urlversioned var="scriptLink" value="/js/suspectedLinkBadge.js"></ui:urlversioned>
<script src="${scriptLink}"></script>