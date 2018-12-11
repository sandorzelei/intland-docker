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
<%-- rows of the diff table. request variables that this jsp file expects:
 * diff: a TrackerItemFieldDiff instance. this contains the list of differences
 * showOmittedFields: if true then we show the omitted fields in the table
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="formatSelector">
    <select class="formatSelector">
        <option value="html">HTML</option>
        <option value="wiki">Wiki</option>
    </select>
</c:set>

<c:forEach items="${diff.diff}" var="item"> <%-- item is a TrackerItemFieldDiff instance --%>
    <%-- do not show the diff if it's omit merge property is true or if it is not readable at all --%>
    <c:if test="${item.readable and (ignoreOmittedFields or (showOmittedFields and item.omitMerge or !showOmittedFields and !item.omitMerge))}">
        <tr ${item.different ? 'class="different highlighted"' : ''} style="${item.different ? '' : 'display:none;'}">
            <td class="copy label">
                <spring:message code="tracker.field.${item.fieldPair.left.label}.label" text="${item.fieldPair.left.label}" var="leftLabel"/>
                    ${leftLabel}
                <c:if test="${item.copyHtml != null}">
                    ${formatSelector}
                </c:if>
            </td>
            <td class="copy value ${item.copyUpdated ? 'updated' : '' }">
                <c:choose>
                    <c:when test="${item.copyHtml != null}">
                        <span class="html">${item.copyHtml}</span>
                        <span class="wiki" style="display: none;"><c:out value="${item.copy}" /></span>
                    </c:when>
                    <c:otherwise>
                        <span>
                            <c:choose>
                                <c:when test="${item.fieldPair.left.table}">
                                    <spring:message code="tracker.choice.${item.copyRendered}.label" text="${ui:sanitizeHtml(item.copyRendered)}"/>
                                </c:when>
                                <c:otherwise>
                                    <spring:message code="tracker.choice.${item.copyRendered}.label" text="${item.copyRendered}" htmlEscape="true"/>
                                </c:otherwise>
                            </c:choose>
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
                    <c:if test="${editable and (item.editable or item.rightEditable) and item.compatible and (!checkEditAndDeletePermissions || canEditOnTarget)}">
                        <ui:applyCheckbox initialState="false" fieldId="${fieldId }" name="apply_${item.fieldPair.left.id}"
                                          extraCssClass="${item.table ? 'tableField' : '' }" biDirectional="${isBidirectionalAssociation}"
                                            leftEditable="${item.editable}" rightEditable="${item.rightEditable}"/>
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
                <spring:message code="tracker.field.${item.fieldPair.right.label}.label" text="${item.fieldPair.right.label}" var="rightLabel"/>
                    ${rightLabel}

                <c:if test="${not empty triggeringFields and fn:contains(triggeringFields, item.fieldPair.right) }">
                    <spring:message code="diffTool.field.triggering.suspected" text="The change of this field triggered the suspected flag" var="triggerTitle"/>
                    <span class="triggering-field" title="${triggerTitle }"></span>
                </c:if>

                <c:if test="${item.originalHtml != null}">
                    ${formatSelector}
                </c:if>
            </td>
            <td class="original value ${item.originalUpdated ? 'updated' : '' }">
                <c:choose>
                    <c:when test="${item.originalHtml != null}">
                        <span class="html">${item.originalHtml}</span>
                        <span class="wiki" style="display: none;"><c:out value="${item.original}" /></span>
                    </c:when>
                    <c:otherwise>
                        <span>
                            <c:choose>
                                <c:when test="${item.fieldPair.right.table}">
                                    <spring:message code="tracker.choice.${item.originalRendered}.label" text="${ui:sanitizeHtml(item.originalRendered)}"/>
                                </c:when>
                                <c:otherwise>
                                    <spring:message code="tracker.choice.${item.originalRendered}.label" text="${item.originalRendered}" htmlEscape="true"/>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </c:otherwise>
                </c:choose>
            </td>
        </tr>
    </c:if>
</c:forEach>