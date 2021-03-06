describe ReportCard do
  it "should be valid" do
    expect(FactoryBot.create(:report_card, :with_transcript).valid?).to be true
  end

  it "number grade should be valid" do
    expect(FactoryBot.create(:report_card, :with_transcript, :number_grade).valid?).to be true
  end

  it "A-F report should be valid" do
    expect(FactoryBot.create(:report_card, :with_transcript, :a_to_f_letter_grade).valid?).to be true
  end

  #it "E-U should be valid" do
  #expect(FactoryBot.create(:report_card, :with_transcript, :e_to_u_letter_grade).valid?).to be true
  #end

  describe "#reassign_to_last_season" do

    let(:student){FactoryBot.create(:student)}
    let(:reg_curr){FactoryBot.create(:student_registration, season: Season.current, student: student, status: :confirmed_paid)}
    let(:card){FactoryBot.create(:report_card, :with_transcript, season: Season.current, student_registration: reg_curr)}

    context "student has previous registration" do
      it "should reassigns report card to previous season attended" do
        reg_prev = FactoryBot.create(:student_registration, season: Season.previous,  student: student, status: :wait_list)
        card.reassign_to_last_season
        expect(card.student_registration).to eq reg_prev
        expect(card.season).to eq Season.previous
      end
    end

    context "student has no previous registration" do
      it "should reassigns report card to previous season attended" do
        card.reassign_to_last_season
        expect(card.student_registration).to eq reg_curr
        expect(card.season).to eq Season.current
      end
    end
  end



  it "is unblocks if previous report cards provided " do

    @fall = FactoryBot.create(:marking_period)
    @spring = FactoryBot.create(:marking_period, name: MarkingPeriod::SECOND_SESSION)
    @student = FactoryBot.create(:student)
    @prev_reg = FactoryBot.create(:student_registration, :confirmed, :previous, :student => @student)
    @reg = FactoryBot.create(:student_registration, :student => @student)

    expect(@reg.status).to eq :blocked_on_report_card

    FactoryBot.create(:report_card, :with_transcript, 
                            student_registration: @prev_reg, 
                            marking_period: MarkingPeriod.first_session, 
                            academic_year:  Season.previous.academic_year)
    expect(@reg.status).to eq :blocked_on_report_card

    FactoryBot.create(:report_card, :with_transcript, 
                            student_registration: @prev_reg, 
                            marking_period: MarkingPeriod.second_session, 
                            academic_year:  Season.previous.academic_year)

    expect(@reg.reload.status).to eq :pending
  end

end



