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
 * $Id$
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	tag renders non resizable two column layout.
 --%>
<%@ attribute name="leftContent" fragment="true"
	description="The content of the left column" required="true" %>

<style type="text/css">
<!--
	.left-panel-content {
		min-width: 240px !important;
		width: 240px;
		overflow: auto;
	}
-->
</style>

<table border="0" cellpadding="0" cellspacing="0" width="100%" id="twoColumnTable">
<tr>
<td id="left-panel" valign="top">
	<div class="left-panel-content">
	 <jsp:invoke fragment="leftContent"/>
	</div>
</td>
<td id="middle-panel" valign="top" >
	 <jsp:doBody></jsp:doBody>
</td>
</tr>
</table>