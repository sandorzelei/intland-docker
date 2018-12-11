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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="taglib" prefix="tag" %>

<c:set var="sendMode" value="${not empty sendPullRequestForm}"/>
<c:if test="${empty formId}">
	<c:set var="formId" value="sendPullRequestForm"/>
</c:if>
<c:if test="${empty autoSubmit}">
	<c:set var="autoSubmit" value="true"/>
</c:if>

<c:if test="${sendMode}">
	<script type="text/javascript">
		function pickSourceLastRevision(sourceLastRevision) {
			$('#${formId} #pullRequest\\.sourceLastRevision').val(sourceLastRevision);
			$('#${formId} #sourceLastRevisionPicked').val('true');
			<c:if test="${autoSubmit}">
				$('#${formId}').submit();
			</c:if>
		}
	</script>
</c:if>

<div class="actionBar" style="margin-bottom: 15px;"></div>

<display:table class="expandTable" name="changeSets" id="changeSet" cellpadding="0" defaultsort="1" defaultorder="descending" export="false">
	<spring:message var="authorTitle" code="scm.commit.author.label" text="Author"/>
	<display:column title="${authorTitle}" sortProperty="submittedAt" headerClass="textData" class="textData columnSeparator">
		<ui:changeSetAuthor changeSet="${changeSet}"/>
	</display:column>
	<spring:message var="commentTitle" code="scm.commit.comment.label" text="Comment"/>
	<display:column title="${commentTitle}" headerClass="expandText textData" class="expandText textDataWrap columnSeparator">
		<pre class="commitmessage"><c:out value="${changeSet.message}"/></pre>
		<c:if test="${not empty changeSet.revision}">
			<span class="subtext">
				<spring:message code="scm.commit.revision.label" text="revision"/> <a href="<c:url value="${changeSet.urlLink}"/>">${changeSet.revision}</a>
				<%-- display last revision selector in Send mode --%>
				<c:if test="${(sendMode) && (sendPullRequestForm.pullRequest.sourceLastRevision != changeSet.revision) && !showRadio}">
					<span style="margin-left: 2em;">[ <a href="#" onclick="javascript:pickSourceLastRevision('${changeSet.revision}'); return false;">include only until this revision</a> ]</span>
				</c:if>
				<c:if test="${sendMode && showRadio}">
					<form:radiobutton path="pullRequest.sourceLastRevision" value="${changeSet.revision}"/>
				</c:if>
				
			</span>
		</c:if>
	</display:column>

	<spring:message var="submittedAtTitle" code="issue.submittedAt.label" text="Submitted"/>
	<spring:message var="tasksTitle" code="scm.commit.tasks.label" text="Tasks"/>

	<display:column title="${tasksTitle}" headerClass="textDataWrap" class="textDataWrap columnSeparator">
		<tag:joinLines>
			<c:choose>
				<c:when test="${fn:length(changeSet.trackerItems) > 0}">
					<c:forEach items="${changeSet.trackerItems}" var="trackerItem" varStatus="status">
						<tag:formatDate var="submittedAt" value="${trackerItem.submittedAt}" />

						<c:set var="styleClass" value="${trackerItem.closed ? 'closedItem' : ''}" />

						<c:url var="issueUrl" value="${trackerItem.urlLink}" />
						<a class="${styleClass}" href="${issueUrl}" title='<c:out value="${trackerItem.summary}; ${submittedAtTitle}: ${submittedAt}" />'><c:out value="${trackerItem.keyAndId}" /></a><c:if test="${!status.last}">,</c:if>
					</c:forEach>
				</c:when>
				<c:otherwise>
					--
				</c:otherwise>
			</c:choose>
		</tag:joinLines>
	</display:column>
</display:table>
