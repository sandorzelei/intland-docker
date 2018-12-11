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
<%--
	JSP fragment renders the title for the Sitemesh decorators.

	This works in cooperation with the ui:pageTitle tag, the body of the ui:pageTitle is transformed to
	the real page title.
 --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="pageTitle"><decorator:getProperty property="meta.pageTitle" /></c:set>
<%-- if there was no ui:pageTitle call on the original jsp page, then generate the default, which includes the current-identifiable's name --%>
<c:if test="${empty pageTitle}">
	<ui:pageTitle printBody="false" >Intland - Codebeamer</ui:pageTitle>
	<c:set var="pageTitle" value="${requestScope.pageTitle}" />
</c:if>
<title>${pageTitle}</title>
