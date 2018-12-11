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

<c:set var="artifactToApprove" value="${wikiPage}" scope="request" />
<jsp:include page="../docs/includes/artifactApprovals.jsp">
	<jsp:param name="forwardUrl" value="/proj/wiki/displayWikiPageProperties.spr?doc_id=${wikiPage.id}"/>
</jsp:include>
