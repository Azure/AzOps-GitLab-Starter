# AzOps on GitLab

This repository contains scripts, starter pipelines and instructions on how to get started with AzOps on GitLab.
*Note that the pipelines have only been validated in GitLab cloud.*

Please refer to the main [AzOps repo/wiki]([https://github.com/azure/azops] ) for general documentation around features and configuration options.

## Prerequisites

Before you start, make sure you have followed the steps in the [prerequisites](https://github.com/azure/azops/wiki/prerequisites) article to create required service principal as well as configure the required Azure RBAC permissions for AzOps.

## 1. Import/create project from repository by URL

- Create a new project and select the import project option.
![](./media/gitlab_import_1.png)
- Select to import repository by URL
![](./media/gitlab_import_2.png)
- Add the Git repository URL `https://github.com/azure/AzOps-GitLab-Starter.git` and change project/repository name as per requirements
![](./media/gitlab_import_3.png)
[Reference from GitLab documentation](https://docs.gitlab.com/ee/user/project/import/repo_by_url.html)

## 2. Configure project settings

- Open the newly created project and navigate to Settings -> Merge requests and configure squash commit requirements as well as merge checks
![](./media/gitlab_project_1.png)
- **[Optional]** Depending on your security requirements, you might also want to configure merge request approvals.
![](./media/gitlab_project_2.png)

## 3. Create project access token

- Under Settings -> Access Tokens, create a [project access token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html#create-a-project-access-token).
The token will be used in the pipeline to interact with the GitLab APIs and the repository. Give the token the maintainer role and `api`,`read_api`,`read_repository` and `write_repository` scope permissions.
![](./media/gitlab_token_1.png)

 > Note: Project access tokens are not available with a GitLab trial license.

- Copy the access token value, you will need it in the next step.

## 4. Create required CI/CD variables

- Under Settings -> CI/CD, create the following variables for Azure and GitLab access.
> Note: Do not create any of the variables with the 'Protect variable' flag enabled. As such variables can't be used in merge request scenarios, it will break the validate pipeline.

| Key | Value | Flags |
| --- | ---| ---|
|ARM_CLIENT_ID| Client id from service principal creation| |
|ARM_CLIENT_SECRET| Client secret from service principal creation| Mask variable |
|ARM_SUBSCRIPTION_ID|Subscription ID to use for connecting to Azure| |
|ARM_TENANT_ID| Azure AD tenant ID from service principal creation | |
|CI_CD_TOKEN| Project access token from previous step | Mask variable |

![](./media/gitlab_cicd_variables.png)

## 5. Run initial pull pipeline to bootstrap repository
 - Navigate to CI/CD -> Pipelines -> Run pipeline -> Run pipeline to kick off the initial Pull pipeline that will bootstrap the repository based on your Azure hierarchy and settings.
![](./media/gitlab_run_boostrap_1.png)
![](./media/gitlab_run_boostrap_2.png)
 - After successful Pull, changes to the environment can now be made through PRs by updating or creating new bicep/ARM templates at any scope in the hierarchy.
![](./media/pull_successful_1.png)
![](./media/pull_successful_2.png)


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
