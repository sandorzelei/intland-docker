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
<%@ taglib uri="uitaglib" prefix="ui" %>

<%-- JSP fragment shows action menubar and links for the Tags pages
	This expects following params:
	title	The title for the Tags
--%>
	<c:set var="actionMenuBodyPart">
		<ui:breadcrumbs strongBody="true">
			<ui:pageTitle>${param.title}</ui:pageTitle>
		</ui:breadcrumbs>
	</c:set>
<ui:actionMenuBar showGlobalMessages="${empty param.showGlobalMessages || param.showGlobalMessages == 'true'}">
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>		
