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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="isWikiPageAssociations" scope="request" value="true" />

<tag:itemDependecy var="itemDependency" item_id="${wikiPage.id}" item_type_id="${GROUP_OBJECT}" item_rev="${pageRevision.baseline.id}" scope="request" />

<div class="actionBar">
	<ui:actionGenerator builder="wikiPageActionMenuBuilder" actionListName="artifactActions" subject="${wikiPage}">
		<ui:actionLink keys="Add Association" actions="${artifactActions}" />
	</ui:actionGenerator>
</div>

<jsp:include page="/association/associationList.jsp" flush="true"/>

