import { NextResponse } from "next/server"

export async function GET() {
  return NextResponse.json({
    apiKeyExists: !!process.env.OPENAI_API_KEY,
    apiKeyFirstChars: process.env.OPENAI_API_KEY ? process.env.OPENAI_API_KEY.substring(0, 3) + "..." : "not found"
  })
}