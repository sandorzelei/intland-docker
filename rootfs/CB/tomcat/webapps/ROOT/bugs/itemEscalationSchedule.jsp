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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:choose>
	<c:when test="${!escalationLicenseEnabled}">
		<div class="warning">
			<spring:message code="tracker.escalation.no.license.warning" text="You cannot use this feature because you don't have the necessary license. To read more about this feature visit our <a href='https://codebeamer.com/cb/wiki/85612'>Knowledge base</a>."/>
		</div>
	</c:when>
	<c:otherwise>
		<display:table class="expandTable" name="${itemEscalations}" id="escalation" cellpadding="0" export="false" sort="external"
				decorator="com.intland.codebeamer.ui.view.table.TrackerItemEscalationDecorator">

			<spring:message var="predicateTitle" code="tracker.escalation.predicate.label" text="Predicate"/>
			<display:column escapeXml="true" title="${predicateTitle}" property="predicateName" headerClass="textData" class="textDataWrap columnSeparator" style="width:20%"/>

			<spring:message var="levelTitle" code="tracker.escalation.level.label" text="Level"/>
			<display:column title="${levelTitle}" property="level" headerClass="numberData" class="numberData columnSeparator" style="width: 2%"/>

			<spring:message var="anchorTitle" code="tracker.escalation.anchor.label" text="Anchor"/>
			<display:column title="${anchorTitle}" property="anchor" headerClass="textData" class="textData columnSeparator" style="width: 16%"/>

			<spring:message var="actionsTitle" code="tracker.escalation.actions.label" text="Actions"/>
			<display:column title="${actionsTitle}" property="actions" headerClass="textData" class="textDataWrap columnSeparator" />

			<spring:message var="dueAtTitle" code="tracker.escalation.dueAt.label" text="Due at"/>
			<display:column title="${dueAtTitle}" property="dueAt" headerClass="dateData" class="dateData columnSeparator" style="width: 5%"/>

			<spring:message var="firedTitle" code="tracker.escalation.fired.label" text="Fired"/>
			<display:column title="${firedTitle}" headerClass="textData" class="textData" style="width: 2%">
				<c:if test="${escalation.fired}">
					<img src="<c:url value='/images/choice-yes.gif'/>"/>
				</c:if>
			</display:column>

		</display:table>
	</c:otherwise>
</c:choose>


