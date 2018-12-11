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
 *
 * $Revision$ $Date$
 */
var codebeamer = codebeamer || {};

codebeamer.AjaxRefreshingWikiPlugin = codebeamer.AjaxRefreshingWikiPlugin || (function($) {

	function getParamFromUrl(url, param) {
        var tempArray = url.split('?');
        if (tempArray[1]) { // check for url without query string -> /cb/query/73203
            var paramsURL = tempArray[1];
            tempArray = paramsURL.split('&');
            for (i=0; i<tempArray.length; i++) {
                var index = tempArray[i].indexOf('=');
                if (index != -1) {
                    var paramName = tempArray[i].substring(0, index);

                    if(paramName == param) {
                        var paramValue = tempArray[i].substring(index + 1);
                        return paramName + '=' + paramValue;
                    }
                }
            }
        }
        return "";
    }

	function attachClickHandler($plugin, anchorSelector, baseUrl) {
		$plugin.on('click', anchorSelector, function(e) {
            e.preventDefault();
            var nextLocation = $(e.target).attr('href');
            var pageParam = getParamFromUrl(nextLocation, 'page');
            var pageSizeParam = getParamFromUrl(nextLocation, 'pagesize');
            var sortParam = getParamFromUrl(nextLocation, 'sort');
            var sortDirParam = getParamFromUrl(nextLocation, 'dir');

            var extraParamArr = ['ajax=true'];
            if (pageParam) extraParamArr.push(pageParam);
            if (pageSizeParam) extraParamArr.push(pageSizeParam);
            if (sortParam) extraParamArr.push(sortParam);
            if (sortDirParam) extraParamArr.push(sortDirParam);

            var extraParam = extraParamArr.join('&');

            var url = baseUrl + '&' + extraParam;
            $.ajax({
                url: url,
                method: 'GET',
                dataType: 'xml',
                success: function(data) {
                    var response = $(data).find('html').text();
                    $plugin.replaceWith(response);
                }
            });
        });
	}

	return {
		attachClickHandler: attachClickHandler
	}
})(jQuery);