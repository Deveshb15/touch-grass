import type { MetadataRoute } from "next";
import { NAME, DESCRIPTION } from "@/lib/site";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: NAME,
    short_name: "Touch Grass",
    description: DESCRIPTION,
    start_url: "/",
    display: "standalone",
    background_color: "#fdf3ea",
    theme_color: "#fdf3ea",
    icons: [
      { src: "/shots/icon.png", sizes: "256x256", type: "image/png", purpose: "any" },
    ],
  };
}
