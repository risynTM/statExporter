void RenderMainUI() {
    vec2 size = vec2(1200, 700);
    vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::FirstUseEver);
    if (UI::Begin(MenuTitle)){
        
    }
    UI::End();
}