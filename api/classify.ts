import type { NextApiRequest, NextApiResponse } from "next";
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // make sure this is set in Vercel
});

const categories = [
  "Food", "Quotes", "Music", "Sports",
  "News", "Events", "Work", "Travel",
  "Shopping", "Health", "Finance", "Other"
];

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { text } = req.body;

  if (!text || typeof text !== "string") {
    return res.status(400).json({ error: "Missing text" });
  }

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini", // fast + cheap
      messages: [
        {
          role: "system",
          content: `You are a classifier. Categorize the following text into exactly ONE of these categories: ${categories.join(", ")}. Return only the category name.`
        },
        {
          role: "user",
          content: text,
        },
      ],
      max_tokens: 10,
      temperature: 0,
    });

    const category = response.choices[0]?.message?.content?.trim() || "Other";

    // Validate against list
    const validCategory = categories.includes(category) ? category : "Other";

    return res.status(200).json({ category: validCategory });
  } catch (err: any) {
    console.error("❌ OpenAI classify error:", err.message);
    return res.status(500).json({ category: "Other" });
  }
}

