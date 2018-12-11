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

<style type="text/css">
<!--
	.verticalMiddleAlignedTable {
		height: 100%;
	}
	.verticalMiddleAlignedTableRow, .verticalMiddleAlignedTableCell {
		vertical-align: middle;
		width: 100%; height: 100%;
	}
-->
</style>
<%--
	tag vertically middle aligns its body
 --%>
<table class="verticalMiddleAlignedTable">
	<tr class="verticalMiddleAlignedTableRow">
		<td class="verticalMiddleAlignedTableCell">
			<jsp:doBody/>
		</td>
	</tr>
</table>
