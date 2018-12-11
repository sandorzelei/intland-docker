<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:if test="${not empty startBaseline or not empty endBaseline}">
    <c:choose>
	    <c:when test="${not empty startBaseline and not empty endBaseline}">
            <div class="baseline-info"${baselineRowStyle}>
                <spring:message
                    code="tracker.configuration.history.plugin.baseline.changes.between.message"
                    arguments="${startBaseline.name},${endBaseline.name}"
                    text="You are now viewing changes between <span class=\"baseline-name\">{0}</span> and <span class=\"baseline-name\">{1}</span> baselines">
                </spring:message>
            </div>
		</c:when>
		<c:when test="${empty startBaseline and not empty endBaseline}">
            <div class="baseline-info"${baselineRowStyle}>
                <spring:message
                    code="tracker.configuration.history.plugin.baseline.changes.until.message"
                    arguments="${endBaseline.name}"
                    text="You are now viewing changes until <span class=\"baseline-name\">{0}</span> baseline">
                </spring:message>
            </div>
        </c:when>
        <c:otherwise>
            <div class="baseline-info"${baselineRowStyle}>
                <spring:message
                    code="tracker.configuration.history.plugin.baseline.changes.since.message"
                    arguments="${startBaseline.name}"
                    text="You are now viewing changes since <span class=\"baseline-name\">{0}</span> baseline">
                </spring:message>
            </div>
        </c:otherwise>
    </c:choose>
</c:if>