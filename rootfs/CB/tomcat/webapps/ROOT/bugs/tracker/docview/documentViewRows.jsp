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

<c:forEach items="${paragraphs}" var="par" varStatus="loopStatus">
	<c:set var="paragraph" value="${par }" scope="request"/>
		<c:choose>
			<c:when test="${loopStatus.last}">
				<c:set var="dataAttribute" value='data-matching-ids="${matchingIds }" data-hasmore-before="${par.value.id != firstItem.value.id}" data-hasmore-after="${par.value.id != lastItem.value.id}"' scope="request"/>
			</c:when>
			<c:when test="${loopStatus.first }">
				<c:set var="dataAttribute" value='data-hasmore-before="${par.value.id != firstItem.value.id}" data-hasmore-after="${par.value.id != lastItem.value.id}" data-valueid="${firstItem.value.id }"' scope="request"/>
			</c:when>
			<c:otherwise>
				<c:set var="dataAttribute" value='data-hasmore-before="true" data-hasmore-after="true"' scope="request"/>
			</c:otherwise>
		</c:choose>
	<jsp:include page="documentViewRow.jsp"/>
</c:forEach>
