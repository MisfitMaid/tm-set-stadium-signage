namespace ML {
    // See https://wiki.trackmania.io/en/ManiaScript/UI-Manialinks/Manialinks
    const string quadTemplate = """
<frame id="frame-global" z-index="-2" hidden="0">
    <quad id="quad-sign" image=":url" size=":size_x :size_y" z-index="0" halign="center" valign="center" bgcolor="000000" />
</frame>
""";

    string GenQuad(const string &in url, float size_x = 320, float size_y = 50) {
        return quadTemplate.Replace(':url', url)
            .Replace(":size_x", tostring(size_x))
            .Replace(":size_y", tostring(size_y))
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
        if (Sign64x10 != "") {
            CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Checkpoint");
            CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Finish");
            CreateOrUpdateMLPage(ma, GenQuad(Sign64x10, 320, 50), "64x10_Start");
        }
        if (Sign2x3 != "") {
            CreateOrUpdateMLPage(ma, GenQuad(Sign2x3, 120, 180), "2x3_Stadium");
        }
        if (Sign16x9 != "") {
            CreateOrUpdateMLPage(ma, GenQuad(Sign16x9, 320, 180), "16x9_Stadium");
            CreateOrUpdateMLPage(ma, GenQuad(Sign16x9, 320, 180), "16x9_StadiumSmall");
        }
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
