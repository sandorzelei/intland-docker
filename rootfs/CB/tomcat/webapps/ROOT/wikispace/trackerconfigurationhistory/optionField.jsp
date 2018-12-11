<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<div class="list">
	<spring:message code="tracker.reference.choose.static" text="Options" />:
	<div style="margin-left: 15px;">
		<c:choose>
			<c:when test="${fieldConfig['fieldOptions']['options'] != null && fn:length(fieldConfig['fieldOptions']['options']) > 0}">
				<c:forEach var="options" items="${fieldConfig['fieldOptions']['options']}">
					<div style="display:list-item; margin-left: 15px;">
						<c:out value="${options['name']}" />
					</div>
				</c:forEach>
			</c:when>
			<c:otherwise>
				<c:out value="--" />
			</c:otherwise>
		</c:choose>
	</div>
</div>