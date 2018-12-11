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

<%--
	The configuration page for the extended view (where the user can add additional fields).
--%>
<meta name="decorator" content="popup"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<ui:actionMenuBar>
	Configuration
</ui:actionMenuBar>
<form:form commandName="command">

	<ui:actionBar>
		<form:button class="button"><spring:message code="button.save" text="Save"></spring:message></form:button>
	</ui:actionBar>

	<div class="contentWithMargins">
		<span class="hint">On this page you can add/remove fields from the view</span>

		<div style="margin-top: 10px; margin-bottom: 10px;">
			<input type="text" autocomplete="off" name="filterInput" id="filterInput" maxlength="30" size="30" />
		</div>

		<div>
			<table id="fieldlist" syle="margin-top: 10px; margin-bottom: 10px;">
				<c:forEach items="${fields }" var="field">
					<tr>
						<td>
							<label>
								<c:set var="checked" value="${configuration.fieldIds.contains(field.id) ? 'checked=checked' : 'false' }"></c:set>
								<input type="checkbox" name="fieldIds" value="${field.id }" ${checked } />
								<spring:message code="tracker.field.${field.label }.label" text="${field.label }"></spring:message>
							</label>
						</td>
					</tr>
				</c:forEach>
			</table>
		</div>
	</div>

</form:form>

<script type="text/javascript">
	var table = $("#fieldlist");
	$("#filterInput").keyup(function() {
		$.uiTableFilter(table, this.value);
	}).Watermark(i18n.message("user.history.filter.label"));
</script>



