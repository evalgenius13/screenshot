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

// 🔹 Strip common social media UI clutter but KEEP hashtags
const socialUIPatterns = [
  /\d+•\s*Sp\s*Your story Live/gi,
  /\d+\s*hours ago/gi,
  /Liked by .* and \d+ others/gi,
  /Add comment.*/gi,
  /Your story/gi,
  /Instagram/gi,
  /Facebook/gi,
  /Twitter/gi,
  /Reply/gi,
  /Repost/gi
]

function cleanOCR(text: string): string {
  let cleaned = text
  socialUIPatterns.forEach(p => {
    cleaned = cleaned.replace(p, '')
  })
  return cleaned.trim()
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const requestStart = Date.now()

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Normalize body (fix parse errors on Vercel)
    let body: any = req.body
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body)
      } catch {
        return res.status(400).json({ error: 'Invalid JSON body' })
      }
    }

    const { text } = body
    if (!text || typeof text !== 'string') {
      return res.status(400).json({ error: 'Invalid or missing text' })
    }

    // Clean OCR input
    const cleanText = cleanOCR(text)

    const prompt = `
Classify the following social media post into ONE of these categories:
${CATEGORIES.join(", ")}

Rules:
- Focus on the main content (captions, hashtags, or quotes).
- Ignore usernames, likes, timestamps, and app UI elements.
- Pay special attention to hashtags as strong category signals (e.g. #fitness, #ootd, #foodie).
- Return exactly one category from the list above.
- If nothing fits, return "Other".

Text: """${cleanText}"""
`

    const start = Date.now()
    const response = await client.chat.completions.create({
      model: 'gpt-4o',   // ✅ best accuracy for MVP
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 10,
      temperature: 0
    })

    console.log("⏱ GPT classify duration:", Date.now() - start, "ms")

    // ✅ Whitelist validation
    let category = response.choices[0].message?.content?.trim() || "Other"
    const validCategory = CATEGORIES.includes(category) ? category : "Other"

    console.log("⏱ Total request duration:", Date.now() - requestStart, "ms")
    console.log("🔍 Input length:", cleanText.length, "chars")
    console.log("✅ Classified:", validCategory)

    res.status(200).json({ category: validCategory })
  } catch (err: any) {
    console.error("❌ classify API error:", err.response?.data || err.message)
    res.status(500).json({ error: 'OpenAI request failed' })
  }
}
