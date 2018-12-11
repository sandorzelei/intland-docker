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
--%>
<%-- validation errors and explanations must follow actionBar --%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<ui:showErrors errors="${errors}"/>

<ui:coloredEntityIcon subject="${copy}" iconUrlVar="copyIconUrl" iconBgColorVar="copyIconBgColor"/>
<c:if test="${original != null}">
	<ui:coloredEntityIcon subject="${original}" iconUrlVar="originalIconUrl" iconBgColorVar="originalIconBgColor"/>
</c:if>
<c:url var="copyIconUrl" value="${copyIconUrl}"/>
<c:url var="originalIconUrl" value="${originalIconUrl}"/>

<link rel="stylesheet" href="<ui:urlversioned value="/diff/diff.less" />" type="text/css" media="all" />

<c:set var="formatSelector">
	<select class="formatSelector">
		<option value="html">HTML</option>
		<option value="wiki">Wiki</option>
	</select>
</c:set>

<div class="contentWithMargins">

	<spring:message code="diffTool.summaryStat" arguments="${differenceCount},${totalCount + 1}" />

	<span class="showDifferentOnlyContainer">
		<label>
			<input type="checkbox" class="showDifferentFieldsOnly" checked="checked">
			<spring:message code="diffTool.showDifferentFieldsOnly" text="Show different fields only" />
		</label>
	</span>

	<ui:globalMessages/>

	<table class="diffTable">
		<thead>
		<tr class="sizer">
			<th class="label"></th>
			<th class="value"></th>
			<th class="controls"></th>
			<th class="label"></th>
			<th class="value"></th>
		</tr>
		<tr class="header">
			<th colspan="2">
				<%-- tag:summary item="${copy}" htmlEscape="true"/ --%>
				<c:if test="${not empty copyLabel }">
					(${copyLabel })
				</c:if>
			</th>
			<th class="controls"><c:if test="${editable and not onlyReadonlyChanges}"><ui:applyCheckbox initialState="false" name="all" /></c:if></th>
			<th colspan="2">
				<c:choose>
					<c:when test="${not empty originalLabel }">
						(${originalLabel })
					</c:when>
					<c:otherwise>
						<%-- tag:summary item="${original}" var="originalItemSummary"/ --%>
						<%-- spring:message code="diffTool.original" arguments="${originalItemSummary}" htmlEscape="true" / --%>
						<spring:message code="sysadmin.audit.diff.original" text="Original" />
					</c:otherwise>
				</c:choose>
			</th>
		</tr>
		</thead>
		<tbody>
		<tr class="fixed-id different">
			<td class="copy label">ID</td>
			<td class="copy value">
			<span>
				<img class="issueIcon" style="background-color: ${copyIconBgColor}" src="${copyIconUrl}" alt="icon">
				<a class="issueLink" href="${pageContext.request.contextPath}${copy.urlLinkVersioned}">${copy.id} ${copy.name}</a>
				<%-- span class="referenceSettingBadge versionSettingBadge">v${copy.version}</span>
				<c:if test="${copy.lastModifiedAt != null }">
					<span class="subtext">(
						<spring:message code="tracker.modifiedAt.label" text="Modified at"/>:
						<tag:formatDate value="${copy.lastModifiedAt}" />)
					</span>
				</c:if --%>
			</span>
			</td>
			<td class="controls"></td>
			<td class="original label">ID</td>
			<td class="original value">
			<span>
				<c:if test="${original != null}">
					<img class="issueIcon" style="background-color: ${originalIconBgColor}" src="${originalIconUrl}" alt="icon">
					<a class="issueLink" href="${pageContext.request.contextPath}${original != null ? (original.urlLinkVersioned) : (originalRevision != null ? originalRevision.urlLink : '')}"><c:if test="${original != null}">${original.id} ${original.name }</c:if></a>
				</c:if>
				<%-- span class="referenceSettingBadge versionSettingBadge">v${displayedOriginal.version}</span>
				<c:if test="${displayedOriginal.lastModifiedAt != null }">
					<span class="subtext">(
					<spring:message code="tracker.modifiedAt.label" text="Modified at"/>:
					<tag:formatDate value="${displayedOriginal.lastModifiedAt}" />)
				</span>
				</c:if --%>
			</span>
			</td>
		</tr>
		<c:forEach items="${diff}" var="item">
			<c:if test="${item.readable}">
				<tr ${item.different ? 'class="different highlighted"' : ''} style="${item.different ? '' : 'display:none;'}">
					<td class="copy label">
						<spring:message text="${item.fieldPair.left.label}" var="leftLabel"/>
						${leftLabel}
						<%-- c:if test="${item.copyHtml != null}">
							${formatSelector}
						</c:if --%>
					</td>
					<td class="copy value ${item.copyUpdated ? 'updated' : '' }">
						<c:choose>
							<c:when test="${item.copyHtml != null}">
								<span class="html">${item.copyHtml}</span>
								<span class="wiki" style="display: none;"><c:out value="${item.copy}" /></span>
							</c:when>
							<c:otherwise>
								<span>
									<spring:message code="tracker.choice.${item.copyRendered}.label" text="${item.copyRendered}" htmlEscape="true"/>
								</span>
							</c:otherwise>
						</c:choose>
					</td>
					<td class="controls">
						<c:if test="${item.different}">
							<c:choose>
								<c:when test="${item.table}">
									<c:set var="fieldId" value="${item.tableColumns}" />
								</c:when>
								<c:otherwise>
									<c:set var="fieldId" value="${item.fieldPair.left.id}" />
								</c:otherwise>
							</c:choose>
							<c:if test="${editable and item.editable and item.compatible}">
								<ui:applyCheckbox initialState="false" fieldId="${fieldId }" name="apply_${item.fieldPair.left.id}"
									extraCssClass="${item.table ? 'tableField' : '' }"/>
							</c:if>

							<%-- if the field is a wiki field then show the diff popup link and the items exist on both branches/ends--%>
							<c:if test="${item.fieldPair.left.wikiTextField && item.trackerItemPair.left != null && item.trackerItemPair.right != null}">
							 	<c:url value="/proj/trackers/compareTrackerItemPairRevisions.spr" var="diffUrl">
							 		<c:param name="fieldId" value="${fieldId }"></c:param>
							 		<c:param name="revision1" value="${item.trackerItemPair.left.id }/${item.trackerItemPair.left.version }"></c:param>
							 		<c:param name="revision2" value="${item.trackerItemPair.right.id }/${item.trackerItemPair.right.version }"></c:param>
							 		<c:param name="hideActionBar" value="true"></c:param>
							 	</c:url>

							 	<a onclick="launch_url('${diffUrl }');" class="colored-diff-link"><spring:message code="baseline.diff.label" text="Show diff"/></a>
							</c:if>
							<c:if test="${editable}">
								<c:if test="${not item.editable }">
									<spring:message code="issue.import.roundtrip.field.not.editable" text="Not editable"/>
								</c:if>

								<c:if test="${not item.compatible }">
									<spring:message code="issue.import.roundtrip.field.not.compatible" text="Value not compatible with reference configuration"/>
								</c:if>
							</c:if>
						</c:if>
					</td>
					<td class="original label">
						<spring:message text="${item.fieldPair.right.label}" var="rightLabel"/>
						${rightLabel}

						<c:if test="${not empty triggeringFields and fn:contains(triggeringFields, item.fieldPair.right) }">
							<spring:message code="diffTool.field.triggering.suspected" text="The change of this field triggered the suspected flag" var="triggerTitle"/>
							<span class="triggering-field" title="${triggerTitle }"></span>
						</c:if>

						<%--c:if test="${item.originalHtml != null}">
							${formatSelector}
						</c:if --%>
					</td>
					<td class="original value ${item.originalUpdated ? 'updated' : '' }">
						<c:choose>
							<c:when test="${item.originalHtml != null}">
								<span class="html">${item.originalHtml}</span>
								<span class="wiki" style="display: none;"><c:out value="${item.original}" /></span>
							</c:when>
							<c:otherwise>
								<span>
									<spring:message code="tracker.choice.${item.originalRendered}.label" text="${item.originalRendered}" htmlEscape="true"/>
								</span>
							</c:otherwise>
						</c:choose>
					</td>
				</tr>
			</c:if>
		</c:forEach>
		</tbody>
	</table>

</div>