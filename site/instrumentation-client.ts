import posthog from "posthog-js";

const EVENT_PREFIX = "touch_grass_";

const projectToken = process.env.NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN;
const host = process.env.NEXT_PUBLIC_POSTHOG_HOST;

if (!projectToken && process.env.NODE_ENV === "development") {
  throw new Error(
    "NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN variable required by PostHog is missing or un-configured, this causes events to be silently missed. This error stops appearing once NEXT_PUBLIC_POSTHOG_PROJECT_TOKEN is configured",
  );
}

if (!host && process.env.NODE_ENV === "development") {
  throw new Error(
    "NEXT_PUBLIC_POSTHOG_HOST variable required by PostHog is missing or un-configured, this causes events to be silently missed. This error stops appearing once NEXT_PUBLIC_POSTHOG_HOST is configured",
  );
}

if (projectToken && host) {
  posthog.init(projectToken, {
    api_host: host,
    defaults: "2026-01-30",
    capture_exceptions: true,
    debug: process.env.NODE_ENV === "development",
    // Ensure every custom event carries the touch_grass_ prefix. PostHog's
    // own `$`-prefixed events ($pageview, $exception, ...) are left alone so
    // built-in dashboards keep working; they're tagged via `app` below.
    before_send: (event) => {
      if (event && !event.event.startsWith("$") && !event.event.startsWith(EVENT_PREFIX)) {
        event.event = `${EVENT_PREFIX}${event.event}`;
      }
      return event;
    },
  });
  posthog.register({ app: "touch_grass" });
}
