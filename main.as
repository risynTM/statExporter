const string MenuTitle = "Stat Explorer Settings";
string mapChangeUid = "";
string mapProcessUid = "";
uint64 mapChangedTimestamp;
const uint64 timeoutTime = 5000;
bool isDebugMode = false;

void Main() {
    return;
}

void RenderInterface() {
    if (isDebugMode) {
        if (UI::Begin("statExplorer - debug")) {
            UI::Text(mapProcessUid);
            UI::Text(newMapUid);
            UI::Text(mapChangeUid);
            UI::Text("" + mapChangedTimestamp);
            UI::Text("" + fileStamp);
            UI::Text("" + currentTimeStamp);
        }
        UI::End();
    }
}

string newMapUid = "";
uint64 fileStamp;
uint64 currentTimeStamp;
void Update(float dt) {
    auto app = GetApp();
#if TMNEXT
    auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
    newMapUid = !(playground is null) && !(playground.Map is null) ? playground.Map.IdName : "";
#endif
    if (mapChangeUid != newMapUid) {
        mapChangeUid = newMapUid;
        if (newMapUid == "") mapChangedTimestamp = Time::Stamp;
    }

    if (mapProcessUid != mapChangeUid && app.Editor is null) {
        if (mapProcessUid == "") {
            mapProcessUid = mapChangeUid;
            return;
        }
        
        auto folderLocation = IO::FromDataFolder("Grinding Stats");
        auto jsonFile = folderLocation + "/" + mapProcessUid + ".json";

        currentTimeStamp = Time::Stamp;
        auto isTimeout = currentTimeStamp - mapChangedTimestamp >= timeoutTime;

        if (!IO::FileExists(jsonFile) && isTimeout) {
            NotifyWarning("File for " + mapProcessUid + " didn't exist in time");
            mapProcessUid = mapChangeUid;
            return;
        } 
        
        fileStamp = IO::FileModifiedTime(jsonFile);
        
        if (currentTimeStamp - fileStamp < timeoutTime) {
            Notify(mapProcessUid); //delete, fuck you, you don't get a space between "//" and delete
            mapProcessUid = mapChangeUid;
        } else if (isTimeout) {
            NotifyWarning("File for " + mapProcessUid + " didn't update in time");
            mapProcessUid = mapChangeUid;
        }
    }
}



[SettingsTab name="statExporter settings"]
void RenderSettingstab() {
    UI::BeginTabBar("settings_tabs", UI::TabBarFlags::AutoSelectNewTabs);
    if (UI::BeginTabItem("settings")) {
        DrawSettingsTab();
        UI::EndTabItem();
    }
    if (UI::BeginTabItem("debug")) {
        DrawDebugTab();
        UI::EndTabItem();
    }
    UI::EndTabBar();
}


string api_url = "";
string api_key = "";
bool show_settings = false;
bool show_confirm_window = false;
string button_text = "Show API details";
void DrawSettingsTab() {
    
    // show_settings = UI::Checkbox("Show hidden settings", show_settings);
    // show_settings = ConfirmShowSettings();
    if (show_settings){
        button_text = "Hide API details";
    } else {
        button_text = "Show API details";
    }

    if (UI::Button(button_text)) {
        show_confirm_window = true;
    }
    if (show_confirm_window){
        ConfirmShowSettings();
    }
    
    if (show_settings){
        api_url = Text::OpenplanetFormatCodes(UI::InputText("Api Url", api_url));
        api_key = Text::OpenplanetFormatCodes(UI::InputText("Api Key", api_key, UI::InputTextFlags::Password)); 
    }
    
    if (UI::Button("save")) SaveSettingsTab();
}

void DrawDebugTab() {
    isDebugMode = UI::Checkbox("enable debug UI", isDebugMode);
}

void SaveSettingsTab() {
    Notify("test");
}


void ConfirmShowSettings() {
    if (show_settings) {
        show_settings = false;
        show_confirm_window = false;
        return;
    }
    if (UI::Begin("ARE YOU SURE??????")) {
        UI::Text("Do you want to (potentially) expose your API details?");
        if (UI::Button("yes")) {
            show_settings = true;
            show_confirm_window = false;
        }
        if (UI::Button("no")){
            show_settings = false;
            show_confirm_window = false;
        }
    }
    UI::End();
}