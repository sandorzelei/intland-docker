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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="association.unresolved.dependencies.label" text="Unresolved Dependencies" />
	</ui:pageTitle>
</ui:actionMenuBar>

<div class="contentWithMargins">
	<display:table htmlId="itemSelector" name="${items}" id="item" requestURI="" sort="external" cellpadding="0" decorator="decorator">
		<display:setProperty name="paging.banner.placement" value="${empty items ? 'none' : 'bottom'}"/>
	
		<display:column class="textData">
			<ui:wikiLink item="${item}" target="_blank" hideJumpToDocViewBadge="true" />	
		</display:column>
	</display:table>
</div>