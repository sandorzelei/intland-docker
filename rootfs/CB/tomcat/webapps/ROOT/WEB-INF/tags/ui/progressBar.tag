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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="greenPercentage" type="java.lang.Integer" required="false" description="The percentage value that represents the 'completed' or 'successful' ratio." %>
<%@ attribute name="redPercentage" type="java.lang.Integer" required="false" description="The percentage value that represents the 'failed' or 'broken' ratio," %>
<%@ attribute name="greyPercentage" type="java.lang.Integer" required="false" description="The percentage value that represents the 'blocked' or 'skipped' ratio." %>

<%@ attribute name="totalPercentage" type="java.lang.Integer" required="false" description="The percentage of the test cases run ((passed + blocked + failed) / all). Needed
	because of the rounding errors." %>

<%@ attribute name="greenTitle" type="java.lang.String" required="false" description="the title written into the green bar" %>
<%@ attribute name="redTitle" type="java.lang.String" required="false" description="the title written into the red bar" %>
<%@ attribute name="greyTitle" type="java.lang.String" required="false" description="the title written into the grey bar" %>

<%@ attribute name="id" required="false" description="Id for the wrapping DIV element." %>
<%@ attribute name="title" required="false" description="Hover text to display over the bar." %>
<%@ attribute name="hideTotal" required="false" type="java.lang.Boolean" description="If true, then the total percentage is not shown on the bars" %>
<%@ attribute name="label" required="false" description="Optional text to write on the progress bar. If present hten it will be shown instead of total" %>

<%--
	alternative configuration where the percentage/title/cssClasses are passed as arrays. This allows more freedom for the bars...
 --%>
<%@ attribute name="percentages" type="java.lang.Integer[]" %>
<%@ attribute name="titles" type="java.lang.String[]" %>
<%@ attribute name="cssClasses" type="java.lang.String[]" %>
<%@ attribute name="bgcolors" type="java.lang.String[]" %>
<%@ attribute name="fontcolors" type="java.lang.String[]" %>
<%
	if (percentages == null || percentages.length == 0) {
		// convert from legacy to new config
		percentages = new Integer[] { greenPercentage, redPercentage, greyPercentage };
		titles = new String[] { greenTitle, redTitle, greyTitle };
		cssClasses = new String[] {"progressBarGreen", "progressBarRed", "progressBarGray" };
	}
	// compute the actual total value from the percentages
	int total = 0;
	for (int i=0; i<percentages.length; i++) {
		Integer percent = percentages[i];
		if (percent == null) {
			// avoid null percentages, use 0 instead
			percent = Integer.valueOf(0);
			percentages[i] = percent;
		}
		total += percent.intValue();
	}

	if (totalPercentage == null) {
		totalPercentage = Integer.valueOf(total);
		jspContext.setAttribute("totalPercentage", totalPercentage);
	} else {
		// TODO: this would be nicer in a separate class with unit tests...
		// deal with rounding errors, because the expected and actual total percentage values differ
		int delta = totalPercentage.intValue() - total;
		// distribute the difference between the parts evenly
		int i = 0;
		int d = (int) Math.signum(delta);
		boolean stop = false;
		boolean wasChange = false;
		while (delta !=0 && !stop) {
			int percent = percentages[i].intValue() + d;
			if (percentages[i].intValue() > 0 && percent >=0 && percent <= 100) {
				// ok, a bit is added/removed here successfully
				percentages[i] = Integer.valueOf(percent);
				delta -= d;
				wasChange = true;
			}
			if (++i >= percentages.length) {
				i=0;
				if (!wasChange) {
					// in this cycle there was no successful distribution, stop to avoid infinite loop
					stop = true;
				}
				wasChange = false;
			}
		}
	}

	jspContext.setAttribute("percentages", percentages);
	jspContext.setAttribute("titles", titles);
	jspContext.setAttribute("cssClasses", cssClasses);
	jspContext.setAttribute("noData", total == 0);
%>

<div <c:if test="${not empty id}">id="${id}"</c:if> class="miniprogressbar" <c:if test="${not empty title}">title="<c:out value='${title}'/>"</c:if> >
	<c:set var="total" value="${totalPercentage}"/>
	<c:forEach var="percent" items="${percentages}" varStatus="stat"  >
		<c:if test="${percent > 0}">
		<div style="width:${percent}%;background-color:${!empty bgcolors ? bgcolors[stat.index] : ''}" class="${cssClasses[stat.index]}">
			<c:if test="${!empty titles[stat.index]}">
				<span class="barLabel" style="color:${!empty fontcolors ? fontcolors[stat.index] : ''}">${titles[stat.index]}</span>
			</c:if>
		</div>
		</c:if>
	</c:forEach>

	<c:choose>
		<c:when test="${!empty label}">
			<label style="font-weight:bold"><c:out value='${label}'/></label>
		</c:when>
		<c:otherwise>
		<c:if test="${empty hideTotal || !hideTotal }">
			<label style="font-weight:bold">${total}%</label>
		</c:if>
		</c:otherwise>
	</c:choose>

	<c:if test="${noData}"><!-- No data --></c:if>
</div>
