# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Authentication', document: :customer_v1 do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/customer/v1/auth' do
    parameter :login, 'Login', scope: :auth, required: true
    parameter :password, 'Password', scope: :auth, required: true

    let(:login) { 'login' }
    let(:password) { 'password' }

    before { create :api_access, login: login, password: password }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
    end
  end
end
