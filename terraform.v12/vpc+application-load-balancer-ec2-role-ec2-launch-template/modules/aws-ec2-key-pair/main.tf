resource "aws_key_pair" "rabbitmq-ec2-key" {
  key_name   = "rabbitmq"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChSTHHBoMAYz5zkl4ctXoEYQ2fJ9cvEX9kN7qyTugTixN8SayZHDUxOiTyDHdgJyjws6SxvirOjC8G+CcmUUs+MqiZ7skkoR07Qzkyu3cY4AuMu0lCPMAF8F25F5RzxO2S2/nwz+ynBJqrBsZJGkjgvpGT5kxqYuM/uPPbiVuTWWDsTMdjsz0XcEUOrzeJ58l53Q+oU0AV3V4NyFgd2Mpyyaz2EdsU6H6i+c2holwNXOjtx08A2SdYEq8XoWDdCGZZunBbeDoubpQFOr7qi75u8c8E9vRl3rKjMoHjCh0mD8mzIcIZBJJKu63YxWvVXPLZRyWLDzbj7FupnB4Ozbx5 MuhammadAsim@DESKTOP-ENE2K87"
}