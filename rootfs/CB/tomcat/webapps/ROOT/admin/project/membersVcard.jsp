<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.persistence.dto.UserDto"%>

<div class="actionBar">
	<jsp:include page="membersActionBar.jsp"/>
</div>

<div class="contentWithMargins">

	<c:if var="outlookStyle" test="${empty project.propagation and project.category eq 'Collaborative'}">
		<%-- Upon special customer request, members in private projects can see everything about each other --%>
		<c:set var="canViewCompany" value="true"/>
		<c:set var="canViewEmail"   value="true"/>
		<c:set var="canViewPhone"   value="true"/>
		<c:set var="canViewAddress" value="true"/>
	</c:if>

	<display:table class="expandTable" requestURI="" name="${membersPerRole}" id="role" cellpadding="0" sort="external">

		<spring:message var="roleTitle" code="role.label" text="Role"/>
		<display:column title="${roleTitle}" headerClass="textData" class="textDataWrap" style="width:20%">
			<spring:message code="role.${role.key.name}.label" text="${role.key.name}"/>
			<div class="subtext" style="margin-left: 20px;">
				<spring:message code="role.${role.key.name}.tooltip" text="${role.key.description}"/>
			</div>
		</display:column>

		<c:set var="separator" value="" />

		<spring:message var="membersTitle" code="project.members.title" text="Members"/>
		<display:column title="${membersTitle}" headerClass="textData" class="textDataWrap columnSeparator">
			<c:if test="${not empty role.value}">
				<c:forEach items="${role.value}" var="member">
					<div style="float:left; margin:2px;">
						<c:choose>
							<c:when test='<%=(pageContext.getAttribute("member") instanceof UserDto)%>'>
								<ui:vcard user="${member}" hideCompany="${!canViewCompany}" hideEmail="${!canViewEmail}" outlookStyle="${outlookStyle}" showPhone="${canViewPhone}" showAddress="${canViewAddress}"/>
							</c:when>
							<c:otherwise>
								<div class="${outlookStyle ? (canViewAddress ? (canViewPhone ? 'vcardFull' : 'vcardMedium') : (canViewPhone ? 'vcardMedium' : 'vcard')) : 'vcard'}">
									<table cellpadding="0" cellspacing="0">
										<tr>
											<td style="padding: 10px 20px 10px 10px;">
												<img src="${userGroupIcon}"/>
											</td>
											<td>
												<c:url var="groupMembersUrl" value="/sysadmin/users.spr">
													<c:param name="groupId" value="${member.id}"/>
												</c:url>

												<spring:message var="groupTitle" code="group.${member.name}.tooltip" text="${member.shortDescription}" htmlEscape="true"/>
														<span title="${groupTitle}" <c:if test="${outlookStyle}">style="font-weight:bold; font-size:12pt;"</c:if>>
														<spring:message code="group.${member.name}.label" text="${member.name}"/>
														</span>
												<c:choose>
													<c:when test="${outlookStyle}">
														(<a href="${groupMembersUrl}"><c:out value="${groupMemberCount[member.id]}"/> <spring:message code="${groupMemberCount[member.id] eq 1 ? 'project.member.label' : 'group.members.label'}" text="members"/></a>)
														<br/>
														<spring:message code="group.label" text="User Group"/>
														<br/>
													</c:when>
													<c:otherwise>
														<br/>
														<spring:message code="group.label" text="User Group"/>
														(<a href="${groupMembersUrl}"><c:out value="${groupMemberCount[member.id]}"/> <spring:message code="${groupMemberCount[member.id] eq 1 ? 'project.member.label' : 'group.members.label'}" text="members"/></a>)
													</c:otherwise>
												</c:choose>
											</td>
										</tr>
									</table>
								</div>
							</c:otherwise>
						</c:choose>
					</div>
				</c:forEach>
			</c:if>
		</display:column>
	</display:table>

</div>