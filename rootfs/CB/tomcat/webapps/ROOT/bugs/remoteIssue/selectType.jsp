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
--%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.servlet.CBPaths" %>

<jsp:include page="header.jsp?step=selectType&stepIndex=2"></jsp:include>

<div class="container">
	<c:choose>
		<c:when test="${bugTrackerId == -1 && featureRequestTrackerId == -1 && questionTrackerId == -1}">
			<div class="information">
				<spring:message code="remote.issue.report.trackers.not.configured" text="No trackers are configured for remote issue reporting."/>
			</div>
		</c:when>
		<c:otherwise>
			<div class="info">
				<spring:message code="remote.issue.report.message" text="This wizard will create a new issue at {0}" arguments="<%= CBPaths.CB_API_URL %>"/>
				<spring:message code="remote.issue.report.selectType.description" text="Select which type of issue you wan't to create."/>
			</div>
			<form:form method="GET" commandName="addUpdateTaskForm">
				<form:hidden path="hostId"/>
				<form:hidden path="operatingSystem"/>
				<form:hidden path="releaseId"/>
				<form:hidden path="diskSpace"/>
				<form:hidden path="databaseType"/>
				<form:hidden path="memory"/>
                <div class="decisionRadioGroup">
                    <c:if test="${bugTrackerId != -1}">
                    	<div class="decisionRadio"><input type="radio" name="tracker_id" value="${bugTrackerId}" id="bugType" checked="checked"><label for="bugType" class="labelText"><spring:message code="tracker.type.Bug" text="Bug"/></label></div>
                    </c:if>
                    <c:if test="${featureRequestTrackerId != -1}">
                    	<c:if test="${bugTrackerId == -1}">
                    		<c:set var="checked" value="checked=\"checked\""></c:set>
                    	</c:if>
                    	<div class="decisionRadio"><input type="radio" name="tracker_id" value="${featureRequestTrackerId}" id="requestType" class="decisionRadio" ${checked}><label for="requestType" class="labelText"><!--
                    	 --><spring:message code="tracker.Feature\ Requests.label" text="Feature Request"/>
                    	</label></div>
                    </c:if>
                    <c:if test="${questionTrackerId != -1}">
                        <c:if test="${bugTrackerId == -1 && featureRequestTrackerId == -1}">
                            <c:set var="checkedQuestion" value="checked=\"checked\""></c:set>
                        </c:if>
                        <div class="decisionRadio"><input type="radio" name="tracker_id" value="${questionTrackerId}" id="questionType" class="decisionRadio" ${checkedQuestion}><label for="questionType" class="labelText"><!--
                         --><spring:message code="tracker.Questions.label" text="Question"/>
                        </label></div>
                    </c:if>
                </div>
				<spring:message code="post.installer.navigation.next.label" text="Next" var="nextLabel"/>
				<input type="submit" value="${nextLabel}" class="button"/>
			</form:form>
		</c:otherwise>
	</c:choose>

	<jsp:include page="footer.jsp?step=selectType"></jsp:include>
</div>

