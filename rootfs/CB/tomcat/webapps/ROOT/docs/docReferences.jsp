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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<div class="actionBar"></div>

<display:table requestURI="" cellpadding="0" name="${docReferences}" id="reference" defaultsort="1">
	<spring:message var="wikiLinkTitle" code="document.wikiLink.label" text="Wiki Link"/>
	<display:column title="${wikiLinkTitle}" property="from.interwikiLink" sortable="true" headerClass="textData" class="textData columnSeparator"/>

	<spring:message var="sourceTitle" code="association.source.label" text="Source"/>
	<display:column title="${sourceTitle}" headerClass="textData expand" class="textData">
		<c:choose>
			<c:when test="${not empty reference.from.urlLink}">
				<html:img border="0" page="${reference.from.iconUrl}"/>
				<a href="<c:url value="${reference.from.urlLink}"/>">
					<c:out value="${reference.from.shortDescription}"/>
				</a>
			</c:when>
			<c:otherwise>
				<spring:message code="wiki.links.incoming.broken" text="Broken incoming link"/>
			</c:otherwise>
		</c:choose>
	</display:column>
</display:table>

