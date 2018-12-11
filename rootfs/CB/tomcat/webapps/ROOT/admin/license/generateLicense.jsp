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
<meta name="decorator" content="main"/>
<meta name="module" content="license"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:url var="generateLicenseUrl" value="/sysadmin/generateLicense.spr"/>

<c:url var="licenseFeaturesUrl" value="/ajax/licenseFeatures.spr">
	<c:param name="version" value=""/>
</c:url>

<c:url var="productOptionsUrl" value="/sysadmin/productOptions.spr">
	<c:param name="version" value=""/>
</c:url>

<c:url var="productLicensesUrl" value="/sysadmin/productLicenses.spr">
	<c:param name="version" value=""/>
</c:url>

<c:url var="licenseTypeMatrixUrl" value="/sysadmin/licenseTypeMatrix.spr">
	<c:param name="version" value=""/>
</c:url>

<style>
	.formTableWithSpacing {
		border-collapse: collapse !important;
	}

	.formTableWithSpacing td {
		border: 1px solid #ababab;
	}

	.noBorderTable td {
		border: 0 !important;
	}
</style>

<script type="text/javascript">
var selectedFeatures = {<c:forEach items="${selectedFeatures}" var="selectedFeature" varStatus="loop">"${selectedFeature.key}" : ${selectedFeature.value}<c:if test="${!loop.last}">, </c:if></c:forEach>};
var selectedLimits   = {<c:forEach items="${selectedLimits}"   var="selectedLimit"   varStatus="loop">"${selectedLimit.key}" : ${selectedLimit.value}<c:if test="${!loop.last}">, </c:if></c:forEach>};

function changeFeatures(features) {
	var featureDiv = $('#licenseFeatureTable');
	featureDiv.empty();

	if ($.isArray(features) && features.length > 0) {
		for (var i = 0; i < features.length; ++i) {
			var feature = $('<label>', { title : features[i].tooltip, style : 'vertical-align: middle;' });
			feature.append($('<input>', { type : 'checkbox', name : 'feature', value : features[i].name, checked : selectedFeatures[features[i].name] }));
			feature.append(features[i].label);

			if (i > 0) {
				featureDiv.append(', ');
			}
			featureDiv.append(feature);
		}
		$('#licenseFeatures').show();
	} else {
		$('#licenseFeatures').hide();
	}
}

function changeLimits(limits) {
	var limitsDiv = $('#licenseLimitTable');
	limitsDiv.empty();

	if ($.isArray(limits) && limits.length > 0) {
		var table = $('<table>', { class : "noBorderTable" });
		limitsDiv.append(table);

		for (var i = 0; i < limits.length; ++i) {
			var row = $('<tr>', { title : limits[i].tooltip, valign : 'middle' });
			table.append(row);

			row.append($('<td>', { "class" : 'labelColumn optional', style : 'whitespace: Nowrap;' }).text(limits[i].label));
			row.append($('<td>').append($('<input>', { type : 'number', name : limits[i].name, value : selectedLimits[limits[i].name], size: 5, maxlength : 5 })));
		}

		$('#licenseLimits').show();
	} else {
		$('#licenseLimits').hide();
	}
}

function prepareFeatures(version) {
	$.get('${licenseFeaturesUrl}' + version).done(function(result) {
		changeFeatures(result.features);
		changeLimits(result.limits);

	}).fail(function(jqXHR, textStatus, errorThrown) {
		try {
    		var exception = eval('(' + jqXHR.responseText + ')');
    		alert(exception.message);
		} catch(err) {
			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		}
    });
}

function changeVersion(version) {
	if (parseInt(version.value.substring(0, 1)) >= 9){
		$('#company-name-line').css("display", "");
	} else {
		$('#company-name-line').css("display", "none");
		$("input[value='companyName']").val('');
	}
	prepareFeatures(version.value);

	$('#productLicenses').load('${productLicensesUrl}' + version.value, function() {
		$('#productLicenses select[id^="product-"]').change(function() {
			var part = $(this).attr('id').substring(8);
			var product = $(this).val();

			$('#options-' + part).load('${productOptionsUrl}' + version.value + '&product=' + escape(product) + '&part=' + part);
		});

		$('#product-0').change();
	});

	$('#licenseTypeMatrix').load('${licenseTypeMatrixUrl}' + version.value);
}

$(document).ready(function() { <c:choose>
  <c:when test="${empty productLicenses}">
	changeVersion(document.getElementById('versionSelector'));
  </c:when>
  <c:when test="${selectedFeatures != null or selectedLimits != null}">
  	prepareFeatures("${cbVersion}");
  </c:when>
</c:choose>

	codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());

});

</script>
<c:set value="style=\"width: 166px\"" var="style"/>
<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.license.create.label" text="Generate License"/></ui:pageTitle>
</ui:actionMenuBar>

<form action="${generateLicenseUrl}" method="post">

	<ui:actionBar>
		<spring:message var="saveButton" code="button.save" text="Save"/>

		&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
	</ui:actionBar>

	<div class="contentWithMargins">
		<table class="formTableWithSpacing">
			<tr>
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.hostid" text="Host-ID"/>:
				</td>
				<td>
					<input type="text" name="hostId" value="${hostId}" maxlength="90" ${style} } />
				</td>
			</tr>

			<tr id="company-name-line">
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.companyName" text="Company name"/>:
				</td>
				<td>
					<input type="text" name="companyName" value="${companyName}" maxlength="50" ${style} } />
				</td>
			</tr>

			<tr>
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.validUntil" text="Valid Until"/>:
				</td>
				<td>
					<input type="text" name="validUntil" value="${validUntil}" maxlength="20" ${style} }/>
				</td>
			</tr>

			<tr>
				<td nowrap class="labelColumn optional">
					<spring:message code="cmdb.version.label" text="Release"/>:
				</td>
				<td>
					<select id="versionSelector" name="cbVersion" onchange="changeVersion(this);">
						<c:forEach items="${versions}" var="version">
							<option value="${version.key}" <c:if test="${version.key eq cbVersion}">selected="selected"</c:if>>
									${version.value}
							</option>
						</c:forEach>
					</select>
				</td>
			</tr>

			<tr id="licenseFeatures" style="display: None;">
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.features" text="Features"/>:
				</td>
				<td id="licenseFeatureTable" valign="middle">
				</td>
			</tr>

			<tr id="licenseLimits" style="display: None;">
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.limits" text="Limits"/>:
				</td>
				<td id="licenseLimitTable" valign="middle">
				</td>
			</tr>

			<tr valign="top">
				<td nowrap class="labelColumn optional">
					<spring:message code="sysadmin.license.license" text="Licenses"/>:
				</td>
				<td id="productLicenses">
					${productLicenses}
				</td>
			</tr>

			<tr>
				<td nowrap class="labelColumn optional">
					<spring:message code="user.password.label" text="Password"/>:
				</td>
				<td>
					<input type="password" name="password" maxlength="20" autocomplete="off" ${style} />
				</td>
			</tr>
		</table>
	</div>

</form>

<div id="licenseTypeMatrix" style="margin-top:1em;">
	${licenseTypeMatrix}
</div>
