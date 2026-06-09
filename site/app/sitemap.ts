import type { MetadataRoute } from "next";
import { SITE_URL, ROUTES } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();
  return ROUTES.map((r) => ({
    url: new URL(r.path, SITE_URL).toString(),
    lastModified,
    changeFrequency: r.changeFrequency,
    priority: r.priority,
  }));
}
