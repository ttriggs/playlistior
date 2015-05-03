class MockChart
  CHARTS_FILE = File.expand_path("../example_chart.json", __FILE__)
  CHARTS_JSON = File.read(CHARTS_FILE)
  def self.get_mock_chart
    CHARTS_JSON
  end
end
