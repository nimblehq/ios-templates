## Automating Wiki

1. Setup the Github Wiki by following this [official guide](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-wiki-pages).
2. Create [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token.) with `repo` scope enabled - a bot account is recommended to generate that token.
3. Create a [Repository Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) with the above token, the default name for this secret is `NIMBLE_DEV_TOKEN`.