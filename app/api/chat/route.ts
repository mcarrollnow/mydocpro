import { NextResponse } from "next/server"

export async function POST(request: Request) {
  try {
    const { messages } = await request.json();

    // Combine messages into a single prompt for Anthropic
    const userMessage = messages
      .map((m: { role: string; content: string }) => `${m.role === "user" ? "Human" : "Assistant"}: ${m.content}`)
      .join("\n") + "\nAssistant:";

    const response = await fetch("https://api.anthropic.com/v1/complete", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": process.env.ANTHROPIC_API_KEY!,
        "anthropic-version": "2023-06-01"
      },
      body: JSON.stringify({
        model: "claude-3-opus-20240229", // or another Claude model if you prefer
        prompt: userMessage,
        max_tokens_to_sample: 1024,
        temperature: 0.7
      }),
    });

    const data = await response.json();

    return NextResponse.json({
      success: true,
      response: data.completion,
    });
  } catch (error) {
    console.error("Error in chat API:", error);
    return NextResponse.json(
      {
        success: false,
        error: "Failed to generate response. Please try again.",
      },
      { status: 500 }
    );
  }
}
