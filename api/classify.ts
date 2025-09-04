import type { NextApiRequest, NextApiResponse } from "next";

const BASE_CATEGORIES = [
  "Meme",
  "Quote",
  "News",
  "Promotion",
  "Personal",
];

// 🔹 You can extend this list without touching iOS code
const CUSTOM_CATEGORIES = [
  "Sports",
  "MusicProduction",
];

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { text } = req.body;

    if (!text || typeof text !== "string") {
      return res.status(400).json({ error: "Missing text" });
    }

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${process.env.OPENAI_API_KEY!}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: `
You are a screenshot classifier.

Known categories:
${BASE_CATEGORIES.join(", ")}, ${CUSTOM_CATEGORIES.join(", ")}

Rules:
1. If text clearly matches one of the known categories, return that.
2. If text contains a username, handle, or brand (e.g. "justwomenssports"), return that exact name as the category.
3. If text references sports teams, games, scores → return Sports.
4. If text references music software, FL Studio, DAWs, instruments → return MusicProduction.
5. If nothing fits, return "Other".
6. Always return exactly ONE short category name, no sentences.
            `,
          },
          { role: "user", content: text },
        ],
        max_tokens: 10,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("❌ OpenAI API error:", errorText);
      return res.status(500).json({ category: "Other", error: "OpenAI API error" });
    }

    const data = await response.json();
    const category =
      data.choices?.[0]?.message?.content?.trim() || "Other";

    res.status(200).json({ category });
  } catch (err) {
    console.error("❌ classify API error:", err);
    res.status(500).json({ category: "Other", error: "Classification failed" });
  }
}
