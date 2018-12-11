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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>

<ui:coloredEntityIcon subject="${copy}" iconUrlVar="copyIconUrl" iconBgColorVar="copyIconBgColor"/>
<ui:coloredEntityIcon subject="${original}" iconUrlVar="originalIconUrl" iconBgColorVar="originalIconBgColor"/>
<c:url var="copyIconUrl" value="${copyIconUrl}"/>
<c:url var="originalIconUrl" value="${originalIconUrl}"/>
<thead>
    <tr class="sizer">
        <th class="label"></th>
        <th class="value"></th>
        <th class="controls"></th>
        <th class="label"><news/th>
        <th class="value"></th>
    </tr>
    <tr class="header">
        <th colspan="2">
            <tag:summary item="${copy}" htmlEscape="true"/>
            <c:if test="${not empty copyLabel }">
                (${copyLabel })
            </c:if>
        </th>
        <th class="controls">
            <c:if test="${!hideApplyAll and editable and not onlyReadonlyChanges and (!checkEditAndDeletePermissions || canEditOnTarget)}">
                <ui:applyCheckbox initialState="false" name="all" biDirectional="${isBidirectionalAssociation}" rightEditable="true" leftEditable="true" />
            </c:if>
        </th>
        <th colspan="2">
            <c:choose>
                <c:when test="${not empty originalLabel }">
                    (${originalLabel })
                </c:when>
                <c:otherwise>
                    <tag:summary item="${original}" var="originalItemSummary"/>
                    <spring:message code="diffTool.original" arguments="${originalItemSummary}" htmlEscape="true" argumentSeparator=";;;"/>
                </c:otherwise>
            </c:choose>
        </th>
    </tr>
</thead>