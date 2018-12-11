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

<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>

<%
    pageContext.setAttribute("targetURL", ControllerUtils.getOriginatingRequestUri(request, false, true));
%>

<div id="highlightLogin">
    <p>
        <c:url var="loginUrl" value="/login.spr">
            <c:param name="targetURL" value="${targetURL}"/>
        </c:url>
        <c:set var="loginIcon">
            <a href="${loginUrl}">
                <img class="login-highlight-icon white" src="<c:url value='/images/space.gif'/>"/>
            </a>
        </c:set>
        <spring:message code="login.highlight.title" arguments="${loginIcon}"/>
    </p>

    <img class="close-icon" src="<c:url value='/images/space.gif'/>"/>

    <script type="text/javascript">
        $(function() {
            var $highlightLogin = $('#highlightLogin');

            $highlightLogin.find('.close-icon').on('click', function() {
                $highlightLogin.remove();

                $.cookie('CB-headerHighlightLoginClosed', 'true', {
                    path: '/',
                    expires: 1 / 24, // setting the cookie for an hour
                    secure: location.protocol === 'https:'
                });
            });
        });
    </script>
</div>
