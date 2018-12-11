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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<div class="actionBar" style="height: 16px;"></div>

<%-- shows the content of the forks tab --%>
<c:choose>
	<c:when test="${repositoryModel.numForks != 0}">
		<jsp:include page="./repository-list.jsp?parentId=${repository.id}&showForks=false" />
	</c:when>
	<c:otherwise>
		<style type="text/css">
			#noForksInformation {
				margin-top: 15px;
				margin-bottom:0;
			}
			#noForksInformation a {
				margin: 0;
			}
		</style>
		<div id="noForksInformation" class="information">
			<spring:message code="scm.repository.has.no.forks" text="This repository has no forks."/>
			<c:if test="${! empty actions['fork']}">
				<c:set var="forkLink"><ui:actionLink actions="${actions}" keys="fork" /></c:set>
				<spring:message code="scm.repository.has.no.forks.can.create.new" arguments="${forkLink}" argumentSeparator="|no|"
					htmlEscape="false" />
				<br/>
			</c:if>
		</div>
	</c:otherwise>
</c:choose>

