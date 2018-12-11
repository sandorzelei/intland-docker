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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="doc_id" value="${param.doc_id}" />

<c:set var="canEditComment" value="false" />

<div class="actionBar">
	<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="artifactActions" subject="${documentRevision}">
		<table style="width: 100%;">
			<tbody style="border-spacing: 0px;">
			<tr style="border-spacing: 0px;">
				<td nowrap width="10%">
					<ui:actionLink keys="Add Comment" actions="${artifactActions}" />
				</td>
				<td align="right" style="padding-left: 10px;" width="10%">
					<ui:actionMenu actions="${artifactActions}" subject="${documentRevision}" keys="showcomments,showattachments,showcommentsattachments" inline="false" cssClass="actionLink commentsFilter" cssStyle="float: right;margin-right: 0px;">
						<a href="#"><spring:message code="comments.attachments.filter.label"/></a>
					</ui:actionMenu>
				</td>
			</tr>
			</tbody>
		</table>
	</ui:actionGenerator>
</div>

<jsp:include page="/docs/includes/commentsTable.jsp" flush="true">
	<jsp:param name="requestURI" value="/proj/doc/details.do"/>
</jsp:include>

