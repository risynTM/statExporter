const string MenuTitle = "Stat Explorer Settings";
string mapChangeUid = "";
string mapProcessUid = "";
uint64 mapChangedTimestamp;
const uint64 timeoutTime = 5;
[Setting hidden]
bool isDebugMode = false;

void Main() {
#if DEPENDENCY_CHAMPIONMEDALS
    return;
#else
    NotifyDependency("Champion Medals are supported!");
    return;
#endif

#if DEPENDENCY_WARRIORMEDALS
    return;
#else
    NotifyDependency("Warrior Medals are supported!");
    return;
#endif
}

void RenderInterface() {
    if (isDebugMode) {
        if (UI::Begin("statExplorer - debug")) {
            UI::Columns(2);

            UI::Text("Processed UID:");
            UI::Text("New UID:");
            UI::Text("Changed UID:");
            UI::Text("Map change timestamp:");
            UI::Text("GrindingStats file edit timestamp:");
            UI::Text("Current timestamp:");
            UI::Text("New map TMX-Id:");
            UI::Text("Map name:");
            UI::Text("Medal Id:");
            UI::Text("PB:");
            
            UI::NextColumn();
            UI::Text("" + mapProcessUid);
            UI::Text("" + newMapUid);
            UI::Text("" + mapChangeUid);
            UI::Text("" + mapChangedTimestamp);
            UI::Text("" + fileStamp);
            UI::Text("" + currentTimeStamp);
            UI::Text("" + newMapTMXId);
            UI::Text("" + mapName);
            UI::Text("" + medalId);
            UI::Text("" + time);
        }
        UI::End();
    }
}

int cmTime = 0;
int wmTime = 0;
void UpdateCustomMedalTimes(){
    cmTime = 0;
    wmTime = 0;
#if DEPENDENCY_WARRIORMEDALS
    wmTime = WarriorMedals::GetWMTimeAsync();
#endif
#if DEPENDENCY_CHAMPIONMEDALS
    cmTime = ChampionMedals::GetCMTime();
#endif
}

string newMapUid = "";
int newMapTMXId;
uint64 fileStamp;
uint64 currentTimeStamp;
Json::Value mapDetailJson;
string mapName;
void Update(float dt) {
    auto app = GetApp();
#if TMNEXT
    auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
    newMapUid = !(playground is null) && !(playground.Map is null) ? playground.Map.IdName : "";
#endif
    if (mapChangeUid != newMapUid) {
        if (newMapUid != "") {
            // gets the TMX id and map name when loading into a map, doesn't update on leaving a map
            try {
            newMapTMXId = ManiaExchange::GetCurrentMapID();
            mapDetailJson = ManiaExchange::GetCurrentMapInfo();
            mapName = mapDetailJson.Get("GbxMapName");
            } catch {
                NotifyError("Error getting data from Trackmania Exchange");
                // Stop execution ??
            }
            UpdateCustomMedalTimes();
        }
            
        mapChangeUid = newMapUid;
        // detect the player leaving a map by checking if the new map is empty and get a timestamp for the file check timeout
        // works because in between maps and when going to menu there is a time where you aren't on a map
        if (newMapUid == "") mapChangedTimestamp = Time::Stamp;
    }

    // check if the last map that was processed is different from the map (or menu) the player changed to
    if (mapProcessUid != mapChangeUid && app.Editor is null) {
        // when loading the first map of the session it is not necessary to collect stats as no run has been submitted yet
        if (mapProcessUid == "") {
            mapProcessUid = mapChangeUid;
            return;
        }
        
        auto folderLocation = IO::FromDataFolder("PluginStorage/GrindingStats/data");
        auto jsonFile = folderLocation + "/" + mapProcessUid + ".json";

        currentTimeStamp = Time::Stamp;
        auto isTimeout = currentTimeStamp - mapChangedTimestamp >= timeoutTime;

        if (!IO::FileExists(jsonFile) && isTimeout) {
            NotifyWarning("File for " + mapProcessUid + " didn't exist in time");
            mapProcessUid = mapChangeUid;
            return;
        } 
        
        fileStamp = IO::FileModifiedTime(jsonFile);
        // print("FILESTAMP --------> ");
        
        if ((currentTimeStamp - fileStamp < timeoutTime) && (newMapTMXId > 0)) {
            GatherData();
            mapProcessUid = mapChangeUid;
        } else if (isTimeout) {
            NotifyWarning("File for " + mapProcessUid + " didn't update in time");
            mapProcessUid = mapChangeUid;
        }
    }
    // NotifyError("HUH???");
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

[Setting hidden]
string api_url = "";
[Setting hidden]
string api_key = "";
[Setting hidden]
bool prioritizeWR = false;
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
    UI::Separator();
    UI::Checkbox("Prioritize world record", prioritizeWR);
}

void DrawDebugTab() {
    isDebugMode = UI::Checkbox("enable debug UI", isDebugMode);
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

int medalId;
uint time;
uint tries;
uint playtime;
void GatherData() {
    Net::HttpRequest request;   
    request.Headers.Set("Content-Type", "application/json");
    request.Headers.Set("ApiKey", api_key);
    // gather data here 
    ReadGrindingStatsFile();
    // uid //maybe add this as an alternative??? <-------------------------------------------
    // tmxId -> newMapTMXId,
    // map name -> mapName,
    // tries -> tries,
    // playtime -> playtime
    // medal format:
    // 0 - none
    // 1 - bronze
    // 2 - silver
    // 3 - gold
    // 4 - author
    // 5 - champion
    // 6 - WR
    // 7 - warrior

    time = GetPB(); 
    medalId = GetMedalId();

    auto jsonBody = Json::Object();
    jsonBody["id"] = newMapTMXId;
    jsonBody["name"] = mapName;
    jsonBody["time"] = time; 
    jsonBody["medal"] = medalId;
    jsonBody["tries"] = tries;
    jsonBody["playtime"] = playtime;

    request.Body = Json::Write(jsonBody);

    request.Url = api_url;
    startnew(CoroutineFuncUserdata(RequestHandler), request); 
}

void ReadGrindingStatsFile() {
    auto folderLocation = IO::FromDataFolder("PluginStorage/GrindingStats/data");
    auto jsonFile = folderLocation + "/" + mapProcessUid + ".json";
    if (IO::FileExists(jsonFile)) {
        auto content = Json::FromFile(jsonFile);
        tries = Text::ParseUInt64(content.Get('resets', "0"));
        playtime = Text::ParseUInt64(content.Get('time', "0"));
    }
}

void RequestHandler(ref@ arg) {
    auto request = cast<Net::HttpRequest>(arg);
    request.Method = Net::HttpMethod::Post;
    request.Start();
    while(!request.Finished()) {
        yield();
    }
    if (request.ResponseCode() == 200) {
        Notify("Request successful");
        return;
    }
    if (request.ResponseCode() == 0) {
        NotifyWarning("No API-enpoint found");
        return;
    }
    NotifyWarning("Request failed. Response: " + request.ResponseCode() + " See log for more info.");
    print("Request failed. Response: " + request.Body);
}

int GetMedalId() {
    auto app = cast<CTrackMania@>(GetApp());
    auto rootMap = app.RootMap;
    auto scoreMgr = GetScoreMgr(app);
    int medal = -1;
    uint nandoMedal;
    if (scoreMgr is null) {
        return -1;
    }
    if (time == 4294967295 || time == 0) {
        return 0;
    }
    print("Pb: " + time);
    print("Nandomedal: " + scoreMgr.Map_GetMedal(UserId, mapProcessUid, "PersonalBest", "", "TimeAttack", ""));
    // uint medalC = ; // get champion medal Time somehow
    bool isWr = IsWR();

    // !!!!!!!!!
    // check if CM/WM time gets returned correctly when leaving a map to menu
    // !!!!!!!!!
    if (prioritizeWR && isWr) {
        return 6;
    }

#if DEPENDENCY_WARRIORMEDALS
    if (wmTime != 0 && time <= wmTime) {
        medal = 7;
    }
#endif
#if DEPENDENCY_CHAMPIONMEDALS
    if (cmTime != 0 && time <= cmTime) {
        medal = 5;
    }
#endif

    // return Nando medal ID if above don't apply
    if (medal == -1){
        nandoMedal = scoreMgr.Map_GetMedal(UserId, mapProcessUid, "PersonalBest", "", "TimeAttack", "");
        medal = nandoMedal;
    }
    return medal;
}

bool IsWR() {
    string url = "https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/map?scores[";
    url = url + mapProcessUid + "]" + "=" + cast<string>(time); 

    Net::HttpRequest request;
    request.Headers.Set("Content-Type", "application/json");
    request.Headers.Set("User-Agent", "statExporter Plugin/ @risyn_1 / mail@risyn.art");

    auto maps = Json::Array();
    string mapString = "\"mapUid\": \"" + mapProcessUid + "\", \"groupUid\": \"Personal_Best\"";  
    auto map = Json::Parse(mapString);
    maps.Add(map);

    request.Body = Json::Write(maps);
    request.Url = url;
    auto requestCoroutine = startnew(CoroutineFuncUserdata(RequestHandler), request);
    await(requestCoroutine);

    requestAnswer = request.Json();
    if (Json::Write(requestAnswer.Get("position")) == "1") {
        return true;
    }
    return false;
}

uint GetPB() {
    auto app = cast<CTrackMania@>(GetApp());
    auto rootMap = app.RootMap;
    auto scoreMgr = GetScoreMgr(app);
    if (scoreMgr is null) {
        return -1;
    }
    uint pb = scoreMgr.Map_GetRecord_v2(UserId, mapProcessUid, "PersonalBest", "", "TimeAttack", "");
    if (pb == 4294967295) {
        return 0;
    }
    return pb;
}

CGameScoreAndLeaderBoardManagerScript@ GetScoreMgr(CTrackMania@ app) {
    try {
        return app.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr;
    } catch {
        return null;
    }
}

MwId UserId {
    get {
        // auto userMgr = GetApp().Network.ClientManiaAppPlayground.UserMgr;
        auto app = cast<CTrackMania@>(GetApp());
        auto userMgr = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr;
        if (userMgr is null || userMgr.Users.Length < 1) return MwId(256);
        return userMgr.Users[0].Id;
    }
}