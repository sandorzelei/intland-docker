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
 *
 * $Revision$ $Date$
--%>

<%--
JSP fragments renders a repository "card" the main informations about a repository.

parameters:

- requestScope.repositoryModelBuilder 	The ScmRepositoryModelBuilder contains all ScmRepositoryModel/Dto hierarchy prepared for rendering
- requestScope.repositoryModel		    The current ScmRepositoryModel
- param.showForks	 	- Boolean if the forks are shown. Defaults to true
--%>
<%@page import="com.intland.codebeamer.remoting.GroupType"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<ui:delayedScript avoidDuplicatesOnly="true">
<head>
	<link rel="stylesheet" href="<ui:urlversioned value="/scm/includes/repository-card.css" />" type="text/css" media="all" />
</head>
</ui:delayedScript>

<c:set var="showingSameRepository" value="${repository == repositoryModel.dto}"/>
<c:set var="repository" value="${repositoryModel.dto}" />
<c:set var="showForks" value="${(empty param.showForks || param.showForks eq 'true') && repositoryModel.numForks > 0}"/>

<c:set var="pullRequestsLink">
	<a class="pullRequests ${repositoryModel.numPullRequests > 0 ? 'pendingRequests': ''}" href="<c:url value='${repository.urlLink}/pullrequests'/>">
		<spring:message code="scm.repository.num.pull.requests" text="{0} pending" arguments="${repositoryModel.numPullRequests}" />
	</a>
</c:set>
<c:set var="lastPushOrChangeLink">
	<%-- TODO: date would be nicer like "2 hours ago" --%>
	<c:set var="lastPushOrChangeDate" value="${repositoryModel.distributedScm? repositoryModel.lastPushDate : repositoryModel.lastChangeSetDate}"/>
	<a href="<c:url value='${repository.urlLink}/changesets'/>">
		<tag:formatDate value="${lastPushOrChangeDate}" />
	</a>
</c:set>
<c:choose>
	<c:when test="${repositoryModel.distributedScm}">
		<spring:message var="lastPushOrChangeLabel" code="scm.repository.last.push.label" text="Last push:"/>
	</c:when>
	<c:otherwise>
		<spring:message var="lastPushOrChangeLabel" code="scm.repository.last.change.label" text="Last commit:"/>
	</c:otherwise>
</c:choose>

<div class="repositoryCard ${compactRepositoryCard ? 'compactRepositoryCard' : ''}">
	<div class="header">
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<c:if test="${! compactRepositoryCard}">
					<ui:actionGenerator builder="scmRepositoryActionMenuBuilder" subject="${repository}"
							actionListName="actions" deniedKeys="newRepository">
						<ui:actionMenu actions="${actions}" cssClass="biggerMenuArrow" />
					</ui:actionGenerator>
				</c:if>
			</jsp:attribute>
			<jsp:attribute name="filler2">
				<span class="subtext repoInfo">
					<c:choose>
						<c:when test="${! compactRepositoryCard || repository.templateId == null}">
							<spring:message var="scmType" code="scmtype.${repository.type}.displayname" text="${repository.type}"/>
							<spring:message code="scm.repository.created.by" arguments="${scmType}"/>
						</c:when>
						<c:otherwise>
							<spring:message code="scm.repository.forked.by"/>
						</c:otherwise>
					</c:choose>
					<tag:userLink user_id="${repository.createdBy.id}" />
				</span>

				<c:if test="${compactRepositoryCard}">
					<c:if test="${repositoryModel.forkSupported}">
					<span class="repoInfo subtext">
						<spring:message code="scm.repository.num.pull.requests.label" text="Pull requests:"/>
						${pullRequestsLink}
					</span>
					</c:if>

					<span class="repoInfo subtext">
						${lastPushOrChangeLabel}
						${lastPushOrChangeLink}
					</span>
				</c:if>
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<c:if test="${module != 'notifications'}">
					<c:set var="entitySubscription" scope="request" value="${entitySubscriptions[repository.id]}" />
				</c:if>
				<jsp:include page="/includes/notificationBox.jsp" >
					<jsp:param name="entityTypeId" value="<%=com.intland.codebeamer.remoting.GroupType.SCM_REPOSITORY%>" />
					<jsp:param name="entityId" value="${repository.id}" />
				</jsp:include>
			</jsp:attribute>
			<jsp:body>
				<ui:coloredEntityIcon subject="${repository}" iconUrlVar="imgUrl" iconBgColorVar="iconBgColor"/>

				<%-- show the link to the repo only if this is not showing the same repository --%>
				<c:choose>
					<c:when test="${showingSameRepository}">
						<img style="background-color:${iconBgColor}; margin-right:2px; vertical-align:text-bottom;" src="<c:url value="${imgUrl}"/>">
						<span class="repoName"><c:out value="${repository.name}"/></span>
					</c:when>
					<c:otherwise>
						<a class="repoName" href="<c:url value='${repository.urlLink}'/>">
							<img style="background-color:${iconBgColor}; margin-right:2px; vertical-align:text-top;" src="<c:url value="${imgUrl}"/>">
							<c:out value="${repository.name}"/>
							</a><br/>
					</c:otherwise>
				</c:choose>
			</jsp:body>
		</ui:rightAlign>
		<c:if test="${param.showParent eq 'true' && (! empty repositoryModel.parentDto)}">
			<div class="parentRepositoryContainer">
				<spring:message code="scm.repository.forked.from" text="Forked from"/>
				<spring:message code="scm.repository.forked.from.link.tooltip" var="tooltip" />
				<a class="repoName" href="<c:url value='${repositoryModel.parentDto.urlLink}'/>" title="${tooltip}"><c:out value="${repositoryModel.parentDto.name}"/></a>
			</div>
		</c:if>
	</div>

	<div class="body">
		<div class="subtext repoDescription">
			<tag:transformText value="${repository.description}" format="${repository.descriptionFormat}" default="--" />
		</div>
		<c:if test="${!compactRepositoryCard}">

		<spring:message var="copy_hint" code="scm.repository.url.copy.to.clipboard.hint" />

		<table class="repoDetails">
			<tr>
				<c:choose>
					<c:when test="${empty repositoryModel.externalAccessUrl}">
						<td>
							<img src="<ui:urlversioned value='/images/newskin/action/repository-clone.png'/>" />
						</td>
						<td>
							<spring:message code="scm.repository.clone.label" text="Clone:"/>
						</td>
						<td class="stretch">
							<div class="pullURLs">
								<c:forEach var="pullSource" items="${repositoryModel.pullSources}">
									<c:remove var="urlStyle"/>
									<c:set var="sshUrl" value="${fn:startsWith(fn:toLowerCase(pullSource), 'ssh')}"></c:set>
									<c:set var="disabledBecauseMissingSSHKey" value="${(missingSSHKey && sshUrl)}" />
									<c:if test="${!canClone || disabledBecauseMissingSSHKey}">
										<c:set var="urlStyle" value="closedItem"/>
									</c:if>

									<c:if test="${disabledBecauseMissingSSHKey}">${addSSHKeyLink}</c:if>
									<c:choose>
										<c:when test="${disabledBecauseMissingSSHKey}">
											<spring:message var="add_key_hint" code='scm.repository.access.needs.public.ssh.key.icon'/>
											<a href="${addSSHKeyURL}" class="${urlStyle}" title="${add_key_hint}"><c:out value="${pullSource}"/></a>
										</c:when>
										<c:otherwise>
											<a href="${pullSource}" onclick="alert('${copy_hint}'); return false;" class="${urlStyle}"><c:out value="${pullSource}"/></a>
										</c:otherwise>
									</c:choose>
									<br/>
								</c:forEach>
							</div>
						</td>
					</c:when>
					<c:otherwise>
						<td>
							<img src="<ui:urlversioned value='/images/access-url.gif'/>" />
						</td>
						<td>
							<spring:message code="scm.repository.repositoryURL.label" />
						</td>
						<td class="stretch">
							<a href="${repositoryModel.externalAccessUrl}" onclick="alert('${copy_hint}'); return false;" ><c:out value="${repositoryModel.externalAccessUrl}"/></a>
						</td>
					</c:otherwise>
				</c:choose>
				<td>
					${lastPushOrChangeLabel}
				</td>
				<td class="stretch">
					${lastPushOrChangeLink}
				</td>
			</tr>
			<tr>
				<c:choose>
					<c:when test="${empty repositoryModel.externalAccessUrl}">
						<td>
							<img src="<ui:urlversioned value='/images/newskin/action/repository-push.png'/>" />
						</td>
						<td>
							<spring:message code="scm.repository.push.label" text="Push:"/>
						</td>
						<td>
							<div class="pushURLs">
								<c:forEach var="pushDestination" items="${repositoryModel.pushDestinations}">
									<c:remove var="urlStyle"/>
									<c:set var="disabledBecauseMissingSSHKey" value="${(missingSSHKey && fn:startsWith(fn:toLowerCase(pushDestination), 'ssh'))}" />
									<c:if test="${!canPush || disabledBecauseMissingSSHKey}">
										<c:set var="urlStyle" value="closedItem"/>
									</c:if>

									<a href="${pushDestination}" onclick="alert('${copy_hint}'); return false;" class="${urlStyle}"><c:out value="${pushDestination}"/></a>
									<c:if test="${disabledBecauseMissingSSHKey}">${addSSHKeyLink}</c:if>
									<br/>
								</c:forEach>
							</div>
						</td>
					</c:when>
					<c:otherwise>
						<td colspan="3"/>
					</c:otherwise>
				</c:choose>
				<td>
					<spring:message code="scm.repository.size.label" text="Size:"/>
				</td>
				<td>
					<a href="<c:url value="${repository.urlLink}/files"/>">${repositoryModel.repositorySize}</a>
				</td>
			</tr>
			<c:if test="${repositoryModel.forkSupported}">
			<tr>
				<td>
				</td>
				<td>
					<spring:message code="scm.repository.forks" text="Forks"/>:
				</td>
				<td>
					<spring:message var="forksTitle" code="scm.repository.forks.tooltip" text="Forks of '{0}'" arguments="${repository.name}" htmlEscape="true" />
					<spring:message var="toggleTitle" code="ui.tag.collapsingBorder.title" arguments="${forksTitle}" />
					<c:choose>
						<c:when test="${showForks}">
							<%-- onclick toggles the the collapsingborder below, plus toggles the look of this link --%>
							<a href="#" onclick="alert('toggling is disabled now!'); return false;"
									class="toggleLink" title="${toggleTitle}">
								${repositoryModel.numForks}
							</a>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${repositoryModel.numForks == 0}">
									<%-- when repo has no forks dont' show the link, because that would go to wrong page --%>
									${repositoryModel.numForks}
								</c:when>
								<c:otherwise>
									<a href="<c:url value='${repository.urlLink}/forks'/>">
										${repositoryModel.numForks}
									</a>
								</c:otherwise>
							</c:choose>
						</c:otherwise>
					</c:choose>
				</td>
				<td>
					<spring:message code="scm.repository.num.pull.requests.label" text="Pull requests:"/>
				</td>
				<td>
					${pullRequestsLink}
				</td>
			</tr>
			</c:if>
		</table>
		</c:if>
	</div>
</div>

<c:if test="${showForks}">
	<%-- render child/fork repos of this repo --%>
	<spring:message var="forksLabel" code="scm.repository.forks.label" text="Forks ({0})" arguments="${repositoryModel.numForks}" />
	<div class="forksContainer">
		<jsp:include page="./repository-list.jsp?parentId=${repository.id}" />
	</div>
</c:if>


