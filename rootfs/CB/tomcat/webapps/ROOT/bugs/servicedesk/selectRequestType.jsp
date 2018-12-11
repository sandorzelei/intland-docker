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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:set var="escapedTitle"><c:out value="${config.title}" escapeXml="true" /></c:set>

<div class="actionBar">

	<c:choose>
		<c:when test="${param.itemCreated != null }">
			<div class="large-title larger"><spring:message code="tracker.serviceDesk.thank.you" text="Thank You!"/></div>
		</c:when>
		<c:otherwise>
			<div class="large-title larger"><spring:message code="${escapedTitle}"/></div>
		</c:otherwise>
	</c:choose>
</div>
<div class="contentWithMargins">
	<c:choose>
		<c:when test="${param.itemCreated != null }">
			<div class="desk-description">
				<spring:message code="tracker.serviceDesk.thankyou.message"/>
			</div>
			<c:url var="deskUrl" value="/servicedesk/serviceDesk.spr"/>
			<a href="${deskUrl }"><spring:message code="issue.details.back.label" text="Go back"/></a>
		</c:when>
		<c:otherwise>
			<div class="desk-description">
				<spring:message code="${config.description}" var="mainDescription"/>
				<tag:transformText value="${mainDescription}" format="W" />
			</div>

			<c:choose>
				<c:when test="${empty trackerTitles or noTrackersWithPermission }">
					<div class="information">
						<spring:message code="sysadmin.serviceDesk.no.trackers.message" text="Currently there are no trackers added to Service Desk. You can add a tracker to Service Desk under the \"Customize\" menu of the tracker."/>
					</div>
				</c:when>
				<c:otherwise>
					<div id="trackerList">
						<c:forEach items="${trackerTitles}" var="entry">
							<c:if test="${trackersWithPermission[entry.key]}">
								<div class="tracker">
									<div class="tracker-icon">
										<c:choose>
											<c:when test="${trackerImages[entry.key] != null}">
												<c:url var="iconUrl" value="/displayDocument">
													<c:param name="doc_id" value="${trackerImages[entry.key]}"></c:param>
												</c:url>
												<img src="${iconUrl}" class="icon-img" style="background-color: ${trackerColors[entry.key]};"/>
											</c:when>
											<c:otherwise>
												<ui:letterIcon elementId="${entry.key.id}"
													elementName="${trackerTitles[entry.key]}" color="${trackerColors[entry.key]}"/>
											</c:otherwise>
										</c:choose>
									</div>
									<div class="tracker-info">
										<span class="tracker-link">
											<c:url var="trackerUrl" value="/servicedesk/addItem.spr">
												<c:param name="tracker_id" value="${entry.key.id}"></c:param>
											</c:url>
											<a href="${trackerUrl}"><c:out escapeXml="true" value="${trackerTitles[entry.key]}"></c:out></a>
										</span>
										<div class="tracker-description">
											<tag:transformText value="${trackerDescriptions[entry.key]}" format="W" />
										</div>
									</div>
								</div>
							</c:if>
						</c:forEach>
					</div>
				</c:otherwise>
			</c:choose>
		</c:otherwise>
	</c:choose>
</div>

