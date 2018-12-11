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
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<%--
CB Task #18860 for Firefox.
The <html:cancel/> control cannot be used on this page.
Since we need that "GO" button will be activated when user press <RETURN> button,
we have to use the only one <input type="submit"> control.
But the the <html:cancel/> generates
<input type="submit" name="org.apache.struts.taglib.html.CANCEL" value="Cancel"> HTML tag.

"tabindex" didn't help to change behaviour.
JavaScript didn't help too, since some bug in Firefox.
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ page import="com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorController"%>
<%@ page import="com.intland.codebeamer.servlet.bugs.dynchoices.SelectReferenceController"%>
<%
	pageContext.getRequest().setAttribute("CURRENT_USER", UserSelectorController.CURRENT_USER);
	pageContext.getRequest().setAttribute("UNSET_USER", UserSelectorController.UNSET_USER);
%>

<c:if test="${selectAssignedUsersCommand.submitted == false}">

<c:set var="singleSelect" value="${param.singleSelect eq 'true'}" />

<form:form id="selectAssignedUsersForm" commandName="selectAssignedUsersCommand">

<style type="text/css">
<!--
	.actionBar .button {
		margin-left: 1em;
	}
	#projectAndRole {
		margin: 15px;
	}
	#member {
		margin: 15px;
	}
	.titleDiv {
		margin: 15px;
	}
	.titleDiv .count {
		padding-left: 1em;
		text-transform: none;
		letter-spacing: normal;
	}
	.displaytag {
		width: 95% !important;
	}
	.descriptionBox {
		margin: 15px;
		border: none !important;
	}
	input[type="checkbox"], input[type="radio"] {
  		vertical-align: text-bottom;
	}
-->
</style>

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false">
		<spring:message code="${selectAssignedUsersCommand.allowRoleSelection ? 'project.membersAndRoles.choose.title' : 'project.members.choose.title'}" />
	</ui:pageTitle>
</ui:actionMenuBar>

<spring:message var="toggleButton" code="${singleSelect ? 'project.members.choose.none.tooltip' : 'search.what.toggle'}" />

<c:choose>
	<c:when test="${empty selectAssignedUsersCommand.project_list}">
		<div class="warning">
			<spring:message code="project.members.choose.warning" text="There are no projects available to select members."/>
		</div>
	</c:when>

	<c:otherwise>
		<c:set var="actionBarContent">
			<spring:message var="saveButton" code="button.set" text="Set"/>
			<input type="button" value="${saveButton}" onclick="submitAction(this.form);" class="button" />

			<c:if test="${singleSelect}">
				<spring:message var="unsetButton" code="tracker.field.value.unset.label" text="Unset"/>
				<spring:message var="unsetTitle" code="tracker.field.value.unset.tooltip" text="Clear field value"/>
				<input type="submit" name="unset_button" value="${unsetButton}" class="button" title="${unsetTitle}" />
			</c:if>
			<input type="hidden" id="SUBMIT" name="SUBMIT" />

			<%-- button allow resetting to default-value --%>
			<c:if test="${!empty selectAssignedUsersCommand.setToDefaultLabel}">
				<input type="submit" class="button" name="<%=SelectReferenceController.BUTTON_RESET_TO_DEFAULT%>" value="<c:out value='${selectAssignedUsersCommand.setToDefaultLabel}'/>" />
			</c:if>

			<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
			<input type="submit" name="_cancel" value="${cancelButton}" class="cancelButton" onclick="cancelAction();return false;" />
		</c:set>
		<ui:actionBar>${actionBarContent}</ui:actionBar>

		<form:hidden path="project_list" />
		<form:hidden path="required_roles" />

		<div class="accordion">

			<c:if test="${canSelectFields}">

				<!-- Fields -->

				<h3 class="titleDiv accordion-header">
					<b><spring:message code="tracker.fieldAccess.memberFields.label" text="Participants"/></b>
					<span class="count"></span>
				</h3>

				<div class="descriptionBox accordion-content" id="participants-accordion" >
					<c:forEach items="${memberFields}" var="memberField">
						<c:set var="fldId" value="memberField_${memberField.id}"/>
						<spring:message var="fldLabel" code="tracker.field.${memberField.label}.label" text="${memberField.label}"/>
						<spring:message var="fldTitle" code="tracker.fieldAccess.memberField.tooltip" text="Members and Roles listed in field {0}" arguments="${fldLabel}"/>

						<c:choose>
							<c:when test="${singleSelect}">
								<form:radiobutton id="${fldId}" path="selectedFieldIds" value="${memberField.id}" ondblclick="submitAction(this.form); return false;"/>
							</c:when>
							<c:otherwise>
								<form:checkbox id="${fldId}" path="selectedFieldIds" value="${memberField.id}" ondblclick="submitAction(this.form); return false;"/>
							</c:otherwise>
						</c:choose>
						<label for="${fldId}">${fldLabel}</label>
						&nbsp;&nbsp;
					</c:forEach>
				</div>
			</c:if>

			<c:if test="${selectAssignedUsersCommand.allowUserSelection}">

				<!-- Member selection -->

				<h3 class="titleDiv accordion-header"><b><spring:message code="project.members.choose.members.title" text="Choose Members"/></b><span class="count"></span></h3>

				<%-- filter the users --%>
				<div class="descriptionBox accordion-content">
					<STRONG style="margin-left: 1em;"><spring:message code="project.newMember.filter.label" text="Filter"/>:</STRONG>
					<spring:message var="filter_tooltip" code="account.filter.title" />
					<form:input size="15" title="${filter_tooltip}" path="ITEMFILTER" onkeypress="return submitOnEnter(this,event)"/>

					<c:if test="${not selectAssignedUsersCommand.disableRoleFiltering }">
						<c:if test="${canViewRoles}">
							<STRONG style="margin-left: 1em;"><spring:message code="role.label" text="Role"/>:</STRONG>
							<form:select path="role_id_filter">
								<form:options items="${results.roleFilter}" itemLabel="label" itemValue="value" />
							</form:select>
						</c:if>

						<spring:message var="onlyTitle" code="project.members.choose.onlyMembers.tooltip" text="Only show members of this project"/>
						<label for="onlyMembersCheckbox" style="margin-left: 1em;" title="${onlyTitle}">
							<form:checkbox path="onlyMembers" id="onlyMembersCheckbox"/>
							<spring:message code="project.members.choose.onlyMembers.label" text="Only members"/>
						</label>

						<label for="includeDisabledUsers" style="margin-left: 1em;" title="${onlyTitle}">
							<form:checkbox path="includeDisabledUsers" id="includeDisabledUsers"/>
							<spring:message code="project.members.choose.includeDisabledUsers.label" text="Show disabled users"/>
						</label>

					</c:if>

					<spring:message var="searchButton" code="search.submit.label" text="GO"/>
					<input type="submit" title="${filter_tooltip}" class="button" name="INFO" value="${searchButton}" style="margin-left:1em;" />

					<c:set var="checkAll">
						<c:choose>
							<c:when test="${singleSelect}">
								<input type="radio" name="selectedUserIds" value="" title="${toggleButton}" />
							</c:when>
							<c:otherwise>
								<input type="checkbox" name="selectAll" title="${toggleButton}" onclick="setAllStatesFrom(this, 'selectedUserIds')" />
							</c:otherwise>
						</c:choose>
					</c:set>

					<display:table class="expandTable" requestURI="" name="${members}" id="member" cellpadding="0"
								   decorator="com.intland.codebeamer.ui.view.table.ProjectMemberDecorator" sort="external" export="false">

						<display:setProperty name="basic.msg.empty_list_row">
							<tr class="empty">
								<td colspan="{0}">
									<div class="explanation">
										<spring:message code="account.filter.no.matching.account" />
									</div>
								</td>
							</tr>
						</display:setProperty>

						<display:column title="${checkAll}" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
							<c:choose>
								<c:when test="${singleSelect}">
									<form:radiobutton disabled="${!member.user.activated}" path="selectedUserIds" value="${member.user.id}" ondblclick="submitAction(this.form);" />
								</c:when>
								<c:otherwise>
									<form:checkbox disabled="${!member.user.activated}"	path="selectedUserIds" value="${member.user.id}" ondblclick="submitAction(this.form);" />
								</c:otherwise>
							</c:choose>
						</display:column>

						<spring:message var="titleAccount" code="user.account.label" text="Account"/>
						<display:column title="${titleAccount}" headerClass="textData" property="nameOpenInNewWindow" class="textData columnSeparator referenceSelectName" />

						<spring:message var="titleName" code="user.realName.label" text="Name" />
						<display:column title="${titleName}" property="realName" headerClass="textData" class="textData columnSeparator realName" />

						<c:if test="${canViewRoles and not selectAssignedUsersCommand.disableRoleFiltering}">
							<spring:message var="titleRoles" code="project.roles.label" text="Roles"/>
							<display:column title="${titleRoles}" property="roles" headerClass="textData" class="textDataWrap columnSeparator referenceSelectLessImportant" />
						</c:if>

						<c:if test="${canViewCompany}">
							<spring:message var="titleCompany" code="user.company.label" text="Company"/>
							<display:column title="${titleCompany}" property="company" headerClass="textData" class="textDataWrap referenceSelectLessImportant"/>
						</c:if>
					</display:table>
				</div>
			</c:if>

			<c:if test="${selectAssignedUsersCommand.allowRoleSelection}">
				<h3 class="titleDiv accordion-header"><b><spring:message code="project.membersAndRoles.choose.roles.title" text="Choose Roles"/></b><span class="count"></span></h3>

				<c:set var="checkAll">
					<c:choose>
						<c:when test="${singleSelect}">
							<form:radiobutton path="selectedRoleIds" value="" title="${toggleButton}" />
						</c:when>
						<c:otherwise>
							<input type="checkbox" name="selectAll" title="${toggleButton}" onclick="setAllStatesFrom(this, 'selectedRoleIds')" />
						</c:otherwise>
					</c:choose>
				</c:set>

				<div class="descriptionBox accordion-content">
					<display:table class="expandTable" requestURI="" name="${rolesAndMembers}" id="roleAndMembers" cellpadding="0"
								   decorator="com.intland.codebeamer.ui.view.table.RoleMemberDecorator" sort="external" export="false" >

						<c:set var="role" value="${roleAndMembers.key}" />

						<display:column title="${checkAll}" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
							<c:set var="selectorId" value="selectedRoleIds_${role.id}" />
							<c:choose>
								<c:when test="${singleSelect}">
									<form:radiobutton path="selectedRoleIds" value="${role.id}" ondblclick="submitAction(this.form); return false;" id="${selectorId}"/>
								</c:when>
								<c:otherwise>
									<form:checkbox path="selectedRoleIds" value="${role.id}" ondblclick="submitAction(this.form); return false;" id="${selectorId}"/>
								</c:otherwise>
							</c:choose>
						</display:column>

						<spring:message var="roleTitle" code="role.label" text="Role"/>
						<display:column title="${roleTitle}" headerClass="textData" class="textData columnSeparator referenceSelectName" >
							<label for="${selectorId}"><spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/></label>
						</display:column>

						<c:if test="${canViewRoles}">
							<spring:message var="membersTitle" code="members.label" text="Members"/>
							<display:column title="${membersTitle}" headerClass="textData" property="memberLinksOpenInNewWindow" class="textDataWrap columnSeparator referenceSelectLessImportant"/>
						</c:if>

						<spring:message var="descTitle" code="role.description.label" text="Description"/>
						<display:column title="${descTitle}" property="role.description" headerClass="textData" class="textDataWrap" escapeXml="true" />
					</display:table>
				</div>
			</c:if>

			<c:if test="${canSelectGroups}">
				<h3 class="titleDiv accordion-header"><b><spring:message code="project.membersAndRoles.choose.groups.title" text="Choose Groups"/></b><span class="count"></span></h3>

				<c:set var="checkAllGroups">
					<c:choose>
						<c:when test="${singleSelect}">
							<form:radiobutton path="selectedGroupIds" value="" title="${toggleButton}" />
						</c:when>
						<c:otherwise>
							<input type="checkbox" name="selectAllGroups" title="${toggleButton}" onclick="setAllStatesFrom(this, 'selectedGroupIds')" />
						</c:otherwise>
					</c:choose>
				</c:set>

				<div class="descriptionBox accordion-content">
					<display:table class="expandTable" requestURI="" name="${groupsAndRoles}" id="groupAndRoles" cellpadding="0" sort="external" export="false" >
						<c:set var="group" value="${groupAndRoles.key}" />

						<display:column title="${checkAllGroups}" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
							<c:set var="selectorId" value="selectedGroupIds_${group.id}" />
							<c:choose>
								<c:when test="${singleSelect}">
									<form:radiobutton path="selectedGroupIds" value="${group.id}" ondblclick="submitAction(this.form); return false;" id="${selectorId}"/>
								</c:when>
								<c:otherwise>
									<form:checkbox path="selectedGroupIds" value="${group.id}" ondblclick="submitAction(this.form); return false;" id="${selectorId}"/>
								</c:otherwise>
							</c:choose>
						</display:column>

						<spring:message var="groupTitle" code="group.label" text="Group" htmlEscape="true"/>
						<display:column title="${groupTitle}" headerClass="textData" class="textData columnSeparator referenceSelectName" >
							<label for="${selectorId}"><spring:message code="group.${group.name}.label" text="${group.name}"/></label>
						</display:column>

						<c:if test="${canViewRoles}">
							<spring:message var="titleRoles" code="project.roles.label" text="Roles" htmlEscape="true"/>
							<display:column title="${titleRoles}" headerClass="textData" class="textDataWrap columnSeparator referenceSelectLessImportant">
								<c:set var="separator" value="" />

								<tag:joinLines newLinePrefix="">
									<c:forEach items="${groupAndRoles.value}" var="groupRole">
										<c:out value="${separator}" escapeXml="false" /><c:out value="${groupRole}" escapeXml="false" />
										<c:set var="separator" value=", " />
									</c:forEach>
								</tag:joinLines>
							</display:column>
						</c:if>

						<spring:message var="descTitle" code="group.details.label" text="Description" htmlEscape="true"/>
						<display:column title="${descTitle}" headerClass="textData" class="textDataWrap">
							<c:choose>
								<c:when test="${group.name eq 'sysadmin' or empty group.shortDescription}">
									<spring:message code="group.${group.name}.tooltip" text="" />
								</c:when>
								<c:otherwise>
									<c:out value="${group.shortDescription}" />
								</c:otherwise>
							</c:choose>
						</display:column>
					</display:table>
				</div>
			</c:if>

		</div>

	</c:otherwise>
</c:choose>

<%--note: this script must be inside/after html:form as uses variables populate in form-bean's reset() method --%>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
function cancelAction() {
	inlinePopup.close();
}

function submitAction(frm) {
	// all this magic with "Set" button is to make the GO the default button used when enter pressed
	document.getElementById("SUBMIT").value="anythingbutempty";
	frm.submit();
}
</SCRIPT>

<script type="text/javascript">
	var focusControl = document.forms["selectAssignedUsersForm"].elements["ITEMFILTER"];
	$(focusControl).focus();

	$(function () {

		function initAccordion() {
			var accordion = $('.accordion');
			accordion.cbMultiAccordion();

			if ($("body").hasClass("FF")) {
				$(".accordion").css("visibility", "hidden");
				setTimeout(function() {
					accordion.cbMultiAccordion("open", 0);
					accordion.cbMultiAccordion("open", 1);
					<c:if test="${canSelectFields}">
						accordion.cbMultiAccordion("open", 2);
					</c:if>
					$(".accordion").css("visibility", "visible");
				}, 100);
			} else {
				accordion.cbMultiAccordion("open", 0);
				accordion.cbMultiAccordion("open", 1);
				<c:if test="${canSelectFields}">
					accordion.cbMultiAccordion("open", 2);
				</c:if>
			}

			var getHeaderIndex = function(element, headers) {
				var index = 0;
				var headerIndex = 0;
				headers.each(function() {
					if (element.get(0) == $(this).get(0)) headerIndex = index;
					index++;
				});
				return headerIndex;
			};

			var headers = accordion.find("h3");
			headers.click(function() {
				var headerIndex = getHeaderIndex($(this), headers);
				if (headerIndex > 0) {
					accordion.cbMultiAccordion("scrollToHeader", headerIndex, accordion.closest("body"));
				}
			});

			<c:if test="${!singleSelect}">

			var changeSelectedText = function(container) {
				setTimeout(function() {
					var countSelected = function(container) {
						return container.find('input[type="checkbox"][name!="selectAll"][name!="onlyMembers"][name!="selectAllGroups"]').filter(":checked").length;
					};
					var header = container.prev("h3");
					var countSpan = header.find("span.count");
					countSpan.text("(" + i18n.message("project.member.selected.label", countSelected(container)) + ")");
				}, 100);
			};

			$('input[type="checkbox"]').change(function() {
				changeSelectedText($(this).closest("div.accordion-content"));
			});
			accordion.find("div.accordion-content").each(function() {
				changeSelectedText($(this));
			});

			</c:if>

		}

		initAccordion();

	});
</script>

</form:form>
</c:if>

<%-- include scriptlet used when an user is selected, so window is closing --%>
<jsp:include page="./userSelected.jsp" />
