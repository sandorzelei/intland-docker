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
--%>
<%--
 * this file lists all the review items in the review (almost the same as the center panel of the document view).
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:globalMessages/>

<c:if test="${empty reviewItems }">
	<div class="information">
		<spring:message code="cmdb.version.stats.no.issues.found" text="No items matching"></spring:message>
	</div>
</c:if>

<%-- build the table that lists the reviews --%>
<table id="requirements" class="displaytag fullExpandTable" style="table-layout: fixed;">
	<jsp:include page="reviewItemRows.jsp"/>
</table>
