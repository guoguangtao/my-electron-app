{
  "targets": [
    {
      "target_name": "addon",
      "conditions": [
        [
          "OS=='win'", 
          {
            "sources": [
              "./src/native/windows/addon.cc",
            ]
          }
        ],
        [
          "OS=='mac'", 
          {
            "sources": [
              "./src/native/macos/addon.mm",
              "./src/native/macos/LBMacCastHandler.m",
              "./src/native/macos/AOCOutputSwitcher.m",
              "./src/native/macos/HPSystemAuthorize.m",
              "./src/native/macos/HPCastFoundationTool.m",
            ],
            "xcode_settings": {
              # 需要加上这个，否则build 会报 cannot use 'throw' with exceptions disabled
              "GCC_ENABLE_CPP_EXCEPTIONS": "YES"
            }
          }
        ]
      ],
      "include_dirs": [
        "<!@(node -p \"require('./node_modules/node-addon-api').include\")",
      ],
      "dependencies": [
        "<!@(node -p \"require('./node_modules/node-addon-api').gyp\")"
      ],
    }
  ]
}
