bool WindowOpen = true;

const string MenuTitle = "Stat Explorer Settings"

// array<Tab@> settingsTabs;

void RenderMainUI() {
    // vec2 size = vec2(1200, 700);
    // vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    // UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    // UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::FirstUseEver);
    // if (UI::Begin(MenuTitle, WindowOpen)){
    //     UI::BeginTabBar("settings_tabs",UI::TabBarFlags::NoCloseWithMiddleMouseButton);
    //     for (uint i = 0; i < )
    // }
    // UI::End();

    // UI::Begin(MenuTitle, UI::WindowFlags::MenuBar);
    
    // if (UI::BeginMenuBar()){
    //     if (UI::BeginMenuItem("Settings")) {
    //         return
    //     }
    // }
    // UI::EndMenuBar();
    if (UI::Begin(MenuTitle,isOpen)) {
        UI::Text("test");
    }
    UI::End();
}