using PkgTemplates
t = Template(;
    user="xzackli",
    authors="Zack Li",
    julia=v"1.5",
    plugins=[
        License(; name="MIT"),
        Git(; manifest=false, ssh=true),
        GitHubActions(; x86=false),
        Codecov(),
        Documenter{GitHubActions}(),
        Develop(),
    ],
)

t("Slow")
