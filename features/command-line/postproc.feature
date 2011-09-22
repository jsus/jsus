Feature: postprocessing
  In order to leave unneccessary compatibility code out, I should be able to
  use postprocessing feature.

  Scenario: compat12
    When I run "jsus Postprocessing/MootoolsCompat12 tmp --postproc moocompat12"
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
    And file "tmp/package.js" should not contain
      """
      <1.2compat>
      """
    And file "tmp/package.js" should not contain
      """
      var compatible12 = true;
      """
    And file "tmp/package.js" should contain
      """
      var incompatible = true;
      """

  Scenario: mooltIE8
    When I run "jsus Postprocessing/MootoolsLtIE8 tmp --postproc mooltIE8"
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
    And file "tmp/package.js" should not contain
      """
      <ltIE8>
      """
    And file "tmp/package.js" should not contain
      """
      var compatibleIE8 = true;
      """
    And file "tmp/package.js" should contain
      """
      var incompatible = true;
      """

  Scenario: semicolon
    When I run "jsus Postprocessing/MootoolsLtIE8 tmp --postproc semicolon"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should begin with
      """
      ;
      """
