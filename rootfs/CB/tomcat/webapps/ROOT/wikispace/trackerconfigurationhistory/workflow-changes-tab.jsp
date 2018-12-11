<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:if test="${isExportMode}"><br><b>${tabTitle}</b><br></c:if>

<table class="tracker-history-entries"${tableStyle}>
    <thead>
        <tr>
            <th></th>
            <th><spring:message code="tracker.configuration.history.plugin.name.label" text="Name" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.action.label" text="Action" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.new.value.label" text="New value" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.old.value.label" text="Old value" /></th>
        </tr>
    </thead>
    <c:forEach var="auditEntry" items="${mapEntry.value.workflowChanges}">
        <c:if test="${not auditEntry.baselineEntry}">
            <c:forEach var="change" items="${auditEntry.configurationChanges}" varStatus="loop">
                <tr>
                    <c:if test="${loop.count eq 1}">
                        <td class="user-photo-cell" rowspan="${fn:length(auditEntry.configurationChanges)}">
                            <div class="user-photo"${displayNoneStyle}><ui:userPhoto userId="${auditEntry.user.id}" userName="${auditEntry.user.name}" url="/userdata/${auditEntry.user.id}"></ui:userPhoto></div>
                            <div>
                                <a href="${pageContext.request.contextPath}/userdata/${auditEntry.user.id}">${auditEntry.user.name}</a>
                                <div><tag:formatDate value="${auditEntry.date}" /></div>
                            </div>
                        </td>
                    </c:if>
                    <td>${auditEntry.transitionName}</td>
                    <td>
                        <spring:message code="tracker.configuration.history.${change.action}.label" />
                        <c:if test="${auditEntry.inheritedEntry}"><span class="inherited-change">(inherited)</span></c:if>
                    </td>
                    <td>${ui:getStringWithDefaultValue(change.newValue, '--')}</td>
                    <td>${ui:getStringWithDefaultValue(change.oldValue, '--')}</td>
                </tr>
            </c:forEach>
        </c:if>
        <c:set var="auditEntry" value="${auditEntry}" scope="request"/>
        <jsp:include page="audit-baseline-row.jsp">
            <jsp:param value="5" name="columnCount" />
        </jsp:include>
    </c:forEach>
</table>
