namespace ML {
    const string quadTemplate = """
<frame id="frame-global" z-index="-2" hidden="0">
    <quad image=":url" size="320 50" z-index="0" halign="center" valign="center" bgcolor="000000" />
</frame>
""";

    string GenQuad(const string &in url) {
        return quadTemplate.Replace(':url', url);
    }

    void OnEnterPlayground() {
        while (GetApp().Network.ClientManiaAppPlayground is null) yield();
        auto cmap = GetApp().Network.ClientManiaAppPlayground;
        while (cmap.UILayers.Length < 2) yield();
        CreateMLPage(cmap, GenQuad(Sign64x10), "64x10_Checkpoint");
        CreateMLPage(cmap, GenQuad(Sign64x10), "64x10_Finish");
        CreateMLPage(cmap, GenQuad(Sign64x10), "64x10_Start");
        CreateMLPage(cmap, GenQuad(Sign16x9), "2x3_Stadium");
    }

    CGameUILayer@ CreateMLPage(CGameManiaApp@ ma, const string &in pageSrc, const string &in attachId = "") {
        auto layer = ma.UILayerCreate();
        layer.ManialinkPageUtf8 = pageSrc;
        layer.AttachId = attachId;
        layer.Type = CGameUILayer::EUILayerType::ScreenIn3d;
        return layer;
    }
}
