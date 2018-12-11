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

<%--
	Tag showing some headline/title
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ tag import="java.util.HashMap"%>
<%@ tag import="java.util.Map"%>

<%-- original tile definitions --%>
<%@ attribute name="icon" %>
<%@ attribute name="grayGapHeight"  %>
<%@ attribute name="bottomMargin"  %>
<%@ attribute name="topMargin"  %>
<%@ attribute name="separatorDecoration"  %>
<%@ attribute name="separatorGapHeight"  %>
<%@ attribute name="titleStyle"  %>
<%@ attribute name="alreadyInTable" type="java.lang.Boolean" %>
<%@ attribute name="colSpan" %>
<%@ attribute name="extraColSpan"  %>

<%@ attribute name="header" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="description" type="java.lang.String" %>	<%-- TODO: is it used at all? --%>

<%@ attribute name="style" required="true" type="java.lang.String"
	description="Name of the style defines the default values used for missing attributes" %>

<%!
	// default values for different styles
	// Maps style->(attribute->value) pairs for the given style.
	static Map<String,Map<String,Object>> defaultValues = new HashMap();

	// defining default values for title styles
	static {
		// headline style
		Map headline = new HashMap<String,Object>();
		headline.put("header","");
		headline.put("topMargin","0");
		headline.put("separatorDecoration","1");
		headline.put("grayGapHeight","12");
		headline.put("bottomMargin","15");
		headline.put("separatorGapHeight","0");
		headline.put("titleStyle","titlenormal");
		headline.put("colSpan","2");
		headline.put("alreadyInTable",Boolean.FALSE);
		headline.put("showProjectName", Boolean.FALSE);

		defaultValues.put("headline", headline);

		// "sub-headline" style
		Map sub_headline = new HashMap<String,Object>(headline); // extends headline
		sub_headline.put("grayGapHeight","0");
		sub_headline.put("icon","");
		sub_headline.put("bottomMargin","10");
		defaultValues.put("sub-headline", sub_headline);

		// Sub-Headline component with top margin
		// "top-sub-headline" style
		Map top_sub_headline = new HashMap<String,Object>(sub_headline); // extends sub_headline
		top_sub_headline.put("topMargin","10");
		top_sub_headline.put("bottomMargin","0");
		top_sub_headline.put("separatorDecoration","0");
		defaultValues.put("top-sub-headline", top_sub_headline);

		// Sub-Headline component with top margin and decoration
		Map top_sub_headline_decoration = new HashMap<String,Object>(sub_headline); // extends sub_headline
		top_sub_headline_decoration.put("topMargin","20");
		top_sub_headline_decoration.put("bottomMargin","0");
		defaultValues.put("top-sub-headline-decoration", top_sub_headline_decoration);

		// Sub-Headline component
		// TODO: remove this, only used once ?
		Map headline_normargin = new HashMap<String,Object>(sub_headline); // extends sub_headline
		headline_normargin.put("bottomMargin","0");
		defaultValues.put("headline.nomargin", headline_normargin);

		// Note: "cb.headline2.layout" is dropped, not used anywhere

		// Sub-simple grayed Headline component
		Map headline_grayed = new HashMap<String,Object>(top_sub_headline); // extends top_sub_headline
		headline_grayed.put("bottomMargin","2");
		headline_grayed.put("grayGapHeight","2");
		headline_grayed.put("separatorDecoration","0");
		defaultValues.put("headline.grayed", headline_grayed);
	}
%>

<%
	Map<String,Object> styleValues = defaultValues.get(style);
	if (styleValues == null) {
		throw new IllegalArgumentException("Unknown style parameter value:" + style);
	}
	// set missing attributes from the defaults
	for (Map.Entry<String,Object> entry: styleValues.entrySet()) {
		String attr = entry.getKey();
		Object value = entry.getValue();
		// check if an attribute is missing, and use the default instead then
		Object jspAttr = jspContext.getAttribute(attr);
		if (jspAttr == null && value != null) {
			jspContext.setAttribute(attr, value);
		}
	}
%>

<!--title.tag begin -->

<c:if test="${empty extraColSpan}">
	<c:set var="extraColSpan" value="0" />
</c:if>

<c:if test="${!alreadyInTable}">
<table class="titleTagTable" width="100%" cellpadding="0" cellspacing="0" border="0">
</c:if>

<c:if test="${topMargin != '0'}">
<tr>
   	<td colspan="${colSpan}" width="1" height="${topMargin}"></td>
</tr>
</c:if>

<tr VALIGN="top">
<%
	icon = (String) jspContext.getAttribute("icon");
	String iconString = "";
	if (icon == null || icon.equals("default")) {
		iconString = "<IMG src=\"" + request.getContextPath()
			+ "/images/space.gif\" border=\"0\" width=\"24\" height=\"25\" align=\"middle\" class=\"bullet\">";
	} else if (icon.toString().indexOf("images") != -1) { // FIXME a quick workaround
		iconString = "<IMG src=\"" + request.getContextPath() + icon + "\" border=\"0\" width=\"24\" height=\"24\" align=\"middle\">";
	} else { // FIXME never used IMHO (kao)
		iconString = icon.toString().trim();
		if (iconString.startsWith("/")) {
			iconString = request.getContextPath() + iconString;
		}
	}
	if (iconString.length() != 0) {
		iconString += "&nbsp;";
	}
%>
	<td nowrap><%=iconString%></td>
	<td width="100%" colspan="${colSpan - 1}"
		<c:if test="${!empty titleStyle}">
			class="${titleStyle}"
		</c:if>
		align="LEFT" valign="middle" >

		<%-- render project name if selected --%>
		<c:if test="${(grayGapHeight != '0') && (bottomMargin != '2') && (PROJECT_DTO.id != null)}">
			<span class="title-subtext"><c:out value="${PROJECT_DTO.name}" /></span><br/>
		</c:if>

		<%--
			A workaround for the commons-el bug that "header" is displayed wrong ???:
			http://forums.sun.com/thread.jspa?threadID=5156184
			see also: http://issues.apache.org/jira/browse/EL-9
					  http://jira.springframework.org/browse/SPR-3563

			--%>
		<%
			Object header = jspContext.getAttribute("header");
			if (header != null) {
				out.print(header);
			}
		%>
		<jsp:doBody/><%-- The header can be provided in the body or as simple attribute header --%>
	</td>
</tr>

<c:if test="${separatorGapHeight != '0'}">
	<tr>
    	<td nowrap colspan="${colSpan}" width="1" height="${separatorGapHeight}"></td>
	</tr>
</c:if>

<c:if test="${separatorDecoration != '0'}">
	<tr>
    	<td colspan=${colSpan + extraColSpan} nowrap class="toolheadline" width="1" height="2"></td>
	</tr>
	<tr>
    	<td colspan="${colSpan + extraColSpan}" width="1" height="1"></td>
	</tr>
</c:if>

<c:if test="${grayGapHeight != '0'}">
	<tr>
    	<td nowrap colspan="${colSpan}" class="toolheadsubline" width="1" height="${grayGapHeight}"></td>
	</tr>
</c:if>

<c:if test="${!empty description}">
	<tr>
		<td colspan="${colSpan}" width="1" height="5"></td>
	</tr>
	<tr>
		<td colspan="${colSpan}" class="boxtext">${description}</td>
	</tr>
</c:if>

<c:if test="${bottomMargin != '0'}">
<tr>
   	<td colspan="${colSpan}" width="1" height="${bottomMargin}"></td>
</tr>
</c:if>

<c:if test="${!alreadyInTable}">
</table>
</c:if>

<!--title.tag end -->

