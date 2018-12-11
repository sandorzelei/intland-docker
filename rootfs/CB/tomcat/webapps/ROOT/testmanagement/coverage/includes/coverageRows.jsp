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
--%>

<%--
	Renders a set of rows in the coverage table
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="java.util.Map" %>

<ui:UserSetting var="coverageBrowserTreeWidth" setting="COVERAGE_BROWSER_TREE_WIDTH" defaultValue="300"/>
<ui:UserSetting var="newWindowTarget" setting="NEW_BROWSER_WINDOW_TARGET" />

<c:forEach items="${tree }" var="node">
	<c:set var="attr" value="${node.li_attr }"/>
	<c:set var="id" value="${node.id}"/>
	<c:set var="hasChildren" value="${not empty node.children }"/>
	<c:set var="isTestCase" value="${attr['trackerType'] == 'testcase' }"/>

	<tr data-tt-branch="${hasChildren }" class="${hasChildren ? (isTestCase ? 'expanded initialized' : 'collapsed') : '' } ${attr['trackerType']}" data-tt-id="${id}"
		data-tt-parent-id="${node.parentId ==  null ? param.nodeId : node.parentId}"  data-id="${attr['data-id'] != null ? attr['data-id'] : node.id }"
		data-level="${node.level }">
		<td class="firstColumn" style="width: ${coverageBrowserTreeWidth}px;">
			<%-- add an opener and set its padding if there are children for the item --%>
			<span class="indenter" style="padding-left: ${node.level * 19}px;">
			<c:if test="${hasChildren }">
				<a href="#">&nbsp;</a>
			</c:if>
			</span>

			<a href="<c:url value="${node.link}"/>" class="itemUrl ${attr['isBranchItem'] == 'true' ? 'branchItem' : '' }" data-id="${id}" target="${newWindowTarget}">
				<img style="background-color: ${attr['iconBgColor']};" src="${node.icon }" alt="icon" class="icon">
				<c:out value="${node.text}"/>

			</a>
			<c:if test="${not empty attr['branchBadge'] }">
				${attr['branchBadge'] }
			</c:if>
			<c:if test="${not empty attr['testCaseVersionBadge'] }">
				${attr['testCaseVersionBadge'] }
			</c:if>
		</td>

		<c:if test="${coverageForm.showColors}">
			<td class="colorColumn">
				${attr['color']}
			</td>
		</c:if>

		<td class="coverageColumn coverageStatus">
			<span class="coverageStatus ${attr['coverageClass'] }">${attr['reachedCoverage']}</span>
		</td>


		<c:if test="${coverageForm.recentRuns != 0}">
			<td class="runBy" style="width: 120px;">
				<tag:userLink user_id="${attr['assignees']}"></tag:userLink>
			</td>
		</c:if>

		<td class="totalColumn">
			${attr['total']}
		</td>

		<td class="runResult">
			<c:if test="${attr['trackerType'] == 'requirement' and attr['total'] != '0' }">
				<div class="miniprogressbar wideProgressBar" data-total="${attr['total'] }" data-passed="${attr['passed'] }"
					 data-partly-passed="${attr['partlyPassed'] }">
					 <%
					 	Map<String, String> attr = (Map<String, String>) pageContext.getAttribute("attr");

					 	int passed = Integer.valueOf(attr.get("passed")).intValue();
					 	int partlyPassed = Integer.valueOf(attr.get("partlyPassed")).intValue();
					 	int failed = Integer.valueOf(attr.get("failed")).intValue();
					 	int blocked = Integer.valueOf(attr.get("blocked")).intValue();
					 	double total = Integer.valueOf(attr.get("total")).doubleValue();

					 	int notRun = (int) total - passed - failed - blocked - partlyPassed;

					 	pageContext.setAttribute("passedWidth", (int) (passed / total * 100));
					 	pageContext.setAttribute("partlyPassedWidth", (int) (partlyPassed / total * 100));
					 	pageContext.setAttribute("failedWidth", (int) (failed / total * 100));
					 	pageContext.setAttribute("blockedWidth", (int) (blocked / total * 100));
					 	pageContext.setAttribute("notRunWidth", (int) (notRun / total * 100));
					 	pageContext.setAttribute("notRun", notRun);
					 %>
					<div class="testingProgressBarPassed barColumn" style="width:${passedWidth}%;">
						<span class="barLabel">${attr['passed'] != '0' ? attr['passed'] : ''}</span>
					</div>
					<div class="testingProgressBarPartlyPassed barColumn" style="width:${partlyPassedWidth}%;">
						<span class="barLabel">${attr['partlyPassed'] != '0' ? attr['partlyPassed'] : ''}</span>
					</div>
					<div class="testingProgressBarFailed barColumn" style="width:${failedWidth}%;">
						<span class="barLabel">${attr['failed'] != '0' ? attr['failed'] : ''}</span>
					</div>
					<div class="testingProgressBarBlocked barColumn" style="width:${blockedWidth}%;">
						<span class="barLabel">${attr['blocked'] != '0' ? attr['blocked'] : ''}</span>
					</div>
					<div class="progressBarLightGrey barColumn"  style="width:${notRunWidth}%;">
						<span class="barLabel">${notRun != 0 ? notRun : ''}</span>
					</div>
				</div>
			</c:if>
		</td>

		<c:if test="${command.recentRuns != 0}">
			<td class="runAt">
				${attr['runAt']}
			</td>
		</c:if>


	</tr>
</c:forEach>