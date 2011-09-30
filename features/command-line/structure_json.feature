Feature: structure json files
  In order to have programmatic ability to introspect resulting packages, we
  generate some extra files.

  @wip
  Scenario: auto-generation of tree.json and scripts.json
    When I run "jsus Basic tmp"
    Then the following files should exist:
      | tmp/tree.json    |
      | tmp/scripts.json |
    And file "tmp/tree.json" should contain valid JSON
    And file "tmp/tree.json" should contain JSON equivalent to
      """
      {
        "Library": {
          "Color": {
            "desc": "A library to work with colors",
            "requires": [

            ],
            "provides": [
              "Color"
            ]
          }
        },
        "Widget": {
          "Input": {
            "Input.Color": {
              "desc": "Cool colorpicker for everyone to enjoy",
              "requires": [
                "Color"
              ],
              "provides": [
                "Input.Color"
              ]
            }
          }
        }
      }
      """
    And file "tmp/scripts.json" should contain valid JSON
    And file "tmp/scripts.json" should contain JSON equivalent to
      """
      {
        "Package": {
          "desc": "Jsus package with correct order set",
          "provides": [
            "Color",
            "Input.Color"
          ],
          "requires": [

          ]
        }
      }
      """
