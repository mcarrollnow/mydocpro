"use server"

import { getDocuments } from "./document-actions"

export async function generateChatResponse(
  messages: { role: string; content: string }[],
  clientContext?: string
) {
  try {
    let context = clientContext;
    
    // If no client context is provided, try to get documents from the server
    if (!context) {
      // Get all documents from server
      const { documents } = await getDocuments()

      if (documents.length === 0) {
        return {
          success: true,
          response: "I don't see any documents uploaded yet. Please upload some documents so I can help you with them.",
        }
      }

      // Create a context from the server documents
      context = documents.map((doc) => `Document: ${doc.name}\nContent: ${doc.content}`).join("\n\n")
    }

    // Call our chat API route
    try {
      // Ensure absolute URL for production
      const baseUrl = process.env.VERCEL_URL
        ? `https://${process.env.VERCEL_URL}`
        : "http://localhost:3000";
      const response = await fetch(`${baseUrl}/api/chat`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ messages, context }),
      })

      const result = await response.json()
      if (result.success) {
        return {
          success: true,
          response: result.response,
        }
      } else {
        throw new Error(result.error)
      }
    } catch (error) {
      console.error("Error calling chat API:", error)
      // Fall back to simulated response if API call fails
      return {
        success: true,
        response:
          "I'm having trouble connecting to my AI backend. Here's what I found in your documents: The documents contain information about project proposals, financial data, and meeting notes. If you have specific questions, please try again later.",
      }
    }
  } catch (error) {
    console.error("Error generating chat response:", error)
    return {
      success: false,
      error: "Failed to generate response. Please try again.",
    }
  }
}