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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=admin&stepIndex=4"/>

	<div class="info">
		<spring:message code="post.installer.sysadmin.info" text="Please set up your codeBeamer administrator account."/>
	</div>

	<form:form method="POST" modelAttribute="systemAdminForm">
		<div class="form-fields">
			<div class="field"><label for="firstName"><spring:message code="post.installer.admin.first.name.label" text="First name"/></label><form:input value="${userData.firstName}" path="firstName" id="firstName" cssErrorClass="error"/></div>
			<div class="field"><label for="lastName"><spring:message code="post.installer.admin.last.name.label" text="Last name"/></label><form:input value="${userData.lastName}" path="lastName" id="lastName" cssErrorClass="error"/></div>
			<div class="field"><label for="email"><spring:message code="post.installer.admin.email.label" text="Email address"/></label><form:input path="email" id="email" cssErrorClass="error"/></div>
			<div class="field"><label for="userName"><spring:message code="post.installer.admin.user.name.label" text="Username"/></label><form:input path="userName" id="userName" cssErrorClass="error"/></div>
			<div class="field"><label for="password"><spring:message code="post.installer.admin.password.label" text="Password"/></label><form:password path="password" id="password" cssErrorClass="error" autocomplete="off"/></div>
			<div class="field"><label for="confirmPassword"><spring:message code="post.installer.admin.confirm.password.label" text="Confirm password"/></label><form:password path="confirmPassword" id="confirmPassword" cssErrorClass="error" autocomplete="off"/></div>
		</div>
		<jsp:include page="includes/footer.jsp?step=admin&formName=systemAdminForm"/>
	</form:form>
</div>

