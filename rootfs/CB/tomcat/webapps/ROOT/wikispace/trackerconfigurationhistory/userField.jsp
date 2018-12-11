<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<div class="list">
	<div style="display:list-item; margin-left: 15px;">
		<label title="<spring:message code='tracker.reference.choose.users.groups.tooltip' text='If groups are selected, only members of these groups are included' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.users.groups.label" text="in Group" javaScriptEscape="true"/>:
		</label>
		<div class="projectQualifiers userGroups">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['groups'] != null}">
					<c:forEach var="group" items="${fieldConfig['fieldReferences']['groups']}">
						<div class="projectQualifier userGroup" style="display:list-item; margin-left: 10px;">
							<label title="${group['title']}">
								<b>${group['name']}</b>
							</label>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<label>
							<spring:message code="tracker.reference.choose.users.groups.any" text="Any" javaScriptEscape="true"/>
						</label>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
	<div style="margin-top: 10px; display:list-item; margin-left: 15px;">
		<label title="<spring:message code='tracker.reference.choose.users.permissions.tooltip' text='If permissions are selected, only users are included where the user has at least one of the specified permissions' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.users.permissions.label" text="with Permission" javaScriptEscape="true"/>:
		</label>
		<div class="permissions">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['permissions'] != null}">
					<c:forEach var="permission" items="${fieldConfig['fieldReferences']['permissions']}">
						<div class="permission" style="display:list-item; margin-left: 10px;">
							<label title="${permission['title']}">
								<b>${permission['name']}</b>
							</label>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<spring:message code="tracker.reference.choose.users.permissions.any" text="Any" javaScriptEscape="true"/>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
	<div style="margin-top: 10px; display:list-item; margin-left: 15px;">
		<label title="<spring:message code='tracker.reference.choose.users.members.tooltip' text='If projects members are selected, those are included whether or not they are member of the specified groups' javaScriptEscape='true'/>">
			<spring:message code="tracker.reference.choose.users.members.label" text="member of" javaScriptEscape="true"/>
		</label>
		<div class="projects">
			<c:choose>
				<c:when test="${fieldConfig['fieldReferences']['projects'] != null}">
					<c:forEach var="project" items="${fieldConfig['fieldReferences']['projects']}">
						<div class="project" style="display:list-item; margin-left: 10px;">
							<spring:message code="tracker.reference.choose.trackers.projects.label" text="in Project" javaScriptEscape="true"/>
							<label>
								<b>${project['name']}</b>
							</label>
							<div>
								<div style="display:list-item; margin-left: 10px;">
									<label title="<spring:message code='tracker.reference.choose.members.roles.tooltip' text='If roles are selected, only members in these roles are included' javaScriptEscape='true'/>">
										<spring:message code="tracker.reference.choose.members.roles.label" text="in Role" javaScriptEscape="true"/>:
									</label>
									<div class="projectQualifiers projectRoles">
										<c:choose>
											<c:when test="${project['roles'] != null}">
												<c:forEach var="role" items="${project['roles']}">
													<c:if test="${role['selected'] != null && role['selected']}">
														<div class="projectQualifier projectRole" style="display:list-item; margin-left: 10px;">
															<label title="${role['description']}">
																<b>${role['name']}</b>
															</label>
														</div>
													</c:if>
												</c:forEach>
											</c:when>
											<c:otherwise>
												<div>
													<spring:message code="tracker.reference.choose.users.groups.any" text="Any" javaScriptEscape="true"/>
												</div>
											</c:otherwise>
										</c:choose>
									</div>
								</div>
								<div style="display:list-item; margin-left: 10px; margin-top: 10px;">
									<label title="<spring:message code='tracker.reference.choose.members.permissions.tooltip' text='If permissions are selected, all members with any of these permissions are selected, independent of the role' javaScriptEscape='true'/>">
										<spring:message code="tracker.reference.choose.members.permissions.label"	text="with Permission" javaScriptEscape="true"/>:
									</label>
									<div class="permissions">
										<c:choose>
											<c:when test="${project['permissions'] != null}">
												<c:forEach var="permission" items="${project['permissions']}">
												<div class="permission" style="display:list-item; margin-left: 10px;">
													<label title="${permission['title']}">
														<b>${permission['name']}</b>
													</label>
												</div>
											</c:forEach>
										</c:when>
										<c:otherwise>
											<label>
												<spring:message code="tracker.reference.choose.users.permissions.any" text="Any" javaScriptEscape="true"/>
											</label>
										</c:otherwise>
									</c:choose>
									</div>
								</div>
							</div>
						</div>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div>
						<spring:message code="tracker.reference.choose.users.members.none" text="None" javaScriptEscape="true"/>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>