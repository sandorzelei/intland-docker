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
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="height" required="true" type="java.lang.Integer" rtexprvalue="true" description="Dialog height"  %>
<%@ attribute name="attachTo" required="true" type="java.lang.String" rtexprvalue="true" description="Selector of element to attach dialog when clicked"  %>
<%@ attribute name="triggerOnClick" required="false" type="java.lang.Boolean" rtexprvalue="true" description="Trigger show dialog on element click"  %>
<%@ attribute name="attachToParent" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If true then attaches to the parent window using the attachTo selector"  %>
<%@ attribute name="message" required="false" type="java.lang.String" rtexprvalue="true" description="Message to show"  %>
<%@ attribute name="imageUrl" required="false" type="java.lang.String" rtexprvalue="true" description="URL of image to show"  %>

<c:if test="${imageUrl == 'default'}">
	<c:set var="imageUrl" value="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" />
</c:if>

<ui:delayedScript avoidDuplicatesOnly="true">
<div id="inProgressDialogMarkup" class="popup" style="display: none">
	<div style="text-align: center; <c:if test="${empty message}">margin-top: 25px;</c:if>">
		<c:if test="${!empty message}">
			<p><c:out value="${message}" /></p>
		</c:if>
		<c:if test="${!empty imageUrl}">
			<img src="${imageUrl}" alt="progress"></img>
		</c:if>
	</div>
</div>

<style>
	.noTitle .ui-dialog-titlebar {
		display: none;
	}
</style>

<script type="text/javascript">
	// show the in-progress dialog attached to the element, use attachTo above to attach!
	function showInProgressDialog(elem) {
		$(elem).trigger("inProgressDialog");
	}

	var inProgressDialog = {
		show: function() {
			$("#inProgressDialogMarkup").dialog({
				height: ${height},
				modal: true,
				dialogClass: "popup noTitle"
			});
		},
		destroy: function() {
			$("#inProgressDialogMarkup").dialog("destroy");
		}
	};
</script>
</ui:delayedScript>

<c:if test="${!empty attachTo}">
	<script type="text/javascript">
		jQuery(function($) {
			var elem = $("${attachTo}" <c:if test="${attachToParent}">, parent.document</c:if>);
			var show = inProgressDialog.show;
			var destroy = inProgressDialog.destroy;
			// trigger the "inProgressDialog" event on the element to show/hide the dialog
			elem.on("inProgressDialog", function(event, toggle) {
				(toggle !== false) ? show() : destroy();
			});
			<c:if test="${triggerOnClick}">
				elem.click(show);
			</c:if>
		});

	</script>
</c:if>
