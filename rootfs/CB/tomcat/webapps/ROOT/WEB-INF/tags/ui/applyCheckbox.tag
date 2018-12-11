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
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ attribute name="initialState" required="false" type="java.lang.Boolean" rtexprvalue="true" description="Initial state of the control"  %>
<%@ attribute name="biDirectional" required="false" type="java.lang.Boolean" rtexprvalue="true"
			  description="True if the apply button is bidirectional"  %>
<%@ attribute name="name" required="true" type="java.lang.String" rtexprvalue="true" description="Name of the HTML input elem"  %>
<%@ attribute name="fieldId" required="false" type="java.lang.String" rtexprvalue="true" description="id of the field being compared"  %>
<%@ attribute name="extraCssClass" required="false" type="java.lang.String" rtexprvalue="true" description="an extra css clas to add to the checkbox"  %>

<%@ attribute name="leftEditable" required="false" type="java.lang.Boolean" rtexprvalue="true"
              description="For bidirectional references: true if the field in the left item is editable" %>
<%@ attribute name="rightEditable" required="false" type="java.lang.Boolean" rtexprvalue="true"
              description="For bidirectional references: true if the field in the right item is editable" %>

<c:set var="checked">${initialState ? "checked" : ""}</c:set>

<a class="applyCheckbox left ${biDirectional ? 'biDirectional' :''}
    ${biDirectional && !leftEditable ? 'left-readonly' : ''}
    ${biDirectional && !rightEditable ? 'right-readonly' : ''}
    ${checked} ${name == 'all' ? 'all' : ''} ${extraCssClass}">
	<c:if test="${biDirectional}">
		<%-- add the clickable areas for left and right merge --%>
        <span class="applyToRight applyIcon ${!rightEditable ? 'disabled' : ''}" data-direction="right"></span>
		<span class="applyToLeft applyIcon ${!leftEditable ? 'disabled' : ''}" data-direction="left"></span>
		<label><spring:message code="button.apply" text="Apply"/></label>
	</c:if>
	<input type="checkbox" name="${name}" style="display: none" ${checked} data-field-id="${empty fieldId ? '' : fieldId }">
</a>

<c:choose>

	<c:when test="${biDirectional}">
		<script type="text/javascript">
			(function($) {
			    $(document).on('click', '.applyIcon', function () {
			        var $icon = $(this);
			        var direction = $icon.data('direction');
			        var $container = $icon.closest('.applyCheckbox');
			        $container
						.removeClass('left right')
						.addClass(direction)
						.addClass('checked');
                	$container.find("input[type=checkbox]").attr('checked', true);
				}).on('click', '.applyCheckbox.checked', function () {
				    $(this).removeClass('checked left right')
                        .find("input[type=checkbox]").attr('checked', false);
				});
			})(jQuery);
		</script>
	</c:when>

	<c:otherwise>
		<script type="text/javascript">

            jQuery(function($) {
                var boxes = $(".applyCheckbox").filter(function() {
                    return $(this).prop("initialized") !== true;
                });

                boxes.each(function() {
                    var box = $(this);
                    box.prop("initialized", true);
                    box.click(function(e) {
                        var newState = !box.hasClass("checked");
                        box.toggleClass("checked")
                            .find("input[type=checkbox]").attr('checked', newState);
                        e.preventDefault();
                    });

                    box.on("check", function() {
                        if (!box.is(".checked")) {
                            box.click();
                        }
                    });

                    box.on("uncheck", function() {
                        if (box.is(".checked")) {
                            box.click();
                        }
                    });
                });
            });

		</script>
	</c:otherwise>
</c:choose>

