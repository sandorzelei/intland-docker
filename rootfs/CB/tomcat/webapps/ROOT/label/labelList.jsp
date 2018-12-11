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
<meta name="decorator" content="main"/>
<meta name="module" content="labels"/>
<meta name="moduleCSSClass" content="newskin labelsModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script src="<ui:urlversioned value='/js/label/deleteLabelConfirm.js'/>"></script>

<spring:message var="title" code="tags.admin.title" text="Tag Administration ({0})" arguments="${fn:length(labels)}"/>
<jsp:include page="./includes/actionBar.jsp">
	<jsp:param name="title" value="${title}"/>
</jsp:include>

<style type="text/css">
	.displaytag {
		width: 98% !important;
	}
	#label {
  		border-bottom: 0px;
  	}
	#label .centered {
		text-align: center;
	}
	#label .leftaligned {
		text-align: left;
	}
	.leftaligned {
		padding-left: 10px;
	}
	.rightalignedth, .rightalignedtd {
		text-align: right;
	}
	.rightalignedth {
		padding-right: 5px !important;
	}
	.rightalignedth a {
		padding-right: 0px !important;
	}
	.rightalignedtd {
		padding-right: 22px !important;
	}
</style>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<ui:showErrors/>
<display:table name="${labels}" id="label" requestURI="showLabels.do" class="expandTable displaytag" cellpadding="0" defaultsort="1">

	<spring:message var="tagTitle" code="tag.label" text="Tag"/>
	<display:column title="${tagTitle}" sortProperty="displayName" sortable="true" headerClass="textData" class="textData" style="width:60%;">
		<c:url var="displayLabeledContentUrl" value="/proj/label/displayLabeledContent.do">
			<c:param name="labelId" value="${label.id}" />
		</c:url>
		<html:link href="${displayLabeledContentUrl}"><c:out value="${label.displayName}" /></html:link>
	</display:column>

	<display:column media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu builder="labelsPageContextActionMenuBuilder" subject="${label}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
	</display:column>

	<spring:message var="tagPopularity" code="tag.popularity.label" text="Popularity"/>
	<display:column title="${tagPopularity}" property="popularity" sortable="true" headerClass="centered numberData" class="centered numberData columnSeparator" style="width:10%;"/>

	<spring:message var="tagCreated" code="tag.createdAt.label" text="Created"/>
	<display:column title="${tagCreated}" sortProperty="createdAt" sortable="true" headerClass="dateData" class="dateData leftaligned" style="width:10%;">
		<tag:formatDate value="${label.createdAt}" />
	</display:column>

	<spring:message var="tagCreator" code="tag.createdBy.label" text="Creator"/>
	<display:column title="${tagCreator}" sortProperty="createdBy.name" sortable="true" headerClass="rightalignedth" class="rightalignedtd columnSeparator" style="width:10%;">
		<tag:userLink user_id="${label.createdBy.id}" />
	</display:column>

</display:table>
