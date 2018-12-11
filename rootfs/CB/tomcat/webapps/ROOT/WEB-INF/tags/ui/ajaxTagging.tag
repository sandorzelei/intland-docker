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
<%@tag import="com.intland.codebeamer.ui.view.actionmenubuilder.AbstractActionMenuBuilder"%>
<%@tag import="java.util.List"%>
<%@tag import="com.intland.codebeamer.Config"%>
<%@tag import="com.intland.codebeamer.controller.support.SimpleMessageResolver"%>
<%@tag import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"%>
<%@tag import="com.intland.codebeamer.persistence.dto.EntityLabelDto"%>
<%@tag import="com.intland.codebeamer.utils.URLCoder"%>
<%@tag import="com.intland.codebeamer.persistence.dto.LabelDto"%>
<%@tag import="org.apache.log4j.Logger"%>

<%@ tag import="com.intland.codebeamer.persistence.dto.base.ReferenceDto"%>
<%@ tag import="com.intland.codebeamer.manager.EntityLabelManager"%>
<%@ tag import="com.intland.codebeamer.remoting.GroupTypeClassUtils"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%--
	Tag renders a ajax-tagging/favourite/star widget to mark an entity as favourite or put/remove a Tag on that
--%>
<%@ attribute name="entity" required="false" rtexprvalue="true"
	type="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"
	description="The id of the entity to Tag" %>

<%@ attribute name="entityTypeId" required="false" rtexprvalue="true"
	description="The grouptype of the entity to Tag" %>
<%@ attribute name="entityId" required="false" rtexprvalue="true"
	description="The id of the entity to Tag" %>

<%@ attribute name="on" required="false" rtexprvalue="true"
	type="java.lang.Boolean"
	description="If the element is starred. If missing then the starred status will be looked up automatically"
%>

<%@ attribute name="favourite" required="false" type="java.lang.Boolean"
	description="If showing/tagging the favourite tag" %>
<%@ attribute name="tagName" required="false"
	description="The tag name to show/set" %>

<%@ attribute name="cssClass" required="false"
	description="CSS class attribute" %>
<%@ attribute name="cssStyle" required="false"
	description="CSS style attribute" %>

<%@ attribute name="enabled" required="false"
	type="java.lang.Boolean"
	description="If the widget is enabled (will change the tag status on click)" %>
	
<%!
	static int idgen = 0;
	final static Logger logger = Logger.getLogger("com.intland.codebeamer.jsp.ajaxTagging.tag");

	static EntityLabelManager entityLabelManager = EntityLabelManager.getInstance();

	private boolean isTagged(HttpServletRequest request, UserDto user, ReferenceDto targetRef) {
		return AbstractActionMenuBuilder.isTagged(request, user, targetRef, tagName);
	}

%>
<%
	try {
		UserDto user = ControllerUtils.getCurrentUser(request);
		boolean anonymous = (user == null || Config.isAnonymousUser(user));
		if (anonymous) {
			return;
		}

		Integer groupType;
		Integer id;
		if (entity != null) {
			groupType = GroupTypeClassUtils.objectToGroupType(entity);
			id = entity.getId();
		} else {
			groupType = Integer.valueOf(entityTypeId);
			id = Integer.valueOf(entityId);
		}

		if (enabled == null) {
			enabled = Boolean.TRUE;
		}

		if (cssClass == null) {
			cssClass = "";
		}
		if (cssStyle == null) {
			cssStyle = "";
		}

		SimpleMessageResolver messageResolver = SimpleMessageResolver.getInstance(request);

		String onTitle = messageResolver.getMessage("tags.tagging.on.title");
		String offTitle = messageResolver.getMessage("tags.tagging.off.title");

		boolean hidden = false;
		if (Boolean.TRUE.equals(favourite)) {
			cssClass += " favouriteWidget";
			tagName = LabelDto.PRIVATE_LABEL_PREFIX + EntityLabelManager.STARRED_LABEL;
			hidden = true;

			onTitle = messageResolver.getMessage("tags.starring.on.title");
			offTitle = messageResolver.getMessage("tags.starring.off.title");
		} else {
			cssClass += " ajaxTaggingWidget";
		}

		if (on == null) {
			ReferenceDto targetRef = new ReferenceDto(groupType, id);
			boolean tagged = isTagged(request, user, targetRef);
			on = Boolean.valueOf(tagged);
		}

		jspContext.setAttribute("on", on);
		String widgetHTMLId = "ajaxTagging_" + (idgen++);

		String tagNameEscaped = URLCoder.encode(tagName);
%>

<span class="<%=cssClass%>"><img src="<c:url value='/images/space.gif'/>" width="16" height="16" id="<%=widgetHTMLId%>"
			class="<c:if test="<%=on%>">tagged</c:if>"
			style="${cssStyle}" ></img></span>

<script type="text/javascript">
	new TaggingWidget("<%=widgetHTMLId%>", "<%=groupType%>", "<%=id%>", <%=on%>, "<%=tagNameEscaped%>", "<%=onTitle%>", "<%=offTitle%>", <%=enabled%>);
</script>

<%
	} catch (NumberFormatException ex) {
		// invalid entity id param
		logger.warn("Failed to render Favourite/Starred tag", ex);
	}
%>
