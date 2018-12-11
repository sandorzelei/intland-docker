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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	JSP fragment renders an expandable box which will display the unidiff of a change/file

	parameters:
		request.diffChangeFile	- Contains the ScmChangeFileDto whose diff will be shown
 --%>
<ui:delayedScript avoidDuplicatesOnly="true">
<head>
<style type="text/css">
	.diffContainer {
		display: none;
	}
	.diffContainer .diff {
		background-color: white;
	}
	.diffContainer .diff td {
		padding: 0;
		font-size: 9pt;
	}
	.diffStats {
		display: none;
	}
	.linesAdded {
		color: #00a85d;
	}
	.linesRemoved {
		color:#b31317;
	}
</style>
</head>
</ui:delayedScript>

<%! int diffId=0; %>
<spring:message var="expandDiffTitle" code="scm.commit.expand.diff.label" text="Click here to expand/collapse diff"/>

<c:set var="diffId" value="<%=diffId++%>" />
<c:set var="diffElementId" value="diffElement_${diffId}" />
<c:set var="changeSet" value="${diffChangeFile.scmChangeSet}" />

<a href="#" class="toggleLink" style="background:none !important;" title="${expandDiffTitle}"
	onclick="showDiff.toggleDiff(this, null, true); return false;" rel="${diffElementId}"  >
	<span class="diffStats" id="${diffElementId}_stats" ></span>
</a>

<div class="diffContainer" id="${diffElementId}"
	scmChangeFilePath="${diffChangeFile.path}" scmChangeFileOldRevision="${diffChangeFile.oldRevision}" scmChangeFileNewRevision="${diffChangeFile.newRevision}"
></div>

<script type="text/javascript">
	showDiff.registerDiffPlaceHolder("${diffElementId}", "${changeSet.repository.id}", "<c:out value='${diffChangeFile.oldRevision}'/>", "<c:out value='${diffChangeFile.newRevision}'/>", "<c:out value='${diffChangeFile.path}'/>");
</script>





















