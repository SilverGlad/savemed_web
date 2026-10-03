{{flutter_js}}
{{flutter_build_config}}

const reportStartupError = (error) => {
  console.error('SaveMed could not start', error);
  window.dispatchEvent(new Event('savemed-app-error'));
};

_flutter.loader
  .load({
    config: {
      canvasKitBaseUrl: 'canvaskit/',
    },
    onEntrypointLoaded: async (engineInitializer) => {
      try {
        const appRunner = await engineInitializer.initializeEngine();
        await appRunner.runApp();
        await new Promise((resolve) =>
          requestAnimationFrame(() => requestAnimationFrame(resolve)),
        );
        window.dispatchEvent(new Event('savemed-app-ready'));
      } catch (error) {
        reportStartupError(error);
      }
    },
  })
  .catch(reportStartupError);
