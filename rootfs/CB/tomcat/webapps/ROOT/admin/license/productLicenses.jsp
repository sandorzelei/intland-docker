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
 * $Revision$ $Date$
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>


<c:url var="productOptionsUrl" value="/sysadmin/productOptions.spr">
	<c:param name="version" value="${release}"/>
	<c:param name="product" value=""/>
</c:url>

<script type="text/javascript">

function changeProduct(product, part) {
	$('#options-' + part).load('${productOptionsUrl}' + escape(product.value) + '&part=' + part);
}

<c:if test="${empty selectedProduct}">
	$(document).ready(function() {
		changeProduct(document.getElementById('product-1'), '1');
	});
</c:if>

</script>


<table class="noBorderTable">
	<c:if test="${!empty products}">
		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="sysadmin.license.product" text="Product"/>:
			</td>

			<c:forEach begin="0" end="${lastPart}" var="part">
				<td>
					<select id="product-${part}" name="product[${part}]" onChange="changeProduct(this, '${part}');">
						<c:if test="${part gt 0}">
							<option value="" <c:if test="${selectedProduct[part] == null}">selected="selected"</c:if>>
								--
							</option>
						</c:if>
						<c:forEach items="${products}" var="product">
							<spring:message var="tooltip" code="sysadmin.license.product.${product}.tooltip" text="" htmlEscape="true"/>

							<option value="${product}" title="${tooltip}" <c:if test="${selectedProduct[part] eq product}">selected="selected"</c:if>>
								<c:if test="${not empty tooltip}">
									${tooltip}
								</c:if>
								<c:if test="${empty tooltip}">
									<spring:message code="sysadmin.license.product.${product}" text="${product}" />
								</c:if>
							</option>
						</c:forEach>
					</select>
				</td>
			</c:forEach>
		</tr>

		<tr valign="top">
			<td nowrap class="labelColumn optional">
				<spring:message code="sysadmin.license.options" text="Options"/>:
			</td>

			<c:forEach begin="0" end="${lastPart}" var="part">
				<td id="options-${part}">
					${productOptions[part]}
				</td>
			</c:forEach>
		</tr>
	</c:if>

	<tr>
		<td nowrap class="labelColumn  optional">
			<spring:message code="user.licenseType.1" text="Users with named license"/>:
		</td>

		<c:forEach begin="0" end="${lastPart}" var="part">
			<td>
				<input type="number" name="users[${part}][0]" value="${users[part][0]}" min="0" max="999999" width="6" maxlength="6"/>
			</td>
		</c:forEach>
	</tr>

	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="user.licenseType.2" text="User with floating license"/>:
		</td>
		<c:forEach begin="0" end="${lastPart}" var="part">
			<td>
				<input type="number" name="users[${part}][1]" value="${users[part][1]}" min="0" max="999999" width="6" maxlength="6"/>
			</td>
		</c:forEach>
	</tr>

	<c:if test="${customers}">
		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="user.licenseType.3" text="Customer with named license"/>:
			</td>
			<c:forEach begin="0" end="${lastPart}" var="part">
				<td>
					<input type="number" name="users[${part}][2]" value="${users[part][2]}" min="0" max="999999" width="6" maxlength="6"/>
				</td>
			</c:forEach>
		</tr>

		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="user.licenseType.4" text="Customer with floating license"/>:
			</td>
			<c:forEach begin="0" end="${lastPart}" var="part">
				<td>
					<input type="number" name="users[${part}][3]" value="${users[part][3]}" min="0" max="999999" width="6" maxlength="6"/>
				</td>
			</c:forEach>
		</tr>
	</c:if>

</table>