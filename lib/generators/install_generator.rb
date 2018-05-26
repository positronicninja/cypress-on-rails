module Cypress
  class InstallGenerator < Rails::Generators::Base
    def install
      empty_directory "spec/cypress"
      empty_directory "spec/cypress/integrations"
      empty_directory "spec/cypress/plugins"
      empty_directory "spec/cypress/scenarios"
      empty_directory "spec/cypress/support"

      replace = [
        "# when running the cypress UI, allow reloading of classes",
        "config.cache_classes = (defined?(Cypress) ? Cypress.configuration.cache_classes : true)"
      ]
      gsub_file 'config/environments/test.rb', 'config.cache_classes = true', replace.join("\n")

      create_file "cypress.json", <<-EOF
{
  "fixturesFolder": "spec/cypress/fixtures",
  "integrationFolder": "spec/cypress/integrations",
  "pluginsFile": "spec/cypress/plugins/index.js",
  "screenshotsFolder": "spec/cypress/screenshots",
  "supportFile": "spec/cypress/support/index.js",
  "videosFolder": "spec/cypress/videos"
}
EOF

      create_file "spec/cypress/cypress_helper.rb", <<-EOF
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../../config/environment', __FILE__)

Cypress.configure do |c|
  # change this to nil, if you are not using RSpec Mocks
  c.test_framework = :rspec

  # change this to nil, if you are not using DatabaseCleaner
  c.db_resetter = :database_cleaner

  c.before do
    # this is called when you call cy.setupScenario
    # use it to reset your application state
  end

  # add a module to your run context
  # c.include MyModule
end
EOF

    create_file "spec/cypress/integrations/simple_spec.js", <<-FILE
describe('My First Test', function() {
  it('visit root', function() {
    // This calls to the backend to prepare the application state
    // see the scenarios directory
    cy.setupScenario('basic')

    // The application unter test is available at SERVER_PORT
    cy.visit('http://localhost:'+Cypress.env("SERVER_PORT"))
  })
})
FILE

    create_file "spec/cypress/scenarios/basic.rb", <<-FILE
scenario :basic do
  # You can setup your Rails state here
  # MyModel.create name: 'something'
end
FILE

    create_file "spec/cypress/plugins/index.js", <<-FILE
// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)

module.exports = (on, config) => {
  // `on` is used to hook into various events Cypress emits
  // `config` is the resolved Cypress config
}
FILE

    create_file "spec/cypress/support/index.js", <<-FILE
// cypress-on-rails: dont remove these command
// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands';
import './rails';

// Alternatively you can use CommonJS syntax:
// require('./commands')
FILE

    create_file "spec/cypress/support/commands.js", <<-FILE
// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

FILE

    create_file "spec/cypress/support/rails.js", <<-FILE
// cypress-on-rails: dont remove these command
Cypress.Commands.add('setupScenario', function(name) {
  Cypress.log({ message: name })
  cy.request('POST', 'http://localhost:' + Cypress.env("SERVER_PORT") + "/__cypress__/scenario", JSON.stringify({ scenario: name }))
});

Cypress.Commands.add('setupRails', function () {
  cy.request('POST', 'http://localhost:' + Cypress.env("SERVER_PORT") + "/__cypress__/setup")
});

Cypress.Commands.add('rails', function(code) {
  cy.request('POST', 'http://localhost:' + Cypress.env("SERVER_PORT") + '/__cypress__/eval', JSON.stringify({ code: code }))
})
// cypress-on-rails: end

// The next setup is optional, but if you remove it you will have to manually reset the database
beforeEach(() => { cy.setupRails() });
FILE
    end
  end
end