require_relative '../lib/util'

describe do
  it "determines the start_date" do
    expected_date = Date.parse("2013-01-26")
    dates = [
      "2013-02-02",
      "2013-02-03",
      "2013-02-04",
      "2013-02-05",
      "2013-02-06",
      "2013-02-07",
      "2013-02-08",
    ].each do |date|
      computed_date = determine_start_date(Date.parse(date))
      computed_date.should eq(expected_date), "Checking #{date}"
    end
  end

end
