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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<script type="text/javascript" src="<ui:urlversioned value='js/sjcl/sjcl.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='js/userFormTable.js'/>"></script>
<script src='https://www.google.com/recaptcha/api.js'></script>

<form:hidden path="encryptionRequest" cssClass="encryptionRequest" value="false"/>

<c:set var="timeZoneAndDateFormatTable">
<c:if test="${isAccountEditing && (isAccountAdministratorOwn || isModifyTimeZoneAndDateFormat || isAccountAdministrator)}">
	<h4>
		<spring:message code="user.dateTimeSettings.label" text="Timezone / Date Format"/>
	</h4>
	<table border="0" cellpadding="0" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="user.timeZonePattern.label" text="Time zone"/>:</td>
			<td class="data">
				<form:select path="user.timeZonePattern">
					<form:options items="${timeZoneOptions}" itemLabel="name" itemValue="value" />
				</form:select>
			</td>
		</tr>

		<tr>
			<td class="optional"><spring:message code="user.dateFormatPattern.label" text="Date Format"/>:</td>
			<td class="data">
				<form:select path="user.dateFormatPattern">
					<form:options items="${availableDateFormats}" itemLabel="name" itemValue="value" />
				</form:select>
			</td>
		</tr>
	</table>
</c:if>
</c:set>

<c:set var="userGroupMemberShipTable">
<c:if test="${isAccountEditing && isAccountAdministrator}">
	<h4>
		<spring:message code="user.groupMemberships.label" text="Member in Groups"/>
	</h4>
	<table border="0" cellpadding="0" class="formTableWithSpacing">
		<tr>
			<td class="optional" style="vertical-align: top;"><spring:message code="user.memberInGroups.label" text="Member in Groups"/>:</td>
			<td class="data" id="rolesList" style="white-space:normal !important;">
				<c:forEach items="${userGroups}" var="userGroup">
					<c:remove var="lastModifiedInfo"/>
					<c:set var="definition" value="${groupMembership[userGroup.id]}"/>
					<c:if test="${definition != null}">
						<c:set var="lastModifiedInfo">
							<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/> <c:out value="${definition.lastModifiedBy.name}"/>, <tag:formatDate value="${definition.lastModifiedAt}"/>
						</c:set>
					</c:if>

					<spring:message var="groupTitle" code="group.${userGroup.name}.tooltip" text="${userGroup.shortDescription}" htmlEscape="true"/>
					<label for="userGroup_${userGroup.id}" title="${groupTitle}">
						<form:checkbox path="groupId" value="${userGroup.id}" title="${lastModifiedInfo}" id="userGroup_${userGroup.id}" />
						<spring:message code="group.${userGroup.name}.label" text="${userGroup.name}"/>
					</label>
				</c:forEach>
				<div style="clear:both;"></div>
				<form:errors path="groupId" cssClass="invalidfield"/>
			</td>
		</tr>
	</table>
</c:if>
</c:set>

<c:set var="privacyAgreement">
	<style type="text/css">
		.privacyAgree label {
			margin-left: 10px;
		}
		.privacyAgree p {
			margin-left: 20px;
		}
		.consentCheckbox {
			vertical-align: middle;
			position: relative;
			bottom: 1px;
		}
	</style>
	<tr>
		<td colspan="2" class="privacyAgree">
			<p style="margin-top: 20px; font-weight: bold;"><spring:message code="user.privacy.note" /></p>
			<p>
				<form:checkbox cssClass="consentCheckbox" path="user.marketingConsentAccepted" id="agree1" />
				<label for="agree1" ><spring:message code="user.privacy.agree1" /></label>
			</p>
			<p>
                <form:checkbox cssClass="consentCheckbox" path="user.salesConsentAccepted" id="agree2"/>
				<label for="agree2"><spring:message code="user.privacy.agree2" /></label>
			</p>
		</td>
	</tr>
</c:set>

<c:set var="personalDetails">
<table width="100%" border="0" cellpadding="0" class="formTableWithSpacing">

<c:if test="${!showPrivacyAgreement && !isAccountEditing && !isEmailRegistry}">
	<tr>
		<td colspan="2">
			<STRONG>
				<spring:message code="user.confidentiality.hint"
								  text="This information will be kept on this {0} installation only<BR>and no information will be transferred over the Internet."
								  arguments="${licenseCode.type}"/>
			</STRONG>
		</td>
	</tr>
</c:if>

<tr>
	<td class="mandatory"><spring:message code="user.name.label" text="Account Name"/>:</td>
	<td class="data">
		<form:input path="user.name" cssClass="sensitive" size="60" maxlength="50" disabled="${isLdap}"/>
		<c:if test="${isLdap}">
			<spring:message code="user.name.ldap.warn" text="Title" var="ldapWarn"/>
			<div class="user-ldap-alert" title="${ldapWarn}"></div>
		</c:if>
		<br/><form:errors path="user.name" cssClass="invalidfield"/>
	</td>
</tr>

<c:if test="${isUserPasswordEditable}">
	<tr>
		<td class="mandatory"><spring:message code="user.password.label" text="Password"/>:</td>
		<td class="data">
			<ui:password path="user.password" size="60" maxlength="70" autocomplete="off" /><br/><form:errors path="user.password" cssClass="invalidfield" />
		</td>
	</tr>
	<tr>
		<td class="mandatory"><spring:message code="user.password.confirm" text="Confirm Password"/>:</td>
		<td class="data">
			<ui:password path="password2" size="60" maxlength="70" autocomplete="off" /><br/><form:errors path="password2" cssClass="invalidfield"/>
		</td>
	</tr>
</c:if>
<c:if test="${!isUserPasswordEditable}">
	<form:hidden path="user.password"/>
	<form:hidden path="password2"/>
</c:if>

<c:if test="${(isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator}">
<tr>
	<td class="optional"><spring:message code="user.title.label" text="Title"/>:</td>
	<td class="data">
		<form:input path="user.title" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.title" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>
<tr>
	<td class="mandatory"><spring:message code="user.firstName.label" text="First Name"/>:</td>
	<td class="data">
		<form:input path="user.firstName" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.firstName" cssClass="invalidfield"/>
	</td>
</tr>
<tr>
	<td class="mandatory"><spring:message code="user.lastName.label" text="Last Name"/>:</td>
	<td class="data">
		<form:input path="user.lastName" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.lastName" cssClass="invalidfield"/>
	</td>
</tr>

<c:if test="${!isAccountAdministrator}">
	<form:hidden path="user.status"/>
</c:if>

<c:if test="${captchaEnabled && !isAccountEditing && !isAccountAdministrator}">
<tr class="blockStart" valign="top">
	<td class="mandatory" style="vertical-align: top;padding-top: 60px !important;">
		<spring:message code="user.captcha.label" text="Please write the letters into the text field"/>:
	</td>
	<td class="data">
		<div id="captcha_paragraph">
			<div class="g-recaptcha" data-sitekey="6LcH3EkUAAAAABznQLtL7YWgXwOHBLLxMKyMFn0T">
		</div>
		<form:errors path="captcha" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

<c:if test="${isUserEmailEditable || (isAccountDeactivated && isAccountAdministrator)}">
	<tr class="blockStart">
		<td class="mandatory" valign="top"><spring:message code="user.email.label" text="Email"/>:</td>
		<td class="data">
			<spring:message var="emailTitle" code="email.multiple.tooltip" />
			<form:input path="user.email" cssClass="sensitive" size="60" maxlength="250" title="${emailTitle}" /><br/><form:errors path="user.email" cssClass="invalidfield"/>

			<c:if test="${isEmailRegistry}">
				<spring:message code="user.email.verification.hint"/>
			</c:if>
		</td>
	</tr>
</c:if>

<c:if test="${!isUserEmailEditable && !isAccountDeactivated}">
	<tr class="blockStart">
		<td class="optional" valign="top"><spring:message code="user.email.label" text="Email"/>:</td>
		<td class="data">
			<form:hidden path="user.email"/>
			<a href="mailto:<c:out value="${userForm.user.email}" />"><c:out value="${userForm.user.email}" default="--" /></a>
		</td>
	</tr>
</c:if>

<c:if test="${(isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator || userForm.phoneMandatory}">
<tr>
	<td class="<c:choose><c:when test="${userForm.phoneMandatory}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
		<spring:message code="user.phone.label" text="Phone"/>:
	</td>
	<td class="data">
		<form:input path="user.phone" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.phone" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

<c:if test="${(isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator}">
<tr>
	<td class="optional"><spring:message code="user.mobile.label" text="Mobile"/>:</td>
	<td class="data">
		<form:input path="user.mobile" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.mobile" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>
	<c:if test="${(isSaas || isCodebeamerCom || userForm.industryMandatory)}">
		<c:choose>
			<c:when test="${isAccountEditing && userForm.industryMandatory}">
				<tr hidden>
					<td class="${userForm.industryMandatory ? 'mandatory' : 'optional'}">
						<spring:message code="user.industry.label" text="Industry"/>:
					</td>
					<td class="data">

						<form:select path="user.industry">
							<form:option value="--" label="--"/>
							<form:options items="${industryOptions}" itemLabel="key" itemValue="value"/>
						</form:select>
						<br/><form:errors path="user.industry" cssClass="invalidfield"/>
					</td>
				</tr>
			</c:when>
			<c:when test="${!isAccountEditing}">
			<tr>
					<td class="${userForm.industryMandatory ? 'mandatory' : 'optional'}">
						<spring:message code="user.industry.label" text="Industry"/>:
					</td>
					<td class="data">
						<form:select path="user.industry">
							<form:option value="" label="--"/>
							<form:options items="${industryOptions}" itemLabel="key" itemValue="value"/>
						</form:select>
						<br/><form:errors path="user.industry" cssClass="invalidfield"/>
					</td>
				</tr>
			</c:when>
		</c:choose>
	</c:if>

<tr>
	<td class="${isSaas || userForm.companyMandatory ? 'mandatory' : 'optional'}" >
		<spring:message code="user.company.label" text="Company"/>:
	</td>
	<td class="data">
		<form:input path="user.company" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.company" cssClass="invalidfield"/>
	</td>
</tr>

<c:if test="${(isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator || userForm.postalAddressMandatory}">
<tr>
	<td class="<c:choose><c:when test="${userForm.postalAddressMandatory}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
		<spring:message code="user.address.label" text="Address"/>:
	</td>
	<td class="data">
		<form:input path="user.address" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.address" cssClass="invalidfield"/>
	</td>
</tr>
<tr>
	<td class="<c:choose><c:when test="${userForm.postalAddressMandatory}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
		<spring:message code="user.city.label" text="City"/>:
	</td>
	<td class="data">
		<form:input path="user.city" cssClass="sensitive" size="60" maxlength="70" /><br/><form:errors path="user.city" cssClass="invalidfield"/>
	</td>
</tr>
<tr>
	<td class="<c:choose><c:when test="${userForm.postalAddressMandatory}">mandatory</c:when><c:otherwise>optional</c:otherwise></c:choose>">
		<spring:message code="user.zip.label" text="Zip/Postal Code"/>:
	</td>
	<td class="data">
		<form:input path="user.zip" cssClass="sensitive" size="60" maxlength="15" /><br/><form:errors path="user.zip" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

<c:if test="${(isSaas || isCodebeamerCom || userForm.countryMandatory) || ((isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator)}">
<tr>
	<td class="optional"><spring:message code="user.state.label" text="State/Province"/>:</td>
	<td class="data">
		<form:input path="user.state" cssClass="sensitive" size="60" maxlength="50" /><br/><form:errors path="user.state" cssClass="invalidfield"/>
	</td>
</tr>
<tr>
	<td class="${userForm.countryMandatory ? 'mandatory' : 'optional'}"><spring:message code="user.country.label" text="Country"/>:</td>
	<td class="data">
		<form:select cssClass="sensitive" path="user.country">
			<form:option value="" label="--"/>
			<form:options items="${countryOptions}" itemLabel="key" itemValue="value" />
		</form:select>
		<br/><form:errors path="user.country" cssClass="invalidfield"/>
	</td>
</tr>
<tr class="blockStart">
	<td class="optional"><spring:message code="user.language.label" text="Language"/>:</td>
	<td class="data">
		<form:select path="user.language">
			<form:options items="${languageOptions}" itemLabel="key" itemValue="value" />
		</form:select>
		<br/><form:errors path="user.language" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

<c:if test="${!isAccountEditing}">
	<tr>
		<td class="optional"><spring:message code="user.timeZonePattern.label" text="Time zone"/>:</td>
		<td class="data">
			<form:select path="user.timeZonePattern">
				<form:options items="${timeZoneOptions}" itemLabel="name" itemValue="value" />
			</form:select>
			<br/><form:errors path="user.timeZonePattern" cssClass="invalidfield"/>
		</td>
	</tr>

	<tr>
		<td class="optional"><spring:message code="user.dateFormatPattern.label" text="Date Format"/>:</td>
		<td class="data">
			<form:select path="user.dateFormatPattern">
				<form:options items="${availableDateFormats}" itemLabel="name" itemValue="value" />
			</form:select>
			<br/><form:errors path="user.dateFormatPattern" cssClass="invalidfield"/>
		</td>
	</tr>
</c:if>

<c:if test="${isAccountAdministrator}">

	<c:if test="${multiLicenses}">
		<script type="text/javascript">
			function showHideFilter(checkbox) {
				var select = $(checkbox).closest("tr").find("select");
				select.css({"visibility" : (checkbox.checked ? "visible" : "hidden")});
			}

			$(function() {
				$("#licenseTypesTable input[type='checkbox']").each(function() {
					showHideFilter(this);
				});
			});
		</script>
	</c:if>

	<tr>
		<td class="optional" style="vertical-align: top; padding-top: 9px !important;" ><spring:message code="user.licenseType.label" text="License Type"/>:</td>
		<td class="data">
			<c:choose>
				<c:when test="${multiLicenses}">
					<table id="licenseTypesTable" class="displaytag">
						<tr class="head">
							<th class="textData columnSeparator" colspan="2"><spring:message code="sysadmin.license.product" text="Product"/></th>
							<th class="textData"><spring:message code="sysadmin.license.label"   text="License"/></th>
						</tr>
						<tr><td colspan="3"/></tr> <%-- just for spacing --%>

						<c:forEach items="${licenseCode.productLicenses}" var="productLicense" varStatus="loop">
							<c:remove var="lastModifiedInfo"/>
							<c:set var="definition" value="${userLicenses[productLicense.type]}"/>
							<c:if test="${definition != null}">
								<c:set var="lastModifiedInfo">
									<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/> <c:out value="${definition.lastModifiedBy.name}"/>, <tag:formatDate value="${definition.lastModifiedAt}"/>
								</c:set>
							</c:if>

							<tr title="${lastModifiedInfo}" class="odd" style="vertical-align: baseline;">
								<td class="checkbox-column-minwidth">
									<form:checkbox id="license_${loop.index}_selector" path="userLicense" value="${productLicense.type}" onchange="showHideFilter(this);"/>
								</td>
								<td class="textData columnSeparator" width="10%">
									<label for="license_${loop.index}_selector">
										<spring:message code="sysadmin.license.product.${productLicense.type}"  text="${productLicense.type}"/>
									</label>
								</td>
								<td class="textData" style="visibility:hidden;">
									<form:select path="userLicenseType[${productLicense.type}]">
										<c:forEach items="${productLicense.userLicenseTypes}" var="userType">
											<form:option value="${userType.id}">
												<spring:message code="user.licenseType.${userType.id}" />
											</form:option>
										</c:forEach>
									</form:select>
								</td>
							</tr>
						</c:forEach>
					</table>
				</c:when>

				<c:otherwise>
					<c:forEach items="${licenseCode.productLicenses}" var="productLicense" varStatus="loop">
						<input type="hidden" name="userLicense" value="${productLicense.type}"/>

						<c:remove var="lastModifiedInfo"/>
						<c:set var="definition" value="${userLicenses[productLicense.type]}"/>
						<c:if test="${definition != null}">
							<c:set var="lastModifiedInfo">
								<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/> <c:out value="${definition.lastModifiedBy.name}"/>, <tag:formatDate value="${definition.lastModifiedAt}"/>
							</c:set>
						</c:if>

						<form:select path="userLicenseType[${productLicense.type}]" title="${lastModifiedInfo}">
							<c:forEach items="${productLicense.userLicenseTypes}" var="userType">
								<form:option value="${userType.id}">
									<spring:message code="user.licenseType.${userType.id}" />
								</form:option>
							</c:forEach>
						</form:select>
					</c:forEach>
				</c:otherwise>
			</c:choose>

			<form:errors path="userLicense" cssClass="invalidfield"/>
		</td>
	</tr>

	<tr>
		<td class="optional"><spring:message code="user.status.label" text="Status"/>:</td>
		<td class="data">
			<spring:message var="activatedUser" code="user.activated" text="Activated"/>
			<spring:message var="disabledUser" code="user.disabled" text="Disabled"/>
			<spring:message var="pendingUser" code="user.inactivation" text="In activation"/>

			<c:choose>
				<c:when test="${isAccountDeactivated && !isAccountReactivationAllowed}">
					<form:hidden path="user.status"/>
					<c:out value="${disabledUser}" />
				</c:when>
				<c:otherwise>
				${user.status}
					<form:select path="user.status" cssClass="userStatusDropdown">
						<form:option label="${activatedUser}" value="activated" />
						<form:option label="${disabledUser}" value="disabled" />
						<c:if test="${isAccountInActivation}">
							<form:option label="${pendingUser}" value="inactivation" />
						</c:if>
					</form:select>
					<br/><form:errors path="user.status" cssClass="invalidfield"/>
				</c:otherwise>
			</c:choose>
		</td>
	</tr>

<c:if test="${isAccountEditing && isAccountAdministrator && isSaas}">
	<tr>
		<td class="optional">Account expiry:</td>
		<td class="data">
			<form:input path="expiryDate" size="12" maxlength="30" id="expiryDate"/>
			<ui:calendarPopup textFieldId="expiryDate" />
			<br/><form:errors path="expiryDate" cssClass="invalidfield"/>
		</td>
	</tr>
</c:if>

	<tr>
		<td class="mandatory"><spring:message code="user.downloadLimit.label" text="Upload Limit (in KB)"/>:</td>
		<td class="data">
			<form:input path="user.downloadLimit" size="60" maxlength="30" /><br/><form:errors path="user.downloadLimit" cssClass="invalidfield"/>
		</td>
	</tr>

	<c:if test="${!isAccountEditing}">
		<tr>
			<td class="mandatory"><spring:message code="user.memberInGroups.label" text="Member in Groups"/>:</td>
			<td class="data" id="rolesList">
				<c:forEach items="${userGroups}" var="userGroup">
					<c:remove var="lastModifiedInfo"/>
					<c:set var="definition" value="${groupMembership[userGroup.id]}"/>
					<c:if test="${definition != null}">
						<c:set var="lastModifiedInfo">
							<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/> <c:out value="${definition.lastModifiedBy.name}"/>, <tag:formatDate value="${definition.lastModifiedAt}"/>
						</c:set>
					</c:if>

					<spring:message var="groupTitle" code="group.${userGroup.name}.tooltip" text="${userGroup.shortDescription}" htmlEscape="true"/>
					<label for="userGroup_${userGroup.id}" title="${groupTitle}">
						<form:checkbox path="groupId" value="${userGroup.id}" title="${lastModifiedInfo}" id="userGroup_${userGroup.id}" />
						<spring:message code="group.${userGroup.name}.label" text="${userGroup.name}"/>
					</label>
				</c:forEach>
				<br/><form:errors path="groupId" cssClass="invalidfield"/>
			</td>
		</tr>
	</c:if>
</c:if>

<c:if test="${isEmailRegistry}">
	<tr>
		<td class="optional"><spring:message code="user.sourceOfInterest.label" text="Source of interest"/>:</td>
		<td class="data">
			<form:input path="user.sourceOfInterest" size="60" maxlength="70" /><br/><form:errors path="user.sourceOfInterest" cssClass="invalidfield"/>
		</td>
	</tr>

	<tr>
		<td class="mandatory"><spring:message code="user.teamSize.label" text="Size of your development team"/>:</td>
		<td class="data">
			<label><form:radiobutton path="user.teamSize" value="-1" /> --</label>
			<label><form:radiobutton path="user.teamSize" value="10" />&lt; 10</label>
			<label><form:radiobutton path="user.teamSize" value="50" />&lt; 50</label>
			<label><form:radiobutton path="user.teamSize" value="100" />&lt; 100</label>
			<label><form:radiobutton path="user.teamSize" value="200" />&lt; 200</label>
			<label><form:radiobutton path="user.teamSize" value="1000" />&gt; 200</label>
			<br/><form:errors path="user.teamSize" cssClass="invalidfield"/>
		</td>
	</tr>

	<tr>
		<td class="mandatory"><spring:message code="user.divisionSize.label" text="Size of the overall development division"/>:</td>
		<td class="data">
			<label><form:radiobutton path="user.divisionSize" value="-1" /> --</label>
			<label><form:radiobutton path="user.divisionSize" value="10" />&lt; 10</label>
			<label><form:radiobutton path="user.divisionSize" value="50" />&lt; 50</label>
			<label><form:radiobutton path="user.divisionSize" value="100" />&lt; 100</label>
			<label><form:radiobutton path="user.divisionSize" value="200" />&lt; 200</label>
			<label><form:radiobutton path="user.divisionSize" value="1000" />&gt; 200</label>
			<br/><form:errors path="user.divisionSize" cssClass="invalidfield"/>
		</td>
	</tr>

	<tr>
		<td class="mandatory"><spring:message code="user.scc.label" text="SCM solution used"/>:</td>
		<td class="data">
			<form:select path="user.scc">
				<form:option value="Unset">--</form:option>
				<form:option value="Subversion">Subversion</form:option>
				<form:option value="GIT">GIT (Distributed Version Control)</form:option>
				<form:option value="Mercurial">Mercurial (Distributed Version Control)</form:option>
				<form:option value="CVS">CVS</form:option>
				<form:option value="ClearCase">ClearCase</form:option>
				<form:option value="CM-Synergy">CM-Synergy</form:option>
				<form:option value="SourceSafe">SourceSafe</form:option>
				<form:option value="PVCS">PVCS</form:option>
				<form:option value="Perforce">Perforce</form:option>
				<form:option value="Starteam">StarTeam</form:option>
				<form:option value="Other"><spring:message code="user.scc.other" text="Other"/></form:option>
				<form:option value="No"><spring:message code="user.scc.none" text="No"/></form:option>
			</form:select>
			<br/><form:errors path="user.scc" cssClass="invalidfield"/>
		</td>
	</tr>
</c:if>

<c:if test="${(isAccountEditing && isAccountAdministratorOwn) || isAccountAdministrator}">
<tr valign="top">
	<td class="optional" style="vertical-align: top; padding-top: 18px !important;"><spring:message code="user.skills.label" text="Skills"/>:</td>
	<td class="data">
		<form:textarea path="user.skills" cssClass="sensitive" rows="2" cols="60" /><br/><form:errors path="user.skills" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

</table>
</c:set>

<TABLE id="userDataTable" WIDTH="90%" CELLPADDING="0">
<tbody>
<tr VALIGN="top">
	<c:if test="${!isAccountEditing || isAccountAdministratorOwn || isAccountAdministrator}">
		<td style="vertical-align: top; width: 1%;">
			<%-- TODO: would be nice to integrate photo editing here, now this is disabled
				<c:set var="updateUserPhotoUrl" value="/updateUserPhoto?user_id=${userForm.user.id}" />
					... url="${canModifyAccount ? updateUserPhotoUrl : null}"
			--%>
			<c:choose>
				<c:when test="${!empty userForm.user.id }">
					<ui:userPhoto userId="${userForm.user.id}" userName="${userForm.user.name}" large="true" url="#" />
				</c:when>
				<c:otherwise>
					<c:url var="imgUrl" value="/images/newskin/item/blank-person-l.png"/>
					<img class="largePhoto photoBox" src="${imgUrl}"/>
				</c:otherwise>
			</c:choose>
		</td>
		<td WIDTH="40%" class="block">
			<%-- Left column --%>
			<h4>
				<spring:message code="user.personalDetails.label" text="Personal Details"/>
			</h4>
			${personalDetails}
		</td>
	</c:if>
	<td WIDTH="40%" class="block">
		<div class="block">${userGroupMemberShipTable}</div>
		<div class="block">${timeZoneAndDateFormatTable}</div>
	</td>
	<c:if test="${showPrivacyAgreement && !isAccountEditing}">
		${privacyAgreement}
	</c:if>

</tr>
</tbody>
</TABLE>

<c:if test="${hasSubmissionGuid}">
	<jsp:include page="capterra.jsp"/>
</c:if>
