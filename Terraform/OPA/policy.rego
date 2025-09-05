package policy

default allow = false

allow if {
    input.user.role[_] == "admin"
}


allow if {
    startswith(input.request.path, "/public")
    input.request.method == "GET"
} 