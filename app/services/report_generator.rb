# frozen_string_literal: true

class ReportGenerator
  require "axlsx"
  # region Date Range Reports

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_visitors_report(start_date, end_date)
    spreadsheet = Axlsx::Package.new

    space_details = get_visitors(start_date, end_date)

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        merge_cell = sheet.styles.add_style alignment: { vertical: :center }

        header(sheet, "Visitors", start_date, end_date)

        # region Overview
        title(sheet, "Overview")
        table_header(
          sheet,
          ["Space", "Distinct User.unscopeds", "", "Total Visits"]
        )

        space_details[:spaces].each do |space_name, space|
          sheet.add_row [space_name, space[:unique], "", space[:total]]
        end

        sheet.add_row # spacing

        table_header(
          sheet,
          ["Identity", "Distinct User.unscopeds", "", "Total Visits"]
        )

        space_details[:identities].each do |identity_name, space|
          sheet.add_row [identity_name, space[:unique], "", space[:total]]
        end

        sheet.add_row # spacing

        table_header(
          sheet,
          ["Faculty", "Distinct User.unscopeds", "", "Total Visits"]
        )

        space_details[:faculties].each do |faculty_name, space|
          sheet.add_row [faculty_name, space[:unique], "", space[:total]]
        end

        sheet.add_row # spacing

        table_header(
          sheet,
          [
            "Identity",
            "Distinct User.unscopeds",
            "",
            "Total Visits",
            "",
            "Faculty"
          ]
        )
        space_details[:identities].each do |identity_name, identity|
          start_index = sheet.rows.last.row_index + 1

          identity[:faculties].each do |faculty_name, faculty|
            sheet.add_row [
                            identity_name,
                            faculty[:unique],
                            "",
                            faculty[:total],
                            "",
                            faculty_name
                          ],
                          style: [merge_cell]
          end

          end_index = sheet.rows.last.row_index

          sheet.merge_cells("A#{start_index + 1}:A#{end_index + 1}")
        end

        sheet.add_row # spacing
        # endregion
      end

    # region Per-space details
    space_details[:spaces].each do |space_name, space_detail|
      spreadsheet
        .workbook
        .add_worksheet(name: space_name) do |sheet|
          title(sheet, space_name)

          faculty_hash = {}
          merge_cell = sheet.styles.add_style alignment: { vertical: :center }

          table_header(
            sheet,
            ["Identity", "Distinct User.unscopeds", "", "Total Visits"]
          )
          space_detail[:identities].each do |identity_name, identity|
            sheet.add_row [
                            identity_name,
                            identity[:unique],
                            "",
                            identity[:total]
                          ]
          end

          sheet.add_row # spacing

          table_header(
            sheet,
            ["Faculty", "Distinct User.unscopeds", "", "Total Visits"]
          )
          space_detail[:faculties].each do |faculty_name, faculty|
            sheet.add_row [faculty_name, faculty[:unique], "", faculty[:total]]
          end

          sheet.add_row # spacing

          table_header(
            sheet,
            [
              "Identity",
              "Distinct User.unscopeds",
              "",
              "Total Visits",
              "",
              "Faculty"
            ]
          )
          space_detail[:identities].each do |identity_name, identity|
            start_index = sheet.rows.last.row_index + 1

            identity[:faculties].each do |faculty_name, faculty|
              sheet.add_row [
                              identity_name,
                              faculty[:unique],
                              "",
                              faculty[:total],
                              "",
                              faculty_name
                            ],
                            style: [merge_cell]
              if faculty_hash[faculty_name].blank?
                faculty_hash[faculty_name] = faculty[:unique]
              else
                faculty_hash[faculty_name] = faculty[:unique] +
                  faculty_hash[faculty_name]
              end
            end

            end_index = sheet.rows.last.row_index

            sheet.merge_cells("A#{start_index + 1}:A#{end_index + 1}")
          end

          sheet.add_row # spacing

          table_header(
            sheet,
            ["Gender", "Distinct User.unscopeds", "", "Total Visits"]
          )
          space_detail[:genders].each do |gender_name, gender|
            sheet.add_row [gender_name, gender[:unique], "", gender[:total]]
          end

          space = sheet.add_row # spacing

          male =
            (
              if space_detail[:genders]["Male"].present?
                space_detail[:genders]["Male"][:unique]
              else
                0
              end
            )
          female =
            (
              if space_detail[:genders]["Female"].present?
                space_detail[:genders]["Female"][:unique]
              else
                0
              end
            )
          other =
            (
              if space_detail[:genders]["Other"].present?
                space_detail[:genders]["Other"][:unique]
              else
                0
              end
            )
          prefer_not =
            (
              if space_detail[:genders]["Prefer not to specify"].present?
                space_detail[:genders]["Prefer not to specify"][:unique]
              else
                0
              end
            )
          final_other = other + prefer_not

          sheet.add_chart(
            Axlsx::Pie3DChart,
            rot_x: 90,
            start_at: "A#{space.row_index + 2}",
            end_at: "E#{space.row_index + 14}",
            grouping: :stacked,
            show_legend: true,
            title: "Gender of unique users"
          ) do |chart|
            chart.add_series data: [male, female, final_other],
                             labels: [
                               "Male",
                               "Female",
                               "Other/Prefer not to specify"
                             ],
                             colors: %w[1FC3AA 8624F5 A8A8A8 A8A8A8]
            chart.add_series data: [male, female, final_other],
                             labels: [
                               "Male",
                               "Female",
                               "Other/Prefer not to specify"
                             ],
                             colors: %w[FFFF00 FFFF00 FFFF00]
            chart.d_lbls.show_percent = true
            chart.d_lbls.d_lbl_pos = :bestFit
          end

          sheet.add_chart(
            Axlsx::Pie3DChart,
            rot_x: 90,
            start_at: "A#{space.row_index + 16}",
            end_at: "E#{space.row_index + 28}",
            grouping: :stacked,
            show_legend: true,
            title: "Faculty of unique users"
          ) do |chart2|
            chart2.add_series data: faculty_hash.values,
                              labels: faculty_hash.keys,
                              colors: %w[
                                416145
                                33EEDD
                                860F48
                                88E615
                                6346F0
                                F5E1FE
                                E9A55B
                                A2F8FA
                                260AD2
                                12032E
                                755025
                                723634
                              ]
            chart2.add_series data: faculty_hash.values,
                              labels: faculty_hash.keys,
                              colors: %w[
                                416145
                                33EEDD
                                860F48
                                88E615
                                6346F0
                                F5E1FE
                                E9A55B
                                A2F8FA
                                260AD2
                                12032E
                                755025
                                723634
                              ]
            chart2.d_lbls.show_percent = true
            chart2.d_lbls.d_lbl_pos = :bestFit
          end
        end
    end
    # endregion

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_trainings_report(start_date, end_date)
    trainings = get_trainings(start_date, end_date)

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "Trainings")

        sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
        sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
        sheet.add_row # spacing

        table_header(sheet, ["Training", "Session Count", "Total Attendees"])

        trainings[:training_types].each do |_, training_type|
          sheet.add_row [
                          training_type[:name],
                          training_type[:count],
                          training_type[:total_attendees]
                        ]
        end

        sheet.add_row # spacing

        table_header(
          sheet,
          [
            "Training",
            "Level",
            "Course",
            "Instructor",
            "Date",
            "Facility",
            "Attendee Count"
          ]
        )

        trainings[:training_sessions].each do |row|
          training = Training.find(row[:training_id])
          color =
            if training.skill_id.present?
              if training.skill.name == "Machine Shop Training"
                { bg_color: "ed7d31" }
              elsif training.skill.name == "Technology Trainings"
                { bg_color: "70ad47" }
              elsif training.skill.name == "CEED Trainings"
                { bg_color: "ffc000" }
              else
                {}
              end
            else
              {}
            end
          style = sheet.styles.add_style(color)

          sheet.add_row [
                          row[:training_name],
                          row[:training_level],
                          row[:course_name],
                          row[:instructor_name],
                          row[:date].localtime.strftime("%Y-%m-%d %H:%M"),
                          row[:facility],
                          row[:attendee_count]
                        ],
                        style: [style]
        end
      end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_certifications_report(start_date, end_date)
    spreadsheet = Axlsx::Package.new

    ["MTC", "Makerspace", "Makerlab 119", "Makerlab 121"].each do |space|
      if Space.find_by(name: space).present?
        spreadsheet
          .workbook
          .add_worksheet(name: space) do |sheet|
            space_id = Space.find_by_name(space).id

            header(sheet, "Certifications in #{space}", start_date, end_date)

            header = ["Certification"]
            header2 = [""]
            CourseName.all.each do |course|
              header << (course.name == "no course" ? "Open" : course.name)
              header << ""
              header2.push("# sessions", "# of attendees")
            end

            header.push("Total Sessions", "Total Certifications")

            table_header(sheet, header)
            table_header(sheet, header2)
            final_total_sessions = {}
            final_total_certifications = {}

            Training
              .all
              .joins(:spaces_trainings)
              .where(spaces_trainings: { space_id: space_id })
              .each do |training|
                training_sessions =
                  TrainingSession.where(
                    training_id: training.id,
                    space_id: space_id,
                    created_at: start_date..end_date
                  )
                training_row = [training.name]
                total_certifications = 0

                CourseName.all.each do |course|
                  if final_total_sessions[course.name].nil?
                    final_total_sessions[course.name] = 0
                    final_total_certifications[course.name] = 0
                  end

                  user_count = 0
                  course_training_session =
                    training_sessions.where(course_name_id: course.id)
                  course_training_session.each do |session|
                    user_count += session.users.count
                  end
                  training_row << course_training_session.count
                  training_row << user_count
                  total_certifications += user_count
                  final_total_sessions[
                    course.name
                  ] += course_training_session.count
                  final_total_certifications[course.name] += user_count
                end

                training_row << training_sessions.count
                training_row << total_certifications
                final_total_sessions["total"] = 0 if final_total_sessions[
                  "total"
                ].nil?
                final_total_certifications[
                  "total"
                ] = 0 if final_total_certifications["total"].nil?
                final_total_sessions["total"] += training_sessions.count
                final_total_certifications["total"] += total_certifications

                color =
                  if training.skill_id.present?
                    if training.skill.name == "Machine Shop Training"
                      { bg_color: "ed7d31" }
                    elsif training.skill..name == "Technology Trainings"
                      { bg_color: "70ad47" }
                    elsif training.skill.name == "CEED Trainings"
                      { bg_color: "ffc000" }
                    else
                      {}
                    end
                  else
                    {}
                  end
                style = sheet.styles.add_style(color)
                sheet.add_row training_row, style: [style]
              end

            final_s = ["Total # sessions"]
            final_c = ["Total # certifications", ""]
            final_total_sessions.values.each { |value| final_s.push(value, "") }
            final_total_certifications.values.each do |value|
              final_c.push(value, "")
            end
            sheet.add_row final_s
            sheet.add_row final_c

            sheet.add_row # spacing

            # Summary
            summary_total = { "total" => 0 }
            certification_summary = {}

            # Header
            header_summary = [""]
            CourseName.all.each do |course|
              header_summary << if course.name == "no course"
                "Open"
              else
                course.name
              end
            end
            header_summary << "Total"
            sheet.add_row header_summary

            Training
              .all
              .joins(:spaces_trainings)
              .where(spaces_trainings: { space_id: space_id })
              .each do |training|
                training_sessions =
                  TrainingSession.where(
                    training_id: training.id,
                    space_id: space_id,
                    created_at: start_date..end_date
                  )
                training_row = [training.name]
                total_certifications = 0

                # One row
                CourseName.all.each do |course|
                  if certification_summary[course.name].nil?
                    certification_summary[course.name] = 0
                    summary_total[course.name] = 0
                  end

                  user_count = 0
                  training_sessions
                    .where(course_name_id: course.id)
                    .each { |session| user_count += session.users.count }

                  training_row << user_count
                  total_certifications += user_count
                  certification_summary[course.name] += user_count
                  summary_total[course.name] += user_count
                end

                training_row << total_certifications
                certification_summary["total"] = 0 if certification_summary[
                  "total"
                ].nil?
                certification_summary["total"] += total_certifications
                summary_total["total"] = summary_total["total"] +
                  total_certifications

                sheet.add_row training_row
              end

            # Adding the summary
            final_summary = ["Total"]
            final = summary_total["total"].to_i # Adding the final number last
            summary_total.delete("total")
            summary_total.values.each { |value| final_summary.push(value) }

            final_summary << final

            sheet.add_row final_summary
          end
      end
    end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_new_users_report(start_date, end_date)
    users = User.unscoped.between_dates_picked(start_date, end_date)

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "New User.unscopeds")

        sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
        sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
        sheet.add_row # spacing

        sheet.add_row # spacing
        sheet.add_row # spacing

        male = users.where(gender: "Male").count
        female = users.where(gender: "Female").count
        other = users.where(gender: "Other").count
        prefer_not = users.where(gender: "Prefer not to specify").count
        final_other = other + prefer_not

        sheet.add_chart(
          Axlsx::Pie3DChart,
          rot_x: 90,
          start_at: "D1",
          end_at: "G13",
          grouping: :stacked,
          show_legend: true,
          title: "Gender of new users"
        ) do |chart|
          chart.add_series data: [male, female, final_other],
                           labels: [
                             "Male",
                             "Female",
                             "Other/Prefer not to specify"
                           ],
                           colors: %w[1FC3AA 8624F5 A8A8A8 A8A8A8]
          chart.add_series data: [male, female, final_other],
                           labels: [
                             "Male",
                             "Female",
                             "Other/Prefer not to specify"
                           ],
                           colors: %w[FFFF00 FFFF00 FFFF00]
          chart.d_lbls.show_percent = true
          chart.d_lbls.d_lbl_pos = :bestFit
        end

        sheet.add_row # spacing
        sheet.add_row # spacing
        sheet.add_row # spacing
        sheet.add_row # spacing

        title(sheet, "Overview")

        groups = users.group_by(&:identity)

        groups.each do |group_name, values|
          sheet.add_row [group_name, values.length]
        end

        sheet.add_row # spacing

        table_header(
          sheet,
          [
            "Name",
            "User.unscopedname",
            "Email",
            "Gender",
            "Identity",
            "Faculty",
            "Year of Study",
            "Student ID",
            "Joined on"
          ]
        )

        users.each do |user|
          sheet.add_row [
                          user.name,
                          user.username,
                          user.email,
                          user.gender,
                          user.identity,
                          user.faculty,
                          user.year_of_study,
                          user.student_id,
                          user.created_at.localtime.strftime("%Y-%m-%d %H:%M")
                        ]
        end
      end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_training_attendees_report(start_date, end_date)
    certifications =
      Certification
        .includes({ training_session: %i[user training space] }, :user)
        .where("created_at" => start_date..end_date)
        .order(
          "spaces.name",
          "training_sessions.created_at",
          "users_certifications.name"
        )
        .group_by { |item| item.training_session.space.id }

    spreadsheet = Axlsx::Package.new

    certifications.each do |_space, space_certifications|
      spreadsheet
        .workbook
        .add_worksheet(
          name:
            "Report - #{space_certifications[0].training_session.space.name}"
        ) do |sheet|
          merge_cell = sheet.styles.add_style alignment: { vertical: :center }

          title(
            sheet,
            "Training Attendees - #{space_certifications[0].training_session.space.name}"
          )

          sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
          sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
          sheet.add_row # spacing

          table_header(
            sheet,
            [
              "Student ID",
              "Name",
              "Email Address",
              "Certification Type",
              "Certification Date",
              "Instructor",
              "Course",
              "Facility"
            ]
          )

          start_index = sheet.rows.last.row_index + 2
          last_training_session_id = nil

          space_certifications.each do |certification|
            if (
                 last_training_session_id != certification.training_session.id
               ) && !last_training_session_id.nil?
              end_index = sheet.rows.last.row_index + 1

              if start_index < end_index
                sheet.merge_cells("A#{start_index}:A#{end_index}")
                sheet.merge_cells("B#{start_index}:B#{end_index}")
                sheet.merge_cells("C#{start_index}:C#{end_index}")
                sheet.merge_cells("D#{start_index}:D#{end_index}")
                sheet.merge_cells("E#{start_index}:E#{end_index}")
                sheet.merge_cells("F#{start_index}:F#{end_index}")
                sheet.merge_cells("G#{start_index}:G#{end_index}")
                sheet.merge_cells("H#{start_index}:H#{end_index}")
              end

              start_index = sheet.rows.last.row_index + 2
            end

            sheet.add_row [
                            certification.user.student_id,
                            certification.user.name,
                            certification.user.email,
                            certification.training_session.training.name,
                            certification.training_session.created_at.strftime(
                              "%Y-%m-%d %H:%M"
                            ),
                            certification.training_session.user.name,
                            certification.training_session.course,
                            certification.training_session.space.name
                          ],
                          style: [
                            merge_cell,
                            merge_cell,
                            merge_cell,
                            merge_cell,
                            merge_cell
                          ]

            last_training_session_id = certification.training_session.id
          end

          sheet.add_row #spacing

          month_average = ["Month average of attendees per sessions"]
          month_header = ["Month"]

          (start_date.to_datetime..end_date.to_datetime)
            .select { |date| date.day == 1 }
            .map do |date|
              month_header << date.strftime("%B")
              month_certifications =
                space_certifications.select do |cert|
                  cert.created_at.between?(
                    date.beginning_of_month,
                    date.end_of_month
                  )
                end
              average =
                if month_certifications.count.zero? ||
                     month_certifications
                       .pluck(:training_session_id)
                       .uniq
                       .count
                       .zero?
                  0
                else
                  month_certifications.count /
                    month_certifications.pluck(:training_session_id).uniq.count
                end
              month_average << average
            end

          table_header(sheet, month_header)
          sheet.add_row month_average
          sheet.add_row #spacing

          week_average = ["Week average of attendees per sessions"]
          week_header = ["Week"]

          (start_date.to_datetime.to_i..end_date.to_datetime.to_i).step(
            1.week
          ) do |date|
            week_header << "#{Time.at(date).beginning_of_week.strftime("%Y-%m-%d")} to #{Time.at(date).end_of_week.strftime("%Y-%m-%d")}"
            week_certifications =
              space_certifications.select do |cert|
                cert.created_at.between?(
                  Time.at(date).beginning_of_week,
                  Time.at(date).end_of_week
                )
              end
            average =
              if week_certifications.count.zero? ||
                   week_certifications
                     .pluck(:training_session_id)
                     .uniq
                     .count
                     .zero?
                0
              else
                week_certifications.count /
                  week_certifications.pluck(:training_session_id).uniq.count
              end
            week_average << average
          end

          table_header(sheet, week_header)
          sheet.add_row week_average
          sheet.add_row #spacing
        end
    end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_new_projects_report(start_date, end_date)
    repositories =
      Repository.where("created_at" => start_date..end_date).includes(
        :users,
        :categories
      )

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "New Projects")

        sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
        sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
        sheet.add_row # spacing

        table_header(sheet, %w[Title User.unscopeds URL Categories])

        repositories.each do |repository|
          sheet.add_row [
                          repository.title,
                          repository.users.map(&:name).join(", "),
                          Rails.application.routes.url_helpers.repository_path(
                            id: repository.id,
                            user_username: repository.user_username
                          ),
                          repository.categories.map(&:name).join(", ")
                        ]
        end
      end

    spreadsheet
  end

  # @param [Integer] id
  def self.generate_training_session_report(id)
    session =
      TrainingSession.includes(:user, :users, :space, :training).find(id)

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "Training Session")

        sheet.add_row ["Training Type", session.training.name]
        sheet.add_row ["Location", session.space.name]
        sheet.add_row ["Date", session.created_at.strftime("%Y-%m-%d %H:%M")]
        sheet.add_row ["Instructor", session.user.name]
        sheet.add_row ["Course", session.course]
        sheet.add_row ["Number of Trainees", session.users.length]

        sheet.add_row # spacing

        table_header(sheet, ["Name", "Email", "Student Number"])

        session.users.each do |student|
          sheet.add_row [student.name, student.email, student.student_id]
        end
      end

    spreadsheet
  end

  # @param [Integer] id
  def self.generate_space_present_users_report(id)
    lab_sessions =
      LabSession
        .unscoped
        .includes(:user)
        .joins(:user)
        .where("space_id" => id)
        .where("sign_in_time < ?", DateTime.now)
        .where("sign_out_time > ?", DateTime.now)

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "Present User.unscopeds")

        sheet.add_row ["Date", DateTime.now.strftime("%Y-%m-%d %H:%M:%S")]

        sheet.add_row # spacing

        table_header(sheet, ["Name", "Email", "Student Number"])

        lab_sessions.each do |lab_session|
          sheet.add_row [
                          lab_session.user.name,
                          lab_session.user.email,
                          lab_session.user.student_id
                        ]
        end
      end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_peak_hours_report(start_date, end_date)
    ls = LabSession.unscoped.arel_table

    result =
      ActiveRecord::Base.connection.exec_query(
        ls
          .project(
            ls["sign_in_time"].extract("YEAR").as("year"),
            ls["sign_in_time"].extract("MONTH").as("month"),
            ls["sign_in_time"].extract("DAY").as("day"),
            ls["sign_in_time"].extract("HOUR").as("hour"),
            Arel.star.count.as("total_visits")
          )
          .from(ls)
          .where(ls["sign_in_time"].between(start_date..end_date))
          .group("year", "month", "day", "hour")
          .to_sql
      )

    visits_by_hour = {}
    min_hour = 23
    max_hour = 0

    result.each do |row|
      year = row["year"].to_i
      month = row["month"].to_i
      day = row["day"].to_i
      hour = row["hour"].to_i
      total_visits = row["total_visits"].to_i

      date = DateTime.new(year, month, day, hour).localtime

      min_hour = [min_hour, date.hour].min
      max_hour = [max_hour, date.hour].max

      visits_by_hour[date.year] = {} unless visits_by_hour[date.year]

      visits_by_hour[date.year][date.month] = {} unless visits_by_hour[
        date.year
      ][
        date.month
      ]

      visits_by_hour[date.year][date.month][date.day] = {
      } unless visits_by_hour[date.year][date.month][date.day]

      visits_by_hour[date.year][date.month][date.day][date.hour] = total_visits
    end

    spreadsheet = Axlsx::Package.new

    spreadsheet.workbook.add_worksheet do |sheet|
      title(sheet, "Visitors by Hour")
      sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
      sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
      sheet.add_row # spacing

      header = ["Date"]

      (min_hour..max_hour).each { |hour| header << "%02i:00" % hour }

      table_header(sheet, header)

      (start_date..end_date).each do |date|
        row = [date.strftime("%Y-%m-%d")]

        (min_hour..max_hour).each do |hour|
          if visits_by_hour[date.year] &&
               visits_by_hour[date.year][date.month] &&
               visits_by_hour[date.year][date.month][date.day] &&
               visits_by_hour[date.year][date.month][date.day][hour]
            row << visits_by_hour[date.year][date.month][date.day][hour]
          else
            row << 0
          end
        end

        sheet.add_row row
      end
    end

    spreadsheet
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.generate_kit_purchased_report(start_date, end_date)
    kits = ProjectKit.where("created_at" => start_date..end_date)

    spreadsheet = Axlsx::Package.new

    spreadsheet
      .workbook
      .add_worksheet(name: "Report") do |sheet|
        title(sheet, "Purchased kits")

        sheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
        sheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
        sheet.add_row # spacing

        table_header(
          sheet,
          ["Kit name", "User.unscoped", "Date", "Delivery Status"]
        )

        kits.each do |kit|
          status = kit.delivered? ? "Delivered" : "Not yet delivered"
          sheet.add_row [
                          kit.proficient_project.title,
                          kit.user.name,
                          kit.created_at,
                          status
                        ]
        end
      end

    spreadsheet
  end

  # endregion

  # region Database helpers

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.get_visitors(start_date, end_date)
    g = Arel::Table.new("g")
    ls = LabSession.unscoped.arel_table
    u = User.unscoped.arel_table
    s = Space.arel_table

    result =
      ActiveRecord::Base.connection.exec_query(
        g
          .project(
            [
              g[:space_name].minimum.as("space_name"),
              g[:identity],
              g[:faculty],
              g[:gender],
              Arel.star.count.as("unique_visitors"),
              g[:count].sum.as("total_visits")
            ]
          )
          .from(
            LabSession
              .unscoped
              .select(
                [
                  ls[:space_id],
                  s[:name].minimum.as("space_name"),
                  u[:identity],
                  u[:faculty],
                  u[:gender],
                  Arel.star.count
                ]
              )
              .joins(ls.join(u).on(u[:id].eq(ls[:user_id])).join_sources)
              .joins(ls.join(s).on(s[:id].eq(ls[:space_id])).join_sources)
              .where(ls[:sign_in_time].between(start_date..end_date))
              .group(
                ls[:space_id],
                ls[:user_id],
                u[:faculty],
                u[:identity],
                u[:gender]
              )
              .arel
              .as(g.name)
          )
          .order(g[:space_name].minimum, g[:identity], g[:faculty], g[:gender])
          .group(g[:space_id], g[:identity], g[:faculty], g[:gender])
          .to_sql
      )

    # shove everything into a hash
    organized = {
      unique: 0,
      total: 0,
      spaces: {
      },
      identities: {
      },
      faculties: {
      },
      genders: {
      }
    }

    result.each do |row|
      space_name = row["space_name"]
      faculty = row["faculty"].presence || "Unknown"
      gender = row["gender"]

      identity =
        case row["identity"]
        when "undergrad"
          "Undergraduate"
        when "grad"
          "Graduate"
        when "faculty_member"
          "Faculty Member"
        when "community_member"
          "Community Member"
        else
          "Unknown"
        end

      unless organized[:spaces][space_name]
        organized[:spaces][space_name] = {
          unique: 0,
          total: 0,
          identities: {
          },
          faculties: {
          },
          genders: {
          }
        }
      end

      unless organized[:spaces][space_name][:identities][identity]
        organized[:spaces][space_name][:identities][identity] = {
          unique: 0,
          total: 0,
          faculties: {
          }
        }
      end

      unless organized[:spaces][space_name][:identities][identity][:faculties][
               faculty
             ]
        organized[:spaces][space_name][:identities][identity][:faculties][
          faculty
        ] = { unique: 0, total: 0 }
      end

      unless organized[:spaces][space_name][:faculties][faculty]
        organized[:spaces][space_name][:faculties][faculty] = {
          unique: 0,
          total: 0
        }
      end

      unless organized[:spaces][space_name][:genders][gender]
        organized[:spaces][space_name][:genders][gender] = {
          unique: 0,
          total: 0
        }
      end

      organized[:identities][identity] = {
        unique: 0,
        total: 0,
        faculties: {
        }
      } unless organized[:identities][identity]

      unless organized[:identities][identity][:faculties][faculty]
        organized[:identities][identity][:faculties][faculty] = {
          unique: 0,
          total: 0
        }
      end

      organized[:faculties][faculty] = { unique: 0, total: 0 } unless organized[
        :faculties
      ][
        faculty
      ]

      organized[:genders][gender] = { unique: 0, total: 0 } unless organized[
        :genders
      ][
        gender
      ]

      unique = row["unique_visitors"].to_i
      total = row["total_visits"].to_i

      organized[:unique] += unique
      organized[:total] += total

      organized[:identities][identity][:unique] += unique
      organized[:identities][identity][:total] += total

      organized[:identities][identity][:faculties][faculty][:unique] += unique
      organized[:identities][identity][:faculties][faculty][:total] += total

      organized[:faculties][faculty][:unique] += unique
      organized[:faculties][faculty][:total] += total

      organized[:genders][gender][:unique] += unique
      organized[:genders][gender][:total] += total

      organized[:spaces][space_name][:unique] += unique
      organized[:spaces][space_name][:total] += total

      organized[:spaces][space_name][:identities][identity][:unique] += unique
      organized[:spaces][space_name][:identities][identity][:total] += total

      organized[:spaces][space_name][:identities][identity][:faculties][
        faculty
      ][
        :unique
      ] += unique
      organized[:spaces][space_name][:identities][identity][:faculties][
        faculty
      ][
        :total
      ] += total

      organized[:spaces][space_name][:faculties][faculty][:unique] += unique
      organized[:spaces][space_name][:faculties][faculty][:total] += total

      organized[:spaces][space_name][:genders][gender][:unique] += unique
      organized[:spaces][space_name][:genders][gender][:total] += total
    end

    organized
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.get_trainings(start_date, end_date)
    t = Training.arel_table
    ts = TrainingSession.arel_table
    tsu = Arel::Table.new(:training_sessions_users)
    u = User.unscoped.arel_table
    uu = User.unscoped.arel_table.alias("trainers")
    s = Space.arel_table

    query =
      TrainingSession
        .select(
          [
            t[:id].minimum.as("training_id"),
            t[:name].minimum.as("training_name"),
            ts[:level].minimum.as("training_level"),
            ts[:course].minimum.as("course_name"),
            uu[:name].minimum.as("instructor_name"),
            ts[:created_at].minimum.as("date"),
            s[:name].minimum.as("space_name"),
            Arel.star.count.as("attendee_count")
          ]
        )
        .where(ts[:created_at].between(start_date..end_date))
        .joins(ts.join(t).on(t[:id].eq(ts[:training_id])).join_sources)
        .joins(
          ts.join(tsu).on(ts[:id].eq(tsu[:training_session_id])).join_sources
        )
        .joins(ts.join(u).on(u[:id].eq(tsu[:user_id])).join_sources)
        .joins(ts.join(uu).on(uu[:id].eq(ts[:user_id])).join_sources)
        .joins(ts.join(s).on(s[:id].eq(ts[:space_id])).join_sources)
        .group(ts[:id])
        .order(ts[:created_at].minimum)
        .to_sql

    result = { training_sessions: [], training_types: {} }

    ActiveRecord::Base
      .connection
      .exec_query(query)
      .each do |row|
        result[:training_sessions] << {
          training_id: row["training_id"],
          training_name: row["training_name"],
          training_level: row["training_level"],
          course_name: row["course_name"],
          instructor_name: row["instructor_name"],
          date: DateTime.strptime(row["date"], "%Y-%m-%d %H:%M:%S"),
          facility: row["space_name"],
          attendee_count: row["attendee_count"].to_i
        }

        unless result[:training_types][row["training_id"]]
          result[:training_types][row["training_id"]] = {
            name: row["training_name"],
            count: 0,
            total_attendees: 0
          }
        end

        result[:training_types][row["training_id"]][:count] += 1
        result[:training_types][row["training_id"]][:total_attendees] += row[
          "attendee_count"
        ].to_i
      end

    result
  end

  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.get_certifications(start_date, end_date)
    c = Certification.arel_table
    ts = TrainingSession.arel_table
    t = Training.arel_table
    s = Space.arel_table

    ActiveRecord::Base.connection.exec_query(
      Certification
        .select(
          [
            t["name"].minimum.as("name"),
            s["name"].minimum.as("space_name"),
            ts["course"],
            Arel.star.count.as("total_certifications")
          ]
        )
        .joins(
          c.join(ts).on(c["training_session_id"].eq(ts["id"])).join_sources
        )
        .joins(ts.join(t).on(ts["training_id"].eq(t["id"])).join_sources)
        .joins(ts.join(s).on(ts["space_id"].eq(s["id"])).join_sources)
        .where(ts["created_at"].between(start_date..end_date))
        .group(t["id"], s["id"], ts["course"])
        .order("name", "course", "space_name")
        .to_sql
    )
  end

  # endregion

  # region Axlsx helpers

  # @param [Axlsx::Worksheet] worksheet
  # @param [String] title
  def self.title(worksheet, title)
    worksheet.add_row [title], b: true, u: true
  end

  # @param [Axlsx::Worksheet] worksheet
  # @param [Array<String>] headers
  def self.table_header(worksheet, headers)
    worksheet.add_row headers, b: true
  end

  # @param [Axlsx::Worksheet] worksheet
  # @param [String] title
  # @param [DateTime] start_date
  # @param [DateTime] end_date
  def self.header(worksheet, title, start_date, end_date)
    self.title(worksheet, title)
    worksheet.add_row ["From", start_date.strftime("%Y-%m-%d")]
    worksheet.add_row ["To", end_date.strftime("%Y-%m-%d")]
    worksheet.add_row # spacing
  end

  # endregion
end
