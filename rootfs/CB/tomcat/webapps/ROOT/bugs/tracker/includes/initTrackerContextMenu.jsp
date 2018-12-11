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

<%--
Parameters:
  - isCategoryTracker
  - isAdvancedView
Output parameters (added to request):
  - actionBuilder
  - actionLinkKeys
  - actionKeys
  - viewsActionKeys
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="commonViewActions"
	   value="generateDocuments,[---],showTableView,showDocumentView,showDocumentViewExtended,showDashboardView,[---],coverageBrowser,riskMatrixDiagram${ empty branch ? ',testRunBrowser,traceabilityMatrix,traceabilityBrowser,traceability,transitionsGraph,classDiagram' : ''},[---],newBaseline,createBranch,sendToReview,sendSelectionToReview,sendMergeRequest,sendMergeRequestFromSelection,showPendingMergeRequests,[---],branchProperties,merge,mergeFromMaster,[---],createView,editView,setAsDefault,unsetAsDefault,duplicateView"/>

<c:set var="extraActions" value=""/>
<c:choose>
	<c:when test="${(selectedLayout eq 0) && !tracker.versionCategory && empty baseline}">
		<c:set var="extraActions"
			value=",cut,copy,paste,copyTo,moveTo,delete,restore,massEdit,[---]"/>
	</c:when>
	<c:when test="${(selectedLayout eq 0) && !tracker.versionCategory && not empty baseline}">
		<c:set var="extraActions"
			value=",copy,copyTo,[---]"/>
	</c:when>
</c:choose>

<c:choose>
	<c:when test="${param.isCategoryTracker}">
		<c:set var="actionBuilder" value="categoryListContextActionMenuBuilder" scope="request" />
		<c:set var="actionLinkKeys" value="fastAddTrackerItem, showBaselinesAndBranches, newTestRun" scope="request" />

		<c:set var="actionKeys"
			   value="customizeTracker,adminTrackerSubscriptions,versionStats,${empty branch ? 'Properties' : 'branchProperties'},[---],import,importFromWord,exportToWord, exportSelectionToWord,importFromDOORS,syncWithJIRA,[---],${commonViewActions},[---],configure,permaLink[---],referenceSettings,newBaseline,[---]${extraActions},referenceSettings,Lock,Unlock,Follow,[---],addTag"
			   scope="request"/>
		<c:set var="viewsActionKeys" value="" scope="request"/>
	</c:when>
	<c:otherwise>
		<c:set var="actionBuilder" value="trackerListContextActionMenuBuilder" scope="request"/>
		<c:set var="actionLinkKeys" value="fastAddTrackerItem, showBaselinesAndBranches" scope="request"/>

		<c:set var="actionKeys"
			   value="customizeTracker,adminTrackerSubscriptions,branchProperties,[---],import,importFromWord,exportToWord,exportSelectionToWord,importFromDOORS,syncWithJIRA,[---],${commonViewActions},[---],configure,permaLink,[---]${extraActions},referenceSettings,Lock,Unlock,Follow,[---],addTag"
			   scope="request"/>
		<c:set var="viewsActionKeys" value="" scope="request"/>

		<c:if test="${param.isAdvancedView}">
			<c:set var="viewsActionKeys" value="${commonViewActions}" scope="request"/>
		</c:if>
	</c:otherwise>
</c:choose>
