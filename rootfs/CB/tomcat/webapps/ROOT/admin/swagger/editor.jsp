<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri = "http://java.sun.com/jsp/jstl/core" prefix = "c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script src="<ui:urlversioned value="/wro/swagger.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="/wro/swagger.css"/>">

<c:url value="/v2/swagger.json" var="swaggerJsonUrl" />

<!DOCTYPE html>
<html lang="en">
	<head>
    	<meta charset="UTF-8">
    	<link rel="icon" href="<ui:urlversioned value="/images/favicon.ico" />" type="image/png" />
    	<title><spring:message code="swagger.editor.title" /></title>
	</head>

	<body>
		<div id="swagger-editor" data-url="${swaggerJsonUrl}"></div>
	</body>
	
</html>
