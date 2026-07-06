{{flutter_js}}
{{flutter_build_config}}

// TestSprite / headless browsers: skip the service worker and load CanvasKit locally.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
