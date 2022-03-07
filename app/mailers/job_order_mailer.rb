class JobOrderMailer < ApplicationMailer

  def send_job_submitted(job_order_id)
    JobOrder.where(id: job_order_id).present? ? @job_order = JobOrder.find(job_order_id) : return
    if @job_order.expedited?
      mail(to: 'makerspace@uottawa.ca', subject: 'EXPEDITED: A new Job Order has been submitted', 'Importance': 'high', 'X-Priority': '1')
    else
      mail(to: 'makerspace@uottawa.ca', subject: 'A new Job Order has been submitted')
    end
  end

  def send_job_quote(job_order_id, reminder=false)
    JobOrder.where(id: job_order_id).present? ? @job_order = JobOrder.find(job_order_id) : return
    @reminder = reminder
    mail(to: @job_order.user.email, reply_to: 'makerspace@uottawa.ca', bcc: 'uottawa.makerepo@gmail.com', subject: "Your job ##{@job_order.id} (#{@job_order.user_files.first.filename}) has been #{"re-" if @job_order.job_order_statuses.where(job_status: JobStatus::USER_APPROVAL).count > 1}approved!")
  end

  def send_job_declined(job_order_id)
    JobOrder.where(id: job_order_id).present? ? @job_order = JobOrder.find(job_order_id) : return
    mail(to: @job_order.user.email, reply_to: 'makerspace@uottawa.ca', bcc: 'uottawa.makerepo@gmail.com', subject: "Your job ##{@job_order.id} (#{@job_order.user_files.first.filename}) has been declined")
  end

  def send_job_user_approval(job_order_id)
    JobOrder.where(id: job_order_id).present? ? @job_order = JobOrder.find(job_order_id) : return
    if @job_order.expedited?
      mail(to: 'makerspace@uottawa.ca', subject: 'EXPEDITED: A user has approved a Job Order', 'Importance': 'high', 'X-Priority': '1')
    else
      mail(to: 'makerspace@uottawa.ca', subject: 'A user has approved a Job Order')
    end
  end

  def send_job_processed(job_order_id)
    JobOrder.where(id: job_order_id).present? ? @job_order = JobOrder.find(job_order_id) : return
    mail(to: @job_order.user.email, reply_to: 'makerspace@uottawa.ca', bcc: 'uottawa.makerepo@gmail.com', subject: "Your Job Order ##{@job_order.id} is available for pickup")
  end

  # def send_print_reminder(email, id)
  #   mail(to: email, subject: "Reminder for your print order ##{id}")
  # end
end
