module RequestSpecHelper
    # Method to parse JSON responses in request specs
    def json
      JSON.parse(response.body)
    end
  end
  