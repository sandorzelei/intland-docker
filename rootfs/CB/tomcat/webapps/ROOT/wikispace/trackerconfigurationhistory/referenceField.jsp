<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<div class="projects list">
	<c:choose>
		<c:when test="${fieldConfig['fieldReferences'] != null && fn:length(fieldConfig['fieldReferences']) > 0}">
			<c:forEach var="project" items="${fieldConfig['fieldReferences']}">
				<div class="project" style="display:list-item; margin-left: 15px;">
					<spring:message code="tracker.reference.choose.trackers.projects.label" text="in Project" javaScriptEscape="true"/>
					<label><b>${project['name']}</b></label>
					<div class="components" style="display:list-item; margin-left: 10px;">
                        <c:if test="${(project['types'] != null && fn:length(project['types']) > 0) || (project['permissions'] != null && fn:length(project['permissions']) > 0)}">
							<div class="component allItems">
								<c:choose>
									<c:when test="${fieldConfig['refType'] == 9}">
			   							<c:if test="${project['flags'] != null}">
			   								<label title="<spring:message code='tracker.reference.choose.items.allOf.title' text='If at least one type and/or permission is selected, all Tracker/CMDB items in this project with any of these types/permissions are included.' javaScriptEscape='true'/>">
			   									<spring:message code="tracker.reference.choose.items.allOf.label" text="all Tracker/CMDB items" javaScriptEscape="true"/>
			   								</label>
			   								<spring:message code="issue.references.status.label" text="with status" javaScriptEscape="true"/>: ${project['flags']['name']}
			    						</c:if>
									</c:when>
									<c:when test="${fieldConfig['refType'] == 18}">
										<label title="<spring:message code='tracker.reference.choose.repositories.allOf.title' text='If at least one type and/or permission is selected, all repositories in this project with any of these types/permissions are included.' javaScriptEscape='true'/>">
											<b><spring:message code="tracker.reference.choose.repositories.allOf.label" text="all Repositories" javaScriptEscape="true"/></b>
										</label>
									</c:when>
									<c:otherwise>
										<label title="<spring:message code='tracker.reference.choose.trackers.allOf.title' text='If at least one type and/or permission is selected, all Trackers/CMDB Categories in this project with any of these types/permissions are included.' javaScriptEscape='true'/>">
											<b><spring:message code="tracker.reference.choose.trackers.allOf.label" text="all Trackers/CMDB Categories" javaScriptEscape="true"/></b>
										</label>
									</c:otherwise>
								</c:choose>
								<div class="allTrackerItems">
									<c:if test="${project['types'] != null && fn:length(project['types']) > 0}">
										<div class="component allOfType" style="display:list-item; margin-left: 10px;">
											<label title="<spring:message code='tracker.reference.choose.items.types.tooltip' text='If types are selected, all Tracker/CMDB items of this type in this project are included.' javaScriptEscape='true'/>">
												<spring:message code="tracker.reference.choose.items.types.label" text="of type" javaScriptEscape="true"/>
											</label>
									<div class="trackerTypes">
										<c:forEach var="tracker" items="${project['types']}">
											<div class="trackerType" style="display:list-item; margin-left: 10px;list-style-type: circle;">
												<label><b>${tracker['name']}</b></label>
											</div>
										</c:forEach>
									</div>
										</div>
									</c:if>
									<c:if test="${project['permissions'] != null && fn:length(project['permissions']) > 0}">
										<div class="component allWithPermission" style="margin-top: 10px;">
											<c:choose>
									<c:when test="${fieldConfig['refType'] == 9}">
		 								<label title="<spring:message code='tracker.reference.choose.items.permissions.tooltip' text='If permission are selected, all Tracker/CMDB items with any of these permissions are included.' javaScriptEscape='true'/>">
	                                        <b><spring:message code="tracker.reference.choose.projects.permissions.label" text="with Permission" javaScriptEscape="true"/>:</b>
		 								</label>
									</c:when>
									<c:when test="${fieldConfig['refType'] == 18}">
		 								<label title="<spring:message code='tracker.reference.choose.repositories.permissions.tooltip' text='If permissions are selected, all SCM repositories in this project are included, where the user has at least one of the specified permissions.' javaScriptEscape='true'/>">
											<b><spring:message code="tracker.reference.choose.projects.permissions.label" text="with Permission" javaScriptEscape="true"/>:</b>
		 								</label>
									</c:when>
									<c:otherwise>
										<label title="<spring:message code='tracker.reference.choose.items.permissions.tooltip' text='If permission are selected, all Tracker/CMDB items with any of these permissions are included.' javaScriptEscape='true'/>">
											<b><spring:message code="tracker.reference.choose.projects.permissions.label" text="with Permission" javaScriptEscape="true"/>:</b>
										</label>
									</c:otherwise>
									</c:choose>
											<div class="permissions">
												<c:forEach var="permission" items="${project['permissions']}">
													<div class="permission">
														<label title="${permission['title']}">
															<b>${permission['name']}</b>
														</label>
													</div>
												</c:forEach>
											</div>
										</div>
									</c:if>
								</div>
							</div>
                        </c:if>
					<c:if test="${project['explicitly'] != null && fn:length(project['explicitly']) > 0}">
						<div class="component explicitly" style="margin-top: 10px;">
							<c:choose>
								<c:when test="${fieldConfig['refType'] == 9}">
									<label title="<spring:message code='tracker.reference.choose.items.explicitly.tooltip' text='If individual Trackers/CMDB Categories are selected, all items from these Trackers/CMDB Categories matching the specified filter/criteria are included' javaScriptEscape='true'/>">
										<b><spring:message code="tracker.reference.choose.items.explicitly.label" text="and explicitly" javaScriptEscape="true"/></b>
									</label>
								</c:when>
								<c:when test="${fieldConfig['refType'] == 18}">
									<label title="<spring:message code='tracker.reference.choose.repositories.explicitly.tooltip' text='If individual SCM repositories are selected, those are included, whether or not the type or permission matches.' javaScriptEscape='true'/>">
										<b><spring:message code="tracker.reference.choose.repositories.explicitly.label" text="and explicitly" javaScriptEscape="true"/></b>
									</label>
								</c:when>
								<c:otherwise>
									<label title="<spring:message code='tracker.reference.choose.trackers.explicitly.tooltip' text='If individual Trackers/CMDB Categories are selected, those are included, whether or not the type or permission matches.' javaScriptEscape='true'/>">
										<b><spring:message code="tracker.reference.choose.trackers.explicitly.label" text="and explicitly" javaScriptEscape="true"/></b>
									</label>
								</c:otherwise>
							</c:choose>
							<div class="folders">
								<c:forEach var="folder" items="${project['explicitly']}">
								<div class="folder">
									<spring:message code="issue.references.in.label" text="in" javaScriptEscape="true"/>
									<label>
										<b>${folder['path']}</b>
									</label>
									<c:if test="${folder['trackers'] != null && fn:length(folder['trackers']) > 0}">
										<div class="trackers">
										<c:forEach var="tracker" items="${folder['trackers']}">
											<c:if test="${tracker['selected']}">
												<div class="tracker">
													<label title="${tracker['title']}">
														<b>${tracker['name']}</b>
													</label>
													<c:if test="${tracker['filter'] != null}">
														: ${tracker['filter']['name']}
													</c:if>
												</div>
											</c:if>
										</c:forEach>
										</div>
									</c:if>
								</div>
								</c:forEach>
							</div>
						</div>
					</c:if>
					</div>
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