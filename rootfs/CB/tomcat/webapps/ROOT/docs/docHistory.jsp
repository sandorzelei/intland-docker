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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmRestore(ver) {
	var msg = '<spring:message javaScriptEscape="true" code="docs.history.restore" />';
	msg = msg.replace(/\{0\}/, ver);
	return confirm(msg);
}
// -->
</SCRIPT>

<style type="text/css">
	.StatusHeaderClass {
		padding-right: 5px !important;
	}
</style>

<div class="actionBar">
	<c:if test="${empty documentRevision.baseline}" >
		<ui:rightAlign>
			<jsp:attribute name="filler">
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<div class="descriptionText"><spring:message code="document.version.restore.hint" text="To restore a version, use the tooltip menu beside the version number that you wish to restore"/></div>
			</jsp:attribute>
			<jsp:body>
			</jsp:body>
		</ui:rightAlign>
	</c:if>
</div>
<c:url var="propertiesURL" value="/proj/doc/details.do">
	<c:param name="doc_id" value="${document.id}" />
</c:url>

<ui:displaytagPaging defaultPageSize="${pagesize}" items="${docRevisions}" excludedParams="page"/>

<display:table name="${docRevisions}" id="revision" requestURI="/proj/doc/details.do" excludedParams="orgDitchnetTabPaneId"
			sort="external" defaultsort="1" defaultorder="descending" cellpadding="0" export="false"
			decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">

	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty docRevisions.list ? 'none' : 'bottom'}"/>

	<ui:actionGenerator builder="artifactHistoryActionMenuBuilder" actionListName="actions" subject="${revision}">

	<spring:message var="versionLabel" code="document.version.label" text="Version"/>
	<display:column title="${versionLabel}" sortProperty="sortVersion" headerClass="numberData" class="numberData" media="html" style="width:5%">
		<c:if test="${!empty document.additionalInfo.publishedRevision}">
			<c:choose>
				<c:when test="${revision.version eq document.additionalInfo.publishedRevision}">
					<span class="subtext"><spring:message code="document.version.published" text="(Published)"/></span>
				</c:when>
			 	<c:when test="${revision.version eq document.version}">
					<span class="subtext approvableArtifact"><spring:message code="document.version.pending" text="(Pending)"/></span>
				</c:when>
			</c:choose>
		</c:if>

		<c:set var="clickAction" value="${actions['displayRevision']}" />
		<c:if test="${! empty clickAction}">
        	<a href="${clickAction.url}" title='${clickAction.toolTip}' onclick="${clickAction.onClick}"><c:out value="${revision.version}" /></a>&nbsp;
	    </c:if>
	</display:column>

	<display:column title="${versionLabel}" property="version" headerClass="numberData" class="numberData" media="excel xml csv pdf rtf" />

    <display:column media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu actions="${actions}" />
    </display:column>

	<spring:message var="versionDateLabel" code="document.createdAt.label" text="Date"/>
	<display:column title="${versionDateLabel}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" style="width:5%" />

	<spring:message var="versionCreatorLabel" code="document.createdBy.label" text="Created by"/>
	<display:column title="${versionCreatorLabel}" property="lastModifiedBy" headerClass="textData" class="textData columnSeparator" style="width:10%" />

	<spring:message var="versionCommentLabel" code="document.comment.label" text="Comment"/>
	<display:column title="${versionCommentLabel}" property="comment" headerClass="textData" class="textDataWrap columnSeparator" />

	<spring:message var="versionStatusLabel" code="document.status.label" text="Status"/>
	<display:column title="${versionStatusLabel}" property="status" headerClass="textData StatusHeaderClass" class="textData columnSeparator StatusClass"  style="width:10%;" />

	<spring:message var="versionSizeLabel" code="document.fileSize.label" text="Size"/>
	<display:column title="${versionSizeLabel}" property="fileSize" headerClass="SizeHeaderClass numberData" class="SizeClass numberData" style="width:5%"/>

	</ui:actionGenerator>
</display:table>

