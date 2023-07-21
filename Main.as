[Setting name="Bigass 16x9 stadium sign"]
string Sign16x9 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/screen_16x9/18618/63235f0b11c38.dds?updateTimestamp=1663262476.dds";

[Setting name="Square club decal under checkpoints"]
string SignClubLogo = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/decal/18618/63133d19a3627.png?updateTimestamp=1662205213.png";

[Setting name="4x1 'sponsor' Decal (checkpoints and spectator stands usually)"]
string Sign4x1 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/decal_sponsor_4x1/18618/63235e74e375c.png?updateTimestamp=1663262327.png";

[Setting name="Vertical stadium sign with 'TRACK MAN'" description="Currently doesnt work, idk :("]
string Sign2x1 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/vertical/18618/632e9902e84c8.png?updateTimestamp=1663998215.png";

[Setting name="8x1 grandstands sign"]
string Sign8x1 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/screen_8x1/18618/63235fce1bcee.dds?updateTimestamp=1663262671.dds";

[Setting name="16x1 strip under the bigass sign"]
string Sign16x1 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/screen_16x1/18618/63235e680fdad.dds?updateTimestamp=1663262313.dds";

[Setting name="64x10 on Start / CP / Fin"]
string Sign64x10 = "https://trackmania-prod-nls-file-store-s3.cdn.ubi.com/club/screen_16x1/18618/63235e680fdad.dds";

[Setting name="Set from Club" hidden]
uint64 idClub = 18618;

[SettingsTab name="Set from Club"]
void SettingsTabSetFromClubID() {
	UI::Text("This is experimental, it might be better to slurp the values from tm.io and set them urself...");

	idClub = UI::InputInt("Club ID", idClub);
	if (UI::Button("Fetch resources")) {
		startnew(saveClubAssets, idClub);
	}
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
		Sign2x1 = data["verticalUrl"];
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
	startnew(saveClubAssets, idClub);
	while (true) {
	    CTrackMania@ app = cast<CTrackMania>(GetApp());

    	string mapUid;
        if (app.RootMap is null || !app.RootMap.MapInfo.IsPlayable || app.Editor !is null) {
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

void OnNewMap() {
	startnew(ML::OnEnterPlayground);

	auto ps = cast<CSmArenaRulesMode@>(GetApp().PlaygroundScript);

	if (ps is null) return;

	if (Sign4x1 != "") {
		ps.SetDecoImageUrl_DecalSponsor4x1(Sign4x1);
	}

	if (Sign2x1 != "") {
		// ps.SetDecoImageUrl_Screen2x1(Sign2x1);
		// this doesn't seem to work when called via script, when called via nod explorer it...changes the 16x9 billboard? idfk lmao
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
