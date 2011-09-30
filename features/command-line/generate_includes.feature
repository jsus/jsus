Feature: generate includes.js
  In order to be able to quickly iterate over js files, I need to be able to generate
  includes.js files with load instructions for browser in correct order.

  Scenario: using -g option
    When I run "jsus Basic tmp -g"
    Then the following files should exist:
      | tmp/includes.js    |
    And file "tmp/includes.js" should contain
    """
    Library/Color.js
    """
    And file "tmp/includes.js" should contain
    """
    Widget/Input/Input.Color.js
    """

  Scenario: using --generate-include option to override includes root
    When I run "jsus Basic tmp --generate-includes=Basic/Source/Library"
    Then the following files should exist:
      | tmp/includes.js    |
    And file "tmp/includes.js" should contain
    """
    Color.js
    """
    And file "tmp/includes.js" should not contain
    """
    Library/Color.js
    """
    And file "tmp/includes.js" should contain
    """
    ../Widget/Input/Input.Color.js
    """
    And file "tmp/includes.js" should have "Color.js" before "Input.Color.js"
