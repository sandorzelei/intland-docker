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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="outgoingReferences" value="${referenceData.outgoingReferences }" scope="request"></c:set>
<c:set var="incomingReferences" value="${referenceData.incomingReferences }" scope="request"></c:set>
<c:set var="incomingAssociations" value="${referenceData.incomingAssociations }" scope="request"></c:set>
<c:set var="outgoingAssociations" value="${referenceData.outgoingAssociations }" scope="request"></c:set>
<c:set var="referenceCount" value="${referenceData.referenceCount }" scope="request"></c:set>
<c:set var="overallReferenceCount" value="${referenceData.referenceCount }" scope="request"></c:set>

<jsp:include page="/bugs/tracker/docview/referencesSection.jsp"/>
<jsp:include page="reviewAssociationsSection.jsp"/>