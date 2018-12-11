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
<%@ taglib prefix="ui" uri="uitaglib" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="wysiwyg" uri="wysiwyg" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<script src="<ui:urlversioned value='/reviews/initPreventPrefill.js'/>"></script>

<spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }request.new.version.label" text="Restart Review"
                var="restartLabel"/>

<ui:actionMenuBar>
    ${restartLabel}
</ui:actionMenuBar>

<div class="contentWithMargins">
    <form:form>
        <p>
            <label for="comment"><spring:message code="review.complete.final.comments.label" text="Comment"/>:</label>
            <form:textarea path="comment" cssStyle="width: 100%;" rows="5" autocomplete="off"/>
        </p>

        <div class="field">
            <label for="baselineSignature" class="mandatory"><spring:message code="baseline.signature.label" text="Baseline Signature"/>:</label>
            <form:password path="baselineSignature" size="30" maxlength="30" autocomplete="new-password"/><form:errors path="baselineSignature" cssClass="invalidfield"></form:errors>
        </div>

        <p style="margin-top: 10px;">
            <button name="status" class="button" value="RESTART" style="margin-right: 10px;">${restartLabel }</button>
        </p>
    </form:form>
</div>