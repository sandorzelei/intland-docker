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
 * $Revision: 21489:1c3770393951 $ $Date: 2009-05-29 13:46 +0000 $
--%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ tag import="java.util.List"%>
<%@ tag import="java.util.ArrayList"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>
<%@ tag import="com.intland.codebeamer.persistence.util.NodeHierarchy.Node"%>
<%@ tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="id"        required="true" type="java.lang.Integer" rtexprvalue="true" description="The current choice field (cell) ID"  %>
<%@ attribute name="tracker"   required="true" type="java.lang.Integer" rtexprvalue="true" description="The current tracker Id"  %>
<%@ attribute name="status"    required="true" type="java.lang.Integer" rtexprvalue="true" description="The current tracker item status ID"  %>
<%@ attribute name="field"     required="true" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true" description="The current choice field"  %>
<%@ attribute name="disabled"  required="false" type="java.lang.Boolean" rtexprvalue="true" description="Whether the field is disabled (not editable)"  %>
<%@ attribute name="decorator" required="true" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" description="The tracker item decorator"  %>
<%@ attribute name="context"   required="true" type="javax.servlet.jsp.JspContext" rtexprvalue="true" description="The parent context where to set/remove attributes"  %>

<%
	Integer fieldId = (field != null ? field.getId() : null);

	context.removeAttribute("onFocus");
	context.removeAttribute("onChange");

	Node node = (decorator != null ? decorator.getDependencyNode(fieldId) : null);
	if (node != null && field != null && !Boolean.TRUE.equals(disabled)) {
		boolean dynChoice = (field.isMemberChoice()  ||
							 field.isDynamicChoice() ||
							 field.isLanguageField() ||
							 field.isCountryField()  ||
							 (field.isReferenceFieldConfigurationAllowed() && Boolean.TRUE.equals(field.getMultipleSelection())));

		int tableIndex  = TrackerLayoutLabelDto.getTableIndex(id.intValue());
		if (tableIndex == -1) {

			// If this field depends on other fields
			if (node.getLevel() > 1) {
				String optionsUrl = dynChoice ? "/trackers/ajax/checkFieldValues.spr" : "/trackers/ajax/getChoiceOptions.spr";
%>
				<c:url var="optionsUrl" value="<%=optionsUrl%>">
					<c:param name="tracker_id" 		value="${tracker}"/>
					<c:param name="status_id"   	value="${status}"/>
					<c:param name="field_id"   		value="<%=fieldId.toString()%>"/>
					<c:param name="values"   		value=""/>
				</c:url>

				<script type='text/javascript'>
					function getContext<%=fieldId%>() {
						var context = [];
<%						for (Node fld : node.getParent().getPath()) {
						    int tblIdx = TrackerLayoutLabelDto.getTableIndex(fld.getId().intValue());
							if (tblIdx == -1) {
%>								context.push('<%=fld.getId()%>=' + $('#dynamicChoice_references_<%=fld.getId()%>').val());
<%							}
 						}
%>						return context.join(';');
					}

					function loadOptions<%=fieldId%>(field) {
						var values  = field.value;
						var context = getContext<%=fieldId%>();
						var options = '${optionsUrl}' + encodeURIComponent(values) + '&context=' + encodeURIComponent(context);
<%                      if (dynChoice) {
%>							$.getJSON(options, function(data) {
								// data is an array of values that should be removed !!
								try {
									ajaxReferenceFieldAutoComplete.removeValueBoxes(<%=fieldId%>, data);
								} catch(e) {
									alert(e);
								}
							});
<%                      } else {
%>							$(field).load(options);
<% 						}
%>					}
				</script>
<%
				if (dynChoice) {
				 	// When requesting possible field values, also send the current values of all other fields this fields depends on
					context.setAttribute("getContext", "getContext" + fieldId + "()");
				} else {
					List<String> initializers = (List) request.getAttribute("staticChoiceFieldInitializers");
					if (initializers == null) {
						request.setAttribute("staticChoiceFieldInitializers", initializers = new ArrayList<String>());
					}
					initializers.add("loadOptions" + fieldId + "(document.getElementById('dynamicChoice_references_" + id + "'));");
				}
			}

			// If other fields depend on this field
			if (node.hasChildren()) {
%>				<script type='text/javascript'>
					function checkDependendOptions<%=fieldId%>() {
						var elem;
<% 						for (Node fld : node.getDescendants(false)) {
		                    int tblIdx = TrackerLayoutLabelDto.getTableIndex(fld.getId().intValue());
							if (tblIdx == -1) {
%>								elem = document.getElementById('dynamicChoice_references_<%=fld.getId()%>');
								if (elem != null) {
									try {
										loadOptions<%=fld.getId()%>(elem);
									} catch (e) {
									}
								}
<% 							}
						}
%>					}
				</script>
<%
				context.setAttribute("onChange", "checkDependendOptions" + fieldId + "()");
			}
		}
	}
%>