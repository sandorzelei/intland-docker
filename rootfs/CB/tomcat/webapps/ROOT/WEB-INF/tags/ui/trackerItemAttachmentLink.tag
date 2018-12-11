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
<%@tag import="com.intland.codebeamer.servlet.docs.DisplayDocument"%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%--
	Tag renders a html link to an TrackerItem/Artifact as attachment opens in a popup
	Can render a TrackerItemAttachmentRevision.
--%>
<%@ attribute name="trackerItemAttachment" type="com.intland.codebeamer.persistence.util.TrackerItemAttachmentRevision"
	required="true" %>
<%@ attribute name="revision" description="The revision override (for example a baseline.id)" %>
<%@ attribute name="cssClass" required="false"
	description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false"
	description="CSS style attribute" %>
<%@ attribute name="newskin" description="if the page has been facelifted or not" %>

<c:set var="file" value="${trackerItemAttachment}"/>
<tag:mimeLinkTarget var="target" value="${file.dto.name}" />
<tag:mimeIcon var="mimeIcon" value="${file.dto.name}" newskin="${newskin}" />

<c:set var="backgroundStyle" value=""/>
<c:if test="${newskin}">
	<c:set var="bgColor">
		<%= com.intland.codebeamer.ui.view.ColoredEntityIconProvider.freshColor %>
	</c:set>
	<c:set var="backgroundStyle" value="background-color:${bgColor}"/>
</c:if>

<c:url var="click_url" value="<%=DisplayDocument.getDownloadUrl(trackerItemAttachment, revision)%>" >
   <c:param name="raw" value="true"/>
</c:url>
<c:set var="onclick" value="launch_url('${click_url}');return false;" />

<c:set var="attachmentLength" value="${file.dto.fileSize}" />
<fmt:formatNumber var="formattedAttLength" value="${attachmentLength}" />
<c:set var="titleLengthValue" value="${formattedAttLength} bytes" />

<a href="<c:out value="${click_url}" />" class="attachmentFile ${cssClass}" style="${cssStyle}"
		<c:if test="${target != '_top'}">
			target="<c:out value="${target}" />"
			onclick="<c:out value="${onclick}" />"
		</c:if>
		title="${titleLengthValue}"
	><img src="<c:url value="${mimeIcon}" />" border="0" width="16" height="16" style="${backgroundStyle}"><c:out value="${file.dto.name}" /></a>
