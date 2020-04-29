resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucket-name
  acl    = "private"

  tags = {
    Name = var.tag_key_Name
  }
}

locals {
  s3_origin_id = "S3-${var.bucket-name}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/${var.bucket-name}"

}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3bucket.bucket_regional_domain_name
    origin_id = local.s3_origin_id



    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path

    }

  }

  enabled = true
  is_ipv6_enabled = true
  comment = var.comment
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket = "${var.bucket-name}.s3.amazonaws.com"
    prefix = var.logs_prefix

  }

  aliases = [
    var.domain_aliases]

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern = "/*"
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"]
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers = [
        "Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }

//  # Cache behavior with precedence 1
//  ordered_cache_behavior {
//    path_pattern = "/content/*"
//    allowed_methods = [
//      "GET",
//      "HEAD",
//      "OPTIONS"]
//    cached_methods = [
//      "GET",
//      "HEAD"]
//    target_origin_id = local.s3_origin_id
//
//    forwarded_values {
//      query_string = false
//
//      cookies {
//        forward = "none"
//      }
//    }
//
//    min_ttl = 0
//    default_ttl = 3600
//    max_ttl = 86400
//    compress = true
//    viewer_protocol_policy = "redirect-to-https"
//  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"

    }
  }

  tags = {
    Environment = var.Environment
  }

  viewer_certificate {
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
  }
}