resource "aws_security_group" "efs_foobar" {
  name   = "${aws_vpc.this.tags.Name}-efs-foobar"
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-efs-foobar"
  }

  # インバウンドルール
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}