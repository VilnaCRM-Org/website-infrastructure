data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "iam_policy_doc" {
  statement {
    sid    = "IAMReadOnlyPolicy"
    effect = "Allow"
    actions = [
      "iam:ListRoleTags",
      "iam:ListServerCertificates",
      "iam:ListPoliciesGrantingServiceAccess",
      "iam:ListInstanceProfileTags",
      "iam:ListServiceSpecificCredentials",
      "iam:ListMFADevices",
      "iam:ListSigningCertificates",
      "iam:ListVirtualMFADevices",
      "iam:ListInstanceProfilesForRole",
      "iam:ListSSHPublicKeys",
      "iam:ListAttachedRolePolicies",
      "iam:ListOpenIDConnectProviderTags",
      "iam:ListAttachedUserPolicies",
      "iam:ListSAMLProviderTags",
      "iam:ListAttachedGroupPolicies",
      "iam:ListPolicyTags",
      "iam:ListRolePolicies",
      "iam:ListAccessKeys",
      "iam:ListPolicies",
      "iam:ListSAMLProviders",
      "iam:ListCloudFrontPublicKeys",
      "iam:ListGroupPolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListRoles",
      "iam:ListUserPolicies",
      "iam:ListInstanceProfiles",
      "iam:ListPolicyVersions",
      "iam:ListOpenIDConnectProviders",
      "iam:ListGroupsForUser",
      "iam:ListServerCertificateTags",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListGroups",
      "iam:ListMFADeviceTags",
      "iam:ListSTSRegionalEndpointsStatus",
      "iam:GetLoginProfile",
      "iam:ListUserTags",
      "iam:GetAccountSummary",
      "iam:GenerateCredentialReport",
      "iam:GetPolicyVersion",
      "iam:GetAccountPasswordPolicy",
      "iam:GetMFADevice",
      "iam:GetServiceLastAccessedDetailsWithEntities",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:GetServiceLastAccessedDetails",
      "iam:GetGroup",
      "iam:GetContextKeysForPrincipalPolicy",
      "iam:GetOrganizationsAccessReport",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "iam:SimulateCustomPolicy",
      "iam:SimulatePrincipalPolicy",
      "iam:GenerateOrganizationsAccessReport",
      "iam:GetAccountEmailAddress",
      "iam:GetCloudFrontPublicKey",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetCredentialReport",
      "iam:GetSAMLProvider",
      "iam:GetServerCertificate",
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:GetPolicy",
      "iam:GetAccessKeyLastUsed",
      "iam:GetSSHPublicKey",
      "iam:GetContextKeysForCustomPolicy",
      "iam:GetUserPolicy",
      "iam:GetAccountName",
      "iam:GetGroupPolicy",
      "iam:GetUser",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:*"
    ]
  }
  statement {
    sid    = "IAMWritePolicy"
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:UpdateUser",
      "iam:UpdateAccessKey",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
      "iam:ChangePassword",
      "iam:CreatePolicy",
      "iam:PutUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:AttachUserPolicy",
      "iam:DeletePolicy",
      "iam:DetachGroupPolicy",
      "iam:DeleteGroupPolicy",
      "iam:DetachUserPolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:PutGroupPolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:*"
    ]
  }
  statement {
    sid    = "IAMGroupActionsPolicy"
    effect = "Allow"
    actions = [
      "iam:CreateGroup",
      "iam:AttachGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:AddUserToGroup",
      "iam:RemoveUserFromGroup",
      "iam:UpdateGroup",
      "iam:DeleteGroup"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:group/backend-users/backend-users",
      "arn:aws:iam::${local.account_id}:group/devops-users/devops-users",
      "arn:aws:iam::${local.account_id}:group/qa-users/qa-users",
      "arn:aws:iam::${local.account_id}:group/frontend-users/frontend-users",
      "arn:aws:iam::${local.account_id}:group/admin-users/admin-users"
    ]
  }
}
