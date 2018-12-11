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

<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${diff}" actionListName="actions" deniedKeys="Show diff,Properties,Browse,Open Directory,Display Wiki Note">
	<ui:actionMenu actions="${actions}" forceOpenInNewWindow="true" />
</ui:actionGenerator>
