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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value='/bugs/importing/conversions/ValueMapper.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/bugs/importing/conversions/ValueMapper.js' />"></script>

<c:set var="addTitle" value="Add new mapping" />	<%-- TODO i18n --%>
<c:set var="deleteTitle" value="Delete this mapping" />	<%-- TODO i18n --%>
<c:url var="addImg" value="/images/add.png" /> <%-- /images/newskin/action/add-new-s.png --%>
<c:url var="delImg" value="/images/delete.png" /> <%-- /images/newskin/action/delete-grey-16x16_on.png --%>

<div class="valueMapping">
	<form:hidden path="valueMappingsJSON"/>
	<c:set var="addButton">
		<a href="#" title="${addTitle}" onclick="valueMapper.addOneValueMapping(this); return false;"><img src="${addImg}"></img></a>
	</c:set>
	<p>Configure value mapping of input values ${addButton}</p>
	
	<ul class="mappings"></ul>	
	
	<%-- hidden template of the mapping configuration, when you add a new mapping this will be copied --%>
	<div class="template">
		<select class="inputValues" multiple="multiple">
			<c:forEach var="inputValue" items="${converter.inputValues}"><option><c:out value="${inputValue}"/></option></c:forEach>
		</select>
		
		&rarr; <input type="text" name="mappedValue" class="mappedValue"></input>
		
		<a href="#" title="deleteTitle" onclick="valueMapper.deleteMapping(this); return false;"><img src="${delImg}"></img></a>
   	    ${addButton}
	</div>
	
<%--	
	<pre>
		${converter}
	</pre>
--%>	
</div>
