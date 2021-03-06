ActiveAdmin.register ReportCard, max_width: "800px" do
  menu parent: "Students"
  includes :student_registration, :grades, :marking_period
  actions  :index, :destroy, :edit, :update, :show
  permit_params :format_cd,:academic_year,:marking_period_id, :student_registration_id

  scope :all, default: true
  scope :not_graded
  scope :graded

  filter :season, collection: Season.by_season, include_blank: false
  filter :student, :collection => Student.by_last_first
  filter :marking_period,  :collection => MarkingPeriod.simple_periods

  controller do
    before_action only: :index do
      # when arriving through top navigation

      if(params['q'] && params['q']['student_registration_season_id_eq'])
        @season = Season.find(params['q']["student_registration_season_id_eq"])
      else
        @season = Season.current
      end
    end

    def scoped_collection
      if params["action"] == "index"
        end_of_association_chain.joins(:student_registration).where("student_registrations.season_id =?", @season.id)
      else
        end_of_association_chain
      end
    end



    def edit
      @report_card = ReportCard.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: report_cards_data }
      end
    end

    def report_cards_data
      @report_card.as_json(include: { grades: {only: [ :id, :value, :subject_id], methods:[:score, :subject_name]}}, only:[:id], methods: [:subject_list, :average])
    end
  end

  index download_links: -> { [:csv]  } do
    column :student
    column :term
    column :marking_period_name
    column "Transcipt Available" do |report_card|
      report_card.transcript.attached?
    end

    column "Uploaded At" do |c|
      c.created_at if c.transcript.attached?
    end

    column "Grades Entered" do |report_card|
      report_card.grades.any?
    end

    column "GPA" do |rc|
      rc.average
    end

    actions defaults: true do |c|
      link_to "Download", rails_blob_path(c.transcript, disposition: "attachment"), class: 'member_link' if c.transcript.attached?
    end
  end

  form title: ->(report_card){"#{report_card.student_name}/#{report_card.term}/#{report_card.marking_period_name}" } do |f|

    panel "Report Card Overview" do

      def grade_hint
        "Select a grade format to enable the grade entry form" if report_card.format_cd.nil?
      end

      h3 "#{report_card.student_name}"

      f.semantic_errors(*f.object.errors.keys)

      inputs  do
        input :student_registration, as: :select, collection: resource.student.student_registrations.map{|s|[s.term, s.id]}
        input :marking_period, as: :radio, collection: MarkingPeriod.simple_periods{|m|[ m.name, m.id ]} 
        input :format_cd, as: :radio, collection: GradeConversionService.for_select, label: "Grade Type", hint: grade_hint
      end
      f.actions
    end
  
    columns do
      column  max_width: "675px", min_width: "675px" do
        panel "Uploaded Transcript" do
          render "report_cards/transcript_iframe", {report_card: report_card}
        end
      end

      column max_width: "450px" do
        panel "Grades" , class: "grades-list" do
          div class: "grade-format-missing" do
            "Select a grade type in report card summary above (e.g.  #{GradeConversionService.descriptions.join(', ')}) in order to enter grades" 
          end if report_card.format_cd.nil?
          render "report_card_app", {report_card: report_card}
        end
      end 
    end
  end

  csv do
    column :student do |c|
      c.student_name
    end
    column :term
    column :marking_period_name
    column "Uploaded At" do |c|
      c.created_at if c.transcript.attached?
    end
    column "GPA" do |rc|
      rc.average
    end
  end


  show title: ->(report_card){"#{report_card.student_name}/#{report_card.term}/#{report_card.marking_period_name}" } do
    columns do
      column min_width: "65%" do
        panel "Transcript" do
          render "report_cards/transcript_iframe", {report_card: report_card}
        end
      end

      column max_width: "33%" do
        panel "Grades" do
          table_for report_card.grades do
            column :subject
            column "Grade", :value
            column "Grade *", :hundred_point
          end
        end
      end
    end
  end
end
