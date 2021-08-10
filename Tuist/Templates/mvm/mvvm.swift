import ProjectDescription

var templateAttrs: [Template.Attribute] {
    [
        .required("name"),
        .optional("platform", default: "ios")
    ]
}

let projectPath = "."
let sourcesPath = "Sources/"


let template = Template(
    description: "MVVM Architecture Project",
    attributes: templateAttrs,
    files: [
        .string(path: "README.md", contents: "#\(Template.Attribute.required("name"))"),
        .file(path: projectPath + "/Project.swift", templatePath: "Project.stencil"),
        .file(path: sourcesPath + "/AppDelegate.swift", templatePath: "AppDelegate.swift")
    ]
)
