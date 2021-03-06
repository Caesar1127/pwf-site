class AttendanceAwardSheetPdf <Prawn::Document
  STUDENTS_PER_PAGE = 40.0
  STAFF_PER_PAGE = 25.0

  def initialize(params ={})
    super()
    enrollment = StudentRegistration.current.confirmed.order_by_student_last_name
    @staff_data =  [["Instructor Name", "Size"]]

    @hoodies = AttendanceAwards.hoodies(enrollment, params)
    @hoodie_data =  @hoodies.map{|enrolled|[name_with_attendence(enrolled), enrolled.size.to_s]}

    @t_shirts = AttendanceAwards.t_shirts(enrollment, params)
    @t_shirts_data =  @t_shirts.map{|enrolled|[name_with_attendence(enrolled), enrolled.size.to_s]}


    [@hoodie_data, @t_shirts_data].each_with_index do |group, index|
      name = index == 0 ? "Hoodies" : "T-Shirts Only"
      draw_student_sheets group, name
    end

    print_order_summary enrollment, params

  end

  def draw_student_sheets group, name
    total_pages_for_group  =  pages_for_group_size(group.size)
    0.upto(total_pages_for_group) do |page|
      text_box "#{name} List", :size=>15, :align =>:center

      left, right = assemble_batch_for group, page
      print_batch left, 0 
      print_batch right, 300 

      start_new_page if page < pages_for_group_size(@hoodie_data.size + @t_shirts_data.size)
    end
  end

 def pages_for_group_size size
   (size/STUDENTS_PER_PAGE).ceil - 1
 end

  def print_batch batch, pos
    column_box([pos, bounds.top], :columns => 2, :width => bounds.width) do
      move_down 75 
      table batch, :cell_style => { :inline_format => true } if batch
    end
  end

  def assemble_batch_for group,  page
    per_column = STUDENTS_PER_PAGE/2

    left_off = page * STUDENTS_PER_PAGE   #page: 0 => (0, 19); 2 = (40,59)
    right_off = left_off + per_column  #page: 0 => (20,39), 2 => (60, 79)

    left = group.slice(left_off, per_column)
    right = group.slice(right_off, per_column)

    [left, right]
  end

  def print_order_summary enrollment, params
    start_new_page
    move_down 75
    text_box "Order Summary", :size=>15, :align =>:center
    hoodies = AttendanceAwards.hoodies_breakdown enrollment,params
    tshirts = AttendanceAwards.t_shirt_breakdown enrollment,params
    summary = [["Size", "Hoodies", "T-Shirts"]]
    StudentRegistration::SIZES.each do |size|
      summary.push [size, hoodies[size], tshirts[size]]
    end
    summary.push ["Total", hoodies.values.sum, tshirts.values.sum]
    table summary
  end

  def name_with_attendence student
    "#{student.student_first_name.titleize} #{student.student_last_name.titleize}:  #{current_attendances student}"
  end

  def current_attendances person
    person.student.current_present_attendances.count
  end

end

