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
 * $Revision: 23888:e24caddde660 $ $Date: 2009-11-25 15:39 +0100 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript">

	function updateFlagValue(){
		var selectedOptions = "";
		$(".flagOptions input:checkbox").each(function(index){
			if (this.checked){
				if (selectedOptions !== ""){
					selectedOptions += ",";
				}
				selectedOptions += this.id.replace("flag_","");
			}
		});

		$("input[name='filter.value']").val(selectedOptions);
	}
</script>

<style>

	.flagOptions{
	    width: 400px;
	    margin-left: 20px;
	    margin-top: -5px;
	}

	.flagOptionsTable{
		width: 100%;
	}

	.filterTable .chooseReferences {
	    width: 160px;
	}

</style>

<table class="filterTable">
	<tr style="vertical-align: middle;">
	  <c:if test="${param.showField != 'false' }">
		<td style="vertical-align: middle; white-space: nowrap; font-weight: bold;">
			<input type="hidden" name="filter.field" value="${field.id}"/>
			<spring:message var="label" code="tracker.field.${field.label}.label" text="${field.label}" htmlEscape="true"/>
			<c:if test="${field.id eq 85}">
				<spring:message var="label" code="tracker.view.field.options"/>
			</c:if>
			<c:out escapeXml="false" value="${label}" />
		</td>
	  </c:if>

		<td style="vertical-align: middle;">
			<label>
				<input type="checkbox" name="filter.not" value="true" <c:if test="${filterNot}">checked="checked"</c:if>/>
				<spring:message code="tracker.view.not.label" text="not"/>
			</label>
			<c:choose>
				<c:when test="${empty operators}">
					<input type="hidden" name="filter.op" value="${filterOp}"/>
				</c:when>
				<c:otherwise>
					<select name="filter.op">
						<c:forEach items="${operators}" var="operator">
							<option value="${operator.value}" <c:if test="${operator.value eq filterOp}">selected="selected"</c:if>>
								<spring:message code="tracker.view.op.${operator.label}" text="${operator.label}"/>
							</option>
						</c:forEach>
					</select>
				</c:otherwise>
			</c:choose>
		</td>

		<td>
			<c:choose>
			  	<%-- member choice fields --%>
				<c:when test="${field.userReferenceField}">
					<spring:message var="title" code="tracker.field.value.choose.tooltip" text="Choose {0}" arguments="${label}"/>
				  	<bugs:userSelector htmlId="${htmlId}" tracker_id="${tracker.id}" field_id="${field.id}" fieldName="filter.value" ids="${filterVal}"
										singleSelect="false" allowRoleSelection="true" showCurrentUser="true" defaultValue="${unsetValue}"
										onlyUsersAndRolesWithPermissionsOnTracker="true" showUnset="true"
										specialValueResolver="com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorSpecialValues"
										title="${title}" removeDoNotModifyBox="true"
									/>
			  	</c:when>

				<%-- flags --%>
			  	<c:when test="${field.id eq 85}">
			  		<div class="flagOptions">
			  			<input type="hidden" name="filter.value" value="${filterVal}"/>
			  			<table class="flagOptionsTable">
			  				<tbody>
			  					<tr>
									<td><b><spring:message code="tracker.choice.flags.label"/>:</b></td>
									<td><b><spring:message code="tracker.field.State.label"/>:</b></td>
									<td><b><spring:message code="cmdb.category.label"/>:</b></td>
								</tr>
			  				<c:set var="count" value="0" scope="page" />
				  			<c:forEach items="${options}" var="option">

				  				<c:if test="${count == 0}">
				  					<tr>
				  				</c:if>

								<td>
				  					<input id="flag_${option.key}" name="flag_${option.key}" onchange="updateFlagValue();" type="checkbox"<c:if test="${flagValues.contains(option.key)}"> checked="checked"</c:if> value="true" />
				  					<label class="flagCheckbox" for="flag_${option.key}">${option.value}</label>
								</td>

				  				<c:set var="count" value="${count + 1}" scope="page"/>
				  				<c:if test="${count == 3}">
				  					</tr>
				  					<tr>
				  					<c:set var="count" value="0" scope="page"/>
				  				</c:if>

							</c:forEach>
								</tr>
							</tbody>
						</table>
					</div>
				</c:when>

			  	<%-- multiple/dynamic choice fields --%>
				<c:when test="${field.choiceField or field.languageField or field.countryField or field.id eq 76}">
					<spring:message var="title" code="tracker.field.value.choose.tooltip" text="Choose {0}" arguments="${label}"/>
					<bugs:chooseReferences htmlId="${htmlId}" tracker_id="${tracker.id}" label="${field}" fieldName="filter.value" ids="${filterVal}"
											showUnset="true" unsetValue="${unsetValue}" defaultValue="${unsetValue}" forceMultiSelect="true"
											labelMap="${specialValues}" title="${title}" removeDoNotModifyBox="true"
										/>
				</c:when>

			  	<%-- static/single choice fields or Start/End date or user defined boolean/date fields --%>
				<c:when test="${!empty options}">
					<select name="filter.value">
						<c:forEach items="${options}" var="option">
							<option value="${option.key}" <c:if test="${option.key eq filterVal}">selected="selected"</c:if>>
								<c:out value="${option.value}"/>
							</option>
						</c:forEach>
					</select>
				</c:when>

			   	<c:otherwise>
					<c:set var="rows" value="${field.rows}" />
					<c:set var="cols" value="${field.cols}" />
					<c:if test="${empty cols || cols < 1}">
						<c:set var="cols=" value="10" />
					</c:if>

					<c:choose>
						<c:when test="${rows gt 1}">
							<textarea class="${textStyle}" name="filter.value" rows="${rows}" cols="${cols > 24 ? cols : 24}">
								<c:out value="${filterVal}"/>
							</textarea>
						</c:when>

						<c:otherwise>
							<input type="text" class="${textStyle}" name="filter.value" value="<c:out value='${filterVal}'/>" size="${cols > 20 ? cols : 20}" />
						</c:otherwise>
					</c:choose>
			 	</c:otherwise>
			</c:choose>
		<td>
	</tr>
</table>
