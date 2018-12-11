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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<script src="<ui:urlversioned value='/reviews/initPreventPrefill.js'/>"></script>

<style type="text/css">
	.miniprogressbar {
		width: 100%;
	}

	form label {
		font-weight: bold;
		padding-right: 10px;
	}

    form button {
        margin-right: 10px;
    }
</style>


<ui:actionMenuBar>
	<spring:message code="review.${review.mergeRequest ? 'merge.' : '' }complete.title" text="Complete Review"/>
</ui:actionMenuBar>
<c:if test="${not empty sourceTracker or not empty targetTracker}">
	<div class="contentWithMargins">
			<span class="hint">
				<c:if test="${not empty sourceTracker}">
					<label class="optional"><spring:message code="review.statistics.source.${branchMergeRequest or sourceTracker.branch ? 'branch' : 'tracker'}.label" text="Source Branch"/>:</label>
					<ui:wikiLink item="${sourceTracker}" useKeyInLabel="true"/>
				</c:if>
				<c:if test="${not empty targetTracker}">
					, <label class="optional"><spring:message code="review.statistics.target.${branchMergeRequest or targetTracker.branch ? 'branch' : 'tracker'}.label" text="Target Branch"/>:</label>
					<ui:wikiLink item="${targetTracker}" useKeyInLabel="true"/>
				</c:if>
			</span>
	</div>
</c:if>

<div class="contentWithMargins">
	<c:if test="${not canComplete}">
		<div class="warning">
			<spring:message code="review.finish.not.not.enough.signatures.warning" arguments="${minimumNumberOfSignatures},${nunmberOfSignatures}"/>
		</div>
	</c:if>

	<form:form>
		<spring:message code="review.complete.stats" text="From ${stats.total } items you accepted ${stats.accepted } and rejected ${stats.rejected }." arguments="${stats.total },${stats.accepted },${stats.rejected }"/>

		<h3>
			<spring:message code="review.${review.mergeRequest ? 'merge.' : '' }progress.progress.summary" text="Progress of all reviewers reviewers"></spring:message>
		</h3>

		<jsp:include page="includes/reviewProgress.jsp"></jsp:include>

		<c:if test="${canComplete}">
			<p>
				<label for="comment"><spring:message code="review.complete.final.comments.label" text="Comment"/>:</label>
				<form:textarea path="comment" cssStyle="width: 100%;" rows="5"/>
			</p>

			<c:if test="${requiresSignature }">
				<div class="field">
					<label for="baselineSignature" class="mandatory"><spring:message code="baseline.signature.label" text="Baseline Signature"/>:</label>
					<form:password path="baselineSignature" size="30" maxlength="30" autocomplete="new-password"/><form:errors path="baselineSignature" cssClass="invalidfield"></form:errors>
				</div>
			</c:if>
		</c:if>

		<p style="margin-top: 10px;">
			<spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }approve.label" text="Approve" var="approveLabel"></spring:message>
			<spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }request.new.version.label" text="Request New Version" var="requestNewVersionLabel"></spring:message>
			<spring:message code="review.complete.map.statuses.label" text="Set Statuses" var="setStatusesLabel"></spring:message>
			<spring:message code="review.complete.merge.label" text="Merge" var="mergeLabel"></spring:message>
			<spring:message code="review.complete.merge.and.finish.label" text="Merge Items &amp; Finish" var="mergeAndFinishLabel"></spring:message>
			<spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }approve.for.user.label" text="Sign Review" var="signReviewLabel"/>

			<c:if test="${review.requiresSignatureFromReviewers and not review.isUserCompletedReview(user)}">
				<%-- show the finish for user button when signature for reviewers is enabled --%>
				<button name="status" class="button" value="FINISH_FOR_USER">${signReviewLabel }</button>
			</c:if>

			<c:if test="${canComplete}">

				<c:if test="${review.mergeRequest and canMerge }">
					<button name="status" class="button" value="MERGE_AND_FINISH"
							onclick="return askForConfirmation(event, this, ${hasApprovedItems});">${mergeAndFinishLabel }</button>
					<button name="status" class="button" value="MERGE">${mergeLabel }</button>
				</c:if>

				<button name="status" class="button" value="FINISH">${approveLabel }</button>

				<c:if test="${!review.mergeRequest }">
					<c:if test="${canSetStatuses }">
						<button name="status" class="button" value="SET_STATUSES">${setStatusesLabel }</button>
					</c:if>
				</c:if>
				<button name="status" class="button" value="RESTART">${requestNewVersionLabel }</button>
			</c:if>

		</p>
	</form:form>
</div>

<script type="text/javascript">
    function askForConfirmation (event, target, hasApprovedItems) {
        if (!hasApprovedItems) {
            event.preventDefault();

            showFancyAlertDialog(i18n.message('review.merge.no.items.to.merge.message'), 'warning');

            return;
		}

      var $button = $(target);
      if ($button.data('confirmed')) {
		  return true;
		}

        event.preventDefault();

        showFancyConfirmDialogWithCallbacks(i18n.message('review.complete.merge.and.finish.confirm.message'), function () {
            $button.data('confirmed', true);
			$button.click();
		}, null, 'warning');

	};
</script>


