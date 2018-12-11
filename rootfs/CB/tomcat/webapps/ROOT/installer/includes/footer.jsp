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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<c:set value="${param.step}" var="step"/>

<div class="footer">

	<spring:hasBindErrors name="${param.formName}">
		<div id="springBindingErrors">
			<spring:message code="post.installer.validation.missing.info.message" text="Missing information. Please verify."/>
			<form:errors cssClass="form-errors" htmlEscape="false"></form:errors>
			<form:errors path="*" htmlEscape="false"></form:errors>
		</div>
	</spring:hasBindErrors>

	<c:if test="${!param.hideNavigation}">
		<spring:message code="post.installer.navigation.next.label" text="Next" var="nextLabel"/>
		<spring:message code="post.installer.navigation.previous.label" text="Previous" var="prevLabel"/>
		<spring:message code="post.installer.navigation.skip.label" text="Skip" var="skipLabel"/>
		<c:if test="${step != 'welcome' && step != 'admin'}">
			<input type="submit" name="_eventId_previous" value="${prevLabel }" class="prev-button link-button"/>
		</c:if>

		

		<c:if test="${step != 'done'}">
			<input type="submit" id="nextButton" name="_eventId_next" value="${nextLabel}" class="next-button link-button"/>
		</c:if>

		<c:if test="${step == 'agreement'}">
			<spring:message code="post.installer.agreement.button" text="I accept License Agreement" var="agreeText"/>
			<div class="agree-button">
				<input type="checkbox" id="agree" value="false"/>
				<label for="agree" class="link-button"><c:out value="${agreeText}"/></label>
				<script type="text/javascript">
					$(document).ready(function() {
						$("#nextButton").attr('disabled', 'disabled');
						$("#nextButton").addClass("next-button-disabled");
						$("#agree").change(function() {
							if($(this).is(":checked")) {
								$("#nextButton").removeAttr('disabled');
								$("#nextButton").removeClass("next-button-disabled");
							} else {
								$("#nextButton").attr('disabled', 'disabled');
								$("#nextButton").addClass("next-button-disabled");
							}
						});
					});
				</script>
			</div>
		</c:if>
		
		<c:if test="${step == 'license'}">
			<spring:message code="post.installer.navigation.${param.nextButtonLabel}.label" text="Next" var="nextButtonLabelString"/>
			<input type="button" name="ajax" class="next-button link-button" value="${nextButtonLabelString}"/>
		</c:if>

		<c:if test="${param.skipButton}">
			<input type="submit" name="_eventId_skip" value="${skipLabel}" class="link-button skip-button"/>
		</c:if>

	</c:if>
</div>
<div style="display:none"><img src="${pageContext.request.contextPath}/js/yui/assets/skins/sam/ajax-loader.gif"></div>

<script type="text/javascript">
	$(function() {

		// Footer position alignement
		var cont = $('.form-container');
		var footer = $('.footer');
		var formCont = cont.find('form');
		var alignFooter = function() {
			var scrollBarVisible = cont.get(0).scrollHeight > cont.get(0).offsetHeight;
			footer.css('position', scrollBarVisible ? 'relative' : 'absolute');
			formCont.css('padding-bottom', scrollBarVisible ? '0' : '50px');
		};
		alignFooter();
		$(window).resize(alignFooter);

		// Remove error css class if input focused and add autocomplete off to avoid browser caching
		var inputs = $('input, textarea, select');
		inputs.attr("autocomplete", "off");
		inputs.focus(function() {
			$(this).removeClass("error");
		});

		// Handling ENTER
		$(document).keypress(function(e) {
			var code = e.keyCode || e.which;
			if (code  == 13 && !$(e.target).is("textarea")) {
				e.preventDefault();
				$('#mask').remove();
				$('.overlay').remove();
			}
		});
		$('input').keypress(function(e) {
			var code = e.keyCode || e.which;
			if (code  == 13) {
				e.preventDefault();
				if ($("#mask").length > 0) {
					$('#mask').remove();
					$('.overlay').remove();
				} else {
					var ajaxButton = $('input[name="ajax"]');
					var nextButton = $('input[name="_eventId_next"]');
					if (ajaxButton.length > 0 && ajaxButton.is(':visible')) {
						ajaxButton.click();
					} else if (nextButton.length > 0 && nextButton.is(':visible')) {
						nextButton.click();
					} else {
						return false;
					}
				}
				return false;
			}
		});

		var errorCont = $("#springBindingErrors");
		if (errorCont.length > 0) {
			codebeamer.installer.displayErrorMessage(errorCont.find("span").first().html());
		}
	});
</script>
