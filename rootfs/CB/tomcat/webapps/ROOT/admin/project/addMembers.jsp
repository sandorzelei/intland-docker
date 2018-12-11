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
<meta name="decorator" content="popup"/>
<meta name="module" content="members"/>
<meta name="moduleCSSClass" content="newskin membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
.inviteEmail {
	display: block;
	margin: 10px 0;
}
.inviteEmail input {
	width: 28%;
	white-space: nowrap;
}
.inviteOnly .memberSelector {
	padding-top: 0 !important;
}
.inviteOnly .roles {
	top: 0 !important;
}
h3 {
	margin: 5px 0px !important;
}
.memberSelector {
	margin-bottom 0 !important;
}
.inviteOnly .expandTextArea {
	margin-bottom: 15px;
}
#comment {
	clear:both;
}
</style>

<script type="text/javascript">
	$(function () {
		var filterTable = function () {
			var text = $("#memberFilter").val();
			if (text.length >= 2 || text.length == 0) {
				$.uiTableFilter($(".memberTable"), text);
			}
		};
		$("#memberFilter").Watermark(i18n.message("project.newMember.filter.tooltip"), "#d1d1d1");
		var commentWatermark = i18n.message("${inviteOnly ? 'project.newMember.invite.comment.tooltip' : 'project.newMember.comment.tooltip'}");
		applyHintInputBox("#comment", commentWatermark);
		$("#memberFilter").keyup(function() {
			throttle(filterTable);
		});

		setTimeout(function () {
			if ($("#memberFilter").size() > 0) {
				$("#memberFilter").focus();
			} else {
				// set the focus to the user selector
				$(".yui-ac-input").focus();
			}
		}, 10);

		// User selector click bug fix
		$('.userSelector').on('mousedown', '.yui-ac-bd li', function(e) {
			if ($('body').hasClass('IE8')) {
				return false;
			}
			e = $.event.fix(e);
			e.preventDefault();
		});
		$('.memberSelector').on('click', function(e) {
			if ($(e.target).is('li')) {
				$('.memberSelector').scrollTop(0);
			}
		});

		// Check if at least one role is selected
		$('input[name="ADD"]').click(function() {
			<c:choose>
				<c:when test="${inviteOnly}">
					$("#addForm").submit();
				</c:when>
				<c:otherwise>
					var hasSelectedRole = false;
					$('.roles input').each(function() {
						if ($(this).is(':checked')) {
							hasSelectedRole = true;
						}
					});
					if (hasSelectedRole) {
						$("#addForm").submit();
					} else {
						alert(i18n.message("proj.member.roles.required"));
					}
				</c:otherwise>
			</c:choose>
		});

	});
</script>

<c:set var="selectionSize" value="20" />

<c:url var="actionUrl" value="/proj/addMembers.spr"/>

<c:set var="commentEditorBlock">
	<textarea class="expandTextArea" id="comment" name="comment" cols="80" maxlength="255"><c:out value="${command.comment}"/></textarea>
</c:set>

<ui:actionBar cssStyle="padding-left: 10px;">
	<div class="okcancel" style="margin-top: 0px;">
		<c:choose>
			<c:when test="${inviteOnly}">
				<spring:message var="addButton" code="project.newMember.invite" text="Invite"/>
				<input type="button" class="button" name="ADD" value="${addButton}" title="${addTitle}" style="margin-right: 5px;"/>
			</c:when>
			<c:otherwise>
				<c:if test="${tooManyCandidates || !empty candidates || !empty groupCandidates}">
					<c:if test="${showParam eq 'members' || empty showParam || (showParam eq 'groups' and !empty groupCandidates)}">
						<spring:message var="addButton" code="button.add" text="Save"/>
						<spring:message var="addTitle" code="project.newMember.add.tooltip" text="Add Selected Accounts as Project Members"/>
						<input type="button" class="button" name="ADD" value="${addButton}" title="${addTitle}" style="margin-right: 5px;"/>
					</c:if>
				</c:if>
			</c:otherwise>
		</c:choose>

		<spring:message var="cancelButton" code="button.cancel"/>
		<a onclick="closePopupInline(); return false;">${cancelButton}</a>
	</div>
</ui:actionBar>

<div class="contentWithMargins addMember ${inviteOnly ? 'inviteOnly':''}">

	<c:if test="${!inviteOnly && (showParam eq 'members' || (showParam eq 'groups' && not empty groupCandidates))}">
		<table class="infotable">
			<tr>
				<td class="step1">
					<h3><spring:message code="project.newMember.info.step1.title" text="Step 1"/></h3>
					<c:set var="step1Label" value="${showParam eq 'members' ? 'project.newMember.info.members.step1' : 'project.newMember.info.groups.step1'}"/>
					<spring:message code="${step1Label}"/>
				</td>
				<td class="step2">
					<h3><spring:message code="project.newMember.info.step2.title" text="Step 2"/></h3>
					<c:set var="step2Label" value="${showParam eq 'members' ? 'project.newMember.info.members.step2' : 'project.newMember.info.groups.step2'}"/>
					<spring:message code="${step2Label}"/>
				</td>
			</tr>
		</table>
	</c:if>

	<spring:message var="filterTitle" code="project.newMember.filter.tooltip" text="Only show members of this role"/>
	<c:if test="${! inviteOnly}">
	<div>
		<c:if test="${!tooManyCandidates}">
			<label>
				<spring:message code="project.newMember.filter.label" text="Filter"/>:
				<input type="text" id="memberFilter" name="filter" class="memberFilter" value="<c:out value='${filter}'/>" size="30" title="${filterTitle}" />
			</label>
		</c:if>
		<c:if test="${!tooManyCandidates && !empty groups}">
			<form action="${actionUrl}" method="get" id="groupForm" style="display: inline;">
				<input type="hidden" name="proj_id"  value="<c:out value='${project.id}'/>" />
				<input type="hidden" name="referrer" value="<c:out value='${referrer}'/>" />
				<c:if test="${not empty showParam}">
					<input type="hidden" name="showParam" value="<c:out value='${showParam}'/>">
				</c:if>

				<label for="groupSelector" style="margin-right: 10px;"><spring:message code="project.newMember.groupFilter.label" text="Only show"/>:</label>
				<select id="groupSelector" name="groupId" onchange="$('#groupForm').submit();" style="width: 15%;">
					<option value="">
						<spring:message code="useradmin.users.label" text="Accounts"/>
					</option>
					<c:forEach items="${groups}" var="group">
						<c:choose>
							<c:when test="${group.name eq 'sysadmin' or empty group.shortDescription}">
								<spring:message var="groupTitle" code="group.${group.name}.tooltip" text="" htmlEscape="true"/>
							</c:when>
							<c:otherwise>
								<c:set var="groupTitle">
									<c:out value="${group.shortDescription}" />
								</c:set>
							</c:otherwise>
						</c:choose>

						<option value="${group.id}" title="${groupTitle}" <c:if test="${groupId eq group.id}">selected="selected"</c:if>>
							<spring:message code="group.${group.name}.label" text="${group.name}"/> (<c:out value="${groupMembers[group.id]}"/>)
						</option>
					</c:forEach>
				</select>
			</form>
		</c:if>
	</div>
	</c:if>

	<c:set var="groupsSection">
		<c:if test="${not empty groupCandidates}">
			<c:if test="${empty showParam}">
				<div style="margin-bottom: 10px; padding-left: 4px;"><strong><spring:message code="project.newMember.groups.label" text="Groups"/></strong></div>
			</c:if>
			<table id="groupTable" class="memberTable">
				<c:forEach items="${groupCandidates}" var="candidate" varStatus="iteration">
					<tr><td>
					<div style="margin-bottom: ${iteration.last ? '20' : (empty showParam ? '10' : '7')}px;">
						<input id="member_${candidate.key}" type="checkbox" title="${roleTitle}" <c:if test="${selectedMembers[candidate.key]}">checked="checked"</c:if>
							 value="${candidate.key}" name="member"/>
						<label for="member_${candidate.key}">${candidate.value}</label>
					</div>
					</td></tr>
				</c:forEach>
			</table>
		</c:if>
	</c:set>
	<form action="${actionUrl}" method="post" id="addForm">
		<input type="hidden" name="proj_id"  value="<c:out value='${project.id}'/>" />
		<input type="hidden" name="groupId"  value="<c:out value='${groupId}'/>" />
		<input type="hidden" name="filter"   value="<c:out value='${filter}'/>" />
		<input type="hidden" name="referrer" value="<c:out value='${referrer}'/>" />
		<input type="hidden" name="role_id"  value="<c:out value='${roleId}'/>" />
		<c:if test="${not empty showParam}">
			<input type="hidden" name="showParam" value="<c:out value='${showParam}'/>">
		</c:if>

		<c:choose>
		    <c:when test="${hasGroupViewPermission}">
		        <spring:message var="noCandidatesHint" code="project.newMember.no.candidates.hint" text="There are currently no other users or user groups that you could add as new project members."/>
		    </c:when>
		    <c:otherwise>
		        <spring:message var="noCandidatesHint" code="project.newMember.no.groupview.missing.hint" text="You cannot add new group because you don't have the necessary permission."/>
		    </c:otherwise>
		</c:choose>
		<c:choose>
			<c:when test="${!tooManyCandidates and empty candidates and empty groupCandidates}">
				<span class="subtext">
					${noCandidatesHint}
				</span>
			</c:when>

			<c:when test="${showParam eq 'groups' and empty groupCandidates}">
				<span class="subtext">
					${noCandidatesHint}
				</span>
			</c:when>

			<c:otherwise>
				<c:choose>
					<c:when test="${inviteOnly}">
						<div class="memberSelector">
							<h3><spring:message code="project.newMember.invite.title" text="Invite members"/></h3>
							<div class="subtext"><spring:message code="project.newMember.invite.title.hint" text="Invite new members using their email addresses below"/></div>

							<spring:message var="emailTooltip" code="user.email.label" />
							<spring:message var="firstNameTooltip" code="user.firstName.label" />
							<spring:message var="lastNameTooltip" code="user.lastName.label" />
							<c:forEach var="inviteUser" items="${command.inviteUsers}" varStatus="status">
								<div class="inviteEmail">
									<input type="text" class="email" name="inviteUsers[${status.index}].email" value="<c:out value='${inviteUser.email}'/>" title="${emailTooltip}"/>
									<input type="text" class="first_name" name="inviteUsers[${status.index}].first_name" value="<c:out value='${inviteUser.first_name}'/>" title="${firstNameTooltip}" />
									<input type="text" class="last_name" name="inviteUsers[${status.index}].last_name" value="<c:out value='${inviteUser.last_name}'/>" title="${lastNameTooltip}" />
								</div>
							</c:forEach>

							<script type="text/javascript">
								$(function() {
									applyHintInputBox(".inviteEmail input.email","${emailTooltip}");
									applyHintInputBox(".inviteEmail input.first_name","${firstNameTooltip}");
									applyHintInputBox(".inviteEmail input.last_name", "${lastNameTooltip}");
								});
							</script>
						</div>
					</c:when>
					<c:when test="${tooManyCandidates}">
						<div class="memberSelector">
							<c:if test="${showParam eq 'members' || empty showParam}">
								<spring:message var="unsetButton" code="tracker.field.value.unset.label" text="Unset"/>
								<bugs:userSelector htmlId="userSelector" singleSelect="false" allowRoleSelection="false" title="${filterTitle}"
												   setToDefaultLabel="${unsetButton}" defaultValue="" ids="" fieldName="member"
												   searchOnAllUsers="true" showPopupButton="false" currentProject="${project.id}"/>
							</c:if>
							<c:if test="${showParam eq 'groups' || empty showParam}">
								<c:if test="${empty showParam}">
									<div style="margin-top: 15px;">
								</c:if>
									${groupsSection}
								<c:if test="${empty showParam}">
									</div>
								</c:if>
							</c:if>
						</div>
					</c:when>
					<c:otherwise>
						<div class="memberSelector">
							<c:if test="${showParam eq 'groups' || empty showParam}">
								${groupsSection}
							</c:if>
							<c:if test="${not empty candidates && (showParam eq 'members' || empty showParam)}">
								<div style="margin-bottom: 10px; padding-left: 4px;"><strong><spring:message code="project.newMember.users.label" text="Users"/></strong></div>
								<table id="memberTable" class="memberTable">
									<c:forEach items="${candidates}" var="candidate">
										<tr><td>
										<div style="margin-bottom: 10px;">
											<input id="member_${candidate.key}" type="checkbox" title="${roleTitle}" <c:if test="${selectedMembers[candidate.key]}">checked="checked"</c:if>
												 value="${candidate.key}" name="member"/>
											<label for="member_${candidate.key}">${candidate.value}</label>
										</div>
										</td></tr>
									</c:forEach>
								</table>
							</c:if>
						</div>
					</c:otherwise>
				</c:choose>

				<div class="roles" style="<c:if test="${tooManyCandidates}">top: -5px; width: 35%</c:if>">
					<c:if test="${empty showParam || inviteOnly}">
						<h3><spring:message code="project.newMember.addInRole.label" text="Add in role"/></h3>
						<div class="subtext" style="padding-top: 10px;"><spring:message code="project.newMember.addInRole.hint" text="Hint: you can select multiple roles"/></div>
					</c:if>
					<div style="height: 305px; overflow-y: auto;">
						<c:forEach items="${roles}" var="role" varStatus="iterationStatus">
							<div style="padding-bottom: 10px; ${iterationStatus.first ? (empty showParam ? 'padding-top: 20px;' : 'padding-top: 10px;') : ''}">
								<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true"/>
								<input id="role_${role.id}" type="checkbox" title="${roleTitle}" <c:if test="${selectedRoles[role.id]}">checked="checked"</c:if> value="${role.id}" name="role_id"/>
								<label for="role_${role.id}"><spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/></label>
							</div>
						</c:forEach>
					</div>
				</div>

				<c:if test="${! inviteOnly}">${commentEditorBlock}</c:if>
			</c:otherwise>
		</c:choose>
	</form>
	<c:if test="${inviteOnly}">${commentEditorBlock}</c:if>
</div>
