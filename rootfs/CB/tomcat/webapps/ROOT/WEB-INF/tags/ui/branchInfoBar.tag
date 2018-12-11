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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
	renders an information bar for a branch with some useful buttons.
--%>

<%@ attribute name="branch" required="true" rtexprvalue="true" type="com.intland.codebeamer.persistence.dto.BranchDto"%>
<%@ attribute name="baseline" required="false" rtexprvalue="true" type="com.intland.codebeamer.persistence.util.Baseline"%>
<%@ attribute name="masterUrlLink" required="false" rtexprvalue="true" type="java.lang.String"%>


<div  id="docbaselineinfo" class="baseline" >

	<c:set var="branchName" ><c:out value='${branch.name}' /></c:set>
	<spring:message code="tracker.branching.hint" text="You are now viewing the tracker under branch {0}" arguments="${branchName}" />

	<c:if test="${empty masterUrlLink }">
		<c:url value="${branch.masterUrlLink }" var="masterUrlLink">
			<c:if test="${baseline != null }">
				<c:param name="revision" value="${baseline.id }"></c:param>
			</c:if>
		</c:url>
	</c:if>

	<a class="changeLink" href="${masterUrlLink}"><spring:message code="tracker.branching.switch.to.master.label" text="Switch to Master"/></a>

	<c:if test="${not empty branch.parentBranch }">
		<c:url value="${branch.masterUrlLink }" var="parentUrlLink">
			<c:if test="${baseline != null }">
				<c:param name="revision" value="${baseline.id }"></c:param>
			</c:if>
			<c:param name="branchId" value="${branch.parentBranch }"></c:param>
		</c:url>
		<a class="changeLink" href="${parentUrlLink}"><spring:message code="tracker.branching.switch.to.parent.label" text="Switch to parent Branch"/></a>
	</c:if>
</div>