require 'rails_helper'

RSpec.describe User, :type => :model do
  describe '.fetch_from' do
    let(:user) { build_stubbed :user }

    let(:json) do
      {
        display_name: user.display_name,
        domain: user.domain,
        locale: user.locale,
        url: "http://#{user.domain}/"
      }.to_json
    end

    before do
      stub_request(:get, "http://#{user.domain}/user.json")
        .to_return(status: 200, body: json, headers: { content_type: 'application/json' })
    end

    it "performs a request to /user.json" do
      User.fetch_from(user.domain)
    end

    it "rewrites the given path to /user.json" do
      User.fetch_from("http://#{user.domain}/foo.png")
    end
  end
end
