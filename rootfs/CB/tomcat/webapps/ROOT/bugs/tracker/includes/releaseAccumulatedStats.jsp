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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:if test="${info.descendantsNumber > 0}">

	<div class="accumulatedStats">
		<span><spring:message code="cmdb.version.issues.sprint.count" arguments="${info.descendantsNumber}" /></span>
		<c:set var="greenPercentage" value="${(100.0 * info.descendantsResolvedOrClosed) / info.descendantsNumber}" />
		<c:set var="grayPercentage" value="${100.0 - greenPercentage}" />
		<fmt:formatNumber var="sprintProgressBarLabel" value="${greenPercentage}" maxFractionDigits="0"/>

		<ui:progressBar greenPercentage="${greenPercentage}" greyPercentage="${grayPercentage}" label="${sprintProgressBarLabel}%" totalPercentage="100" />
		<span><spring:message code="cmdb.version.issues.count.closed2" arguments="${info.descendantsResolvedOrClosed}" /></span>
		<span><spring:message code="cmdb.version.issues.count.open" arguments="${info.descendantsNumber - info.descendantsResolvedOrClosed}" /></span>
	</div>
</c:if>

<jsp:include page="./versionProgressInfo.jsp"/>
