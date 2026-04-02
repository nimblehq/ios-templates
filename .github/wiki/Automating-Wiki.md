## Automating Wiki

1. Setup the GitHub Wiki by following this [official guide](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-wiki-pages).
2. Create the first wiki page manually on GitHub so the wiki repository is initialized.
3. Create a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with `repo` scope enabled. The token should be generated from the same GitHub account used by the workflow, which is currently `team-nimblehq`.
4. Create a [repository secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) with that token. The workflow expects the secret to be named `NIMBLE_DEV_TOKEN`.
5. Update files inside `.github/wiki/` and push them to `develop`, `main`, or `master`. The workflow at `.github/workflows/publish_docs_to_wiki.yml` will automatically sync those changes to the GitHub wiki. You can also run it manually from the Actions tab with `workflow_dispatch`.
