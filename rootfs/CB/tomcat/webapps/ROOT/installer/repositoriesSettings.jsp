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

<%@ page import="com.intland.codebeamer.installer.InstallerSupport" %>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=repositories&stepIndex=5"/>

	<div class="warningText"><spring:message code="post.installer.repositories.svn.warn" text="Due to security concerns, we do not recommend enabling local SVN services. If enabled, user passwords will be stored as a plain text in the generated password file for SVN."/></div>
	<div class="info"><spring:message code="post.installer.repositories.svn.info" text="Do you want to enable SVN services on your server?"/></div>

	<form:form method="POST">
		<div class="form-fields">
			<div class="decisionRadio"><input type="radio" id="enableSvn" name="decision" value="enableSvn">
				<label for="enableSvn"><spring:message code="post.installer.repositories.svn.enable" text="Enable local SVN services"/></label>
			</div>
			<div class="decisionRadio"><input type="radio" id="disableSvn" name="decision" value="disableSvn" checked="checked">
				<label for="disableSvn"><spring:message code="post.installer.repositories.svn.disable" text="Disable local SVN services"/></label>
			</div>
		</div>
		<jsp:include page="includes/footer.jsp?step=repositories"/>
	</form:form>
</div>

<script type="text/javascript">
	$(function() {
		var radioButtons = $('input[type="radio"]');
		var nextButton = $('input.next-button').first();
		radioButtons.change(function() {
			if ($(this).is(":checked")) {
				var actionValue = $(this).attr("value");
				nextButton.attr("name", "_eventId_" + actionValue);
			}
		});
		radioButtons.change();
	});
</script>
