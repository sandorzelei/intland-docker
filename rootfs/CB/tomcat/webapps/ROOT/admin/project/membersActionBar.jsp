<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style>
	.actionBar .tableIcon {
		margin-top: -4px;
	    position: relative;
	    top: 3px;
	}
</style>

<ui:actionGenerator builder="membersPageActionsMenuBuilder" subject="${project}" actionListName="actions">
	<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="more" actions="${actions}" keys="emailMembers, memberTrends, viewJoinRequests, Collection<ProjectRole>" />
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<form action="${requestURI}" method="get">
					<input type="hidden" name="proj_id" value="${project.id}" />
					<c:if test="${memberLayout ne 'settings'}">
						<c:choose>
							<c:when test="${canViewRoles}">
								<select id="roleSelector" name="role_id" onchange="$('#filterBtn').click();">
									<option value="">
										<spring:message code="project.members.title" text="Members"/> (<c:out value="${projMembers}"/>)
									</option>
									<c:forEach items="${roles}" var="role">
										<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true"/>
										<option value="${role.id}" title="${roleTitle}" <c:if test="${roleId eq role.id}">selected="selected"</c:if>>
											<spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/> (<c:out value="${roleMembers[role.id]}"/>)
										</option>
									</c:forEach>
								</select>
							</c:when>
							<c:otherwise>
								<spring:message code="project.members.title" text="Members"/>
							</c:otherwise>
						</c:choose>
					</c:if>

					<c:if test="${canAdminMembers}">
						<c:choose>
							<c:when test="${memberLayout eq 'settings'}"><spring:message var="roleStatusLabel" code="project.member.role.status.label" text="Role status:"/></c:when>
							<c:otherwise><spring:message var="roleStatusLabel" code="project.member.status.label" text="with status"/></c:otherwise>
						</c:choose>
						<span class="withStatusText">${roleStatusLabel}</span>
						<select id="statusSelector" name="status_id" onchange="$('#filterBtn').click();">
							<c:forEach items="${memberStatus}" var="status">
								<c:if test="${memberLayout ne 'settings' || (memberLayout eq 'settings' and status.id ne 1 and status.id ne 2)}">
									<option value="${status.id}" <c:if test="${statusId eq status.id}">selected="selected"</c:if>>
										<spring:message code="project.member.status.${status.name}" text="${status.name}"/>
									</option>
								</c:if>
							</c:forEach>
						</select>
					</c:if>

					<spring:message var="filterTooltip" code="project.members.filter.tooltip" text="Filter accounts by name, email, phone, mobile or company"/>
					<input type="text" id="memberFilter" name="memberFilter" size="15" value="<c:out value='${memberFilter}'/>" title="${filterTooltip}" />

					<spring:message var="filterLabel" code="search.submit.label" text="GO" />
					<input id="filterBtn" type="submit" class="button" value="${filterLabel}" title="${filterTooltip}"/>
				</form>
			</jsp:attribute>
		<jsp:body>
			<ui:actionLink actions="${actions}" keys="${memberLayout ne 'settings' ? 'newMember,newGroup,projectRoles,exportMembers' : 'newMember,newGroup,exportMembers'}"/>
		</jsp:body>
	</ui:rightAlign>
</ui:actionGenerator>