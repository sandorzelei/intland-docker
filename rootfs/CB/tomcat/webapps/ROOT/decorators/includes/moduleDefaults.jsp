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
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>

<%@ page import="com.intland.codebeamer.ui.SitemeshModuleDefaults"%>
<%@ page import="com.intland.codebeamer.Config"%>

<%-- small fragment sets up the default values (SitemeshModuleDefaults) object for the current module.
	 only used if <meta name="useModuleDefaults" value="true"/> meta tag is set.

	 Any values in the moduleDefaults is only used if an explicit meta tag for that module is not set.
 --%>
<c:set var="module"><decorator:getProperty property="meta.module"/></c:set>
<c:set var="moduleDefaults" value="<%=SitemeshModuleDefaults.getModuleDefaults((String)pageContext.findAttribute(\"module\"))%>"></c:set>

<c:if test="<%=Config.isDevelopmentMode()%>">
	<!-- 
		Sitemesh is using module defaults: module:${module}, defaults: ${moduleDefaults} 
		moduleCSSClass: ${moduleCSSClass}, default:  default: ${moduleDefaults.moduleCSSClass}		
	-->	
</c:if>
<%-- extra css class to add to the body --%>
<c:set var="bodyCSSClass"><decorator:getProperty property="meta.bodyCSSClass" default="" /></c:set>
<c:set var="moduleCSSClass" scope="request"><decorator:getProperty property="meta.moduleCSSClass" default="${moduleDefaults.moduleCSSClass}" /> ${bodyCSSClass}</c:set>
