# Public Contract

This skill is anchored to the public `Shopify/tophat` repo, not a private internal fork.

## Public `tophatctl` Recipe Schema

When specifying the path to a JSON configuration file for `tophatctl install`, use a JSON array of recipes.

General form:

```json
[
  {
    "artifactProviderID": "<example>",
    "artifactProviderParameters": {},
    "launchArguments": [],
    "platformHint": "ios",
    "destinationHint": "simulator"
  }
]
```

To target a specific device by name and runtime version:

```json
[
  {
    "artifactProviderID": "<example>",
    "artifactProviderParameters": {},
    "launchArguments": [],
    "device": {
      "name": "iPhone 16 Pro",
      "platform": "ios",
      "runtimeVersion": "18.2"
    }
  }
]
```

Relevant public fields:

- `artifactProviderID`
- `artifactProviderParameters`
- `launchArguments`
- `platformHint`
- `destinationHint`
- `device.name`
- `device.platform`
- `device.runtimeVersion`

## Public GitHub Actions Provider

The checked-out public repo includes `TophatGitHubActionsExtension`.

- Provider ID: `gha`
- Provider title: `GitHub Actions`
- Required parameters:
  - `owner`
  - `repo`
  - `artifact_id`

The public implementation downloads an artifact archive from:

```text
GET /repos/{owner}/{repo}/actions/artifacts/{artifact_id}/zip
```

The extension requires a GitHub personal access token in Tophat settings.

For this skill, owner and repo should normally come from the current checkout via `git remote get-url origin` or `git remote -v`. Only ask the user for repository details when the local checkout does not expose a usable GitHub remote.

This skill is intentionally limited to GitHub Actions artifacts through `gh` and Tophat's `gha` provider. Do not add fallback behavior to GitHub MCP, direct REST calls, or other providers.

Use `/Applications/Tophat.app/Contents/MacOS/tophatctl` as the CLI path for this skill.
