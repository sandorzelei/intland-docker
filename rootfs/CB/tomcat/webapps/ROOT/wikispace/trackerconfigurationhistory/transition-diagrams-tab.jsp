<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag" %>

<c:if test="${isExportMode}"><br><b>${tabTitle}</b><br></c:if>

<c:if test="${not isExportMode}">
    <div class="accordion transition-diagrams-accordion">
        <c:forEach var="entry" items="${diagramEntries}">
            <h3 class="accordion-header transition-diagram-header" data-tracker-id="${trackerId}" data-revision="${entry.id}">
                ${entry.baselineName}
                <span class="modified-by-info">
                   <spring:message code="tracker.configuration.history.plugin.created.at.label" text="created at" /> <b><tag:formatDate value="${entry.date}" /></b>
                </span>
            </h3>
            <div class="accordion-content">
            </div>
        </c:forEach>
    </div>
</c:if>

<c:if test="${isExportMode}">
    <c:forEach var="entry" items="${diagramEntries}">
        <div>
	        <p>
	            ${entry.baselineName} <spring:message code="tracker.configuration.history.plugin.created.at.label" text="created at" /> <b><tag:formatDate value="${entry.date}" /></b>
	        </p>
	        ${mapEntry.value.transitionDiagrams[entry.id]}
        </div>
    </c:forEach>
</c:if>