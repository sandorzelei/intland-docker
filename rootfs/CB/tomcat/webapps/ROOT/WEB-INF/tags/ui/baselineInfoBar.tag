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
	Tag renders a baseline info bar.
--%>

<%@ attribute name="projectId" required="true" rtexprvalue="true" %>
<%@ attribute name="baselineName" required="true" rtexprvalue="true" %>
<%@ attribute name="baselineParamName" required="true" rtexprvalue="true" description="Baseline URL parameter name. If provided, change baseline action will reload current page with this parameter updated." %>
<%@ attribute name="cssStyle" required="false" %>
<%@ attribute name="notSupported" required="false" rtexprvalue="true" %>
<%@ attribute name="showCompareButton" required="false" rtexprvalue="true" %>
<%@ attribute name="compareUrl" required="false" rtexprvalue="true" %>
<%@ attribute name="showChangeLink" required="false" rtexprvalue="true" %>

<div id="docbaselineinfo" class="baseline" style="${cssStyle}">
	<c:choose>
		<c:when test="${notSupported}">
			<spring:message code="document.baseline.notSupported.hint" text="Baselining is not supported in this page." />
			<c:if test="${showChangeLink}">
			    <a class="changeLink" href="#" onclick="codebeamer.Baselines.changeDefaultBaseline('${projectId}', '${baselineParamName}'); return false;"><spring:message code="baseline.change.label" text="Change" /></a>
			</c:if>
		</c:when>
		<c:otherwise>
			<c:set var="baselineName" ><c:out value='${baselineName}' /></c:set>
			<spring:message code="document.baseline.hint" text="You are now viewing baselined version {0}" arguments="${baselineName}" />
			<a class="changeLink" href="#" onclick="codebeamer.Baselines.changeDefaultBaseline('${projectId}', '${baselineParamName}'); return false;"><spring:message code="baseline.change.label" text="Change" /></a>

			<c:if test="${not empty compareUrl }">
				<spring:message code="baseline.compare.label" var="compareLabel" text="Compare to Head revision"/>

				<a class="changeLink" href="${compareUrl}">
					<span class="baseline-compare-head"></span>
					<spring:message code="baseline.compare.label" text="Compare to Head revision"/>
				</a>
			</c:if>
		</c:otherwise>
	</c:choose>
	<button class="changeToHeadRevision" onclick="codebeamer.Baselines.switchToHead('${baselineParamName}'); return false;"><spring:message code="document.baseline.switchToHead.label" text="Switch to HEAD" /></button>
</div>
