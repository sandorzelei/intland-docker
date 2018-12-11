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
<%@page import="com.intland.codebeamer.license.VersionMetas.VersionMeta"%>
<%@page import="com.intland.codebeamer.license.VersionMetas"%>
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@page import="com.intland.codebeamer.utils.SystemInfoUtils" %>
<%@page import="com.intland.codebeamer.Config" %>
<%@page import="com.intland.codebeamer.persistence.dto.UserDto" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<c:catch>

<!-- Don't modify, change or delete this file without a written permission from Intland Software. -->
<c:choose>
	<c:when test="${fn:contains(licenseCode.type, 'Participate')}">
		<c:set var="productName" value="participate" />
		<spring:message var="productUrl" code="cb.participate.url" text="https://intland.com/codebeamer/product-overview/"/>
	</c:when>
	<c:otherwise>
		<c:set var="productName" value="codeBeamer" />
		<spring:message var="productUrl" code="cb.codeBeamer.url" text="https://intland.com/codebeamer/product-overview/"/>
	</c:otherwise>
</c:choose>

<c:set var="aboutUrl" value="${productUrl}"/>
<c:set var="companyName" value="${licenseCode.companyName}" />

<acl:isUserInRole value="system_admin">
	<c:url var="aboutUrl" value="/about.do" />
</acl:isUserInRole>

<div id="footer" class="noPrint" <c:if test="${! applyLayout}"> style="visibility: hidden;" </c:if> >
	<%
		VersionMeta versionMeta = ControllerUtils.getSpringBean(request, VersionMetas.class).getCurrentVersionsMeta();
		String fullVersion = "";
		if (versionMeta != null && versionMeta.isFull()) {
			fullVersion = " (full)";
		}
		pageContext.setAttribute("fullVersion", fullVersion);

		pageContext.setAttribute("memory", SystemInfoUtils.getMemoryInfoString());

		pageContext.setAttribute("diskSpace", SystemInfoUtils.getUsableSpace());

	%>
	<spring:message code="cb.${productName}.powered" arguments="${aboutUrl},${applicationScope.CB_VERSION}${fullVersion},${applicationScope.DB_PROVIDER_NAME}"/> |
	<%
		String remoteUrl = Config.getInstallation().getLicenseGenerationUrl();
		pageContext.setAttribute("remoteUrl", remoteUrl);

		UserDto user = ControllerUtils.getCurrentUser(request);
		if (user == null) {
			String url = request.getRequestURL().toString();
			if (url != null && remoteUrl != null && url.startsWith(remoteUrl)) {
				pageContext.setAttribute("showOldReportIssueLink", Boolean.TRUE);
			}
		}

		if (Config.getInstallation().isDisableRemoteIssueReportUrl()) {
			pageContext.setAttribute("showOldReportIssueLink", Boolean.TRUE);
		}
	%>
	<c:set var="currentUrl">${pageContext.request.requestURI}${not empty pageContext.request.queryString ? '?' : ''}${pageContext.request.queryString}</c:set>
	<c:set var="knowledgeBaseUrl" value="${ui:getKnowledgeBaseUrl(currentUrl, requestScope.functionalityForKnowledgeBaseLink)}" />
	<c:choose>
		<c:when test="${applicationScope.freeLicense || showOldReportIssueLink}">
			<spring:message code="cb.support.info.free" arguments="${knowledgeBaseUrl}"/>
		</c:when>
		<c:otherwise>
			<c:set var="remoteIssueUrl" value="${remoteUrl}/remote/issue/create.spr?${applicationScope.SUPPORT_URL_PARAMS}&memory=${memory}&diskSpace=${diskSpace}"></c:set>
			<spring:message code="cb.support.info.standard"
			argumentSeparator="##" arguments="${remoteIssueUrl}##javascript:showPopupInline('${remoteIssueUrl}', {'geometry':'large', hideMinifyDialogLink : true}); return false;##${knowledgeBaseUrl}"/>
		</c:otherwise>
	</c:choose>
	<spring:message code="testrunner.hotkeys.hint" var="hotkeysTitle" text="Show keyboard hotkeys"/>
	| <a onclick="toggleHotkeys();" title="${hotkeysTitle }" id="hotkey-toggle">
		<c:url value="/images/newskin/hotkeys.png" var="imgUrl"/>
		<img src="${imgUrl }"/>
		<spring:message code="testrunner.hotkeys.title" text="Hotkeys"/>
	</a>
	<c:if test="${companyName != null}">
		|
		<div style="display: inline-block;"><spring:message code="cb.licensed.by"/></div>
		<div style="display: inline-block; font-weight: bold;">${companyName}</div>
	</c:if>
</div>

<c:if test="${! applyLayout}">
	<script type="text/javascript">
		$(setupStickFooterToBottom);
	</script>
</c:if>

	<script type="text/javascript">
		// listens for messages from cross-domain iframes
		$(window).bind("message", function(e, m) {
			var data = e.originalEvent.data
			if (data == "closePopup") {
				inlinePopup.close();
			}
		});
	</script>

</c:catch>

