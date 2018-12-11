<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<div class="list">
	<div style="display:list-item; margin-left: 15px;">
		<label title="<spring:message code='tracker.reference.choose.projects.qualifiers.tooltip' text='If categories are selected, only projects with these categories are included' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.projects.qualifiers.label" text="of Category" javaScriptEscape="true"/>:
		</label>
		<div class="projectQualifiers">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['qualifiers'] != null}">
					<c:forEach var="qualifier" items="${fieldConfig['fieldReferences']['qualifiers']}">
						<div class="projectQualifier" style="display:list-item; margin-left: 10px;">
							<label>
								<b>${qualifier['label']}</b>
							</label>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<spring:message code="tracker.reference.choose.projects.qualifiers.any" text="Any" javaScriptEscape="true"/>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
	<div style="display:list-item; margin-left: 15px; margin-top: 10px;">
		<label title="<spring:message code='tracker.reference.choose.projects.permissions.tooltip' text='If permissions are selected, only projects are included where the user has at least one of the specified permissions' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.projects.permissions.label" text="with Permission" javaScriptEscape="true"/>:
		</label>
		<div class="permissions">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['permissions'] != null}">
					<c:forEach var="permission" items="${fieldConfig['fieldReferences']['permissions']}">
						<div class="permission" style="display:list-item; margin-left: 10px;">
							<label title="${permission.title}">
								<b>${permission.name}</b>
							</label>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<spring:message code="tracker.reference.choose.projects.permissions.any" 	text="Any" 		javaScriptEscape="true"/>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
	<div style="display:list-item; margin-left: 15px; margin-top: 10px;">
		<label title="<spring:message code='tracker.reference.choose.projects.individual.tooltip' text='If individual projects are selected, those are included, whether or not the category or permission matches.' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.projects.individual.label" text="and explicitly" javaScriptEscape="true"/>:
		</label>
		<div class="projects">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['projects'] != null}">
					<c:forEach var="project" items="${fieldConfig['fieldReferences']['projects']}">
						<div class="project" style="display:list-item; margin-left: 10px;">
							<label>
								<b>${project['name']}</b>
							</label>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<spring:message code="tracker.reference.choose.projects.individual.none" text="None" javaScriptEscape="true"/>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>