// QIPLUS Conference runtime configuration. This file is appended to config.js
// by the web image entrypoint, after the standard Docker configuration.
config.dynamicBrandingUrl = 'static/qiplus-branding.json';

config.deeplinking = {
    ...(config.deeplinking || {}),
    disabled: true
};