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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ tag import="com.intland.codebeamer.controller.usersettings.UserSetting"%>
<%@ tag import="com.intland.codebeamer.Config"%>

<%
jspContext.setAttribute("defaultMode", com.intland.codebeamer.Config.getWikiStyleConfig().getDefaultMode());
%>

<c:if test="${mode != 'wysiwyg' && mode != 'markup' && mode != 'preview'}">
    <ui:UserSetting setting="PREFERRED_EDITOR_MODE" var="mode" />
</c:if>

<c:if test="${mode != 'wysiwyg' && mode != 'markup' && mode != 'preview'}">
    <c:set var="mode" value="${defaultMode}" />
</c:if>

<ui:UserSetting setting="WYSIWYG_PASTE_AS_TEXT" var="pasteAsText" />

<div id="froalaOptions" data-mode="${mode}" data-pasteplain="${pasteAsText}"></div>