import type { NextApiRequest, NextApiResponse } from "next";

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

Base categories:
- Meme
- Quote
- News
- Personal
- Promotion

Rules:
1. If text clearly matches one of the base categories, return that.
2. If not, create a short dynamic category (e.g. brand, username, topic).
3. Always return ONE category name only, no explanations.
            `,
          },
          { role: "user", content: text },
        ],
        max_tokens: 10,
      }),
    });

    const data = await response.json();
    const category =
      data.choices?.[0]?.message?.content?.trim() || "Other";

    res.status(200).json({ category });
  } catch (err) {
    console.error("❌ classify API error:", err);
    res.status(500).json({ category: "Other", error: "Classification failed" });
  }
}
