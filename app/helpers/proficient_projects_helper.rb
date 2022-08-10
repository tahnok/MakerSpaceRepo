# frozen_string_literal: true

module ProficientProjectsHelper
  def return_hover_and_text_colors(level)
    case level
    when "Beginner"
      "w3-hover-border-light-green w3-hover-text-light-green"
    when "Intermediate"
      "w3-hover-border-yellow w3-hover-text-yellow"
    when "Advanced"
      "w3-hover-border-red w3-hover-text-red"
    end
  end

  def return_border_color(level)
    case level
    when "Beginner"
      "w3-border-light-green"
    when "Intermediate"
      "w3-border-yellow"
    when "Advanced"
      "w3-border-red"
    end
  end

  def training_status(training_id, user_id)
    user = User.find(user_id)
    level =
      Certification
        .joins(:user, :training_session)
        .where(training_sessions: { training_id: training_id }, user: user)
        .pluck(:level)
    div =
      Proc.new do |color, level|
        "<span class='float-end' style='color: #{color}'>#{level}</span>"
      end
    if level.include?("Advanced")
      div.call("red", "🦅 Advanced")
    elsif level.include?("Intermediate")
      div.call("#969600", "🦩 Intermediate")
    elsif level.include?("Beginner")
      div.call("green", "🦆 Beginner")
    else
      training = Training.find(training_id)
      learning_modules_completed =
        training
          .learning_modules
          .joins(:learning_module_tracks)
          .where(learning_module_tracks: { user: user, status: "Completed" })
          .present?
      proficient_projects_completed =
        training
          .proficient_projects
          .where(id: user.order_items.awarded.pluck(:proficient_project_id))
          .present?
      if learning_modules_completed || proficient_projects_completed
        div.call("black", "🐥 Newbie")
      else
        div.call("gray", "🐣 Not Started")
      end
    end
  end

  def return_levels(training_id, user_id)
    current_status = ProficientProject.training_status(training_id, user_id)
    case current_status
    when "Beginner"
      ["Beginner"]
    when "Intermediate"
      %w[Beginner Intermediate]
    when "Advanced"
      %w[Beginner Intermediate Advanced]
    end
  end
end
