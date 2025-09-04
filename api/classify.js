export default async function handler(req, res) {
  try {
    const { text } = req.body;

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a screenshot classifier. Categories: Meme, Quote, News, Personal, Promotion, Other. Classify the following text into ONE category." },
          { role: "user", content: text }
        ],
        max_tokens: 10
      })
    });

    const data = await response.json();
    const category = data.choices?.[0]?.message?.content?.trim() || "Other";

    res.status(200).json({ category });
  } catch (err) {
    console.error(err);
    res.status(500).json({ category: "Other", error: "Classification failed" });
  }
}
