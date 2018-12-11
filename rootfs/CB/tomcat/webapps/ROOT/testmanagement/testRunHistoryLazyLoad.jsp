<%@ page import="com.intland.codebeamer.controller.testmanagement.TestRunHistoryController" %><%--
  ~ Copyright by Intland Software
  ~
  ~ All rights reserved.
  ~
  ~ This software is the confidential and proprietary information
  ~ of Intland Software. ("Confidential Information"). You
  ~ shall not disclose such Confidential Information and shall use
  ~ it only in accordance with the terms of the license agreement
  ~ you entered into with Intland.
  --%>

<script type="text/javascript">

/**
* Lazy/ajax load of reported bugs of a TestCase
* @param params additional parameters
* @param forceLoad If the content is loaded even when item is not visible
* @return a jquery-Promise called when the data is loaded
*/
function testRunsLazyLoad(params, forceLoad) {
    var element = $("#testRunsLazyLoad");
    // show loading animation
    $(element).html("<img src='"+ contextPath +"/images/ajax_loading_horizontal_bar.gif'/>");
    // load when visible
    var url = contextPath + "<%= TestRunHistoryController.URL%>?";
    if (params != null) {
        url += params;
    }

    return loadWhenVisibleOrOnTabChange(element, url, forceLoad);
}

$(function() {
    testRunsLazyLoad("task_id=" + ${task.id} + "&revision=${param.revision}"); // TODO: pass revision ???
});
</script>

<div id="testRunsLazyLoad">
</div>
