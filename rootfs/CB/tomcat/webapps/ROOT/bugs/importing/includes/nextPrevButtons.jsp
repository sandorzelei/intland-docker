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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

	<c:set var="nr_of_columns" value="${fn:length(importForm.dataList[0])}" />
<%-- small fragment showing next/prev/cancel buttons --%>
	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
	<c:if test="${param.finish eq 'true'}">
		<spring:message var="nextButton" code="button.finish" text="Finish &gt;"/>
	</c:if>

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_back" value="${backButton}" />
	<c:if test="${finishAllowed != false && nr_of_columns > 0}">
		&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_next" value="${nextButton}" />
	</c:if>
	<input type="submit" class="button cancelButton" name="_eventId_cancel" value="${cancelButton}" />

<pre style="float:right; width: 30%; height: 500px; overflow: auto; display: none">
<c:out value='${importForm.asJSON}'/>
</pre>
