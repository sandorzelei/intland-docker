<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>



<c:if test="${isExportMode}"><br><b>${tabTitle}</b><br></c:if>

<div class="tracker-history-action-bar"><spring:message code="tracker.configuration.history.plugin.permissions.hint" /></div>
<c:forEach var="role" items="${mapEntry.value.permissions}">
    <b>${role.key.name} <spring:message code="role.label" text="Role" /></b>
    <ul>
        <c:forEach var="privilege" items="${role.value}">
            <spring:message var="privilegeLabel" code="permission.${privilege}.label" />
            <spring:message var="privilegeTooltip" code="permission.${privilege}.tooltip" />
            <li title="${privilegeTooltip}">${privilegeLabel}</li>
        </c:forEach>
    </ul>
</c:forEach>
