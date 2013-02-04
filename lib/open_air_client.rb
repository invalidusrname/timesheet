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

    if has_timesheet?(start_date)
      element = @driver.find_element(:xpath, "//a[contains(text(), 'Timesheet for #{date}')]")
      element.click
    else
      element = @driver.find_element(:xpath, "//a[contains(text(), 'New ...')]")
      @driver.execute_script "javascript:openMenu('timesheetmenu')"
      element.click

      @driver.find_elements(:tag_name, 'option').each do |o|
        o.click if o.text == date
      end

      @driver.find_element(:name, 'save').submit
    end

    activites_grouped_by_mapping(timesheet).each do |mapping, hash|
      fill_out_mapping(mapping, hash)
    end

    @driver.find_element(:name, '_save_grid').click
    pause(5)
  end

  def pause(seconds = 1)
    sleep(seconds)
  end

  def fill_out_mapping(map, hash)
    #puts "finding project #{map.project_text}"

    o = project_element(map.project_text)

    #puts "found project: #{o.text}"

    s = o.find_element(:xpath, '..')
    row_number = s['id'].split('_').last

    s.click
    pause
    project_element(map.project_text).click
    pause

    #puts "finding task in row #{row_number}: #{map.task_text}"

    o = task_element(row_number)

    #puts "found task: #{o.text}"

    o.find_element(:xpath, '..').click
    pause
    task_element(row_number).click

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

      hour_input = @driver.find_elements(:id, link_id).first
      note_link  = @driver.find_elements(:id, link_id).last

      hour_input.clear
      hour_input.send_keys 1

      #note = @driver.find_elements(:id, note_id).last

      note_link.click

      @driver.switch_to.frame('timesheet_notes_panel_contents')
      text_area = @driver.find_element(:id, "tm_notes")

      txt = activities.collect { |a| a.to_note } * "<br/>\n"

      text_area.clear
      text_area.send_keys txt

      @driver.find_element(:id, "close_save").click
      @driver.switch_to.default_content

      pause
    end
  end

  def map_for_activity(activity)
    @timesheet_mappings.find_mapping(activity)
  end

  def activites_grouped_by_mapping(timesheet)
    maps = {}
    timesheet.activities.each do |a|
      map = map_for_activity(a)

      maps[map] = {} unless maps.has_key?(map)

      if maps[map].has_key?(a.date)
        maps[map][a.date] << a
      else
        maps[map][a.date] = []
      end
    end
    maps
  end

  def project_element(select_text)
    xpath = "//option[contains(text(), '#{select_text}')]"
    element = @driver.find_elements(:xpath, xpath).select do |e|
      e.selected?
    end

    if element
      puts "FOUND ELEMENT #{element.first} #{element.first.text} "
      element.first
    else
      puts "UNSELECTED FOUND ELEMENT #{element} #{element.text}"
      element = first_unselected_element('customer_project_', select_text)
    end
  end

  def task_element(row_number)
    puts "finding text"
    @driver["project_task_#{row_number}"]
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

