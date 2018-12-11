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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	Tag to render a layout with two celled table where
	the 1st cell occupies as much space as possible, and the 2nd cell is right aligned.
--%>
<%@ attribute name="tableCssClass" type="java.lang.String" %>
<%@ attribute name="tableCssStyle" type="java.lang.String" %>

<%@ attribute name="cssClass" type="java.lang.String" %>
<%@ attribute name="cssStyle" type="java.lang.String" %>

<%@ attribute name="filler" fragment="true" %>
<%@ attribute name="fillerCSSClass" type="java.lang.String" %>
<%@ attribute name="fillerCSSStyle" type="java.lang.String" %>

<%@ attribute name="filler2" fragment="true" %>
<%@ attribute name="fillerCSSClass2" type="java.lang.String" %>
<%@ attribute name="fillerCSSStyle2" type="java.lang.String" %>

<%@ attribute name="filler3" fragment="true" %>
<%@ attribute name="fillerCSSClass3" type="java.lang.String" %>
<%@ attribute name="fillerCSSStyle3" type="java.lang.String" %>

<%@ attribute name="rightAligned" fragment="true" %>
<%@ attribute name="rightAlignedCSSClass" type="java.lang.String" %>
<%@ attribute name="rightAlignedCSSStyle" type="java.lang.String" %>

<table border="0" cellpadding="0" cellspacing="0" class="rightAlign ${tableCssClass}" style="${tableCssStyle}">
	<tr>
		<td class="rightAlignCell ${cssClass}" <c:if test="${! empty cssStyle}"> style="${cssStyle}" </c:if>>
			<jsp:doBody/>
		</td>
<%--
				Use fillers to fill the gap between the left-side and the right-side.
				Its cells can incorporate DIVs without any problem.
			--%>
		<c:if test="${not empty filler}">
			<td class="rightAlignCell ${fillerCSSClass}" <c:if test="${! empty fillerCSSStyle}"> style="${fillerCSSStyle}" </c:if> >
				<jsp:invoke fragment="filler"/>
			</td>
		</c:if>
		<c:if test="${not empty filler2}">
			<td class="rightAlignCell ${fillerCSSClass2}" <c:if test="${! empty fillerCSSStyle2}"> style="${fillerCSSStyle2}" </c:if> >
				<jsp:invoke fragment="filler2"/>
			</td>
		</c:if>
		<c:if test="${not empty filler3}">
			<td class="rightAlignCell ${fillerCSSClass3}" <c:if test="${! empty fillerCSSStyle3}"> style="${fillerCSSStyle3}" </c:if> >
				<jsp:invoke fragment="filler3"/>
			</td>
		</c:if>
		<td class="rightAlignCell rightAligned ${rightAlignedCSSClass}" <c:if test="${! empty rightAlignedCSSStyle}"> style="${rightAlignedCSSStyle}" </c:if> >
			<jsp:invoke fragment="rightAligned"/>
		</td>
	</tr>
</table>

