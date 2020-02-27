/*Create a key pair*/
resource "aws_key_pair" "main" {

    key_name = "${file("${var.aws_pwd}/key_pair_name.txt")}" /*Key name of the created key pair*/
    public_key = "${file("${var.aws_pwd}/public_key.txt")}" /*Public key of the created key pair*/
}
