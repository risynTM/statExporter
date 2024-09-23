const string MenuTitle = "Stat Explorer Settings"

void Main() {
    return;
}

bool isOpen = false;
void RenderMenu() {
    if (UI::MenuItem("Stat Exporter Settings")){
        isOpen != isOpen;
    }
}

void RenderInterface() {
    // RenderMainUI();
    if (UI::Begin(MenuTitle,isOpen)) {
        UI::Text("test");
    }
    UI::End();
}