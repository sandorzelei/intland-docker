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
 *
 * $Revision$ $Date$
--%><%-- DO NOT PUT anything before this, because IE6 will otherwise switch to QUIRKS mode! --%><%=com.intland.codebeamer.servlet.IWebConstants.HTML_DOCTYPE%>
<%-- Useful with Html-Checker.
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
--%>

<%--
	This decorator adds the header and the footer. To add additional content use <content tag="north">...</content> in the
	decorated page. Possible values for tag: north, center, south.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="taglib" %>
<%@ page import="com.intland.codebeamer.utils.CookieUtils"%>
<%@ page import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.EntityCache"%>
<%@ page import="com.intland.codebeamer.controller.support.UserAgent"%>
<%@ page import="com.intland.codebeamer.Config"%>
<%@ page import="com.intland.codebeamer.controller.usersettings.UserSettingSupport"%>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />
<ui:UserSetting var="doubleClickEditOnDocView" setting="DOUBLE_CLICK_EDIT_ON_DOC_VIEW" defaultValue="false" />
<ui:UserSetting var="doubleClickEditOnWikiSection" setting="DOUBLE_CLICK_EDIT_ON_WIKI_SECTION" defaultValue="false" />

<html>
<head>
	<%@include file="includes/userAgentCSS.jsp" %>
	<%@include file="includes/moduleDefaults.jsp" %>

	<c:set var="stylesheet"><decorator:getProperty property="meta.stylesheet" default="${moduleDefaults.stylesheet}"/></c:set>
	<c:set var="hideToolBar"><decorator:getProperty property="meta.hideToolBar" default="false" /></c:set>

	<%@include file="includes/title.jsp" %>
	<%@include file="includes/htmlHeader.jsp" %>

<c:if test="${!empty stylesheet}">
	<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/${stylesheet}" />" type="text/css"/>
</c:if>
	<c:set var="applyLayout" scope="request"><decorator:getProperty property="meta.applyLayout" default="false" /></c:set>

	<spring:message var="buttonTitle" code="button.toggle.toolbar" text="Toggle toolbar"/>
	<spring:message var="searchHint" code="search.hint" text="Search..."/>
	<script type="text/javascript">
		$(document).ready(function () {
			layoutScripts.init(${applyLayout == "true"}, '${buttonTitle}', '${searchHint}');
			// handling ajax authorization errors
			$(document).ajaxError(ajaxErrorHandler);
		});
	</script>
	<%
		// check if header is collapsed. related to layoutScripts javascript
		String headerHiddenCookie = CookieUtils.getCookieValue(request, "CB-headerHidden");
		boolean headerHidden = "true".equals(headerHiddenCookie);
		pageContext.setAttribute("headerHidden", Boolean.valueOf(headerHidden));

        // check if header login highlight is closed
        String headerHighlightLoginCookie = CookieUtils.getCookieValue(request, "CB-headerHighlightLoginClosed");
        boolean headerHighlightLoginClosed = "true".equals(headerHighlightLoginCookie);
        pageContext.setAttribute("headerHighlightLoginClosed", Boolean.valueOf(headerHighlightLoginClosed));
	%>

	<%
		// the current project is used when binding the global hotkeys
		ProjectDto project = ControllerUtils.getCurrentProject(request);
		pageContext.setAttribute("project", project);
	    UserDto currentUser = ControllerUtils.getCurrentUser(request);
		if (project != null) {
			boolean isProjectAdmin = EntityCache.getInstance(currentUser).isProjectAdmin(project.getId());
			pageContext.setAttribute("isProjectAdmin", isProjectAdmin);
		}
		
		if (currentUser != null) {
		    pageContext.setAttribute("isAnonymousUser", Boolean.valueOf(Config.isAnonymousUser(currentUser)));
		}
		String newWindowTarget = UserSettingSupport.getNewBrowserWindowTarget(currentUser);
	%>
	<script type="text/javascript">
		var hotkeysConfig = {
			'subjectId': ${project != null ? project.id : 'null'}
		};

		if ("${isProjectAdmin}" == "false") {
			hotkeysConfig.disabledModules = ["admin"];
		}

		var codebeamerHotkeys = new codebeamer.Hotkeys(hotkeysConfig);

		// initialize the form related hotkeys as well
		new codebeamer.FormHotkeys();
		// used to render correct toolbar menu -> BUG-790444
		codebeamer.projectId = '<%= project != null ? project.getId() : "" %>';
		
		codebeamer.userPreferences = {
			newWindowTarget: '<%= newWindowTarget %>',
			alwaysDisplayContextMenuIcons: '${alwaysDisplayContextMenuIcons}' == 'true',
			doubleClickEditOnDocView: '${doubleClickEditOnDocView}' == 'true',
			doubleClickEditOnWikiSection: '${doubleClickEditOnWikiSection}' == 'true'
		};
		// turning off propagate dependencies configuration on tracker level
		codebeamer.hidePropagateDependenciesOnTrackerLevel = true;
	</script>
</head>
<c:set var="northContent"><decorator:getProperty property="page.north"/></c:set>
<c:set var="centerContent"><decorator:getProperty property="page.center"/></c:set>
<c:set var="southContent"><decorator:getProperty property="page.south"/></c:set>
<ui:isMac var="isMac" />

<body class="${userAgentClass} ${isMac ? 'Mac ' : ''}yui-skin-cb ${moduleCSSClass} ${headerHidden? 'headerCollapsed' :''} ${developmentMode ? 'DEVELOPMENTMODE' : ''}" bgcolor="white" link="#000000" vlink="#000000" alink="#000000" topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<c:choose>
	<c:when test="${taglib:isIeStrictMode() and (userAgent.ie gt 0) and (userAgent.ie lt 11)}">
		<ui:message type="warning" isSingleMessage="true" style="padding-top: 0px; padding-left: 30px;">
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
		</ui:message>
	</c:when>
	<c:otherwise>
		<spring:message code="testrunner.hotkeys.hint" var="hotkeysHintText" text="Show keyboard hotkeys"/>
		<div id="hotkeysHint" class="hint" onclick="toggleHotkeys(); return false;" title="${hotkeysHintText}" style="display:none;">
			<table>

			</table>
		</div>

		<c:set var="isServiceDeskMode" value="${false}" />
		<ui:detectServiceDeskUser var="isServiceDeskMode" />

		<div class="ui-layout-north ${isServiceDeskMode ? "service-desk-mode" : ""  }" style="overflow:hidden;border:0;" id="northPane">
			<div id="headerPane">
                <c:set var="isHighlightLogin" value="${isAnonymousUser && !isLoginView}" scope="request" />

                <c:if test="${requestScope.isHighlightLogin && !headerHighlightLoginClosed}">
                    <%@ include file="includes/headerHighlightLogin.jsp" %>
                </c:if>
                <%@ include file="includes/header.jsp" %>
			</div>
		<c:if test="${! hideToolBar}">

			<c:choose>
				<c:when test="${isServiceDeskMode == false}">
					<div id="toolmenuContainer">
						<%@ include file="includes/toolmenu.jsp" %>
					</div>
				</c:when>
			</c:choose>

			<%-- if you want to add content here use <content tag="north">...</content> in the decorated page --%>
			<c:if test="${!empty northContent}">
				${northContent}
			</c:if>
		</c:if>
		</div>

		<div class="ui-layout-center" style="border:0;">
			<div class="contentArea">
				<c:set var="showGlobalMessages"><decorator:getProperty property="meta.showGlobalMessages" default="true" /></c:set>
				<c:if test="${showGlobalMessages}"><ui:globalMessages/></c:if>
				<%-- if you want to add content here use <content tag="center">...</content> in the decorated page --%>
				<c:choose>
					<c:when test="${!empty centerContent}">
						${centerContent}
					</c:when>
					<c:otherwise>
						<decorator:body />
					</c:otherwise>
				</c:choose>
			</div>
		</div>
		<div class="ui-layout-south" style="border:0;overflow:hidden;">
			<%-- if you want to add content here use <content tag="south">...</content> in the decorated page --%>
			<c:if test="${!empty southContent}">
				${southContent}
			</c:if>

			<%@ include file="includes/footer.jsp" %>
		</div>

		<%@include file="includes/cookieBar.jsp" %>

		<c:catch>
			<ui:delayedScript flush="true" />
		</c:catch>
		<%--
			<jsp:include page="includes/perftestEnd.jsp" />
		--%>
	</c:otherwise>
</c:choose>
</body>
</html>
