class JobOrderOption < ApplicationRecord
  belongs_to :job_order
  belongs_to :job_option

  has_one_attached :option_file
  validates :option_file, file_content_type: {
    allow: ['application/pdf', 'image/svg+xml', 'text/html', 'model/stl', 'application/vnd.ms-pki.stl', 'application/octet-stream', 'text/plain', "model/x.stl-binary", 'model/x.stl-binary', 'text/x.gcode', 'image/vnd.dxf', 'image/x-dxf', 'model/x.stl-ascii'],
    if: -> {option_file.attached?},
  }
end
