Feature: MooForge compatibility layer
  In order to be compliant with mooforge packages, we should accept
  various quirky source files.

  Scenario: Compiling a mooforge package that uses mooforge tag dependency notation
    When I run "jsus MooforgePlugin/Plugin tmp -d MooforgePlugin/Core"
    Then the following files should exist:
      | tmp/plugin.js |
    And file "tmp/plugin.js" should contain
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
    And file "tmp/plugin.js" should contain
      """
      /*
      ---

      script: plugin.js

      description: plugin main file

      license: UNLICENSE

      authors:
      - Mark Abramov

      provides:
        - Base

      requires:
        - /Support
        - mootools_core/1.3.0: Core

      ...
      */
      """
    And file "tmp/plugin.js" should contain
      """
      /*
      ---

      script: plugin-support.js

      description: plugin support file

      license: UNLICENSE

      authors:
      - Mark Abramov

      provides:
        - Support

      requires:
        - mootools_core/1.3.0: Core

      ...
      */
      """
    And file "tmp/plugin.js" should have "script: plugin-support.js" before "script: plugin.js"
