Paperclip::Attachment.default_options[:s3_host_name] = 's3-us-west-2.amazonaws.com'
Paperclip.options[:content_type_mappings] = {
  :stl => ["text/plain", "application/octet-stream"],
  :gcode => "text/plain",
  :fzz => "application/zip",
  :ino => "text/plain",
  :slpt => "text/plain",
  :aix => "application/zip",
  :sldprt => "application/vnd.ms-office",
  :x3g => ["application/x3g", "application/octet-stream"]
}
