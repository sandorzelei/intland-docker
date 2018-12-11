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
 * $Id$
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="java.util.List"%>
<%@ tag import="java.util.Collection"%>
<%@ tag import="java.util.Collections"%>
<%@ tag import="java.util.Arrays"%>
<%@ tag import="org.displaytag.pagination.PaginatedList"%>
<%@ tag import="org.apache.commons.lang.StringUtils"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>


<%--
	Tag builds the allItems html block showing all items on the current displaytag.
	Sets:
		-requestScope.allItems variable, which can be used in displaytag to show all items...
		-requestScope.pagesize variable to contain the current pagesize parameter, or which default to defaultPageSize attribute

	USE: <display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
--%>

<%@ attribute name="itemNumber" required="false"
	description="Total number of items. Optional. Overridden by the 'items' attribute if present!" %>
<%@ attribute name="items" required="false" type="java.lang.Object"
	description="Optional collection of all items inside the table." %>

<%@ attribute name="defaultPageSize" required="false"
	description="Default page size" %>

<%@ attribute name="requestURI" required="false" description="same as display:table" type="java.lang.Object" %>

<%@ attribute name="excludedParams" required="false" type="java.lang.String"
	description="The white space separated list of params to be left out from the 'allItemsURL'. Note: This does NOT accept *-s a s DISPLAYTAG!"  %>

<c:if test="${!empty param.pagesize}">
	<c:catch>
		<c:set var="pagesize" value="${0 + param.pagesize}" />
	</c:catch>
</c:if>
<c:if test="${empty pagesize || pagesize < 1}">
	<c:set var="pagesize" value="${defaultPageSize}" />
</c:if>

<%-- export pagesize as request variable --%>
<c:set var="pagesize" scope="request" value="${pagesize}" />

<%
 List<String> excludedParamList = Collections.EMPTY_LIST;
 if (excludedParams != null) {
	 excludedParamList = Arrays.asList(excludedParams.split("\\s"));
 }

 Integer maxPageSize = null;
 if (items instanceof PaginatedList) {
	 PaginatedList page = (PaginatedList) items;
	 maxPageSize = Integer.valueOf(Math.min(ControllerUtils.MAX_PAGE_SIZE, page.getFullListSize()));
 } else if (StringUtils.isBlank(itemNumber) && items instanceof Collection) {
	 Collection collection = (Collection) items;
	 maxPageSize = Integer.valueOf(Math.min(ControllerUtils.MAX_PAGE_SIZE, collection.size()));
 }

 if (maxPageSize != null) {
 	jspContext.setAttribute("itemNumber", maxPageSize.toString());
 }
%>

<c:url var="allItemsURL" value="${empty requestURI ? '' : requestURI}" >
	<c:forEach var="par" items="${paramValues}">
		<c:if test="${par.key ne 'pagesize' }">
			<c:set var="paramKey" value="${par.key}" scope="page"/>
			<%
			   Object paramKey = jspContext.findAttribute("paramKey");
			   if (! excludedParamList.contains(paramKey)) { %>
				<c:param name="${par.key}" value="${par.value[0]}" />
			<% } %>
		</c:if>
	</c:forEach>
	<c:param name="pagesize" value="${itemNumber}" />
</c:url>

<spring:message var="title" code="paging.all.tooltip" text="Show All items in the table..."/>

<c:set var="allItems" scope="request">
	<div class="pagebanner" style="float:right;" >
		<a href="<c:out value="${allItemsURL}"/>" title="${title}">{0}</a> <spring:message code="paging.items.banner" text="{1} found, displaying {2} to {3}."/>	<a href="<c:out value="${allItemsURL}"/>" title="${title}"><spring:message code="paging.all.label" text="Show All..."/></a>
	</div>
</c:set>

