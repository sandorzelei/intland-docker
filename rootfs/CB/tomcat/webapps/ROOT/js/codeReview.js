/*
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */
var codeReview = {};

(function($) {
	var mydata = null;
	var fromCommentId = -1;
	var loadingReviews = false;

	var isEditorRow = function(row) {
		var $row = $(row);
		// dont' decorate if this is the editor
		if ($row.hasClass('codeReviewEditor')) {
			return true;
		}
		if ($row.hasClass('codeReviewContent')) {
			return true;
		}
		return false;
	};

	var mouseEnter = function(event) {
		var $this = $(this);
		if (isEditorRow($this)) {
			return;
		}

		$this.addClass("codeReview");
		var $td = $(this).find("td").first();
		if (! $td.attr("title")) {	// preserve original tooltip if there is something
			$td.attr("title", i18n.message('scm.review.diff.row.title'));
		}
		$td.append("<a href='#' class='codeReviewButton' title='" + i18n.message('scm.review.button.title') + "'></a>");
	};

	var mouseLeave = function(event) {
		var $this = $(this);
		if (isEditorRow($this)) {
			return;
		}

		$this.removeClass("codeReview");
		$this.find("td").find(".codeReviewButton").remove();
	};

	// show the review dialog inside the table
	var openReview = function(event) {
		event.preventDefault();
		event.stopPropagation();

		var $row = $(this).closest("tr");
		if (isEditorRow($row)) {
			return;
		}
		// check if there is already an editor open for this row? then don't create a new editor, but focus on the existing one
		var $next = $row.next();
		if ($next.hasClass("codeReviewEditor")) {
			$next.find("textarea").focus();
			return;
		}
		$row.after("<tr class='codeReviewEditor' title='" + i18n.message('scm.review.comment.editor.title') + "'>" +
					"<td colspan='99'><textarea></textarea>" +
					"<input type='button' class='saveCodeReview' value='Save' title='" + i18n.message('scm.review.comment.save.button.title') +"'/>" +
					"<a href='#' class='cancelCodeReview'>Cancel</a></td></tr>");
		var $newrow = $row.next();
		$newrow.find("textarea").focus();
	};

	var computeLineNumbers = function(element) {
		// compute line numbers for the table.diff and store it in the lineno attr for each tr-s
		var lineno = 0;
		var $diffTable = $(element).closest("table.diff");
		if ($diffTable.hasClass('withLineNumbers')) {
			return;	// already computed, don't do again
		}
		$diffTable.addClass("withLineNumbers");

		$diffTable.find("tr").each(function() {
			if (!isEditorRow(this)) {
				$(this).attr("lineno", lineno ++);
			}
		});
	};

	var getLineNo = function(tr) {
		var $tr = $(tr).closest("tr");
		if (isEditorRow(this)) {
			return null;
		}
		var lineno = $tr.attr("lineno");
		if (lineno == null) {
			// missing the linen numbers, compute them for the table.diff and store it in the lineno attr for each tr-s
			computeLineNumbers(tr);
			lineno = $tr.attr("lineno");
		}
		return lineno;
	};

	var findLine = function(diffContainer, lineNo) {
		// TODO: this is very simplistic and slow, find better!
		var $diffTable = $(diffContainer).find("table.diff");
		// ensure line numbers are computed
		computeLineNumbers($diffTable);

		var tr = $diffTable.find("tr[lineno=" + lineNo +"]").first();
		return tr.length == 0 ? null : tr[0];
	};

	var getChangeFileData = function(element) {
		var $diffContainer = $(element).closest(".diffContainer");

		// TODO: now few attributes are holding the scm data, maybe the complete ScmChangeFile should be put here as JSON using jquery's data() method ?
		var filePath = $diffContainer.attr("scmChangeFilePath");
		var newRevision = $diffContainer.attr("scmChangeFileNewRevision");

		return {
			"filePath" : filePath,	   // TODO: add file path
			"revision" : newRevision   // TODO: add file revision
		};
	};

	var saveReview = function(event) {
		event.preventDefault();

		var reviewText = $(this).closest(".codeReviewEditor").find("textarea").val();
		console.log("Saving review text <" + reviewText +">");
		// TODO: the line number is just the line number in the diff !!!
		// find the line number of the previous row
		var $previousRow = $(this).closest("tr").prev();
		var lineno = getLineNo($previousRow);

		var changeFileData = getChangeFileData(this);

		var review = $.extend(changeFileData, {
			"comment" : reviewText,
			"line" : lineno
		});

		var submitData = $.extend({}, mydata);
		for (var prop in review) {
			submitData["review." + prop] = review[prop];
		}

		// TODO: error handling ?
		$.ajax({
			url: contextPath + "/scm/submitReview.spr",
			type: "POST",
			data: submitData,
			success: function(reviews) {
				// the add element sends back the review, adding this to the table
				showReviews(reviews, true);
			}
		});

		closeEditor.apply(this, [event]);
	};

	var closeEditor = function(event) {
		event.preventDefault();
		// close the editor
		$(this).closest(".codeReviewEditor").remove();
	};

	/**
	 * @return the new row added
	 */
	var showReview = function(review, flash) {
		var newRow = null;
		$(".diffContainer").each(function() {
			var changeFileData = getChangeFileData(this);
			// check if all props are same
			for (var prop in changeFileData) {
				var v = changeFileData[prop];
				var r = review[prop];
				if (v != r) {
					return;	// not found
				}
			}
			// found the diffContainer for this !
			// find the line
			var row = findLine(this, review.line);
			var comment = $(".codeReviewContent#" + review.commentId);
			if (row != null && comment.size() == 0) {
				$(row).after("<tr class='codeReviewContent' id='" + review.commentId + "'><td colspan='99'>" + review.comment + "</td></tr>");	// TODO: show user's name/id too!
				newRow = $(row).next();
			}
		});

		if (review.commentId && review.commentId > fromCommentId) {
			fromCommentId = review.commentId;
		}

		return newRow;
	};

	/**
	 * @param reviews The reviews to show
	 * @param flash If the new rows are flashed
	 * @return the array of the new rows added
	 */
	var showReviews = function(reviews, flash) {
		if (reviews.hasOwnProperty('errorMessage')) {
			alert(reviews['errorMessage']);
			return;
		}
		var newRows = [];
		for (var i=0; i<reviews.length; i++) {
			var newRow = showReview(reviews[i], flash);
			if (newRow) {
				newRows.push(newRow);
			}
		};
		if (flash) {
			// flash/highlight the new rows
			for (var i=0; i<newRows.length;i++) {
				flashChanged($(newRows[i]).find("td"));
			}
		}
		return newRows;
	};

	// load the reviews from the entity via ajax
	var loadReviews = function(flash) {
		if (loadingReviews) {
			return;	// already loading...
		}
		loadingReviews = true;

		var data = $.extend({}, mydata, {"fromCommentId": fromCommentId});
		$.ajax({
			url: contextPath + "/scm/loadReviews.spr",
			type: "GET",
			data: data,
			success:function(reviews) {
				showReviews(reviews, flash);
			}
		}).always(function() {
			loadingReviews = false;
		});
	};

	var initEvents = function() {
		// init events
		// $("table.diff").each(function)

		// Clear previous event listeners, if any exists
		$(document).off("mouseenter.codeReview");
		$(document).off("mouseleave.codeReview");
		$(document).off("dblclick.codeReview");
		$(document).off("click.codeReview");


		var diffRows = "table.diff tr";
		$(document).on("mouseenter.codeReview", diffRows, mouseEnter)
					.on("mouseleave.codeReview", diffRows, mouseLeave)
					.on("dblclick.codeReview", diffRows, openReview);	// Note: double click is used to allow selection of the text using single click
		$(document).on("click.codeReview", diffRows + " .codeReviewButton", openReview);
		$(document).on("click.codeReview", diffRows + " .saveCodeReview", saveReview);
		$(document).on("click.codeReview", diffRows + " .cancelCodeReview", closeEditor);
	};

	/**
	 * @param data The data contains the entityTypeId and entityId of the entity where the code review goes
	 */
	codeReview.init = function(data) {
		var $this = $(this);

		mydata = data;

		initEvents();

		var keepFetching = false;
		if (keepFetching) {
			var loadReviewsIfDiffsVisible = function() {
				// only ping the server if there is any diff visible to avoid unwanted overloading the server
				if ($("table.diff:visible").length > 0) {
					loadReviews(true);
				}
			};

			loadReviewsIfDiffsVisible();
			// keep fetching the new reviews
			setInterval(loadReviewsIfDiffsVisible, 2000);
		} else {
			loadReviews(false);
		}

		return $this;
	};

	codeReview.reset = function () {
		fromCommentId = -1;
	}

})(jQuery);
