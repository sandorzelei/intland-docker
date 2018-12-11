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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="treeId" fragment="false" required="true"
			  description="The html-id of the tree (jstree) to filter" %>
<%@ attribute name="minFilterLength" fragment="false" required="false" type="java.lang.Integer"
			  description="The minimum length of the filter text. If less characters are entered than this then the filtering is inacivated"
%>
<%@ attribute name="cssStyle" required="false" %>
<%@ attribute name="disableNativeFiltering" required="false" type="java.lang.Boolean"
			  description="If set, no filtering will be done automatically, just 'codebeamer.filtered' custom event will be triggered on the tree" %>
<%@ attribute name="emptyValue" required="false"
			  description="The value used when filter is empty as filter expression" %>
<%@ attribute name="disableEnter" required="false" %>
<%@ attribute name="triggerWithButton" required="false" description="When true then instead of the keypress event the click on a button will trigger the filtering"%>

<%@ attribute name="hideTreeOnNoMatch" required="false" description="Hide the tree when search does not match any nodes. JStree 3 keeps the tree open"%>

<c:if test="${empty minFilterLength}" >
	<c:set var="minFilterLength" value="2" />
</c:if>
<c:if test="${empty emptyValue}">
	<c:set var="emptyValue" value=""/>
</c:if>

<style type="text/css">
	.treeFilterBox {
		width: 120px;
	}
	.treeWithNoMatch {
		visibility: hidden;
	}
</style>

<%--
 Filter box typically above a tree which will filter out some elements from the tree...
--%>
<spring:message code="association.search.as.you.type.label" var="filterLabel" text="${filterLabel}"/>
<c:choose>
	<c:when test="${triggerWithButton}">
		<div class="treeSearchBoxContainer">
			<spring:message code="search.submit.label" var="go" text="GO"></spring:message>
			<div class="treeSearchContainer">
				<div class="treeSearchField">
					<input class="treeFilterBox withButton" type="text" id="searchBox_${treeId}" style="${cssStyle}" title="${filterLabel}" />
					<span id="go_${treeId}" class="treeSearchToggleButton"/>
				</div>
			</div>
		</div>
	</c:when>
	<c:otherwise>
		<input class="treeFilterBox" type="text" id="searchBox_${treeId}" style="${cssStyle}" title="${filterLabel}" />
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	<c:if test="${triggerWithButton}">
	$("#go_${treeId}").click(function() {
		keyupHandler_${treeId}();
	});
	</c:if>
	var keyupHandler_${treeId} = throttleWrapper(function () {
		var v = $("#searchBox_${treeId}").val();
		var tree = $("#${treeId}");

		<c:if test="${not disableNativeFiltering}">
		console.log("Tree is seaching for:" +v);

		if (tree.hasClass("searchRunning")) {
			console.log("Tree-Search is already running, skipping...");
			return;
		}
		tree.addClass("searchRunning");	// avoid multiple parallel search runs if the search is already running

		if (v.length == 0) {
			v = '${emptyValue}';
		}

		if (v.length < ${minFilterLength}) {
			tree.jstree("clear_search");
		} else {
			tree.jstree("search", v);
		}

		</c:if>

		tree.trigger("codebeamer.filtered", [ tree, v ]);
	}, 500);

	$(function() {
		var initSearch_${treeId} = function () {

			var $s = $("#searchBox_${treeId}");
			$s.Watermark("${filterLabel}", "#1e1e1e");

			<c:if test="${!triggerWithButton}">
			$s.keyup(function(e, d) {
				if (e.keyCode == 27) {	//esc should clear search
					$(this).val('');
				}
				if (e.charcode !== 0) {
					keyupHandler_${treeId}.call(this);
				}
			});

			<c:if test="${disableEnter}">
			$s.keypress(function(e) {
				if (e.keyCode == 13) {
					keyupHandler_${treeId}.call(this);
					e.preventDefault();
				}
			});
			</c:if>
			</c:if>

			<c:if test="${triggerWithButton && !disableEnter}">
			$s.keypress(function(e) {
				if (e.keyCode == 13) {
					$("#go_${treeId}").click();
					e.preventDefault();
				}
			});
			</c:if>

			var searchEnds = function(e,data) {
				$(this).removeClass("searchRunning");	// remove marker if the search is running

				<c:if test="${hideTreeOnNoMatch == true}">
				var matchedNodes = data.nodes;
				var empty = data.nodes.length == 0;
				// hide the tree if no matches
				if (empty) {
					$(this).addClass("treeWithNoMatch");
				} else {
					$(this).removeClass("treeWithNoMatch");
				}
				</c:if>
			}
			$("#${treeId}").on("search.jstree", searchEnds)
				.on("clear_search.jstree", searchEnds);
		};
		initSearch_${treeId}();
	});
</script>

