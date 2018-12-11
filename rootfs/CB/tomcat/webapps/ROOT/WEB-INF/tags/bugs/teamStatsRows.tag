<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="bugstaglib" prefix="tags" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="groups"  required="true" type="java.util.List" rtexprvalue="true" description="The list of TeamDto items to display."  %>

<c:forEach var="team" items="${groups}">
	<c:set var="filterCategoryName" scope="request">team</c:set>
	<c:set var="filterCategoryValue" scope="request">${team.id}</c:set>

	<c:set var="mergeOpenAndClosed" scope="request" value="false" />
	<c:set var="firstColumnClasses" scope="request" value="checkmark-selected-state" />

	<c:set var="groupRendered" scope="request"><div class="state-indicator-box" style="background-color:${team.color};"></div><span>${team.name}</span></c:set>

	<c:set var="dataTtId" scope="request" value="${team.id}"/>
	<c:set var="submitDataTtId" scope="request" value="true"/>
	<c:choose>
		<c:when test="${!empty team.parent}">
			<c:set var="parent" scope="request" value="${team.parent}"/>
			<c:set var="dataTtParentId" scope="request" value="${parent.id}"/>
		</c:when>
	</c:choose>

	<c:set var="group" scope="request" value="${team}" />

	<jsp:include page="/bugs/tracker/versionStatsRow.jsp"/>

	<c:if test="${!empty team.children}">
		<tags:teamStatsRows groups="${team.children}" />
	</c:if>

	 <c:remove var="dataTtId" scope="request" />
	 <c:remove var="parent" scope="request" />
	 <c:remove var="dataTtParentId" scope="request" />
	 <c:remove var="filterCategoryName" scope="request" />
	 <c:remove var="filterCategoryValue" scope="request" />
</c:forEach>

<c:remove var="teamColor" scope="request" />
<c:remove var="groupRendered" scope="request" />
<c:remove var="mergeOpenAndClosed" scope="request" />
<c:remove var="firstColumnClasses" scope="request" />
<c:remove var="group" scope="request" />
<c:remove var="submitDataTtId" scope="request" />