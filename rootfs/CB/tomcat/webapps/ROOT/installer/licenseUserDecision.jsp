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

<%@ page import="com.intland.codebeamer.servlet.CBPaths" %>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=license&stepIndex=2"/>

	<div class="info"><spring:message code="post.installer.license.info" text="To start using codeBeamer ALM, you will need a License Code and an account on <a href=\"{0}\" target=\"_blank\">{0}</a>. You can either use your existing account, or create a new one below." arguments="<%= CBPaths.CB_API_URL %>"/></div>

	<form:form method="POST">
		<div class="form-fields">
			<div class="decisionRadio"><input type="radio" id="createNew" name="decision" value="createNew" checked="checked"><label for="createNew"><spring:message code="post.installer.license.create.new.account.label" text="Create new account"/></label></div>
			<div class="decisionRadio"><input type="radio" id="useExisting" name="decision" value="useExisting"><label for="useExisting"><spring:message code="post.installer.license.use.existing.account.label" text="Use existing account"/></label></div>
		</div>
		<jsp:include page="includes/footer.jsp?step=licenseDecision"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {
		var radioButtons = $('input[type="radio"]');
		var nextButton = $('input.next-button').first();
		radioButtons.change(function() {
			if ($(this).is(":checked")) {
				var actionValue = $(this).attr("value");
				//nextButton.attr("value", actionValue);
				nextButton.attr("name", "_eventId_" + actionValue);
			}
		});
		radioButtons.change();
	});
</script>
