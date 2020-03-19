# ローカル開発で使うユーザー
# このユーザーに権限を付与する
resource "aws_iam_user" "localuser" {
  name = "localuser"
  path = "/personal/"

  tags = {
    Name = "example for AssumeRole"
  }
}

# EC2からS3へアクセスするためにIAM Role
# 本番環境ではEC2にアタッチする
# ローカル環境ではIAMユーザーにAssumeする
module "role_s3_putobject_for_ec2" {
  source = "./iam_role"
  name = "role_s3_putobject_for_ec2"
  service_identifier = "ec2.amazonaws.com"
  iam_identifier = aws_iam_user.localuser.arn
  policy = data.aws_iam_policy_document.example.json
}

data "aws_iam_policy_document" "example" {
  statement {

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.example.arn}/home/&{aws:username}",
    ]

  }
}


# 検証用プライベートバケット
resource "aws_s3_bucket" "example" {
  bucket = "my-assumerole-example"
  acl    = "private"

  tags = {
    Name = "example"
  }
}

output "example_s3_bucket_arn" {
  value = aws_s3_bucket.example.arn
}
