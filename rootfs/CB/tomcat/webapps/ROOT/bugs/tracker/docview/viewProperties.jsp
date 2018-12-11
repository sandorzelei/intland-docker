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
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>
<%@ page import="com.intland.codebeamer.ui.view.ColoredEntityIconProvider" %>

<spring:message var="detailsTitle" code="planner.issueDetails" text="Details" />
<spring:message var="descriptionTitle" code="planner.issueDescription" text="Description" />
<spring:message var="associationsTitle" code="planner.issueAssociations" text="Associations"/>
<spring:message var="referencesTitle" code="planner.issueReferences" text="References"/>
<spring:message var="commentsTitle" code="planner.issueComments" text="Comments"/>

<c:set var="showReviewVersionBadge" value="false"></c:set>

<div>
	<ul class="quick-icons" id="document-view-quick-icons"><!--
			--><li class="details" title="<c:out value="${detailsTitle}" />"></li><!--
			--><c:if test="${showDescription}"><li class="description " title="<c:out value="${descriptionTitle}" />"></li></c:if><!--
			--><c:if test="${!hideRelations }"><li class="references" title="<c:out value="${referencesTitle}" />"></li></c:if><!--
			--><c:if test="${!hideRelations }"><li class="associations" title="<c:out value="${associationsTitle}" />"></li></c:if><!--
			--><li class="comments" title="<c:out value="${commentsTitle}" />"></li><!--
		--></ul>

	<div class="overflow">
		<div class="accordion" data-quick-icons="document-view-quick-icons">

			<c:if test="${not empty itemReviewStats }">
				<spring:message code="review.details.statistics.label" var="reviewStatisticsLabel"/>
				<h3 class="issue-review-title accordion-header"><span class="icon"></span><c:out value="${reviewStatisticsLabel}" /></h3>
				<div class="issue-review accordion-content" data-section-id="review">
					<jsp:include page="/bugs/tracker/includes/itemReviewStats.jsp"></jsp:include>
				</div>
			</c:if>

			<h3 class="issue-details-title accordion-header"><span class="icon"></span><c:out value="${detailsTitle}" /></h3>
			<div class="issue-details accordion-content" data-section-id="details">

				<c:if test="${!empty layout.fields}">
					<spring:message code="planner.properties.label" var="propertiesLabel" text="Properties"/>

					<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />
					<h3 data-planner-role="title" style="margin-bottom: 5px; margin-top: 0px;">
						<c:set var="lockedTitle" value=""></c:set>
						<c:if test="${isLocked }">
							<c:set var="lockedTitle" value="${locker }"></c:set>

							<span class="locked" title="${lockedTitle}"></span>
						</c:if>

						<c:if test="${reviewItemId != null}">
							<c:set var="showReviewVersionBadge" value="true"></c:set>
						</c:if>

						<ui:wikiLink item="${item}" alwaysShowVersionBadge="${showReviewVersionBadge}" hideBadges="${!showReviewVersionBadge}" forceBaselineAware="${true}"/>
					</h3>

					<c:if test="${item.branchItem }">
						<c:set var="originalItem" value="${item.branchOriginalItem.originalTrackerItem }"/>
						<div style="margin-top: 10px;">
							<spring:message code="tracker.branching.show.on.master.label" text="Show on Master" var="showOnMasterLabel"/>
							<c:if test="${originalItem != null }">
								<c:url var="originalTrackerUrl" value="${originalItem.tracker.urlLink }">
									<c:param name="selectedItemId" value="${originalItem.id }"></c:param>

									<c:if test="${not empty param.revision }">
										<c:param name="revision" value="${param.revision }"></c:param>
									</c:if>
								</c:url>
								<a href="${originalTrackerUrl}">${showOnMasterLabel}</a>
							</c:if>
						</div>

						<div style="margin-top: 10px;">
							<bugs:itemBranchBadges itemDivergedOnMaster="${divergedOnMaster}"
								itemDivergedOnBranch="${divergedOnBranch}"
								itemCreatedOnBranch="${createdOnBranch}" branch="${item.branch }" item="${item }" ></bugs:itemBranchBadges>
						</div>
					</c:if>

					<c:set var="itemName"><c:out escapeXml="true" value="${item.name}" /></c:set>
					
					<%
						final int MAXCOLUMNS = 1;
						TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 2);
					%>

					<style type="text/css">
						.issueStatus {
							height: 13px !important;
							vertical-align: middle;
						}
					</style>
					
					<table border="0" class="propertyTable${isItemEditable ? ' inlineEditEnabled' : ''}" cellpadding="2" class="fieldLayoutTable" data-planner-role="details" data-item-id="${item.id}" data-item-name="${itemName}">
						<%-- tracker always show to get consistent layout for fields --%>
						<%	tableCellCounter.insertNewRow(); %>
						<td class="optional">
							<spring:message code="${item.configItem ? 'cmdb.category.label' : 'tracker.label'}"/>:
						</td>
						<td class="tableItem">
							<spring:message code="tracker.${item.tracker.name}.label" text="${item.tracker.name}" htmlEscape="true"/>
						</td>

						<c:forEach items="${layout.fields}" var="fieldLayout">
						<c:if test="${fieldLayout.hidden == null || !fieldLayout.hidden}">

						<c:set var="label_id" value="${fieldLayout.id}" />
						<spring:message var="label" code="tracker.field.${fieldLayout.labelWithoutBR}.label" text="${fieldLayout.labelWithoutBR}"/>
						<c:set var="breakRow" value="${fieldLayout.breakRow}" />
						<c:set var="colspan" value="${fieldLayout.colspan}" />
						<c:set var="xcolspan" value="${empty colspan or colspan < 1 ? 1 : colspan}" />

						<log:trace value="label_id: ${label_id} label: ${label}" />

						<c:if test="${colspan gt 1}">
							<c:set var="xcolspan" value="${colspan * 2 - 1}" />
						</c:if>

						<jsp:useBean id="fieldLayout" beanName="fieldLayout" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />

						<c:choose>
							<%-- item status --%>
							<c:when test="${label_id == STATUS_ID}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional"><c:out escapeXml="false" value="${label}" />:</td>
								<td class="tableItem"><c:out escapeXml="false" value="${decorated.status}" default="--" /></td>
							</c:when>

							<%-- item priority --%>
							<c:when test="${label_id == PRIORITY_ID}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional"><c:out escapeXml="false" value="${label}" />:</td>
								<td class="tableItem fieldColumn fieldId_${label_id}"><c:out escapeXml="false" value="${decorated.priorityWithIcon}" default="--" /></td>
							</c:when>

							<%-- resolution in the test run trackers --%>
							<c:when test="${label_id == 15 && item.tracker.testRun}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional"><c:out escapeXml="false" value="${label}" />:</td>
								<td class="tableItem fieldColumn fieldId_${label_id}"><c:out escapeXml="false" value="${decorated.resolutions}" default="--" /></td>
							</c:when>

							<%-- choice fields --%>
							<c:when test="${fieldLayout.choiceField}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional"><c:out escapeXml="false" value="${label}" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}" colspan="${xcolspan}" style="white-space: normal;">
									<c:out escapeXml="false" value="<%= decorated.getReferences(fieldLayout) %>" default="--"/>
									<c:if test="${label_id == ASSIGNED_TO_ID and !empty item.assignedAt}">
										<tag:formatDate value="${item.assignedAt}" />
									</c:if>
								</td>
							</c:when>

							<%-- user defined fields --%>
							<c:when test="${fieldLayout.userDefined}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional"><c:out escapeXml="false" value="${label}" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}" colspan="${xcolspan}" style="white-space: normal;">
									<c:out escapeXml="false" value="<%= decorated.getRenderValue(fieldLayout) %>" default="--" />
								</td>
							</c:when>

							<c:when test="${fieldLayout.label == TEST_CASES_FIELD_NAME}">
								<%-- hiding Test Cases table, will show test cases as it looks on editor... --%>
							</c:when>

							<c:when test="${fieldLayout.label == TEST_STEPS_FIELD_NAME}">
								<%-- hiding Test Steps table and moving it to a separate tab --%>
							</c:when>

							<%-- embedded tables --%>
							<c:when test="${fieldLayout.table}">
								<%	tableCellCounter.insertNewRow(); %>

								<td class="optional" valign="top"><c:out escapeXml="false" value="${label}" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}" COLSPAN="${xcolspan}" style="white-space: normal;">
									<%= decorated.getRenderValue(fieldLayout, true) %>
								</td>
							</c:when>

							<c:otherwise>

							<%-- Submitted by --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SUBMITTED_BY_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow(); %>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem">
									<tag:userLink user_id="${item.submitter.id}" />
									<tag:formatDate value="${item.submittedAt}" />
								</td>
							</logic:equal>

							<%-- Modified by --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.MODIFIED_BY_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem">
									<tag:userLink user_id="${item.modifier.id}" />
									<tag:formatDate value="${item.modifiedAt}" />
								</td>
							</logic:equal>

							<%-- Start date --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.START_DATE_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}">
									<c:out escapeXml="false" value="${decorated.startDate}" default="--" />
								</td>
							</logic:equal>

							<%-- End date --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.END_DATE_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}">
									<c:out escapeXml="false" value="${decorated.endDate}" default="--" />
								</td>
							</logic:equal>

							<%-- Closed at --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.CLOSED_AT_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem">
									<c:out escapeXml="false" value="${decorated.closedAt}" default="--" />
								</td>
							</logic:equal>

							<%-- Spent effort --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SPENT_H_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>

								<td class="tableItem fieldColumn fieldId_${label_id}">
									<c:out escapeXml="false" value="${decorated.spentMillis}" default="--" />
									<c:if test="${isItemEditable and empty revision}">
										${decorated.timeRecordingLink}
									</c:if>
								</td>
							</logic:equal>

							<%-- Estimated effort --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.ESTIMATED_H_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>
								<td class="tableItem fieldColumn fieldId_${label_id}">
									<c:out escapeXml="false" value="${decorated.estimatedMillis}" default="--" />
								</td>
							</logic:equal>

							<%-- Spent/Estimated ratio --%>
							<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SPENT_ESTIMATED_H_LABEL_ID)%>">
								<% tableCellCounter.insertNewRow();	%>
								<td class="optional"><c:out value="${label}" escapeXml="false" />:</td>
								<td class="tableItem">
									<c:out escapeXml="false" value="${decorated.spentEstimatedHours}" default="--" />
								</td>
							</logic:equal>
							</c:otherwise>
						</c:choose> <%-- choose for reference fields --%>
						</c:if>
						</c:forEach>

					</tr>
					</table>
				</c:if>

			</div>

			<c:if test="${showDescription}">
				<h3 class="issue-description-title accordion-header"><span class="icon"></span><c:out value="${descriptionTitle}" /></h3>
				<div class="issue-description accordion-content" data-section-id="description">
					<c:set var="fieldLayout" value="${layout.mapTable[DESCRIPTION_LABEL_ID]}" />
					<spring:message var="label" code="tracker.field.Description.label"/>

					<ui:collapsingBorder label="${label}" hideIfEmpty="false" open="${param.descriptionOpen}" cssClass="scrollable" id="description">
						<div class="fieldColumn fieldId_${DESCRIPTION_LABEL_ID}${isItemEditable ? ' inlineEditEnabled' : ''}" data-planner-role="description" data-item-id="${item.id}" data-item-name="${itemName}"><c:out value="${itemDescription}" escapeXml="false"/></div>
					</ui:collapsingBorder>
				</div>
			</c:if>

			<c:if test="${!hideRelations}">
				<h3 class="issue-references-title accordion-header"><span class="icon"></span><c:out value="${referencesTitle}" /> (${referenceCount})</h3>
				<div class="issue-references accordion-content" data-section-id="references">
					<div data-planner-role="references">
						<jsp:include page="referencesSection.jsp"/>
					</div>
				</div>

				<h3 class="issue-associations-title accordion-header"><span class="icon"></span><c:out value="${associationsTitle}" /> (${associationCount})</h3>
				<div class="issue-associations accordion-content" data-section-id="associations">
					<div data-planner-role="associations">
						<jsp:include page="associationsSection.jsp"/>
					</div>
				</div>
			</c:if>

			<h3 class="issue-comments-title accordion-header"><span class="icon"></span><c:out value="${commentsTitle}" /> <span class="comment-count">(${fn:length(itemAttachments)})</span></h3>
			<div class="issue-comments accordion-content" data-section-id="comments">
				<jsp:include page="commentsSection.jsp"/>
			</div>

		</div>
	</div>
</div>
