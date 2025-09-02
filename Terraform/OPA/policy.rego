package policy
default allow = false

# helpers
is_admin if {
  input.user.roles[_] == "admin"
}

is_method_allowed if {
  m := upper(input.request.method)
  m == "GET"  # add more if needed
  # OR: m == "GET" or m == "POST"
}

is_path_allowed if {
  startswith(input.request.path, "/public")
}

is_public_get if {
  is_path_allowed
  upper(input.request.method) == "GET"
}


allow if {
  is_admin
  is_method_allowed
  is_path_allowed
}

allow if {
  not is_admin
  is_public_get
}
