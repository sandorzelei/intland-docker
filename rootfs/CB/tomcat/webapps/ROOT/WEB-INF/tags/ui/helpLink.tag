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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders WIKI or other help button/link, which opens in a popup dialog. Shows WIKI help by default.
--%>
<%@ attribute name="cssClass" required="false"
	description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false"
	description="CSS style attribute" %>
<%@ attribute name="helpURL" required="false"
	description="Optional url parameter, where the help link goes. Default shows the wiki-help-link" %>
<%@ attribute name="title" required="false"
	description="Optional title for the tooltip of the button. Defaults to 'Wiki Editing Help'" %>
<%@ attribute name="useImage" required="false"
	description="If true, then only the help icon will be displayed" %>
<%@ attribute name="target" required="false"
	description="Optional target attribute for the html link" %>


<c:if test="${empty helpURL}">
	<c:set var="helpURL" value="/help/wiki.do" />
</c:if>
<c:if test="${empty title}">
	<spring:message var="title" code="cb.wiki.help.title" text="Help" />
</c:if>

<c:url var="editing_help_url" value="${helpURL}" />
<c:set var="editing_help_onclick" value="launch_url('${editing_help_url}',null);return false;" />

<a title="${title}" href="${editing_help_url}" onclick="${editing_help_onclick}"
	class="${cssClass} helpLink" style="${cssStyle}" <c:if test="${! empty target}">target="${target}"</c:if>>
	<c:choose>
		<c:when test="${useImage || empty useImage}">
			<img src="<c:url value='/images/newskin/action/help.png'/>" />
		</c:when>
		<c:otherwise>
			${title}
		</c:otherwise>
	</c:choose>
</a>
