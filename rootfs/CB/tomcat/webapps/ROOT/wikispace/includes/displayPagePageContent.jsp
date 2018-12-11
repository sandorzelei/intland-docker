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

<c:set var="viewAsMarkup" value="${displayFormat eq 'W'}"/>
<div class="wikiPageContent">
	<c:if test="${!wikiPage.trackerHomePage}">
		<jsp:include page="../../label/entityLabelList.jsp">
			<jsp:param name="entityTypeId" value="${GROUP_OBJECT}"/>
			<jsp:param name="entityId" value="${wikiPage.id}"/>
			<jsp:param name="forwardUrl" value="${wikiPage.urlLink}"/>
			<jsp:param name="editable" value="${empty pageRevision.baseline}"/>
		</jsp:include>
	</c:if>
	<%-- do not change element id="pagecontent" as JSPWiki javascript functions rely on using this ID --%>
	<div id="pagecontent" class="thumbnailImages">
		<c:choose>
			<c:when test="${viewAsMarkup}">
				<pre><c:out value="${pageContent}" escapeXml="true"/></pre>
			</c:when>
			<c:otherwise><c:out value="${pageContent}" escapeXml="false"/></c:otherwise>
		</c:choose>
	</div>
</div>
