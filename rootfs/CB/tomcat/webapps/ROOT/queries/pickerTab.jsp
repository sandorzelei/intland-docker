<%@ page import="com.intland.codebeamer.manager.UserManager" %>
<%@ page import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.ArtifactDto"%>
<%@ page import="com.intland.codebeamer.manager.EntityReferenceManager" %>
<%@ page import="com.intland.codebeamer.persistence.dto.base.NamedDto" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<spring:message code="queries.picker.myqueries.column.name.label" text="Name" var="column1title" scope="request" />
<spring:message code="queries.type.label" text="Type" var="column2title" scope="request" />
<spring:message code="tracker.field.Submitted at.label" text="Submitted at" var="column3title" scope="request" />
<spring:message code="tracker.field.Modified by" text="Modified by" var="column4title" scope="request" />
<spring:message code="tracker.field.Modified at" text="Modified at" var="column5title" scope="request" />

<display:table requestURI="/proj/queries/picker.spr" sort="external" name="queries" id="query" cellpadding="0" pagesize="${pagesize}" style="margin-top:4px;">
	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<c:if test="${reportSelectorMode}">
		<display:column headerClass="checkboxHeader" sortable="false">
			<input id="searchItem_${query.id}" name="searchItem" class="reportSelectorRadio" type="radio" value="${query.id}"<c:if test="${selectedItem eq query.id}"> checked="checked"</c:if>>
		</display:column>
	</c:if>
	<display:column title="${column1title}" headerClass="columnSeparator" class="textSummaryData" sortable="true" sortProperty="REV.name">
		<c:choose>
			<c:when test="${reportSelectorMode}">
				<a class="itemUrlLink" href="<c:url value="${query.urlLink}"></c:url>" target="_blank" title="${openLabel}">↗</a>
				<c:set var="reportName"><%= EntityReferenceManager.abbreviate(((NamedDto) query).getName()) %></c:set>
				<label class="reportSummary" data-id="${query.id}" data-name="<c:out value="${reportName}" />" for="searchItem_${query.id}"><c:out value="${query.name}" /></label>
			</c:when>
			<c:otherwise>
				<a href="<c:url value="${query.urlLink}"></c:url>" class="query-link" data-queryid="${query.id}"><c:out value="${query.name}" /></a>
			</c:otherwise>
		</c:choose>
	</display:column>
	<display:column title="${column2title}" headerClass="columnSeparator" class="textData column-minwidth">
		<c:choose>
			<c:when test="${currentUser eq query.owner}">
				<span class="private"><spring:message code="queries.private.label" text="private"/></span>
			</c:when>
			<c:otherwise>
				<span class="shared"><spring:message code="queries.shared.label" text="shared"/></span>
			</c:otherwise>
		</c:choose>
	</display:column>
	<display:column title="${column5title}" headerClass="columnSeparator" class="dateData column-minwidth" sortable="true" sortProperty="REV.created_at">
		<tag:formatDate value="${query.lastModifiedAt}" />
	</display:column>
	<display:column title="${column4title}" headerClass="columnSeparator" class="textData columnSeparator column-minwidth" sortable="true" sortProperty="REV.created_by">
		 <%
		 	UserDto modifiedBy = ((ArtifactDto) pageContext.getAttribute("query")).getLastModifiedBy();
		 %>
		 <%= UserManager.getInstance().getReference(request, modifiedBy) %>
	</display:column>
</display:table>