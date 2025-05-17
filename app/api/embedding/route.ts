import { OpenAI } from "openai"
import { NextResponse } from "next/server"

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: Request) {
  try {
    const { text } = await request.json()

    if (!text || typeof text !== "string") {
      return NextResponse.json({ error: "Invalid text format" }, { status: 400 })
    }

    const response = await openai.embeddings.create({
      model: "text-embedding-3-small",
      input: text.slice(0, 8000), // Limit to first 8000 chars
    })

    return NextResponse.json({
      success: true,
      embedding: response.data[0].embedding,
    })
  } catch (error) {
    console.error("Error in embedding API:", error)
    return NextResponse.json(
      {
        success: false,
        error: "Failed to generate embedding. Please try again.",
      },
      { status: 500 },
    )
  }
}
