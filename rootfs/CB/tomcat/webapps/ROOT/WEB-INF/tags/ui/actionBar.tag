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

<%--
	Tag renders actionBar. Use this to render the action-bar when that is on the top of the page.
	It also add the globalMessages control below the actionBar if that is not yet added.
--%>

<%@ attribute name="rightAligned" fragment="true" required="false" %>

<%@ attribute name="cssClass" required="false" description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false" description="CSS style attribute" %>
<%@ attribute name="id" required="false" description="The html id" %>
<%@ attribute name="excludeGlobalMessages" required="false" description="If true, do not display the global messages" %>

<div class="actionBar ${cssClass}" <c:if test="${! empty cssStyle}"> style="${cssStyle}" </c:if> <c:if test="${! empty id}"> id="${id}" </c:if> >
	<c:if test="${!empty rightAligned}">
		<div style="float: right"><jsp:invoke fragment="rightAligned"/></div>
	</c:if>
	<jsp:doBody/>
</div>

<c:if test="${!excludeGlobalMessages}">
	<%-- the global messages should always appear right after the action-menu-bar --%>
	<ui:globalMessages/>
</c:if>


