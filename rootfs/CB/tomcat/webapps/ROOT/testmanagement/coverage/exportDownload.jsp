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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<ui:actionMenuBar>
  <ui:breadcrumbs showProjects="false" >
    <span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false">
    	<c:choose>
    		<c:when test="${isTestRunBrowserExport }">
    			<spring:message code="tracker.coverage.export.test.run.title"></spring:message>
    		</c:when>
    		<c:otherwise>
    		    <spring:message code="tracker.coverage.export.title" />
    		</c:otherwise>
    	</c:choose>
       </ui:pageTitle>
  </ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="closeButton" code="button.close"/>
<ui:actionBar>
  &nbsp;&nbsp;<input type="submit" class="button" value="${closeButton}" onclick="inlinePopup.close(); return false;"/>
</ui:actionBar>

<div class="contentWithMargins">
  <div class="information">
		<spring:message code="tracker.traceability.browser.export.result" arguments="${downloadUrl},${ui:removeXSSCodeAndHtmlEncode(fileName)}"/>
   </div>
</div>

<script type="text/javascript">
  $(function() {
	  $('.container-close', window.parent.document).show();

      document.location.href = "${downloadUrl}";
  });
</script>