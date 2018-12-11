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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<fmt:bundle basename="com.intland.codebeamer.utils.Bundle">
	<fmt:message key="cookie.policy" var="cookiePolicyText" />
	<fmt:message key="cookie.policy.enabled" var="isCookiePolicyEnabled" />
	<fmt:message key="cookie.policy.format" var="cookiePolicyFormat" />
</fmt:bundle>

<c:if test="${isCookiePolicyEnabled eq 'true' and not empty cookiePolicyText}">
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/cookieBar.less' />" type="text/css" media="all" />

	<div id="cookie-bar" class="noPrint">
		<div class="cookie-bar-content">
			<tag:transformText value="${cookiePolicyText}" format="${cookiePolicyFormat}" />
			<div class="buttons">
				<button class="accept-button"><spring:message code="button.accept" text="Accept" /></button>
			</div>
		</div>
	</div>
	<script type="text/javascript">
		$(function() {
			var $cookieBar = $('#cookie-bar'),
				cookie = $.cookie('cookiebar');

			if (cookie) {
				$cookieBar.hide();
			} else {
				$cookieBar.show();

				$cookieBar.find('.buttons .accept-button').on('click', function() {
					$.cookie('cookiebar', true, {
						expires: 365 * 10,
						path: contextPath
						// secure option is automatically set by jquery.cookie.patched.js
					});
					$cookieBar.hide();
				});
			}
		});
	</script>
</c:if>