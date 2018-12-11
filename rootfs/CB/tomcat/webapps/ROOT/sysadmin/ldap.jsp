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
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style type="text/css">
<!--
#authenticateUsersAgainst p {
	margin:1px;
}
.testResult {
	font-weight: bold;
	color: blue;
}
textarea {
	width: 40em;
	height: 3em;
}
-->
</style>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="ldap.config.title" text="Configure the LDAP/Active Directory access"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="ldap" method="POST" autocomplete="off">
	<ui:actionBar>
		<spring:message var="saveButton" code="button.save" text="Save"/>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" onclick="return confirmSave();" />
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<spring:hasBindErrors name="ldap">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	<script type="text/javascript">
		function confirmSave() {
			var enabledCheckbox = document.getElementById("realm.enabled");
			if (enabledCheckbox.checked == false) {
				var msg = i18n.message("ldap.config.save.confirm");
				var answer = confirm(msg);
				return answer;
			}
			return;
		}

		$(document).ready(function() {
			codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
		});
	</script>

<div class="contentWithMargins">
	<table border="0" cellpadding="2" style="width: 100%; border-collapse: separate;border-spacing: 2px;">
		<tr>
			<td valign="top" align="left" style="width:50%;">
				<fieldset>
					<legend><spring:message code="ldap.server.label" text="LDAP/Active Directory Server"/></legend>

					<table border="0" cellpadding="2" class="formTableWithSpacing">
						<spring:message var="ldapServerUrlTitle" code="ldap.server.urls.tooltip" text="Hostname/IP-address and port of the LDAP servers. You can specify multiple servers (primary plus alternatives) by separating them with commas or new lines"/>
						<tr title="${ldapServerUrlTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.urls.label" text="Server URLs"/>:</td>
							<td align="left">
								<form:textarea path="serverUrls" /> <br/>
								<form:errors path="server.urls" cssClass="invalidfield"/>
							</td>
						</tr>
						<spring:message var="ldapServerBaseDnTitle" code="ldap.server.baseDn.tooltip" text="Common LDAP base domain where all codebeamer users are all stored"/>
						<tr title="${ldapServerBaseDnTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.baseDn.label" text="Base domain"/>:</td>
							<td align="left">
								<form:input path="server.baseDn" size="70" /> <br/>
								<form:errors path="server.baseDn" cssClass="invalidfield"/>
							</td>
						</tr>
						<spring:message var="ldapServerUserDnTitle" code="ldap.server.userDn.tooltip" text="The full distinguished name of an LDAP user to login"/>
						<tr title="${ldapServerUserDnTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.userDn.label" text="Username"/>:</td>
							<td align="left">
								<form:input path="server.userDn" size="70" /> <br/>
								<form:errors path="server.userDn" cssClass="invalidfield"/>
							</td>
						</tr>
						<spring:message var="ldapServerPasswordTitle" code="ldap.server.password.tooltip" text="The password/credentials to authenticate the login user"/>
						<tr title="${ldapServerPasswordTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.password.label" text="Password"/>:</td>
							<td align="left">
								<ui:password path="server.password" size="40" autocomplete="off"/> <br/>
								<form:errors path="server.password" cssClass="invalidfield"/>
							</td>
						</tr>
						<tr>
							<td class="optional" align="right"><spring:message code="ldap.server.anonymousReadOnly.label" text="Anonymous?"/>:</td>
							<td align="left">
								<form:checkbox path="server.anonymousReadOnly" id="server.anonymousReadOnly" />
								<label for="server.anonymousReadOnly">
									<spring:message code="ldap.server.anonymousReadOnly.tooltip" text="If anonymous access is allowed, you can omit the Username and Password"/>
								</label>
							</td>
						</tr>
						<spring:message var="ldapServerConnectTitle" code="ldap.server.connectTimeout.tooltip" text="Timeout (in milliseconds) for establishing connections to the LDAP server"/>
						<tr title="${ldapServerConnectTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.connectTimeout.label" text="Connect timeout"/>:</td>
							<td align="left" nowrap>
								<form:input path="server.connectTimeout" size="8" /> ms <br/>
								<form:errors path="server.connectTimeout" cssClass="invalidfield"/>
							</td>
						</tr>
						<spring:message var="ldapServerReadTitle" code="ldap.server.readTimeout.tooltip" text="Timeout (in milliseconds) to wait for responses from the LDAP server"/>
						<tr title="${ldapServerReadTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.readTimeout.label" text="Read timeout"/>:</td>
							<td align="left" nowrap>
								<form:input path="server.readTimeout" size="8" /> ms <br/>
								<form:errors path="server.readTimeout" cssClass="invalidfield"/>
							</td>
						</tr>
						<spring:message var="ldapServerReferralTitle" code="ldap.server.referral.tooltip" text="Method to handle referrals. For Active-Directory use follow"/>
						<tr title="${ldapServerReferralTitle}">
							<td class="optional" align="right"><spring:message code="ldap.server.referral.label" text="Referrals"/>:</td>
							<td align="left">
								<form:select path="server.referral">
									<form:option value="ignore"><spring:message code="ldap.server.referral.ignore" text="Ignore"/></form:option>
									<form:option value="follow"><spring:message code="ldap.server.referral.follow" text="Follow"/></form:option>
									<form:option value="throw"><spring:message code="ldap.server.referral.throw" text="Throw"/></form:option>
								</form:select>
								<br/>
								<form:errors path="server.referral" cssClass="invalidfield"/>
							</td>
						</tr>
					</table>
				</fieldset>

				<br/>

				<fieldset id="authenticateUsersAgainst">
					<legend>
						<form:checkbox path="realm.enabled" id="realm.enabled"/>
						<label for="realm.enabled"><spring:message code="ldap.realm.label" text="Authenticate users against LDAP/Active Directory"/></label>
					</legend>

						<spring:message var="ldapRealmLookupTitle" code="ldap.realm.userPattern.tooltip" text="The user's unique Distinguished Name (DN) pattern, where '{0}' will be replaced by the login name of the user. You can specify multiple patterns to try via (pattern1) (pattern2) ...(patternX)"/>
						<fieldset title="${ldapRealmLookupTitle}">
							<legend><spring:message code="ldap.realm.userPattern.label" text="Lookup user"/></legend>

							<table border="0" cellpadding="2" class="formTableWithSpacing">
								<tr>
									<td width="25px" align="right" nowrap >as</td>
									<td align="left" nowrap>
										<form:textarea path="realm.userPattern" />
										<div>
											<form:errors path="realm.userPattern" cssClass="invalidfield"/>
										</div>
									</td>
								</tr>
							</table>
						</fieldset>
						<fieldset>
							<legend><spring:message code="ldap.realm.userSearch.title" text="Search user"/></legend>

							<table border="0" cellpadding="2" class="formTableWithSpacing">
								<spring:message var="ldapRealmSearchTitle" code="ldap.realm.userSearch.tooltip" text="Search criteria to find a single user in a specific directory branch, where '{0}' will be replaced by the login name of the user"/>
								<tr title="${ldapRealmSearchTitle}">
									<td width="25px" align="right" nowrap><spring:message code="ldap.realm.userSearch.label" text="with"/></td>
									<td align="left" nowrap>
										<form:textarea path="realm.userSearch" />
										<div>
											<form:errors path="realm.userSearch" cssClass="invalidfield"/>
										</div>
									</td>
								</tr>
								<spring:message var="ldapRealmSearchBase" code="ldap.realm.userBase.tooltip" text="The base/root directory branch (relative to Base Domain) where to search for users"/>
								<tr title="${ldapRealmSearchBase}">
									<td width="25px" align="right" nowrap><spring:message code="ldap.realm.userBase.label" text="in"/></td>
									<td align="left" nowrap>
										<form:textarea path="realm.userBase" />
									</td>
								</tr>
								<spring:message var="ldapRealmSearchTree" code="ldap.realm.userSubtree.tooltip" text="Whether to search recursivly or not "/>
								<tr title="${ldapRealmSearchTree}">
									<td width="25px" align="right" nowrap >
										<form:checkbox path="realm.userSubtree" />
									</td>
									<td align="left" nowrap><spring:message code="ldap.realm.userSubtree.label" text="recursively"/></td>
								</tr>
							</table>
						</fieldset>

						<table border="0" cellpadding="2" class="formTableWithSpacing">
							<tr>
								<td valign="top">
									<form:checkbox path="realm.storePassword" id="realm.storePassword" />
								</td>
								<td>
									<label for="realm.storePassword">
										<spring:message code="ldap.realm.storePassword.label" text="Store password of LDAP users also in CodeBeamer database (Required if fallback should be enabled)."/>
									</label>
								</td>
							</tr>
							<tr>
								<td valign="top">
									<form:checkbox path="realm.fallback" id="realm.fallback"/>
								</td>
								<td>
									<label for="realm.fallback">
										<spring:message code="ldap.realm.fallback.label" text="Fallback to default CodeBeamer authentication, when (none of) the LDAP server(s) is reachable, or the user is not an LDAP user."/>
									</label>
								</td>
							</tr>
							<tr>
								<td valign="top">
									<form:checkbox path="cache.enabled" id="cache.enabled"/>
								</td>
								<td>
									<label for="cache.enabled">
										<spring:message code="ldap.cache.enabled.label" text="Cache authentication results"/>
									</label>
									<spring:message code="ldap.cache.successTTL.label" text=", and remembersuccessful logins for"/>
									<form:input path="cache.successTTL" size="8" /> ms
									<spring:message code="ldap.cache.failureTTL.label" text="failed logins for"/>
									<form:input path="cache.failureTTL" size="8" /> ms.
								</td>
							</tr>
						</table>
				</fieldset>
			</td>

			<td valign="top" align="left">
				<fieldset>
					<legend>
						<spring:message code="ldap.mapping.label" text="Mapping of codeBeamer User/Account attributes to the appropriate LDAP attributes"/>
					</legend>

					<spring:nestedPath path="mapping">
						<table border="0" cellpadding="2" class="formTableWithSpacing">
							<c:if test="${! empty testResult}">
								<th colspan="2"/>
								<th nowrap><spring:message code="ldap.mapping.result" text="Response from LDAP"/></th>
							</c:if>

							<spring:message var="ldapMappingName" code="ldap.mapping.username.tooltip" text="LDAP attribute holding the user/account name"/>
							<tr title="${ldapMappingName}">
								<td class="optional" align="right"><spring:message code="user.name.label" text="Account Name"/>:</td>
								<td align="left" nowrap>
									<form:input path="name" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.name} </td>
							</tr>
							<spring:message var="ldapMappingPassword" code="ldap.mapping.password.tooltip" text="LDAP attribute holding the user/account password"/>
							<tr title="${ldapMappingPassword}">
								<td class="optional" align="right"><spring:message code="user.password.label" text="Password"/>:</td>
								<td align="left" nowrap>
									<form:input path="password" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.password} </td>
							</tr>
							<spring:message var="ldapMappingTitle" code="ldap.mapping.title.tooltip" text="LDAP attribute holding the user''s title"/>
							<tr title="${ldapMappingTitle}">
								<td class="optional" align="right"><spring:message code="user.title.label" text="Title"/>:</td>
								<td align="left" nowrap>
									<form:input path="title" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.title} </td>
							</tr>
							<spring:message var="ldapMappingFirstName" code="ldap.mapping.firstName.tooltip" text="LDAP attribute holding the user''s first name"/>
							<tr title="${ldapMappingFirstName}">
								<td class="optional" align="right"><spring:message code="user.firstName.label" text="First Name"/>:</td>
								<td align="left" nowrap>
									<form:input path="firstName" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.firstName} </td>
							</tr>
							<spring:message var="ldapMappingLastName" code="ldap.mapping.lastName.tooltip" text="LDAP attribute holding the user''s family/last name"/>
							<tr title="${ldapMappingLastName}">
								<td class="optional" align="right"><spring:message code="user.lastName.label" text="Last Name"/>:</td>
								<td align="left" nowrap>
									<form:input path="lastName" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.lastName} </td>
							</tr>
							<spring:message var="ldapMappingCompany" code="ldap.mapping.company.tooltip" text="LDAP attribute holding the user''s company"/>
							<tr title="${ldapMappingCompany}">
								<td class="optional" align="right"><spring:message code="user.company.label" text="Company"/>:</td>
								<td align="left" nowrap>
									<form:input path="company" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.company} </td>
							</tr>
							<spring:message var="ldapMappingAddress" code="ldap.mapping.address.tooltip" text="LDAP attribute holding the user''s address"/>
							<tr title="${ldapMappingAddress}">
								<td class="optional" align="right"><spring:message code="user.address.label" text="Address"/>:</td>
								<td align="left" nowrap>
									<form:input path="address" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.address} </td>
							</tr>
							<spring:message var="ldapMappingZIP" code="ldap.mapping.zip.tooltip" text="LDAP attribute holding the ZIP/PostalCode to the user''s address"/>
							<tr title="${ldapMappingZIP}">
								<td class="optional" align="right"><spring:message code="user.zip.label" text="Zip/Postal Code"/>:</td>
								<td align="left" nowrap>
									<form:input path="zip" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.zip} </td>
							</tr>
							<spring:message var="ldapMappingCity" code="ldap.mapping.city.tooltip" text="LDAP attribute holding the name of the city of residence"/>
							<tr title="${ldapMappingCity}">
								<td class="optional" align="right"><spring:message code="user.city.label" text="City"/>:</td>
								<td align="left" nowrap>
									<form:input path="city" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.city} </td>
							</tr>
							<spring:message var="ldapMappingState" code="ldap.mapping.state.tooltip" text="LDAP attribute holding the name of the state/province of residence"/>
							<tr title="${ldapMappingState}">
								<td class="optional" align="right"><spring:message code="user.state.label" text="State/Province"/>:</td>
								<td align="left" nowrap>
									<form:input path="state" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.state} </td>
							</tr>
							<spring:message var="ldapMappingCountry" code="ldap.mapping.country.tooltip" text="LDAP attribute holding the name of the country of residence"/>
							<tr title="${ldapMappingCountry}">
								<td class="optional" align="right"><spring:message code="user.country.label" text="Country"/>:</td>
								<td align="left" nowrap>
									<form:input path="country" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.country} </td>
							</tr>
							<spring:message var="ldapMappingTimezone" code="ldap.mapping.timeZonePattern.tooltip" text="LDAP attribute holding the name/id of the time zone"/>
							<tr title="${ldapMappingTimezone}">
								<td class="optional" align="right"><spring:message code="user.timeZonePattern.label" text="Timezone"/>:</td>
								<td align="left" nowrap>
									<form:input path="timeZonePattern" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.timeZonePattern} </td>
							</tr>
							<spring:message var="ldapMappingEmail" code="ldap.mapping.email.tooltip" text="LDAP attribute holding the email address of the user"/>
							<tr title="${ldapMappingEmail}">
								<td class="optional" align="right"><spring:message code="user.email.label" text="Email"/>:</td>
								<td align="left" nowrap>
									<form:input path="email" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.email} </td>
							</tr>
							<spring:message var="ldapMappingEmailSuffix" code="ldap.mapping.mailSuffix.tooltip" text="Special constant to append to the fetched email address"/>
							<tr title="${ldapMappingEmailSuffix}">
								<td class="optional" align="right"><spring:message code="ldap.mapping.mailSuffix.label" text="Email Suffix"/>:</td>
								<td align="left" nowrap>
									<form:input path="mailSuffix" size="40" />
								</td>
								<td/>
							</tr>
							<spring:message var="ldapMappingPhone" code="ldap.mapping.phone.tooltip" text="LDAP attribute holding the phone number of the user"/>
							<tr title="${ldapMappingPhone}">
								<td class="optional" align="right"><spring:message code="user.phone.label" text="Phone"/>:</td>
								<td align="left" nowrap>
									<form:input path="phone" size="40" />
								</td>
								<td align="left" class="testResult" > ${testResult.phone} </td>
							</tr>
							<spring:message var="ldapMappingMobile" code="ldap.mapping.mobile.tooltip" text="LDAP attribute holding the mobile number of the user"/>
							<tr title="${ldapMappingMobile}">
								<td class="optional" align="right"><spring:message code="user.mobile.label" text="Mobile"/>:</td>
								<td align="left" nowrap>
									<form:input path="mobile" size="40" />
								</td>
								<td align="left" class="testResult"> ${testResult.mobile} </td>
							</tr>
						</table>
					</spring:nestedPath>
				</fieldset>

				<br/>

				<fieldset>
					<legend><spring:message code="ldap.config.test" text="Test authentication against LDAP/Active Directory"/></legend>

					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td align="left">
								<table border="0" cellpadding="2" class="formTableWithSpacing">
									<spring:message var="ldapTestUser" code="ldap.testUser.name.tooltip" text="The name of a codeBeamer User/Account to test"/>
									<tr title="${ldapTestUser}">
										<td class="optional" align="right"><spring:message code="login.username" text="Username"/>:</td>
										<td align="left" nowrap>
											<form:input path="testUser.name" size="40" />
											<div>
												<form:errors path="testUser.name" cssClass="invalidfield"/>
											</div>
										</td>
									</tr>
									<spring:message var="ldapTestPassword" code="ldap.testUser.password.tooltip" text="The password/credentials to authenticate against LDAP/Active Directory"/>
									<tr title="${ldapTestPassword}">
										<td class="optional" align="right"><spring:message code="login.password" text="Password"/>:</td>
										<td align="left" nowrap>
											<form:password path="testUser.password" size="40" autocomplete="off" />
										</td>
									</tr>
								</table>
							</td>
							<td width="50px" valign="middle" align="center">
								<spring:message var="ldapTestButton" code="ldap.config.test.button" text="Test"/>
								<input type="submit" class="button" value="${ldapTestButton}" name="_test" />
							</td>
						</tr>
					</table>
				</fieldset>
			</td>
		</tr>
	</table>
</div>
</form:form>

<script type="text/javascript">
// add autoresize to all text-areas
$(function() {$('textarea').autosize();})
</script>