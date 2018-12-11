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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

	<div class="actionBar">
		<ui:actionGenerator builder="wikiPageActionMenuBuilder" actionListName="artifactActions" subject="${wikiPage}">
			<ui:actionLink keys="addChildPage" actions="${artifactActions}" />
			<ui:actionComboBox keys="paste" actions="${artifactActions}" id="actionCombo"
				automaticJavascriptGeneration="true"
			/>
		</ui:actionGenerator>
	</div>

	<display:table requestURI="" defaultsort="1" export="${export}" cellpadding="0" name="${pageChildren}" id="childPage"
					decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">

		<spring:message var="pageName" code="document.name.label" text="Name"/>
		<display:column title="${pageName}" property="name" sortable="true" sortProperty="name" headerClass="textData expand" class="textData columnSeparator"/>

		<spring:message var="pageModified" code="document.lastModifiedAt.label" text="Modified at"/>
		<display:column title="${pageModified}" property="lastModifiedAt" sortable="true" sortProperty="sortLastModifiedAt" headerClass="dateData" class="dateData columnSeparator"/>

		<spring:message var="pageSize" code="document.fileSize.label" text="Size"/>
		<display:column title="${pageSize}" property="fileSize" sortable="true" sortProperty="sortFileSize" headerClass="numberData" class="numberData"/>

	</display:table>
