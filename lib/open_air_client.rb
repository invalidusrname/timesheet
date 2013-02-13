require "selenium-webdriver"

class OpenAirClient

  def initialize(company_id, user_id, password, timesheet_mappings, url = 'https://www.openair.com/index.pl')
    @url        = url
    @driver     = Selenium::WebDriver.for :firefox
    @company_id = company_id
    @user_id    = user_id
    @password   = password
    @timesheet_mappings = timesheet_mappings
  end

  def login
    @driver.navigate.to @url
    @driver.find_element(:id, 'login_user_id').send_keys @user_id
    @driver.find_element(:id, 'login_company_id').send_keys @company_id
    @driver.find_element(:id, 'login_password').send_keys @password
    @driver.find_element(:id, 'login_button').submit
  end

  def custom_date(date)
    Date.parse(date.to_s).strftime("%m/%d/%y")
  end

  def fillout_timesheet(timesheet)
    login
    start_date = timesheet.start_date

    date = custom_date(start_date)

    puts "Checking for #{start_date}"

    if has_timesheet?(start_date)
      puts "Opening existing timesheet"
      element = @driver.find_element(:xpath, "//a[contains(text(), 'Timesheet for #{date}')]")
      element.click
    else
      puts "Creating timesheet"
      element = @driver.find_element(:xpath, "//a[contains(text(), 'New ...')]")
      @driver.execute_script "javascript:openMenu('timesheetmenu')"
      pause
      element.click
      pause(3)

      @driver.find_elements(:tag_name, 'option').each do |o|
        o.click if o.text == date
      end

      @driver.find_element(:name, 'save').submit
    end

    activites_grouped_by_mapping(timesheet).each do |mapping, hash|
      fill_out_mapping(mapping, hash)
    end

    pause(2)
    @driver.find_element(:name, '_save_grid').click
    pause(4)
  end

  def pause(seconds = 1)
    sleep(seconds)
  end

  def fill_out_mapping(map, hash)
    puts "fillind out mapping: #{map.project_text} - #{map.task_text}"

    p_element = find_available_row(map.project_text, map.task_text)
    puts "found project select: #{p_element.text}"
    p_element.click
    pause(2)

    row_number = p_element['id'].split('_').last

    o = find_project_option(row_number, map.project_text)
    puts "found project element: #{o.text}"
    o.click
    pause(2)

    o = find_task_option(row_number, map.task_text)
    puts "found task element: #{o.text}"
    o.click
    pause(2)

    a_map = {
      6 => 3,
      7 => 4,
      1 => 5,
      2 => 6,
      3 => 7,
      4 => 8,
      5 => 9,
    }

    hash.each do |date, activities|
      puts date
      puts activities

      i = a_map[date.cwday]
      link_id = "_c#{i}_r#{row_number}"
      note_id = "_c#{i}_r#{row_number}_dot"

      # click hour field
      @driver.find_elements(:id, link_id).first.click
      pause

      note_link  = @driver.find_elements(:id, link_id).last
      note_link.click
      pause

      @driver.switch_to.frame('timesheet_notes_panel_contents')

      txt = activities.collect { |a| a.to_note } * "<br/>\n"

      if txt == ''
        txt = activities.first.class.to_s
      end

      pause
      text_area = @driver.find_element(:id, "tm_notes")
      text_area.clear
      text_area.send_keys txt
      pause

      @driver.find_element(:id, "close_save").click
      @driver.switch_to.default_content
      pause(2)

      hour_input = @driver.find_elements(:id, link_id).first

      if activities.first.is_a? GitCommit
        cd = CommitDay.new(date)
        activities.each do |a|
          cd.add_commit a
        end

        hrs = (cd.duration / 60.0).round(2)
        puts "Duration: #{hrs}"

        if cd.duration > 0
          hour_input.clear
          hour_input.send_keys(hrs.to_s)
        else
          hour_input.clear
          hour_input.send_keys 1
        end
      else
        hour_input.clear
        hour_input.send_keys 1
      end
    end
  end

  def map_for_activity(activity)
    @timesheet_mappings.find_mapping(activity)
  end

  def activites_grouped_by_mapping(timesheet)
    maps = {}
    timesheet.activities.each do |a|
      map = map_for_activity(a)

      # don't be adding activities that can't be mapped to a project/task
      next if map.nil?

      maps[map] = {} unless maps.has_key?(map)

      if maps[map].has_key?(a.date)
        maps[map][a.date] << a
      else
        maps[map][a.date] = []
      end
    end
    maps
  end

  def find_available_row(project_text, task_text)
    projects = fetch_all_projects.select { |e| e.text.include? project_text }
    tasks = fetch_all_tasks.select { |e| e.text.include? task_text }

    if projects.size == 1 && tasks.size == 0
      projects.first
    else
      first_available_row
    end
  end

  def first_available_row
    fetch_all_projects.select { |e| e.selected? == false }.first
  end

  def fetch_all_projects
    @driver.find_elements(:xpath, "//select[contains(@id, 'customer_project_')]")
  end

  def fetch_all_tasks
    @driver.find_elements(:xpath, "//select[contains(@id, 'project_task_')]")
  end

  def find_project_option(row_number, option_text)
    project_element(row_number).click
    pause
    xpath = "//select[@id='customer_project_#{row_number}']/option"
    @driver.find_elements(:xpath, xpath).select do |e|
      e.text.include? option_text
    end.first
  end

  def find_task_option(row_number, option_text)
    task_element(row_number).click
    pause
    xpath = "//select[@id='project_task_#{row_number}']/option"
    @driver.find_elements(:xpath, xpath).select do |e|
      e.text.include? option_text
    end.first
  end

  def project_element(row_number)
    @driver.find_element(:id, "customer_project_#{row_number}")
  end

  def task_element(row_number)
    @driver.find_element(:id, "project_task_#{row_number}")
  end

  def first_unselected_element(option_partial_id, txt)
    xpath = "//select[contains(@id, '#{option_partial_id}')]"

    @driver.find_elements(:xpath, xpath).select do |e|

    end
    #customer_project_2
  end

  def has_timesheet?(start_date)
    text_date = Date.parse(start_date.to_s).strftime("%m/%d/%y")
    @driver.page_source.include? text_date
  end

  def close
    @driver.quit
  end
end

