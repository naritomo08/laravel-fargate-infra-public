#--------------------------------------
# EFSの作成
#----------------------------------------

resource "aws_efs_file_system" "EFS" {

  encrypted  = "true"

  tags = {
    Name = "${local.system_name}-${local.env_name}-${local.service_name}"
  }
}

#マウントターゲットの作成
resource "aws_efs_mount_target" "EFS-target" {
  for_each = { for s in aws_subnet.private : s.id => s }
  file_system_id  = aws_efs_file_system.EFS.id
  subnet_id = each.value.id
  security_groups = [aws_security_group.efs_foobar.id]
}

resource "aws_efs_access_point" "EFSpoint" {
  file_system_id = aws_efs_file_system.EFS.id
}