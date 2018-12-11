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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	div.version {
		position: relative;
		top: 15%;
	}

	div.version span {
		color: #2b2b2b;
		font-weight: normal;
	}

	.actionBar .filter-label {
		margin-right: 5px;
		color: #666666;
	}

	.actionBar .filter-label.last {
		margin-left: 10px;
	}

</style>

<c:choose>
	<c:when test="${headRevision}">
		<c:set var="referrerURI" value="${requestURI}?orgDitchnetTabPaneId=task-referring-issues&refType=${refType}"/>
	</c:when>

	<c:otherwise>
		<c:set var="referrerURI" value="${requestURIRevision}&orgDitchnetTabPaneId=task-referring-issues&refType=${refType}"/>
	</c:otherwise>
</c:choose>


<c:url var="refTypeSelectorURL" value="${requestURIRevision}">
	<c:param name="orgDitchnetTabPaneId" value="task-referring-issues"/>
	<c:param name="viewId"  			 value="${view.id}"/>
</c:url>

<c:url var="viewSelectorURL" value="${requestURIRevision}">
	<c:param name="orgDitchnetTabPaneId" value="task-referring-issues"/>
	<c:param name="refType"				 value="${refType}"/>
</c:url>


<script language="JavaScript" type="text/javascript">

function submitRefType(selector) {
	if (selector != null) {
		location.href='${refTypeSelectorURL}&refType=' + selector.value;
		return false;
	}
}

function submitView(selector) {
	if (selector != null) {
		location.href='${viewSelectorURL}&viewId=' + selector.value;
		return false;
	}
}
</script>

<c:choose>
	<c:when test="${headRevision}">
		<div class="actionBar">
			<ui:rightAlign>
				<jsp:attribute name="filler">
				</jsp:attribute>
				<jsp:attribute name="rightAligned">
					<div class="version" style="float: right; height:1.2em;background-color: transparent; border: 0px;margin-bottom:0px;">
						${decorated.referringIssuesProgressInfo}
					</div>

					<table style="float: left; margin-right: 20px; magin-left:-30px;">
						<tr valign="middle">
							<td valign="middle" width="100%" nowrap>
								<span class="filter-label"><spring:message code="issue.references.type.filter.label" text="Tracker Type"/></span>

								<select name="refType" size="1" onchange="submitRefType(this)">
									<c:forEach items="${refTypes}" var="option">
												<option value="${option.value}" <c:if test="${refType eq option.value}"> selected="selected" </c:if> >
													<c:out value="${option.label}"/>
												</option>
									</c:forEach>
								</select>

								<span class="filter-label last"><spring:message code="issue.references.status.filter.label" text="Status"/></span>

								<select name="viewId" size="1" onchange="submitView(this)">
									<c:forEach items="${views}" var="choice">
												<option value="${choice.id}" <c:if test="${view != null and view.id eq choice.id}"> selected="selected" </c:if> >
													<spring:message code="issue.flags.${choice.name}.label" text="${choice.name}" htmlEscape="true"/>
												</option>
									</c:forEach>
								</select>

								<c:if test="${headRevision}">
								&nbsp;

								</c:if>
							</td>
						</tr>
					</table>
				</jsp:attribute>
			</ui:rightAlign>
		</div>
		<bugs:displaytagTrackerItems htmlId="referringIssues" decorator="${referringIssuesDecorator}" layoutList="${referringIssuesColumns}" items="${referringIssues}" selection="false" export="false"
									 browseTrackerMode="true" clearNavigationList="false" requestURI="${referrerURI}&viewId=${view.id}" excludedParams="orgDitchnetTabPaneId viewId refType filter page" includeBaselineInTtId="true"
		/>
	</c:when>
	<c:otherwise>
		<div class="information">
			<spring:message code="issue.references.baseline.label" text="References tab is not available in Baseline mode. Please use the Traceability accordion." htmlEscape="true"/>
		</div>
	</c:otherwise>
</c:choose>

