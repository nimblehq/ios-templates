## Automating Wiki

1. Setup the Github Wiki by following this official guide https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-wiki-pages.
2. Create Personal Access Token with `repo` scope enabled - a bot account is recommended to generate that token https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token.
3. Create a Repository Secret for the above token, the default name for this secret is `NIMBLE_DEV_TOKEN`.