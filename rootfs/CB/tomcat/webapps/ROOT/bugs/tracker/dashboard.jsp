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
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>

<%
	final int MAXCOLUMNS = 2;
	TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 1);
%>
<table border="0" cellpadding="0" style="width: 100%; border-collapse: separate;border-spacing: 20px">
	<c:forEach items="${charts}" var="chart">
		<% tableCellCounter.insertNewRow(1, false); %>

		<td nowrap width="50%" valign="top">
			<tag:transformText owner="${tracker}" value="${chart}" format="W" />
		</td>
	</c:forEach>

	<% tableCellCounter.finishRow(); %>
	</TR>
</table>

