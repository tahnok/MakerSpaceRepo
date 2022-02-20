class JobOrder < ApplicationRecord
  belongs_to :user
  belongs_to :job_type
  belongs_to :job_service_group
  belongs_to :job_order_quote, dependent: :destroy
  has_many :job_order_options, dependent: :destroy
  has_many :job_order_statuses, dependent: :destroy
  has_and_belongs_to_many :job_services

  scope :without_drafts, -> {
    joins(:job_order_statuses)
      .where('job_order_statuses.created_at = (SELECT MAX(job_order_statuses.created_at) FROM job_order_statuses WHERE job_order_statuses.job_order_id = job_orders.id)')
      .where.not(job_order_statuses: {job_status: JobStatus::DRAFT})
      .group('job_orders.id')
  }

  has_many_attached :user_files
  validates :user_files, file_content_type: {
    allow: ['application/pdf', 'image/svg+xml', 'text/html', 'model/stl', 'application/vnd.ms-pki.stl', 'application/octet-stream', 'text/plain', "model/x.stl-binary", 'model/x.stl-binary', 'text/x.gcode', 'image/vnd.dxf', 'image/x-dxf', 'model/x.stl-ascii'],
    if: -> { user_files.attached? },
  }

  has_many_attached :staff_files
  validates :staff_files, file_content_type: {
    allow: ['application/pdf', 'image/svg+xml', 'text/html', 'model/stl', 'application/vnd.ms-pki.stl', 'application/octet-stream', 'text/plain', "model/x.stl-binary", 'model/x.stl-binary', 'text/x.gcode', 'image/vnd.dxf', 'image/x-dxf', 'model/x.stl-ascii'],
    if: -> { staff_files.attached? },
  }

  def allow_edit?
    job_order_statuses.last.job_status == JobStatus::DRAFT || job_order_statuses.last.job_status == JobStatus::STAFF_APPROVAL
  end

  def add_options(params)
    success = true

    params.permit!

    params.to_h.each do |key, value|
      if key.include?('options_id_')
        if job_order_options.where(job_option_id: value).present?
          if JobOption.find(value).need_files?
            unless params['options_keep_file_' + value].present?
              job_order_options.where(job_option_id: value).first.option_file.purge
            end
          end
        else
          option = JobOrderOption.create(job_order_id: id, job_option_id: value)
          if params['options_file_' + value].present?
            option.option_file.attach(params['options_file_' + value])
            unless save
              success = true
            end
          end
          job_order_options << option
          unless save
            success = true
          end
        end
      end
    end

    success
  end

  def max_step
    if job_type_id.present? && user_id.present?
      if job_service_group_id.present? && job_services.present? && user_files.attached?
        5
      else
        2
      end
    else
      1
    end
  end
end
