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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%-- use the pullrequest-to-send if an existing pullrequest is not available in the model --%>
<c:if test="${empty pullRequest}">
	<c:set var="pullRequest" value="${sendPullRequestForm.pullRequest}"/>
</c:if>

<div class="actionBar" style="margin-bottom: 15px;"></div>

<%-- manual merge instructions --%>
<c:if test="${canMerge}">
<div class="commands">
	<b>Resolving the conflicts by manual merging</b><br>
	Follow these steps to resolve the merge conflicts using the commandline client <tt><c:out value='${pullRequest.targetRepository.type}'/></tt>.
	<c:choose>
		<c:when test="${pullRequest.targetRepository.type eq 'git'}">
			<p>
			<b>1.</b> In case you already have a local clone of <b><c:out value='${pullRequest.targetRepository.name}'/></b>, switch to the <b><c:out value='${pullRequest.targetBranch}'/></b> branch and update that by:
<pre>$ cd full/path/to/<c:out value='${pullRequest.targetRepository.name}'/>
$ git checkout <c:out value='${pullRequest.targetBranch}'/>
$ git pull origin <c:out value='${pullRequest.targetBranch}'/></pre>
			</pre>
			If you don't have a local clone yet, clone <b><c:out value='${pullRequest.targetRepository.name}'/></b> and switch to the <b><c:out value='${pullRequest.targetBranch}'/></b> branch by:
<pre>$ git clone <c:out value='${targetRepositoryModel.firstPullSource}'/>
$ cd <c:out value='${pullRequest.targetRepository.name}'/>
$ git checkout <c:out value='${pullRequest.targetBranch}'/></pre>
			</p>
			<p>
				<c:choose>
					<c:when test="${hasNewChanges}">
						<b>2.</b> Fetch the changes from <b><c:out value='${pullRequest.sourceRepository.name}'/></b>:
						<pre>$ git fetch <c:out value='${sourceRepositoryModel.firstPullSource} ${pullRequest.sourceBranch}'/></pre>
						Then merge the changes up to <b><c:out value='${pullRequest.sourceLastRevision}'/></b>:
						<pre>$ git merge <c:out value='${pullRequest.sourceLastRevision}'/></pre>
					</c:when>
					<c:otherwise>
						<b>2.</b> Pull the changes from <b><c:out value='${pullRequest.sourceRepository.name}'/></b>:
						<pre>$ git pull <c:out value='${sourceRepositoryModel.firstPullSource} ${pullRequest.sourceBranch}'/></pre>
					</c:otherwise>
				</c:choose>
				<span class="subtext">Tip: <a href="http://book.git-scm.com/3_distributed_workflows.html">create a remote</a> if you merge with <b><c:out value='${pullRequest.sourceRepository.name}'/></b> frequently.</span>
			</p>
			<p>
			<b>3.</b> Open the conflicting files in your favourite editor, and resolve the conflicts one by one.
			</p>
			<p>
			<b>4.</b> Commit and push your changes to the server:
<pre>$ git commit -a -m &quot;<c:choose><c:when test="${not empty pullRequest.id}">#${pullRequest.id} Conflicts resolved for <c:out value='${pullRequest.keyAndId}'/></c:when><c:otherwise>Conflicts resolved</c:otherwise></c:choose>&quot;
$ git push origin <c:out value='${pullRequest.targetBranch}'/></pre>
			</p>
			<p>
			<b>5.</b> Done.
			</p>
		</c:when>
		<c:when test="${pullRequest.targetRepository.type eq 'hg'}">
			<p>
			<b>1.</b> In case you already have a local clone of <b><c:out value='${pullRequest.targetRepository.name}'/></b>, update that by:
<pre>$ cd full/path/to/<c:out value='${pullRequest.targetRepository.name}'/>
$ hg pull -u <c:out value='${pullRequest.targetBranch}'/></pre>
			</pre>
			If you don't have a local clone yet, make that by:
<pre>$ hg clone <c:out value='${targetRepositoryModel.firstPullSource}'/>
$ cd <c:out value='${pullRequest.targetRepository.name}'/></pre>
			</p>
			<p>
			<b>2.</b> Pull the changes from <b><c:out value='${pullRequest.sourceRepository.name}'/></b>:
<pre>$ hg pull -u -b <c:out value='${pullRequest.sourceBranch} ${sourceRepositoryModel.firstPullSource}'/>
$ hg merge</pre>

				<span class="subtext">Tip: create a <a href="http://www.selenic.com/mercurial/hgrc.5.html#paths">symbolic name</a> if you merge with <b><c:out value='${pullRequest.sourceRepository.name}'/></b> frequently.</span>
			</p>
			<p>
			<b>3.</b> Open the conflicting files in your favourite editor, and resolve the conflicts one by one.
			<c:if test="${pullRequest.targetRepository.type eq 'hg'}">
				Mark the conflicting files as resolved:
				<pre>$ hg resolve -m file_name</pre>
			</c:if>
			</p>
			<p>
			<b>4.</b> Commit and push your changes to the server:
<pre>$ hg commit -m &quot;#${pullRequest.id} Conflicts resolved for <c:out value='${pullRequest.keyAndId}'/>&quot;
$ hg push -b <c:out value='${pullRequest.targetBranch}'/></pre>
			</p>
			<p>
			<b>5.</b> Done.
			</p>
		</c:when>
	</c:choose>
</div>
</c:if>

<!-- diffs per conflicting file -->
<c:forEach var="conflictHtml" items="${conflictHtmls}">
	<c:if test="${conflictHtml.key.path != 'NO_DIFF_PLACEHOLDER' }">
		<b><c:out value='${conflictHtml.key.path}'/></b>
		<div style="margin-bottom: 1em;">
			${conflictHtml.value}
		</div>
	</c:if>
</c:forEach>
