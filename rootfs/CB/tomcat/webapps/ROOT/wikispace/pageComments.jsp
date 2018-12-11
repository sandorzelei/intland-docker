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
 * $Revision: 23432:e1ea81dfd394 $ $Date: 2009-10-28 11:27 +0100 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<div class="actionBar">
	<ui:actionGenerator builder="wikiPageActionMenuBuilder" actionListName="artifactActions" subject="${wikiPage}">
		<ui:actionLink keys="comment" actions="${artifactActions}" />
	</ui:actionGenerator>
</div>

<!-- call the commentsTable, and pass the params -->
<c:set var="document" scope="request" value="${wikiPage}" />
<jsp:include page="/docs/includes/commentsTable.jsp" flush="true" />

