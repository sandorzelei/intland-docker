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

<style type="text/css">
	#importHierarchyConfig optgroup {
		color: gray;
	}
	#importHierarchyConfig option {
		color: black;
	}
	#importHierarchyConfig .hint {
		margin-left: 2.5em;
		margin-top: 5px;
	}
</style>

<!--
	customHierarchyImporter: ${importForm.customHierarchyImporter}
-->
<TR>
   <c:set var="customHierarchyImporter" value="${importForm.customHierarchyImporter}" />
   <c:choose>
	   <c:when test="${empty customHierarchyImporter}">
	   <TD class="optional">
	   		<label for="importHierarchyIndentationColumn"><spring:message code="issue.import.hierarchy.based.on.column"/>:</label>
	   </TD>
	   <TD>
		   <input type="hidden" name="importHierarchies" value="true" />
		   <form:select path="importHierarchyIndentationColumn" id="importHierarchyIndentationColumn">
		   		<spring:message code="issue.import.hierarchy.off" var="doNotGenerateHierarchy" />
		   		<form:option label="${doNotGenerateHierarchy}" value="" />

		   		<spring:message code='issue.import.hierarchy.use.summary' var="useSummaryLabel"/>
		    	<form:option label="${useSummaryLabel}" value="-1"/>
		    	<spring:message code='issue.import.hierarchy.select.column.group' var="groupLabel"/>
		    	<optgroup label="${groupLabel}">
			    	<c:forEach var="previewColumn" items="${importForm.previewFields}" varStatus="columnStats">
			    		<form:option label="${previewColumn}" value="${columnStats.count -1}" htmlEscape="true"/>
			    	</c:forEach>
		    	</optgroup>
		    </form:select>
	    </TD>
	    <TD><div class="hint"><spring:message code="issue.import.hierarchy.explanation" /></div></TD>

		</c:when>
		<c:otherwise>
		<TD class="optional">
			<label for="importHierarchies" >
				<spring:message code="issue.import.hierarchy.label" />
			</label>
		</TD>
		<TD><form:checkbox path="importHierarchies" id="importHierarchies" /></TD>
		<TD>
			<%-- custom hierarchy imports are not configurable, but we'll show some explanation --%>
			<div class="hint">
		    	<spring:message code="issue.import.hierarchy.explanation.${customHierarchyImporter}" />
		    </div>
		</TD>

		</c:otherwise>
	</c:choose>
</TR>