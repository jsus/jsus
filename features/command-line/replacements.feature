Feature: replacements
  In order to monkeypatch other libraries, I should be able to replace some
  of the files.

  Scenario: monkeypatch for external dependency
    When I run "jsus Replacements tmp -d Replacements/Dependencies --no-deep-recurse"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should contain
      """
      description: Replaced mootools core
      """
    And file "tmp/package.js" should contain
      """
      description: A library to work with colors
      """
    And file "tmp/package.js" should not contain
      """
      description: Mootools fake core
      """
    And file "tmp/package.js" should have "MootooolsCore.js" before "script: Color.js"
