import { OpenAI } from "openai"
import { NextResponse } from "next/server"

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: Request) {
  const body = await request.json();
  console.log("Payload received:", JSON.stringify(body, null, 2));
  return NextResponse.json({ echo: body });
}
