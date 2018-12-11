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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<div class="exportInformation">
	<c:choose>
		<c:when test="${!empty command.selectedIssues}">
			<c:set var="childrenCheckbox"><label style="font-weight: bold;" for="exportChildren"><form:checkbox id="exportChildren" path="exportChildren"/>	</c:set>
			<spring:message code="tracker.issues.exportToWord.exporting.selected.issues.explanation"
				arguments="<b>${fn:length(command.selectedIssues)}</b>|${childrenCheckbox}"
				argumentSeparator="|" />.</label>
		</c:when>
		<c:otherwise>

			<c:set var="viewInfoPart">
				<c:choose>
					<c:when test="${!empty command.cbQLViewName}">
						<c:set var="localizedCbQLViewName">
							<spring:message code="tracker.view.${command.cbQLViewName}.label" text="${command.cbQLViewName}"></spring:message>
						</c:set>
						<spring:message code="tracker.issues.exportToWord.exporting.tracker.explanation.view.from" arguments="${localizedCbQLViewName}"/>
					</c:when>
					<c:otherwise>
						<c:if test="${! empty command.view}">
							<c:set var="viewName"><b><spring:message code="tracker.view.${command.view.name}" text="${command.view.name}" htmlEscape="true" /></b></c:set>
							<spring:message code="tracker.issues.exportToWord.exporting.tracker.explanation.view" arguments="${viewName}" argumentSeparator="|" />
						</c:if>
					</c:otherwise>
				</c:choose>
			</c:set>

			<c:choose>
				<c:when test="${! empty command.filterPattern}">
					<spring:message code="tracker.issues.exportToWord.exporting.tracker.explanation.tracker"
						arguments="<b>${fn:length(command.requirements)}</b>|<b>${command.tracker.name}</b>" argumentSeparator="|" />
					${viewInfoPart}
					<spring:message code="tracker.issues.exportToWord.exporting.tracker.explanation.filterPattern"/> "<b><c:out value="${command.filterPattern}"/></b>."
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.issues.exportToWord.exporting.tracker.explanation.tracker"
						arguments="<b>${fn:length(command.requirements)}</b>|<b>${command.tracker.name}</b>" argumentSeparator="|" />
					${viewInfoPart}.
				</c:otherwise>
			</c:choose>

		</c:otherwise>
	</c:choose>
	<p/>
</div>
