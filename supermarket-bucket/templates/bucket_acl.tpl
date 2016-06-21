{
"Id": "Policy1459815636248",
"Version": "2012-10-17",
"Statement": [
{
        "Sid": "Stmt1459815634494",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${bucket_name}",
        "Principal": {
                        "AWS": [
                                "arn:aws:iam::${aws_user_arn}:user/${aws_iam_username}"
                        ]
                }
                }
        ]
}
