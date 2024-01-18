output "efs_id" {
  value = aws_efs_file_system.EFS.id
}

output "efs_point_id" {
  value = aws_efs_access_point.EFSpoint.id
}
