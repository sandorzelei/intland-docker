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

<jsp:include page="header.jsp?step=login&stepIndex=1"></jsp:include>

<div class="container">
	<form:form commandName="userForm" autocomplete="off">
		<jsp:include page="/admin/userFormTable.jsp"></jsp:include>
	</form:form>

	<jsp:include page="footer.jsp?step=register"></jsp:include>
</div>

