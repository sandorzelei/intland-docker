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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>

<jsp:include page="includes/head.jsp"></jsp:include>


<div class="form-container">
	<jsp:include page="includes/header.jsp?step=showBranchDiff&stepIndex=2"/>

	<form:form method="POST" modelAttribute="createReviewForm">
		<%-- the merge forms are not editable in this step --%>
		<c:set var="disableEditing" value="true" scope="request"/>
		<%-- <jsp:include page="/bugs/tracker/branching/branchDiff.jsp?noActionMenuBar=true&isPopup=true"></jsp:include> --%>

		${branchDiffHtml}

		<%-- do not show the next button if there are no differences in the tracker items --%>
		<c:set var="noDiff" value="${empty divergedItems and empty createdOnBranch and empty deletedOnBranch }"/>
		<jsp:include page="includes/footer.jsp?step=showBranchDiff&nextStep=previewSelection&noNext=${noDiff }"/>
	</form:form>
</div>
