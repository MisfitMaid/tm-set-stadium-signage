[Setting name="Bigass 16x9 stadium sign"]
string Sign16x9 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/16x9.dds";

[Setting name="Square club decal under checkpoints"]
string SignClubLogo = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/decal.png";

[Setting name="4x1 'sponsor' Decal (checkpoints and spectator stands usually)"]
string Sign4x1 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/4x1.png";

[Setting name="Vertical stadium sign with 'TRACK MAN'"]
string Sign2x3 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/2x3.png";

[Setting name="8x1 grandstands sign"]
string Sign8x1 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/8x1.dds";

[Setting name="16x1 strip under the bigass sign"]
string Sign16x1 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/16x1.dds";

[Setting name="64x10 on Start / CP / Fin"]
string Sign64x10 = "https://misfitmaid.github.io/tm-set-stadium-signage/img/defaults/64x10.png";

[Setting name="Set from Club" hidden]
uint64 idClub = 18618;

[SettingsTab name="Set from Club"]
void SettingsTabSetFromClubID() {
	UI::TextWrapped("This will set your signage to that of any particular club ID you specify. Note that this will not adjust 64x10 checkpoint signs.");

	idClub = UI::InputInt("Club ID", idClub);
	if (UI::Button(Icons::Download + " Fetch resources")) {
		startnew(saveClubAssets, idClub);
	}

	UI::TextWrapped("You will need to restart the map to see the changes update.");
}

void saveClubAssets(uint64 idClub) {
	trace("fetching club asset URLs...");
	NadeoServices::AddAudience("NadeoLiveServices");
	while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();

	auto req = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + "/api/token/club/" + Text::Format("%d", idClub));
	req.Start();

	while (!req.Finished()) yield();

	Json::Value data = req.Json();

	if (data.GetType() != Json::Type::Object) {
		error("unexpected response from nano, check network log and report if needed");
	} else {
		Sign4x1 = data["decalSponsor4x1Url"];
		Sign2x3 = data["verticalUrl"]; // not quite a perfect fit but close enough tbh.
		Sign16x9 = data["screen16x9Url"];
		Sign8x1 = data["screen8x1Url"];
		Sign16x1 = data["screen16x1Url"];
		SignClubLogo = data["decalUrl"];
		Meta::SaveSettings();

		UI::ShowNotification("Set Stadium Signage", "Successfully imported assets from club " + string(data["name"]) + ". You may need to restart the map.");

	}
}

string currentMapUid;

void Main() {
	// startnew(saveClubAssets, idClub);
	startnew(WatchForEditorPg);
	while (true) {
	    CTrackMania@ app = cast<CTrackMania>(GetApp());

    	string mapUid;
        if (app.RootMap is null) { // || !app.RootMap.MapInfo.IsPlayable || app.Editor !is null) {
    	    mapUid = "";
    	} else {
	        mapUid = app.RootMap.MapInfo.MapUid;
    	}

    	if(mapUid != currentMapUid) {
        	currentMapUid = mapUid;
        	OnNewMap();
    	}
		yield();
	}
}

void WatchForEditorPg() {
	while (true) {
		yield();
		while (cast<CGameCtnEditorFree>(GetApp().Editor) is null) yield();
		while (cast<CGameCtnEditorFree>(GetApp().Editor) !is null && GetApp().CurrentPlayground is null) yield();
		if (GetApp().CurrentPlayground !is null) {
			startnew(OnNewMap);
		}
		while (GetApp().CurrentPlayground !is null) yield();
		// might need to reset deco when going from PG -> Editor
		startnew(OnNewMap);
	}
}

void OnNewMap() {
	startnew(ML::OnEnterPlayground);
	if (cast<CGameCtnEditorFree>(GetApp().Editor) !is null) {
		startnew(ML::OnEnterEditor);
	}

	auto ps = cast<CSmArenaRulesMode@>(GetApp().PlaygroundScript);

	if (ps is null) return;

	if (Sign4x1 != "") {
		ps.SetDecoImageUrl_DecalSponsor4x1(Sign4x1);
	}

	if (Sign16x9 != "") {
		ps.SetDecoImageUrl_Screen16x9(Sign16x9);
	}

	if (Sign8x1 != "") {
		ps.SetDecoImageUrl_Screen8x1(Sign8x1);
	}

	if (Sign16x1 != "") {
		ps.SetDecoImageUrl_Screen16x1(Sign16x1);
	}

	if (SignClubLogo != "") {
		ps.SetClubLogoUrl(SignClubLogo);
	}

	trace("overrided stadium signs :)");
}
