<%-- Licence expiry warning --%>
<c:if test="${licenseCode != null and licenseCode.expireDateInDays < (licenseCode.eval ? 31 : 15)}">

	<c:if test="${isSysAdmin}">
		<c:set var="contactURL" value="mailto:support@intland.com?subject=License%20Request%20for%20Host-ID:%20 ${HOSTID}" />

		<c:set var="licenseExpiredMsg">
			<spring:message code="your" text="Your"/>
			<c:out value="${licenseCode.productLicense.type}"/>
			<a href="<c:url value="/sysadmin/configLicense.spr" />"><spring:message code="license" text="License"/></a>
			<c:choose>
				<c:when test="${licenseCode.expireDateInDays gt 0}">
					<spring:message code="license.willExpire" text="will expire in {0} days" arguments="${licenseCode.expireDateInDays}"/>.
				</c:when>
				<c:otherwise>
					<spring:message code="license.hasExpired" text="has expired"/>.
				</c:otherwise>
			</c:choose>

			<spring:message code="license.renewal" text="Please contact Intland Software for a license code. <br/> When requesting the license code please attach your unique Host-ID, which is:" arguments="${contactURL}, ${HOSTID}"/>
		</c:set>

		<%
			GlobalMessages globalMessages = GlobalMessages.getInstance(request);
			String licenseExpiredMsg = (String) pageContext.findAttribute("licenseExpiredMsg");
			globalMessages.error(licenseExpiredMsg);
		%>
	</c:if>
</c:if>