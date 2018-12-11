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
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule"/>
<meta name="stylesheet" content="sources.css"/>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<c:set var="screenFilter" scope="request">
	<html:form action="/proj/sources/listFiles" method="GET" focus="name" styleClass="filterForm">
		<html:hidden property="proj_id" />

		<html:select property="pageSize" title="Page size below" style="margin-right:0.5em;">
			<html:option value="25">Show &nbsp;25</html:option>
			<html:option value="50">Show &nbsp;50</html:option>
			<html:option value="100">Show 100</html:option>
			<html:option value="500">Show 500</html:option>
			<html:option value="-1">Show All</html:option>
		</html:select>

		<label>
		Type
		<html:select property="type" title="Which kind of files to show?">
			<html:option value="">All</html:option>
			<html:option value="j">Java</html:option>
			<html:option value="c">C/C++</html:option>
			<html:option value="p">JSP</html:option>
			<html:option value="w">Web</html:option>
			<html:option value="x">XML</html:option>
			<html:option value="t">JavaScript</html:option>
			<html:option value="m">Make</html:option>
			<html:option value="h">Html</html:option>
			<html:option value="s">Sql</html:option>
			<html:option value="*">Image</html:option>
			<html:option value="o">Other</html:option>
		</html:select>
		</label>

		<label>Name
			<html:text property="name" size="32" title="Filter by file name"/>
		</label>

		<label>
			<html:checkbox property="details" title="If details are shown" styleClass="checkbox" /> Detailed
		</label>

		<html:submit styleClass="button">GO</html:submit>
	</html:form>
</c:set>

<jsp:include page="includes/actionBar.jsp" >
	<jsp:param name="screenTitle" value="Source Files"/>
	<jsp:param name="screenFilter" value="${screenFilter}" />
</jsp:include>


<c:set var="showDetails" value="${fileSearchForm.map.details}" />

<c:url var="requestURL" value="/proj/sources/listFiles.do" />

<%--
<ui:displaytagPaging defaultPageSize="25" items="${files}" />
--%>

<display:table requestURI="${requestURL}" name="files" id="file" cellpadding="0" cellspacing="0"
	decorator="com.intland.codebeamer.ui.view.table.FileBrowseDecorator" pagesize="${pagesize}">

	<display:setProperty name="pagination.sort.param" value="orderBy" />

	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />

	<display:column title="Filename" property="name" sortable="true" headerClass="textData" class="textData columnSeparator"
		style="white-space:nowrap; width:20%;"
	/>

	<c:if test="${isUserInRoleScmView}">
		<display:column title="" property="historyLink" headerClass="textData" class="textData columnSeparator" />
	</c:if>

	<display:column title="Directory" property="directory.name" sortable="true"
		headerClass="textData expand" class="textData columnSeparator" />

	<c:if test="${showDetails}">
		<display:column title="Lines" property="totalLines" sortable="true"
			headerClass="numberData" class="numberData columnSeparator" />

		<display:column title="Size" property="size" sortable="true"
			headerClass="numberData" class="numberData columnSeparator" />

		<display:column title="Modified at" property="lastModifiedAt" sortable="true"
			headerClass="dateData" class="dateData columnSeparator" />

		<display:column title="Parsed at" property="parsedAt" sortable="true"
			headerClass="dateData" class="dateData" />
	</c:if>

</display:table>
