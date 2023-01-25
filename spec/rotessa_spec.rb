# frozen_string_literal: true

RSpec.describe Rotessa do
  it "has a version number" do
    expect(Rotessa::VERSION).not_to be nil
  end

  let(:client) { Rotessa::Client.new(api_key: ENV.fetch("ROTESSA_API_KEY")) }

  it "gets customers" do
    response, results = client.customers
    expect(response).to be_success
    expect(results.size).to be > 100
  end

  # it 'gets one customer with a string identifier' do
  #   puts client.customer(id: 'KERILARC0001')
  #   response = client.customer(id: 'KERILARC0001')
  #   expect(response).to be_success
  #   expect(response['id']).to eq 327051
  # end

  it "gets one customer with a numeric identifier" do
    response = client.customer(id: 327_051)
    expect(response).to be_success
    expect(response["id"]).to eq(327_051)
  end

  it "gets all financial transactions" do
    response, results = client.transactions(start_date: "2022-01-01")
    expect(response).to be_success
    expect(results.size).to be > 1000
  end

  it "gets all declined transactions" do
    response, results = client.transactions(start_date: "2022-01-01", status: "Declined")
    expect(response).to be_success
    expect(results.size).to be < 50
    expect(results.size).to be > 5
  end
end
