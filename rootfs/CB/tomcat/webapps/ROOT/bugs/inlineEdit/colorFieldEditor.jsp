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

<input type="text" name="color" id="${not empty uniqueId ? uniqueId : 'inlineEditColorFieldEditor'}" value="${existing}" readonly="readonly" style="width: 6em;"/>
<ui:colorPicker fieldId="${not empty uniqueId ? uniqueId : 'inlineEditColorFieldEditor'}" dialogCssClass="${dialogCssClass}"></ui:colorPicker>
