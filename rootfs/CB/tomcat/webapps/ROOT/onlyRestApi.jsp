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
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="login"/>
<meta name="bodyCSSClass" content="newskin"/>

<title><spring:message code="not.found.title" text="Allow only Rest Requests"/></title>

<div class="contentWithMargins not-found-content">
    <div class="not-found-header"><spring:message code="only.rest.header" text="You can access to codeBeamer only via Rest-Api"/></div>
    <div class="not-found-explanation"><spring:message code="only.rest.message" text="One of your User Group has 'Allow only Rest Requests' permission so you can access codeBeamer only via Rest-Api."/></div>
</div>

