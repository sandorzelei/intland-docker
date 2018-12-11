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
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:delayedScript avoidDuplicatesOnly="true">
    <script type="text/javascript" src="<ui:urlversioned value='/wro/froala.js'/>"></script>
    <link rel="stylesheet" href="<ui:urlversioned value='/wro/froala-styles.css'/>" type="text/css" media="all" />

    <script type="text/javascript">
    codebeamer.EditorLanguages.init();
    </script>
</ui:delayedScript>