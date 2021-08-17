# ios-template

Our optimized iOS template used in our projects using Xcode Templates

## Requirements

Xcode 12.0

## Wiki

1. [Standard File Organization](https://github.com/nimblehq/ios-templates/wiki/Standard-file-organization)
2. [Project Configurations](https://github.com/nimblehq/ios-templates/wiki/Project-configurations)
3. [Why having project's dependencies](https://github.com/nimblehq/ios-templates/wiki/Why-having-project%27s-dependencies)
4. [Github Actions](https://github.com/nimblehq/ios-templates/wiki/Github-Actions-Templates)

</br>

# Tuist Installation and Documentations

</br>

Run the following command in your terminal for the Tuist installation:

</br>

```bash
bash <(curl -Ls https://install.tuist.io)
```
</br>

Documentation : [Tuist Official Documents](https://docs.tuist.io/tutorial/get-started)

</br>


## How to use

</br>

- Change the project name at line 3 in `Project.swift` 

    ```swift
    let project = Project.project(name: "ios-template")
    ```
    to:
    ```swift
    let project = Project.project(name: "<Your Project Name>")
    ```

- Go navigate to `Tuist` directory and execute the following command:

    ```bash
    tuist generate
    ```
    The command `tuist generate` will generate your project files, folders and two important files `*.xcodeproj` and `*.xcworkspace`.
    
