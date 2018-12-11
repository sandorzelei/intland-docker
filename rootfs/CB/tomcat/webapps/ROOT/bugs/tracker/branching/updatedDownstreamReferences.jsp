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

<%-- renders a table with all the updated downstream references --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:if test="${not empty updatedDownstreamSet }">
	<span class="hint"><spring:message code="tracker.branching.merge.updated.downstream.head.warning"/></span>
	<ul class="updated-downstream-references" data-item-id="${referredItem.id }">
		<c:forEach items="${updatedDownstreamSet }" var="referenceInfo"> <%-- referenceInfo is a com.intland.codebeamer.controller.branching.BranchReferenceInfo object --%>
			<li>
				<c:set var="disabled" value=""/>
				<c:if test="${not referenceInfo.canUpdate or disableDownstreamCheckboxes }">
					<c:set var="disabled" value="disabled='disabled'"/>
				</c:if>
				<%-- TODO: check if the user can update the item, otherwise do not show the checkbox --%>
				<label><input type="checkbox" class="${referenceInfo.canUpdate ? 'editable' : '' }" value="${referenceInfo.field.id }-${referenceInfo.referringItem.id}" name="incomingReferencesToUpdate" ${disabled }/>
		        	<ui:wikiLink item="${referenceInfo.referringItem }" ></ui:wikiLink>

					<spring:message code="tracker.field.${referenceInfo.field.label }.label" text="${referenceInfo.field.label }" var="fieldLabel"></spring:message>
		        	<span style="position: relative; top: 2px;">
		        		<spring:message code="tracker.branching.merge.updated.downstream.field.label" arguments="${fieldLabel }" text=" in ${fieldLabel } field"></spring:message>
		        	</span>
				</label>
			</li>
		</c:forEach>
	</ul>
</c:if>
