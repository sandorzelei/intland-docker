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
 *
 */

var codebeamer = codebeamer || {};
codebeamer.review = codebeamer.review || (function($) {
	var ReviewItemState = {
			ACCEPTED: "ACCEPTED",
			REJECTED: "REJECTED",
			NOT_REVIEWED: "NOT_REVIEWED"
	};

	var config = {};

	var init = function (options) {
		config = $.extend(config, options);

		setUpEventHandlers();

		setIssueClickSelectNodeInTree("#centerDiv", "reviewTree");

		setUpTreeStateStorage();
	};

	var setUpTreeStateStorage = function () {
		$.jstree.defaults.state.key = "reviewTree";
	};

	var loadReviewItemReferences = function () {
		var $box = $(this);
		if ($box.is(".initialized")) {
			return;
		}

		var id = $box.closest(".requirementTr").data("reviewId");

		var bs = ajaxBusyIndicator.showBusysign($box, i18n.message("ajax.loading"));
		$.get(contextPath + "/ajax/review/getReviewItemReferences.spr", {
			"task_id": id
		}).done(function (data) {
			$box.find(".collapsingBorder_content").html(data);
			$box.addClass("initialized")
		}).fail(function (data) {
			showOverlayMessage(data, true, 5);
		}).always(function () {
			bs.remove();
		});
	};

	var setUpEventHandlers = function () {
		if (!config.done && config.canEdit) {
			// initialize the items that are available only for inprogress reviews
			$(document).on('click', '.accept', function () {
				var $button = $(this).closest('.review-button');
				var $row = $(this).closest(".requirementTr");

				// this action is not available on closed review items
				if ($row.is(".closed")) {
					return;
				}
				var id = $row.data("reviewId");
				if ($button.is('.accepted')) {
					$button.removeClass('accepted');
					updateReviewItemState(id, ReviewItemState.NOT_REVIEWED);
				} else {
					$button.removeClass('rejected').addClass('accepted');
					updateReviewItemState(id, ReviewItemState.ACCEPTED);
				}
			}).on('click', '.reject', function () {
				var $button = $(this).closest('.review-button');
				var $row = $(this).closest(".requirementTr");

				// this action is not available on closed review items
				if ($row.is(".closed")) {
					return;
				}

				var id = $row.data("reviewId");
				$row.find('.comment-bubble').addClass('adding-comment');

				if ($button.is('.rejected')) {
					$button.removeClass('rejected');
					updateReviewItemState(id, ReviewItemState.NOT_REVIEWED);
				} else {
					// show the commend dialog and reject the item only after the comment was saved
					var url = contextPath + '/proj/tracker/docview/showCommentDialog.spr?task_id=' + id + '&showCommentTypes=true&commentForReject=true&required=true';
					showPopupInline(url, {'geometry': 'large'});
				}
			}).on("codebeamer:reviewItemUpdated", function (reviewItemId) {
				$.get(contextPath + "/ajax/review/getFilters.spr", {
					reviewId: config.reviewId
				}).done(function (data) {

					// update the review filter labels
					for (var key in data) {
						$("[for=" + key + "]").html(data[key]);
					}
				});
			}).on('click','.testStepContainer', function () {
				var $container = $(this);
				// clicking on the test steps box: load test steps
				var id = $container.closest(".requirementTr").attr("data-review-id");
				var $expandable = $container.next(".expandable");

				// the revision is null because the review item already contains the version of the original item
				codebeamer.common.loadContentFromUrl(id, $expandable, "/trackers/ajax/getTestSteps.spr", null, null, false);

				$expandable.toggle();

				var visible = $expandable.is(":visible");
				// change the expander [+]/[-] icon image
				$container.find("img.expander").toggleClass("expanded", visible);
				$('#rightPane').trigger('cbRightPaneHeightChanged');
			}).on('click', '.referenceContainer .collapseToggle', function() {
				$('#rightPane').trigger('cbRightPaneHeightChanged');
			});
		}

		$(document).on('click', '.requirementTr', function () {
			// select the clicked item in the tree (without scrolling the center panel)
			var $row = $(this);

			var nameVisible = $row.data('nameVisible');

			var id = $row.attr("id");

			var $tree = $("#reviewTree");

			var node = $tree.jstree("get_node", id);

			if (nameVisible) {
				// when the user has no permission to the item do not open its properties

				codebeamer.common.selectItemInTree($row, function () {
					if ($row.size() > 0) {
						var rowId = $row.data("reviewId");

						var $target = $('#issuePropertiesPane');
						var currentlyShowing = $target.data("showingIssue");

						if (currentlyShowing != rowId) {
							codebeamer.common.loadProperties(rowId, $target, null, false, null, contextPath + "/reviews/ajax/getIssueProperties.spr", false);
						}

						$(".requirement-active").removeClass("requirement-active");
						$row.addClass("requirement-active");
					}
				}, "reviewTree");
			}
		}).on('mouseover', '.requirementTr', function () {
			if ($(".jstree-contextmenu").size() == 0) {
				var $row = $(this);
				// select the item in the tree when the user moves the cursor over it on the center panel
				// but only if the context menu is not active because otherwise moving above the menu can change the selection
				codebeamer.common.selectItemInTree($row, null, "reviewTree");
			}
		}).on('change', '[name=review-filter]', function () {
			$("[name=review-filter]").attr("disabled", true);

			// reload the right panel
			reload().always(function () {
				$(document).trigger("codebeamer:reviewFiltering.finished");
			});
		}).on('codebeamer:reviewFiltering.finished', function () {
			$("[name=review-filter]").attr("disabled", false);

			// update the url with the new filter
			var filter = $("[name=review-filter]:checked").val();
			var title = $(document).find("title").text();
			History.pushState({filter: filter}, title, contextPath + "/review/" + config.reviewId + "?filter=" + filter);
		}).on('click', '.updatedBadge:not(.branchBadge)', function () {
			if (config.hasEditLicense) {
				var $badge = $(this);

				var url = null;
                var issueId = $badge.data("issueId");

                if ($badge.is('.mergeRequestBadge')) {
					var copyId = $badge.data('copyId');
					url = '/issuediff/diff.spr?disableEditing=true&copy_id=' + copyId + '&original_id=' + issueId;
                } else {
                    var baselineId = $badge.data("baselineId");
                    var newVersion = $badge.data("newVersion");

                    url = "/issuediff/diffVersion.spr?issue_id=" + issueId + "&revision=" + baselineId +
                    	(newVersion ? "&newVersion=" + newVersion : "")
                }

				inlinePopup.show(contextPath + url, {
					geometry: "large"
				});
			} else {
				showLicenseWarning();
			}
        }).on('click', '.updatedBadge.mergeRequestBadge', function () {

		}).on('click', '.updatedBadge.branchBadge', function () {
			var $badge = $(this);
			var masterDiverged = $badge.is(".masterDivergedBadge");

			var originalId = $badge.data("originalId");
			var issueId = $badge.data("issueId");
			inlinePopup.show(contextPath + "/branching/branchMergeRequestDiff.spr?isPopup=true&branchId=" + config.branchId + "&issueIds=" + issueId
					+ "&mergeFromMaster=" + masterDiverged + "&disableEditing=true", {
				geometry: "large"
			});
		}).on('click', '.export-to-word', function () {
			exportToOffice();
		}).on('click', '.comment-bubble', function () {
			var $target = $(this);
			var id = $target.data("reviewItemId");

			$('.adding-comment').removeClass("adding-comment");
			if ($target.data('canview')) {
				var revision = $target.data('revision');
				$target.addClass('adding-comment');
				var url = contextPath + '/proj/tracker/docview/showCommentDialog.spr?task_id=' + id + '&showCommentTypes=true';

				if (revision) {
					url += '&revision=' + revision;
				}

				showPopupInline(url, {'geometry': 'large'});
			}
		}).on("ready.jstree", function() {
			resizeLeftPanel();
		});

		$(window).resize(function () {
			setTimeout(resizeLeftPanel, 800);
		});
	};

	var showLicenseWarning = function () {
		showReviewLicenseWarning();
	};

	var updateCommentCounts = function (taskIds) {
        $.get(contextPath + '/ajax/review/getCommentCount.spr', {
            'taskIds': taskIds.join(',')
        }).done(function (data) {
            for (var i = 0; i < taskIds.length; i++) {
                var itemId = taskIds[i];
                var count = data[itemId];

                if (count) {
                    $('.comment-bubble[data-review-item-id=' + itemId + ']').html(count);
                }
            }
        });
	};

	var reload = function (extraParameters) {
		var url = '/ajax/review/review.spr';
		var urlParameters = getUrlParameters();

		if (extraParameters) {
			urlParameters = $.extend(urlParameters, extraParameters);
		}

		var $container = $(".review-container");
		var bs = ajaxBusyIndicator.showBusysign($container, i18n.message("ajax.loading"))
		var promise = $.get(contextPath + url, urlParameters).done(function (data) {
			$container.html($(data));
			initInfiniteScrolling();
		}).always(function () {
			if (bs) {
				bs.remove();
			}
		});

		return promise;
	};

	var initInfiniteScrolling = function () {
		var url = '/ajax/review/reviewFragment.spr'
		var updatedParams = getUrlParameters();
		codebeamer.infiniteScroller.init({
			url: url,
			defaultParams: updatedParams,
			idAttr: "data-review-id" // the review item id is stored in this attribute for each row
		});
	};

	var getUrlParameters = function () {
		var filter = $("[name=review-filter]:checked").val();

		return {
			filter: filter,
			reviewId: config.reviewId,
			revision: config.revision,
			'remove_query_plugin_row_ids': true
		};
	};

	var updateReviewItemState = function (id, state) {
		$.post(contextPath + "/ajax/review/updateReviewItem.spr", {
			"state": state,
			"task_id": id
		}).done(function (result) {
			if (result.success) {
				showOverlayMessage();
				$(document).trigger("codebeamer:reviewItemUpdated", [id]);
			} else {
				showOverlayMessage(result.error, 5, true);
			}
		});

	};

    /**
	 * resets the review buttons based on state.
     * @param state either 'REJECTED' or 'ACCEPTED' (the valiues from the server side enum)
     */
	var resetAllReviewButtons = function (state) {
        $('.review-button')
            .removeClass('accepted').removeClass('rejected')
            .addClass(state.toLowerCase());
	};

    var batchUpdateReviewItemState = function (state) {
        var busyPage = ajaxBusyIndicator.showBusyPage();
        $.post(contextPath + "/ajax/review/batchUpdateReviewItem.spr", {
            "state": state,
            "reviewId": config.reviewId
        }).done(function (result) {
            if (result.success) {
                showOverlayMessage();
                resetAllReviewButtons(state);

            } else {
                showOverlayMessage(result.error, 5, true);
            }

            if (busyPage) {
            	busyPage.remove();
			}
        });

    };

	var closeReview = function (id) {
		return $.post(contextPath + "/ajax/review/completeReview.spr", {
			"task_id": id
		}).done(function (result) {
			if (result.success) {
				showOverlayMessage();
			} else {
				showOverlayMessage(result.error, 5, true);
			}
		});
	};

	// set tree panel height
	var resizeLeftPanel = throttleWrapper(function() {
		var westHeight = $(".ui-layout-west").height();
		var targetHeight = westHeight - $(".ui-layout-west .actionBar").outerHeight() - $(".ui-layout-west .ditch-tab-wrap").outerHeight();
		$("#tree").height(targetHeight);
	});

	var disablePropertiesPanelOpening = function () {
		// disable opening the right panel when the user has no reviewer license
		if (!config.hasEditLicense) {
			$("#opener-east").unbind().click(showLicenseWarning);
		}
	};

	var nodeClickHandler = function (node) {
		var id = node.li_attr["id"];

		// scroll to the selected element
		var $element = $("tr#" + id);

		if (!codebeamer.treeLoaded || $element.size() == 0) {
			var requestData = {};
			var isTracker = node.li_attr["type"] == "tracker";
			if (!isTracker) {
				$.extend(requestData, {issueId: node.li_attr["reviewItemId"]});

				// find the position of the selected item
				var $rootNode = $("#reviewTree li[type=tracker]");
				var tree = $.jstree.reference("reviewTree");

				var root = tree.get_node($rootNode);
				var nodeIndex = root.children_d.indexOf(node.li_attr["id"]);

				if (nodeIndex >= 0) {
					$.extend(requestData, {selectedPosition: nodeIndex});
				}
			}

			disablePropertiesPanelOpening();

			reload(requestData).done(function () {
				selectElement(node);
				disablePropertiesPanelOpening();
			});
			codebeamer.treeLoaded = true;
		} else {
			selectElement(node);
		}


	};

	var selectElement = function (node) {
		var id = node.li_attr["id"];

		var $element = $("tr#" + id);

		if (!$element.offset()) {
			return;
		}

		var $container = $("#rightPane");
		$('.requirement-active').removeClass('requirement-active');
		$('.selected').removeClass('selected');
		$element.addClass('requirement-active selected');
		$container.animate({"scrollTop": $element.offset().top - $container.offset().top + $container.scrollTop()}, 0);

		// show the issue properties

		var $target = $("#issuePropertiesPane");
		var currentlyShowing = $target.data("showingIssue");
		if (currentlyShowing != node.li_attr["reviewItemId"]) {
			codebeamer.common.loadProperties(node.li_attr["reviewItemId"], $target, null, false, null, contextPath + "/reviews/ajax/getIssueProperties.spr", false);
		}
	};

	var populateTree = function () {
		return {
			"reviewId": config.reviewId
		};
	};

	var loadFirstPage = function () {
		var tree = $.jstree.reference("reviewTree");
		var selected = tree ? tree.get_selected() : null;

		if (!selected || !selected.length) {
			reload().done(function () {
				disablePropertiesPanelOpening();
			});
		}
	};

	var exportToOffice = function () {
		var url = "/reviews/exportReviewAsDocx.spr";
		var urlParams = getUrlParameters();
		showPopupInline(contextPath + url + "?reviewId="
				+ urlParams.reviewId + (urlParams.filter ? "&filter=" + urlParams.filter : "")
            		+ (urlParams.revision ? "&revision=" + urlParams.revision : ""),
				{geometry: 'large'});
	};

	/**
	 * toggles the rejected state of a tracker item (row).
	 */
	var toggleRejected = function ($row) {
		var $button = $row.find('.review-button');
		var id = $row.data('reviewId');

		if ($button.is('.rejected')) {
			$button.removeClass('rejected');
			updateReviewItemState(id, ReviewItemState.NOT_REVIEWED);
		} else {
			$button.removeClass('accepted').addClass('rejected');
			updateReviewItemState(id, ReviewItemState.REJECTED);
		}
	};

	var initializeCreateFormFieldDependencies = function () {
        var notificationFunction = function () {
            var enabledOnUpdate = $("#notifyReviewers").prop("checked") || $("#notifyModerators").prop("checked");
            $("#notifyOnItemUpdate").prop("disabled", !enabledOnUpdate);

            if(!enabledOnUpdate){
                $("#notifyOnItemUpdate").prop("checked", false);
            }
        };
        $("#notifyReviewers").on("click", notificationFunction);
        $("#notifyModerators").on("click", notificationFunction);
        notificationFunction();

        var toggleMinimumCountsField = function () {
            var $checkbox = $("#requiresSignatureFromReviewers");
            var $minimumSignaturesField = $("#minimumSignaturesRequired");

            $minimumSignaturesField.prop('disabled', !$("#requiresSignatureFromReviewers").prop('checked'));
        };
        $("#requiresSignatureFromReviewers").click(toggleMinimumCountsField);
        toggleMinimumCountsField();
	};

	return {
		"init": init,
		"nodeClickHandler": nodeClickHandler,
		"populateTree": populateTree,
		"loadReviewItemReferences": loadReviewItemReferences,
		"initInfiniteScrolling": initInfiniteScrolling,
		"getUrlParameters": getUrlParameters,
		"loadFirstPage": loadFirstPage,
		'toggleRejected': toggleRejected,
		"batchUpdateReviewItemState": batchUpdateReviewItemState,
		"resetAllReviewButtons": resetAllReviewButtons,
		"updateCommentCounts": updateCommentCounts,
		"initializeCreateFormFieldDependencies": initializeCreateFormFieldDependencies
	};

})(jQuery);

function getFilterParameters () {
	codebeamer.review.getUrlParameters();
}

var addCommentInOverlay = function (id) {
	var $target = $(".comment-bubble[data-review-item-id=" + id + "]");

	if ($target.data('canview')) {
		$target.addClass('adding-comment');
		var reviewItemId = $target.data("reviewItemId");
		var url = contextPath + '/proj/tracker/docview/showCommentDialog.spr?task_id=' + reviewItemId;
		showPopupInline(url, {'geometry': 'large'});
	}
}