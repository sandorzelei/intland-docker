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
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<tag:catch>
<%-- fragment shows the SequentionTestSetLocked exception: if appears in the session scope --%>
<c:if test="${! empty sequentialTestSetLocked}">
	<%--
	<div class="ui-layout-center">
	--%>
		<div class="warning">
			<c:set var="lockerUserLink">
				<tag:userLink user_id="${sequentialTestSetLocked.lock.user.id}" />
			</c:set>
			<c:set var="lockedTestCaseLink">
				<c:set var="lockedTestCase" value="${sequentialTestSetLocked.lock.testCaseIssue}" />
				<a href="<c:url value='${ui:removeXSSCodeAndHtmlEncode(lockedTestCase.urlLink)}'/>">
					<c:out value="${ui:sanitizeHtml(lockedTestCase.name)}" />
				</a>
			</c:set>
			<spring:message code="testrunner.sequential.locked.by.somebody.else"
				arguments="${lockerUserLink}~${lockedTestCaseLink}" argumentSeparator="~"
				text="Can not run any tests in this Test Set, because an other user is also running this, and the execution of tests is sequential in this set..." />
		</div>
	<%--
	</div>
	--%>

	<c:remove var="sequentialTestSetLocked"/>
</c:if>
</tag:catch>
