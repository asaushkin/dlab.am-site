data template_file swagger {
  template = file("${path.module}/api-gateway.yml")

  vars = {
    hello = aws_lambda_function.hello.invoke_arn
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  body = data.template_file.swagger.rendered

  name = "${local.name}-dlab"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(data.template_file.swagger.rendered)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "docint" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = local.name
}

resource "aws_acm_certificate" "domain-cert" {
  domain_name = "api.${local.domain}"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name         = "${local.domain}."
  private_zone = false
}

resource aws_api_gateway_domain_name domain {
  domain_name     = "api.${local.domain}"
  regional_certificate_arn = aws_acm_certificate.domain-cert.arn
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

resource aws_api_gateway_base_path_mapping base_path {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  domain_name = aws_api_gateway_domain_name.domain.domain_name
  stage_name  = aws_api_gateway_stage.docint.stage_name
}

resource aws_route53_record validation {
  for_each = {
    for dvo in aws_acm_certificate.domain-cert.domain_validation_options: dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}


resource aws_route53_record a {
  name    = aws_api_gateway_domain_name.domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain.regional_zone_id
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.domain-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
