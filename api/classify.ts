import type { VercelRequest, VercelResponse } from '@vercel/node'
import OpenAI from 'openai'

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
})

const CATEGORIES = [
  "Food & Recipes",
  "Fashion & Style",
  "Fitness & Health",
  "Home & Decor",
  "Beauty",
  "Travel",
  "Quotes & Motivation",
  "Business & Career",
  "Relationships & Dating",
  "Entertainment",
  "Finance",
  "Education",
  "Parenting",
  "Pets",
  "Technology",
  "Art & Creativity",
  "Music",
  "Sports",
  "Other"
]

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestStart = Date.now()

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // 🔹 Normalize body (fix parse error)
    let body: any = req.body;
    if (typeof body === "string") {
      try {
        body = JSON.parse(body);
      } catch {
        return res.status(400).json({ error: "Invalid JSON body" });
      }
    }

    const { text } = body;

    if (!text) {
      return res.status(400).json({ error: "No text provided" })
    }

    const prompt = `
Classify the following social media post into ONE of these categories:
${CATEGORIES.join(", ")}

Rules:
- Always return exactly one category string, no sentences.
- If multiple categories could apply, choose the closest match.
- If nothing fits, return "Other".
Text: """${text}"""
`

    const start = Date.now()
    const response = await client.chat.completions.create({
      model: 'gpt-4o-mini',  // ✅ use mini for speed, switch to gpt-4o for MVP demo
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 10,
      temperature: 0
    })
    console.log("⏱ GPT classify duration:", Date.now() - start, "ms")

    const category = response.choices[0].message?.content?.trim() || "Other"
    console.log("⏱ Total request duration:", Date.now() - requestStart, "ms")

    res.status(200).json({ category })
  } catch (err: any) {
    console.error("❌ classify API error:", err.response?.data || err.message)
    res.status(500).json({ error: 'OpenAI request failed' })
  }
}
