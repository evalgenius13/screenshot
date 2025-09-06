import type { NextApiRequest, NextApiResponse } from "next";
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // make sure this is set in Vercel
});

const categories = [
  "Food", "Fashion", "Home", "Beauty",
  "Fitness", "Education", "Quotes", "Music",
  "Entertainment", "Art", "Travel", "Other"
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
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: `Classify this text into exactly ONE category: ${categories.join(", ")}.

          Weighting guidelines for context-based classification:
          
          • Food - recipes, restaurants, cooking, ingredients, meals, beverages
          • Fashion - clothing, accessories, style, brands, outfits, shopping for apparel
          • Home - decor, furniture, interior design, household items, real estate
          • Beauty - cosmetics, skincare, hair care, makeup, beauty routines
          • Fitness - exercise, workouts, health apps, gym content, medical/health info
          • Education - learning, news, business, finance, tutorials, how-to content
          • Quotes - inspirational text, motivational sayings, meaningful phrases
          • Music - songs, artists, albums, concerts, music apps, audio content
          • Entertainment - movies, TV, games, sports, YouTube, social media, events
          • Art - visual arts, creativity, design, photography, artistic content
          • Travel - maps, transportation, trips, locations, hotels, navigation
          • Other - anything that doesn't clearly fit the above categories
          
          Classify based on the primary content meaning, not rigid rules. 
          Return only the category name.`
        },
        {
          role: "user",
          content: text,
        },
      ],
      max_tokens: 15,
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
