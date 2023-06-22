# RouletteAnalysis

| ![](https://miyashi.app/images/rouletteanalysis/app.png)                                                                                        | ![](https://miyashi.app/images/rouletteanalysis/macOS.png)                                                                                |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [![iosappstore.svg](https://miyashi.app/images/rouletteanalysis/iosappstore.svg)](https://apps.apple.com/us/app/roulette-analysis/id6449939201) | [![macStore.svg](https://miyashi.app/images/rouletteanalysis/macStore.svg)](https://apps.apple.com/us/app/roulette-analysis/id6449939201) |


```mermaid
graph TD;
    AppView-->Item;
    AppView-->UserDefaultsClient;
    AppView-->Tutorial;
    AppView-->Feedback;
    AppView-->App;
    AppView-->Setting;
    AppView-->Wheel;
    AppView-->TableLayout;
    AppView-->Roulette;
    AppView-->SettingView;
    AppView-->WheelView;
    AppView-->TableLayoutView;
    AppView-->RouletteView;
    AppView-->HistoryView;
    App-->Item;
    App-->Setting;
    App-->Roulette;
    App-->UserDefaultsClient;
    Tutorial-->Utility;
    Setting-->UserDefaultsClient;
    Setting-->Item;
    SettingView-->Item;
    SettingView-->Setting;
    SettingView-->Tutorial;
    SettingView-->Feedback;
    Roulette-->TableLayout;
    Roulette-->Wheel;
    Roulette-->History;
    Roulette-->Setting;
    RouletteView-->TableLayout;
    RouletteView-->Wheel;
    RouletteView-->History;
    RouletteView-->Setting;
    RouletteView-->TableLayout;
    RouletteView-->TableLayoutView;
    RouletteView-->Roulette;
    RouletteView-->HistoryView;
    RouletteView-->SettingView;
    RouletteView-->WheelView;
    RouletteView-->App;
    TableLayout-->History;
    TableLayout-->Setting;
    TableLayout-->Item;
    TableLayoutView-->History;
    TableLayoutView-->Setting;
    TableLayoutView-->Item;
    TableLayoutView-->TableLayout;
    TableLayoutView-->Roulette;
    TableLayoutView-->Utility;
    Wheel-->History;
    Wheel-->Setting;
    Wheel-->Item;
    WheelView-->History;
    WheelView-->Setting;
    WheelView-->Item;
    WheelView-->Wheel;
    WheelView-->Utility;
    WheelView-->Roulette;
    History-->UserDefaultsClient;
    History-->Item;
    HistoryView-->Item;
    HistoryView-->History;
    Feedback-->Utility;
    Feedback-->APIClient;
    RouletteFeatureTests-->AppView;
```
