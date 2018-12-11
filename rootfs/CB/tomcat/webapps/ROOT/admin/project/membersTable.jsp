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

	<ui:displaytagPaging defaultPageSize="${pagesize}" items="${members}" excludedParams="page"/>

	<display:table class="expandTable" requestURI="${requestURI}" excludedParams="page" name="${members}" id="member" cellpadding="0" sort="external" export="true"
				   decorator="com.intland.codebeamer.ui.view.table.ProjectMemberDecorator">

		<display:setProperty name="basic.msg.empty_list_row">
			<tr class="empty">
				<td colspan="{0}">
					<div class="explanation">
						<spring:message code="account.filter.no.matching.account" />
					</div>
				</td>
			</tr>
		</display:setProperty>

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty members.list ? 'none' : 'bottom'}"/>

		<display:column title="" headerClass="textData" class="textData" media="html" style="width:2em;">
			<c:choose>
				<c:when test='<%=(pageContext.getAttribute("member") instanceof UserDto)%>'>
					<ui:userPhoto userId="${member.id}" userName="${member.name}"/>
				</c:when>
				<c:otherwise>
					<img src="${userGroupIcon}" style="padding-left: 10px;" />
				</c:otherwise>
			</c:choose>
		</display:column>

		<spring:message var="memberName" code="project.member.label" text="Member"/>
		<display:column title="${memberName}" property="name" headerClass="textData" class="textData" sortable="true" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" style="width:1%;"
						headerClass="action-column-minwidth" class="action-column-minwidth columnSeparator" >
			<ui:actionMenu builder="membersPageUsersContextActionListMenuBuilder" subject="${member}" />
		</display:column>

		<c:if test="${canViewRoles}">
			<spring:message var="memberRoles" code="role.label" text="Role"/>
			<display:column title="${memberRoles}" property="roles" headerClass="textData" class="textDataWrap columnSeparator"/>
		</c:if>

		<spring:message var="memberFirstName" code="user.firstName.label" text="First Name"/>
		<display:column title="${memberFirstName}" property="firstName" headerClass="textData" class="textData columnSeparator" sortable="true" />

		<spring:message var="memberLastName" code="user.lastName.label" text="Last Name"/>
		<display:column title="${memberLastName}" property="lastName" headerClass="textData" class="textData columnSeparator" sortable="true" />

		<c:if test="${canViewEmail}">
			<spring:message var="memberEmail" code="user.email.label" text="Email"/>
			<display:column title="${memberEmail}" property="email" headerClass="textData" class="textData columnSeparator" sortable="true" />
		</c:if>

		<c:if test="${canViewAddress}">
			<spring:message var="memberAddress" code="user.address.label" text="Address"/>
			<display:column title="${memberAddress}" property="address" headerClass="textData" class="textData columnSeparator" sortable="true" />

			<spring:message var="memberZIP" code="user.zip.label" text="ZIP"/>
			<display:column title="${memberZIP}" property="zip" headerClass="textData" class="textData columnSeparator" sortable="true" />

			<spring:message var="memberCity" code="user.city.label" text="City"/>
			<display:column title="${memberCity}" property="city" headerClass="textData" class="textData columnSeparator" sortable="true" />

			<spring:message var="memberCountry" code="user.country.label" text="Country"/>
			<display:column title="${memberCountry}" property="country" headerClass="textData" class="textData columnSeparator" sortable="true" />
		</c:if>

	</display:table>

</div>