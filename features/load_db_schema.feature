Feature: Adding a task

  Background: 
    Given a nilm
    
  Scenario: User can view database schema as JSON
    When User updates the nilm
    Then GET /nilm/:id.json displays schema as JSON
    