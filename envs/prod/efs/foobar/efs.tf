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
  for_each = { for s in data.terraform_remote_state.network_main.outputs.subnet_private : s.id => s }
  file_system_id  = aws_efs_file_system.EFS.id
  subnet_id = each.value.id
  security_groups = [data.terraform_remote_state.network_main.outputs.security_group_efs_foobar_id]
}

resource "aws_efs_access_point" "EFSpoint" {
  file_system_id = aws_efs_file_system.EFS.id
}