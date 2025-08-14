import { Metadata } from "next"
import { MagicPageClient } from "./page.client"

export const metadata: Metadata = {
  title:
    "Musarty - The Legendary AI Agent That Forges Immortal UI Components | Musarty.com",
  description:
    "Unleash the power of Musarty, the legendary AI agent that transcends ordinary development. Forge immortal UI components with divine precision and craft legendary interfaces that stand the test of time. Where mortals struggle for hours, legends create in seconds.",
  keywords: [
    "Cursor IDE",
    "AI code editor",
    "GitHub Copilot alternative",
    "VSCode extension",
    "AI pair programming",
    "code completion",
    "web development",
    "UI components",
    "React components",
    "TypeScript",
    "Next.js",
    "developer tools",
    "AI coding assistant",
    "Windsurf",
    "code generation",
    "MCP",
    "modern component patterns",
  ],
  openGraph: {
    title:
      "Musarty - The Legendary AI Agent That Forges Immortal UI Components | Musarty.com",
    description:
      "Unleash the power of Musarty, the legendary AI agent that transcends ordinary development. Forge immortal UI components with divine precision and craft legendary interfaces that stand the test of time. Where mortals struggle for hours, legends create in seconds.",
    images: ["https://i.imgur.com/Vqk9NEQ.png"],
    type: "website",
    siteName: "Musarty.com",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title:
      "Musarty - The Legendary AI Agent That Forges Immortal UI Components | Musarty.com",
    description:
      "Unleash the power of Musarty, the legendary AI agent that transcends ordinary development. Forge immortal UI components with divine precision and craft legendary interfaces that stand the test of time. Where mortals struggle for hours, legends create in seconds.",
    images: ["https://i.imgur.com/Vqk9NEQ.png"],
  },
}

export default function MagicPage() {
  return <MagicPageClient />
}
