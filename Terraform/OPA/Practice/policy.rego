package policy
default allow = false

allow if {
  rc := input.resource_changes[_]
  rc.type == "aws_instance"
  rc.change.actions[_] == "create"
  rc.change.after.instance_type == data.allow_vm_type[_]
}