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
<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<head>
<style type="text/css">
	ul.submodules {
		margin: 0;
		padding: 0;
	}

	ul.submodules li {
		margin: 0;
		padding: 0;
		list-style: none;
		white-space: nowrap;
	}

	ul.submodules_branch {
		margin-left: 16px;
		padding: 0;
		list-style: none;
		white-space: nowrap;
	}
	.filterForm select, .filderForm label {
		margin-right: 1em;
	}
	.filterForm label input {
		margin-right: 0;
	}

	.branchOrTagImage {
		margin-left: 2px;width: 18px;
	}
	.branchOrTagImage img {
		border: none;
	}
</style>
</head>

<c:url var="actionURL" value="/repository/${repository.id}/branchesAndTags" />

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<div class="actionBar actionBarWithButtons">
	<form:form action="${actionURL}" cssClass="filterForm" method="GET" commandName="command">
		<label><spring:message code="scm.branchesortags.label" text="Branches, tags"/></label>
		<form:select path="branchTagFilter" >
			<form:option value="branch tag"><spring:message code="scm.branches-and-tags.label" text="Branches and Tags" /></form:option>
			<form:option value="branch"><spring:message code="scm.branches.label" text="Branches" /></form:option>
			<form:option value="tag"><spring:message code="scm.tags.label" text="Tags" /></form:option>
		</form:select>

		<label for="showDetails">
			<form:checkbox path="showDetails" id="showDetails"/>
			<spring:message code="scm.showdetails.label" text="Show Details"/>
		</label>

		<c:if test="${supportSubmodules}">
			<label for="showSubModules">
				<form:checkbox path="showSubModules" id="showSubModules"/>
				<spring:message code="scm.showsubmodules.label" text="Show Submodules"/>
			</label>
		</c:if>

		<spring:message var="goButton" code="search.submit.label" text="GO"/>
		<input style="margin-left:1em;" type="submit" class="button narrowButton" value="${goButton}"/>
	</form:form>
</div>

<display:table requestURI="${actionURL}" name="${repositoryTagsAndBranches}" id="symbol" cellpadding="0"
	pagesize="25" defaultsort="4" defaultorder="descending" excludedParams="repositoryId module orgDitchnetTabPaneId">

	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:setProperty name="basic.empty.showtable" value="false" />

	<display:column title=" " media="html" class="branchOrTagImage">
		<img src='<c:url value="/images/newskin/item/${symbol.isTag ? 'tag.png': 'branch.png'}" />' />
	</display:column>

	<spring:message var="nameTitle" code="scm.browse.name.label" text="Name"/>
	<display:column title="${nameTitle}" sortProperty="name" sortable="true" headerClass="textData" class="textData">
		<c:url var="url" value="${repository.filesUrlLink}">
			<c:param name="branchOrTag" value="${symbol.name}" />
		</c:url>
		<a href="${url}"><c:out value="${symbol.name}" /></a>
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu builder="scmTagBranchListContextActionMenuBuilder" subject="${symbol}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
	</display:column>

	<spring:message var="dateTitle" code="scm.browse.date.label" text="Date"/>
	<display:column title="${dateTitle}" sortProperty="date" sortable="true" headerClass="textData" class="dateData columnSeparator">
		<tag:formatDate value="${symbol.date}" />
	</display:column>

	<c:if test="${command.showSubModules && supportSubmodules}">
		<spring:message var="submodulesTitle" code="scm.submodule.submodules.title" text="Submodules"/>
		<spring:message var="pathAt" code="scm.submodule.submodule.path.at.label" text="at"/>

		<display:column title="${submodulesTitle}" sortable="false" headerClass="textData" class="textData columnSeparator" style="width: 35%;" escapeXml="false">
			<c:set var="submodulesOfTagOrBranch" value="${subAndSupermodules.submodules[symbol.name]}" />

			<c:choose>
				<c:when test="${empty submodulesOfTagOrBranch}">--</c:when>
				<c:otherwise>
					<ul class="submodules">
					<c:forEach var="subRepo" items="${submodulesOfTagOrBranch}">
						<li>
							<img border="0" src='<c:url value="/images/Uses-submodule.png" />' />&nbsp;<a href="<c:url value='${subRepo.repository.urlLink}'/>"><c:out value='${subRepo.repository.name}'/></a> ${pathAt} <b>/<c:out value='${subRepo.path}'/></b>
							<span class="subtext">${subRepo.submoduleRevision}</span>
							<c:choose>
								<c:when test="${empty subRepo.tagsAndBranches}">--</c:when>
								<c:otherwise>
									<ul class="submodules_branch">
									<c:forEach var="tagOrBranch" items="${subRepo.tagsAndBranches}" varStatus="status">
										<c:url var="fileUrl" value="${subRepo.repository.filesUrlLink}">
											<c:param name="branchOrTag" value="${tagOrBranch.name}" />
										</c:url>
										<li>
											<img border="0" src='<c:url value="/images/${tagOrBranch.tag ? 'Tag.png': 'Branch.png'}" />' />
											<a href="${fileUrl}"><c:out value='${tagOrBranch.name}'/></a>
										</li>
									</c:forEach>
									</ul>
								</c:otherwise>
							</c:choose>
						</li>
					</c:forEach>
					</ul>
				</c:otherwise>
			</c:choose>

		</display:column>

		<spring:message var="supermodulesTitle" code="scm.submodule.supermodules.title" text="Supermodules"/>
		<display:column title="Supermodules" sortable="false" headerClass="textData" class="textData columnSeparator" style="width: 35%;" escapeXml="false">
			<c:set var="supermodulesOfTagOrBranch" value="${subAndSupermodules.supermodules[symbol.name]}" />
			<c:choose>
				<c:when test="${empty supermodulesOfTagOrBranch}">--</c:when>
				<c:otherwise>
					<ul class="submodules">
					<c:forEach var="superRepo" items="${supermodulesOfTagOrBranch}">
						<li>
							<c:set var="subm" value="${superRepo.value}" />
							<c:set var="firstSymbol" value="${subm[0]}" />
							<img border="0" src='<c:url value="/images/Used-as-submodule.png" />' />&nbsp;<a href="<c:url value='${firstSymbol.superRepository.urlLink}' />"><c:out value='${firstSymbol.superRepository.name}'/></a>

							<ul class="submodules_branch">
								<c:forEach var="branchOrTagOfSupermodule" items="${subm}">
									<c:url var="fileUrl" value="${branchOrTagOfSupermodule.superRepository.filesUrlLink}">
										<c:param name="branchOrTag" value="${branchOrTagOfSupermodule.superRepositoryBranchOrTag.name}" />
									</c:url>
									<li>
										<img border="0" src='<c:url value="/images/${branchOrTagOfSupermodule.superRepositoryBranchOrTag.tag ? 'Tag.png': 'Branch.png'}" />' />
										<a href="${fileUrl}"><c:out value="${branchOrTagOfSupermodule.superRepositoryBranchOrTag.name}" /></a>
									</li>
								</c:forEach>
							</ul>
						</li>
					</c:forEach>
					</ul>
				</c:otherwise>
			</c:choose>

		</display:column>
	</c:if>

	<c:if test="${command.showDetails}">
		<spring:message var="authorTitle" code="scm.commit.author.label" text="Author"/>
		<display:column title="${authorTitle}" property="author" sortable="true"
			headerClass="textData" class="textData columnSeparator authorColumn" escapeXml="true" />

		<spring:message var="messageTitle" code="scm.commit.comment.label" text="Message"/>
		<display:column title="${messageTitle}" property="message" sortable="false"
			headerClass="textData expand" class="textDataWrap columnSeparator compact commitMessageColumn" escapeXml="true" />

		<spring:message var="revTitle" code="scm.browse.revision.label" text="Rev."/>
		<display:column title="${revTitle}" property="revision" sortable="false" headerClass="textData" class="textData columnSeparator"
			escapeXml="true"
		/>
	</c:if>
</display:table>
