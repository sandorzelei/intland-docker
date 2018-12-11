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
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<meta name="decorator" content="popup" />
<meta name="module" content="<c:out value='${command.module}'/>"/>
<meta name="bodyCSSClass" content="newskin" />
<meta name="useModuleDefaults" content="true"/>

<c:if test="${empty param.noNavigation }">
	<script type="text/javascript" src="<ui:urlversioned value='/diffviewer/JumpToDiff.js' />"></script>
</c:if>
<script type="text/javascript" src="<ui:urlversioned value='/diffviewer/diffViewer.js' />"></script>
<link rel="stylesheet" href="<ui:urlversioned value='/diffviewer/diffViewer.less' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<ui:pageTitle><c:out value='${pageTitle}' /></ui:pageTitle>
</ui:actionMenuBar>

<c:if test="${empty param.noNavigation }">
	<div class="floatingOverlay" id="findDiffButtonsPanel">
		<spring:message var="title" code="scm.diffviewer.button.next.diff.title" text="Jump to next difference" />
		<spring:message var="value" code="scm.diffviewer.button.next.diff.value" text="Next difference" />
		<input type="button" class="button" title="${title}" value="${value}" onclick="JumpToDiff.jumpToNext(); return false;" />
		&nbsp;
		<spring:message var="title" code="scm.diffviewer.button.prev.diff.title" text="Jump to previous difference" />
		<spring:message var="value" code="scm.diffviewer.button.prev.diff.value" text="Previous difference" />
		<input type="button" class="button" title="${title}" value="${value}" onclick="JumpToDiff.jumpToPrev(); return false;" />
	</div>
</c:if>

<spring:message var="revisionSelectTitle" code="scm.diffviewer.revisions.select.title" text="Select revision to compare!" />

<ui:actionBar id="actionBar1">
	<form:form method="GET" >
		<c:if test="${!command.hideActionBar}">
			<%-- all revisions are loaded via ajax, because this can be slow --%>
			<spring:message code="scm.diffviewer.comparing.revision" text="Comparing revision" />
			<form:select id="revision2" path="revision2" title="${revisionSelectTitle}" disabled="disabled" onchange="submitForm(this);" >
				<c:set var="rev"><c:out value="${command.revisionInfo2.revision}" /></c:set>
				<form:option value="${rev}"><c:out value='${rev}'/></form:option>
			</form:select>

			<spring:message code="scm.diffviewer.comparing.revision.and" text="and" />
			<form:select id="revision1" path="revision1" title="${revisionSelectTitle}" disabled="disabled" onchange="submitForm(this);" >
				<c:set var="rev"><c:out value="${command.revisionInfo1.revision}" /></c:set>
				<form:option value="${rev}"><c:out value='${rev}'/></form:option>
			</form:select>

			<script type="text/javascript">
			$(function(){
				fetchRevisions("<c:url value='${getRevisionsAjaxUrl}'/>");
			});
			</script>
		</c:if>

		<c:if test="${command.hideActionBar }">
			<input type="hidden" name="revision1" value="<c:out value='${command.revisionInfo1.revision}' />" />
			<input type="hidden" name="revision2" value="<c:out value='${command.revisionInfo2.revision}' />" />
			<input type="hidden" name="hideActionBar" value="${command.hideActionBar }"/>
		</c:if>

		<spring:message code="scm.diffviewer.display.as" text="display as" />
		<form:select path="diffRendererSelected" onchange="submitForm(this);">
			<c:forEach var="diffRenderer" items="${command.diffRenderers}" varStatus="status">
				<form:option value="${diffRenderer}"><spring:message code="scm.diffviewer.renderers.${diffRenderer}"/></form:option>
			</c:forEach>
		</form:select>

	<%--
		&nbsp;
		<spring:message var="title" code="scm.diffviewer.swap.button.title,value" text="Swap the two sides/versions" />
		<spring:message var="value" code="scm.diffviewer.swap.button.value" text="Swap" />
		<input type="submit" class="button" title="${title}" value="${value}" />
     --%>

		&nbsp;
		<spring:message var="title" code="scm.diffviewer.allowWrap.title" text="Allow some line wrapping" />
		<form:checkbox path="allowWrap" title="Allow some line wrapping" id="allowWrap"	/>
		<label for="allowWrap" ><spring:message code="scm.diffviewer.allowWrap.label" text="Allow wrapping"/></label>

		<%-- keep all params through request, can not use form:hidden because these are not always available in the command bean --%>
		<c:forEach var="keep" items="${command.parametersToKeep}">
			<c:if test="${! empty keep.value}">
				<input type="hidden" name="${keep.key}" value="<c:out value='${keep.value}'/>" />
			</c:if>
		</c:forEach>

		<c:if test="${not empty extraFields }">
			<c:forEach items="${extraFields }" var="field">
				<input type="hidden" name="${field.key }" value="${field.value }"/>
			</c:forEach>
		</c:if>
	</form:form>
</ui:actionBar>

<div id="diffContainer" class="diffRenderer_${command.diffRendererSelected}">${diff}</div>
