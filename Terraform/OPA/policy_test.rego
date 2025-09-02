package policy_test

import data.policy.allow

test_allow_is_false_by_default if {
    not allow
}

test_allow_if_admin if {
    allow with input as {
        "user" : {
            "role" : ["admin"]
        }
    }
}

test_deny_if_not_admin if {
    not allow with input as {
        "user" : {
            "role" : ["QA"]
        }
    }
    not allow with input as {
        "user" : {
            "role" : ["dev"] 
        }
    }
}

test_allow_if_get_on_public if {
    allow with input as {
        "request" : {
            "method" : "GET",
            "path" : "/public"
        }
    }
    allow with input as {
        "request" : {
            "method" : "GET",
            "path" : "/public/data"
        }
    }
}

test_deny_if_get_on_public if {
    not allow with input as {
        "request" : {
            "method" : "PUT",
            "path" : "/public"
        }
    }
    not allow with input as {
        "request" : {
            "method" : "GET",
            "path" : "/private"
        }
    }
}