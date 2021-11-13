output "domain-name" {
  value = aws_instance.this.public_dns
}

output "application-url" {
  value = "${aws_instance.this.public_dns}/index.php"
}
