/*Creates a key pair */
resource "aws_key_pair" "main" {
    key_name = "${file("${var.aws_pwd}/key_pair_name.txt")}"
    public_key = "${file("${var.aws_pwd}/public_key.txt")}"
}
