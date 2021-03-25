## output webserver and dbserver address
output "db_server_address" {
  value = aws_db_instance.omopfhirdb.address
}

output "db_endpoint" {
  value = aws_db_instance.omopfhirdb.endpoint
}
  
output "web_server_address" {
  value = aws_instance.omopfhir.public_dns
}
  
output "web_server_ip" {
  value = aws_instance.omopfhir.public_ip
}
