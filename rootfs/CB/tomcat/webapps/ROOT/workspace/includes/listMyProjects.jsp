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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
<!--
	.favouriteWidget {
		margin-right: 0px;
	}
	.favouriteWidget img {
		margin-right: 2px;
	}

	#myProjects {
		margin: 20px;
		padding:0;
		width: 80%;
		list-style: none;
	}
	#myProjects > li {
		margin-bottom: 10px;
		float:left;
		width: 33%;
	}
	#myProjects > li a {
		position: relative;
		top: -2px;
	}

	.actionBar input[type='checkbox'] {
		padding: 0 3px;
	}

-->
</style>

<ul id="myProjects">
	<c:choose>
		<c:when test="${fn:length(myProjects) eq 0}">
			<spring:message code="project.selector.empty" text="No project available"/>.
		</c:when>

		<c:otherwise>
			<c:forEach items="${myProjects}" var="project">
				<c:choose>
					<c:when test="${project.deleted and showDeleted}">
						<c:url var="projectUrl" value="/proj/admin.spr">
							<c:param name="proj_id" value="${project.id}"/>
							<c:param name="options" value="IgnoreDeletedFlag"/>
						</c:url>
					</c:when>

					<c:otherwise>
						<c:url var="projectUrl" value="${project.urlLink}"/>
					</c:otherwise>
				</c:choose>

				<li>
					<ui:ajaxTagging entity="${project}" favourite="true"/>
					<a class="${project.styleClass}" href="${projectUrl}"><c:out value="${project.name}" /></a>
				</li>
			</c:forEach>
		</c:otherwise>
	</c:choose>
</ul>
<div style="clear: both;"></div>
