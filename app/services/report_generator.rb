class ReportGenerator

  def self.new_user_report
    @users = User.in_last_month
    attributes = %w{id name username email gender identity faculty program year_of_study student_id created_at}
    @users.to_csv(*attributes)
  end

  def self.lab_session_report
    @labs = LabSession.in_last_month
    column = []
    column << ["lab_id", "sign_in_time", "user_id", "name", "email", "gender","idenity", "faculty", "program"]
    @labs.each do |lab|
      row = []
      row << lab.id << lab.sign_in_time
      row << lab.user.id << lab.user.name << lab.user.email << lab.user.gender << lab.user.identity << lab.user.faculty << lab.user.program
      column << row
    end
    column << [] << ["Total visitors this month:", @labs.length] << ["# of Unique Visits:", @labs.distinct.count(:user_id)]
    @labs.to_csv(column)
  end

  def self.unique_visitors_report
    @labs = LabSession.in_last_month
    @unique_visits = @labs.select('DISTINCT user_id')
    column = []
    column << ["id" , "name", "username", "email", "gender", "idenity", "faculty", "program" ]
    @unique_visits.each do |lab|
      @visitor = lab.user
      row = []
      row << @visitor.id << @visitor.name << @visitor.username << @visitor.email << @visitor.gender << @visitor.identity << @visitor.faculty << @visitor.program
      column << row
    end
    column << [] << ["# of Unique Visits:", @labs.distinct.count(:user_id)]
    @unique_visits.to_csv(column)
  end

  def self.faculty_frequency_report
      @users = User.in_last_month
      @faculty_freq = @users.group(:faculty).count(:faculty)
      CSV.generate do |csv|
        csv << @faculty_freq.keys
        csv << @faculty_freq.values
      end
  end

  def self.gender_frequesncy_report
    @users = User.in_last_month
    @gender_freq = @users.group(:gender).count(:gender)
    CSV.generate do |csv|
      csv << @gender_freq.keys
      csv << @gender_freq.values
    end
  end

  def self.training_report
    @certifications = Certification.in_last_month

    column = []
    column << ["TRAINING ID", "STUDENT ID", "NAME", "EMAIL", "CERTIFICATION TYPE", "CERTIFICATION DATE", "INSTRUCTOR", "COURSE", "WORKSHOP"]

    @certifications.each do |certification|
      row = []
      row << certification.id << certification.user.student_id << certification.user.name << certification.user.email << certification.training
      row << certification.created_at <<  User.find(certification.training_session.user_id).name << certification.training_session.course
      column << row
    end
    @certifications.to_csv(column)
  end

end
