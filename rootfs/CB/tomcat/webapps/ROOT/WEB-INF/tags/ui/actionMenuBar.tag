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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%--
	Tag renders Action-MenuBar. Necessary, because it is not simply a div any more, but with an actionMenuBar icon, and
	there might be other markup for the rounded borders too :-(
--%>

<%@ attribute name="cssClass" required="false"
	description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false"
	description="CSS style attribute" %>
<%@ attribute name="verticalMiddleAlign" required="false" type="java.lang.Boolean"
	description="If the content is middle aligned vertically. Defaults to true" %>
<%@ attribute name="showGlobalMessages" required="false" type="java.lang.Boolean"
	description="If the GlobalMessages will be displayed right below the actionMenuBar. Should be used when there is no actionBar on the page, otherwise the ui:actionBar should be used!" %>
<%@ attribute name="showRating" required="false" type="java.lang.Boolean"
	description="If the rating widget is shown on this page. Defaults to true" %>

<c:if test="${empty verticalMiddleAlign}"><c:set var="verticalMiddleAlign" value="true"/></c:if>

<%@ attribute name="rightAligned" fragment="true" %>

<div class="actionMenuBar ${cssClass}" <c:if test="${! empty cssStyle}"> style="${cssStyle}" </c:if> >
		<%-- the position:relative below is a hack to fix IE problems caused by the background image,
		see #3 at : http://www.webcredible.co.uk/user-friendly-resources/css/internet-explorer.shtml --%>
	<c:choose>
		<c:when test="${verticalMiddleAlign}">
			<ui:rightAlign tableCssClass="actionMenuBarContent">
				<jsp:attribute name="filler"><jsp:doBody></jsp:doBody></jsp:attribute>
				<jsp:attribute name="rightAligned"><c:if test="${empty showRating || showRating}"><ui:rating voting="false" onlyForWikiOrIssue="true" disabled="true" /></c:if><jsp:invoke fragment="rightAligned"/></jsp:attribute>
				<jsp:body><div class="actionMenuBarIcon" ></div></jsp:body>
			</ui:rightAlign>
		</c:when>
		<c:otherwise>
			<div class="actionMenuBarContent">
				<div class="actionMenuBarIcon" ></div>
				<%-- process the body inside the actionMenuBar --%>
				<jsp:doBody></jsp:doBody>
			</div>
		</c:otherwise>
	</c:choose>

	<div style="clear:both;" ></div>
</div>

<c:if test="${showGlobalMessages}">
	<ui:globalMessages/>
</c:if>
