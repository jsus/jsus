Feature: structure json files
  In order to have programmatic ability to introspect resulting packages, we
  generate some extra files.

  Scenario: auto-generation scripts.json
    When I run "jsus Basic tmp"
    And file "tmp/scripts.json" should contain valid JSON
    And file "tmp/scripts.json" should contain JSON equivalent to
      """
      {
        "Package": {
          "desc": "Jsus package with correct order set",
          "provides": [
            "Package/Color",
            "Package/Input.Color"
          ],
          "requires": [
          ]
        }
      }
      """
