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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="popup"/>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/remoteIssue/remoteIssue.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/installer/installer.css" />" type="text/css" media="all" />

<c:set var="step" value="${param.step}"/>
<c:set var="stepIndex" value="${param.stepIndex}"/>

<div class="header">
	<div class="actionBar">
		<div class="step-icon main"></div>
		<span class="main-title"><spring:message code="remote.issue.report.page.title" text="codeBeamer Contact Form"/></span>
	</div>

	<div class="installation-steps">
		<span class="${step == 'login' ? 'current' : '' }">1. <spring:message code="remote.issue.report.login.title" text="Login/Register"/></span>
		<span class="${step == 'submit' || step == 'selectType' ? 'current' : '' }">2. <spring:message code="remote.issue.report.submit.title" text="Submit a Bug / Feature Request / Question"/></span>
		<span class="${step == 'done' ? 'current' : '' }">3. <spring:message code="remote.issue.report.done.title" text="Done"/></span>
	</div>

	<div class="step-info">
		<div class="step-title">
			<spring:message code="post.installer.step.title" text="Step ${stepIndex}" arguments="${stepIndex}"/>
		</div>
		<div class="step-name">
			<c:choose>
				<c:when test="${step == 'submit' }">
					<c:choose>
						<c:when test="${addUpdateTaskForm.type == 'bug'}">
							<spring:message code="remote.issue.report.submit.type.title" arguments="${addUpdateTaskForm.trackerItem.typeName}" text=""/>
						</c:when>
                        <c:when test="${addUpdateTaskForm.type == 'request'}">
                            <spring:message code="remote.issue.report.submit.type.title" arguments="Feature Request" text=""/>
                        </c:when>
						<c:otherwise>
							<spring:message code="remote.issue.report.submit.type.title" arguments="Question" text=""/>
						</c:otherwise>
					</c:choose>
				</c:when>
				<c:otherwise>
					<spring:message code="remote.issue.report.${step}.title" text=""/>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>

<c:if test="${step != 'login' && step != 'selectType'}">
	<script type="text/javascript">
		$(document).ready(function () {
			// hide the submit buttons from included pages
			$(".container input[type=submit]").hide();
		});
	</script>
</c:if>

