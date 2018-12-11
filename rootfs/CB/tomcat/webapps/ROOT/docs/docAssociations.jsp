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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<tag:itemDependecy var="itemDependency" item_id="${document.id}" item_type_id="${document.typeId eq 16 ? GROUP_TRACKER : GROUP_OBJECT}" item_rev="${documentRevision.baseline.id}" scope="request" />

<div class="actionBar">
	<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="artifactActions" subject="${documentRevision}">
		<ui:actionLink keys="Add Association" actions="${artifactActions}" />
	</ui:actionGenerator>
</div>

<jsp:include page="/association/associationList.jsp" flush="true"/>
