<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/ui/userPhoto.tag' --%>
<%@ taglib uri="uitaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.ui.UserPhotoWrapper" %>

<% UserPhotoWrapper a = ((UserPhotoWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:userPhoto
	userId="<%=a.userId%>"
	userName="<%=a.userName%>"
	large="<%=a.large%>"
	url="<%=a.url%>"
	placeholderGeneration="<%=a.placeholderGeneration%>"
>${tagFileWrapper.jspBody}</gen:userPhoto>
