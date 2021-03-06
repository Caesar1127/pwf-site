ActiveAdmin.register Season do
  permit_params :current, :beg_date, :end_date, :fall_registration_open, :spring_registration_open, :status_cd, :created_at, :updated_at, :current, :fencing_fee, :aep_fee, :waitlist_registration_date, :open_enrollment_date, :enrollment_limit, :message, :min_for_hoodie, :min_for_t_shirt, staff_ids:[]

  menu :parent => "Administration", label: "Season Management", priorty: 20
  config.clear_sidebar_sections!

  scope :active, :default =>true
  scope :all

  index do
    column :name
    column :beg_date
    column :end_date
    column :fall_registration_open
    column :waitlist_registration_date
    column :open_enrollment_date
    column :status
    actions
  end

 controller do
   def edit
     @season = Season.find(params[:id])
   end

   def update
     @season = Season.find(params[:id])
     @season.update_attributes(permitted_params[:season])
     redirect_to admin_season_path(@season)
   end

 end

  form do |f|
    f.inputs season.description do
      f.input :beg_date, as: :date_picker
      f.input :end_date, as: :date_picker
      f.input :fall_registration_open, as: :date_picker
      f.input :waitlist_registration_date, as: :date_picker
      f.input :open_enrollment_date, as: :date_picker
      f.input :current
      f.input :status_cd, :as => :select, :collection => Season.statuses.hash
      f.input :fencing_fee
      f.input :aep_fee
      f.input :enrollment_limit
      f.input :min_for_hoodie, label: "Min Hoodie attendance"
      f.input :min_for_t_shirt, label: "Min T-shirt attendance"
      f.input :staffs, as: :select, label: "Staff", include_hidden: true , input_html: {multiple: true}, collection: Staff.all 

    end
    f.actions

  end

  show :title => :description do
    attributes_table do
      row :beg_date
      row :end_date
      row :fall_registration_open
      row :waitlist_registration_date
      row :open_enrollment_date
      row :fencing_fee
      row :aep_fee
      row :enrollment_limit
    end
    panel "Staff" do
      table_for(resource.season_staffs) do |t|
        t.column("name")   {|staff| link_to staff.name, admin_staff_path(staff.staff_id)}
      end
    end
  end
end
