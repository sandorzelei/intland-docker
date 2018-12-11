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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="changeSet" type="com.intland.codebeamer.persistence.dto.ScmChangeSetDto" required="true" description="Change set to render the author and/or pusher from." %>

<ui:submission userId="${changeSet.submitter.name eq changeSet.submitterName ? changeSet.submitter.id : -1}" userName="${changeSet.submitterName}" date="${changeSet.submittedAt}"/>

<c:if test="${changeSet.push != null && changeSet.push.submitterName != null}">
	<c:if test="${changeSet.push.submitterName != changeSet.submitterName}">
		<br/>
		<span class="subtext"><spring:message code="scm.commit.pusher.label" text="Pusher"/>:</span>&nbsp;
		<tag:userLink user_id="${changeSet.push.submitter.id}"/>
		<br/>
		<span class="subtext"><tag:formatDate value="${changeSet.push.submittedAt}"/></span>
	</c:if>
</c:if>

