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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=agreement"/>

<div class="la-body">
	<pre class="la-body-text"><jsp:include page="/installer/includes/LICENSE.txt" />
	
	</pre>
</div>

	<form:form method="POST">
		<jsp:include page="includes/footer.jsp?step=agreement"/>
	</form:form>
	
</div>

