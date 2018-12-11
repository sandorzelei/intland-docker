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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="wikiModule"/>

<%--
	JSP page for selecting wikis to copy. This shows the wiki tree structure too.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ page import="com.intland.codebeamer.controller.wiki.copywiki.CopyWikiControllerSupport"%>

<c:set var="MOVE_DISABLED" value="<%=CopyWikiControllerSupport.MOVE_DISABLED%>" />
<c:set var="COPY_WIKI_SELECTION_OF_PAGES_DISABLED" value="<%=CopyWikiControllerSupport.COPY_WIKI_SELECTION_OF_PAGES_DISABLED%>" />

<c:choose>
<c:when test="${empty treeTopWikiPage}">
	<%-- this actually must never happen --%>
	<div class="actionBar">
		<spring:message var="closeButton" code="button.close" text="Close"/>
		<input type="button" class="button" value="${closeButton}" onclick="window.close();" />
	</div>
</c:when>
<c:otherwise>

<ui:actionMenuBar>
	<ui:pageTitle>
			<c:set var="args"><c:out value="${treeTopWikiPage.dto.name},${targetPage.name}"/></c:set>
			<c:choose>
				<c:when test="${COPY_WIKI_SELECTION_OF_PAGES_DISABLED}">
					<spring:message code="copywiki.paste.all.title" text="Paste a copy of Wiki page {0} and its children to page {1} recursively" arguments="${args}" />
				</c:when>
				<c:otherwise>
					<spring:message code="copywiki.paste.selected.title" text="Paste a copy of Wiki page {0} and its children to page {1} selectively" arguments="${args}" />
				</c:otherwise>
			</c:choose>
	</ui:pageTitle>
</ui:actionMenuBar>

<spring:message var="moveButton" code="action.move.label" text="Move"/>
<spring:message var="pasteButton" code="action.paste.label" text="Paste"/>
<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

<script type="text/javascript">
	function onMoveCheckboxChange(checkbox) {
		var submitButton = document.getElementById("submitButton");
		if (checkbox.checked) {
			submitButton.value = "${moveButton}";
		} else {
			submitButton.value = "${pasteButton}";
		}
	}
	function confirmPaste() {
		<c:if test="${COPY_WIKI_SELECTION_OF_PAGES_DISABLED}">return true;</c:if>
		return submitIfSelected(form, 'sourceReferences');
	}
</script>

<form:form >
	<ui:actionBar>
		<input type="submit" class="button" id="submitButton" value="${pasteButton}" onclick="return confirmPaste();" />&nbsp;&nbsp;
		<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />

		<c:if test="${! MOVE_DISABLED}">
			&nbsp;&nbsp;
			<spring:message var="moveHint" code="copywiki.move.hint" text="Check if you want to Move the selected pages."/>
			<form:checkbox path="move" title="${moveHint}" onclick="onMoveCheckboxChange(this);" cssStyle="vertical-align:bottom;" />${moveButton}
		</c:if>
	</ui:actionBar>

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	<div class="hint">
		<c:set var="targetPageName"><c:out value="${targetPage.name}"/></c:set>
		<c:choose>
			<c:when test="${COPY_WIKI_SELECTION_OF_PAGES_DISABLED}">
				<spring:message code="copywiki.paste.all.hint" text="The pages shown below will become new children of the page {0}" arguments="${targetPageName}" />
			</c:when>
			<c:otherwise>
				<spring:message code="copywiki.paste.selected.hint" text="Please select from the pages below, which of them should be actually pasted as new children of {0}" arguments="${targetPageName}" />
			</c:otherwise>
		</c:choose>
	</div>

	<c:set var="topNodeId" value="${treeTopWikiPage.versionReference}" />
	<c:if test="${COPY_WIKI_SELECTION_OF_PAGES_DISABLED}">
		<input type="hidden" name="sourceReferences" value="${topNodeId}" />
	</c:if>

	<ui:wikiStructureBrowser
		topNodeId = "${topNodeId}"
		projectId = "${treeTopWikiPage.dto.project != null ? treeTopWikiPage.dto.project.id : '' }"
		topNodeLink = ""
		topNodeLabel = "${treeTopWikiPage.dto.name}"
		treeType="CopyWikiTree"
		multiSelection="true"
		showSelectors="${! COPY_WIKI_SELECTION_OF_PAGES_DISABLED}"
		inputName="sourceReferences"
		ajaxRequestParams="topNodeId=${topNodeId}&revision=${empty treeTopWikiPage.baseline ? '' : treeTopWikiPage.baseline.root.id}"
	/>
</form:form>

</c:otherwise>
</c:choose>