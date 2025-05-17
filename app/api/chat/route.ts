import { OpenAI } from "openai"
import { NextResponse } from "next/server"

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: Request) {
  try {
    const { messages, context } = await request.json()

    if (!messages || !Array.isArray(messages)) {
      return NextResponse.json({ error: "Invalid messages format" }, { status: 400 })
    }

    // Create system message with context
    const systemMessage = {
      role: "system",
      content: `You are an AI assistant that helps users understand their documents. 
      Use the following document context to answer the user's questions. 
      If the answer cannot be found in the documents, say so politely.
      
      Document Context:
      ${context || "No documents provided."}`,
    }

    // Add system message to the beginning of the messages array
    const messagesWithContext = [systemMessage, ...messages]

    // Generate response using OpenAI
    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: messagesWithContext,
      temperature: 0.7,
      max_tokens: 1000,
    })

    return NextResponse.json({
      success: true,
      response: completion.choices[0].message.content,
    })
  } catch (error) {
    console.error("Error in chat API:", error)
    return NextResponse.json(
      {
        success: false,
        error: "Failed to generate response. Please try again.",
      },
      { status: 500 },
    )
  }
}
