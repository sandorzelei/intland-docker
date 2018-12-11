<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="trackersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/search.css' />" type="text/css"/>

<style type="text/css">
	#items {
		width: 95% !important
	}
</style>

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false">
		<c:choose>
			<c:when test="${type == 'RiskMatrixDiagram'}">
				<c:if test="${!basedOnRequirement}">
					<spring:message code="tracker.type.Risk.plural" text="Risks"/>
				</c:if>
				<c:if test="${basedOnRequirement && isReqTracker}">
					<spring:message code="tracker.type.Requirement.plural" text="Requirements"/>
				</c:if>
				<c:if test="${basedOnRequirement && isUserStoryTracker}">
					<spring:message code="tracker.type.User Story.plural" text="User Stories"/>
				</c:if>
				<c:if test="${basedOnRequirement && isRiskTracker}">
					<spring:message code="tracker.riskMatrix.relatedItem.reqOrUserStory" text="Requirements/User Stories"/>
				</c:if>
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.type.Item.plural" text="Items" />
			</c:otherwise>
		</c:choose>
	</ui:pageTitle>
</ui:actionMenuBar>

<ui:displaytagPaging defaultPageSize="${pageSize}" items="${trackerItems}" excludedParams="page"/>

<display:table htmlId="items" name="${trackerItems}" id="item" requestURI="" sort="external" cellpadding="0">
	<display:setProperty name="paging.banner.items_name">
		<c:choose>
			<c:when test="${type == 'RiskMatrixDiagram'}">
				<c:if test="${!basedOnRequirement}">
					<spring:message code="tracker.type.Risk.plural" text="Risks"/>
				</c:if>
				<c:if test="${basedOnRequirement && isReqTracker}">
					<spring:message code="tracker.type.Requirement.plural" text="Requirements"/>
				</c:if>
				<c:if test="${basedOnRequirement && isUserStoryTracker}">
					<spring:message code="tracker.type.User Story.plural" text="User Stories"/>
				</c:if>
				<c:if test="${basedOnRequirement && isRiskTracker}">
					<spring:message code="tracker.riskMatrix.relatedItem.reqOrUserStory" text="Requirements/User Stories"/>
				</c:if>
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.type.Item.plural" text="Items"/>
			</c:otherwise>
		</c:choose>
	</display:setProperty>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found" value=""/>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty trackerItems.list ? 'none' : 'bottom'}"/>

	<spring:message var="itemId" code="issue.id.label" text="Id"/>
	<c:if test="${showID}">
		<display:column title="${itemId}" property="id" sortable="true" headerClass="textData" class="textData columnSeparator"/>
	</c:if>

	<%-- Display project name and code if type is RiskMatrixDiagram --%>
	<c:if test="${type == 'RiskMatrixDiagram'}">
		<display:column title="${itemId}" headerClass="textDataWrap" class="textDataWrap columnSeparator referenceSelectLessImportant">
			<c:out value="${item.getTracker().getProject().getName()}" /> → <c:out value="${item.getKeyAndId()}" />
		</display:column>
	</c:if>

	<c:choose>
		<c:when test="${type == 'RiskMatrixDiagram'}">
			<c:if test="${!basedOnRequirement}">
				<spring:message var="itemLabel" code="tracker.type.Risk" text="Risk"/>
			</c:if>
			<c:if test="${basedOnRequirement && isReqTracker}">
				<spring:message var="itemLabel" code="tracker.type.Requirement" text="Requirement"/>
			</c:if>
			<c:if test="${basedOnRequirement && isUserStoryTracker}">
				<spring:message var="itemLabel" code="tracker.type.User Story" text="User Story"/>
			</c:if>
			<c:if test="${basedOnRequirement && isRiskTracker}">
				<spring:message var="itemLabel" code="tracker.riskMatrix.relatedItem.reqOrUserStory" text="Requirements/User Stories"/>
			</c:if>
		</c:when>
		<c:otherwise>
			<spring:message var="itemLabel" code="tracker.type.Item" text="Item"/>
		</c:otherwise>
	</c:choose>
	<display:column title="${itemLabel}" headerClass="textDataWrap" class="textDataWrap columnSeparator">
		<a href="${contextPath}/issue/${item.id}" target="_blank"><c:out value="${item.name}"/></a>
	</display:column>

	<%-- Show related risks/requirements if type is RiskMatrixDiagram --%>
	<c:if test="${type == 'RiskMatrixDiagram'}">
		<spring:message var="riskLabel" code="tracker.type.Risk.plural" text="Risks"/>
		<spring:message var="requirementsLabel" code="tracker.type.Requirement.plural" text="Requirements"/>
		<c:if test="${!basedOnRequirement}">
			<spring:message var="relatedItemTitle" code="tracker.riskMatrix.relatedItem.reqOrUserStory" text="Requirements/User Stories"/>
		</c:if>
		<c:if test="${basedOnRequirement}">
			<spring:message var="relatedItemTitle" code="tracker.type.Risk.plural" text="Risks"/>
		</c:if>
		<display:column title="${relatedItemTitle}" headerClass="textDataWrap" class="textDataWrap">
			<c:set var="riskItems" value="${itemsMap[item]}"></c:set>
			<c:choose>
				<c:when test="${empty riskItems}">
					<spring:message code="tracker.riskMatrix.no.relations" text="No relations found."/>
				</c:when>
				<c:otherwise>
					<c:forEach var="riskItem" items="${riskItems}" varStatus="status">
						<a href="${contextPath}/issue/${riskItem.id}" target="_blank"><c:out value="${riskItem.name}"/></a><c:if test="${not status.last}">, </c:if>
					</c:forEach>
				</c:otherwise>
			</c:choose>
		</display:column>
	</c:if>

</display:table>
