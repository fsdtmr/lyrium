{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
        let appRunner = await engineInitializer.initializeEngine({
            hostElement: document.querySelector("#flutterview"),
        });
        await appRunner.runApp();
    },
});

self.addEventListener("install", (event) => {
    event.waitUntil(
        caches.open("flutter-app-cache").then((cache) => {
            return cache.addAll([
                "/",
                "/index.html",
                "/main.dart.js",
            ]);
        })
    );
});

self.addEventListener("fetch", (event) => {
    event.respondWith(
        caches.match(event.request).then((cachedResponse) => {
            if (cachedResponse) {
                return cachedResponse;
            }
            return fetch(event.request);
        })
    );
});
