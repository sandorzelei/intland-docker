/**
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

/**
 * initializer function fot branch links on the tracker branches dialog
 */

$(function() {

    function addSkipBranchWarningParameter(url) {
        return UrlUtils.addOrReplaceParameter(url, "skipBranchSwitchWarning", "true");
    }

    $('a[data-branchId]').click(function(e) {

        e.preventDefault();
        e.stopPropagation();

        var $this = $(this);
        var revision = $this.attr('data-revision');

        if ($this.attr("data-originalItemId")) {
            var originalItemId = $this.attr("data-originalItemId");
            var branchId = $this.attr("data-branchId");
            var trackerId = $this.attr("data-trackerId");
            var itemIdOnBranch = $this.attr("data-itemIdOnBranch");
            if (itemIdOnBranch) {
                parent.window.location.href = addSkipBranchWarningParameter(contextPath + "/issue/" + itemIdOnBranch
                    + (revision ? '&revision=' + revision : ''));
                return false;
            } else {
                parent.window.location.href = addSkipBranchWarningParameter(contextPath + "/tracker/" + trackerId + "?branchId="
                    + branchId + (revision ? '&revision=' + revision : ''));
                return false;
            }
        }

        var url = parent.window.location.href;
        if ($this.data('originalTrackerUrl')) {
            url = contextPath + $this.data('originalTrackerUrl');
        }
        url = UrlUtils.addOrReplaceParameter(url, "branchId", $this.attr("data-branchId"));

        parent.window.location.href = addSkipBranchWarningParameter(url + (revision ? '&revision=' + revision : ''));
        return false;
    });
});