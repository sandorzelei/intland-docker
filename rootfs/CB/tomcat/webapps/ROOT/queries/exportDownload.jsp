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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<ui:actionMenuBar>
	<spring:message code="queries.export.download.title" text="Download Exported Queries"/>
</ui:actionMenuBar>

<spring:message var="closeButton" code="button.close"/>
<ui:actionBar>
	&nbsp;&nbsp;<input type="submit" class="button" value="${closeButton}" onclick="inlinePopup.close(); return false;"/>
</ui:actionBar>

<c:if test="${! empty downloadUrl}">
	<script type="text/javascript">
		$(function() {
			document.location.href="${downloadUrl}";
		});
	</script>
</c:if>
