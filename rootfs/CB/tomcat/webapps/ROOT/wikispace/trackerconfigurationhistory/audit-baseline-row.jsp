<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:if test="${auditEntry.baselineEntry}">
	<c:url var="wikiHomepageURL" value="/proj/wiki/displayWikiPageRevision.spr">
		<c:param name="doc_id"   value="${project.wikiHomepageId}"/>
		<c:param name="revision" value="${auditEntry.id}"/>
	</c:url>
    <tr>
        <td class="user-photo-cell baseline-row"${baselineRowStyle} colspan="${param.columnCount}">
            <c:if test="${not isExportMode}">
		        <div class="user-photo"><ui:userPhoto userId="${auditEntry.user.id}" userName="${auditEntry.user.name}" url="/userdata/${auditEntry.user.id}"></ui:userPhoto></div>
		        <div>
		            <a href="${pageContext.request.contextPath}/userdata/${auditEntry.user.id}">${auditEntry.user.name}</a>
		            <div><tag:formatDate value="${auditEntry.date}" /></div>
		        </div>
	            <div class="baseline-label-wrapper">
	                <img class="info-image" src="${pageContext.request.contextPath}/images/newskin/message/info-stripes.png" />
	                <a href="${wikiHomepageURL}">${auditEntry.baselineName}</a>
	                <spring:message code="tracker.configuration.history.plugin.baseline.created.label" text="baseline"/>
	            </div>
            </c:if>
            <c:if test="${isExportMode}">
                <a href="${pageContext.request.contextPath}/userdata/${auditEntry.user.id}">${auditEntry.user.name}</a>
                <tag:formatDate value="${auditEntry.date}" />&nbsp;&nbsp;
                <img class="info-image" src="${pageContext.request.contextPath}/images/newskin/message/info-stripes.png" />&nbsp;
                <a href="${wikiHomepageURL}">${auditEntry.baselineName}</a>
                <spring:message code="tracker.configuration.history.plugin.baseline.created.label" text="baseline"/>
            </c:if>
        </td>
    </tr>
</c:if>
