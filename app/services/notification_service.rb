module NotificationService

  class ReportCard
    class << self
      def missing params
        StudentRegistration.where
          .not(id: params[:exclude_list])
          .missing_first_session_report_cards
          .each do |student|
          ReportCardMailer.missing(student).deliver
        end
      end
    end
  end

end
