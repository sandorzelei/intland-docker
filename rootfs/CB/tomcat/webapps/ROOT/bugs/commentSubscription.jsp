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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:if test="${canSubscribeComment}">
	<style type="text/css">
		.emailContainerTable {
			width: 100%;
			margin-top: 0 !important;
		}
		.emailContainerTable .emailContainerTdLabel {
			width: 5%;
			vertical-align: middle !important;
		}
		.emailContainerTable .userSelector {
			position: relative;
			left: -2px;
		}
		.emailContainerTable .userSelector .chooseReferences {
			border: 1px solid #d1d1d1;
		}
		.emailContainerTable .emailSubject {
			width: 99.3%;
		}
	</style>

	<spring:message var="commentSubscriptionLabel" code="comment.subscription.send.email.label"/>
	<ui:collapsingBorder id="commentSubscription" label="${commentSubscriptionLabel}" open="false" cssClass="separatorLikeCollapsingBorder">
		<table class="emailContainerTable fieldsTable">
			<tr>
				<td class="fieldLabel mandatory emailContainerTdLabel"><spring:message code="comment.subscription.to.label"/>:</td>
				<td><bugs:userSelector ids="${commentSubscriptionIds}" htmlId="commentSubscriptionSelector" onlyCurrentProject="true" acceptEmail="true" existingJSON="${commentSubscriptionJSON}" showPopupButton="false"/></td>
			</tr>
			<tr>
				<td class="fieldLabel mandatory emailContainerTdLabel"><spring:message code="comment.subscription.subject.label"/>:</td>
				<td><input name="emailSubject" class="emailSubject" type="text" id="commentSubscriptionSubject" value="${not empty commentSubscriptionSubject ? commentSubscriptionSubject : ''}"></td>
			</tr>
		</table>
		<input type="hidden" name="subscription">
	</ui:collapsingBorder>

	<script type="text/javascript">
		$(function() {
			var $container = $("#commentSubscription");
			$container.find("a.collapseToggle").click(function() {
				setTimeout(function() {
					var collapsed = $("#commentSubscription").hasClass("collapsingBorder_collapsed");
					var saveButtonLabel = collapsed ? i18n.message("button.save") : i18n.message("button.saveAndSend");
					$(".editCommentSection .saveButton").html(saveButtonLabel);
					var $layout = $container.closest("#popupLayoutContentArea");
					if ($layout.length > 0) {
						$layout.find('input[name="SAVE"]').val(saveButtonLabel.replace("&amp;", "&"));
					}
					var $layoutContainer = $container.closest("#layoutContainer");
					if ($layoutContainer.length > 0) {
						$layoutContainer.find('input[name="save"]').val(saveButtonLabel.replace("&amp;", "&"));
					}
				}, 100);
			});
			var existingSubscriptionJSON = ${empty commentSubscriptionJSON ? 'null' : commentSubscriptionJSON};
			if (existingSubscriptionJSON !== null) {
				$container.find("a.collapseToggle").click();
			}
		});
	</script>
</c:if>