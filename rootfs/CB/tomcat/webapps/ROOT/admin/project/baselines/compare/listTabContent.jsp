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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>

<tag:formatDate value="${first.dto.createdAt}" var="formattedFirstDate" />
<tag:formatDate value="${second.dto.createdAt}" var="formattedSecondDate" />

<ct:call object="${baselineRenderer}" method="getDescription" return="oldBaselineDesc" param1="${first.dto}" param2="${baselineDecorator}" />

<c:set var="oldBaselineHeader">
	<jsp:include page="baselineHeader.jsp">
		<jsp:param name="name" value="${first.dto.name}" />
		<jsp:param name="url" value="${not empty first.dto.id ? pageContext.request.contextPath.concat(first.dto.urlLink) : ''}" />
		<jsp:param name="description" value="${oldBaselineDesc}" />
		<jsp:param name="createdBy" value="${first.dto.owner.name}" />
		<jsp:param name="formattedCreatedDate" value="${formattedFirstDate}" />
	</jsp:include>
</c:set>

<ct:call object="${baselineRenderer}" method="getDescription" return="newBaselineDesc" param1="${second.dto}" param2="${baselineDecorator}" />

<c:set var="newBaselineHeader">
	<jsp:include page="baselineHeader.jsp">
		<jsp:param name="name" value="${second.dto.name}" />
		<jsp:param name="url" value="${not empty second.dto.id ? pageContext.request.contextPath.concat(second.dto.urlLink) : ''}" />
		<jsp:param name="description" value="${newBaselineDesc}" />
		<jsp:param name="createdBy" value="${second.dto.owner.name}" />
		<jsp:param name="formattedCreatedDate" value="${formattedSecondDate}" />
	</jsp:include>
</c:set>

<display:table requestURI="" id="diff" name="${diffs}" cellpadding="0" export="false" decorator="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator">

	<display:setProperty name="export.csv.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
	<display:setProperty name="export.excel.decorator" value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
	<display:setProperty name="export.xml.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
	<display:setProperty name="export.pdf.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />
	<display:setProperty name="export.rtf.decorator"   value="com.intland.codebeamer.ui.view.table.ArtifactDiffDecorator" />

	<display:setProperty name="paging.banner.placement" value="bottom" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />

	<display:column title="${oldBaselineHeader}" property="oldRevisionWithVersionAndMenu" headerClass="withRightSeparator textData containsBaselineInfo" class="withRightSeparator textData containsDiffDescriptor" style="width:30%" />

	<display:column media="html" title="${newBaselineHeader}" property="newRevisionWithVersionAndMenu" headerClass="withRightSeparator textData containsBaselineInfo" class="withRightSeparator textData containsDiffDescriptor" style="width:30%" />

	<spring:message var="actionTitle" code="issue.history.action.label" text="Action"/>
	<display:column title="${actionTitle}" property="action" headerClass="textData" class="actionCell textData columnSeparator" style="width:5%" />

	<spring:message var="changeComment" code="document.comment.label" text="Comment"/>
	<display:column title="${changeComment}" property="comment" headerClass="textData expand" class="commentCell textData columnSeparator" style="width:15%" />

	<spring:message var="lastModifiedAt" code="document.lastModifiedBy.tooltip" text="Last modified by"/>
	<display:column title="${lastModifiedAt}" media="html" headerClass="dateData lastmodifiedheader" class="lastModifiedByCell dateData columnSeparator" style="width:5%">
		<c:if test="${diff.dto != null && diff.dto.lastModifiedBy != null && diff.dto.lastModifiedAt != null}">
			<ui:submission userId="${diff.dto.lastModifiedBy.id}" userName="${diff.dto.lastModifiedBy.name}" date="${diff.dto.lastModifiedAt}"/>
		</c:if>
	</display:column>

</display:table>
