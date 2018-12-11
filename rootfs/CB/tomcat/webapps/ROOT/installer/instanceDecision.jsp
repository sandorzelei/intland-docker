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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=instance&stepIndex=1"/>

	<div class="info"><spring:message code="post.installer.instance.info" text="Please select whether you would like to upgrade your existing codeBeamer ALM instance, or create a new one:"/></div>

	<form:form method="POST">
		<div class="form-fields">
			<div class="decisionRadio"><input type="radio" id="new" name="decision" value="new"<c:if test="${empty existingLicenseCode}"> checked="checked"</c:if>><label for="new"><spring:message code="post.installer.instance.new.label" text="Create a new codeBeamer ALM instance"/></label></div>
			<div class="decisionRadio"><input type="radio" id="existing" name="decision" value="existing"<c:if test="${not empty existingLicenseCode}"> checked="checked"</c:if>><label for="existing"><spring:message code="post.installer.instance.existing.label" text="Upgrade my existing codeBeamer ALM instance"/></label></div>
			<div id="existingInstanceInfo"><spring:message code="post.installer.instance.existing.info" text="Please follow the upgrade process that is described in the codeBeamer Knowleged Base <b><a href=\"https://codebeamer.com/cb/wiki/93657\" target=\"_blank\">Upgrading from older versions</a></b>."/></div>
		</div>
		<jsp:include page="includes/footer.jsp?step=instance"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {
		var radioButtons = $('input[type="radio"]');
		var nextButton = $('input.next-button').first();
		var existingInfo = $('#existingInstanceInfo');
		radioButtons.change(function() {
			if ($(this).is(":checked")) {
				var actionValue = $(this).attr("value");
				//nextButton.attr("value", actionValue);
				nextButton.attr("name", "_eventId_" + actionValue);
				if (actionValue == "existing") {
					existingInfo.show();
				} else {
					existingInfo.hide();
				}
			}
		});
		radioButtons.change();
	});
</script>
