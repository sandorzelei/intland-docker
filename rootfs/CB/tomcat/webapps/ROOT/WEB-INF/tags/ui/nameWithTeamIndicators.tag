<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="auxiliaryTeamContext" required="true" type="com.intland.codebeamer.controller.support.shared.AuxiliaryTeamContext" rtexprvalue="true" description="Context object containing the teams for each user."  %>
<%@ attribute name="userId" required="true" type="java.lang.Integer" rtexprvalue="true" description="Id of the target user."  %>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/nameWithTeamIndicators.css" />" type="text/css"/>

<div class="nameWithTeamIndicators table">
	<div class="table-row">
		<div class="table-cell">
			<jsp:doBody />
		</div>
	</div>
	<div class="table-row">
		<div class="table-cell limited-height">
			<ct:call object="${auxiliaryTeamContext}" method="getTeamsForUser" return="teamsForUser" param1="${userId}"/>
			<c:if test="${!empty teamsForUser}">
				<c:forEach var="team" items="${teamsForUser}">
					<span class="teamCircle" style="color:${team.color};" title="${team.name}">&#9679;</span>
				</c:forEach>
			</c:if>
		</div>
	</div>
</div>
