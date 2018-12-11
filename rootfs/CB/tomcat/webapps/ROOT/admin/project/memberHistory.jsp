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

<display:table requestURI="" name="${history}" id="revision" cellpadding="0" sort="external" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator" style="width:98%">
	<display:setProperty name="paging.banner.placement" value="none"/>

	<spring:message var="statusLabel" code="document.status.label" text="Status"/>
	<display:column title="${statusLabel}" headerClass="textData" class="textData columnSeparator" style="width:10%" >
		<spring:message code="project.member.status.${revision.status.id eq 1 ? 'Submitted' : (revision.status.id eq 2 ? 'Rejected' : (revision.status.id eq 3 ? 'Accepted' : 'Resigned'))}" />
	</display:column>

	<spring:message var="dateLabel" code="document.createdAt.label" text="Date"/>
	<display:column title="${dateLabel}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" style="width:5%" />

	<spring:message var="userLabel" code="document.lastModifiedBy.short" text="by"/>
	<display:column title="${userLabel}" property="lastModifiedBy" headerClass="textData" class="textData columnSeparator" style="width:10%" />

	<spring:message var="commentLabel" code="association.description.label" text="Comment"/>
	<display:column title="${commentLabel}" property="comment" headerClass="textData" class="textDataWrap columnSeparator" />
</display:table>
