Feature: extensions
  In order to monkeypatch other libraries, I should be able to cook some
  extensions.

  Scenario: monkeypatch for external dependency
    When I run "jsus Extensions tmp -d Extensions/Mootools --no-deep-recurse"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: Core.js

      description: Mootools fake core

      license: MIT-style license

      authors:
      - Valerio Proietti

      provides: [Core]

      ...
      */
      """
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: MootooolsCore.js

      description: Extension for mootools core

      license: MIT-style license

      authors:
      - Mark Abramov

      extends: Mootools/Core

      ...
      */
      """
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: Color.js

      description: A library to work with colors

      license: MIT-style license

      authors:
      - Valerio Proietti

      requires:
        - Mootools/Core

      provides: [Color]

      ...
      */
      """
    And file "tmp/package.js" should have "MootooolsCore.js" after "script: Core.js"
    And file "tmp/package.js" should have "MootooolsCore.js" before "script: Color.js"
