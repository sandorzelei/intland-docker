<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%--
  ~ Copyright by Intland Software
  ~
  ~ All rights reserved.
  ~
  ~ This software is the confidential and proprietary information
  ~ of Intland Software. ("Confidential Information"). You
  ~ shall not disclose such Confidential Information and shall use
  ~ it only in accordance with the terms of the license agreement
  ~ you entered into with Intland.
  --%>

<c:if test="${fn:length(mapEntry.value.events) == 0}">
    <spring:message code="table.nothing.found" text="No data to display." />
</c:if>
<c:if test="${fn:length(mapEntry.value.events) > 0}">
    <c:if test="${isExportMode}"><br><b>${tabTitle}</b><br></c:if>
    <table class="tracker-history-entries"${tableStyle}>
        <thead>
            <tr>
                <th><spring:message code="audit.trail.event.delete.items.createdAt.label" text="Created at" /></th>
                <th><spring:message code="audit.trail.event.delete.items.createdBy.label" text="Created by" /></th>
                <th><spring:message code="audit.trail.event.delete.items.event.label" text="Event" /></th>
                <th><spring:message code="audit.trail.event.delete.items.details.label" text="Details" /></th>
            </tr>
        </thead>
        <c:forEach var="auditEntry" items="${mapEntry.value.events}">
            <tr>
                <td>
                    <tag:formatDate value="${auditEntry.createdAt}" />
                </td>
                <td class="user-photo-cell">
                    <div class="user-photo"${displayNoneStyle}><ui:userPhoto userId="${auditEntry.user.id}" userName="${auditEntry.user.name}" url="/userdata/${auditEntry.user.id}"></ui:userPhoto></div>
                    <div>
                        <a href="${pageContext.request.contextPath}/userdata/${auditEntry.user.id}">${auditEntry.user.name}</a>
                    </div>
                </td>
                <td><spring:message code="audit.trail.event.${auditEntry.eventTypeName}.event" /></td>
                <td>${ui:getStringWithDefaultValue(auditEntry.details, '--')}</td>
            </tr>
        </c:forEach>
    </table>
</c:if>
