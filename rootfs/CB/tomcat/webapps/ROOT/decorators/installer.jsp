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
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.servlet.CBPaths" %>

<html>
	<head>
		<%@include file="includes/title.jsp" %>
		<c:if test="${!empty stylesheet}">
			<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/${stylesheet}" />" type="text/css"/>
		</c:if>

		<script type="text/javascript">
			var contextPath = '${pageContext.request.contextPath}';

			var cbApiUrl = '<%= CBPaths.CB_API_URL %>';
		</script>

		<link rel="icon" href="<ui:urlversioned value="/images/favicon.ico" />" type="image/png" />

	</head>
	<body class="newskin" >
		<decorator:body />
		<ui:delayedScript flush="true" />
	</body>
</html>
