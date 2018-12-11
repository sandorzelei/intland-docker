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
<%--
	Tag renders user selector and calls popup to select new users
--%>

<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
<%@ tag import="java.util.Arrays"%>
<%@ tag import="java.util.Iterator"%>
<%@ tag import="java.util.List"%>
<%@ tag import="java.util.Map"%>
<%@ tag import="org.apache.log4j.Logger"%>
<%@ tag import="org.apache.commons.lang.StringUtils"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.LabelMapEncoder"%>
<%@ tag import="com.intland.codebeamer.manager.user.UserNameCustomizer"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@ tag import="com.intland.codebeamer.utils.URLCoder"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.RoleDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.base.ProjectAwareDto"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ tag import="com.intland.codebeamer.persistence.util.PersistenceUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ attribute name="ids" required="true" type="java.lang.String" rtexprvalue="true"
		 description="The comma separated list of ids in form of The comma separated ids of 'group-type-entityId'"  %>

<%@ attribute name="disabled" required="false" type="java.lang.Boolean" rtexprvalue="true"
		 description="If the editing of this reference list is disabled" %>
<%@ attribute name="setToDefaultLabel" required="false" rtexprvalue="true"
		 description="The label for button resetting to default value, button only shown if it is not empty" %>
<%@ attribute name="defaultValue" required="false" rtexprvalue="true"
		 description="The default value can be reset to" %>
<%@ attribute name="emptyValue" required="false" rtexprvalue="true"
		 description="Optional empty value will be used when every previous selection is deleted" %>

<%@ attribute name="labelMap" required="false" type="java.util.Map" rtexprvalue="true"
		 description="Map with String->String content, contains mapping about how the the special-id values of references will be displayed. For example __DO_NOT_CHANGE__ would translate to &lt;don't change&gt;"  %>
<%@ attribute name="specialValueResolver" required="false" type="java.lang.String" rtexprvalue="true"
		 description="class name of the class implements the ReferenHandlerSupport.SpecialValueResolver interface. That class must have a public default constructor." %>

<%@ attribute name="htmlId" required="false" type="java.lang.String" rtexprvalue="true"
		description="The html id used for the field. This should be unique on the whole page. If missing then it will be generated as a random number" %>
<%@ attribute name="fieldName" required="false" type="java.lang.String" rtexprvalue="true"
	description="the name of the HTML input field (hidden field), which contains and submits back selected users." %>

<%@ attribute name="showPopupButton" type="java.lang.Boolean" rtexprvalue="true"
	description="If the popup button is shown. If not provided the popup button will automatically disappear if the jsp:body is not empty" %>

<%@ attribute name="showCurrentUser" required="false" type="java.lang.Boolean" rtexprvalue="true" %>
<%@ attribute name="showUnset" required="false" type="java.lang.Boolean" rtexprvalue="true" %>

<%@ attribute name="projectList" required="false" type="java.util.List" rtexprvalue="true"
	description="List of ProjectDtos , only members of these are shown" %>
<%@ attribute name="onlyCurrentProject" required="false" type="java.lang.Boolean" rtexprvalue="true"
	description="Only members of the current project are shown" %>

<%@ attribute name="useAllProjects" required="false" type="java.lang.Boolean" rtexprvalue="true"
    description="If true then any project members are shown" %>

<%@ attribute name="requiredRoles" required="false" type="java.util.Collection" rtexprvalue="true" %>
<%@ attribute name="singleSelect" required="false" type="java.lang.Boolean" rtexprvalue="true"
	description="if the popup will allow selection of a single user only" %>

<%--	/* role selection related fields follow */ --%>
<%@ attribute name="memberType" type="java.lang.Integer" rtexprvalue="true"	description="Which type of members can be selected." %>
<%@ attribute name="allowUserSelection" type="java.lang.Boolean" rtexprvalue="true"
	description="if users can also be selected. Used for assigned-to users, which allows role selection" %>
<%@ attribute name="allowRoleSelection" type="java.lang.Boolean" rtexprvalue="true"
	description="if roles can also be selected. Used for assigned-to users, which allows role selection" %>
<%@ attribute name="allowMemberFields" type="java.lang.Boolean" rtexprvalue="true"
	description="Should member fields also be selectable ? Only in conjunction with a tracker_id" %>

<%@ attribute name="cssClass" type="java.lang.String" rtexprvalue="true"
	description="CSS class attribute put on outermost container" %>

<%@ attribute name="onlyUsersAndRolesWithPermissionsOnTracker" type="java.lang.Boolean" rtexprvalue="true"
	description="if only users/roles with with permission to view own/any items on the current tracker are shown" %>
<%@ attribute name="tracker_id" type="java.lang.Integer" rtexprvalue="true"
	description="The current tracker's id. Parameter required if 'onlyUsersAndRolesWithPermissionsOnTracker' is set." %>
<%@ attribute name="status_id" type="java.lang.Integer" rtexprvalue="true"
	description="The status to find status specific filters." %>
<%@ attribute name="field_id" type="java.lang.Integer" rtexprvalue="true"
	description="The id of the members field whose values to select." %>
<%@ attribute name="task_id" type="java.lang.Integer" rtexprvalue="true"
	description="The id of the task whose field values to select." %>
<%@ attribute name="transition_id" type="java.lang.Integer" rtexprvalue="true"
	description="The id of the current task transition to execute." %>
<%@ attribute name="title" type="java.lang.String" rtexprvalue="true"
	description="Optional tooltip/title for the selector" %>
<%@ attribute name="searchOnAllUsers" type="java.lang.Boolean"
	description="if true, then all users are filtered regardless of the selected project" %>
<%@ attribute name="includeDisabledUsers" type="java.lang.Boolean"
			  description="if true, then disabled (deactivated) users will be included to the result" %>
<%@ attribute name="currentProject" type="java.lang.Integer"
	description="the id of the current project. when adding project members the users in this project will not be returned" %>
<%@ attribute name="acceptEmail" type="java.lang.Boolean"
	description="if true, the field will accept email addresses to" %>

<%@ attribute name="existingJSON" type="java.lang.String" rtexprvalue="true" required="false"
	description="Existing JSON which should be displayed inside the selector. This will overwrite the field value data if field present." %>

<%@ attribute name="removeDoNotModifyBox" type="java.lang.Boolean" rtexprvalue="true"
	description="Optional boolean if showing the 'dont modify' special value. Defaults to false" %>

<%@ attribute name="field"     required="false" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true" description="The current choice field"  %>
<%@ attribute name="decorator" required="false" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" description="The tracker item decorator"  %>
<%@ attribute name="onlyMembers" required="false" type="java.lang.Boolean" description="If true then only directly assigned members are shown" %>
<%@ attribute name="ignoreCurrentProject" required="false" type="java.lang.Boolean" description="If true then the user search is done without the current project (the project members are not excluded)" %>

<%@ attribute name="disableRoleFiltering" required="false" type="java.lang.Boolean" %>

<c:if test="${empty ids}">
	<c:set var="ids" value="" />
</c:if>
<c:if test="${empty disabled}">
	<c:set var="disabled" value="false"/>
</c:if>

<c:if test="<%=title == null%>">
	<c:set var="title" value="Choose Users..." />
</c:if>

<%
	// setting defaults
	if (showUnset == null) {
		showUnset = Boolean.FALSE;
	}
	if (showCurrentUser == null) {
		showCurrentUser = Boolean.FALSE;
	}
	if (singleSelect == null) {
		singleSelect = Boolean.FALSE;
		jspContext.setAttribute("singleSelect", singleSelect);
	}
	if (specialValueResolver == null) {
		specialValueResolver = "com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorSpecialValues";
	}
	if (onlyUsersAndRolesWithPermissionsOnTracker == null) {
	 	onlyUsersAndRolesWithPermissionsOnTracker = Boolean.FALSE;
	}
	if (onlyUsersAndRolesWithPermissionsOnTracker.booleanValue() && tracker_id == null) {
		throw new IllegalArgumentException("Tracker_id parameter required if 'onlyUsersAndRolesWithPermissionsOnTracker' is set.");
	}
	if (Boolean.TRUE.equals(allowMemberFields) && tracker_id == null) {
		allowMemberFields = Boolean.FALSE;
	}
	if (acceptEmail == null) {
		acceptEmail = Boolean.FALSE;
		jspContext.setAttribute("acceptEmail", acceptEmail);
	}

	Logger log = Logger.getLogger(this.getClass());

	if (field != null && field.getId() != null) {
		field_id = field.getId();
		jspContext.setAttribute("field_id", field_id);
	}

	Integer valueId = field_id;
	if (StringUtils.isEmpty(htmlId)) {
		// generate an unique html id for the field.
		htmlId = String.valueOf(Math.random()).replaceAll("\\.","");
		jspContext.setAttribute("htmlId", htmlId);
	} else {
		try {
			valueId = Integer.valueOf(htmlId, 10);
		} catch(Throwable ex) {
		}
	}
	jspContext.setAttribute("valueId", valueId);

	if (log.isDebugEnabled()) {
		log.debug("Show Unset: " + showUnset);
		log.debug("Show Current User: " + showCurrentUser);
		log.debug("Project List: " + projectList +", onlyCurrentProject=" + onlyCurrentProject);
		log.debug("fieldName: " + fieldName);
	}

	// onlyCurrentProject will overwrite the project-list
	if (onlyCurrentProject != null && onlyCurrentProject.booleanValue()) {
		ProjectDto project = ControllerUtils.getCurrentProject(request);
		if (project == null) {
			throw new IllegalStateException("Current project can not be found (onlyCurrentProject='true')");
		}
		projectList = PersistenceUtils.createSingleItemList(project);
	}

	// build the static url parameters, because used for both the popup and both the ajax request
	StringBuilder urlparams = new StringBuilder(512);
	urlparams.append("show_unset=").append(showUnset);
	urlparams.append("&show_current_user=").append(showCurrentUser);
	urlparams.append("&opener_htmlId=").append(htmlId);
	urlparams.append("&opener_fieldName=").append(URLCoder.encode(fieldName));
	urlparams.append("&singleSelect=").append(singleSelect);

	if (memberType != null) {
		urlparams.append("&memberType=").append(memberType);
	} else {
		if (allowUserSelection != null && !allowUserSelection.booleanValue()) {
			urlparams.append("&allowUserSelection=false");
		}

		if (allowRoleSelection != null && allowRoleSelection.booleanValue()) {
			urlparams.append("&allowRoleSelection=").append(allowRoleSelection);
		}
		if (allowMemberFields != null && allowMemberFields.booleanValue()) {
			urlparams.append("&allowMemberFields=").append(allowMemberFields);
		}

		if (onlyMembers != null) {
			urlparams.append("&onlyMembers=").append(onlyMembers);
		}

		if (ignoreCurrentProject != null) {
			urlparams.append("&ignoreCurrentProject=").append(ignoreCurrentProject);
		}
	}

	if (disableRoleFiltering != null && disableRoleFiltering.booleanValue()) {
		urlparams.append("&disableRoleFiltering=").append(disableRoleFiltering);
	}

	// The customized property is set to true if the account name is customized. See Config' login.accountLink xml attribute
	if (UserNameCustomizer.isCustomized()) {
		urlparams.append("&customized=true");
	}

	if (projectList != null && !projectList.isEmpty()) {
		urlparams.append("&project_list=").append(URLCoder.encode(StringUtils.join(PersistenceUtils.grabIds(projectList), ',')));
	}

	if (requiredRoles != null && !requiredRoles.isEmpty()) {
		urlparams.append("&required_roles=").append(URLCoder.encode(StringUtils.join(PersistenceUtils.grabIds(requiredRoles), ',')));
	}

	if (labelMap != null) {
		String encodedLabelMap = new LabelMapEncoder().encodeLabelMap(labelMap);
		urlparams.append("&labelMap=").append(encodedLabelMap);
	}

	if (setToDefaultLabel != null) {
		urlparams.append("&setToDefaultLabel=").append(setToDefaultLabel);
	} else {
		defaultValue = null;
	}

	if (defaultValue != null) {
		urlparams.append("&defaultValue=").append(defaultValue);
	}

	if (specialValueResolver != null) {
		urlparams.append("&specialValueResolver=").append(specialValueResolver);
	}

	if (currentProject != null) {
		urlparams.append("&proj_id=").append(currentProject);
	}

	if (useAllProjects != null && useAllProjects.booleanValue()) {
		urlparams.append("&useAllProjects=true");
	}

	urlparams.append("&onlyUsersAndRolesWithPermissionsOnTracker=").append(onlyUsersAndRolesWithPermissionsOnTracker);
	if (onlyUsersAndRolesWithPermissionsOnTracker != null && onlyUsersAndRolesWithPermissionsOnTracker.booleanValue()) {
		urlparams.append("&tracker_id=").append(tracker_id);
		if (status_id != null && status_id.intValue() > 0) {
			urlparams.append("&status_id=").append(status_id);
		}
		if (field_id != null) {
			urlparams.append("&labelId=").append(field_id);
		}
		if (task_id != null && task_id.intValue() > 0) {
			urlparams.append("&task_id=").append(task_id);
			if (transition_id != null && transition_id.intValue() > 0) {
				urlparams.append("&transition_id=").append(transition_id);
			}
		}
	}

	if (searchOnAllUsers != null) {
		urlparams.append("&searchOnAllUsers=").append(searchOnAllUsers);
	} else {
		urlparams.append("&searchOnAllUsers=false");
	}
	if (includeDisabledUsers != null) {
		urlparams.append("&includeDisabledUsers=").append(includeDisabledUsers);
	}
	urlparams.append("&acceptEmail=").append(acceptEmail);

	jspContext.setAttribute("urlparams", urlparams.toString());

	jspContext.setAttribute("getContext", "null");
%>

<bugs:fieldDependency id="${valueId}" tracker="${tracker_id}" status="${status_id}" field="${field}" disabled="${disabled}" decorator="${decorator}" context="<%=jspContext%>"/>

<%-- wrapping span with CSS class added to make it 'skinnable' by css --%>
<span class="userSelector">
	<c:set var="htmlFragment" value="" />
	<c:if test="${! disabled}">
		<c:set var="onclick">
			chooseReferences.showUserSelectorPopup('${htmlId}', '${urlparams}', ${getContext}); return false;
		</c:set>
	</c:if>

	<%-- for the body you could use the old icon: <img src="<c:url value='/images/Members.gif'/>" title="..." border="0" width="16" height="16" /> --%>
	<bugs:chooseReferencesUI tracker_id="${tracker_id}" field_id="${field_id}" ids="${ids}" disabled="${disabled}" labelMap="${labelMap}" specialValueResolver="${specialValueResolver}"
		emptyValue="${emptyValue}" htmlId="${htmlId}" fieldName="${fieldName}" onclick="${onclick}" showPopupButton="<%=showPopupButton%>"
		cssClass="${cssClass}" title="${title}" ajaxEnabled="true" ajaxURLParameters="${urlparams}" userSelectorMode="true" acceptEmail="${acceptEmail}" multiSelect="${! singleSelect}"
		removeDoNotModifyBox="${removeDoNotModifyBox}" reqContext="${getContext}" onChange="${onChange}" onChangeHandler="${onChangeHandler}" existingJSON="${existingJSON}"
		>
		<jsp:doBody/>
	</bugs:chooseReferencesUI>
</span>