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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<h2>
	<spring:message code="wiki.links.incoming.title" text="Incoming Links ({0})" arguments="${fn:length(pageIncomingLinks)}"/>
</h2>

<display:table requestURI="" cellpadding="0" name="${pageIncomingLinks}" id="incomingLink" defaultsort="1" pagesize="${pageSize}">
	<spring:message var="wikiLinkTitle" code="document.wikiLink.label" text="Wiki Link"/>
	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:column title="${wikiLinkTitle}" sortProperty="from.interwikiLink" sortable="true" headerClass="textData" class="textData columnSeparator">
		<c:choose>
			<c:when test="${not empty incomingLink.from.interwikiLink}">
				${incomingLink.from.interwikiLink}
			</c:when>
			<c:otherwise>
				--
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="sourceTitle" code="association.source.label" text="Source"/>
	<display:column title="${sourceTitle}" headerClass="textData expand" class="textData">
		<c:choose>
			<c:when test="${not empty incomingLink.from.urlLink}">
				<ui:wikiLink item="${incomingLink.from}"/>
			</c:when>
			<c:otherwise>
				<spring:message code="wiki.links.incoming.broken" text="Broken incoming link"/>
			</c:otherwise>
		</c:choose>
	</display:column>
</display:table>

<br/>

<h2>
	<spring:message code="wiki.links.outgoing.title" text="Outgoing Links ({0})" arguments="${fn:length(pageOutgoingLinks)}"/>
</h2>

<display:table requestURI="" cellpadding="0" name="${pageOutgoingLinks}" id="outgoingLink" defaultsort="1" pagesize="${pageSize}">
	<spring:message var="wikiLinkTitle" code="document.wikiLink.label" text="Wiki Link"/>
	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:column title="${wikiLinkTitle}" sortProperty="to.interwikiLink" sortable="true" headerClass="textData" class="textData columnSeparator">
		<c:choose>
			<c:when test="${not empty outgoingLink.to.interwikiLink}">
				${outgoingLink.to.interwikiLink}
			</c:when>
			<c:otherwise>
				--
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="targetTitle" code="association.target.label" text="Target"/>
	<display:column title="${targetTitle}" headerClass="textData expand" class="textData">
		<c:choose>
			<c:when test="${not empty outgoingLink.to.urlLink}">
				<ui:wikiLink item="${outgoingLink.to}"/>
			</c:when>
			<c:when test="${outgoingLink.urlReference}">
				<a href="<c:url value="${outgoingLink.url}"/>">
					<c:out value="${outgoingLink.url}"/>
				</a>
				<img class="outlink" src="<c:url value="/images/out.png"/>"/>
			</c:when>
			<c:otherwise>
				<spring:message code="wiki.links.outgoing.broken" text="Broken outgoing link"/>
			</c:otherwise>
		</c:choose>
	</display:column>
</display:table>
