<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="type" required="true" type="java.lang.String" description="Type of the message box. Accepted values: information, warning and error" %>
<%@ attribute name="containerId" required="false" type="java.lang.String" description="Id for the container element." %>
<%@ attribute name="messageId" required="false" type="java.lang.String" description="Id for the container element." %>
<%@ attribute name="style" required="false" type="java.lang.String" description="Inline style for the message element." %>
<%@ attribute name="isSingleMessage" required="false" type="java.lang.Boolean" description="Adds the item version to the item url" %>
<%@ attribute name="isContainerRequired" required="false" type="java.lang.Boolean" description="Adds a div around with the infoNessages class. Default is true." %>

<c:if test="${empty isSingleMessage}">
	<c:set var="isSingleMessage" value="${false}" />
</c:if>

<c:if test="${empty isContainerRequired || isContainerRequired == true}">
	<c:set var="isContainerRequired" value="${true}" />
</c:if>

<c:choose>
	<c:when test="${type == 'error'}">
		<c:set var="cssClass" value="error"/>
	</c:when>
	<c:when test="${type == 'warning'}">
		<c:set var="cssClass" value="warning"/>
	</c:when>
	<c:otherwise>
		<c:set var="cssClass" value="information"/>
	</c:otherwise>
</c:choose>

<c:if test="${isContainerRequired}">
	<div class="infoMessages" <c:if test="${not empty containerId}">id="${containerId}"</c:if>>
</c:if>

		<div <c:if test="${not empty messageId}">id="${messageId}"</c:if> class="${cssClass}<c:if test="${isSingleMessage}"> onlyOneMessage</c:if>" <c:if test="${not empty style}">style="${style}"</c:if>>
			<jsp:doBody var="tagBody" />
			${ui:sanitizeHtml(tagBody)}
		</div>

<c:if test="${isContainerRequired}">
	</div>
</c:if>

