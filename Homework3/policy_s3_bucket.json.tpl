{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow access for specific role",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${role_arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "${s3_bucket_arn}",
                "${s3_bucket_arn}/*"
            ]
        }
    ]
}