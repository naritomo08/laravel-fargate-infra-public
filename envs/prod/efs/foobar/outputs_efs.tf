output "security_group_efs_foobar_id" {
  value = aws_security_group.efs_foobar.id
}

output "efs_id" {
  value = aws_efs_file_system.EFS.id
}

output "efs_point_id" {
  value = aws_efs_access_point.EFSpoint.id
}
