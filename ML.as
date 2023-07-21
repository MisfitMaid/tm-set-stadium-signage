namespace ML {
    // See https://wiki.trackmania.io/en/ManiaScript/UI-Manialinks/Manialinks
    const string quadTemplate = """
<frame id="frame-global" z-index="-2" hidden="0">
    <quad id="quad-sign" image=":url" size=":size_x :size_y" z-index="0" halign="center" valign="center" bgcolor="000000" />
    <label text=":label_text" size=":size_x :size_y" opacity="1" textsize=":l_textsize" textcolor="ffffffff" textemboss="1" halign="center" valign="center" />
</frame>

<script><!--
main() {
    yield;

    declare Quad_Sign <=> (Page.GetFirstChild("quad-sign") as CMlQuad);
    declare origUrl = Quad_Sign.ImageUrl;
    // declare secondUrl = "https:/"^"/i.imgur.com/VP9V8Ya.jpeg";
    declare secondUrl = "https:/"^"/i.imgur.com/cVsYOXy.png";

    declare Integer lastRun = Now;

    while (True) {
        yield;
        if (Now - lastRun > 30000 && :swap_urls_bool) {
            Quad_Sign.ImageUrl = secondUrl;
            secondUrl = origUrl;
            origUrl = Quad_Sign.ImageUrl;
            lastRun = Now;
        }
    }
}
--></script>
""";

    string GenQuad(const string &in url, float size_x = 320, float size_y = 50, const string &in labelText = "This pleases you?") {
        return quadTemplate.Replace(':url', url)
            .Replace(":size_x", tostring(size_x))
            .Replace(":size_y", tostring(size_y))
            .Replace(":label_text", labelText)
            .Replace(":l_textsize", tostring(size_x / float(labelText.Length) * 1.8))
            .Replace(":swap_urls_bool", (size_x == 120 && size_y == 180) ? "True" : "False")
            ;
    }

    void OnEnterPlayground() {
        if (GetApp().Network.ClientManiaAppPlayground is null) return;
        auto cmap = GetApp().Network.ClientManiaAppPlayground;
        AddMLPagesToManiaApp(cmap);
    }

    void OnEnterEditor() {
        // Doesn't work / do anything
        // while (cast<CGameCtnEditorFree>(GetApp().Editor) is null) yield();
        // auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        // AddMLPagesToManiaApp(editor.PluginMapType);
        // AddMLPagesToManiaApp(editor.MainPLugin);
    }

    void AddMLPagesToManiaApp(CGameManiaApp@ ma) {
        if (ma.UILayers.Length < 2) yield();
        CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Checkpoint");
        CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Finish");
        CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Start");
        CreateOrUpdateMLPage(ma, GenQuad(Sign2x3, 120, 180), "2x3_Stadium");
        CreateOrUpdateMLPage(ma, GenQuad(Sign16x9, 320, 180), "16x9_Stadium");
        CreateOrUpdateMLPage(ma, GenQuad(Sign16x9, 320, 180), "16x9_StadiumSmall");
    }

    CGameUILayer@ CreateOrUpdateMLPage(CGameManiaApp@ ma, const string &in pageSrc, const string &in attachId = "") {
        auto layer = GetOrCreateLayer(ma, attachId, CGameUILayer::EUILayerType::ScreenIn3d);
        layer.ManialinkPageUtf8 = pageSrc;
        layer.AttachId = attachId;
        layer.Type = CGameUILayer::EUILayerType::ScreenIn3d;
        return layer;
    }

    CGameUILayer@ GetOrCreateLayer(CGameManiaApp@ ma, const string &in attachId, CGameUILayer::EUILayerType type) {
        for (uint i = 0; i < ma.UILayers.Length; i++) {
            auto layer = ma.UILayers[i];
            if (layer.AttachId == attachId && layer.Type == type) {
                return layer;
            }
        }
        return ma.UILayerCreate();
    }
}
