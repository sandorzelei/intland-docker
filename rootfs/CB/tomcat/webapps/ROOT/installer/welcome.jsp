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

<%@ page import="com.intland.codebeamer.controller.support.UserAgent" %>

<%
	UserAgent userAgent = UserAgent.get(request);
	request.setAttribute("userAgent", userAgent);
	request.setAttribute("userAgentString", userAgent.getName());
%>

<c:choose>
	<c:when test="${(userAgent.ie gt 0) and (userAgent.ie lt 11)}">
		<ul><spring:message code='not.supported.browser.warning'/>
			<ul style="padding-top:15px; line-height: 1.5em;">
				<li><a style="text-decoration:none;" href="http://www.microsoft.com/windows/Internet-explorer/default.aspx">Internet Explorer 11+ </a></li>
				<li><a style="text-decoration:none;" href="http://www.mozilla.com/firefox/"><spring:message code="not.supported.browser.latest.stable.label"/> Firefox </a></li>
				<li><a style="text-decoration:none;" href="http://www.google.com/chrome"><spring:message code="not.supported.browser.latest.stable.label"/> Chrome </a></li>
			</ul>
		</ul>
		<div style="padding-left:15px;">
			<spring:message code='not.supported.browser.info'/><br/><br/>
				<spring:message code='not.supported.browser.detected' arguments='${userAgentString}'/></li>
		</div>
	</c:when>
	<c:otherwise>
		<div class="form-container">
			<jsp:include page="includes/header.jsp?step=welcome"/>

			<div class="info"><spring:message code="post.installer.welcome.part1" text="This Setup Wizard will guide you through the steps of the installation process, helping you get started with codeBeamer ALM in a matter of minutes."/></div>
			<div class="info"><spring:message code="post.installer.welcome.part2" text="You are about to set up a 30-day trial instance of codeBeamer ALM which allows you to use this integrated ALM platform with no obligations or limitations. This copy of codeBeamer ALM is a fully functional Application Lifecycle Management suite that you'll be able to use for 30 days with up to 25 users to evaluate the functionally and performance of our market-leading ALM tool."/></div>
			<div class="info"><spring:message code="post.installer.welcome.part3" text="For more information about codeBeamer ALM, visit <a href=\"https://intland.com/\" target=\"_blank\">https://intland.com</a>, or head over to our <a href=\"https://codebeamer.com/cb/project/CB\" target=\"_blank\">Knowledge Base</a>."/></div>
			<div class="info"><spring:message code="post.installer.welcome.part4" text="If you are ready to make purchase, get in touch with our sales team at <a href= \"mailto:sales@intland.com\" class=\"actionLink\">sales@intland.com.</a> for a custom quote."/></div>
			<div class="info"><spring:message code="post.installer.welcome.part5" text="To start the installation process, click Next."/></div>

			<form:form method="POST">
				<jsp:include page="includes/footer.jsp?step=welcome"/>
			</form:form>
		</div>
	</c:otherwise>
</c:choose>

