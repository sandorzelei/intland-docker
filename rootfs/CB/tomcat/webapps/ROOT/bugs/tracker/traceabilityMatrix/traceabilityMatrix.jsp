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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="callTag" prefix="ct" %>

<%-- Fragment shows the traceability matrix's table only. For full page see traceabilityMatrixPage.jsp --%>
<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/traceabilityMatrix/traceabilityMatrix.less' />" type="text/css" media="all" />

<table class="traceabilityMatrix ${allowEditingTraceabilityMatrix ? 'configurableTraceabilityMatrix' : ''}" border="0">
	<thead>
		<c:if test="${! empty extraHeaderRow}">
			<tr class="vertical extraHeaderRow">
				${extraHeaderRow}
			</tr>
		</c:if>
		<tr class="vertical">
			<th class="topleftCorner"><c:if test="${! empty topleftCorner && ! empty horizontalTrackerItems && ! empty verticalTrackerItems}">${topleftCorner}</c:if></th>
			<c:forEach var="horizontalTrackerItem" items="${horizontalTrackerItems}" varStatus="status"><tag:joinLines newLinePrefix="">
				<c:set var="id" value="${horizontalTrackerItem.id}" />
				<th id="horizontal-${id}" class="issue horizontal ${((status.count % 2) == 1) ? 'odd' : 'even'}">
					<input type="hidden" value="${id}"/>
					<c:forEach var="substring" items="${fn:split(horizontalTrackerItem.keyAndId, '-')}">
						<c:out value="${substring}" /><br>
					</c:forEach>
					<c:set var="headerLinkTooltip" value="Click to open in a new window..." />
					<a href="<c:url value='${horizontalTrackerItem.urlLink}'/>" target="_blank" title="${headerLinkTooltip}" ><c:out value="${horizontalTrackerItem.name}"/></a>
					<%--
					<label><c:out value="${horizontalTrackerItem.name}"/></label>
					--%>
				</th>
			</tag:joinLines></c:forEach>
		</tr>
	</thead>
	<tbody>
		<c:forEach var="verticalTrackerItem" varStatus="status" items="${verticalTrackerItems}"><tag:joinLines newLinePrefix="">
			<tr class="${((status.count % 2) == 1) ? 'odd' : 'even'}">
				<c:set var="id" value="${verticalTrackerItem.id}" />
				<th id="vertical-${id}" class="issue vertical">
					<input type="hidden" value="${id}"/>
					${verticalTrackerItem.keyAndId}
					<a href="<c:url value='${verticalTrackerItem.urlLink}'/>" target="_blank" title="${headerLinkTooltip}"><c:out value="${verticalTrackerItem.name}"/></a>
					<%--
					<label><c:out value="${verticalTrackerItem.name}"/></a>
					--%>
				</th>
				<c:forEach var="horizontalTrackerItem" items="${horizontalTrackerItems}">
					<c:set var="id" value="dependency-${horizontalTrackerItem.id}-${verticalTrackerItem.id}"/>
					<c:set var="cssStyle" value="" />
					<c:choose>
						<c:when test="${verticalTrackerItem.id != horizontalTrackerItem.id}">
							<c:set var="dependency" value="${dependencyMap[verticalTrackerItem.id][horizontalTrackerItem.id]}"/>
							<c:set var="direction" value="${dependency.direction}" />
							<c:set var="cssClass"><c:if test="${! editable}">noteditable</c:if><c:if test="${(not empty dependency) && (dependency.propagateSuspected)}"> propagate-suspected</c:if></c:set>

							<ct:call object="${suspects}" method="hasSuspectedLink" param1="${verticalTrackerItem.id}" param2="${horizontalTrackerItem.id}" return="suspectedLink"/>
							<c:if test="${suspectedLink}">
								<c:set var="cssClass" value="${cssClass} suspectedCell"/>
							</c:if>

							<c:set var="content">
								<c:if test="${not empty dependency}">
									<c:set var="imgurl" value="${(direction eq 'H2V') ? '/images/top_to_left_arrow.png' : ((direction eq 'V2H') ? '/images/left_to_top_arrow.png' : '/images/top_left_bidir_arrow.png')}" />
									<img src="<ui:urlversioned value='${imgurl}'/>">
								</c:if>
								<c:if test="${suspectedLink}">
									<span class="suspect">SUSPECTED</span>
								</c:if>
							</c:set>
						</c:when>
						<c:otherwise>
							<c:set var="cssClass" value="axial" />
							<c:set var="content" value="" />
						</c:otherwise>
					</c:choose>
					<!--
						call the Velocity script from the Traceability-matrix's plugin body
						this script can modify the cssClass/cssStyle of the cell and the content of the cell, and can access all variables in the jsp scope now!
					! -->
					<c:if test="${! empty cellDecoratorScript}">
						<c:set var="modifiedContent"><ui:velocity script="${cellDecoratorScript}" exportVariablesRegexp="css.*"/></c:set>
						<c:set var="content" value="${fn:trim(modifiedContent)}" />
					</c:if>
					<td id="${id}" <c:if test="${! empty cssClass}">class="${cssClass}"</c:if> <c:if test="${! empty cssStyle}">style="${cssStyle}"</c:if> >${content}</td>
				</c:forEach>
			</tr>
		</tag:joinLines></c:forEach>
	</tbody>
</table>

<%-- The hidden html fragment will be used as template in the dependency editor's overlay --%>
<div id="dependency-editor-overlay" style="display:none;" >
	<ui:actionMenuBar>Update dependency</ui:actionMenuBar>
	<table id="dependency-editor" style="border-spacing: 10px; width: 100%; margin: 15px 10px;">
		<tr>
			<td style="width: 40%;"/>
			<td>
				<input type="hidden" id="horizontalId"/>
				<b id="horizontalName">Horizontal item</b>
			</td>
		</tr>
		<tr>
			<td style="text-align: right;">
				<input type="hidden" id="verticalId"/>
				<b id="verticalName">Vertical item</b>
			</td>
			<td>
				<div id="direction">
					<input type="radio" id="h2v" name="direction" /><label for="h2v"><img src="<ui:urlversioned value='/images/top_to_left_arrow.png'/>"></label>
					<input type="radio" id="v2h" name="direction" /><label for="v2h"><img src="<ui:urlversioned value='/images/left_to_top_arrow.png'/>"></label>
					<input type="radio" id="bi" name="direction" /><label for="bi"><img src="<ui:urlversioned value='/images/top_left_bidir_arrow.png'/>"></label>
					<input type="radio" id="none" name="direction" /><label for="none">None</label>
				</div>
			</td>
		</tr>
		<tr>
			<td/>
			<td>
				<input id="propagateSuspected" type="checkbox" name="propagateSuspected"/><label for="propagateSuspected">Trigger suspected links</label><br>
				<span class="subtext">Whether to make this dependency suspected when the influent issue is updated.</span>
			</td>
		</tr>
		<tr>
			<td/>
			<td>
				<input type="button" value="Update dependency" style="margin-top:5px;"/>
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/traceabilityMatrix/traceabilityMatrix.js'/>" ></script>
