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

- Copy the whole directory `Tuist` and its content to one directory up of your project's directory.

    *Assume your future project in `Projects` directory*

    ```
    Projects
    |-- Tuist
        |-- Templates
            |-- mvvm
                |-- AppDelegate.swift
                |-- mvvm.swift
                |-- Project.stencil
    |-- <Your future project's directory>
    └── ...
    ```
</br>

- Navigate to your future project's directory and run

    ```bash
    tuist init -t mvvm --name <Name of project>    
    ```

</br>

- After init command finished, run the following command

    ```bash
    tuist generate
    ```
    The command `tuist generate` will generate your project files, folders and two important files `*.xcodeproj` and `*.xcworkspace`.
    
