# RouletteAnalysis

| ![](https://miyashi.app/images/rouletteanalysis/app.png)                                                                                        | ![](https://miyashi.app/images/rouletteanalysis/macOS.png)                                                                                |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [![iosappstore.svg](https://miyashi.app/images/rouletteanalysis/iosappstore.svg)](https://apps.apple.com/us/app/roulette-analysis/id6449939201) | [![macStore.svg](https://miyashi.app/images/rouletteanalysis/macStore.svg)](https://apps.apple.com/us/app/roulette-analysis/id6449939201) |


# Dependencies Graph
Powerd by [ Ryu0118/swift-dependencies-graph](https://github.com/Ryu0118/swift-dependencies-graph) & [ChatGPT](https://chat.openai.com/?model=gpt-4)

```mermaid
graph TB

  subgraph "Main"
    RouletteAnalysis
  end


subgraph "SPM"
  subgraph "Core"
    App
    Setting
    Roulette
    TableLayout
    Wheel
    History
    Item
  end

  subgraph "Views"
    AppView
    SettingView
    RouletteView
    TableLayoutView
    WheelView
    HistoryView
    Tutorial
    Feedback
  end

　　subgraph "Dependencies"
    UserDefaultsClient
    Tutorial
    Feedback
    Utility
    APIClient
    end
  end



　RouletteAnalysis-->AppView
  AppView-->App
  AppView-->Tutorial
  AppView-->Setting

  AppView-->SettingView
  AppView-->RouletteView

  App-->Setting
  App-->Roulette
  Setting-->Item
  SettingView-->Item
  SettingView-->Setting
  SettingView-->Tutorial
  SettingView-->Feedback
  Roulette-->TableLayout
  Roulette-->Wheel
  Roulette-->History
  Roulette-->Setting
  RouletteView-->TableLayout
  RouletteView-->Wheel
  RouletteView-->History
  RouletteView-->Setting
  RouletteView-->TableLayoutView
  RouletteView-->Roulette
  RouletteView-->HistoryView
  RouletteView-->SettingView
  RouletteView-->WheelView
  TableLayout-->History
  TableLayout-->Setting
  TableLayout-->Item
  TableLayoutView-->History
  TableLayoutView-->Setting
  TableLayoutView-->Item
  TableLayoutView-->TableLayout
  TableLayoutView-->Roulette
  Wheel-->History
  Wheel-->Setting
  Wheel-->Item
  WheelView-->History
  WheelView-->Setting
  WheelView-->Item
  WheelView-->Wheel
  WheelView-->Roulette
  History-->Item
  HistoryView-->Item
  HistoryView-->History
```

