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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="tracker" prefix="tracker" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="mystart"/>
<meta name="moduleCSSClass" content="workspaceModule newskin"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/workspace/userdata.css' />" type="text/css" media="all" />
</head>

<script type="text/javascript">
function requestPasswordReset(userId) {
	if (confirm('<spring:message code="user.password.reset.confirm" text="Really ask this user to change/reset his account password ?"/>')) {
		$.ajax('<c:url value="/ajax/requestPasswordReset.spr"/>', {
			type		: 'GET',
			data		: { user_id : userId },
			contentType : 'application/json',
			dataType 	: 'json'
		}).done(function(msg) {
			alert(msg);
		}).fail(function(jqXHR, textStatus, errorThrown) {
    		try {
	    		var exception = eval('(' + jqXHR.responseText + ')');
	    		alert(exception.message);
    		} catch(err) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
    		}
        });
	}

	return false;
}
</script>

<%-- Use Skype URL as default --%>
<c:set var="callto" value="callto://" />

<c:set var="user" value="${targetUser}" />
<c:set var="emptyValue" value="--" />

<c:choose>
	<c:when test="${user.downloadLimit < 0}">
		<spring:message var="downloadLimitLabel" code="user.downloadLimit.unlimited" text="Unlimited"/>
	</c:when>

	<c:otherwise>
		<c:set var="downloadLimitLabel" value="${user.downloadLimit} KB" />
	</c:otherwise>
</c:choose>

<c:set var="stars" value="************" />

<ui:actionMenuBar cssClass="accountHeadLine">
	<ui:pageTitle>
		<spring:message code="user.account.label" text="Account"/><span class='breadcrumbs-separator'>&raquo;</span><c:out value="${user.name}" />
	</ui:pageTitle>
</ui:actionMenuBar>

<ui:actionBar>
	<ui:actionLink builder="userAccountActionMenuBuilder" subject="${user}"/>

	<%-- show CTI actions if they are enabled --%>
	<ui:actionGenerator builder="ctiUserActionMenuBuilder" actionListName="ctiActions" subject="${user}"   throwExceptionOnMissingBuilder="false" >
		<ui:actionLink actions="${ctiActions}" keys="createNewTrackerItem"/>
		<%-- preserve ctiActions in request scope used below --%>
		<c:set var="_ctiActions" value="${ctiActions}"/>
	</ui:actionGenerator>
</ui:actionBar>

<c:set var="timeZoneAndDateFormatTable">
	<h4>
		<spring:message code="user.dateTimeSettings.label" text="Timezone / Date Format"/>
	</h4>
	<table border="0" cellpadding="0" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="user.dateFormatPattern.label" text="Date Format"/>:</td>
			<td class="tableItem"><c:out value="${dateExample}" /></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.timeZonePattern.label" text="Time zone"/>:</td>
			<td class="tableItem"><c:out value="${userTimezoneName}" /> (<c:out value="${user.timeZone.ID}" />)</td>
		</tr>
	</table>
</c:set>

<c:set var="userGroupMemberShipTable">
	<c:if test="${canModifyAny || canViewRole}">
	<h4>
		<spring:message code="user.groupMemberships.label" text="Member in Groups"/>
	</h4>
	<table border="0" cellpadding="0" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="user.memberInGroups.label" text="Member in Groups"/>:</td>

			<td class="tableItem">
				<c:forEach items="${userGroups}" var="userGroup" varStatus="status">
					<c:url var="link" value="/sysadmin/editGroup.spr">
						<c:param name="groupId" value="${userGroup.id}" />
					</c:url>
					<spring:message var="groupTitle" code="group.${userGroup.name}.tooltip" text="${userGroup.shortDescription}" htmlEscape="true"/>

					<tag:joinLines>
						<c:choose>
							<c:when test="${canModifyAny}">
								<a href="${link}" title="${groupTitle}">
									<spring:message code="group.${userGroup.name}.label" text="${userGroup.name}" htmlEscape="true"/>
								</a>
							</c:when>

							<c:otherwise>
								<label title="${groupTitle}">
									<spring:message code="group.${userGroup.name}.label" text="${userGroup.name}" htmlEscape="true"/>
								</label>
							</c:otherwise>
						</c:choose>
					</tag:joinLines><c:if test="${!status.last}">,</c:if>
				</c:forEach>
			</td>
		</tr>
	</table>
	</c:if>
</c:set>

<table id="userDataTable" width="90%" cellpadding="0">
<tbody>
<tr style="vertical-align: top">
	<td style="vertical-align: top; width: 1%;">
		<c:set var="updateUserPhotoUrl" value="/updateUserPhoto?userId=${user.id}" />
		<ui:userPhoto userId="${user.id}" userName="${user.name}" large="true" url="${canModifyAccount ? updateUserPhotoUrl : null}"/>
	</td>
	<td width="40%" class="block">
		<%-- Left column --%>
		<h4>
			<spring:message code="user.personalDetails.label" text="Personal Details"/>
		</h4>

		<table width="100%" cellpadding="2" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="user.name.label" text="Account Name"/>:</td>

			<c:set var="styleClass" value="" />
			<c:if test="${!user.activated}">
				<c:set var="styleClass" value="disableduser" />
			</c:if>
			<td class="tableItem <c:out value="${styleClass}" />"><c:out value="${user.name}" /></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.lastLogin.label" text="Last Login"/>:</td>

			<td class="tableItem">
				<c:choose>
					<c:when test="${!isAnonymous}">
						<tag:formatDate value="${user.lastLogin}" />
						<c:set var="hostName" value="${user.hostName}" />
						<c:if test="${!empty hostName and hostName != 'localhost'}">
							&nbsp;<spring:message code="user.lastLogin.from" text="from"/>:
							<c:if test="${!empty user.geoLocation.mapUrl}">
								<c:out value="${user.geoLocation}" default="${emptyValue}" />
								<a target="_blank"	href="<c:out value="${user.geoLocation.mapUrl}" />"><img style="vertical-align: text-bottom" src="<c:url value='/images/newskin/action/map.png'/>" title="Google Map" /></a>
							</c:if>
						</c:if>
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.title.label" text="Title"/>:</td >
			<td class="tableItem"><c:out value="${user.title}" default="${emptyValue}" /></td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.id.label" text="Account ID"/>:</td >
			<td class="tableItem"><c:out value="${user.id}" /></td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.firstName.label" text="First Name"/>:</td >
			<td class="tableItem"><c:out value="${user.firstName}" default="${emptyValue}" /></td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.lastName.label" text="Last Name"/>:</td >
			<td class="tableItem"><c:out value="${user.lastName}" default="${emptyValue}" /></td >
		</tr>
		<tr class="bigGapBefore">
			<td class="optional" ><spring:message code="user.email.label" text="Email"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewEmail}">
						<a href="mailto:<c:out value="${user.email}" />"><c:out value="${user.email}" default="${emptyValue}" /></a>
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.phone.label" text="Phone"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewPhone}">
						<c:choose>
							<c:when test="${!empty user.phone}">
								<a href="${callto}<c:out value="${user.phone}" />"><c:out value="${user.phone}" default="${emptyValue}" /></a>
							</c:when>
							<c:otherwise>
								<c:out value="${emptyValue}" />
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.mobile.label" text="Mobile"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewPhone}">
						<c:choose>
							<c:when test="${!empty user.mobile}">
								<a href="${callto}<c:out value="${user.mobile}" />"><c:out value="${user.mobile}" default="${emptyValue}" /></a>
							</c:when>
							<c:otherwise>
								<c:out value="${emptyValue}" />
							</c:otherwise>
						</c:choose>
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.company.label" text="Company"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewCompany}">
						<c:out value="${user.company}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.address.label" text="Address"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<c:out value="${user.address}" default="${emptyValue}" />

						<c:if test="${!empty user.mapUrl}">
							&nbsp;<a target="_blank" href="<c:out value="${user.mapUrl}" />"><img style="vertical-align: text-bottom" border="0" src="<c:url value='/images/newskin/action/map.png'/>" title="Google Map"/></a>
						</c:if>
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.city.label" text="City"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<c:out value="${user.city}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.zip.label" text="Zip/Postal Code"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<c:out value="${user.zip}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.state.label" text="State/Province"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<c:out value="${user.state}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.country.label" text="Country"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<c:out value="${userCountryName}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr class="bigGapBefore">
			<td class="optional"><spring:message code="user.language.label" text="Language"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewPhone or canViewEmail}">
						<c:out value="${userLanguageName}" default="${emptyValue}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.registryDate.label" text="Registered"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewAddress}">
						<tag:formatDate type="date" value="${user.registryDate}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>

	<c:if test="${canModifyAny}">
		<tr>
			<td class="optional"><spring:message code="user.licenseType.label" text="License Type"/>:</td >
			<td class="tableItem">

				<table class="displaytag formTableWithSpacing licenseTable">
					<thead>
						<tr>
							<c:forEach items="${userLicenses}" var="entry">
								<th class="licenseHeader">${entry.key}</th>
							</c:forEach>
						</tr>
					</thead>
					<tbody>
						<tr>
							<c:forEach items="${userLicenses}" var="entry">
								<td class="licenseOptions">
									<c:choose>
										<c:when test="${!empty(entry.value)}">
											${entry.value}
										</c:when>
										<c:otherwise>
											<spring:message code="sysadmin.license.option.NoUserOptionsDefined" text="No additional feature"/>
										</c:otherwise>
									</c:choose>
								</td>
							</c:forEach>
						</tr>
					</tbody>

				</table>

			</td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.status.label" text="Status"/>:</td >
			<td class="tableItem"><spring:message code="user.${user.status}" text="${user.status}" htmlEscape="true" /></td >
		</tr>
		<tr>
			<td class="optional"><spring:message code="user.downloadLimit.label" text="Upload Limit (in KB)"/>:</td >
			<td class="tableItem"><c:out value="${downloadLimitLabel}" /></td >
		</tr>
	</c:if>
		<tr>
			<td class="optional"><spring:message code="user.skills.label" text="Skills"/>:</td >
			<td class="tableItem">
				<c:choose>
					<c:when test="${canViewSkills}">
						<c:out value="${user.skills}" />
					</c:when>
					<c:otherwise>
						<c:out value="${stars}" />
					</c:otherwise>
				</c:choose>
			</td >
		</tr>
		</table>
	</td>

	<%-- Right column --%>
	<td style="width: 40%">
		<div class="block">${userGroupMemberShipTable}</div>
		<div class="block">${timeZoneAndDateFormatTable}</div>

		<c:if test="${!empty trackerItemStats}">
			<div class="block">
				<h4><spring:message code="user.issues.open" text="Open Issues"/></h4>

				<ul>
					<c:set var="usertasks" value="/browseIssues.spr" />

					<%-- The list of open task items assigned to or submitted by the user. --%>
					<c:url var="link" value="${usertasks}">
						<c:param name="user_id" value="${user.id}" />
						<c:param name="onlyAssignedToUser" value="true" />
						<c:param name="onlySubmittedByUser" value="true" />
						<c:param name="onlyOwnedByUser" value="true" />
						<c:param name="onlyDirectUserItems" value="true" />
						<c:param name="show" value="Unresolved" />
					</c:url>
					<li>
						<a href="${link}"><spring:message code="user.issues.all" text="All Issues"/></a>
						(<fmt:formatNumber value="${trackerItemStats.all}" />)
					</li>

					<%-- The list of open task items assigned to the user. --%>
					<c:url var="link" value="${usertasks}">
						<c:param name="user_id" value="${user.id}" />
						<c:param name="onlyAssignedToUser" value="true" />
						<c:param name="onlyDirectUserItems" value="true" />
						<c:param name="show" value="Unresolved" />
					</c:url>
					<li>
						<a href="${link}"><spring:message code="user.issues.assignedTo" text="Assigned to"/></a>
						(<fmt:formatNumber value="${trackerItemStats.assigned}" />)
					</li>

					<%-- The list of open task items submitted by the user. --%>
					<c:url var="link" value="${usertasks}">
						<c:param name="user_id" value="${user.id}" />
						<c:param name="onlySubmittedByUser" value="true" />
						<c:param name="onlyDirectUserItems" value="true" />
						<c:param name="show" value="Unresolved" />
					</c:url>
					<li>
						<a href="${link}"><spring:message code="user.issues.submittedBy" text="Submitted by"/></a>
						(<fmt:formatNumber value="${trackerItemStats.submitted}" />)
					</li>

					<!-- ctiActions is generated above and is in request! -->
					<c:set var="action" value="${_ctiActions.showOwnedByTrackerItems}"/>
					<c:if test="${! empty action}">
						<%-- The list of open task items owned by the user. --%>
						<li>
							<a href="${action.url}" onclick="${action.onClick}"><spring:message code="user.issues.supervisedBy" text="Owned by"/></a>
							(<fmt:formatNumber value="${trackerItemStats.supervised}" />)
						</li>
					</c:if>
				</ul>
			</div>
		</c:if>

		<c:if test="${isOwnUserPage}">

		<div class="block">
			<c:url var="link" value="/listSubscribes.spr">
			</c:url>

			<h4><spring:message code="user.subscriptions.label" text="Subscriptions"/></h4>

			<ul>
				<li>
					<a href="${link}?type=1"><spring:message code="user.subscribed.trackers" text="Subscribed Trackers"/></a>
					(<fmt:formatNumber value="${subscribedTrackers}" />)
				</li>
				<li>
					<a href="${link}?type=2"><spring:message code="user.subscribed.wikipages" /></a>
					(<fmt:formatNumber value="${subscribedWikipages}" />)
				</li>
				<li>
					<a href="${link}?type=3"><spring:message code="user.subscribed.documents" /></a>
					(<fmt:formatNumber value="${subscribedDocuments}" />)
				</li>
				<c:if test="${!empty trackerItemStats}">
					<li>
						<a href="${link}?type=4"><spring:message code="user.subscribed.workitems" /></a>
						(<fmt:formatNumber value="${trackerItemStats.subscribed}" />)
					</li>
				</c:if>
			</ul>
		</div>

		</c:if>
	</td>
</tr>
</tbody>
</table>
