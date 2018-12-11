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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="step" value="${param.step}"/>

<div class="footer">
	<c:if test="${step != 'done' && step != 'login'}">
		<spring:message code="post.installer.navigation.next.label" text="Next" var="nextLabel"/>
		<input type="button" id="next" value="${nextLabel}" class="next-button link-button"/>
	</c:if>
	<c:if test="${step == 'done'}">
		<spring:message code="remote.issue.report.done.title" text="Done" var="doneLabel"/>
		<input type="button" id="done" value="${doneLabel}" class="next-button link-button" onclick="window.parent.postMessage('closePopup', '*');"/>
	</c:if>

	<c:if test="${addUpdateTaskForm != null && (step == 'selectType' || step == 'submit')}">
		<c:url var="loginUrl" value="/remote/issue/login.spr">
			<c:param name="targetURL"
				value="/remote/issue/create.spr?hostId=${addUpdateTaskForm.hostId}&operatingSystem=${addUpdateTaskForm.operatingSystem}&databaseType=${addUpdateTaskForm.databaseType}&releaseId=${addUpdateTaskForm.releaseId}&diskSpace=${addUpdateTaskForm.diskSpace}&memory=${addUpdateTaskForm.memory}"></c:param>
            <c:param name="doLogout" value="true" />
		</c:url>
		<spring:message var="switchUserTitle" code="remote.issue.report.switch.user.title" text="Log in with an other user"/>
		<c:set var="userName"><c:out value='${userName}'/></c:set>
		<span class="logged-in-userinfo"><spring:message code="remote.issue.report.logged.in.info" text="Logged in user <strong>{0}</strong>" arguments="${userName }"/> (<a href="${loginUrl}" title="Log in with an other user"><spring:message code="remote.issue.report.switch.user.message" text="Not you?"/></a>)</span>
	</c:if>
</div>

<c:choose>
	<c:when test="${step == 'submit' }">
		<script type="text/javascript">
			$("#next").click(function () {
				$(".container input[name=SUBMIT]").click();
			});
		</script>
	</c:when>
	<c:otherwise>
		<script type="text/javascript">
			$("#next").click(function () {
				$("form").submit();
			});
		</script>
	</c:otherwise>
</c:choose>

