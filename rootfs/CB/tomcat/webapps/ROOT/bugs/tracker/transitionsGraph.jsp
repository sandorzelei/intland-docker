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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="${empty tracker.parent.id ? (tracker.category ? 'cmdb' : 'tracker') : 'docs'}"/>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"/>
</ui:actionMenuBar>

<ui:actionBar>
<a class="action" href="<c:url value='${tracker.urlLink}' />"><spring:message code="tracker.Issues.label" text="Issues"/></a>
</ui:actionBar>

<p />

${graphHtmlMarkup}
