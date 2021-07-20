data "aws_iam_policy" "pvre_policy" {
    arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// ec2
resource "aws_iam_role_policy_attachment" "pvre-attach-ec2" {
  role       = aws_iam_role.bigdata_ec2_service_role.name
  policy_arn = data.aws_iam_policy.pvre_policy.arn
}

// emr
resource "aws_iam_role_policy_attachment" "pvre-attach-emr" {
  role       = aws_iam_role.iam_emr_profile_role.name
  policy_arn = data.aws_iam_policy.pvre_policy.arn
}



