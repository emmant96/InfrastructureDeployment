provider "aws" {
  region = "us-east-1"
  profile = "sule" 

}


resource "aws_s3_bucket" "main" {
  bucket = "sulebucket"
  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "versioning"{
  bucket = aws_s3_bucket.main.id    # Reference the S3 bucket created above
  versioning_configuration {
    status = "Enabled"
  }
  
}