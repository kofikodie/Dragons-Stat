resource "aws_s3_bucket" "dragons-bucket" {
  bucket = "dragons-stat-bucket"

  tags = {
    Name        = "Dragon bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_object" "dragons-stats-json" {
  bucket = aws_s3_bucket.dragons-bucket.id
  key    = "dragonsList"
  source = "dragon_stats_one.json"

  tags = {
    Name        = "Dragons files bucket"
    Environment = "Dev"
  }
}
